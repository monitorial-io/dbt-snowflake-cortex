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

       Agent entries are built as the model's fully-qualified 'DATABASE.SCHEMA.AGENT_NAME' (using the
       model's own resolved database, which may differ from target.database if the model overrides
       `database` in its config) so remove_snowflake_intelligence_agent addresses the right object even
       for cross-database agent models.

       `co_work_targets` must be a list; a bare string is coerced to a single-element list so
       `target.name not in co_work_targets` can't match a substring of the string instead of an exact
       target name.

       When this invocation is a partial run (dbt's `selected_resources` is non-empty, e.g. `dbt run -s
       some_model`), only agent models included in `selected_resources` are considered, for the same
       reason publish_snowflake_intelligence_agents scopes to it. A full, unselected invocation (or a
       `run-operation` call, where `selected_resources` is always empty) considers every non-opted-in
       agent in the manifest as before.

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
        {% if (selected_resources | length) == 0 or node.unique_id in selected_resources %}
          {% set co_work_targets = (node.config.meta or {}).get('co_work_targets') or [] %}
          {% if co_work_targets is string %}
            {% set co_work_targets = [co_work_targets] %}
          {% endif %}
          {% if target.name not in co_work_targets %}
            {% set agent_database = node.database or target.database %}
            {% do agents_to_detach.append((agent_database ~ '.' ~ node.schema ~ '.' ~ node.alias) | upper) %}
          {% endif %}
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
