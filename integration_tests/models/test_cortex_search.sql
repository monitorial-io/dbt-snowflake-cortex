-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Placeholder model for the cortex_search materialization (Form 1).
-- This model only compiles; it requires a live Snowflake connection to actually run.
{{
  config(
    materialized = 'cortex_search',
    meta = {
      'search_column': 'description',
      'attributes': ['name', 'category'],
      'warehouse': 'COMPUTE_WH',
      'target_lag': '1 day',
      'create_or_replace': true
    }
  )
}}

select
    'sample_id' as id,
    'Sample product description' as description,
    'Sample Product' as name,
    'Category A' as category
