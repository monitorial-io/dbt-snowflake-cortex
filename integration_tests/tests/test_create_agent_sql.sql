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
) | trim -%}

{%- set assertions = [] -%}
{%- if 'create or replace agent' not in ddl | lower -%}
    {%- do assertions.append('missing CREATE OR REPLACE AGENT') -%}
{%- endif -%}
{%- if 'TEST_DB.TEST_SCHEMA.MY_AGENT' not in ddl -%}
    {%- do assertions.append('missing relation name') -%}
{%- endif -%}
{%- if 'FROM SPECIFICATION' not in ddl -%}
    {%- do assertions.append('missing FROM SPECIFICATION') -%}
{%- endif -%}
{%- if 'name: my_agent' not in ddl -%}
    {%- do assertions.append('missing specification content') -%}
{%- endif -%}

{%- if assertions | length > 0 -%}
    {{ exceptions.raise_compiler_error('test_create_agent_sql FAILED: ' ~ assertions | join(', ') ~ '\nActual DDL:\n' ~ ddl) }}
{%- endif -%}

select 1 where false
