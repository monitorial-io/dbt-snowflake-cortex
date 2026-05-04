-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_rename_agent_sql produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_rename_agent_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_AGENT',
    new_name='TEST_DB.TEST_SCHEMA.MY_AGENT_V2'
) -%}

select 1 as failure
where
    '{{ ddl }}' not like '%alter agent if exists%TEST_DB.TEST_SCHEMA.MY_AGENT%'
    or '{{ ddl }}' not like '%rename to%TEST_DB.TEST_SCHEMA.MY_AGENT_V2%'
