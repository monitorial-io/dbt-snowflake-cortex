-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_drop_agent_sql produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_drop_agent_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_AGENT'
) | replace('\n', ' ') | replace('\r', ' ') | trim -%}

select 1 as failure
where not (
    '{{ ddl }}' ilike '%drop agent if exists%TEST_DB.TEST_SCHEMA.MY_AGENT%'
)
