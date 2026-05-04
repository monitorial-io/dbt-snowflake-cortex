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

{% macro config_meta_get(key, default=none) %}
    {%- set meta = config.get("meta", none) -%}
    {%- if meta is not none and meta is mapping and key in meta -%}
        {{ return(meta[key]) }}
    {%- elif execute -%}
        {{ return(config.get(key, default)) }}
    {%- else -%}
        {{ return(default) }}
    {%- endif -%}
{% endmacro %}
