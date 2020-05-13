unit uObjectsPropertyForm;

interface

uses  Windows, SysUtils, CommDlg, ComCtrls, uobject, uselectools,DesignIntf,
      dialogs, Classes, Controls, Forms, StdCtrls,
      uBtnListView, uUInterface, uEditObj;

type
  TObjExplorerDlg = class(TForm)
    lv: TBtnListView;
    procedure lvDblClickProcess(item: TListItem; lv: TListView);
  private
    editObj:cEditObj;
    designer:idesigner;
    UI:cUInterface;
    procedure GetUI(pUI:cUInterface);
  public
    constructor create(aOwner:tcomponent;pdesigner:idesigner);
    destructor destroy;
    procedure execute(UI:cUInterface);
  end;

procedure ReleaseVectorEditorForm;

var
  ObjExplorerDlg: TObjExplorerDlg;

const
  ObjName = 'Имя';
  ObjType = 'Тип';
  DrawNormal = 'Нормали';
  DrawAxis = 'BasePivot';
  c_ind = 'Индекс';

implementation

{$R *.dfm}

procedure ReleaseVectorEditorForm;
begin
	if Assigned(ObjExplorerDlg) then begin
	   ObjExplorerDlg.Free; ObjExplorerDlg:=nil;
	end;
end;


constructor TObjExplorerDlg.create(aOwner:tcomponent;pdesigner:idesigner);
begin
  inherited create(aowner);
  editObj:=cEditObj.create;
  designer:=pdesigner;
  UI:=nil;
end;

procedure TObjExplorerDlg.GetUI(pUI:cUInterface);
var obj:cobject;
    i:integer;
    li:tlistitem;
begin
  if UI=nil then
    UI:=pUI;
  lv.Clear;
  if UI.m_RenderScene.m_Loader.Objects.Count<>0 then
  begin
    for i:=0 to UI.m_RenderScene.m_Loader.Objects.Count - 1 do
    begin
      li:=lv.items.Add;
      obj:=cobject(UI.m_RenderScene.m_Loader.Objects.Objects[i]);
      lv.SetSubItemByColumnName(c_ind,inttostr(i),li);
      lv.SetSubItemByColumnName(ObjName,obj.name,li);
      case obj.objecttype of
        constQuatObject: lv.SetSubItemByColumnName(ObjType,'ТестКватернионов',li);
        constmesh: lv.SetSubItemByColumnName(ObjType,'Меш',li);
        constLight: lv.SetSubItemByColumnName(ObjType,'Светильник',li);
        constcamera: lv.SetSubItemByColumnName(ObjType,'Камера',li);
        constdummy: lv.SetSubItemByColumnName(ObjType,'Пустышка',li);
      end;
    end;
  end;
end;


procedure TObjExplorerDlg.lvDblClickProcess(item: TListItem; lv: TListView);
var obj:cobject;
begin
  showmessage('0');
  designer.SelectComponent(tPersistent(editobj));
  obj:=UI.m_RenderScene.m_Loader.GetObj(item.Index);
  showmessage('1');
  if obj<>editObj.getObj then
  begin
    showmessage('2');
    editObj.SetObj(obj);
    showmessage('3');
    designer.Modified;
    showmessage('4');
  end;
end;

procedure TObjExplorerDlg.execute(UI:cUInterface);
begin
  lv.Clear;
  GetUI(UI);
  inherited show;
end;

destructor TObjExplorerDlg.Destroy;
begin
  lv.Destroy;
  designer._Release;
  editObj.destroy;
  inherited destroy;
end;

procedure ReleaseEditorForm;
begin
  if assigned(ObjExplorerDlg) then
    ObjExplorerDlg.Free;
end;


initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

finalization

   ReleaseVectorEditorForm;


end.
