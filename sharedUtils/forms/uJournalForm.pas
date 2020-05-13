unit uJournalForm;

interface

uses
  Windows, Forms, Menus, ComCtrls, uBtnListView, StdCtrls, uFileMng, sysutils,
  Dialogs,
  Controls, Classes, uEventTypes, ExtCtrls,
  ueventlist,
  ulogFrame, ulogfile;

type
  TJournalForm = class(TForm)
    LogGB: TGroupBox;
    LogFrame1: TLogFrame;
  private
  public
    procedure init(f:clogfile);
  end;

var
  JournalForm: TJournalForm;

implementation

{$R *.dfm}
procedure TJournalForm.init(f:clogfile);
begin
  logframe1.init(f);
end;


end.
