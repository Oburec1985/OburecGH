program PluginEditorStateSmoke;
{$mode objfpc}{$H+}
{$PACKRECORDS C}
uses Interfaces, Forms, Controls, ExtCtrls, Classes, SysUtils, IniFiles, LCLType,
  uRecorderFormModel, uRecorderTags, uRecorderPluginRuntime, uFormEditorController,
  uRecorderVisualComponentApiV2;
type
  { The fixture's complete non-view state prefix. View lifecycle counters after
    this prefix legitimately change during editor reconstruction. }
  TProbeModelPrefix = record
    Magic: QWord;
    Value: Int64;
    ObservedTagId: QWord;
    ObservedHistoryCount, Reserved: LongWord;
    ObservedLatestValue: Double;
    ObservedRevision: QWord;
    ObservedTagInfo: TRecorderVisualTagInfoV2;
    ConfiguredContext: TRecorderVisualCreateContextV2;
  end;
  TPageProvider = class
    Page: TRecorderFormPage;
    function GetPage: TRecorderFormPage;
  end;
  TControlAccess = class(TControl);
function TPageProvider.GetPage: TRecorderFormPage;
begin Result := Page; end;
procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;
function ModelPrefix(AComponent: TRecorderPluginVisualComponent): TProbeModelPrefix;
var lBytes: TRecorderPluginConfigBytes;
begin
  Check(AComponent.Factory.SaveOpaqueComponentState(AComponent) = rosSuccess, 'Save complete fixture prefix');
  lBytes := AComponent.ConfigBlob;
  Check(Length(lBytes) >= SizeOf(Result), 'Complete fixture prefix absent');
  Move(lBytes[0], Result, SizeOf(Result));
end;
procedure SeedModel(AComponent: TRecorderPluginVisualComponent; out APrefix: TProbeModelPrefix);
var lBytes: TRecorderPluginConfigBytes;
begin
  APrefix := ModelPrefix(AComponent);
  APrefix.Value := 123456789;
  APrefix.Reserved := 777;
  APrefix.ObservedLatestValue := -9.75;
  APrefix.ObservedTagInfo.Description[0] := 'X';
  APrefix.ConfiguredContext.ComponentNo := 999;
  lBytes := AComponent.ConfigBlob;
  Move(APrefix, lBytes[0], SizeOf(APrefix));
  AComponent.ConfigBlob := lBytes;
  Check(AComponent.Factory.LoadOpaqueComponentState(AComponent) = rosSuccess, 'Seed full model state');
end;
procedure CheckModel(AComponent: TRecorderPluginVisualComponent; const AExpected: TProbeModelPrefix);
var lActual: TProbeModelPrefix;
begin
  lActual := ModelPrefix(AComponent);
  Check(CompareByte(lActual,AExpected,SizeOf(lActual)) = 0, 'Complete plugin model prefix must survive');
end;
procedure SetValue(AComponent: TRecorderPluginVisualComponent; AValue: Int64);
var lBytes: TRecorderPluginConfigBytes;
begin
  Check(AComponent.Factory.SaveOpaqueComponentState(AComponent) = rosSuccess, 'Save fixture state');
  lBytes := AComponent.ConfigBlob;
  Check(Length(lBytes) >= 16, 'Fixture magic/value prefix absent');
  Move(AValue, lBytes[8], SizeOf(AValue));
  AComponent.ConfigBlob := lBytes;
  Check(AComponent.Factory.LoadOpaqueComponentState(AComponent) = rosSuccess, 'Load fixture value');
end;
function ReadValue(AComponent: TRecorderPluginVisualComponent): Int64;
var lBytes: TRecorderPluginConfigBytes;
begin
  Check(AComponent.Factory.SaveOpaqueComponentState(AComponent) = rosSuccess, 'Read fixture state');
  lBytes := AComponent.ConfigBlob;
  Check(Length(lBytes) >= 16, 'Read fixture prefix absent');
  Move(lBytes[8], Result, SizeOf(Result));
