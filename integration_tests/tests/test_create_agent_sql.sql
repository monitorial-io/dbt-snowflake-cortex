-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_create_agent_sql produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_create_agent_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_AGENT',
    create_statement='create or replace agent',
    comment='Test agent',
    profile='default_profile',
    specification='name: my_agent\nmodel: claude-4-sonnet'
) | replace('\n', ' ') | replace('\r', ' ') | trim -%}

select 1 as failure
where not (
    '{{ ddl }}' ilike '%create or replace agent%TEST_DB.TEST_SCHEMA.MY_AGENT%'
    and '{{ ddl }}' ilike '%FROM SPECIFICATION%'
    and '{{ ddl }}' ilike '%name: my_agent%'
)
