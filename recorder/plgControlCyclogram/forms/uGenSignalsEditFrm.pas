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
    procedure CreateSignalBtnClick(Sender: TObject);
  private
    m_l:tlist;
  protected
    function NewName:string;
  public
    procedure NewSignal(l:tlist);
  end;

var
  GenSignalsEditFrm: TGenSignalsEditFrm;

implementation

{$R *.dfm}

{ TGenSignalsEditFrm }

procedure TGenSignalsEditFrm.CreateSignalBtnClick(Sender: TObject);
var
  s:cgensig;
begin
  NameEdit.text:=NewName;
  s:=cGenSig.create(NameEdit.text, 1000);
  s.Phase0:=phasese.Value;
  s.Amp:=AmpSE.Value;
  s.m_freq:=FreqSE.Value;
  s.m_fs:=FsEdit.FloatNum;
  s.m_type:=styperg.ItemIndex;
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
    str:=ModName(str);
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
