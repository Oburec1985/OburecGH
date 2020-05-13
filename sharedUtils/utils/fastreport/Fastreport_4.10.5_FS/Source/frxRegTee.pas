
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Registration unit             }
{                                          }
{         Copyright (c) 1998-2008          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxRegTee;

{$I frx.inc}

interface


procedure Register;

implementation

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
{$IFNDEF Delphi6}
  DsgnIntf,
{$ELSE}
  DesignIntf, DesignEditors,
{$ENDIF}
  frxChart;


procedure Register;
begin
  RegisterComponents('FastReport 4.0',
    [TfrxChartObject]);
end;

end.


