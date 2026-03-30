# dbt-snowflake-cortex Changelog

## 1.1.0 - 2026-03-20 - Snowflake Cortex Search Service

* added `cortex_search` materialization to create and manage Snowflake Cortex Search services
* supports Form 1 (`ON <search_column>`) and Form 2 (`TEXT INDEXES` / `VECTOR INDEXES`) CREATE syntax
* config parameters: `search_column`, `primary_key`, `attributes`, `warehouse`, `target_lag`, `embedding_model`, `refresh_mode`, `initialize`, `full_index_build_interval_days`, `comment`, `source_table_or_view`, `create_or_replace`
* alter-in-place path updates `warehouse`, `target_lag`, `primary_key`, `full_index_build_interval_days`, and `comment` without recreating the service
* added utility macros for all ALTER forms: `SET`, `SUSPEND/RESUME`, `REFRESH`, `UNSET`, `ADD/DROP SCORING PROFILE`
* added `grant_cortex_search_usage` macro to manage USAGE grants on Cortex Search services
* updated `grant_cortex_ownership` to include Cortex Search service ownership
* updated `snowflake__create_replace_or_alter_cortex_search` so that the environment name is appended to the end of the description

## 1.0.0 - 2026-03-17 - Snowflake Agents

* added in new materalization `agent` which allows you to create and manage Snowflake Cortex Agents
* added in macros for grants of `semantic views` and `agents`
