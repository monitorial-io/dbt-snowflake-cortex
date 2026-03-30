-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

{#-
--  ALTER CORTEX SEARCH SERVICE [ IF EXISTS ] <name> SET ...
--  Note: changing query, search_column, attributes, or indexes requires CREATE OR REPLACE.
--
--  Args:
--  - warehouse: str | None
--  - target_lag: str | None - e.g. "1 day"
--  - primary_key: list[str] | None
--  - full_index_build_interval_days: int | None
--  - comment: str | None
-#}
{% macro snowflake__get_alter_cortex_search_set_sql(relation, warehouse, target_lag, primary_key, full_index_build_interval_days, comment) -%}
    alter cortex search service if exists {{ relation }} set
    {%- if warehouse %}
        WAREHOUSE = {{ warehouse }}
    {%- endif %}
    {%- if target_lag %}
        TARGET_LAG = '{{ target_lag }}'
    {%- endif %}
    {%- if primary_key and primary_key | length > 0 %}
        PRIMARY KEY = ( {{ primary_key | join(', ') }} )
    {%- endif %}
    {%- if full_index_build_interval_days is not none %}
        FULL_INDEX_BUILD_INTERVAL_DAYS = {{ full_index_build_interval_days }}
    {%- endif %}
    {%- if comment %}
        COMMENT = '{{ comment | replace("'", "''") }}'
    {%- endif %};
{%- endmacro %}

{#-
--  ALTER CORTEX SEARCH SERVICE [ IF EXISTS ] <name> { SUSPEND | RESUME } [ { INDEXING | SERVING } ]
--
--  Args:
--  - relation: Union[SnowflakeRelation, str]
--  - action: str - SUSPEND or RESUME
--  - scope: str | None - INDEXING or SERVING (omit for both)
-#}
{% macro snowflake__get_alter_cortex_search_suspend_resume_sql(relation, action, scope) -%}
    alter cortex search service if exists {{ relation }} {{ action }}
    {%- if scope %} {{ scope }}{%- endif %};
{%- endmacro %}

{#-
--  ALTER CORTEX SEARCH SERVICE [ IF EXISTS ] <name> REFRESH
-#}
{% macro snowflake__get_alter_cortex_search_refresh_sql(relation) -%}
    alter cortex search service if exists {{ relation }} refresh;
{%- endmacro %}

{#-
--  ALTER CORTEX SEARCH SERVICE [ IF EXISTS ] <name> UNSET [ PRIMARY KEY ]
--
--  Args:
--  - unset_primary_key: bool - whether to unset the primary key
-#}
{% macro snowflake__get_alter_cortex_search_unset_sql(relation, unset_primary_key) -%}
    alter cortex search service if exists {{ relation }} unset
    {%- if unset_primary_key %}
        PRIMARY KEY
    {%- endif %};
{%- endmacro %}

{#-
--  ALTER CORTEX SEARCH SERVICE <name>
--    ADD SCORING PROFILE [ IF NOT EXISTS ] <profile_name>
--    <scoring_profile>
--
--  Args:
--  - profile_name: str
--  - scoring_profile: str - the scoring profile definition
--  - if_not_exists: bool - whether to add IF NOT EXISTS guard
-#}
{% macro snowflake__get_alter_cortex_search_add_scoring_profile_sql(relation, profile_name, scoring_profile, if_not_exists) -%}
    alter cortex search service {{ relation }}
    add scoring profile {% if if_not_exists %}if not exists {% endif %}{{ profile_name }}
    {{ scoring_profile }};
{%- endmacro %}

{#-
--  ALTER CORTEX SEARCH SERVICE <name>
--    DROP SCORING PROFILE [ IF EXISTS ] <profile_name>
--
--  Args:
--  - profile_name: str
--  - if_exists: bool - whether to add IF EXISTS guard
-#}
{% macro snowflake__get_alter_cortex_search_drop_scoring_profile_sql(relation, profile_name, if_exists) -%}
    alter cortex search service {{ relation }}
    drop scoring profile {% if if_exists %}if exists {% endif %}{{ profile_name }};
{%- endmacro %}
