unit uExcessFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises, mathfunction, tags,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, uCounterAlg,
  uExcessAlg,
  uRcCtrls,
  DCL_MYOWN, uTahoAlg, Spin, ComCtrls, uBtnListView, uRcFunc;

type
  TExcessFrame = class(TBaseAlgFrame)
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
  ExcessFrame: TExcessFrame;

implementation

{$R *.dfm}

{ TBaseAlgFrame1 }

function TExcessFrame.algClass: string;
begin
  result:='cExcessAlg';
end;

procedure TExcessFrame.clearframeparams;
begin
  AlgTypeRG.itemindex:=0;
  dtFE.text:='0';
  pCountEdit.IntNum:=0;
  ChannelCB.text:='';
  OutChannelName.text:='';
end;

constructor TExcessFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := '�������';
end;

function TExcessFrame.CreateAlg: cBaseAlg;
begin
  result := cExcessAlg.create;
end;

destructor TExcessFrame.destroy;
begin

  inherited;
end;

procedure TExcessFrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
end;

function TExcessFrame.getProperties: string;
begin
  addParam(m_pars, 'Type', inttostr(AlgTypeRG.ItemIndex));
  if dtFE.text<>'' then
    addParam(m_pars, 'dT', replaceChar(dtFE.text,',','.'));
  addParam(m_pars, 'pCount', pCountEdit.text);
  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
    OutChannelName.text:=ChannelCB.text+'_Excess';
  end;
  result:=ParsToStr(m_pars);
end;

procedure TExcessFrame.init;
begin

end;

procedure TExcessFrame.setProperties(s: string);
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

  OutChannelName.text:=ChannelCB.text+'_Excess';
end;

end.
