unit uRecorderMessages;

{
  Доменная модель строковых сообщений RecorderLnx. Источники один раз создают
  сообщения в реестре при конфигурации и затем публикуют только новые значения.
  UI читает согласованный latest-state snapshot по номеру ревизии.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Contnrs, SyncObjs;

type
  TRecorderMessageKind = (rmkInformation, rmkWarning, rmkStatus);

  TRecorderMessageSnapshot = record
    Id: QWord;
    Name: string;
    SourceId: string;
    Address: string;
    Value: string;
    TimestampSec: Double;
    Kind: TRecorderMessageKind;
    Color: LongInt;
    Quality: Cardinal;
    Revision: QWord;
  end;
  TRecorderMessageSnapshotArray = array of TRecorderMessageSnapshot;

  TRecorderMessage = class
  private
    fId: QWord;
    fName: string;
    fSourceId: string;
    fAddress: string;
    fValue: string;
    fTimestampSec: Double;
    fKind: TRecorderMessageKind;
    fColor: LongInt;
    fQuality: Cardinal;
    fRevision: QWord;
  public
    property Id: QWord read fId;
    property Name: string read fName;
    property SourceId: string read fSourceId;
    property Address: string read fAddress;
    property Kind: TRecorderMessageKind read fKind;
    property Color: LongInt read fColor;
  end;

  TRecorderMessageRegistry = class
  private
    fLock: TCriticalSection;
    fItems: TObjectList;
    fNextId: QWord;
    fRevision: QWord;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AName, ASourceId, AAddress: string;
      AKind: TRecorderMessageKind; AColor: LongInt): TRecorderMessage;
    procedure RemoveBySource(const ASourceId: string);
    procedure Publish(AItem: TRecorderMessage; const AValue: string;
      ATimestampSec: Double; AQuality: Cardinal);
    function CopySnapshot(var AItems: TRecorderMessageSnapshotArray;
      APreviousRevision: QWord): QWord;
    function Revision: QWord;
  end;

function RecorderMessageDefaultColor(AKind: TRecorderMessageKind): LongInt;
function RecorderMessageKindName(AKind: TRecorderMessageKind): string;
function RecorderMessageKindFromName(const AName: string): TRecorderMessageKind;

implementation

function RecorderMessageDefaultColor(AKind: TRecorderMessageKind): LongInt;
begin
  case AKind of
    rmkWarning: Result := $00C0FFFF;
    rmkStatus: Result := $00E6E6E6;
  else
    Result := $00FFFFFF;
  end;
end;

function RecorderMessageKindName(AKind: TRecorderMessageKind): string;
begin
  case AKind of
    rmkWarning: Result := 'warning';
    rmkStatus: Result := 'status';
  else
    Result := 'information';
  end;
end;

function RecorderMessageKindFromName(const AName: string): TRecorderMessageKind;
begin
  if SameText(Trim(AName), 'warning') then Exit(rmkWarning);
  if SameText(Trim(AName), 'status') then Exit(rmkStatus);
  Result := rmkInformation;
end;

constructor TRecorderMessageRegistry.Create;
begin
  inherited Create;
  fLock := TCriticalSection.Create;
  fItems := TObjectList.Create(True);
  fNextId := 1;
end;

destructor TRecorderMessageRegistry.Destroy;
begin
  fItems.Free;
  fLock.Free;
  inherited Destroy;
end;

function TRecorderMessageRegistry.Add(const AName, ASourceId,
  AAddress: string; AKind: TRecorderMessageKind;
  AColor: LongInt): TRecorderMessage;
var
  I: Integer;
  lItem: TRecorderMessage;
begin
  fLock.Acquire;
  try
    for I := 0 to fItems.Count - 1 do
    begin
      lItem := TRecorderMessage(fItems[I]);
      if SameText(lItem.fSourceId, ASourceId) and
        SameText(lItem.fAddress, AAddress) then
      begin
        lItem.fName := AName;
        lItem.fKind := AKind;
        if AColor < 0 then
          lItem.fColor := RecorderMessageDefaultColor(AKind)
        else
          lItem.fColor := AColor;
        Inc(fRevision);
        lItem.fRevision := fRevision;
        Exit(lItem);
      end;
    end;
    Result := TRecorderMessage.Create;
    Result.fId := fNextId;
    Inc(fNextId);
    Result.fName := AName;
    Result.fSourceId := ASourceId;
    Result.fAddress := AAddress;
    Result.fKind := AKind;
    if AColor < 0 then
      Result.fColor := RecorderMessageDefaultColor(AKind)
    else
      Result.fColor := AColor;
    fItems.Add(Result);
    Inc(fRevision);
    Result.fRevision := fRevision;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderMessageRegistry.Publish(AItem: TRecorderMessage;
  const AValue: string; ATimestampSec: Double; AQuality: Cardinal);
begin
  if AItem = nil then Exit;
  fLock.Acquire;
  try
    if (AItem.fValue = AValue) and (AItem.fQuality = AQuality) and
      SameValue(AItem.fTimestampSec, ATimestampSec) then Exit;
    AItem.fValue := AValue;
    AItem.fTimestampSec := ATimestampSec;
    AItem.fQuality := AQuality;
    Inc(fRevision);
    AItem.fRevision := fRevision;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderMessageRegistry.RemoveBySource(const ASourceId: string);
var
  I: Integer;
begin
  fLock.Acquire;
  try
    for I := fItems.Count - 1 downto 0 do
      if SameText(TRecorderMessage(fItems[I]).fSourceId, ASourceId) then
      begin
        fItems.Delete(I);
        Inc(fRevision);
      end;
  finally
    fLock.Release;
  end;
end;

function TRecorderMessageRegistry.CopySnapshot(
  var AItems: TRecorderMessageSnapshotArray;
  APreviousRevision: QWord): QWord;
var
  I: Integer;
  lItem: TRecorderMessage;
begin
  fLock.Acquire;
  try
    Result := fRevision;
    if Result = APreviousRevision then Exit;
    if Length(AItems) <> fItems.Count then SetLength(AItems, fItems.Count);
    for I := 0 to fItems.Count - 1 do
    begin
      lItem := TRecorderMessage(fItems[I]);
      AItems[I].Id := lItem.fId;
      AItems[I].Name := lItem.fName;
      AItems[I].SourceId := lItem.fSourceId;
      AItems[I].Address := lItem.fAddress;
      AItems[I].Value := lItem.fValue;
      AItems[I].TimestampSec := lItem.fTimestampSec;
      AItems[I].Kind := lItem.fKind;
      AItems[I].Color := lItem.fColor;
      AItems[I].Quality := lItem.fQuality;
      AItems[I].Revision := lItem.fRevision;
    end;
  finally
    fLock.Release;
  end;
end;

function TRecorderMessageRegistry.Revision: QWord;
begin
  fLock.Acquire;
  try
    Result := fRevision;
  finally
    fLock.Release;
  end;
end;

end.
