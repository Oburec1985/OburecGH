// Таблица для просмотра и редактиирования свойств объектов в сцене. Колонки
// таблицы должны называться строго определленным способом. См. константы в
// uEditListForm. Это сделано так, чтобы определить в какой колонке какое
// свойство размещается.
unit SelectObjectsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, uRender, uUI, uselectools,
  uEditListForm,
  uobject,
  uBaseCamera,
  uObjectTypes,
  uEventList,
  uglEventTypes;

type
  TSelectObjectFrame = class(TFrame)
    ObjectsLV: TBtnListView;
    Label1: TLabel;
    procedure ObjectsLVDblClickProcess(item: TListItem; lv: TListView);
  private
    { Private declarations }
  public
    procedure GetUI(UI:cUI);
    // Обновляет список объектов в ListView, присутствующих в сцене
    procedure LincScene;
    // Получить ссылку на выделенный listitem
    function GetObject:cobject;
    // Событие удаления объекта. Линкуется к UserInterface, который вызывает
    // это событие при удалении объекта. sender можно разъименовать как cobject
    procedure OnDeleteObject(sender:tobject);
  end;
var
  // Сделаны в качестве глобальной переменной а не мембера Fram-а, чтоб
  // компилятор не отвлекал тупыми сообщениями
  m_UInterface:cUI;// передается при создании с помощью GetUI

const
  ObjName = 'Имя объекта';
  ObjType = 'Тип';
  DrawNormal = 'Нормали';
  DrawAxis = 'BasePivot';
  c_ind = 'Индекс';
implementation

{$R *.dfm}

// Получить ссылку на UserInterface и прилинковать события к нему
procedure TSelectObjectFrame.GetUI(UI:cui);
begin
  m_UInterface:=UI;
  LincScene;
end;

// Обновляет ListView в который отображается информация об объектах сцены
procedure TSelectObjectFrame.LincScene;
var
  i:integer;
  li:TListItem;
  obj:cobject;
begin
  ObjectsLV.Clear;
  for i:=0 to m_UInterface.scene.World.ChildCount - 1 do
  begin
    li:=ObjectsLV.items.Add;
    obj:=cobject(m_UInterface.scene.GetObj(i));
    ObjectsLV.SetSubItemByColumnName(ObjName,obj.name,li);
    case obj.objtype of
      constQuatObject:ObjectsLV.SetSubItemByColumnName(ObjType,'ТестКватернионов',li);
      constmesh:ObjectsLV.SetSubItemByColumnName(ObjType,'Меш',li);
      constLight:ObjectsLV.SetSubItemByColumnName(ObjType,'Светильник',li);
      constcamera:ObjectsLV.SetSubItemByColumnName(ObjType,'Камера',li);
      constdummy:ObjectsLV.SetSubItemByColumnName(ObjType,'Пустышка',li);
      constNodeObject:ObjectsLV.SetSubItemByColumnName(ObjType,'Тест Node-ов',li);
    end;
  end;
  m_UInterface.EventList.AddEvent('TargetComboBoxChange(LoadScene)',
               E_glLoadScene, EditObjectForm.TargetComboBoxChange);
end;

// Получить объект из stringlist по имени
function GetObjFromStringlist(strings:tstringlist;name:string):Tobject;
var i:integer;
begin
  strings.Find(name,i);
  result:=strings.Objects[i];
end;

// Обработка двойного клика по итему (вызов диалога настройки объекта)
procedure TSelectObjectFrame.ObjectsLVDblClickProcess(item: TListItem; lv: TListView);
begin
  //EditObjectForm.ShowModal_(item,lv,cobject(GetObjFromStringlist(strings,item.Caption)));
end;

// Получить выделеный объект объект.
function TSelectObjectFrame.GetObject:cobject;
var li:TListItem;
    str:string;
    index:integer;
begin
  li:=ObjectsLV.Selected;
  if li=nil then
  begin
    if (ObjectsLV.items.Count>0) then
    begin
     ObjectsLV.ItemIndex:=0;
     li:=ObjectsLV.items[0];
    end;
  end;
  if li<>nil then
  begin
    ObjectsLV.GetSubItemByColumnName(ObjName,li,str);
    result:=cobject(m_UInterface.scene.getobj(index));
  end
  else
    result:=nil;
end;

// Событие которое будет вызывать UInterface при удалении объекта
procedure TSelectObjectFrame.OnDeleteObject(sender:tobject);
var
  i:integer;
  li:tlistitem;
  str:string;
begin
  // Индекс объекта в таблице совпадает с индексом в стринглисте класса LoadSCENE.
  // находим этот индекс и удаляем по нему объект из таблицы
  for I := 0 to ObjectsLV.items.Count - 1 do
  begin
    li:=ObjectsLV.Items[i];
    ObjectsLV.GetSubItemByColumnName('Имя объекта', li, str);
    if str=cobject(sender).name then
    begin
      li.Destroy;
      exit;
    end;
  end;
end;

end.
