unit uRecorderPxiMx248Addressing;

{ Presentation addresses for MX-248. Physical SourceId stays route-based. }

{$mode objfpc}{$H+}

interface

uses SysUtils;

const
  CPxiMx248AddressRuleKey = 'pxi.address-rule';
  CPxiMx248SourceAddressKey = 'pxi.source-address'; { dialog-only }
  CPxiMx248AddressRuleSlot = 'slot-channel';
  CPxiMx248AddressRuleTypeSlot = 'type-slot-channel';
  CPxiMx248AddressRuleChassisSlot = 'chassis-slot-channel';
  CPxiMx248AddressRuleManual = 'manual';

function PxiMx248NormalizeAddressRule(const ARule: string): string;
function PxiMx248DefaultSourceAddress(AChassis, ASlot: Integer;
  const ARule: string): string;
function PxiMx248ChannelAddress(const ASourceAddress: string;
  AChannel: Integer): string;
function PxiMx248TryChannelFromAddress(const AAddress: string;
  out AChannel: Integer): Boolean;
function PxiMx248ValidSourceAddress(const AAddress: string): Boolean;

implementation

function PxiMx248NormalizeAddressRule(const ARule: string): string;
begin
  if SameText(Trim(ARule), CPxiMx248AddressRuleManual) then
    Result := CPxiMx248AddressRuleManual
  else if SameText(Trim(ARule), CPxiMx248AddressRuleTypeSlot) then
    Result := CPxiMx248AddressRuleTypeSlot
  else if SameText(Trim(ARule), CPxiMx248AddressRuleChassisSlot) then
    Result := CPxiMx248AddressRuleChassisSlot
  else
    Result := CPxiMx248AddressRuleSlot;
end;

function PxiMx248DefaultSourceAddress(AChassis, ASlot: Integer;
  const ARule: string): string;
begin
  if PxiMx248NormalizeAddressRule(ARule) = CPxiMx248AddressRuleManual then
    Result := 'mx248-' + IntToStr(ASlot)
  else if PxiMx248NormalizeAddressRule(ARule) = CPxiMx248AddressRuleTypeSlot then
    Result := 'mx248-' + IntToStr(ASlot)
  else if PxiMx248NormalizeAddressRule(ARule) =
    CPxiMx248AddressRuleChassisSlot then
    Result := 'pxi' + IntToStr(AChassis) + '-' + IntToStr(ASlot)
  else
    Result := IntToStr(ASlot);
end;

function PxiMx248ChannelAddress(const ASourceAddress: string;
  AChannel: Integer): string;
begin
  Result := Trim(ASourceAddress) + '-' + IntToStr(AChannel);
end;

function PxiMx248TryChannelFromAddress(const AAddress: string;
  out AChannel: Integer): Boolean;
var
  lDash: SizeInt;
  lText: string;
begin
  lText := Trim(AAddress);
  if TryStrToInt(lText, AChannel) then
    Exit((AChannel >= 1) and (AChannel <= 8));
  lDash := LastDelimiter('-', lText);
  Result := (lDash > 0) and TryStrToInt(Copy(lText, lDash + 1, MaxInt),
    AChannel) and (AChannel >= 1) and (AChannel <= 8);
end;

function PxiMx248ValidSourceAddress(const AAddress: string): Boolean;
var
  lText: string;
begin
  lText := Trim(AAddress);
  Result := (lText <> '') and (Pos(';', lText) = 0) and
    (Pos('=', lText) = 0) and (lText[Length(lText)] <> '-');
end;

end.
