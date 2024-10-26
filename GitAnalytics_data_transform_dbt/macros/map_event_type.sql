{#
This macro provides usnique key to event type
#}

{% macro map_event_type (type) -%}



    case cast( {{type}} as STRING)
        
        when "PushEvent" Then "1"
        when "CreateEvent"	 Then "2"
        when "IssueCommentEvent"	 Then "3"
        when "PullRequestEvent" Then "4"
        when "ReleaseEvent" Then "5"
        when "IssuesEvent" Then "6"
        when "WatchEvent"	 Then "7 "
        when "PullRequestReviewEvent"	 Then "8"
        when "PullRequestReviewCommentEvent" Then "9"
        when "ForkEvent" Then "10"
        when "DeleteEvent"	 Then "11"
        when "PublicEvent"	 Then "12"
        when "CommitCommentEvent"	 Then "13"
        when "MemberEvent" Then "14"
        when "GollumEvent"  Then "15"
        else "unknown"

    end

{%- endmacro %}