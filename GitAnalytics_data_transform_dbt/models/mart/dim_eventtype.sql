SELECT DISTINCT
    stg_gitAnalytics.eventtype_key AS event_type_key,
    stg_gitAnalytics.type AS event_type
FROM {{ ref('stg_gitAnalytics') }}

