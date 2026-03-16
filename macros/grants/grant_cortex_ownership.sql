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

{% macro grant_cortex_ownership(exclude_schemas, role_name) %}
    {# Maintain signature & invocation semantics; use helpers for clarity and efficiency #}
    {% if flags.WHICH not in ['run', 'run-operation'] %}
        {% do log('Skipping grant_cortex_ownership: not run/run-operation context', info=True) %}
        {% do return(none) %}
    {% endif %}
    {% if not execute %}
        {% do log('Skipping grant_cortex_ownership: compile phase only', info=True) %}
        {% do return(none) %}
    {% endif %}

    {% if exclude_schemas is not iterable %}
        {% set exclude_schemas = [] %}
    {% endif %}
    {% if 'INFORMATION_SCHEMA' not in exclude_schemas %}
        {% do exclude_schemas.append('INFORMATION_SCHEMA') %}
    {% endif %}

    {% set include_schemas = dbt_monitorial_snowflake_cortex._grants_collect_schemas(exclude_schemas) %}
    {% if include_schemas | length == 0 %}
        {% do log('No schemas eligible for ownership processing in ' ~ target.database, info=True) %}
        {% do return(none) %}
    {% endif %}

    {% set formatted_schema_list = dbt_monitorial_snowflake_cortex._grants_format_list(include_schemas) %}
    {% set queries = [] %}
    {% do log('Verifying Ownership rights across ' ~ (include_schemas | length) ~ ' schemas in ' ~ target.database ~ ' for role ' ~ role_name, info=True) %}

    {% do queries.extend(dbt_monitorial_snowflake_cortex.grant_semantic_view_ownership(formatted_schema_list, role_name)) %}
    {% do queries.extend(dbt_monitorial_snowflake_cortex.get_grant_agent_ownership(formatted_schema_list, role_name)) %}


    {% if queries | length == 0 %}
        {% do log('No ownership grant statements generated (all objects already owned by ' ~ role_name ~ ')', info=True) %}
        {% do return(none) %}
    {% endif %}

    {% do log('Executing ' ~ (queries | length) ~ ' ownership grant statements for role ' ~ role_name, info=True) %}
    {% for q in queries %}
        {% if q %}
            {% set _ = run_query(q) %}
        {% endif %}
    {% endfor %}
    {% do log('Completed ownership grants for role ' ~ role_name, info=True) %}
    {% do return(none) %}
{% endmacro %}
