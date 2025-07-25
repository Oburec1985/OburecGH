unit uEditEvalFRFFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, uTagsListFrame, StdCtrls, ExtCtrls,
  ActiveX, ComCtrls,
  uRCFunc,
  uHardwareMath,
  uCommonMath,
  uBladeDb,
  uComponentServises,
  tags, uEvalFRFFrm, uSpmProfile, uProfile, uEditTest,
  uRcCtrls, DCL_MYOWN, Spin, ImgList, Buttons;

type
  TEditFrfFrm = class(TForm)
    SignalsTV: TVTree;
    TagsListFrame1: TTagsListFrame;
    MainPanel: TPanel;
    TahoGB: TGroupBox;
    RightShiftLabel: TLabel;
    LeftShiftEdit: TFloatEdit;
    LeftShiftLabel: TLabel;
    LengthFE: TFloatEdit;
    ThresholdLabel: TLabel;
    ThresholdFE: TFloatEdit;
    SPMGB: TGroupBox;
    FFTBlockSizeLabel: TLabel;
    FFTShiftLabel: TLabel;
    FFTdxLabel: TLabel;
    BlockSizeFLabel: TLabel;
    FFTSizeSB: TSpinButton;
    FFTBlockSizeIE: TIntEdit;
    FFTShiftSB: TSpinButton;
    FFTShiftIE: TIntEdit;
    FFTdxFE: TFloatEdit;
    BlockSizeFE: TFloatEdit;
    Splitter1: TSplitter;
    ShCountLabel: TLabel;
    NullCB: TCheckBox;
    ChartGB: TGroupBox;
    LgXcb: TCheckBox;
    LgYcb: TCheckBox;
    ImageList1: TImageList;
    ShCountIE: TIntEdit;
    Label1: TLabel;
    TahoNameCB: TRcComboBox;
    UpdateBtn: TSpeedButton;
    MinXLabel: TLabel;
    MinXfe: TFloatEdit;
    MaxXLabel: TLabel;
    MaxXfe: TFloatEdit;
    MinYLabel: TLabel;
    MinYfe: TFloatEdit;
    MaxYLabel: TLabel;
    MaxYfe: TFloatEdit;
    CohThresholdFE: TFloatEdit;
    Label3: TLabel;
    SaveT0CB: TCheckBox;
    WelchGB: TGroupBox;
    WelchBCountIE: TIntEdit;
    WelchCountLabel: TLabel;
    UseWelchCb: TCheckBox;
    NewAxCb: TCheckBox;
    SigAx: TRadioGroup;
    AddPNumIE: TIntEdit;
    AddPNumLabel: TLabel;
    ProfileBtn: TButton;
    FlagsCB: TCheckBox;
    BandLabelCB: TCheckBox;
    procedure SignalsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure SignalsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject;
         Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure FormShow(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure SignalsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FFTSizeSBDownClick(Sender: TObject);
    procedure FFTSizeSBUpClick(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
    procedure WelchShiftIEChange(Sender: TObject);
    procedure FFTBlockSizeIEChange(Sender: TObject);
    procedure FFTShiftIEChange(Sender: TObject);
    procedure SignalsTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProfileBtnClick(Sender: TObject);
  public
    m_SRS:TFRFFrm;
  private
    procedure UpdateWelchBCount;
    procedure ShowTaho(t:cSrsTaho);
    procedure ShowSrsRes(s:cSrsRes);
    // �������� ������ ����� � ���������
    Procedure UpdateTags;
    procedure ShowSrsCfg;
    function GetSelectTaho:cSRSTaho;
  public
    procedure Edit(p_srs:TFRFFrm);
  end;

var
  EditFrfFrm: TEditFrfFrm;

implementation

{$R *.dfm}

procedure TEditFrfFrm.ApplyBtnClick(Sender: TObject);
var
  lt:cSRSTaho;
  t:itag;
  cfg:cSpmCfg;
begin
  lt:=GetSelectTaho;
  if lt=nil then
  begin
    t:=TahoNameCB.gettag;
    if t<>nil then
    begin
      lt:=cSRSTaho.Create;
      lt.m_tag.tag:=t;
      lt.m_treshold:=ThresholdFE.FloatNum;
      m_SRS.m_ShiftLeft:=LeftShiftEdit.FloatNum;
      m_SRS.m_Length:=LengthFE.FloatNum;
      m_SRS.addTaho(lt);
      cfg:=cSpmCfg.Create;
      cfg.m_fftCount:=FFTBlockSizeIE.IntNum;
      cfg.m_addNulls:=NullCB.Checked;
      cfg.m_blockcount:=ShCountIE.IntNum;
      lt.Cfg:=cfg;
    end;
  end;
  ShowSrsCfg;
end;

procedure TEditFrfFrm.Edit(p_srs: tFRFfrm);
begin
  m_SRS:=p_srs;
  ShowModal;
end;

procedure TEditFrfFrm.FFTBlockSizeIEChange(Sender: TObject);
begin
  UpdateWelchBCount;
end;

procedure TEditFrfFrm.FFTShiftIEChange(Sender: TObject);
begin
  UpdateWelchBCount;
end;

procedure TEditFrfFrm.FFTSizeSBDownClick(Sender: TObject);
var
  t:csrstaho;
begin
  if Sender = FFTSizeSB then
  begin
    if FFTBlockSizeIE.IntNum >= 2 then
    begin
      FFTBlockSizeIE.IntNum := round(FFTBlockSizeIE.IntNum / 2);
      FFTShiftIE.IntNum:=FFTBlockSizeIE.IntNum;
    end
    else
    begin
      FFTBlockSizeIE.IntNum := 2;
    end;
  end;
  if Sender = FFTShiftSB then
  begin
    if FFTShiftIE.IntNum >= 2 then
    begin
      FFTShiftIE.IntNum := round(FFTShiftIE.IntNum / 2);
      FFTBlockSizeIE.IntNum := FFTShiftIE.IntNum;
    end
    else
    begin
      FFTShiftIE.IntNum := 2;
    end;
  end;
  t:=GetSelectTaho;
  if t<>nil then
  begin
    FFTdxFE.FloatNum:=csrstaho(t).m_tag.freq/FFTBlockSizeIE.IntNum;
    BlockSizeFE.FloatNum:=FFTBlockSizeIE.IntNum/csrstaho(t).m_tag.freq;
  end;
end;

procedure TEditFrfFrm.FFTSizeSBUpClick(Sender: TObject);
var
  t:csrstaho;
begin
  if Sender = FFTSizeSB then
  begin
    if FFTBlockSizeIE.IntNum >= 2 then
    begin
      FFTBlockSizeIE.IntNum := FFTBlockSizeIE.IntNum * 2;
      FFTShiftIE.IntNum:=FFTBlockSizeIE.IntNum;
    end
    else
      FFTBlockSizeIE.IntNum := 2;
  end;
  if Sender = FFTShiftSB then
  begin
    if FFTShiftIE.IntNum >= 2 then
    begin
      FFTShiftIE.IntNum := FFTShiftIE.IntNum * 2;
      FFTBlockSizeIE.IntNum:=FFTShiftIE.IntNum;
    end
    else
      FFTShiftIE.IntNum := 2;
  end;
  t:=GetSelectTaho;
  if t<>nil then
  begin
    FFTdxFE.FloatNum:=csrstaho(t).m_tag.freq/FFTBlockSizeIE.IntNum;
    BlockSizeFE.FloatNum:=FFTBlockSizeIE.IntNum/csrstaho(t).m_tag.freq;
  end;
end;

procedure TEditFrfFrm.FormCreate(Sender: TObject);
begin
  //exit;
end;

procedure TEditFrfFrm.FormDestroy(Sender: TObject);
begin
  //showmessage('TEditSrsFrm.FormDestroy');
end;

procedure TEditFrfFrm.FormShow(Sender: TObject);
begin
  UpdateTags;
  ShowSrsCfg;
end;

function TEditFrfFrm.GetSelectTaho: cSRSTaho;
var
  n, parentnode: pvirtualnode;
  d: pnodedata;
begin
  result := nil;
  n := GetSelectNode(SignalsTV);
  if n=nil then
  begin
    n:=SignalsTV.RootNode;
    if n=nil then exit;
  end;
  if n<>SignalsTV.RootNode then
  begin
    if n.Parent<>SignalsTV.RootNode then
      n:=n.Parent;
  end
  else
  begin
    if n.ChildCount>0 then
    begin
      n:=n.FirstChild;
    end
    else
    begin
      result:=nil;
      exit;
    end;
  end;
  d:=SignalsTV.getNodeData(n);
  if tobject(d.Data) is cSRSTaho then
  begin
    result:=csrstaho(d.Data);
  end;
end;

procedure TEditFrfFrm.ProfileBtnClick(Sender: TObject);
var
  t:cSRSTaho;
begin
  t:=m_SRS.getTaho;
  if EditTestFrm=nil then
    EditTestFrm:=TEditTestFrm.create(nil);
  EditTestFrm.edit(nil);
end;

procedure TEditFrfFrm.ShowSrsCfg;
var
  i:integer;
  t:cSRSTaho;
  cfg:cSpmCfg;
  srs:cSRSres;
  n, parnode: pvirtualnode;
  d: pnodedata;
begin
  UseWelchCb.Checked:=m_SRS.m_UseWelch;
  WelchBCountIE.IntNum:=m_SRS.m_WelchCount;
  if m_SRS.m_WelchShift<>0 then
  begin
    FFTShiftIE.IntNum:=m_SRS.m_WelchShift;
  end;

  MinXfe.FloatNum:=m_SRS.m_minX;
  MaxXfe.FloatNum:=m_SRS.m_maxX;
  MinYfe.FloatNum:=m_SRS.m_minY;
  MaxYfe.FloatNum:=m_SRS.m_maxY;
  LgXcb.Checked:=m_SRS.m_lgX;
  LgYcb.Checked:=m_SRS.m_lgY;
  NewAxCb.Checked:=m_SRS.m_newAx;

  FlagsCB.Checked:=m_SRS.m_showflags;
  BandLabelCB.Checked:=m_SRS.m_showBandLab;

  SaveT0CB.Checked:=m_srs.m_saveT0;
  t:=m_SRS.getTaho;
  if t<>nil then
  begin
    NullCB.Checked:=t.cfg.m_addNulls;
    if t<>nil then
      ShowTaho(t);
  end;
  SignalsTV.clear;
  if t<>nil then
  begin
    parnode:=SignalsTV.AddChild(nil, nil);
    d:=SignalsTV.getNodeData(parnode);
    d.data:=t;
    d.color:=SignalsTV.normalcolor;
    d.Caption:=t.name;
    d.ImageIndex:=1;
    for I := 0 to t.cfg.SRSCount - 1 do
    begin
      n:=SignalsTV.AddChild(parnode, nil);
      d:=SignalsTV.getNodeData(n);
      srs:=t.Cfg.GetSrs(i);
      d.data:=srs;
      d.color:=SignalsTV.normalcolor;
      d.Caption:=srs.name;
      d.ImageIndex:=2;
    end;
  end;
end;

procedure TEditFrfFrm.ShowSrsRes(s:cSrsRes);
begin
  SigAx.ItemIndex:=s.m_axis;
  AddPNumIE.IntNum:=s.m_incPNum;
end;

procedure TEditFrfFrm.ShowTaho(t: cSrsTaho);
var
  c:cSpmCfg;
begin
  setComboBoxItem(t.name,TahoNameCB);
  if t.m_tag.tag=nil then
    t.m_tag.tag:=getTagByName(t.m_tag.tagname);
  ThresholdFE.FloatNum:=t.m_treshold;
  LeftShiftEdit.FloatNum:=m_SRS.m_ShiftLeft;
  LengthFE.FloatNum:=m_SRS.m_Length;
  c:=t.Cfg;
  FFTBlockSizeIE.IntNum:=c.m_fftCount;
  //FFTShiftIE.IntNum:=c.m_fftCount;
  if c.m_fftCount<>0 then
    FFTdxFE.FloatNum:=csrstaho(c.taho).m_tag.freq/c.m_fftCount;
  if csrstaho(c.taho).m_tag.freq<>0 then
    BlockSizeFE.FloatNum:=FFTBlockSizeIE.IntNum/csrstaho(c.taho).m_tag.freq;
  ShCountIE.IntNum:=1;
  ShCountIE.IntNum:=c.m_capacity;
  CohThresholdFE.FloatNum:=t.m_CohTreshold;
  UpdateWelchBCount;
end;

procedure TEditFrfFrm.SignalsTVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  n: PVirtualNode;
  D: PNodeData;
begin
  n := GetSelectNode(SignalsTV);
  d := SignalsTV.GetNodeData(n);
  if d <> nil then
  begin
    if TObject(d.data) is cSRSTaho then
    begin
      ShowTaho(cSRSTaho(TObject(d.data)));
    end;
    if TObject(d.data) is cSRSRes then
    begin
      ShowSrsRes(cSRSRes(TObject(d.data)));
    end;
  end;
end;

procedure TEditFrfFrm.SignalsTVDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  I: Integer;
  n, sn, new, prev: PVirtualNode;
  data, sd, nd:pnodedata;
  li:TListItem;
  t:cSRSTaho;
  it:itag;
  cfg:cSpmCfg;
begin
  // ������������� vcl ���������
  n := Sender.DropTargetNode;
  if n<>nil then
  begin
    data:=SignalsTV.GetNodeData(n);
  end;
  if source=TagsListFrame1.TagsLV then
  begin
    t:=GetSelectTaho;
    if t=nil then
    begin
      li:=TagsListFrame1.TagsLV.Selected;
      t:=cSRSTaho.create;
      t.m_tag.tag:=itag(li.Data);
      cfg:=cSpmCfg.Create;
      t.Cfg:=cfg;
      m_SRS.addTaho(t);
    end
    else
    begin
      li:=TagsListFrame1.TagsLV.Selected;
      cfg:=t.cfg;
      for I := 0 to TagsListFrame1.TagsLV.SelCount - 1 do
      begin
        cfg.addSRS(li.data);
        li:=TagsListFrame1.TagsLV.GetNextItem(li,sdAll,[isSelected]);
      end;
    end;
  end
  else
  begin

  end;
  ShowSrsCfg;
end;

procedure TEditFrfFrm.SignalsTVDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
VAR
  n, tn:PVirtualNode;
  d, td:pnodedata;
begin
  Accept := false;
  if Source = TagsListFrame1.TagsLV then
    Accept := true
  else
  begin

  end;
end;

procedure TEditFrfFrm.SignalsTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  next,n, Node: PVirtualNode;
  Data, parentdata: PNodeData;
  I: Integer;
  del:boolean;
begin
  if Key = VK_DELETE then
  begin
    Node := SignalsTV.GetFirstSelected(true);
    while Node <> nil do
    begin
      del:=false;
      Data := SignalsTV.GetNodeData(Node);
      if tobject(data.data) is cSRSres then
      begin
        del:=true;
        cSRSres(data.data).Destroy;
      end;
      next := SignalsTV.GetNextSelected(Node, false);
      if next = nil then
      begin
        if Data.Data<>nil then
        begin

        end;
      end;
      if del then
      begin
        SignalsTV.DeleteNode(node);
      end;
      Node := next;
      inc(I);
    end;
  end;
end;

procedure TEditFrfFrm.UpdateBtnClick(Sender: TObject);
var
  t:cSRSTaho;
  c:cSpmCfg;
  s:cSRSres;
  bl:TDataBlock;
  n:PVirtualNode;
  d:PNodeData;
  I, j: Integer;
  selbl:cxmlfolder;
begin
  m_SRS.m_ShiftLeft:=LeftShiftEdit.FloatNum;
  m_SRS.m_Length:=LengthFE.FloatNum;

  m_SRS.m_lgX:=lgXcb.Checked;
  m_SRS.m_lgY:=lgYcb.Checked;
  m_SRS.m_minX:=MinXfe.FloatNum;
  m_SRS.m_maxX:=MaxXfe.FloatNum;
  m_SRS.m_minY:=MinYfe.FloatNum;
  m_SRS.m_maxY:=MaxYfe.FloatNum;
  m_SRS.m_saveT0:=SaveT0CB.Checked;

  m_SRS.m_UseWelch:=UseWelchCb.Checked;
  m_SRS.m_WelchCount:=WelchBCountIE.IntNum;
  m_SRS.m_WelchShift:=FFTShiftIE.IntNum;
  m_SRS.m_WelchCount:=WelchBCountIE.IntNum;
  m_SRS.NewAxis:=NewAxCb.Checked;
  m_SRS.UpdateChart;
  m_SRS.m_showflags:=FlagsCB.Checked;
  m_SRS.m_showBandLab:=BandLabelCB.Checked;
  m_SRS.UpdateBandNames;
  selbl:=g_mbase.SelectBlade;
  if selbl<>nil then
    m_SRS.BladeNumEdit.Text:=selbl.name;
  n:=SignalsTV.FocusedNode;
  d:=SignalsTV.GetNodeData(n);
  if d<>nil then
  begin
    if tobject(d.data) is cSRSres then
    begin
      csrsres(d.data).m_axis:=SigAx.ItemIndex;
      csrsres(d.data).m_incPNum:=AddPNumIE.IntNum;
    end;
  end;

  t:=GetSelectTaho;
  if t=nil then
    exit;
  c:=t.Cfg;
  t.m_shockList.m_wnd.x2:=LengthFE.FloatNum*0.7;
  if t=nil then exit;
  t.m_treshold:=ThresholdFE.FloatNum;
  c.m_fftCount:=FFTBlockSizeIE.IntNum;
  c.m_blockcount:=ShCountIE.IntNum;
  c.m_addNulls:=NullCB.Checked;
  c.m_capacity:=ShCountIE.IntNum;
  t.m_CohTreshold:=CohThresholdFE.FloatNum;

  for I := 0 to c.SRSCount - 1 do
  begin
    s:=c.GetSrs(i);
    s.updateBlock(FFTBlockSizeIE.IntNum, round(m_srs.m_length*s.m_tag.freq));
  end;
  m_SRS.UpdateBlocks;
end;

procedure TEditFrfFrm.UpdateTags;
begin
  TahoNameCB.updateTagsList;
  TagsListFrame1.ShowChannels;
end;

procedure TEditFrfFrm.WelchShiftIEChange(Sender: TObject);
begin
  UpdateWelchBCount;
end;

procedure TEditFrfFrm.UpdateWelchBCount;
var
  t:cSRSTaho;
  lastpos:integer;
  Len:double;
begin
  t:=GetSelectTaho;
  if t=nil then exit;

  lastpos:=trunc(LengthFE.FloatNum*t.m_tag.freq)-FFTBlockSizeIE.IntNum;
  if lastpos>0 then
  begin
    if FFTShiftIE.IntNum>0 then
    begin
      // =����(C9>=fftsize;����������(1+(C9-fftsize)/fftshift;0);0)
      WelchBCountIE.IntNum:=trunc(lastpos/FFTShiftIE.IntNum)+1
    end;
  end
  ELSE
    WelchBCountIE.IntNum:=1;
end;

end.
