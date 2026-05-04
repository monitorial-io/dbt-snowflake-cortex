-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: _grants_format_list produces a correctly formatted SQL list.
-- A passing test returns zero rows.

{%- set result = dbt_monitorial_snowflake_cortex._grants_format_list(['PUBLIC', 'MY_SCHEMA']) | trim -%}

{%- set assertions = [] -%}
{%- if "'PUBLIC'" not in result -%}
    {%- do assertions.append('missing PUBLIC') -%}
{%- endif -%}
{%- if "'MY_SCHEMA'" not in result -%}
    {%- do assertions.append('missing MY_SCHEMA') -%}
{%- endif -%}

{%- if assertions | length > 0 -%}
    {{ exceptions.raise_compiler_error('test_grants_format_list FAILED: ' ~ assertions | join(', ') ~ '\nActual result:\n' ~ result) }}
{%- endif %}
select 1 where 1 = 0
