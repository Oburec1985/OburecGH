unit uObjExplorerDlg;

interface
uses  Windows, SysUtils, CommDlg, ComCtrls, uobject, uselectools,
      Classes, Controls, Forms, StdCtrls, uBtnListView, uUInterface;
type
  cObjExplorerDlg = class
  private
    f:tform;
    lv:tBtnListView;
    procedure GetUI(UI:cUInterface);
  public
    constructor Create(AOwner:TComponent);
    destructor destroy;
    procedure execute(UI:cUInterface);
  end;

const
  ObjName = '���';
  ObjType = '���';
  DrawNormal = '�������';
  DrawAxis = 'BasePivot';
  C_ind = '������';

implementation

procedure cObjExplorerDlg.GetUI(UI:cUInterface);
var obj:cobject;
    i:integer;
    li:tlistitem;
begin
  lv.Clear;
  for i:=0 to UI.m_RenderScene.m_Loader.Objects.Count - 1 do
  begin
    li:=lv.items.Add;
    obj:=cobject(UI.m_RenderScene.m_Loader.Objects.Objects[i]);
    lv.SetSubItemByColumnName(c_ind,inttostr(i),li);
    lv.SetSubItemByColumnName(ObjName,obj.name,li);
    case obj.objecttype of
      constQuatObject: lv.SetSubItemByColumnName(ObjType,'����������������',li);
      constmesh: lv.SetSubItemByColumnName(ObjType,'���',li);
      constLight: lv.SetSubItemByColumnName(ObjType,'����������',li);
      constcamera: lv.SetSubItemByColumnName(ObjType,'������',li);
      constdummy: lv.SetSubItemByColumnName(ObjType,'��������',li);
    end;
  end;
end;

procedure cObjExplorerDlg.execute(UI:cUInterface);
begin
  lv.Clear;
  GetUI(UI);
  f.show;
end;

constructor cObjExplorerDlg.Create(AOwner:TComponent);
var c1,c2,c3:TListColumn;
    col:tlistcolumns;
begin
  f:=tform.createnew(nil,0);
  f.Width:=265;
  f.Height:=439;
  f.Caption:='�������� �������� objects';
  lv:=tBtnListView.CreateParented(f.handle);
  lv.Top:=0;
  lv.left:=0;
  lv.Width:=265;
  lv.Height:=439;
  lv.Align:=alClient;
  lv.Visible:=true;
  lv.Color:=0;
  col:=tlistColumns.Create(lv);
  c1:=col.Add;c1.Caption:='������';
  c2:=col.Add;c2.Caption:='���';
  c3:=col.Add;c3.Caption:='���';
  lv.Columns:=col;
end;

destructor cObjExplorerDlg.Destroy;
begin
  lv.Destroy;
  f.Destroy;
  inherited destroy;
end;

end.
