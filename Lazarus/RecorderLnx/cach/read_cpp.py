import sys

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

def read_lines(filepath, start_line, end_line):
    try:
        with open(filepath, 'r', encoding='cp1251', errors='replace') as f:
            lines = f.readlines()
        for idx in range(start_line - 1, min(end_line, len(lines))):
            print(f"{idx + 1}: {lines[idx]}", end='')
    except Exception as e:
        print(f"Error reading file {filepath}: {e}")

if __name__ == '__main__':
    if len(sys.argv) < 4:
        print("Usage: python read_cpp.py <filepath> <start_line> <end_line>")
    else:
        read_lines(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))
