-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Test: snowflake_intelligence macro family (add/remove/publish/unpublish/sync) against a real
-- Snowflake Intelligence (CoWork) object, using the test agents built by test_si_agent_opted_in
-- (meta.co_work_targets = [target.name], always opted in) and test_si_agent_not_opted_in (no
-- co_work_targets, never opted in).
--
-- These macros execute live ALTER SNOWFLAKE INTELLIGENCE DDL and guard against running outside a
-- run/build context (see add_snowflake_intelligence_agent), so this test only exercises them when
-- invoked via `dbt build` or `dbt run` + `dbt test` run together under the same invocation -- a
-- plain `dbt test` or `dbt compile` will skip gracefully instead of asserting on state that was
-- never mutated. The test also skips gracefully if the account has no Snowflake Intelligence object.
--
-- Leaves both test agents fully detached at the end, so repeated runs (and CI re-runs) never hit
-- Snowflake's "already present" / "was not found" errors from stale attachment state.
--
-- A passing test returns zero rows.

{%- if flags.WHICH not in ['run', 'build'] -%}

{%- do log('test_snowflake_intelligence_lifecycle: skipping (snowflake_intelligence macros only execute under run/build context) -- run via `dbt build` to exercise this test', info=True) -%}
select 1 where 1 = 0

{%- else -%}

