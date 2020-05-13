unit uGlBasePropertyEdior;

interface
uses  DesignIntf, ubaseGlComponent, DesignEditors, sysutils, uUInterface,
      uobject, dialogs, ComCtrls, forms, uObjectsPropertyForm, uEditObj;
Type

cGlBasePropertyEdior = class(tPropertyEditor)
private
  dlg:TObjExplorerDlg;
public
  function GetAttributes: TPropertyAttributes; override;
  function GetValue : string; override;
  procedure Edit; override;
  procedure Initialize; override;
  destructor Destroy;override;
end;

procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(cobject), cBaseGLComponent,'obj', cGlBasePropertyEdior);
  RegisterPropertyEditor(TypeInfo(cobject), cEditObj,'position', tVariantProperty);
end;

destructor cGlBasePropertyEdior.Destroy;
begin
  if dlg<>nil then
  begin
    dlg.destroy;
    dlg:=nil;
  end;
end;

// Делаем так, чтоб около свойства высвечивалась кнопка ...
function cGlBasePropertyEdior.GetAttributes:TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog, paReadOnly];
end;

function cGlBasePropertyEdior.GetValue:string;
begin
  FmtStr(Result, '(%s)', [GetPropType^.Name]);
end;

procedure cGlBasePropertyEdior.edit;
var
    comp:cBaseGlComponent;
    obj:cobject;
begin
  comp:=cBaseGlComponent(getcomponent(0));
  if comp<>nil then
  begin
    if comp.mUI<>nil then
    begin
      dlg.execute(comp.mUI);
    end;
  end;
end;

procedure cGlBasePropertyEdior.Initialize;
begin
  inherited;
  dlg:=TObjExplorerDlg.Create(nil,designer);
end;

end.
