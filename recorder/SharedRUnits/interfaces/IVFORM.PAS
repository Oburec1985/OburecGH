unit IVFORM;

interface
uses
  Windows,
  Wintypes,
  WinProcs,
  rcPlugin;

//type
// {95001263-E83C-11d6-9243-00E029288A7F}
//extern GUID IID_IVForm;


//Нотификации формуляров и сервера визуализации
// Visualization server notifications
const
	// Общие нотификации с плагинами
	VSN_ENTERRCCONFIG = PN_ENTERRCCONFIG; // Рекордер перешел в режим настройки 1
	VSN_LEAVERCCONFIG = PN_LEAVERCCONFIG;             // Рекордер вышел из режима настройки 2
	VSN_CHANGECURTAG  = PN_CHANGECURTAG;              // Сменился текущий тег, data=ITag* 3

	VSN_RCSAVECONFIG  = PN_RCSAVECONFIG;              // Рекордер сохранил конфигурацию
	VSN_RCLOADCONFIG  = PN_RCLOADCONFIG;              // Рекордер загрузил конфигурацию

	VSN_RCSTART       = PN_RCSTART;                   // Рекордер перешел в режим получения/вычитки данных
	VSN_RCPLAY        = PN_RCPLAY;                    // Рекордер перешел в режим воспроизведения данных
	VSN_RCSTOP        = PN_RCSTOP;                    // Рекордер остановлен
	VSN_BEFORE_RCSTART= PN_BEFORE_RCSTART;            // Рекордер переходит в режим получения/вычитки данных
	VSN_BEFORE_RCSTOP = PN_BEFORE_RCSTOP ;            // Рекордер останавливается
	VSN_ABORT_RCSTART = PN_ABORT_RCSTART;             // Опереция старта была прервана
	VSN_UPDATE_DATA		= PN_UPDATEDATA;		            // Обновление данных в rc

	// Индивидуальные нотификации
	VSN_SPECIFIED=$4000;       //
	//VSN_RESIZE;                 // Изменить размер окна формуляра
	//VSN_CHANGEVIEWTIME;         // Смена интервала отображения
	//VSN_CHANGETIMESHIFT;        // Смена смещения интервала отображения
	//VSN_CHANGERCSTATE;          // Изменилось состояние Recorder в dwData новое состояния
	//VSN_SET_PARENT;             // Установить нового парента (dwData)
	//VSN_QUERY_ALARMS_STATE;     // Запросить состояние уставок
	//VSN_QUERY_ALARMS_COLOR;     // Запросить цвет текущей уставки
	//VSN_GET_TRANSPARENT;        // Запросить флаг прозрачности
	//VSN_ON_CHANGE_TAGS_FILTER;  // Изменился фильтр фаналов
	//VSN_ON_DBLCLK_TAGS_LIST;    // Дабл клик на списке тегов в режиме просмотра
	//VSN_ON_ADD_SELECTED_TAGS;		// Команда на добавление выделенных тегов, генерится по ДнД из списка каналов
	//VSN_QUERY_DROP_ACCEPT;			// Форма принимает DnD каналы
	//VSN_USER=0x7000;             // Юзерские нотификации VFN_USER+XXXX

/// Идентификатор сообщения об изменении размера компонента
/// отпавляется родителю окна<br>
/// wParam ссылка на IVForm компонента<br>
/// lParam новые размеры компонента<br>
///  Для формирования lParam можно использовать функции MAKELPARAM(x,y)<br>
/// Для получения числового значения сообщения используется функция
/// RegisterWindowMessage
//#define ID_WM_ON_CHANGE_CHILD_SIZE "Mera.Recorder.IVForm.WM_ON_CHANGE_CHILD_SIZE"
type
   //Интерфейс для управления специализированными формулярами отображения
   IVForm = interface
   ['{95001263-E83C-11d6-9243-00E029288A7F}']
      //Получить имя формы должно быть уникальным, используется при регистрации
      function GetName: LPCSTR; stdcall;
      //Инициализация формы
      function Init(pParent: IRecorder; hParent: HWND; lParam: longint): boolean; stdcall;
      //Получить HWND формы
      function GetHWnd: HWND; stdcall;
      //Вызывается при закрытии формы
      function Close: boolean; stdcall;
      function Prepare: boolean; stdcall;
      function Update: boolean; stdcall;
      //Перерисовка формы
      function Repaint: boolean; stdcall;
      //Привязка к тегам рекордера
      function LinkTags( var pTagsList: TagsArray;
                         var nTagsCount: ULONG): boolean; stdcall;
      //Активизация формы
      function Activate: boolean; stdcall;
      //Деактивизация формы
      function Deactivate: boolean; stdcall;
      //Вызов окна редактирования
      function Edit: boolean; stdcall;
      //События, уведомления, команды
      function Notify(const dwCommand: DWORD; const dwData: DWORD): boolean; stdcall;
   end;

implementation

end.
