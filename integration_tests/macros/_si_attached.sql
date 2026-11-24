{% macro _si_attached(si_name, fqn) %}
    {#- Test helper for test_snowflake_intelligence_lifecycle.sql: returns whether `fqn` (a fully
       database-qualified 'DATABASE.SCHEMA.AGENT_NAME' string) is currently attached to the named
       Snowflake Intelligence object. Defined as a real macro (macro-paths) rather than inline inside
       the test file -- dbt Core does not reliably support calling a `{% macro %}` block defined inline
       inside a model/test .sql file later in the same render (confirmed live: "'_si_attached' is
       undefined"), even though dbt Fusion's Jinja engine allows it. #}
    {% set rows = run_query('show agents in snowflake intelligence ' ~ si_name) %}
    {% set attached = [] %}
    {% for row in rows %}
        {% do attached.append((row.database_name ~ '.' ~ row.schema_name ~ '.' ~ row.name) | upper) %}
    {% endfor %}
    {{ return(fqn in attached) }}
{% endmacro %}
