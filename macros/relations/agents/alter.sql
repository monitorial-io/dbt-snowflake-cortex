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

{% macro snowflake__get_alter_agent_comment_and_profile_sql(relation, comment, profile) -%}
    alter agent {{ relation }}
    SET {%- if comment %}
        COMMENT = '{{ comment | replace("'", "''") }}'
    {%- endif %}
    {%- if profile %}
        PROFILE = '{{ profile }}'
    {%- endif %};
{%- endmacro %}


{% macro snowflake__get_alter_agent_specification_sql(relation, specification) -%}
    alter agent {{ relation }}
    modify live vesion set specification =
     $$
{{ specification | indent(4, false) }}
    $$;
{%- endmacro %}
