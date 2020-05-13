unit Unit1;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, Project1_TLB, StdVcl,
  Winpos_ole_TLB, POSBase, Unit2, SysUtils, Forms;

type
  TTSampleWPPlugIn = class(TAutoObject, ISampleWPPlugIn)
  protected
    function Connect(const app: IDispatch): Integer; safecall;
    function Disconnect: Integer; safecall;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer;
      safecall;
  end;

//var WINPOS : IWinPOS;

implementation

uses ComServ;

var ID_Run1 : Integer=0;
//var ID_Run2 : Integer=0;
var bar_ID : Integer;
var FlagFormCreated : Boolean;

function TTSampleWPPlugIn.Connect(const app: IDispatch): Integer;
var hbmp:THandle;
begin
   WINPOS:=app as IWinPOS;
   ID_Run1 := WINPOS.RegisterCommand();

   hbmp:=LoadBitmap(HInstance,'TOOLBAR');

   bar_ID:=WINPOS.CreateToolbar();
   WINPOS.CreatetoolbarButton(bar_ID,ID_Run1,hbmp,'');

// ���� ����� ��� ���� ������...
// ID_Run2:= WINPOS.RegisterCommand();
// hbmp:= LoadBitmap(HInstance,'TOOLBAR2');
// WINPOS.CreatetoolbarButton(bar_ID,ID_Run2,hbmp,'');

   FlagFormCreated:= false;
   Result:=0;
end;

function TTSampleWPPlugIn.Disconnect: Integer;
begin
  Result:=0;
end;

var InPlugunCode : Boolean = False;

function TTSampleWPPlugIn.NotifyPlugin(what: Integer;
  var param: OleVariant): Integer;
begin
  Result:= 0;
  inPlugunCode:= true;
  try
    try
      // ����� �� ������� ������������ case, �.�. ID_Run1 - ����������, � �� ���������
      if HiWord(what)=ID_Run1 // ����� LoWord(what)=2 - "2" ������������� ������� ������ �������
      then
      begin
        if not FlagFormCreated then
          Application.CreateForm(TForm1, Form1);
        FlagFormCreated:=true;
        Form1.Show;
      end;
      Result:=0;
    finally
      InPlugunCode:= False;
    end
  except
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TTSampleWPPlugIn, Class_TSampleWPPlugIn,
    ciMultiInstance, tmApartment);
end.
