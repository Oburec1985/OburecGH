import os

def patch_file(path, old_text, new_text):
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return False
    
    with open(path, 'r', encoding='cp1251', errors='ignore') as f:
        content = f.read()
    
    if old_text in content:
        new_content = content.replace(old_text, new_text)
        with open(path, 'w', encoding='cp1251') as f:
            f.write(new_content)
        print(f"Patched: {path}")
        return True
    else:
        print(f"Pattern not found in: {path}")
        # Let's try to find it with more flexibility if needed
        return False

# 1. Patch THilbFltFrm
old_hilb = """constructor THilbFltFrm.create(aowner: tcomponent);
begin
  TranslateForm(Self);
  inherited;
  M_slist:=TStringList.Create;
  Caption:='setup '+HilbFltRegName;
end;"""

new_hilb = """constructor THilbFltFrm.create(aowner: tcomponent);
begin
  inherited;
  TranslateForm(Self);
  M_slist:=TStringList.Create;
  Caption:=_('setup ')+HilbFltRegName;
end;"""

patch_file(r'forms\uFrmHibFltFrm.pas', old_hilb, new_hilb)

# 2. Patch TGraphFrm (uGraphMngFrm.pas)
old_graph = """constructor TGraphFrm.Create(AOwner: TComponent);
begin
  TranslateForm(Self);
  inherited;"""

new_graph = """constructor TGraphFrm.Create(AOwner: TComponent);
begin
  inherited;
  TranslateForm(Self);"""

patch_file(r'forms\uGraphMngFrm.pas', old_graph, new_graph)
