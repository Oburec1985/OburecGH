unit uMeraSignal;

interface
uses
  uCommonTypes;

type

  cSignal = class
    // ����� � �������
    obj:tobject;
    // ����� Mera �����
    k1:single;
    k0:single;
    // �������
    freqX:single;
    WriteXY:boolean;
    xUnits, yUnits, zUnits:string;

    b_3d:boolean;
    dZ,
    portionsize:integer;
  public
    function VType:integer;virtual; abstract;
    function GetT0:single;virtual; abstract;
    function SignalType:integer;virtual; abstract;
    function Count:integer;virtual; abstract;
    function GetP2(i:integer):point2;virtual; abstract;
    function GetY(i:integer):single;overload; virtual; abstract;
    function GetY(t:single):single;overload; virtual; abstract;
    function GetX(i:integer):single;virtual; abstract;
    function GetP2d(i:integer):point2d;virtual;abstract;
    function GetYd(i:integer):double;overload;virtual;abstract;
    function GetYd(t:double):double;overload;virtual;abstract;
    function GetXd(i:integer):double;virtual;abstract;
    function getname:string;virtual; abstract;
    function GetTEnd:single;virtual; abstract;
    constructor create;virtual;
  end;

  const
    c_Float = 1;
    c_Double = 2;

implementation

constructor cSignal.create;
begin
  k1:=1;
  k0:=0;
end;

end.
