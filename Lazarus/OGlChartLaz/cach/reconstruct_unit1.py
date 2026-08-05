import json

def main():
    log_file = r"C:\Users\User\.gemini\antigravity-ide\brain\39557652-c3c6-4d79-900e-1d55eb93e441\.system_generated\logs\transcript.jsonl"
    original_file = r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\backup\unit1.pas"
    target_file = r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

    # Читаем исходный файл в cp1251
    with open(original_file, 'r', encoding='cp1251', errors='replace') as f:
        content = f.read()

    edits = []
    with open(log_file, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            try:
                data = json.loads(line)
            except:
                continue
            
            step_index = data.get("step_index")
            if "tool_calls" in data:
                for tc in data["tool_calls"]:
                    if tc.get("name") == "replace_file_content":
                        args = tc.get("args", {})
                        target = args.get("TargetFile", "")
                        if "unit1.pas" in target:
                            target_content = args.get("TargetContent", "")
                            repl_content = args.get("ReplacementContent", "")
                            if target_content.startswith('"') and target_content.endswith('"'):
                                target_content = json.loads(target_content)
                            if repl_content.startswith('"') and repl_content.endswith('"'):
                                repl_content = json.loads(repl_content)
                            
                            edits.append({
                                "step": step_index,
                                "target": target_content,
                                "replacement": repl_content
                            })

    edits.sort(key=lambda x: x["step"])

    for edit in edits:
        target = edit["target"].replace('\r\n', '\n').replace('\n', '\r\n')
        replacement = edit["replacement"].replace('\r\n', '\n').replace('\n', '\r\n')
        
        if target not in content and target.replace('\r\n', '\n') in content:
            target = target.replace('\r\n', '\n')
            replacement = replacement.replace('\r\n', '\n')

        if target in content:
            content = content.replace(target, replacement)
            print(f"Applied edit from step {edit['step']} successfully")
        else:
            print(f"Warning: target from step {edit['step']} not found in content!")

    # Сохраняем в cp1251
    with open(target_file, 'w', encoding='cp1251', errors='replace', newline='\r\n') as f:
        f.write(content)
    print("Reconstruction finished!")

if __name__ == '__main__':
    main()
