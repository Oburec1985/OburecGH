program FrfRouteTest;
{$mode objfpc}{$H+}
uses Classes, SysUtils, IniFiles, uRecorderFrfRepository, uRecorderFrfRoute;

procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage) end;

{ Route unit tests only the committed descriptor marker. The MERA codec has its
  own round-trip tests; this fixture must not duplicate its format. }
procedure CommitDescriptor(const APointDirectory: string);
var lIni: TMemIniFile; lDirectory: string;
begin
  lDirectory := IncludeTrailingPathDelimiter(APointDirectory) + 'frf';
  ForceDirectories(lDirectory);
  lIni := TMemIniFile.Create(lDirectory + PathDelim + 'session.mera');
  try
    lIni.WriteString('Test', 'Marker', 'Committed');
    lIni.UpdateFile;
  finally lIni.Free end;
end;

var lRoute, lReload: TRecorderFrfRoute; lEntry: TRecorderFrfRouteEntry;
  lCurve: TRecorderFrfCurveData;
  lDirectory, lConfigFile, lLegacyText: string; lGuid: TGUID;
  lFiles, lLegacy: TStringList; lIndex: Integer;
  lIni: TMemIniFile;
  lBinding: TRecorderFrfRouteBinding;
begin
  CreateGUID(lGuid);
  lDirectory := IncludeTrailingPathDelimiter(GetTempDir) + 'frf-route-' + GUIDToString(lGuid);
  lRoute := TRecorderFrfRoute.Create;
  lReload := TRecorderFrfRoute.Create;
  lFiles := TStringList.Create;
  lLegacy := TStringList.Create;
  try
    lConfigFile := lDirectory + '-project' + PathDelim + 'route.ini';
    lRoute.ConfigFileName := lConfigFile;
    lReload.ConfigFileName := lConfigFile;
    lEntry := Default(TRecorderFrfRouteEntry);
    lEntry.ChannelIndex := 0; lEntry.PointNumber := 7;
    lEntry.TargetNodeId := 100; lEntry.TargetNodeName := 'Object A';
    lRoute.Add(lEntry);
    Check(lRoute[0].PointLabel = '1', 'Default label is step ordinal');
    lBinding := Default(TRecorderFrfRouteBinding);
    lBinding.ChannelIndex := 0;
    lBinding.PointNumber := 7;
    lBinding.PointLabel := 'sensor-A';
    lBinding.TargetNodeId := 100;
    lBinding.SceneComponentId := 'scene-A';
    lRoute.AddBinding(0, lBinding);
    lBinding.ChannelIndex := 1;
    lBinding.PointNumber := 8;
    lRoute.AddBinding(0, lBinding);
    lEntry.PointNumber := 8; lEntry.TargetNodeId := 200;
    lEntry.TargetNodeName := 'Object B';
    lEntry.PointLabel := 'Route B-12';
    lRoute.Add(lEntry);
    Check(lRoute[0].CurveId <> lRoute[1].CurveId, 'Duplicate channel needs distinct snapshot IDs');
    lRoute.Save(lDirectory);
    Check(FileExists(lConfigFile), 'Route is stored in project configuration');
    Check(not FileExists(lDirectory + '/route.ini'), 'No manifest in results');
    lRoute.SetPointLabel(0, 'Route A-01');
    Check(not lRoute.AllComplete, 'Incomplete route must refuse completion');
    lCurve.Id := 1;
    SetLength(lCurve.FrequencyHz, 2); SetLength(lCurve.Magnitude, 2);
    SetLength(lCurve.PhaseRadians, 2); SetLength(lCurve.Coherence, 2);
    SetLength(lCurve.Amplitude, 2);
    lCurve.FrequencyHz[0] := 10; lCurve.FrequencyHz[1] := 20;
    lCurve.Magnitude[0] := 2.5; lCurve.Magnitude[1] := 3.5;
    lCurve.Amplitude[0] := 7.25; lCurve.Amplitude[1] := 8.25;
    try
      lRoute.CaptureCurrent(lCurve);
      raise Exception.Create('Capture without MERA descriptor accepted');
    except
      on E: Exception do
        Check(Pos('Save MERA realization', E.Message) > 0,
          'Missing MERA descriptor must be rejected');
    end;
    Check(lRoute.CurrentIndex = 0, 'Rejected capture does not advance');
    CommitDescriptor(lRoute.PointDirectory(0));
    lRoute.CaptureCurrent(lCurve);
    Check(lRoute.CurrentIndex = 1, 'Capture must advance');
    lCurve.Magnitude[0] := 99;
    CommitDescriptor(lRoute.PointDirectory(1));
    lRoute.CaptureCurrent(lCurve);
    Check(not FileExists(lRoute.PointDirectory(0) + '/curve.frf'),
      'Route never writes duplicate legacy curve');
    lReload.Load(lDirectory);
    Check(Length(lReload[0].Bindings) = 2, 'Multiple mappings per step persisted');
    Check(lReload[0].Bindings[1].ChannelIndex = 1, 'Mapped channel persisted');
    Check(lReload[0].Bindings[1].SceneComponentId = 'scene-A', 'Mapped scene persisted');
    Check(lReload.CurrentIndex = 0, 'Current UI step is not route configuration');
    Check(lReload[0].TargetNodeName = 'Object A', 'Object persisted');
    Check(lReload[0].PointLabel = 'Route A-01', 'Edited route label persisted');
    Check(lReload[1].PointLabel = 'Route B-12', 'Custom label persisted');
    lReload.SetPointLabel(1, '');
    Check(lReload[1].PointLabel = '8', 'Empty label restores object point number');
    lIni := TMemIniFile.Create(lConfigFile);
    try
      Check(not lIni.ValueExists('Route', 'Current'), 'UI step not persisted');
      Check(not lIni.ValueExists('Point0', 'Captured'), 'Saved state rediscovered from MERA');
      lIni.DeleteKey('Point0', 'PointLabel');
      lIni.WriteInteger('Route', 'Version', 1);
      lIni.UpdateFile;
    finally lIni.Free end;
    lReload.Load(lDirectory);
    Check(lReload[0].PointLabel = '7', 'Legacy route defaults missing label to point number');
    Check((Length(lReload[0].Bindings) = 1) and
      (lReload[0].Bindings[0].PointNumber = 7), 'Legacy point migrated to one step mapping');
    Check(lReload.AllComplete, 'Committed MERA route complete after reload');
    lReload.CurrentIndex := 0;
    lEntry := lReload[0];
    lEntry.PointNumber := 11;
    lEntry.PointLabel := 'Edited label';
    lEntry.ChannelIndex := 1;
    lEntry.CurveId := 0;
    lEntry.Captured := False;
    lReload.UpdateEntry(0, lEntry);
    Check(lReload[0].CurveId = lRoute[0].CurveId, 'Edit preserves curve identity');
    Check(lReload[0].Captured, 'Edit preserves saved state');
    lReload.MoveEntry(0, 1);
    Check(lReload.CurrentIndex = 1, 'Reorder retains current point identity');
    Check(lReload.AllComplete, 'Reorder retains committed MERA markers');
    lReload.MoveEntry(1, 0);
    lReload.CaptureEntry(0, lCurve);
    Check(lReload.CurrentIndex = 0, 'Explicit capture does not advance');
    lLegacy.LoadFromFile(lConfigFile);
    lLegacy.SaveToFile(lDirectory + '/route.ini');
    lLegacyText := lLegacy.Text;
    DeleteFile(lConfigFile);
    Check(lReload.HasManifest(lDirectory), 'Legacy manifest available for import');
    lReload.Load(lDirectory);
    Check(lReload.Count = 2, 'Legacy object-local route imported');
    Check(not FileExists(lConfigFile), 'Read-only import does not write configuration');
    lReload.Save(lDirectory);
    Check(FileExists(lConfigFile), 'Explicit save migrates route to project');
    lLegacy.LoadFromFile(lDirectory + '/route.ini');
    Check(lLegacy.Text = lLegacyText, 'Migration leaves old object-local file untouched');
    lReload.SetDirectory(lDirectory + '-other-object');
    Check(not lReload[0].Captured, 'Other object has independent saved state');
    Check(lReload.ConfigFileName = lConfigFile, 'Object change retains project route path');
    lReload.SetDirectory(lDirectory);
    Check(lReload[0].Captured, 'Original object saved state rediscovered');
    lFiles.Add(lRoute.PointDirectory(0) + '/frf/session.mera');
    lFiles.Add(lRoute.PointDirectory(1) + '/frf/session.mera');
    DeleteFile(lFiles[0]);
    Check(not lReload.AllComplete, 'Missing MERA descriptor refuses completion');
    lReload.ResetProgress;
    Check(lReload.CurrentIndex = 0, 'Resume first missing snapshot');
    lFiles.Add(lConfigFile);
    lFiles.Add(lDirectory + '/route.ini');
    WriteLn('RESULT FrfRouteTest passed');
  finally
    for lIndex := 0 to lFiles.Count - 1 do DeleteFile(lFiles[lIndex]);
    RemoveDir(lRoute.PointDirectory(0) + '/frf');
    RemoveDir(lRoute.PointDirectory(1) + '/frf');
    RemoveDir(lRoute.PointDirectory(0));
    RemoveDir(lRoute.PointDirectory(1));
    RemoveDir(lDirectory);
    RemoveDir(lDirectory + '-project');
    lLegacy.Free; lFiles.Free; lReload.Free; lRoute.Free;
  end;
end.
