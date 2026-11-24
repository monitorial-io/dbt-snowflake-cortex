{% macro publish_snowflake_intelligence_agents() %}
  {% if flags.WHICH in ['run', 'build', 'run-operation'] %}

    {# Attaches one or more Cortex Agents to this account's Snowflake Intelligence (CoWork) object, so
       they show up in the CoWork curated agent list. The list of agents to attach is NOT hardcoded -
       it's built from every model in the manifest with materialized='agent', opted in per-environment
       via that model's own config(meta={'co_work_targets': [...]}). An agent with no co_work_targets
       (or one that doesn't list the current target.name) is simply skipped - CoWork visibility is a
       deliberate per-agent, per-environment decision, not an implicit default, so a newly
       reverse-engineered agent never shows up in CoWork until someone opts it in.

       Delegates the actual attach to dbt_monitorial_snowflake_cortex.add_snowflake_intelligence_agent, which is
       idempotent (checks SHOW AGENTS IN SNOWFLAKE INTELLIGENCE first) and purely additive - this macro
       never removes an agent (use dbt_monitorial_snowflake_cortex.remove_snowflake_intelligence_agent for that,
       e.g. after an agent's co_work_targets entry for a target is removed).

       Agent entries are built as 'SCHEMA.AGENT_NAME' (not database-qualified), matching
       add_snowflake_intelligence_agent's own convention - it auto-qualifies with target.database, so the
       same relative agent name works across dev/prod databases without hardcoding either.

       Skips entirely (log, not error) if this account has no Snowflake Intelligence object yet -
       CREATE SNOWFLAKE INTELLIGENCE needs the CREATE SNOWFLAKE INTELLIGENCE ON ACCOUNT privilege, which
       dbt's own execution role is not expected to hold; create the object once via Snowsight (AI & ML ->
       Agents -> CoWork tab -> Open settings) or `CREATE SNOWFLAKE INTELLIGENCE <name>` as ACCOUNTADMIN,
       then re-run.

       Uses nested {% if %}/{% endif %} rather than {% do return(none) %} for every early-exit path -
       this macro is called directly via {{ }} as an on-run-end hook (not {% do %}), and a macro that
       explicitly returns a value when called via {{ }} renders that value's string form ("None") as the
       hook's SQL, which then fails with a syntax error. Falling through to the end of the macro with no
       explicit return instead renders only the (empty) buffered output, which is a safe no-op hook. #}

    {% set agents_to_attach = [] %}
    {% for node in graph.nodes.values() %}
      {% if node.resource_type == 'model' and node.config.get('materialized') == 'agent' %}
        {% set co_work_targets = (node.config.meta or {}).get('co_work_targets') or [] %}
        {% if target.name in co_work_targets %}
          {% do agents_to_attach.append((node.schema ~ '.' ~ node.alias) | upper) %}
        {% endif %}
      {% endif %}
    {% endfor %}

    {% if agents_to_attach | length == 0 %}
      {% do log('publish_snowflake_intelligence_agents: no agent opts into co_work_targets for target ' ~ target.name ~ ' - nothing to do', info=True) %}
    {% else %}
      {% set si_object_rows = run_query('SHOW SNOWFLAKE INTELLIGENCES') %}
      {% if si_object_rows | length == 0 %}
        {% do log('publish_snowflake_intelligence_agents: no Snowflake Intelligence object exists in this account - skipping. Create one via Snowsight (AI & ML -> Agents -> CoWork tab -> Open settings) or CREATE SNOWFLAKE INTELLIGENCE as ACCOUNTADMIN, then re-run.', info=True) %}
      {% else %}
        {# Only one Snowflake Intelligence object can exist per account. #}
        {% set si_object_name = si_object_rows[0]['name'] %}
        {% do dbt_monitorial_snowflake_cortex.add_snowflake_intelligence_agent(si_object_name, agents_to_attach) %}
      {% endif %}
    {% endif %}

  {% endif %}
{% endmacro %}