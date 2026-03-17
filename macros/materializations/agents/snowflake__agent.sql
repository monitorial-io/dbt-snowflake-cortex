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

{%- materialization agent, adapter='snowflake' -%}

  {% set original_query_tag = set_query_tag() %}

  {% set target_relation = api.Relation.create(identifier=model['alias'], schema=schema, database=database) %}

  {% do dbt_monitorial_snowflake_cortex.snowflake__create_replace_or_alter_agent() %}

  {% do unset_query_tag(original_query_tag) %}
  -- return
  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}