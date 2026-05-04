-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_alter_agent_comment_and_profile_sql produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_alter_agent_comment_and_profile_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_AGENT',
    comment='Updated comment',
    profile='new_profile'
) | trim -%}

{%- set assertions = [] -%}
{%- if 'alter agent' not in ddl | lower -%}
    {%- do assertions.append('missing ALTER AGENT') -%}
{%- endif -%}
{%- if 'TEST_DB.TEST_SCHEMA.MY_AGENT' not in ddl -%}
    {%- do assertions.append('missing relation name') -%}
{%- endif -%}
{%- if 'SET' not in ddl -%}
    {%- do assertions.append('missing SET') -%}
{%- endif -%}
{%- if 'COMMENT' not in ddl -%}
    {%- do assertions.append('missing COMMENT') -%}
{%- endif -%}
{%- if 'PROFILE' not in ddl -%}
    {%- do assertions.append('missing PROFILE') -%}
{%- endif -%}

{%- if assertions | length > 0 -%}
    {{ exceptions.raise_compiler_error('test_alter_agent_sql FAILED: ' ~ assertions | join(', ') ~ '\nActual DDL:\n' ~ ddl) }}
{%- endif %}
select 1 where 1 = 0
