unit uRecorderBuiltInFormsUI;

{
  UI-владелец встроенных формуляров RecorderLnx: цифровой таблицы и базовой
  страницы осциллограмм. MainForm выбирает представление, но не знает деталей
  snapshot, раскраски, числа графиков и их обновления.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Controls, ExtCtrls, Forms, Grids, Spin, StdCtrls, Graphics,
  uRecorder, uRecorderFormModel, uRecorderMessages;

const
  CRecorderDigitalFormPageId = 'DigitalForm';
  CRecorderBaseFormPageId = 'BasePage';

type
  TRecorderDigitalViewMode = (rdvmTags, rdvmMessages);

  TRecorderBuiltInFormsFrame = class(TFrame)
    BaseToolbar: TPanel;
    BaseChartsPanel: TPanel;
    OscillogramCountEdit: TSpinEdit;
    OscillogramCountLabel: TLabel;
    BaseFpsLabel: TLabel;
    procedure BaseChartsPanelResize(Sender: TObject);
    procedure OscillogramCountEditChange(Sender: TObject);
  private
    fDigitalGrid: TStringGrid;
    fFormManager: TRecorderFormManager;
    fMessageRevision: QWord;
    fMessageRows: TRecorderMessageSnapshotArray;
    fRecorder: TRecorder;
    fViewMode: TRecorderDigitalViewMode;
    procedure RenderMessages(ARebuild: Boolean);
  public
    procedure Configure(ARecorder: TRecorder; AForms: TRecorderFormManager;
      ADigitalGrid: TStringGrid);
    function IsBuiltInPage(APage: TRecorderFormPage): Boolean;
    procedure RenderDigital(ARebuild: Boolean = True);
    procedure RenderBase;
    procedure RebuildBase(ACount: Integer);
    procedure RefreshBase;
    procedure SetBaseVisible(AVisible: Boolean);
    procedure SetChartsVisible(AVisible: Boolean);
    procedure InvalidateBase;
    function BaseVisible: Boolean;
    procedure ToggleDigitalMode;
    procedure SetDigitalViewMode(AValue: TRecorderDigitalViewMode);
    procedure PrepareDigitalCanvas(ACol, ARow: Integer;
      AState: TGridDrawState);
    function DigitalTagNameAtRow(ARow: Integer): string;
    property ViewMode: TRecorderDigitalViewMode read fViewMode;
  end;

implementation

{$R *.lfm}

uses
  DateUtils, Math, SysUtils,
  uRecorderDigitalPageView, uRecorderOglOscillogramView, uRecorderStateMachine,
  uRecorderTags;

procedure TRecorderBuiltInFormsFrame.Configure(ARecorder: TRecorder;
  AForms: TRecorderFormManager; ADigitalGrid: TStringGrid);
begin
  fRecorder := ARecorder;
  fFormManager := AForms;
  fDigitalGrid := ADigitalGrid;
end;

function TRecorderBuiltInFormsFrame.IsBuiltInPage(
  APage: TRecorderFormPage): Boolean;
begin
  Result := (APage <> nil) and ((APage.Id = CRecorderDigitalFormPageId) or
    (APage.Id = CRecorderBaseFormPageId));
end;

procedure TRecorderBuiltInFormsFrame.RenderDigital(ARebuild: Boolean);
begin
  if (fRecorder = nil) or (fDigitalGrid = nil) then
    Exit;
  if fViewMode = rdvmMessages then
    RenderMessages(ARebuild)
  else if ARebuild then
    RenderRecorderDigitalPage(fDigitalGrid, fRecorder.TagRegistry,
      fRecorder.AlarmEngine)
  else
    UpdateRecorderDigitalPage(fDigitalGrid, fRecorder.TagRegistry,
      fRecorder.AlarmEngine);
end;

procedure TRecorderBuiltInFormsFrame.RenderMessages(ARebuild: Boolean);
var
  I: Integer;
  lRevision: QWord;
  lTimeText, lTypeText: string;
begin
  lRevision := fRecorder.Messages.CopySnapshot(fMessageRows, fMessageRevision);
  if (not ARebuild) and (lRevision = fMessageRevision) then Exit;
  fMessageRevision := lRevision;
  fDigitalGrid.BeginUpdate;
  try
    fDigitalGrid.ColCount := 6;
    fDigitalGrid.FixedRows := 1;
    fDigitalGrid.RowCount := Max(2, Length(fMessageRows) + 1);
    fDigitalGrid.Cells[0, 0] := 'Сообщение';
    fDigitalGrid.Cells[1, 0] := 'Источник';
    fDigitalGrid.Cells[2, 0] := 'Значение';
    fDigitalGrid.Cells[3, 0] := 'Время';
    fDigitalGrid.Cells[4, 0] := 'Тип';
    fDigitalGrid.Cells[5, 0] := 'Качество';
    fDigitalGrid.ColWidths[0] := 160;
    fDigitalGrid.ColWidths[1] := 190;
    fDigitalGrid.ColWidths[2] := 320;
    fDigitalGrid.ColWidths[3] := 170;
    fDigitalGrid.ColWidths[4] := 110;
    fDigitalGrid.ColWidths[5] := 90;
    for I := 0 to High(fMessageRows) do
    begin
      if fMessageRows[I].TimestampSec > 0 then
        lTimeText := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',
          UnixToDateTime(Trunc(fMessageRows[I].TimestampSec), False) +
          Frac(fMessageRows[I].TimestampSec) / 86400.0)
      else
        lTimeText := '';
      case fMessageRows[I].Kind of
        rmkWarning: lTypeText := 'Предупреждение';
        rmkStatus: lTypeText := 'Статус';
      else
        lTypeText := 'Информация';
      end;
      fDigitalGrid.Cells[0, I + 1] := fMessageRows[I].Name;
      fDigitalGrid.Cells[1, I + 1] := fMessageRows[I].SourceId;
      fDigitalGrid.Cells[2, I + 1] := fMessageRows[I].Value;
      fDigitalGrid.Cells[3, I + 1] := lTimeText;
      fDigitalGrid.Cells[4, I + 1] := lTypeText;
      fDigitalGrid.Cells[5, I + 1] := '0x' +
        IntToHex(fMessageRows[I].Quality, 8);
    end;
    if Length(fMessageRows) = 0 then
      for I := 0 to fDigitalGrid.ColCount - 1 do
        fDigitalGrid.Cells[I, 1] := '';
  finally
    fDigitalGrid.EndUpdate;
  end;
