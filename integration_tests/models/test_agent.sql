-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Placeholder model for the agent materialization.
-- This model only compiles; it requires a live Snowflake connection to actually run.
{{
  config(
    materialized = 'agent',
    meta = {
      'specification': 'name: test_agent\nmodel: claude-4-sonnet\ntools: []\n',
      'comment': 'Integration test agent',
      'profile': none,
      'create_or_replace': true,
      'append_environment_to_comment': true
    }
  )
}}

{# The specification is provided via config, so the SQL body is not used. #}
