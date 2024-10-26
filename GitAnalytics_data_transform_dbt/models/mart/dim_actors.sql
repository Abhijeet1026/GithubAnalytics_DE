{{ config(materialized='view') }}

SELECT DISTINCT
    actor_id,
    actor_user_id,
    CASE
        WHEN actor_user_id LIKE '%[bot]%' THEN 'yes'
        ELSE 'no'
    END AS is_bot
FROM {{ ref('stg_gitAnalytics') }}