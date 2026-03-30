# dbt-snowflake-cortex Changelog

## 1.1.0 - 2026-03-20 - Snowflake Cortex Search Service

* added `cortex_search` materialization to create and manage Snowflake Cortex Search services
* added `grant_cortex_search_usage` macro to manage USAGE grants on Cortex Search services
* updated `grant_cortex_ownership` to include Cortex Search service ownership
* updated `snowflake__create_replace_or_alter_agent` so that the environment name is appended to the end of the description

## 1.0.0 - 2026-03-17 - Snowflake Agents

* added in new materalization `agent` which allows you to create and manage Snowflake Cortex Agents
* added in macros for grants of `semantic views` and `agents`
