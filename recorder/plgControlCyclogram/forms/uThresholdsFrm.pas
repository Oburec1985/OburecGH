unit uThresholdsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons,
  uControlEditFrame, uModeFrame, uRecorderEvents, uControlObj,
  uComponentServises,
  uAlarms,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService,
  tags, recorder, uBaseObjService, uModesTabsForm, activex, uRTrig,
  DCL_MYOWN, uRcCtrls, uTrigsFrm, uEventTypes, uCommonMath,
  uExcel, Spin, uSpin, uTagsListFrame;

type
  TAlarms = class;

  DataRec = record
    normal, HH, h, L, LL:double;
    outRange:double;
    normalCol, outRangeCol, HHCol, hCol, LCol, LLCol:integer;
    // если не valid то ставим цвет серый outRangeCol
    m_valid:boolean;
  end;

  PDataRec = ^DataRec;

  TThresholdGroup = class
  public
    // тег для переключения наборов
    ControlTag:itag;
    AlarmList:tstringlist;
    name:string;
    m_Data:array of DataRec;
    // емкость
    m_capacity:integer;
    // количество элементов
    m_size:integer;
  private
    // заполнить массив данными
    procedure fillData(from:integer; pd:PDataRec);
  public
    procedure setCount(c:integer);
    // получить запись с уставками
    function AlarmData:PDataRec;overload;
    function AlarmData(i:integer):PDataRec;overload;
    function GetAlarm(i:integer):TAlarms;
    function toString(i:integer):string;
    procedure StringToData(str:string;i:integer);
    // получить значение тега управляющего наборами
    function ControlVal:integer;
    function addtag(t:itag; var new:boolean):TAlarms;
    // обновить список аварий в тегах
    procedure ApplyAlarms;overload;
    procedure ApplyAlarms(pd:PDataRec);overload;
    constructor create;
    destructor destroy;
  end;

  TAlarms = class
  public
    owner:TThresholdGroup;
    t:itag;
    m_ACon: IAlarmsControl;
    m_a_ll,m_a_l,m_a_h,m_a_hh:IAlarm;
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
    NormalSE: TFloatSpinEdit;
    NormalLabel: TLabel;
    NormalColor: TPanel;
    NumSe: TSpinEdit;
    NumLabel: TLabel;
    GroupNameEdit: TEdit;
    GroupNameLabel: TLabel;
    ControTaglCB: TRcComboBox;
    ControlTagLabel: TLabel;
    ImageList_16: TImageList;
    NotValidCB: TCheckBox;
    CountIE: TIntEdit;
    Label1: TLabel;
    BackGroundColorDialog: TColorDialog;
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
  public
    m_selGroup:TThresholdGroup;
  private
    function AddGroup:pVirtualNode;
    procedure setData(pdata:PDataRec);

  public
    function getGroup(i:integer):TThresholdGroup;
    procedure save(fname:string);
    procedure load(fname:string);
    procedure UpdateTagList;
  end;

var
  ThresholdFrm: TThresholdFrm;

implementation

{$R *.dfm}

{TThresholdFrm}
function TThresholdFrm.AddGroup: pVirtualnode;
var
  d:pnodedata;
  g:TThresholdGroup;
begin
  g:=TThresholdGroup.create;
  result:=TagsTV.AddChild(TagsTV.rootNode, nil);
  d:=TagsTV.getNodeData(result);
  g.name:='Group_'+inttostr(result.Index);
  d.Caption:=g.name;
  d.color:=TagsTV.normalcolor;
  d.ImageIndex:=1;
  D.data:=g;
end;

procedure TThresholdFrm.CountIEChange(Sender: TObject);
begin
  NumSe.MaxValue:=CountIE.IntNum-1;
end;

function TThresholdFrm.getGroup(i:integer): TThresholdGroup;
var
  n:pvirtualnode;
  ind:integer;
begin
  ind:=0;
  n:=tagstv.RootNode.FirstChild;
  while n<>nil do
  begin
    if i=ind then
    begin
      result:=TThresholdGroup(pnodedata(tagstv.GetNodeData(n)).data);
      exit;
    end;
    n:=TagsTV.GetNext(n,false);
  end;
end;

procedure TThresholdFrm.HHColorDblClick(Sender: TObject);
begin
  if BackGroundColorDialog.Execute then
    tpanel(sender).color:=BackGroundColorDialog.Color;
end;

procedure TThresholdFrm.NumSeChange(Sender: TObject);
var
  pd:PDataRec;
begin
  if NumSe.Value<0 then
    NumSe.Value:=0
  else
  begin
    if NumSe.Value>CountIE.IntNum-1 then
      NumSe.Value:=CountIE.IntNum-1;
  end;
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
  j: Integer;
  s, str:string;
