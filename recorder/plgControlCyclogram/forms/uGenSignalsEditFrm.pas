unit uGenSignalsEditFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  activex,
  blaccess,
  urcfunc,
  ucommonmath, MathFunction, uMyMath,
  uRecorderEvents, ubaseObj, uCommonTypes,
  uRTrig, ubasealg, uBuffTrend1d, tags,
  PluginClass, ImgList, Menus, DCL_MYOWN, uSpin, uGenSignalsFrm;

type
  TGenSignalsEditFrm = class(TForm)
    NameEdit: TEdit;
    STypeRG: TRadioGroup;
    AmpLabel: TLabel;
    AmpSE: TFloatSpinEdit;
    FreqLabel: TLabel;
    FreqSE: TFloatSpinEdit;
    PhaseLabel: TLabel;
    PhaseSE: TFloatSpinEdit;
    Label1: TLabel;
    FsEdit: TFloatEdit;
    FsLabel: TLabel;
    CreateSignalBtn: TButton;
    OffsetFE: TFloatSpinEdit;
    Label2: TLabel;
    F2SweepLabel: TLabel;
    Freq2Fe: TFloatSpinEdit;
    SweepTimeLabel: TLabel;
    TimeSe: TFloatSpinEdit;
    SweepSinCB: TCheckBox;
    SweepLgCB: TCheckBox;
    procedure CreateSignalBtnClick(Sender: TObject);
  private
    m_l:tlist;
  protected
    function NewName:string;
    procedure UpdateSignal(s:cGenSig);
  public
    procedure NewSignal(l:tlist);
  end;

var
  GenSignalsEditFrm: TGenSignalsEditFrm;

implementation

{$R *.dfm}

{ TGenSignalsEditFrm }


procedure TGenSignalsEditFrm.UpdateSignal(s: cGenSig);
begin
  s.Phase0:=phasese.Value;
  s.Amp:=AmpSE.Value;
  s.m_freq:=FreqSE.Value;
  s.m_fs:=FsEdit.FloatNum;
  s.m_type:=styperg.ItemIndex;
  s.m_offset:=OffsetFE.Value;

  s.m_sweep:=SweepSinCB.Checked;
  s.m_lg:=SweepLgCB.Checked;
  s.m_freq2:=Freq2Fe.Value;
  s.m_sweepTime:=Freq2Fe.Value;
end;


procedure TGenSignalsEditFrm.CreateSignalBtnClick(Sender: TObject);
var
  s:cgensig;
begin
  NameEdit.text:=NewName;
  s:=cGenSig.create(NameEdit.text, 1000);
  // копируем свойства формы в сигнал
  UpdateSignal(s);
  m_l.Add(s);
end;

function TGenSignalsEditFrm.NewName: string;
var
  t:itag;
  str:string;
begin
  str:='GenSignal_001';
  t:=getTagByName(str);
  while t<>nil do
  begin
    str:=ModName(str, false);
    t:=getTagByName(str);
  end;
  result:=str;
end;

procedure TGenSignalsEditFrm.NewSignal(l:tlist);
begin
  m_l:=l;
  showmodal;
end;

end.
