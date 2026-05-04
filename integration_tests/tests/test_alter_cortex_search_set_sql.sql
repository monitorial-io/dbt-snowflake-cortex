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
) | replace('\n', ' ') | replace('\r', ' ') | trim -%}

select 1 as failure
where not (
    '{{ ddl }}' ilike '%alter cortex search service if exists%TEST_DB.TEST_SCHEMA.MY_SEARCH%set%'
    and '{{ ddl }}' ilike '%WAREHOUSE = NEW_WH%'
    and '{{ ddl }}' ilike '%PRIMARY KEY%new_pk%'
    and '{{ ddl }}' ilike '%FULL_INDEX_BUILD_INTERVAL_DAYS = 30%'
)
