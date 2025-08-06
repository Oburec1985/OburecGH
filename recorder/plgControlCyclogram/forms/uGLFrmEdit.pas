
unit uGLFrmEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  uMeasureBase,
  uMBaseControl,
  uVertexEditFrame,
  uGlEventTypes,
  uEventList,
  uObject, uNodeobject,
  StdCtrls, ExtCtrls, uTagsListFrame,
  TestUDPSender,
  u3dMoveEngine,
  uUI,
  u3dObjEditFrame;

type
  TObjFrm3dEdit = class(TForm)
    LowPanel: TPanel;
    CancelBtn: TButton;
    OkBtn: TButton;
    AlClientPanel: TPanel;
    OpenDialog1vista: TFileOpenDialog;
    RightPanel: TPanel;
    TopPanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    ShowTrfrmToolsCB: TCheckBox;
    SceneFolderEdit: TEdit;
    SceneNameEdit: TEdit;
    PathBtn: TButton;
    TagsListFrame1: TTagsListFrame;
    ObjPanel: TPanel;
    ObjEditFrame1: TObjEditFrame;
    Button1: TButton;
    procedure PathBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
  private
    finit:boolean;
    m_glFrm:tform;
    skinframe:TVertexEditFrame;
    frames:tlist;
    m_curObj:cnodeobject;
    e:cEvent;
  protected
    procedure doStart(sender:tobject);
    procedure createevents;
    procedure destroyevents;
    procedure OnSelectObj(sender:tobject);
  public
    procedure doRecroderInit;
    procedure init;
    function getFrame(s:string):tframe;
    procedure edit(glFrm:tobject);
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

var
  g_ObjFrm3dEdit:TObjFrm3dEdit;

implementation
uses
  u3dObj, PluginClass, uRecorderEvents;

{$R *.dfm}

procedure TObjFrm3dEdit.createevents;
begin
  e:=TObjFrm3d(m_glFrm).GL.mUI.eventlist.AddEvent('TObjFrm3dEdit_OnSelObj',E_glSelectNew,OnSelectObj);
  e.active:=false;
  addplgevent('TObjFrm3d_doRcInit', c_RC_DoChangeRCState, doStart);
end;

procedure TObjFrm3dEdit.destroyevents;
begin
  if m_glFrm<>nil then
    TObjFrm3d(m_glFrm).GL.mUI.eventlist.removeEvent(OnSelectObj, E_glSelectNew);
end;

procedure TObjFrm3dEdit.doRecroderInit;
begin
  init;
  if g_ObjFrm3dFactory.count>0 then
  begin
    TestUDPSenderFrm.createtags;
    TestUDPSenderFrm.doRCinit;
  end;
end;

procedure TObjFrm3dEdit.doStart(sender: tobject);
begin
  if RStatePlay then
  begin
    if TestUDPSenderFrm<>nil then
      TestUDPSenderFrm.doRCStart;
  end
  else
  begin
    if TestUDPSenderFrm<>nil then
      TestUDPSenderFrm.doRCStop;
  end;
end;

procedure TObjFrm3dEdit.Button1Click(Sender: TObject);
var
  o:c3dCtrlObj;
  m:c3dMoveObj;
  ui:cUi;
begin
  if m_curObj=nil then exit;

  ObjEditFrame1.xRotTagCb.SetTagName('YRotTag');
  ObjEditFrame1.yRotTagCb.SetTagName('XRotTag');
  ObjEditFrame1.zRotTagCb.SetTagName('ZRotTag');

  o:=(g_CtrlObjList.GetObj(m_curObj.name+'_Ctrl'));
  if o=nil then
  begin
    m:=c3dMoveObj.create;
    m.name:=m_curObj.name+'_Ctrl';
    g_CtrlObjList.addObj(m);
    ui:=TObjFrm3d(m_glFrm).GL.mUI;

    UI.scene.Add(m, ui.scene.World);
    m.fHelper:=false;
    m.nodetm:=m_curObj.nodeResTm;
    m.addchild(m_curObj);
    m.RotXTag.tag:=ObjEditFrame1.xRotTagCb.gettag;
    m.RotYTag.tag:=ObjEditFrame1.yRotTagCb.gettag;
    m.RotZTag.tag:=ObjEditFrame1.zRotTagCb.gettag;
    TObjFrm3d(m_glFrm).UpdateTreeView;
  end
  else
  begin
    m:=c3dMoveObj(o);
  end;
