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
) -%}

select 1 as failure
where
    '{{ ddl }}' not like '%create or replace cortex search service%TEST_DB.TEST_SCHEMA.MY_SEARCH%'
    or '{{ ddl }}' not like '%ON description%'
    or '{{ ddl }}' not like '%PRIMARY KEY%id%'
    or '{{ ddl }}' not like '%ATTRIBUTES name, category%'
    or '{{ ddl }}' not like '%WAREHOUSE = COMPUTE_WH%'
    or '{{ ddl }}' not like "%TARGET_LAG = '1 day'%"
    or '{{ ddl }}' not like '%EMBEDDING_MODEL = e5-base-v2%'
    or '{{ ddl }}' not like '%REFRESH_MODE = INCREMENTAL%'
    or '{{ ddl }}' not like '%INITIALIZE = ON_CREATE%'
    or '{{ ddl }}' not like '%FULL_INDEX_BUILD_INTERVAL_DAYS = 7%'
    or '{{ ddl }}' not like '%select id, description, name, category from products%'
