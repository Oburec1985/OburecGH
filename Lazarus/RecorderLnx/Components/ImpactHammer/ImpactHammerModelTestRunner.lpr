program ImpactHammerModelTestRunner;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, SysUtils, Graphics, FPImage, IntfGraphics,
  uRecorderTags, uRecorderImpactHammerModel,
  uRecorderImpactHammerModelTests, uRecorderImpactHammerSettingsDialog;

procedure CheckSettingsDialogCreation;
var
  lComponent: TRecorderImpactHammerComponent;
  lDialog: TRecorderImpactHammerSettingsDialog;
  lBitmap: TBitmap;
  lPng: TPortableNetworkGraphic;
begin
  Application.Initialize;
  lComponent := TRecorderImpactHammerComponent.Create;
  lDialog := nil;
  try
    try
      lDialog := TRecorderImpactHammerSettingsDialog.CreateDialog(nil,
        lComponent, nil);
    except
      on E: Exception do
      begin
        WriteLn(E.ClassName + ': ' + E.Message);
        raise;
      end;
    end;
    if lDialog.grdAxes.RowCount <> 6 then
      raise Exception.Create('FRF axis settings grid was not initialized');
    lDialog.Show;
    Application.ProcessMessages;
    lBitmap := lDialog.GetFormImage;
    lPng := TPortableNetworkGraphic.Create;
    try
      lPng.Assign(lBitmap);
      lPng.SaveToFile(ExtractFilePath(ParamStr(0)) +
        'impact-frf-settings.png');
    finally
      lPng.Free;
      lBitmap.Free;
    end;
  finally
    lDialog.Free;
    lComponent.Free;
  end;
end;

begin
  try
    RunRecorderImpactHammerModelTests;
    CheckSettingsDialogCreation;
    WriteLn('RESULT passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT failed: ' + E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
