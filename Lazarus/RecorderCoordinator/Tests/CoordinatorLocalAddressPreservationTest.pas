program CoordinatorLocalAddressPreservationTest;
{$mode objfpc}{$H+}
uses {$IFDEF UNIX}cthreads,{$ENDIF} Classes, SysUtils, fpjson, uCoordinatorModel;
const CId='83e7e8d1-64d0-486b-a512-12ab34cd56ef';
var M:TCoordinatorModel; D,R,H:TJSONObject; A:TJSONArray; IP:string;
procedure CheckAddress(const Stage:string);
begin
 H:=M.HostByIdJson(CId);
 try if H.Get('address','')<>IP then raise Exception.Create(Stage+': address changed to '+H.Get('address','')) finally H.Free end;
end;
begin
 if ParamCount<>1 then raise Exception.Create('Pass a real IPv4 of this test host');
 IP:=ParamStr(1); M:=TCoordinatorModel.Create;
 try
   D:=TJSONObject.Create; try D.Add('instance_id',CId); D.Add('remote_address',IP); R:=M.RegisterHello(D); R.Free finally D.Free end;
   D:=TJSONObject.Create; try D.Add('instance_id',CId); D.Add('remote_address','127.0.0.1'); R:=M.RegisterDiscovery(D); R.Free finally D.Free end;
   CheckAddress('UDP discovery');
   D:=TJSONObject.Create; try D.Add('instance_id',CId); D.Add('remote_address','127.0.0.1'); R:=M.RegisterHello(D); R.Free finally D.Free end;
   CheckAddress('HTTP hello');
   WriteLn('PASS preserved local address ',IP);
 finally M.Free end;
 M:=TCoordinatorModel.Create;
 try
   D:=TJSONObject.Create; try D.Add('instance_id','9ed2a651-7bdd-4260-a2a1-62e61d14a359'); D.Add('remote_address',IP); D.Add('mac_address','AA:BB:CC:DD:EE:01'); R:=M.RegisterHello(D); R.Free finally D.Free end;
   D:=TJSONObject.Create; try D.Add('instance_id',CId); D.Add('remote_address','127.0.0.1'); D.Add('mac_addresses','AA:BB:CC:DD:EE:01'); R:=M.RegisterDiscovery(D); R.Free finally D.Free end;
   CheckAddress('New instance with existing local MAC');
   A:=M.HostsJson; try if A.Count<>1 then raise Exception.Create('Duplicate local recorder') finally A.Free end;
   WriteLn('PASS replaced local identity without duplicate');
 finally M.Free end;
end.
