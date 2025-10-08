unit uPhaseFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises,uGrmsAlg,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, uPhaseAlg, tags, uRCFunc, uSpm,
  uRcCtrls, Spin, DCL_MYOWN;

type
  TPhaseFrame = class(TBaseAlgFrame)
    SpmPan: TPanel;
    FFTCountLabel: TLabel;
    FFTCountEdit: TIntEdit;
    FFTCountSpinBtn: TSpinButton;
    ChannelCB1: TRcComboBox;
    ChannelLabel1: TLabel;
    Label2: TLabel;
    OutChannelName: TEdit;
    ChannelLabel2: TLabel;
    ChannelCB2: TRcComboBox;
    dFEdit: TEdit;
    dFLabel: TLabel;
    procedure FFTCountEditChange(Sender: TObject);
    procedure FFTCountSpinBtnDownClick(Sender: TObject);
    procedure FFTCountSpinBtnUpClick(Sender: TObject);
    procedure ChannelCB1DragDrop(Sender, Source: TObject; X, Y: Integer);
  protected
    m_lastOutTag:string;
  protected
    function getProperties: string; override;
    procedure setProperties(s: string); override;
    function algClass:string;override;
    procedure clearframeparams; override;
    // обновляем дискретизацию спектра и др параметры
    procedure updateParams;
  public
    procedure doShow; override;
    constructor create(aOwner: tcomponent); override;
    destructor destroy; override;
    function CreateAlg: cBaseAlg; override;
  end;

var
  PhaseFrame: TPhaseFrame;

implementation

const
  c_algClass  = 'cPhaseAlg';

{$R *.dfm}


procedure TPhaseFrame.FFTCountEditChange(Sender: TObject);
begin
  updateOptsStr;
end;

procedure TPhaseFrame.FFTCountSpinBtnDownClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum>2 then
    FFTCountEdit.IntNum:=round(FFTCountEdit.IntNum/2);
end;

procedure TPhaseFrame.FFTCountSpinBtnUpClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum>2 then
    FFTCountEdit.IntNum:=FFTCountEdit.IntNum*2;
end;


function TPhaseFrame.getProperties: string;
var
  str:string;
  b:boolean;
  t:itag;
begin
  if FFTCountEdit.text<>'' then
    addParam(m_pars, 'FFTCount', FFTCountEdit.text);

  if ChannelCB2.text<>'' then
  begin
    addParam(m_pars, 'Channel2', ChannelCB2.text);
  end;

  if ChannelCB1.text<>'' then
  begin
    addParam(m_pars, 'Channel1', ChannelCB1.text);
    str:=ChannelCB1.text+'_Ph';
    b:=true;
    while b do
    begin
      t:=getTagByName(str);
      if (t=nil) or (str=m_lastOutTag)  then
        b:=false
      else
        str:=ModName(str, false);
    end;
    OutChannelName.text:=str;
    m_lastOutTag:=str;
    addParam(m_pars, 'OutChannel', str);
  end;
  result:=ParsToStr(m_pars);
end;

procedure TPhaseFrame.setProperties(s: string);
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

  setcomboboxitem(GetParsValue(m_pars, 'Channel2'), ChannelCB2);
  setcomboboxitem(GetParsValue(m_pars, 'Channel1'), ChannelCB1);
  updateParams;
  if channelcb1.ItemIndex>0 then
  begin
    str:=GetParsValue(m_pars, 'OutChannel');
    if str='' then
    begin
      OutChannelName.text:=ChannelCB1.text+'_Ph';
      m_lastOutTag:='';
    end
    else
    begin
      OutChannelName.text:=str;
      m_lastOutTag:=str;
    end;
    updateParams;
  end;
end;

procedure TPhaseFrame.updateParams;
var
  s:cSpm;
begin
  s:=cphasealg(m_a).m_spm;
  if s<>nil then
    dFEdit.text:=floattostr(s.dX);
end;

function TPhaseFrame.algClass: string;
begin
  result:=c_algClass;
end;

procedure TPhaseFrame.ChannelCB1DragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  inherited;
  updateOptsStr;
end;

procedure TPhaseFrame.clearframeparams;
begin
  inherited;

end;

constructor TPhaseFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := 'Фаза';
end;

destructor TPhaseFrame.destroy;
begin
  inherited;
end;

function TPhaseFrame.CreateAlg: cBaseAlg;
begin
  result := cPhaseAlg.create;
end;

procedure TPhaseFrame.doShow;
begin
  inherited;
  ChannelCB1.updateTagsList;
  ChannelCB2.updateTagsList;
end;

end.
