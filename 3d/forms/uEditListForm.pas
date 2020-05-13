// Диалог вызываемый для редактирования свойств объекта (рисовать узел, нормали)
// и проч. Колонки редактируемого ListView должны быть названы строго
// определленным способом (см. константы описанный ниже)
unit uEditListForm;

interface

uses
  Windows, Forms, StdCtrls, ComCtrls, Controls, Classes, uBtnListView, DCL_MYOWN,
  SysUtils, uNodeObject,uObject, uselectools, uBaseCamera, uSpin,uObjectTypes,
  umeshobr, uBaseObj;

type
  TEditObjectForm = class(TForm)
    DrawNormalCheckBox: TCheckBox;
    Label1: TLabel;
    Nameedit: TEdit;
    Label2: TLabel;
    ObjTypeCombobox: TComboBox;
    Button1: TButton;
    Button2: TButton;
    Label3: TLabel;
    NormalFloatEdit: TFloatEdit;
    Label4: TLabel;
    AxisLengthFloatEdit: TFloatEdit;
    DrawAxisCheckBox: TCheckBox;
    Label5: TLabel;
    DrawNodeCheckBox: TCheckBox;
    CameraGroupBox: TGroupBox;
    ActivateCameraCheckBox: TCheckBox;
    Label6: TLabel;
    FovSpinEdit: TFloatSpinEdit;
    AspectSpinEdit: TFloatSpinEdit;
    Label7: TLabel;
    NearPlaneSpinEdit: TFloatSpinEdit;
    Label8: TLabel;
    Label9: TLabel;
    FarPlaneSpinEdit: TFloatSpinEdit;
    TargetComboBox: TComboBox;
    Label10: TLabel;
    // Заполнение комбобокса именами объектов
    procedure TargetComboBoxChange(Sender: TObject);
    procedure TargetComboBoxUpdate(Sender: TObject);
  private
    m_obj:cnodeobject;// редактируемый объект
    { Private declarations }
  public
    // Меняет в UInterface указатель выбранного объекта и сам объект
    procedure SetNewSelObj(item: TListItem; lv: TListView;obj:cobject);
    procedure ShowModal_(item: TListItem; lv: TListView;obj:cobject);
    { Public declarations }
  end;

var
  EditObjectForm: TEditObjectForm;

const
  ObjName = 'Имя объекта';
  ObjType = 'Тип';
  DrawNormal = 'Нормали';
  DrawAxis = 'BasePivot';

implementation
uses
  uUI, uRender, uSceneMng;
{$R *.dfm}

procedure TEditObjectForm.SetNewSelObj(item: TListItem; lv: TListView;obj:cobject);
begin
   TBtnListView(lv).SetSubItemByColumnName(DrawNormal,
                    floattostr(NormalFloatEdit.FloatNum),item);
   // Обновить флаг рисовать нормали
   if obj.objtype=constcamera then
   begin
     cBaseCamera(obj).active:=ActivateCameraCheckBox.Checked;
     cBaseCamera(obj).fov:=fovspinedit.Value;
     cBaseCamera(obj).aspect:=Aspectspinedit.Value;
     cBaseCamera(obj).nearplane:=NearPlanespinedit.Value;
     cBaseCamera(obj).farplane:=FarPlanespinedit.Value;
   end;
   if DrawNormalCheckBox.Checked=true then
   begin
     obj.settings:=obj.settings or DRAW_NORMAL;
     if obj.objtype=constmesh then
     begin
       cMeshObr(obj).mesh.m_drawnormal:=NormalFloatEdit.FloatNum;
     end;
   end
   else
     obj.settings:=obj.settings and (DRAW_ALL - DRAW_NORMAL);
   // Обновить флаг рисовать локальную ось и узел
   TBtnListView(lv).SetSubItemByColumnName(DrawAxis,
                    floattostr(axisLengthFloatEdit.FloatNum),item);
   if DrawAxisCheckBox.Checked=true then
   begin
     obj.settings:=obj.settings or DRAW_LOCAL;
     obj.m_fAxisLength:=axisLengthFloatEdit.FloatNum;
   end
   else
     obj.settings:=obj.settings and (DRAW_ALL - DRAW_LOCAL);
   if DrawNodeCheckBox.Checked=true then
   begin
     obj.settings:=obj.settings or DRAW_NODE;
   end
   else
     obj.settings:=obj.settings and (DRAW_ALL - DRAW_NODE);
end;

procedure TEditObjectForm.ShowModal_(item: TListItem; lv: TListView;obj:cobject);
var str:string;
    res:integer;
begin
 m_obj:=obj;
 if obj.objtype=constcamera then
 begin
   CameraGroupBox.Visible:=true;
   ActivateCameraCheckBox.Checked:=cBaseCamera(obj).active;
   fovspinedit.Value:=cBaseCamera(obj).fov;
   Aspectspinedit.Value:=cBaseCamera(obj).aspect;
   NearPlanespinedit.Value:=cBaseCamera(obj).nearplane;
   FarPlanespinedit.Value:=cBaseCamera(obj).farplane;
 end
 else
 begin
   CameraGroupBox.Visible:=false;
 end;
 if obj.settings and DRAW_NORMAL<>0 then
 begin
   DrawNormalCheckBox.Checked:=true;
 end
 else
   DrawNormalCheckBox.Checked:=false;
  // Получить переменную "рисовать локальную ось"
 if obj.settings and DRAW_LOCAL<>0 then
   DrawNormalCheckBox.Checked:=true
 else
   DrawNormalCheckBox.Checked:=false;
  // Получить переменную "рисовать узел"
 if obj.settings and DRAW_NODE<>0 then
   DrawNodeCheckBox.Checked:=true
 else
   DrawNormalCheckBox.Checked:=false;
 // Получить имя объекта
 NameEdit.Text:=Obj.name;
 // Получить тип объекта
 TBtnListView(lv).GetSubItemByColumnName(ObjType,item,str);
 ObjTypeComboBox.Text:=str;
 res:= inherited ShowModal;
 // Изменение переменной рисовать нормали
 if res=mrok then
 begin
   SetNewSelObj(item, lv, obj);
 end
end;

// заполнение структуры выделенного объекта
procedure TEditObjectForm.TargetComboBoxChange(Sender: TObject);
var
  sc:cscene;
  i:integer;
  obj:cbaseobj;
begin
  sc:=cscene(sender);
  TargetComboBox.Clear;
  for I := 0 to sc.Count - 1 do
  begin
    obj:=sc.GetObj(i);
    TargetComboBox.AddItem(obj.name,obj);
  end;
end;

// заполнение структуры выделенного объекта
procedure TEditObjectForm.TargetComboBoxUpdate(Sender: TObject);
var obj:cNodeObject;
begin
  if TargetComboBox.ItemIndex<>-1 then
  begin
    cbasecamera(m_obj).gettarget(cnodeobject( TargetComboBox.items.Objects[TargetComboBox.ItemIndex]));
  end
  else
    cbasecamera(m_obj).gettarget(cnodeobject(nil));
end;

end.
