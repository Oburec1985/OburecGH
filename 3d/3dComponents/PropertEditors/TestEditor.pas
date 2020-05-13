unit TestEditor;

interface

uses Classes, Controls, ExtCtrls, StdCtrls, DesignIntf, DesignEditors,
     Dialogs, ubaseglcomponent,  uglbaseitem, uglComponent, testunit;

type
   TButtonEditor = class(TComponentEditor)
     procedure Edit; override;
   end;

procedure Register;

implementation

procedure Register;
begin
//  RegisterComponentEditor(TButton, TButtonEditor);
end;

procedure TButtonEditor.Edit;
var P:TParentComponent;
    obj:tsubcomponent;
begin
   if Designer = nil then exit;
   P := Designer.CreateComponent(TParentComponent, Designer.Root, 10, 10, 10, 10) as TParentComponent;
   obj:=tsubcomponent(Designer.CreateComponent(TSubComponent, P, 10, 10, 10, 10));
   obj.SetParent(p);
end;

end.
