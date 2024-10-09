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
  public
    function ready:boolean;
    function SrsFrm:TSRSFrm;
    procedure readFRFSensors(x,y,z:string);
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
  public
    function getPoint(i:integer):cModelPoint;
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
    p:=cModelPointList(m_owner).getPoint(i);
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
    m_frfSignalY:=f.getRes(x);
    m_frfSignalZ:=f.getRes(x);
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
function cModelPointList.getPoint(i: integer): cModelPoint;
begin
  result:=cModelPoint(items[i]);
end;

end.
