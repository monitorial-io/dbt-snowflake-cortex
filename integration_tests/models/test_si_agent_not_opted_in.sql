{{ config(materialized='agent', static_analysis='off', meta={
    'comment': 'Integration test agent - never opted into Snowflake Intelligence'
}) }}
models:
  orchestration: auto
instructions:
  response: 'Integration test agent for snowflake_intelligence macro tests (not opted in).'
