-- Check superadmin
SELECT id, email, role, LEFT(password_hash, 30) as pw_start FROM users WHERE role = 'superadmin';

-- Check all users
SELECT email, role FROM users;
