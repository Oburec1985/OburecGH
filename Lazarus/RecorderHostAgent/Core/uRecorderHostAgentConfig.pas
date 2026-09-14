unit uRecorderHostAgentConfig;

{$mode objfpc}{$H+}

interface

type
  TRecorderHostAgentConfig = class
  public
    ListenAddress: string;
    Port: Word;
    RecorderPath: string;
    AllowShutdown: Boolean;
    ApiToken: string;
    constructor Create;
    procedure Load(const AFileName: string);
    procedure Save(const AFileName: string);
  end;

implementation

uses IniFiles, SysUtils;

constructor TRecorderHostAgentConfig.Create;
begin
  ListenAddress := '0.0.0.0';
  Port := 8766;
  RecorderPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    {$ifdef windows}'RecorderLnx.exe'{$else}'RecorderLnx'{$endif};
  AllowShutdown := False;
  ApiToken := '';
end;

procedure TRecorderHostAgentConfig.Load(const AFileName: string);
var lIni: TIniFile;
begin
  if not FileExists(AFileName) then
  begin
    Save(AFileName);
    Exit;
  end;
  lIni := TIniFile.Create(AFileName);
  try
    ListenAddress := lIni.ReadString('agent', 'listen', ListenAddress);
    Port := lIni.ReadInteger('agent', 'port', Port);
    RecorderPath := lIni.ReadString('agent', 'recorder_path', RecorderPath);
    if Trim(RecorderPath) = '' then
      RecorderPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
        {$ifdef windows}'RecorderLnx.exe'{$else}'RecorderLnx'{$endif};
    AllowShutdown := lIni.ReadBool('agent', 'allow_shutdown', AllowShutdown);
    ApiToken := lIni.ReadString('agent', 'api_token', ApiToken);
  finally
    lIni.Free;
  end;
end;

procedure TRecorderHostAgentConfig.Save(const AFileName: string);
var lIni: TIniFile;
begin
  lIni := TIniFile.Create(AFileName);
  try
    lIni.WriteString('agent', 'listen', ListenAddress);
    lIni.WriteInteger('agent', 'port', Port);
    lIni.WriteString('agent', 'recorder_path', RecorderPath);
    lIni.WriteBool('agent', 'allow_shutdown', AllowShutdown);
    lIni.WriteString('agent', 'api_token', ApiToken);
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
end;

end.
