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

{% macro snowflake__get_create_cortex_search_sql(relation, create_statement, search_column, primary_key, attributes, warehouse, target_lag, embedding_model, refresh_mode, initialize, full_index_build_interval_days, comment, query) -%}
{#-
--  Produce DDL for CREATE CORTEX SEARCH SERVICE (Form 1: ON <search_column>).
--
--  Args:
--  - relation: Union[SnowflakeRelation, str]
--  - create_statement: str - "create [or replace] cortex search service [if not exists]"
--  - search_column: str - column to build the full-text search index on (ON clause)
--  - primary_key: list[str] | None - optional primary key column(s)
--  - attributes: list[str] | None - additional columns for filtering/retrieval
--  - warehouse: str - warehouse used to refresh the search index
--  - target_lag: str - refresh frequency, e.g. "1 day" (no DOWNSTREAM support)
--  - embedding_model: str | None - optional embedding model name
--  - refresh_mode: str | None - FULL or INCREMENTAL
--  - initialize: str | None - ON_CREATE or ON_SCHEDULE
--  - full_index_build_interval_days: int | None - optional rebuild interval
--  - comment: str | None - optional comment
--  - query: str - the AS <query> source data
-#}

  {{ create_statement }} {{ relation }}
    ON {{ search_column }}
    {%- if primary_key and primary_key | length > 0 %}
    PRIMARY KEY ( {{ primary_key | join(', ') }} )
    {%- endif %}
    {%- if attributes and attributes | length > 0 %}
    ATTRIBUTES {{ attributes | join(', ') }}
    {%- endif %}
    WAREHOUSE = {{ warehouse }}
    TARGET_LAG = '{{ target_lag }}'
    {%- if embedding_model %}
    EMBEDDING_MODEL = {{ embedding_model }}
    {%- endif %}
    {%- if refresh_mode %}
    REFRESH_MODE = {{ refresh_mode }}
    {%- endif %}
    {%- if initialize %}
    INITIALIZE = {{ initialize }}
    {%- endif %}
    {%- if full_index_build_interval_days is not none %}
    FULL_INDEX_BUILD_INTERVAL_DAYS = {{ full_index_build_interval_days }}
    {%- endif %}
    {%- if comment %}
    COMMENT = '{{ comment }}'
    {%- endif %}
    AS
{{ query | indent(4, false) }};

{%- endmacro %}


{% macro snowflake__get_create_cortex_search_indexes_sql(relation, create_statement, text_indexes, vector_indexes, primary_key, attributes, warehouse, target_lag, refresh_mode, initialize, full_index_build_interval_days, comment, query) -%}
{#-
--  Produce DDL for CREATE CORTEX SEARCH SERVICE (Form 2: TEXT INDEXES / VECTOR INDEXES).
--
--  Args:
--  - relation: Union[SnowflakeRelation, str]
--  - create_statement: str - "create [or replace] cortex search service"
--      (note: IF NOT EXISTS is not valid for Form 2)
--  - text_indexes: list[str] - text column names to index
--  - vector_indexes: list[str] | None - vector column specifications to index
--  - primary_key: list[str] | None - optional primary key column(s)
--  - attributes: list[str] | None - additional columns for filtering/retrieval
--  - warehouse: str - warehouse used to refresh the search index
--  - target_lag: str - refresh frequency, e.g. "1 day"
--  - refresh_mode: str | None - FULL or INCREMENTAL
--  - initialize: str | None - ON_CREATE or ON_SCHEDULE
--  - full_index_build_interval_days: int | None - optional rebuild interval
--  - comment: str | None - optional comment
--  - query: str - the AS <query> source data
-#}

  {{ create_statement }} {{ relation }}
    TEXT INDEXES {{ text_indexes | join(', ') }}
    {%- if vector_indexes and vector_indexes | length > 0 %}
    VECTOR INDEXES {{ vector_indexes | join(', ') }}
    {%- endif %}
    {%- if primary_key and primary_key | length > 0 %}
    PRIMARY KEY ( {{ primary_key | join(', ') }} )
    {%- endif %}
    {%- if attributes and attributes | length > 0 %}
    ATTRIBUTES {{ attributes | join(', ') }}
    {%- endif %}
    WAREHOUSE = {{ warehouse }}
    TARGET_LAG = '{{ target_lag }}'
    {%- if refresh_mode %}
    REFRESH_MODE = {{ refresh_mode }}
    {%- endif %}
    {%- if initialize %}
    INITIALIZE = {{ initialize }}
    {%- endif %}
    {%- if full_index_build_interval_days is not none %}
    FULL_INDEX_BUILD_INTERVAL_DAYS = {{ full_index_build_interval_days }}
    {%- endif %}
    {%- if comment %}
    COMMENT = '{{ comment }}'
    {%- endif %}
    AS
{{ query | indent(4, false) }};

{%- endmacro %}
