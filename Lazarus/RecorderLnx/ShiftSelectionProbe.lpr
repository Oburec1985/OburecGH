program ShiftSelectionProbe;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Classes, SysUtils, Controls, Grids, Types,
  uRecorderSettingsDialog;
var D: TRecorderSettingsDialog; G: TStringGrid; R: TRect;
begin
  try
    Application.Initialize;
    D := TRecorderSettingsDialog.Create(nil);
    try
      G := TStringGrid(D.FindComponent('fSelectedChannelsGrid'));
      if (G = nil) or not Assigned(G.OnMouseDown) then Halt(1);
      G.RowCount := 10;
      G.Selection := TGridRect(Rect(0, 2, G.ColCount - 1, 2));
      R := G.CellRect(1, 5);
      G.OnMouseDown(G, mbLeft, [ssShift], R.Left + 2, R.Top + 2);
      if (G.Selection.Top <> 2) or (G.Selection.Bottom <> 2) then Halt(2);
      G.OnMouseDown(G, mbLeft, [ssCtrl], R.Left + 2, R.Top + 2);
      if (G.Selection.Top <> 2) or (G.Selection.Bottom <> 2) then Halt(3);
      G.OnMouseDown(G, mbLeft, [], R.Left + 2, R.Top + 2);
      if (G.Selection.Top <> 5) or (G.Selection.Bottom <> 5) then Halt(4);
    finally D.Free; end;
  except
    on E: Exception do
    begin
      with TStringList.Create do
      try
        Add(E.ClassName + ': ' + E.Message);
        SaveToFile(GetTempDir + 'shift-selection-probe-error.txt');
      finally Free; end;
      Halt(10);
    end;
  end;
end.
