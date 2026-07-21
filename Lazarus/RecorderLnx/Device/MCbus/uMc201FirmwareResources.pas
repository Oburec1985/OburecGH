unit uMc201FirmwareResources;

{
  Загрузка бинарников устройств из ресурсов exe.

  Все firmware/BIOS/calibration-файлы, которые нужны для настройки железа,
  должны сначала добавляться как RCDATA-ресурсы проекта. Файловый путь остается
  только fallback для отладки старых сборок и сравнения с оригинальным Recorder.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

const
  CMc201BiosResourceName = 'MC201A_BIO';
  CMc201BiosResourceType = 'MC201BIO';

function LoadDeviceBinaryResource(const AResourceName, AFallbackPath: string;
  out ABytes: TBytes; out ASource, AErrorMessage: string): Boolean;

implementation

uses
  uRecorderResourcePaths;

const
  CMc201BiosLogicalPath = 'devices/mc201/mc_201a.bio';
  CMc201BiosDevelopmentPath =
    'Device/MCbus/resources/devices/mc201/mc_201a.bio';

function LoadBytesFromStream(AStream: TStream; out ABytes: TBytes): Boolean;
begin
  SetLength(ABytes, AStream.Size);
  if Length(ABytes) > 0 then
    AStream.ReadBuffer(ABytes[0], Length(ABytes));
  Result := True;
end;

function LoadDeviceBinaryResource(const AResourceName, AFallbackPath: string;
  out ABytes: TBytes; out ASource, AErrorMessage: string): Boolean;
var
  lResourceError: string;
  lFallbackPath: string;
  lSearchedPaths: string;
  lResourceStream: TResourceStream;
  lFileStream: TFileStream;
begin
  Result := False;
  SetLength(ABytes, 0);
  ASource := '';
  AErrorMessage := '';
  lResourceError := '';
  lFallbackPath := '';

  try
    lResourceStream := TResourceStream.Create(HInstance, AResourceName,
      PChar(CMc201BiosResourceType));
    try
      Result := LoadBytesFromStream(lResourceStream, ABytes);
      ASource := 'resource:' + AResourceName;
      Exit;
    finally
      lResourceStream.Free;
    end;
  except
    on E: Exception do
      lResourceError := E.Message;
  end;

  if not RecorderResolveResourceFile(CMc201BiosLogicalPath, AFallbackPath,
    CMc201BiosDevelopmentPath, lFallbackPath, lSearchedPaths) then
  begin
    AErrorMessage := Format('Ресурс %s не найден (%s). Проверены пути:%s%s',
      [AResourceName, lResourceError, LineEnding, TrimRight(lSearchedPaths)]);
    Exit;
  end;

  try
    lFileStream := TFileStream.Create(lFallbackPath, fmOpenRead or fmShareDenyNone);
    try
      Result := LoadBytesFromStream(lFileStream, ABytes);
      ASource := 'file:' + lFallbackPath;
    finally
      lFileStream.Free;
    end;
  except
    on E: Exception do
    begin
      AErrorMessage := Format('Не удалось прочитать fallback-файл %s: %s',
        [lFallbackPath, E.Message]);
      Result := False;
    end;
  end;
end;

end.
