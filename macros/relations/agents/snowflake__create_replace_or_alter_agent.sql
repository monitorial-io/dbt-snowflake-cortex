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

{% macro snowflake__create_replace_or_alter_agent() %}
    {%- set comment = config.get('comment', default=none) -%}
    {%- set profile = config.get('profile', default=none) -%}
    {%- set specification = config.get('specification', default=none) -%}
    {%- set create_or_replace = config.get('create_or_replace', default=false) -%}
    {%- set identifier = model['alias'] -%}

    {%- if not specification -%}
        {# Use the model's SQL content as the specification #}
        {%- set specification = sql -%}
        {%- if not specification -%}
            {{ exceptions.raise_compiler_error("Must specify either 'specification' or put the YAML specification as the model's SQL content.") }}
        {%- endif -%}
    {%- endif -%}

    {% if create_or_replace %}
        {% set create_statement = "create or replace" %}
    {% else %}
        {% set create_statement = "create if not exists" %}
    {% endif %}

    {% set existing_relation = load_relation(this) %}
    {%- set target_relation = api.Relation.create(identifier=identifier, schema=schema, database=database, type='agent') -%}

    {{ run_hooks(pre_hooks) }}

    {% set statements = [] %}

    {% if create_or_replace or not existing_relation %}
        {% if existing_relation %}
            {{ log("Relation already exists at {}. It will be replaced.".format(existing_relation), info=True) }}
        {% endif %}
        {% do statements.append(dbt_monitorial_snowflake_cortex.snowflake__get_create_agent_sql(target_relation, comment, profile, specification)) %}
    {% else %}
        {% do statements.append(dbt_monitorial_snowflake_cortex.snowflake__get_alter_agent_comment_and_profile_sql(target_relation, comment, profile)) %}
        {% do statements.append(dbt_monitorial_snowflake_cortex.snowflake__get_alter_agent_specification_sql(target_relation, specification)) %}
    {% endif %}
    -- build model
    {% for statement in statements %}
        {% call statement('main') -%}
            {{ statement }}
        {%- endcall %}
    {% endfor %}

    {{ run_hooks(post_hooks) }}

    {{ return({'relations': [target_relation]}) }}

{% endmacro %}