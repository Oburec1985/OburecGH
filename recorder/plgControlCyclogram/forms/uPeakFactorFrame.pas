unit uPeakFactorFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises, mathfunction, tags,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, uCounterAlg,
  uPeakFactorAlg,
  uRcCtrls,
  DCL_MYOWN, uTahoAlg, Spin, ComCtrls, uBtnListView, uRcFunc;

type
  TPeakFactorFrame = class(TBaseAlgFrame)
    PCountLabel: TLabel;
    PCountEdit: TIntEdit;
    dFLabel: TLabel;
    dTFE: TEdit;
    AlgTypeRG: TRadioGroup;
    ChannelCB: TRcComboBox;
    ChannelLabel: TLabel;
    OutChannelName: TEdit;
    Label1: TLabel;
  private
    procedure init;
    function getProperties: string; override;
    procedure setProperties(s: string); override;
    function algClass:string;override;
    procedure clearframeparams; override;
  public
    procedure doShow; override;
    constructor create(aOwner: tcomponent); override;
    destructor destroy; override;
    function CreateAlg: cBaseAlg; override;
  end;

var
  PeakFactorFrame: TPeakFactorFrame;

implementation

{$R *.dfm}

{ TBaseAlgFrame1 }

function TPeakFactorFrame.algClass: string;
begin
  result:='cPeakFactorAlg';
end;

procedure TPeakFactorFrame.clearframeparams;
begin
  AlgTypeRG.itemindex:=0;
  dtFE.text:='0';
  pCountEdit.IntNum:=0;
  ChannelCB.text:='';
  OutChannelName.text:='';
end;

constructor TPeakFactorFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := '��� ������';
end;

function TPeakFactorFrame.CreateAlg: cBaseAlg;
begin
  result := cPeakFactorAlg.create;
end;

destructor TPeakFactorFrame.destroy;
begin

  inherited;
end;

procedure TPeakFactorFrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
  if AlgTypeRg.Items.Count=0 then
  begin
    AlgTypeRg.Items.Add('�� ������� (A/Rms)');
    AlgTypeRg.Items.Add('�� ������� A1/Rms');
  end;
end;

function TPeakFactorFrame.getProperties: string;
begin
  addParam(m_pars, 'Type', inttostr(AlgTypeRG.ItemIndex));
  if dtFE.text<>'' then
    addParam(m_pars, 'dT', replaceChar(dtFE.text,',','.'));
  addParam(m_pars, 'pCount', pCountEdit.text);
  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
    OutChannelName.text:=ChannelCB.text+'_PeakFct';
  end;
  result:=ParsToStr(m_pars);
end;

procedure TPeakFactorFrame.init;
begin

end;

procedure TPeakFactorFrame.setProperties(s: string);
var
  p:tnotifyevent;
  str:string;
begin
  inherited;
  // m_pars �������� � inherited
  str:=GetParsValue(m_pars, 'Type');
  if isvalue(str) then
    AlgTypeRG.itemindex:= strtoint(str)
  else
    AlgTypeRG.itemindex:= 0;

  p:=dtFE.OnChange;
  dtFE.OnChange:=nil;
  dtFE.Text := GetParsValue(m_pars, 'dT');
  dtFE.OnChange:=p;

  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);
  //OutChannelName.text:=ChannelCB.text+'_PeakFct';
  OutChannelName.text:=GetParsValue(m_pars, 'OutChannel');
end;

end.
