unit uLuaCalcSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls,
  uRecorderTags;

procedure ShowLuaCalcSettings(AOwner: TComponent; const AProjectDir: string;
  ATags: TRecorderTagRegistry);

implementation

uses
  Dialogs, IniFiles, Menus;

type
  TLuaCalcSettingsForm = class(TForm)
  private
    fScripts: TListBox;
    fEditor: TMemo;
    fTags: TListBox;
    fFunctions: TListBox;
    fDirectory: string;
    fConfigFile: string;
    fCurrentFile: string;
    fTagRegistry: TRecorderTagRegistry;
    procedure LoadScripts;
    procedure SaveConfig;
    procedure SaveAndCheckCurrent;
    procedure OfferMissingTags;
    procedure RefreshTags;
    procedure SelectScript(Sender: TObject);
    procedure AddScript(Sender: TObject);
    procedure DeleteScript(Sender: TObject);
    procedure SaveScript(Sender: TObject);
    procedure Closing(Sender: TObject; var CloseAction: TCloseAction);
    procedure InsertTag(Sender: TObject);
    procedure InsertFunction(Sender: TObject);
    procedure ShowFunctionHelp(Sender: TObject);
    procedure FunctionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function ScriptPath(const AName: string): string;
  public
    constructor CreateForProject(AOwner: TComponent;
      const AProjectDir: string; ATags: TRecorderTagRegistry);
  end;

procedure ShowLuaCalcSettings(AOwner: TComponent; const AProjectDir: string;
  ATags: TRecorderTagRegistry);
var
  lForm: TLuaCalcSettingsForm;
begin
  lForm := TLuaCalcSettingsForm.CreateForProject(AOwner, AProjectDir, ATags);
  try
    lForm.ShowModal;
  finally
    lForm.Free;
  end;
end;

constructor TLuaCalcSettingsForm.CreateForProject(AOwner: TComponent;
  const AProjectDir: string; ATags: TRecorderTagRegistry);
