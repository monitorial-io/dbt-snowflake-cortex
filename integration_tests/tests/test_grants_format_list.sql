-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: _grants_format_list produces a correctly formatted SQL list.
-- A passing test returns zero rows.

{%- set input_list = ['PUBLIC', 'MY_SCHEMA', "O'Brien"] -%}
{%- set result = dbt_monitorial_snowflake_cortex._grants_format_list(input_list) -%}
{%- set expected = "'PUBLIC', 'MY_SCHEMA', 'O''Brien'" -%}

select 1 as failure
where '{{ result }}' != '{{ expected }}'
