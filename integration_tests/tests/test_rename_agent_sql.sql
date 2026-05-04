-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_rename_agent_sql produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_rename_agent_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_AGENT',
    new_name='TEST_DB.TEST_SCHEMA.MY_AGENT_V2'
) | trim -%}

{%- set assertions = [] -%}
{%- if 'alter agent if exists' not in ddl | lower -%}
    {%- do assertions.append('missing ALTER AGENT IF EXISTS') -%}
{%- endif -%}
{%- if 'TEST_DB.TEST_SCHEMA.MY_AGENT' not in ddl -%}
    {%- do assertions.append('missing source relation name') -%}
{%- endif -%}
{%- if 'rename to' not in ddl | lower -%}
    {%- do assertions.append('missing RENAME TO') -%}
{%- endif -%}
{%- if 'TEST_DB.TEST_SCHEMA.MY_AGENT_V2' not in ddl -%}
    {%- do assertions.append('missing target relation name') -%}
{%- endif -%}

{%- if assertions | length > 0 -%}
    {{ exceptions.raise_compiler_error('test_rename_agent_sql FAILED: ' ~ assertions | join(', ') ~ '\nActual DDL:\n' ~ ddl) }}
{%- endif %}
select 1 where 1 = 0
