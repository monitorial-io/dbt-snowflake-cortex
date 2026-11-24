# dbt-snowflake-cortex Changelog

## 1.4.0 - 2026-11-24 - dbt v2 (Fusion) Support & Snowflake Intelligence Integration

* loosened `require-dbt-version` upper bound from 2.0.0 to 3.0.0 so the package can be installed against dbt v2 (Fusion) 2.0.x runtimes
* fixed a missing comma in the README's recommended `agent` materialization config example
* documented and added `static_analysis='off'` to the `agent` YAML-as-SQL-content example, which avoids a non-fatal dbt v2 (Fusion) static SQL-analysis warning on model bodies that are YAML rather than SQL
* added `add_snowflake_intelligence_agent` and `remove_snowflake_intelligence_agent` macros to attach/detach Cortex Agents from a Snowflake Intelligence (CoWork) object
* added `publish_snowflake_intelligence_agents` macro to attach every agent model opted in via `meta.co_work_targets` for the current target, intended for use as an `on-run-end` hook
* added `unpublish_snowflake_intelligence_agents` macro to detach every agent model NOT opted in via `meta.co_work_targets` for the current target, intended for use as an `on-run-end` hook
* added `sync_snowflake_intelligence_agents` macro to call `publish_snowflake_intelligence_agents` then `unpublish_snowflake_intelligence_agents`, fully reconciling CoWork attachments with `meta.co_work_targets`
* added `test_snowflake_intelligence_lifecycle` integration test exercising add/remove/publish/unpublish/sync end-to-end against a real Snowflake Intelligence object, plus two supporting test agent models (`test_si_agent_opted_in`, `test_si_agent_not_opted_in`)
* fixed `publish`/`unpublish_snowflake_intelligence_agents` treating a scalar `meta.co_work_targets` string as a sequence, which could substring-match an unintended target name
* fixed `publish`/`unpublish_snowflake_intelligence_agents` qualifying attach/detach targets with `target.database` instead of each agent model's own resolved `database`, which addressed the wrong object for agent models that override `database` in their config
* fixed `publish_snowflake_intelligence_agents` attempting to attach every opted-in agent in the full manifest even during a partial (`--select`) run, which could fail the whole hook by trying to `ADD` an agent not yet built in the target database; it now scopes to `selected_resources` when the invocation is a partial run
* `add_snowflake_intelligence_agent` and `remove_snowflake_intelligence_agent` now accept either a `'SCHEMA.AGENT_NAME'` entry (target.database is prepended, unchanged) or an already-qualified `'DATABASE.SCHEMA.AGENT_NAME'` entry, used internally by publish/unpublish for cross-database agent models
* fixed `test_snowflake_intelligence_lifecycle` failing under dbt Core with `'_si_attached' is undefined`: a test helper defined inline as a nested `{% macro %}` works under dbt Fusion's Jinja engine but is not reliably callable later in the same render under dbt Core. Moved it to a proper macro file (`integration_tests/macros/_si_attached.sql`)
* CI now runs the integration test suite against both dbt Core and dbt Fusion (sequentially, since both share the same account-level Snowflake Intelligence object)

## 1.3.1 - 2026-07-16 - Bug Fix

* fixed `get_grant_cortex_search_ownership` macro failing with `invalid identifier "owner"` because `SHOW CORTEX SEARCH SERVICES` does not expose an `owner` column (unlike `SHOW AGENTS`). Ownership is now checked per-service via `SHOW GRANTS` before granting.

## 1.3.0 - 2026-05-04 - dbt Fusion Compatibility, Documentation & CI

* verified all macros for dbt Fusion (dbt Projects on Snowflake) compatibility
* moved custom config parameters to `meta` for dbt Fusion compatibility, with fallback to top-level config for standard dbt Core users
* fixed typo in `snowflake__get_alter_agent_specification_sql` (`vesion` -> `version`)
* added macro property YML files for all 25 macros with full argument documentation
* added integration test suite with 8 singular tests covering DDL generation macros
* added GitHub Actions CI pipeline with lint, compile/parse, and integration test jobs
* added CODEOWNERS file

## 1.1.0 - 2026-03-20 - Snowflake Cortex Search Service

* added `cortex_search` materialization to create and manage Snowflake Cortex Search services
* added `grant_cortex_search_usage` macro to manage USAGE grants on Cortex Search services
* updated `grant_cortex_ownership` to include Cortex Search service ownership
* updated `snowflake__create_replace_or_alter_agent` so that the environment name is appended to the end of the description

## 1.0.0 - 2026-03-17 - Snowflake Agents

* added in new materalization `agent` which allows you to create and manage Snowflake Cortex Agents
* added in macros for grants of `semantic views` and `agents`
