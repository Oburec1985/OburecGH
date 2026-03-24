unit Unit1;

{******************************************************************************
 * Модуль формы управления ЦАП (uDacFrm.pas)
 *------------------------------------------------------------------------------
 * НАЗНАЧЕНИЕ:
 *   Этот модуль содержит UI и основную логику приложения для управления ЦАП.
 *   Он использует класс TDacDevice (реализованный в TSoundCardDac) для
 *   взаимодействия со звуковой картой.
 *
 * АРХИТЕКТУРА И ПОТОКОВАЯ МОДЕЛЬ:
 *   Работа с ЦАП построена на событийно-управляемой модели с двойной
 *   буферизацией, что обеспечивает непрерывное ("бесшовное") воспроизведение.
 *
 *   1. Инициация: Пользователь нажимает "Play". В основном потоке приложения
 *      вызывается GenerateAndQueueData, который генерирует первый блок данных
 *      и отправляет его в TSoundCardDac, который, в свою очередь, передает его
 *      драйверу звуковой карты.
 *
 *   2. Цикл воспроизведения (потоковый режим SweepSin):
 *      - Звуковая карта в своем собственном высокоприоритетном потоке
 *        (создаваемом системой) воспроизводит буфер.
 *      - Когда буфер доигран, драйвер через callback-функцию вызывает событие
 *        OnBufferEnd.
 *      - ВАЖНО: Обработчик DacBufferEndHandler выполняется НЕ В ОСНОВНОМ ПОТОКЕ
 *        приложения, а в контексте того самого системного мультимедиа-потока.
 *      - Внутри DacBufferEndHandler снова вызывается GenerateAndQueueData.
 *        Таким образом, пока звуковая карта проигрывает один буфер, в это же
 *        время в другом потоке уже готовится и отправляется следующий.
 *
 *   3. Потокобезопасность: В данном примере GenerateAndQueueData не обращается
 *      напрямую к элементам UI, поэтому код условно безопасен. В более сложных
 *      приложениях для доступа к UI из обработчика OnBufferEnd следовало бы
 *      использовать TThread.Synchronize или TThread.Queue.
 *
 * ГДЕ ЗАДАЕТСЯ ДЛИТЕЛЬНОСТЬ БУФЕРА?
 *   Длительность одного блока данных задается в миллисекундах в константе
 *   BUFFER_SIZE_MS внутри процедуры GenerateAndQueueData. На ее основе
 *   рассчитывается реальный размер буфера в сэмплах (зависит от SampleRate).
 *****************************************************************************}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uDacDevice, uSoundCardDac, Math, ImgList,
  inifiles,
  ulogFile,
  uChart, uSpin, uDACProgram;

