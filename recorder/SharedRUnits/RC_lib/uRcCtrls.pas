unit uRcCtrls;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons, uComponentServises,
  uRecorderEvents,   uRCFunc, ubtnlistview, uRvclService,
  tags, recorder, activex;
type

  TRcComboBox = class(TCombobox)
  protected
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
                        var Accept: Boolean); override;
  protected
    procedure DragDrop(Source: TObject; X, Y: Integer);override;
    //procedure WndProc(var Message: TMessage); override;
  public
    function gettag(i:integer):itag;
    procedure updateTagsList;

  end;

procedure Register;

implementation

procedure TRcComboBox.DragDrop(Source: TObject; X, Y: Integer);
var
  t:itag;
  s:string;
  li:tlistitem;
begin
  t:=nil;
  if source is  tlistview then
  begin
    li:=tbtnlistview(source).selected;//tbtnlistview(source).GetItemAt(x,y);
    t:=itag(li.data);
  end;
  if t<>nil then
  begin
    s:=t.getname;
    setComboBoxItem(s,tcombobox(self));
  end;
  inherited;
end;

procedure TRcComboBox.DragOver(Source: TObject; X, Y: Integer;
                      State: TDragState; var Accept: Boolean);
var
  li:tlistitem;
begin
  inherited;
  if source is tListView then
  begin
    li:=tBtnListView(source).selected;
    if li=nil then exit;
    if li.Data <>nil then
    begin
      if tListitem(source).Data <>nil then
      begin
        Accept:= Supports(itag(li.Data),IID_ITAG);
      end;
    end;
  end;
end;



function TRcComboBox.gettag(i: integer): itag;
begin
  result:=itag(pointer(items.Objects[i]));
end;

procedure TRcComboBox.updateTagsList;
var
  str:string;
  ir:irecorder;
begin
  str:=text;
  ir:=getIR;
  Clear;
  if ir<>nil then
  begin
    tagsToCB(ir, self);
  end;
  setComboBoxItem(str,tcombobox(self));
end;

//procedure TRcComboBox.WndProc(var Message: TMessage);
//var
//  b:boolean;
//begin
//  case message.Msg of
//    WM_MOUSEWHEEL: exit;
//  end;
//  inherited;
//end;

///////////////////////////////////////////////////////////////////////////////////////////
procedure Register;
begin
   RegisterComponents('MERARecorder', [TRcComboBox]);
end;

end.
