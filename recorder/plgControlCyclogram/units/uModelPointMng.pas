unit uModelPointMng;

interface
// ������ ��� �������� ������ ������ �� ������������ ���������������
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
    // ������ �����
    m_owner:tlist;
    // ������ ������ � ����� � ������������ ��������������
    m_frfSignalX, m_frfSignalY, m_frfSignalZ:cSRSres;
    // ��� �� ������� ��� �������
    m_dF:double;
    // ��������������� ������������ �������������� (�����������)
    m_frfX, m_phaseX: TDoubleArray;
    m_frfY, m_phaseY: TDoubleArray;
    m_frfZ, m_phaseZ: TDoubleArray;
  public
    // ����� �������� �� ����
    m_xName, m_yName, m_zName:string;
    // id ����� (��������� ����� FRF � ����� ����� ������)
    m_num:integer;
  protected
    procedure readFRFSensors(x,y,z:string);
  public
    procedure setnames(x,y,z:string);
    function ready:boolean;
    function SrsFrm:TSRSFrm;
    constructor create(owner:tlist; num:integer);
    destructor destroy;
  end;

  // ����� ��������� ������ ����� 3d ������
  cModelPointList = class (tList)
  protected
    // ������ ������ Frf
    m_SRSFrm:TsrsFrm;
  public
    // ������������� ������
    m_Model: c3dSkinObj;
    // ������� ��������
    m_scale:double;
  protected
    procedure ReadPointsFromSrsFrm;
  public
    function getByIndPoint(i:integer):cModelPoint;
    function getByNamePoint(num:integer):cModelPoint;
    function AddPoint(Pnum:integer):cModelPoint;
    procedure setSrsFrm(f:tsrsfrm);
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
begin
  //result:=cModelPoint
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
    if p.m_num=num then
    begin
      result:=p;
      exit;
    end;
  end;
  result:=cModelPoint.create(self, num);
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
end;

procedure cModelPointList.setSrsFrm(f: tsrsfrm);
begin
  m_SRSFrm:=f;
  ReadPointsFromSrsFrm;
end;

end.
