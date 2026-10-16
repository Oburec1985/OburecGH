unit uRecorderFrfRouteDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Non-modal route configuration editor. Acquisition and navigation belong to
  the FRF widget; this form edits assignments and stable row ordering. }

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Grids, Dialogs,
  uRecorderImpactHammerModel, uRecorderImpactHammerContracts, uRecorderFrfRoute;

type
  TRecorderFrfRouteDialog = class(TForm)
    btnAdd, btnDelete, btnFolder, btnLoad, btnSave, btnApply, btnAssemble: TButton;
    cbChannel, cbObject, cbScene: TComboBox;
    chkMdb: TCheckBox;
    edSearch, edPoint, edPointLabel, edFolder: TEdit;
    gridRoute: TStringGrid;
    lblState, lblObject, lblPoint, lblPointLabel, lblScene: TLabel;
    procedure SceneChange(Sender:TObject);
    procedure SceneDropDown(Sender:TObject);
    procedure ObjectDropDown(Sender:TObject);
    procedure LabelSet(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure AddClick(Sender: TObject);
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
  private
    fModel: TRecorderImpactHammerComponent;
    fRoute: TRecorderFrfRoute;
    fObjectIds: array of QWord;
    fStart, fCapture, fAssemble: TNotifyEvent;
    fRefreshing: Boolean;
    fDragRow: Integer;
    procedure LoadSelectedEntry(ARow: Integer);
    function ReadEntry(out AEntry: TRecorderFrfRouteEntry): Boolean;
    procedure LoadObjects;
    procedure LoadScenes;
    procedure RefreshRoute;
    procedure RunCommand(ACommand: TNotifyEvent);
    function UpdateMdbDirectory: Boolean;
  public
    class function ShowRoute(AOwner: TComponent;
      AModel: TRecorderImpactHammerComponent; ARoute: TRecorderFrfRoute;
      AStart, ACapture, AAssemble: TNotifyEvent): TRecorderFrfRouteDialog;
  end;

implementation

uses uRecorderMdbManager, uRecorderMeraBaseModel;

{$R *.lfm}

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
    edFolder.Text := ActiveDirectory + 'frf';
    if fModel.ScenarioEnabled then
      edFolder.Text := IncludeTrailingPathDelimiter(edFolder.Text) + 'track';
    Exit(True);
  end;
end;

procedure TRecorderFrfRouteDialog.MdbChange(Sender: TObject);
begin
  edFolder.ReadOnly := chkMdb.Checked;
  btnFolder.Enabled := not chkMdb.Checked;
  if not chkMdb.Checked then Exit;
  try
    if not UpdateMdbDirectory then
    begin
      chkMdb.Checked := False;
      edFolder.ReadOnly := False;
      btnFolder.Enabled := True;
      MessageDlg('Не удалось получить каталог объекта БД. Выберите и примените объект в базе данных испытаний.', mtInformation, [mbOK], 0);
      Exit;
    end;
    if FileExists(IncludeTrailingPathDelimiter(edFolder.Text) + 'route.ini') then
      LoadClick(nil);
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
  AStart, ACapture, AAssemble: TNotifyEvent): TRecorderFrfRouteDialog;
begin
  Result := TRecorderFrfRouteDialog.Create(AOwner);
  Result.fModel := AModel;
  Result.fRoute := ARoute;
  Result.fStart := AStart;
  Result.fCapture := ACapture;
  Result.fAssemble := AAssemble;
  Result.edFolder.Text := ARoute.Directory;
  Result.SearchChange(nil);
  Result.LoadScenes;
  Result.LoadObjects;
  Result.RefreshRoute;
  Result.LoadSelectedEntry(Result.gridRoute.Row);
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
end;

procedure TRecorderFrfRouteDialog.AddClick(Sender: TObject);
var
  Entry: TRecorderFrfRouteEntry;
begin
  if not ReadEntry(Entry) then Exit;
  fRoute.Add(Entry);
  RefreshRoute;
  gridRoute.Row := fRoute.Count;
  LoadSelectedEntry(gridRoute.Row);
end;

