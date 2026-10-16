unit uOscTags;
{$mode objfpc}{$H+}
{ Plugin-owned compatibility data facade. Metadata and settings load at
  Configure; RefreshInfo is called once per data notification. Reads never
  reach RecorderLnx objects. Caller arrays must be prepared before runtime. }
interface
uses Classes, SysUtils, Math, uOscModel, uOscDataAdapter,
  uRecorderVisualComponentApiV2;
type
  TOscDoubleArray = array of Double;
  TOscEstimateValue = record Valid: Boolean; Value: Double; end;
  TOscEstimateSettings = record
    EnabledKinds: array[TOscEstimate] of Boolean;
    DefaultKind: TOscEstimate;
  end;
  TOscSignalInfo = class
  public
    Revision, BlockCounter: QWord;
    Count: Integer;
    LatestTime: Double;
  end;
  EOscDataRead = class(Exception);
  TOscTag = class
  private
    fServices: PRecorderVisualHostServicesV2;
    fSignal: TOscSignalInfo;
    fUnitName: UTF8String;
    fEstimates: array[TOscEstimate] of TOscEstimateValue;
    function GetBlockCounter: QWord;
    procedure AcceptRead(AStatus: LongInt; ARequired, ACapacity: LongWord;
      out ACount: Integer);
  public
    Id: QWord;
    Name, Address, Description: UTF8String;
    AutoRange: Boolean;
    SourceVisible: Boolean;
    RangeMin, RangeMax, PollFrequencyHz: Double;
    EstimateSettings: TOscEstimateSettings;
    constructor Create(AServices: PRecorderVisualHostServicesV2;
      const AMeta: TOscTagMeta);
    destructor Destroy; override;
    function RefreshInfo: LongInt;
    function Estimate(AKind: TOscEstimate): TOscEstimateValue;
    procedure CopyLatestInto(AWindowSeconds: Double;
      var ATimes,AValues: TOscDoubleArray; out ACount: Integer;
      out ADisplayStart: Double); overload;
    procedure CopyLatestInto(AWindowSeconds: Double;
      var ATimes,AValues: TOscDoubleArray; out ACount: Integer;
      out ADisplayStart: Double; out ARevision: QWord); overload;
    procedure SnapshotRangeInto(AFromTimeSec: Double; AIncludePrevious: Boolean;
      var ATimes,AValues: TOscDoubleArray; out ACount: Integer;
      AToTimeSec: Double = MaxDouble);
    property SignalBuffer: TOscSignalInfo read fSignal;
    property UnitName: UTF8String read fUnitName;
    property BlockCounter: QWord read GetBlockCounter;
  end;
  TOscTagArray = array of TOscTag;
  TOscTagRegistry = class
  private
    fServices: PRecorderVisualHostServicesV2;
    fTags: TOscTagArray;
    function GetTagCount: Integer;
    function GetTag(AIndex: Integer): TOscTag;
    function GetSelectedTag: TOscTag;
  public
    constructor Create(AServices: PRecorderVisualHostServicesV2);
    destructor Destroy; override;
    function Configure: LongInt;
    procedure RefreshInfo;
    function FindById(AId: QWord): TOscTag;
    function FindByName(const AName: string): TOscTag;
    function IndexOf(ATag: TOscTag): Integer;
    property Tags[AIndex: Integer]: TOscTag read GetTag;
    property TagCount: Integer read GetTagCount;
    property SelectedTag: TOscTag read GetSelectedTag;
  end;
procedure PrepareOscHistory(var ATimes,AValues: TOscDoubleArray; ACapacity: Integer);
implementation
function HasServices(A: PRecorderVisualHostServicesV2): Boolean;
begin
  Result := OscServicesAvailable(A);
  if Result then Result := A^.Header.Size >= SizeOf(TRecorderVisualHostServicesV2);
end;
procedure InitHeader(var AHeader: TRecorderVisualAbiHeaderV2; ASize: LongWord);
begin
  AHeader.Size := ASize; AHeader.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  AHeader.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
end;
procedure PrepareOscHistory(var ATimes,AValues: TOscDoubleArray; ACapacity: Integer);
begin
  if ACapacity < 0 then raise ERangeError.Create('Negative history capacity');
  SetLength(ATimes,ACapacity); SetLength(AValues,ACapacity);
end;
constructor TOscTag.Create(AServices: PRecorderVisualHostServicesV2;
  const AMeta: TOscTagMeta);
