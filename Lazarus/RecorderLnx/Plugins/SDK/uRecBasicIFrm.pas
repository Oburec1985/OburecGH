unit uRecBasicIFrm;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Общий маршрут сохранения настроек экземпляра визуального компонента.
  Имена методов соответствуют фреймворку оригинального Recorder. В RLNX
  хост передаёт непрозрачный буфер байтов: текущий осциллограф хранит JSON
  в UTF-8; это не интерфейс файлового пути и секции INI оригинала.
  Формат и проверку содержимого определяет конкретный компонент. }
interface

uses uRecorderVisualComponentApiV2;

type
  cRecBasicIFrm = class
  protected
    function SaveSettings(out AData: UTF8String): LongInt; virtual; abstract;
    function LoadSettings(const AData: UTF8String): LongInt; virtual; abstract;
  public
    function doWriteSettings(ABuffer: Pointer; ACapacity: SizeUInt;
      out ARequiredSize: SizeUInt): LongInt;
    function doReadSettings(AData: Pointer; ASize: SizeUInt): LongInt;
  end;

implementation

function cRecBasicIFrm.doWriteSettings(ABuffer: Pointer; ACapacity: SizeUInt;
  out ARequiredSize: SizeUInt): LongInt;
var
  lData: UTF8String;
begin
  ARequiredSize := 0;
  try
    Result := SaveSettings(lData);
    if Result <> REC_VISUAL_OK then Exit;
    ARequiredSize := Length(lData);
    if (ABuffer = nil) or (ACapacity < ARequiredSize) then
      Exit(REC_VISUAL_BUFFER_TOO_SMALL);
    if ARequiredSize > 0 then Move(lData[1], ABuffer^, ARequiredSize);
  except
    Result := REC_VISUAL_ERROR;
  end;
end;

function cRecBasicIFrm.doReadSettings(AData: Pointer; ASize: SizeUInt): LongInt;
var
  lData: UTF8String;
begin
  if (AData = nil) or (ASize > REC_VISUAL_MAX_STATE_BYTES) then
    Exit(REC_VISUAL_ERROR);
  try
    SetString(lData, PAnsiChar(AData), ASize);
    Result := LoadSettings(lData);
  except
    Result := REC_VISUAL_ERROR;
  end;
end;

end.