{%- set opted_in = ref('test_si_agent_opted_in') -%}
{%- set not_opted_in = ref('test_si_agent_not_opted_in') -%}
{%- set opted_in_agent = (opted_in.schema ~ '.' ~ opted_in.identifier) | upper -%}
{%- set not_opted_in_agent = (not_opted_in.schema ~ '.' ~ not_opted_in.identifier) | upper -%}
{#- add/remove_snowflake_intelligence_agent take 'SCHEMA.NAME' and prepend target.database
    themselves; SHOW AGENTS IN SNOWFLAKE INTELLIGENCE returns rows with the database as a
    separate column, so attachment checks need the fully-qualified 'DATABASE.SCHEMA.NAME' form. -#}
{%- set opted_in_fqn = (target.database ~ '.' ~ opted_in_agent) | upper -%}
{%- set not_opted_in_fqn = (target.database ~ '.' ~ not_opted_in_agent) | upper -%}

{%- set si_rows = run_query('show snowflake intelligences') -%}
{%- set assertions = [] -%}

{%- if si_rows | length == 0 -%}

{%- do log('test_snowflake_intelligence_lifecycle: skipping (no Snowflake Intelligence object exists in this account)', info=True) -%}
select 1 where 1 = 0

{%- else -%}
{%- set si_name = si_rows[0]['name'] -%}

{%- macro _si_attached(si_name, fqn) -%}
    {%- set rows = run_query('show agents in snowflake intelligence ' ~ si_name) -%}
    {%- set attached = [] -%}
    {%- for row in rows -%}
        {%- do attached.append((row.database_name ~ '.' ~ row.schema_name ~ '.' ~ row.name) | upper) -%}
    {%- endfor -%}
    {{- return(fqn in attached) -}}
{%- endmacro -%}

{#- 1. add_snowflake_intelligence_agent: attach, with a duplicate entry to exercise dedup -#}
{%- do dbt_monitorial_snowflake_cortex.add_snowflake_intelligence_agent(si_name, [opted_in_agent, opted_in_agent]) -%}
{%- if not _si_attached(si_name, opted_in_fqn) -%}
    {%- do assertions.append('add_snowflake_intelligence_agent did not attach ' ~ opted_in_agent) -%}
{%- endif -%}

{#- 1b. calling add again must be a no-op, not an error (already attached) -#}
{%- do dbt_monitorial_snowflake_cortex.add_snowflake_intelligence_agent(si_name, [opted_in_agent]) -%}
{%- if not _si_attached(si_name, opted_in_fqn) -%}
    {%- do assertions.append('second add_snowflake_intelligence_agent call unexpectedly detached ' ~ opted_in_agent) -%}
{%- endif -%}

{#- 2. remove_snowflake_intelligence_agent: detach -#}
{%- do dbt_monitorial_snowflake_cortex.remove_snowflake_intelligence_agent(si_name, [opted_in_agent]) -%}
{%- if _si_attached(si_name, opted_in_fqn) -%}
    {%- do assertions.append('remove_snowflake_intelligence_agent did not detach ' ~ opted_in_agent) -%}
{%- endif -%}

{#- 2b. calling remove again must be a no-op, not an error (not attached) -#}
{%- do dbt_monitorial_snowflake_cortex.remove_snowflake_intelligence_agent(si_name, [opted_in_agent]) -%}
{%- if _si_attached(si_name, opted_in_fqn) -%}
    {%- do assertions.append('second remove_snowflake_intelligence_agent call unexpectedly attached ' ~ opted_in_agent) -%}
{%- endif -%}

{#- 3. seed a stale attachment on the agent that is NOT opted in, simulating a prior manual
      attachment that publish/unpublish must clean up -#}
{%- do dbt_monitorial_snowflake_cortex.add_snowflake_intelligence_agent(si_name, [not_opted_in_agent]) -%}
{%- if not _si_attached(si_name, not_opted_in_fqn) -%}
    {%- do assertions.append('seed add for ' ~ not_opted_in_agent ~ ' failed, cannot test unpublish') -%}
{%- endif -%}

{#- 4. publish_snowflake_intelligence_agents: must attach the opted-in agent and must NOT touch
      the not-opted-in agent (still attached from the seed step) -#}
{{ dbt_monitorial_snowflake_cortex.publish_snowflake_intelligence_agents() }}
{%- if not _si_attached(si_name, opted_in_fqn) -%}
    {%- do assertions.append('publish_snowflake_intelligence_agents did not attach ' ~ opted_in_agent) -%}
{%- endif -%}
{%- if not _si_attached(si_name, not_opted_in_fqn) -%}
    {%- do assertions.append('publish_snowflake_intelligence_agents unexpectedly detached ' ~ not_opted_in_agent) -%}
{%- endif -%}

{#- 5. unpublish_snowflake_intelligence_agents: must detach the not-opted-in agent and must NOT
      touch the opted-in agent (still attached from the publish step) -#}
{{ dbt_monitorial_snowflake_cortex.unpublish_snowflake_intelligence_agents() }}
{%- if _si_attached(si_name, not_opted_in_fqn) -%}
    {%- do assertions.append('unpublish_snowflake_intelligence_agents did not detach ' ~ not_opted_in_agent) -%}
{%- endif -%}
{%- if not _si_attached(si_name, opted_in_fqn) -%}
    {%- do assertions.append('unpublish_snowflake_intelligence_agents unexpectedly detached ' ~ opted_in_agent) -%}
{%- endif -%}

{#- cleanup before testing sync, so sync starts from a known (fully detached) state -#}
{%- do dbt_monitorial_snowflake_cortex.remove_snowflake_intelligence_agent(si_name, [opted_in_agent]) -%}

{#- 6. sync_snowflake_intelligence_agents: publish then unpublish from a clean slate -- the
      opted-in agent must end up attached, the not-opted-in agent must end up (still) detached -#}
{{ dbt_monitorial_snowflake_cortex.sync_snowflake_intelligence_agents() }}
{%- if not _si_attached(si_name, opted_in_fqn) -%}
    {%- do assertions.append('sync_snowflake_intelligence_agents did not attach ' ~ opted_in_agent) -%}
{%- endif -%}
{%- if _si_attached(si_name, not_opted_in_fqn) -%}
    {%- do assertions.append('sync_snowflake_intelligence_agents unexpectedly attached ' ~ not_opted_in_agent) -%}
{%- endif -%}

{#- final cleanup: leave both test agents fully detached regardless of outcome -#}
{%- do dbt_monitorial_snowflake_cortex.remove_snowflake_intelligence_agent(si_name, [opted_in_agent, not_opted_in_agent]) -%}

{%- if assertions | length > 0 -%}
    {{ exceptions.raise_compiler_error('test_snowflake_intelligence_lifecycle FAILED: ' ~ assertions | join('; ')) }}
{%- endif %}
select 1 where 1 = 0

{%- endif -%}
{%- endif -%}
