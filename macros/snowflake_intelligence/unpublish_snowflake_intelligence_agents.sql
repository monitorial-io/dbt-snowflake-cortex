{% macro unpublish_snowflake_intelligence_agents() %}
  {% if flags.WHICH in ['run', 'build', 'run-operation'] %}

    {# Detaches every agent model (materialized='agent') that does NOT opt in to the current target
       via config(meta={'co_work_targets': [...]}) from this account's Snowflake Intelligence (CoWork)
       object. Mirror image of publish_snowflake_intelligence_agents: an agent model is queued for
       removal if it has no co_work_targets entry, or if co_work_targets does not include
       target.name. Delegates the actual detach to
       dbt_monitorial_snowflake_cortex.remove_snowflake_intelligence_agent, which is idempotent (checks
       SHOW AGENTS IN SNOWFLAKE INTELLIGENCE first and only drops agents that are actually attached), so
       it is safe to call on every run even for agents that were never attached in the first place.

       Agent entries are built as 'SCHEMA.AGENT_NAME' (not database-qualified), matching
       remove_snowflake_intelligence_agent's own convention - it auto-qualifies with target.database, so
       the same relative agent name works across dev/prod databases without hardcoding either.

       Skips entirely (log, not error) if this account has no Snowflake Intelligence object yet.

       Uses nested {% if %}/{% endif %} rather than {% do return(none) %} for every early-exit path -
       this macro is called directly via {{ }} (e.g. as an on-run-end hook, not {% do %}), and a macro
       that explicitly returns a value when called via {{ }} renders that value's string form ("None")
       as the hook's SQL, which then fails with a syntax error. Falling through to the end of the macro
       with no explicit return instead renders only the (empty) buffered output, which is a safe no-op
       hook. #}

    {% set agents_to_detach = [] %}
    {% for node in graph.nodes.values() %}
      {% if node.resource_type == 'model' and node.config.get('materialized') == 'agent' %}
        {% set co_work_targets = (node.config.meta or {}).get('co_work_targets') or [] %}
        {% if target.name not in co_work_targets %}
          {% do agents_to_detach.append((node.schema ~ '.' ~ node.alias) | upper) %}
        {% endif %}
      {% endif %}
    {% endfor %}

    {% if agents_to_detach | length == 0 %}
      {% do log('unpublish_snowflake_intelligence_agents: every agent model opts into co_work_targets for target ' ~ target.name ~ ' - nothing to do', info=True) %}
    {% else %}
      {% set si_object_rows = run_query('SHOW SNOWFLAKE INTELLIGENCES') %}
      {% if si_object_rows | length == 0 %}
        {% do log('unpublish_snowflake_intelligence_agents: no Snowflake Intelligence object exists in this account - skipping. Create one via Snowsight (AI & ML -> Agents -> CoWork tab -> Open settings) or CREATE SNOWFLAKE INTELLIGENCE as ACCOUNTADMIN, then re-run.', info=True) %}
      {% else %}
        {# Only one Snowflake Intelligence object can exist per account. #}
        {% set si_object_name = si_object_rows[0]['name'] %}
        {% do dbt_monitorial_snowflake_cortex.remove_snowflake_intelligence_agent(si_object_name, agents_to_detach) %}
      {% endif %}
    {% endif %}

  {% endif %}
{% endmacro %}
