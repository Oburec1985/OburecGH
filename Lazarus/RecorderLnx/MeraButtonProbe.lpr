program MeraButtonProbe;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Classes, SysUtils, StdCtrls, ExtCtrls, ComCtrls, uRecorderSettingsDialog;
var D: TRecorderSettingsDialog; B: TButton; S: TScrollBox;
begin
  try
  Application.Initialize;
  D := TRecorderSettingsDialog.Create(nil);
  try
    if not (D.FindComponent('btnPublishMeraFiles') is TButton) then Halt(1);
    B := TButton(D.FindComponent('btnPublishMeraFiles'));
    if (B.Tag <> 1) or not Assigned(B.OnClick) or not B.Visible then Halt(2);
    if not (D.FindComponent('pnRecorderLeft') is TScrollBox) then Halt(3);
    S := TScrollBox(D.FindComponent('pnRecorderLeft'));
    TPageControl(D.FindComponent('fPageControl')).ActivePage :=
      TTabSheet(D.FindComponent('tsRecorder'));
    D.Width := D.Constraints.MinWidth;
    if not S.AutoScroll then Halt(4);
  finally D.Free; end;
  except
    on E: Exception do
    begin
      with TStringList.Create do
      try
        Add(E.ClassName + ': ' + E.Message);
        SaveToFile(GetTempDir + 'mera-button-probe-error.txt');
      finally Free; end;
      Halt(10);
    end;
  end;
end.
