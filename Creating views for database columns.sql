-- 							CREATING VIEWS
-- Participant Profiles view

create view participant_profiles as 
select
	id, full_name,
    email,
    country,
    created_at as registration_date,
    last_login,
case 
    when last_login > now() - interval 7 day then 'Active' else 'Inactive'
    end as status
from users
where role = 'participant';


-- submission tracking

create view submission_track as 
select
	s.id,
    u.full_name as participant, 
    st.stage_number,
    st.name as stage_name,
    s.title,
    submitted_at,
    s.status,
    count(e.id) as evaluation_count,
    coalesce(avg(e.score), 0) as avg_score
from submissions s
join users u on s.user_id = u.id
join stages st on s.stage_id = st.id
left join evaluations e on s.id = e.submission_id
group by s.id;

-- Judges scoring
create view judge_scoring_queue as
select
	s.id as submission_id,
    u.full_name as participant, 
    st.stage_number,
    s.title,
    s.submitted_at,
    datediff(now(), s.submitted_at) as days_pending
from submissions s
join users u on s.user_id = u.id
join stages st on s.stage_id = st.id
where s.status = 'under_review';

-- stage progress


create view stage_progress as
select
	st.stage_number,
    st.name as stage_name,
    count(distinct s.user_id) as participants_submitted,
    count(distinct 
		case
			when s.status = 'scored' then s.user_id
		end) as participants_score,
	round(avg(ss.percentage), 2) as avg_score_percentage
from stages st
left join submissions s on st.id = s.stage_id
left join submission_scores ss on s.id = ss.submission_id;


-- Leaderboard

create view leaderboard as
select 
	u.full_name,
    country,
    count(distinct s.id) as total_submissions,
    round(avg(ss.percentage), 2) as agv_score,
    rank() over (order by avg(ss.percentage) desc)
from users u
join submissions s on u.id = s.user_id
join submission_scores ss on s.id = ss.submission_id
where u.role = 'participant' and ss.percentage is not null
group by u.id;



-- Audit_logs
create view recent_audit_log as
select
	al.table_name,
    al.action,
    al.old_data, 
    al.new_data,
    u.full_name as changed_by,
    al.changed_at
from audit_logs al
join users u on al.changed_by = u.id
order by al.changed_at desc
limit 100;



-- Partcipants performance
create view participant_performance as
select
	u.full_name,
    u.email,
    count(s.id) as submission_made,
    count(
		case
			when s.status = 'scored' then 1
		end) as submissions_scored,
	round(avg(ss.percentage), 2) as overall_perfromance,
	case
		when avg(ss.percentage) >= 80 then 'Excellent'
        when avg(ss.percentage) >= 60 then 'Good'
        when avg(ss.percentage) >= 40 then 'Average'
        else 'Needs Improvement'
	end as performance_grade
from users u
left join submissions s on u.id = s.user_id
left join submission_scores ss on s.id = ss.submission_id
where u.role = 'participant'
group by u.id;


-- Daily Analytics
create view daily_analytics as
select
	date(submitted_at) as date,
    count(*) as total_submissions,
    count(distinct user_id) as unique_participants,
    count(
		case 
			when status = 'scored' then 1
		end) as scored_submissions,
	count(
		case
			when is_late then 1
		end) as late_submissions
from submissions
group by date(submitted_at)
order by date desc;

