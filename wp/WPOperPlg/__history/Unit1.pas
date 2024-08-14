unit Unit1;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Classes, ComObj, ActiveX, Project1_TLB, Winpos_ole_TLB, StdVcl, SysUtils, Forms;

type
  Tclass1 = class(TAutoObject, IWPPlugin)
  protected
    function Connect(const app: IDispatch): Integer; safecall;
    function Disconnect: Integer; safecall;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer; safecall;

  end;

implementation

uses ComServ;
var ID_Run1 : Integer=0; // Идентификатор (код) команды
var bar_ID : Integer; // Дескриптор панели инструментов

function Tclass1.Connect(const app: IDispatch): Integer;
var hbmp:THandle;
begin
 WINPOS:=app as IWinPOS;
 ID_Run1 := WINPOS.RegisterCommand(); //Получение кода команды
 bar_ID:=WINPOS.CreateToolbar(); //Создание панели инструментов
//Загрузка изображения кнопки
 hbmp:=LoadBitmap(HInstance,'TOOLBAR');
//Создание кнопки
 WINPOS.CreatetoolbarButton( bar_ID, ID_Run1, hbmp,
 'Новое действие'#10' Новое действие');
 Result:= 0;
end;

function Tclass1.Disconnect: Integer;
begin
 Result:= 0;
end;

function Tclass1.NotifyPlugin(what: Integer; var param: OleVariant): Integer;
var cmdln : AnsiString;
begin
 try
 if HiWord(what)=ID_Run1 //Проверка кода команды
 then
 begin //Создание формы
 Application.CreateForm(TForm1, Form1);
 Form1.Show;
 end
 except
 end;
 Result:= 0;
end;

initialization
  TAutoObjectFactory.Create(ComServer, Tclass1, Class_class1,
    ciMultiInstance, tmApartment);
end.
