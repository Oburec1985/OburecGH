unit uOperPack;
{$WARN SYMBOL_PLATFORM OFF}
// в свойствах проекта для дебуга включить опции Delphi Compiler/linking/
// Debug info ,include remote debug , map files,

interface

uses
  Windows, ActiveX, Classes, ComObj, StdVcl,
  Winpos_ole_TLB, POSBase, SysUtils, Forms, WpOperPlg_TLB,
  dialogs,
  variants,
  Messages,
  uIRGraphFrm,
  inifiles;

type
  TOperPack = class(TAutoObject, IWPPlugin)
  protected
    // хендл главного окна
    mainwnd: cardinal;

    tagproc: function(p_tag: integer): integer;
    stdcall;
  public
    init: boolean;
    // используется для клавиатурного хука
    m_showlegend: boolean;
  public
    function Connect(const app: IDispatch): integer; safecall;
    function Disconnect: integer; safecall;
    function NotifyPlugin(what: cardinal; var param: OleVariant): integer;
      safecall;
  end;

var
  g_startDir: string;
  OperPack: TOperPack;

const
  e_OnAddSRC = $00002000;

implementation

uses ComServ;

const
  c_2pi = 2*3.141592653;
  c_wpextpack_tag = 10001;
  vbEmpty = 0;
  vbNull = 1;
  vbInteger = 2;
  vbLong = 3;
  vbSingle = 4;
  vbDouble = 5;
  vbCurrency = 6;
  vbDate = 7;
  vbString = 8;
  vbObject = 9;
  vbError = 10;
  vbBoolean = 11;
  vbVariant = 12;
  vbDataObject = 13;
  vbDecimal = 14;
  vbByte = 17;
  vbArray = 8192;
  DllName = 'SniffDll.dll';

var
  c_vers: string = 'Скомпилирован 06.09.17';

var
  // указатель на тулбар винпоса
  bar_ID: cardinal;
  // Событие загрузки файла ((5 shl 16) or 1)
  // 327681 - событие вызывается при загрузке файла
  // $000f0001 событие вызова алгоритма. в событие передается
  ID_RunPlg: cardinal = 1;

function CreateSinusSig(p_amplitude: double; p_SampleFreq:double;
        p_Freq:double;
         len: integer;path: string): integer;
var
  y : Double;
  i : integer;
  signal: IWPSignal;
begin
    with WINPOS do
    begin;
      signal:= CreateSignal(VT_R8) as IWPSignal;

      if Assigned(signal) then // если сигнал создан
        Link(path, 'sinus', signal as IDispatch);
        Refresh();
        signal.deltaX:=1/p_SampleFreq;
        signal.size:= len; // зададим длину сигнала
        for i:= 0 to len-1 do // занесем данные
        begin
          y:= (p_amplitude)*sin(i*c_2pi/p_SampleFreq); // вычисляем очередное значение
          signal.SetY(i, y); // помещаем его в сигнал
        end;
        showmessage('signal created at '+path);
    end;

end;




function TOperPack.Connect(const app: IDispatch): integer;
var
  hbmp: cardinal;
  date: tdatetime;
  str: string;
begin
  g_startDir := extractfiledir(Application.ExeName) + '\plugins\OperPack\';
  init := false;
  WINPOS := app as IWinPOS;

  // создаем вкладку для кнопок плагина
  bar_ID := WINPOS.CreateToolbar();
  ID_RunPlg := WINPOS.RegisterCommand();
  // hinstans - глобальная переменная которая является идентификатором приложения
  hbmp := LoadBitmap(HInstance, 'IRDIAG');

  date := now;
  c_vers := 'Скомпилирован ' + datetostr(now);
  str := c_vers;

  WINPOS.CreatetoolbarButton(bar_ID, ID_RunPlg, hbmp, 'Диаграмма Найквиста' + str);


end;

function TOperPack.Disconnect: integer;
begin
  Result := 0;
end;


function TOperPack.NotifyPlugin(what: cardinal; var param: OleVariant): integer;
var
  InPlugunCode:boolean;
  alg, src: string;
  strList: tstringlist;

  pvar: array of variant;
  hgraph, haxis, hline: integer;
  isig: iwpsignal;
  hword: cardinal;
begin
  Result := 0;
  hword:=HIWORD(what);
  if HIWORD(what) = ID_RunPlg then
  begin
    if IRGraphFrm=nil then
    begin
      //IRGraphFrm:=TIRGraphFrm.CreateNew(nil);
      IRGraphFrm:=TIRGraphFrm.Create(nil);
    end;
    //'CreateSinusSig(20,10000,100,10000,'/Signals/test_generator');
    IRGraphFrm.ShowModal();
  end;
end;


initialization

//TAutoObjectFactory.Create(ComServer, TExtPack, Class_ExtPack, ciMultiInstance,
//  tmApartment);

TAutoObjectFactory.Create(ComServer, TOperPack, Class_OperPack, ciMultiInstance,
  tmApartment);

end.