var
  lLeft, lRight, lButtons, lTagPanel, lFunctionPanel: TPanel;
  lButton: TButton;
  lMenu: TPopupMenu;
  lMenuItem: TMenuItem;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Расчётные скрипты Lua';
  Width := 1050;
  Height := 650;
  Position := poScreenCenter;
  OnClose := @Closing;
  fDirectory := IncludeTrailingPathDelimiter(AProjectDir) + 'LuaCalc';
  fConfigFile := IncludeTrailingPathDelimiter(AProjectDir) + 'LuaCalc.ini';
  fTagRegistry := ATags;

  lLeft := TPanel.Create(Self);
  lLeft.Parent := Self;
  lLeft.Align := alLeft;
  lLeft.Width := 215;
  lLeft.Caption := '';
  fScripts := TListBox.Create(Self);
  fScripts.Parent := lLeft;
  fScripts.Align := alClient;
  fScripts.OnClick := @SelectScript;
  lButtons := TPanel.Create(Self);
  lButtons.Parent := lLeft;
  lButtons.Align := alBottom;
  lButtons.Height := 72;
  lButtons.Caption := '';
  lButton := TButton.Create(Self);
  lButton.Parent := lButtons;
  lButton.SetBounds(8, 8, 90, 26);
  lButton.Caption := 'Добавить';
  lButton.OnClick := @AddScript;
  lButton := TButton.Create(Self);
  lButton.Parent := lButtons;
  lButton.SetBounds(108, 8, 90, 26);
  lButton.Caption := 'Удалить';
  lButton.OnClick := @DeleteScript;
  lButton := TButton.Create(Self);
  lButton.Parent := lButtons;
  lButton.SetBounds(8, 39, 190, 26);
  lButton.Caption := 'Сохранить код';
  lButton.OnClick := @SaveScript;

  lRight := TPanel.Create(Self);
  lRight.Parent := Self;
  lRight.Align := alRight;
  lRight.Width := 235;
  lRight.Caption := '';
  lFunctionPanel := TPanel.Create(Self);
  lFunctionPanel.Parent := lRight;
  lFunctionPanel.Align := alBottom;
  lFunctionPanel.Height := 230;
  lFunctionPanel.Caption := '';
  lButton := TButton.Create(Self);
  lButton.Parent := lFunctionPanel;
  lButton.Align := alTop;
  lButton.Height := 30;
  lButton.Caption := 'Функции RecorderLnx';
  lButton.Enabled := False;
  fFunctions := TListBox.Create(Self);
  fFunctions.Parent := lFunctionPanel;
  fFunctions.Align := alClient;
  fFunctions.Items.Add('logMessage');
  fFunctions.Items.Add('getValue');
  fFunctions.Items.Add('setValue');
  fFunctions.OnDblClick := @InsertFunction;
  fFunctions.OnMouseDown := @FunctionMouseDown;
  lMenu := TPopupMenu.Create(Self);
  lMenuItem := TMenuItem.Create(lMenu);
  lMenuItem.Caption := 'Справка по функции';
  lMenuItem.OnClick := @ShowFunctionHelp;
  lMenu.Items.Add(lMenuItem);
  fFunctions.PopupMenu := lMenu;
  lTagPanel := TPanel.Create(Self);
  lTagPanel.Parent := lRight;
  lTagPanel.Align := alClient;
  lTagPanel.Caption := '';
  lButton := TButton.Create(Self);
  lButton.Parent := lTagPanel;
  lButton.Align := alTop;
  lButton.Height := 30;
  lButton.Caption := 'Теги: двойной щелчок вставляет';
  lButton.Enabled := False;
  fTags := TListBox.Create(Self);
  fTags.Parent := lTagPanel;
  fTags.Align := alClient;
  fTags.OnDblClick := @InsertTag;
  fTags.Sorted := True;
  RefreshTags;

  fEditor := TMemo.Create(Self);
  fEditor.Parent := Self;
  fEditor.Align := alClient;
  fEditor.ScrollBars := ssBoth;
  fEditor.WordWrap := False;
  fEditor.Font.Name := 'Consolas';
  fEditor.Font.Size := 10;
  LoadScripts;
end;

function TLuaCalcSettingsForm.ScriptPath(const AName: string): string;
begin
  Result := IncludeTrailingPathDelimiter(fDirectory) + AName + '.lua';
end;

procedure TLuaCalcSettingsForm.LoadScripts;
var
  lSearch: TSearchRec;
  lIni: TIniFile;
  lFileName: string;
  lConfigured: Boolean;
  I: Integer;
begin
  fScripts.Items.Clear;
  fScripts.Sorted := True;
  lConfigured := False;
  if FileExists(fConfigFile) then
  begin
    lIni := TIniFile.Create(fConfigFile);
    try
      lConfigured := lIni.ValueExists('LuaCalc', 'ScriptCount');
      if lConfigured then
        for I := 0 to lIni.ReadInteger('LuaCalc', 'ScriptCount', 0) - 1 do
        begin
          lFileName := lIni.ReadString('LuaCalc', 'Script' + IntToStr(I), '');
          if (lFileName <> '') and
            (ExtractFileName(lFileName) = lFileName) and
            SameText(ExtractFileExt(lFileName), '.lua') and
            FileExists(IncludeTrailingPathDelimiter(fDirectory) + lFileName) then
            fScripts.Items.Add(ChangeFileExt(lFileName, ''));
        end;
    finally
      lIni.Free;
    end;
    if lConfigured then Exit;
  end;
  if FindFirst(IncludeTrailingPathDelimiter(fDirectory) + '*.lua',
    faAnyFile, lSearch) = 0 then
  try
    repeat
      if (lSearch.Attr and faDirectory) = 0 then
        fScripts.Items.Add(ChangeFileExt(lSearch.Name, ''));
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
  SaveConfig;
end;

procedure TLuaCalcSettingsForm.SaveConfig;
var
  lIni: TIniFile;
  lOldCount, I: Integer;
