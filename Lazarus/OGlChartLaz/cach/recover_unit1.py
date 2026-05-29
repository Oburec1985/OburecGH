import json

def main():
    log_file = r"C:\Users\User\.gemini\antigravity-ide\brain\39557652-c3c6-4d79-900e-1d55eb93e441\.system_generated\logs\transcript.jsonl"
    
    with open(log_file, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            try:
                data = json.loads(line)
            except:
                continue
            
            # Ищем шаг, где был совершен просмотр unit1.pas
            # Обычно это шаг типа VIEW_FILE с результатом в поле content или output
            if data.get("type") == "VIEW_FILE" or "view_file" in str(data):
                # Проверим, относится ли это к unit1.pas
                content_str = json.dumps(data)
                if "unit1.pas" in content_str and "procedure TForm1" in content_str:
                    print(f"Found view_file step {data.get('step_index')}")
                    # Сохраним содержимое в файл
                    # Вытащим поле output
                    out = data.get("output", "")
                    if not out and "content" in data:
                        out = data["content"]
                    
                    # Если нашли, запишем в unit1_recovered.pas
                    if out:
                        # Очистим номера строк типа "1: unit Unit1;"
                        lines = out.split('\n')
                        cleaned_lines = []
                        for l in lines:
                            # Шаблон: "123:  код" или "123:код"
                            m = json.dumps(l)
                            # Просто уберем префикс "число: " если он есть
                            cleaned = l
                            if ":" in l:
                                parts = l.split(":", 1)
                                if parts[0].strip().isdigit():
                                    cleaned = parts[1]
                                    if cleaned.startswith(" "):
                                        cleaned = cleaned[1:]
                            cleaned_lines.append(cleaned)
                        
                        recovered_content = '\r\n'.join(cleaned_lines)
                        with open(r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1_recovered.pas", 'w', encoding='cp1251', newline='\r\n') as out_f:
                            out_f.write(recovered_content)
                        print("Saved to unit1_recovered.pas")

if __name__ == '__main__':
    main()
