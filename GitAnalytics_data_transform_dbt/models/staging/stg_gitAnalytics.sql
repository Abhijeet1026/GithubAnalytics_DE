with 

source as (

    select * from {{source('staging', 'gitanalytics_raw_data')}}
),

renamed as (

    select 
       id,
       {{map_event_type('type') }} as eventtype_key,
       type,
       created_at,
       actor_id,
       actor_login,
       repo_id,
       repo_name,
       payload_size,
       org_present
    
    from source

)

select * from renamed