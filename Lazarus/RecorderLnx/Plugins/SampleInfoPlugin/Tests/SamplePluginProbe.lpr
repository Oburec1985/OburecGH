program SamplePluginProbe;
{$mode objfpc}{$H+}
{ Production plugin export/state probe. Only flat SDK callbacks and opaque
  buffers cross the DLL boundary; no RecorderLnx classes or legacy factory API. }
uses SysUtils,DynLibs,fpjson,jsonparser,uRecorderPluginApi,
  uRecorderVisualComponentApiV2, uRecorderPluginComponentManager,
  uRecorderPluginClass, uRecorderPluginFramework;
procedure Check(AValue:Boolean; const AMessage:string);
begin if not AValue then raise Exception.Create(AMessage); end;

type
  TTestFactory = class(cRecBasicFactory)
    Events: array[0..3] of PtrUInt;
    EventCount, InitCount, CloseCount, CloseMode: Integer;
    function GetDescriptor(ADescriptor:PRecorderVisualComponentDescriptorV2;
      ACapacity:SizeUInt):LongInt; override;
    function Notify(AKind:LongWord; AData:Pointer):LongInt; override;
    function doRecorderInit:LongInt; override;
    function doClose:LongInt; override;
  end;
  TNotifyCounts = record
    StartCount, UpdateCount, StopCount:Integer;
    StartModes:LongWord;
    InvalidPayload, Fail:Boolean;
  end;

function TTestFactory.GetDescriptor(ADescriptor:PRecorderVisualComponentDescriptorV2;
  ACapacity:SizeUInt):LongInt;
begin Result:=REC_VISUAL_NOT_HANDLED; end;

function TTestFactory.Notify(AKind:LongWord; AData:Pointer):LongInt;
begin
  if AKind in [PN_RCSTART,PN_RCSTOP] then begin
    if EventCount<Length(Events) then Events[EventCount]:=PtrUInt(AData);
    Inc(EventCount);
  end;
  Result:=inherited Notify(AKind,AData);
end;

function TTestFactory.doRecorderInit:LongInt;
begin Inc(InitCount); Result:=REC_VISUAL_OK; end;

function TTestFactory.doClose:LongInt;
begin
  Inc(CloseCount);
  if CloseMode=1 then Exit(REC_VISUAL_ERROR);
  if CloseMode=2 then raise Exception.Create('fixture close failure');
  Result:=REC_VISUAL_OK;
end;

var gTestManager:cCompMng; gTestA,gTestB:TTestFactory;
procedure RegisterTestFactories(AManager:cCompMng);
begin
  gTestManager:=AManager;
  gTestA:=TTestFactory.Create; AManager.Add(gTestA);
  gTestB:=TTestFactory.Create; AManager.Add(gTestB);
end;

function CountDispatch(AInstance:Pointer; AKind:LongWord; AInput:Pointer;
  AInputSize:SizeUInt; AOutput:Pointer; AOutputCapacity:SizeUInt;
  out AOutputSize:SizeUInt):LongInt; cdecl;
var lCounts:^TNotifyCounts;
begin
  lCounts:=AInstance; AOutputSize:=0;
  case AKind of
    REC_VISUAL_DISPATCH_START: begin
      Inc(lCounts^.StartCount);
      if (AInput=nil) or (AInputSize<>SizeOf(TRecorderVisualRunContextV2)) then
        lCounts^.InvalidPayload:=True
      else if (PRecorderVisualRunContextV2(AInput)^.Header.Size<>AInputSize) or
        (PRecorderVisualRunContextV2(AInput)^.Header.AbiMajor<>REC_VISUAL_ABI_V2_MAJOR) or
        (PRecorderVisualRunContextV2(AInput)^.Recording>1) then
        lCounts^.InvalidPayload:=True
      else lCounts^.StartModes:=(lCounts^.StartModes shl 4) or
        (PRecorderVisualRunContextV2(AInput)^.Recording+1);
    end;
    REC_VISUAL_DISPATCH_DATA_UPDATED: begin
      Inc(lCounts^.UpdateCount);
      if (AInput<>nil) or (AInputSize<>0) then lCounts^.InvalidPayload:=True;
    end;
    REC_VISUAL_DISPATCH_STOP: begin
      Inc(lCounts^.StopCount);
      if (AInput<>nil) or (AInputSize<>0) then lCounts^.InvalidPayload:=True;
    end;
  end;
  if lCounts^.Fail then Result:=REC_VISUAL_ERROR else Result:=REC_VISUAL_OK;
end;