type
  TDACFrm = class(TForm)
    pnlTop: TPanel;                  // Панель для кнопок управления
    btnPlayStop: TButton;           // Кнопка "Play/Stop"
    rgMode: TRadioGroup;            // Переключатель режимов (Sin/SweepSin)
    rgProgramType: TRadioGroup;     // Переключатель типа программы (Simple/Accurate)
    gbSweepSin: TGroupBox;               // Группа параметров для режима Sin
    gbProgram: TGroupBox;           // Группа параметров программы
    lblProgFreq: TLabel;            // Метка "Частота программы"
    lblProgAmpl: TLabel;            // Метка "Амплитуда программы"
    edProgFreq: TEdit;              // Поле ввода частоты программы
    edProgAmpl: TFloatSpinEdit;     // Поле ввода амплитуды программы
    lblMinSamples: TLabel;          // Метка "Мин. сэмплов"
    edMinSamples: TEdit;            // Поле ввода мин. сэмплов (для Accurate)
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    TestBtn: TButton;
    cbDacDevices: TComboBox;
    btnRefreshDevices: TButton;
    cChart1: cChart;             // Поле ввода времени развертки (SweepSin)
    procedure btnPlayStopClick(Sender: TObject); // Обработчик нажатия кнопки Play/Stop
    procedure FormCreate(Sender: TObject);     // Обработчик создания формы
    procedure FormDestroy(Sender: TObject);    // Обработчик закрытия формы
    procedure rgModeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnRefreshDevicesClick(Sender: TObject);
    procedure RefreshDeviceList;
    procedure rgProgramTypeClick(Sender: TObject);
    procedure edProgFreqChange(Sender: TObject);
    procedure edProgAmplChange(Sender: TObject);
    procedure edMinSamplesChange(Sender: TObject);
  private
    { Private declarations }
    FDacDevice: TDacDevice;       // Экземпляр класса ЦАП
    FBuffer: array of Smallint;   // Буфер для генерации звуковых данных (16-бит)

    // --- Программы ЦАП ---
    FSimpleSinusProgram: TSimpleSinusProgram;
    FAccurateSinusProgram: TAccurateSinusProgram;
    FCurrentProgram: TDacProgram; // Текущая активная программа

    // --- Состояние режима SweepSin ---
    FSweepPhase: Double;          // Текущая фаза для генератора SweepSin
    FSweepCurrentFreq: Double;    // Текущая частота для генератора SweepSin
    FSweepStartTime: Cardinal;    // Время начала для режима SweepSin

    // Генерирует и отправляет в ЦАП следующий блок данных
    procedure GenerateAndQueueData(sender:tobject);
    // Обновляет видимость панелей с параметрами в зависимости от режима
    procedure UpdateModeView;
    // сохранить конфигурацию
    procedure save(ifile:tinifile);
    // загрузить конфигурацию
    procedure load(ifile:tinifile);
    // Инициализация программ ЦАП
    procedure InitPrograms;
    // Переключение между программами
    procedure SetProgram(AProgramType: Integer);
  public
    { Public declarations }
  end;

var
  DACFrm: TDACFrm;

implementation

{$R *.dfm}

procedure TDACFrm.btnPlayStopClick(Sender: TObject);
begin
  if FDacDevice.IsPlay then
  begin
    logMessage('btnPlayStopClick: STOP');
    // Останавливаем текущую программу
    if Assigned(FCurrentProgram) then
      FCurrentProgram.Stop;

    // Останавливаем воспроизведение
    FDacDevice.Stop(False);
    btnPlayStop.Caption := 'Play';
  end
  else
  begin
    logMessage('btnPlayStopClick: PLAY');
    case rgMode.ItemIndex of
      0: // Sin
      begin
      end;
      1: // SweepSin
      begin
        FSweepPhase := 0;
        FSweepCurrentFreq := StrToFloatDef(edStartFreq.Text, 100);
        FSweepStartTime := GetTickCount;
      end;
    end;
    btnPlayStop.Caption := 'Stop';

    case FDacDevice.State of
      stClosed:
      begin
        //logMessage('btnPlayStopClick: State=stClosed, calling Open');
        // Общие настройки
        FDacDevice.SampleRate := 44100;
        FDacDevice.BitsPerSample := 16;
        FDacDevice.Channels := 1;
        // Сообщаем ЦАП желаемый размер буфера в мс
        FDacDevice.BufferSizeMS := 300;
        FDacDevice.DeviceID := cbDacDevices.ItemIndex;
        FDacDevice.Open;
        //logMessage('btnPlayStopClick: after Open, calling Start');
        FDacDevice.Start(1);
        // Запускаем программу
        if Assigned(FCurrentProgram) then
          FCurrentProgram.Start;
        //logMessage('btnPlayStopClick: after Start');
      end;
      stOpened:
      begin
        //logMessage('btnPlayStopClick: State=stOpened, calling Start');
        FDacDevice.Start(1);
        // Запускаем программу
        if Assigned(FCurrentProgram) then
          FCurrentProgram.Start;
        //logMessage('btnPlayStopClick: after Start');
      end;
    end;
  end;
end;

procedure TDACFrm.btnRefreshDevicesClick(Sender: TObject);
begin
  RefreshDeviceList;
end;

procedure TDACFrm.FormCreate(Sender: TObject);
var
  IniFile: TIniFile;
begin
  g_logFile:=cLogFile.create(ExtractFileDir(Application.ExeName)+'\log.txt', ';');

  FDacDevice := TSoundCardDac.Create;
  FDacDevice.OnGenerateData := GenerateAndQueueData;
  FDacDevice.name:='Тест DAQ';
  rgMode.ItemIndex := 0;
  rgProgramType.ItemIndex := 0;
  UpdateModeView;
  RefreshDeviceList;

  // Инициализация программ ЦАП
  InitPrograms;

  // Инициализация и загрузка настроек из INI-файла
  IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    load(IniFile);
  finally
    IniFile.Free;
  end;
