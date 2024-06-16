select distinct
    se.visitor_id,
    se.visit_date,
    se.source as utm_source,
    se.medium as utm_medium,
    se.campaign as utm_campaign,
    le.lead_id,
    le.created_at,
    le.amount,
    le.closing_reason,
    le.status_id
from sessions as se
left join leads as le
    on
        se.visitor_id = le.visitor_id
        and se.visit_date <= le.created_at
        and se.medium in ('cpc', 'cpa', 'youtube', 'cpp', 'tg', 'social')
order by le.amount desc nulls last, se.visit_date asc, se.source asc
;
