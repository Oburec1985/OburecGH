import sys

def main():
    filename = sys.argv[1]
    start_line = int(sys.argv[2])
    end_line = int(sys.argv[3])
    with open(filename, 'r', encoding='cp1251', errors='replace') as f:
        lines = f.readlines()
    for i in range(start_line - 1, min(end_line, len(lines))):
        print(f"{i+1}: {lines[i]}", end='')

if __name__ == '__main__':
    main()