begin
  ifile:=TIniFile.Create(fname);
  ifile.WriteString('Main', 'GCount', TagsTV.RootNode.ChildCount);
  for I := 0 to TagsTV.RootNode.ChildCount - 1 do
  begin
    g:=getGroup(i);
    ifile.WriteString('G_'+inttostr(i), 'Name', g.name);
    if s<>'' then
    begin
      s:=g.ControlTag.GetName;
      ifile.WriteString('G_'+inttostr(i), 'ControlTag', s);
    end;
    ifile.WriteInteger('G_'+inttostr(i), 'Size', g.m_size);
    for j := 0 to g.m_size - 1 do
    begin
      ifile.WriteString('G_'+inttostr(i), 'Data_'+inttostr(j), g.toString(i));
    end;
    ifile.WriteInteger('G_'+inttostr(i), 'TCount', g.AlarmList.Count);
    str:='';
    for j := 0 to g.AlarmList.Count - 1 do
    begin
      a:=g.GetAlarm(j);
      s:=a.t.GetName;
      str:=str+s+';';
    end;
    ifile.WriteString('G_'+inttostr(i), 'Tags', str);
  end;
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
  c:=ifile.ReadString('Main', 'GCount', 0);
  for I := 0 to c - 1 do
  begin
    n:=AddGroup;
    d:=TagsTV.GetNodeData(n);
    g:=TThresholdGroup(d.data);
    g.name:=ifile.ReadString('G_'+inttostr(i), 'Name', g.name);
    s:=ifile.ReadString('G_'+inttostr(i), 'ControlTag', '');
    if s<>'' then
      g.ControlTag:=getTagByName(s);
    g.setCount(ifile.ReadInteger('G_'+inttostr(i), 'Size', 1));
    for j := 0 to g.m_size - 1 do
    begin
      s:=ifile.ReadString('G_'+inttostr(i),  'Data_'+inttostr(j), '10;5;-5;-10;255;2;3;255;0;1');
      g.StringToData(s,j);
    end;
    c1:=ifile.ReadInteger('G_'+inttostr(i), 'TCount', 0);
    s:=ifile.ReadString('G_'+inttostr(i), 'Tags', '');
    for j := 0 to c1 - 1 do
    begin
      s1:=getSubStrByIndex(s, ';', 1, j);
      t:=getTagByName(s1);
      a:=g.addtag(t, new);
      a.t:=t;
    end;
  end;
  ifile.Destroy;
end;

procedure TThresholdFrm.setData(pdata: PDataRec);
begin
  HHSe.Value:=pdata.HH;
  HSe.Value:=pdata.h;
  lSe.Value:=pdata.l;
  llSe.Value:=pdata.ll;
  HHColor.color:=pdata.HHCol;
  HColor.color:=pdata.HCol;
  lColor.color:=pdata.lCol;
  llColor.color:=pdata.llCol;
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
      pdata:=g.AlarmData;
      CountIE.IntNum:=g.m_size;
      setData(pdata);
      m_selGroup:=g;
    end;
    if tobject(d.Data) is TAlarms then
    begin
      a:=TAlarms(d.Data);
      pdata:=a.owner.AlarmData;
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
        new:=TagsTV.AddChild(n, nil);
        sd:=TagsTV.GetNodeData(new);
        sd.data:=a;
        sd.color:=TagsTV.normalcolor;
        sd.ImageIndex:=0;
        sd.Caption:=li.Caption;
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
  pd.HH:=HHSe.Value;
  pd.h:=HSe.Value;
  pd.l:=lSe.Value;
  pd.ll:=llSe.Value;
  pd.HHcol:=HHColor.Color;
  pd.hcol:=HColor.Color;
  pd.lcol:=lColor.Color;
  pd.llcol:=llColor.Color;
  m_selGroup.ApplyAlarms(pd);
end;

procedure TThresholdFrm.UpdateTagList;
begin
  TagsListFrame1.ShowChannels;
end;

{ TThresholdGroup }
function TThresholdGroup.addtag(t: itag; var new:boolean): TAlarms;
var
  s:string;
  a:TAlarms;
  ia:ialarm;
  i,c:integer;
  count:cardinal;
  temp_BSTR: BSTR;
  v:double;
