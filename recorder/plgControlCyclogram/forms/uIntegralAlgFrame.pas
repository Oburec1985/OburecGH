unit uIntegralAlgFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, uCounterAlg,
  uRcCtrls, DCL_MYOWN, Spin;

type
  TIntegralAlgFrame = class(TBaseAlgFrame)
    LoThresholdSE: TFloatSpinEdit;
    ThresholdLabel1: TLabel;
    ChannelCB: TRcComboBox;
    ChannelLabel: TLabel;
    Label1: TLabel;
    OutChannelName: TEdit;
    FltRG: TRadioGroup;
    FltCountLabel: TLabel;
    FltCountEdit: TIntEdit;
    ShiftLabel: TLabel;
    ShiftIE: TIntEdit;
    SpinBtn: TSpinButton;
    procedure LoThresholdSEChange(Sender: TObject);
    procedure HiThresholdSEChange(Sender: TObject);
    procedure ChannelCBChange(Sender: TObject);
    procedure FltRGClick(Sender: TObject);
    procedure SpinBtnDownClick(Sender: TObject);
    procedure SpinBtnUpClick(Sender: TObject);
  protected
    function getProperties: string; override;
    procedure setProperties(s: string); override;
    function algClass:string;override;
    procedure clearframeparams; override;
    procedure RoundFFTCount;
  public
    procedure doShow; override;
    constructor create(aOwner: tcomponent); override;
    destructor destroy; override;
    function CreateAlg: cBaseAlg; override;
  end;



var
  IntegralAlgFrame: TIntegralAlgFrame;

implementation

{$R *.dfm}
{ TBaseAlgFrame1 }

function TIntegralAlgFrame.algClass: string;
begin
  result:='cIntegralAlg';
end;

procedure TIntegralAlgFrame.ChannelCBChange(Sender: TObject);
begin
  CheckCBItemInd(tcombobox(sender));
  updateOptsStr;
end;

procedure TIntegralAlgFrame.clearframeparams;
begin
  LoThresholdSE.text:='0';
  ChannelCB.text:='';
  OutChannelName.text:='';
end;

constructor TIntegralAlgFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := '��������';
end;

destructor TIntegralAlgFrame.destroy;
begin
  inherited;
end;

function TIntegralAlgFrame.CreateAlg: cBaseAlg;
begin
  result := cCounterAlg.create;
end;

procedure TIntegralAlgFrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
  if fltrg.Items.Count=0 then
  begin
    fltRg.Items.Add('��� ����������');
    fltRg.Items.Add('���������� �������');
    fltRg.Items.Add('FFT ����������');
  end;
  FltRGClick(nil);
end;

procedure TIntegralAlgFrame.FltRGClick(Sender: TObject);
begin
  inherited;
  case FltRG.ItemIndex of
    0:
    begin
      spinbtn.Visible:=false;
      fltcountlabel.Caption:='����� �����';
      ShiftLabel.Visible:=false;
      ShiftIE.Visible:=false;
    end;
    1:
    begin
      spinbtn.Visible:=false;
      fltcountlabel.Visible:=true;
      fltcountlabel.Caption:='����� �����';
      ShiftLabel.Visible:=false;
      ShiftIE.Visible:=false;
    end;
    2:
    begin
      RoundFFTCount;
      spinbtn.Visible:=true;
      fltcountlabel.Caption:='����� ����� FFT';
      ShiftLabel.Visible:=true;
      ShiftIE.Visible:=true;
    end;
  end;
end;

function TIntegralAlgFrame.getProperties: string;
begin
  //inherited;
  if LoThresholdSE.text<>'' then
    addParam(m_pars, 'Lo', replaceChar(LoThresholdSE.text,',','.'));

  addParam(m_pars, 'FltType', inttostr(FltRG.itemindex));
  if FltRG.itemindex=2 then
  begin
    addParam(m_pars, 'FltShift', inttostr(ShiftIE.IntNum));
  end;
  addParam(m_pars, 'FltCount', inttostr(FltCountEdit.IntNum));

  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
    OutChannelName.text:=ChannelCB.text+'_Intl';
  end;
  result:=ParsToStr(m_pars);
end;

procedure TIntegralAlgFrame.setProperties(s: string);
var
  p:tnotifyevent;
begin
  inherited;
  // m_pars �������� � inherited
  p:=LoThresholdSE.OnChange;
  LoThresholdSE.OnChange:=nil;
  LoThresholdSE.Text := GetParsValue(m_pars, 'Lo');

  fltrg.itemindex := strtoint(GetParsValue(m_pars, 'FltType'));
  FltCountEdit.IntNum := strtoint(GetParsValue(m_pars, 'FltCount'));
  if fltrg.itemindex=2 then
  begin
    shiftie.IntNum:=strtoint(GetParsValue(m_pars, 'FltShift'));
  end;

  LoThresholdSE.OnChange:=p;

  p:=LoThresholdSE.OnChange;
  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);
  OutChannelName.text:=GetParsValue(m_pars, 'OutChannel');;
end;

procedure TIntegralAlgFrame.SpinBtnDownClick(Sender: TObject);
begin
  FltCountEdit.IntNum:=FltCountEdit.IntNum shr 1;
  ShiftIE.IntNum:=FltCountEdit.IntNum;
end;

procedure TIntegralAlgFrame.SpinBtnUpClick(Sender: TObject);
begin
  FltCountEdit.IntNum:=FltCountEdit.IntNum shl 1;
  ShiftIE.IntNum:=FltCountEdit.IntNum;
end;

procedure TIntegralAlgFrame.HiThresholdSEChange(Sender: TObject);
begin
  updateOptsStr;
end;

procedure TIntegralAlgFrame.LoThresholdSEChange(Sender: TObject);
begin
  updateOptsStr;
end;

procedure TIntegralAlgFrame.RoundFFTCount;
var
  i:integer;
begin
  i:=2;
  while fltcountedit.IntNum>i do
    i:=i shl 1;
  fltcountedit.IntNum:=i;
end;

end.
