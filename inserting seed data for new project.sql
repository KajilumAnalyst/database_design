-- seed data: inserting values into newly created tables for functionality
-- inserting values in stages table
insert into stages ( stage_number, name, description, start_date, end_date, is_active)
values
	(1, 'Foundation', 'Basic Skills assessment', '2026-02-02', '2026-02-15', true),
    (2, 'Intermediate', 'Advanced problem solving', '2026-02-17', '2026-02-27', false),
    (3, 'Expert', 'Real-world project', '2026-03-02', '2026-03-15', false);
    
    
    -- inserting data into users table for participants

insert into users (id, email, full_name, role, country, created_at)
select
	uuid(),
    concat('participant', n, 'gmail.com'),
    concat('participant ', n),
    'participant',
    elt(1 + floor(rand() * 5), 'USA', 'UK', 'Canada' 'Nigeria', 'Australia'),
    now() - interval floor(rand() * 30) day
from (
	select @i := @i + 1 as n
    from 
		(select 1 union select 2 union select 3 union select 4 union select 5) t1,
		(select 1 union select 2 union select 3 union select 4 union select 5) t2,
        (select 1 union select 2 union select 3 union select 4) t3,
        (select @i := 0) t4
	) numbers 
limit 120;

update users
set country = 'Canada'
where role = 'participant'
and rand() < 0.2;


insert into users (id, email, full_name, role, country)
values
	(uuid(), 'saragibbson@gmail.com', 'Sarah Gibbson', 'Judge', 'USA'),
    (uuid(), 'bdavid@gmail.com', 'David Beckam', 'Judge', 'UK'),
    (uuid(), 's_waziri@gmail.com', 'Sule Waziri', 'Judge', 'Nigeria'),
    (uuid(), 'drakem@gmail.com', 'Mikel Drake', 'Judge', 'Canada'),
    (uuid(), 'marypete@gmail.com', 'Mary Peterson', 'Judge', 'Australia');
    
    --  Inserting admins values
insert into users (id, email, full_name, role, country)
values 
	(uuid(), 'john@admin.com', 'Admin John', 'admin', 'USA'),
    (uuid(), 'Kajilum@admin.com', 'Admin Kajilum', 'admin', 'Nigeria'),
    (uuid(), 'kofi@admin.com', 'Admin Kofi', 'admin', 'UK'),
    (uuid(), 'tolu@admin.com', 'Admin Tolu', 'admin', 'Canadas'),
    (uuid(), 'Uche@admin.com', 'Admin Uche', 'admin', 'Australia');
    
    
 -- Adding values to teams table
insert into teams (team_name, leader_id)
values
	('A squard', (select id from users where email = 'participant1@gmail.com')),
    ('B crew', (select id from users where email = 'participant2@gmail.com')),
    ('C force', (select id from users where email = 'participant3@gmail.com'));
    
-- Adding team members
insert into team_members (team_id, user_id)
select
	1 + floor(rand() * 3),
    id
from users
where role = 'Participant'
order by rand()
limit 90;

-- inserting submission values

insert into submissions (user_id, stage_id, title, submission_url, status, submitted_at)
select
	u.id,
	1,
	concat('Submission for', u.full_name),
	concat('https://github.com/',replace (u.full_name, '',''),'/project'),
	-- elt(1 + floor(rand()*4), 'pending', 'under_review', 'scored','rejected'),
		case floor(rand() * 4)
			when 0 then 'pending'
            when 1 then 'under_review'
            when 2 then 'scored'
            when 3 then 'rejected'
		else 'pending'
	end,
	now()-interval floor(rand()*10)day
from users u
where u.role = 'participant'
limit 80;


select * from criteria;
-- inserting criteriatable values
insert into criteria (stage_id, criterion_name, max_points, weight)
values
	(1, 'Code Quality', 25, 1.0),
    (1, 'Documentation', 20, 1.0),
    (1, 'Functionality', 35, 1.5),
    (1, 'Creativity', 20, 0.5),
    (2, 'Problem Solving', 30, 1.2),
    (2, 'Effeciency', 25, 1.0),
    (2, 'Testing', 25, 0.8),
    (3, 'Innovation', 40, 1.5),
    (3, 'Presentation', 30, 1.0),
    (3, 'Impact', 30, 1.2);
    
    
-- adding values to empty evaluation table

insert into evaluations (submission_id, judge_id, criterion_id, score, feedback)
select
	s.id,
    (select id from users where role = 'judge' order by rand() limit 1),
    c.id,
    floor(50 + rand() * 51),
    elt(1 + floor(rand() * 5),
		'Great work!', 'Needs improvement', 'Excellent!', 'Good job', 'Could be better')
from submissions s
cross join criteria c
where s.status in ('scored', 'under_review')
limit 30;


insert into submission_scores (submission_id, total_score, max_possible_score, percentage)
select
	e.submission_id,
    sum(e.score) as total_score,
     stage_max.total_possible as max_possible_scores,
     round(sum(e.score)/stage_max.total_possible * 100,2) / 10 as percentage
from evaluations e
join submissions s on e.submission_id = s.id
join criteria c on e.criterion_id = c.id
join (
	select stage_id, sum(max_points * weight) as total_possible
    from criteria
    group by stage_id
) stage_max on s.stage_id = stage_max.stage_id
group by e.submission_id, stage_max.total_possible;


