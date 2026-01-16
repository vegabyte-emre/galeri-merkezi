const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const pool = new Pool({
  host: 'postgres',
  user: 'galeri_user',
  password: 'galeri_password',
  database: 'galeri_db',
});

async function updatePasswords() {
  try {
    const hash = await bcrypt.hash('Test123!', 12);
    console.log('New hash:', hash);
    
    await pool.query(
      'UPDATE users SET password_hash = $1 WHERE email IN ($2, $3)', 
      [hash, 'test1@galeri.com', 'test2@galeri.com']
    );
    console.log('Passwords updated');
    
    // Verify
    const result = await pool.query(
      'SELECT email, password_hash FROM users WHERE email LIKE $1', 
      ['test%']
    );
    console.log('Users:', result.rows);
    
    for (const user of result.rows) {
      const verify = await bcrypt.compare('Test123!', user.password_hash);
      console.log(`Verification for ${user.email}:`, verify);
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

updatePasswords();
