SELECT  
    DISTINCT
        actor_id, actor_login,
    Case
        when actor_login like "%[bot]%" Then "yes"
        else "no"
    end as is_bot,

    

FROM {{ ref('stg_gitAnalytics') }}