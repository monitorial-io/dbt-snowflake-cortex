-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake__get_alter_agent_comment_and_profile_sql produces correct DDL.
-- A passing test returns zero rows.

{%- set ddl = dbt_monitorial_snowflake_cortex.snowflake__get_alter_agent_comment_and_profile_sql(
    relation='TEST_DB.TEST_SCHEMA.MY_AGENT',
    comment='Updated comment',
    profile='new_profile'
) -%}

select 1 as failure
where
    '{{ ddl }}' not like '%alter agent%TEST_DB.TEST_SCHEMA.MY_AGENT%'
    or '{{ ddl }}' not like '%SET%'
    or '{{ ddl }}' not like '%COMMENT =%Updated comment%'
    or '{{ ddl }}' not like '%PROFILE =%new_profile%'
