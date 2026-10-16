unit uOscUnits;
{$mode objfpc}{$H+}
interface
uses Classes, SysUtils, uRecorderVisualComponentApiV2;
type
  TOscUnitInfo=record
    QuantityId,Name,BaseUnitName:UTF8String;
    ScaleToBase:Double;
  end;
  TOscUnitCatalog=class
  private fUnits:array of TOscUnitInfo;
  public
    function Configure(AServices:PRecorderVisualHostServicesV2):LongInt;
    procedure FillUnitNames(ANames:TStrings);
    function TryGetUnitInfo(const AName:string; out AInfo:TOscUnitInfo):Boolean;
    function TryGetConversionFactor(const AFrom,ATo:string; out AFactor:Double):Boolean;
  end;
implementation
function TextOf(AText:PAnsiChar; ASize:Integer):UTF8String;
var lLength:Integer;
begin lLength:=0; while (lLength<ASize) and (AText[lLength]<>#0) do Inc(lLength);
  SetString(Result,AText,lLength); end;
function TOscUnitCatalog.Configure(AServices:PRecorderVisualHostServicesV2):LongInt;
var lInfo:TRecorderVisualUnitInfoV2; lIndex:LongWord;
begin
  fUnits:=nil; Result:=REC_VISUAL_NOT_HANDLED;
  if (AServices=nil) or (AServices^.Header.AbiMajor<>REC_VISUAL_ABI_V2_MAJOR) or
    (AServices^.Header.Size<SizeOf(TRecorderVisualHostServicesV2)) then Exit;
  if not Assigned(AServices^.EnumerateUnits) then Exit;
  for lIndex:=0 to 65535 do begin
    lInfo:=Default(TRecorderVisualUnitInfoV2); lInfo.Header.Size:=SizeOf(lInfo);
    lInfo.Header.AbiMajor:=REC_VISUAL_ABI_V2_MAJOR;
    Result:=AServices^.EnumerateUnits(AServices^.Context,lIndex,@lInfo);
    if Result=REC_VISUAL_END_OF_ENUMERATION then Exit(REC_VISUAL_OK);
    if Result<>REC_VISUAL_OK then begin fUnits:=nil; Exit; end;
    if (lInfo.Header.Size<SizeOf(lInfo)) or
      (lInfo.Header.AbiMajor<>REC_VISUAL_ABI_V2_MAJOR) then begin
      fUnits:=nil; Exit(REC_VISUAL_ERROR);
    end;
    SetLength(fUnits,lIndex+1);
    fUnits[lIndex].Name:=TextOf(@lInfo.Name[0],SizeOf(lInfo.Name));
    fUnits[lIndex].QuantityId:=TextOf(@lInfo.QuantityId[0],SizeOf(lInfo.QuantityId));
    fUnits[lIndex].BaseUnitName:=TextOf(@lInfo.BaseUnitName[0],SizeOf(lInfo.BaseUnitName));
    fUnits[lIndex].ScaleToBase:=lInfo.ScaleToBase;
  end;
  fUnits:=nil; Result:=REC_VISUAL_ERROR;
end;
procedure TOscUnitCatalog.FillUnitNames(ANames:TStrings);
var lUnit:TOscUnitInfo;
begin ANames.Clear; for lUnit in fUnits do ANames.Add(lUnit.Name); end;
function TOscUnitCatalog.TryGetUnitInfo(const AName:string; out AInfo:TOscUnitInfo):Boolean;
var lUnit:TOscUnitInfo;
begin Result:=False; AInfo:=Default(TOscUnitInfo);
  for lUnit in fUnits do if SameText(lUnit.Name,AName) then begin AInfo:=lUnit; Exit(True); end;
end;
function TOscUnitCatalog.TryGetConversionFactor(const AFrom,ATo:string; out AFactor:Double):Boolean;
var lFrom,lTo:TOscUnitInfo;
begin
  AFactor:=1;
  Result:=TryGetUnitInfo(AFrom,lFrom) and TryGetUnitInfo(ATo,lTo);
  if Result then Result:=SameText(lFrom.QuantityId,lTo.QuantityId) and (lTo.ScaleToBase<>0);
  if Result then AFactor:=lFrom.ScaleToBase/lTo.ScaleToBase;
end;
end.