end;

procedure TDACFrm.FormDestroy(Sender: TObject);
var
  IniFile: TIniFile;
begin
  // Сохранение настроек в INI-файл перед уничтожением формы
  IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    save(IniFile);
  finally
    IniFile.Free;
  end;
  FDacDevice.Stop(false);
  FDacDevice.Close;
  FDacDevice.Free;

  // Освобождаем программы
  FSimpleSinusProgram.Free;
  FAccurateSinusProgram.Free;
end;

procedure TDACFrm.FormShow(Sender: TObject);
begin
  //btnPlayStopClick(nil);
end;

procedure TDACFrm.GenerateAndQueueData(sender:tobject);
var
  i: Integer;
  Freq, Ampl, Value: Double;
  // Sweep vars
  StartFreq, EndFreq, SweepTime, CurrentTime, k: Double;
  lBlockSize: Integer;
begin
  if length(FBuffer)=0 then
  begin
    // FBuffer - длина задается в количестве отсчетов а не байт
    SetLength(FBuffer, FDacDevice.BufferSize shr 1);
  end;

  Ampl := StrToFloatDef(edAmpl.Text, 0.8);
  if Ampl > 1.0 then Ampl := 1.0;
  if Ampl < 0 then Ampl := 0;

  case rgMode.ItemIndex of
    0: // Sin
    begin
      Freq := StrToFloatDef(edFreq.Text, 1000);
      for i := 0 to Length(FBuffer) - 1 do
      begin
        Value := Ampl * Sin(2 * PI * Freq * i / FDacDevice.SampleRate);
        FBuffer[i] := round(Value * High(Smallint));
      end;
    end;
    1: // SweepSin
    begin
      StartFreq := StrToFloatDef(edStartFreq.Text, 100);
      EndFreq := StrToFloatDef(edEndFreq.Text, 10000);
      SweepTime := StrToFloatDef(edSweepTime.Text, 10);
      CurrentTime := (GetTickCount - FSweepStartTime) / 1000.0;

      // Линейная интерполяция частоты
      if SweepTime > 0 then
        FSweepCurrentFreq := StartFreq + (EndFreq - StartFreq) * (CurrentTime / SweepTime)
      else
        FSweepCurrentFreq := StartFreq;

      if FSweepCurrentFreq > EndFreq then FSweepCurrentFreq := EndFreq;

      for i := 0 to Length(FBuffer) - 1 do
      begin
        Value := Ampl * Sin(FSweepPhase);
        FBuffer[i] := round(Value * High(Smallint));
        FSweepPhase := FSweepPhase + 2 * PI * FSweepCurrentFreq / FDacDevice.SampleRate;
      end;
    end;
  end;

  lBlockSize := Length(FBuffer) * SizeOf(Smallint);
  FDacDevice.QueueBuffer(FBuffer[0], lBlockSize);
end;

procedure TDACFrm.rgModeClick(Sender: TObject);
begin
  UpdateModeView;
end;

procedure TDACFrm.save(ifile: tinifile);
begin
  ifile.WriteInteger('DAC', 'Mode', rgMode.ItemIndex);
  ifile.WriteString('DAC', 'Freq', edFreq.Text);
  ifile.WriteString('DAC', 'Ampl', edAmpl.Text);
  ifile.WriteString('DAC', 'StartFreq', edStartFreq.Text);
  ifile.WriteString('DAC', 'EndFreq', edEndFreq.Text);
  ifile.WriteString('DAC', 'SweepTime', edSweepTime.Text);
  ifile.WriteInteger('DAC', 'DeviceID', cbDacDevices.ItemIndex);
end;

