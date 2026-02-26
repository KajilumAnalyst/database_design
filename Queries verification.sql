-- ‎Queries verification

select 
	'users' as table_name,
    count(*) as total
from users 
union all

select
	'submissions',
    count(*) 														-- -- check counts
from submissions 
union all

select
	'evaluations',
    count(*)
from evaluations
union all

select
	'criteria',
    count(*)
from criteria;