end;

procedure TRecorderBuiltInFormsFrame.RenderBase;
var
  lCount: Integer;
begin
  lCount := 2;
  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) and
    (fFormManager.ActivePage.Id = CRecorderBaseFormPageId) then
    lCount := EnsureRange(fFormManager.ActivePage.BaseOscillogramCount, 1, 16);
  OscillogramCountEdit.OnChange := nil;
  try
    OscillogramCountEdit.Value := lCount;
  finally
    OscillogramCountEdit.OnChange := @OscillogramCountEditChange;
  end;
  RebuildBase(lCount);
  RefreshBase;
  BaseChartsPanel.Invalidate;
end;

procedure TRecorderBuiltInFormsFrame.RebuildBase(ACount: Integer);
begin
  if fRecorder = nil then Exit;
  RebuildRecorderOglOscillograms(Self, BaseChartsPanel,
    fRecorder.TagRegistry, ACount, fRecorder.RunSettings.DisplayBufferMs / 1000);
end;

procedure TRecorderBuiltInFormsFrame.RefreshBase;
begin
  if fRecorder = nil then Exit;
  RefreshRecorderOglOscillograms(BaseChartsPanel, fRecorder.TagRegistry,
    fRecorder.RunSettings.DisplayBufferMs / 1000,
    fRecorder.StateMachine.State = rsPreview);
  BaseFpsLabel.Caption := RecorderOglOscillogramsFpsText(BaseChartsPanel);
end;

procedure TRecorderBuiltInFormsFrame.SetBaseVisible(AVisible: Boolean);
begin
  Visible := AVisible;
  BaseToolbar.Visible := AVisible;
  BaseChartsPanel.Visible := AVisible;
  if AVisible then
  begin
    BringToFront;
    BaseChartsPanel.Invalidate;
  end;
