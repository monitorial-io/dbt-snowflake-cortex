# dbt-snowflake-cortex
The DBT package to support Snowflake Agents as a new materialization.

This [dbt](https://github.com/dbt-labs/dbt) package contains snowflake cortex related materalizations and macros that can be (re)used across dbt projects.

> require-dbt-version: [">=1.9.0", "<2.0.0"]
----

## Installation Instructions
Add the following to your packages.yml file
```
  - git: https://github.com/monitorial-io/dbt-snowflake-cortex.git
    revision: "1.0.0"
```

## Contents

Contains the following materializations for Snowflake:
* Snowflake Agent
* Snowflake Cortex Search

Contains the following macros for Snowflake:
* grant_semantic_views_privileges
* grant_agent_usage
* grant_cortex_search_usage
* grant_cortex_ownership

---

## Macro Reference

### grant_semantic_views_privileges
**Description:**
Grants SELECT privileges on all semantic views in eligible schemas to specified roles. Excludes schemas as needed.

**Parameters:**
- `exclude_schemas` (list): Schemas to exclude from processing. Optional.
- `grant_roles` (list): Roles to grant SELECT privileges to. Required.

**Example Usage:**
```sql
{% do dbt_monitorial_snowflake_cortex.grant_semantic_views_privileges(['EXCLUDED_SCHEMA'], ['ANALYST_ROLE', 'DATA_SCIENTIST']) %}
```

---

### grant_agent_usage
**Description:**
Grants USAGE privileges on all agents in eligible schemas to specified roles. Excludes schemas as needed.

**Parameters:**
- `exclude_schemas` (list): Schemas to exclude from processing. Optional.
- `grant_roles` (list): Roles to grant USAGE privileges to. Required.

**Example Usage:**
```sql
{% do dbt_monitorial_snowflake_cortex.grant_agent_usage(['EXCLUDED_SCHEMA'], ['ANALYST_ROLE', 'DATA_SCIENTIST']) %}
```

---

### grant_cortex_ownership
**Description:**
Grants OWNERSHIP on semantic views, agents, and Cortex Search services to a specified role, across all eligible schemas in the target database.

**Parameters:**
- `exclude_schemas` (list): Schemas to exclude from processing. Optional.
- `role_name` (str): Role to grant ownership to. Required.

**Example Usage:**
```sql
{% do dbt_monitorial_snowflake_cortex.grant_cortex_ownership(['EXCLUDED_SCHEMA'], 'ADMIN_ROLE') %}
```

---


### grant_cortex_search_usage
**Description:**
Grants USAGE privileges on all Cortex Search services in eligible schemas to specified roles. Revokes USAGE from any roles not in the list.

**Parameters:**
- `exclude_schemas` (list): Schemas to exclude from processing. Optional.
- `grant_roles` (list): Roles to grant USAGE privileges to. Required.

**Example Usage:**
```sql
{% do dbt_monitorial_snowflake_cortex.grant_cortex_search_usage(['EXCLUDED_SCHEMA'], ['ANALYST_ROLE', 'DATA_SCIENTIST']) %}
```

---


# Snowflake Agent Materialization

This materialization allows you to create and manage Snowflake Cortex Agents using dbt.

## Usage

### YAML Specification as SQL Content (Recommended)

For the cleanest approach, you can put the YAML specification directly as the model's SQL content:

```sql
{{
    config(
        materialized='agent',
        comment='Description of your agent',
        profile='{"display_name": "Agent Name", "avatar": "icon.png", "color": "blue"}'
    )
}}

models:
  orchestration: claude-4-sonnet

orchestration:
  budget:
    seconds: 30
    tokens: 16000

instructions:
  response: "Your response instructions"
  orchestration: "Your orchestration instructions"
  system: "Your system instructions"

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "AnalystTool"
      description: "Tool description"

tool_resources:
  AnalystTool:
    semantic_view: "database.schema.view_name"
```


**Run normally:**
```bash
dbt run --models my_agent
```

## Configuration Parameters

| Parameter                       | Description                                                | Required | Default |
|---------------------------------|------------------------------------------------------------|----------|---------|
| `materialized`                  | Must be set to `'agent'`                                   | Yes      | -       |
| `comment`                       | Description of the agent                                   | No       | None    |
| `profile`                       | JSON string containing display name, avatar, and color     | No       | None    |
| `append_environment_to_comment` | Specifies if to append the environment name to the comment | No       | true    |


## Profile Object

The profile parameter should be a JSON string with the following structure:
```json
{
  "display_name": "Agent Display Name",
  "avatar": "image-file.png",
  "color": "blue"
}
```

## Specification Object

The specification parameter contains the agent's YAML configuration including:

- **models**: Model configuration (e.g., `orchestration: claude-4-sonnet`)
- **orchestration**: Budget constraints (seconds, tokens)
- **instructions**: Response, orchestration, and system instructions
- **tools**: Array of available tools for the agent
- **tool_resources**: Configuration for each tool

For complete specification format, see the [Snowflake Agent documentation](https://docs.snowflake.com/en/sql-reference/sql/create-agent).

## Examples

- `docs/models/agents_example/my_business_agent.sql` - Example using YAML as SQL content
- `docs/models/cortex_search_example/my_product_search.sql` - Example cortex search configuration

## Requirements

- Snowflake account with Cortex functionality enabled
- Appropriate privileges to create agents in the target schema
- Access to any semantic views or search services referenced in tool_resources


# Snowflake Cortex Search Materialization

This materialization creates and manages Snowflake Cortex Search services using dbt. The model's SQL body is the `AS <query>` clause, so `ref()` and `source()` work normally for lineage tracking. Two CREATE forms are supported.

## Form 1: `ON <search_column>` (text search)

Use this form to create a full-text search index on a single text column.

```sql
{{
    config(
        materialized='cortex_search',
        warehouse='COMPUTE_WH',
        search_column='description',
        attributes=['product_name', 'category'],
        target_lag='1 day',
        comment='Product catalog search'
    )
}}

SELECT
    product_name,
    description,
    category
FROM {{ ref('products') }}
```

## Form 2: `TEXT INDEXES` / `VECTOR INDEXES`

Use this form to index multiple text or vector columns. Supply `text_indexes` instead of `search_column`.

```sql
{{
    config(
        materialized='cortex_search',
        warehouse='COMPUTE_WH',
        text_indexes=['title', 'body'],
        vector_indexes=['embedding'],
        attributes=['category', 'author'],
        primary_key=['doc_id'],
        target_lag='6 hours'
    )
}}

SELECT
    doc_id,
    title,
    body,
    embedding,
    category,
    author
FROM {{ ref('documents') }}
```

## Configuration Parameters

### Shared parameters

| Parameter                        | Description                                        | Required | Default |
|----------------------------------|----------------------------------------------------|----------|---------|
| `materialized`                   | Must be `'cortex_search'`                          | Yes      | -       |
| `warehouse`                      | Warehouse used to build and refresh the index      | Yes      | -       |
| `target_lag`                     | Refresh frequency, e.g. `'1 day'`, `'6 hours'`     | Yes      | -       |
| `attributes`                     | Columns available for filtering/retrieval          | No       | `[]`    |
| `primary_key`                    | Primary key column(s), e.g. `['id']`               | No       | None    |
| `refresh_mode`                   | `FULL` or `INCREMENTAL`                            | No       | None    |
| `initialize`                     | `ON_CREATE` or `ON_SCHEDULE`                       | No       | None    |
| `full_index_build_interval_days` | Override for full rebuild interval                 | No       | None    |
| `comment`                        | Description of the service                         | No       | None    |
| `create_or_replace`              | Use `CREATE OR REPLACE` instead of `IF NOT EXISTS` | No       | `false` |

### Form 1 only

| Parameter         | Description                                                 | Required |
|-------------------|-------------------------------------------------------------|----------|
| `search_column`   | Column to build the full-text search index on (`ON` clause) | Yes      |
| `embedding_model` | Embedding model name                                        | No       |

### Form 2 only

| Parameter        | Description                             | Required |
|------------------|-----------------------------------------|----------|
| `text_indexes`   | Text column(s) to index                 | Yes      |
| `vector_indexes` | Vector column specification(s) to index | No       |

> `search_column` and `text_indexes` are mutually exclusive.

## Alter behaviour

On subsequent `dbt run` calls (when `create_or_replace=false` and the service already exists), only the mutable properties are updated via `ALTER ... SET`: `warehouse`, `target_lag`, `primary_key`, `full_index_build_interval_days`, and `comment`. Changes to `search_column`, `attributes`, `text_indexes`, `vector_indexes`, or the AS query require `create_or_replace=true`.

## Utility ALTER macros

These macros are available for use in run-operations:

```sql
-- Suspend / resume (scope: INDEXING or SERVING, or omit for both)
{% do dbt_monitorial_snowflake_cortex.snowflake__get_alter_cortex_search_suspend_resume_sql(this, 'SUSPEND', 'INDEXING') %}

-- Force an immediate refresh
{% do dbt_monitorial_snowflake_cortex.snowflake__get_alter_cortex_search_refresh_sql(this) %}

-- Remove the primary key
{% do dbt_monitorial_snowflake_cortex.snowflake__get_alter_cortex_search_unset_sql(this, unset_primary_key=true) %}

-- Add / drop a scoring profile
{% do dbt_monitorial_snowflake_cortex.snowflake__get_alter_cortex_search_add_scoring_profile_sql(this, 'my_profile', scoring_profile, if_not_exists=true) %}
{% do dbt_monitorial_snowflake_cortex.snowflake__get_alter_cortex_search_drop_scoring_profile_sql(this, 'my_profile', if_exists=true) %}
```

## Requirements for Cortex Search

- Snowflake account with Cortex Search functionality enabled
- Appropriate privileges to create Cortex Search services in the target schema
- Access to the source table or view specified in configuration
- Valid warehouse with appropriate compute resources