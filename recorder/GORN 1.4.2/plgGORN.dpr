library plgGORN;

uses
  Windows,
  Themes,
  SysUtils,
  Classes,
  PluginClass in '..\SharedRUnits\PluginClass.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  uCompMng in '..\SharedRUnits\uCompMng.pas',
  uRecBasicFactory in '..\SharedRUnits\uRecBasicFactory.pas',
  uMainFrm in 'forms\uMainFrm.pas' { MainFrm },
  uRecorderEvents in '..\SharedRUnits\uRecorderEvents.pas',
  uFrmSync in '..\SharedRUnits\uFrmSync.pas' { FrmSync },
  uCreateComponents in 'units\uCreateComponents.pas',
  uCreateNotifyProcess in 'units\uCreateNotifyProcess.pas',
  DevAPI in '..\SharedRUnits\interfaces\DevAPI.pas',
  device in '..\SharedRUnits\interfaces\device.pas',
  journal in '..\SharedRUnits\interfaces\journal.pas',
  modules in '..\SharedRUnits\interfaces\modules.pas',
  plugin in '..\SharedRUnits\interfaces\plugin.pas',
  rcPlugin in '..\SharedRUnits\interfaces\rcPlugin.pas',
  recorder in '..\SharedRUnits\interfaces\recorder.pas',
  signal in '..\SharedRUnits\interfaces\signal.pas',
  tags in '..\SharedRUnits\interfaces\tags.pas',
  scales in '..\SharedRUnits\interfaces\scales.pas',
  uAlarms in '..\SharedRUnits\interfaces\uAlarms.pas',
  uRCFunc in '..\SharedRUnits\uRCFunc.pas',
  uMyErrorMessages in '..\SharedRUnits\Sergey\uMyErrorMessages.pas',
  uMyRecorderUtils in '..\SharedRUnits\Sergey\uMyRecorderUtils.pas',
  uSettingsFrm in 'forms\uSettingsFrm.pas' {SettingsFrm},
  uSelectChannelFrm in '..\SharedRUnits\Sergey\uSelectChannelFrm.pas' {SelectChannelFrm},
  upidreg in 'units\upidreg.pas',
  TimerThread in 'units\TimerThread.pas',
  PerformanceTime in '..\..\sharedUtils\utils\PerformanceTime.pas';

{$R toolbarExtPack.res}
{$R *.res}

{ -----------------------------------------------Процедура - точка входа в dll }
{ Вызывается при загрузке и выгрузке dll }
procedure DllEntryPoint(Reason: integer);
begin
  case Reason of { Ветвление по коду причины вызова }
    DLL_PROCESS_ATTACH:
    begin

    end;
    DLL_PROCESS_DETACH:
    begin
      // удаление делфевых глобальных классов управления темами форм
      ThemeServices.Free;
    end;
    DLL_THREAD_ATTACH:
    begin

    end;
    DLL_THREAD_DETACH:
    begin

    end;
  end;
end;


// ----------------------------Экспортируемые функции}
// {Ниже описаны и реализованы пять функций, которые должна экспортировать}
// библиотека plug-in`а для Recorder`а}

// Получение типа объекта, реализованного в билиотеке}
function GetPluginType: integer; cdecl;
begin
  Result := PLUGIN_CLASS; { В данном случае, это тип объекта plug-in`а }
end;

// Функция создания экземпляра plug-in`а.
// Функция объявлена таким образом, как будто она возвращает не интерфейс,
// а указатель. Причина такого объявления обоснована в документе описания.
function CreatePluginClass: pointer { IRecorderPlugin } ; cdecl;
begin
  GPluginInstance := TExtRecorderPack.Create;
  // Создание одного глобального экземпляра plug-in`а}
  Result := pointer(GPluginInstance);
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // При возврате плагина как поинтера DELPHI не вызывает приращение ссылки!!!!!
  GPluginInstance._AddRef;
end;

{ Функция удаления plug-in`а. }
function DestroyPluginClass(piPlg: IRecorderPlugin): integer; cdecl;
begin
  // Так как объект один и глобальный, то он здесь не удаляется.
  // Объект plug-in`а удаляет себя сам (как любой COM объект),
  // если счетчик ссылок его интерфейсов станет равен нулю.
  Result := RCERROR_NOERROR;
  TExtRecorderPack(GPluginInstance).destroyForms;
  GPluginInstance._release;
  GPluginInstance := NIL;
end;

{ Функция получения строки описания plug-in`а }
function GetPluginDescription: LPCSTR; cdecl;
begin
  // Описание извлекается из глобальной описательной структуры}
  Result := LPCSTR(GPluginInfo.Dsc);
  // Result := LPCSTR('Модуль для теста (пустой)');
end;

{ Функция получения полного описания plug-in`а }
procedure GetPluginInfo(var lpPluginInfo: PLUGININFO); cdecl;
begin
  // Описание извлекается из глобальной описательной структуры
  // Копирование строк производится именно функциями StrCopy()
  // из-за того, что структура описания plug-in`а описана
  // в языке C++}
  StrCopy(@lpPluginInfo.name, LPCSTR(GPluginInfo.Name));
  StrCopy(@lpPluginInfo.describe, LPCSTR(GPluginInfo.Dsc));
  StrCopy(@lpPluginInfo.vendor, LPCSTR(GPluginInfo.vendor));
  lpPluginInfo.version := GPluginInfo.version;
  lpPluginInfo.subversion := GPluginInfo.SubVertion;
end;

{ ---------------------Объявление экспортируемых процедур---------------------- }
{ Объявление строковых имен экспортируемых функций }
exports GetPluginType name 'GetPluginType';

exports CreatePluginClass name 'CreatePluginClass';

exports DestroyPluginClass name 'DestroyPluginClass';

exports GetPluginDescription name 'GetPluginDescription';

exports GetPluginInfo name 'GetPluginInfo';

begin
  // Подстановка своей функции DllEntryPoint, таким образом
  // через функцию DllEntryPoint появляется возможность
  // обрабатывать сообщения о выгрузке библиотеки
  if not Assigned(DLLProc) then
    DLLProc := @DllEntryPoint;
  DllEntryPoint(DLL_PROCESS_ATTACH);

end.
