unit uRecorderImpactSessionCommands;

{ LCL application-shell adapter for session commands. It owns dialogs and
  adapter selection; the view and headless service remain free of file UI. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Dialogs, uRecorderImpactSessionContracts,
  uRecorderImpactHammerService;

type
  TRecorderImpactSavePathProvider = function: string of object;

  TRecorderImpactSessionCommands = class(TInterfacedObject,
    IRecorderImpactSessionCommandPort)
  private
    fService: TRecorderImpactHammerService;
    fMdb: IRecorderImpactMdbAdapter;
    fWinPos: IRecorderImpactExternalToolPort;
    fSavePath: string;
    procedure ReportError(const AError: string);
  public
    constructor Create(AService: TRecorderImpactHammerService;
      const AMdb: IRecorderImpactMdbAdapter;
      const AWinPos: IRecorderImpactExternalToolPort;
      const ASavePath: string = '');
    procedure Execute(ACommand: TRecorderImpactSessionCommand);
  end;

procedure SetRecorderImpactDefaultSavePathProvider(
  AProvider: TRecorderImpactSavePathProvider);

implementation

uses
  uRecorderImpactSessionJson, uRecorderImpactSessionCsv;

var
  GDefaultSavePathProvider: TRecorderImpactSavePathProvider = nil;

procedure SetRecorderImpactDefaultSavePathProvider(
  AProvider: TRecorderImpactSavePathProvider);
begin
  GDefaultSavePathProvider := AProvider;
end;

constructor TRecorderImpactSessionCommands.Create(
  AService: TRecorderImpactHammerService; const AMdb: IRecorderImpactMdbAdapter;
  const AWinPos: IRecorderImpactExternalToolPort; const ASavePath: string);
begin
  inherited Create;
  fService := AService;
  fMdb := AMdb;
  fWinPos := AWinPos;
  fSavePath := ASavePath;
end;

procedure TRecorderImpactSessionCommands.ReportError(const AError: string);
begin
  if AError <> '' then
    MessageDlg('Ударный FRF', AError, mtError, [mbOK], 0);
end;

procedure TRecorderImpactSessionCommands.Execute(
  ACommand: TRecorderImpactSessionCommand);
var
  SaveDialog: TSaveDialog;
  OpenDialog: TOpenDialog;
  Store: IRecorderImpactSessionStore;
  Csv: IRecorderImpactSessionCsvExporter;
  Comparison: IRecorderImpactComparisonPort;
  Snapshot: TRecorderImpactSessionSnapshot;
  Options: TRecorderImpactSessionSaveOptions;
  ErrorText: string;
  InitialSavePath: string;
begin
  if fService = nil then
    Exit;
  Options.SaveT0 := True;
  Options.IncludeRawBlocks := True;
  Options.IncludeSpectra := True;
  case ACommand of
    iscSavePortable, iscSaveCsv, iscSaveMdb:
      begin
        SaveDialog := TSaveDialog.Create(nil);
        try
          InitialSavePath := fSavePath;
          if (InitialSavePath = '') and Assigned(GDefaultSavePathProvider) then
            InitialSavePath := GDefaultSavePathProvider();
          if (InitialSavePath <> '') and DirectoryExists(InitialSavePath) then
            SaveDialog.InitialDir := InitialSavePath;
          case ACommand of
            iscSavePortable:
              SaveDialog.Filter := 'Recorder Impact Session (*.ihs.json)|*.ihs.json';
            iscSaveCsv:
              SaveDialog.Filter := 'CSV (*.csv)|*.csv';
            iscSaveMdb:
              SaveDialog.Filter := 'Microsoft Access (*.mdb)|*.mdb';
          end;
          if not SaveDialog.Execute then
            Exit;
          if ACommand = iscSaveCsv then
          begin
            Csv := TRecorderImpactSessionCsvExporter.Create;
            fService.BuildSessionSnapshot(Snapshot);
            if not Csv.ExportCsv(SaveDialog.FileName, Snapshot, Options,
              ErrorText) then
              ReportError(ErrorText);
          end
          else
          begin
            if ACommand = iscSavePortable then
              Store := TRecorderImpactSessionJsonStore.Create
            else
              Store := fMdb;
            if not fService.SaveSession(SaveDialog.FileName, Store, Options,
              ErrorText) then
              ReportError(ErrorText);
          end;
        finally
          SaveDialog.Free;
        end;
      end;
    iscImportComparison:
      begin
        OpenDialog := TOpenDialog.Create(nil);
        try
          OpenDialog.Filter :=
            'Recorder Impact Session (*.ihs.json)|*.ihs.json|Все файлы|*.*';
          if not OpenDialog.Execute then
            Exit;
          Comparison := TRecorderImpactSessionJsonStore.Create;
          if not fService.ImportComparison(OpenDialog.FileName, Comparison,
            ErrorText) then
            ReportError(ErrorText);
        finally
          OpenDialog.Free;
        end;
      end;
    iscLaunchWinPos:
      begin
        if fWinPos = nil then
        begin
          ReportError('Адаптер WinPos не установлен.');
          Exit;
        end;
        fService.BuildSessionSnapshot(Snapshot);
        if not fWinPos.LaunchWinPos(Snapshot, ErrorText) then
          ReportError(ErrorText);
      end;
  end;
end;

end.
