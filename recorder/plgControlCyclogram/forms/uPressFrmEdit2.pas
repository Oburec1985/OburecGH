unit uPressFrmEdit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, uStringGridExt, DCL_MYOWN, Spin, StdCtrls, uRcCtrls,
  uTagsListFrame, Buttons, ExtCtrls, uComponentservises, ComCtrls,
  Tags, uCommonMath, uRCFunc, uPressFrm2, uPressFrmFrame2, uspm, uHardwareMath;

type
  TPressFrmEdit2 = class(TForm)
    TagsListFrame1: TTagsListFrame;
    alClientGB: TGroupBox;
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
    HHFE: TFloatEdit;
    HHLabel: TLabel;
    HLabel: TLabel;
    HFE: TFloatEdit;
    TagsLB: TListBox;
    BNumLabel: TLabel;
    BNumIE: TIntEdit;
    BNumSB: TSpinButton;
    Label1: TLabel;
    RefFE: TFloatEdit;
    procedure FFTCountSpinBtnDownClick(Sender: TObject);
    procedure FFTCountSpinBtnUpClick(Sender: TObject);
    procedure UpdateAlgBtnClick(Sender: TObject);
    procedure BCountSBDownClick(Sender: TObject);
    procedure BCountSBUpClick(Sender: TObject);
    procedure BandSGKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BandSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure TagsLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TagsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TagsLBKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BandSGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure BNumSBDownClick(Sender: TObject);
    procedure BNumSBUpClick(Sender: TObject);
    procedure TagsLBClick(Sender: TObject);
  private
    m_init,
    m_manualB:boolean;
    m_pf:TPressFrm2;
    m_row, m_col:integer;
  private
    procedure updateBands;
    procedure updateFFTnum;
  public
    procedure EditPressFrm(Pf:TPressFrm2);
    constructor create(c:tcomponent);override;
  end;

var
  PressFrmEdit2: TPressFrmEdit2;

implementation

{$R *.dfm}

{ TPressFrmEdit }
procedure TPressFrmEdit2.BandSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  color:tcolor;
  sg:tstringgrid;
begin
  sg:=BandSG;
  Color := sg.Canvas.Brush.Color;
  if Arow-1 = BNumIE.IntNum then
  begin
    sg.Canvas.Brush.Color := CLgREEN;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
  end;
end;

procedure TPressFrmEdit2.BandSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  str:string;
begin
  if key=VK_RETURN then
  begin
    // начали вносить ручные правки
    m_manualB:=true;
    str:=BandSG.Cells[m_col, m_row];
    if not isValue(str) then
    begin
      if m_col=0 then
        BandSG.Cells[m_col, m_row]:=floattostr(g_PressCamFactory2.m_bands[m_row-1].f1)
      else
      begin
        BandSG.Cells[m_col, m_row]:=floattostr(g_PressCamFactory2.m_bands[m_row-1].f2);
      end;
    end;
  end;
end;

procedure TPressFrmEdit2.TagsLBClick(Sender: TObject);
var
  I, sel: Integer;
begin
  sel:=-1;
  for I := 0 to tagsLB.Count - 1 do
  begin
    if tagsLB.Selected[i] then
    begin
      sel:=i;
      break;
    end;
  end;
  if sel<>-1 then
    RefFE.FloatNum:=g_PressCamFactory2.GetRef(sel);
end;

procedure TPressFrmEdit2.TagsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  I: Integer;
  t:itag;
  li:tlistitem;
begin
  for I := 0 to tagslistframe1.tagsLV.SelCount - 1 do
  begin
    if i=0 then
    begin
      li:=tagslistframe1.tagsLV.Selected;
    end
    else
    begin
      li:=tagslistframe1.tagsLV.GetNextItem(li,sdAll,[isSelected]);
    end;
    t:=itag(li.data);
    tagslb.AddItem(t.GetName, nil);
  end;
end;

procedure TPressFrmEdit2.TagsLBDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if source=tagslistframe1.tagslv then
  begin
    Accept:=true;
  end;
end;

procedure TPressFrmEdit2.TagsLBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_DELETE then
    TagsLB.DeleteSelected;
end;

procedure TPressFrmEdit2.BandSGSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  m_row:=arow;
  m_col:=acol;
end;

procedure TPressFrmEdit2.BCountSBDownClick(Sender: TObject);
begin
  BCountIE.IntNum:=BCountIE.IntNum-1;
end;

procedure TPressFrmEdit2.BCountSBUpClick(Sender: TObject);
begin

  BCountIE.IntNum:=BCountIE.IntNum+1;
end;

procedure TPressFrmEdit2.BNumSBDownClick(Sender: TObject);
begin
  if BNumIE.IntNum>0 then
  begin
    BNumIE.IntNum:=BNumIE.IntNum-1;
    BandSG.Invalidate;
  end;
