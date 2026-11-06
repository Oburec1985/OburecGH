program RecorderCoordinatorOwnershipTest;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}cthreads, cwstring,{$ENDIF}
  Classes, SysUtils, IniFiles, fpjson, jsonparser,
  uRecorderCoordinatorOwnership, uRecorderCoordinatorClient;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

var
  lOwner: TRecorderCoordinatorOwnership;
  lConfig, lAgain: TRecorderCoordinatorClientConfig;
  lIni: TIniFile;
  lFile, lId: string;
  lGeneration: QWord;
  lClient: TRecorderCoordinatorClient;
  lData: TJSONData;
  lText: TStringList;
begin
  lOwner := TRecorderCoordinatorOwnership.Create;
  try
    Check(lOwner.CanClaim('panel-A', 'claim-A', False), 'free claim');
    lOwner.Accept('panel-A', 'claim-A', 'http://127.0.0.1:19001', 1000);
    lGeneration := lOwner.Generation;
    Check(not lOwner.CanClaim('panel-B', 'claim-B', False), 'busy claim denied');
    Check(lOwner.CanClaim('panel-B', 'claim-B', True), 'explicit takeover allowed');
    lOwner.Accept('panel-A', 'claim-A', 'http://127.0.0.1:19001', 2000);
    Check(lOwner.Generation = lGeneration, 'retry is idempotent');
    Check(not lOwner.Release('panel-B', 'claim-A'), 'foreign release denied');
    Check(not lOwner.Expire(16999), 'live lease');
    Check(lOwner.Expire(17000), 'expired lease');
    Check(lOwner.CoordinatorId = '', 'released to autonomous');
    Check(not lOwner.CanClaim('panel-A', 'claim-A', True), 'retired claim replay denied');
    Check(lOwner.Generation <> lGeneration, 'old commands fenced');
    lOwner.Accept('panel-B', 'claim-B', 'http://127.0.0.1:19002', 18000);
    Check(not lOwner.Release('panel-A', 'claim-A'), 'stale release denied');
    Check(lOwner.Release('panel-B', 'claim-B'), 'owner release');
    Check(not lOwner.CanClaim('panel-B', 'claim-B', False), 'released claim retry denied');
  finally
    lOwner.Free;
  end;
  lFile := GetTempFileName(GetTempDir, 'ownership');
  try
    lIni := TIniFile.Create(lFile);
    try
      lIni.WriteString('Coordinator', 'BaseUrl', 'http://stale-panel:8765');
    finally
      lIni.Free;
    end;
    lConfig := TRecorderCoordinatorClientConfig.Create;
    lAgain := TRecorderCoordinatorClientConfig.Create;
    try
      lConfig.LoadFromFile(lFile);
      lId := lConfig.InstanceId;
      Check(lConfig.BaseUrl = '', 'legacy fixed endpoint ignored');
      Check(lId <> '', 'identity generated');
      lAgain.LoadFromFile(lFile);
      Check(lAgain.InstanceId = lId, 'identity survives incomplete INI reload');
      lIni := TIniFile.Create(lFile);
      try
        Check(not lIni.ValueExists('Coordinator', 'BaseUrl'), 'legacy endpoint removed');
      finally
        lIni.Free;
      end;
    finally
      lAgain.Free;
      lConfig.Free;
    end;
  finally
    DeleteFile(lFile);
  end;
  lFile := GetTempFileName(GetTempDir, 'event-owner');
  lText := TStringList.Create;
  try
    lText.Text := '[{"internal_kind":"recording_origin",' +
      '"correlation_id":"long-recording","coordinator_id":"panel-A"}]';
    lText.SaveToFile(ChangeFileExt(lFile, '.events.json'));
    lConfig := TRecorderCoordinatorClientConfig.Create;
    lConfig.FileName := lFile;
    lClient := TRecorderCoordinatorClient.Create(lConfig);
    try
      lClient.PublishEvent('recording.completed', 'long-recording', '{}');
      lText.LoadFromFile(ChangeFileExt(lFile, '.events.json'));
      lData := GetJSON(lText.Text);
      try
        Check((lData is TJSONArray) and (TJSONArray(lData).Count = 1),
          'completed recording removes only the origin metadata');
        Check(TJSONObject(TJSONArray(lData)[0]).Get('coordinator_id', '') =
          'panel-A', 'recording completion retains durable former owner');
      finally
        lData.Free;
      end;
    finally
      lClient.Free;
    end;
  finally
    lText.Free;
    DeleteFile(lFile);
    DeleteFile(ChangeFileExt(lFile, '.events.json'));
  end;
  WriteLn('RESULT coordinator ownership and identity passed');
end.