var lSettings: TRecorderVisualEstimateSettingsV2; lKind: TOscEstimate;
begin
  inherited Create; fServices:=AServices; fSignal:=TOscSignalInfo.Create;
  Id:=AMeta.Id; Name:=AMeta.Name; fUnitName:=AMeta.UnitName;
  Address:=AMeta.Address; Description:=AMeta.Description;
  RangeMin:=AMeta.RangeMin; RangeMax:=AMeta.RangeMax;
  PollFrequencyHz:=AMeta.PollFrequencyHz;
  AutoRange:=(AMeta.Flags and REC_VISUAL_TAG_FLAG_AUTO_RANGE)<>0;
  SourceVisible:=(AMeta.Flags and REC_VISUAL_TAG_FLAG_SOURCE_VISIBLE)<>0;
  EstimateSettings.DefaultKind:=ovLastValue;
  if HasServices(fServices) and Assigned(fServices^.GetTagEstimateSettings) then begin
    lSettings:=Default(TRecorderVisualEstimateSettingsV2);
    InitHeader(lSettings.Header,SizeOf(lSettings));
    if fServices^.GetTagEstimateSettings(fServices^.Context,Id,@lSettings)=REC_VISUAL_OK then begin
      for lKind:=Low(TOscEstimate) to High(TOscEstimate) do
        EstimateSettings.EnabledKinds[lKind]:=(lSettings.EnabledKinds and (QWord(1) shl Ord(lKind)))<>0;
      if lSettings.DefaultKind<=Ord(High(TOscEstimate)) then
        EstimateSettings.DefaultKind:=TOscEstimate(lSettings.DefaultKind);
    end;
  end;
end;
destructor TOscTag.Destroy;
begin fSignal.Free; inherited Destroy; end;
function TOscTag.GetBlockCounter: QWord;
begin Result:=fSignal.BlockCounter; end;
function TOscTag.RefreshInfo: LongInt;
var lInfo:TRecorderVisualSignalInfoV2; lEstimate:TRecorderVisualEstimateV2;
  lKind:TOscEstimate;
begin
  Result:=REC_VISUAL_NOT_HANDLED;
  if not HasServices(fServices) or not Assigned(fServices^.GetSignalInfo) then Exit;
  lInfo:=Default(TRecorderVisualSignalInfoV2); InitHeader(lInfo.Header,SizeOf(lInfo));
  Result:=fServices^.GetSignalInfo(fServices^.Context,Id,@lInfo);
  if (Result=REC_VISUAL_OK) and
    ((lInfo.Header.Size<SizeOf(lInfo)) or
     (lInfo.Header.AbiMajor<>REC_VISUAL_ABI_V2_MAJOR) or
     (lInfo.Count>LongWord(High(Integer)))) then Result:=REC_VISUAL_ERROR;
  if Result<>REC_VISUAL_OK then begin
    fSignal.Count:=0; fSignal.Revision:=0; fSignal.BlockCounter:=0;
    fSignal.LatestTime:=0;
    FillChar(fEstimates,SizeOf(fEstimates),0); Exit;
  end;
  fSignal.Revision:=lInfo.Revision; fSignal.BlockCounter:=lInfo.BlockCounter;
  fSignal.Count:=lInfo.Count; fSignal.LatestTime:=lInfo.LatestTimeSec;
  if Assigned(fServices^.ReadEstimate) then
    for lKind:=Low(TOscEstimate) to High(TOscEstimate) do begin
      lEstimate:=Default(TRecorderVisualEstimateV2); InitHeader(lEstimate.Header,SizeOf(lEstimate));
      fEstimates[lKind].Valid:=fServices^.ReadEstimate(fServices^.Context,Id,
        Ord(lKind),@lEstimate)=REC_VISUAL_OK;
      fEstimates[lKind].Valid:=fEstimates[lKind].Valid and (lEstimate.Valid<>0);
      fEstimates[lKind].Value:=lEstimate.Value;
    end;
end;
function TOscTag.Estimate(AKind:TOscEstimate):TOscEstimateValue;
begin Result:=fEstimates[AKind]; end;
procedure TOscTag.AcceptRead(AStatus:LongInt; ARequired,ACapacity:LongWord; out ACount:Integer);
begin
  ACount:=0;
  if AStatus=REC_VISUAL_NOT_FOUND then Exit;
  if AStatus=REC_VISUAL_BUFFER_TOO_SMALL then
    raise EOscDataRead.CreateFmt('History capacity %d required; prepared %d',[ARequired,ACapacity]);
  if (AStatus<>REC_VISUAL_OK) or (ARequired>ACapacity) then
    raise EOscDataRead.CreateFmt('History callback status %d',[AStatus]);
  ACount:=ARequired;
end;
procedure TOscTag.CopyLatestInto(AWindowSeconds:Double; var ATimes,AValues:TOscDoubleArray;
  out ACount:Integer; out ADisplayStart:Double);
var lRevision:QWord;
begin CopyLatestInto(AWindowSeconds,ATimes,AValues,ACount,ADisplayStart,lRevision); end;
procedure TOscTag.CopyLatestInto(AWindowSeconds:Double; var ATimes,AValues:TOscDoubleArray;
  out ACount:Integer; out ADisplayStart:Double; out ARevision:QWord);