end;

procedure TRecorderBuiltInFormsFrame.SetChartsVisible(AVisible: Boolean);
begin
  BaseChartsPanel.Visible := AVisible;
end;

procedure TRecorderBuiltInFormsFrame.InvalidateBase;
begin
  BaseChartsPanel.Invalidate;
end;

function TRecorderBuiltInFormsFrame.BaseVisible: Boolean;
begin
  Result := Visible and BaseChartsPanel.Visible;
end;

procedure TRecorderBuiltInFormsFrame.ToggleDigitalMode;
begin
  if fViewMode = rdvmTags then fViewMode := rdvmMessages
  else fViewMode := rdvmTags;
  RenderDigital(True);
end;

procedure TRecorderBuiltInFormsFrame.SetDigitalViewMode(
  AValue: TRecorderDigitalViewMode);
begin
  if fViewMode = AValue then Exit;
  fViewMode := AValue;
  fMessageRevision := 0;
end;

procedure TRecorderBuiltInFormsFrame.PrepareDigitalCanvas(ACol, ARow: Integer;
  AState: TGridDrawState);
var
  lColor: LongInt;
  lRow: Integer;
  lTag: TRecorderTag;
  lUnit: string;
begin
  if (fDigitalGrid = nil) or (ARow <= 0) or (gdSelected in AState) then Exit;
  if fViewMode = rdvmMessages then
  begin
    if ARow <= Length(fMessageRows) then
    begin
      fDigitalGrid.Canvas.Brush.Color := TColor(fMessageRows[ARow - 1].Color);
      fDigitalGrid.Canvas.Font.Color := clBlack;
    end;
    Exit;
  end;
  lUnit := Trim(fDigitalGrid.Cells[3, ARow]);
  if (ACol = 3) and (SameText(lUnit, 'код') or SameText(lUnit, 'code')) then
  begin
    fDigitalGrid.Canvas.Brush.Color := clSilver;
    fDigitalGrid.Canvas.Font.Color := clBlack;
    Exit;
  end;
  if (fRecorder = nil) or (fRecorder.TagRegistry = nil) or
    (fRecorder.AlarmEngine = nil) then Exit;
  lRow := ARow;
  while (lRow > 0) and (fDigitalGrid.Cells[0, lRow] = '') do Dec(lRow);
  if lRow <= 0 then Exit;
  lTag := fRecorder.TagRegistry.FindByName(fDigitalGrid.Cells[0, lRow]);
  if lTag = nil then Exit;
  if lTag.SignalBuffer.Count = 0 then lColor := $808080
  else lColor := fRecorder.AlarmEngine.GetTagAlarmColor(lTag);
  if lColor <> 0 then
  begin
    fDigitalGrid.Canvas.Brush.Color := TColor(lColor);
    fDigitalGrid.Canvas.Font.Color := clBlack;
  end;
end;

function TRecorderBuiltInFormsFrame.DigitalTagNameAtRow(ARow: Integer): string;
begin
  Result := '';
  if (fDigitalGrid = nil) or (fViewMode <> rdvmTags) then Exit;
  while (ARow > 0) and (fDigitalGrid.Cells[0, ARow] = '') do Dec(ARow);
  if ARow > 0 then Result := Trim(fDigitalGrid.Cells[0, ARow]);
end;

procedure TRecorderBuiltInFormsFrame.OscillogramCountEditChange(Sender: TObject);
begin
  if (fFormManager = nil) or (fFormManager.ActivePage = nil) or
    (fFormManager.ActivePage.Id <> CRecorderBaseFormPageId) then Exit;
  fFormManager.ActivePage.BaseOscillogramCount := OscillogramCountEdit.Value;
  RenderBase;
end;

procedure TRecorderBuiltInFormsFrame.BaseChartsPanelResize(Sender: TObject);
begin
  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) and
    (fFormManager.ActivePage.Id = CRecorderBaseFormPageId) then
    RebuildBase(OscillogramCountEdit.Value);
end;

end.
