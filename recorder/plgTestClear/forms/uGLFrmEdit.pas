unit uGLFrmEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TglFrmEdit = class(TForm)
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
  glFrmEdit:TglFrmEdit;

implementation
uses
  uGlFrm;

{$R *.dfm}

Procedure TglFrmEdit.edit(glFrm:tobject);
begin
  ShowTrfrmToolsCB.Checked:=cGLFrm(glFrm).ShowTools;
  if showModal=mrok then
  begin
    cGLFrm(glFrm).ShowTools:=ShowTrfrmToolsCB.Checked;
  end;
end;


end.
