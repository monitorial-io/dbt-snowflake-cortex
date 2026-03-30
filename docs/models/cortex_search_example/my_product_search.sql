{{
    config(
        materialized='cortex_search',
        comment='Example cortex search for product data',
        warehouse='COMPUTE_WH',
        search_column='description',
        attributes=['product_name', 'category'],
        target_lag='1 day'
    )
}}

SELECT
    product_name,
    description,
    category
FROM {{ ref('products') }}