procedure CheckFactoryNotifications;
var m:cCompMng; a,b:TTestFactory; desc:TRecorderVisualComponentDescriptorV2;
  counts:array[0..2] of TNotifyCounts; p:TExtRecorderPack;
  api:TRecorderPluginHostApi; failed:Boolean;
begin
  FillChar(counts,SizeOf(counts),0); counts[0].Fail:=True;
  desc:=Default(TRecorderVisualComponentDescriptorV2); desc.ViewDispatch:=@CountDispatch;
  api:=Default(TRecorderPluginHostApi); api.Size:=SizeOf(api);
  p:=TExtRecorderPack.Create(@RegisterTestFactories);
  try
    Check(p.Initialize(@api),'SDK plugin initialization failed');
    m:=gTestManager; a:=gTestA; b:=gTestB;
    a.SetDescriptor(desc); b.SetDescriptor(desc);
    a.RegisterInstance(@counts[0]); a.RegisterInstance(@counts[1]);
    b.RegisterInstance(@counts[2]);
    Check(p.ProcessNotify(PN_RCINITIALIZED,nil)=REC_VISUAL_OK,'initialization not handled');
    Check((a.InitCount=1) and (b.InitCount=1),'initialization did not reach both factories');
    Check(p.ProcessNotify(PN_RCSTART,nil)=REC_VISUAL_ERROR,'factory error not returned');
    Check(p.ProcessNotify(PN_RCSTART,Pointer(PtrUInt(1)))=REC_VISUAL_ERROR,'record start error not returned');
    Check(p.Notify(PN_UPDATEDATA,nil)=REC_VISUAL_ERROR,'update error not returned');
    Check(p.Notify(PN_RCSTOP,nil)=REC_VISUAL_ERROR,'stop error not returned');
    Check((a.EventCount=3) and (b.EventCount=3) and
      (a.Events[0]=0) and (a.Events[1]=1) and (a.Events[2]=0) and
      (b.Events[0]=0) and (b.Events[1]=1) and (b.Events[2]=0),
      'SDK ProcessNotify did not forward start/stop data in order');
    Check(not counts[0].InvalidPayload and not counts[1].InvalidPayload and
      not counts[2].InvalidPayload and (counts[0].StartModes=$12) and
      (counts[1].StartModes=$12) and (counts[2].StartModes=$12),
      'instance start context did not preserve preview then record');
    Check((counts[0].StartCount=2) and (counts[0].UpdateCount=1) and (counts[0].StopCount=1)
      and (counts[1].StartCount=2) and (counts[1].UpdateCount=1) and (counts[1].StopCount=1)
      and (counts[2].StartCount=2) and (counts[2].UpdateCount=1) and (counts[2].StopCount=1),
      'events not delivered exactly once to all instances');
    a.UnregisterInstance(@counts[0]); a.UnregisterInstance(@counts[1]);
    b.UnregisterInstance(@counts[2]);
    Check(not m.HasInstances,'unregistered instances remain');
    a.CloseMode:=1; b.CloseMode:=2; failed:=False;
    try p.Close; except on E:Exception do failed:=True; end;
    Check(failed and (a.CloseCount=1) and (b.CloseCount=1),
      'close failure did not stop all factories');
    a.CloseMode:=0; b.CloseMode:=0;
    p.Close;
    Check((a.CloseCount=2) and (b.CloseCount=2),'close retry failed');
    p.Close;
    Check((a.CloseCount=2) and (b.CloseCount=2),'successful close not idempotent');
  finally p.Free; end;
end;

procedure CheckPluginCloseAbi;
var p:Pointer; api:TRecorderPluginHostApi;
begin
  ConfigureFramework(@RegisterTestFactories);
  p:=CreatePluginClass;
  Check(p<>nil,'SDK ABI plugin creation failed');
  api:=Default(TRecorderPluginHostApi); api.Size:=SizeOf(api);
  Check(PluginCreate(p,@api),'SDK ABI plugin initialization failed');
  gTestA.CloseMode:=1;
  Check(not PluginClose(p),'SDK ABI close failure was hidden');
  Check((gTestA.CloseCount=1) and (gTestB.CloseCount=1),
    'SDK ABI close skipped a factory');
  gTestA.CloseMode:=0;
  Check(PluginClose(p),'SDK ABI close retry failed');
  Check(PluginClose(p),'SDK ABI repeated close failed');
  Check((gTestA.CloseCount=2) and (gTestB.CloseCount=2),
    'SDK ABI successful close was repeated');
  Check(DestroyPluginClass(p)=0,'SDK ABI plugin destruction failed');
