unit uLuaCalcSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls,
  SynEdit, uRecorderTags, uLuaSyntaxHighlighter;

procedure ShowLuaCalcSettings(AOwner: TComponent; const AProjectDir: string;
  ATags: TRecorderTagRegistry);

implementation

uses
  Dialogs, IniFiles, Menus, LCLType, LazUTF8, uLuaCalcEngine
  {$ifdef Windows}, ShellApi{$endif};

type
  TLuaCalcSettingsForm = class(TForm)
  private
    fScripts: TListBox;
    fEditor: TSynEdit;
    fHighlighter: TLuaSyntaxHighlighter;
    fTags: TListBox;
    fTagFilter: TEdit;
    fFunctions: TTreeView;
    fDirectory: string;
    fConfigFile: string;
    fCurrentFile: string;
    fTagRegistry: TRecorderTagRegistry;
    procedure LoadScripts;
    procedure SaveConfig;
    procedure SaveAndCheckCurrent;
    procedure OfferMissingTags;
    procedure RefreshTags;
    procedure TagFilterChanged(Sender: TObject);
    procedure SelectScript(Sender: TObject);
    procedure AddScript(Sender: TObject);
    procedure DeleteScript(Sender: TObject);
    procedure SaveScript(Sender: TObject);
    procedure TestScript(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ChangeSelectionIndent(AOutdent: Boolean);
    procedure Closing(Sender: TObject; var CloseAction: TCloseAction);
    procedure InsertTag(Sender: TObject);
    procedure InsertFunction(Sender: TObject);
    function FunctionTemplate(AIndex: Integer): string;
    function FunctionHelpTopic(AIndex: Integer): string;
    function OpenFunctionHelp(AIndex: Integer): Boolean;
    procedure InsertEditorTemplate(const ATemplate: string);
    procedure ShowFunctionHelp(Sender: TObject);
    procedure FunctionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FunctionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PopulateFunctionTree;
    function SelectedTemplateIndex: Integer;
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
  lEditorSplitter, lTagFunctionSplitter: TSplitter;
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
  lButtons.Height := 103;
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
  lButton := TButton.Create(Self);
  lButton.Parent := lButtons;
  lButton.SetBounds(8, 70, 190, 26);
  lButton.Caption := 'Test';
  lButton.OnClick := @TestScript;

  lRight := TPanel.Create(Self);
  lRight.Parent := Self;
  lRight.Align := alRight;
  lRight.Width := 235;
  lRight.Caption := '';
  lEditorSplitter := TSplitter.Create(Self);
  lEditorSplitter.Parent := Self;
  lEditorSplitter.Align := alRight;
  lEditorSplitter.Width := 5;
  lEditorSplitter.MinSize := 150;
  lEditorSplitter.Cursor := crHSplit;
  lFunctionPanel := TPanel.Create(Self);
  lFunctionPanel.Parent := lRight;
  lFunctionPanel.Align := alBottom;
  lFunctionPanel.Height := 230;
  lFunctionPanel.Caption := '';
  lButton := TButton.Create(Self);
  lButton.Parent := lFunctionPanel;
  lButton.Align := alTop;
  lButton.Height := 30;
  lButton.Caption := 'Функции и шаблоны Lua';
  lButton.Enabled := False;
  fFunctions := TTreeView.Create(Self);
  fFunctions.Parent := lFunctionPanel;
  fFunctions.Align := alClient;
  fFunctions.ReadOnly := True;
  fFunctions.HideSelection := False;
  PopulateFunctionTree;
  fFunctions.OnDblClick := @InsertFunction;
  fFunctions.OnMouseDown := @FunctionMouseDown;
  fFunctions.OnKeyDown := @FunctionKeyDown;
  lMenu := TPopupMenu.Create(Self);
  lMenuItem := TMenuItem.Create(lMenu);
  lMenuItem.Caption := 'Справка по функции';
  lMenuItem.OnClick := @ShowFunctionHelp;
  lMenu.Items.Add(lMenuItem);
  fFunctions.PopupMenu := lMenu;
  lTagFunctionSplitter := TSplitter.Create(Self);
  lTagFunctionSplitter.Parent := lRight;
  lTagFunctionSplitter.Align := alBottom;
  lTagFunctionSplitter.Height := 5;
  lTagFunctionSplitter.MinSize := 80;
  lTagFunctionSplitter.Cursor := crVSplit;
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
  fTagFilter := TEdit.Create(Self);
  fTagFilter.Parent := lTagPanel;
  fTagFilter.Align := alTop;
  fTagFilter.TextHint := 'Поиск по тегам';
  fTagFilter.OnChange := @TagFilterChanged;
  fTags := TListBox.Create(Self);
  fTags.Parent := lTagPanel;
  fTags.Align := alClient;
  fTags.OnDblClick := @InsertTag;
  fTags.Sorted := True;
  RefreshTags;

  fEditor := TSynEdit.Create(Self);
  fEditor.Parent := Self;
  fEditor.Align := alClient;
  fEditor.ScrollBars := ssBoth;
  fEditor.Font.Name := 'Consolas';
  fEditor.Font.Size := 10;
  fEditor.TabWidth := 2;
  fHighlighter := TLuaSyntaxHighlighter.Create(Self);
  fEditor.Highlighter := fHighlighter;
  fEditor.OnKeyDown := @EditorKeyDown;
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
  if SysUtils.FindFirst(IncludeTrailingPathDelimiter(fDirectory) + '*.lua',
    faAnyFile, lSearch) = 0 then
  try
    repeat
      if (lSearch.Attr and faDirectory) = 0 then
        fScripts.Items.Add(ChangeFileExt(lSearch.Name, ''));
    until SysUtils.FindNext(lSearch) <> 0;
  finally
    SysUtils.FindClose(lSearch);
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
  lFilter, lTagName: string;
begin
  lFilter := UTF8LowerCase(Trim(fTagFilter.Text));
  fTags.Items.BeginUpdate;
  try
    fTags.Items.Clear;
    if fTagRegistry <> nil then
      for I := 0 to fTagRegistry.TagCount - 1 do
      begin
        lTagName := fTagRegistry.Tags[I].Name;
        if (lFilter = '') or
          (Pos(lFilter, UTF8LowerCase(lTagName)) > 0) then
          fTags.Items.Add(lTagName);
      end;
  finally
    fTags.Items.EndUpdate;
  end;
end;

procedure TLuaCalcSettingsForm.TagFilterChanged(Sender: TObject);
begin
  RefreshTags;
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
      lList := lList + UTF8Encode('• ') + lNames[I] + LineEnding;
    if MessageDlg(UTF8Encode('Создать отсутствующие виртуальные теги?') +
      LineEnding +
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
  fEditor.Lines.Text :=
    '-- Однострочный комментарий: текст после -- не выполняется' + LineEnding +
    '--[[' + LineEnding +
    'Многострочный комментарий: весь текст внутри блока не выполняется.' + LineEnding +
    ']]' + LineEnding + LineEnding +
    'function lua_main()' + LineEnding +
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
  if MessageDlg(UTF8Encode('Удалить подпрограмму ') +
    fScripts.Items[fScripts.ItemIndex] + '?',
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

procedure TLuaCalcSettingsForm.TestScript(Sender: TObject);
var
  lEngine: TLuaCalcEngine;
begin
  if fCurrentFile = '' then Exit;
  lEngine := TLuaCalcEngine.Create;
  try
    if lEngine.Validate(UTF8String(fEditor.Text)) then
      MessageDlg('Проверка Lua', 'OK', mtInformation, [mbOK], 0)
    else
      MessageDlg('Ошибка Lua', lEngine.LastError, mtError, [mbOK], 0);
  finally
    lEngine.Free;
  end;
end;

procedure TLuaCalcSettingsForm.EditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <> VK_TAB then Exit;
  ChangeSelectionIndent(ssCtrl in Shift);
  Key := 0;
end;

procedure TLuaCalcSettingsForm.ChangeSelectionIndent(AOutdent: Boolean);
var
  lText, lLine, lResult: string;
  lLines: TStringList;
  lSelectionStart, I: Integer;
begin
  lSelectionStart := fEditor.SelStart;
  lText := fEditor.SelText;
  if lText = '' then
  begin
    if not AOutdent then
      fEditor.SelText := #9;
    Exit;
  end;
  lLines := TStringList.Create;
  try
    lLines.Text := lText;
    lResult := '';
    for I := 0 to lLines.Count - 1 do
    begin
      lLine := lLines[I];
      if AOutdent then
      begin
        if (lLine <> '') and (lLine[1] = #9) then
          Delete(lLine, 1, 1)
        else
        begin
          if (lLine <> '') and (lLine[1] = ' ') then Delete(lLine, 1, 1);
          if (lLine <> '') and (lLine[1] = ' ') then Delete(lLine, 1, 1);
        end;
      end
      else
        lLine := #9 + lLine;
      if I > 0 then lResult := lResult + LineEnding;
      lResult := lResult + lLine;
    end;
    fEditor.SelText := lResult;
    fEditor.SelStart := lSelectionStart;
    fEditor.SelEnd := lSelectionStart + Length(lResult);
  finally
    lLines.Free;
  end;
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

function TLuaCalcSettingsForm.FunctionTemplate(AIndex: Integer): string;
const
  Templates: array[0..25] of string = (
    'if условие then' + LineEnding +
      '  -- действия' + LineEnding +
      'end',
    'if условие then' + LineEnding +
      '  -- действия, если условие истинно' + LineEnding +
      'else' + LineEnding +
      '  -- действия, если условие ложно' + LineEnding +
      'end',
    'for i = 1, N do' + LineEnding +
      '  -- действия' + LineEnding +
      'end',
    'while условие do' + LineEnding +
      '  -- действия' + LineEnding +
      'end',
    'repeat' + LineEnding +
      '  -- действия' + LineEnding +
      'until условие',
    'local значение = 0',
    'math.abs(значение)',
    'math.min(значение1, значение2)',
    'math.max(значение1, значение2)',
    'math.sqrt(значение)',
    'tostring(значение)',
    'string.format("%.2f", значение)',
    '{ИмяТега}.Value',
    '{ИмяТега} = 0',
    'getValue("ИмяТега")',
    'setValue("ИмяТега", 0)',
    'getTagTime("ИмяТега")',
    'local значение, время = getTagSample("ИмяТега")',
    'tagExists("ИмяТега")',
    'local порог, включена = getTagSetpoint("ИмяТега", "highAlarm")',
    'setTagSetpoint("ИмяТега", "highAlarm", 100, 1)',
    'getTagAlarmLevel("ИмяТега")',
    'local уровень = getTagAlarmLevel("ИмяТега")' + LineEnding +
      'if уровень == 2 then' + LineEnding +
      '  logMessage("Авария тега ИмяТега")' + LineEnding +
      'elseif уровень == 1 then' + LineEnding +
      '  logMessage("Предупреждение тега ИмяТега")' + LineEnding +
      'end',
    'logMessage("Сообщение")',
    'getRecorderTime()',
    'SetTagValue("ИмяТега", 0, 1.0)');
begin
  Result := '';
  if (AIndex >= Low(Templates)) and (AIndex <= High(Templates)) then
    Result := Templates[AIndex];
end;

function TLuaCalcSettingsForm.FunctionHelpTopic(AIndex: Integer): string;
const
  Topics: array[0..25] of string = (
    'if_then', 'if_else', 'for', 'while', 'repeat_until', 'local',
    'math_abs', 'math_min', 'math_max', 'math_sqrt', 'tostring',
    'string_format', 'tag_value', 'tag_write', 'get_value', 'set_value',
    'get_tag_time', 'get_tag_sample', 'tag_exists', 'get_tag_setpoint',
    'set_tag_setpoint', 'get_tag_alarm_level', 'alarm_handling',
    'log_message', 'get_recorder_time', 'set_tag_value_delayed');
begin
  Result := '';
  if (AIndex >= Low(Topics)) and (AIndex <= High(Topics)) then
    Result := Topics[AIndex];
end;

function TLuaCalcSettingsForm.OpenFunctionHelp(AIndex: Integer): Boolean;
{$ifdef Windows}
var
  lHelpFile, lTarget: UnicodeString;
{$endif}
begin
  Result := False;
  if FunctionHelpTopic(AIndex) = '' then Exit;
  {$ifdef Windows}
  lHelpFile := IncludeTrailingPathDelimiter(
    ExtractFilePath(UTF8Decode(ParamStr(0)))) +
    'help\RecorderLnxLua.chm';
  if not FileExists(lHelpFile) then
    lHelpFile := ExpandFileName(ExtractFilePath(UTF8Decode(ParamStr(0))) +
      '..\..\Docs\LuaHelp\RecorderLnxLua.chm');
  if not FileExists(lHelpFile) then
    lHelpFile := ExpandFileName(ExtractFilePath(UTF8Decode(ParamStr(0))) +
      '..\Docs\LuaHelp\RecorderLnxLua.chm');
  if not FileExists(lHelpFile) then Exit;
  lTarget := '"' + lHelpFile + '::/topics/' +
    UTF8Decode(FunctionHelpTopic(AIndex)) + '.html"';
  Result := ShellExecuteW(0, 'open', 'hh.exe', PWideChar(lTarget), nil,
    1) > 32;
  {$endif}
end;

procedure TLuaCalcSettingsForm.InsertFunction(Sender: TObject);
var
  lTemplate: string;
begin
  if fCurrentFile = '' then Exit;
  lTemplate := FunctionTemplate(SelectedTemplateIndex);
  if lTemplate = '' then Exit;
  InsertEditorTemplate(lTemplate);
  fEditor.SetFocus;
end;

procedure TLuaCalcSettingsForm.InsertEditorTemplate(const ATemplate: string);
var
  lBeforeCaret, lCurrentLine, lIndent, lText: string;
  lLineStart, I: Integer;
begin
  if fEditor.SelStart > 1 then
    lBeforeCaret := Copy(fEditor.Text, 1, fEditor.SelStart - 1)
  else
    lBeforeCaret := '';
  lLineStart := LastDelimiter(#10, lBeforeCaret) + 1;
  lCurrentLine := Copy(lBeforeCaret, lLineStart, MaxInt);
  lIndent := '';
  for I := 1 to Length(lCurrentLine) do
    if lCurrentLine[I] in [' ', #9] then
      lIndent := lIndent + lCurrentLine[I]
    else
      Break;
  lText := StringReplace(ATemplate, LineEnding, LineEnding + lIndent,
    [rfReplaceAll]);
  fEditor.SelText := lText;
end;

procedure TLuaCalcSettingsForm.FunctionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lNode: TTreeNode;
begin
  if Button = mbRight then
  begin
    lNode := fFunctions.GetNodeAt(X, Y);
    if lNode <> nil then fFunctions.Selected := lNode;
  end;
end;

procedure TLuaCalcSettingsForm.FunctionKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <> VK_F1 then Exit;
  ShowFunctionHelp(Sender);
  Key := 0;
end;

function TLuaCalcSettingsForm.SelectedTemplateIndex: Integer;
begin
  Result := -1;
  if (fFunctions.Selected <> nil) and (fFunctions.Selected.Data <> nil) then
    Result := PtrInt(fFunctions.Selected.Data) - 1;
end;

procedure TLuaCalcSettingsForm.PopulateFunctionTree;
  procedure AddTemplate(AParent: TTreeNode; const ACaption: string;
    AIndex: Integer);
  var
    lNode: TTreeNode;
  begin
    lNode := fFunctions.Items.AddChild(AParent, ACaption);
    lNode.Data := Pointer(PtrInt(AIndex + 1));
  end;
var
  lStandard, lConditions, lLoops, lValues: TTreeNode;
  lRecorder, lTags, lSetpoints, lAlarms, lSystem: TTreeNode;
begin
  fFunctions.Items.BeginUpdate;
  try
    fFunctions.Items.Clear;
    lStandard := fFunctions.Items.Add(nil, 'Стандартные функции Lua');
    lConditions := fFunctions.Items.AddChild(lStandard, 'Условия');
    AddTemplate(lConditions, 'if ... then', 0);
    AddTemplate(lConditions, 'if ... then ... else', 1);
    lLoops := fFunctions.Items.AddChild(lStandard, 'Циклы');
    AddTemplate(lLoops, 'for i = 1, N do', 2);
    AddTemplate(lLoops, 'while ... do', 3);
    AddTemplate(lLoops, 'repeat ... until', 4);
    lValues := fFunctions.Items.AddChild(lStandard, 'Переменные и преобразования');
    AddTemplate(lValues, 'local переменная', 5);
    AddTemplate(lValues, 'math.abs', 6);
    AddTemplate(lValues, 'math.min', 7);
    AddTemplate(lValues, 'math.max', 8);
    AddTemplate(lValues, 'math.sqrt', 9);
    AddTemplate(lValues, 'tostring', 10);
    AddTemplate(lValues, 'string.format', 11);

    lRecorder := fFunctions.Items.Add(nil, 'RecorderLnx');
    lTags := fFunctions.Items.AddChild(lRecorder, 'Теги');
    AddTemplate(lTags, '{Тег}.Value — получить значение', 12);
    AddTemplate(lTags, '{Тег} = значение — записать', 13);
    AddTemplate(lTags, 'getValue', 14);
    AddTemplate(lTags, 'setValue', 15);
    AddTemplate(lTags, 'SetTagValue — отложенная запись', 25);
    AddTemplate(lTags, 'getTagTime', 16);
    AddTemplate(lTags, 'getTagSample', 17);
    AddTemplate(lTags, 'tagExists', 18);
    lSetpoints := fFunctions.Items.AddChild(lRecorder, 'Уставки');
    AddTemplate(lSetpoints, 'getTagSetpoint', 19);
    AddTemplate(lSetpoints, 'setTagSetpoint', 20);
    lAlarms := fFunctions.Items.AddChild(lRecorder, 'Аварии');
    AddTemplate(lAlarms, 'getTagAlarmLevel', 21);
    AddTemplate(lAlarms, 'Обработка аварии', 22);
    lSystem := fFunctions.Items.AddChild(lRecorder, 'Система');
    AddTemplate(lSystem, 'logMessage', 23);
    AddTemplate(lSystem, 'getRecorderTime', 24);
    lStandard.Expand(False);
    lRecorder.Expand(False);
    lTags.Expand(False);
  finally
    fFunctions.Items.EndUpdate;
  end;
end;

procedure TLuaCalcSettingsForm.ShowFunctionHelp(Sender: TObject);
const
  Descriptions: array[0..25] of string = (
    'if условие then ... end' + LineEnding +
      'Выполняет блок, когда условие истинно.',
    'if условие then ... else ... end' + LineEnding +
      'Выбирает один из двух блоков по условию.',
    'for i = 1, N do ... end' + LineEnding +
      'Повторяет блок N раз. Переменная i содержит номер шага.',
    'while условие do ... end' + LineEnding +
      'Повторяет блок, пока условие истинно.',
    'repeat ... until условие' + LineEnding +
      'Повторяет блок до выполнения условия.',
    'local имя = значение' + LineEnding +
      'Создаёт локальную переменную внутри подпрограммы.',
    'math.abs(число) — модуль числа.',
    'math.min(a, b) — меньшее из двух чисел.',
    'math.max(a, b) — большее из двух чисел.',
    'math.sqrt(число) — квадратный корень.',
    'tostring(значение) — преобразует значение в строку.',
    'string.format(формат, значение) — форматирует строку.',
    '{ИмяТега}.Value' + LineEnding + 'Читает последнее значение тега.',
    '{ИмяТега} = значение' + LineEnding +
      'Записывает значение в существующий виртуальный тег.',
    'getValue(имяТега)' + LineEnding + 'Читает последнее значение тега.',
    'setValue(имяТега, значение)' + LineEnding +
      'Записывает число в существующий виртуальный тег.',
    'getTagTime(имяТега)' + LineEnding +
      'Возвращает время последнего значения тега в секундах.',
    'getTagSample(имяТега)' + LineEnding +
      'Возвращает два результата: значение и время измерения.',
    'tagExists(имяТега)' + LineEnding +
      'Возвращает 1, если тег существует, иначе 0.',
    'getTagSetpoint(имяТега, тип)' + LineEnding +
      'Возвращает порог и признак включения (1 или 0).' + LineEnding +
      'Типы: highAlarm, highWarning, lowWarning, lowAlarm.',
    'setTagSetpoint(имяТега, тип, порог, включена)' + LineEnding +
      'Меняет порог и состояние уставки. Включена: 1 или 0.' + LineEnding +
      'Изменение сохраняется при сохранении проекта.',
    'getTagAlarmLevel(имяТега)' + LineEnding +
      'Возвращает 0 — нет аварий, 1 — предупреждение, 2 — авария.',
    'Пример обработки уровня аварии 0, 1 или 2.',
    'logMessage(текст)' + LineEnding +
      'Добавляет строку в системный журнал RecorderLnx.',
    'getRecorderTime()' + LineEnding +
      'Возвращает текущее время данных RecorderLnx в секундах.',
    'SetTagValue(имяТега, значение, задержкаСекунд)' + LineEnding +
      'Записывает значение в тег из отдельного потока после указанной задержки.');
var
  lIndex: Integer;
begin
  lIndex := SelectedTemplateIndex;
  if (lIndex < 0) or (lIndex > High(Descriptions)) then Exit;
  if OpenFunctionHelp(lIndex) then Exit;
  MessageDlg(fFunctions.Selected.Text, Descriptions[lIndex] +
    LineEnding + LineEnding + UTF8Encode('Пример использования:') + LineEnding +
    FunctionTemplate(lIndex),
    mtInformation, [mbOK], 0);
end;

end.
