-- Create Database
CREATE DATABASE remote_hustle_project;

-- Connect to the database (for psql)
\c remote_hustle_project;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================
-- TABLES
-- =========================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('participant', 'Judge', 'admin')),
    country VARCHAR(50),
    created_at TIMESTAMP NULL,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT true
);

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

CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leader_id UUID REFERENCES users(id)
);

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
    user_id UUID NOT NULL REFERENCES users(id),
    stage_id INT NOT NULL REFERENCES stages(id),
    team_id INT REFERENCES teams(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    submission_url TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','under_review','scored','rejected')),
    is_late BOOLEAN DEFAULT false
);

CREATE TABLE criteria (
    id SERIAL PRIMARY KEY,
    stage_id INT REFERENCES stages(id),
    criterion_name VARCHAR(100) NOT NULL,
    max_points INT NOT NULL,
    weight DECIMAL(3,2) DEFAULT 1.0
);

CREATE TABLE evaluations (
    id SERIAL PRIMARY KEY,
    submission_id INT NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
    judge_id UUID NOT NULL REFERENCES users(id),
    criterion_id INT REFERENCES criteria(id),
    score INT CHECK (score >= 0),
    feedback TEXT,
    evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE submission_scores (
    id SERIAL PRIMARY KEY,
    submission_id INT UNIQUE REFERENCES submissions(id),
    total_score DECIMAL(10,2),
    max_possible_score INT,
    percentage DECIMAL(5,2),
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    record_id INT,
    action VARCHAR(20),
    old_data JSONB,
    new_data JSONB,
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    report_type VARCHAR(50),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    report_data JSONB,
    created_by UUID REFERENCES users(id)
);

-- =========================
-- SEED DATA
-- =========================

INSERT INTO stages (stage_number, name, description, start_date, end_date, is_active)
VALUES
(1,'Foundation','Basic Skills assessment','2026-02-02','2026-02-15',true),
(2,'Intermediate','Advanced problem solving','2026-02-17','2026-02-27',false),
(3,'Expert','Real-world project','2026-03-02','2026-03-15',false);

-- =========================
-- VIEWS
-- =========================

CREATE VIEW participant_profiles AS 
SELECT id, full_name, email, country,
created_at AS registration_date,
last_login,
CASE WHEN last_login > NOW() - INTERVAL '7 days' THEN 'Active' ELSE 'Inactive' END AS status
FROM users
WHERE role='participant';

-- =========================
-- TRIGGERS
-- =========================

CREATE OR REPLACE FUNCTION audit_submissions_insert_func()
RETURNS TRIGGER AS $$
BEGIN
INSERT INTO audit_logs (table_name, record_id, action, new_data, changed_at)
VALUES ('submissions',NEW.id,'INSERT',
JSONB_BUILD_OBJECT('id',NEW.id,'user_id',NEW.user_id,'status',NEW.status),
NOW());
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_submissions_insert
AFTER INSERT ON submissions
FOR EACH ROW
EXECUTE FUNCTION audit_submissions_insert_func();
