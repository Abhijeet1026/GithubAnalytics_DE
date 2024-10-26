{{ 
    config(
        materialized='view', 
        partition_by={"field": "date_info", "data_type": "date"}
    ) 
}}

SELECT 
    f.event_id AS event_id,
    e.event_type,
    f.actor_id AS actor_id,
    a.actor_user_id AS actor_user_id,
    a.is_bot AS is_actor_bot,
    f.repo_id AS repo_id,
    r.repo_name AS repo_name,
    f.extracted_date AS date_info,
    d.month_ AS month_,
    d.year_ AS year_,
    f.payload_size AS payload_size,
    f.org_present AS org_present
FROM {{ ref('fact_gitanalytics') }} AS f
INNER JOIN {{ ref('dim_eventtype') }} AS e ON f.event_type_key = e.event_type_key
INNER JOIN {{ ref('dim_actors') }} AS a ON f.actor_id= a.actor_id and f.actor_user_id = a.actor_user_id
INNER JOIN {{ ref('dim_repo') }} AS r ON f.event_id= r.event_id
INNER JOIN {{ ref('dim_dates') }} AS d ON f.extracted_date = d.extracted_date