begin
  ForceDirectories(ExtractFileDir(fConfigFile));
  lIni := TIniFile.Create(fConfigFile);
  try
    lOldCount := lIni.ReadInteger('LuaCalc', 'ScriptCount', 0);
    lIni.WriteInteger('LuaCalc', 'ScriptCount', fScripts.Items.Count);
    for I := 0 to fScripts.Items.Count - 1 do
      lIni.WriteString('LuaCalc', 'Script' + IntToStr(I),
        fScripts.Items[I] + '.lua');
    for I := fScripts.Items.Count to lOldCount - 1 do
      lIni.DeleteKey('LuaCalc', 'Script' + IntToStr(I));
  finally
    lIni.Free;
  end;
end;

procedure TLuaCalcSettingsForm.SelectScript(Sender: TObject);
begin
  if fScripts.ItemIndex < 0 then Exit;
  SaveAndCheckCurrent;
  fCurrentFile := ScriptPath(fScripts.Items[fScripts.ItemIndex]);
  fEditor.Lines.LoadFromFile(fCurrentFile);
end;

procedure TLuaCalcSettingsForm.RefreshTags;
var
  I: Integer;
begin
  fTags.Items.BeginUpdate;
  try
    fTags.Items.Clear;
    if fTagRegistry <> nil then
      for I := 0 to fTagRegistry.TagCount - 1 do
        fTags.Items.Add(fTagRegistry.Tags[I].Name);
  finally
    fTags.Items.EndUpdate;
  end;
end;

procedure TLuaCalcSettingsForm.SaveAndCheckCurrent;
begin
  if fCurrentFile = '' then Exit;
  if fEditor.Modified then SaveScript(Self);
  OfferMissingTags;
end;

procedure TLuaCalcSettingsForm.OfferMissingTags;
var
  lCode, lName, lList, lTail, lBefore: string;
  lNames: TStringList;
  lIndex, lEnd, I: Integer;
  lTag: TRecorderTag;
