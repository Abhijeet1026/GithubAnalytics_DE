SELECT 
     id as event_id,
     stg_gitAnalytics.eventtype_key AS event_type_key,
     actor_id,
     repo_id,
     DATE(created_at) AS extracted_date,
     payload_size,
     org_present

FROM {{ ref('stg_gitAnalytics') }} 