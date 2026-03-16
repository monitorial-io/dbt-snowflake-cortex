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

Contains the following macros for Snowflake:
* grant_semantic_views_privileges
* grant_agent_usage
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
Grants OWNERSHIP on schemas, semantic views, and agents to a specified role, excluding schemas as needed. (Macro file may be named differently; see project macros for exact name.)

**Parameters:**
- `exclude_schemas` (list): Schemas to exclude from processing. Optional.
- `role_name` (str): Role to grant ownership to. Required.

**Example Usage:**
```sql
{% do dbt_monitorial_snowflake_cortex.grant_cortex_ownership(['EXCLUDED_SCHEMA'], 'ADMIN_ROLE') %}
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

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `materialized` | Must be set to `'agent'` | Yes | - |
| `comment` | Description of the agent | No | None |
| `profile` | JSON string containing display name, avatar, and color | No | None |


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

- `models/agents_example/my_business_agent.sql` - Example using YAML as SQL content

## Requirements

- Snowflake account with Cortex functionality enabled
- Appropriate privileges to create agents in the target schema
- Access to any semantic views or search services referenced in tool_resources