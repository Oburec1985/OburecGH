const fs = require('fs');
const src = process.argv[2];
const dst = process.argv[3];
const data = fs.readFileSync(src);
fs.writeFileSync(dst, data);
console.log('COPIED ' + data.length + ' -> ' + dst);
