unit ulogFrame;

interface

uses
  Windows, Classes, Controls, Forms,  StdCtrls, Grids, uLogFile;

type
  TLogFrame = class(TFrame)
    ControlGB: TGroupBox;
    ClearBtn: TButton;
    FilterCB: TComboBox;
    FilterLabel: TLabel;
    LogSg: TStringGrid;
    procedure FrameResize(Sender: TObject);
  private
    log:clogFile;
  protected
    procedure OnUpdateLog(sender:tobject);
  public
    procedure Init(p_log:clogFile);
  end;

implementation
const
 c_NumColWidth = 40;

{$R *.dfm}

procedure TLogFrame.FrameResize(Sender: TObject);
var
  w,colcount:integer;
  I: Integer;
begin
  colcount:=LogSg.ColCount;
  w:=trunc((Width-c_NumColWidth)/(colcount-1));
  LogSg.ColWidths[0]:=c_NumColWidth;
  for I := 1 to colcount - 1 do
  begin
    LogSg.ColWidths[i]:=w;
  end;
end;

procedure TLogFrame.Init(p_log:clogFile);
begin
  InitSG(logsg,p_log);
  log:=p_log;
  log.fOnAddRecord:=OnUpdateLog;
end;

procedure TLogFrame.OnUpdateLog(sender:tobject);
begin
  ShowInSG(logsg,log);
end;

end.
