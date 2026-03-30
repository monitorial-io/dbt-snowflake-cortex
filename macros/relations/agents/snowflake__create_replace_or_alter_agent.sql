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
    {%- set append_environment_to_comment = config.get('append_environment_to_comment', default=true) -%}
    {%- set identifier = model['alias'] -%}

    {%- if not specification -%}
        {# Use the model's SQL content as the specification #}
        {%- set specification = sql -%}
        {%- if not specification -%}
            {{ exceptions.raise_compiler_error("Must specify either 'specification' or put the YAML specification as the model's SQL content.") }}
        {%- endif -%}
    {%- endif -%}

    {% if create_or_replace %}
        {% set create_statement = "create or replace agent" %}
    {% else %}
        {% set create_statement = "create agent if not exists" %}
    {% endif %}

    {%- if append_environment_to_comment and target.name != 'prod' -%}
        {%- set comment = (_raw_comment ~ ' [' ~ target.name ~ ']') if _raw_comment else '[' ~ target.name ~ ']' -%}
    {%- else -%}
        {%- set comment = _raw_comment -%}
    {%- endif -%}

    {% set existing_relation = load_relation(this) %}
    {%- set target_relation = api.Relation.create(identifier=identifier, schema=schema, database=database) -%}

    {{ run_hooks(pre_hooks) }}

    {% set statements = [] %}

    {% if create_or_replace or not existing_relation %}
        {% if existing_relation %}
            {{ log("Relation already exists at {}. It will be replaced.".format(existing_relation), info=True) }}
        {% endif %}
        {% call statement('main') -%}
            {{ dbt_monitorial_snowflake_cortex.snowflake__get_create_agent_sql(target_relation, create_statement, comment, profile, specification) }}
        {%- endcall %}
    {% else %}
        {% call statement('main') -%}
            {{ dbt_monitorial_snowflake_cortex.snowflake__get_alter_agent_comment_and_profile_sql(target_relation, comment, profile) }}
        {% endcall %}
        {% call statement('main') -%}
            {{ dbt_monitorial_snowflake_cortex.snowflake__get_alter_agent_specification_sql(target_relation, specification) }}
        {% endcall %}
    {% endif %}

    {{ run_hooks(post_hooks) }}

    {{ return({'relations': [target_relation]}) }}

{% endmacro %}