procedure TDACFrm.load(ifile: tinifile);
begin
  rgMode.ItemIndex := ifile.ReadInteger('DAC', 'Mode', 0);
  edFreq.Text := ifile.ReadString('DAC', 'Freq', '1000');
  edAmpl.Text := ifile.ReadString('DAC', 'Ampl', '0.8');
  edStartFreq.Text := ifile.ReadString('DAC', 'StartFreq', '100');
  edEndFreq.Text := ifile.ReadString('DAC', 'EndFreq', '10000');
  edSweepTime.Text := ifile.ReadString('DAC', 'SweepTime', '10');
  cbDacDevices.ItemIndex := ifile.ReadInteger('DAC', 'DeviceID', 0);
  UpdateModeView;
end;


procedure TDACFrm.UpdateModeView;
begin
  gbSin.Visible := rgMode.ItemIndex = 0;
  gbSweepSin.Visible := rgMode.ItemIndex = 1;
  
  // Показываем панель программы только для режима Sin
  gbProgram.Visible := rgMode.ItemIndex = 0;
  
  // Показываем поле MinSamples только для Accurate программы
  lblMinSamples.Visible := rgProgramType.ItemIndex = 1;
  edMinSamples.Visible := rgProgramType.ItemIndex = 1;
end;

// Обновляет список доступных устройств вывода
procedure TDACFrm.RefreshDeviceList;
var
  DeviceList: TStringList;
begin
  // Получаем список устройств от класса ЦАП
  DeviceList := FDacDevice.GetDeviceList;
  try
    // Заполняем выпадающий список
    cbDacDevices.Items.Assign(DeviceList);
    // Выбираем первое устройство в списке по умолчанию
    if cbDacDevices.Items.Count > 0 then
      cbDacDevices.ItemIndex := 0;
  finally
    DeviceList.Free;
  end;
end;

{ Методы для работы с программами ЦАП }

procedure TDACFrm.InitPrograms;
begin
  // Создаем программы
  FSimpleSinusProgram := TSimpleSinusProgram.Create;
  FAccurateSinusProgram := TAccurateSinusProgram.Create;

  // Устанавливаем устройство для обеих программ
  FSimpleSinusProgram.Device := FDacDevice;
  FAccurateSinusProgram.Device := FDacDevice;

  // Инициализируем параметры из UI
  FSimpleSinusProgram.Frequency := StrToFloatDef(edProgFreq.Text, 440);
  FSimpleSinusProgram.Amplitude := edProgAmpl.Value;

  FAccurateSinusProgram.Frequency := StrToFloatDef(edProgFreq.Text, 440);
  FAccurateSinusProgram.Amplitude := edProgAmpl.Value;
  FAccurateSinusProgram.MinSamplesTarget := StrToIntDef(edMinSamples.Text, 1024);

  // По умолчанию используем простую программу
  FCurrentProgram := FSimpleSinusProgram;
end;

procedure TDACFrm.SetProgram(AProgramType: Integer);
begin
  // Останавливаем текущую программу
  if Assigned(FCurrentProgram) then
    FCurrentProgram.Stop;

  // Выбираем новую программу
  case AProgramType of
    0: FCurrentProgram := FSimpleSinusProgram;
    1: FCurrentProgram := FAccurateSinusProgram;
  else
    FCurrentProgram := FSimpleSinusProgram;
  end;

  // Запускаем новую программу (если устройство активно)
  if FDacDevice.IsPlay then
    FCurrentProgram.Start;
end;

procedure TDACFrm.rgProgramTypeClick(Sender: TObject);
begin
  SetProgram(rgProgramType.ItemIndex);
  UpdateModeView;
end;

procedure TDACFrm.edProgFreqChange(Sender: TObject);
begin
  // Обновляем частоту в обеих программах
  FSimpleSinusProgram.Frequency := StrToFloatDef(edProgFreq.Text, 440);
  FAccurateSinusProgram.Frequency := StrToFloatDef(edProgFreq.Text, 440);
end;

procedure TDACFrm.edProgAmplChange(Sender: TObject);
begin
  // Обновляем амплитуду в обеих программах
  FSimpleSinusProgram.Amplitude := edProgAmpl.Value;
  FAccurateSinusProgram.Amplitude := edProgAmpl.Value;
end;

procedure TDACFrm.edMinSamplesChange(Sender: TObject);
begin
  // Обновляем мин. количество сэмплов для Accurate программы
  FAccurateSinusProgram.MinSamplesTarget := StrToIntDef(edMinSamples.Text, 1024);
end;

end.
