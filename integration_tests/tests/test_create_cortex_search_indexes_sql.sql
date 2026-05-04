-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_create_cortex_search_indexes_sql (Form 2) produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_create_cortex_search_indexes_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_SEARCH',
    create_statement='create or replace cortex search service',
    text_indexes=['title', 'body'],
    vector_indexes=['embedding USING e5-base-v2'],
    primary_key=['doc_id'],
    attributes=['author', 'date'],
    warehouse='COMPUTE_WH',
    target_lag='1 day',
    refresh_mode='FULL',
    initialize='ON_CREATE',
    full_index_build_interval_days=14,
    comment='Test search indexes',
    query='select doc_id, title, body, author, date, embedding from documents'
) | trim -%}

{%- set assertions = [] -%}
{%- if 'create or replace cortex search service' not in ddl | lower -%}
    {%- do assertions.append('missing CREATE OR REPLACE CORTEX SEARCH SERVICE') -%}
{%- endif -%}
{%- if 'TEST_DB.TEST_SCHEMA.MY_SEARCH' not in ddl -%}
    {%- do assertions.append('missing relation name') -%}
{%- endif -%}
{%- if 'TEXT INDEXES title, body' not in ddl -%}
    {%- do assertions.append('missing TEXT INDEXES') -%}
{%- endif -%}
{%- if 'WAREHOUSE = COMPUTE_WH' not in ddl -%}
    {%- do assertions.append('missing WAREHOUSE') -%}
{%- endif -%}
{%- if 'REFRESH_MODE = FULL' not in ddl -%}
    {%- do assertions.append('missing REFRESH_MODE') -%}
{%- endif -%}

{%- if assertions | length > 0 -%}
    {{ exceptions.raise_compiler_error('test_create_cortex_search_indexes_sql FAILED: ' ~ assertions | join(', ') ~ '\nActual DDL:\n' ~ ddl) }}
{%- endif -%}

select 1 where false
