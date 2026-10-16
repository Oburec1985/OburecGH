program OscDataAdapterTest;
{$mode objfpc}{$H+}{$codepage utf8}
uses SysUtils, uRecorderVisualComponentApiV2, uOscDataAdapter, uSharedStatistics,
  uOscTags, uOscModel;
var gMode: Integer;
function EnumTags(AContext: Pointer; AIndex: LongWord;
  AInfo: PRecorderVisualTagInfoV2): LongInt; cdecl;
const Name: UTF8String = 'датчик';
begin
  if (gMode = 4) and (AIndex = 1) then Exit(REC_VISUAL_ERROR);
  if (gMode = 5) and (AIndex = 1) then
  begin
    AInfo^.TagId := 43;
    Result := REC_VISUAL_OK;
    Exit;
  end;
  if AIndex > 0 then Exit(REC_VISUAL_END_OF_ENUMERATION);
  AInfo^.TagId := 42; Move(Name[1], AInfo^.Name[0], Length(Name));
  Result := REC_VISUAL_OK;
end;
function CopyHistory(AContext: Pointer; ATagId: QWord; AWindowSeconds: Double;
  ATimes, AValues: PDouble; ACapacity: LongWord; out ACount: LongWord;
  out ARevision: QWord; out AStart, ALatest: Double): LongInt; cdecl;
begin
  ACount := 3; ARevision := 7; AStart := 1; ALatest := 3;
  if gMode = 1 then Exit(REC_VISUAL_NOT_FOUND);
  if gMode = 2 then begin ACount := 4; Exit(REC_VISUAL_BUFFER_TOO_SMALL); end;
  if gMode = 3 then begin ACount := 0; Exit(REC_VISUAL_OK); end;
  if ACapacity < 3 then Exit(REC_VISUAL_BUFFER_TOO_SMALL);
  ATimes[0] := 1; ATimes[1] := 2; ATimes[2] := 3;
  AValues[0] := 1; AValues[1] := 2; AValues[2] := 3;
  Result := REC_VISUAL_OK;
end;
procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;
function SignalInfo(AContext:Pointer; ATagId:QWord;
  AInfo:PRecorderVisualSignalInfoV2):LongInt; cdecl;
begin
  if (gMode=5) and (ATagId=43) then
    raise Exception.Create('Injected refresh failure');
  AInfo^.Count:=3; AInfo^.Revision:=7; AInfo^.BlockCounter:=2;
  AInfo^.LatestTimeSec:=3; Result:=REC_VISUAL_OK;
end;
function Selection(AContext:Pointer; out ATagId:QWord):LongInt; cdecl;
begin ATagId:=42; Result:=REC_VISUAL_OK; end;
function CopyRange(AContext:Pointer; ATagId:QWord; AFrom,ATo:Double;
  APrevious:LongWord; ATimes,AValues:PDouble; ACapacity:LongWord;
  out ACount:LongWord; out ARevision:QWord; out AStart,ALatest:Double):LongInt; cdecl;
begin
  if (AFrom<>1) or (ATo<>3) or (APrevious<>1) then Exit(REC_VISUAL_ERROR);
  Result:=CopyHistory(AContext,ATagId,2,ATimes,AValues,ACapacity,
    ACount,ARevision,AStart,ALatest);
end;
var lServices: TRecorderVisualHostServicesV2; lCatalog: TOscTagCatalog;
  lBinding: TOscTagBinding; lSummary: TStatisticsSummary; lValue: Double;
  lSnapshot: TOscHistorySnapshot;
  lRegistry:TOscTagRegistry; lTimes,lValues:TOscDoubleArray;
  lCount:Integer; lStart:Double; lOriginalTag:TOscTag;
