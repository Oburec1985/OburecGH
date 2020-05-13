// ������� ��� ��������� � ��������������� ������� �������� � �����. �������
// ������� ������ ���������� ������ ������������� ��������. ��. ��������� �
// uEditListForm. ��� ������� ���, ����� ���������� � ����� ������� �����
// �������� �����������.
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
    // ��������� ������ �������� � ListView, �������������� � �����
    procedure LincScene;
    // �������� ������ �� ���������� listitem
    function GetObject:cobject;
    // ������� �������� �������. ��������� � UserInterface, ������� ��������
    // ��� ������� ��� �������� �������. sender ����� ������������� ��� cobject
    procedure OnDeleteObject(sender:tobject);
  end;
var
  // ������� � �������� ���������� ���������� � �� ������� Fram-�, ����
  // ���������� �� �������� ������ �����������
  m_UInterface:cUI;// ���������� ��� �������� � ������� GetUI

const
  ObjName = '��� �������';
  ObjType = '���';
  DrawNormal = '�������';
  DrawAxis = 'BasePivot';
  c_ind = '������';
implementation

{$R *.dfm}

// �������� ������ �� UserInterface � ������������ ������� � ����
procedure TSelectObjectFrame.GetUI(UI:cui);
begin
  m_UInterface:=UI;
  LincScene;
end;

// ��������� ListView � ������� ������������ ���������� �� �������� �����
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
      constQuatObject:ObjectsLV.SetSubItemByColumnName(ObjType,'����������������',li);
      constmesh:ObjectsLV.SetSubItemByColumnName(ObjType,'���',li);
      constLight:ObjectsLV.SetSubItemByColumnName(ObjType,'����������',li);
      constcamera:ObjectsLV.SetSubItemByColumnName(ObjType,'������',li);
      constdummy:ObjectsLV.SetSubItemByColumnName(ObjType,'��������',li);
      constNodeObject:ObjectsLV.SetSubItemByColumnName(ObjType,'���� Node-��',li);
    end;
  end;
  m_UInterface.EventList.AddEvent('TargetComboBoxChange(LoadScene)',
               E_glLoadScene, EditObjectForm.TargetComboBoxChange);
end;

// �������� ������ �� stringlist �� �����
function GetObjFromStringlist(strings:tstringlist;name:string):Tobject;
var i:integer;
begin
  strings.Find(name,i);
  result:=strings.Objects[i];
end;

// ��������� �������� ����� �� ����� (����� ������� ��������� �������)
procedure TSelectObjectFrame.ObjectsLVDblClickProcess(item: TListItem; lv: TListView);
begin
  //EditObjectForm.ShowModal_(item,lv,cobject(GetObjFromStringlist(strings,item.Caption)));
end;

// �������� ��������� ������ ������.
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

// ������� ������� ����� �������� UInterface ��� �������� �������
procedure TSelectObjectFrame.OnDeleteObject(sender:tobject);
var
  i:integer;
  li:tlistitem;
  str:string;
begin
  // ������ ������� � ������� ��������� � �������� � ����������� ������ LoadSCENE.
  // ������� ���� ������ � ������� �� ���� ������ �� �������
  for I := 0 to ObjectsLV.items.Count - 1 do
  begin
    li:=ObjectsLV.Items[i];
    ObjectsLV.GetSubItemByColumnName('��� �������', li, str);
    if str=cobject(sender).name then
    begin
      li.Destroy;
      exit;
    end;
  end;
end;

end.
