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
) | replace('\n', ' ') | replace('\r', ' ') | trim -%}

select 1 as failure
where not (
    '{{ ddl }}' ilike '%create or replace cortex search service%TEST_DB.TEST_SCHEMA.MY_SEARCH%'
    and '{{ ddl }}' ilike '%TEXT INDEXES title, body%'
    and '{{ ddl }}' ilike '%VECTOR INDEXES embedding USING e5-base-v2%'
    and '{{ ddl }}' ilike '%PRIMARY KEY%doc_id%'
    and '{{ ddl }}' ilike '%WAREHOUSE = COMPUTE_WH%'
    and '{{ ddl }}' ilike '%REFRESH_MODE = FULL%'
)
