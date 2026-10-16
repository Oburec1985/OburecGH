const fs = require('fs');
const path = process.argv[2];
console.log('READDIR ' + path);
try {
  const entries = fs.readdirSync(path, { withFileTypes: true });
  for (const e of entries) console.log((e.isDirectory() ? 'D ' : 'F ') + e.name);
} catch (e) {
  console.log('ERR ' + e.message);
}
