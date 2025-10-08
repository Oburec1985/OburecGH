unit uTresHoldFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises, uThreshHolderAlg,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, uQueue,
  uRcCtrls, DCL_MYOWN;

type
  TTresHoldFrame = class(TBaseAlgFrame)
    ChannelCB: TRcComboBox;
    ChannelLabel: TLabel;
    OutLabel: TLabel;
    OutChannelName: TEdit;
    HistFe: TFloatEdit;
    Label1: TLabel;
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
  TresHoldFrame: TTresHoldFrame;

implementation

{$R *.dfm}
{ TBaseAlgFrame1 }

function TTresHoldFrame.algClass: string;
begin
  result:='cThresHoldAlg';
end;

procedure TTresHoldFrame.ChannelCBChange(Sender: TObject);
begin
  CheckCBItemInd(tcombobox(sender));
  updateOptsStr;
end;

procedure TTresHoldFrame.clearframeparams;
begin
  ChannelCB.text:='';
  OutChannelName.text:='';
end;

constructor TTresHoldFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := 'Макс_за_время';
end;

destructor TTresHoldFrame.destroy;
begin
  inherited;
end;

function TTresHoldFrame.CreateAlg: cBaseAlg;
begin
  result := cThresHoldAlg.create;
end;

procedure TTresHoldFrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
end;

function TTresHoldFrame.getProperties: string;
var
  b, err: Boolean;
begin
  //inherited;
  addParam(m_pars, 'Hist', HistFe.text);
  OutChannelName.text:=ChannelCB.text+'_Hld';
  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
    OutChannelName.text:=ChannelCB.text+'_Hld';
  end;

  result:=ParsToStr(m_pars);
end;

procedure TTresHoldFrame.setProperties(s: string);
var
  p:tnotifyevent;
  str:string;
begin
  inherited;
  str:=GetParsValue(m_pars, 'Hist');
  if CheckStr(str) then
  begin
    HistFe.FloatNum:=strtoFloatExt(str);
  end;
  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);
  if channelcb.ItemIndex>0 then
  begin
    OutChannelName.text:=ChannelCB.text+'_Hld';
  end;
end;


end.