begin
  s:=t.GetName;
  if not AlarmList.find(s, i) then
  begin
    a:=TAlarms.Create;
    a.t:=t;
    a.owner:=self;
    if FAILED(t.QueryInterface(IID_IAlarmsControl, a.m_ACon)) then
      a.m_ACon:=nil;
    a.m_ACon.GetAlarmsCount(count);
    for I := 0 to count-1 do
    begin
      a.m_ACon.GetAlarm(i, ia);
      case i of
        0:a.m_a_ll:=ia;
        1:a.m_a_l:=ia;
        2:a.m_a_h:=ia;
        3:a.m_a_hh:=ia;
      end;
    end;
    AlarmList.AddObject(s, a);
    result:=a;
    new:=true;
  end
  else
  begin
    result:=TAlarms(AlarmList.Objects[i]);
    new:=false;
  end;
  //ia.GetName(temp_BSTR);
  //ia.SetEnabled(Variant_True); // включаем уставку
  //pAlarm.SetColor(clLime);   // цвет уставки
  // устанавливаем уставку
  //ia.SetLevel((10-i));
  if AlarmList.Count=1 then
  begin
    a.m_a_hh.GetLevel(v);
    m_Data[0].HH:=v;
    a.m_a_h.GetLevel(v);
    m_Data[0].h:=v;
    a.m_a_l.GetLevel(v);
    m_Data[0].L:=v;
    a.m_a_ll.GetLevel(v);
    m_Data[0].LL:=v;
    m_Data[0].normalCol:=clWhite;
    m_Data[0].outRangeCol:=clGray;
    a.m_a_hh.GetColor(c);
    m_Data[0].HHCol:=c;
    a.m_a_h.GetColor(c);
    m_Data[0].hCol:=c;
    a.m_a_l.GetColor(c);
    m_Data[0].LCol:=c;
    a.m_a_ll.GetColor(c);
    m_Data[0].LLCol:=c;
    fillData(1, @m_Data[0]);
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

procedure TThresholdGroup.ApplyAlarms(pd: PDataRec);
var
  I: Integer;
  a:TAlarms;
begin
  for I := 0 to AlarmList.Count - 1 do
  begin
    a:=TAlarms(AlarmList.Objects[i]);
    a.m_a_ll.SetLevel(pd.LL);
    a.m_a_l.SetLevel(pd.l);
    a.m_a_h.SetLevel(pd.h);
    a.m_a_hh.SetLevel(pd.hh);
    a.m_a_ll.SetColor(pd.LLCol);
    a.m_a_l.SetColor(pd.lCol);
    a.m_a_h.SetColor(pd.hCol);
    a.m_a_hh.SetColor(pd.hhCol);
  end;
end;

procedure TThresholdGroup.ApplyAlarms;
var
  I: Integer;
  a:TAlarms;
  pd:PDataRec;
begin
  for I := 0 to AlarmList.Count - 1 do
  begin
    a:=TAlarms(AlarmList.Objects[i]);
    pd:=AlarmData;
    ApplyAlarms(pd);
  end;
end;

function TThresholdGroup.ControlVal: integer;
begin
  if ControlTag=nil then
    result:=0
  else
    result:=round(GetMean(ControlTag));
end;

constructor TThresholdGroup.create;
begin
  AlarmList:=TStringList.Create;
  AlarmList.Sorted:=true;
  m_capacity:=20;
  m_size:=1;
  setlength(m_Data,m_capacity);
  ControlTag:=nil;
end;

destructor TThresholdGroup.destroy;
var
  I: Integer;
  a:TAlarms;
begin
  for I := 0 to AlarmList.Count - 1 do
  begin
    a:=TAlarms(AlarmList.objects[i]);
    a.Destroy;
  end;
  AlarmList.Destroy;
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

function TThresholdGroup.GetAlarm(i: integer): TAlarms;
begin
  result:=TAlarms(AlarmList.Objects[i]);
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
  ind:integer;
begin
  for I := 0 to 9 do
  begin
    s:=getSubStrByIndex(str, ';',1,ind);
    case i of
      0:m_Data[i].HH:=strtofloat(s);
      1:m_Data[i].H:=strtofloat(s);
      2:m_Data[i].l:=strtofloat(s);
      3:m_Data[i].ll:=strtofloat(s);
      4:m_Data[i].HHCol:=strtoint(s);
      5:m_Data[i].HCol:=strtoint(s);
      6:m_Data[i].lCol:=strtoint(s);
      7:m_Data[i].llCol:=strtoint(s);
      8:m_Data[i].outRangeCol:=strtoint(s);
      9:
      begin
        if s='0' then
          m_Data[i].m_valid:=false
        else
          m_Data[i].m_valid:=true;
      end;
    end;
  end;
end;

function TThresholdGroup.toString(i: integer): string;
begin
  result:=floattostr(m_Data[i].HH)+';'+floattostr(m_Data[i].h)+';'
          +floattostr(m_Data[i].l)+';'+floattostr(m_Data[i].ll)+';'
          +inttostr(m_Data[i].HHCol)+';'+inttostr(m_Data[i].HCol)+';'
          +inttostr(m_Data[i].lCol)+';'+inttostr(m_Data[i].llCol)+';'
          +inttostr(m_Data[i].outRangeCol);
  if m_Data[i].m_valid then
    result:=result+';1'
  else
    result:=result+';0';
end;

end.
