unit uRecorderDacContracts;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, uRecorderDacTypes;

type
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

  IRecorderDacMirrorIdentity = interface
    ['{DBEAE561-057C-40E1-A13D-E9F174337F5E}']
    function MirrorIdentity: QWord;
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
    function CreateBackend(const AEndpoint: string): IRecorderDacBackend;
      virtual; abstract;
  end;

implementation

end.
