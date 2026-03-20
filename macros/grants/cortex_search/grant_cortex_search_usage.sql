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

{% macro grant_cortex_search_usage(exclude_schemas, grant_roles) %}
    {% if flags.WHICH not in ['run', 'run-operation'] %}
        {% do log('Skipping grant_cortex_search_usage: not run/run-operation context', info=True) %}
        {% do return(none) %}
    {% endif %}
    {% if not execute %}
        {% do log('Skipping grant_cortex_search_usage: compile phase', info=True) %}
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
        {% do log('grant_cortex_search_usage: no schemas to process', info=True) %}
        {% do return(none) %}
    {% endif %}

    {% set snowflake_roles = dbt_monitorial_snowflake_cortex._grants_collect_roles(grant_roles) %}
    {% do log('grant_cortex_search_usage: processing ' ~ (include_schemas | length) ~ ' schemas for roles ' ~ (snowflake_roles | join(', ')), info=True) %}
    {% for schema_name in include_schemas %}
        {% do dbt_monitorial_snowflake_cortex._grant_cortex_search_usage_specific(schema_name, snowflake_roles) %}
    {% endfor %}
{% endmacro %}
