{{ config(materialized='incremental', partition_by={"field": "extracted_date", "data_type": "date"}) }}

SELECT  
    DISTINCT
        id AS event_id,
        repo_id,
        repo_name,
        DATE(created_at) AS extracted_date
FROM {{ ref('stg_gitAnalytics') }}

{% if is_incremental() %}
    WHERE DATE(created_at) > (SELECT COALESCE(MAX(DATE(extracted_date)), '1970-01-01') FROM {{ this }})
{% endif %}
