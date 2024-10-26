SELECT 
     Distinct DATE(created_at) AS extracted_date,
     Extract (Month from created_at) as month_,
     EXTRACT (YEAR from created_at) as year_
FROM {{ ref('stg_gitAnalytics') }} 