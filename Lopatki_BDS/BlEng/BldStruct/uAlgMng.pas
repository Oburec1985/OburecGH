unit uAlgMng;

interface

uses
  usensor, ustage, utickdata, ubldmath, classes,ubldEngEventTypes, uDrawObj,
  uBaseBldAlg, uCommonMath, uEventtypes, ExtCtrls, uTag, uBaseObjMng, uDensityAlg
  ,uEvalTahoAlg, uRestoreVibrationAlg, uPairShape, uTrendAlg, uchart, ubaseobj,
  uSensorList, NativeXML, uPairTrend;

type
  cAlgMng = class(cBaseObjMng)
  protected
    tproc:tobject;
  protected
    fchart:cchart;
  protected
    procedure setchart(ch:cchart);
    procedure regObjClasses;override;
    procedure XMLSaveMngAttributes(node:txmlnode);override;
    procedure XMLlOADMngAttributes(node:txmlnode);override;
    procedure AddBaseObjInstance(obj:cbaseobj);override;
    procedure createevents;
    procedure OnChangeEngine(sender:tobject);
    procedure OnChangeGraphs(sender:tobject);
    procedure DeleteDrawObj(obj:cDrawObj);
  public
    procedure linc(p_tproc:tobject);
    function getTProc:tobject;
    function getalg(i:integer):cBaseBldAlg;
    constructor create;override;
    property chart:cchart read fchart write setChart;
    Function CreateObjByType(Classname:string):cbaseobj;override;
  end;


implementation
uses
  uBldTimeProc;

constructor cAlgMng.create;
begin
  inherited;
  objects.destroydata:=true;
end;

procedure cAlgMng.AddBaseObjInstance(obj:cbaseobj);
begin
  inherited;
  if tproc<>nil then
    cbldtimeproc(tproc).addalgtags(cBaseBldAlg(obj));
end;

procedure cAlgMng.setchart(ch:cchart);
begin
  fchart:=ch;
  if ch<>nil then
  begin
    ch.OBJmNG.Events.AddEvent('cAlgMng_OnChangeGraph',E_OnDestroyObject,OnChangeGraphs);
  end;
end;

procedure cAlgMng.regObjClasses;
begin
  inherited;
  regclass(cDensityAlg);
  regclass(cTahoAlg);
  regclass(cPairShape);
  regclass(cRestoreAlg);
  regclass(cTrendAlg);
  regclass(cPairTrend);
end;

Function cAlgMng.CreateObjByType(Classname:string):cbaseobj;
begin
  result:=inherited CreateObjByType(Classname);
  if result is cBaseBldAlg then
  begin
    cBaseBldAlg(result).eng:=cBldTimeProc(tproc).feng;
    cBaseBldAlg(result).sensorsList:=cAlgSensorList.create;
    cBaseBldAlg(result).sensorsList.destroydata:=false;
    cBaseBldAlg(result).ownerSensorList:=true;
  end;
end;

procedure cAlgMng.XMLSaveMngAttributes(node:txmlnode);
var
  str:string;
begin
  inherited;
  // ��� ���� �������
  node.WriteAttributeString('TahoName',str);
  // ������� ����������
  node.WriteAttributeFloat('ScreenUpdateT',cbldtimeproc(tproc).ViewTime);
end;

procedure cAlgMng.XMLlOADMngAttributes(node:txmlnode);
var
  str:string;
  sensor:csensor;
begin
  inherited;
  str:=node.ReadAttributeString('TahoName');
  sensor:=csensor(cbldtimeproc(tproc).feng.getobj(str));
  // ������� ����������
  cbldtimeproc(tproc).ViewTime:=node.ReadAttributeFloat('ScreenUpdateT');
end;

procedure cAlgMng.createevents;
begin
  cbldtimeproc(tproc).feng.Events.AddEvent('cAlgMng_OnChangeEngineList',E_OnDestroyObject,OnChangeEngine);
end;

procedure cAlgMng.OnChangeGraphs(sender:tobject);
begin
  if sender is cdrawobj then
  begin
    DeleteDrawObj(cdrawobj(sender));
  end;
end;

procedure cAlgMng.OnChangeEngine(sender:tobject);
var
  i:integer;
  a:cbasebldalg;
  s:csensor;
begin
  if sender is csensor then
  begin
    for I := 0 to Count - 1 do
    begin
      a:=getalg(i);
      if a.curtaho=sender then
        a.curtaho:=nil;
      s:=a.sensorsList.GetSensor(csensor(sender).name);
      if s=sender then
        a.sensorsList.Remove(s);
    end;
  end;
end;

function cAlgMng.getalg(i:integer):cBaseBldAlg;
begin
  result:=cBaseBldAlg(getobj(i));
end;

procedure cAlgMng.linc(p_tproc:tobject);
begin
  tproc:=p_tproc;
  createevents;
end;

function cAlgMng.getTProc:tobject;
begin
  result:=tproc;
end;

procedure cAlgMng.DeleteDrawObj(obj:cDrawObj);
var
  a:cbasebldalg;
  tag:cbasetag;
  I,j: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    a:=getalg(i);
    for j := 0 to a.tags.count - 1 do
    begin
      tag:=cbasetag(a.tags.getobj(j));
      if tag.DrawObj=obj then
      begin
        tag.DrawObj:=nil;
        exit;
      end;
    end;
  end;
end;

end.
