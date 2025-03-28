unit uPlatFrame;

interface

uses
  Windows, SysUtils, Classes, Forms, uUtsSensor, ubldobj, uChan, uBldGlobalStrings,
  StdCtrls, ComCtrls, uBtnListView, uBaseObjService, utickdata, Controls,
  uBldCompProc, u2070, uPlat, u2081, uSpin;


type
  TPlatframe = class(TFrame)
    BufSizeCB: TComboBox;
    BuffSizeLabel: TLabel;
    PeriodSE: TFloatSpinEdit;
    PeriodLabel: TLabel;
    FreqFE: TFloatSpinEdit;
    Label1: TLabel;
    ModeLabel: TLabel;
    ModeCB: TComboBox;
  private
    plat:cPlat;
  public
    //  ���������� �������� ������� � �����
    procedure GetObj(obj:cbldobj);
    //  ��������� �������� ������� �� ������ � ������
    procedure SetObj(obj:cbldobj);
  end;

implementation

{$R *.dfm}


procedure TPlatframe.GetObj(obj:cbldobj);
begin
  plat:=cplat(obj);
  BufSizeCB.Text:=inttostr(plat.BufferSize);
  freqfe.Value:=plat.freq;
  periodse.Value:=plat.period/1000;
  if plat.DataMode=c_OscMode then
    modecb.ItemIndex:=0
  else
    modecb.ItemIndex:=1;
end;

procedure TPlatframe.SetObj(obj:cbldobj);
begin
  plat.BufferSize:=strtoint(BufSizeCB.Text);
  plat.freq:=freqfe.Value;
  plat.period:=trunc(periodse.Value*1000);
  if modecb.ItemIndex=0 then
     plat.DataMode:=c_OscMode
  else
     plat.DataMode:=c_ASyncMode;
end;

end.
