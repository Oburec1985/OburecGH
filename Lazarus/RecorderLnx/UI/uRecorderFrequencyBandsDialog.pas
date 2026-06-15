unit uRecorderFrequencyBandsDialog;

{
  Dialog for editing RecorderLnx frequency bands.

  It is intentionally simple and LCL-only. The model lives in
  uRecorderFrequencyBands so spectrum/AFC charts can later link to the same
  bands without depending on this dialog.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Grids,
  LConvEncoding, uRecorderFrequencyBands;

type
  TRecorderFrequencyBandsDialog = class(TForm)
  private
    fBands: TRecorderFrequencyBandList;
    fOwnBands: Boolean;
    fBandList: TListBox;
    fNameEdit: TEdit;
    fKindCombo: TComboBox;
    fX1Edit: TEdit;
    fX2Edit: TEdit;
    fTermsGrid: TStringGrid;
    procedure AddBandClick(Sender: TObject);
    procedure DeleteBandClick(Sender: TObject);
    procedure ApplyBandClick(Sender: TObject);
    procedure AddTermClick(Sender: TObject);
    procedure DeleteTermClick(Sender: TObject);
    procedure BandListClick(Sender: TObject);
    function CurrentBand: TRecorderFrequencyBand;
    procedure BuildUi;
    procedure LoadBand(ABand: TRecorderFrequencyBand);
    procedure RefreshBandList;
    procedure StoreBand(ABand: TRecorderFrequencyBand);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Bands: TRecorderFrequencyBandList read fBands;
  end;

function ShowRecorderFrequencyBandsDialog(AOwner: TComponent;
  ABands: TRecorderFrequencyBandList): Boolean;

implementation

function ShowRecorderFrequencyBandsDialog(AOwner: TComponent;
  ABands: TRecorderFrequencyBandList): Boolean;
var
  lDialog: TRecorderFrequencyBandsDialog;
begin
  lDialog := TRecorderFrequencyBandsDialog.Create(AOwner);
  try
    if ABands <> nil then
    begin
      lDialog.fBands.Free;
      lDialog.fBands := ABands;
      lDialog.fOwnBands := False;
      lDialog.RefreshBandList;
    end;
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderFrequencyBandsDialog.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  fBands := TRecorderFrequencyBandList.Create;
  fOwnBands := True;
  BuildUi;
  RefreshBandList;
end;

destructor TRecorderFrequencyBandsDialog.Destroy;
begin
  if fOwnBands then
    fBands.Free;
  inherited Destroy;
end;

procedure TRecorderFrequencyBandsDialog.BuildUi;
var
  lLeftPanel: TPanel;
  lRightPanel: TPanel;
  lBottomPanel: TPanel;
  lButton: TButton;
begin
  Caption := CP1251ToUTF8('Частотные полосы');
  Width := 680;
  Height := 420;
  Position := poOwnerFormCenter;

  lLeftPanel := TPanel.Create(Self);
  lLeftPanel.Parent := Self;
  lLeftPanel.Align := alLeft;
  lLeftPanel.Width := 210;
  lLeftPanel.BevelOuter := bvNone;

  fBandList := TListBox.Create(Self);
  fBandList.Parent := lLeftPanel;
  fBandList.Align := alClient;
  fBandList.OnClick := @BandListClick;

  lBottomPanel := TPanel.Create(Self);
  lBottomPanel.Parent := lLeftPanel;
  lBottomPanel.Align := alBottom;
  lBottomPanel.Height := 42;
  lBottomPanel.BevelOuter := bvNone;

  lButton := TButton.Create(Self);
  lButton.Parent := lBottomPanel;
  lButton.SetBounds(8, 8, 58, 26);
  lButton.Caption := '+';
  lButton.OnClick := @AddBandClick;

  lButton := TButton.Create(Self);
  lButton.Parent := lBottomPanel;
  lButton.SetBounds(74, 8, 58, 26);
  lButton.Caption := '-';
  lButton.OnClick := @DeleteBandClick;

  lRightPanel := TPanel.Create(Self);
  lRightPanel.Parent := Self;
  lRightPanel.Align := alClient;
  lRightPanel.BevelOuter := bvNone;

  with TLabel.Create(Self) do
  begin
    Parent := lRightPanel;
    SetBounds(12, 14, 90, 18);
    Caption := CP1251ToUTF8('Название');
  end;
  fNameEdit := TEdit.Create(Self);
  fNameEdit.Parent := lRightPanel;
  fNameEdit.SetBounds(110, 10, 190, 24);

  with TLabel.Create(Self) do
  begin
    Parent := lRightPanel;
    SetBounds(320, 14, 42, 18);
    Caption := CP1251ToUTF8('Тип');
  end;
  fKindCombo := TComboBox.Create(Self);
  fKindCombo.Parent := lRightPanel;
  fKindCombo.SetBounds(368, 10, 130, 24);
  fKindCombo.Style := csDropDownList;
  fKindCombo.Items.Add(CP1251ToUTF8('абсолютная'));
  fKindCombo.Items.Add(CP1251ToUTF8('формула'));
  fKindCombo.ItemIndex := 0;

  with TLabel.Create(Self) do
  begin
    Parent := lRightPanel;
    SetBounds(12, 48, 90, 18);
    Caption := 'F1';
  end;
  fX1Edit := TEdit.Create(Self);
  fX1Edit.Parent := lRightPanel;
  fX1Edit.SetBounds(110, 44, 90, 24);

  with TLabel.Create(Self) do
  begin
    Parent := lRightPanel;
    SetBounds(220, 48, 90, 18);
    Caption := 'F2';
  end;
  fX2Edit := TEdit.Create(Self);
  fX2Edit.Parent := lRightPanel;
  fX2Edit.SetBounds(268, 44, 90, 24);

  fTermsGrid := TStringGrid.Create(Self);
  fTermsGrid.Parent := lRightPanel;
  fTermsGrid.SetBounds(12, 84, 486, 230);
  fTermsGrid.AnchorSideRight.Control := lRightPanel;
  fTermsGrid.AnchorSideRight.Side := asrRight;
  fTermsGrid.AnchorSideBottom.Control := lRightPanel;
  fTermsGrid.AnchorSideBottom.Side := asrBottom;
  fTermsGrid.Anchors := [akLeft, akTop, akRight, akBottom];
  fTermsGrid.ColCount := 2;
  fTermsGrid.RowCount := 2;
  fTermsGrid.FixedCols := 0;
  fTermsGrid.Cells[0, 0] := CP1251ToUTF8('Тахо/частота');
  fTermsGrid.Cells[1, 0] := CP1251ToUTF8('Коэффициент');
  fTermsGrid.Options := fTermsGrid.Options + [goEditing, goRowSelect];

  lBottomPanel := TPanel.Create(Self);
  lBottomPanel.Parent := lRightPanel;
  lBottomPanel.Align := alBottom;
  lBottomPanel.Height := 48;
  lBottomPanel.BevelOuter := bvNone;

  lButton := TButton.Create(Self);
  lButton.Parent := lBottomPanel;
  lButton.SetBounds(12, 10, 86, 28);
  lButton.Caption := CP1251ToUTF8('+ слагаемое');
  lButton.OnClick := @AddTermClick;

  lButton := TButton.Create(Self);
  lButton.Parent := lBottomPanel;
  lButton.SetBounds(106, 10, 86, 28);
  lButton.Caption := CP1251ToUTF8('- слагаемое');
  lButton.OnClick := @DeleteTermClick;

  lButton := TButton.Create(Self);
  lButton.Parent := lBottomPanel;
  lButton.SetBounds(210, 10, 90, 28);
  lButton.Caption := CP1251ToUTF8('Применить');
  lButton.OnClick := @ApplyBandClick;

  lButton := TButton.Create(Self);
  lButton.Parent := lBottomPanel;
  lButton.SetBounds(320, 10, 78, 28);
  lButton.Caption := 'OK';
  lButton.ModalResult := mrOk;

  lButton := TButton.Create(Self);
  lButton.Parent := lBottomPanel;
  lButton.SetBounds(406, 10, 78, 28);
  lButton.Caption := CP1251ToUTF8('Закрыть');
  lButton.ModalResult := mrCancel;
end;

function TRecorderFrequencyBandsDialog.CurrentBand: TRecorderFrequencyBand;
begin
  Result := nil;
  if (fBandList.ItemIndex >= 0) and (fBandList.ItemIndex < fBands.BandCount) then
    Result := fBands.Bands[fBandList.ItemIndex];
end;

procedure TRecorderFrequencyBandsDialog.RefreshBandList;
var
  I: Integer;
begin
  fBandList.Items.BeginUpdate;
  try
    fBandList.Items.Clear;
    for I := 0 to fBands.BandCount - 1 do
      fBandList.Items.Add(CP1251ToUTF8(fBands.Bands[I].Name));
  finally
    fBandList.Items.EndUpdate;
  end;
  if (fBandList.ItemIndex < 0) and (fBandList.Count > 0) then
    fBandList.ItemIndex := 0;
  LoadBand(CurrentBand);
end;

procedure TRecorderFrequencyBandsDialog.LoadBand(ABand: TRecorderFrequencyBand);
var
  I: Integer;
begin
  if ABand = nil then
    Exit;
  fNameEdit.Text := CP1251ToUTF8(ABand.Name);
  fKindCombo.ItemIndex := Ord(ABand.Kind);
  fX1Edit.Text := FloatToStr(ABand.X1);
  fX2Edit.Text := FloatToStr(ABand.X2);
  fTermsGrid.RowCount := ABand.TermCount + 1;
  if fTermsGrid.RowCount < 2 then
    fTermsGrid.RowCount := 2;
  for I := 1 to fTermsGrid.RowCount - 1 do
  begin
    fTermsGrid.Cells[0, I] := '';
    fTermsGrid.Cells[1, I] := '';
  end;
  for I := 0 to ABand.TermCount - 1 do
  begin
    fTermsGrid.Cells[0, I + 1] := CP1251ToUTF8(ABand.Terms[I].TagName);
    fTermsGrid.Cells[1, I + 1] := FloatToStr(ABand.Terms[I].Coefficient);
  end;
end;

procedure TRecorderFrequencyBandsDialog.StoreBand(ABand: TRecorderFrequencyBand);
var
  I: Integer;
  lK: Double;
begin
  if ABand = nil then
    Exit;
  ABand.Name := UTF8ToCP1251(Trim(fNameEdit.Text));
  ABand.Kind := TRecorderFrequencyBandKind(fKindCombo.ItemIndex);
  ABand.X1 := StrToFloatDef(Trim(fX1Edit.Text), 0.0);
  ABand.X2 := StrToFloatDef(Trim(fX2Edit.Text), 0.0);
  ABand.ClearTerms;
  for I := 1 to fTermsGrid.RowCount - 1 do
  begin
    if Trim(fTermsGrid.Cells[0, I]) = '' then
      Continue;
    lK := StrToFloatDef(Trim(fTermsGrid.Cells[1, I]), 1.0);
    ABand.AddTerm(UTF8ToCP1251(Trim(fTermsGrid.Cells[0, I])), lK);
  end;
  ABand.Validate;
end;

procedure TRecorderFrequencyBandsDialog.AddBandClick(Sender: TObject);
var
  lBand: TRecorderFrequencyBand;
begin
  lBand := fBands.AddBand('Полоса ' + IntToStr(fBands.BandCount + 1));
  lBand.X1 := 0.0;
  lBand.X2 := 100.0;
  RefreshBandList;
  fBandList.ItemIndex := fBands.BandCount - 1;
  LoadBand(lBand);
end;

procedure TRecorderFrequencyBandsDialog.DeleteBandClick(Sender: TObject);
begin
  fBands.DeleteBand(fBandList.ItemIndex);
  RefreshBandList;
end;

procedure TRecorderFrequencyBandsDialog.ApplyBandClick(Sender: TObject);
begin
  StoreBand(CurrentBand);
  RefreshBandList;
end;

procedure TRecorderFrequencyBandsDialog.AddTermClick(Sender: TObject);
begin
  fTermsGrid.RowCount := fTermsGrid.RowCount + 1;
end;

procedure TRecorderFrequencyBandsDialog.DeleteTermClick(Sender: TObject);
begin
  if fTermsGrid.Row > 0 then
    fTermsGrid.DeleteRow(fTermsGrid.Row);
end;

procedure TRecorderFrequencyBandsDialog.BandListClick(Sender: TObject);
begin
  LoadBand(CurrentBand);
end;

end.
