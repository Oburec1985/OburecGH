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
  uCommonMath, MathFunction, u2DMath,
  u3dMoveEngine;


type
  cModelPoint = class
  protected
    // список точек
    m_owner:tlist;
    // хранит данные о тегах и передаточной характеристике
    m_frfSignalX, m_frfSignalY, m_frfSignalZ:cSRSres;
    // шаг по частоте для спектра
    m_dF:double;
    // синтезированная передаточная характеристика (усредненная)
    m_frfX, m_phaseX: TDoubleArray;
    m_frfY, m_phaseY: TDoubleArray;
    m_frfZ, m_phaseZ: TDoubleArray;
  public
    // имена датчиков по осям
    m_xName, m_yName, m_zName:string;
    // id точки (связывает номер FRF и номер точки модели)
    m_num:integer;
  public
    function ready:boolean;
    function SrsFrm:TSRSFrm;
    procedure readFRFSensors(x,y,z:string);
    constructor create(owner:tlist; num:integer);
    destructor destroy;
  end;

  // класс описатель списка точек 3d модели
  cModelPointList = class (tList)
  protected
    // список снятых Frf
    m_SRSFrm:TsrsFrm;
  public
    // деформируемая модель
    m_Model: c3dSkinObj;
    // масштаб анимации
    m_scale:double;
  public
    function getByIndPoint(i:integer):cModelPoint;
    function getByNamePoint(num:integer):cModelPoint;
    function AddPoint(Pnum:integer):cModelPoint;
  end;

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

procedure cModelPoint.readFRFSensors(x, y, z: string);
var
  f:TSRSFrm;
begin
  f:=SrsFrm;
  if checkstr(x) then
  begin
    m_frfSignalX:=f.getRes(x);
    m_frfSignalY:=f.getRes(y);
    m_frfSignalZ:=f.getRes(z);
  end;
end;

function cModelPoint.ready: boolean;
begin

end;

function cModelPoint.SrsFrm: TSRSFrm;
begin
  result:=cModelPointList(m_owner).m_SRSFrm;
end;

{ cModelPointList }
function cModelPointList.AddPoint(Pnum: integer): cModelPoint;
begin
  result:=cModelPoint
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
  for I := 0 to count - 1 do
  begin
    p:=getByIndPoint(i);
    if p=num then
    begin
      result:=p;
      exit;
    end;
  end;
  result:=cModelPoint.create(self, num);
end;

end.
