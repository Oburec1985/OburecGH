unit uRecorderFrfRouteDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Немодальный редактор маршрута FRF. Здесь настраиваются точки, связи каналов
  и порядок шагов; сбор данных и навигацией управляет компонент FRF. }

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, Grids, Dialogs, LCLType,
  uRecorderImpactHammerModel, uRecorderImpactHammerContracts, uRecorderFrfRoute,
  uRecorderTags;

type
  TRecorderFrfRouteDialog = class(TForm)
    btnAdd, btnDelete, btnFolder, btnLoad, btnSave, btnApply, btnAssemble: TButton;
    cbChannel, cbObject, cbScene: TComboBox;
    rgVertexLabels: TRadioGroup;
    lblSelectedVertex: TLabel;
    btnAddBinding, btnDeleteBinding: TButton;
    btnCopyStep: TButton;
    gridBindings: TStringGrid;
    splitSteps: TSplitter;
    pnlBindings: TPanel;
    pnlPointTag: TPanel;
    lblPointTag: TLabel;
    edPointTag: TEdit;
    btnPointTag, btnClearPointTag: TButton;
    chkMdb, chkRouteAuto, chkPointTagSync, chkAutoOverwrite: TCheckBox;
    cbAtPointTag, cbNextStepTag, cbPointTag: TComboBox;
    edNextStepPulse: TEdit;
    lblAtPointTag, lblNextStepTag, lblNextStepPulse: TLabel;
    edSearch, edPointLabel, edFolder: TEdit;
    gridRoute: TStringGrid;
    lblState, lblObject, lblPoint, lblPointLabel, lblScene: TLabel;
    procedure AutomationChange(Sender: TObject);
    procedure AutomationSearchChange(Sender: TObject);
    procedure AutomationTagSelect(Sender: TObject);
    procedure AutomationTagDropDown(Sender: TObject);
    procedure AutomationTagKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PulseEditingDone(Sender: TObject);
    procedure PointTagClick(Sender: TObject);
    procedure ClearPointTagClick(Sender: TObject);
    procedure SceneChange(Sender:TObject);
    procedure SceneDropDown(Sender:TObject);
    procedure ObjectDropDown(Sender:TObject);
    procedure LabelSet(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure AddClick(Sender: TObject);
    procedure CopyStepClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure FolderClick(Sender: TObject);
    procedure LoadClick(Sender: TObject);
    procedure SearchChange(Sender: TObject);
    procedure MdbChange(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure RouteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RouteDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure RouteDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure AssembleClick(Sender: TObject);
    procedure AddBindingClick(Sender: TObject);
    procedure DeleteBindingClick(Sender: TObject);
    procedure ObjectChange(Sender: TObject);
    procedure InputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure VertexLabelsChange(Sender: TObject);
    procedure BindingSelect(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure BindingValidate(Sender: TObject; ACol, ARow: Integer;
      const OldValue: string; var NewValue: string);
  private
    fSelectedPoint: Integer;
    fSelectedLabel: string;
    fModel: TRecorderImpactHammerComponent;
    fRegistry: TRecorderTagRegistry;
    fAutomationTags: array of record
      Tag: TRecorderTag;
      SearchText: string;
    end;
    fRoute: TRecorderFrfRoute;
    fObjectIds: array of QWord;
    fStart, fCapture, fAssemble: TNotifyEvent;
    fRefreshing: Boolean;
    fDragRow: Integer;
    fMdbUpdateQueued: Boolean;
    procedure MdbContextChanged(Sender: TObject);
    procedure ApplyMdbContextChange(Data: PtrInt);
    procedure LoadSelectedEntry(ARow: Integer);
    procedure LoadObjects;
    procedure LoadScenes;
    procedure RefreshRoute;
    procedure RunCommand(ACommand: TNotifyEvent);
    function UpdateMdbDirectory: Boolean;
    procedure LoadPoints;
    procedure RefreshBindings(AStep: Integer);
    function BindingLabel(const ABinding: TRecorderFrfRouteBinding): string;
    procedure SceneSelection(const ASelection: TRecorderModelPointSelection);
    procedure RefreshPointTag;
    procedure RefreshAutomation;
    procedure PrepareAutomationTags;
    procedure FillAutomationTags(ACombo: TComboBox; const AFilter: string;
      ACommand: Boolean; ASelectedId: TRecorderTagId);
  public
    procedure UpdateAutomationState(AAutoMode, ATagSync: Boolean);
    procedure RefreshStorage;
    destructor Destroy; override;
    class function ShowRoute(AOwner: TComponent;
      AModel: TRecorderImpactHammerComponent; ARoute: TRecorderFrfRoute;
      AStart, ACapture, AAssemble: TNotifyEvent;
      ARegistry: TRecorderTagRegistry = nil): TRecorderFrfRouteDialog;
  end;

implementation

uses LazUTF8, uRecorderMdbManager, uRecorderMeraBaseModel, uRecorderTagPickerDialog;

{$R *.lfm}

procedure TRecorderFrfRouteDialog.UpdateAutomationState(AAutoMode, ATagSync: Boolean);
begin
  fRefreshing := True;
  try
    chkRouteAuto.Checked := AAutoMode;
    chkPointTagSync.Checked := ATagSync;
  finally fRefreshing := False end;
end;

procedure TRecorderFrfRouteDialog.FillAutomationTags(ACombo: TComboBox;
  const AFilter: string; ACommand: Boolean; ASelectedId: TRecorderTagId);
var I: Integer; lTag: TRecorderTag; Filter: string;
begin
  Filter := UTF8LowerCase(Trim(AFilter));
  ACombo.Items.BeginUpdate;
  try
    ACombo.Clear;
    ACombo.Items.AddObject('Не выбран', nil);
    if fRegistry <> nil then
      for I := 0 to High(fAutomationTags) do
      begin
        lTag := fAutomationTags[I].Tag;
        if ACommand and not lTag.ExternalWriteAllowed then Continue;
        if (Filter <> '') and (Pos(Filter, fAutomationTags[I].SearchText) = 0) then Continue;
        ACombo.Items.AddObject(lTag.Name, lTag);
        if lTag.Id = ASelectedId then ACombo.ItemIndex := ACombo.Items.Count - 1;
      end;
    if ASelectedId = 0 then ACombo.ItemIndex := 0;
  finally
    ACombo.Items.EndUpdate;
  end;
end;

procedure TRecorderFrfRouteDialog.PrepareAutomationTags;
var I: Integer; lTag: TRecorderTag;
begin
  if fRegistry = nil then Exit;
  SetLength(fAutomationTags, fRegistry.TagCount);
  for I := 0 to High(fAutomationTags) do
  begin
    lTag := fRegistry.Tags[I];
    fAutomationTags[I].Tag := lTag;
    fAutomationTags[I].SearchText := UTF8LowerCase(lTag.Name + ' ' +
      lTag.Address + ' ' + lTag.Description);
  end;
end;

procedure TRecorderFrfRouteDialog.RefreshAutomation;
begin
  if fModel = nil then Exit;
  fRefreshing := True;
  try
    chkRouteAuto.Checked := fModel.RouteAutoEnabled;
    chkPointTagSync.Checked := fModel.RouteTagSyncEnabled;
    chkAutoOverwrite.Checked := fModel.RouteAutoOverwrite;
    edNextStepPulse.Text := IntToStr(fModel.RouteNextStepPulseMs);
    FillAutomationTags(cbAtPointTag, '', False, fModel.RouteAtPointTagId);
    FillAutomationTags(cbNextStepTag, '', True, fModel.RouteNextStepTagId);
    FillAutomationTags(cbPointTag, '', False, fModel.RoutePointTagId);
  finally fRefreshing := False end;
end;

procedure TRecorderFrfRouteDialog.AutomationChange(Sender: TObject);
begin
  if fRefreshing or (fModel = nil) then Exit;
  fModel.RouteAutoEnabled := chkRouteAuto.Checked;
  fModel.RouteTagSyncEnabled := chkPointTagSync.Checked;
  fModel.RouteAutoOverwrite := chkAutoOverwrite.Checked;
  if Assigned(fStart) then fStart(Self);
end;

procedure TRecorderFrfRouteDialog.AutomationSearchChange(Sender: TObject);
var
  Combo: TComboBox;
  Search: string;
  Caret, SelectionLength: Integer;
begin
  if fRefreshing or (fModel = nil) then Exit;
  Combo := TComboBox(Sender);
  // Значение фиксирует OnSelect, а уведомление о редактировании оставляет ввод поиском.
  if (Combo.ItemIndex >= 0) and
    (Combo.Text = Combo.Items[Combo.ItemIndex]) then Exit;
  Search := Combo.Text;
  Caret := Combo.SelStart;
  SelectionLength := Combo.SelLength;
  fRefreshing := True;
  try
    FillAutomationTags(Combo, Search, Combo = cbNextStepTag, 0);
    Combo.ItemIndex := -1;
    Combo.Text := Search;
    if Combo.Focused and Combo.HandleAllocated then Combo.DroppedDown := True;
    Combo.SelStart := Caret;
    Combo.SelLength := SelectionLength;
  finally fRefreshing := False end;
end;

procedure TRecorderFrfRouteDialog.AutomationTagKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var Combo: TComboBox; I: Integer; SelectedId: TRecorderTagId;
begin
  if fRefreshing or (fModel = nil) then Exit;
  Combo := TComboBox(Sender);
  if Key = VK_ESCAPE then
  begin
    SelectedId := fModel.RoutePointTagId;
    if Combo = cbAtPointTag then SelectedId := fModel.RouteAtPointTagId
    else if Combo = cbNextStepTag then SelectedId := fModel.RouteNextStepTagId;
    fRefreshing := True;
    try
      Combo.DroppedDown := False;
      FillAutomationTags(Combo, '', Combo = cbNextStepTag, SelectedId);
    finally fRefreshing := False end;
    Key := 0;
  end
  else if Key = VK_RETURN then
  begin
    // Enter принимает подсказку; произвольный текст без совпадения ничего не меняет.
    if Combo.ItemIndex < 0 then
      for I := 1 to Combo.Items.Count - 1 do
        if (Combo.Items.Count = 2) or SameText(Combo.Text, Combo.Items[I]) then
        begin Combo.ItemIndex := I; Break end;
    AutomationTagSelect(Combo);
    Combo.DroppedDown := False;
    Key := 0;
  end;
end;

procedure TRecorderFrfRouteDialog.AutomationTagSelect(Sender: TObject);
var Combo: TComboBox; lTag: TRecorderTag;
begin
  if fRefreshing or (fModel = nil) then Exit;
  Combo := TComboBox(Sender);
  if Combo.ItemIndex < 0 then Exit;
  lTag := TRecorderTag(Combo.Items.Objects[Combo.ItemIndex]);
  if Combo = cbPointTag then
  begin
    fModel.RoutePointTagId := 0; fModel.RoutePointTagName := '';
    if lTag <> nil then begin fModel.RoutePointTagId := lTag.Id; fModel.RoutePointTagName := lTag.Name end;
    RefreshPointTag;
  end
  else if Combo = cbAtPointTag then
  begin
    fModel.RouteAtPointTagId := 0; fModel.RouteAtPointTagName := '';
    if lTag <> nil then begin fModel.RouteAtPointTagId := lTag.Id; fModel.RouteAtPointTagName := lTag.Name end;
  end
  else
  begin
    fModel.RouteNextStepTagId := 0; fModel.RouteNextStepTagName := '';
    if lTag <> nil then begin fModel.RouteNextStepTagId := lTag.Id; fModel.RouteNextStepTagName := lTag.Name end;
  end;
  if Assigned(fStart) then fStart(Self);
end;

procedure TRecorderFrfRouteDialog.AutomationTagDropDown(Sender: TObject);
var Combo: TComboBox; SelectedId: TRecorderTagId;
begin
  if fRefreshing or (fModel = nil) then Exit;
  Combo := TComboBox(Sender);
  if Combo.ItemIndex < 0 then Exit;
  SelectedId := fModel.RoutePointTagId;
  if Combo = cbAtPointTag then SelectedId := fModel.RouteAtPointTagId
  else if Combo = cbNextStepTag then SelectedId := fModel.RouteNextStepTagId;
  fRefreshing := True;
  try FillAutomationTags(Combo, '', Combo = cbNextStepTag, SelectedId);
  finally fRefreshing := False end;
end;

procedure TRecorderFrfRouteDialog.PulseEditingDone(Sender: TObject);
var Duration: Integer;
begin
  if fRefreshing or (fModel = nil) then Exit;
  Duration := StrToIntDef(edNextStepPulse.Text, fModel.RouteNextStepPulseMs);
  Duration := EnsureRange(Duration, 1, 60000);
  edNextStepPulse.Text := IntToStr(Duration);
  fModel.RouteNextStepPulseMs := Duration;
  if Assigned(fStart) then fStart(Self);
end;

procedure TRecorderFrfRouteDialog.RefreshPointTag;
begin
  edPointTag.Text := fModel.RoutePointTagName;
  btnPointTag.Enabled := fRegistry <> nil;
  btnClearPointTag.Enabled := (fModel.RoutePointTagId <> 0) or
    (fModel.RoutePointTagName <> '');
end;

procedure TRecorderFrfRouteDialog.PointTagClick(Sender: TObject);
var lTag: TRecorderTag;
begin
  if not ShowRecorderTagPickerDialog(Self, fRegistry,
    fModel.RoutePointTagName, False, lTag) then Exit;
  if (lTag.Id = fModel.RoutePointTagId) and
    (lTag.Name = fModel.RoutePointTagName) then Exit;
  fModel.RoutePointTagId := lTag.Id;
  fModel.RoutePointTagName := lTag.Name;
  RefreshPointTag;
  if Assigned(fStart) then fStart(Self);
end;

procedure TRecorderFrfRouteDialog.ClearPointTagClick(Sender: TObject);
begin
  fModel.RoutePointTagId := 0;
  fModel.RoutePointTagName := '';
  RefreshPointTag;
  if Assigned(fStart) then fStart(Self);
end;

destructor TRecorderFrfRouteDialog.Destroy;
begin
  UnsubscribeRecorderMdbContextChanged(@MdbContextChanged);
  Application.RemoveAsyncCalls(Self);
  UnsubscribeRecorderModelPointSelection(@SceneSelection);
  inherited Destroy;
end;

procedure TRecorderFrfRouteDialog.SceneSelection(const ASelection: TRecorderModelPointSelection);
var I: Integer; Catalog: IRecorderModelPointCatalog; Sink: IRecorderModelPointBindingSink;
  Labels: IRecorderModelLabeledPointCatalog; Info: TRecorderModelPointInfo;
begin
  if not Visible then Exit;
  I := cbScene.Items.IndexOf(ASelection.SceneComponentId);
  if I < 0 then Exit;
  cbScene.ItemIndex := I;
  SceneChange(nil);
  for I := 0 to High(fObjectIds) do
    if fObjectIds[I] = ASelection.NodeId then cbObject.ItemIndex := I;
  LoadPoints;
  if FindRecorderModelPointTarget(cbScene.Text, Catalog, Sink) and
    Supports(Catalog, IRecorderModelLabeledPointCatalog, Labels) then
    for I := 0 to Labels.PointCount(ASelection.NodeId) - 1 do
      if Labels.PointInfo(ASelection.NodeId, I, Info) and
        (Info.PointNumber = ASelection.PointNumber) then
      begin
        fSelectedPoint := Info.PointNumber;
        fSelectedLabel := Info.LabelText;
        lblSelectedVertex.Caption := 'Выбрана вершина: ' + fSelectedLabel;
        Break;
      end;
  RefreshBindings(gridRoute.Row - 1);
end;

procedure TRecorderFrfRouteDialog.ObjectChange(Sender: TObject);
begin LoadPoints end;

procedure TRecorderFrfRouteDialog.InputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  if Sender = edPointLabel then ApplyClick(Sender) else AddBindingClick(Sender);
  Key := 0;
end;

procedure TRecorderFrfRouteDialog.LoadPoints;
begin
  fSelectedPoint := 0;
  fSelectedLabel := '';
  lblSelectedVertex.Caption := 'Выберите вершину на сцене';
end;

procedure TRecorderFrfRouteDialog.VertexLabelsChange(Sender: TObject);
var Catalog: IRecorderModelPointCatalog; Sink: IRecorderModelPointBindingSink;
  Mode: IRecorderModelVertexLabelMode;
begin
  if fRefreshing or (fModel = nil) then Exit;
  fModel.OnlySensors := rgVertexLabels.ItemIndex = 1;
  if FindRecorderModelPointTarget(cbScene.Text, Catalog, Sink) and
    Supports(Sink, IRecorderModelVertexLabelMode, Mode) then
    Mode.SetVertexLabelMode(fModel.OnlySensors);
  if Assigned(fStart) then fStart(Self);
end;

procedure TRecorderFrfRouteDialog.BindingSelect(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
var Catalog: IRecorderModelPointCatalog; Sink: IRecorderModelPointBindingSink;
  Labels: IRecorderModelLabeledPointCatalog; Info: TRecorderModelPointInfo;
  Entry: TRecorderFrfRouteEntry; Binding: TRecorderFrfRouteBinding; I: Integer; Scene: string;
begin
  gridBindings.Columns[2].PickList.Clear;
  if (ARow < 1) or (gridRoute.Row < 1) or (gridRoute.Row > fRoute.Count) then Exit;
  Entry := fRoute[gridRoute.Row - 1];
  if ARow > Length(Entry.Bindings) then Exit;
  Binding := Entry.Bindings[ARow - 1];
  Scene := Binding.SceneComponentId;
  if Scene = '' then Scene := fModel.Target3dComponentId;
  if not FindRecorderModelPointTarget(Scene, Catalog, Sink) or
    not Supports(Catalog, IRecorderModelLabeledPointCatalog, Labels) then Exit;
  for I := 0 to Labels.PointCount(Binding.TargetNodeId) - 1 do
    if Labels.PointInfo(Binding.TargetNodeId, I, Info) and (Info.LabelText <> '') then
      gridBindings.Columns[2].PickList.Add(Info.LabelText);
end;

procedure TRecorderFrfRouteDialog.BindingValidate(Sender: TObject;
  ACol, ARow: Integer; const OldValue: string; var NewValue: string);
var Catalog: IRecorderModelPointCatalog; Sink: IRecorderModelPointBindingSink;
  Labels: IRecorderModelLabeledPointCatalog; Info: TRecorderModelPointInfo;
  Entry: TRecorderFrfRouteEntry; I: Integer; Scene: string;
begin
  if fRefreshing or (ACol <> 2) or (ARow < 1) or
    (gridRoute.Row < 1) or (gridRoute.Row > fRoute.Count) then Exit;
  Entry := fRoute[gridRoute.Row - 1];
  if ARow > Length(Entry.Bindings) then begin NewValue := OldValue; Exit end;
  Scene := Entry.Bindings[ARow - 1].SceneComponentId;
  if Scene = '' then Scene := fModel.Target3dComponentId;
  if FindRecorderModelPointTarget(Scene, Catalog, Sink) and
    Supports(Catalog, IRecorderModelLabeledPointCatalog, Labels) then
    for I := 0 to Labels.PointCount(Entry.Bindings[ARow - 1].TargetNodeId) - 1 do
      if Labels.PointInfo(Entry.Bindings[ARow - 1].TargetNodeId, I, Info) and
        (Info.LabelText = Trim(NewValue)) and (Info.LabelText <> '') then
      begin
        NewValue := Info.LabelText;
        Entry.Bindings[ARow - 1].PointNumber := Info.PointNumber;
        Entry.Bindings[ARow - 1].PointLabel := Info.LabelText;
        fRoute.UpdateEntry(gridRoute.Row - 1, Entry);
        if Assigned(fStart) then fStart(Self);
        Exit;
      end;
  NewValue := OldValue;
  lblState.Caption := 'У объекта нет вершины с такой подписью. Выберите точку из списка.';
end;

procedure TRecorderFrfRouteDialog.AddBindingClick(Sender: TObject);
var lBinding: TRecorderFrfRouteBinding;
begin
  if (fSelectedPoint < 1) or (cbObject.ItemIndex < 0) or (cbChannel.ItemIndex < 0) then
  begin MessageDlg('Выберите канал, объект и подписанную вершину.', mtInformation, [mbOK], 0); Exit end;
  if fRoute.Count = 0 then AddClick(nil);
  lBinding := Default(TRecorderFrfRouteBinding);
  lBinding.ChannelIndex := PtrInt(cbChannel.Items.Objects[cbChannel.ItemIndex]);
  lBinding.PointNumber := fSelectedPoint;
  lBinding.PointLabel := fSelectedLabel;
  lBinding.TargetNodeId := fObjectIds[cbObject.ItemIndex];
  lBinding.TargetNodeName := cbObject.Text;
  lBinding.SceneComponentId := cbScene.Text;
  fRoute.AddBinding(gridRoute.Row - 1, lBinding);
  RefreshBindings(gridRoute.Row - 1);
  if Assigned(fStart) then fStart(Self);
end;

procedure TRecorderFrfRouteDialog.DeleteBindingClick(Sender: TObject);
begin
  if (gridRoute.Row < 1) or (gridRoute.Row > fRoute.Count) then Exit;
  fRoute.DeleteBinding(gridRoute.Row - 1, gridBindings.Row - 1);
  RefreshBindings(gridRoute.Row - 1);
  if Assigned(fStart) then fStart(Self);
end;

function TRecorderFrfRouteDialog.BindingLabel(const ABinding: TRecorderFrfRouteBinding): string;
var lCatalog: IRecorderModelPointCatalog; lLabels: IRecorderModelLabeledPointCatalog;
  lSink: IRecorderModelPointBindingSink; lInfo: TRecorderModelPointInfo;
  lScene: string; I: Integer;
begin
  Result := '';
  lScene := ABinding.SceneComponentId;
  if lScene = '' then lScene := fModel.Target3dComponentId;
  if not FindRecorderModelPointTarget(lScene, lCatalog, lSink) or
    not Supports(lCatalog, IRecorderModelLabeledPointCatalog, lLabels) then Exit;
  for I := 0 to lLabels.PointCount(ABinding.TargetNodeId) - 1 do
    if lLabels.PointInfo(ABinding.TargetNodeId, I, lInfo) and
      (lInfo.PointNumber = ABinding.PointNumber) then Exit(lInfo.LabelText);
end;

procedure TRecorderFrfRouteDialog.RefreshBindings(AStep: Integer);
var I: Integer; lEntry: TRecorderFrfRouteEntry; lBinding: TRecorderFrfRouteBinding;
begin
  lEntry := Default(TRecorderFrfRouteEntry);
  if (AStep >= 0) and (AStep < fRoute.Count) then lEntry := fRoute[AStep];
  gridBindings.RowCount := Length(lEntry.Bindings) + 1;
  if gridBindings.RowCount < 2 then gridBindings.RowCount := 2;
  gridBindings.Cells[0, 0] := 'Канал FRF'; gridBindings.Cells[1, 0] := 'Объект';
  gridBindings.Cells[2, 0] := 'Точка'; gridBindings.Cells[3, 0] := 'Сцена';
  for I := 1 to gridBindings.RowCount - 1 do gridBindings.Rows[I].Clear;
  for I := 0 to High(lEntry.Bindings) do
  begin
    lBinding := lEntry.Bindings[I];
    if (lBinding.ChannelIndex >= 0) and (lBinding.ChannelIndex < fModel.ResponseCount) then
      gridBindings.Cells[0, I + 1] := fModel.Responses[lBinding.ChannelIndex].TagName;
    gridBindings.Cells[1, I + 1] := lBinding.TargetNodeName;
    gridBindings.Cells[2, I + 1] := BindingLabel(lBinding);
    gridBindings.Cells[3, I + 1] := lBinding.SceneComponentId;
  end;
  btnDeleteBinding.Enabled := Length(lEntry.Bindings) > 0;
end;

procedure TRecorderFrfRouteDialog.MdbContextChanged(Sender: TObject);
begin
  if not chkMdb.Checked or fMdbUpdateQueued then Exit;
  fMdbUpdateQueued := True;
  Application.QueueAsyncCall(@ApplyMdbContextChange, 0);
end;

procedure TRecorderFrfRouteDialog.ApplyMdbContextChange(Data: PtrInt);
begin
  fMdbUpdateQueued := False;
  if not chkMdb.Checked then Exit;
  UpdateMdbDirectory;
  if Assigned(fStart) then fStart(Self);
end;

function TRecorderFrfRouteDialog.UpdateMdbDirectory: Boolean;
var
  ActiveDirectory: string;
begin
  Result := False;
  ActiveDirectory := RecorderMeraObjectDirectory;
  if ActiveDirectory = '' then
    ActiveDirectory := RecorderMdbActiveObjectDirectory;
  if (ActiveDirectory <> '') and (fModel <> nil) then
  begin
    edFolder.Text := IncludeTrailingPathDelimiter(ActiveDirectory) + 'frf';
    if fModel.ScenarioEnabled then
      edFolder.Text := IncludeTrailingPathDelimiter(edFolder.Text) + 'track';
    if fRoute<>nil then
      if fRoute.SetDirectory(edFolder.Text) then RefreshRoute;
    Exit(True);
  end;
  edFolder.Clear;
  if fRoute <> nil then fRoute.SetDirectory('');
end;

procedure TRecorderFrfRouteDialog.RefreshStorage;
begin
  if fRoute=nil then Exit;
  edFolder.Text:=fRoute.Directory;
  RefreshRoute;
end;

procedure TRecorderFrfRouteDialog.MdbChange(Sender: TObject);
begin
  if fRefreshing then Exit;
  edFolder.ReadOnly := chkMdb.Checked;
  btnFolder.Enabled := not chkMdb.Checked;
  if not chkMdb.Checked then
  begin
    if fModel <> nil then
      fModel.ExportPath := ExtractFileDir(ExcludeTrailingPathDelimiter(edFolder.Text));
    if Assigned(fStart) then fStart(Self);
    Exit;
  end;
  fModel.ExportPath := '';
  try
    if not UpdateMdbDirectory then
    begin
      chkMdb.Checked := False;
      edFolder.ReadOnly := False;
      btnFolder.Enabled := True;
      MessageDlg('Не удалось получить каталог объекта БД. Выберите и примените объект в базе данных испытаний.', mtInformation, [mbOK], 0);
      Exit;
    end;
    if fRoute.HasManifest(edFolder.Text) then
      LoadClick(nil);
    if Assigned(fStart) then fStart(Self);
  except
    on E: Exception do
    begin
      chkMdb.Checked := False;
      edFolder.ReadOnly := False;
      btnFolder.Enabled := True;
      MessageDlg(E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

class function TRecorderFrfRouteDialog.ShowRoute(AOwner: TComponent;
  AModel: TRecorderImpactHammerComponent; ARoute: TRecorderFrfRoute;
  AStart, ACapture, AAssemble: TNotifyEvent;
  ARegistry: TRecorderTagRegistry): TRecorderFrfRouteDialog;
var lMdbDirectory: string;
begin
  Result := TRecorderFrfRouteDialog.Create(AOwner);
  Result.fModel := AModel;
  Result.fRegistry := ARegistry;
  Result.PrepareAutomationTags;
  Result.RefreshPointTag;
  Result.RefreshAutomation;
  Result.fRefreshing := True;
  Result.rgVertexLabels.ItemIndex := Ord(AModel.OnlySensors);
  Result.fRefreshing := False;
  Result.fRoute := ARoute;
  if AModel.RouteConfigFileName <> '' then
    ARoute.ConfigFileName := AModel.RouteConfigFileName;
  lMdbDirectory:=RecorderMeraObjectDirectory;
  if lMdbDirectory='' then lMdbDirectory:=RecorderMdbActiveObjectDirectory;
  if lMdbDirectory<>'' then
  begin
    lMdbDirectory:=IncludeTrailingPathDelimiter(lMdbDirectory)+'frf';
    if AModel.ScenarioEnabled then
      lMdbDirectory:=IncludeTrailingPathDelimiter(lMdbDirectory)+'track';
  end;
  Result.fRefreshing:=True;
  try
    Result.chkMdb.Checked:=(Trim(AModel.ExportPath)='') and (lMdbDirectory <> '');
    Result.edFolder.ReadOnly:=Result.chkMdb.Checked;
    Result.btnFolder.Enabled:=not Result.chkMdb.Checked;
  finally Result.fRefreshing:=False; end;
  Result.fStart := AStart;
  Result.fCapture := ACapture;
  Result.fAssemble := AAssemble;
  Result.edFolder.Text := ARoute.Directory;
  if Result.chkMdb.Checked then Result.UpdateMdbDirectory;
  Result.SearchChange(nil);
  Result.LoadScenes;
  Result.LoadObjects;
  Result.RefreshRoute;
  Result.LoadSelectedEntry(Result.gridRoute.Row);
  SubscribeRecorderModelPointSelection(@Result.SceneSelection);
  SubscribeRecorderMdbContextChanged(@Result.MdbContextChanged);
  Result.Show;
end;

procedure TRecorderFrfRouteDialog.SearchChange(Sender: TObject);
var
  I, lPrevious: Integer;
begin
  if fModel = nil then Exit;
  lPrevious := -1;
  if cbChannel.ItemIndex >= 0 then
    lPrevious := PtrInt(cbChannel.Items.Objects[cbChannel.ItemIndex]);
  cbChannel.Clear;
  for I := 0 to fModel.ResponseCount - 1 do
    if (Trim(edSearch.Text) = '') or
      (Pos(LowerCase(Trim(edSearch.Text)), LowerCase(fModel.Responses[I].TagName)) > 0) then
    begin
      cbChannel.Items.AddObject(fModel.Responses[I].TagName, TObject(PtrInt(I)));
      if I = lPrevious then cbChannel.ItemIndex := cbChannel.Items.Count - 1;
    end;
  if (cbChannel.ItemIndex < 0) and (cbChannel.Items.Count > 0) then
    cbChannel.ItemIndex := 0;
end;

procedure TRecorderFrfRouteDialog.LoadScenes;
var lPrevious:string;
begin
  lPrevious:=fModel.Target3dComponentId;
  GetRecorderModelPointTargetIds(cbScene.Items);
  cbScene.ItemIndex:=cbScene.Items.IndexOf(lPrevious);
  if (cbScene.ItemIndex<0) and (cbScene.Items.Count=1) then
    cbScene.ItemIndex:=0;
  if cbScene.ItemIndex>=0 then
    fModel.Target3dComponentId:=cbScene.Items[cbScene.ItemIndex];
end;

procedure TRecorderFrfRouteDialog.SceneChange(Sender:TObject);
begin
  if (fModel=nil) or (cbScene.ItemIndex<0) then Exit;
  fModel.Target3dComponentId:=cbScene.Items[cbScene.ItemIndex];
  LoadObjects;
end;

procedure TRecorderFrfRouteDialog.SceneDropDown(Sender:TObject);
begin
  LoadScenes;
  LoadObjects;
end;

procedure TRecorderFrfRouteDialog.ObjectDropDown(Sender:TObject);
begin
  LoadObjects;
end;

procedure TRecorderFrfRouteDialog.LoadObjects;
var
  Catalog: IRecorderModelPointCatalog;
  Sink: IRecorderModelPointBindingSink;
  Info: TRecorderModelObjectInfo;
  I: Integer;
  lPrevious:QWord;
begin
  lPrevious:=fModel.Target3dNodeId;
  if (cbObject.ItemIndex>=0) and (cbObject.ItemIndex<Length(fObjectIds)) then
    lPrevious:=fObjectIds[cbObject.ItemIndex];
  cbObject.Clear;
  SetLength(fObjectIds, 0);
  if not FindRecorderModelPointTarget(fModel.Target3dComponentId, Catalog, Sink) then Exit;
  for I := 0 to Catalog.ObjectCount - 1 do
    if Catalog.ObjectInfo(I, Info) then
    begin
      SetLength(fObjectIds, Length(fObjectIds) + 1);
      fObjectIds[High(fObjectIds)] := Info.NodeId;
      cbObject.Items.Add(Info.Name);
      if Info.NodeId = lPrevious then cbObject.ItemIndex := High(fObjectIds);
    end;
  if (cbObject.ItemIndex < 0) and (cbObject.Items.Count > 0) then cbObject.ItemIndex := 0;
  LoadPoints;
end;

procedure TRecorderFrfRouteDialog.AddClick(Sender: TObject);
var
  Entry: TRecorderFrfRouteEntry;
begin
  Entry := Default(TRecorderFrfRouteEntry);
  Entry.PointNumber := fRoute.Count + 1;
  Entry.PointLabel := IntToStr(fRoute.Count + 1);
  fRoute.Add(Entry);
  fRoute.CurrentIndex := fRoute.Count - 1;
  RefreshRoute;
  gridRoute.Row := fRoute.Count;
  LoadSelectedEntry(gridRoute.Row);
  if Assigned(fStart) then fStart(Self);
end;

procedure TRecorderFrfRouteDialog.CopyStepClick(Sender: TObject);
var Entry: TRecorderFrfRouteEntry;
begin
  if (gridRoute.Row < 1) or (gridRoute.Row > fRoute.Count) then Exit;
  Entry := fRoute[gridRoute.Row - 1];
  Entry.PointLabel := IntToStr(fRoute.Count + 1);
  Entry.PointNumber := fRoute.Count + 1;
  Entry.StorageFolder := '';
  Entry.Captured := False;
  // Новый шаг получает новый ID и копирует связи, но не сохранённые измерения.
  fRoute.Add(Entry);
  fRoute.CurrentIndex := fRoute.Count - 1;
  RefreshRoute;
  gridRoute.Row := fRoute.Count;
  LoadSelectedEntry(gridRoute.Row);
  if Assigned(fStart) then fStart(Self);
end;

procedure TRecorderFrfRouteDialog.SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if not fRefreshing and (ARow > 0) and (ARow <= fRoute.Count) then
  begin
    fRoute.CurrentIndex := ARow - 1;
    LoadSelectedEntry(ARow);
    if Assigned(fStart) then fStart(Self);
  end;
end;

procedure TRecorderFrfRouteDialog.LoadSelectedEntry(ARow: Integer);
var Entry: TRecorderFrfRouteEntry;
begin
  if (fRoute = nil) or (ARow < 1) or (ARow > fRoute.Count) then Exit;
  Entry := fRoute[ARow - 1];
  edPointLabel.Text := Entry.PointLabel;
  RefreshBindings(ARow - 1);
end;

procedure TRecorderFrfRouteDialog.ApplyClick(Sender: TObject);
var Row: Integer;
begin
  Row := gridRoute.Row;
  if (Row < 1) or (Row > fRoute.Count) then Exit;
  fRoute.SetPointLabel(Row - 1, edPointLabel.Text);
  RefreshRoute;
  gridRoute.Row := Row;
  LoadSelectedEntry(Row);
end;

procedure TRecorderFrfRouteDialog.RouteMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Col, Row: Integer;
begin
  if Button <> mbLeft then Exit;
  gridRoute.MouseToCell(X, Y, Col, Row);
  if (Row < 1) or (Row > fRoute.Count) then Exit;
  fDragRow := Row;
  gridRoute.BeginDrag(False);
end;

procedure TRecorderFrfRouteDialog.RouteDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
var Col, Row: Integer;
begin
  gridRoute.MouseToCell(X, Y, Col, Row);
  Accept := (Source = gridRoute) and (Row > 0) and (Row <= fRoute.Count);
end;

procedure TRecorderFrfRouteDialog.RouteDragDrop(Sender, Source: TObject; X, Y: Integer);
var Col, Row: Integer;
begin
  if Source <> gridRoute then Exit;
  gridRoute.MouseToCell(X, Y, Col, Row);
  if (Row < 1) or (Row > fRoute.Count) then Exit;
  fRoute.MoveEntry(fDragRow - 1, Row - 1);
  RefreshRoute;
  gridRoute.Row := Row;
  LoadSelectedEntry(Row);
end;

procedure TRecorderFrfRouteDialog.LabelSet(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  if not fRefreshing and (fRoute <> nil) and (ACol = 4) and
    (ARow > 0) and (ARow <= fRoute.Count) then
    fRoute.SetPointLabel(ARow - 1, Value);
end;

procedure TRecorderFrfRouteDialog.DeleteClick(Sender: TObject);
begin
  if fRoute.Count <= 1 then Exit;
  if (gridRoute.Row > 0) and (gridRoute.Row <= fRoute.Count) then
    fRoute.Delete(gridRoute.Row - 1);
  if fRoute.CurrentIndex >= fRoute.Count then fRoute.CurrentIndex := fRoute.Count - 1;
  RefreshRoute;
  if Assigned(fStart) then fStart(Self);
end;

procedure TRecorderFrfRouteDialog.FolderClick(Sender: TObject);
var
  Directory: string;
begin
  Directory := edFolder.Text;
  if SelectDirectory('Папка сохранённых реализаций маршрута', '', Directory) then
  begin
    edFolder.Text := Directory;
    fRoute.SetDirectory(Directory);
    RefreshRoute;
  end;
end;

procedure TRecorderFrfRouteDialog.LoadClick(Sender: TObject);
begin
  try
    if chkMdb.Checked and not UpdateMdbDirectory then
    begin
      MdbChange(nil);
      Exit;
    end;
    fRoute.Load(edFolder.Text);
    RefreshRoute;
  except on E: Exception do MessageDlg(E.Message, mtError, [mbOK], 0); end;
end;

procedure TRecorderFrfRouteDialog.SaveClick(Sender: TObject);
begin
  try
    if chkMdb.Checked and not UpdateMdbDirectory then
    begin
      MdbChange(nil);
      Exit;
    end;
    if fRoute.Count = 0 then raise Exception.Create('Добавьте точки маршрута.');
    if Trim(edFolder.Text) = '' then raise Exception.Create('Выберите папку сохранения.');
    fRoute.Save(edFolder.Text);
  except on E: Exception do MessageDlg(E.Message, mtError, [mbOK], 0); end;
end;

procedure TRecorderFrfRouteDialog.AssembleClick(Sender: TObject);
begin
  RunCommand(fAssemble);
end;

procedure TRecorderFrfRouteDialog.RunCommand(ACommand: TNotifyEvent);
begin
  try
    if Assigned(ACommand) then ACommand(Self);
  except on E: Exception do MessageDlg(E.Message, mtError, [mbOK], 0); end;
  RefreshRoute;
end;

procedure TRecorderFrfRouteDialog.RefreshRoute;
var
  I, Channel: Integer;
begin
  fRefreshing := True;
  try
  gridRoute.RowCount := fRoute.Count + 1;
  if gridRoute.RowCount < 2 then gridRoute.RowCount := 2;
  gridRoute.Cells[0, 0] := '№';
  gridRoute.Cells[1, 0] := 'Шаг';
  gridRoute.Cells[2, 0] := 'Данные';
  gridRoute.Cells[3, 0] := 'Сохранено';
  for I := 1 to gridRoute.RowCount - 1 do gridRoute.Rows[I].Clear;
  for I := 0 to fRoute.Count - 1 do
  begin
    gridRoute.Cells[0, I + 1] := IntToStr(I + 1);
    Channel := fRoute.Entries[I].ChannelIndex;
    gridRoute.Cells[1, I + 1] := fRoute.Entries[I].PointLabel;
    gridRoute.Cells[2, I + 1] := 'Все датчики FRF / SPM';
    if fRoute.Entries[I].Captured then gridRoute.Cells[3, I + 1] := 'Да';
  end;
  { Сервис показывает сохранённые шаги, даже если маршрут ещё не завершён. }
  btnAssemble.Enabled := fRoute.Count > 0;
  btnCopyStep.Enabled := fRoute.Count > 0;
  btnAdd.Enabled := True;
  btnDelete.Enabled := fRoute.Count > 1;
  btnApply.Enabled := fRoute.Count > 0;
  lblState.Caption := 'Шаг сохраняет все каналы. Ниже настройте привязки каналов к подписанным вершинам.';
  if (fRoute.CurrentIndex >= 0) and (fRoute.CurrentIndex < fRoute.Count) then
  begin
    gridRoute.Row := fRoute.CurrentIndex + 1;
    lblState.Caption := 'Текущий шаг ' + IntToStr(fRoute.CurrentIndex + 1) +
      ' из ' + IntToStr(fRoute.Count) + '. ' + lblState.Caption;
  end;
  finally
    fRefreshing := False;
  end;
  RefreshBindings(gridRoute.Row - 1);
end;

end.
