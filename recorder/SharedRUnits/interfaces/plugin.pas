{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для COM класса plug-in`а                 }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}
unit plugin;
interface
{$ALIGN 8}
uses Windows, recorder, tags;
const
  //Константы идентификаторов типов plug-in`ов
  PLUGIN_CLASS =  0;  //объект plug-in - основной тип
  PLUGIN_HANDLE = 1;  //не используется

   //Коды идентификаторов событий для plug-in`ов
   PN_ENTERRCCONFIG =            0; // Рекордер перешел в режим настройки
   PN_LEAVERCCONFIG =            1; // Рекордер вышел из режима настройки
   PN_CHANGECURTAG =             2; // Сменился текущий тег, в параметре dwData
                                    //    номер тега, который становится выбранным.
   PN_RCSTART =                  3; // Рекордер перешел в режим получения/вычитки данных
   PN_RCPLAY =                   4; // Рекордер перешел в режим воспроизведения данных
   PN_RCSTOP =                   5; // Рекордер остановлен
   PN_UPDATEDATA =               6; // Произошло обновление данных тегов, в data количество тегов
   PN_SHOWINFO =                 7; // Показать окно информации о плагине
   PN_RCSAVECONFIG =             8; // Рекордер сохранил конфигурацию
   PN_RCLOADCONFIG =             9; // Рекордер загрузил конфигурацию
   PN_SYNCHRO_READ_DATA_BLOCK = 10; // Синхронное чтение
                                    //  RCNOTIFY rcn;
                                    //  rcn.pSender=dynamic_cast<IUnknown*>(ITAG);
                                    //  rcn.lParam=(long)a_dwPortionLen;
                                    //  rcn.pvParam=a_pdblBuffer;
   PN_EDIT_VIRTUAL_TAG_PROPS =  11; // Редактирование специфичных свойств
                                    // виртуального тега
                                    //  RCNOTIFY rcn;
                                    //  rcn.pSender=dynamic_cast<IUnknown*>(ITAG);
   PN_IMPORTSETTINGS =          12; // Импорт установок имя файла импорта
   PN_EXPORTSETTINGS =          13; // Экспорт установок имя файла экспорта
   PN_BEFORE_RCSTART =          14; // Рекордер переходит в режим получения/вычитки данных
   PN_BEFORE_RCSTOP =           15; // Рекордер останавливается
   PN_ABORT_RCSTART =           16; // Опереция старта была прервана
   PN_BROADCAST =               17; // Передача широковещательного сообщения
   PN_CUSTOM_BUTTON_CLICK =     18;
   PN_CUSTOM_BUTTON_QUERY_STATE = 19;
   PN_ENABLE_VTAG_SETUP_DLG =   20; // Запрос на разрешение посылки команды
    	                              // на редактирование свойств виртуального тега
	                                  // в data ссылка на IEnumUnknown со списком каналов
   PN_EDIT_MULTI_VTAG_PROPS =   21; // Аналог PN_EDIT_VIRTUAL_TAG_PROPS но для варианта 21
     	                              // RCNOTIFY rcn;
	                                  // rcn.punkParam=IEnumUnknown со списком каналов
	PN_QUERY_VTAG_INFO =          22; // Запрос информации по виртуальному каналу 22
                                    //  RCNOTIFY rcn;
                                    //  rcn.punkParam=ITag ссылка на тег по которому запрашивается
                                    //  информация
                                    //  в rcn.bstrParam плагин может положить информацию
                                    //  память выделяется по соглашениям COM
	PN_REMOVE_VTAGS =             23; // Уведомление от пользователя на удаление 23
	                                  // виртуальных каналов принадлежащих плагину
	                                  //  RCNOTIFY rcn;
	                                  //  rcn.punkParam=IEnumUnknown со списком каналов
	PN_RCINITIALIZED =            24; // Инициализация рекордера завершена, все плагины загружены
	PN_ON_CHANGE_DATAPLACEMENT =  25; // Уведомление о смене рабочего каталога и имени фрейма
	                                  // передается ссылка на DATAPLACEMENT
	PN_ON_BEFORE_FRAME_REMOVING = 26; // Уведомление перед удалнием пустого фрейма
	                                  // Если плагины что-то приготовили писать надо закрыть и удалить
	PN_ON_AFTER_FRAME_REMOVING =  27; // После удаления фрейма - если надо на это среагировать
	PN_FILE_PROCESSING_COMPLETED= 28; // Операции с фалами данных завершены
	PN_ON_DESTROY_UI_SRV =        29; // Уведомнение о закрытии сервера интерфейса пользователя
	                                  // На момент уведомления сервер еще жив, поэтому надо
	                                  // разрегистрировать формы, кнопки и др. визуальные объекты
	PN_ON_SWITCH_TO_UI_THREAD =   30; // Переключение контекста в оконный тред, чтобы плагин мог
	                                  // при необходимости создать в нем окна
	                                  // вызывается однократно при создании плагина и по запросу плагина
	PN_ON_CONFIG_MODE_COMPLETED = 31; // Режим настройки завершен все плагины, тоже завершили настройки
                                    // По этому сообщение ЗАПРЕЩАЕТСЯ входить в режим настройки
                                    // Зато можно стартовать регистрацию данных
	PN_ON_SWITCH_CALIBR_MODE =    32; // Уведомление о переключении режима калибровки
	PN_ON_RC_PROGRAMMING =        33; // Сообщение о том что Recorder готовится к режиму "Готов" плагины
	                                  // могут перепрограммировать свои механизмы и дать отбой готовности
	PN_ABORT_RC_PROGRAMMING =     34; // Опереция подготовки к режиму измерения была прервана
	PN_ON_UPDATE_SECURITY_STATE = 35; // Можно обновить статус безопасности
	                                  // Дается ссылка на текущий DWORD можно изменить
	PN_ON_UPDATE_MF_TITLE =       36; // Обновление заголовкак главного окна
	                                  // в двнных BSTR ссылка на строку с заголовком, можно подменить
	PN_ON_REC_MODE =              37; // Уведомдение о переключении в режим записиё
	PN_ON_PLAY_MODE =             38; // Уведомдение о переключении в режим воспроизведения
	PN_ON_POPUP_SETUP_DIALOG =    39; // Рекордер планирует показать окно настройки
	                                  // используя передаваемую в параметре структуру (ACTIONCTRL) можно
    	                              // отменить действие и показать например свое окно настройки
	PN_ON_POPUP_SEL_FRAME_DIALOG =40; // Рекордер планирует показать окно выбора имени замера
	                                  // используя передаваемую в параметре структуру (ACTIONCTRL) можно
    	                              // отменить действие и показать например свое окно настройки
	PN_ON_ACTION_SAVE_CFG =       41; // Рекордер планирует сохранить конфигурацию
	PN_ON_ACTION_SAVE_CFG_AS =    42; // Рекордер планирует сохранить конфигурацию
	PN_ON_ACTION_LOAD_CFG =       43; // Рекордер планирует загрузить конфигурацию
	PN_ON_CHANGE_FORMS =          44; // Смена состояния формуляров:
	                                  //  - смена текущего
	                                  //  - прикрепление/открепоение
	PN_ABORT_RCSTOP =             45; // Опереция останова измерения была прервана
	PN_ON_ACTION_CLOSE_APP =      46; // Рекордер планирует завершить работу
	PN_ON_ZBALANCE_VTAG =         47; // Команда на балансировку нуля виртуального канала
  PN_USER                 =  $7000; //Юзерские нотификации PN_USER+XXXX

   //Типы переконфигурации рекордера
   RCCT_FULLRESET =     0;
   RCCT_DEVICERESET =   1;
   RCCT_SOFTWARERESET = 2;
   RCCT_LINKSREFRESH =  3;

   //Свойства плагинов
   PLGPROP_STATUSSTRING = 0; // Строка статуса плагина. Специфическая
                             // информация для пользователя
   PLGPROP_INFOSTRING =   1; // Развернутая информация о плагине
   PLGPROP_STATE =        2; // Состояние плагина
   PLGPROP_USER =         $7000; // Юзерские свойства PLGPROP_USER+XXXX

   //Состояния плагина
   PLGSTATE_SUSPENDED = 1; // Работа плагина приостановлена извне

type
   //Описание тсруктуры для передачи данных с событием
   //PN_SYNCHRO_READ_DATA_BLOCK и событием PN_EDIT_VIRTUAL_TAG_PROPS
   tagRCNOTIFY = record
      pSender: IUnknown;    //ссылка на источник события
      nSubCommand: UINT;    //Код команды
      lParam: longint;      //резервные параметры
      dblParam: double;
      pvParam: pointer;
   end;
   RCNOTIFY = tagRCNOTIFY;
   LPRCNOTIFY = ^RCNOTIFY;

   //Структура для полного описания plug-in`а
   //Данная структура создана по аналогии со структурой в C++.
   //Массивы символов являются строками в формате C++, то есть
   //должен присутствовать завершающий строку 0.
   tagPLUGININFO = record
      name:       array [0..100] of AnsiChar;  //наименование
      describe:   array [0..200] of AnsiChar;  //описание
      vendor:     array [0..200] of AnsiChar;  //наименование фирмы разработчика
      version:    word;                    //номер версии
      subversion: word;                    //номер подверсии
   end;
   PLUGININFO = tagPLUGININFO;
   LPPLUGININFO = ^PLUGININFO;

   // Интерфейс plug-in`а к Рекордеру
   IRecorderPlugin = interface
   ['{5967D621-0C3B-11d7-9243-00E029288A7F}']
       // Создание плагина
       function _Create(pOwner: IRecorder): boolean; stdcall;
       // Конфигурирование
       function Config: boolean; stdcall;
       // Вызов окна настройки
       function Edit: boolean; stdcall;
       // Запуск
       function Execute: boolean; stdcall;
       // Приостановка работы
       function Suspend: boolean; stdcall;
       // Возобновление работы
       function Resume: boolean; stdcall;
       // Уведомление о внешних событиях
       function Notify(const dwCommand: DWORD;
                       const dwData: DWORD): boolean; stdcall;
       // Получение имени
       function Getname: LPCSTR; stdcall;
       // Получить свойство
       function GetProperty(const dwPropertyID: DWORD;
                            var Value: OleVariant): boolean; stdcall;
       // Задать свойство
       function SetProperty(const dwPropertyID: DWORD;
                            {const} Value: OleVariant): boolean; stdcall;

       // Узнать можно ли завершить работу плагина
       function CanClose: boolean; stdcall;
       // Завершить работу плагина
       function Close:  boolean; stdcall;
   end;

implementation
end.









