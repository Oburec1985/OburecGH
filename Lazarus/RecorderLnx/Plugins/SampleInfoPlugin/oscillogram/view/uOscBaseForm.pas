unit uOscBaseForm;
{$mode objfpc}{$H+}{$codepage UTF8}
{ The Base-page oscillogram layout, controls and behavior belong to the plugin.
  Host domain models, controllers and UI classes are forbidden here. Catalog
  and units are borrowed plugin-local facades over standard SDK services. }
interface
uses Classes, SysUtils, Math, Forms, Controls, ExtCtrls, StdCtrls, Spin,
  uOscView, uOscTags, uOscUnits;
type
  TOscBaseForm = class(TForm)
  published
    TopPan: TPanel;
    CountLabel, FpsLabel: TLabel;
    CountEdit: TSpinEdit;
    Surface: TOscBaseSurface;
    procedure CountEditChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    fTags: TOscTagRegistry;
    fDisplaySeconds: Double;
    fUpdating, fRunning: Boolean;
    fOnCountChanged: TNotifyEvent;
    function GetCount: Integer;
    procedure RebuildSurface;
  public
    ViewId: QWord;
    procedure Configure(ATags: TOscTagRegistry; AUnits: TOscUnitCatalog;
      ACount: Integer = 2; ADisplaySeconds: Double = 1);
    procedure Refresh(ARunning: Boolean);
    property Count: Integer read GetCount;
    property OnCountChanged: TNotifyEvent read fOnCountChanged write fOnCountChanged;
  end;
implementation
{$R *.lfm}

function TOscBaseForm.GetCount: Integer;
begin
  Result := CountEdit.Value;
end;

procedure TOscBaseForm.Configure(ATags: TOscTagRegistry;
  AUnits: TOscUnitCatalog; ACount: Integer; ADisplaySeconds: Double);
begin
  if (ADisplaySeconds <= 0) or IsNan(ADisplaySeconds) or
    IsInfinite(ADisplaySeconds) then
    raise EArgumentException.Create('Base-page display window must be finite and positive');
  fUpdating := True;
  try
    fTags := ATags;
    fDisplaySeconds := ADisplaySeconds;
    Surface.UnitCatalog := AUnits;
    CountEdit.Value := EnsureRange(ACount, 1, 16);
    RebuildSurface;
  finally fUpdating := False; end;
end;

procedure TOscBaseForm.RebuildSurface;
begin
  if fTags = nil then Exit;
  Surface.Rebuild(fTags, Count, fDisplaySeconds);
  Refresh(fRunning);
end;

procedure TOscBaseForm.Refresh(ARunning: Boolean);
begin
  fRunning := ARunning;
  if fTags = nil then Exit;
  Surface.Refresh(fTags, fDisplaySeconds, ARunning);
  FpsLabel.Caption := Surface.FpsText;
end;

procedure TOscBaseForm.CountEditChange(Sender: TObject);
begin
  if fUpdating or (fTags = nil) then Exit;
  RebuildSurface;
  if Assigned(fOnCountChanged) then fOnCountChanged(Self);
end;

procedure TOscBaseForm.FormResize(Sender: TObject);
begin
  if not fUpdating and (Surface <> nil) and (fTags <> nil) then
    RebuildSurface;
end;
end.
