unit uRZDTareFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, ucommontypes,posbase, Winpos_ole_TLB, uWPProc,
  uWPservices;

type
  TRZDTareFrame = class(TFrame)
    HFCbox: TComboBox;
    Path: TComboBox;
    S1Cbox: TComboBox;
    S2Cbox: TComboBox;
    S3Cbox: TComboBox;
    S4Cbox: TComboBox;
    VFCbox: TComboBox;
    PathBtn: TButton;
    SelectIntervalCursorBtn: TButton;
    T1FE: TFloatEdit;
    T2FE: TFloatEdit;
    T1Label: TLabel;
    T2Label: TLabel;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    NullFE1: TFloatEdit;
    NullFE2: TFloatEdit;
    Label3: TLabel;
    Label4: TLabel;
    NullBtn: TButton;
    SelectIntervalGraphBtn: TButton;
    procedure SelectIntervalCursorBtnClick(Sender: TObject);
    procedure SelectIntervalGraphBtnClick(Sender: TObject);
    procedure PathBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    function GetInterval:point2d;
    function GetNullInterval:point2d;
  end;

implementation

{$R *.dfm}

procedure TRZDTareFrame.PathBtnClick(Sender: TObject);
begin
  if opendialog1.Execute(0) then
  begin
    path.text:=opendialog1.FileName;
  end;
end;

procedure TRZDTareFrame.SelectIntervalCursorBtnClick(Sender: TObject);
var
  p2:point2d;
begin
  p2:=GetActiveCursorX;
  t1fe.FloatNum:=p2.x;
  t2fe.FloatNum:=p2.y;
end;

procedure TRZDTareFrame.SelectIntervalGraphBtnClick(Sender: TObject);
var
  p2:point2d;
begin
  p2:=GetActiveGraphX;
  t1fe.FloatNum:=p2.x;
  t2fe.FloatNum:=p2.y;
end;

function TRZDTareFrame.GetInterval:point2d;
begin
  result:=p2d(t1fe.FloatNum, t2fe.FloatNum);
end;

function TRZDTareFrame.GetNullInterval:point2d;
begin
  result.x:=NullFE1.FloatNum;
  result.y:=NullFE2.FloatNum;
end;

end.