end;
procedure SelectFirst(ACanvas: TPanel);
var lPagePanel: TWinControl; lControl: TControl; I: Integer;
begin
  lPagePanel := nil;
  for I := 0 to ACanvas.ControlCount - 1 do
    if ACanvas.Controls[I] is TPanel then begin lPagePanel := TWinControl(ACanvas.Controls[I]); Break; end;
  Check(lPagePanel <> nil, 'Real editor page panel absent');
  for I := 0 to lPagePanel.ControlCount - 1 do
  begin
    lControl := lPagePanel.Controls[I];
    if (lControl is TPanel) and (lControl.Tag = 0) and
      (lControl.Hint <> 'Resize selection') and Assigned(TControlAccess(lControl).OnMouseDown) then
    begin
      TControlAccess(lControl).OnMouseDown(lControl, mbLeft, [], 5, 5);
      if Assigned(TControlAccess(lControl).OnMouseUp) then
        TControlAccess(lControl).OnMouseUp(lControl, mbLeft, [], 5, 5);
      Exit;
    end;
  end;
  raise Exception.Create('Real selectable component host absent');
end;
procedure Run(const ADll: string);
var lFactories: TRecorderComponentFactory; lTags: TRecorderTagRegistry;
  lRuntime: TRecorderPluginRuntime; lProvider: TPageProvider; lForm: TForm;
  lCanvas: TPanel; lEditor: TFormEditorController; lIni: TMemIniFile;
  lConfig, lPluginPath: string; lSource, lDestination: TFileStream;
  lComponent, lCopy: TRecorderPluginVisualComponent; lKey: Word;
  lTag: TRecorderTag; lSettings: TRecorderTagEstimateSettings; lKind: TRecorderTagEstimateKind;
  lExpected: TProbeModelPrefix;
