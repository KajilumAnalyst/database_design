-- Submissions INSERT trigger
create trigger audit_submissions_insert
after insert on submissions
for each row
insert into audit_logs (table_name, record_id, action, new_data, changed_at)
values 
	('submissions', NEW.id, 'INSERT',
    json_object('id', NEW.id, 'user.id', NEW.user_id, 'status', New.status), Now());
    
    
 -- Submissions UPDATE trigger
create trigger audit_submissions_update
after update on submissions
for each row
insert into audit_logs (table_name, record_id, action, old_data, changed_at)
values
	('submissions', new.id, 'UPDATE',
    json_object('id', old.id, 'status', old.status),
    json_object('id', new.id, 'status', new.status), now());
    