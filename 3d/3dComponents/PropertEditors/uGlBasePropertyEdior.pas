unit uGlBasePropertyEdior;

interface
uses  DesignIntf, ubaseGlComponent, DesignEditors, sysutils, uUI,
      uobject, dialogs, ComCtrls, forms, uObjectsPropertyForm, uEditObj;
Type

cGlBasePropertyEdior = class(tPropertyEditor)
private
public
  function GetAttributes: TPropertyAttributes; override;
  function GetValue : string; override;
  procedure Edit; override;
  // метод вызывается средой, здесь происходит создание диалога редактирования
  // объектов сцены
  procedure Initialize; override;
//  destructor Destroy;override;
end;

procedure Register;

implementation

procedure Register;
begin
  // 1 - тип свойства, 2 - тип компонента(владельца свойства), 3- название свойства, тип редактора
  RegisterPropertyEditor(TypeInfo(cobject), cBaseGLComponent,'obj', cGlBasePropertyEdior);
end;
//destructor cGlBasePropertyEdior.Destroy;
//begin
//  if dlg<>nil then
//  begin
//    dlg.destroy;
//    dlg:=nil;
//  end;
//end;
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
      dlg.execute(comp,comp.mUI,comp.owner,designer);
    end;
  end;
end;

procedure cGlBasePropertyEdior.Initialize;
begin
  inherited;
  if not assigned(dlg) then
    dlg:=TObjExplorerDlg.Create(nil);
end;


end.
