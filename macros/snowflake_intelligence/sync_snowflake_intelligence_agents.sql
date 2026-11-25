{% macro sync_snowflake_intelligence_agents() %}
  {# Reconciles this account's Snowflake Intelligence (CoWork) object with every agent model's
     co_work_targets entry for the current target: first attaches every opted-in agent
     (publish_snowflake_intelligence_agents), then detaches every agent that is no longer opted in
     (unpublish_snowflake_intelligence_agents). Attach runs first so an agent whose co_work_targets
     entry changes to include the current target is never left detached during this run, and detach
     runs second so it only ever removes agents that have actually lost their opt-in.

     Intended as a drop-in on-run-end hook replacement for publish_snowflake_intelligence_agents alone,
     for projects that also want agents automatically detached from CoWork as their co_work_targets
     entries are removed, rather than requiring a manual remove_snowflake_intelligence_agent call.

     Both delegate macros independently guard their own early-exit conditions (run context, compile
     phase, no Snowflake Intelligence object), so no additional guarding is needed here. #}
  {{ dbt_monitorial_snowflake_cortex.publish_snowflake_intelligence_agents() }}
  {{ dbt_monitorial_snowflake_cortex.unpublish_snowflake_intelligence_agents() }}
{% endmacro %}
