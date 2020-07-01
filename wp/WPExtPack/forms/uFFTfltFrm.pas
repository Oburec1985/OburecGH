unit uFFTfltFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, Spin, ExtCtrls, uChart, uFFTflt,
  uWPservices, uCommonTypes, posbase, Winpos_ole_TLB,
  inifiles,
  uComponentServises,
  uCommonMath;

type
  TFFTFltFrm = class(TForm)
    ActionPanel: TPanel;
    RightPanel: TPanel;
    ApplyBtn: TButton;
    BtnListView1: TBtnListView;
    SignalsLB: TListBox;
    EditCurvePanel: TPanel;
    F1se: TSpinEdit;
    F2se: TSpinEdit;
    F1Label: TLabel;
    F2Label: TLabel;
    Indexse_01: TSpinEdit;
    Indexse_02: TSpinEdit;
    F1indLabel: TLabel;
    F2indLabel: TLabel;
    ScaleSE: TSpinEdit;
    Label5: TLabel;
    Установить: TButton;
    ScaleCurveChart: cChart;
  private
    m_oper:TExtFFTflt;
  private
    procedure showSignals;
    function getsignal(i:integer):iwpsignal;
    function GetPropStr: string;
    Procedure SetPropStr(str: string);
    function GetNotifyStr(p_opts: string): string;
  public
    procedure link(eo: TExtFFTflt);
    function EditOper: string;
  end;

var
  FFTFltFrm: TFFTFltFrm;

implementation

{$R *.dfm}

{ TFFTFltFrm }

function TFFTFltFrm.EditOper: string;
var
  res: integer;
  i: integer;
  p2:point2d;
begin
  // переносим свойства в форму
  p2:=GetActiveCursorX;
  showSignals;
  res := showmodal;
  if res = mrok then
  begin
    // переносим свойства в оператор
    m_oper.SetPropStr(GetPropStr);
  end;
end;

function TFFTFltFrm.GetNotifyStr(p_opts: string): string;
begin

end;

function TFFTFltFrm.GetPropStr: string;
begin

end;

function TFFTFltFrm.getsignal(i: integer): iwpsignal;
begin

end;

procedure TFFTFltFrm.link(eo: TExtFFTflt);
begin

end;

procedure TFFTFltFrm.SetPropStr(str: string);
begin

end;

procedure TFFTFltFrm.showSignals;
begin

end;

end.
