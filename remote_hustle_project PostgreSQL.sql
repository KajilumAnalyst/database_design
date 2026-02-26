-- Creating Database (PostgreSQL doesn't use CREATE DATABASE in scripts usually)
-- Connect to database: \c Remote_Hustle_Project

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Creating database tables

CREATE TABLE Users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('participant', 'Judge', 'admin')),
    country VARCHAR(50),
    created_at TIMESTAMP NULL,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT true
);

-- stages
CREATE TABLE stages (
    id SERIAL PRIMARY KEY,
    stage_number INT UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    max_score INT DEFAULT 100,
    is_active BOOLEAN DEFAULT false
);

-- Teams 
CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leader_id UUID,
    FOREIGN KEY (leader_id) REFERENCES users(id)
);

-- team member
CREATE TABLE team_members (
    team_id INT,
    user_id UUID,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (team_id, user_id),
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE submissions (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    stage_id INT NOT NULL,
    team_id INT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    submission_url TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'scored', 'rejected')),
    is_late BOOLEAN DEFAULT false,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (stage_id) REFERENCES stages(id),
    FOREIGN KEY (team_id) REFERENCES teams(id)
);

-- Evaluation Criteria 
CREATE TABLE criteria (
    id SERIAL PRIMARY KEY,
    stage_id INT,
    criterion_name VARCHAR(100) NOT NULL,
    max_points INT NOT NULL,
    weight DECIMAL(3,2) DEFAULT 1.0,
    FOREIGN KEY (stage_id) REFERENCES stages(id)
);

-- Evaluations
CREATE TABLE evaluations (
    id SERIAL PRIMARY KEY,
    submission_id INT NOT NULL,
    judge_id UUID NOT NULL,
    criterion_id INT,
    score INT CHECK (score >= 0),
    feedback TEXT,
    evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE,
    FOREIGN KEY (judge_id) REFERENCES users(id),
    FOREIGN KEY (criterion_id) REFERENCES criteria(id)
);

-- submission scores
CREATE TABLE submission_scores (
    id SERIAL PRIMARY KEY,
    submission_id INT UNIQUE,
    total_score DECIMAL(10, 2),
    max_possible_score INT,
    percentage DECIMAL(5,2),
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (submission_id) REFERENCES submissions(id)
);

-- audit logs
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    record_id INT,
    action VARCHAR(20),
    old_data JSONB,
    new_data JSONB,
    changed_by UUID,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (changed_by) REFERENCES users(id)
);

-- reports
CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    report_type VARCHAR(50),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    report_data JSONB,
    created_by UUID,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- seed data: inserting values into newly created tables for functionality
INSERT INTO stages (stage_number, name, description, start_date, end_date, is_active)
VALUES
    (1, 'Foundation', 'Basic Skills assessment', '2026-02-02', '2026-02-15', true),
    (2, 'Intermediate', 'Advanced problem solving', '2026-02-17', '2026-02-27', false),
    (3, 'Expert', 'Real-world project', '2026-03-02', '2026-03-15', false);
