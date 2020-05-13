unit uGlPackage;

interface
uses
  SysUtils, Classes, Controls, uBaseGlComponent;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('glPage', [cBaseGlComponent]);
end;

end.
