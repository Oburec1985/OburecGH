# -*- coding: utf-8 -*-
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'UI' / 'uTagSettingsDialog.pas'
text = path.read_text(encoding='utf-8')

const_names = ('sGhDownloadTitle', 'sGhDownloadOk', 'sGhDownloadNoMic140')
lines = text.splitlines()
out = []
for line in lines:
    stripped = line.strip()
    if any(stripped.startswith(name + ' =') for name in const_names):
        name, rest = stripped.split(' = ', 1)
        val = rest.strip().strip(';').strip("'")
        try:
            val = val.encode('cp1251').decode('utf-8')
        except UnicodeError:
            pass
        indent = line[: len(line) - len(line.lstrip())]
        out.append(f"{indent}{name} = '{val}';")
        print(name, '->', val)
    else:
        out.append(line)

path.write_bytes('\n'.join(out).replace('\n', '\r\n').encode('utf-8'))
print('written', path)
