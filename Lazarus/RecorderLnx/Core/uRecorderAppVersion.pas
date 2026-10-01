unit uRecorderAppVersion;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

const
  CRecorderLnxVersion = '0.1.148';
  CRecorderLnxCaption = 'RecorderLnx ' + CRecorderLnxVersion;
  CRecorderDefaultSoftwareArticle = 'БЛИЖ.409801.100.236-01';

function RecorderSoftwareArticle: string;

implementation

uses
  SysUtils, IniFiles, uRecorderMeraPaths;

function RecorderSoftwareArticle: string;
var
  lIni: TIniFile;
  lIniFileName: string;
begin
  Result := CRecorderDefaultSoftwareArticle;
  lIniFileName := RecorderAppConfigFileName;
  if FileExists(lIniFileName) then
  begin
    lIni := TIniFile.Create(lIniFileName);
    try
      if lIni.ValueExists('Application', 'SoftwareArticle') then
        Result := Trim(lIni.ReadString('Application', 'SoftwareArticle',
          CRecorderDefaultSoftwareArticle))
      else
        lIni.WriteString('Application', 'SoftwareArticle',
          CRecorderDefaultSoftwareArticle);
    finally
      lIni.Free;
    end;
  end;
  if Result = '' then
    Result := CRecorderDefaultSoftwareArticle;
end;

end.
