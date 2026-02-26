-- creating database
create database r_hustle;

use r_hustle;

--  													creating tables
-- users table

create table Users (
	id char(36) primary key default (uuid()),
    email varchar(255) unique not null,
    full_name varchar(100)Not null,
    role enum('participant', 'Judge', 'admin') Not Null,
    country varchar(50),
    created_at timestamp null,
    last_login timestamp null,
    is_active Boolean default true
    );
    
-- stages
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
    

-- Teams 
create table teams (
	id int auto_increment primary key,
    team_name varchar(100) unique not null,
    created_at timestamp default current_timestamp,
    leader_id char(36),
    foreign key (leader_id) references users(id)
    );
    
-- team member
create table team_members (
	team_id int,
    user_id char(36),
    joined_at timestamp default current_timestamp,
    primary key (team_id, user_id),
    foreign key (team_id) references teams(id) on delete cascade,
    foreign key (user_id) references users(id) on delete cascade
    );

create table submissions (
	id int auto_increment primary key,
    user_id char(36) not null,
    stage_id int not null,
    team_id int,
    title varchar(200) not null,
    description text,
    submission_url text,
    submitted_at timestamp default current_timestamp,
    status enum('pending','under_review', 'scored', 'rejected') default 'pending',
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
    
    
    
