program CloseGateGuiSmoke;
{$mode objfpc}{$H+}{$codepage UTF8}
uses Interfaces, Forms, Controls, Classes, SysUtils, IniFiles, Windows, DynLibs,
  uMainForm, uRecorderPluginRuntime, uRecorderFormModel, uRecorderTags,
  uRecorderVisualComponentApiV2;
type
  TProbeForm = class(TMainForm)
    constructor Create(AOwner:TComponent); override;
  end;
  TProbe = class
    Form:TProbeForm;
    Runtime:TRecorderPluginRuntime;
    Action:TCloseAction;
    CloseCount:Integer;
    CancelAfterFirst:Boolean;
    CallbackCloseRejected:Boolean;
    procedure OnClose(Sender:TObject; var AAction:TCloseAction);
    procedure OnLog(const AMessage:string);
  end;
  TProbeFn = function:LongInt; cdecl;
  TProbeCount = function:LongWord; cdecl;

constructor TProbeForm.Create(AOwner:TComponent);
begin inherited CreateNew(AOwner); end;
procedure TProbe.OnClose(Sender:TObject; var AAction:TCloseAction);
begin
  Inc(CloseCount);
  if CancelAfterFirst and (CloseCount>1) then AAction:=caNone
  else AAction:=Action;
end;
procedure TProbe.OnLog(const AMessage:string);
begin
  Form.Close;
  CallbackCloseRejected:=not Runtime.ShutdownStarted;
end;
procedure Check(ACondition:Boolean; const AText:string);
begin if not ACondition then raise Exception.Create(AText); end;
procedure CopyFileSimple(const AFrom,ATo:string);
var a,b:TFileStream;
begin
  a:=TFileStream.Create(AFrom,fmOpenRead or fmShareDenyNone);
  try b:=TFileStream.Create(ATo,fmCreate); try b.CopyFrom(a,0); finally b.Free; end;
  finally a.Free; end;
end;
procedure WaitForClose;
var deadline:QWord;
begin
  deadline:=GetTickCount64+5000;
  while not Application.Terminated and (GetTickCount64<deadline) do begin
    Application.ProcessMessages; Sleep(10);
  end;
  Check(Application.Terminated,'timer did not complete close');
end;
var form:TProbeForm; p:TProbe; reg:TRecorderComponentFactory;
  tags:TRecorderTagRegistry; runtime:TRecorderPluginRuntime;
  ini:TMemIniFile; config,dir,dll:string; h:HMODULE;
  count:TProbeCount; invoke:TProbeFn; mode,token:string; guid:TGUID;
  createdDir,createdDll,createdConfig:Boolean;
begin
  try
    mode:=ParamStr(1); Application.Initialize;
    Application.CreateForm(TProbeForm,form);
    form.SetBounds(80,80,500,300); form.Show;
    p:=TProbe.Create; reg:=TRecorderComponentFactory.Create;
    tags:=TRecorderTagRegistry.Create(nil);
    runtime:=TRecorderPluginRuntime.Create(reg,tags);
    try
      p.Form:=form; p.Runtime:=runtime;
      form.CloseTestSetRuntime(runtime); form.OnClose:=@p.OnClose;
      if mode='none' then p.Action:=caNone
      else if mode='hide' then p.Action:=caHide
      else if mode='minimize' then p.Action:=caMinimize
      else p.Action:=caFree;
      if (mode='commit') or (mode='busy') then begin
        dir:=IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'plugins';
        createdDir:=not DirectoryExists(dir);
        Check(ForceDirectories(dir),'cannot create fixture plugin directory');
        Check(CreateGUID(guid)=0,'cannot create fixture GUID');
        token:=GUIDToString(guid);
        token:=StringReplace(token,'{','',[rfReplaceAll]);
        token:=StringReplace(token,'}','',[rfReplaceAll]);
        dll:=IncludeTrailingPathDelimiter(dir)+'close-gui-'+token+'.dll';
        Check(not FileExists(dll),'fixture DLL path already exists');
        createdDll:=True;
        CopyFileSimple(ParamStr(2),dll);
        config:=IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'close-gui-'+token+'.ini';
        Check(not FileExists(config),'fixture config path already exists');
        createdConfig:=True;
        ini:=TMemIniFile.Create(config); try
          ini.WriteInteger('Plugins','Count',1);
          ini.WriteString('Plugin0','FileName',ExtractFileName(dll)); ini.UpdateFile;
        finally ini.Free; end;
        if mode='commit' then SetEnvironmentVariable('RECORDER_CLOSE_PROBE','failonce');
        runtime.LoadConfigured(config);
        Check(runtime.LoadedCount=1,'fixture not loaded');
        h:=GetModuleHandle(PChar(ExtractFileName(dll))); Check(h<>0,'fixture module missing');
        if mode='commit' then begin
          Pointer(count):=GetProcAddress(h,'ProbeCloseCount');
          Check(Assigned(count),'close counter missing');
          p.CancelAfterFirst:=True;
          form.Close;
          Check(form.CloseTestCommitted and runtime.ShutdownStarted,'close not committed');
          Check(not form.Enabled and not Application.Terminated,'first failed Close destroyed graph');
          Check(Pos('ожидание остановки плагинов', form.Caption)>0,
            'close progress title is missing');
          Check((count()=1) and (p.CloseCount=1),'first Close count incorrect');
          WaitForClose;
          Check((count()=2) and (p.CloseCount=1),'committed retry repeated OnClose or skipped plugin Close');
        end else begin
          Pointer(invoke):=GetProcAddress(h,'ProbeLogService');
          Check(Assigned(invoke),'log callback missing');
          runtime.OnLogMessage:=@p.OnLog;
          Check(invoke()=REC_VISUAL_OK,'log callback failed');
          Check(p.CallbackCloseRejected and not runtime.ShutdownStarted,'busy callback committed close');
          WaitForClose;
          Check(runtime.ShutdownStarted,'retry did not commit');
        end;
      end else begin
        form.Close;
        if mode='free' then
          Check(runtime.ShutdownStarted and Application.Terminated,'normal main form close not committed')
        else Check(not runtime.ShutdownStarted and not Application.Terminated,
          'cancelled/hidden/minimized close modified runtime');
      end;
      WriteLn('RESULT close gate GUI ',mode,' passed');
      form.CloseTestSetRuntime(nil);
    finally
      SetEnvironmentVariable('RECORDER_CLOSE_PROBE',nil);
      runtime.Free; tags.Free; reg.Free; p.Free;
      if createdConfig then SysUtils.DeleteFile(config);
      if createdDll then SysUtils.DeleteFile(dll);
      if createdDir then SysUtils.RemoveDir(dir);
    end;
  except on E:Exception do begin WriteLn('FAIL ',E.ClassName,': ',E.Message); Halt(1); end; end;
end.
