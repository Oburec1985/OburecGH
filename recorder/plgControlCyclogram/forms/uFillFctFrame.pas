unit uFillFctFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, uCounterAlg,
  uRcCtrls;

type
  TFillFctFrame = class(TBaseAlgFrame)
    ThresholdLabel1: TLabel;
    ChannelLabel: TLabel;
    Label1: TLabel;
    ThresholdSE: TFloatSpinEdit;
    ChannelCB: TRcComboBox;
    OutChannelName: TEdit;
    FsLabel: TLabel;
    FsSE: TFloatSpinEdit;
    procedure ChannelCBChange(Sender: TObject);
    procedure ThresholdSEChange(Sender: TObject);
    procedure FsSEChange(Sender: TObject);
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
  FillFctFrame: TFillFctFrame;

implementation

{$R *.dfm}


function TFillFctFrame.algClass: string;
begin
  result:='cFillingFactorAlg';
end;


procedure TFillFctFrame.ChannelCBChange(Sender: TObject);
begin
  CheckCBItemInd(tcombobox(sender));
  updateOptsStr;
end;

procedure TFillFctFrame.clearframeparams;
begin
  ThresholdSE.text:='0';
  FsSE.text:='0';
  ChannelCB.text:='';
  OutChannelName.text:='';
end;

constructor TFillFctFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := 'Скважность';
end;

destructor TFillFctFrame.destroy;
begin
  inherited;
end;

function TFillFctFrame.CreateAlg: cBaseAlg;
begin
  result := cCounterAlg.create;
end;

procedure TFillFctFrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
end;

procedure TFillFctFrame.FsSEChange(Sender: TObject);
begin
  updateOptsStr;
end;

function TFillFctFrame.getProperties: string;
begin
  //inherited;
  if ThresholdSE.text<>'' then
    addParam(m_pars, 'Lvl', replaceChar(ThresholdSE.text,',','.'));
  if ThresholdSE.text<>'' then
    addParam(m_pars, 'Fs', replaceChar(FsSe.text,',','.'));


  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
    OutChannelName.text:=ChannelCB.text+'_FillFct';
  end;
  result:=ParsToStr(m_pars);
end;

procedure TFillFctFrame.setProperties(s: string);
var
  p:tnotifyevent;
begin
  inherited;
  // m_pars обновлен в inherited
  p:=ThresholdSE.OnChange;
  ThresholdSE.OnChange:=nil;
  ThresholdSE.Text := GetParsValue(m_pars, 'Lvl');
  ThresholdSE.OnChange:=p;

  p:=FsSe.OnChange;
  FsSe.OnChange:=nil;
  FsSe.Text := GetParsValue(m_pars, 'Fs');
  FsSe.OnChange:=p;

  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);

  if channelcb.ItemIndex>0 then
  begin
    OutChannelName.text:=ChannelCB.text+'_FillFct';
  end;
end;

procedure TFillFctFrame.ThresholdSEChange(Sender: TObject);
begin
  updateOptsStr;

end;

end.
