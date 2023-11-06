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
    OpenDialog1: TOpenDialog;
    PathBtn: TButton;
  private
    { Private declarations }
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


end.
