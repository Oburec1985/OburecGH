unit uRecorderDriverContractsV2;

{
  Additive contracts for the next hardware-driver composition layer.
  This unit has no registration side effects and is not connected to the
  current RecorderLnx runtime factory.
}

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}
{$codepage UTF8}

interface

type
  TRcOperationCode = (
    rocOk,
    rocInvalidArgument,
    rocInvalidState,
    rocUnsupported,
    rocTransport,
    rocProtocol,
    rocTimeout,
    rocInternal
  );

  TRcOperationResult = record
    Code: TRcOperationCode;
    Stage: string;
    MessageText: string;
    class function Success: TRcOperationResult; static;
    class function Failure(ACode: TRcOperationCode;
      const AStage, AMessage: string): TRcOperationResult; static;
    function IsSuccess: Boolean;
  end;

  TRecorderPropertyKind = (rpkString, rpkInteger, rpkFloat, rpkBoolean,
    rpkEnum);
  TRecorderPropertyScope = (rpsDevice, rpsChannel);
  TRecorderPropertyAccess = (rpaReadOnly, rpaReadWrite);

  TRecorderPropertyDescriptor = record
    Name: string;
    ValueKind: TRecorderPropertyKind;
    Scope: TRecorderPropertyScope;
    Access: TRecorderPropertyAccess;
    DefaultValue: string;
    UnitName: string;
    MinimumValue: string;
    MaximumValue: string;
    { Pipe-delimited canonical values, used only by rpkEnum. }
    AllowedValues: string;
    SinceVersion: string;
  end;

  TRecorderPropertyDescriptorArray = array of TRecorderPropertyDescriptor;

  { Optional capability. Drivers which do not expose textual configuration do
    not need to implement it. SetProperties is an atomic operation. }
  IRecorderTransactionalProperties = interface
    ['{EE9FF035-222A-4C3A-BDD1-21136734690F}']
    function GetPropertyDescriptors: TRecorderPropertyDescriptorArray;
    function GetProperties(const ARequest: string; out AResponse: string):
      TRcOperationResult;
    { Calculates a complete candidate snapshot without mutation or device I/O. }
    function CalcProperties(const AProperties: string; out AResponse: string):
      TRcOperationResult;
    function SetProperties(const AProperties: string): TRcOperationResult;
  end;

implementation

class function TRcOperationResult.Success: TRcOperationResult;
begin
  Result.Code := rocOk;
  Result.Stage := '';
  Result.MessageText := '';
end;

class function TRcOperationResult.Failure(ACode: TRcOperationCode;
  const AStage, AMessage: string): TRcOperationResult;
begin
  Result.Code := ACode;
  Result.Stage := AStage;
  Result.MessageText := AMessage;
end;

function TRcOperationResult.IsSuccess: Boolean;
begin
  Result := Code = rocOk;
end;

end.
