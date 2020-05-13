unit uModifyFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uDeformerframe,
  uUI,
  uBtnListView,
  uNodeObject,
  uBaseModificator,
  ToolWin,
  uEventList,
  CreateModificatorForm,
  StdCtrls,uObjectTypes,
  uMoveControllerFrame,
  uMoveController,ImgList,
  uBaseDeformer,
  uSkinFrame,
  uskin,
  uglEventTypes;

type
  TModifyFrame = class(TFrame)
    ToolBar1: TToolBar;
    ModificatorsLV: TBtnListView;
    AddKeyBtn: TToolButton;
    ImageList1: TImageList;
    ScrollBox1: TScrollBox;
    RemoveKeyBtn: TToolButton;
    procedure ModificatorsLVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure AddKeyBtnClick(Sender: TObject);
    procedure ModificatorsLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  public
    SkinFrame1:  TSkinFrame;
    defFrame:TDeformerFrame;
    MoveControllerFrame:  TMoveControllerFrame;
  private
    UI:cUI;
    curobj:cnodeobject;
  private
    // событие выделения объекта
    procedure SelectNotify(sender:tobject);
    procedure hideframes;
  public
    constructor Create(AOwner: TComponent); override;
    procedure lincscene(pUI:cUI);
    procedure showmodifyies;
  end;

implementation

uses uModList;

{$R *.dfm}
constructor TModifyFrame.Create(AOwner: TComponent);
begin
  inherited;
  SkinFrame1:=tSkinFrame.Create(self);
  SkinFrame1.Parent:=ScrollBox1;
  SkinFrame1.Visible:=false;

  defframe:=TDeformerFrame.Create(self);
  defframe.Parent:=ScrollBox1;
  defframe.Visible:=false;

  MoveControllerFrame:=tMoveControllerFrame.Create(self);
  MoveControllerFrame.Parent:=ScrollBox1;
  MoveControllerFrame.Visible:=false;
end;

procedure TModifyFrame.SelectNotify(sender:tobject);
begin
  showmodifyies;
end;

procedure TModifyFrame.AddKeyBtnClick(Sender: TObject);
begin
  if curobj<>nil then
  begin
    cCreateModificatorForm.ShowModal(curobj.modcreator);
    showmodifyies;
  end;
end;

procedure TModifyFrame.lincscene(pUI:cUI);
begin
  UI:=pUI;
  ui.EventList.AddEvent('ShowModigyiesFrame',E_glSelectNew,SelectNotify);
  SkinFrame1.LincScene(pUI);
  MoveControllerFrame.LincScene(pUI);
  // отображаем модификаторы
  defFrame.LincScene(pUI);
  showmodifyies;
end;

procedure TModifyFrame.ModificatorsLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  ModificatorsLVSelectItem(sender, item, true);
end;

procedure TModifyFrame.ModificatorsLVSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  hideframes;
  if item.Data<>nil then
  begin
    if (tobject(item.data) is cskin) then
    begin
      SkinFrame1.skin:=cskin(item.Data);
      SkinFrame1.Show;
      SkinFrame1.visible:=true;
    end;
    if (tobject(item.data) is cBaseDeformer) then
    begin
      defFrame.deformer:=cBaseDeformer(item.Data);
      defFrame.Show;
      defFrame.visible:=true;
    end;
    if tobject(item.data) is cMoveController then
    begin
      MoveControllerFrame.showControler(cMoveController(item.Data));
      MoveControllerFrame.visible:=true;
    end;
  end;
end;

procedure TModifyFrame.showmodifyies;
var i:integer;
    obj:cnodeobject;
    li:tlistitem;
    modificator:cBaseModificator;
begin
  if Visible then
  begin
    obj:=UI.getselected(0);
    if obj<>nil then
    begin
      curobj:=obj;
      // Очистка списка модификаторов
      ModificatorsLV.Clear;
      for I := 0 to obj.ModCreator.count - 1 do
      begin
        li:=ModificatorsLV.items.add;
        modificator:=obj.ModCreator.getitem(i);
        li.Data:=modificator;
        ModificatorsLV.SetSubItemByColumnName(col_ModName,modificator.ClassName,li)
      end;
    end;
  end;
end;

procedure TModifyFrame.hideframes;
var i:integer;
    comp:tcomponent;
begin
  for I := 0 to componentcount - 1 do
  begin
    comp:=Components[i];
    if comp is tframe then
      tframe(comp).visible:=false;
  end;
end;

end.
