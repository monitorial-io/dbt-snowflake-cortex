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

{% macro get_grant_agent_ownership(schema_list, role_name) %}
    {% if flags.WHICH not in ['run','run-operation'] %}{% do return([]) %}{% endif %}
    {% if not execute %}{% do return([]) %}{% endif %}
    {% set query %}
       show agents in database {{ target.database }}
       ->>
       select "schema_name" as schema_name, "name" as agent_name
       from $1
       where "owner" != '{{ role_name | upper }}'
         and "schema_name" in ({{ schema_list }})
    {% endset %}
    {% set results = run_query(query) %}
    {% set statements = [] %}
    {% if results and results | length > 0 %}
        {% for r in results %}
            {% do statements.append('grant ownership on agent ' ~ target.database ~ '.' ~ r[0] ~ '.' ~ r[1] ~ ' to role ' ~ role_name ~ ' revoke current grants;') %}
        {% endfor %}
        {% do log('get_grant_agent_ownership: generated ' ~ (statements | length) ~ ' statements', info=True) %}
    {% else %}
        {% do log('get_grant_agent_ownership: no agent ownership changes required', info=True) %}
    {% endif %}
    {% do return(statements) %}
{% endmacro %}

