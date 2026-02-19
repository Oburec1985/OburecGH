unit uGrmsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises,uGrmsAlg,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg,
  uRcCtrls, Spin, DCL_MYOWN;

type
  TGRmsFrame = class(TBaseAlgFrame)
    Label2: TLabel;
    OutChannelName: TEdit;
    TahoLabel: TLabel;
    UseTahoCB: TCheckBox;
    SpmPan: TPanel;
    FFTCountLabel: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    FFTdX: TFloatEdit;
    BandF1Edit: TFloatEdit;
    BandF2Edit: TFloatEdit;
    FFTCountEdit: TIntEdit;
    FFTCountSpinBtn: TSpinButton;
    PercentCB: TCheckBox;
    ChannelCB: TRcComboBox;
    ChannelLabel: TLabel;
    TahoCB: TRcComboBox;
    procedure FFTCountSpinBtnDownClick(Sender: TObject);
    procedure FFTCountSpinBtnUpClick(Sender: TObject);
    procedure FFTCountEditChange(Sender: TObject);
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

const
  c_algClass  = 'cGrmsAlg';

var
  GRmsFrame: TGRmsFrame;

implementation

{$R *.dfm}

procedure TGRmsFrame.FFTCountEditChange(Sender: TObject);
begin
  updateOptsStr;
end;

procedure TGRmsFrame.FFTCountSpinBtnDownClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum>2 then
    FFTCountEdit.IntNum:=round(FFTCountEdit.IntNum/2);
end;

procedure TGRmsFrame.FFTCountSpinBtnUpClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum>2 then
    FFTCountEdit.IntNum:=FFTCountEdit.IntNum*2;
end;


function TGRmsFrame.getProperties: string;
begin
  //inherited;
  if FFTDx.text<>'' then
    addParam(m_pars, 'dX', FFTDx.text);
  if BandF1Edit.text<>'' then
    addParam(m_pars, 'Band1', BandF1Edit.text);
  if BandF2Edit.text<>'' then
    addParam(m_pars, 'Band2', BandF2Edit.text);
  if FFTCountEdit.text<>'' then
    addParam(m_pars, 'FFTCount', FFTCountEdit.text);

  addParam(m_pars, 'UseTaho', booltostr(UseTahoCB.Checked));
  addParam(m_pars, 'Percent', booltostr(PercentCB.Checked));

  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
    OutChannelName.text:=ChannelCB.text+'_Grms';
  end;
  if TahoCB.text<>'' then
  begin
    addParam(m_pars, 'Taho', TahoCB.text);
  end
  else
  begin
    addParam(m_pars, 'Taho', '');
  end;
  result:=ParsToStr(m_pars);
end;

procedure TGRmsFrame.setProperties(s: string);
var
  p:tnotifyevent;
  str:string;
begin
  inherited;
  // m_pars обновлен в inherited
  p:=FFTCountEdit.OnChange;
  FFTCountEdit.OnChange:=nil;
  FFTCountEdit.Text := GetParsValue(m_pars, 'FFTCount');
  FFTCountEdit.OnChange:=p;

  p:=FFTdx.OnChange;
  FFTdx.OnChange:=nil;
  FFTdx.Text := GetParsValue(m_pars, 'dX');
  FFTdx.OnChange:=p;

  p:=FFTdx.OnChange;
  FFTdx.OnChange:=nil;
  FFTdx.Text := GetParsValue(m_pars, 'dX');
  FFTdx.OnChange:=p;

  p:=BandF1Edit.OnChange;
  BandF1Edit.OnChange:=nil;
  BandF1Edit.Text := GetParsValue(m_pars, 'Band1');
  BandF1Edit.OnChange:=p;

  p:=BandF2Edit.OnChange;
  BandF2Edit.OnChange:=nil;
  BandF2Edit.Text := GetParsValue(m_pars, 'Band2');
  BandF2Edit.OnChange:=p;

  p:=PercentCB.OnClick;
  PercentCB.OnClick:=nil;
  str:=GetParsValue(m_pars, 'Percent');
  if str<>'' then
    PercentCB.checked := strtobool(str);
  PercentCB.OnClick:=p;

  p:=UseTahoCB.OnClick;
  UseTahoCB.OnClick:=nil;
  str:=GetParsValue(m_pars, 'UseTaho');
  if str<>'' then
    UseTahoCB.checked := strtobool(str);
  UseTahoCB.OnClick:=p;

  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);
  setcomboboxitem(GetParsValue(m_pars, 'Taho'), TahoCB);
  if channelcb.ItemIndex>0 then
  begin
    OutChannelName.text:=ChannelCB.text+'_Grms';
  end;
end;

function TGRmsFrame.algClass: string;
begin
  result:=c_algClass;
end;

procedure TGRmsFrame.clearframeparams;
begin
  inherited;

end;

constructor TGRmsFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := 'СКЗ в полосе';
end;

destructor TGRmsFrame.destroy;
begin
  inherited;
end;

function TGRmsFrame.CreateAlg: cBaseAlg;
begin
  result := cGRmsAlg.create;
end;

procedure TGRmsFrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
  TahoCB.updateTagsList;
end;

end.
