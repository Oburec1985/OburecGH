unit uObjectsPropertyForm;

interface

uses  Windows, SysUtils, CommDlg, ComCtrls, uobject, uselectools,DesignIntf,
      dialogs, Classes, Controls, Forms, StdCtrls,uObjectTypes,uGLComponent,
      uBtnListView, uUI, uEditObj, Buttons, uBaseglcomponent,
      ToolWin,uGlBaseItem, uObjCtrFrame
      //uSceneTreeView
      ;

type
  TObjExplorerDlg = class(TForm)
    lv: TBtnListView;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    BottomGB: TGroupBox;
    procedure AddObjBtnClick(Sender: TObject);
    procedure DelObjBtnClick(Sender: TObject);
    procedure lvDblClickProcess(item: TListItem; lv: TListView);
  private
    editObj:cEditObj;
    TestObj:cGlButton;
    designer:idesigner;
    form:tcomponent;
    UI:cUI;
    // ���������� � ��������� ������� �������
    basegl:cbaseglcomponent;
    ctrlObjFrame:TCtrlViewFrame;
    //ScTVFr:TSceneTreeViewFrame;
  private
    procedure GetUI(pUI:cUI);
    procedure createFrames;
  public
    constructor create(aOwner:tcomponent);
    destructor destroy;
    // f - ����� �� ������� ���������� ������, ���������� UI ������������ � form
    procedure execute(comp:cBaseglcomponent;UI:cUI;f:tcomponent;pdesigner:idesigner);
  end;

procedure releaseform;

var
  // ������ ���� ���������� ����������!!!, ��������� � ����������� ������ 1 ���
  // ����� ��� �������������� ���������� ����� ���������� ������
  dlg:TObjExplorerDlg;

var
  ObjExplorerDlg: TObjExplorerDlg;

const
  ObjName = '���';
  ObjType = '���';
  DrawNormal = '�������';
  DrawAxis = 'BasePivot';
  c_ind = '������';

implementation
uses testunit;

{$R *.dfm}

procedure releaseform;
begin
  if dlg<>nil then
  begin
    dlg.destroy;
    dlg:=nil;
  end;
end;

procedure TObjExplorerDlg.AddObjBtnClick(Sender: TObject);
var obj:cGlButton;
begin
  obj:=nil;
  if Assigned(Designer) then
  begin
    obj:=cGlButton(Designer.CreateComponent(cGlButton, nil , 1, 1, 1, 1));
    obj.setparent(BASEGL);
  end;
end;

procedure TObjExplorerDlg.DelObjBtnClick(Sender: TObject);
begin
  if Assigned(Designer) then
  begin
    TestObj.destroy;
  end;
end;

constructor TObjExplorerDlg.create(aOwner:tcomponent);
begin
  inherited create(aowner);
  editObj:=cEditObj.create(aowner);
  UI:=nil;
end;

procedure TObjExplorerDlg.GetUI(pUI:cUI);
var obj:cobject;
    i:integer;
    li:tlistitem;
begin
  if UI=nil then
  begin
    UI:=pUI;
    createFrames;    
  end;
  lv.Clear;
  if UI.scene.Count<>0 then
  begin
    for i:=0 to UI.scene.Objects.Count - 1 do
    begin
      li:=lv.items.Add;
      obj:=cobject(UI.scene.getObj(i));
      lv.SetSubItemByColumnName(c_ind,inttostr(i),li);
      lv.SetSubItemByColumnName(ObjName,obj.name,li);
      case obj.objtype of
        constQuatObject: lv.SetSubItemByColumnName(ObjType,'����������������',li);
        constmesh: lv.SetSubItemByColumnName(ObjType,'���',li);
        constLight: lv.SetSubItemByColumnName(ObjType,'����������',li);
        constcamera: lv.SetSubItemByColumnName(ObjType,'������',li);
        constdummy: lv.SetSubItemByColumnName(ObjType,'��������',li);
      end;
    end;
  end;
end;


procedure TObjExplorerDlg.lvDblClickProcess(item: TListItem; lv: TListView);
var obj:cobject;
begin
  if editobj<>nil then
  begin
    obj:=cobject(UI.scene.GetObj(item.Index));
    if obj<>nil then
    begin
      editObj.parent:=basegl;
      editObj.SetObj(obj);
      editObj.getPosition;
      if designer<>nil then
      begin
        designer.SelectComponent(TPersistent(editobj));
        designer.Modified;
      end;
    end;
  end;
end;

procedure TObjExplorerDlg.execute(comp:cBaseglcomponent;UI:cUI;f:tcomponent;pdesigner:idesigner);
begin
  designer:=pdesigner;
  form:=f;
  lv.Clear;
  GetUI(UI);
  basegl:=comp;
  inherited show;
end;

destructor TObjExplorerDlg.Destroy;
begin
  lv.Destroy;
  editObj.destroy;
  inherited destroy;
end;

procedure TObjExplorerDlg.createFrames;
begin
  ctrlObjFrame:= TCtrlViewFrame.create(self);
  ctrlObjFrame.parent:=BottomGB;
  ctrlObjFrame.Visible:=true;
  ctrlObjFrame.lincScene(ui);

  //ScTVFr:=TSceneTreeViewFrame.create(self);
  //ScTVFr.parent:=self;
  //ScTVFr.Visible:=true;
  //ScTVFr.GetUI(ui);
end;


initialization

finalization
  ReleaseForm;


end.
