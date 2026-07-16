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

{% macro get_grant_cortex_search_ownership(schema_list, role_name) %}
    {% if flags.WHICH not in ['run', 'run-operation'] %}{% do return([]) %}{% endif %}
    {% if not execute %}{% do return([]) %}{% endif %}
    {% set query %}
       show cortex search services in database {{ target.database | replace("'", "''") }}
       ->>
       select "schema_name" as schema_name, "name" as service_name
       from $1
       where "schema_name" in ({{ schema_list }})
    {% endset %}
    {% set results = run_query(query) %}
    {% set statements = [] %}
    {% if results and results | length > 0 %}
        {% for r in results %}
            {% set fqn = target.database ~ '.' ~ r[0] ~ '.' ~ r[1] %}
            {% set grants_query %}
                show grants on cortex search service {{ fqn }}
                ->>
                select "grantee_name"
                from $1
                where "privilege" = 'OWNERSHIP'
                  and "grantee_name" = '{{ role_name | upper }}'
            {% endset %}
            {% set owner_result = run_query(grants_query) %}
            {% if owner_result | length == 0 %}
                {% do statements.append('grant ownership on cortex search service ' ~ fqn ~ ' to role ' ~ role_name ~ ' revoke current grants;') %}
            {% endif %}
        {% endfor %}
        {% if statements | length > 0 %}
            {% do log('get_grant_cortex_search_ownership: generated ' ~ (statements | length) ~ ' statements', info=True) %}
        {% else %}
            {% do log('get_grant_cortex_search_ownership: no cortex search service ownership changes required', info=True) %}
        {% endif %}
    {% else %}
        {% do log('get_grant_cortex_search_ownership: no cortex search service ownership changes required', info=True) %}
    {% endif %}
    {% do return(statements) %}
{% endmacro %}
