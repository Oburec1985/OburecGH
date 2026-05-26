unit testBaseObj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ubaseobjLaz;

var
  Root: TBaseObj;

// --- Аннотации ---
// Создает тестовое дерево объектов TBaseObj.
procedure CreateTestTree;

// Проверка сохранения и загрузки в XML (в файл).
// Создаёт копию дерева Root, сохраняет в временный файл, загружает в новый объект,
// проверяет совпадение структуры (имена, количество потомков), освобождает объекты.
procedure TestSaveLoadXML;

// Проверка сохранения и загрузки в строку в INI-файле.
// Сериализует Root в XML-строку, записывает её в секцию INI, читает обратно,
// загружает в новый объект и проверяет структуру.
procedure TestSaveLoadStringInIni;

implementation

uses
  IniFiles;

// --- Реализация ---

procedure CreateTestTree;
var
  Child1, Child2, GrandChild1, GrandChild2, GrandChild3: TBaseObj;
begin
  // Создаем корневой элемент
  Root := TBaseObj.Create;
  Root.Name := 'Root';
  Root.Caption := 'Корневой элемент';
  Root.ImageIndex := 0;

  // --- Первая ветка ---
  Child1 := TBaseObj.Create;
  Child1.Name := 'Child1';
  Child1.Caption := 'Потомок 1';
  Child1.ImageIndex := 1;
  Root.AddChild(Child1); // Добавляем в корень

  GrandChild1 := TBaseObj.Create;
  GrandChild1.Name := 'GrandChild1_1';
  GrandChild1.Caption := 'Внук 1.1';
  GrandChild1.ImageIndex := 2;
  Child1.AddChild(GrandChild1); // Добавляем в Потомок 1

  GrandChild2 := TBaseObj.Create;
  GrandChild2.Name := 'GrandChild1_2';
  GrandChild2.Caption := 'Внук 1.2';
  GrandChild2.ImageIndex := 2;
  Child1.AddChild(GrandChild2); // Добавляем в Потомок 1

  // --- Вторая ветка ---
  Child2 := TBaseObj.Create;
  Child2.Name := 'Child2';
  Child2.Caption := 'Потомок 2';
  Child2.ImageIndex := 1;
  Root.AddChild(Child2); // Добавляем в корень

  GrandChild3 := TBaseObj.Create;
  GrandChild3.Name := 'GrandChild2_1';
  GrandChild3.Caption := 'Внук 2.1';
  GrandChild3.ImageIndex := 2;
  Child2.AddChild(GrandChild3); // Добавляем в Потомок 2
end;

// --- Вспомогательная: проверка совпадения структуры двух деревьев по именам и количеству потомков ---
function TreesStructureEqual(A, B: TBaseObj): Boolean;
var
  i: Integer;
begin
  Result := False;
  if (A = nil) and (B = nil) then
  begin
    Result := True;
    Exit;
  end;
  if (A = nil) or (B = nil) then
    Exit;
  if CompareText(A.Name, B.Name) <> 0 then
    Exit;
  if A.GetChildCount <> B.GetChildCount then
    Exit;
  Result := True;
  for i := 0 to A.GetChildCount - 1 do
    if not TreesStructureEqual(A.GetChild(i), B.GetChild(i)) then
    begin
      Result := False;
      Exit;
    end;
end;

procedure TestSaveLoadXML;
var
  TempFile: string;
  LoadedRoot: TBaseObj;
begin
  if Root = nil then
    raise Exception.Create('TestSaveLoadXML: Root is nil. Call CreateTestTree first.');
  TempFile := GetTempFileName('', 'baseobj');
  try
    Root.SaveToXML(TempFile);
    LoadedRoot := TBaseObj.Create;
    try
      LoadedRoot.LoadFromXML(TempFile);
      if not TreesStructureEqual(Root, LoadedRoot) then
        raise Exception.Create('TestSaveLoadXML: structure mismatch after load.');
    finally
      LoadedRoot.Free;
    end;
  finally
    if FileExists(TempFile) then
      DeleteFile(TempFile);
  end;
end;

procedure TestSaveLoadStringInIni;
const
  IniSection = 'BaseObjData';
  IniKey = 'XML';
var
  IniPath: string;
  XMLString: string;
  SStream: TStringStream;
  Ini: TIniFile;
  LoadedRoot: TBaseObj;
begin
  if Root = nil then
    raise Exception.Create('TestSaveLoadStringInIni: Root is nil. Call CreateTestTree first.');

  SStream := TStringStream.Create('');
  try
    Root.SaveToXMLStream(SStream);
    XMLString := SStream.DataString;
  finally
    SStream.Free;
  end;

  IniPath := GetTempFileName('', 'ini');
  try
    Ini := TIniFile.Create(IniPath);
    try
      Ini.WriteString(IniSection, IniKey, XMLString);
    finally
      Ini.Free;
    end;

    Ini := TIniFile.Create(IniPath);
    try
      XMLString := Ini.ReadString(IniSection, IniKey, '');
    finally
      Ini.Free;
    end;

    if XMLString = '' then
      raise Exception.Create('TestSaveLoadStringInIni: empty string read from INI.');

    SStream := TStringStream.Create(XMLString);
    try
      LoadedRoot := TBaseObj.Create;
      try
        LoadedRoot.LoadFromXMLStream(SStream);
        if not TreesStructureEqual(Root, LoadedRoot) then
          raise Exception.Create('TestSaveLoadStringInIni: structure mismatch after load from INI.');
      finally
        LoadedRoot.Free;
      end;
    finally
      SStream.Free;
    end;
  finally
    if FileExists(IniPath) then
      DeleteFile(IniPath);
  end;
end;

initialization
  Root := nil;

finalization
  Root.Free;

end.
