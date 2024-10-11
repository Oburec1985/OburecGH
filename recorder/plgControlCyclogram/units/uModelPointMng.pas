unit uModelPointMng;

interface
// Классы для анимации вершин модели по передаточным характеристикам
uses
  classes,
  uRCFunc,
  uSrsFrm,
  uMBaseControl,
  uMeasureBase,
  uHardwareMath,
  upoint,
  uCommonTypes,
  uCommonMath, MathFunction, u2DMath,
  uUI,
  unodeobject,
  uGlEventTypes,
  u3dobj,
  u3dMoveEngine;


type
  cModelPoint = class
  protected
    // список точек
    m_owner:tlist;
    // объект кость для анимации сетки
    m_SkinObj:c3dSkinObj;
    // шаг по частоте для спектра
    m_dF:double;
    m_xS, m_yS, m_zS:csrsres;
    // синтезированная передаточная характеристика (усредненная)
    m_frfX, m_phaseX: TDoubleArray;
    m_frfY, m_phaseY: TDoubleArray;
    m_frfZ, m_phaseZ: TDoubleArray;
  public
    // имена датчиков по осям
    m_xName, m_yName, m_zName:string;
    // id точки (связывает номер FRF и номер точки модели)
    m_num:integer;
  protected
    procedure readFRFSensors(x,y,z:string);
  public
    function GetAmp(sc:double; freq:double; phase:double):point3d;
    procedure setnames(x,y,z:string);
    function ready:boolean;
    function SrsFrm:TSRSFrm;
    constructor create(owner:tlist; num:integer);
    destructor destroy;
  end;

  // класс описатель списка точек 3d модели
  cModelPointList = class (tList)
  protected
    m_ui:cUI;
    // список снятых Frf
    m_SRSFrm:TsrsFrm;
  public
    // деформируемая модель
    m_Model: cnodeobject;
    // масштаб анимации
    m_scale:double;
  protected
    procedure OnPlayTimer(sender:tobject);
    procedure DelGlEvent;
    // связать точки с деформерами объекта
    procedure LinkPointsToModel;
  public
    procedure CreateGlEvent(ui:cui);
    // считать точки из FRF компонента
    procedure ReadPointsFromSrsFrm;
    function getByIndPoint(i:integer):cModelPoint;
    function getByNamePoint(num:integer):cModelPoint;
    // добавить или получить точку по имени
    function AddPoint(Pnum:integer):cModelPoint;
    // установка компонента с ударами
    procedure setSrsFrm(f:tsrsfrm);
    constructor create;
  end;

var
  g_ModelPointList:cModelPointList;

implementation

{ cPoint }

constructor cModelPoint.create(owner:tlist; num:integer);
begin
  m_owner:=owner;
  m_num:=num;
end;

destructor cModelPoint.destroy;
var
  I: Integer;
  p:cModelPoint;
begin
  for I := 0 to m_owner.Count - 1 do
  begin
    p:=cModelPointList(m_owner).getByIndPoint(i);
    if p=self then
    begin
      m_owner.Delete(i);
      break;
    end;
  end;
end;

function cModelPoint.GetAmp(sc:double; freq:double; phase:double):point3d;
var
  y, p:double;
  ind:integer;
begin
  result.x:=0; result.y:=0; result.z:=0;
  ind:=trunc(freq/m_dF);
  //p:=phase;
  if m_xS<>nil then
  begin
    y:=EvalLineYd(freq, p2d(ind*m_dF, m_frfX[ind]),p2d((ind+1)*m_dF, m_frfX[ind+1]));
    p:=EvalLineYd(freq, p2d(ind*m_dF, m_phaseX[ind]),p2d((ind+1)*m_dF, m_phaseX[ind+1]));
    result.x:=y*sc*sin(p*c_degtorad+phase);
  end;
  if m_yS<>nil then
  begin
    y:=EvalLineYd(freq, p2d(ind*m_dF, m_frfY[ind]),p2d((ind+1)*m_dF, m_frfY[ind+1]));
    p:=EvalLineYd(freq, p2d(ind*m_dF, m_phaseY[ind]),p2d((ind+1)*m_dF, m_phaseY[ind+1]));
    result.y:=y*sc*sin(p*c_degtorad+phase);
  end;
  if m_zS<>nil then
  begin
    y:=EvalLineYd(freq, p2d(ind*m_dF, m_frfZ[ind]),p2d((ind+1)*m_dF, m_frfZ[ind+1]));
    p:=EvalLineYd(freq, p2d(ind*m_dF, m_phaseZ[ind]),p2d((ind+1)*m_dF, m_phaseZ[ind+1]));
    result.z:=y*sc*sin(p*c_degtorad+phase);
  end;
end;

procedure cModelPoint.readFRFSensors(x, y, z: string);
var
  s:cSRSres;
  f:tsrsfrm;
  t: cSRSTaho;
