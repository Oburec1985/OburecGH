unit uThresholdsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons,
  uControlEditFrame, uModeFrame, uRecorderEvents, uControlObj,
  uComponentServises,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService,
  tags, recorder, uBaseObjService, uModesTabsForm, activex, uRTrig,
  DCL_MYOWN, uRcCtrls, uTrigsFrm, uEventTypes, uCommonMath,
  uExcel, Spin, uSpin, uTagsListFrame;

type
  TThresholdGroup = class
  public
    ControlTag:itag;
    AlarmList:tlist;
    name:string;
  public
    constructor create;
    destructor destroy;
  end;

  TAlarms = class
  public
    owner:TThresholdGroup;
    normal, outRange, HH, h, L, LL:double;
    normalCol, outRangeCol, HHCol, hCol, LCol, LLCol:integer;
  end;

  TThresholdFrm = class(TForm)
    BotPan: TPanel;
    AddPObjBtn: TSpeedButton;
    UpdatePObjBtn: TSpeedButton;
    LoadFromExcelBtn: TSpeedButton;
    SaveToExcelBtn: TSpeedButton;
    LeftPan: TPanel;
    TagsTV: TVTree;
    Panel3: TPanel;
    TagsListFrame1: TTagsListFrame;
    AlClPan: TPanel;
    OutRangeSe: TFloatSpinEdit;
    OutRangeLabel: TLabel;
    HHSe: TFloatSpinEdit;
    HHLabel: TLabel;
    HSe: TFloatSpinEdit;
    HLabel: TLabel;
    LSe: TFloatSpinEdit;
    LLabel: TLabel;
    LLSe: TFloatSpinEdit;
    LLLabel: TLabel;
    OutRColor: TPanel;
    HHColor: TPanel;
    HColor: TPanel;
    LColor: TPanel;
    LLColor: TPanel;
    NormalSE: TFloatSpinEdit;
    NormalLabel: TLabel;
    NormalColor: TPanel;
    NumSe: TSpinEdit;
    NumLabel: TLabel;
    GroupNameEdit: TEdit;
    GroupNameLabel: TLabel;
    ControTaglCB: TRcComboBox;
    ControlTagLabel: TLabel;
    procedure TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
  private
    procedure UpdateTagList;
    function AddGroup:TThresholdGroup;
  public
    { Public declarations }
  end;

var
  ThresholdFrm: TThresholdFrm;

implementation

{$R *.dfm}

{ TThresholdFrm }

function TThresholdFrm.AddGroup: TThresholdGroup;
begin
  result:=TThresholdGroup.create;
  new:=AlgsTV.AddChild(n, nil);
  TagsTV.Nodes()
  result.name:=
end;

procedure TThresholdFrm.TagsTVDragDrop(Sender: TBaseVirtualTree;
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
    d:=TagsTV.GetNodeData(n);
  end
  else
  begin

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

procedure TThresholdFrm.TagsTVDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := false;
  if Source = TagsListFrame1.TagsLV then
    Accept := true;
end;

procedure TThresholdFrm.UpdateTagList;
begin
  TagsListFrame1.ShowChannels;
end;

{ TThresholdGroup }

constructor TThresholdGroup.create;
begin
  AlarmList:=TList.Create;
end;

destructor TThresholdGroup.destroy;
var
  I: Integer;
  a:TAlarms;
begin
  for I := 0 to AlarmList.Count - 1 do
  begin
    a:=TAlarms(AlarmList.Items[i]);
    a.Destroy;
  end;
  AlarmList.Destroy;
end;

end.
