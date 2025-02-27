unit uPressFrmEdit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath, MathFunction,
  Forms, ComCtrls,
  uRecBasicFactory,
  uRecorderEvents,
  uComponentServises,
  uChart,
  inifiles,
  upage,
  tags,
  complex,
  uBuffTrend1d,
  uCommonMath,
  uCommonTypes,
  pluginClass,
  uMeasureBase,
  uMBaseControl,
  shellapi,
  uPathMng,
  uExcel,
  uListMath,
  uSpm, uBaseAlg,
  opengl, uSimpleObjects,
  math, uAxis, uDrawObj, uDoubleCursor, uBasicTrend,
  Dialogs, ExtCtrls, StdCtrls, DCL_MYOWN, Spin, Buttons, uPressFrmFrame2,
  uPressFrm2, uEditCurveFrm, uSpmThresholdProfile,
  uRcCtrls, Menus, Grids, uStringGridExt, uTagsListFrame;

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
    BNumLabel: TLabel;
    BNumIE: TIntEdit;
    BNumSB: TSpinButton;
    RefLabel: TLabel;
    RefFE: TFloatEdit;
    TypeResCB: TComboBox;
    TypeLabel: TLabel;
    CreateTagsCB: TCheckBox;
    WndCB: TComboBox;
    WndLab: TLabel;
    AFHcb: TCheckBox;
    HH_AlTagCB: TRcComboBox;
    H_AlTagCB: TRcComboBox;
    Label4: TLabel;
    HHLab: TLabel;
    AlarmCB: TRcComboBox;
    AlarmLabel: TLabel;
    NormalLabel: TLabel;
    NormalCB: TRcComboBox;
    UseRefTagCb: TCheckBox;
    RefTagCb: TRcComboBox;
    TagsLB: TListView;
    Splitter1: TSplitter;
    UseRefProfileCB: TCheckBox;
    useAlarmsCB: TCheckBox;
    procedure setHideTags;
    // отобразить галочки отображаемых сигналов на основании инф-ии в m_pf.m_hidesignals
    procedure SetCheckBoxes;
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
    procedure RefFEChange(Sender: TObject);
    procedure AFHcbClick(Sender: TObject);
    procedure UseRefTagCbClick(Sender: TObject);
    procedure UseRefProfileCBClick(Sender: TObject);
    procedure TagsLBChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    m_init,
    m_manualRef:boolean;
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
procedure TPressFrmEdit2.AFHcbClick(Sender: TObject);
var
  s:PTagRec;
  i:integer;
  li:tlistitem;
begin
  if TagsLB.ItemIndex=-1 then
  begin
    i:=0;
  end
  else
    i:=TagsLB.ItemIndex;
  li:=TagsLB.items[i];
  s:=g_PressCamFactory2.getTag(li.Caption);
  if s<>nil then
  begin
    if AFHcb.Checked then
    begin
      if s.m_curve=nil then
      begin
        s.m_curve:=cCurve.create;
      end;
      s.m_curve.m_use:=true;
      s.m_curve.getMemScaleData(FFTCountEdit.IntNum shr 1);
      s.m_s.SetScaleData(s.m_curve.m_ScaleData.p);
      EditCurveFrm.editCurve(s.m_curve, FFTCountEdit.IntNum);
    end
    else
    begin
      if s.m_curve<>nil then
        s.m_curve.m_use:=true;
    end;
    if s.m_curve<>nil then
      s.m_s.SetUseScaleData(s.m_curve.m_use);
  end;
end;

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
    if m_row=0 then
      m_row:=1;
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

procedure TPressFrmEdit2.TagsLBChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  s:PTagRec;
  li:tlistitem;
begin
  if tagsLB.SelCount=1 then
  begin
    li:=tagsLB.Selected;
    s:=g_PressCamFactory2.getTag(li.Index);
    useAlarmsCB.checked:=g_PressCamFactory2.m_useAlarmsArr[li.Index];
  end
  else
  begin
    if tagsLB.SelCount>0 then
    begin
      li:=tagsLB.Selected;
      while li<>nil do
      begin
        s:=g_PressCamFactory2.getTag(li.Index);
        SetMultiSelectComponentBool(useAlarmsCB, g_PressCamFactory2.m_useAlarmsArr[li.Index]);
        li:=tagsLB.GetNextItem(li,sdAll,[isselected]);
      end;
    end;
    endMultiSelect(useAlarmsCB);
  end;
