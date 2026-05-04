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
) | trim -%}

{%- set assertions = [] -%}
{%- if 'alter cortex search service if exists' not in ddl | lower -%}
    {%- do assertions.append('missing ALTER CORTEX SEARCH SERVICE IF EXISTS') -%}
{%- endif -%}
{%- if 'TEST_DB.TEST_SCHEMA.MY_SEARCH' not in ddl -%}
    {%- do assertions.append('missing relation name') -%}
{%- endif -%}
{%- if 'WAREHOUSE = NEW_WH' not in ddl -%}
    {%- do assertions.append('missing WAREHOUSE') -%}
{%- endif -%}
{%- if 'FULL_INDEX_BUILD_INTERVAL_DAYS = 30' not in ddl -%}
    {%- do assertions.append('missing FULL_INDEX_BUILD_INTERVAL_DAYS') -%}
{%- endif -%}

{%- if assertions | length > 0 -%}
    {{ exceptions.raise_compiler_error('test_alter_cortex_search_set_sql FAILED: ' ~ assertions | join(', ') ~ '\nActual DDL:\n' ~ ddl) }}
{%- endif %}
select 1 where 1 = 0
