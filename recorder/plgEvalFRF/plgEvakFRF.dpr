library plgEvakFRF;

uses
  Windows,
  Themes,
  SysUtils,
  Classes,
  uLogFile in '..\..\sharedUtils\utils\uLogFile.pas',
  usetlist in '..\..\sharedUtils\utils\lists\usetlist.pas',
  uComponentServises in '..\..\sharedUtils\utils\uComponentServises.pas',
  uListMath in '..\..\sharedUtils\math\uListMath.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  uGlTurbine in '..\..\3d\3dComponents\components\Asutp\uGlTurbine.pas',
  uTrfrmToolsFrame in '..\..\3d\forms\uTrfrmToolsFrame.pas' {TrfrmToolsFrame: TFrame},
  uObjCtrFrame in '..\..\3d\forms\uObjCtrFrame.pas' {CtrlViewFrame: TFrame},
  uMatrix in '..\..\sharedUtils\math\uMatrix.pas',
  uCompMng in '..\SharedRUnits\uCompMng.pas',
  uRecBasicFactory in '..\SharedRUnits\uRecBasicFactory.pas',
  uRecorderEvents in '..\SharedRUnits\uRecorderEvents.pas',
  uCreateComponents in 'units\uCreateComponents.pas',
  blaccess in '..\SharedRUnits\interfaces\blaccess.pas',
  CFREG in '..\SharedRUnits\interfaces\CFREG.PAS',
  DevAPI in '..\SharedRUnits\interfaces\DevAPI.pas',
  device in '..\SharedRUnits\interfaces\device.pas',
  journal in '..\SharedRUnits\interfaces\journal.pas',
  modules in '..\SharedRUnits\interfaces\modules.pas',
  plugin in '..\SharedRUnits\interfaces\plugin.pas',
  rcPlugin in '..\SharedRUnits\interfaces\rcPlugin.pas',
  recorder in '..\SharedRUnits\interfaces\recorder.pas',
  signal in '..\SharedRUnits\interfaces\signal.pas',
  tags in '..\SharedRUnits\interfaces\tags.pas',
  transf in '..\SharedRUnits\interfaces\transf.pas',
  transformers in '..\SharedRUnits\interfaces\transformers.pas',
  waitwnd in '..\SharedRUnits\interfaces\waitwnd.pas',
  uEditEvalFRFFrm in 'forms\uEditEvalFRFFrm.pas' {EditFrfFrm},
  uEvalFRFFrm in 'forms\uEvalFRFFrm.pas' {FRFFrm},
  PluginClass in '..\SharedRUnits\PluginClass.pas',
  uFrmSync in '..\SharedRUnits\uFrmSync.pas' {FrmSync},
  uSpmProfile in 'forms\uSpmProfile.pas' {SpmProfileFrm},
  uEditTest in 'forms\uEditTest.pas' {EditTestFrm};

//rcPlugin in 'interfaces\rcPlugin.pas';

{$R toolbarExtPack.res}

{-----------------------------------------------Процедура - точка входа в dll}
{Вызывается при загрузке и выгрузке dll}
procedure DllEntryPoint(Reason: integer);
begin
  case Reason of{Ветвление по коду причины вызова}
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


//----------------------------Экспортируемые функции}
//{Ниже описаны и реализованы пять функций, которые должна экспортировать}
//библиотека plug-in`а для Recorder`а}

//Получение типа объекта, реализованного в билиотеке}
function GetPluginType: integer; cdecl;
begin
  Result:= PLUGIN_CLASS; {В данном случае, это тип объекта plug-in`а}
end;
//Функция создания экземпляра plug-in`а.
//Функция объявлена таким образом, как будто она возвращает не интерфейс,
//а указатель. Причина такого объявления обоснована в документе описания.
function CreatePluginClass: pointer{IRecorderPlugin}; cdecl;
begin
  GPluginInstance := TExtRecorderPack.Create;
  //Создание одного глобального экземпляра plug-in`а}
  result := pointer(GPluginInstance);
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // При возврате плагина как поинтера DELPHI не вызывает приращение ссылки!!!!!
  GPluginInstance._AddRef;
end;

{Функция удаления plug-in`а.}
function DestroyPluginClass(piPlg: IRecorderPlugin): integer; cdecl;
begin
  //Так как объект один и глобальный, то он здесь не удаляется.
  //Объект plug-in`а удаляет себя сам (как любой COM объект),
  //если счетчик ссылок его интерфейсов станет равен нулю.
  Result := RCERROR_NOERROR;
  TExtRecorderPack(piPlg).destroyForms;
  GPluginInstance:=NIL;
  piPlg._release;
end;

{Функция получения строки описания plug-in`а}
function GetPluginDescription: LPCSTR; cdecl;
var
  I: Integer;
begin
  for I := 0 to length(GPluginInfo.Dsc)-1 do
  begin
    GPlgDSC[i]:=GPluginInfo.Dsc[i+1];
  end;
  Result := LPCSTR(@GPlgDSC[0]);
end;

{Функция получения полного описания plug-in`а}
procedure GetPluginInfo(var lpPluginInfo: PLUGININFO); cdecl;
var
  lName, lDst, lVend:array of ansichar;
  i:integer;
begin
  //Описание извлекается из глобальной описательной структуры
  //Копирование строк производится именно функциями StrCopy()
  // из-за того, что структура описания plug-in`а описана
  // в языке C++}
  setlength(lname, length(GPluginInfo.Name)+1);
  setlength(lDst, length(GPluginInfo.Dsc)+1);
  setlength(lVend, length(GPluginInfo.Vendor)+1);
  for I := 0 to length(GPluginInfo.Name)-1 do
  begin
    lname[i]:=GPluginInfo.Name[i+1];
  end;
  for I := 0 to length(GPluginInfo.Dsc)-1 do
  begin
    lDst[i]:=GPluginInfo.Dsc[i+1];
  end;
  for I := 0 to length(GPluginInfo.Vendor)-1 do
  begin
    lVend[i]:=GPluginInfo.Vendor[i+1];
  end;
  lname[length(lname)-1]:=ansichar(0);
  lDst[length(lDst)-1]:=ansichar(0);
  lVend[length(lVend)-1]:=ansichar(0);

  StrCopy( @lpPluginInfo.name,lpcstr(@lname[0]));
  StrCopy( @lpPluginInfo.describe,lpcstr(@lDst[0]));
  StrCopy( @lpPluginInfo.vendor,lpcstr(@lVend[0]));

  //StrCopy( @lpPluginInfo.name,LPCSTR(GPluginInfo.Name));
  //StrCopy( @lpPluginInfo.describe,LPCSTR(GPluginInfo.Dsc));
  //StrCopy( @lpPluginInfo.vendor,LPCSTR(GPluginInfo.Vendor));
  lpPluginInfo.version := GPluginInfo.Version;
  lpPluginInfo.subversion := GPluginInfo.SubVertion;
end;

{---------------------Объявление экспортируемых процедур----------------------}
{Объявление строковых имен экспортируемых функций}
exports GetPluginType        name 'GetPluginType';
exports CreatePluginClass    name 'CreatePluginClass';
exports DestroyPluginClass   name 'DestroyPluginClass';
exports GetPluginDescription name 'GetPluginDescription';
exports GetPluginInfo        name 'GetPluginInfo';

begin
 //Подстановка своей функции DllEntryPoint, таким образом
 //через функцию DllEntryPoint появляется возможность
 //обрабатывать сообщения о выгрузке библиотеки
  if not Assigned(DLLProc) then
    DLLProc:= @DllEntryPoint;
  DllEntryPoint(DLL_PROCESS_ATTACH);

end.
