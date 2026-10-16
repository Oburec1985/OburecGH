unit PluginClass;

{$mode ObjFPC}{$H+}{$codepage UTF8}

{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль класса тестового plug-in`а, описание и реализация            }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}

{В данном модуле описан и реализован класс TTestPlugin тестового plug-in`а.}

interface
uses
   Forms, ucommon,
   recorder in 'interfaces\recorder.pas',
   tags in 'interfaces\tags.pas', plugin in 'interfaces\plugin.pas',
   LazUTF8, fgl, ModbusDevice, UDATag, dataaccess in 'interfaces\dataaccess.pas',
   LCLIntf, resstr;
type
   DynTagsArray = array of ITag;
   TDATagList = specialize TFPGList<TDATag>;

   TTagStartCtrl = record
   dwSize: DWORD;
   dwFlags: DWORD;
   bContinueAction: boolean;
   pObject: IUnknown;
   end;

   PTagStartCtrl = ^TTagStartCtrl;

   {Класс тестового plug-in`а. Наследует классу TInterfacedObject,
    при этом наследуется реализация IUnknown и механизм подсчета
    ссылок соответсвенно. Класс реализует интерфейс IRecorderPlugin -
    интерфейс plug-in`а. Для отображения данных класс использует
    специальную форму (поле FTestForm).}

   { TTestPlugin }

   TTestPlugin = class(TInterfacedObject, IRecorderPlugin)
   protected
      {Ссылка на форму plug-in`а. Во избежание рекурсивных ссылок
       для работы с формой используется понижающее приведение типа.
       Переменная описана как TForm, а используется везде с приведением
       типа к TSettingsForm}

      {Ссылка на интерфейс для управления Recorder`ом}
      fIRecorder: IRecorder;
      //Имя конфигурации
      fConfigName: AnsiString;
   public
      {Конструктор}
      constructor Create;
      {Деструктор}
      destructor Destroy; override;

   public    //IRecorderPlugin
      // Создание плагина
      function _Create(pOwner: IRecorder): boolean; stdcall;
      // Конфигурирование
      function Config: boolean; stdcall;
      // Вызов окна настройки
      function Edit: boolean; stdcall;
      // Запуск - активизация работы plug-in`а
      function Execute: boolean; stdcall;
      // Приостановка работы
      function Suspend: boolean; stdcall;
      // Возобновление работы
      function Resume: boolean; stdcall;
      // Уведомление о внешних событиях
      function Notify(const dwCommand: DWORD;
                    const dwData: DWORD): boolean; stdcall;
      // Получение имени
      function GetName: PChar; stdcall;
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
  private
    fDATags: TDATagList;

    function CheckBusListForReadyToStart: boolean;
    function getConfigName: AnsiString;
    procedure setConfigName(const Value: AnsiString);
    procedure LoadConfName;
    function GetRecorder: IRecorder;
    procedure TagNewData(Sender: TObject; DA: IDataAccess);

   public
      procedure UninitDataAccess;
      procedure InitDataAccess;

      {Метод запуска и останова измерения}
      function StartMeasure: boolean;

      function StopMeasure: boolean;
      property Recorder: IRecorder read GetRecorder;
      property ConfigName: AnsiString read getConfigName write setConfigName;
   protected
      {Метод получения массива ссылок на интерфейсы тегов Recorder`а}
      procedure GetDynTagsArray(var Tags: DynTagsArray);
   end;

type
   {Тип для хранения информации о plug-in`е}
   {Этот тип удобнее использовать в Delphi, чем PLUGININFO}
   TInternalPluginInfo = record
      Name:       AnsiString;  //наименование
      Dsc:        AnsiString;  //описание
      Vendor:     AnsiString;  //описание разработчика
      Version:    integer; //версия
      SubVertion: integer; //под-версия
   end;

const


  {Глобальная переменная для храения описания plug-in`а.}
   GPluginInfo: TInternalPluginInfo = (
      Name:   rsPlgName;
      Dsc:    rsPlgDescr;
      Vendor: rsVendor;
      Version:    1;
      SubVertion: 7;
   );

{В библиотеке создается всего один глобальный экземпляр plug-in`а,
    и соответсвенно есть переменная ссылка на интерфейс этого plug-in`а.
    Экземпляр plug-in`а создается по загрузке библиотеки, и должен удаляться,
    когда счетчик ссылок станет равен нулю, это должно происходить перед
    выгрузкой библиотеки (если подсчет ссылок организоан правильно).}


implementation
uses
   SysUtils, UForm_Settings, dlgNodeCopy, dlgConfSelect, uFrmAbout;

