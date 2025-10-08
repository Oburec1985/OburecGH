unit uCounterAlgFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, uCounterAlg,
  uRcCtrls;

type
  TCounterAlgFrame = class(TBaseAlgFrame)
    LoThresholdSE: TFloatSpinEdit;
    ThresholdLabel1: TLabel;
    ThresholdLabel2: TLabel;
    HiThresholdSE: TFloatSpinEdit;
    ChannelCB: TRcComboBox;
    ChannelLabel: TLabel;
    OutLabel: TLabel;
    OutChannelName: TEdit;
    MinThresholdSE: TFloatSpinEdit;
    LabelMinThreshold: TLabel;
    TrigCB: TRcComboBox;
    TrigChanLabel: TLabel;
    NullTagCB: TRcComboBox;
    ZeroChanLabel: TLabel;
    SaveOnStartCb: TCheckBox;
    ShiftChanLabel: TLabel;
    ShiftTagCB: TRcComboBox;
    procedure LoThresholdSEChange(Sender: TObject);
    procedure HiThresholdSEChange(Sender: TObject);
    procedure ChannelCBChange(Sender: TObject);
  protected
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
  CounterAlgFrame: TCounterAlgFrame;

implementation

{$R *.dfm}
{ TBaseAlgFrame1 }

function TCounterAlgFrame.algClass: string;
begin
  result:='cCounterAlg';
end;

procedure TCounterAlgFrame.ChannelCBChange(Sender: TObject);
begin
  CheckCBItemInd(tcombobox(sender));
  updateOptsStr;
end;

procedure TCounterAlgFrame.clearframeparams;
begin
  LoThresholdSE.text:='0';
  HiThresholdSE.text:='0';
  ChannelCB.text:='';
  OutChannelName.text:='';
end;

constructor TCounterAlgFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := '—четчик';
end;

destructor TCounterAlgFrame.destroy;
begin
  inherited;
end;

function TCounterAlgFrame.CreateAlg: cBaseAlg;
begin
  result := cCounterAlg.create;
end;

procedure TCounterAlgFrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
  TrigCB.updateTagsList;
  NullTagCB.updateTagsList;
  ShiftTagCB.updateTagsList;
end;

function TCounterAlgFrame.getProperties: string;
var
  b, err: Boolean;
begin
  //inherited;
  if HiThresholdSE.text<>'' then
    addParam(m_pars, 'Hi', replaceChar(HiThresholdSE.text,',','.'));
  if LoThresholdSE.text<>'' then
    addParam(m_pars, 'Lo', replaceChar(LoThresholdSE.text,',','.'));

  if MinThresholdSE.text<>'' then
    addParam(m_pars, 'MinThreshold', replaceChar(MinThresholdSE.text,',','.'));

  b := GetMultiSelectComponentBool(SaveOnStartCb, err);
  if not err then
  begin
    addParam(m_pars, 'SaveVal', booltostr(b));
  end;

  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
    OutChannelName.text:=ChannelCB.text+'_cnt';
  end;
  // канал разрешени€ счета
  if TrigCB.text<>'' then
  begin
    addParam(m_pars, 'TrigTag', TrigCB.text);
  end;
  // канал сброса значени€
  if NullTagCB.text<>'' then
  begin
    addParam(m_pars, 'NullTag', NullTagCB.text);
  end;
  // канал смещени€
  if ShiftTagCB.text<>'' then
  begin
    addParam(m_pars, 'ShiftTag', ShiftTagCB.text);
  end;
  result:=ParsToStr(m_pars);
end;

procedure TCounterAlgFrame.setProperties(s: string);
var
  p:tnotifyevent;
  str:string;
begin
  inherited;
  // m_pars обновлен в inherited
  p:=LoThresholdSE.OnChange;
  LoThresholdSE.OnChange:=nil;
  LoThresholdSE.Text := GetParsValue(m_pars, 'Lo');
  LoThresholdSE.OnChange:=p;

  p:=HiThresholdSE.OnChange;
  HiThresholdSE.OnChange:=nil;
  HiThresholdSE.Text := GetParsValue(m_pars, 'Hi');
  HiThresholdSE.OnChange:=p;

  str := GetParsValue(m_pars, 'SaveVal');
  if checkstr(str) then
  begin
    SetMultiSelectComponentBool(SaveOnStartCb, StrToBool(str));
  end;

  p:=MinThresholdSE.OnChange;
  MinThresholdSE.OnChange:=nil;
  MinThresholdSE.Text := GetParsValue(m_pars, 'MinThreshold');
  MinThresholdSE.OnChange:=p;

  setcomboboxitem(GetParsValue(m_pars, 'TrigTag'), TrigCB);
  setcomboboxitem(GetParsValue(m_pars, 'NullTag'), NullTagCB);
  setcomboboxitem(GetParsValue(m_pars, 'ShiftTag'), ShiftTagCB);
  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);
  if channelcb.ItemIndex>0 then
  begin
    OutChannelName.text:=ChannelCB.text+'_cnt';
  end;
end;

procedure TCounterAlgFrame.HiThresholdSEChange(Sender: TObject);
begin
  updateOptsStr;
end;

procedure TCounterAlgFrame.LoThresholdSEChange(Sender: TObject);
begin
  updateOptsStr;
end;



end.
