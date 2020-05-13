unit uEditPoint3;

interface
uses  DesignIntf, ubaseGlComponent, DesignEditors, sysutils, uUInterface,
      uobject,ueditobj;

type
  tGetStrProc = procedure (const s:string) of object;

  cEditPoint3Property = class (tpropertyeditor)
    function GetAttributes: TPropertyAttributes; override;
    procedure GetProperties(Proc: TGetPropProc); override;
    procedure GetValues(Proc: TGetStrProc);
  end;

implementation


procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(string), cEditObj,'position', cEditPoint3Property);
end;

// Делаем так, чтоб около свойства высвечивалась кнопка ...
function cEditPoint3Property.GetAttributes:TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paValueList, paSubProperties];
end;

procedure cEditPoint3Property.GetValues(Proc: TGetStrProc);
begin
  //proc(floattostr(x));
  //proc(floattostr(y));
  //proc(floattostr(z));
end;

procedure cEditPoint3Property.GetProperties(Proc: TGetPropProc);
var
    comp:cEditObj;
    obj:cobject;
begin
  comp:=cEditObj(getcomponent(0));
 // proc(comp.position.x);
end;

end.
