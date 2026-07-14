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
  lResourceStream: TResourceStream;
  lFileStream: TFileStream;
begin
  Result := False;
  SetLength(ABytes, 0);
  ASource := '';
  AErrorMessage := '';
  lResourceError := '';

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

  if AFallbackPath = '' then
  begin
    AErrorMessage := Format('Ресурс %s не найден: %s',
      [AResourceName, lResourceError]);
    Exit;
  end;
  if not FileExists(AFallbackPath) then
  begin
    AErrorMessage := Format('Ресурс %s не найден (%s), fallback-файл не найден: %s',
      [AResourceName, lResourceError, AFallbackPath]);
    Exit;
  end;

  try
    lFileStream := TFileStream.Create(AFallbackPath, fmOpenRead or fmShareDenyNone);
    try
      Result := LoadBytesFromStream(lFileStream, ABytes);
      ASource := 'file:' + AFallbackPath;
    finally
      lFileStream.Free;
    end;
  except
    on E: Exception do
    begin
      AErrorMessage := Format('Не удалось прочитать fallback-файл %s: %s',
        [AFallbackPath, E.Message]);
      Result := False;
    end;
  end;
end;

end.
