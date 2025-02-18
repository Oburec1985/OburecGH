unit uRcCtrls;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms, Graphics,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons,
  //uComponentServises,
  uRecorderEvents,
  ubtnlistview,
  uRvclService,
  recorder, uRCFunc,
  tags, // теги рекордера
  activex;
type

  TRcComboBox = class(TCombobox)
  protected
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
                        var Accept: Boolean); override;
  protected
    procedure DragDrop(Source: TObject; X, Y: Integer);override;
    //procedure WndProc(var Message: TMessage); override;
  public
    function gettag(i:integer):itag; overload;
    function gettag:itag; overload;
    procedure updateTagsList;overload;
    procedure updateTagsList(vector:boolean);overload;
    procedure SetTagName(s:string);
  end;

procedure Register;

implementation

const
  c_lightRed = $008080FF;


function CheckCBItemInd(c:tcombobox):boolean;
begin
  if c.itemindex=-1 then
  begin
    c.Color:=c_lightRed;
    result:=false;
  end
  else
  begin
    c.Color:=clWindow;
    result:=true;
  end;
end;


function setComboBoxItem(str:string; c:tcombobox):integer;
var
  I: Integer;
begin
  result:=-1;
  for I := 0 to c.Items.Count - 1 do
  begin
    if (lowercase(c.Items[i])=lowercase(str)) then
    begin
      c.ItemIndex:=i;
      c.text:=str;
      result:=i;
      CheckCBItemInd(c);
      exit;
    end;
  end;
  if str='' then
  begin
    c.ItemIndex:=-1;
  end
  else
  begin
    c.ItemIndex:=-1;
    c.text:=str;
  end;
  CheckCBItemInd(c);
end;

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

procedure TRcComboBox.SetTagName(s:string);
begin
  setComboBoxItem(s,tcombobox(self));
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



function TRcComboBox.gettag: itag;
begin
  if ItemIndex>-1 then
  begin
    result:=itag(pointer(items.Objects[ItemIndex]));
  end
  else
    result:=nil;
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

procedure TRcComboBox.updateTagsList(vector: boolean);
var
  str:string;
  ir:irecorder;
begin
  str:=text;
  ir:=getIR;
  Clear;
  if ir<>nil then
  begin
    tagsToCB(ir, self, vector);
  end;
  setComboBoxItem(str, tcombobox(self));
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
