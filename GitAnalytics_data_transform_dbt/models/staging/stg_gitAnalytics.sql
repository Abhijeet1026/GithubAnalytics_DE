{{ config(materialized='incremental', unique_key='id') }}

WITH source AS (
    SELECT * FROM {{ source('staging', 'gitanalytics_raw_data') }}
),

renamed AS (
    SELECT 
       DISTINCT id,
       {{ map_event_type('type') }} AS eventtype_key,
       type,
       created_at,
       actor_id,
       actor_login as actor_user_id,
       repo_id,
       repo_name,
       payload_size,
       org_present
    FROM source
)

SELECT * 
FROM renamed

{% if is_incremental() %}
    WHERE DATE(created_at) > (SELECT COALESCE(MAX(DATE(created_at)), '1970-01-01') FROM {{ this }})
{% endif %}
