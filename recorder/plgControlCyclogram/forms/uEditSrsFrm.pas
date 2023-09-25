unit uEditSrsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, uTagsListFrame, StdCtrls, ExtCtrls,
  ActiveX,
  uRCFunc,
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
  t:ctag;
begin
  t:=TrigNameCB.gettag;
  if t<>nil then
  begin
    lt:=cSRSTaho.Create;
    lt.m_tag.tag:=t.tag;
    lt.m_treshold:=ThresholdFE.FloatNum;
    lt.m_ShiftLeft:=LeftShiftEdit.FloatNum;
    lt.m_Length:=LengthFE.FloatNum;
    m_SRS.addTaho(lt);
  end;
end;

procedure TEditSrsFrm.Edit(p_srs: tsrsfrm);
begin

end;

procedure TEditSrsFrm.FormShow(Sender: TObject);
begin
  UpdateTags;
end;

procedure TEditSrsFrm.ShowSrsCfg;
var
  i:integer;
  t:cSRSTaho;
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
  d.ImageIndex:=0;
  for I := 0 to t..Count - 1 do
  begin

  end;
    for j := 0 to cfg.ChildCount - 1 do
    begin
      a:=cfg.getAlg(j);
      n:=AlgsTV.AddChild(parnode, cfg);
      d:=AlgsTV.getNodeData(n);
      d.Caption:=a.name;
      d.ImageIndex:=1;
      d.data:=a;
      d.color:=AlgsTV.normalcolor;
    end;
end;

procedure TEditSrsFrm.SignalsTVDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  I: Integer;
  n, sn, new, prev: PVirtualNode;
  d, sd, nd:pnodedata;
begin
  // перетаскиваем vcl компонент
  n := Sender.DropTargetNode;
  if n<>nil then
  begin
    d:=SignalsTV.GetNodeData(n);
  end;
  if source=TagsListFrame1.TagsLV then
  begin
    if DataObject = nil then
    begin
      AddAlgToNode(n);
    end;
  end
  else
  begin
    if source=AlgsTV then // если источник само дерево алгоритмов
    begin
      sn:=AlgsTV.GetFirstSelected(false);
      while sn<>nil do
      begin
        sd:=AlgsTV.GetNodeData(sn);
        if tobject(d.data) is cBaseAlgContainer then
        begin
          n:=n.Parent;
          d:=AlgsTV.GetNodeData(n);
        end;
        if tobject(d.data) is cAlgConfig then // если дропаем в конфиг
        begin
          if tobject(sd.data) is cbasealgcontainer then
          begin
            if cbasealgcontainer(sd.data).ClassType=cAlgConfig(d.data).clType then
            begin
              new:=AlgsTV.AddChild(n, nil);
              nd:=AlgsTV.GetNodeData(new);
              nd.data:=sd.data;
              nd.ImageIndex:=sd.ImageIndex;
              nd.color:=sd.color;
              nd.Caption:=sd.Caption;
              cAlgConfig(d.data).AddChild(cbasealgcontainer(sd.data));
              prev:=sn;
              sn:=AlgsTV.GetNextSelected(sn, false);
              AlgsTV.DeleteNode(prev,true);
            end;
          end;
        end;
      end;
    end;
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
