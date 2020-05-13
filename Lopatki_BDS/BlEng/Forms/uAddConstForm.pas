// Юнит выполняет функции по генерации данных для класса cBldFile.
// Реализованные функции:
// 1) FormDataToBld - сохраняет данные компонент формы в cbldFile
// 2) SensorsListViewAdvancedCustomDrawSubItem - перерисовка ListView (рисование
// кнопок в колонке "+/-")
// 3) SensorsListViewColumnBtnClick - В случае если нажатие
// произошло на колонке "+/-" происходит удаление или добавление датчика
// 4) SensorsListViewDblClick - переход в режим редактирования датчика
// 5) SensorsListViewDblClickProcess - редактирование датчика (вызывается форма EditListItem)
// 6) GenBldDataBtnClick - сгенерировать данные в cBldFile и перенести их в форму
// 7) AddTicks, DecTicks - складывают, вычетают значения времен/ учитывают
// возможность переполнения cardinal.
//
// Логика работы:
// При вызове формы (ShowModal) в нее передается ссылка cBldFile из основного
// окна программы. В процессе редактирования формы (возможные пути: ручное
// редактирование; автоматическая генерация; загрузка из файла) подготавливаются
// данные для класса cBldFile. По подтверждении происходит перенос данных из
// формы в cBldFile(FormDataToBld) и сохранение данных в файл на диске(cBldFile.save)



unit uAddConstForm;

interface

uses
  Windows, Classes, Forms, StdCtrls, ExtCtrls, Controls, uBldFile,
  SysUtils, Graphics, dialogs, uFormEditListItem, uGenFreqForm,
  ComCtrls, iniFiles, DCL_MYOWN, uBtnListView,upair,
  ubldmath,utickdata,umytypes_,uBldservice, ubldturnmath
  ;

