with last_paid_click as (
    select
        se.visitor_id,
        se.visit_date::date,
        se.source as utm_source,
        se.medium as utm_medium,
        se.campaign as utm_campaign,
        se.content as utm_content,
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
),

advertising as (
    select
        ad_id,
        campaign_id,
        campaign_name,
        campaign_date,
        daily_spent,
        utm_source,
        utm_medium,
        utm_campaign,
        utm_content
    from vk_ads
    union all
    select
        ad_id,
        campaign_id,
        campaign_name,
        campaign_date,
        daily_spent,
        utm_source,
        utm_medium,
        utm_campaign,
        utm_content
    from ya_ads
)

select
    cl.visit_date,
    cl.utm_source,
    cl.utm_medium,
    cl.utm_campaign,
    count(cl.visitor_id) as visitors_count,
    sum(ad.daily_spent) as total_cost,
    count(cl.lead_id) as leads_count,
    count(cl.lead_id) filter (
        where cl.closing_reason = 'Успешно реализовано' or cl.status_id = '142'
    ) as purchases_count,
    sum(cl.amount) filter (
        where cl.closing_reason = 'Успешно реализовано' or cl.status_id = '142'
    ) as revenue
from last_paid_click as cl
left join advertising as ad
    on
        cl.utm_source = ad.utm_source
        and cl.utm_medium = ad.utm_medium
        and cl.utm_campaign = ad.utm_campaign
        and cl.utm_content = ad.utm_content
group by
    cl.visit_date,
    cl.utm_source,
    cl.utm_medium,
    cl.utm_campaign
order by
    revenue desc nulls last,
    cl.visit_date asc,
    visitors_count desc,
    cl.utm_source asc,
    cl.utm_medium asc,
    cl.utm_campaign asc;
