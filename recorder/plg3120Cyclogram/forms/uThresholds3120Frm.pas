unit uThresholds3120Frm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons,
  uRecorderEvents,
  uComponentServises,
  uAlarms,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService,
  tags, recorder, uBaseObjService, activex,
  DCL_MYOWN, uRcCtrls, uEventTypes, uCommonMath,
  Spin, uSpin, uTagsListFrame;

type
  TAlarms = class;

  DataRec = record
    // если <>nil
    LvlTag:itag;
    normal, // используется если задавать уставки отклонением normal+-hh
    HH, h, L, LL:double;
    outRange:double;
    normalCol, outRangeCol, HHCol, hCol, LCol, LLCol:integer;
    // если не valid то ставим цвет серый outRangeCol
    m_notvalid:boolean;
  end;

  PDataRec = ^DataRec;

  AlarmHandler = class(TInterfacedObject, IAlarmEventHandler)
  public
    fAlarm:TNotifyEvent;
  public
    procedure Attach;
    procedure Detach;
    function OnAlarmEvent(pTag: ITag; pAlarm:IAlarm; nIndex:integer; dblVal:double; flags:ULONG): HRESULT;stdcall;
  end;

  TThresholdGroup = class
  public
    // использовать подгруппы
    m_useSubGroups:boolean;
    // список подгруп TThresholdGroup. Нужно например для частотного профиля
    m_SubGroups:tlist;
    owner:tstringlist;
    m_lastControlVal:integer;
    initList:boolean;
    // тег для переключения наборов
    ControlTag:ctag;
    // список TAlarms
    AlarmList:tstringlist;
    name:string;
    // данные набора прописываемые в алармы
    // номер в массиве определяется по сути номером режима с набором
    // уставок
    // не используется для профиля частот!!!
    m_Data:array of DataRec;
    // емкость
    m_capacity:integer;
    // количество элементов
    m_size:integer;
  private
    // заполнить массив данными
    procedure fillData(from:integer; pd:PDataRec);
  public
    procedure initiface;
    procedure setCount(c:integer);
    // получить запись с уставками
    function AlarmData:PDataRec;overload;
    function AlarmData(i:integer):PDataRec;overload;
    // костыль для 3120, вернет зачение опорного тега t
    function DisableAlarmByTag(a:TAlarms):double;
    function GetAlarm(i:integer):TAlarms;overload;
    function GetAlarm(s:string):TAlarms;overload;
    function toString(i:integer):string;
    procedure StringToData(str:string;i:integer);
    // получить значение тега управляющего наборами
    function ControlVal:integer;
    function addtag(t:itag; var new:boolean):TAlarms;overload;
    function addtag(tname:string; var new:boolean):TAlarms;overload;
    function addtag(tname: string; parentGroup:TThresholdGroup;var new: boolean): TAlarms; overload;
    procedure clear;
    // обновить список аварий в тегах
    procedure ApplyAlarms;overload;
    // restype - 0 - абс; 1- от задания; 2 - от канала
    procedure ApplyAlarms(pd:PDataRec; restype:integer);overload;
    function EvalAlarmLvl: double;
    procedure setEnabled(b:boolean);
    constructor create;
    destructor destroy;
  end;
  // класс отвечает за работу с алармами рекордера.
  // Создается классом TThresholdGroup в addtag
  // m_OutRangeLevel
  TAlarms = class
  public
    owner:TThresholdGroup;
    t:ctag;
    m_ACon: IAlarmsControl;
    m_a_ll,m_a_l,m_a_h,m_a_hh,
    activeA:IAlarm;
    ActiveAlInd:integer;
    // выход за допустимый диапазон
    m_OutRangeLevel:double;
    m_OutRangeEnabled:boolean;
    m_OutRange:boolean;
  protected
    procedure initTagIface;
  public
    procedure SetEnabled(b:boolean);
    function notValid:boolean;
    function notValidCol:integer;
    constructor create;
    destructor destroy;
  end;

  TThresholdFrm = class(TForm)
    BotPan: TPanel;
    AddPObjBtn: TSpeedButton;
    UpdatePObjBtn: TSpeedButton;
    LeftPan: TPanel;
    TagsTV: TVTree;
    Panel3: TPanel;
    AlClPan: TPanel;
    HHSe: TFloatSpinEdit;
    HHLabel: TLabel;
    HSe: TFloatSpinEdit;
    HLabel: TLabel;
    LSe: TFloatSpinEdit;
    LLabel: TLabel;
    LLSe: TFloatSpinEdit;
    LLLabel: TLabel;
    HHColor: TPanel;
    HColor: TPanel;
    LColor: TPanel;
    LLColor: TPanel;
    NormalLabel: TLabel;
    NormalColor: TPanel;
    NumSe: TSpinEdit;
    NumLabel: TLabel;
    GroupNameEdit: TEdit;
    GroupNameLabel: TLabel;
    ControTaglCB: TRcComboBox;
    ControlTagLabel: TLabel;
    NotValidCB: TCheckBox;
    CountIE: TIntEdit;
    Label1: TLabel;
    BackGroundColorDialog: TColorDialog;
    TagsListFrame1: TTagsListFrame;
    Restype: TRadioGroup;
    NormalValueFE: TFloatSpinEdit;
    AlarmTagCB: TRcComboBox;
    Label2: TLabel;
    procedure TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure TagsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure UpdatePObjBtnClick(Sender: TObject);
    procedure NumSeChange(Sender: TObject);
    procedure CountIEChange(Sender: TObject);
    procedure HHColorDblClick(Sender: TObject);
    procedure TagsTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
    m_AlarmHandler:AlarmHandler;
    m_Groups:TStringList;
    m_selGroup:TThresholdGroup;
    m_AlarmTag:ctag;
  private
    procedure ShowGroup(g:TThresholdGroup; parent:pVirtualNode);
    procedure setData(pdata:PDataRec);
    procedure createevents;
    procedure destroyevents;
    procedure doChangeRState(Sender: TObject);
    procedure doStart;
    procedure doStop;
    procedure ShowTV;
  public
    procedure doUpdateData(Sender: TObject);
    // пройти все аварии и найти максимальный уровень
    function EvalAlarmLvl:double;
    procedure AttachAlarms;
    function AddGroup:pVirtualNode;overload;
    function AddGroup(g: TThresholdGroup):pVirtualNode;overload;
    function getAlarm(tname:string):TAlarms;
    function getGroup(i:integer):TThresholdGroup;
    procedure save(fname:string);
    procedure load(fname:string);
    procedure UpdateTagList;
    procedure clear;
    constructor create(aowner:tcomponent);override;
    destructor destroy;
  end;

