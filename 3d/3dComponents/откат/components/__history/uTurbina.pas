unit uTurbina;

interface
uses
  SysUtils, Classes, Controls, uUInterface,messages;

type

  tturbina = class(TWinControl)
  private
    mUI:cUInterface;
  protected
    procedure WndProc(var Message:TMessage);override;
  public
    Constructor Create(AOwner:TComponent);override;
  published
  end;


implementation

Constructor tturbina.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  parent:=TWinControl(AOwner);
  Width:=200;
  hEIght:=200;
  mUI:=cUInterface.Create(handle);
end;

procedure tturbina.WndProc(var Message:TMessage);
begin
 inherited WndProc(Message);
 case Message.Msg of
 wm_paint:
   begin
     //mUI.m_RenderScene.RenderScene;
   end;
 end;
end;

end.
