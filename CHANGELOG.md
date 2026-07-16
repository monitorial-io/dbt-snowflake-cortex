# dbt-snowflake-cortex Changelog

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
