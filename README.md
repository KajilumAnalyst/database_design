# 📘 **Remote Hustle Operational Database**
### *RHDC Stage 1 Project*

[![Database](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://www.postgresql.org/)
[![Hosted on](https://img.shields.io/badge/Hosted%20on-Supabase-green.svg)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📋 **Table of Contents**
- [Project Overview](#project-overview)
- [Database Schema](#database-schema)
- [Technology Stack](#technology-stack)
- [Connection Instructions](#connection-instructions)
- [Sample Queries](#sample-queries)
- [Features](#features)
- [Development Journey](#development-journey)
- [How Remote Hustle Can Use This](#how-remote-hustle-can-use-this)
- [Repository Structure](#repository-structure)
- [Author](#author)

---

## 🚀 **Project Overview**

The **Remote Hustle Operational Database** is a comprehensive, production-ready database solution designed to streamline the management of participants, submissions, evaluations, and reporting for the Remote Hustle platform. This database eliminates manual tracking, reduces scoring delays, and provides real-time analytics through 8 pre-built analytical views.

---

## 📊 **Database Schema**

The database consists of **10 core tables** with proper relationships, constraints, and data integrity measures:

| Table | Description |
|-------|-------------|
| `users` | Stores participants, judges, and admins (120+ sample records) |
| `stages` | Competition stages (Foundation, Intermediate, Expert) |
| `teams` | Participant team information |
| `team_members` | Many-to-many relationship between users and teams |
| `submissions` | Task submissions with status tracking (80+ sample records) |
| `criteria` | Scoring rubrics with weighted criteria per stage |
| `evaluations` | Judge scores and feedback (30+ sample evaluations) |
| `submission_scores` | Calculated percentages and performance metrics |
| `audit_logs` | Complete change history for compliance |
| `reports` | Pre-generated analytics and report storage |

### **Entity Relationship Diagram**
![ER Diagram](ER_Diagram.png)

---

## 🛠️ **Technology Stack**

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Original Database** | MySQL 8.0 | Initial development and testing |
| **Deployed Database** | PostgreSQL 16 | Production database |
| **Hosting Platform** | Supabase (Free Tier) | Cloud hosting with built-in security |
| **Development Tools** | MySQL Workbench, Supabase SQL Editor | Database design and management |
| **Version Control** | Git, GitHub | Code repository and documentation |
| **Diagramming** | dbdiagram.io | ER diagram creation |

### **Development Journey**
> **Note:** This database was initially developed and tested using **MySQL**, then successfully converted and deployed on **PostgreSQL** (Supabase). All MySQL syntax was carefully migrated to PostgreSQL-compatible code while maintaining data integrity and functionality.

---

## 🔌 **Connection Instructions**

### **Live Database Credentials**

```
┌─────────────────────────────────────────────────────────┐
│  HOST:     db.fjxtiijrzocrgmknpnwx.supabase.co         │
│  PORT:     5432                                         │
│  DATABASE: postgres                                     │
│  USER:     postgres                                     │
│  PASSWORD: [Contact project author for password]       │
│  SSL:      Required                                     │
└─────────────────────────────────────────────────────────┘
```

### **Connection URL**
```
postgresql://postgres:[PASSWORD]@db.fjxtiijrzocrgmknpnwx.supabase.co:5432/postgres
```

### **Connection Tool**

#### **Command Line (psql)**
```bash
psql -h db.fjxtiijrzocrgmkpnpwx.supabase.co -p 5432 -d postgres -U postgres
```

---

## 📝 **Sample Queries**

### **1. View All Participants**
```sql
SELECT * FROM participant_profiles LIMIT 10;
```

### **2. Check Pending Submissions (Judge Queue)**
```sql
SELECT * FROM judge_scoring_queue;
```

### **3. Score a Submission**
```sql
INSERT INTO evaluations (submission_id, judge_id, criterion_id, score, feedback)
VALUES (
    1, 
    (SELECT id FROM users WHERE role = 'Judge' LIMIT 1),
    1, 
    85, 
    'Excellent work! Clear and well-documented.'
);
```

### **4. View Leaderboard**
```sql
SELECT * FROM leaderboard LIMIT 10;
```

### **5. Stage Progress Report**
```sql
SELECT * FROM stage_progress;
```

### **6. Participant Performance Analysis**
```sql
SELECT * FROM participant_performance WHERE performance_grade = 'Excellent';
```

### **7. Daily Analytics**
```sql
SELECT * FROM daily_analytics ORDER BY date DESC;
```

### **8. Audit Trail**
```sql
SELECT * FROM recent_audit_log;
```

---

## ✨ **Features**

### ✅ **Data Integrity**
- Primary and foreign key constraints
- CHECK constraints for data validation
- ENUM restrictions (converted to PostgreSQL CHECK constraints)
- Audit logging for all critical changes

### ✅ **Security**
- Row-level security policies
- Role-based access (participant, judge, admin)
- SSL-encrypted connections
- Password-protected access

### ✅ **Performance**
- Optimized queries with proper indexing
- Materialized views for analytics
- Efficient JOIN operations
- 8 pre-built analytical views

### ✅ **Scalability**
- Normalized schema design
- JSONB support for flexible reporting
- Extensible table structure
- Cloud-hosted for 24/7 availability

### ✅ **Realistic Test Data**
- 120+ participants from 5+ countries
- 80+ submissions across 3 stages
- 30+ evaluations with feedback
- 10 weighted criteria
- 5 judges and 3 admins

---

## 🗺️ **Development Journey: MySQL to PostgreSQL**

This project underwent a complete migration from MySQL to PostgreSQL:

| Aspect | MySQL | PostgreSQL | Migration Notes |
|--------|-------|------------|-----------------|
| **UUID Generation** | `UUID()` | `uuid_generate_v4()` | Added uuid-ossp extension |
| **Auto-increment** | `AUTO_INCREMENT` | `SERIAL` | Direct conversion |
| **ENUM Types** | `ENUM()` | `VARCHAR + CHECK` | Replaced with constraints |
| **Random Function** | `RAND()` | `RANDOM()` | Function name change |
| **JSON Support** | `JSON` | `JSONB` | Enhanced performance |
| **Triggers** | `CREATE TRIGGER` | `CREATE FUNCTION + TRIGGER` | PostgreSQL syntax |
| **Date Intervals** | `INTERVAL X DAY` | `INTERVAL 'X days'` | ISO format |
| **String Functions** | `ELT()` | `CASE` | Rewritten logic |

The migration preserved all functionality while leveraging PostgreSQL's advanced features like JSONB and better performance.

---

## 🎯 **How Remote Hustle Can Use This Today**

### **Immediate Implementation:**

1. **Participant Management**
   - Import existing participants into the `users` table
   - Track registration dates and countries
   - Monitor active vs. inactive participants

2. **Submission Workflow**
   - Replace spreadsheets with centralized submission tracking
   - Automate status updates (pending → under_review → scored)
   - Flag late submissions automatically

3. **Judge Operations**
   - Assign judges to submissions
   - Provide structured feedback with criteria-based scoring
   - Track judge performance and turnaround time

4. **Reporting & Analytics**
   - Generate real-time leaderboards
   - Monitor stage completion rates
   - Identify top performers and at-risk participants
   - Daily activity reports for admin review

5. **Compliance & Security**
   - Complete audit trail for all data changes
   - Role-based access control
   - Data integrity through constraints and validation

---

## 📁 **Repository Structure**

```
remote-hustle-database/
│
├── 📄 README.md                 # This file
├── 📄 schema.sql                # PostgreSQL table creation scripts
├── 📄 seed_data.sql              # Sample data inserts (120+ participants)
├── 📄 queries.sql                # 8+ analytical views
├── 📄 triggers.sql               # Audit log triggers
├── 📄 mysql_original.sql         # Original MySQL version (reference)
├── 📄 migration_notes.md         # MySQL to PostgreSQL conversion details
├── 🖼️ ER_Diagram.png              # Entity Relationship Diagram
└── 📁 docs/
    ├── project_description.pdf   # 1-page project summary
    └── demo_video_link.txt       # Link to 2-3 min demo video
```

---

## 📊 **Database Statistics**

| Metric | Count |
|--------|-------|
| Tables | 10 |
| Participants | 120+ |
| Judges | 5 |
| Admins | 3 |
| Submissions | 80+ |
| Evaluations | 30+ |
| Criteria | 10 |
| Pre-built Views | 8 |
| Countries Represented | 5+ |

---

## 👤 **Author**

**Gideon Kajilum Benjamin**
- 📧 Email: gkajilum@gmail.com
- 🔗 GitHub: [KajilumAnalyst](https://github.com/your-username)
- 🎓 Project: Remote Hustle Database Challenge (RHDC) Stage 1

---

## 📅 **Submission Details**

- **Project:** Remote Hustle Operational Database
- **Stage:** 1 - Master Operational Database
- **Date:** February 2025
- **Hosted On:** Supabase (PostgreSQL)
- **Original Development:** MySQL

---

## 🔌 Live Database Access

**Connection Details:**
- **Host:** `db.fjxtiijrzocrgmkpnpwx.supabase.co`
- **Port:** `5432`
- **Database:** `postgres`
- **User:** `postgres`
- **Password:** `**********`
- **SSL:** Required

**Connection URL:** postgresql://postgres:[YOUR-PASSWORD]@db.fjxtiijrzocrgmkpnpwx.supabase.co:5432/postgres

--

## 📜 **License**

This project is submitted for the Remote Hustle Database Challenge (RHDC) and is available for evaluation purposes.

---

## 🙏 **Acknowledgments**

- Remote Hustle for the challenge opportunity
- Supabase for free PostgreSQL hosting
- MySQL and PostgreSQL communities for excellent documentation

---

<div align="center">
  <h3>⭐ Integrity > Everything | Quality > Size ⭐</h3>
  <p><i>— RHDC Stage 1 Complete —</i></p>
</div>
```