begin
  if fTagRegistry = nil then Exit;
  lCode := fEditor.Text;
  lNames := TStringList.Create;
  try
    lNames.CaseSensitive := False;
    lIndex := 1;
    while lIndex <= Length(lCode) do
    begin
      if lCode[lIndex] = '{' then
      begin
        lEnd := Pos('}', lCode, lIndex + 1);
        if lEnd > lIndex + 1 then
        begin
          lName := Trim(Copy(lCode, lIndex + 1, lEnd - lIndex - 1));
          lTail := TrimLeft(Copy(lCode, lEnd + 1, 12));
          lBefore := Copy(lCode, 1, lIndex - 1);
          lBefore := Copy(lBefore, LastDelimiter(#10, lBefore) + 1, MaxInt);
          if (lName <> '') and (Pos(#10, lName) = 0) and
            (Pos('--', lBefore) = 0) and
            ((Copy(lCode, lEnd + 1, 6) = '.Value') or
             ((lTail <> '') and (lTail[1] = '='))) and
            (fTagRegistry.FindByName(lName) = nil) and
            (lNames.IndexOf(lName) < 0) then
            lNames.Add(lName);
          lIndex := lEnd;
        end;
      end;
      Inc(lIndex);
    end;
    if lNames.Count = 0 then Exit;
    lList := '';
    for I := 0 to lNames.Count - 1 do
      lList := lList + '• ' + lNames[I] + LineEnding;
    if MessageDlg('Создать отсутствующие виртуальные теги?' + LineEnding +
      lList, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
    for I := 0 to lNames.Count - 1 do
    begin
      if fTagRegistry.FindByName(lNames[I]) <> nil then Continue;
      lTag := fTagRegistry.CreateTag(lNames[I], 4096, True);
      lTag.SourceId := 'manual';
      lTag.SourceValueMode := 'scalar';
      lTag.Address := 'virtual.' + lNames[I];
      lTag.ModuleType := 'Virtual';
      lTag.Description := 'Расчётный виртуальный тег Lua';
      lTag.UnitName := '-';
      lTag.AutoUnit := False;
    end;
    RefreshTags;
  finally
    lNames.Free;
  end;
end;

procedure TLuaCalcSettingsForm.AddScript(Sender: TObject);
var
  lName: string;
  lChar: Char;
begin
  lName := '';
  if not InputQuery('Новая подпрограмма', 'Имя скрипта:', lName) then Exit;
  lName := Trim(lName);
  if lName = '' then Exit;
  for lChar in lName do
    if not (lChar in ['A'..'Z', 'a'..'z', '0'..'9', '_', '-']) then
    begin
      MessageDlg('Имя файла: только латиница, цифры, _ и -.',
        mtError, [mbOK], 0);
      Exit;
    end;
  if FileExists(ScriptPath(lName)) then
  begin
    MessageDlg('Подпрограмма уже существует.', mtInformation, [mbOK], 0);
    Exit;
  end;
  SaveAndCheckCurrent;
  ForceDirectories(fDirectory);
  fEditor.Lines.Text := 'function lua_main()' + LineEnding +
    '  -- setValue("Result", {Source}.Value)' + LineEnding + 'end';
  fCurrentFile := ScriptPath(lName);
  fEditor.Lines.SaveToFile(fCurrentFile);
  fScripts.Items.Add(lName);
  SaveConfig;
  fScripts.ItemIndex := fScripts.Items.IndexOf(lName);
end;

procedure TLuaCalcSettingsForm.DeleteScript(Sender: TObject);
begin
  if fScripts.ItemIndex < 0 then Exit;
  if MessageDlg('Удалить подпрограмму ' + fScripts.Items[fScripts.ItemIndex] + '?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  DeleteFile(ScriptPath(fScripts.Items[fScripts.ItemIndex]));
  fScripts.Items.Delete(fScripts.ItemIndex);
  SaveConfig;
  fCurrentFile := '';
  fEditor.Clear;
end;

procedure TLuaCalcSettingsForm.SaveScript(Sender: TObject);
begin
  if fCurrentFile = '' then Exit;
  fEditor.Lines.SaveToFile(fCurrentFile);
  fEditor.Modified := False;
end;

procedure TLuaCalcSettingsForm.Closing(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  SaveAndCheckCurrent;
end;

procedure TLuaCalcSettingsForm.InsertTag(Sender: TObject);
begin
  if (fTags.ItemIndex < 0) or (fCurrentFile = '') then Exit;
  fEditor.SelText := '{' + fTags.Items[fTags.ItemIndex] + '}.Value';
  fEditor.SetFocus;
end;

procedure TLuaCalcSettingsForm.InsertFunction(Sender: TObject);
const
  Templates: array[0..2] of string = (
    'logMessage("Сообщение")',
    'getValue("ИмяТега")',
    'setValue("ИмяТега", 0)');
begin
  if (fCurrentFile = '') or (fFunctions.ItemIndex < 0) or
    (fFunctions.ItemIndex > High(Templates)) then Exit;
  fEditor.SelText := Templates[fFunctions.ItemIndex];
  fEditor.SetFocus;
end;

procedure TLuaCalcSettingsForm.FunctionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    fFunctions.ItemIndex := fFunctions.ItemAtPos(Point(X, Y), True);
end;

procedure TLuaCalcSettingsForm.ShowFunctionHelp(Sender: TObject);
const
  Descriptions: array[0..2] of string = (
    'logMessage(текст)' + LineEnding +
      'Добавляет строку в системный журнал RecorderLnx.',
    'getValue(имяТега)' + LineEnding +
      'Читает последнее числовое значение тега. Ссылка {Имя}.Value делает то же.',
    'setValue(имяТега, значение)' + LineEnding +
      'Записывает число в существующий виртуальный тег.');
begin
  if (fFunctions.ItemIndex < 0) or
    (fFunctions.ItemIndex > High(Descriptions)) then Exit;
  MessageDlg(fFunctions.Items[fFunctions.ItemIndex],
    Descriptions[fFunctions.ItemIndex], mtInformation, [mbOK], 0);
end;

end.
