unit uRecorderDacContracts;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, uRecorderDacTypes, uRecorderBlockClock;

type
  { Worker-side numeric clock update; implementations preserve phase and must
    neither allocate nor reconfigure the native hardware. }
  IRecorderDacPlaybackRateControl = interface
    ['{84D3210B-13EA-4D28-BE0A-5E0AAC4122EC}']
    function CanSetPlaybackSampleRate(ARate: Double; out AResult: TRecorderDacResult): Boolean;
    function SetPlaybackSampleRate(ARate: Double; out AResult: TRecorderDacResult): Boolean;
  end;

  { Publisher commits the clock at the exact generated frame boundary carried
    by the FIFO slot. Older queued blocks retain their preceding clock. }
  IRecorderDacRateControlledMirror = interface
    ['{5A97D029-E134-44B3-BC34-A084DF42CF77}']
    function CanSetRateFactor(AFactor: Double; out AResult: TRecorderDacResult): Boolean;
    function SetRateFactorAtFrame(AFactor: Double; APivotFrame: QWord;
      out AResult: TRecorderDacResult): Boolean;
  end;

  { Provider writes interleaved engineering values into caller-owned memory. }
  IRecorderDacSampleProvider = interface
    ['{2927F824-230A-49E5-B887-7202E40D5839}']
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
  end;

  { Mirror receives the final clamped engineering block. }
  IRecorderDacMirror = interface
    ['{C13A04EE-3E96-4C07-805E-1C4CBB947C42}']
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function WriteBlock(ABuffer: PDouble; AFrameCount: Integer;
      out AResult: TRecorderDacResult): Boolean;
  end;

  IRecorderDacSourceIdentity = interface
    ['{B7B2D018-9B8B-4CB4-9364-FC65125D395A}']
    function SourceIdentity: QWord;
  end;

  { Submission-time metadata travels with the queued samples. Legacy mirrors
    can still consume WriteBlock, but cannot reconstruct clock gaps. }
  IRecorderDacTimedMirror = interface
    ['{82910C45-638D-4C79-B9A5-08BE249EF851}']
    function WriteTimedBlock(ABuffer: PDouble; const ATime: TRecorderBlockTime;
      out AResult: TRecorderDacResult): Boolean;
  end;

  { Optional live-only publication while calibration is pending. Provisional
    samples must never enter persistent recording. Before corrected replay,
    discard only the provisional display history, retaining recording cursors. }
  IRecorderDacProvisionalMirror = interface
    ['{33E75566-614B-41F3-BC2B-2C68030945D2}']
    function WriteProvisionalTimedBlock(ABuffer: PDouble;
      const ATime: TRecorderBlockTime; out AResult: TRecorderDacResult): Boolean;
    function BeginCalibratedReplay(out AResult: TRecorderDacResult): Boolean;
  end;

  IRecorderDacMirrorIdentity = interface
    ['{DBEAE561-057C-40E1-A13D-E9F174337F5E}']
    function MirrorIdentity: QWord;
  end;

  { Optional deferred mirror lifecycle. The publisher, never the GUI/audio
    callback, polls pending feedback and drains calibrated history. }
  IRecorderDacMirrorMaintenance = interface
    ['{504AC219-A497-4338-8E15-0B7238405ACD}']
    function Poll(out AResult: TRecorderDacResult): Boolean;
    function Pending: Boolean;
    procedure Cancel;
  end;

  { A backend owns one native driver session and never allocates in SubmitBlock. }
  IRecorderDacBackend = interface
    ['{0DEB0CB5-C907-48DD-8617-49AB0C3CF55C}']
    function BackendId: string;
    function Endpoint: string;
    function State: TRecorderDacState;
    function Connect(out AResult: TRecorderDacResult): Boolean;
    function Initialize(out AResult: TRecorderDacResult): Boolean;
    function ReadProperties(out AResult: TRecorderDacResult): Boolean;
    function SampleRateHz: Double;
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function Start(out AResult: TRecorderDacResult): Boolean;
    function SubmitBlock(ABuffer: PDouble; AFrameCount: Integer;
      out AResult: TRecorderDacResult): Boolean;
    function Stop(out AResult: TRecorderDacResult): Boolean;
    procedure Abort;
    function Disconnect(out AResult: TRecorderDacResult): Boolean;
  end;

  TRecorderDacBackendFactory = class
  public
    function BackendId: string; virtual; abstract;
    function DiscoverEndpoints(out AEndpoints: TRecorderDacEndpoints;
      out AResult: TRecorderDacResult): Boolean; virtual; abstract;
    function CreateBackend(const AEndpoint: string): IRecorderDacBackend;
      virtual; abstract;
  end;

implementation

end.
