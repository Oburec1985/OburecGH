program SettingsLayoutUiSmoke;

{ Regression for designer-owned Recorder settings layout. Construct the real
  production form, show it and resize it; never attach a recorder or touch
  devices/settings. LFM owns the geometry, not post-show label measurements. }

{$mode objfpc}{$H+}
uses
  Interfaces, Forms, Classes, SysUtils, Controls, StdCtrls,
  uRecorderSettingsDialog;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

function Control(AForm: TForm; const AName: string): TControl;
begin
  Check(AForm.FindComponent(AName) is TControl, 'Missing control: ' + AName);
  Result := TControl(AForm.FindComponent(AName));
end;

procedure CheckGeometry(AForm: TForm; AExpectedLeft, AExpectedWidth: Integer;
  const AStage: string);
var
  lBuffer, lUpdate, lBufferSec, lUpdateSec, lBufferLabel, lUpdateLabel: TControl;
begin
  lBuffer := Control(AForm, 'fBufferSecondsEdit');
  lUpdate := Control(AForm, 'fDataUpdateEdit');
  lBufferSec := Control(AForm, 'lbBufferSecondsSec');
  lUpdateSec := Control(AForm, 'lbDataUpdateSec');
  lBufferLabel := Control(AForm, 'lbBufferSeconds');
  lUpdateLabel := Control(AForm, 'lbDataUpdate');
  Check(lBuffer.Left = lUpdate.Left, AStage + ': input left edges differ');
  Check(lBuffer.Width = lUpdate.Width, AStage + ': input widths differ');
  Check((lBuffer.Left = AExpectedLeft) and (lBuffer.Width = AExpectedWidth),
    AStage + ': runtime changed LFM geometry');
  Check(lBufferSec.Left = lUpdateSec.Left, AStage + ': seconds labels differ');
  Check(lBuffer.Left >= lBufferLabel.Left + lBufferLabel.Width,
    AStage + ': buffer label overlaps input');
  Check(lUpdate.Left >= lUpdateLabel.Left + lUpdateLabel.Width,
    AStage + ': update label overlaps input');
  Check(lBufferSec.Left >= lBuffer.Left + lBuffer.Width,
    AStage + ': seconds label overlaps input');
  WriteLn(AStage, ': left=', lBuffer.Left, ' width=', lBuffer.Width,
    ' seconds-left=', lBufferSec.Left);
end;

procedure Run;
var
  lForm: TRecorderSettingsDialog;
  lLeft, lWidth: Integer;
begin
  lForm := TRecorderSettingsDialog.Create(nil);
  try
    lLeft := Control(lForm, 'fBufferSecondsEdit').Left;
    lWidth := Control(lForm, 'fBufferSecondsEdit').Width;
    CheckGeometry(lForm, lLeft, lWidth, 'created');
    lForm.Show;
    Application.ProcessMessages;
    CheckGeometry(lForm, lLeft, lWidth, 'shown');
    lForm.Width := lForm.Width + 180;
    lForm.Height := lForm.Height + 90;
    Application.ProcessMessages;
    CheckGeometry(lForm, lLeft, lWidth, 'enlarged');
    lForm.Width := lForm.Constraints.MinWidth;
    lForm.Height := lForm.Constraints.MinHeight;
    Application.ProcessMessages;
    CheckGeometry(lForm, lLeft, lWidth, 'minimum');
    lForm.Hide;
    lForm.Show;
    Application.ProcessMessages;
    CheckGeometry(lForm, lLeft, lWidth, 'reshown');
  finally
    lForm.Free;
  end;
end;

begin
  Application.Initialize;
  try
    Run;
    WriteLn('RESULT SettingsLayoutUiSmoke create/show/resize/reshow passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT SettingsLayoutUiSmoke failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
