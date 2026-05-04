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
) -%}

select 1 as failure
where
    '{{ ddl }}' not like '%create or replace agent%TEST_DB.TEST_SCHEMA.MY_AGENT%'
    or '{{ ddl }}' not like '%COMMENT =%Test agent%'
    or '{{ ddl }}' not like '%PROFILE =%default_profile%'
    or '{{ ddl }}' not like '%FROM SPECIFICATION%'
    or '{{ ddl }}' not like '%name: my_agent%'