end;

procedure TPressFrmEdit2.TagsLBClick(Sender: TObject);
var
  I, sel: Integer;
begin
  sel:=tagsLB.itemindex;
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
    li:=tagslb.Items[tagslb.items.Count-1];
    li.Checked:=true;
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
  EditCurveFrm:=TEditCurveFrm.Create(nil);
end;

procedure TPressFrmEdit2.EditPressFrm(Pf: TPressFrm2);
var
  p: TNotifyEvent;
  props:string;
  str: string;
  i: Integer;
  t: itag;
  s:cspm;
  sig:PTagRec;
  b, err:boolean;
  li:tlistitem;
begin
  m_pf:=pf;
  pf.bnumupdate:=true;
  BNumIE.IntNum:=pf.m_bnum;
  H_AlTagCB.updateTagsList;
  HH_AlTagCB.updateTagsList;
  AlarmCB.updateTagsList;
  NormalCB.updateTagsList;
  RefTagCb.updateTagsList;

  H_AlTagCB.SetTagName(g_PressCamFactory2.m_AlarmTagH.tagname);
  HH_AlTagCB.SetTagName(g_PressCamFactory2.m_AlarmTagHH.tagname);
  AlarmCB.SetTagName(g_PressCamFactory2.m_AlarmTag.tagname);
  NormalCB.SetTagName(g_PressCamFactory2.m_NormalTag.tagname);
  RefTagCb.SetTagName(g_PressCamFactory2.m_RefTag.tagname);
  useRefTagCb.Checked:=g_PressCamFactory2.m_useRefTag;
  RefTagCb.Visible:=g_PressCamFactory2.m_useRefTag;

  // отображаем векторные теги
  if not m_init then
  begin
    m_init:=true;
    TagsListFrame1.ShowVectortags:=true;
    TagsListFrame1.ShowChannels;
  end;
  str := '';
  if g_PressCamFactory2.m_spmCfg<>nil then
  begin
    props:=g_PressCamFactory2.m_spmCfg.str;
    str := GetParam(props, 'FFTCount');
  end;
  if CheckStr(str) then
  begin
    p := FFTCountEdit.OnChange;
    FFTCountEdit.OnChange := nil;
    FFTCountEdit.Text:=str;
    FFTCountEdit.OnChange := p;
  end;
  TagsLB.Clear;
  if g_PressCamFactory2.m_spmCfg<>nil then
  begin
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
  end;
  p:=UseRefProfileCB.OnClick;
  UseRefProfileCB.OnClick:=nil;
  UseRefProfileCB.Checked:=g_PressCamFactory2.m_UseProfile;
  UseRefProfileCB.OnClick:=p;

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
  TypeResCB.ItemIndex:=g_PressCamFactory2.m_typeRes;
  wndCB.ItemIndex:=g_PressCamFactory2.GetWndInd;
  CreateTagsCB.Checked:=g_PressCamFactory2.m_createTags;
  // отобразить галочки спрятанных тегов
  SetCheckBoxes;
  if ShowModal=mrok then
  begin
    updateBands;
    if tagsLB.SelCount>0 then
    begin
      li:=tagsLB.Selected;
      while li<>nil do
      begin
        sig:=g_PressCamFactory2.getTag(li.Index);
        b:=GetMultiSelectComponentBool(useAlarmsCB, err);
        if not err then
        begin
          g_PressCamFactory2.m_useAlarmsArr[li.index]:=b;
        end;
        li:=tagsLB.GetNextItem(li,sdAll,[isselected]);
      end;
    end;
    if m_manualRef then
    begin
      g_PressCamFactory2.m_Manualref:=m_manualRef;
      g_PressCamFactory2.SetRef(RefFE.FloatNum);
      m_manualRef:=false;
    end;
    g_PressCamFactory2.m_createTags:=CreateTagsCB.Checked;
    g_PressCamFactory2.m_typeRes:=TypeResCB.ItemIndex;
    ecm(b);
    g_PressCamFactory2.CreateAlg(TagsLB);
    g_PressCamFactory2.CreateFrames(true);
    g_PressCamFactory2.m_spmCfg.str:='FFTCount='+FFTCountEdit.text;
    case WndCb.ItemIndex of
      0:g_PressCamFactory2.m_spmCfg.str:='Wnd=Rect';
      1:g_PressCamFactory2.m_spmCfg.str:='Wnd=Hamming';
      2:g_PressCamFactory2.m_spmCfg.str:='Wnd=Hann'; // Хеннинг
      3:g_PressCamFactory2.m_spmCfg.str:='Wnd=Blackmann';
      4:g_PressCamFactory2.m_spmCfg.str:='Wnd=Flattop';
    end;
    g_PressCamFactory2.m_AlarmTagH.tag:=H_AlTagCB.gettag();
    g_PressCamFactory2.m_AlarmTagHH.tag:=HH_AlTagCB.gettag();
    g_PressCamFactory2.m_AlarmTag.tag:=AlarmCB.gettag();
    g_PressCamFactory2.m_NormalTag.tag:=NormalCB.gettag();
    g_PressCamFactory2.m_RefTag.tag:=RefTagCb.gettag();
    g_PressCamFactory2.m_useRefTag:=useRefTagCb.Checked;
    // номер полосы
    m_pf.m_bnum:=BNumIE.IntNum;
    m_pf.BNumIE.IntNum:=BNumIE.IntNum;
    m_pf.updatecaption;
    if TypeResCB.ItemIndex=0 then // СКО
    begin
      m_pf.UnitMaxALab.Caption:='rms';
    end
    else
    begin
      m_pf.UnitMaxALab.Caption:='pk-pk';
    end;
    g_PressCamFactory2.CreateTags;
    setHideTags;
    if b then
      lcm;
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

