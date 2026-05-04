-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_create_cortex_search_sql (Form 1) produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_create_cortex_search_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_SEARCH',
    create_statement='create or replace cortex search service',
    search_column='description',
    primary_key=['id'],
    attributes=['name', 'category'],
    warehouse='COMPUTE_WH',
    target_lag='1 day',
    embedding_model='e5-base-v2',
    refresh_mode='INCREMENTAL',
    initialize='ON_CREATE',
    full_index_build_interval_days=7,
    comment='Test search service',
    query='select id, description, name, category from products'
) | trim -%}

{%- set assertions = [] -%}
{%- if 'create or replace cortex search service' not in ddl | lower -%}
    {%- do assertions.append('missing CREATE OR REPLACE CORTEX SEARCH SERVICE') -%}
{%- endif -%}
{%- if 'TEST_DB.TEST_SCHEMA.MY_SEARCH' not in ddl -%}
    {%- do assertions.append('missing relation name') -%}
{%- endif -%}
{%- if 'ON description' not in ddl -%}
    {%- do assertions.append('missing ON search_column') -%}
{%- endif -%}
{%- if 'WAREHOUSE = COMPUTE_WH' not in ddl -%}
    {%- do assertions.append('missing WAREHOUSE') -%}
{%- endif -%}
{%- if 'EMBEDDING_MODEL = e5-base-v2' not in ddl -%}
    {%- do assertions.append('missing EMBEDDING_MODEL') -%}
{%- endif -%}
{%- if 'REFRESH_MODE = INCREMENTAL' not in ddl -%}
    {%- do assertions.append('missing REFRESH_MODE') -%}
{%- endif -%}

{%- if assertions | length > 0 -%}
    {{ exceptions.raise_compiler_error('test_create_cortex_search_sql FAILED: ' ~ assertions | join(', ') ~ '\nActual DDL:\n' ~ ddl) }}
{%- endif %}
select 1 where 1 = 0
