import fs from 'node:fs';
const p = process.argv[2];
const entries = fs.readdirSync(p, { withFileTypes: true });
for (const e of entries) console.log((e.isDirectory() ? 'D ' : 'F ') + e.name);
