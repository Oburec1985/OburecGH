program AliasDiscoverySmoke;
{$mode objfpc}{$H+}
uses Interfaces,Forms,Classes,SysUtils,IniFiles,FileUtil,Windows,
  uRecorderFormModel,uRecorderPluginRuntime;
procedure Check(AValue:Boolean; const AMessage:string);
begin if not AValue then raise Exception.Create(AMessage); end;
procedure RunMode(const AMode,AConfig:string; ASuccess:Boolean);
var lFactories:TRecorderComponentFactory; lRuntime:TRecorderPluginRuntime;
  lFactory:TRecorderComponentFactoryBase; lComponent:TRecorderVisualComponent;
  lLibrary:string;
begin
  Check(SetEnvironmentVariable('RECORDER_ALIAS_PROBE',PChar(AMode)),'cannot set fixture mode');
  lFactories:=TRecorderComponentFactory.Create;
  lRuntime:=TRecorderPluginRuntime.Create(lFactories,nil);
  try
    lFactories.RegisterFactory(TRecorderComponentFactoryBase.Create('test.hostcollision',
      'Host collision',TRecorderStaticTextComponent,20,20,False));
    lRuntime.LoadConfigured(AConfig);
    Check((lRuntime.LoadedCount=1)=ASuccess,'unexpected discovery result: '+AMode);
    if ASuccess then
    begin
      lFactory:=lFactories.FindFactory('test.stateful-visual');
      Check(lFactory<>nil,'canonical factory missing: '+AMode);
      if AMode='success' then
      begin
        Check(lFactories.FindFactory('test.alias')=lFactory,'alias owns a different factory');
        lComponent:=lFactories.CreateComponent('test.alias');
        try
          Check(lComponent.Factory=lFactory,'alias component not owned by canonical factory');
          Check(lFactory.ChildCount=1,'alias duplicated factory lifecycle ownership');
          Check(lFactory.SaveOpaqueComponentState(lComponent)=rosSuccess,'alias native save');
        finally lComponent.Free; end;
        Check(lFactory.ChildCount=0,'alias component destruction leaked ownership');
      end
      else Check(lFactories.FindFactory('test.alias')=nil,'old prefix invoked alias callback');
    end
    else
    begin
      Check(lFactories.FindFactory('test.stateful-visual')=nil,'failed batch published first factory');
      Check(lFactories.FindFactory('test.empty-state-visual')=nil,'failed batch published second factory');
      Check(lFactories.FindFactory('test.alias')=nil,'failed batch published alias');
      Check(lFactories.FindFactory('test.alias.0')=nil,'endless batch published aliases');
    end;
    lLibrary:=ExtractFileName(ParamStr(1));
    FreeAndNil(lRuntime);
    Check(lFactories.FindFactory('test.stateful-visual')=nil,'unload left canonical factory');
    Check(lFactories.FindFactory('test.alias')=nil,'unload left borrowed alias');
    Check(GetModuleHandle(PChar(lLibrary))=0,'alias lifecycle pinned/leaked DLL');
    Check(lFactories.FindFactory('test.hostcollision')<>nil,'failed batch removed host factory');
    WriteLn('RESULT AliasDiscoverySmoke mode ',AMode,' passed');
  finally lRuntime.Free; lFactories.Free; end;
end;
const RejectedModes:array[0..8] of string =
  ('host','future','self','duplicate','crossalias','error','nonul','endless','empty');
var lDirectory,lConfig:string; lIni:TMemIniFile; lMode:string;
begin
  try
    Check(ParamCount=1,'usage: AliasDiscoverySmoke fixture.dll');
    Application.Initialize; Application.ShowMainForm:=False;
    lDirectory:=ExtractFilePath(ParamStr(0))+'plugins';
    Check(ForceDirectories(lDirectory),'cannot prepare plugin directory');
    Check(FileUtil.CopyFile(ParamStr(1),lDirectory+PathDelim+ExtractFileName(ParamStr(1))),'cannot stage DLL');
    lConfig:=ExtractFilePath(ParamStr(0))+'alias-smoke.ini';
    lIni:=TMemIniFile.Create(lConfig);
    try
      lIni.WriteInteger('Plugins','Count',1);
      lIni.WriteString('Plugin0','FileName',ExtractFileName(ParamStr(1)));
      lIni.UpdateFile;
    finally lIni.Free; end;
    try
      RunMode('success',lConfig,True);
      RunMode('oldprefix',lConfig,True);
      for lMode in RejectedModes do
        RunMode(lMode,lConfig,False);
    finally
      SetEnvironmentVariable('RECORDER_ALIAS_PROBE',nil);
      SysUtils.DeleteFile(lConfig);
    end;
    WriteLn('RESULT AliasDiscoverySmoke passed');
  except on E:Exception do begin WriteLn('RESULT AliasDiscoverySmoke failed: ',E.Message); Halt(1); end; end;
end.
