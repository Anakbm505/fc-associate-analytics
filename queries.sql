SELECT
a.associate_id,
a.full_name,
d.dept_name,
d.floor
FROM associates a
JOIN departments d ON a.department_id = d.department_id
WHERE a.status = 'Active';