var
  ThresholdFrm: TThresholdFrm;

implementation
uses
  u3120ControlObj, uControlObj;

{$R *.dfm}

{TThresholdFrm}
function TThresholdFrm.AddGroup: pVirtualnode;
var
  d:pnodedata;
  g:TThresholdGroup;
begin
  g:=TThresholdGroup.create;
  g.name:='Group_'+inttostr(m_Groups.Count);
  m_Groups.AddObject(g.name, g);
  if TagsTV<>nil then
  begin
    result:=TagsTV.AddChild(TagsTV.rootNode, nil);
    d:=TagsTV.getNodeData(result);
    d.Caption:=g.name;
    d.color:=TagsTV.normalcolor;
    d.ImageIndex:=1;
    D.data:=g;
  end;
end;

function TThresholdFrm.AddGroup(g: TThresholdGroup): pVirtualNode;
var
  d:pnodedata;
begin
  m_Groups.AddObject(g.name, g);
  if TagsTV<>nil then
  begin
    result:=TagsTV.AddChild(TagsTV.rootNode, nil);
    d:=TagsTV.getNodeData(result);
    d.Caption:=g.name;
    d.color:=TagsTV.normalcolor;
    d.ImageIndex:=1;
    D.data:=g;
  end;
end;



procedure TThresholdFrm.clear;
var
  I: Integer;
  g:TThresholdGroup;
begin
  for I := 0 to m_Groups.Count - 1 do
  begin
    g:=TThresholdGroup(m_Groups.Objects[i]);
    g.destroy;
  end;
  m_Groups.Clear;
  TagsTV.Clear;
end;

procedure TThresholdFrm.CountIEChange(Sender: TObject);
begin
  NumSe.MaxValue:=CountIE.IntNum-1;
end;

procedure TThresholdFrm.AttachAlarms;
begin
  m_AlarmHandler:=AlarmHandler.Create;
  m_AlarmHandler.Attach;
end;

destructor TThresholdFrm.destroy;
var
  I: Integer;
  g:TThresholdGroup;
begin
  for I := 0 to m_Groups.Count - 1 do
  begin
    g:=TThresholdGroup(m_Groups.Objects[i]);
    g.destroy;
  end;
  m_Groups.Destroy;
  m_AlarmHandler.Destroy;
end;

procedure TThresholdFrm.destroyevents;
begin
  RemovePlgEvent(doUpdateData, c_RUpdateData);
end;

constructor TThresholdFrm.create(aowner: tcomponent);
begin
  inherited;
  m_AlarmTag:= cTag.create;
end;

