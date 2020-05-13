unit uSkinForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  ComCtrls, uBtnListView, StdCtrls, uSpin,
  uUI, uNodeObject, uEventList, uGlEventTypes;

type
  TSkinFrame = class(TFrame)
    BonesLV: TBtnListView;
    GroupBox1: TGroupBox;
    BonesCB: TComboBox;
    AddBtn: TButton;
    DelBtn: TButton;
    FloatSpinEdit1: TFloatSpinEdit;
    Label1: TLabel;
  private
    ui:cUI;
  private
    // Событие которое происходит при выделении объекта
    procedure SelObjNotify(Sender: TObject);
  public
    procedure LincScene(pUI:cUI);
  end;

implementation

{$R *.dfm}

// заполнение структуры выделенного объекта
procedure TSkinFrame.SelObjNotify(Sender: TObject);
var ui:cUI;
    i:integer;
    obj:cNodeObject;
begin
  ui:=cUI(sender);
  BonesCB.Clear;
  for I := 0 to ui.scene.Objects.Count - 1 do
  begin
    obj:=cnodeobject(ui.scene.GetObj(i));
    BonesCB.AddItem(obj.name,obj);
  end;
end;

procedure TSkinFrame.LincScene(pUI:cUI);
begin
  UI:=pUI;
  ui.EventList.AddEvent('TSceneTreeViewFrame_OnSelect', E_glSelectNew, SelObjNotify);
end;

end.