end;

constructor TObjFrm3dEdit.create(aowner: tcomponent);
var
  fr:TFrame;
begin
  inherited;
  // фрейм настройки вершин
  //fr:=TVertexEditFrame.CreateParented(AlClientPanel.Handle);
  fr:=TVertexEditFrame.Create(nil);
  fr.parent:=AlClientPanel;
  fr.visible:=true;
  TVertexEditFrame(fr).init;
  skinframe:=TVertexEditFrame(fr);

  frames:=TList.Create;
  frames.add(fr);

  //if TestUDPSenderFrm=nil then
  //  TestUDPSenderFrm:=TTestUDPSenderFrm.Create(nil);
end;

destructor TObjFrm3dEdit.destroy;
begin
  destroyevents;
  skinframe.destroyevents;

  frames.Destroy;
  inherited;
end;

Procedure TObjFrm3dEdit.edit(glFrm:tobject);
var
  scenepath:string;
begin
  m_glFrm:=tform(glFrm);
  TagsListFrame1.ShowChannels;

  ShowTrfrmToolsCB.Checked:=TObjFrm3d(glFrm).ShowTools;
  scenepath:=TObjFrm3d(glFrm).BuildPath;
  SceneFolderEdit.Text:=extractfiledir(scenepath);
  SceneNameEdit.Text:=ExtractFileName(scenepath);
  if e<>nil then
    e.active:=false;
  OnSelectObj(nil);
  show;
  TestUDPSenderFrm.show;
end;


procedure TObjFrm3dEdit.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if e<>nil then
    e.Active:=true;
end;

procedure TObjFrm3dEdit.FormShow(Sender: TObject);
var
  fr:tframe;
begin
  skinframe.Align:=alClient;
end;

function TObjFrm3dEdit.getFrame(s: string): tframe;
var
  I: Integer;
  fr:tframe;
begin
  result:=nil;
  for I := 0 to frames.Count - 1 do
  begin
    fr:=tframe(frames.items[i]);
    if fr.classname=s then
    begin
      result:=fr;
      exit;
    end;
  end;
end;

procedure TObjFrm3dEdit.init;
var
  I: Integer;
begin
  if m_glFrm=nil then
  begin
    for I := 0 to g_ObjFrm3dFactory.Count - 1 do
    begin
      if i=0 then
      begin
        m_glFrm:=g_ObjFrm3dFactory.GetFrm(i);
        break;
      end;
    end;
  end;

  if not finit then
  begin
    if m_glFrm<>nil then
    begin
      skinframe.m_ui:=TObjFrm3d(m_glFrm).GL.mUI;
      if skinframe.m_ui<>nil then
      begin
        finit:=true;
        createevents;
        skinframe.createevents;
      end;
    end;
  end;
end;

procedure TObjFrm3dEdit.OkBtnClick(Sender: TObject);
begin
  TObjFrm3d(m_glFrm).ShowTools:=ShowTrfrmToolsCB.Checked;
  TObjFrm3d(m_glFrm).m_ScenePath:= SceneFolderEdit.Text;
  TObjFrm3d(m_glFrm).m_SceneName:=SceneNameEdit.Text;
  skinframe.apply;
end;

procedure TObjFrm3dEdit.OnSelectObj(sender: tobject);
var
  p:cnodeobject;
begin
  if TObjFrm3d(m_glFrm).GL.mUI=nil then exit;
  if TObjFrm3d(m_glFrm).GL.mUI.selectCount>0 then
  begin
    m_curObj:=TObjFrm3d(m_glFrm).GL.mUI.getselected(0);
    skinframe.showObj(cobject(m_curObj), m_glFrm);
    ObjEditFrame1.SetEditObj(m_curObj);
    if m_curObj.parent<>nil then
    begin

    end;
  end
  else
    m_curObj:=nil;
end;

procedure TObjFrm3dEdit.PathBtnClick(Sender: TObject);
begin
  OpenDialog1vista.filename := SceneFolderEdit.text;
  if OpenDialog1vista.Execute() then
  begin
    OpenDialog1vista.Options := [fdoPickFolders, fdoForceFileSystem];
    SceneFolderEdit.Text:=extractfiledir(OpenDialog1vista.FileName);
    SceneNameEdit.Text:=extractfilename(OpenDialog1vista.FileName);
  end;

end;

end.
