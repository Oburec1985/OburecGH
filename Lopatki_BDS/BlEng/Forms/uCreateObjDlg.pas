unit uCreateObjDlg;

interface

uses
  Windows, Forms, StdCtrls, Controls, Classes, uBldObj, uBldEng, ubaseobj,
  uTurbineFrame, ExtCtrls, uCompaundFrame, uTurbina, uStage, uPair, uSensor,
  uChan, uBaseObjService, uUTSSensor, uBldGlobalStrings, u2070, u2081;

type
  TCreateObjDlg = class(TForm)
    SelectObjTypeGB: TGroupBox;
    PossibleObjLV: TListBox;
    UserBtnGB: TGroupBox;
    CancelBtn: TButton;
    OkBtn: TButton;
    ObjPropertyGB: TGroupBox;
    Splitter1: TSplitter;
    CompaundFrame1: TCompaundFrame;
    procedure PossibleObjLVClick(Sender: TObject);
  private
    curobj:cbldobj;
  private
    rootObj:cBldObj;
    eng:cBldEng;
    // Выбраный тип создаваемого объекта
    selecttype:integer;
    uTurbineFrame:TTurbineFrame;
  private
    // прилинковать объект к которому может быть добавлен дочерний объект
    procedure lincRoot(p_rootObj:cBldObj);
  public
    procedure lincEng(p_eng:cBldEng);
    Function CreateObj:cBldObj;
    constructor create(aowner:tcomponent);override;
    function showmodal:integer;override;
  end;

var
  CreateObjDlg: TCreateObjDlg;

implementation

{$R *.dfm}

procedure TCreateObjDlg.lincEng(p_eng:cBldEng);
begin
  eng:=p_eng;
end;

procedure TCreateObjDlg.lincRoot(p_rootObj:cBldObj);
begin
  rootObj:=p_rootObj;
  PossibleObjLV.Clear;
  if rootObj.SupportedChildClass(c_turbine) then
    PossibleObjLV.AddItem(gettypestring(c_turbine), nil);
  if rootObj.SupportedChildClass(c_stage) then
    PossibleObjLV.AddItem(gettypestring(c_stage), nil);
  if rootObj.SupportedChildClass(c_sensor) then
    PossibleObjLV.AddItem(gettypestring(c_sensor), nil);
  if rootObj.SupportedChildClass(c_pair) then
    PossibleObjLV.AddItem(gettypestring(c_pair), nil);
end;

procedure TCreateObjDlg.PossibleObjLVClick(Sender: TObject);
var
  str:string;
begin
  str:=PossibleObjLV.Items[PossibleObjLV.ItemIndex];
  // отобразить свойства создаваемого объекта
  compaundframe1.getObj(createobj);
end;

Function TCreateObjDlg.CreateObj:cBldObj;
var
  i:integer;
  obj:cBldObj;
begin
  if curobj<>nil then
    curobj.destroy;
  result:=nil;
  if PossibleObjLV.ItemIndex<0 then exit;
  i:=TypeStringToInt(PossibleObjLV.items[PossibleObjLV.ItemIndex]);
  obj:=nil;
  case i of
    c_Turbine:
    begin
      obj:=cturbine.create;
    end;
    c_Stage:
    begin
      obj:=cstage.create;
    end;
    c_Pair:
    begin
      obj:=cpair.create;
    end;
    c_Sensor:
    begin
      obj:=csensor.create;
    end;
    c_Chan:
    begin
      obj:=cchan.create;
    end;
    c_UTS:
    begin
      obj:=cUTSSensor.create;
    end;
    c_2070:
    begin
      obj:=cM2070.create;
    end;
    c_2081:
    begin
      obj:=cM2081.create;
    end;
  end;
  obj.ReplaceObjMng(eng);
  result:=obj;
  curobj:=obj;
end;

constructor TCreateObjDlg.create(aowner:tcomponent);
begin
  inherited;
  PossibleObjLV.Clear;
  PossibleObjLV.AddItem(v_Turbine,nil);
  PossibleObjLV.AddItem(v_stage,nil);
  PossibleObjLV.AddItem(v_Pair,nil);
  PossibleObjLV.AddItem(v_Sensor,nil);
  PossibleObjLV.AddItem(v_Chan,nil);
  PossibleObjLV.AddItem(v_UTS,nil);
  PossibleObjLV.AddItem('M2070',nil);
  PossibleObjLV.AddItem('M2081',nil);
end;

function TCreateObjDlg.showmodal:integer;
begin
  if curobj=nil then
  begin
    curobj:=CreateObj;
    compaundframe1.getObj(curobj);
  end;
  if inherited showmodal = mrok then
  begin
    // перенос созданного объекта в движок
    compaundframe1.setObj;
    curobj.ReplaceObjMng(nil);
    eng.add(curobj);
    curobj:=nil;
  end
  else
  begin
    if curobj<>nil then
    begin
      curobj.destroy;
      curobj:=nil;
    end;
  end;
end;

end.
