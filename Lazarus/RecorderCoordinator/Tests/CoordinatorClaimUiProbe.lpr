program CoordinatorClaimUiProbe;
{$mode objfpc}{$H+}{$codepage UTF8}
uses cthreads, Interfaces, Forms, Classes, SysUtils, IniFiles, Graphics,
  fphttpclient, uCoordinatorMainForm;
var
  lForm: TCoordinatorMainForm;
  lIni: TIniFile;
  lPanelId: string;
  lImage: TBitmap;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure Hello(const AOwner, AClaim: string);
var
  lHttp: TFPHTTPClient;
  lBody: TStringStream;
begin
  lHttp := TFPHTTPClient.Create(nil);
  lBody := TStringStream.Create('{"instance_id":"claim-ui-fixture",' +
    '"remote_address":"192.0.2.11","state":"stopped",' +
    '"coordinator_instance_id":"' + AOwner + '",' +
    '"coordinator_claim_id":"' + AClaim + '"}');
  try
    lHttp.AddHeader('Content-Type', 'application/json');
    lHttp.RequestBody := lBody;
    lHttp.Post('http://127.0.0.1:18966/api/v1/clients/hello');
  finally
    lHttp.Free;
    lBody.Free;
  end;
  lForm.timerRefreshTimer(nil);
  lForm.gridHosts.Row := 1;
  lForm.gridHostsSelection(lForm.gridHosts, 2, 1);
  Application.ProcessMessages;
end;

begin
  // Run under `unshare -n` so neither discovery nor probes reach live machines.
  DeleteFile(ChangeFileExt(ParamStr(0), '.ini'));
  lIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    lIni.WriteString('service', 'listen', '127.0.0.1');
    lIni.WriteInteger('service', 'port', 18966);
    lIni.WriteBool('events', 'create_recording_events', False);
    lIni.WriteInteger('hosts', 'count', 0);
    lIni.WriteInteger('storages', 'count', 0);
  finally lIni.Free; end;
  RequireDerivedFormResource := True;
  Application.Initialize;
  lForm := TCoordinatorMainForm.Create(nil);
  try
    lForm.timerRefresh.Enabled := False;
    lForm.Show;
    Application.ProcessMessages;
    lIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
    try lPanelId := lIni.ReadString('coordinator', 'instance_id', '');
    finally lIni.Free; end;
    Check(lPanelId <> '', 'panel identity not persisted');
    Hello('another-panel', 'foreign-claim');
    Check(lForm.btnClaimRecorder.Caption = 'Перехватить', 'missing takeover caption');
    Check(not lForm.btnReleaseRecorder.Enabled, 'foreign owner can be released');
    Check(not lForm.btnCommandStart.Enabled, 'foreign owner can be commanded');
    Hello(lPanelId, 'our-claim');
    Check(lForm.btnClaimRecorder.Caption = 'Захватить', 'wrong own capture caption');
    Check(lForm.btnReleaseRecorder.Enabled, 'own claim cannot be released');
    Check(lForm.btnCommandStart.Enabled, 'confirmed owner cannot be commanded');
    Check(lForm.btnReleaseRecorder.Left + lForm.btnReleaseRecorder.Width <=
      lForm.pnlHostActions.ClientWidth, 'release button clipped');
    lImage := lForm.GetFormImage;
    try lImage.SaveToFile('/tmp/coordinator-claim-ui.bmp');
    finally lImage.Free; end;
    WriteLn('RESULT Coordinator claim UI probe passed');
  finally lForm.Free; end;
end.
