unit uRecorderMdbDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ComCtrls, ExtCtrls, Dialogs,
  uRecorderMdbTypes, uRecorderMdbManager;

type
  { Operator dialog for selecting the product and test whose immutable IDs are
    attached to subsequent RecorderLnx measurements. SQL stays in the manager. }
  TRecorderMdbDialog = class(TForm)
    btnCancel: TButton;
    btnCreateObject: TButton;
    btnCreateTest: TButton;
    btnSelect: TButton;
    edObjectName: TEdit;
    edObjectSearch: TEdit;
    edObjectSerial: TEdit;
    edObjectType: TEdit;
    edTestName: TEdit;
    edTestSearch: TEdit;
    lblContext: TLabel;
    lblObjectName: TLabel;
    lblObjectSearch: TLabel;
    lblObjectSerial: TLabel;
    lblObjectType: TLabel;
    lblTestName: TLabel;
    lblTestSearch: TLabel;
    lvMeasurements: TListView;
    lbObjects: TListBox;
    lbTests: TListBox;
    ObjectPan: TPanel;
    TestPan: TPanel;
    ClientPan: TPanel;
    BottomPan: TPanel;
    SplitterLeft: TSplitter;
    SplitterRight: TSplitter;
    procedure btnCreateObjectClick(Sender: TObject);
    procedure btnCreateTestClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure edObjectSearchChange(Sender: TObject);
    procedure edTestSearchChange(Sender: TObject);
    procedure lbObjectsSelectionChange(Sender: TObject; User: Boolean);
    procedure lbTestsSelectionChange(Sender: TObject; User: Boolean);
  private
    fManager: TRecorderMdbManager;
    fObjects: TMdbObjectInfos;
    fTests: TMdbTestInfos;
    fPreferredObjectId: string;
    fPreferredTestId: string;
    fReloading: Boolean;
    function SelectedObjectIndex: Integer;
    function SelectedTestIndex: Integer;
    procedure SelectObjectById(const AId: string);
    procedure SelectTestById(const AId: string);
    procedure UpdateSelectionState;
    procedure ReloadObjects;
    procedure ReloadTests;
    procedure ReloadMeasurements;
  public
    function Execute(AManager: TRecorderMdbManager): Boolean;
  end;

implementation

{$R *.lfm}

uses
  DateUtils, LazUTF8;

function ContainsText(const AText, AFilter: string): Boolean;
begin
  Result := (Trim(AFilter) = '') or
    (Pos(UTF8LowerCase(Trim(AFilter)), UTF8LowerCase(AText)) > 0);
end;

function TRecorderMdbDialog.SelectedObjectIndex: Integer;
begin
  if lbObjects.ItemIndex < 0 then Exit(-1);
  Result := PtrInt(lbObjects.Items.Objects[lbObjects.ItemIndex]) - 1;
end;

function TRecorderMdbDialog.SelectedTestIndex: Integer;
begin
  if lbTests.ItemIndex < 0 then Exit(-1);
  Result := PtrInt(lbTests.Items.Objects[lbTests.ItemIndex]) - 1;
end;

procedure TRecorderMdbDialog.SelectObjectById(const AId: string);
var I, lIndex: Integer;
begin
  if AId = '' then Exit;
  for I := 0 to lbObjects.Items.Count - 1 do
  begin
    lIndex := PtrInt(lbObjects.Items.Objects[I]) - 1;
    if (lIndex >= 0) and (fObjects[lIndex].Id = AId) then
    begin
      lbObjects.ItemIndex := I;
      Exit;
    end;
  end;
end;

procedure TRecorderMdbDialog.SelectTestById(const AId: string);
var I, lIndex: Integer;
begin
  if AId = '' then Exit;
  for I := 0 to lbTests.Items.Count - 1 do
  begin
    lIndex := PtrInt(lbTests.Items.Objects[I]) - 1;
    if (lIndex >= 0) and (fTests[lIndex].Id = AId) then
    begin
      lbTests.ItemIndex := I;
      Exit;
    end;
  end;
end;

procedure TRecorderMdbDialog.UpdateSelectionState;
var lObjectIndex, lTestIndex: Integer;
begin
  lObjectIndex := SelectedObjectIndex;
  lTestIndex := SelectedTestIndex;
  btnCreateTest.Enabled := lObjectIndex >= 0;
  btnSelect.Enabled := (lObjectIndex >= 0) and (lTestIndex >= 0);
  if btnSelect.Enabled then
    lblContext.Caption := Format('Замеры: %s / %s',
      [fObjects[lObjectIndex].Name, fTests[lTestIndex].Name])
  else if lObjectIndex >= 0 then
    lblContext.Caption := Format('Изделие: %s. Выберите испытание',
      [fObjects[lObjectIndex].Name])
  else
    lblContext.Caption := 'Выберите изделие и испытание';
end;

