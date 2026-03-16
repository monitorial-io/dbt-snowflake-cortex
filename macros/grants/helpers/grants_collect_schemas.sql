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

{% macro _grants_collect_schemas(exclude_schemas) %}
    {% set include_schemas = [] %}
    {% if exclude_schemas is not iterable %}
        {% set exclude_schemas = [] %}
    {% endif %}
    {% if "INFORMATION_SCHEMA" not in exclude_schemas %}
        {% do exclude_schemas.append("INFORMATION_SCHEMA") %}
    {% endif %}
    {% set query %}
        show schemas in database {{ target.database }};
    {% endset %}
    {% set results = run_query(query) %}
    {% if execute and results %}
        {% for row in results %}
            {% if row.name not in exclude_schemas and row.name not in include_schemas %}
                {% do include_schemas.append(row.name) %}
            {% endif %}
        {% endfor %}
    {% endif %}
    {% do return(include_schemas) %}
{% endmacro %}