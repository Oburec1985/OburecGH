program sizes;
uses SysUtils;
const CMic185SettingsChannelSlots=69;
type
  r1=record f:single;c:boolean;b:word; end;
  r2=packed record f:single;c:boolean;b:word; end;
begin
  WriteLn('default r1=',SizeOf(r1));
  WriteLn('packed r2=',SizeOf(r2));
end.
