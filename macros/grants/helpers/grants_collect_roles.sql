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
{% macro _grants_collect_roles(grant_roles) %}
    {% set roles = [] %}
    {% set query %} show roles {% endset %}
    {% set results = run_query(query) %}
    {% if execute and results %}
        {% for row in results %}
            {% if row.name not in roles and row.name in grant_roles %}
                {% do roles.append(row.name) %}
            {% endif %}
        {% endfor %}
    {% endif %}
    {% do return(roles) %}
{% endmacro %}