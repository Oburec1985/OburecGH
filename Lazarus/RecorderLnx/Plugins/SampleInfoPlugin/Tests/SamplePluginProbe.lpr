program SamplePluginProbe;
{$mode objfpc}{$H+}
{ Production plugin export/state probe. Only flat SDK callbacks and opaque
  buffers cross the DLL boundary; no RecorderLnx classes or legacy factory API. }
uses SysUtils,DynLibs,fpjson,jsonparser,uRecorderPluginApi,
  uRecorderVisualComponentApiV2;
procedure Check(AValue:Boolean; const AMessage:string);
begin if not AValue then raise Exception.Create(AMessage); end;
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
const LegacyNames:array[0..4] of string =
  ('CreatePluginClass','DestroyPluginClass','PluginCreate','PluginNotify','PluginClose');
var lLibrary:TLibHandle; lGetInfo:TRecorderPluginGetInfo;
  lGetType:TRecorderPluginGetType; lGetDescriptor:TRecorderVisualGetDescriptorV2;
  lInfo:TRecorderPluginInfo; lDescriptor:TRecorderVisualComponentDescriptorV2;
  lServices:TRecorderVisualHostServicesV2; lFirst,lSecond:Pointer;
  lInitial,lChanged,lBad:UTF8String; lJson:TJSONData; lName:string;
  lStatus:LongInt; lOutputSize:SizeUInt;
begin
  lLibrary:=LoadLibrary(APath);
  Check(lLibrary<>NilHandle,'cannot load '+APath);
  lFirst:=nil; lSecond:=nil;
  try
    for lName in LegacyNames do
      Check(GetProcedureAddress(lLibrary,lName)=nil,'obsolete export remains: '+lName);
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
    UnloadLibrary(lLibrary);
  end;
end;
begin
  try
    Check(ParamCount=1,'usage: SamplePluginProbe plugin-library');
    RunProbe(ParamStr(1));
    WriteLn('RESULT sample-plugin flat V2 descriptor/state/lifecycle/no-legacy passed');
  except on E:Exception do
    begin WriteLn('RESULT sample-plugin failed: ',E.Message); Halt(1); end; end;
end.