procedure TRecorderMdbDialog.ReloadObjects;
var I, lSelectedIndex: Integer;
begin
  if fPreferredObjectId = '' then
  begin
    lSelectedIndex := SelectedObjectIndex;
    if lSelectedIndex >= 0 then
      fPreferredObjectId := fObjects[lSelectedIndex].Id;
  end;
  fManager.Repository.ListObjects(fObjects);
  fReloading := True;
  try
    lbObjects.Items.BeginUpdate;
    try
      lbObjects.Clear;
      for I := 0 to High(fObjects) do
        if ContainsText(fObjects[I].Name + ' ' + fObjects[I].SerialNumber,
          edObjectSearch.Text) then
          lbObjects.Items.AddObject(fObjects[I].Name + ' [' +
            fObjects[I].SerialNumber + ']', TObject(PtrInt(I + 1)));
    finally
      lbObjects.Items.EndUpdate;
    end;
    SelectObjectById(fPreferredObjectId);
  finally
    fReloading := False;
  end;
  fPreferredObjectId := '';
  ReloadTests;
end;

procedure TRecorderMdbDialog.ReloadTests;
var I, lObjectIndex, lSelectedIndex: Integer;
begin
  if fPreferredTestId = '' then
  begin
    lSelectedIndex := SelectedTestIndex;
    if lSelectedIndex >= 0 then
      fPreferredTestId := fTests[lSelectedIndex].Id;
  end;
  SetLength(fTests, 0);
  lObjectIndex := SelectedObjectIndex;
  if lObjectIndex >= 0 then
    fManager.Repository.ListTests(fObjects[lObjectIndex].Id, fTests);
  fReloading := True;
  try
    lbTests.Items.BeginUpdate;
    try
      lbTests.Clear;
      for I := 0 to High(fTests) do
        if ContainsText(fTests[I].Name, edTestSearch.Text) then
          lbTests.Items.AddObject(fTests[I].Name, TObject(PtrInt(I + 1)));
    finally
      lbTests.Items.EndUpdate;
    end;
    SelectTestById(fPreferredTestId);
  finally
    fReloading := False;
  end;
  fPreferredTestId := '';
  ReloadMeasurements;
end;

procedure TRecorderMdbDialog.ReloadMeasurements;
var
  lItems: TMdbMeasurementInfos;
  lItem: TListItem;
  I, lObjectIndex, lTestIndex: Integer;
begin
  lvMeasurements.Clear;
  lObjectIndex := SelectedObjectIndex;
  lTestIndex := SelectedTestIndex;
  UpdateSelectionState;
  if (lObjectIndex < 0) or (lTestIndex < 0) then Exit;
  fManager.Repository.ListMeasurements(fObjects[lObjectIndex].Id,
    fTests[lTestIndex].Id, lItems);
  for I := 0 to High(lItems) do
  begin
    lItem := lvMeasurements.Items.Add;
    lItem.Caption := DateTimeToStr(UniversalTimeToLocal(lItems[I].StartedAtUtc));
    lItem.SubItems.Add(lItems[I].Status);
    lItem.SubItems.Add(IntToStr(lItems[I].ValueCount));
    lItem.SubItems.Add(IntToStr(lItems[I].FileCount));
  end;
end;

procedure TRecorderMdbDialog.btnCreateObjectClick(Sender: TObject);
begin
  try
    fPreferredObjectId := fManager.Repository.CreateObject(edObjectName.Text,
      edObjectType.Text, edObjectSerial.Text);
    ReloadObjects;
  except
    on E: Exception do
      MessageDlg('Mdb', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderMdbDialog.btnCreateTestClick(Sender: TObject);
var lObjectIndex: Integer;
begin
  try
    lObjectIndex := SelectedObjectIndex;
    if lObjectIndex < 0 then
      raise EMdbError.Create('Сначала выберите изделие');
    fPreferredTestId := fManager.Repository.CreateTest(
      fObjects[lObjectIndex].Id, edTestName.Text, '{}',
      LocalTimeToUniversal(Now));
    ReloadTests;
  except
    on E: Exception do
      MessageDlg('Mdb', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderMdbDialog.btnSelectClick(Sender: TObject);
var lObjectIndex, lTestIndex: Integer;
begin
  try
    lObjectIndex := SelectedObjectIndex;
    lTestIndex := SelectedTestIndex;
    if (lObjectIndex < 0) or (lTestIndex < 0) then
      raise EMdbError.Create('Выберите изделие и испытание');
    fManager.SelectContext(fObjects[lObjectIndex], fTests[lTestIndex]);
    ModalResult := mrOK;
  except
    on E: Exception do
      MessageDlg('Mdb', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderMdbDialog.edObjectSearchChange(Sender: TObject);
begin
  ReloadObjects;
end;

procedure TRecorderMdbDialog.edTestSearchChange(Sender: TObject);
begin
  if fReloading then Exit;
  ReloadTests;
  UpdateSelectionState;
end;

procedure TRecorderMdbDialog.lbObjectsSelectionChange(Sender: TObject;
  User: Boolean);
begin
  ReloadTests;
end;

procedure TRecorderMdbDialog.lbTestsSelectionChange(Sender: TObject;
  User: Boolean);
begin
  if fReloading then Exit;
  ReloadMeasurements;
  UpdateSelectionState;
end;

function TRecorderMdbDialog.Execute(AManager: TRecorderMdbManager): Boolean;
begin
  fManager := AManager;
  fPreferredObjectId := fManager.Context.ObjectId;
  fPreferredTestId := fManager.Context.TestId;
  ReloadObjects;
  UpdateSelectionState;
  Result := ShowModal = mrOK;
end;

end.