end;
function EnumTags(AContext:Pointer; AIndex:LongWord;
  AInfo:PRecorderVisualTagInfoV2):LongInt; cdecl;
begin Result:=REC_VISUAL_END_OF_ENUMERATION; end;
function EnumUnits(AContext:Pointer; AIndex:LongWord;
  AInfo:PRecorderVisualUnitInfoV2):LongInt; cdecl;
begin Result:=REC_VISUAL_END_OF_ENUMERATION; end;
function CopyHistory(AContext:Pointer; ATagId:QWord; AWindowSeconds:Double;
  ATimes,AValues:PDouble; ACapacity:LongWord; out ACount:LongWord;
  out ARevision:QWord; out AStart,ALatest:Double):LongInt; cdecl;
begin
  ACount:=0; ARevision:=0; AStart:=0; ALatest:=0;
  Result:=REC_VISUAL_NOT_FOUND;
end;
function Snapshot(const ADescriptor:TRecorderVisualComponentDescriptorV2;
  AInstance:Pointer):UTF8String;
var lRequired,lWritten:SizeUInt; lCanary:Byte;
begin
  Check(ADescriptor.SaveState(AInstance,nil,0,lRequired)=REC_VISUAL_BUFFER_TOO_SMALL,
    'state size query failed');
  Check((lRequired>0) and (lRequired<=REC_VISUAL_MAX_STATE_BYTES),'invalid state size');
  lCanary:=$A5;
  Check((ADescriptor.SaveState(AInstance,@lCanary,0,lWritten)=REC_VISUAL_BUFFER_TOO_SMALL)
    and (lCanary=$A5) and (lWritten=lRequired),'short state buffer was overwritten');
  SetLength(Result,lRequired);
  Check((ADescriptor.SaveState(AInstance,@Result[1],Length(Result),lWritten)=REC_VISUAL_OK)
    and (lWritten=lRequired),'state save failed');
end;
procedure RunProbe(const APath:string);
var lLibrary:TLibHandle; lGetInfo:TRecorderPluginGetInfo;
  lGetType:TRecorderPluginGetType; lGetDescriptor:TRecorderVisualGetDescriptorV2;
  lCreateClass:TRecorderPluginCreateClass; lDestroyClass:TRecorderPluginDestroyClass;
  lCreate:TRecorderPluginCreate; lNotify:TRecorderPluginNotify; lClose:TRecorderPluginClose;
  lPlugin:Pointer; lApi:TRecorderPluginHostApi;
  lInfo:TRecorderPluginInfo; lDescriptor:TRecorderVisualComponentDescriptorV2;
  lServices:TRecorderVisualHostServicesV2; lFirst,lSecond:Pointer;
  lInitial,lChanged,lBad:UTF8String; lJson:TJSONData;
  lStatus:LongInt; lOutputSize:SizeUInt;
