unit uCfgForm;

interface

uses
  Windows, Forms, Menus, ComCtrls, uBtnListView, StdCtrls, uFileMng, sysutils,
  uBlInterfaceFrame, uBldEng,  ubldCompProc, uBldObj, Dialogs,
  uLfmFile, Controls, Classes, uEventTypes, uCompaundFrame, ExtCtrls, uframeevents,
  uSensorFrame, uBldFile, uSystemInfoFrame, uEditListFrame, ueventlist, usensor,
  ustage, upair, uGlTurbineFrame, ulogFrame, uTagPropertiesFrame, uDoubleCursor,
  uTagsCfgFrame, uXmlFile, uBladeTicksFile, uchan, uGetTimeForm, uBldGlobalStrings,
  uBaseObjService, upage;

type
  TCfgForm = class(TForm)
    MainMenu1: TMainMenu;
    AlgorithmsMenu: TMenuItem;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    FileMenu: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    RecentFileMenu: TMenuItem;
    MainSplitter: TSplitter;
    EngGB: TGroupBox;
    EngTreeGB: TGroupBox;
    EngTV: TTreeView;
    EditEngListGB: TGroupBox;
    EditEngListFrame1: TEditEngListFrame;
    OpenFileMenu: TMenuItem;
    SaveMenu: TMenuItem;
    Pages: TPageControl;
    TabSheet1: TTabSheet;
    ObjGB: TGroupBox;
    TagsPage: TTabSheet;
    TagsCfgFrame1: TTagsCfgFrame;
    ObjInterfaceFrame1: TObjInterfaceFrame;
    ProgressBar1: TProgressBar;
    procedure ObjectsLVDblClickProcess(item: TListItem; lv: TListView);
    procedure LoadMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ObjInterfaceFrame1ApplyBtnClick(Sender: TObject);
    procedure ChannelsLVDblClickProcess(item: TListItem; lv: TListView);
    procedure OpenFileMenuClick(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure EngTVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure EngTVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditEngListFrame1CreateObjBtnClick(Sender: TObject);
    procedure EditEngListFrame1DelObjBtnClick(Sender: TObject);
    procedure EngTVClick(Sender: TObject);
    procedure EditEngListFrame1ClearAllClick(Sender: TObject);
    procedure TagPropertiesFrame1DrawObjSelectBtnClick(Sender: TObject);
    procedure TagsCfgFrame1TagsLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure TagsCfgFrame1ApplyBtnClick(Sender: TObject);
  public
    mainform:tform;
  private
    events:ceventlist;
    eng:cBldEng;
    RecentFilesMng:cFileMng;
    // ссылка на выбранный объект
    selected:cbldobj;
    lastDataFile:string;
  private
    function loadfile(name:string):boolean;
    procedure lincevents;
    procedure showObj(obj:tobject);
    procedure update;
    procedure setselected(obj:cbldobj);
    procedure UpdateProgress(Sender: TObject);
  public
    procedure getEngine(p_eng:cBldEng);
    destructor destroy;override;
    constructor create(aowner:tcomponent);override;
  end;


var
  CfgForm: TCfgForm;

const
  recentfiles = 'Недавние файлы';

implementation
uses
  ubldtimeproc, mainform;
{$R *.dfm}

procedure TCfgForm.UpdateProgress(Sender: TObject);
begin
  ProgressBar1.Position:=cBldFile(sender).Progress;
end;


function TCfgForm.loadfile(name:string):boolean;
var ext:string;
  I: Integer;
  chan:cchan;
begin
  ext:=extractfileext(name);
  ext:=lowerCase(ext);
  if ext='' then
  begin
    case opendialog.FilterIndex of
      1:ext:='.lfm';
      2:ext:='.bld';
      3:ext:='.xml';
      4:ext:='.sdt';
    end;
    name:=name+ext;
  end;
  if ext='.lfm' then
  begin
    // удалить объекты движка
    eng.clear;
    // загружаем новую конфигурацию
    readLFMData(eng,name);
    result:=true;
    if result then
      eng.lastfile:=name;
  end;
  if ext='.bld' then
  begin
    result:=ReadBldDataExt(name,eng, UpdateProgress);
    lastDataFile:=name;
    if result then
      eng.lastfile:=name;
    ProgressBar1.Position:=0;
  end;
  if ext='.xml' then
  begin
    result:=LoadXMLFile(name, eng, tmainbldform(mainform).ChartFrame1.cChart1);
    if result then
      eng.curCfg:=name;
  end;
  if ext='.sdt' then
  begin
    ReadData(name,eng.channels);
    result:=true;
    if result then
      eng.lastfile:=name;
    for I := 0 to eng.channels.childCount - 1 do
    begin
      chan:=cchan(eng.channels.getChild(i));
      if chan.eng=nil then
      begin
        chan.eng:=eng;
      end;
    end;
  end;
end;

procedure TCfgForm.LoadMenuClick(Sender: TObject);
var
  name,folder:string;
  updateview:boolean;
begin
  updateview:=false;
  if RecentFilesMng.bclick then
  begin
    RecentFilesMng.bclick:=false;
    name:=RecentFilesMng.GetClickItem;
    folder:='';
    name:=folder+name;
    updateview:=loadfile(name);
  end;
  if updateview then
    update;
end;

procedure TCfgForm.ObjectsLVDblClickProcess(item: TListItem; lv: TListView);
var obj:cbldobj;
begin
  obj:=cbldobj(GetEngObj(tbtnlistview(lv),eng,item));
  setselected(obj);
end;

procedure TCfgForm.ChannelsLVDblClickProcess(item: TListItem; lv: TListView);
var obj:cbldobj;
begin
  obj:=cbldobj(eng.getchan(item.Index));
  setselected(obj);
end;

procedure TCfgForm.ObjInterfaceFrame1ApplyBtnClick(Sender: TObject);
begin
  ObjInterfaceFrame1.ApplyBtnClick(Sender);
end;

procedure TCfgForm.OpenFileMenuClick(Sender: TObject);
begin
  if OpenDialog.Execute(0) then
  begin
    if loadfile(OpenDialog.FileName) then
    begin
      update;
      RecentFilesMng.AddfilePath(OpenDialog.FileName);
    end;
  end;
end;

procedure TCfgForm.SaveMenuClick(Sender: TObject);
var
  ext, lext:string;
  cursor:cdoublecursor;
begin
  if SaveDialog.Execute(0) then
  begin
    ext:=extractfileext(SaveDialog.filename);
    case savedialog.FilterIndex of
      1:lext:='.lfm';
      2:lext:='.bld';
      3:lext:='.xml';
      4:lext:='.sdt';
    end;
    if ext<>lext then
    begin
      ext:=lext;
      SaveDialog.filename:=SaveDialog.filename+ext;
    end;
    ext:=lowerCase(ext);
    if ext='.lfm' then
    begin
      writeLFMData(eng, SaveDialog.FileName);
      RecentFilesMng.AddfilePath(SaveDialog.FileName);
    end;
    if ext='.bld' then
    begin
      writeblddata(SaveDialog.FileName, eng);
    end;
    if ext='.xml' then
    begin
      saveXMLFile(SaveDialog.FileName, eng, tMainBldForm(mainform).ChartFrame1.cChart1);
    end;
    if ext='.sdt' then
    begin
      cursor:=cpage(tmainbldform(mainform).ChartFrame1.cChart1.activePage).cursor;
      if GetTimeForm.showmodal_(eng, cursor.getx1, cursor.getx2)=mrok then
      begin
        SaveData(SaveDialog.FileName,eng.channels, GetTimeForm.StartTimeFE.Value, GetTimeForm.EndTimeFE.Value);
      end;
    end;
  end;
end;

// происходит при выборе очередного узла treeview
procedure TCfgForm.EditEngListFrame1ClearAllClick(Sender: TObject);
begin
  EditEngListFrame1.ClearAllClick(Sender);
end;

procedure TCfgForm.EditEngListFrame1CreateObjBtnClick(Sender: TObject);
begin
  EditEngListFrame1.CreateObjBtnClick(Sender);
end;

procedure TCfgForm.EditEngListFrame1DelObjBtnClick(Sender: TObject);
begin
  EditEngListFrame1.DelObjBtnClick(Sender);
end;

procedure TCfgForm.EngTVClick(Sender: TObject);
var
  xy:tpoint;
  node:ttreenode;
begin
  GetCursorPos(xy);
  Windows.screentoclient(EngTV.Handle,xy);
  node:=EngTV.GetNodeAt(xy.x,xy.Y);
  if node<>nil then
  begin
    setselected(cbldobj(node.Data));
  end;
end;

// происходит при отпускании узла над обьектом
// sender - куда падает объект
// source - сам объект
procedure TCfgForm.EngTVDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  srcNode, dstNode: TTreeNode;
  src, dst:cbldobj;
begin
  if EngTV.Selected = nil then Exit;
  dstNode := EngTV.GetNodeAt(X, Y);
  srcNode:=EngTV.selected;
  src:=cbldobj(srcNode.Data);
  if dstNode<>nil then
    dst:=cbldobj(dstNode.Data)
  else
    dst:=nil;
  if src<>nil then
  begin
    if (src is csensor) or (src is cpair) then
    begin
      if dst is cstage then
      begin
        cstage(dst).AddSensor(csensor(src));
        ShowEngInTreeView(engTV,eng);
        exit;
      end;
    end;
    src.parent:=dst;
    ShowEngInTreeView(engTV,eng);
  end;
end;

procedure TCfgForm.EngTVDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  srcNode, dstNode:TTreeNode;
  src, dst:cbldobj;
begin
  accept:=false;
  if sender=engtv then
  begin
    if srcNode=nil then exit;
    srcNode:=EngTV.selected;
    dstNode := EngTV.GetNodeAt(X, Y);
    src:=cbldobj(srcNode.Data);
    if (dstNode<>nil) and (srcNode<>nil) then
    begin
      dst:=cbldobj(dstNode.Data);
      if dst=nil then
      begin
        exit;
      end;
      if dst.SupportedChildClass(src) then
      begin
        accept:=true;
      end
    end;
  end;
end;

constructor TCfgForm.create(aowner:tcomponent);
begin
  inherited;
  lincevents;
  lastDataFile:='';
end;

destructor TCfgForm.destroy;
begin
  if RecentFilesMng<>nil then
    RecentFilesMng.Destroy;
  events.destroy;
  inherited;
end;

procedure TCfgForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

procedure TCfgForm.FormShow(Sender: TObject);
var
  str:string;
begin
  str:=extractfiledir(application.ExeName)+'\files\3d\resources.ini';
  //ObjInterfaceFrame1.glturbineframe1.cBaseGlComponent1.resources:=str;
  if RecentFilesMng=nil then
    RecentFilesMng:=cFileMng.Create(eng.PathMng.findCfgPathFile('RecentFiles.cfg'),
                                 MainMenu1, recentfiles,TestRecentFiles);
  showObj(nil);
  WindowState:=wsMaximized;
  objinterfaceframe1.Visible:=false;
end;
// происходит при обновлении движка
procedure TCfgForm.showObj(obj:tobject);
begin
  // если передаваемый объект равен выбранному, значит произошло удаление
  if obj=selected then
    setselected(nil);
  ShowEngInTreeView(engTV,eng);
end;

procedure TCfgForm.TagPropertiesFrame1DrawObjSelectBtnClick(Sender: TObject);
begin
  TagsCfgFrame1.TagPropertiesFrame1DrawObjSelectBtnClick(Sender);
end;

procedure TCfgForm.TagsCfgFrame1ApplyBtnClick(Sender: TObject);
begin
  TagsCfgFrame1.ApplyBtnClick(Sender);
end;

procedure TCfgForm.TagsCfgFrame1TagsLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  TagsCfgFrame1.TagsLVChange(Sender, Item, Change);

end;

procedure TCfgForm.update;
begin
  showObj(nil);
end;

procedure TCfgForm.setselected(obj:cbldobj);
begin
  selected:=obj;
  ObjInterfaceFrame1.chart:=tmainbldform(mainform).ChartFrame1.cChart1;
  ObjInterfaceFrame1.getObj(obj);
  if obj<>nil then
    objinterfaceframe1.Visible:=true;
  EditEngListFrame1.setobj(selected);
end;

procedure TCfgForm.lincevents;
begin
  events:=ceventlist.create(self,true);
  ObjInterfaceFrame1.lincevents(events);
  events.addevent('cfgForm onApplyBtn',UpdateInterfaceFrame, showObj);
  EditEngListFrame1.lincevents(events);
end;

procedure TCfgForm.getEngine(p_eng:cBldEng);
begin
  eng:=p_eng;
  showObj(self);
  eng.Events.AddEvent('cfgform addobj',E_OnEngUpdateList,showObj);
  EditEngListFrame1.lincEngine(eng);
  TagsCfgFrame1.Linc(cbldtimeproc(eng.timeProc));
end;



end.
