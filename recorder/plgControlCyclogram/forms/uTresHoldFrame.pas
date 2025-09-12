unit uTresHoldFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, uCounterAlg, uQueue,
  uRcCtrls;

type
  TTresHoldFrame = class(TBaseAlgFrame)
    ChannelCB: TRcComboBox;
    ChannelLabel: TLabel;
    OutLabel: TLabel;
    OutChannelName: TEdit;
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
  result := cCounterAlg.create;
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

  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
    OutChannelName.text:=ChannelCB.text+'_Hold';
  end;

  result:=ParsToStr(m_pars);
end;

procedure TTresHoldFrame.setProperties(s: string);
var
  p:tnotifyevent;
  str:string;
begin
  inherited;
  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);
  if channelcb.ItemIndex>0 then
  begin
    OutChannelName.text:=ChannelCB.text+'_Hold';
  end;
end;


end.
