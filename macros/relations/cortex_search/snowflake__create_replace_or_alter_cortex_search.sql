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

{% macro snowflake__create_replace_or_alter_cortex_search() %}
    {# Shared params #}
    {%- set comment                       = dbt_monitorial_snowflake_cortex.config_meta_get('comment') -%}
    {%- set attributes                    = dbt_monitorial_snowflake_cortex.config_meta_get('attributes', []) -%}
    {%- set primary_key                   = dbt_monitorial_snowflake_cortex.config_meta_get('primary_key') -%}
    {%- set warehouse                     = dbt_monitorial_snowflake_cortex.config_meta_get('warehouse') -%}
    {%- set target_lag                    = dbt_monitorial_snowflake_cortex.config_meta_get('target_lag') -%}
    {%- set refresh_mode                  = dbt_monitorial_snowflake_cortex.config_meta_get('refresh_mode') -%}
    {%- set initialize                    = dbt_monitorial_snowflake_cortex.config_meta_get('initialize') -%}
    {%- set full_index_build_interval_days = dbt_monitorial_snowflake_cortex.config_meta_get('full_index_build_interval_days') -%}
    {%- set create_or_replace             = dbt_monitorial_snowflake_cortex.config_meta_get('create_or_replace', false) -%}
    {%- set identifier                    = model['alias'] -%}

    {# Form 1 params (ON <search_column>) #}
    {%- set search_column   = dbt_monitorial_snowflake_cortex.config_meta_get('search_column') -%}
    {%- set embedding_model = dbt_monitorial_snowflake_cortex.config_meta_get('embedding_model') -%}

    {# Form 2 params (TEXT INDEXES / VECTOR INDEXES) #}
    {%- set text_indexes   = dbt_monitorial_snowflake_cortex.config_meta_get('text_indexes') -%}
    {%- set vector_indexes = dbt_monitorial_snowflake_cortex.config_meta_get('vector_indexes') -%}

    {# Determine which form to use #}
    {%- set use_form2 = text_indexes and text_indexes | length > 0 -%}

    {# Validate required params #}
    {%- if not use_form2 and not search_column -%}
        {{ exceptions.raise_compiler_error(
            "'search_column' is required for cortex_search materialization "
            ~ "when not using text_indexes/vector_indexes form."
        ) }}
    {%- endif -%}
    {%- if use_form2 and search_column -%}
        {{ exceptions.raise_compiler_error("'search_column' and 'text_indexes' are mutually exclusive. Use one form or the other.") }}
    {%- endif -%}
    {%- if not warehouse -%}
        {{ exceptions.raise_compiler_error("'warehouse' is required for cortex_search materialization.") }}
    {%- endif -%}
    {%- if not target_lag -%}
        {{ exceptions.raise_compiler_error("'target_lag' is required for cortex_search materialization. E.g. '1 day'.") }}
    {%- endif -%}

    {# The model SQL body is always the AS query, enabling ref() / source() for lineage #}
    {%- set query = sql -%}
    {%- if not query or query | trim == '' -%}
        {{ exceptions.raise_compiler_error(
            "cortex_search models must contain a SELECT query as the SQL body. "
            ~ "Use ref() or source() to define the source data."
        ) }}
    {%- endif -%}

    {# Form 2 does not support IF NOT EXISTS #}
    {% if create_or_replace %}
        {% set create_statement = "create or replace cortex search service" %}
    {% elif use_form2 %}
        {% set create_statement = "create cortex search service" %}
    {% else %}
        {% set create_statement = "create cortex search service if not exists" %}
    {% endif %}

    {% set existing_relation = load_relation(this) %}
    {%- set target_relation = api.Relation.create(identifier=identifier, schema=schema, database=database) -%}

    {{ run_hooks(pre_hooks) }}

    {% if create_or_replace or not existing_relation %}
        {% if existing_relation %}
            {{ log("Relation already exists at {}. It will be replaced.".format(existing_relation), info=True) }}
        {% endif %}
        {% if use_form2 %}
            {% call statement('main') -%}
                {{ dbt_monitorial_snowflake_cortex.snowflake__get_create_cortex_search_indexes_sql(
                    target_relation, create_statement, text_indexes, vector_indexes,
                    primary_key, attributes, warehouse, target_lag,
                    refresh_mode, initialize, full_index_build_interval_days, comment, query
                ) }}
            {%- endcall %}
        {% else %}
            {% call statement('main') -%}
                {{ dbt_monitorial_snowflake_cortex.snowflake__get_create_cortex_search_sql(
                    target_relation, create_statement, search_column, primary_key, attributes,
                    warehouse, target_lag, embedding_model,
                    refresh_mode, initialize, full_index_build_interval_days, comment, query
                ) }}
            {%- endcall %}
        {% endif %}
    {% else %}
        {% call statement('main') -%}
            {{ dbt_monitorial_snowflake_cortex.snowflake__get_alter_cortex_search_set_sql(
                target_relation, warehouse, target_lag, primary_key,
                full_index_build_interval_days, comment
            ) }}
        {%- endcall %}
    {% endif %}

    {{ run_hooks(post_hooks) }}

    {{ return({'relations': [target_relation]}) }}

{% endmacro %}
