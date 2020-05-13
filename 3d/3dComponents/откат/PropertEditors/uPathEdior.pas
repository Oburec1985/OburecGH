unit uPathEdior;

interface
uses  DesignIntf, ubaseGlComponent, DesignEditors, sysutils, uUInterface,
      uobject, dialogs;
Type

cPathPropEditor = class(tpropertyeditor)
public
  function GetAttributes: TPropertyAttributes; override;
  function GetValue : string; override;
  procedure SetValue(const value:string);override;
  procedure Edit; override;
end;


procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(string), cBaseGLComponent,'resources', cPathPropEditor);
  RegisterPropertyEditor(TypeInfo(string), cBaseGLComponent,'scenename', cPathPropEditor);
end;

// Делаем так, чтоб около свойства высвечивалась кнопка ...
function cPathPropEditor.GetAttributes:TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog];
end;

function cPathPropEditor.GetValue:string;
begin
  result:=getstrvalue;
end;

procedure cPathPropEditor.SetValue(const value:string);
begin
  SetStrValue(value);
end;

procedure cPathPropEditor.edit;
var dlg:topendialog;
  MyClass: TObject;
begin
  DLG:=tOpenDialog.Create(nil);
  try
    with dlg do
    begin
      filename:=value;
      DefaultExt:='ini';
      Filter:='Исполняемые файлы|*.exe|Любые файлы|*.*';
      if execute then value:=filename;
    end;
    finally
      FreeAndNil(dlg);
  end;
end;

end.
