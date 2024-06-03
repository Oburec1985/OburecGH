unit uGLFrmEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  uMeasureBase,
  uMBaseControl,
  StdCtrls;

type
  TObjFrm3dEdit = class(TForm)
    ShowTrfrmToolsCB: TCheckBox;
    CancelBtn: TButton;
    OkBtn: TButton;
    SceneFolderEdit: TEdit;
    Label1: TLabel;
    SceneNameEdit: TEdit;
    Label2: TLabel;
    PathBtn: TButton;
    OpenDialog1vista: TFileOpenDialog;
    procedure PathBtnClick(Sender: TObject);
  private

  public
    procedure edit(glFrm:tobject);
  end;

var
  g_ObjFrm3dEdit:TObjFrm3dEdit;

implementation
uses
  u3dObj;

{$R *.dfm}

Procedure TObjFrm3dEdit.edit(glFrm:tobject);
var
  scenepath:string;
begin
  ShowTrfrmToolsCB.Checked:=TObjFrm3d(glFrm).ShowTools;
  scenepath:=TObjFrm3d(glFrm).BuildPath;
  SceneFolderEdit.Text:=extractfiledir(scenepath);
  SceneNameEdit.Text:=ExtractFileName(scenepath);
  if showModal=mrok then
  begin
    TObjFrm3d(glFrm).ShowTools:=ShowTrfrmToolsCB.Checked;
    TObjFrm3d(glFrm).m_ScenePath:= SceneFolderEdit.Text;
    TObjFrm3d(glFrm).m_SceneName:=SceneNameEdit.Text;
  end;
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
