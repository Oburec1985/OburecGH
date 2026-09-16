unit uCoordinatorVersion;

{$mode objfpc}{$H+}

interface

const
  COORDINATOR_APP_NAME = 'RCPanel';
  COORDINATOR_VERSION = '0.1.22';

function CoordinatorWindowCaption: string;

implementation

function CoordinatorWindowCaption: string;
begin
  Result := COORDINATOR_APP_NAME + ' ' + COORDINATOR_VERSION;
end;

end.
