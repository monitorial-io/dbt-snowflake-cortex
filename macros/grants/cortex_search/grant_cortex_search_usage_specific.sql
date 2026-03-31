-- Copyright 2026 Monitorial.io
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

{% macro _grant_cortex_search_usage_specific(schema_name, grant_roles) %}

    {# Begin usage grants for cortex search services in schema #}
    {% do log('====> Processing usage grants on cortex search services for ' ~ schema_name, info=True) %}
    {% set services_query %}
        show cortex search services in schema {{ target.database }}.{{ schema_name }}
    {% endset %}

    {% set services = run_query(services_query) %}
    {% set statements = [] %}

    {% if services and services | length > 0 %}
        {% for service in services %}
            {% set service_name = target.database ~ "." ~ schema_name ~ "." ~ service[1] %}
            {% set show_grants_query %}
                show grants on cortex search service {{ service_name }};
            {% endset %}
            {% set existing_grants = run_query(show_grants_query) %}
            {% set existing_roles = [] %}
            {% for existing_grant in existing_grants %}
                {% if existing_grant[1] != 'OWNERSHIP' %}
                    {% if existing_grant[5] not in grant_roles %}
                        {% do statements.append('revoke ' ~ existing_grant[1] ~ ' on cortex search service ' ~ service_name ~ ' from role ' ~ existing_grant[5] ~ ';') %}
                    {% else %}
                        {% do existing_roles.append(existing_grant[5]) %}
                    {% endif %}
                {% endif %}
            {% endfor %}
            {% for role in grant_roles %}
                {% if role not in existing_roles %}
                    {% do statements.append('grant usage on cortex search service ' ~ service_name ~ ' to role ' ~ role ~ ';') %}
                {% endif %}
            {% endfor %}
        {% endfor %}
    {% endif %}

    {# Execute all statements #}
    {% if statements | length == 0 %}
        {% do log('grant_cortex_search_usage: no changes required', info=True) %}
        {% do return(none) %}
    {% endif %}
    {% do log('grant_cortex_search_usage: executing ' ~ (statements | length) ~ ' for schema ' ~ schema_name, info=True) %}
    {% for stmt in statements %}
        {% do log(stmt, info=True) %}
        {% set _ = run_query(stmt) %}
    {% endfor %}
    {% do log('grant_cortex_search_usage: completed usage grants on cortex search services for schema ' ~ schema_name, info=True) %}
{% endmacro %}
