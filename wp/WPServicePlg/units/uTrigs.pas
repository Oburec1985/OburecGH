unit uTrigs;

interface
uses
  classes, Winpos_ole_TLB, POSBase;


type
  TUnits = (u_Abs, u_percent, u_10Lg, u_20Lg);

  cTrig = class
  public
    id: string;
    x: double;
    // ��������� ������� ����������� �� X
    Threshold, shift: double;
    // � ����� ������� ������ �����
    Front: boolean;
    TrigName: string;
    fsrcID: integer;
    number: integer;
    list: tstringlist;
    // ��������� ������������
    lastid: integer;
    processed: boolean;
    // ������������ ��� ������
    units: TUnits;
    // ������� ������ ��� ����� ���������. ���� ������� ������� �� ��� ��������� ������ ���������
    // � ������� ����� ������ ��� ����� ���������
    trigtype:integer;
  private
    procedure SetSrcID(id: integer);
    function getsrcid: integer;
  public
    // ���������� �������� � ���������� ���������
    function GetAbsoluteValue(s: iwpsignal): double;
    function GenID: string;
    function GetTime(var error: boolean; src: cSrc; start: double;cb: TProcessEvent): double;overload;
    function GetTime:double;overload;
    Function Compare(t: cTrig): boolean;
    property srcid: integer read getsrcid write SetSrcID;
  end;

implementation

end.
