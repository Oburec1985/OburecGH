// Для успешного билда проекта нужно включить в проект designide.dcp
unit uGlPackage;

interface
uses
  SysUtils, Classes, Controls, uBaseGlComponent, uGlComponent, uglBaseItem,
  testUnit, StdCtrls, DesignIntf, uglturbine;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('glPage', [cBaseGlComponent]);
  RegisterNoIcon([glRegItem]);
  RegisterNoIcon([cGlButton]);
  RegisterNoIcon([cGlTurbine]);
  // ------------------------------------------------
end;

initialization
  Registerclass(glRegItem);
  //Registerclass(cBaseGlComponent);
  Registerclass(cGlButton);
  Registerclass(cGlTurbine);

finalization
  unRegisterclass(glRegItem);
  unRegisterclass(cGlButton);
  unRegisterclass(cGlTurbine);
end.
