unit uRecorderImpactSessionContracts;

{ Immutable, UI-neutral exchange boundary for impact-hammer sessions. Domain
  services build snapshots; file, MDB and external-tool adapters implement the
  ports without introducing storage APIs into acquisition or presentation. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  TRecorderImpactSessionSample = record
    TimeSeconds: Double;
    Value: Double;
  end;

  TRecorderImpactSessionSeries = record
    TagId: QWord;
    CurveId: QWord;
    Name: string;
    UnitName: string;
    Samples: array of TRecorderImpactSessionSample;
  end;

  TRecorderImpactSessionImpact = record
    Sequence: QWord;
    TriggerTimeSeconds: Double;
    Accepted: Boolean;
    Hidden: Boolean;
    Excitation: TRecorderImpactSessionSeries;
    Responses: array of TRecorderImpactSessionSeries;
  end;

  TRecorderImpactSessionCurve = record
    CurveId: QWord;
    TagId: QWord;
    Name: string;
    ExcitationUnitName: string;
    ResponseUnitName: string;
    FrequencyHz: array of Double;
    ExcitationSpectrum: array of Double;
    ResponseSpectrum: array of Double;
    Magnitude: array of Double;
    PhaseRadians: array of Double;
    Coherence: array of Double;
  end;

  TRecorderImpactSessionSnapshot = record
    FormatVersion: Integer;
    SessionId: string;
    CreatedUtc: TDateTime;
    SampleRateHz: Double;
    Impacts: array of TRecorderImpactSessionImpact;
    Curves: array of TRecorderImpactSessionCurve;
  end;

  TRecorderImpactSessionSaveOptions = record
    SaveT0: Boolean;
    IncludeRawBlocks: Boolean;
    IncludeSpectra: Boolean;
  end;

  IRecorderImpactSessionStore = interface
    ['{EB8C8725-DACE-426E-A3F3-D9E7971C3068}']
    function Save(const AFileName: string;
      const ASnapshot: TRecorderImpactSessionSnapshot;
      const AOptions: TRecorderImpactSessionSaveOptions;
      out AError: string): Boolean;
    function Load(const AFileName: string;
      out ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean;
  end;

  { Imported comparison sessions are presented through the same immutable
    snapshot contract and never mutate the live acquisition repository. }
  IRecorderImpactComparisonPort = interface
    ['{5267AD43-D726-48A9-8EAF-E1005DDB56AA}']
    function ImportComparison(const AFileName: string;
      out ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean;
  end;

  IRecorderImpactMdbAdapter = interface(IRecorderImpactSessionStore)
    ['{7D96F643-A03E-4D12-8A8A-DB438D2E5DC5}']
  end;

  IRecorderImpactExternalToolPort = interface
    ['{5AE76F12-3357-451E-9758-9B77C1A617E3}']
    function LaunchWinPos(const ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean;
  end;

  IRecorderImpactSessionCsvExporter = interface
    ['{A48640D8-438A-42AB-8D41-E6A1CB02842E}']
    function ExportCsv(const AFileName: string;
      const ASnapshot: TRecorderImpactSessionSnapshot;
      const AOptions: TRecorderImpactSessionSaveOptions;
      out AError: string): Boolean;
  end;

  TRecorderImpactSessionCommand = (iscSavePortable, iscSaveCsv, iscSaveMdb,
    iscImportComparison, iscLaunchWinPos);

  { The application shell owns file dialogs and adapter composition. The LFM
    view only emits semantic commands through this port. }
  IRecorderImpactSessionCommandPort = interface
    ['{799EB8DD-4191-41F3-8278-130D9059B6E3}']
    procedure Execute(ACommand: TRecorderImpactSessionCommand);
  end;

implementation

end.