begin
  lLibrary:=LoadLibrary(APath);
  Check(lLibrary<>NilHandle,'cannot load '+APath);
  lFirst:=nil; lSecond:=nil; lPlugin:=nil;
  try
    Pointer(lCreateClass):=GetProcedureAddress(lLibrary,'CreatePluginClass');
    Pointer(lDestroyClass):=GetProcedureAddress(lLibrary,'DestroyPluginClass');
    Pointer(lCreate):=GetProcedureAddress(lLibrary,'PluginCreate');
    Pointer(lNotify):=GetProcedureAddress(lLibrary,'PluginNotify');
    Pointer(lClose):=GetProcedureAddress(lLibrary,'PluginClose');
    Check(Assigned(lCreateClass) and Assigned(lDestroyClass) and Assigned(lCreate)
      and Assigned(lNotify) and Assigned(lClose),'plugin lifecycle exports missing');
    lPlugin:=lCreateClass();
    Check(lPlugin<>nil,'plugin class creation failed');
    Check(lCreateClass()=nil,'duplicate plugin class accepted');
    lApi:=Default(TRecorderPluginHostApi); lApi.Size:=SizeOf(lApi);
    Check(lCreate(lPlugin,@lApi),'plugin initialization failed');
    Pointer(lGetType):=GetProcedureAddress(lLibrary,'GetPluginType');
    Pointer(lGetInfo):=GetProcedureAddress(lLibrary,'GetPluginInfo');
    Pointer(lGetDescriptor):=GetProcedureAddress(lLibrary,'RecorderVisualGetDescriptorV2');
    Check(Assigned(lGetType) and Assigned(lGetInfo) and Assigned(lGetDescriptor),
      'metadata/V2 discovery export missing');
    Check(GetProcedureAddress(lLibrary,'GetPluginDescription')<>nil,'description export missing');
    Check(lGetType()=PLUGIN_CLASS,'wrong metadata type');
    lInfo:=Default(TRecorderPluginInfo); lGetInfo(lInfo);
    Check((SizeOf(lInfo)=512) and (lInfo.Version>=1),'metadata ABI/version mismatch');
    Check((Byte(lInfo.Name[0])=$D0) and (Byte(lInfo.Name[1])=$9E),'metadata not UTF8');
    lDescriptor:=Default(TRecorderVisualComponentDescriptorV2);
    Check(lGetDescriptor(0,@lDescriptor,SizeOf(lDescriptor))=REC_VISUAL_OK,'V2 descriptor missing');
    Check((lDescriptor.Header.AbiMajor=REC_VISUAL_ABI_V2_MAJOR) and
      (StrPas(@lDescriptor.TypeId[0])='sample.oscillogram'),'wrong descriptor');
    Check(Assigned(lDescriptor.CreateInstance) and Assigned(lDescriptor.DestroyInstance)
      and Assigned(lDescriptor.SaveState) and Assigned(lDescriptor.LoadState)
      and Assigned(lDescriptor.ViewDispatch),'missing state/lifecycle callbacks');
    lServices:=Default(TRecorderVisualHostServicesV2);
    lServices.Header.Size:=SizeOf(lServices); lServices.Header.AbiMajor:=REC_VISUAL_ABI_V2_MAJOR;
    lServices.Header.AbiMinor:=REC_VISUAL_ABI_V2_MINOR;
    lServices.EnumerateTags:=@EnumTags; lServices.CopyLatestHistory:=@CopyHistory;
    lServices.EnumerateUnits:=@EnumUnits;
    Check(lDescriptor.CreateInstance(@lServices,nil,0,lFirst)=REC_VISUAL_OK,'first instance failed');
    Check(lDescriptor.CreateInstance(@lServices,nil,0,lSecond)=REC_VISUAL_OK,'second instance failed');
    Check(lDestroyClass(lPlugin)<>0,'destroy accepted with live instances');
    Check(lNotify(lPlugin,PN_RCSTART,nil) and lNotify(lPlugin,PN_UPDATEDATA,nil)
      and lNotify(lPlugin,PN_RCSTOP,nil),'manager notification failed');
    lInitial:=Snapshot(lDescriptor,lFirst);
    Check(Snapshot(lDescriptor,lSecond)=lInitial,'new instances differ');
    lJson:=GetJSON(lInitial);
    try TJSONObject(lJson).Strings['TagName']:='Private instance binding'; lChanged:=lJson.AsJSON;
    finally lJson.Free; end;
    Check(lDescriptor.LoadState(lFirst,@lChanged[1],Length(lChanged))=REC_VISUAL_OK,'state load failed');
    Check((Snapshot(lDescriptor,lFirst)=lChanged) and
      (Snapshot(lDescriptor,lSecond)=lInitial),'instance state is shared/not persisted');
    lBad:='{"Version":999}';
    Check(lDescriptor.LoadState(lFirst,@lBad[1],Length(lBad))=REC_VISUAL_ERROR,'invalid state accepted');
    Check(Snapshot(lDescriptor,lFirst)=lChanged,'invalid state changed prior state');
    for lStatus:=REC_VISUAL_DISPATCH_START to REC_VISUAL_DISPATCH_DATA_UPDATED do
      Check(lDescriptor.ViewDispatch(lFirst,lStatus,nil,0,nil,0,lOutputSize)=REC_VISUAL_OK,
        'standard lifecycle dispatch failed');
    lDescriptor.DestroyInstance(lFirst); lFirst:=nil;
    Check(Snapshot(lDescriptor,lSecond)=lInitial,'destroying peer changed surviving instance');
    lDescriptor.DestroyInstance(lSecond); lSecond:=nil;
  finally
    if lFirst<>nil then lDescriptor.DestroyInstance(lFirst);
    if lSecond<>nil then lDescriptor.DestroyInstance(lSecond);
    if lPlugin<>nil then begin lClose(lPlugin); lDestroyClass(lPlugin); end;
    UnloadLibrary(lLibrary);
  end;
end;
begin
  try
    Check(ParamCount=1,'usage: SamplePluginProbe plugin-library');
    CheckFactoryNotifications;
    CheckPluginCloseAbi;
    RunProbe(ParamStr(1));
    WriteLn('RESULT sample-plugin manager descriptor/state/lifecycle passed');
  except on E:Exception do
    begin WriteLn('RESULT sample-plugin failed: ',E.Message); Halt(1); end; end;
end.