begin
  f:=SrsFrm;
  t:=f.getTaho;
  if t<>nil then
    m_dF:=t.cfg.fspmdx;
  if checkstr(x) then
  begin
    s:=f.getRes(x);
    if s<>nil then
    begin
      m_xS:=s;
      setlength(m_frfx, length(s.m_frf));
      setlength(m_phaseX, length(s.m_frf));
      move(s.m_frf[0],m_frfX[0], length(s.m_frf));
      move(s.m_phase[0],m_phaseX[0], length(s.m_frf));
    end;
  end;
  if checkstr(y) then
  begin
    s:=f.getRes(y);
    if s<>nil then
    begin
      m_yS:=s;
      setlength(m_frfY, length(s.m_frf));
      setlength(m_phaseY, length(s.m_frf));
      move(s.m_frf[0],m_frfY[0], length(s.m_frf));
      move(s.m_phase[0],m_phaseY[0], length(s.m_frf));
    end;
  end;
  if checkstr(z) then
  begin
    s:=f.getRes(z);
    if s<>nil then
    begin
      m_zS:=s;
      setlength(m_frfz, length(s.m_frf));
      setlength(m_phaseZ, length(s.m_frf));
      move(s.m_frf[0],m_frfZ[0], length(s.m_frf));
      move(s.m_phase[0],m_phaseZ[0], length(s.m_frf));
    end;
  end;
end;

function cModelPoint.ready: boolean;
begin

end;

procedure cModelPoint.setnames(x, y, z: string);
begin
  m_xName:=x;
  m_yName:=y;
  m_zName:=z;
end;

function cModelPoint.SrsFrm: TSRSFrm;
begin
  result:=cModelPointList(m_owner).m_SRSFrm;
end;

{ cModelPointList }
function cModelPointList.AddPoint(Pnum: integer): cModelPoint;
var
  I: Integer;
  p:cModelPoint;
begin
  result:=nil;
  for I := 0 to count - 1 do
  begin
    p:=getByIndPoint(i);
    if p.m_num=Pnum then
    begin
      result:=p;
      exit;
    end;
  end;
  result:=cModelPoint.create(self, Pnum);
  Add(result);
end;

constructor cModelPointList.create;
begin
  m_scale:=10000;
end;

procedure cModelPointList.CreateGlEvent(ui: cui);
begin
  if m_UI=nil then
  begin
    m_ui:=ui;
    m_ui.TimeCntrl.maxtime:=3000;
    m_ui.TimeCntrl.tps:=1000;   // в 1 секунде 1000 тиков миллисекунд
    ui.eventlist.AddEvent('cModelPointList_OnPlayTimer', e_glOnPlayTimer, OnPlayTimer);
  end;
end;

procedure cModelPointList.DelGlEvent;
begin
  if m_ui<>nil then
  begin
    m_ui.eventlist.removeEvent(OnPlayTimer, e_glOnPlayTimer);
  end;
end;

function cModelPointList.getByIndPoint(i: integer): cModelPoint;
begin
  result:=cModelPoint(items[i]);
end;

function cModelPointList.getByNamePoint(num: integer): cModelPoint;
var
  I: Integer;
  p:cModelPoint;
begin
  result:=nil;
  for I := 0 to count - 1 do
  begin
    p:=getByIndPoint(i);
    if p.m_num=num then
    begin
      result:=p;
      exit;
    end;
  end;
end;

procedure cModelPointList.LinkPointsToModel;
var
  I, j: Integer;
  p:cModelPoint;
  o:c3dSkinObj;
  obj: c3dCtrlObj;
begin
  if g_ObjFrm3dFactory<>nil then
  begin
    CreateGlEvent(TObjFrm3d(g_ObjFrm3dFactory.GetFrm(0)).GL.mUI);
    if m_model=nil then
    begin
      for I := 0 to g_CtrlObjList.Count - 1 do
      begin
        obj:=g_CtrlObjList.GetObj(i);
        if obj is c3dSkinObj then
        begin
          m_model:=c3dSkinObj(obj).m_defObj;
          break;
        end;
      end;
    end;
  end;
  if g_CtrlObjList=nil then exit;
  if m_Model<>nil then
  begin
    for I := 0 to Count - 1 do
    begin
      p:=getByIndPoint(i);
      o:=g_CtrlObjList.GetObjBySkin(m_model.name, p.m_num);
      if o<>nil then
      begin
        p.m_SkinObj:=o;
      end;
    end;
  end;
end;

procedure cModelPointList.OnPlayTimer(sender: tobject);
var
  ph, fr:double;
  I: Integer;
  p:cModelPoint;
  p3:point3d;
begin
  ph:=c_2pi*(m_ui.TimeCntrl.time/m_ui.TimeCntrl.maxtime);
  fr:=m_SRSFrm.m_curFreq;
  if fr=0 then
    fr:=100;
  for I := 0 to Count - 1 do
  begin
    p:=getByIndPoint(i);
    p3:=p.GetAmp(m_scale, fr, ph);
    if p.m_SkinObj<>nil then
    begin
      p.m_SkinObj.position:=p3+p.m_SkinObj.startpos;
    end;
  end;

end;

procedure cModelPointList.ReadPointsFromSrsFrm;
var
  I: Integer;
  p:cModelPoint;
begin
  for I := 0 to Count - 1 do
  begin
    p:=getByIndPoint(i);
    p.readFRFSensors(p.m_xName,p.m_yName, p.m_zName);
  end;
  LinkPointsToModel;
end;

procedure cModelPointList.setSrsFrm(f: tsrsfrm);
begin
  m_SRSFrm:=f;
  m_scale:=f.Scalefe.FloatNum;
end;

end.