end;

procedure TPressFrmEdit2.BNumSBUpClick(Sender: TObject);
begin
  if BNumIE.IntNum<BCountIE.IntNum-1 then
  begin
    BNumIE.IntNum:=BNumIE.IntNum+1;
    BandSG.Invalidate;
  end;
end;

constructor TPressFrmEdit2.create(c: tcomponent);
begin
  inherited;
  m_init:=false;
  BandSG.ColCount:=2;
  BandSG.Cells[0,0]:='F1';
  BandSG.Cells[1,0]:='F2';
end;

procedure TPressFrmEdit2.EditPressFrm(Pf: TPressFrm2);
var
  p: TNotifyEvent;
  props:string;
  str: string;
  i: Integer;
  t: itag;
  s:cspm;
begin
  m_pf:=pf;
  BNumIE.IntNum:=pf.m_bnum;
  // отображаем векторные теги
  if not m_init then
  begin
    m_init:=true;
    TagsListFrame1.ShowVectortags:=true;
    TagsListFrame1.ShowChannels;
  end;
  props:=g_PressCamFactory2.m_spmCfg.str;
  str := GetParam(props, 'FFTCount');
  if CheckStr(str) then
  begin
    p := FFTCountEdit.OnChange;
    FFTCountEdit.OnChange := nil;
    FFTCountEdit.Text:=str;
    FFTCountEdit.OnChange := p;
  end;
  TagsLB.Clear;
  for I := 0 to g_PressCamFactory2.m_spmCfg.ChildCount - 1 do
  begin
    s:=cspm(g_PressCamFactory2.m_spmCfg.getAlg(i));
    TagsLB.AddItem(s.m_tag.tagname, nil);
    if i=0 then
    begin
      if s.m_tag<>nil then
      begin
        if s.m_tag.tag=nil then
        begin
          if s.m_tag.tagname<>'' then
            s.m_tag.tag:=getTagByName(s.m_tag.tagname);
        end;
        if s.m_tag.tag<>nil then
        begin
          if not g_PressCamFactory2.m_manualBand then
          begin
            g_PressCamFactory2.AutoEvalBand(s.m_tag.tag);
          end;
        end;
      end;
    end;
  end;
  RefFE.FloatNum:=g_PressCamFactory2.GetRef(0);
  BCountIE.IntNum:=g_PressCamFactory2.BandCount;
  BandSG.RowCount:=BCountIE.IntNum+1;
  for I := 0 to BCountIE.IntNum - 1 do
  begin
    BandSG.Cells[0,i+1]:=floattostr(g_PressCamFactory2.m_bands[i].f1);
    BandSG.Cells[1,i+1]:=floattostr(g_PressCamFactory2.m_bands[i].f2);
    // всем диапазон от первого датчика
    BandSG.Cells[2,i+1]:=floattostr(g_PressCamFactory2.GetRef(0));
  end;
  sgchange(BandSG);

  if ShowModal=mrok then
  begin
    updateBands;
    g_PressCamFactory2.CreateAlg(TagsLB.Items);
    g_PressCamFactory2.CreateFrames;
    g_PressCamFactory2.m_spmCfg.str:='FFTCount='+FFTCountEdit.text;
    m_pf.m_bnum:=BNumIE.IntNum;
    //showmessage(inttostr(length(TDoubleArray(m_pf.PressFrmFrame21.spm.m_rms.p))));
  end;
end;

procedure TPressFrmEdit2.FFTCountSpinBtnDownClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum > 2 then
    FFTCountEdit.IntNum := round(FFTCountEdit.IntNum / 2);
  updateFFTnum;
end;

procedure TPressFrmEdit2.FFTCountSpinBtnUpClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum > 2 then
    FFTCountEdit.IntNum := FFTCountEdit.IntNum * 2;
  updateFFTnum;
end;

procedure TPressFrmEdit2.UpdateAlgBtnClick(Sender: TObject);
begin
  ModalResult:=mrok;
end;

procedure TPressFrmEdit2.updateBands;
var
  I: Integer;
  fr:TPressFrmFrame2;
begin
  if m_manualB then
  begin
    for I := 0 to BCountIE.IntNum - 1 do
    begin
      g_PressCamFactory2.m_bands[i].f1:=strtofloatext(BandSG.Cells[0,1+i]);
      g_PressCamFactory2.m_bands[i].f2:=strtofloatext(BandSG.Cells[1,1+i]);
    end;
    g_PressCamFactory2.m_manualBand:=true;
    m_manualB:=false;
  end;
end;

procedure TPressFrmEdit2.updateFFTnum;
var
  t:itag;
begin
  t:=getTagByName(TagsLB.Items[0]);
  if t<>nil then
    fftdx.FloatNum := FFTCountEdit.IntNum/t.GetFreq;
end;

end.