function TRecorderFrfRouteDialog.ReadEntry(out AEntry: TRecorderFrfRouteEntry): Boolean;
var Point: Integer;
begin
  Result := False;
  if cbObject.ItemIndex < 0 then
  begin
    MessageDlg('Выберите объект геометрии.', mtInformation, [mbOK], 0);
    Exit;
  end;
  if not TryStrToInt(edPoint.Text, Point) or (Point < 1) then
  begin
    MessageDlg('Номер точки должен быть положительным целым числом.', mtError, [mbOK], 0);
    Exit;
  end;
  AEntry := Default(TRecorderFrfRouteEntry);
  AEntry.ChannelIndex := 0; // Legacy intensity association; acquisition saves all channels.
  AEntry.PointNumber := Point;
  AEntry.PointLabel := Trim(edPointLabel.Text);
  AEntry.TargetNodeId := fObjectIds[cbObject.ItemIndex];
  AEntry.TargetNodeName := cbObject.Text;
  Result := True;
end;

procedure TRecorderFrfRouteDialog.SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if not fRefreshing then LoadSelectedEntry(ARow);
end;

procedure TRecorderFrfRouteDialog.LoadSelectedEntry(ARow: Integer);
var Entry: TRecorderFrfRouteEntry; I: Integer;
begin
  if (fRoute = nil) or (ARow < 1) or (ARow > fRoute.Count) then Exit;
  Entry := fRoute[ARow - 1];
  edSearch.Text := '';
  for I := 0 to cbChannel.Items.Count - 1 do
    if PtrInt(cbChannel.Items.Objects[I]) = Entry.ChannelIndex then cbChannel.ItemIndex := I;
  for I := 0 to High(fObjectIds) do
    if fObjectIds[I] = Entry.TargetNodeId then cbObject.ItemIndex := I;
  edPoint.Text := IntToStr(Entry.PointNumber);
  edPointLabel.Text := Entry.PointLabel;
end;

procedure TRecorderFrfRouteDialog.ApplyClick(Sender: TObject);
var Entry: TRecorderFrfRouteEntry; Row: Integer;
begin
  Row := gridRoute.Row;
  if (Row < 1) or (Row > fRoute.Count) or not ReadEntry(Entry) then Exit;
  fRoute.UpdateEntry(Row - 1, Entry);
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
  if (gridRoute.Row > 0) and (gridRoute.Row <= fRoute.Count) then
    fRoute.Delete(gridRoute.Row - 1);
  RefreshRoute;
end;

procedure TRecorderFrfRouteDialog.FolderClick(Sender: TObject);
var
  Directory: string;
begin
  Directory := edFolder.Text;
  if SelectDirectory('Папка сохранённых реализаций маршрута', '', Directory) then
    edFolder.Text := Directory;
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
  gridRoute.Cells[1, 0] := 'Данные';
  gridRoute.Cells[2, 0] := 'Объект';
  gridRoute.Cells[3, 0] := 'Точка';
  gridRoute.Cells[4, 0] := 'Подпись точки';
  gridRoute.Cells[5, 0] := 'Сохранено';
  for I := 1 to gridRoute.RowCount - 1 do gridRoute.Rows[I].Clear;
  for I := 0 to fRoute.Count - 1 do
  begin
    gridRoute.Cells[0, I + 1] := IntToStr(I + 1);
    Channel := fRoute.Entries[I].ChannelIndex;
    gridRoute.Cells[1, I + 1] := 'Все датчики FRF / SPM';
    gridRoute.Cells[2, I + 1] := fRoute.Entries[I].TargetNodeName;
    gridRoute.Cells[3, I + 1] := IntToStr(fRoute.Entries[I].PointNumber);
    gridRoute.Cells[4, I + 1] := fRoute.Entries[I].PointLabel;
    if fRoute.Entries[I].Captured then gridRoute.Cells[5, I + 1] := 'Да';
  end;
  btnAssemble.Enabled := fRoute.AllComplete;
  btnAdd.Enabled := True;
  btnDelete.Enabled := fRoute.Count > 0;
  btnApply.Enabled := fRoute.Count > 0;
  lblState.Caption := 'Измените выбранную точку и нажмите «Применить». Перетащите строку для изменения порядка.';
  if (fRoute.CurrentIndex >= 0) and (fRoute.CurrentIndex < fRoute.Count) then
  begin
    gridRoute.Row := fRoute.CurrentIndex + 1;
    lblState.Caption := 'Текущая точка ' + IntToStr(fRoute.CurrentIndex + 1) +
      ' из ' + IntToStr(fRoute.Count) + '. ' + lblState.Caption;
  end;
  finally
    fRefreshing := False;
  end;
end;

end.
