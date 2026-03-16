-- Test: Agent materialization macro
{{
    config(
        materialized='agent',
        comment='Test agent',
        profile='{"display_name": "Test Agent", "avatar": "test.png", "color": "green"}'
    )
}}

models:
  orchestration: claude-4-sonnet

orchestration:
  budget:
    seconds: 10
    tokens: 1000

instructions:
  response: "Test response instructions"
  orchestration: "Test orchestration instructions"
  system: "Test system instructions"

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "TestTool"
      description: "Test tool description"

tool_resources:
  TestTool:
    semantic_view: "database.schema.test_view"
