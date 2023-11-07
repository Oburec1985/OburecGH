unit u3dFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus,
  ufileMng, uCursors, uGLEventTypes,
  uUI, ExtCtrls, StdCtrls, ImgList, VirtualTrees, uVTServices,
  uTransformButtons,
  SelectObjectsFrame,
  uModifyFrame,
  uTVFrm;

type
  TGlFrm = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    SaveMenuItem: TMenuItem;
    ImportObjectsMenu: TMenuItem;
    Recentlyopenedfiles1: TMenuItem;
    N4: TMenuItem;
    UIConfigMenu: TMenuItem;
    SceneMenu: TMenuItem;
    N6: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    ModifyMenu: TMenuItem;
    MaterialMenu: TMenuItem;
    N7: TMenuItem;
    GroupMenu: TMenuItem;
    GroupObjectsMenu: TMenuItem;
    UngroupObjectsMenu: TMenuItem;
    OpenGroupMenu: TMenuItem;
    CloseGroupMenu: TMenuItem;
    LincObjMenu: TMenuItem;
    HelpMenu: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    GroupBox1: TGroupBox;
    Splitter1: TSplitter;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    procedure FormClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Recentlyopenedfiles1Click(Sender: TObject);
    procedure ModifyMenuClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    enablecomponents:boolean;
    // фреймы
    TVframe:TSceneTVFrame;
    TransformToolsFrame1:TTransformToolsFrame;
    SelectObjectsFrame:TSelectObjectFrame;
    modifyframe:tmodifyframe;
  private
    procedure init;
    procedure linkFrames;
    procedure changecursorOnUnselect(sender:tobject);
    procedure EnableComponent(state:boolean);
    procedure OnInitContext(sender:tobject);
  public

  end;

 var
   m_fileMng:cFileMng;
   m_HelpMng:cFileMng;
   g_UI:cUI;


 const
   FileMngName = 'Recently opened files';
   HelpFiles = 'Помощь';

var
  GlFrm: TGlFrm;

implementation

{$R *.dfm}


procedure TGlFrm.linkFrames;
begin
  TVframe:=TSceneTVFrame.Create(self);
  g_ui.scene.images_16:=ImageList_16;
  g_ui.scene.images_32:=ImageList_32;
  tvframe.link(g_UI, GroupBox1, ImageList_32);

  TransformToolsFrame1 := TTransformToolsFrame.Create(self);
  TransformToolsFrame1.Parent:=self;
  TransformToolsFrame1.Visible:=true;
  TransformToolsFrame1.Lincscene(g_ui);


  SelectObjectsFrame := TSelectObjectFrame.Create(self);
  SelectObjectsFrame.Parent:=self;
  SelectObjectsFrame.Visible:=false;
  selectObjectsFrame.GetUI(g_UI);
  SelectObjectsFrame.ObjectsLV.Enabled:=true;

  modifyframe:=tmodifyframe.Create(self);
  modifyframe.Parent:=self;
  modifyframe.Visible:=false;
  modifyframe.lincscene(g_ui);
end;

procedure TGlFrm.ModifyMenuClick(Sender: TObject);
begin
  //TVframe.Visible:=false;

  SelectObjectsFrame.Visible:=false;
  //MatFrame.Visible:=false;
  ModifyFrame.Visible:=not ModifyFrame.Visible;
  if not ModifyFrame.Visible then
    ModifyFrame.SkinFrame1.OnHide;
end;


procedure TGlFrm.N2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    g_UI.m_RenderScene.LoadScene(OpenDialog1.FileName);
    m_fileMng.AddfilePath(OpenDialog1.FileName);
    // обновление деревьев
    //lincFrames;
  end;
end;

procedure TGlFrm.EnableComponent(state:boolean);
var i:integer;
begin
  if enablecomponents<>state then
  begin
    for I := 0 to ComponentCount-1 do
    begin
      if Components[i].InheritsFrom(TControl) then
        tcontrol(Components[i]).Enabled:=state;
    end;
    enablecomponents:=state;
  end;
end;

procedure TGlFrm.FormClick(Sender: TObject);
var i:integer;
    b:boolean;
begin
  b:=EnableComponents;
  EnableComponent(false);
  self.SetFocus;
  EnableComponent(b);
end;

procedure TGlFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  m_fileMng.destroy;
  m_HelpMng.destroy;
  g_UI.destroy;
end;

procedure TGlFrm.FormShow(Sender: TObject);
begin
  init;
  linkFrames;
end;

procedure TGlFrm.changecursorOnUnselect(sender:tobject);
begin
  if g_ui.cursor<>crdefault then
  begin
    g_ui.cursor:=crdefault;
    cursor:=g_ui.cursor;
  end;
end;

procedure TGlFrm.OnInitContext(sender:tobject);
var cur:ccursor;
    i:integer;
begin
  for I := 0 to g_ui.cursors.Count - 1 do
  begin
    cur:=ccursor(g_ui.cursors.Objects[i]);
    screen.Cursors[cur.index]:=cur.HIcon;
  end;
end;

procedure TGlFrm.Recentlyopenedfiles1Click(Sender: TObject);
begin
  if m_fileMng.bclick then
  begin
    m_fileMng.bclick:=false;
    OpenDialog1.FileName:=m_fileMng.GetClickItem;
    g_UI.m_RenderScene.LoadScene(OpenDialog1.FileName);
    g_ui.eventlist.CallAllEvents(E_glLoadScene);
  end;
end;


procedure TGlFrm.init;
var
  menuitem:TMenuItem;
  //fr:cClickFrListener;
begin
  DecimalSeparator:=',';
  enablecomponents:=true;
  // При передаче хендла в класс cUInterface он подвязывается для прорисовки окна
  // и для отлавливания wm_message.
  g_UI:=cUI.Create(Handle,extractfiledir(application.ExeName)+'\files\resources.ini');
  m_fileMng:=cFileMng.Create(ExtractFileDir(Application.ExeName)+'\files\Main.ini',
                             MainMenu1,
                             FileMngName,
                             TestRecentFiles);
  m_HelpMng:=cFileMng.Create(ExtractFileDir(Application.ExeName)+'\files\HelpFiles.ini',
                             MainMenu1,
                             HelpFiles,
                             TestRecentFiles);
  //CreateFrames;
  //SceneTreeViewFrame1.GetUI(g_UI);
  //TransformToolsFrame1.Lincscene(g_UI);
  //fr:=cClickFrListener.create(g_UI,cClickFrListener.ClassName);
  //g_UI.framelistener.add(fr);
  //MatFrame.LincToScene(g_UI);
  menuitem:=MainMenu1.items[0];
  //g_ui.EventList.AddEvent('OnObjClick',e_glOnClick,OnObjClick);
  g_ui.EventList.AddEvent('formclick',E_glWindowClick, FormClick);
  g_ui.EventList.AddEvent('changecursorunselect',e_glUnSelect, changecursorOnUnselect);
  OnInitContext(nil);
  //LincFrames;
  //SlaveForm1.lincUI(g_UI);
end;


end.