begin
  Check(ForceDirectories(ExtractFilePath(ParamStr(0)) + 'plugins'), 'Create isolated plugins directory');
  lPluginPath := ExtractFilePath(ParamStr(0)) + 'plugins' + DirectorySeparator + ExtractFileName(ADll);
  lSource := TFileStream.Create(ADll, fmOpenRead or fmShareDenyNone);
  try
    lDestination := TFileStream.Create(lPluginPath, fmCreate);
    try lDestination.CopyFrom(lSource, 0); finally lDestination.Free; end;
  finally lSource.Free; end;
  lConfig := ExtractFilePath(ParamStr(0)) + 'editor-state-smoke.ini';
  lIni := TMemIniFile.Create(lConfig);
  try
    lIni.WriteInteger('Plugins', 'Count', 1);
    lIni.WriteString('Plugin0', 'FileName', ExtractFileName(ADll));
    lIni.UpdateFile;
  finally lIni.Free; end;
  lFactories := TRecorderComponentFactory.Create;
  lTags := TRecorderTagRegistry.Create(nil);
  lTag := lTags.CreateTag('Wave',16,True);
  lTags.SelectedTagName := lTag.Name;
  lSettings := lTag.EstimateSettings;
  for lKind := Low(lKind) to High(lKind) do lSettings.EnabledKinds[lKind] := False;
  lSettings.EnabledKinds[tekMean] := True; lSettings.EnabledKinds[tekRmsValue] := True;
  lSettings.DefaultKind := tekMean; lSettings.PortionLength := 4;
  lSettings.SmoothingEnabled := False; lTag.EstimateSettings := lSettings;
  lTag.AddSamples([1.0,2.0,3.0,4.0],[10.0,20.0,30.0,40.0],4);
  lTags.CreateTag('Empty',16,False);
  lRuntime := TRecorderPluginRuntime.Create(lFactories,lTags);
  lProvider := TPageProvider.Create;
  lProvider.Page := TRecorderFormPage.Create('editor','Editor','');
  lForm := TForm.CreateNew(nil);
  lCanvas := TPanel.Create(lForm);
  lCanvas.Parent := lForm; lCanvas.Align := alClient;
  lForm.SetBounds(0,0,600,400);
  lEditor := nil;
  try
    lRuntime.LoadConfigured(lConfig);
    Check(lRuntime.LoadedCount = 1,'Stateful DLL must load');
    lComponent := TRecorderPluginVisualComponent(lFactories.CreateComponent('test.stateful-visual'));
    lComponent.Id := 'original'; lComponent.Name := 'Original';
    lComponent.TagName := 'Wave'; lComponent.SetBounds(20,30,120,80);
    SeedModel(lComponent,lExpected);
    lProvider.Page.AddComponent(lComponent);
    lEditor := TFormEditorController.Create(lCanvas,@lProvider.GetPage,lFactories);
    lEditor.SetDataContext(lTags,nil,1);
    lEditor.Enabled := True;
    SelectFirst(lCanvas);
    lEditor.DeleteSelected;
    Check(lProvider.Page.ComponentCount = 0,'Real DeleteSelected must delete');
    lEditor.UndoLastStep;
    Check(lProvider.Page.ComponentCount = 1,'Real UndoLastStep must recreate');
    lComponent := TRecorderPluginVisualComponent(lProvider.Page.Components[0]);
    CheckModel(lComponent,lExpected);
    Check((ReadValue(lComponent) = 123456789) and (lComponent.Id = 'original') and
      (lComponent.Name = 'Original') and (lComponent.Bounds.Left = 20), 'Undo preserves opaque/envelope state');
    SelectFirst(lCanvas);
    lKey := VK_C; lEditor.HandleKeyDown(lKey,[ssCtrl]);
    Check(lKey = 0,'Actual Ctrl+C consumed');
    SetValue(lComponent,987654321);
    lKey := VK_V; lEditor.HandleKeyDown(lKey,[ssCtrl]);
    Check((lKey = 0) and (lProvider.Page.ComponentCount = 2),'Actual Ctrl+V creates component');
    lCopy := TRecorderPluginVisualComponent(lProvider.Page.Components[1]);
    CheckModel(lCopy,lExpected);
    Check((ReadValue(lCopy) = 123456789) and (ReadValue(lComponent) = 987654321),
      'Clipboard snapshot independent of later source mutation');
    Check((lCopy.Id <> lComponent.Id) and (lCopy.Factory = lComponent.Factory), 'Paste unique ID canonical factory');
    SetValue(lCopy,-77);
    Check(ReadValue(lComponent) = 987654321,'Pasted live state independent');
    lEditor.UndoLastStep;
    Check(lProvider.Page.ComponentCount = 1,'Undo paste restores original count');
    Check(ReadValue(TRecorderPluginVisualComponent(lProvider.Page.Components[0])) = 987654321,
      'Undo paste preserves pre-paste source state');
    lComponent := TRecorderPluginVisualComponent.Create;
    lComponent.PluginTypeId := 'missing.oscillogram';
    lComponent.Name := 'Missing plugin';
    lComponent.SetBounds(160,30,120,80);
    lProvider.Page.AddComponent(lComponent);
    lEditor.Enabled := False;
    lEditor.Enabled := True;
    Check(lComponent.Factory = nil, 'Missing plugin remains an unbound placeholder');
    WriteLn('RESULT PluginEditorStateSmoke real delete/undo/ctrl-copy-paste independence passed');
  finally
    lEditor.Free; lForm.Free; lProvider.Page.Free; lProvider.Free;
    lRuntime.Free; lFactories.Free; lTags.Free; SysUtils.DeleteFile(lConfig);
  end;
end;
begin
  try
    Application.Initialize; Application.ShowMainForm := False;
    Check(ParamCount = 1,'Pass stateful fixture DLL path');
    Run(ParamStr(1));
  except on E:Exception do begin WriteLn('RESULT PluginEditorStateSmoke failed: ',E.Message); Halt(1); end; end;
end.