procedure TPressFrmEdit2.RefFEChange(Sender: TObject);
begin
  m_manualRef:=true;
end;

procedure TPressFrmEdit2.SetCheckBoxes;
var
  I: Integer;
  s:cspm;
  j: Integer;
  hide:boolean;
begin
  for I := 0 to g_PressCamFactory2.m_spmCfg.ChildCount - 1 do
  begin
    s:=cspm(g_PressCamFactory2.m_spmCfg.getAlg(i));
    hide:=false;
    for j := 0 to length(m_pf.m_hidesignals) - 1 do
    begin
      if s.m_tag.tag=m_pf.m_hidesignals[j] then
      begin
        hide:=true;
        break;
      end;
    end;
    TagsLB.Items[i].Checked:=not hide;
  end;
end;

procedure TPressFrmEdit2.setHideTags;
var
  I,c: Integer;
  li:tlistitem;
begin
  c:=0;
  for I := 0 to TagsLB.items.Count - 1 do
  begin
    li:=TagsLB.items[i];
    if not li.Checked then
    begin
      inc(c);
    end;
  end;
  setlength(m_pf.m_hidesignals,c);
  c:=0;
  for I := 0 to TagsLB.items.Count - 1 do
  begin
    li:=TagsLB.items[i];
    if not li.Checked then
    begin
      m_pf.m_hidesignals[c]:=cspm(g_PressCamFactory2.m_spmCfg.getAlg(i)).m_tag.tag;
      inc(c);
    end;
  end;
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
  if g_PressCamFactory2.BandCount<>BCountIE.IntNum then
  begin
    g_PressCamFactory2.BandCount:=BCountIE.IntNum;
  end;
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
  if TagsLB.Items.Count=0 then exit;
  t:=getTagByName(TagsLB.Items[0].Caption);
  if t<>nil then
    fftdx.FloatNum := FFTCountEdit.IntNum/t.GetFreq;
end;

procedure TPressFrmEdit2.UseRefProfileCBClick(Sender: TObject);
begin
  g_PressCamFactory2.UseProfile:=UseRefProfileCB.Checked;
  if UseRefProfileCB.Checked then
  begin
    g_PressCamFactory2.m_spmProfile.size:=g_PressCamFactory2.BandCount;
    SpmThresholdProfileFrm.edit(g_PressCamFactory2.m_spmProfile);
  end;
end;

procedure TPressFrmEdit2.UseRefTagCbClick(Sender: TObject);
begin
  RefTagcb.Visible:=UseRefTagCb.Checked;
  if UseRefTagCb.Checked then
  begin
    RefLabel.Caption:='Масштаб';
  end
  else
  begin
    RefLabel.Caption:='Ref';
  end;
end;

end.