procedure TThresholdFrm.createevents;
begin
  addplgevent('TThresholdFrm_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('TThresholdFrm_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
end;

procedure TThresholdFrm.doChangeRState(Sender: TObject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
        doStop;
      end;
    RSt_StopToView:
      begin
        doStart;
      end;
    RSt_StopToRec:
      begin
        doStart;
      end;
    RSt_ViewToStop:
      begin
        doStop;
      end;
    RSt_ViewToRec:
      begin
        // g_SRSFactory.m_meraFile := GetMeraFile;
      end;
    RSt_initToRec:
      begin
        // g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_initToView:
      begin
        // g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_RecToStop:
      begin
        doStop;
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

procedure TThresholdFrm.doUpdateData(Sender: TObject);
var
  i: integer;
  g:TThresholdGroup;
begin
  // if g_disableFRF then
  // exit;
  for i := 0 to m_Groups.Count- 1 do
  begin
    g:=TThresholdGroup(m_Groups.Objects[i]);
    g.ApplyAlarms;
  end;
  EvalAlarmLvl;
end;

procedure TThresholdFrm.FormCreate(Sender: TObject);
begin
  m_Groups:=TStringList.Create;
  createevents;
  // не забыть вызвать!!!! RCInit
  //  if ThresholdFrm <> nil then
  //  ThresholdFrm.AttachAlarms;
end;

procedure TThresholdFrm.FormShow(Sender: TObject);
begin
  // отбразить списки каналов в комбобоксах
  UpdateTagList;
  ShowTV;
end;

procedure TThresholdFrm.doStart;
var
  I, j: Integer;
  g:TThresholdGroup;
  a:TAlarms;
begin
  for i := 0 to m_Groups.Count- 1 do
  begin
    g:=TThresholdGroup(m_Groups.Objects[i]);
    if g.ControlTag.tag=nil then
      g.ControlTag.tagname:=g.ControlTag.tagname;
    g.ApplyAlarms;
    for j := 0 to g.AlarmList.Count - 1 do
    begin
      a:=TAlarms(g.AlarmList.Objects[j]);
      a.activeA:=nil;
    end;
  end;
end;

procedure TThresholdFrm.doStop;
begin

end;

function TThresholdFrm.getAlarm(tname: string): TAlarms;
var
  I: Integer;
  g:TThresholdGroup;
  a:talarms;
begin
  result:=nil;
  for I := 0 to m_Groups.Count - 1 do
  begin
    g:=getGroup(i);
    a:=g.GetAlarm(tname);
    if a<>nil then
    begin
      result:=a;
      exit;
    end;
  end;
end;

function TThresholdFrm.getGroup(i:integer): TThresholdGroup;
var
  n:pvirtualnode;
  ind:integer;
  d:pnodedata;
begin
  ind:=0;
  result:= TThresholdGroup(m_Groups.Objects[i]);
  {n:=tagstv.RootNode.FirstChild;
  while n<>nil do
  begin
    if i=ind then
    begin
      d:=pnodedata(tagstv.GetNodeData(n));
      result:=TThresholdGroup(d.data);
      exit;
    end;
    n:=TagsTV.GetNextSibling(n);
    inc(ind);
  end;}
end;

procedure TThresholdFrm.HHColorDblClick(Sender: TObject);
begin
  if BackGroundColorDialog.Execute then
    tpanel(sender).color:=BackGroundColorDialog.Color;
end;

procedure TThresholdFrm.NumSeChange(Sender: TObject);
var
  pd:PDataRec;
  p:TNotifyEvent;
begin
  if m_selGroup=nil then exit;
  p:=NumSe.OnChange;
  NumSe.OnChange:=nil;
  if (NumSe.Value<0) or (CountIE.IntNum=0) then
    NumSe.Value:=0
  else
  begin
    if NumSe.Value>CountIE.IntNum-1 then
      NumSe.Value:=CountIE.IntNum-1;
  end;
  NumSe.OnChange:=p;
  pd:=@m_selGroup.m_Data[NumSe.Value];
  setData(pd);
end;

procedure TThresholdFrm.save(fname: string);
var
  ifile:tinifile;
  I: Integer;
  n:PVirtualNode;
  d:PNodeData;
  g:TThresholdGroup;
  a:TAlarms;
  j, gCount: Integer;
  s, str:string;
begin
  ifile:=TIniFile.Create(fname);
  //ifile.WriteString('Main', 'GCount', '0');
  //exit;
  if TagsTV.RootNode.ChildCount=0 then exit;
  gCount:=0;
  for I := 0 to m_Groups.Count - 1 do
  begin
    g:=getGroup(i);
    // пропускаем служебные автосоздаваемые группы
    //if g.name='PressFrmAlarms' then
    //  continue;
    inc(gCount);
    ifile.WriteString('G_'+inttostr(i), 'Name', g.name);
    if g.ControlTag<>nil then
    begin
      s:=g.ControlTag.tagname;
      ifile.WriteString('G_'+inttostr(i), 'ControlTag', s);
    end;
    ifile.WriteInteger('G_'+inttostr(i), 'Size', g.m_size);
    for j := 0 to g.m_size - 1 do
    begin
      ifile.WriteString('G_'+inttostr(i), 'Data_'+inttostr(j), g.toString(j));
    end;
    ifile.WriteInteger('G_'+inttostr(i), 'TCount', g.AlarmList.Count);
    str:='';
    for j := 0 to g.AlarmList.Count - 1 do
    begin
      a:=g.GetAlarm(j);
      s:=a.t.tagname;
      str:=str+s+';';
    end;
    ifile.WriteString('G_'+inttostr(i), 'Tags', str);
  end;
  ifile.WriteInteger('Main', 'GCount', gCount);
  saveTagToIni(ifile,m_AlarmTag,'Main','AlarmTag');
  ifile.Destroy;
end;

procedure TThresholdFrm.load(fname: string);
var
  ifile:tinifile;
  I, j, c,c1: Integer;
  n:PVirtualNode;
  d:PNodeData;
  g:TThresholdGroup;
  s, s1:string;
  t:itag;
  new:boolean;
  a:TAlarms;
begin
  ifile:=TIniFile.Create(fname);
  c:=ifile.ReadInteger('Main', 'GCount', 0);
  if c=0 then
  begin
    ifile.destroy;
    exit;
  end;
  clear;
  LoadExTagIni(ifile,m_AlarmTag,'Main','AlarmTag');
  if m_AlarmTag.tag=nil then
  begin
    m_AlarmTag.tag:=createScalar('AlarmTag', true);
  end;
  s:=ifile.ReadString('G_'+inttostr(i), 'Name', '');
  c:=ifile.ReadInteger('Main', 'GCount', 0);
  for I := 0 to c - 1 do
  begin
    n:=AddGroup;
    d:=TagsTV.GetNodeData(n);
    g:=TThresholdGroup(d.data);
    g.name:=ifile.ReadString('G_'+inttostr(i), 'Name', g.name);
    s:=ifile.ReadString('G_'+inttostr(i), 'ControlTag', '');
    if s<>'' then
      g.ControlTag.tagname:=s;
    c:=ifile.ReadInteger('G_'+inttostr(i), 'Size', 1);
    g.setCount(c);
    for j := 0 to g.m_size - 1 do
    begin
      s:=ifile.ReadString('G_'+inttostr(i),  'Data_'+inttostr(j), '0;10;5;-5;-10;255;65535;65535;255;0;1');
      g.StringToData(s,j);
    end;
    g.initList:=true;
    c1:=ifile.ReadInteger('G_'+inttostr(i), 'TCount', 0);
    s:=ifile.ReadString('G_'+inttostr(i), 'Tags', '');
    for j := 0 to c1 - 1 do
    begin
      s1:=getSubStrByIndex(s, ';', 1, j);
      t:=getTagByName(s1);
      if t<>nil then
      begin
        a:=g.addtag(t, new);
        a.t.tag:=t;
      end
      else
      begin
        g.addtag(s1, new);
      end;
    end;
    g.setEnabled(true);
  end;
  ifile.Destroy;
end;

procedure TThresholdFrm.setData(pdata: PDataRec);
begin
  NormalValueFE.Value:=pdata.normal;
  HHSe.Value:=pdata.HH;
  HSe.Value:=pdata.h;
  lSe.Value:=pdata.l;
  llSe.Value:=pdata.ll;
  HHColor.color:=pdata.HHCol;
  HColor.color:=pdata.HCol;
  lColor.color:=pdata.lCol;
  llColor.color:=pdata.llCol;
  NotValidCB.Checked:=pdata.m_notvalid;
  NormalColor.Color:=pdata.outRangecol;
end;

procedure TThresholdFrm.ShowGroup(g:TThresholdGroup; parent:pVirtualNode);
var
  a:TAlarms;
  n, n1:pVirtualNode;
  d:pnodedata;
  j:integer;
  subG:TThresholdGroup;
  I: Integer;
begin
  if TagsTV<>nil then
  begin
    n:=TagsTV.AddChild(parent, nil);
    d:=TagsTV.getNodeData(n);
    d.Caption:=g.name;
    d.color:=TagsTV.normalcolor;
    d.ImageIndex:=1;
    D.data:=g;
  end;
  // добавляем подгруппы
  if g.m_useSubGroups then
  begin
    for I := 0 to g.m_SubGroups.Count - 1 do
    begin
      subG:=TThresholdGroup(g.m_SubGroups.Items[i]);
      ShowGroup(subG,n);
    end;
  end;
  for j := 0 to g.AlarmList.Count - 1 do
  begin
    a:=g.GetAlarm(j);
    // добавляем к узлу новые теги
    n1:=ThresholdFrm.TagsTV.AddChild(n, nil);
    d:=ThresholdFrm.TagsTV.GetNodeData(n1);
    d.data:=a;
    d.color:=ThresholdFrm.TagsTV.normalcolor;
    d.ImageIndex:=0;
    d.Caption:=a.t.tagname;
  end;
end;

procedure TThresholdFrm.ShowTV;
var
  I: Integer;
  g:TThresholdGroup;
  a:TAlarms;
  n, n1:pVirtualNode;
  d:pnodedata;
  j: Integer;
begin
  TagsTV.Clear;
  for I := 0 to m_Groups.Count - 1 do
  begin
    g:=getGroup(i);
    if TagsTV<>nil then
    begin
      ShowGroup(g, TagsTV.rootNode);
    end;
  end;
end;

procedure TThresholdFrm.TagsTVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  d:pnodedata;
  g:TThresholdGroup;
  a:TAlarms;
  pdata:PDataRec;
begin
  Node := tagsTV.GetFirstSelected(true);
  if Node <> nil then
  begin
    d:=tagsTV.GetNodeData(Node);
    if tobject(d.Data) is TThresholdGroup then
    begin
      g:=TThresholdGroup(d.Data);
      pdata:=g.AlarmData(NumSe.Value);
      CountIE.IntNum:=g.m_size;
      setData(pdata);
      m_selGroup:=g;
      if m_selGroup<>nil then
      begin
        if m_selGroup.ControlTag<>nil then
          setComboBoxItem(m_selGroup.ControlTag.tagname,ControTaglCB)
        else
          ControTaglCB.ItemIndex:=-1;
      end;
    end;
    if tobject(d.Data) is TAlarms then
    begin
      a:=TAlarms(d.Data);
      pdata:=a.owner.AlarmData(NumSe.Value);
      CountIE.IntNum:=a.owner.m_size;
      setData(pdata);
      m_selGroup:=a.owner;
    end;
  end;
end;

procedure TThresholdFrm.TagsTVDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  I: Integer;
  n, new: PVirtualNode;
  d, sd:pnodedata;
  g:TThresholdGroup;
  t:itag;
  a:TAlarms;
  newAlarm:boolean;
  li:tlistitem;
begin
  // создаем узел при необходимости
  n := Sender.DropTargetNode;
  if n<>nil then
  begin
    d:=TagsTV.GetNodeData(n);
    if not (tobject(d.data) is TThresholdGroup) then
    begin
      n:=n.Parent;
      d:=TagsTV.GetNodeData(n);
    end;
  end
  else
  begin
    n:=AddGroup;
    d:=TagsTV.getNodeData(n);
  end;
  g:=TThresholdGroup(d.data);
  // добавляем к узлу новые теги
  if source=TagsListFrame1.TagsLV then
  begin
    li:=TagsListFrame1.TagsLV.Selected;
    t:=itag(li.data);
    while li<>nil do
    begin
      a:=g.addtag(t, newAlarm);
      if newAlarm then
      begin
        //new:=TagsTV.AddChild(n, nil);
        //sd:=TagsTV.GetNodeData(new);
        //sd.data:=a;
        //sd.color:=TagsTV.normalcolor;
        //sd.ImageIndex:=0;
        //sd.Caption:=li.Caption;
        li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
        if li<>nil then
          t:=itag(li.data);
      end
      else
      begin
        li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
        if li<>nil then
          t:=itag(li.data);
      end;
    end;
    g.initiface;
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

procedure TThresholdFrm.TagsTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  node, next:pvirtualnode;
  d:pnodedata;
  g:TThresholdGroup;
  a:TAlarms;
begin
  if Key = VK_DELETE then
  begin
    Node := TagsTV.GetFirstSelected(true);
    next := TagsTV.GetNextSelected(Node, false);
    while Node <> nil do
    begin
      d:=TagsTV.GetNodeData(node);
      if tobject(d.data) is TThresholdGroup then
      begin
        g:=TThresholdGroup(d.data);
        g.destroy;
      end
      else
      begin
        a:=TAlarms(d.data);
        a.destroy;
      end;
      if next<>nil then
      begin
        next:=TagsTV.GetNextSelected(next, false);
        node:=next;
      end
      else
        node:=nil;
    end;
    tagstv.DeleteSelectedNodes;
  end;
end;

procedure TThresholdFrm.UpdatePObjBtnClick(Sender: TObject);
var
  pd:PDataRec;
begin
  if NumSe.Value>CountIE.IntNum then
  begin
    CountIE.IntNum:=NumSe.Value+1;
  end;
  m_selGroup.setCount(CountIE.IntNum);
  pd:=m_selGroup.AlarmData(NumSe.Value);
  pd.normal:=NormalValueFE.Value;
  pd.HH:=HHSe.Value;
  pd.h:=HSe.Value;
  pd.l:=lSe.Value;
  pd.ll:=llSe.Value;
  pd.HHcol:=HHColor.Color;
  pd.hcol:=HColor.Color;
  pd.lcol:=lColor.Color;
  pd.llcol:=llColor.Color;
  pd.m_notvalid:=NotValidCB.Checked;
  pd.outRangeCol:=NormalColor.Color;
  m_selGroup.ApplyAlarms(pd, 0);
  if ControTaglCB.ItemIndex>-1 then
  begin
    m_selGroup.ControlTag.tag:=ControTaglCB.gettag(ControTaglCB.ItemIndex);
  end;
end;

procedure TThresholdFrm.UpdateTagList;
begin
  TagsListFrame1.ShowChannels;
  ControTaglCB.updateTagsList;
  AlarmTagCB.updateTagsList;
  setComboBoxItem(m_AlarmTag.tagname, AlarmTagCB);
end;

{ TThresholdGroup }

function TThresholdGroup.addtag(t: itag; var new:boolean): TAlarms;
begin
  if t<>nil then
  begin
    result:=addtag(t.GetName, new);
  end
  else
    result:=nil;
end;

function TThresholdGroup.addtag(tname: string; parentGroup: TThresholdGroup;
  var new: boolean): TAlarms;
begin
  result:=parentGroup.addtag(tname, new);
end;

function TThresholdGroup.addtag(tname: string; var new: boolean): TAlarms;
var
  s:string;
  a:TAlarms;
  ia:ialarm;
  i,c:integer;
  count:cardinal;
  temp_BSTR: BSTR;
  v:double;

  n:PVirtualNode;
  d:PNodeData;
begin
  s:=tname;
  if not AlarmList.find(s, i) then
  begin
    a:=TAlarms.Create;
    a.t.tagname:=tname;
    a.owner:=self;
    if a.t.tag<>nil then
      a.initTagIface;
    AlarmList.AddObject(s, a);
    result:=a;
    new:=true;
    if ThresholdFrm<>nil then
    begin
      n:=ThresholdFrm.TagsTV.GetNodeByName(TThresholdGroup(a.owner).name);
      // добавляем к узлу новые теги
      n:=ThresholdFrm.TagsTV.AddChild(n, nil);
      d:=ThresholdFrm.TagsTV.GetNodeData(n);
      d.data:=a;
      d.color:=ThresholdFrm.TagsTV.normalcolor;
      d.ImageIndex:=0;
      d.Caption:=tname;
    end;
  end
  else
  begin
    result:=TAlarms(AlarmList.Objects[i]);
    new:=false;
  end;
end;

procedure TThresholdGroup.clear;
var
  I: Integer;
  a:TAlarms;
begin
  while AlarmList.Count<>0 do
  begin
    a:=GetAlarm(0);
    a.destroy;
  end;
  if m_useSubGroups then
  begin

  end;
end;


function TThresholdGroup.AlarmData: PDataRec;
begin
  result:=@m_Data[ControlVal];
end;


function TThresholdGroup.AlarmData(i: integer): PDataRec;
begin
  result:=@m_Data[i];
end;

function TThresholdGroup.DisableAlarmByTag(a:TAlarms):double;
var
  s:string;
  Mnum:integer;
begin
  s:=a.t.tagname;
  result:=0;
  // имя тега закодировано M1(v)... M5(v)
  if s[1]='M' then
  begin
    Mnum:=strtoint(s[2]);
    if g_Marray[Mnum-1].m_data.ModeType=mtM then
    begin
      result:=g_Marray[Mnum-1].m_Mtag.GetMeanEst;
      a.SetEnabled(true);
    end
    else
    begin
      a.SetEnabled(false);
    end;
  end
  else
  // имя тега закодировано Fm1..Fm5
  begin
    Mnum:=strtoint(s[3]);
    if g_Marray[Mnum-1].m_data.ModeType=mtN then
    begin
      result:=g_Marray[Mnum-1].m_Ntag.GetMeanEst;
      a.SetEnabled(true);
    end
    else
    begin
      a.SetEnabled(false);
    end;
  end;
end;

function TThresholdGroup.EvalAlarmLvl: double;
var
  ind,I: Integer;
  a:TAlarms;
begin
  result:=0;
  for I := 0 to AlarmList.Count - 1 do
  begin
    a:=TAlarms(AlarmList.Objects[i]);
    //    0:m_a_hh:=ia;
    //    1:m_a_h:=ia;
    //    2:m_a_l:=ia;
    //    3:m_a_ll:=ia;
    ind:=a.ActiveAlInd;
    if (ind=0) or (ind=3) then
    begin
      result:=2;
      exit;
    end;
    if (ind=1) or (ind=2) then
    begin
      result:=1;
    end;
  end;
end;

function TThresholdFrm.EvalAlarmLvl: double;
var
  ind,I: Integer;
  g:TThresholdGroup;
  res:double;
begin
  result:=0;
  for I := 0 to m_Groups.Count - 1 do
  begin
    g:=getGroup(i);
    res:=g.EvalAlarmLvl;
    if res>result then
    begin
      result:=res;
      if res>1 then
        break;
    end;
  end;
  m_AlarmTag.PushValue(result);
end;

procedure TThresholdGroup.ApplyAlarms(pd: PDataRec; restype:integer);
var
  I, Mnum: Integer;
  a:TAlarms;
  d:double;
  c:cControlObj;
  lvl:double;
begin
  for I := 0 to AlarmList.Count - 1 do
  begin
    a:=TAlarms(AlarmList.Objects[i]);
    a.SetEnabled(true);
    if pd.LvlTag<>nil then
    begin
      if restype=2 then
      begin
        DisableAlarmByTag(a);
        //d:=GetMean(pd.LvlTag);
        a.m_a_ll.SetLevel(pd.LL*d);
        a.m_a_l.SetLevel(pd.l*d);
        a.m_a_h.SetLevel(pd.h*d);
        a.m_a_hh.SetLevel(pd.hh*d);
        a.m_a_ll.SetColor(pd.LLCol);
        a.m_a_l.SetColor(pd.lCol);
        a.m_a_h.SetColor(pd.hCol);
        a.m_a_hh.SetColor(pd.hhCol);
      end;
    end
    else
    begin
      // задание цвета
      a.m_a_ll.SetColor(pd.LLCol);
      a.m_a_l.SetColor(pd.lCol);
      a.m_a_h.SetColor(pd.hCol);
      a.m_a_hh.SetColor(pd.hhCol);
      DisableAlarmByTag(a);
      if pd.normal=0 then
      begin
        a.m_a_ll.SetLevel(pd.LL);
        a.m_a_l.SetLevel(pd.l);
        a.m_a_h.SetLevel(pd.h);
        a.m_a_hh.SetLevel(pd.hh);
      end
      else // абсолютно от задания
      begin
        a.m_a_ll.SetLevel(pd.normal-pd.LL);
        a.m_a_l.SetLevel(pd.normal-pd.L);
        a.m_a_h.SetLevel(pd.normal+pd.h);
        a.m_a_hh.SetLevel(pd.normal+pd.hh);
      end;
    end;

  end;
end;


procedure TThresholdGroup.ApplyAlarms;
var
  I: Integer;
  a:TAlarms;
  pd:PDataRec;
  v:integer;
  g:TThresholdGroup;
begin
  v:=ControlVal;
  if m_useSubGroups then
  begin
    for I := 0 to m_SubGroups.Count - 1 do
    begin
      g:=TThresholdGroup(m_subGroups.Items[i]);
      pd:=@g.m_data[0];
      g.ApplyAlarms(pd, 0);
    end;
    pd:=@m_data[0];
    ApplyAlarms(pd, 0);
    exit;
  end;
  if m_lastControlVal<>v then
  begin
    m_lastControlVal:=v;
    if m_lastControlVal>-1 then
    begin
      if m_lastControlVal<m_size then
      begin
        pd:=@m_data[m_lastControlVal];
        ApplyAlarms(pd, 0);
      end;
    end;
  end;
end;

function TThresholdGroup.ControlVal: integer;
begin
  if ControlTag.tag=nil then
    result:=0
  else
    result:=round(GetMean(ControlTag.tag));
end;

constructor TThresholdGroup.create;
begin
  initList:=false;
  AlarmList:=TStringList.Create;
  AlarmList.Sorted:=true;
  m_capacity:=20;
  m_size:=1;
  setlength(m_Data,m_capacity);
  ControlTag:=cTag.create;
  ControlTag.useEcm:=false;
  m_lastControlVal:=-1;
  m_SubGroups:=tlist.create;

end;

destructor TThresholdGroup.destroy;
var
  I: Integer;
  a:TAlarms;
  g:TThresholdGroup;
begin
  for I := 0 to m_SubGroups.Count - 1 do
  begin
    g:=TThresholdGroup(m_SubGroups.Items[i]);
    g.destroy;
  end;
  m_SubGroups.Destroy;
  if owner<>nil then
  begin
    if owner.Find(name,i) then
    begin
      owner.Delete(i);
    end;
  end;
  while AlarmList.Count<>0 do
  begin
    a:=TAlarms(AlarmList.objects[0]);
    a.Destroy;
  end;
  AlarmList.Destroy;
  ControlTag.destroy;
end;

procedure TThresholdGroup.fillData(from: integer; pd: PDataRec);
var
  I: Integer;
begin
  for i := from to m_capacity - 1 do
  begin
    m_Data[i]:=pd^;
  end;
end;

function TThresholdGroup.GetAlarm(s: string): TAlarms;
var
  i:integer;
  g:TThresholdGroup;
begin
  result:=nil;
  if AlarmList.Find(s, i) then
  begin
    result:=GetAlarm(i);
    exit;
  end;
  if m_useSubGroups then
  begin
  if result=nil then
    begin
      for I := 0 to m_SubGroups.Count - 1 do
      begin
        g:=TThresholdGroup(m_SubGroups.Items[i]);
        result:=g.GetAlarm(s);
        if result<>nil then
        begin
          exit;
        end;
      end;
    end;
  end;
end;

function TThresholdGroup.GetAlarm(i: integer): TAlarms;
begin
  result:=TAlarms(AlarmList.Objects[i]);
end;

procedure TThresholdGroup.initiface;
var
  I: Integer;
  a:TAlarms;
begin
  for I := 0 to AlarmList.Count - 1 do
  begin
    a:=GetAlarm(i);
    a.initTagIface;
  end;
  ControlTag.tagname:=ControlTag.tagname;
end;

procedure TThresholdGroup.setEnabled(b: boolean);
var
  I: Integer;
  a:TAlarms;
begin
  for I := 0 to AlarmList.Count - 1 do
  begin
    a:=GetAlarm(i);
    a.SetEnabled(b);
  end;
end;

procedure TThresholdGroup.setCount(c: integer);
begin
  if m_size<c then
  begin
    if c>m_capacity then
    begin
      m_capacity:=c;
      SetLength(m_Data,c);
      fillData(m_size, @m_Data[0]);
    end;
  end;
  m_size:=c;
end;




procedure TThresholdGroup.StringToData(str: string; i: integer);
var
  s:string;
  j:integer;
begin
  for j := 0 to 9 do
  begin
    s:=getSubStrByIndex(str, ';',1,j);
    case j of
      0:m_Data[i].normal:=strtoFloatExt(s);
      1:m_Data[i].HH:=strtoFloatExt(s);
      2:m_Data[i].H:=strtoFloatExt(s);
      3:m_Data[i].l:=strtoFloatExt(s);
      4:m_Data[i].ll:=strtoFloatExt(s);
      5:m_Data[i].HHCol:=strtoint(s);
      6:m_Data[i].HCol:=strtoint(s);
      7:m_Data[i].lCol:=strtoint(s);
      8:m_Data[i].llCol:=strtoint(s);
      9:m_Data[i].outRangeCol:=strtoint(s);
      10:
      begin
        if s='0' then
          m_Data[i].m_notvalid:=false
        else
          m_Data[i].m_notvalid:=true;
      end;
    end;
  end;
end;

function TThresholdGroup.toString(i: integer): string;
begin
  result:=floattostr(m_Data[i].normal)+';'
          +floattostr(m_Data[i].HH)+';'+floattostr(m_Data[i].h)+';'
          +floattostr(m_Data[i].l)+';'+floattostr(m_Data[i].ll)+';'
          +inttostr(m_Data[i].HHCol)+';'+inttostr(m_Data[i].HCol)+';'
          +inttostr(m_Data[i].lCol)+';'+inttostr(m_Data[i].llCol)+';'
          +inttostr(m_Data[i].outRangeCol);
  if m_Data[i].m_notvalid then
    result:=result+';1'
  else
    result:=result+';0';
end;

{ TAlarms }

constructor TAlarms.create;
begin
  m_OutRange:=false;
  m_OutRangeEnabled:=true;
  t:=cTag.create;
  t.useEcm:=false;
  ActiveAlInd:=-1;
end;

destructor TAlarms.destroy;
var
  i:integer;
begin
  if owner.AlarmList.Find(t.tagname, i) then
  begin
    owner.AlarmList.Delete(i);
  end;
  t.destroy;
end;

procedure TAlarms.initTagIface;
var
  i:integer;
  ia:IAlarm;
  v:double;
  c:integer;
begin
  if t.tag=nil then
    t.tag:=getTagByName(t.tagname);
  if t.tag=nil then exit;
  if FAILED(t.tag.QueryInterface(IID_IAlarmsControl, m_ACon)) then
  begin
    m_ACon:=nil;
  end;
  if m_aCon<>nil then
  begin
  //m_ACon.GetAlarmsCount(count);
    for I := 0 to 3 do
    begin
      m_ACon.GetAlarm(i, ia);
      case i of
        0:m_a_hh:=ia;
        1:m_a_h:=ia;
        2:m_a_l:=ia;
        3:m_a_ll:=ia;
      end;
    end;
    if not owner.initList then
    begin
      owner.initList:=true;
      // если инициализируем первый тег
      if owner.AlarmList.Count=0 then
      begin
        m_a_hh.GetLevel(v);
        if owner.m_Data[0].hh=0 then
        begin
          owner.m_Data[0].HH:=v;
          owner.m_Data[0].normalCol:=clWhite;
          owner.m_Data[0].outRangeCol:=clGray;
          m_a_hh.GetColor(c);
          owner.m_Data[0].HHCol:=c;
          m_a_h.GetColor(c);
          owner.m_Data[0].hCol:=c;
          m_a_l.GetColor(c);
          owner.m_Data[0].LCol:=c;
          m_a_ll.GetColor(c);
          owner.m_Data[0].LLCol:=c;
          m_a_h.GetLevel(v);
          owner.m_Data[0].h:=v;
          m_a_l.GetLevel(v);
          owner.m_Data[0].L:=v;
          m_a_ll.GetLevel(v);
          owner.m_Data[0].LL:=v;
        end;
        owner.fillData(1, @owner.m_Data[0]);
      end;
    end;
  end;
end;

function TAlarms.notValid: boolean;
begin
  result:=owner.m_Data[owner.ControlVal].m_notvalid;
end;

function TAlarms.notValidCol: integer;
begin
  result:=owner.m_Data[owner.ControlVal].outRangeCol;
end;

procedure TAlarms.SetEnabled(b: boolean);
begin
  m_OutRangeEnabled:=b;
  if b then
  begin
    m_a_hh.SetEnabled(Variant_True);
    m_a_h.SetEnabled(Variant_True);
    m_a_l.SetEnabled(Variant_False);
    m_a_ll.SetEnabled(Variant_False);
  end
  else
  begin
    m_a_hh.SetEnabled(Variant_False);
    m_a_h.SetEnabled(Variant_False);
    m_a_l.SetEnabled(Variant_False);
    m_a_ll.SetEnabled(Variant_False);
  end;
end;

{ AlarmHandler }

procedure AlarmHandler.Attach;
var
  ir:irecorder;
  iaeh:IAlarmEventHandler;
  changed:boolean;
begin
  ir:=getIR;
  //iaeh:=self;
  if not FAILED(QueryInterface(IID_IAlarmEventHandler,iaeh)) then
  begin
    ecm(changed);
    ir.Notify(RCN_SUBSCRALARMSEVENT, cardinal(iaeh));
    if changed then
      lcm;
  end;
end;

procedure AlarmHandler.Detach;
var
  ir:irecorder;
  iaeh:IAlarmEventHandler;
  changed:boolean;
begin
  ir:=getIR;
  //iaeh:=self;
  if not FAILED(QueryInterface(IID_IAlarmEventHandler,iaeh)) then
  begin
    ecm(changed);
    ir.Notify(RCN_UNSUBSCRALARMSEVENT, cardinal(iaeh));
    if changed then
      lcm;
  end;
end;

function AlarmHandler.OnAlarmEvent(pTag: ITag; pAlarm: IAlarm;
  nIndex: integer; dblVal: double; flags: ULONG): HRESULT;
var
  I: Integer;
  //tr:cbasetrig;
  g:TThresholdGroup;
  a:talarms;
  s:string;
begin
  for I := 0 to ThresholdFrm.m_Groups.Count - 1 do
  begin
    g:=TThresholdGroup(ThresholdFrm.m_Groups.Objects[i]);
    s:=pTag.GetName;
    a:=g.GetAlarm(s);
    if a<>nil then
    begin
      nindex:=nindex-1;
      if flags>0 then
      begin
        a.activeA:=pAlarm;
        a.ActiveAlInd:=nindex;
      end
      else
      begin
        a.activeA:=nil;
        a.ActiveAlInd:=-1;
      end;
      if assigned(fAlarm) then
      begin
        fAlarm(a);
      end;
      break;
    end;
  end;
end;

end.
