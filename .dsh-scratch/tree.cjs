const fs = require('fs');
const path = require('path');
const root = process.argv[2];
const maxLines = Number(process.argv[3] || 0);

function walk(dir, depth) {
  let entries;
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch (e) { console.log('ERR ' + dir + ' :: ' + e.message); return; }
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (e.name === 'node_modules') continue;
      if (depth > 0) walk(full, depth - 1);
      else console.log('D ' + full);
    } else {
      let size = 0;
      try { size = fs.statSync(full).size; } catch {}
      console.log('F ' + size + ' ' + full);
    }
  }
}
walk(root, Number(process.argv[4] || 2));
