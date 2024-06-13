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
  StdCtrls, ExtCtrls, uTagsListFrame;

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
    procedure PathBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    finit:boolean;
    m_glFrm:tform;
    skinframe:TVertexEditFrame;
    frames:tlist;
    m_curObj:cnodeobject;
    e:cEvent;
  protected
    procedure createevents;
    procedure destroyevents;
    procedure OnSelectObj(sender:tobject);
  public
    procedure init(t3dfrm:tform);
    function getFrame(s:string):tframe;
    procedure edit(glFrm:tobject);
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

var
  g_ObjFrm3dEdit:TObjFrm3dEdit;

implementation
uses
  u3dObj;

{$R *.dfm}

procedure TObjFrm3dEdit.createevents;
begin
  e:=TObjFrm3d(m_glFrm).GL.mUI.eventlist.AddEvent('TObjFrm3dEdit_OnSelObj',E_glSelectNew,OnSelectObj);
  e.active:=false;
end;

procedure TObjFrm3dEdit.destroyevents;
begin
  TObjFrm3d(m_glFrm).GL.mUI.eventlist.removeEvent(OnSelectObj, E_glSelectNew);
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
  //fr:=getFrame('TVertexEditFrame');
  skinframe.Align:=alClient;
  init(m_glFrm);
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

procedure TObjFrm3dEdit.init(t3dfrm: tform);
begin
  m_glFrm:= t3dfrm;
  if not finit then
  begin
    finit:=true;
    skinframe.m_ui:=TObjFrm3d(m_glFrm).GL.mUI;
    createevents;
    skinframe.createevents;
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
begin
  if TObjFrm3d(m_glFrm).GL.mUI.selectCount>0 then
  begin
    m_curObj:=TObjFrm3d(m_glFrm).GL.mUI.getselected(0);
    skinframe.showObj(cobject(m_curObj), m_glFrm);
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
