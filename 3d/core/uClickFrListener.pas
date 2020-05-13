unit uClickFrListener;

interface
uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,  ComCtrls, ImgList,
  uglframelistener, uUI, ToolWin, uObject, uMatrix, u3dtypes,
  MathFunction, uEventList, uSelectools, uNodeObject,
  uUIutils, uglEventTypes, dialogs;

type
  cClickFrListener = class(cglFrameListener)
  private
  public
    procedure wndproc(msg:tmessage; mouse:mousestruct);override;
  end;

implementation

procedure cClickFrListener.wndproc(msg:tmessage; mouse:mousestruct);
var obj:cnodeobject;
    changecursor:boolean;
begin
  changecursor:=false;
  case msg.Msg of
    WM_LBUTTONDOWN:
    begin
      // Поиск объекта по клику
      if cUI(ui).tryselect and not (cUI(ui).cursor=crSizeall) then
        findobject(mouse.x,mouse.y,ui);
      cUI(ui).needredraw:=true;
      // Вызов событий OnClick
      cUI(ui).eventlist.CallAllEvents(E_glWindowClick);
    end;
  end;
end;

end.
