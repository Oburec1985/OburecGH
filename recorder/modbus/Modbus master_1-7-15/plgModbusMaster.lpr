library plgModbusMaster;

{$mode ObjFPC}{$H+}{$codepage UTF8}
uses

  Classes, sysutils, LazUTF8, interfaces, Forms, blaccess, journal, signal,
  tags, transf, recorder, modules, plugin, waitwnd, transformers, device,
  pluginclass, uFrmSimple, ufrm_adr, ufrm_comport, ufrm_device,
  ufrm_value, ufrm_protocol, uFrmAbout, dlgConfSelect, DefaultTranslator,
  ResStr, ulogger, UProtManager, uUpdatable;

Const
{ DllEntryPoint }
DLL_PROCESS_ATTACH = 1;
DLL_THREAD_ATTACH = 2;
DLL_PROCESS_DETACH = 0;
DLL_THREAD_DETACH = 3;

//{$R *.res}


var
   GPluginInstance: IRecorderPlugin = nil;

{----------------------Процедура - точка входа в dll---------------------------}
{Вызывается при загрузке и выгрузке dll}
procedure DllEntryPoint(Reason: integer);
begin
 //SetHeapTraceOutput('C:\lazproj\Modbus master\heaptrace.log');
 case Reason of{Ветвление по коду причины вызова}
   DLL_PROCESS_ATTACH:begin
      {Создание одного глобального экземпляра plug-in`а}
     Application.Initialize;
   end;
   DLL_PROCESS_DETACH: begin

   end;
   DLL_THREAD_ATTACH: begin

   end;
   DLL_THREAD_DETACH:
   end;
end;

{------------------------------Экспортируемые функции--------------------------}
{Ниже описаны и реализованы пять функций, которые должна экспортировать}
{библиотека plug-in`а для Recorder`а}

{Получение типа объекта, реализованного в билиотеке}
function GetPluginType: integer; cdecl;
begin
  Result:= PLUGIN_CLASS; {В данном случае, это тип объекта plug-in`а}
end;

{Функция создания экземпляра plug-in`а.}
{Функция объявлена таким образом, как будто она возвращает не интерфейс,
а указатель. Причина такого объявления обоснована в документе описания.}
function CreatePluginClass: pointer{IRecorderPlugin}; cdecl;
begin
{Создание одного глобального экземпляра plug-in`а}
  GPluginInstance := TTestPlugin.Create;
  GPluginInstance._AddRef;
  result := pointer(GPluginInstance);
end;

{Функция удаления plug-in`а.}
function DestroyPluginClass(piPlg: IRecorderPlugin): integer; cdecl;
begin
   {Так как объект один и глобальный, то он здесь не удаляется.}
   {Объект plug-in`а удаляет себя сам (как любой COM объект),
    если счетчик ссылок его интерфейсов станет равен нулю.}

   GPluginInstance._release;
   GPluginInstance := NIL;
   //DumpHeap;
   Result := RCERROR_NOERROR;
end;

{Функция получения строки описания plug-in`а}
function GetPluginDescription: PChar; cdecl;
begin
   {Описание извлекается из глобальной описательной структуры}
   Result := PCHAR(GPluginInfo.Dsc);
end;

{Функция получения полного описания plug-in`а}
procedure GetPluginInfo(var lpPluginInfo: PLUGININFO); cdecl;
var
   s1, s2, s3: AnsiString;
begin
   {Описание извлекается из глобальной описательной структуры}
   {Копирование строк производится именно функциями StrCopy()
    из-за того, что структура описания plug-in`а описана
    в языке C++}

      s1 := UTF8ToWinCP(GPluginInfo.Name);
      s2 := UTF8ToWinCP(GPluginInfo.Dsc);
      s3 := UTF8ToWinCP(GPluginInfo.Vendor);

      move(s1[1], lpPluginInfo.name[0], length(s1));
      move(s2[1], lpPluginInfo.describe[0], length(s2));
      move(s3[1], lpPluginInfo.Vendor[0], length(s3));

      //setlength(lpPluginInfo.name, length(GPluginInfo.Name));
      //setlength(lpPluginInfo.describe, length(GPluginInfo.Dsc));
      //setlength(lpPluginInfo.vendor, length(GPluginInfo.vendor));

 { {Глобальная переменная для храения описания plug-in`а.}
   GPluginInfo: TInternalPluginInfo = (
      Name:   'Плагин Modbus Master';
      Dsc:    'Реализация протокола Modbus Master (RTU и TCP)';
      Vendor: 'Скрипник Александр';
      Version:    1;
      SubVertion: 6;
   ); }

      {lpPluginInfo.name := UTF8ToWinCP('Плагин Modbus Master');
      lpPluginInfo.describe := UTF8ToWinCP('Реализация протокола Modbus Master (RTU и TCP)');
      lpPluginInfo.Vendor := UTF8ToWinCP('Скрипник Александр');}

      //lpPluginInfo.name := PAnsiChar(GPluginInfo.Name);
      //lpPluginInfo.describe := PAnsiChar(GPluginInfo.Dsc);
      //lpPluginInfo.Vendor := PAnsiChar(GPluginInfo.Vendor);

      {s1 := UTF8ToWinCP(GPluginInfo.Name);
      s2 := UTF8ToWinCP(GPluginInfo.Dsc);
      s3 := UTF8ToWinCP(GPluginInfo.vendor);

      move(s1[1], lpPluginInfo.name[0], length(s1));
      move(s2[1], lpPluginInfo.describe[0], length(s2));
      move(s3[1], lpPluginInfo.Vendor[0], length(s3)); }

      lpPluginInfo.version :=    GPluginInfo.Version;
      lpPluginInfo.subversion := GPluginInfo.SubVertion;
end;

{---------------------Объявление экспортируемых процедур----------------------}
{Объявление строковых имен экспортируемых функций}
exports GetPluginType        name 'GetPluginType';
exports CreatePluginClass    name 'CreatePluginClass';
exports DestroyPluginClass   name 'DestroyPluginClass';
exports GetPluginDescription name 'GetPluginDescription';
exports GetPluginInfo        name 'GetPluginInfo';

//{$R *.res}

{$R *.res}

begin
 {Подстановка своей функции DllEntryPoint, таким образом}
 {через функцию DllEntryPoint появляется возможность
 обрабатывать сообщения о выгрузке библиотеки}
 //if not Assigned(DLLProc) then
 //   DLLProc := @DllEntryPoint;
 DllEntryPoint(DLL_PROCESS_ATTACH);
end.

