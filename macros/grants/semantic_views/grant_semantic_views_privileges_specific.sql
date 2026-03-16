
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

{% macro _grant_semantic_views_privileges_specific(schema_name, grant_roles) %}
    {% do log('====> Processing select grants on semantic views for ' ~ schema, info=True) %}
    -- Grant SELECT on all semantic views to specified roles

    {% set views_query %}
        show semantic views in schema {{ target.database }}.{{ schema_name }}
    {% endset %}
    {% set views = run_query(views_query) %}
    {% set statements = [] %}

    {% if views and views | length > 0 %}
        {% for view in views %}
            {% set view_name = target.database ~ "." ~ schema_name ~ "." view[1] %}
            {% set show_grants_query %}
                show grants on semantic view {{ agent_name }};
            {% endset %}
            {% set existing_grants = run_query(show_grants_query) %}
            {% set existing_roles = [] %}
            {% for existing_grant in existing_grants %}
                {% if existing_grant[1] != 'OWNERSHIP' %}
                    {% if existing_grant[5] not in grant_roles %}
                        {% do statements.append('revoke ' ~ existing_grant[1] ~ ' on semantic view ' ~ view_name ~ ' from role ' ~ existing_grant[5] ~ ';' ) %}
                    {% else %}
                        {% do existing_roles.append(existing_grant[5]) %}
                    {% endif %}
                {% endif %}
            {% endfor %}
            {% for role in grant_roles %}
                {% if role not in existing_roles %}
                        {% do statements.append('grant select on semantic view ' ~ view_name ~ ' to role ' ~ role ~ ';' ) %}
                {% endfor %}
            {% endfor %}

        {% endfor %}
    {% endif %}

-- Execute all statements
    {% if statements | length == 0 %}
        {% do log('grant_semantic_views_privileges: no changes required', info=True) %}
        {% do return(none) %}
    {% endif %}
    {% do log('grant_semantic_views_privileges: executing ' ~ total_statements ~ ' for schema ' ~ schema_name, info=True) %}
    {% for stmt in statements %}
        {% do log(stmt, info=True) %}
        {% set _ = run_query(stmt) %}
    {% endfor %}
    {% do log('grant_semantic_views_privileges: completed select grants on semantic views for schema ' ~ schema_name, info=True) %}
{% endmacro %}