unit uEditSrsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, uTagsListFrame, StdCtrls, ExtCtrls,
  ActiveX, ComCtrls,
  uRCFunc,
  uHardwareMath,
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
    TahoNameRG: TRcComboBox;
    CheckBox1: TCheckBox;
    AddAlgBtn: TSpeedButton;
    procedure SignalsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure SignalsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure FormShow(Sender: TObject);
    procedure AddAlgBtnClick(Sender: TObject);
  public
    m_SRS:TSRSFrm;
  private
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
  if n.Parent<>nil then
    n:=n.Parent;
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
  n, parnode: pvirtualnode;
  d: pnodedata;
begin
  t:=m_SRS.getTaho;
  SignalsTV.clear;
  parnode:=SignalsTV.AddChild(nil, nil);
  d:=SignalsTV.getNodeData(parnode);
  d.data:=t;
  d.color:=SignalsTV.normalcolor;
  d.Caption:=t.name;
  d.ImageIndex:=1;
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
    li:=TagsListFrame1.TagsLV.Selected;
    for I := 0 to TagsListFrame1.TagsLV.SelCount - 1 do
    begin

    end;
  end
  else
  begin

  end;
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
  TrigNameCB.updateTagsList;
  TagsListFrame1.ShowChannels;
end;

end.
