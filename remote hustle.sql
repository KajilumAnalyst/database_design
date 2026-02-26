use remote_hustle;
--  1. Users table
create table Users (
	id char(36) primary key default (uuid()),
    email varchar(255) unique not null,
    full_name varchar(100)Not null,
    role enum('participant', 'Judge', 'admin') Not Null,
    country varchar(50),
    created_at timestamp null,
    is_active Boolean default true
    );
select * from users;
-- 2. Stages table
create table stages (
	id int auto_increment primary key,
    stage_number int unique not null,
    Name varchar(100)  not null,
    description Text,
    start_date date,
    end_date date,
    max_score int default 100,
    is_active boolean default false
    );

select * from stages;

-- 3. Teams 
create table teams (
	id int auto_increment primary key,
    team_name varchar(100) unique not null,
    created_at timestamp default current_timestamp,
    leader_id char(36),
    foreign key (leader_id) references users(id)
    );
    
    
-- 4. Team members
create table team_members (
	team_id int,
    user_id char(36),
    joined_at timestamp default current_timestamp,
    primary key (team_id, user_id),
    foreign key (team_id) references teams(id) on delete cascade,
    foreign key (user_id) references users(id) on delete cascade
    );
    
    
-- 5. submission
create table submissions (
	id int auto_increment primary key,
    user_id char(36) not null,
    stage_id int not null,
    team_id int,
    title varchar(200) not null,
    description text,
    submission_url text,
    submitted_at timestamp default current_timestamp,
    status enum('pending','under_review', 'scored', 'reject') default 'pending',
    is_late Boolean default false,
    foreign key (user_id) references users(id),
    foreign key (stage_id) references stages(id),
    foreign key (team_id) references teams (id)
    );
    
    
    -- Evaluation Criteria 
    create table criteria (
		id int auto_increment primary key,
        stage_id int,
        criterion_name varchar(100) not null,
        max_points int not null,
        weight Decimal (3,2) default 1.0,
        foreign key (stage_id) references stages (id)
        );
        
-- Evaluations
create table evaluations (
	id int auto_increment primary key,
    submission_id int not null,
    judge_id char(36) not null,
    criterion_id int,
    score int check (score >= 0),
    feedback text,
    evaluated_at timestamp default current_timestamp,
    foreign key (submission_id) references submissions(id) on delete cascade,
    foreign key (judge_id) references users(id),
    foreign key (criterion_id) references criteria(id)
    );
    
    -- submission scores
    create table submission_scores (
		id int auto_increment key,
        submission_id int unique,
        total_score decimal (10, 2),
        max_possible_score int,
        percentage decimal(5,2),
        calculated_at timestamp default current_timestamp,
        foreign key (submission_id) references submissions(id)
        );
        
-- audit logs
create table audit_logs (
	id int auto_increment primary key,
    table_name varchar(50),
    record_id int,
    action varchar(20),
    old_data json,
    new_data json,
    changed_by char(36),
    changed_at timestamp default current_timestamp,
    foreign key (changed_by)references users(id)
    );


-- reports
create table reports (
	id int auto_increment primary key,
    report_type varchar(50),
    generated_at timestamp default current_timestamp,
    report_data json,
    created_by char(36),
    foreign key (created_by)  references users(id)
    );
    
    
-------- seed data -----
-- inserting data
insert into stages (stage_number, name, description, start_date, end_date, is_active)
values
(1, 'Foundation', 'Basic skills assessment', '2026-01-01', '2026-01-07', true),
(2, 'Intermediate', 'Advanced Problem Solving', '2026-01-08', '2026-01-15', false),
(3, 'Expert', 'Real-world project', '2026-01-20', '2026-02-10', false);

Delimiter $$
create procedure GenerateParticipants()
begin
	declare i int default 1;
	while i <= 120 do
		insert into users (id, email, full_name, role, country, created_at)
        values (
			uuid(),
            concat('participant', i, '@gmail.com'),
            concat('participant', i),
            'participant',
            
            elt(1+ floor(rand() * 5), 'USA', 'UK', 'Canada', 'India',  'Australia'),
            now()-interval floor(rand()*30) day
		);
        set i = i +1;
	end while;
end $$
-- DELIMITER;

call GenerateParticipants();

-- add judges
insert into users (id, email, full_name, role, country)
select
	uuid(),
    concat('judge', n, '@gmail.com'),
    concat('judge', n),
    'judge',
    'USA'
from (
	select 1 n union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9 union select 10
) numbers;
    
-- create submission
insert into submissions (user_id, stage_id, title, submission_url, status, submitted_at)
select
	u.id,
	1,
	concat('Submission for', u.full_name),
	concat('https://github.com/',u.full_name,'/project'),
	elt(1 + floor(rand()*4), 'pending', 'under_review', 'scored','rejected'),
	now()-interval floor(rand()*10) day
from users u
where u.role = 'participant'
limit 80;

select * from submissions;