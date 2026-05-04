-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_alter_agent_comment_and_profile_sql produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_alter_agent_comment_and_profile_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_AGENT',
    comment='Updated comment',
    profile='new_profile'
) | replace('\n', ' ') | replace('\r', ' ') | trim -%}

select 1 as failure
where not (
    '{{ ddl }}' ilike '%alter agent%TEST_DB.TEST_SCHEMA.MY_AGENT%'
    and '{{ ddl }}' ilike '%SET%'
    and '{{ ddl }}' ilike '%COMMENT%'
    and '{{ ddl }}' ilike '%PROFILE%'
)
