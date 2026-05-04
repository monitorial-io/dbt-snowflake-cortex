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
) -%}

select 1 as failure
where
    '{{ ddl }}' not like '%create or replace cortex search service%TEST_DB.TEST_SCHEMA.MY_SEARCH%'
    or '{{ ddl }}' not like '%TEXT INDEXES title, body%'
    or '{{ ddl }}' not like '%VECTOR INDEXES embedding USING e5-base-v2%'
    or '{{ ddl }}' not like '%PRIMARY KEY%doc_id%'
    or '{{ ddl }}' not like '%ATTRIBUTES author, date%'
    or '{{ ddl }}' not like '%WAREHOUSE = COMPUTE_WH%'
    or '{{ ddl }}' not like "%TARGET_LAG = '1 day'%"
    or '{{ ddl }}' not like '%REFRESH_MODE = FULL%'
    or '{{ ddl }}' not like '%FULL_INDEX_BUILD_INTERVAL_DAYS = 14%'
