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
) | replace('\n', ' ') | replace('\r', ' ') | trim -%}

select 1 as failure
where not (
    '{{ ddl }}' ilike '%create or replace cortex search service%TEST_DB.TEST_SCHEMA.MY_SEARCH%'
    and '{{ ddl }}' ilike '%ON description%'
    and '{{ ddl }}' ilike '%PRIMARY KEY%id%'
    and '{{ ddl }}' ilike '%WAREHOUSE = COMPUTE_WH%'
    and '{{ ddl }}' ilike '%EMBEDDING_MODEL = e5-base-v2%'
    and '{{ ddl }}' ilike '%REFRESH_MODE = INCREMENTAL%'
)