type
  TConstForm = class(TForm)
    Bevel1: TBevel;
    FreqLabel: TLabel;
    LengthLabel: TLabel;
    ValueLabel: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label12: TLabel;
    PageControl: TPageControl;
    Rotor2: TTabSheet;
    CancelBtn: TButton;
    FreqEdit: TFloatEdit;
    AddBtn: TButton;
    Button2: TButton;
    ValueEdit: TFloatEdit;
    LengthEdit: TFloatEdit;
    GenBldDataBtn: TButton;
    variatefreqCheckBox: TCheckBox;
    VibrationFloatEdit: TFloatEdit;
    RotorCountComboBox: TComboBox;
    GenFreqBtn: TButton;
    ProgressBar1: TProgressBar;
    Rotor1: TTabSheet;
    Bevel2: TBevel;
    SensorsListView: TBtnListView;
    BladesListView: TBtnListView;
    Label6: TLabel;
    BladeCountIntEdit: TIntEdit;
    Label13: TLabel;
    ChanCountIntEdit: TIntEdit;
    Label7: TLabel;
    Bevel3: TBevel;
    Label10: TLabel;
    BladeCountIntEdit2: TIntEdit;
    ChanCountIntEdit2: TIntEdit;
    SensorsListView2: TBtnListView;
    BladesListView2: TBtnListView;
    SwitchAllCheckBox1: TCheckBox;
    SwitchAllCheckBox2: TCheckBox;
    Rotor3: TTabSheet;
    Label11: TLabel;
    Label14: TLabel;
    BladeCountIntEdit3: TIntEdit;
    ChanCountIntEdit3: TIntEdit;
    SensorsListView3: TBtnListView;
    BladesListView3: TBtnListView;
    SwitchAllCheckBox3: TCheckBox;
    Bevel4: TBevel;
    procedure RotorCountComboBoxChange(Sender: TObject);
    procedure SwitchAllCheckBox1Click(Sender: TObject);
    procedure GenerateConfig;
    procedure GenFreqBtnClick(Sender: TObject);
    procedure GenBldDataBtnClick(Sender: TObject);
    procedure SensorsListViewAdvancedCustomDrawSubItem(
      Sender: TCustomListView; Item: TListItem; SubItem: Integer;
      State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure SensorsListViewDblClickProcess(item: TListItem;
      lv: TListView);
    procedure BladesListViewColumnBtnClick(item: TListItem; lv: TListView);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
  private
    GenFreq:boolean;
    GenVibration:boolean;
    m_BldFile:cBldFileGen;
    IniFile:TIniFile;
    // Чтение ini файла в форму.
    Procedure ReadIniFile;
    // Запись данных формы в ini файл.
    Procedure WriteIniFile;
    // Записать паспорт bld файла в класс cBldFile из компонент формы
    Procedure FormDataToBldTitle(var bldFile:cBldFileGen);
    // Создает массив измерительных данных для cBldFile
    Procedure BldConstValueGenerator(var BldFile:cBldFileGen; value:single);
  public
    // Действия выполняемые при вызове формы (создание/загрузка/сохранение bld файла)
    procedure ShowModal(var BldFile:cBldFileGen);
  end;

var
  FreqData:cpoints;
  ConstForm: TConstForm;
  btnClicked:boolean; // переменная которая запоминае, что кнопка на ListView нажата

const IniMainSection = 'memory';
implementation
// ------------------ Загрузка/ сохранение данных формы ------------------------
// =============================================================================
procedure TConstForm.FormDestroy(Sender: TObject);
begin
  WriteIniFile;
end;

procedure TConstForm.FormCreate(Sender: TObject);
begin
  GenFreq:=false;
  GenVibration:=false;
  IniFile:=TIniFile.Create(ExtractFiledir(Application.ExeName)+ '\files\GenFormCfg.Ini');
  ReadIniFile;
  FreqData:=cpoints.Create;
end;
// Записать данные из формы в ini файл
Procedure TConstForm.WriteIniFile;
begin
  IniFile.WriteFloat(IniMainSection,'RotFreq',FreqEdit.FloatNum);
  IniFile.WriteFloat(IniMainSection,'SignalLength',LengthEdit.FloatNum);
  IniFile.WriteFloat(IniMainSection,'Value',ValueEdit.FloatNum);
  IniFile.WriteFloat(IniMainSection,'VibrationFreq',VibrationFloatEdit.FloatNum);
  IniFile.WriteInteger(IniMainSection,'BladeNumber',BladeCountIntEdit.IntNum);
  IniFile.WriteInteger(IniMainSection,'SensorsCount',ChanCountIntEdit.IntNum);
end;
// Считать данные из  ini файла в форму
Procedure TConstForm.ReadIniFile;
begin
  FreqEdit.FloatNum:=IniFile.ReadFloat  (IniMainSection,'RotFreq',FreqEdit.FloatNum);
  LengthEdit.FloatNum:=IniFile.ReadFloat  (IniMainSection,'SignalLength',LengthEdit.FloatNum);
  ValueEdit.FloatNum:=IniFile.ReadFloat  (IniMainSection,'Value',ValueEdit.FloatNum);
  VibrationFloatEdit.FloatNum:=IniFile.ReadFloat  (IniMainSection,'VibrationFreq',VibrationFloatEdit.FloatNum);
  BladeCountIntEdit.IntNum:=IniFile.ReadInteger(IniMainSection,'BladeNumber',BladeCountIntEdit.IntNum);
  ChanCountIntEdit.IntNum:=IniFile.ReadInteger(IniMainSection,'SensorsCount',ChanCountIntEdit.IntNum);
end;


procedure TConstForm.RotorCountComboBoxChange(Sender: TObject);
begin

end;

// Нарисовать кнопку в 6-й колонке ListView
procedure drawButtonOnListItem(var li:TListItem;var LV:TCustomListView);
var
  Rect:TRect;
  Color:TColor;
  settings:integer;
  procedure getRectByColIndex(var Rect:TRect;column:integer);
  var i:integer;
  begin
    for i:=0 to column-1 do
    begin
      Rect.Left:=Rect.Left + TBtnListView(LV).Column[i].Width;
    end;
    Rect.Right:=Rect.Left + TBtnListView(LV).Column[column].Width;
  end;
begin
  // Определить координаты (где рисуем)
  Rect:=li.DisplayRect(drBounds);
  getRectByColIndex(Rect,TBtnListView(LV).BtnCol);
  //--------- Сделать заливку цветом кнопки
  Color:=LV.Canvas.Brush.Color;
  LV.Canvas.Brush.Color:=clLtGray;
  LV.Canvas.FillRect(Rect);
  //--------- Контуры кнопки.
  LV.Canvas.Brush.Color:=clBlack;
  LV.Canvas.MoveTo(Rect.Left,Rect.Bottom-2);
  LV.Canvas.LineTo(Rect.Right-1,Rect.Bottom-2);
  LV.Canvas.LineTo(Rect.Right-1,Rect.Top);
  // -------- Отрисовка верхних контуров кнопки
  if TBtnListView(LV).mBtnClicked and li.Selected then
  begin
    LV.Canvas.Brush.Color:=clBlack;//clgray;
    LV.Canvas.MoveTo(Rect.Left+1,Rect.Bottom-2);
    LV.Canvas.LineTo(Rect.Left+1,Rect.Top);
    LV.Canvas.LineTo(Rect.Right-1,Rect.Top);
  end;
  //--------- Вернуть исходный цвет
  LV.Canvas.Brush.Color:=Color;
end;

function isInteger(str:string):boolean;
begin
  result:=true;
  try StrToInt(str)
  except
   on e: EConvertError do result:=false;
  end;
end;

// Генерит конфигурацию по данным формы
procedure TConstForm.GenerateConfig;
  procedure fillStage(var sensorsLV:TBtnListView;var BladesLV:TBtnListView;
            chuncount:integer;bladesCount:integer;firstchun:integer);
  var i,chuntype:integer;
    // получить местоположение объекта на роторе
    // round - весь путь на котором раскидываются объекты (360(2pi) для круга)
    // count - число объектов
    // index - номер объекта
    // Объекты располагаются исходя из равномерного шага
    function GetAlfa(index,count,round:integer):single;
    var dA:single;
        str:string;
        Blade:integer;
    begin
      dA:=round/count;
      begin
        result:= dA*Index;
      end;
    end;
    procedure AddSensor(var LV:TBtnListView;chunnumber:integer;chuntype:integer);
    var li:tlistitem; // строка таблицы сенсоров
        i:integer; // номер строки в таблице
        name:string; // имя датчика
        str_chunnum,str_chuntype:string;
        pos:single;
    begin
      i:=LV.Items.Count;
      // Добавить новую строку
      LV.Items.Add;
      li:=LV.Items[i];
      // Номер канала
      str_chunnum:=inttostr(chunnumber);
      LV.SetSubItemByColumnName
                     (ColChanNumber,str_chunnum,li);
      // вписать имя датчика
      name:='D'+str_chunnum;
      LV.SetSubItemByColumnName
                     (ColSensorName,name,li);
      // вписать тип датчика
      case chuntype of
        c_rot: str_chuntype:='Тахо';
        c_root:str_chuntype:='Корневой';
        c_edge:str_chuntype:='Периферийный';
      end;
      LV.SetSubItemByColumnName
                     (ColType,str_chuntype,li);
      // Прописываем положение датчика на турбине
      pos:=getalfa(i,chuncount,360);
      LV.SetSubItemByColumnName
                     (ColSensorPos,floattostr(pos),li);
    end;
    // Заполнение таблицы лопатками и значениями их положений на роторе
    procedure AddBlade(var LV:TBtnListView;BladesNumber:integer);
    var li:tlistitem; // строка таблицы сенсоров
        i:integer; // номер строки в таблице
        pos:single;
    begin
      i:=LV.Items.Count;
      // Добавить новую строку
      LV.Items.Add;
      li:=LV.Items[i];
      // Номер канала
      LV.SetSubItemByColumnName(ColBladeNum,inttostr(i),li);
      pos:=getalfa(i,BladesNumber,360);
      LV.SetSubItemByColumnName
                     (ColSensorPos,floattostr(pos),li);
    end;
  begin
    sensorsLV.Clear;
    BladesLV.Clear;
    // Заполнение ListView в цикле по количеству датчиков
    for I := firstchun to chuncount+firstchun - 1 do
    begin
      if i=firstchun then
        chuntype := c_rot
      else
      begin
        if i mod 2 = 0 then
          chuntype:=c_edge
        else
          chuntype:=c_root;
      end;
      AddSensor(sensorsLV,i,chuntype);
    end;
    for I := 0 to bladesCount-1 do
    begin
      AddBlade(BladesLV,bladesCount);
    end;
  end;
begin
  // Заполнение первой ступени
  fillStage(sensorsListView,BladesListView,chancountIntEdit.IntNum,BladeCountIntedit.IntNum,0);
  // Заполнение второй ступени
  fillStage(sensorsListView2,BladesListView2,chancountIntEdit2.IntNum,BladeCountIntedit2.IntNum,chancountIntEdit.IntNum);
  // Заполнение третьей ступени
  fillStage(sensorsListView3,BladesListView3,chancountIntEdit3.IntNum,BladeCountIntedit2.IntNum,chancountIntEdit.IntNum+chancountIntEdit2.IntNum);
end;

// Перенести данные формы в заголовок BldFil-а
Procedure TConstForm.FormDataToBldTitle(var bldFile:cBldFileGen);
  procedure AddStage(var bld:cBldFileGen;diametr:single; name:string;BladesLV:TBtnListView);
  var i,stagecount,bladecount:integer;
      str_bladeoffset:string;
      stage:cStage;
      li:tlistitem;
  begin
    bladecount:=BladesLV.Items.Count;
    stagecount:=bld.stages.Count;
    inc(stagecount,1);
    stage:=cstage.create;
    stage.name:=name;
    stage.bladenumber:=bladecount;
    stage.diametr:=diametr;
    bld.stages.AddObject(name,stage);
    setlength(BldFile.stages.stages[stagecount-1].blades,bladecount);
    // считываем положения лопаток из ListView
    for I := 0 to bladecount - 1 do
    begin
      li:=BladesLV.Items[i];
      BladesLV.GetSubItemByColumnName(ColSensorPos,li,str_bladeoffset);
      BldFile.stages.stages[stagecount-1].blades[i].offset:=strtofloat(str_bladeoffset);
      BldFile.stages.stages[stagecount-1].blades[i].GenVibr:=li.Checked;
    end;
  end;
  function SensorsFromListView(LV:TBtnListView;var BldFile:cBldFileGen;stagename:string):Cardinal;
  var i,size,curlen,firstchun:integer;
      str:string;
      li:TLIstItem;
      sensor:csensor;
  begin
    size:=0;
    curlen:=BldFile.Sensors.count;
    firstchun:=curlen;
    for i := firstchun to LV.items.Count+firstchun-1 do
    begin
      li:=LV.items[i - firstchun];
      sensor:=csensor.create;
      LV.GetSubItemByColumnName(ColSensorName,li,sensor.mChanName);
      LV.GetSubItemByColumnName(ColChanNumber,li,str);
      sensor.mChanNumber:=strtoint(str);
      sensor.mAmplifier:=255;
      sensor.stagename:=stagename;
      BldFile.Sensors.addobject(sensor.mChanName,sensor);
      // Узнаем позицию датчика на турбине из ListView
      LV.GetSubItemByColumnName(ColSensorPos,li,str);
      BldFile.Sensors.sensors[i].pos:=strtofloat(str);
      LV.GetSubItemByColumnName(ColType,li,str);
      if str[1]='Т' then
        BldFile.Sensors.sensors[i].mChanType:=c_rot
      else
        if str[1]='К' then
          BldFile.Sensors.sensors[i].mChanType:=c_root
        else
          BldFile.Sensors.sensors[i].mChanType:=c_edge;
      // 6=2(номер канала)+1(усиление)+1(длина имени)+2(тип датчика)
      size:=Length(BldFile.Sensors.sensors[i].mChanName)+size+6;
    end;
    Result:=size;
  end;
begin
  BldFile.Clear;
  BldFile.mBldTitle.mTitle:='RecBld';
  // Добавить ступени
  AddStage(BldFile,1000,'stage1',BladesListView);
  BldFile.mBldTitle.mTitleSize:=SensorsFromListView(SensorsListView,BldFile,'stage1');
  if (strtoint(RotorCountCombobox.Text)>1) then
  begin
    AddStage(BldFile,1000,'stage2',BladesListView2);
    BldFile.mBldTitle.mTitleSize:=(SensorsFromListView(SensorsListView2,BldFile,'stage2') + BldFile.mBldTitle.mTitleSize);
  end;
  if (strtoint(RotorCountCombobox.Text)>2) then
  begin
    AddStage(BldFile,1000,'stage3',BladesListView3);
    BldFile.mBldTitle.mTitleSize:=(SensorsFromListView(SensorsListView3,BldFile,'stage3') + BldFile.mBldTitle.mTitleSize);
  end;
  // Количество байт, которое займет паспорт в файле
  // 24 =6(RecBld) + 4(размер заголовка) + 2(тип платы) + 2(число каналов)
  // + 8(время и дата испытания)+2(freq)
  BldFile.mBldTitle.mTitleSize:=BldFile.mBldTitle.mTitleSize+24;
  // добавить символы FFDATA
  UpdateTitleSize(BldFile);
  BldFile.mBldTitle.mCardType:=2070;
  BldFile.mBldTitle.mSamplingFreq:=0;//40 МГц
  BldFile.mBldTitle.mTestDate:=Time;
end;

// Основной метод формы - заполнение класса Bld файла и сама запись в файл
procedure TConstForm.ShowModal(var BldFile: cBldFileGen);
begin
  ProgressBar1.Position:=0;
  m_BldFile:=BldFile;
  inherited ShowModal;
end;

procedure TConstForm.SwitchAllCheckBox1Click(Sender: TObject);
var name:string;
    i,namelen:integer;
    lv:tbtnlistview;
    li:tlistitem;
begin
  name:=tcheckbox(sender).name;
  namelen:=length(name);
  i:=strtoint(name[namelen]);
  case i of
    1: lv:=BladesListView;
    2: lv:=BladesListView2;
    3: lv:=BladesListView3;
  end;
  for I := 0 to lv.items.Count - 1 do
  begin
    li:=lv.Items[i];
    li.Checked:=tcheckbox(sender).Checked;
  end;
end;

{$R *.dfm}
// Генерировать данные для файла
procedure TConstForm.GenBldDataBtnClick(Sender: TObject);
var BldFile:cBldFileGen;
    GenData:boolean;
begin
  GenData:=true;
  if SensorsListView.Items.Count<>0 then
  begin
    GenData:=MessageDlg('Вы действительно хотите пересоздать данные?',mtConfirmation,MbYesNo,0)=6;
  end;
  if GenData then
  begin
    BldFile:=cBldFileGen.Create;
    BldFile.Clear;
    GenerateConfig;
  end;
end;

procedure TConstForm.GenFreqBtnClick(Sender: TObject);
begin
  if GenFreqForm.ShowModal(freqData) = mrOk then
  begin
    GenFreq:=true;
    GenVibration:=true;
  end;
end;

function SortTList(Item1, Item2: pointer):integer;
  // Возвращает 1 если первый замер больше второго, меньше -1, иначе 0
begin
  Result:=CompareTicks(sData(Item1^).mTicks,sData(Item2^).mTicks);
end;

// Сгенерить измерительные данные для cBldFile
Procedure TConstForm.BldConstValueGenerator(var BldFile:cBldFileGen; value:single);
type
   PortionData = record
    Data:array of sTickData;
    Count:cardinal;
   end;
var
  stage:cstage; // ступень текущего датчика
  dA,freq:single;
  overflow:cardinal;
  BufData:Array of sData; // Сюда складываются данные из порций чтоб потом отсортировать
  dT:cardinal;                // интервал времени между проходом двух лопаток
  generated,              // число пиков которое уже было сгенерено и находится в Bufdata
  Impulscount,
  maxImpulscount,
  datasize,               // Общее число импульсов в файле
  TurnCount,              // число оборотов вала за время записи
  i,j:integer;   // индексы в цикла
  TaxoFirstTick, // Время прихода импульса на оборотный датчик на очередном обороте
  TaxoCount:integer;// Число корневых и периферийных датчиков
  Portion:PortionData; // Порция данных по одному датчику
  List:TList; // Здесь данные сортируются
  str:string;
  // Вспомогательная переменная для подсчета пиков канала
  g,n:integer;
  // Сгенерить порцию данных. Value - значение разброса (размах), град
  // dTicks - массив времен ( характеризует частоты на каждом обороте),
  // EdgeSensors - массив периферийных датчиков.
  // Root - датчик для которого генерятся данные
  // Taxo - тахо датчик;  TaxoFirstTick - время первого отсчета тахо датчика
  // BladeNumber - число лопаток
  // freq - частота вибрации
  function genticksbyconstfreq(var ticks:cpoints;freq:single;length:single;variatefreq:boolean):cardinal;
  var i,TurnCount:integer;
      dt,overflow:cardinal;
  begin
    // Число оборотов
    TurnCount:=Trunc(Freq*Length);
    // Время одного оборота
    dT:=trunc(CardFreq/(Freq));
    SetLength(ticks.ticks.ticks,TurnCount);
    // Число тиков в обороте
    ticks.ticks.ticks[0].Data:=0;
    ticks.ticks.ticks[0].OverflowCount:=0;
    // Постоянная частота вращения - все времена в массиве оборотов равны
    overflow:=0;
    for i:=1 to TurnCount-1 do
    begin
      ticks.ticks.ticks[i].Data:=AddTicks(ticks.ticks.ticks[i-1].Data,dT,overflow);
      ticks.ticks.ticks[i].OverflowCount:=overflow;
      // Увеличение частоты на каждом обороте (уменьшаем время следующего оборота)
      if variatefreq then
        dT:=trunc(dT/1.01);
    end;
    result:=turncount;
  end;
  // Возвращает число импульсов которе было сгенерено
  function GeneratePortion(var Portion:PortionData; Value:single;
                           const Ticks: array of sTickData;sensor:cSensor;
                            engine:cstage;freq:single):cardinal;
  var i,j:integer;
  // dT - Время прохода 1-о градуса; A - путь проходимый датчиком; f - фаза
      Tturn,T0,dT:Cardinal;
      T:integer;
      phase:single;
      lOverflow:cardinal;
  begin
    lOverflow:=0;
    // Цикл по числу оборотов (Формируем тики на всех оборотах)
    for i:=1 to Length(Ticks)-1 do
    begin
      Tturn:=decTicks(Ticks[i].Data,Ticks[i-1].Data,lOverflow);
      // время прохода одного градуса
      dT := trunc(Tturn/360);
      if sensor.mChanType<>c_rot then
      begin
        // Проход по лопаткам
        for j:=0 to engine.BladeNumber-1 do
        begin
          T0 := EvalBladePosTick(engine.Blades[j].Offset, sensor.pos,0, Ticks[i-1], Ticks[i]).Data;
          // Расчет фазы
          // 1)перевод в секунды (деление на CardFreq)
          // 2) расчет фазы(время/частоту)
          // ВОЗМОЖНО ОШИБКА!!!!!!!!!!!!!!!!
          // freq НУЖНО ПЕРЕСЧИТЫВАТЬ НА КАЖДОМ ОБОРОТЕ ДЛЯ РЕДАКТИРУЕМЫХ ВИБРАЦИЙ
          phase :=frac((T0/CardFreq)*freq)*360;
          // genVibration - переменная, если вкл, то используем закон генерации
          // сигнала из формы genFreqForm - фаза в градусах
          // иначе закон по умолчанию, синус. Фаза в радианах
          if not genVibration then
            // перевод в радианы
            phase := (phase/360)*2*pi;
          // T - значение разброса прихода лопатки
          if not genVibration then
            T :=trunc((dT)*Value*Sin(phase))
          else
            T :=trunc((dT)*GenFreqForm.GetYbyPhase(phase));
          // разброс только для выделенных лопаток
          if not engine.Blades[j].genvibr then  T:=0;
          // Если датчик корневой, то вибрация равна 0.
          if sensor.mChanType<>c_edge then  T:=0;
          lOverflow:=Ticks[i].OverflowCount;
          Portion.Data[(i-1)*engine.BladeNumber+j].Data:=AddTicks(T0,T,lOverflow);
          Portion.Data[(i-1)*engine.BladeNumber+j].OverflowCount:=lOverflow;
          inc(result,1);
        end;
      end
      else // Генерим импульсы от тахо датчика
      begin
        // расчетное время прихода импульса + dT(вибрация)
        lOverflow:=Ticks[i].OverflowCount;
        // РАсчетное время прихода = путь в градусах*t(1-о градуса)
        T0 :=AddTicks(Ticks[i].Data,trunc(dT*sensor.pos),lOverflow);
        T:=0;
        Portion.Data[(i)].Data:=AddTicks(T0,T,lOverflow);
        Portion.Data[(i)].OverflowCount:=lOverflow;
        inc(result,1);
      end;
    end;
  end;
begin
  // Если не была включена генерация формы частоты
  if not GenFreq then
  begin
    turncount:=genticksbyconstfreq(freqdata,freqedit.FloatNum,lengthedit.FloatNum,variatefreqCheckBox.checked);
  end
  else
   TurnCount:=length(freqData.ticks.ticks);
  // Число импульсов на одном датчике
  MaxImpulsCount:=0;
  for I := 0 to bldfile.stages.count - 1 do
  begin
    if maxImpulscount<bldfile.stages.stages[i].bladenumber then
      maxImpulscount:=bldfile.stages.stages[i].bladenumber;
  end;
  Portion.Count:=(TurnCount-1)*MaxImpulsCount;
  // Число импульсов в порции = сумма по датчикам(число лопаток ступени*число оборотов)
  datasize:=0;
  for I := 0 to bldfile.ChunCount-1 do
  begin
    if bldfile.Sensors.sensors[i].mChanType=c_rot then
      Impulscount:=bldfile.getsensorimpulscount(i)*(turncount)
    else
      Impulscount:=bldfile.getsensorimpulscount(i)*(turncount-1);
    datasize:=impulscount+datasize;
  end;
  SetLength(Portion.Data,Portion.Count);
  SetLength(BufData,datasize);
  List:=TList.Create;
  if not genVibration then
    freq:=VibrationFloatEdit.FloatNum
  else
    freq:=1/genFreqForm.Getdx;
  // Добавление импульсов датчиков
  generated:=0;
  for i:=0 to bldfile.ChunCount-1 do
  begin
    // Заполнение ProgressBar
    ProgressBar1.Max:=bldfile.ChunCount;
    // Получаем ступень по индексу датчика
    stage:=bldfile.getstage(i);
    GeneratePortion(Portion,Value,freqData.ticks.ticks,bldfile.Sensors.sensors[i],stage,freq);
    if bldfile.Sensors.sensors[i].mChanType=c_rot then
      Impulscount:=bldfile.getsensorimpulscount(i)*(turncount)
    else
      Impulscount:=bldfile.getsensorimpulscount(i)*(turncount-1);
    for j:=0 to impulscount-1 do // проход по элементам внутри порции данных
    begin
      BufData[generated+j].mChan:=bldfile.Sensors.sensors[i].mChanNumber;
      BufData[generated+j].mTicks:=portion.data[j];
      List.Add(@BufData[generated+j]);
    end;
    inc(generated,Impulscount);
    ProgressBar1.Position:=ProgressBar1.Position+1;
  end;
  List.Sort(@SortTList);
  ProgressBar1.Position:=ProgressBar1.Position+1;
  SetLength(BldFile.mData,Length(BufData));
  for i:=0 to List.Count-1 do
    BldFile.mData[i]:=sData(List.Items[i]^);
end;

procedure TConstForm.SensorsListViewAdvancedCustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
begin
  if SubItem = TBtnListView(Sender).BtnCol then
  begin
    drawButtonOnListItem(item,TCustomListView(Sender));
  end
end;

procedure TConstForm.SensorsListViewDblClickProcess(item: TListItem;
  lv: TListView);
var i:integer;
begin
  i:=FormEditListItem.ShowModal(item,TBtnListView(lv));
  if i<>7 then
//    SensorsListViewUpdateAlfa(item)
  else
//    ChanCountIntEdit.IntNum:=TBtnListView(lv).Items.Count;
end;

procedure TConstForm.BladesListViewColumnBtnClick(item: TListItem;
  lv: TListView);
begin
  item.Delete;
  ChanCountIntEdit.IntNum:=TBtnListView(lv).Items.Count;
end;

Procedure TConstForm.AddBtnClick;
begin
  // Сгенерить паспорт для BldFil-а по данным формы
  FormDataToBldTitle(m_BldFile);
  BldConstValueGenerator(m_BldFile,ValueEdit.FloatNum);
  m_BldFile.evalTicks;
  //m_BldFile.Save;     // Сохранить Bld файл (путь определяется в конструкторе)
  Close;
end;

end.
