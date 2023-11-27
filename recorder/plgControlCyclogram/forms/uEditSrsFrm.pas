unit uEditSrsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, uTagsListFrame, StdCtrls, ExtCtrls,
  ActiveX, ComCtrls,
  uRCFunc,
  uHardwareMath,
  uCommonMath,
  uComponentServises,
  tags,
  uRcCtrls, DCL_MYOWN, Spin, ImgList, Buttons, uSrsFrm;

type
  TEditSrsFrm = class(TForm)
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
    ResTypeRG: TRadioGroup;
    ShCountLabel: TLabel;
    NullCB: TCheckBox;
    ChartGB: TGroupBox;
    LgXcb: TCheckBox;
    LgYcb: TCheckBox;
    ImageList1: TImageList;
    ShCountIE: TIntEdit;
    Label1: TLabel;
    TahoNameCB: TRcComboBox;
    CheckBox1: TCheckBox;
    UpdateBtn: TSpeedButton;
    MinXLabel: TLabel;
    MinXfe: TFloatEdit;
    MaxXLabel: TLabel;
    MaxXfe: TFloatEdit;
    MinYLabel: TLabel;
    MinYfe: TFloatEdit;
    MaxYLabel: TLabel;
    MaxYfe: TFloatEdit;
    ShockCountIE: TIntEdit;
    Label2: TLabel;
    CohThresholdFE: TFloatEdit;
    Label3: TLabel;
    SaveT0CB: TCheckBox;
    EstimatorRG: TRadioGroup;
    CorrTahoCB: TCheckBox;
    CorrSCB: TCheckBox;
    WelchGB: TGroupBox;
    WelchBCountIE: TIntEdit;
    WelchCountLabel: TLabel;
    UseWelchCb: TCheckBox;
    procedure SignalsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure SignalsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure FormShow(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure SignalsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FFTSizeSBDownClick(Sender: TObject);
    procedure FFTSizeSBUpClick(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
    procedure WelchShiftIEChange(Sender: TObject);
    procedure FFTBlockSizeIEChange(Sender: TObject);
    procedure FFTShiftIEChange(Sender: TObject);
  public
    m_SRS:TSRSFrm;
  private
    procedure UpdateWelchBCount;
    procedure ShowTaho(t:cSrsTaho);
    // обновить списки тегов в элементах
    Procedure UpdateTags;
    procedure ShowSrsCfg;
    function GetSelectTaho:cSRSTaho;
  public
    procedure Edit(p_srs:tsrsfrm);
  end;

var
  EditSrsFrm: TEditSrsFrm;

implementation

{$R *.dfm}

procedure TEditSrsFrm.ApplyBtnClick(Sender: TObject);
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
      lt.m_ShiftLeft:=LeftShiftEdit.FloatNum;
      lt.m_Length:=LengthFE.FloatNum;
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

procedure TEditSrsFrm.Edit(p_srs: tsrsfrm);
begin
  m_SRS:=p_srs;
  ShowModal;
end;

procedure TEditSrsFrm.FFTBlockSizeIEChange(Sender: TObject);
begin
  UpdateWelchBCount;
end;

procedure TEditSrsFrm.FFTShiftIEChange(Sender: TObject);
begin
  UpdateWelchBCount;
end;

procedure TEditSrsFrm.FFTSizeSBDownClick(Sender: TObject);
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

procedure TEditSrsFrm.FFTSizeSBUpClick(Sender: TObject);
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

procedure TEditSrsFrm.FormShow(Sender: TObject);
begin
  UpdateTags;
  ShowSrsCfg;
end;

function TEditSrsFrm.GetSelectTaho: cSRSTaho;
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

procedure TEditSrsFrm.ShowSrsCfg;
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

  MinXfe.FloatNum:=m_SRS.m_minX;
  MaxXfe.FloatNum:=m_SRS.m_maxX;
  MinYfe.FloatNum:=m_SRS.m_minY;
  MaxYfe.FloatNum:=m_SRS.m_maxY;
  LgXcb.Checked:=m_SRS.m_lgX;
  LgYcb.Checked:=m_SRS.m_lgY;
  EstimatorRG.ItemIndex:=m_SRS.m_estimator;
  SaveT0CB.Checked:=m_srs.m_saveT0;
  t:=m_SRS.getTaho;
  if t<>nil then
    ShowTaho(t);
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

procedure TEditSrsFrm.ShowTaho(t: cSrsTaho);
var
  c:cSpmCfg;
begin
  setComboBoxItem(t.name,TahoNameCB);
  ThresholdFE.FloatNum:=t.m_treshold;
  LeftShiftEdit.FloatNum:=t.m_ShiftLeft;
  LengthFE.FloatNum:=t.m_Length;
  c:=t.Cfg;
  ResTypeRG.ItemIndex:=C.typeRes;
  FFTBlockSizeIE.IntNum:=c.m_fftCount;
  FFTShiftIE.IntNum:=c.m_fftCount;
  FFTdxFE.FloatNum:=csrstaho(c.taho).m_tag.freq/c.m_fftCount;
  BlockSizeFE.FloatNum:=FFTBlockSizeIE.IntNum/csrstaho(c.taho).m_tag.freq;
  ShCountIE.IntNum:=1;
  NullCB.Checked:=false;
  ShCountIE.IntNum:=c.m_capacity;
  CohThresholdFE.FloatNum:=t.m_CohTreshold;
  UpdateWelchBCount;
end;

procedure TEditSrsFrm.SignalsTVChange(Sender: TBaseVirtualTree;
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
  end;
end;

procedure TEditSrsFrm.SignalsTVDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  I: Integer;
  n, sn, new, prev: PVirtualNode;
  d, sd, nd:pnodedata;
  li:TListItem;
  t:cSRSTaho;
  it:itag;
  cfg:cSpmCfg;
begin
  // перетаскиваем vcl компонент
  n := Sender.DropTargetNode;
  if n<>nil then
  begin
    d:=SignalsTV.GetNodeData(n);
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

procedure TEditSrsFrm.SignalsTVDragOver(Sender: TBaseVirtualTree;
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

procedure TEditSrsFrm.UpdateBtnClick(Sender: TObject);
var
  t:cSRSTaho;
  c:cSpmCfg;
begin
  t:=GetSelectTaho;
  c:=t.Cfg;

  t.m_corrTaho:=CorrTahoCB.Checked;
  t.m_shockList.m_wnd.x2:=LengthFE.FloatNum*0.7;

  if t=nil then exit;
  t.m_treshold:=ThresholdFE.FloatNum;
  t.m_ShiftLeft:=LeftShiftEdit.FloatNum;
  t.m_Length:=LengthFE.FloatNum;
  c.m_fftCount:=FFTBlockSizeIE.IntNum;
  c.m_blockcount:=ShCountIE.IntNum;
  c.m_addNulls:=NullCB.Checked;
  C.typeRes:=ResTypeRg.ItemIndex;
  m_SRS.m_lgX:=lgXcb.Checked;
  m_SRS.m_lgY:=lgYcb.Checked;
  m_SRS.m_minX:=MinXfe.FloatNum;
  m_SRS.m_maxX:=MaxXfe.FloatNum;
  m_SRS.m_minY:=MinYfe.FloatNum;
  m_SRS.m_maxY:=MaxYfe.FloatNum;
  m_SRS.m_estimator:=EstimatorRG.ItemIndex;
  m_SRS.UpdateChart;
  m_SRS.m_saveT0:=SaveT0CB.Checked;
  m_SRS.m_corrS:=CorrSCB.Checked;

  m_SRS.m_UseWelch:=UseWelchCb.Checked;
  m_SRS.m_WelchCount:=WelchBCountIE.IntNum;

  c.m_capacity:=ShCountIE.IntNum;
  t.m_CohTreshold:=CohThresholdFE.FloatNum;
end;

procedure TEditSrsFrm.UpdateTags;
begin
  TahoNameCB.updateTagsList;
  TagsListFrame1.ShowChannels;
end;

procedure TEditSrsFrm.WelchShiftIEChange(Sender: TObject);
begin
  UpdateWelchBCount;
end;

procedure TEditSrsFrm.UpdateWelchBCount;
var
  t:cSRSTaho;
  lastpos:integer;
begin
  t:=GetSelectTaho;
  if t=nil then exit;

  lastpos:=trunc(LengthFE.FloatNum*t.m_tag.freq)-FFTBlockSizeIE.IntNum;
  if lastpos>0 then
    WelchBCountIE.IntNum:=trunc(lastpos/FFTShiftIE.IntNum)+1
  ELSE
    WelchBCountIE.IntNum:=1;
end;

end.