var lTimes,lValues:PDouble; lCapacity,lCount:LongWord; lLatest:Double; lStatus:LongInt;
begin
  if not OscServicesAvailable(fServices) then
    raise EOscDataRead.Create('Latest history service unavailable');
  lTimes:=nil; lValues:=nil; lCapacity:=Min(Length(ATimes),Length(AValues));
  if lCapacity>0 then begin lTimes:=@ATimes[0]; lValues:=@AValues[0]; end;
  lStatus:=fServices^.CopyLatestHistory(fServices^.Context,Id,AWindowSeconds,
    lTimes,lValues,lCapacity,lCount,ARevision,ADisplayStart,lLatest);
  AcceptRead(lStatus,lCount,lCapacity,ACount);
end;
procedure TOscTag.SnapshotRangeInto(AFromTimeSec:Double; AIncludePrevious:Boolean;
  var ATimes,AValues:TOscDoubleArray; out ACount:Integer; AToTimeSec:Double);
var lTimes,lValues:PDouble; lCapacity,lCount:LongWord; lLatest,lStart:Double;
  lRevision:QWord; lStatus:LongInt;
begin
  if not HasServices(fServices) or not Assigned(fServices^.CopyRangeHistory) then
    raise EOscDataRead.Create('Range history service unavailable');
  lTimes:=nil; lValues:=nil; lCapacity:=Min(Length(ATimes),Length(AValues));
  if lCapacity>0 then begin lTimes:=@ATimes[0]; lValues:=@AValues[0]; end;
  lStatus:=fServices^.CopyRangeHistory(fServices^.Context,Id,AFromTimeSec,AToTimeSec,
    Ord(AIncludePrevious),lTimes,lValues,lCapacity,lCount,lRevision,lStart,lLatest);
  AcceptRead(lStatus,lCount,lCapacity,ACount);
end;
constructor TOscTagRegistry.Create(AServices:PRecorderVisualHostServicesV2);
begin inherited Create; fServices:=AServices; end;
destructor TOscTagRegistry.Destroy;
var lTag:TOscTag;
begin for lTag in fTags do lTag.Free; inherited Destroy; end;
function TOscTagRegistry.Configure:LongInt;
var lCatalog:TOscTagCatalog; lTag:TOscTag; lIndex:Integer;
  lNewTags,lOldTags:TOscTagArray;
begin
  Result:=LoadOscTagCatalog(fServices,lCatalog); if Result<>REC_VISUAL_OK then Exit;
  { Publish only a fully constructed/refreshed catalog. Failed callbacks leave
    the old catalog and its borrowed tag references valid. Successful Configure
    replaces the catalog; callers must rebuild their borrowed references. }
  SetLength(lNewTags,Length(lCatalog));
  try
    for lIndex:=0 to High(lNewTags) do
    begin
      lNewTags[lIndex]:=TOscTag.Create(fServices,lCatalog[lIndex]);
      lNewTags[lIndex].RefreshInfo;
    end;
    lOldTags:=fTags;
    fTags:=lNewTags;
    lNewTags:=nil;
    for lTag in lOldTags do lTag.Free;
  finally
    for lTag in lNewTags do lTag.Free;
  end;
end;
procedure TOscTagRegistry.RefreshInfo;
var lTag:TOscTag;
begin for lTag in fTags do lTag.RefreshInfo; end;
function TOscTagRegistry.GetTagCount:Integer;
begin Result:=Length(fTags); end;
function TOscTagRegistry.GetTag(AIndex:Integer):TOscTag;
begin Result:=fTags[AIndex]; end;
function TOscTagRegistry.FindById(AId:QWord):TOscTag;
var lTag:TOscTag;
begin Result:=nil; for lTag in fTags do if lTag.Id=AId then Exit(lTag); end;
function TOscTagRegistry.FindByName(const AName:string):TOscTag;
var lTag:TOscTag;
begin Result:=nil; for lTag in fTags do if SameText(lTag.Name,AName) then Exit(lTag); end;
function TOscTagRegistry.IndexOf(ATag:TOscTag):Integer;
var lIndex:Integer;
begin Result:=-1; for lIndex:=0 to High(fTags) do if fTags[lIndex]=ATag then Exit(lIndex); end;
function TOscTagRegistry.GetSelectedTag:TOscTag;
var lId:QWord;
begin
  Result:=nil;
  if HasServices(fServices) and Assigned(fServices^.GetSelectedTagId) and
    (fServices^.GetSelectedTagId(fServices^.Context,lId)=REC_VISUAL_OK) then
    Result:=FindById(lId);
end;
end.
