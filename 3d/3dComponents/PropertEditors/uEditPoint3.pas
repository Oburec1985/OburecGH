unit uEditPoint3;

interface
uses  DesignIntf, ubaseGlComponent, DesignEditors, sysutils, uUI,
      uobject,ueditobj;

type
  tGetStrProc = procedure (const s:string) of object;

  cEditPoint3Property = class (tclassproperty)
//    function GetAttributes: TPropertyAttributes; override;
//    procedure GetProperties(Proc: TGetPropProc); override;
    //procedure GetValues(Proc: TGetStrProc);
  end;

implementation

procedure Register;
begin
//  RegisterPropertyEditor(TypeInfo(cpoint3), cEditObj,'position', cEditPoint3Property);
end;

// ������ ���, ���� ����� �������� ������������� ������ ...
//function cEditPoint3Property.GetAttributes:TPropertyAttributes;
//begin
//  Result := inherited GetAttributes + [paValueList, paSubProperties];
//end;

//procedure cEditPoint3Property.GetValues(Proc: TGetStrProc);
//begin
  //proc(floattostr(x));
  //proc(floattostr(y));
  //proc(floattostr(z));
//end;

//procedure cEditPoint3Property.GetProperties(Proc: TGetPropProc);
//var
//  comp:cEditObj;
//  obj:cobject;
//begin
//  comp:=cEditObj(getcomponent(0));
//  proc(comp.position.x);
//end;

//var
//  comp:cEditObj;
//  obj:cobject;
//begin
//  inherited;
//  comp:=cBaseGlComponent(getcomponent(0));
//  if comp<>nil then
//  begin
//    comp.position:=pos;
//  end;
end.
