{{ config(
    materialized='incremental',
    partition_by={"field": "extracted_date", "data_type": "date"}
) }}

SELECT 
    id AS event_id,
    {{ map_event_type('type') }} AS event_type_key,
    actor_id,
    actor_user_id,
    repo_id,
    DATE(created_at) AS extracted_date,
    payload_size,
    org_present
FROM {{ ref('stg_gitAnalytics') }}

{% if is_incremental() %}
    WHERE DATE(created_at) > (SELECT COALESCE(MAX(DATE(extracted_date)), DATE '1970-01-01') FROM {{ this }})
{% endif %}
