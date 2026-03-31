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

{% macro snowflake__get_create_agent_sql(relation, create_statement, comment, profile, specification) -%}
{#-
--  Produce DDL that creates a a agent with the given specification.
--
--  Args:
--  - relation: Union[SnowflakeRelation, str]
--      - SnowflakeRelation - required for relation.render()
--      - str - is already the rendered relation name
--  - comment: str - optional comment for the agent
--  - profile: str - optional profile for the agent
--  - specification: str - the specification for the agent, either as a YAML string or as a path to a YAML file. If not provided, the macro will attempt to use the model's SQL content as the specification.
--  Returns:
--      A valid DDL statement which will result in a new agent.
-#}

  {{ create_statement }} {{ relation }}
    {%- if comment %}
    COMMENT = '{{ comment | replace("'", "''") }}'
    {%- endif %}
    {%- if profile %}
    PROFILE = '{{ profile }}'
    {%- endif %}
    FROM SPECIFICATION
    $$
{{ specification | indent(4, false) }}
    $$;

{%- endmacro %}


