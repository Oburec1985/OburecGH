unit uControlCyclogramEditFrm;

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
  uExcel
  //, uBaseAlg
  ;

type

  TControlCyclogramEditFrm = class(TForm)
    ImageList_32: TImageList;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    OpenMenu: TMenuItem;
    SaveMenu: TMenuItem;
    ImageList_16: TImageList;
    SaveDialog1: TSaveDialog;
    FormChannelsGB: TGroupBox;
    CommonPanel: TPanel;
    ActionPanel: TPanel;
    ControlsListPanel: TPanel;
    ControlsGB: TGroupBox;
    ControlsLV: TBtnListView;
    EditcontrolsListPanel: TPanel;
    AddControlBtn: TSpeedButton;
    UpdateBtn: TSpeedButton;
    ModesListPanel: TPanel;
    ModesGB: TGroupBox;
    Panel1: TPanel;
    AddPObjBtn: TSpeedButton;
    ProgramTV: TVTree;
    ControlEditFrame1: TControlEditFrame;
    Splitter2: TSplitter;
    OnTopSplitter: TSplitter;
    ChanNamesPanel: TPanel;
    FilterEdit: TEdit;
    TagsLV: TBtnListView;
    FrmTagPropLabel: TLabel;
    FrmTagPropValueEdit: TEdit;
    FrmTagPropValue: TLabel;
    FrmTagPropNameCB: TComboBox;
    UpdatePObjBtn: TSpeedButton;
    ModeFrame1: TModeFrame;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    StopTrigGB: TGroupBox;
    StopTrigLvl: TFloatEdit;
    Label2: TLabel;
    StopTrigRG: TRadioGroup;
    StopTrigCB: TRcComboBox;
    ActionsTrigs: TMenuItem;
    ApplyTrigBtn: TButton;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    AllowUserModeSelectCB: TCheckBox;
    LoadFromExcelBtn: TSpeedButton;
    SaveToExcelBtn: TSpeedButton;
    SaveDialog2: TSaveDialog;
    OpenDialog2: TOpenDialog;
    procedure AddControlBtnClick(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
    procedure ControlsLVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure SaveMenuClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddPObjBtnClick(Sender: TObject);
    procedure ProgramTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure UpdatePObjBtnClick(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure ProgramTVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ControlsLVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ModeFrame1ShowModesTabBtnClick(Sender: TObject);
    procedure ControlsLVStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure ControlsLVEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure ProgramTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure ProgramTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure ApplyTrigBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionsTrigsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
    procedure ProgramTVDblClick(Sender: TObject);
    procedure SaveToExcelBtnClick(Sender: TObject);
    procedure LoadFromExcelBtnClick(Sender: TObject);
    procedure ControlsLVCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    m_conmng: cControlMng;
    m_fileMng: cfilemng;
    m_lastfile: string;
    m_needShowControls: Boolean;

    m_dragControls: Boolean;
  private
    procedure delControl(obj:cbaseobj);
    procedure createEvents;
    procedure destroyEvents;
    procedure ShowStopTrig;
    procedure ShowChannels;
    procedure ShowControls;
    function GetSelectProg: cProgramObj;
    // �������� ��� �������� ����� ��� �������� ���������� ���������
    function CheckControlParams: Boolean;
    procedure ShowProperties;
    procedure EditControlLI(li: TListItem; con: cControlObj);
    // ���������� �������� ��������� � ����� �����������
    procedure ShowControlProps();
    procedure ShowProgObjProps();

    procedure doPlgEdit(Sender: TObject);
    procedure doUpdateCfg(Sender: TObject);
    procedure save(path: string);
    procedure showprogramInTV;
  public
    procedure load(path: string);
    procedure saveUI;
    procedure LoadUI;
    procedure LinkPlg(p_conmng: cControlMng);
    procedure UnLinkPlg;
    function CreateControl: cControlObj;
  end;

const
  c_ExcelPage = '������� ������������';
  c_modeColCount = 5;

var
  ControlCyclogramEditFrm: TControlCyclogramEditFrm;

procedure ShowProgramsTV(tv: TVTree; mng: cControlMng; image: TImageList);

implementation
uses
  uControlDeskFrm;

{$R *.dfm}
{ TControlCyclogramEditFrm }

procedure ShowProgramsTV(tv: TVTree; mng: cControlMng; image: TImageList);
var
  I: Integer;
begin
  showInVTreeView(tv, mng.programs, image);
end;

procedure TControlCyclogramEditFrm.showprogramInTV;
begin
  ShowProgramsTV(ProgramTV, m_conmng, ImageList_16);
end;

procedure TControlCyclogramEditFrm.ActionsTrigsClick(Sender: TObject);
begin
  TrigsFrm.ShowModal;
end;

procedure TControlCyclogramEditFrm.AddControlBtnClick(Sender: TObject);
var
  con: cControlObj;
  li: TListItem;
begin
  con := CreateControl;
  if con <> nil then
  begin
    li := ControlsLV.Items.Add;
    EditControlLI(li, con);
    LVChange(ControlsLV);
  end;
  g_conmng.configChanged := true;
end;

procedure TControlCyclogramEditFrm.EditControlLI(li: TListItem;
  con: cControlObj);
begin
  li.Data := con;
  li.ImageIndex := con.ImageIndex;
  ControlsLV.SetSubItemByColumnName('�', inttostr(li.index + 1), li);
  ControlsLV.SetSubItemByColumnName('���', con.name, li);
  ControlsLV.SetSubItemByColumnName('���', con.TypeString, li);
  ControlsLV.SetSubItemByColumnName('��������', con.Properties, li);
end;

procedure TControlCyclogramEditFrm.FilterEditChange(Sender: TObject);
begin
  ShowChannels;
end;

procedure TControlCyclogramEditFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  saveUI;
end;

function testDocFileName(str: string): Boolean;
begin
  // �������, ������� ��������� ����� �� ���������� ��������� �� ����� ����� � ����
  result := fileexists(extractfiledir(application.ExeName)
      + '\files\������������\' + str);
end;


procedure TControlCyclogramEditFrm.FormCreate(Sender: TObject);
begin
  m_fileMng := cfilemng.Create(g_startdir + '\ControlCyclogram.ini', MainMenu1,
    '����', testDocFileName);
    m_needShowControls:=true;
end;

procedure TControlCyclogramEditFrm.FormDestroy(Sender: TObject);
begin
  m_fileMng.Destroy;
  m_fileMng:=nil;
end;

function TControlCyclogramEditFrm.GetSelectProg: cProgramObj;
var
  n: PVirtualNode;
  d: PNodeData;
  p: cProgramObj;
begin
  result:=nil;
  n := GetSelectNode(ProgramTV);
  if n <> nil then
  begin
    d := ProgramTV.GetNodeData(n);
    if tobject(d.Data) is cProgramObj then
    begin
      p := cProgramObj(d.Data);
      result:=p;
    end
    else
    begin
      if tobject(d.Data) is cControlObj then
      begin
        n:=n.Parent.parent;
        d := ProgramTV.GetNodeData(n);
        p := cProgramObj(d.Data);
        result:=p;
      end
    end;
  end;
end;

function TControlCyclogramEditFrm.CheckControlParams: Boolean;
begin
  result := ControlEditFrame1.CheckControlName;
end;

procedure TControlCyclogramEditFrm.ControlsLVCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  r:trect;
  str:string;
  i:integer;
begin
  if Item.Selected and not (cdsFocused in State) then
  begin
    DefaultDraw:=false;
    r:=Item.DisplayRect(drBounds);
    with TListView(sender).Canvas do
    begin
      Brush.Color:=clHighlight;
      FillRect(r);
      Brush.Color:=clHighlightText;
      Color:=TListView(sender).Canvas.Font.Color;
      TListView(sender).Canvas.Font.Color:=clWhite;

      str:=item.Caption;
      for I := 0 to item.SubItems.Count - 1 do
      begin
        str:=str+ ' ' +item.SubItems[i];
      end;

      TextOut(r.Left,R.Top,str);
      TListView(sender).Canvas.Font.Color:=Color;
    end;
  end
  else
  begin
    DefaultDraw:=true;
  end;
end;

procedure TControlCyclogramEditFrm.ControlsLVEndDrag(Sender, Target: TObject;
  X, Y: Integer);
begin
  m_dragControls := false;
  StatusBar1.Panels[1].text := '';
end;

procedure TControlCyclogramEditFrm.ControlsLVKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  I: Integer;
  li, next: TListItem;
  obj: cbaseobj;
begin
  if Key = VK_DELETE then
  begin
    li:=ControlsLV.Selected;
    while li<>nil do
    begin
      obj:=cbaseobj(li.data);
      next:=ControlsLV.GetNextItem(li,sdAll,[isSelected]);
      delControl(obj);
      li:=next;
    end;
  end;
  ShowControlProps;
end;

procedure TControlCyclogramEditFrm.ControlsLVSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  con: cControlObj;
  li: TListItem;
begin
  ControlEditFrame1.EndControlsMS;
  ShowControlProps;
  li := ControlsLV.Selected;
  if li <> nil then
  begin
    if ControlsLV.SelCount > 1 then
    begin
      StatusBar1.Panels[1].text := '������� �����������: ' + inttostr
        (ControlsLV.SelCount);
    end
    else
    begin
      con := cControlObj(li.Data);
      StatusBar1.Panels[1].text := '������ ���������: ' + con.name;
    end;
  end
  else
  begin
    StatusBar1.Panels[1].text := '';
  end;
end;

procedure TControlCyclogramEditFrm.ControlsLVStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  m_dragControls := true;
  StatusBar1.Panels[1].text := '���������� ���������� �� ������ ���������';
end;

function TControlCyclogramEditFrm.CreateControl: cControlObj;
begin
  result := ControlEditFrame1.CreateControl(m_conmng);
end;

procedure TControlCyclogramEditFrm.ShowProperties;
begin
  AllowUserModeSelectCB.Checked:=g_conmng.AllowUserModeSelect;

  ShowChannels;
  ShowControls;
  ShowStopTrig;
  showprogramInTV;
  ControlEditFrame1.Show;
  ModeFrame1.Show;
end;

procedure TControlCyclogramEditFrm.ShowStopTrig;
begin
  if g_conmng.StopTrigger<>nil then
  begin
    setComboBoxItem(crtrig(g_conmng.StopTrigger).channame,StopTrigCB);
    StopTrigRG.itemindex:=TrigTypeToInt(crtrig(g_conmng.StopTrigger).Trigtype);
    StopTrigLvl.FloatNum:=crtrig(g_conmng.StopTrigger).Threshold;
  end
  else
  begin
    StopTrigCB.ItemIndex:=-1;
  end;
end;

function getProgramNodeFromChildNode(n:pvirtualnode;tv:tvtree):pvirtualnode;
var
  d:pnodedata;
begin
  result:=nil;
  while (n<>nil) or (n<>tv.RootNode) do
  begin
    d:=tv.GetNodeData(n);
    if d.data<>nil then
    begin
      if tobject(d.data) is cProgramObj then
      begin
        result:=n;
        exit;
      end;
    end;
    n:=n.Parent;
  end;
end;

function getProgramFromChildNode(n:pvirtualnode;tv:tvtree):cProgramObj;
var
  d:pnodedata;
begin
  n:=getProgramNodeFromChildNode(n, tv);
  result:=nil;
  if n<>nil then
  begin
    d:=tv.GetNodeData(n);
    if tobject(d.data) is cProgramObj then
    begin
      result:=cProgramObj(d.data);
      exit;
    end;
  end;
end;

function getSelectModeFromTV(tv:tvtree):cmodeobj;
var
  selectNode:pVirtualNode;
  d:pnodedata;
  p:cprogramobj;
begin
  result:=nil;
  selectNode:=GetSelectNode(tv);
  if selectnode=nil then
  begin
    if g_conmng.ProgramCount > 0 then
    begin
      p := g_conmng.getProgram(0);
      selectNode:=tv.GetNodeByPointer(p);
    end;
  end;
  if selectnode<>nil then
  begin
    d:=tv.GetNodeData(selectnode);
    if d.data<>nil then
    begin
      if tobject(d.data) is cmodeobj then
      begin
        result:=cmodeobj(d.data);
      end;
    end;
  end;
end;

procedure TControlCyclogramEditFrm.AddPObjBtnClick(Sender: TObject);
var
  rootNode, progNode, n, modenode:pVirtualNode;
  root, o: cbaseobj;
  selMode:cmodeobj;
  d:pnodedata;
begin
  root := GetSelectObjectFromVTV(ProgramTV);
  rootNode:=GetSelectNode(ProgramTV);
  if rootNode = nil then
  begin
    if ModeFrame1.PageControl1.ActivePageIndex = 1 then
    begin
      if g_conmng.ProgramCount > 0 then
      begin
        root := g_conmng.getProgram(0);
        rootNode:=ProgramTV.GetNodeByPointer(root);
      end;
    end;
  end;
if root = nil then
  begin
    if ModeFrame1.PageControl1.TabIndex=1 then
    begin
      showmessage('��������� ������� ���������!');
      exit;
    end;
  end;
  o := ModeFrame1.CreateObj;
  if o is cModeObj then
  begin
    if not(root is cProgramObj) then
    begin
      root := getProgramFromChildNode(rootnode, ProgramTV);//root.GetParentByClassName(cProgramObj.ClassName);
    end;
    if root is cProgramObj then
    begin
      progNode:=getProgramNodeFromChildNode(rootnode, ProgramTV);
      selMode:=getSelectModeFromTV(ProgramTV);
      if selmode=nil then
      begin
        cProgramObj(root).addMode(cModeObj(o));
        n:=ProgramTV.AddChild(progNode, nil);
        d:=ProgramTV.GetNodeData(n);
        d.ImageIndex:=cModeObj(o).imageindex;
        d.Caption:=cModeObj(o).caption;
      end
      else
      begin
        cProgramObj(root).insertMode(cModeObj(o),selmode.Mindex+1);
        modenode:=ProgramTV.GetNodeByPointer(selmode);
        //n:=ProgramTV.InsertNode(modenode, amInsertBefore, nil);
        n:=ProgramTV.InsertNode(modenode, amInsertAfter, nil);
        d:=ProgramTV.GetNodeData(n);
        d.ImageIndex:=cModeObj(o).imageindex;
        d.Caption:=cModeObj(o).caption;
      end;
      d.color:=ProgramTV.normalcolor;
      d.data:=o;
      //ShowBaseObjectInVTreeView(ProgramTV,o, progNode);
      //ShowProgramInTV;
    end
    else
    begin
      o.destroy;
      showmessage('��� �������� ������ ����� ������� ������� ���������');
      exit;
    end;
  end;
  if o is cProgramObj then
  begin
    m_conmng.Add(o);
    ShowBaseObjectInVTreeView(ProgramTV,o, nil);
  end;
  //showprogramInTV;
  g_conmng.configChanged := true;
end;

procedure TControlCyclogramEditFrm.ApplyTrigBtnClick(Sender: TObject);
var
  t:crtrig;
begin
  g_conmng.AllowUserModeSelect:=AllowUserModeSelectcb.Checked;
  if g_conmng.StopTrigger<>nil then
  begin

    if StopTrigCB.text<>'' then
    begin
      crTrig(g_conmng.StopTrigger).setchannel(StopTrigCB.text);
    end
    else
    begin
      g_conmng.StopTrigger:=nil;
    end;
  end
  else
  begin
    if StopTrigCB.text<>'' then
    begin
      t:=cRTrig.create(g_conmng);
      crTrig(t).setchannel(StopTrigCB.text);
      g_conmng.StopTrigger:=t;
      t.name:='CommonStopTrig';
      t.Trigtype:=IntToTrigType(StopTrigRG.ItemIndex);
      t.Threshold:=StopTrigLvl.FloatNum;
      g_conmng.addtrig(t);
    end
  end;
end;

procedure TControlCyclogramEditFrm.createEvents;
begin
  AddPlgEvent('TControlCyclogramEditFrm_EditPlg', c_RC_PlgEdit, doPlgEdit);
  //TExtRecorderPack(GPluginInstance).EList.AddEvent('TControlCyclogramEditFrm_EditPlg', c_RC_PlgEdit, doPlgEdit);
  if g_conmng<>nil then
    g_conmng.Events.AddEvent('TControlCyclogramEditFrm_UpdateCfg',E_OnEngUpdateList+E_OnChangeCfg, doUpdateCfg);
end;

procedure TControlCyclogramEditFrm.destroyEvents;
begin
  RemovePlgEvent(doPlgEdit, c_RC_PlgEdit);
  //TExtRecorderPack(GPluginInstance).EList.removeEvent(doPlgEdit, c_RC_PlgEdit);
  if g_conmng<>nil then
    g_conmng.Events.removeEvent(doUpdateCfg, E_OnEngUpdateList+E_OnChangeCfg);
end;

procedure TControlCyclogramEditFrm.delControl(obj: cbaseobj);
var
  I: Integer;
  li:tlistitem;
  n:pvirtualnode;
begin
  // �������� �� ������� ���������
  for I := 0 to ControlsLV.items.Count - 1 do
  begin
    li:=controlsLV.items[i];
    if li.data=obj then
    begin
      li.Destroy;
      break;
    end;
  end;
  // �������� �� ������
  n:=ProgramTV.GetNodeByPointer(obj);
  if n<>nil then
  begin
    ProgramTV.DeleteNode(n);
  end;
  obj.destroy;
end;

procedure TControlCyclogramEditFrm.save(path: string);
begin
  m_lastfile := path;
  m_conmng.SaveToXML(path, 'ControlCyclogram');
end;

procedure TControlCyclogramEditFrm.load(path: string);
begin
  if g_conmng <> nil then
  begin
    m_conmng.LoadFromXML(path, 'ControlCyclogram');
  end;
end;

procedure TControlCyclogramEditFrm.ShowControls;
var
  I: Integer;
  obj: cbaseobj;
  li: TListItem;
begin
  if m_needShowControls then
  begin
    tagsToCB(g_ir, stoptrigcb);
    ControlsLV.Clear;
    for I := 0 to m_conmng.Count - 1 do
    begin
      obj := m_conmng.GetObj(I);
      if obj is cControlObj then
      begin
        li := ControlsLV.Items.Add;
        EditControlLI(li, cControlObj(obj));
      end;
    end;
    LVChange(ControlsLV);
    m_needShowControls := false;
  end;
end;

procedure TControlCyclogramEditFrm.SaveMenuClick(Sender: TObject);
begin
  if SaveDialog1.Execute(0) then
  begin
    save(SaveDialog1.filename);
    m_fileMng.AddfilePath(SaveDialog1.filename);
  end;
end;


procedure TControlCyclogramEditFrm.OpenMenuClick(Sender: TObject);
begin
  OpenDialog1.FileName:=m_lastfile;
  if OpenDialog1.Execute() then
  begin
    m_lastfile:=OpenDialog1.FileName;
    load(OpenDialog1.FileName);
    ShowControls;
    showprogramInTV;
  end;
end;

procedure TControlCyclogramEditFrm.doPlgEdit(Sender: TObject);
begin
  ShowProperties;
  // show;
  // FormStyle:=fsStayOnTop;
  if ShowModal = mrOk then
  begin

  end;
end;

procedure TControlCyclogramEditFrm.doUpdateCfg(Sender: TObject);
begin
  m_needShowControls := true;
end;

procedure TControlCyclogramEditFrm.LinkPlg(p_conmng: cControlMng);
begin
  m_conmng := p_conmng;
  if p_conmng=nil then exit;

  ModeFrame1.LinkMng(p_conmng);

  createEvents;
end;


procedure TControlCyclogramEditFrm.SaveToExcelBtnClick(Sender: TObject);
var
  rng, fname, str, str1, str2:string;
  rngObj, sheet: olevariant;
  p:cprogramObj;
  m:cmodeobj;
  con: cControlObj;
  t:ctask;
  z:cZone;
  pair:TTagPair;
  ind, ind1, r, c, I, j,k: Integer;
  pars:tstringlist;
begin
  p:=g_conmng.getProgram(0);
  if p=nil then exit;

  if SaveDialog2.Execute then
  begin
    fname:=SaveDialog2.FileName;
    str:='';
    for I := length(fname) downto 1 do
    begin
      if fname[i]='.' then
      begin
        str:=Copy(fname, i, length(fname)-i);
        break;
      end;
    end;
    if str='' then
    begin
      fname:=fname+'.xlsx';
    end;
    if not CheckExcelInstall then
    begin
      showmessage('���������� ��������� Excel');
      exit;
    end;
    CreateExcel;
    VisibleExcel(false);

    if fileexists(fname) then
    begin
      OpenWorkBook(fname);
      E.ActiveWorkbook.Sheets.Item[1].cells.clear;
    end
    else
    begin
      AddWorkBook;
      AddSheet(c_ExcelPage);
      DeleteSheet(2);
    end;
    // ���������� �������� ������ 3-� ����� A1
    // SetRange(1,'A1',234.45);
    rng := GetRange(1, 'A1');
    // ������� ����� ������
    r:=1; c:=1;
    setCell(1, r, c, '���������');
    r:=r+1;
    setCell(1, r, c, p.name);
    r:=1; c:=2;
    setCell(1, r, c, '������');
    if ControlDeskFrm<>nil then
    begin
      ind:=ControlDeskFrm.TimeUnitsCB.ItemIndex;
      case ControlDeskFrm.TimeUnitsCB.ItemIndex of
        0: setCell(1, r+1, c, '������������, ���');
        1: setCell(1, r+1, c, '������������, ���');
        2: setCell(1, r+1, c, '������������, ���');
      end;
    end
    else
    begin
      ind:=0;
      setCell(1, r+1, c, '������������, ���');
    end;
    setCell(1, r+2, c, '����������');
    setCell(1, r+2, c+1, '�������');
    setCell(1, r+2, c+2, '��');
    setCell(1, r+2, c+3, '����');
    for I := 0 to p.ControlCount - 1 do
    begin
      con:=p.getOwnControl(i);
      setCell(1, r+3+i, c, con.name);
      // ����� �������
      str:=cDacControl(con).dacname;
      str1:=con.TagsToString;
      pars:=ParsStrParam(str1,',');
      for k := 0 to pars.Count - 1 do
      begin
        str:=str+char(10)+pars.Strings[k];
        cstring(pars.Objects[k]).Destroy;
      end;
      pars.Destroy;
      setCell(1, r+3+i, c+1, str);
      // ����� ��
      setCell(1, r+3+i, c+2, con.feedbackname);
      z:=con.m_ZoneList.DefaultZone;
      str:='';
      for j := 0 to z.tags.Count - 1 do
      begin
        pair:=z.GetZonePair(j);
        str:=str+itag(pair.tag).GetName;
        if j<>z.tags.Count - 1 then
          str:=str+char(10);
      end;
      setCell(1, r+3+i, c+3, str);
    end;
    c:=6;
    // ������ �� �������
    for I := 0 to p.ModeCount - 1 do
    begin
      m:=p.getMode(i);
      setCell(1, r, c+i*c_modeColCount, m.name);
      setCell(1, r+1, c+i*c_modeColCount, SecToTime (m.modelength, ind));
      setCell(1, r+2, c+i*c_modeColCount, '�������');
      setCell(1, r+2, c+i*c_modeColCount+1, 'Thi_���');
      setCell(1, r+2, c+i*c_modeColCount+2, 'Tlo_���');
      setCell(1, r+2, c+i*c_modeColCount+3, '����');
      setCell(1, r+2, c+i*c_modeColCount+4, '��������');
      // ������ �� ���������
      for j := 0 to p.ControlCount - 1 do
      begin
        con:=p.getOwnControl(j);
        t:=m.gettask(con.name);
        // �������
        str:=floattostr(t.task);
        str1:=t.TagsToString;
        str1:=DeleteChars(str1, '"');
        pars:=ParsStrParam(str1, ',');
        for k := 0 to pars.Count - 1 do
        begin
          str:=str+char(10)+cstring(pars.Objects[k]).str;
          cstring(pars.Objects[k]).destroy;
        end;
        pars.Destroy;
        setCell(1, r+3+j, c+i*c_modeColCount, str);
        // hi ���
        str:=t.getParam('PWM_Thi');
        setCell(1, r+3+j, c+i*c_modeColCount+1, str);
        str:=t.getParam('PWM_Tlo');
        setCell(1, r+3+j, c+i*c_modeColCount+2, str);
        // ��� ����
        str:=t.getParam('Zone_state');
        setCell(1, r+3+j, c+i*c_modeColCount+3, str);
        // ���� ��������� ���������� ��� ��� ��������� :(
        str:=t.getParam('Vals');
        ind:=0;
        str:=replaceChar(str, '_', char(10));
        str:=replaceChar(str, ':', '=');
        setCell(1, r+3+j, c+i*c_modeColCount+4, str);
      end;
    end;
    try
      SaveWorkBookAs(fname);
    except
      showmessage(
        '�� ������� ��������� �����. ������������� ������� ��� ���� ������� �� ������');
    end;
    CloseWorkBook;
    CloseExcel;
  end;
end;
// ���������� ����� �����
Function LoadTags(str:string; c:cControlObj):integer;
var
  p:integer;
  str1:string;
  t:itag;
begin
  result:=0;
  p:=0;
  while p<>-1 do
  begin
    str1:=GetSubString(str, char(10), p+1, p);
    if result=0 then
    begin
      t:=getTagByName(str1);
      if t<>nil then
        cDacControl(c).dac:=t;
    end
    else
    begin
      c.addTag(str1, 0);
    end;
    inc(result);
  end;
end;

Function LoadTask(str:string; m:cModeObj; c:cControlObj):ctask;
var
  i,p:integer;
  str1, vals:string;
  t:ctask;
  tag, TaskTag:cTagPair;
begin
  vals:='';
  i:=0;
  p:=0;
  while p<>-1 do
  begin
    str1:=GetSubString(str, char(10), p+1, p);
    if i=0 then
    begin
      t:=m.createTask(c, strtofloatext(str1));
      result:=t;
    end
    else
    begin
      tag:=c.getTag(i-1);
      if tag=nil then
        continue;
      if (i-1)>0 then
        vals:=vals+';';
      vals:=vals+tag.name+'='+str1;
      TaskTag:=cTagPair.create;
      TaskTag.name:=tag.name;
      TaskTag.value:=strtofloat(str1);
      t.m_tags.AddObject(tag.name, TaskTag);
    end;
    inc(i);
  end;
  if vals<>'' then
  begin
    t.setParam('TagsVals', '"'+vals+'"');
  end;
end;

procedure TControlCyclogramEditFrm.LoadFromExcelBtnClick(Sender: TObject);
var
  list:tlist;
  fname, str, str1, params:string;
  sh, rngObj: olevariant;
  i,j, index, lastrow, lastcol, modeInd, timeUnits:integer;
  l_b:boolean;
  con:cControlObj;
  p:cProgramObj;
  m:cmodeobj;
  T:ctask;
  pars:tstringlist; parsRecord:cstring;
  z:cZone;
  pair:TTagPair;

  trig:cRtrig;
  action:TTrigAction;
begin
  if OpenDialog2.Execute then
  begin
    CreateExcel;
    VisibleExcel(false);
    fname:=OpenDialog2.FileName;
    if fileexists(fname) then
    begin
      OpenWorkBook(fname);
      sh:=E.ActiveWorkbook.Sheets.Item[1];
      LastRow:= sh.UsedRange.Rows.count;
      LastCol:= sh.UsedRange.Columns.count;
      g_conmng.controls.clear;
      p:=g_conmng.getProgram(0);
      // �������� ��������� ���� �� �������
      if p=nil then
      begin
        p:=cProgramObj.create;
        p.name:='Prog_01';
        p.RepeatCount:=1;
        p.m_StartOnPlay:=true;
        p.m_enableOnStart:=true;
        p.CreateStateTag;
        g_conmng.Add(p);
      end
      else
      begin
        p.removeOwnControls;
        p.ClearModes;
      end;
      list:=tlist.create;
      // ��������� ��������
      for I := 4 to LastRow do
      begin
        str:=sh.Cells[i, 2];
        if str='' then
        begin
          continue;
          //list.Add(nil);
        end;
        con:=g_conmng.getControlObj(str);
        if con=nil then
        begin
          con:=g_conmng.createControl(str, cDacControl.ClassName);
          list.Add(con);
          // ��������� �������
          str:=sh.Cells[i, 3];
          LoadTags(str, con);
          // ��������� feedback
          str:=sh.Cells[i, 4];
          cDacControl(con).config(getTagByName(str), nil);
          p.AddControl(con);
          // ��������� ������ ����� ��� ������ �� ����� �������������
          str:=sh.Cells[i, 5];
          str:=ReplaceChar(str, char(10), ',');
          if str<>'' then
          begin
            index:=0;
            z:=con.m_ZoneList.GetZone(0);
            z.cleartags;
            while index<length(str) do
            begin
              str1:=GetSubString(str,',',index+1, index);
              pair.tag:=pointer(getTagByName(str1));
              pair.value:=0;
              if pair.tag<>nil then
                z.AddZonePair(pair);
              if index=-1 then
                break;
            end;
            con.m_ZoneList.createPairInf;
          end;
        end;
      end;
      // ������ �� �������
      modeInd:=0;

      str:=sh.Cells[2,2];
      if pos('���', str)>0 then
      begin
        timeUnits:=0;
      end
      else
      begin
        if pos('���', str)>0 then
        begin
          timeUnits:=1;
        end
        else
        begin
          if pos('���', str)>0 then
          begin
            timeUnits:=2;
          end
          else
          begin
            timeUnits:=0;
          end;
        end;
      end;

      while c_modeColCount+modeind*c_modeColCount<lastCol do
      begin
        // ��� ������
        str:=sh.Cells[1,6+modeInd*c_modeColCount];
        if str='' then break;
        m:=cModeObj.create;
        m.name:=str;
        l_b:=false;
        p.addmode(m);
        // �������� ��������
        if m.name='����' then
        begin
          trig:=g_conmng.getTrig('����');
          if trig=nil then
          begin
            trig:=cRTrig.create(nil);
            trig.name:='����';
            trig.m_actions := TList.Create;
            trig.Trigtype:=trStop_cyclogram;
            g_conmng.addtrig(trig);
            action:=TTrigAction.Create(trig);
            action.opertype := c_action_Start;
            action.m_target:=m;
            trig.addAction(action);
          end
          else
          begin
            action:=trig.getaction(0);
            if action<>nil then
            begin
              action.m_target:=m;
            end;
          end;
        end;
        // ������������ ������
        str:=sh.Cells[2,6+modeInd*c_modeColCount];
        if str<>'' then
          m.ModeLength:=toSec(StrToFloat(str), timeUnits);
        m.Infinity:=false;
        m.CheckThreshold:=false;
        cmodeobj(m).CheckLength:=0;
        for j := 0 to p.ControlCount - 1 do
        begin
          //con:=p.getOwnControl(j);
          con:=cControlObj(list.Items[j]);
          params:='';
          // ������� ��������
          str:=sh.Cells[j+4,6+modeind*c_modeColCount];
          if str<>'' then
          begin
            t:=loadtask(str, m, con);
          end
          else
            continue;
          // Thi_���
          str:=sh.Cells[j+4,6+1+modeind*c_modeColCount];
          if str<>'' then
          begin
            params:=params+'PWM_Thi='+str+',';
          end;
          // Tlo_���
          str:=sh.Cells[j+4,6+2+modeind*c_modeColCount];
          if str<>'' then
          begin
            params:=params+'PWM_Tlo='+str+',';
          end;
          // ����
          str:=sh.Cells[j+4,6+3+modeind*c_modeColCount];
          if str<>'' then
          begin
            // �������� �� ���/ ����
            if pos('��', str)<1 then
            begin
              str:='����';
              params:=params+'Zone_state='+str+',';
              if not l_b then
              begin
                showmessage('�������� ������ ������, ������� ����, �����: '+m.name);
                l_b:=true;
              end;
            end
            else
              params:=params+'Zone_state='+str+',';
          end;
          // �������� ������ "32�42; 50" ��� 50 - �������� ��� ������� ����
          str:=sh.Cells[j+4,6+4+modeind*c_modeColCount];
          if str<>'' then
          begin
            // or (pos('�', str)=2)
            if pos('.', str)<1  then // ���� �� ����� �����
            begin
              if pos('�', str)>0 then // � �� ����� ���������
              begin
              end
              else
              begin
                if not l_b then
                begin
                  showmessage('�������� ������ ������, ������� ��������, �����: '+m.name);
                  l_b:=true;
                end;
              end;
              // str:='0...0;'; // ���� ������� �������� ������?
              params:=params+'Vals='+str+',';
            end
            else
            begin
              index:=0;
              fname:=ReplaseChars(str, ',', '.');
              fname:=ReplaseChars(fname, char(10), '_');
              fname:=ReplaseChars(fname, '=', ':');
              params:=params+'Vals='+fname+',';
            end;
          end;
          updateParams(t.m_params, params, ',');
          //t.params:=params;
        end;
        inc(modeind);
      end;
      list.destroy;
    end;
    g_conmng.configChanged := true;
    ShowProperties;
    CloseWorkBook;
    CloseExcel;
  end;
end;

procedure TControlCyclogramEditFrm.LoadUI;
var
  f: tinifile;
begin
  f := tinifile.Create(g_startdir + '\ControlCyclogram.ini');
  m_lastfile := f.ReadString('UIControlCyclogram', 'LastFile', '');
  ModeFrame1.load(f, 'UIControlCyclogram');
  ControlEditFrame1.load(f, 'UIControlCyclogram');
  f.destroy;
end;

procedure TControlCyclogramEditFrm.ModeFrame1ShowModesTabBtnClick
  (Sender: TObject);
begin
  ModeFrame1.m_prog:=GetSelectProg;
  ModeFrame1.ShowModesTabBtnClick(Sender);
end;

procedure TControlCyclogramEditFrm.ProgramTVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  obj: cbaseobj;
  n: PVirtualNode;
  Data: PNodeData;
begin
  ShowProgObjProps;
  n := GetSelectNode(ProgramTV);
  Data := ProgramTV.GetNodeData(n);
  if Data <> nil then
  begin
    obj := cbaseobj(Data.Data);
    if obj is cProgramObj then
    begin
      ModeFrame1.m_prog := cProgramObj(obj);
      ModeFrame1.PageControl1.ActivePageIndex:=0;
    end;
    if obj is cModeObj then
    begin
      ModeFrame1.m_prog := cProgramObj(obj.mainParent);
      ModeFrame1.PageControl1.ActivePageIndex:=1;
    end;
  end;
end;

function FindProgramControlsNode(progNode: PVirtualNode): PVirtualNode;
var
  I: Integer;
begin
  result := progNode.FirstChild;
end;

procedure TControlCyclogramEditFrm.ProgramTVDblClick(Sender: TObject);
var
  n:pvirtualnode;
  d:PNodeData;
  p:cprogramobj;
begin
  n := GetSelectNode(ProgramTV);
  if n <> nil then
  begin
    d := ProgramTV.GetNodeData(n);
    if tobject(d.data) is cProgramObj then
    begin
      p := cProgramObj(d.Data);
      ModesTabForm.Show(p);
    end;
  end;
end;

procedure TControlCyclogramEditFrm.ProgramTVDragDrop
  (Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject;
  Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer;
  Mode: TDropMode);
var
  I: Integer;
  li: TListItem;
  p: cProgramObj;
  c: cControlObj;
  n, controlsNode, child: PVirtualNode;
  d: PNodeData;
begin
  // ������������� vcl ���������
  if DataObject = nil then
  begin
    if Source = ControlsLV then
    begin
      I := 0;
      n := Sender.DropTargetNode;
      // ����������� �� �������� ���� (���������)
      while n.Parent <> Sender.RootNode do
      begin
        n := n.Parent;
      end;
      d := Sender.GetNodeData(n);
      p := cProgramObj(d.Data);
      controlsNode := FindProgramControlsNode(n);

      li := ControlsLV.Selected;
      while I < ControlsLV.SelCount do
      begin
        c := cControlObj(li.Data);
        p.AddControl(c);
        child := Sender.AddChild(controlsNode);
        d := Sender.GetNodeData(child);
        d.color := TVTree(Sender).normalcolor;
        d.caption := c.name;
        d.Data := c;
        d.ImageIndex := c.ImageIndex;
        inc(I);
      end;
    end;
  end;
  Sender.DropTargetNode.States := Sender.DropTargetNode.States + [vsExpanded];
end;

procedure TControlCyclogramEditFrm.ProgramTVDragOver
  (Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState;
  State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer;
  var Accept: Boolean);
begin
  Accept := false;
  if Source = ControlsLV then
    Accept := true;
end;

function isChildNode(pnode, cnode:pvirtualnode):boolean;
var
  p:pvirtualnode;
begin
  result:=false;
  p:=cnode.Parent;
  while p<>nil do
  begin
    if p=pnode then
    begin
      result:=true;
      exit;
    end
    else
      p:=p.parent;
  end;
end;


procedure TControlCyclogramEditFrm.ProgramTVKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  next, Node: PVirtualNode;
  Data, parentdata: PNodeData;
  I: Integer;
  obj: cbaseobj;
  p:cProgramObj;
  changestate:boolean;
begin
  if Key = VK_DELETE then
  begin
    Node := ProgramTV.GetFirstSelected(true);
    while Node <> nil do
    begin
      Data := ProgramTV.GetNodeData(Node);
      obj := cbaseobj(Data.Data);
      if obj<>nil then
      begin
        if obj is cControlObj then
        begin
          parentdata:=ProgramTV.GetNodeData(node.Parent.Parent);
          p:=cprogramobj(parentdata.data);
          p.removeOwnControl(cControlObj(obj));
        end
        else
        begin
          obj.destroy;
          Data.Data:=nil;
        end;
      end;
      next := ProgramTV.GetNextSelected(Node, false);
      if next = nil then
      begin
        if Data.Data<>nil then
        begin
          if TObject(Data.Data) is cBaseProgramObj then
          begin
            ModeFrame1.ShowProgObjProps(cBaseProgramObj(Data.Data), true);
          end;
        end;
      end
      else
      begin
        // ��������� �� ����. �����
        while isChildNode(node, next) do
        begin
          next:=ProgramTV.GetNextSelected(next, false);
        end;
      end;
      Node := next;
      inc(I);
    end;
    lcm;
    ecm;
    ShowChannels;
    showprogramInTV;
  end;
end;

procedure TControlCyclogramEditFrm.saveUI;
var
  f: tinifile;
  path: string;
begin
  path := g_startdir + '\ControlCyclogram.ini';
  f := tinifile.Create(path);
  f.WriteString('UIControlCyclogram', 'LastFile', m_lastfile);
  ModeFrame1.save(f, 'UIControlCyclogram');
  ControlEditFrame1.save(f, 'UIControlCyclogram');
  m_fileMng.save;
  f.destroy;
end;

procedure TControlCyclogramEditFrm.UnLinkPlg;
begin
  destroyEvents;
end;

procedure TControlCyclogramEditFrm.UpdateBtnClick(Sender: TObject);
var
  I: Integer;
  li, next: TListItem;
  con: cControlObj;
  b: Boolean;
begin
  b := false;
  if ControlsLV.Selected = nil then
    exit;
  li := ControlsLV.Selected;
  while li <> nil do
  begin
    b := true;
    con := cControlObj(li.Data);
    ControlEditFrame1.editControl(con);
    next := ControlsLV.GetNextItem(li, sdBelow, [isSelected]);
    // �������������� item � �������
    EditControlLI(li, con);
    if li = next then
      exit;
    li := next;
  end;
  LVChange(ControlsLV);
  g_conmng.configChanged := true;
  ControlEditFrame1.EndControlsMS;
end;

procedure TControlCyclogramEditFrm.UpdatePObjBtnClick(Sender: TObject);
var
  I: Integer;
  n, next: PVirtualNode;
  obj: cbaseobj;
  Data: PNodeData;
begin
  if ProgramTV.SelectedCount > 0 then
  begin
    n := ProgramTV.GetFirstSelected(true);
    while n <> nil do
    begin
      Data := ProgramTV.GetNodeData(n);
      next := ProgramTV.GetNextSelected(n, true);
      obj := cbaseobj(Data.Data);
      if obj is cBaseProgramObj then
      begin
        ModeFrame1.editobj(obj);
        Data.Caption:=obj.name;
      end;
      n := next;
      inc(I);
    end;
  end;
  ProgramTV.Refresh;
  g_conmng.configChanged := true;
end;

procedure TControlCyclogramEditFrm.ShowChannels;
var
  I, ind, tCount: Integer;
  ir: IRecorder;
  t: iTag;
  tname: string;
  li: TListItem;
begin
  ir := getIR;
  // ��������� ������ �������
  tCount := ir.GetTagsCount;
  TagsLV.Clear;
  for I := 0 to tCount - 1 do
  begin
    t := GetTagByIndex(I);
    tname := t.GetName;
    if ((pos(lowercase(FilterEdit.text), lowercase(tname)) > 0) or
        (FilterEdit.text = '')) then
    begin
      li := TagsLV.Items.Add;
      li.Data := pointer(t);
      TagsLV.SetSubItemByColumnName('���', tname, li);
    end;
  end;
  LVChange(TagsLV);

  StopTrigCB.updateTagsList;
  ControlEditFrame1.ShowChannels;
end;

procedure TControlCyclogramEditFrm.ShowProgObjProps();
var
  next, Node: PVirtualNode;
  Data: PNodeData;
  I: Integer;
  p:cProgramObj;
begin
  if ProgramTV.SelectedCount > 0 then
  begin
    Node := ProgramTV.GetFirstSelected(true);
    while Node <> nil do
    begin
      Data := ProgramTV.GetNodeData(Node);
      next := ProgramTV.GetNextSelected(Node, true);
      if next = nil then
      begin
        if TObject(Data.Data) is cBaseProgramObj then
        begin
          ModeFrame1.ShowProgObjProps(cBaseProgramObj(Data.Data), true);
        end;
      end
      else
      begin
        if TObject(Data.Data) is cBaseProgramObj then
        begin
          ModeFrame1.ShowProgObjProps(cBaseProgramObj(Data.Data), false);
        end;
      end;
      Node := next;
      inc(I);
    end;
  end;
end;

procedure TControlCyclogramEditFrm.ShowControlProps();
var
  con: cControlObj;
  b: Boolean;
  li, next: TListItem;
begin
  li := ControlsLV.Selected;
  while li <> nil do
  begin
    b := true;
    con := cControlObj(li.Data);
    next := ControlsLV.GetNextItem(li, sdBelow, [isSelected]);
    if (next = nil) or (next = li) then
    begin
      ControlEditFrame1.ShowControlProps(con, true);
      exit;
    end
    else
      ControlEditFrame1.ShowControlProps(con, false);
    li := next;
  end;
end;

end.
