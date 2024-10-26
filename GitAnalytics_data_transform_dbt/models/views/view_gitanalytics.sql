select 
    f.event_id event_id,
    e.event_type,
    f.actor_id actor_id,
    a.actor_login actor_login,
    a.is_bot is_actor_bot,
    f.repo_id repo_id,
    r.repo_name repo_name,
    f.extracted_date date_info,
    d.month_  month_,
    d.year_  year_,
    f.payload_size payload_size,
    f.org_present org_present
    
    
FROM {{ ref('fact_gitanalytics') }} as f inner join {{ref('dim_eventtype')}} as e
on f.event_type_key = e.event_type_key
inner join {{ref('dim_actors')}} as a 
on f.actor_id = a.actor_id
inner join {{ref('dim_repo')}}  as r 
on f.repo_id = r.repo_id
inner join {{ref('dim_dates')}}  as d
on f.extracted_date = d.extracted_date
