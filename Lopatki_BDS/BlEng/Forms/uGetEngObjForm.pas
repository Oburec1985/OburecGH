unit uGetEngObjForm;

interface

uses
  Windows, SysUtils, Classes, Forms,  StdCtrls, uBtnListView, uBldEng, uBaseObj,
  Controls, ComCtrls, ubldobj;

type
  testFunction = function(data:cbaseobj; data2:cbaseobj):boolean;

  TGetEngObjForm = class(TForm)
    SelObjLV: TBtnListView;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    engine:cbldeng;
  private
    procedure updateLV(testProc:testFunction; data:cbaseobj);
    procedure AddObj(obj:cbaseobj);
  public
    constructor create(aowner:tcomponent);override;
    procedure linc(eng:cBldEng);
    // получить объект по типу
    function GetObj(p_type:integer; data:cbaseobj; header:string):cbaseobj;
  end;

//var
//  GetEngObjForm: TGetEngObjForm;

implementation
uses
  usensor, upair, ustage, uturbina;

{$R *.dfm}

constructor TGetEngObjForm.create(aowner:tcomponent);
begin
  inherited;
  SelObjLV.Columns[0].Width:=45;
  SelObjLV.Columns[1].Width:=150;
  SelObjLV.Columns[2].Width:=100;
end;

procedure TGetEngObjForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

procedure TGetEngObjForm.linc(eng:cBldEng);
begin
  engine:=eng;
end;

function IsSensor(obj:cbaseobj; data2:cbaseobj):boolean;
begin
  result:=false;
  if obj is csensor then
  begin
    if data2<>nil then
    begin
      result:=obj.HaveCommonParent(data2)<>nil;
    end
    else
      result:=true;
  end;
end;

function IsTahoSensor(obj:cbaseobj; data2:cbaseobj):boolean;
begin
  result:=false;
  if (obj is cSensor) then
  begin
    if cSensor(obj).sensortype=c_rot then
    begin
      if data2<>nil then
      begin
        result:=obj.HaveCommonParent(data2)<>nil;
      end
      else
        result:=true;
    end;
  end;
end;

function IsEdgeSensor(obj:cbaseobj; data2:cbaseobj):boolean;
begin
  result:=false;
  if (obj is cSensor) then
  begin
    if cSensor(obj).sensortype=c_edge then
    begin
      if data2<>nil then
      begin
        result:=obj.HaveCommonParent(data2)<>nil;
      end
      else
        result:=true;
    end;
  end;
end;

function IsRootSensor(obj:cbaseobj; data2:cbaseobj):boolean;
begin
  result:=false;
  if (obj is cSensor) then
  begin
    if cSensor(obj).sensortype=c_Root then
    begin
      if data2<>nil then
      begin
        result:=obj.HaveCommonParent(data2)<>nil;
      end
      else
        result:=true;
    end;
  end;
end;

function IsPair(obj:cbaseobj; data2:cbaseobj):boolean;
begin
  result:=false;
  if obj is cPair then
  begin
    if data2<>nil then
    begin
      result:=obj.HaveCommonParent(data2)<>nil;
    end
    else
      result:=true;
  end;
end;

function IsStage(obj:cbaseobj; data2:cbaseobj):boolean;
begin
  result:=false;
  if obj is cStage then
  begin
    if data2<>nil then
    begin
      result:=obj.HaveCommonParent(data2)<>nil;
    end
    else
      result:=true;
  end;
end;

function IsTurbine(obj:cbaseobj; data2:cbaseobj):boolean;
begin
  result:=false;
  if obj is cTurbine then
  begin
    if data2<>nil then
    begin
      result:=obj.HaveCommonParent(data2)<>nil;
    end
    else
      result:=true;
  end;
end;

procedure TGetEngObjForm.AddObj(obj:cbaseobj);
var
  li:tlistitem;
begin
  li:=SelObjLV.Items.Add;
  li.Data:=obj;
  SelObjLV.SetSubItemByColumnName('№',inttostr(li.Index),li);
  SelObjLV.SetSubItemByColumnName('Имя',obj.name,li);
  SelObjLV.SetSubItemByColumnName('Тип',cbldobj(obj).TypeString,li);
end;

procedure TGetEngObjForm.updateLV(testProc:testFunction; data:cbaseobj);
var
  I: Integer;
  obj:cbaseobj;
begin
  SelObjLV.Clear;
  for I := 0 to engine.count - 1 do
  begin
    obj:=engine.getobj(i);
    if testProc(obj,data) then
    begin
      addobj(obj);
    end;
  end;
end;

function TGetEngObjForm.GetObj(p_type:integer; data:cbaseobj; header:string):cbaseobj;
begin
  Caption:=header;
  result:=nil;
  // отображаем весь список объектов удовлетворяющих выбранному фильтру
  case p_type of
    c_tahoSensor: updateLV(IsTahoSensor, data);
    c_edgeSensor: updateLV(IsEdgeSensor, data);
    c_RootSensor: updateLV(IsRootSensor, data);
    c_sensor: updateLV(IsSensor, data);
    c_pair: updateLV(IsPair, data);
    c_stage: updateLV(IsStage, data);
    c_Turbine: updateLV(IsTurbine, data);
  end;
  // Показываем диалог только если выбор более чем из одного объекта  
  if SelObjLV.Items.Count>0 then
  begin
    if SelObjLV.Items.Count>1 then
    begin
      SelObjLV.selected:=SelObjLV.items[0];
      if showmodal=mrok then
      begin
        result:=cbaseobj(SelObjLV.Selected.Data);
      end;
    end
    else
    begin
      result:=cbaseobj(SelObjLV.Items[0].Data);
    end;
  end;
end;

end.
