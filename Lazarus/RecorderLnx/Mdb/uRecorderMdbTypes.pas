unit uRecorderMdbTypes;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}
{$codepage UTF8}

interface

uses
  SysUtils;

type
  EMdbError = class(Exception);

  TMdbObjectInfo = record
    Id: string;
    Name: string;
    ObjectType: string;
    SerialNumber: string;
  end;
  TMdbObjectInfos = array of TMdbObjectInfo;

  TMdbTestInfo = record
    Id: string;
    ObjectId: string;
    Name: string;
    StartedAtUtc: Double;
    FinishedAtUtc: Double;
    MetadataJson: string;
  end;
  TMdbTestInfos = array of TMdbTestInfo;

  TMdbMeasurementInfo = record
    RegistrationId: string;
    ObjectId: string;
    TestId: string;
    StartedAtUtc: Double;
    FinishedAtUtc: Double;
    Status: string;
    Reason: string;
    ValueCount: Int64;
    EventCount: Int64;
    FileCount: Int64;
  end;
  TMdbMeasurementInfos = array of TMdbMeasurementInfo;

  { Immutable value copied to the SQL writer when a measurement starts. }
  TMdbMeasurementContext = record
    ObjectId: string;
    TestId: string;
    ObjectName: string;
    TestName: string;
    function IsValid: Boolean;
    procedure RequireValid;
  end;

implementation

function TMdbMeasurementContext.IsValid: Boolean;
begin
  Result := (Trim(ObjectId) <> '') and (Trim(TestId) <> '');
end;

procedure TMdbMeasurementContext.RequireValid;
begin
  if Trim(ObjectId) = '' then
    raise EMdbError.Create('Measurement object is not selected');
  if Trim(TestId) = '' then
    raise EMdbError.Create('Measurement test is not selected');
end;

end.
