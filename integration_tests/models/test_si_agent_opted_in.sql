{{ config(materialized='agent', static_analysis='off', meta={
    'comment': 'Integration test agent - always opted into Snowflake Intelligence for the current target',
    'co_work_targets': [target.name]
}) }}
models:
  orchestration: auto
instructions:
  response: 'Integration test agent for snowflake_intelligence macro tests (opted in).'