begin
  lServices := Default(TRecorderVisualHostServicesV2);
  lServices.Header.Size := SizeOf(lServices);
  lServices.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  lServices.EnumerateTags := @EnumTags; lServices.CopyLatestHistory := @CopyHistory;
  Check(LoadOscTagCatalog(@lServices, lCatalog) = REC_VISUAL_OK, 'catalog');
  Check(lCatalog[0].Name = 'датчик', 'UTF8 metadata');
  lBinding := ResolveOscTag(@lServices, lCatalog, 42);
  try
    Check(lBinding.Refresh(10) = ohCapacityRequired, 'initial capacity query');
    Check(lBinding.RequiredCapacity = 3, 'required capacity');
    lBinding.Prepare(3);
    Check(lBinding.Refresh(10) = ohReady, 'ready');
    Check(lBinding.TryLatest(lValue) and (lValue = 3), 'latest');
    Check(lBinding.TryStatistics(lSummary, lValue), 'statistics');
    Check((lSummary.Mean = 2) and (Abs(lValue - Sqrt(14/3)) < 1E-12), 'mean RMS');
    lSnapshot := lBinding.Snapshot;
    gMode := 2;
    Check(lBinding.Refresh(10) = ohCapacityRequired, 'capacity changed');
    Check((lBinding.Snapshot.Values = lSnapshot.Values) and
      (lBinding.Snapshot.Revision = 7), 'snapshot preserved');
    gMode := 1;
    Check(lBinding.Refresh(10) = ohMissing, 'removed tag');
    Check(not lBinding.TryLatest(lValue), 'no stale missing value');
    gMode := 3;
    Check(lBinding.Refresh(10) = ohEmpty, 'empty history');
    lServices.Header.Size := SizeOf(TRecorderVisualAbiHeaderV2);
    Check(lBinding.Refresh(10) = ohUnavailable, 'short ABI table');
  finally lBinding.Free; end;
  lServices.Header.Size:=SizeOf(lServices); gMode:=0;
  lServices.GetSignalInfo:=@SignalInfo; lServices.GetSelectedTagId:=@Selection;
  lServices.CopyRangeHistory:=@CopyRange;
  lRegistry:=TOscTagRegistry.Create(@lServices);
  try
    Check(lRegistry.Configure=REC_VISUAL_OK,'facade configure');
    Check(lRegistry.SelectedTag=lRegistry.Tags[0],'selected tag');
    Check(lRegistry.Tags[0].SignalBuffer.Revision=7,'signal revision');
    Check(lRegistry.Tags[0].BlockCounter=2,'block counter');
    lOriginalTag:=lRegistry.Tags[0];
    gMode:=4;
    Check(lRegistry.Configure=REC_VISUAL_ERROR,'failed enumeration status');
    Check((lRegistry.TagCount=1) and (lRegistry.Tags[0]=lOriginalTag),
      'enumeration failure preserves catalog');
    gMode:=5;
    try
      lRegistry.Configure;
      Check(False,'refresh failure must propagate');
    except on E:Exception do
      Check(E.Message='Injected refresh failure','expected injected failure'); end;
    Check((lRegistry.TagCount=1) and (lRegistry.Tags[0]=lOriginalTag) and
      (lOriginalTag.SignalBuffer.Revision=7),'partial build preserves old tag');
    gMode:=0;
    Check(lRegistry.Configure=REC_VISUAL_OK,'reconfigure after failure');
    PrepareOscHistory(lTimes,lValues,3);
    lRegistry.Tags[0].CopyLatestInto(10,lTimes,lValues,lCount,lStart);
    Check((lCount=3) and (lValues[2]=3),'facade history');
    lRegistry.Tags[0].SnapshotRangeInto(1,True,lTimes,lValues,lCount,3);
    Check(lCount=3,'range endpoints');
    gMode:=2;
    try
      lRegistry.Tags[0].CopyLatestInto(10,lTimes,lValues,lCount,lStart);
      Check(False,'capacity must be explicit error');
    except on E:EOscDataRead do Check(Pos('4 required',E.Message)>0,'required capacity report'); end;
  finally lRegistry.Free; end;
  WriteLn('RESULT OscDataAdapter passed');
end.
