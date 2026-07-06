import sys
import os

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

def search_files(directory, query):
    query = query.lower()
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.pas') or file.endswith('.pp') or file.endswith('.inc') or file.endswith('.lpr') or file.endswith('.h') or file.endswith('.cpp'):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='cp1251', errors='replace') as f:
                        lines = f.readlines()
                    for idx, line in enumerate(lines):
                        if query in line.lower():
                            print(f"{filepath}:{idx + 1}: {line.strip()}")
                except Exception as e:
                    pass

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python search_cp1251.py <directory> <query>")
    else:
        search_files(sys.argv[1], sys.argv[2])
