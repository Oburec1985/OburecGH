unit iplgmngr;

interface
uses Windows, tags, modules, device, ActiveX, plugin, recorder;

const
  IID_IPluginsControl: TGUID = (
     // EC4193D5    -09D2-    4741-     82  23- 1A  8D  C5  D8  1E  A7
    D1:$EC4193D5;D2:$09D2;D3:$4741;D4:($82,$23,$1A,$8D,$C5,$D8,$1E,$A7));

type

PLUGINCONTEXT = record
	create_:boolean;
	config_:boolean;
	execute_:boolean;
	hdll_:HMODULE;
	configstate_:Longint;
	name_:lpcstr;
end;

IPluginsControl = interface
['{EC4193D5-09D2-4741-8223-1A8DC5D81EA7}']
	//Получить число подключенных плагинов
	function GetPluginsCount():Longint;stdcall;
	//Получить ссылку на подключенный плагин по индексу
	//virtual IRecorderPlugin* STDMETHODCALLTYPE GetPlugin(ULONG a_nIndex) = 0;
  function GetPlugin(a_nIndex:Longint):pointer;stdcall;
	//Получить число автозагружаемых плагинов
	//virtual ULONG STDMETHODCALLTYPE GetAutoLoadPluginsCount() = 0;
  function GetAutoLoadPluginsCount():Longint;stdcall;
	//Получить имя автозагружаемого плагина
	//virtual HRESULT STDMETHODCALLTYPE GetAutoLoadPluginLibrary(ULONG a_nIndex, CHAR* a_pchLibrary) = 0;
  function GetAutoLoadPluginLibrary(a_nIndex:longint; a_pchLibrary:pchar):HRESULT;stdcall;
	//Добавить плагин в автозагрузку
	//virtual HRESULT          STDMETHODCALLTYPE AddPluginToAutoLoad(const char* a_pchLibrary) = 0;
  function AddPluginToAutoLoad(const a_pchLibrary:pchar):HRESULT;stdcall;
	//Убрать плагин из автозагрузки
	//virtual HRESULT          STDMETHODCALLTYPE RemovePluginFromAutoLoad(const char* a_pchLibrary) = 0;
  function RemovePluginFromAutoLoad(const a_pchLibrary:pchar):HRESULT;stdcall;
	//Запросить информацию о библиотеке плагина
	//virtual HRESULT STDMETHODCALLTYPE RequestLibraryInfo(const char* a_pchLibrary, LPPLUGININFO a_pPluginInfo) = 0;
  function RequestLibraryInfo(const a_pchLibrary:pchar; a_pPluginInfo:LPPLUGININFO):HRESULT;stdcall;


	//virtual HRESULT STDMETHODCALLTYPE CreatePlugin(const char* a_pchPluginPath,IRecorder* m_pOwner) = 0;
  function CreatePlugin(const a_pchPluginPath:pchar;m_pOwner:IRecorder):HRESULT;stdcall;
	//virtual HRESULT STDMETHODCALLTYPE ConfigPlugin(IRecorderPlugin* a_piPlugin) = 0;
  function ConfigPlugin(a_piPlugin:IRecorderPlugin):HRESULT;stdcall;
	//virtual HRESULT STDMETHODCALLTYPE ExecutePlugin(IRecorderPlugin* a_piPlugin) = 0;
  function ExecutePlugin(a_piPlugin:IRecorderPlugin):HRESULT;stdcall;
	//virtual HRESULT STDMETHODCALLTYPE ClosePlugin(IRecorderPlugin* a_piPlugin) = 0;
  function ClosePlugin(a_piPlugin:IRecorderPlugin):HRESULT;stdcall;

	//virtual ULONG   STDMETHODCALLTYPE GetCount() = 0;
  function GetCount(a_piPlugin:IRecorderPlugin):longint;stdcall;
	//virtual IRecorderPlugin* STDMETHODCALLTYPE GetAt(ULONG a_nIndex) = 0;
  function GetAt(a_nIndex:longint):IRecorderPlugin;stdcall;
end;

implementation

end.
