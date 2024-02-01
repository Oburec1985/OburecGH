unit uPressFrmEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, uStringGridExt, DCL_MYOWN, Spin, StdCtrls, uRcCtrls,
  uTagsListFrame, Buttons, ExtCtrls, uComponentservises,
  Tags, uCommonMath, uRCFunc, uPressFrm, uPressFrmFrame;

type
  TPressFrmEdit = class(TForm)
    TagsListFrame1: TTagsListFrame;
    alClientGB: TGroupBox;
    TagnameCB: TRcComboBox;
    TagLabel: TLabel;
    FFTCountEdit: TIntEdit;
    FFTCountSpinBtn: TSpinButton;
    FFTCountLabel: TLabel;
    dFLabel: TLabel;
    FFTdX: TFloatEdit;
    BCountSB: TSpinButton;
    BCountIE: TIntEdit;
    BCountLabel: TLabel;
    BandSG: TStringGridExt;
    Panel1: TPanel;
    UpdateAlgBtn: TSpeedButton;
    procedure FFTCountSpinBtnDownClick(Sender: TObject);
    procedure FFTCountSpinBtnUpClick(Sender: TObject);
    procedure UpdateAlgBtnClick(Sender: TObject);
    procedure BCountSBDownClick(Sender: TObject);
    procedure BCountSBUpClick(Sender: TObject);
  private
    m_init:boolean;
    m_pf:TPressCamFrm;
  private
    procedure updateFFTnum;
  public
    procedure EditPressFrm(Pf:TPressCamFrm);
    constructor create(c:tcomponent);override;
  end;

var
  PressFrmEdit: TPressFrmEdit;

implementation

{$R *.dfm}

{ TPressFrmEdit }
procedure TPressFrmEdit.BCountSBDownClick(Sender: TObject);
begin
  BCountIE.IntNum:=BCountIE.IntNum-1;
end;

procedure TPressFrmEdit.BCountSBUpClick(Sender: TObject);
begin
  BCountIE.IntNum:=BCountIE.IntNum+1;
end;

constructor TPressFrmEdit.create(c: tcomponent);
begin
  inherited;
  m_init:=false;
  BandSG.ColCount:=2;
  BandSG.Cells[0,0]:='F1';
  BandSG.Cells[1,0]:='F2';
end;

procedure TPressFrmEdit.EditPressFrm(Pf: TPressCamFrm);
var
  p: TNotifyEvent;
  props:string;
  str: string;
  i: Integer;
  t: itag;
begin
  m_pf:=pf;
  if not m_init then
  begin
    m_init:=true;
    TagsListFrame1.ShowVectortags:=true;
    TagsListFrame1.ShowChannels;
    TagnameCB.updateTagsList;
  end;
  props:=g_PressCamFactory.m_spmCfg.str;
  str := GetParam(props, 'FFTCount');
  if CheckStr(str) then
  begin
    p := FFTCountEdit.OnChange;
    FFTCountEdit.OnChange := nil;
    FFTCountEdit.Text:=str;
    FFTCountEdit.OnChange := p;
  end;
  str := m_pf.SensorName;
  t:=getTagByName(str);
  BCountIE.IntNum:=Pf.BandCount;
  BandSG.RowCount:=Pf.BandCount+1;
  if t<>nil then
  begin
    TagnameCB.SetTagName(str);
    for I := 0 to Pf.BandCount - 1 do
    begin
      BandSG.Cells[0,i+1]:=floattostr(TPressFrmFrame(pf.BGraphFrames[i]).m_f1);
      BandSG.Cells[1,i+1]:=floattostr(TPressFrmFrame(pf.BGraphFrames[i]).m_f2);
    end;
    sgchange(BandSG);
  end;
  if ShowModal=mrok then
  begin
    m_pf.SensorName:=TagnameCB.text;
    m_pf.m_Spm.Properties:='Channel='+TagnameCB.text+','+'FFTCount='+FFTCountEdit.text+',';
  end;
end;

procedure TPressFrmEdit.FFTCountSpinBtnDownClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum > 2 then
    FFTCountEdit.IntNum := round(FFTCountEdit.IntNum / 2);
  updateFFTnum;
end;

procedure TPressFrmEdit.FFTCountSpinBtnUpClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum > 2 then
    FFTCountEdit.IntNum := FFTCountEdit.IntNum * 2;
  updateFFTnum;
end;

procedure TPressFrmEdit.UpdateAlgBtnClick(Sender: TObject);
begin
  ModalResult:=mrok;
end;

procedure TPressFrmEdit.updateFFTnum;
var
  t:itag;
begin
  t:=TagnameCB.gettag;
  if t<>nil then
    fftdx.FloatNum := FFTCountEdit.IntNum/t.GetFreq;
end;

end.
