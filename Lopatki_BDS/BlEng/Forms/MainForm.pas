

unit MainForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, opengl,
  Dialogs, StdCtrls, Menus, ufileMng, DCL_MYOWN, uBaseObjService,
  uBtnListView, uCfgForm, uBldEng, uGenBldForm, ExtCtrls,
  ComCtrls, ubldcompproc, ubldobj, ToolWin, uSelectAlgDlg,
  ubaseobj, uBldObjList, uCommonMath,usignalsTVframe, ucomponentservises, upage, uaxis,
  usaveeng, uProgramForm, uBldTimeProcForm, ubldTimeProc, uEventTypes,
  uJournalForm, Buttons, ubldEngEventTypes, uChartInputFrame,
  uChartFrame, uDoubleCursor, uAlarmsHistoryForm, uProcessalgtask, uTaskMng,
  uEgineMonitorForm, ImgList, mathfunction, uPlat, uFileThread,
  uBldGlobalStrings, uTag, uSetList, uMetaData, uEditTagForm,
  udrawobj, uSensor, me415;

type
  TMainBldForm = class(TForm)
    MainMenu: TMainMenu;
    TestMenu: TMenuItem;
    ConfigMenuItem: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ImageList_32: TImageList;
    HelpMenu: TMenuItem;
    ImageList_16: TImageList;
    GeneratorMenuItem: TMenuItem;
    MainGB: TGroupBox;
    Splitter1: TSplitter;
    ToolBar2: TToolBar;
    MouseGB: TGroupBox;
    CursorToolBtn: TToolButton;
    DblCursorToolBtn: TToolButton;
    CopyToolBtn: TToolButton;
    DelToolBtn: TToolButton;
    SaveToolButton: TToolButton;
    SaveToImageToolBar: TToolButton;
    TurbineEditMenu: TMenuItem;
    EditProjectMenu: TMenuItem;
    BldTimeProcMenu: TMenuItem;
    TimeLabelEdit: TEdit;
    JournalMenu: TMenuItem;
    AnimationPanel: TPanel;
    DecTimeBtn: TSpeedButton;
    PauseTimeBtn: TSpeedButton;
    AddTimeBtn: TSpeedButton;
    TimeScrollBox: TScrollBar;
    ChartFrame1: TChartFrame;
    SysJournalMenu: TMenuItem;
    AlarmsMenu: TMenuItem;
    MonitorFormMenu: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    CfgGB: TGroupBox;
    Splitter3: TSplitter;
    CfgTV: TTreeView;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    SignalsGB: TGroupBox;
    SignalsTVFrame1: TSignalsTVFrame;
    ToolBar3: TToolBar;
    SearchBtn: TToolButton;
    FilterGB: TGroupBox;
    SearchEdit: TEdit;
    MetaDataValueEdit: TEdit;
    MetaDataValueLabel: TLabel;
    MetaDataNameEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SrcEdit: TEdit;
    MetaDataTypeCB: TComboBox;
    MetaDataTypeLabel: TLabel;
    AddGraphBtn: TToolButton;
    TagsLV: TBtnListView;
    // ���������� � onCreate �����
    procedure ConfigMenuItemClick(Sender: TObject);
    procedure HelpMenuClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure GeneratorMenuItemClick(Sender: TObject);
    procedure CfgTVChange(Sender: TObject; Node: TTreeNode);
    procedure SelectAlgBtnClick(Sender: TObject);
    procedure CursorToolBtnClick(Sender: TObject);
    procedure DblCursorToolBtnClick(Sender: TObject);
    procedure SaveToolButtonClick(Sender: TObject);
    procedure SaveToImageToolBarClick(Sender: TObject);
    procedure DelToolBtnClick(Sender: TObject);
    procedure CopyToolBtnClick(Sender: TObject);
    procedure EditProjectMenuClick(Sender: TObject);
    // ��������� ������������ CfgTV
    procedure UpdateengCfg(Sender: TObject);
    procedure PauseTimeBtnClick(Sender: TObject);
    procedure cChart1Draw(Sender: TObject);
    procedure JournalMenuClick(Sender: TObject);
    procedure ChartFrame1cChart1Init(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AlarmsMenuClick(Sender: TObject);
    procedure BldTimeProcMenuClick(Sender: TObject);
    procedure MonitorFormMenuClick(Sender: TObject);
    procedure SearchEditChange(Sender: TObject);
    procedure TagsLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure TagsLVDblClickProcess(item: TListItem; lv: TListView);
    procedure TimeScrollBoxScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure CfgTVHint(Sender: TObject; const Node: TTreeNode;
      var Hint: string);
    procedure ChartFrame1cChart1Draw(Sender: TObject);
    procedure ChartFrame1PageCountSEChange(Sender: TObject);
  protected
    procedure OnDeadLock(sender:tobject);
    procedure OnExitCS(sender:tobject);
    procedure OnEnterCS(sender:tobject);

    procedure onUpdateTimeProcPlayFunc(sender:tobject);
    procedure onTimeProcStop(sender:tobject);
    procedure SetTimeEdges(sender:tobject);
    procedure SetTimeLabel(sender:tobject);
    procedure InitLV;
    procedure ShowTags(sender:tobject);
  private
    curobjlist:cbldobjlist;
    HelpMng:cFileMng;
    eng:cBldEng;
    bldTimeProc:cbldTimeProc;
    selectTags:cSetList;

    entercsCounter, exitCSCounter:integer;
  public
    // ��������������� �� ����� ������
    fMode:integer;
  private
    function GetCursorDt:single;
    procedure lincframes;
    procedure CreateEvents;
  public

  end;

var
  MainBldForm: TMainBldForm;

implementation

{$R *.dfm}

procedure TMainBldForm.CfgTVChange(Sender: TObject; Node: TTreeNode);
var
  obj:cbldobj;
  i:integer;
begin
  curobjlist.clear;
  for i:=0 to ttreeview(Sender).SelectionCount-1 do
  begin
    curobjlist.add(cbldobj(ttreeview(Sender).Selections[i].Data));
  end;
end;


procedure TMainBldForm.CfgTVHint(Sender: TObject; const Node: TTreeNode;
  var Hint: string);
begin
  if (tobject(node.data) is csensor) then
  begin
    hint:=csensor(node.data).hint;
  end;
end;

procedure TMainBldForm.ChartFrame1cChart1Draw(Sender: TObject);
begin
  ChartFrame1.cChart1.activePage.caption:=modname(ChartFrame1.cChart1.activePage.caption,false);
end;

procedure TMainBldForm.ChartFrame1cChart1Init(Sender: TObject);
begin
  ChartFrame1.cChart1.debugMode:=false;

  ChartFrame1.cChart1Init(Sender);
  loadeng(self,eng);
  ChartFrame1.cChart1.Resources:=extractfiledir(Application.ExeName)+c_curCfg;
end;

procedure TMainBldForm.ChartFrame1PageCountSEChange(Sender: TObject);
begin
  ChartFrame1.PageCountSEChange(Sender);

end;

procedure TMainBldForm.ConfigMenuItemClick(Sender: TObject);
begin
  // ���� �� �������,�� ��� �������� �������� � tv �������� ��������� �������
  // � �������� ������ � ������� OnChange
  cfgtv.Items.Clear;
  CfgForm.showmodal;
  UpdateengCfg(nil);
  caption:=eng.curCfg;
end;

procedure TMainBldForm.CopyToolBtnClick(Sender: TObject);
begin
  chartframe1.Chart.CopyScreenToClipboard;
end;

procedure TMainBldForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ���� �� ������ ������ ���� ����� ��������� ���������
  if PauseTimeBtn.Down then
  begin
    BldTimeProc.stop;
    if fMode=c_Device then
    begin
      cplatslist(eng.HardWare).stop;
    end;
    chartframe1.t1:=0;
  end;
  SelectTags.destroy;
  selectTags:=nil;
  bldTimeProc.destroy;
  eng.destroy;
  Helpmng.Destroy;
  curobjlist.destroy;
  DeleteStrings;
end;

function testDocFileName(str:string):boolean;
begin
  result:=fileexists(extractfiledir(application.ExeName)+'\files\������������\'+str);
end;

procedure TMainBldForm.FormCreate(Sender: TObject);
begin
  DecimalSeparator:='.';
  eng:=cbldeng.create;

  InitLV;
  bldTimeProc:=cbldTimeProc.create(eng);
  eng.timeproc:=bldTimeProc;
  bldTimeProc.eng:=eng;
  curobjlist:=cbldObjList.create;
  curobjlist.destroydata:=false;
  // �������� ��� ����������� ������ ��������
  eng.images_16:=ImageList_16;
  eng.images_32:=ImageList_32;
  Helpmng:=cfilemng.Create(eng.PathMng.findCfgPathFile('HelpFiles.cfg'),
                           MainMenu, v_Helpfiles, testDocFileName);
  chartframe1.linctproc(bldTimeProc);
  CreateEvents;
  SelectTags:=cSetList.create;
  SelectTags.destroydata:=false;

    // �������� ������� ����
  eng.ThreadList.AddID('MainTHread',GetCurrentThreadID);
  ChartFrame1.cChart1.OnDeadLock:=OnDeadLock;
  ChartFrame1.cChart1.OnExitCS:=OnExitCS;
  ChartFrame1.cChart1.OnEnterCS:=OnEnterCS;
end;

procedure TMainBldForm.FormShow(Sender: TObject);
begin
  lincframes;
  WindowState:=wsMaximized;
  RequestAlign;
end;

procedure TMainBldForm.GeneratorMenuItemClick(Sender: TObject);
begin
  //GeneratorForm.ShowModal;
  form2.showmodal;
end;

procedure TMainBldForm.HelpMenuClick(Sender: TObject);
var helpname,folder,name:string;
begin
  if HelpMng.bclick then
  begin
    HelpMng.bclick:=false;
    helpname:=HelpMng.GetClickItem;
    folder:=extractfiledir(application.ExeName)+'/files/������������/';
    name:=folder+helpname;
    ExecuteFile(name);
  end;
end;

procedure TMainBldForm.JournalMenuClick(Sender: TObject);
begin
  JournalForm.Show;
end;

procedure TMainBldForm.lincframes;
var
  frame:TChartInputFrame;
begin
  cfgform.getEngine(eng);
  cfgform.mainform:=self;
  SignalsTVFrame1.GetEng(eng);
  GeneratorForm.getEngine(eng);
  BldtimeprocForm.linc(bldTimeProc,eng, ChartFrame1.cchart1);
  //JournalForm.lincEng(eng);
  // ������� ����� ��� ����������� ��������� �������
  frame:=TChartInputFrame.create(self);
  frame.parent:=MouseGB;
  frame.lincchart(chartframe1.Chart);
  // ������� �����
  EngineMonitorForm.linc(eng);

  EditTagForm.Linc(bldTimeProc);
end;


procedure TMainBldForm.MonitorFormMenuClick(Sender: TObject);
begin
  EngineMonitorForm.Show;
end;


procedure TMainBldForm.SelectAlgBtnClick(Sender: TObject);
begin
  if curobjlist.count=0 then exit;
  SelAlgDlg.getChart(chartframe1.Chart);
  SelAlgDlg.getobj(curobjlist);
  SelAlgDlg.showmodal;
end;

procedure TMainBldForm.SaveToImageToolBarClick(Sender: TObject);
begin
  if SaveDialog.Execute(handle) then
  begin
    chartframe1.Chart.SaveToFile(savedialog.FileName);
  end;
end;

procedure TMainBldForm.SaveToolButtonClick(Sender: TObject);
begin
  SignalsTVFrame1.save;
end;

procedure TMainBldForm.CursorToolBtnClick(Sender: TObject);
var
  obj:cDoubleCursor;
begin
  obj:=cDoubleCursor(chartframe1.Chart.activepage.getChild('cDoubleCursor'));
  if obj<>nil then
  begin
    obj.visible:=not obj.visible;
    if obj.visible then
    begin
      obj.x1:=chartframe1.Chart.activepage.m_viewport[0]+round(chartframe1.Chart.activepage.m_viewport[2]/2);
      obj.x2:=chartframe1.Chart.activepage.m_viewport[0]+round(chartframe1.Chart.activepage.m_viewport[2]/2)+
      round(chartframe1.Chart.activepage.m_viewport[2]/4);
    end;
    chartframe1.Chart.redraw;
  end;
end;

procedure TMainBldForm.DblCursorToolBtnClick(Sender: TObject);
var
  obj:cDoubleCursor;
begin
  obj:=cDoubleCursor(chartframe1.Chart.activepage.getChild('cDoubleCursor'));
  if obj.cursortype=c_SingleCursor then
    obj.cursortype:=c_doublecursor
  else
    obj.cursortype:=c_SingleCursor;
end;

procedure TMainBldForm.DelToolBtnClick(Sender: TObject);
var
  res:integer;
begin
  if not (chartframe1.Chart.selected is cpage) then
  begin
    if chartframe1.Chart.selected is caxis then
    begin
      if cpage(chartframe1.Chart.activepage).getAxisCount=1 then
        exit;
    end;
    res:=MessageDlg('������� ������?',mtConfirmation, mbOKCancel, 0);
    if res=1 then
    begin
      chartframe1.Chart.deleteselected;
    end;
  end;
end;

procedure TMainBldForm.EditProjectMenuClick(Sender: TObject);
begin
  EditProjForm.Showmodal(self,eng);
end;

procedure TMainBldForm.AlarmsMenuClick(Sender: TObject);
begin
  AlarmsHistoryBase.Show;
end;

procedure TMainBldForm.BldTimeProcMenuClick(Sender: TObject);
begin
  BldTimeProcForm.showmodal(ChartFrame1.chart);
end;

procedure TMainBldForm.cChart1Draw(Sender: TObject);
begin
  inc(chartframe1.drawcount);

  Caption:='MainForm'+' DrowCount='+inttostr(chartframe1.drawCount)+' FPS:' +
            inttostr(chartframe1.fps)+' Cscounter: '+inttostr(entercsCounter-exitCSCounter);
end;

procedure TMainBldForm.CreateEvents;
begin
  eng.Events.AddEvent('UpdateMainFormCfgTV', E_OnEngLoadCfg, UpdateengCfg);
  eng.Events.AddEvent('OnUpdateTimeProc_MainForm', E_OnTimeProc, onUpdateTimeProcPlayFunc);
  //eng.Events.AddEvent('onTimeProcStop', e_OnUserFinishPlayData, onTimeProcStop);
  eng.Events.AddEvent('onTimeProcStop', E_OnFinishPlayData, onTimeProcStop);
  eng.Events.AddEvent('OnEngLoadCfg_MainForm', E_OnEngLoadCfg, SetTimeLabel);
  bldTimeProc.fTagMng.Events.AddEvent('OnChangeEventsCfg', E_OnEngUpdateList, ShowTags);
end;

procedure TMainBldForm.UpdateengCfg(Sender: TObject);
begin
  ShowEngInTreeView(cfgtv,eng);
end;

function TMainBldForm.GetCursorDt:single;
var
  obj:cDoubleCursor;
begin
  result:=1;
  // ��������� �������
  obj:=cDoubleCursor(chartframe1.Chart.activepage.getChild('cDoubleCursor'));
  if obj<>nil then
  begin
    result:=obj.dx;
  end;
end;

procedure TMainBldForm.PauseTimeBtnClick(Sender: TObject);
begin
  if PauseTimeBtn.Down then
  begin
    if fmode<>c_Demo then
      eng.clearTicks;
    ChartFrame1.SetTimeLength(BldTimeProc.dt);
    BldTimeProc.play(fMode);
  end
  else
  begin
    BldTimeProc.stop;
    if fMode=c_Device then
    begin
      cplatslist(eng.HardWare).stop;
    end;
    chartframe1.t1:=0;
  end;
end;

// ������� ���������� �� ����������(�� ��������� ������, ������� ���� ��������� ���������� �����)
procedure TMainBldForm.onUpdateTimeProcPlayFunc(sender:tobject);
var
  activetask:ctask;
  obj:cDoubleCursor;
  t0:double;
begin
  //chartframe1.Chart.E-nterCS;
  // ��������� ������� �������� �������
  activetask:=ctaskmng(bldTimeProc.TaskList).activetask;
  if activetask<>nil then
  begin
    if sender=activetask.Thread then
    begin
      TimeScrollBox.Position:=trunc(((activetask.Thread.t1-activetask.Thread.t0)/activetask.Thread.TimeLength)*100);
      SetTimeLabel(nil);
      obj:=cDoubleCursor(chartframe1.Chart.activepage.getChild('cDoubleCursor'));
      if obj.visible then
      begin
        t0:=activetask.Thread.t0;
        obj.setx1(activetask.Thread.t1-t0);
        obj.setx2(activetask.Thread.t2-t0);
      end;
    end;
  end;
  //chartframe1.Chart.E-xitCS;
end;

procedure TMainBldForm.onTimeProcStop(sender:tobject);
var
  t,activetask:ctask;
  i:integer;
  fileThread:cfilethread;
begin
  // ��������� ������� �������� �������
  if fMode=c_demo then
  begin
    fileThread:=cFileThread(eng.GetDataThread('cFileThread'));
    if not fileThread.Enabled then
      cbldtimeproc(eng.timeProc).play(c_demo);
  end;
end;

procedure TMainBldForm.SetTimeEdges(sender:tobject);
var
  obj:cDoubleCursor;
begin
  // ��������� �������
  obj:=cDoubleCursor(chartframe1.Chart.activepage.getChild('cDoubleCursor'));
end;

procedure TMainBldForm.SetTimeLabel(sender:tobject);
var
  activetask:ctask;
begin
  // ��������� ������� �������� �������
  activetask:=ctaskmng(bldTimeProc.TaskList).activetask;
  if activetask<>nil then
  begin
    timeLabelEdit.Text:='t1='+ formatstr(activetask.Thread.t1,3) + '/ t2='+ formatstr(activetask.Thread.t2,3)
  end;
end;

procedure TMainBldForm.InitLV;
var
  col:tListColumn;
begin
  // ����
  col:=tagsLV.Columns.Add;
  col.Caption:=v_Name;
  col.Width:=100;
  col:=tagsLV.Columns.Add;
  col.Caption:=v_Src;
  col.Width:=100;
end;

procedure TMainBldForm.ShowTags(sender:tobject);
var
  tag:cbasetag;
  selected:boolean;
  I,j: Integer;
  �: Integer;
  mData:MetaData;
  li:tlistitem;
begin
  if selectTags=nil then exit;
  selectTags.Clear;
  selected:=false;
  for I := 0 to bldtimeproc.fTagMng.Count - 1 do
  begin
    if selected then
    begin
      selectTags.Add(tag);
    end;
    selected:=true;
    tag:=bldtimeproc.fTagMng.gettag(i);
    // ������ �� �����
    if SearchEdit.Text<>'' then
    begin
      if pos(SearchEdit.Text, tag.name)<1 then
      begin
        selected:=false;
        continue;
      end;
    end;
    if srcEdit.Text<>'' then
    begin
      if cbaseobj(tag.source).name=srcEdit.Text then
      begin

      end
      else
      begin
        selected:=false;
        continue;
      end;
    end;
    // ����� �� ����������
    if MetaDataNameEdit.Text<>'' then
    begin
      mData:=tag.metadata.GetObj(MetaDataNameEdit.Text);
      if mData<>nil then
      begin
        if MetaDataTypeCb.Text<>'' then
        begin
          if mData.ClassName=MetaDataTypeCb.Text then
          begin

          end
          else
          begin
            selected:=false;
            continue;
          end;
        end;
        if MetaDataValueEdit.Text<>'' then
        begin
          if mData.sValue=MetaDataValueEdit.text then
          begin

          end
          else
          begin
            selected:=false;
            continue;
          end;
        end;
      end;
    end;
  end;
  tagslv.Clear;
  for I := 0 to selecttags.Count - 1 do
  begin
    tag:=cbasetag(selecttags.getNode(i));
    li:=tagslv.Items.Add;
    li.data:=tag;
    tagslv.SetSubItemByColumnName(v_name,tag.name,li);
    if tag.source<>nil then
      tagslv.SetSubItemByColumnName(v_Src,cbaseobj(tag.source).name,li);
  end;
end;

procedure TMainBldForm.TagsLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if TBtnListView(sender).Selected<>nil then
    ChartFrame1.OnselectTag(TBtnListView(sender).Selected);
end;

procedure TMainBldForm.TagsLVDblClickProcess(item: TListItem; lv: TListView);
begin
  edittagform.EditTag(cbasetag(item.data));
end;

procedure TMainBldForm.TimeScrollBoxScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
var
  t, Timelength:single;
  i:integer;
  activetask:ctask;
begin
  // ��������� ������� �������� �������
  activetask:=ctaskmng(bldTimeProc.TaskList).activetask;
  Timelength:=activetask.Thread.TimeLength;
  t:=Timelength*TimeScrollBox.Position/100;
  // �������� ����� ���� �����
  for I := 0 to ctaskmng(bldTimeProc.TaskList).Count - 1 do
  begin
    activetask:=ctask(ctaskmng(bldTimeProc.TaskList).getobj(i));
    activetask.Thread.t1:=t+activetask.Thread.t1;
    activetask.Thread.t2:=activetask.Thread.t1+activetask.Thread.dT;
  end;
end;

procedure TMainBldForm.SearchEditChange(Sender: TObject);
begin
  ShowTags(nil);
end;

procedure TMainBldForm.OnDeadLock(sender:tobject);
begin
  eng.getmessage(ChartFrame1.cChart1.deadlockdsc+'_'+
                 eng.ThreadList.GetIDName(GetCurrentThreadId),c_infoMessage);
end;

procedure TMainBldForm.OnExitCS(sender:tobject);
begin
  inc(exitCSCounter);
  //eng.getmessage('exitCS_'+cdrawobj(sender).name+'_'+
  //               eng.ThreadList.GetIDName(GetCurrentThreadId),c_infoMessage);
end;

procedure TMainBldForm.OnEnterCS(sender:tobject);
begin
  //eng.getmessage('EnterCS_'+cdrawobj(sender).name+'_'+
  //               eng.ThreadList.GetIDName(GetCurrentThreadId),c_infoMessage);
  inc(entercsCounter);
end;

end.
