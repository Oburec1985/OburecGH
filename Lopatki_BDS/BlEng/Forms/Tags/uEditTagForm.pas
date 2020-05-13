unit uEditTagForm;

interface

uses
  Windows, SysUtils, Graphics, Forms,  StdCtrls, uTagPropertiesFrame, uTag,
  Classes, Controls, uBldTimeProc;

type
  TEditTagForm = class(TForm)
    ActionGB: TGroupBox;
    ApplyBtn: TButton;
    CancelBtn: TButton;
    TagPropertiesFrame1: TTagPropertiesFrame;
  private

  public
    procedure Linc(tproc:cbldtimeproc);
    procedure EditTag(tag:cbasetag);
  end;

var
  EditTagForm: TEditTagForm;

implementation

{$R *.dfm}
procedure TEditTagForm.Linc(tproc:cbldtimeproc);
begin
  TagPropertiesFrame1.linc(tproc);
end;

procedure TEditTagForm.EditTag(tag:cbasetag);
begin
  TagPropertiesFrame1.setTag(tag);
  if showmodal=mrok then
  begin
    TagPropertiesFrame1.gettag;
  end;
end;

end.
