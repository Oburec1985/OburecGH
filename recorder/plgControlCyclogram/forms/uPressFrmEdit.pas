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
    procedure BandSGKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BandSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    m_init,
    m_manualB:boolean;
    m_pf:TPressCamFrm;
    m_row, m_col:integer;
  private
    procedure updateBands;
    procedure updateFFTnum;
    function getframe(i:integer):TPressFrmFrame;
  public
    procedure EditPressFrm(Pf:TPressCamFrm);
    constructor create(c:tcomponent);override;
  end;

var
  PressFrmEdit: TPressFrmEdit;

implementation

{$R *.dfm}

{ TPressFrmEdit }
procedure TPressFrmEdit.BandSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  str:string;
  fr:TPressFrmFrame;
begin
  if key=VK_RETURN then
  begin
    // начали вносить ручные правки
    m_manualB:=true;
    str:=BandSG.Cells[m_col, m_row];
    if not isValue(str) then
    begin
      fr:=getframe(m_row-1);
      if m_col=0 then
        BandSG.Cells[m_col, m_row]:=floattostr(fr.m_f1)
      else
        BandSG.Cells[m_col, m_row]:=floattostr(fr.m_f2)
    end;
  end;
end;

function TPressFrmEdit.getframe(i: integer): TPressFrmFrame;
begin
  result:=TPressFrmFrame(m_pf.BGraphFrames[i]);
end;

procedure TPressFrmEdit.BandSGSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  m_row:=arow;
  m_col:=acol;
end;

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
  m_manualB:=m_pf.m_manualBand;
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
    updateBands;
    m_pf.SensorName:=TagnameCB.text;
    m_pf.m_Spm.Properties:='Channel='+TagnameCB.text+','+'FFTCount='+FFTCountEdit.text+',';
    m_pf.BarGraphGB.Caption:=str;
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

procedure TPressFrmEdit.updateBands;
var
  I: Integer;
  fr:TPressFrmFrame;
begin
  if m_manualB then
  begin
    m_pf.m_manualBand:=true;
    for I := 0 to BCountIE.IntNum - 1 do
    begin
      fr:=getframe(i);
      fr.m_f1:=strtofloatext(BandSG.Cells[0,1+i]);
      fr.m_f2:=strtofloatext(BandSG.Cells[1,1+i]);
    end;
    m_manualB:=false;
  end;
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
