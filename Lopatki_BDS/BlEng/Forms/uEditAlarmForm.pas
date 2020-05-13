unit uEditAlarmForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  uAlarmEditFrame, StdCtrls, uAlarms, uTag;

type
  TEditAlarmForm = class(TForm)
    AlarmGB: TGroupBox;
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    OkBtn: TButton;
    EditAlarmFrame1: TEditAlarmFrame;
  private

  public
    function CreateAlarm(aMng:cAlarmMng; t:cbasetag):cAlarm;
    procedure editAlarm(a:calarm);
  end;

var
  EditAlarmForm: TEditAlarmForm;

implementation

{$R *.dfm}

function TEditAlarmForm.CreateAlarm(aMng:cAlarmMng; t:cbasetag):cAlarm;
begin
  result:=nil;
  EditAlarmFrame1.NameEdit.text:=t.name+'_Alarm';
  if showmodal=mrok then
  begin
    result:=aMng.createalarm;
    EditAlarmFrame1.a:=result;
    EditAlarmFrame1.SetAlarm;
  end;
end;

procedure TEditAlarmForm.editAlarm(a:calarm);
begin
  EditAlarmFrame1.GetAlarm(a);
  if showmodal=mrok then
  begin
    EditAlarmFrame1.SetAlarm;
  end;
end;

end.
