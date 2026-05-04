-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_drop_agent_sql produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_drop_agent_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_AGENT'
) | trim -%}

{%- set assertions = [] -%}
{%- if 'drop agent if exists' not in ddl | lower -%}
    {%- do assertions.append('missing DROP AGENT IF EXISTS') -%}
{%- endif -%}
{%- if 'TEST_DB.TEST_SCHEMA.MY_AGENT' not in ddl -%}
    {%- do assertions.append('missing relation name') -%}
{%- endif -%}

{%- if assertions | length > 0 -%}
    {{ exceptions.raise_compiler_error('test_drop_agent_sql FAILED: ' ~ assertions | join(', ') ~ '\nActual DDL:\n' ~ ddl) }}
{%- endif -%}

select 1 where false
