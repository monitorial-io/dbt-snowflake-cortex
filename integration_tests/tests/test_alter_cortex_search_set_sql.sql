-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_alter_cortex_search_set_sql produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_alter_cortex_search_set_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_SEARCH',
    warehouse='NEW_WH',
    target_lag='2 days',
    primary_key=['new_pk'],
    full_index_build_interval_days=30,
    comment='Updated search service'
) -%}

select 1 as failure
where
    '{{ ddl }}' not like '%alter cortex search service if exists%TEST_DB.TEST_SCHEMA.MY_SEARCH%set%'
    or '{{ ddl }}' not like '%WAREHOUSE = NEW_WH%'
    or '{{ ddl }}' not like "%TARGET_LAG = '2 days'%"
    or '{{ ddl }}' not like '%PRIMARY KEY%new_pk%'
    or '{{ ddl }}' not like '%FULL_INDEX_BUILD_INTERVAL_DAYS = 30%'
    or '{{ ddl }}' not like '%COMMENT =%Updated search service%'