{Конструктор} {Создание формы тестового plug-in`а}
constructor TTestPlugin.Create;
begin
  inherited;
  //SetHeapTraceOutput('c:\mera files\modbus_heaptrace.log');
end;

destructor TTestPlugin.Destroy;
begin
  //IUnknown(FIRecorder)._Release;
  FreeAndNil(Form_Settings);
  FreeAndNil(FrmAbout);
  FreeAndNil(dlg_NodeCopy);
  FreeAndNil(dlg_ConfSelect);

  inherited;
end;

{Деструктор} {Удаление формы тестового plug-in`а}
{destructor TTestPlugin.Destroy;
begin
  //FreeAndNil(FSettingsForm);
  inherited;
end; }

//IRecorderPlugin
// Создание (инициализации внутренних полей) плагина
function TTestPlugin._Create(pOwner: IRecorder): boolean; stdcall;
var
  Tags: DynTagsArray;
begin
   fIRecorder := pOwner; // сохранение полученной ссылки на интерфейс Recorder`а

   // Рекордер вышел из режима настройки
   {Настройка завершена, и необходимо обновить список тегов}
   GetDynTagsArray(Tags); {получить массив тегов}
   fDATags := TDATagList.Create;
   Result:= true;       // завершено успешно
end;

// Конфигурирование
function TTestPlugin.Config: boolean; stdcall;
begin
   {тестовому plug-in`у нечего настраивать}
   Result:= true;       // завершено успешно
end;

// Вызов окна настройки
function TTestPlugin.Edit: boolean; stdcall;
begin
   Form_Settings.Show; {Тестовый plug-in имеет всего одно окно}
   Result:= true;  // завершено успешно

end;

// Запуск - активизация работы plug-in`а
function TTestPlugin.Execute: boolean; stdcall;
begin
   Result:= true; // завершено успешно
end;

function TTestPlugin.getConfigName: AnsiString;
begin
  result := fConfigName;
end;

// Приостановка работы
function TTestPlugin.Suspend: boolean; stdcall;
begin
   Result:= true; // завершено успешно
end;

// Возобновление работы
function TTestPlugin.Resume: boolean; stdcall;
begin
   Result:= true; // завершено успешно
end;

procedure TTestPlugin.setConfigName(const Value: AnsiString);
begin
  fConfigName := Value;
end;

procedure TTestPlugin.LoadConfName;
var
  Val: OleVariant;
  Ext: string;
  p: integer;
begin
  Recorder.GetProperty(RCPROP_CONFIGNAME, Val);
  fConfigName := ExtractFileName(Val);
  Ext := ExtractFileExt(fConfigName);
  p := Pos(Ext, fConfigName);
  delete(fConfigName, p, length(fConfigName) - p + 1);
end;


function TTestPlugin.CheckBusListForReadyToStart: boolean;
var
  i: integer;
begin
for i := 0 to Form_Settings.SettingsFrame.BusList.Count - 1 do
   begin
   result := not Form_Settings.SettingsFrame.BusList.Items[i].Active;
   if not result then break;
   end;
end;

// Уведомление о внешних событиях
function TTestPlugin.Notify(const dwCommand: DWORD;
              const dwData: DWORD): boolean; stdcall;
var
  Tags: DynTagsArray;
  i: integer;
  estimate: double;
  state: WORD;
  StartCtrl: PTagStartCtrl;
begin
   case dwCommand of
      PN_ENTERRCCONFIG: begin // Рекордер перешел в режим настройки
         //В то время пока производится изменение настройки,
         // теги недоступны (потому, что они могут удаляться)
          //сообщить фрме о начале изменения настройки
         if Assigned(Form_Settings) then
            PostMessage(Form_Settings.Handle, WM_PLUGIN_MSG, PN_ENTERRCCONFIG, 0);
            //Form_Settings.InConfigMode := true;
         Result:= true;
      end;

      PN_RCSAVECONFIG: begin // Рекордер сохранил конфигурацию
        //newconfname := getRConfig;
        //self.ConfigName := ExtractFileName(newconfname);
        LoadConfName;
        //frmModbusSettings.SaveSettings;
        if Assigned(Form_Settings) then
          PostMessage(Form_Settings.Handle, WM_PLUGIN_MSG, PN_RCSAVECONFIG, 0);
        //Form_Settings.SaveSettings;
        result := true;
      end;


      PN_UPDATEDATA: begin
        //Обновление данных

        //Получение изменившихся тэгов
        //По всем шинам и устройствам находим все тэги с правами доступа
        //ReadWrite и Write и имеющие отличные от собственных значения в рекордере
            Result:= true;
      end;

      PN_ON_SWITCH_TO_UI_THREAD: begin
        {Form_Settings := TForm_Settings.Create(self);
        dlg_NodeCopy := TdlgNodeCopy.Create(nil);
        dlg_NodeCopy.HandleNeeded;
        FrmAbout := TFrmAbout.Create(nil);
        FrmAbout.HandleNeeded;
        dlg_ConfSelect := Tdlg_ConfSelect.Create(nil);
        dlg_ConfSelect.HandleNeeded;}

        Result:= true;
      end;



      PN_ON_DESTROY_UI_SRV: begin
    {  PostMessage(Form_Settings.Handle, WM_DESTROY, 0, 0);
      PostMessage(FrmAbout.Handle, WM_DESTROY, 0, 0);
      PostMessage(dlgNodeCopy.Handle, WM_DESTROY, 0, 0);
      PostMessage(dlg_ConfSelect.Handle, WM_DESTROY, 0, 0);  }

        //разрушение перенесено в деструктор плагина
        {FreeAndNil(Form_Settings);
        FreeAndNil(FrmAbout);
        FreeAndNil(dlg_NodeCopy);
        FreeAndNil(dlg_ConfSelect);}
        result := true;
      end;

      PN_ON_ACTION_CLOSE_APP: begin
        {FreeAndNil(Form_Settings);
        FreeAndNil(FrmAbout);
        FreeAndNil(dlg_NodeCopy);
        FreeAndNil(dlg_ConfSelect);
        result := true;}
      end;

      PN_LEAVERCCONFIG: begin
         LoadConfName;
         if Assigned(Form_Settings) then
          PostMessage(form_settings.Handle, WM_PLUGIN_MSG, PN_LEAVERCCONFIG, 0);
         //Form_Settings.InConfigMode := false;
      // Рекордер вышел из режима настройки
         //Настройка завершена, и необходимо обновить список тегов
         GetDynTagsArray(Tags); //получить массив тегов
         //Оповестить форму о завершении изменения конфигурации и
         //передать ей новый список ссылок на интерфейсы тегов
         Result:= true;
      end;

      PN_RCLOADCONFIG: begin // Рекордер загрузил конфигурацию
        Form_Settings := TForm_Settings.Create(self);
        dlg_NodeCopy := TdlgNodeCopy.Create(nil);
        dlg_NodeCopy.HandleNeeded;
        FrmAbout := TFrmAbout.Create(nil);
        FrmAbout.HandleNeeded;
        dlg_ConfSelect := Tdlg_ConfSelect.Create(nil);
        dlg_ConfSelect.HandleNeeded;

         LoadConfName;
         //frmModbusSettings.LoadSettings;
         if Assigned(Form_Settings) then
          PostMessage(form_settings.Handle, WM_PLUGIN_MSG, PN_RCLOADCONFIG, 0);
         //form_settings.LoadSettings;
         Result:= true;
      end;

       PN_RCSTOP: begin
         //frmModbusSettings.Started := false;
         if Assigned(Form_Settings) and (Form_Settings.Started) then
            PostMessage(form_settings.Handle, WM_PLUGIN_MSG, PN_RCSTOP, 0);
         //form_settings.Started := false;
         //UnInitDataAccess; //Возможно проблема
         Result:= true;
      end;

      PN_RCSTART: begin
         if Assigned(Form_Settings) and (not Form_Settings.Started) then
            PostMessage(form_settings.Handle, WM_PLUGIN_MSG, PN_RCSTART, 0);
         //form_settings.Started := true;
         //if fDATags.Count > 0 then UnInitDataAccess;
         //InitDataAccess;

         //Проинициализировать нулями тэги записи при старте рекордера
         //ToDo - повесить на галочку (вывести в настройку)
         {for i := 0 to fDATags.Count - 1 do
           begin
            if (fDATags.Items[i].Tag.GetScalarEstimate(estimate, ESTIMATOR_DEFAULT) <> S_OK) and
              (fDATags.Items[i].ModbusTag.AccessType = atWrite) then
              begin
                fDATags.Items[i].Tag.PushValue(0.0, -1);
              end;
           end; }

         Result := true;
      end;

      PN_BEFORE_RCSTART:
      begin
       //Проверить что есть готовность к старту
       //Все порты закрыты, например
       //  state := fIRecorder.GetState($FFFF);
        {if fIRecorder.CheckState(RS_VIEW) or fIRecorder.CheckState(RS_REC) then
           begin
           result := true;
           end else}

      //Проверяем что старт происходит из состояния стопа
      //и при этом не является стартом записи dwData = 1
      //из-за обратной совместимости такой костыль
        if fIRecorder.CheckState(RS_STOP) and (dwData > 1) then
        begin
        StartCtrl := PTagStartCtrl(dwData);
        state := StartCtrl^.dwFlags;
        if (state and SCF_VIEW = SCF_VIEW) or (state and SCF_REC = SCF_REC) then
           begin
           result := CheckBusListForReadyToStart;
           if not result then
              begin
              StartCtrl^.bContinueAction := false;
              StartCtrl^.pObject := self;
              end;
           end else
           result := true;
        end else result := true;
      end;

      PN_ON_SWITCH_CALIBR_MODE: begin
         if Assigned(Form_Settings) then
            PostMessage(form_settings.Handle, WM_PLUGIN_MSG, PN_RCSTART, 0);
         //form_settings.Started := true;
         //if fDATags.Count > 0 then UnInitDataAccess;
         //InitDataAccess;

         //Проинициализировать нулями тэги записи при старте рекордера
         //ToDo - повесить на галочку (вывести в настройку)
         {for i := 0 to fDATags.Count - 1 do
           begin
            if (fDATags.Items[i].Tag.GetScalarEstimate(estimate, ESTIMATOR_DEFAULT) <> S_OK) and
              (fDATags.Items[i].ModbusTag.AccessType = atWrite) then
              begin
                fDATags.Items[i].Tag.PushValue(0.0, -1);
              end;
           end;}

         Result:= true;
      end

      else
         Result:= false; //прочие сообщения не обрабатываем
      end;

end;

// Получение имени
function TTestPlugin.GetName: PChar; stdcall;
//var
  //s: AnsiString;
begin
   //s := UTF8ToWinCP(GPluginInfo.Name);
   Result:= PChar(UTF8ToWinCP(GPluginInfo.Name)); {Из глобальной структуры описания plug-in`а}
end;
// Получить свойство
function TTestPlugin.GetProperty(const dwPropertyID: DWORD;
                   var Value: OleVariant): boolean; stdcall;
begin
  case dwPropertyID of
     PLGPROP_INFOSTRING: begin    {Получить строку описания plug-in`а}
        Value := GPluginInfo.Dsc; {Из глобальной структуры описания plug-in`а}

        Result:= true;
     end;
     else
        Result:= false;
  end;
end;

function TTestPlugin.GetRecorder: IRecorder;
begin
  result := fIRecorder;
end;

// Задать свойство
function TTestPlugin.SetProperty(const dwPropertyID: DWORD;
                   {const} Value: OleVariant): boolean; stdcall;
begin
   FreeAndNil(fDATags);
   Result:= false; {Свойств нет и устанавливать нечего}
end;

// Узнать можно ли завершить работу плагина
function TTestPlugin.CanClose: boolean; stdcall;
begin
  Result:= true; //всегда можно закрыть plug-in
end;

// Завершить работу плагина
function TTestPlugin.Close:  boolean; stdcall;
begin
   Result:= true;
end;

{Методы запуска и останова измерения}
function TTestPlugin.StartMeasure: boolean;
begin
  {Для запуска необходимо передать сообщение Recorder`у}
  Result:= fIRecorder.Notify( RCN_VIEW, 0);
end;

function TTestPlugin.StopMeasure: boolean;
begin
  {Для останова необходимо передать сообщение Recorder`у}
  Result:= fIRecorder.Notify( RCN_STOP, 0);
end;

{Метод получения массива ссылок на интерфейсы тегов Recorder`а}
{Список тегов запрашивается у Recorder`а, через ссылку на его интерфейс.}
procedure TTestPlugin.GetDynTagsArray(var Tags: DynTagsArray);
var
  Count: integer;
  i: integer;
begin
  //получить кол-во тегов
  Count:= Recorder.GetTagsCount;
  //Установить соответсвующий размер динамического массива
  SetLength(Tags, Count);
  //Последовательно получить ссылки на интерфейсы тегов
  for i:= 0 to Count - 1 do
  //Использование преобразования типа обосновано в описании
  Tags[i]:= ITag(Recorder.GetTagByIndex(i));
end;


procedure TTestPlugin.TagNewData(Sender: TObject; DA: IDataAccess);
var
  datag: TDATag;
  tagtype: OleVariant;
  tag: TModbusTag;
  tagrec: ITag;
  tag_val: double;
  val2: Single;
  valUint16: Word;
  valInt16: Int16;
  RawVal: TBytes;
  device: TModbusDevice;
  byte_flag, reg_flag, flag_dword: boolean;
begin
  datag := TDATag(Sender);


  tag := datag.ModbusTag;
  tagrec := ITag(fIRecorder.GetTagByName(PAnsiChar(UTF8ToWinCP(tag.Name))));
  device := tag.Parent;

  {case device.Parent.ProtocolType of
     ptTCP: if not TBusTCP(device.Parent).Connection.Connected then exit;
     ptRTU: if not TBusRTU(device.Parent).Port.Active then exit;
  end; }

  device.Parent.ProtocolType;

 //Выход из процедуры если тэг относится к отключенному устройству. Добавлено в v.1.0.5.8
  if not device.Enabled then exit;

              //if Assigned(tagrec) and (tag.ValueDouble <> GetLastValue(tagrec)) then

             //Заглушка таймера для анализа времени от подачи команды внешним плагином до отправки в плагин
             //Результаты показали что нет задержки
             //if tag.Name = 'StartTimer' then
             //begin
             //  Timer := TPerformanceTime.Create;
             //  LogMsg('C:\Mera Files\logs\modbuslog.txt', 'StartTimer Время = ' + floattostr(Timer.Start));
             //  Timer.Stop;
             //  FreeAndNil(Timer);
             //  exit;
             //end;

 if Assigned(tagrec) then
  begin
  case tag.DataType of
    dtUInt16:
    begin
    if Assigned(tagrec) then
       tag_val := tagrec.GetEstimate(ESTIMATOR_DEFAULT) else
       exit;
    if (tag_val > 65535) or (tag_val < 0) then exit;
    valUint16 := trunc(tag_val);
    if Assigned(tagrec) and ((length(tag.RawValue) = 0) or (tag.ValueUInt16 <> valUint16)) then
      begin
      setlength(RawVal, sizeof(valUint16));
      move(valUint16, RawVal[0], length(RawVal));
      end;
    end;

    dtInt16:
    begin
    if Assigned(tagrec) then
       tag_val := tagrec.GetEstimate(ESTIMATOR_DEFAULT) else
       exit;

    if (tag_val > 32767) or (tag_val < -32767) then exit;
    valInt16 := trunc(tag_val);

    if Assigned(tagrec) and ((length(tag.RawValue) = 0) or (tag.ValueInt16 <> valInt16)) then
      begin
      setlength(RawVal, sizeof(valInt16));
      move(valInt16, RawVal[0], length(RawVal));
      end;
    end;

    else
    begin
    val2 := tagrec.GetEstimate(ESTIMATOR_DEFAULT);

    if Assigned(tagrec) and ((length(tag.RawValue) = 0) or (tag.ValueSingle <> val2)) then
      begin
      setlength(RawVal, sizeof(val2));
      move(val2, RawVal[0], length(RawVal));
      end;
    end
  end;
  if length(RawVal) > 0 then
     begin
     tag.SetRawValueWithoutEvent(RawVal);
      if tag.ImidiateWrite and (tag.AccessType in [atWrite, atReadWrite]) then
        device.WriteTag(tag);
     end;
  end;

end;

procedure TTestPlugin.InitDataAccess;
var
  i, j, k: integer;
  tag: TModbusTag;
begin
  for i := 0 to  Form_Settings.SettingsFrame.BusList.Count - 1 do
    begin
    for j := 0 to Form_Settings.SettingsFrame.BusList[i].Items.Count - 1 do
      begin
      for k := 0 to Form_Settings.SettingsFrame.BusList[i].Items[j].tags.Count - 1 do
        begin
        tag := Form_Settings.SettingsFrame.BusList[i].Items[j].tags[k];
        if (tag.ImidiateWrite or tag.ContiniousWrite) and (tag.AccessType in [atWrite, atReadWrite]) then
          begin
          fDATags.Add(TDATag.Create);
          fDATags.Last.Recorder := fIRecorder;
          fDATags.Last.ModbusTag := Form_Settings.SettingsFrame.BusList[i].Items[j].tags[k];
          fDATags.Last.OnNewData := @TagNewData;
          fDATags.Last.Init;
          end;
        end;
      end;
    end;
end;

procedure TTestPlugin.UninitDataAccess;
var
  tag: TDATag;
begin
if Assigned(fDATags) then
  while fDATags.Count > 0 do
  begin
  //tag := fDATags.First;
  tag := fDATags.Items[0];
  tag.UnInit;
  //fDATags.Remove(tag);
  fDATags.Delete(0);
  tag.Free;
  //TDATag(tag).Destroy;
  end;
end;

end.
