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
    TrigNameLabel: TLabel;
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
    TrigNameCB: TRcComboBox;
    ShCountIE: TIntEdit;
    Label1: TLabel;
    TahoNameCB: TRcComboBox;
    CheckBox1: TCheckBox;
    AddAlgBtn: TSpeedButton;
    procedure SignalsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure SignalsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure FormShow(Sender: TObject);
    procedure AddAlgBtnClick(Sender: TObject);
    procedure SignalsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  public
    m_SRS:TSRSFrm;
  private
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

procedure TEditSrsFrm.AddAlgBtnClick(Sender: TObject);
var
  lt:cSRSTaho;
  t:itag;
  cfg:cSpmCfg;
begin
  lt:=GetSelectTaho;
  if lt=nil then
  begin
    t:=TrigNameCB.gettag;
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
  t:=m_SRS.getTaho;
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
  setComboBoxItem(t.name,TrigNameCB);
  ThresholdFE.FloatNum:=t.m_treshold;
  LeftShiftEdit.FloatNum:=t.m_ShiftLeft;
  LengthFE.FloatNum:=t.m_Length;
  c:=t.Cfg;
  FFTBlockSizeIE.IntNum:=c.m_fftCount;
  FFTShiftIE.IntNum:=c.m_fftCount;
  FFTdxFE.FloatNum:=csrstaho(c.taho).m_tag.freq/c.m_fftCount;
  BlockSizeFE.FloatNum:=FFTBlockSizeIE.IntNum/csrstaho(c.taho).m_tag.freq;
  ShCountIE.IntNum:=1;
  NullCB.Checked:=false;
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

procedure TEditSrsFrm.UpdateTags;
begin
  TahoNameCB.updateTagsList;
  TrigNameCB.updateTagsList;
  TagsListFrame1.ShowChannels;
end;

end.
