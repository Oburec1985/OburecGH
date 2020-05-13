unit uJournalForm;

interface

uses
  Windows, Forms, Menus, ComCtrls, uBtnListView, StdCtrls, uFileMng, sysutils,
  uBlInterfaceFrame, uBldEng,  ubldCompProc, uBldObj, Dialogs,
  uLfmFile, Controls, Classes, uEventTypes, uCompaundFrame, ExtCtrls, uframeevents,
  uSensorFrame, uBldFile, uSystemInfoFrame, uEditListFrame, ueventlist, usensor,
  ustage, upair, uGlTurbineFrame, ulogFrame;

type
  TJournalForm = class(TForm)
    LogGB: TGroupBox;
    LogFrame1: TLogFrame;
  private
  public
    procedure lincEng(e:cbldeng);
  end;

var
  JournalForm: TJournalForm;

implementation

{$R *.dfm}
procedure TJournalForm.lincEng(e:cbldeng);
begin
  logframe1.init(e.logFile);
end;


end.
