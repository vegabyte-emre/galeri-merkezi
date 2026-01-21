const bcrypt = require('bcrypt');
const hash = bcrypt.hashSync('Test123!', 10);
const sql = 'UPDATE users SET password_hash = ' + "'" + hash + "'" + ' WHERE email = ' + "'admin@otobia.com'" + ';';
console.log(sql);
