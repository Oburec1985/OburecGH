unit uRcFrfPeakForm;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils, Forms, Controls, StdCtrls, Grids, Dialogs,
  uRcFrfPeaks;

type
  TRcPeakSelectedEvent = procedure(Sender: TObject) of object;

  { In-memory FRF peak table. Closing hides it; the view retains its rows. }
  TRcFrfPeakForm = class(TForm)
    btnReport: TButton;
    lblFormula: TLabel;
    grdPeaks: TStringGrid;
    dlgReport: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure grdPeaksSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure grdPeaksClick(Sender: TObject);
  private
    fPeaks: TRcPeaks;
    fSelectedPeakIndex: Integer;
    fUpdatingPeaks: Boolean;
    fUpdateCount: QWord;
    fOnPeakSelected: TRcPeakSelectedEvent;
    procedure SelectPeakRow(ARow: Integer);
  public
    procedure SetPeaks(const APeaks: TRcPeaks);
    function TryGetSelectedPeak(out APeak: TRcPeak): Boolean;
    property OnPeakSelected: TRcPeakSelectedEvent read fOnPeakSelected
      write fOnPeakSelected;
    property UpdateCount: QWord read fUpdateCount;
  end;

implementation

{$R *.lfm}

procedure TRcFrfPeakForm.FormCreate(Sender: TObject);
begin
  fSelectedPeakIndex := -1;
  grdPeaks.Cells[0, 0] := 'Канал';
  grdPeaks.Cells[1, 0] := 'Индекс';
  grdPeaks.Cells[2, 0] := 'Частота, Гц';
  grdPeaks.Cells[3, 0] := 'Значение';
  grdPeaks.Cells[4, 0] := 'Декремент';
end;

procedure TRcFrfPeakForm.SetPeaks(const APeaks: TRcPeaks);
var
  lI, lNewSelection: Integer;
  lSelectedPeak: TRcPeak;
  lHadSelection: Boolean;
begin
  lHadSelection := TryGetSelectedPeak(lSelectedPeak);
  fUpdatingPeaks := True;
  try
    fPeaks := Copy(APeaks);
    grdPeaks.RowCount := Length(fPeaks) + 1;
    if grdPeaks.RowCount < 2 then grdPeaks.RowCount := 2;
    for lI := 0 to grdPeaks.ColCount - 1 do
      grdPeaks.Cells[lI, 1] := '';
    lNewSelection := -1;
    for lI := 0 to High(fPeaks) do
    begin
      grdPeaks.Cells[0, lI + 1] := fPeaks[lI].Curve;
      grdPeaks.Cells[1, lI + 1] := IntToStr(fPeaks[lI].Index);
      grdPeaks.Cells[2, lI + 1] := FormatFloat('0.######', fPeaks[lI].Frequency);
      grdPeaks.Cells[3, lI + 1] := FormatFloat('0.######', fPeaks[lI].Value);
      if fPeaks[lI].Decrement >= 0 then
        grdPeaks.Cells[4, lI + 1] := FormatFloat('0.######', fPeaks[lI].Decrement)
      else
        grdPeaks.Cells[4, lI + 1] := '';
      if lHadSelection and (fPeaks[lI].Curve = lSelectedPeak.Curve) and
        (fPeaks[lI].Index = lSelectedPeak.Index) and
        (fPeaks[lI].Frequency = lSelectedPeak.Frequency) then
        lNewSelection := lI;
    end;
    fSelectedPeakIndex := lNewSelection;
    if lNewSelection >= 0 then
      grdPeaks.Row := lNewSelection + 1;
    Inc(fUpdateCount);
  finally
    fUpdatingPeaks := False;
  end;
end;

function TRcFrfPeakForm.TryGetSelectedPeak(out APeak: TRcPeak): Boolean;
begin
  Result := (fSelectedPeakIndex >= 0) and
    (fSelectedPeakIndex < Length(fPeaks));
  if Result then APeak := fPeaks[fSelectedPeakIndex];
end;

procedure TRcFrfPeakForm.grdPeaksSelectCell(Sender: TObject;
  aCol, aRow: Integer; var CanSelect: Boolean);
begin
  SelectPeakRow(aRow);
end;

procedure TRcFrfPeakForm.grdPeaksClick(Sender: TObject);
begin
  SelectPeakRow(grdPeaks.Row);
end;

procedure TRcFrfPeakForm.SelectPeakRow(ARow: Integer);
begin
  if fUpdatingPeaks or (ARow < 1) or (ARow > Length(fPeaks)) then Exit;
  if fSelectedPeakIndex = ARow - 1 then Exit;
  fSelectedPeakIndex := ARow - 1;
  if Assigned(fOnPeakSelected) then fOnPeakSelected(Self);
end;

procedure TRcFrfPeakForm.btnReportClick(Sender: TObject);
var
  lLines: TStringList;
  lI: Integer;
begin
  if not dlgReport.Execute then Exit;
  lLines := TStringList.Create;
  try
    lLines.Add('Канал;Индекс;Частота, Гц;Значение;Декремент');
    for lI := 0 to High(fPeaks) do
      lLines.Add(Format('%s;%d;%s;%s;%s', [fPeaks[lI].Curve,
        fPeaks[lI].Index,
        FloatToStr(fPeaks[lI].Frequency, DefaultFormatSettings),
        FloatToStr(fPeaks[lI].Value, DefaultFormatSettings),
        FloatToStr(fPeaks[lI].Decrement, DefaultFormatSettings)]));
    lLines.SaveToFile(dlgReport.FileName);
  finally
    lLines.Free;
  end;
end;

procedure TRcFrfPeakForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction := caHide;
end;

end.
