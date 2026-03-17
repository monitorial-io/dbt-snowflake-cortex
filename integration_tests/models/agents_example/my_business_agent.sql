{{
    config(
        materialized='agent',
        comment='Example business agent',
        profile='{"display_name": "Business Agent", "avatar": "icon.png", "color": "blue"}'
    )
}}

models:
  orchestration: claude-4-sonnet

orchestration:
  budget:
    seconds: 30
    tokens: 16000

instructions:
  response: "Your response instructions"
  orchestration: "Your orchestration instructions"
  system: "Your system instructions"

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "AnalystTool"
      description: "Tool description"

tool_resources:
  AnalystTool:
    semantic_view: "database.schema.view_name"
