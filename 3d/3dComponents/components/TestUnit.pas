unit TestUnit;

interface

uses Classes, Controls, ExtCtrls, StdCtrls, DesignIntf,
     Dialogs, ubaseglcomponent,  uglbaseitem, uglComponent;

type
   TParentComponent = class(twincontrol)
   private
      FList : TList;
   protected
      procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
      //procedure CMControlListChanging(var Message: TCMControlListChanging); message CM_CONTROLLISTCHANGING;
   public
      constructor Create(AOwner:TComponent); override;
   end;

   TSubComponent = class(glregitem)
   private
     fparent:tparentcomponent;
   protected
     // ћетод TComponent перекрыт дл€ сохранени€ всего дерева в потоке.
     // ≈сли этот метод не перекрывать, сохран€етс€ только текущий элемент.
     function GetParentComponent:tcomponent;override;
     function HasParent: Boolean; override;
     // ћетод TComponent перекрыт дл€ восстановлени€ иерархии дерева при чтении
     // из потока. ≈сли этот метод не перекрывать, подчиненность элементов нару-
     // шаетс€.
     procedure SetParentComponent (Value: TComponent); override;
   public
     procedure setParent(v:tcomponent);
   end;

implementation

constructor TParentComponent.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   FList := TList.Create;
end;

procedure TParentComponent.GetChildren(Proc: TGetChildProc; Root: TComponent);
var I: Integer;
    Control: TSubComponent;
begin
  for I := 0 to FList.Count - 1 do
  begin
    Control := TSubcomponent(FList[i]);
    if Control.Owner = Root then
     Proc(Control);
  end;
end;

function TSubComponent.GetParentComponent:tcomponent;
begin
  if fparent<>nil then
    result:=fparent;
end;

function TSubComponent.HasParent: Boolean;
begin
  if fparent<>nil then
    result:=true
  else
    result:=false;
end;

procedure TSubComponent.setParent(v:tcomponent);
begin
  fparent:=tparentcomponent(v);
  fparent.FList.Add(self);
end;

procedure TSubComponent.SetParentComponent (Value: TComponent);
begin
  setparent(value);
end;

end.
