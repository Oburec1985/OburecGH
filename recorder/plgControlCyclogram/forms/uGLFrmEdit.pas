unit uGLFrmEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TObjFrm3dEdit = class(TForm)
    ShowTrfrmToolsCB: TCheckBox;
    CancelBtn: TButton;
    OkBtn: TButton;
    //procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure edit(glFrm:tobject);
  end;

var
  ObjFrm3dEdit:TObjFrm3dEdit;

implementation
uses
  u3dObj;

{$R *.dfm}

Procedure TObjFrm3dEdit.edit(glFrm:tobject);
begin
  ShowTrfrmToolsCB.Checked:=TObjFrm3d(glFrm).ShowTools;
  if showModal=mrok then
  begin
    TObjFrm3d(glFrm).ShowTools:=ShowTrfrmToolsCB.Checked;
  end;
end;


end.
