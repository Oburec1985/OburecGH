unit uDACFrm;

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
  uChart,uBuffTrend1d, upage, utextlabel, uaxis, utrend,
  uHardwareMath;

type
  TDACFrm = class(TForm)
    pnlTop: TPanel;                  // Панель для кнопок управления
    btnPlayStop: TButton;           // Кнопка "Play/Stop"
    rgMode: TRadioGroup;            // Переключатель режимов (Sin/SweepSin)
    gbSweepSin: TGroupBox;          // Группа параметров для режима SweepSin
    gbSin: TGroupBox;               // Группа параметров для режима Sin
    lblFreq: TLabel;                // Метка "Частота"
    lblAmpl: TLabel;                // Метка "Амплитуда"
    edFreq: TEdit;                  // Поле ввода для частоты (режим Sin)
    edAmpl: TEdit;                  // Поле ввода для амплитуды
    lblStartFreq: TLabel;           // Метка "Начальная частота"
    lblEndFreq: TLabel;             // Метка "Конечная частота"
    lblSweepTime: TLabel;           // Метка "Время развертки"
    edStartFreq: TEdit;             // Поле ввода начальной частоты (SweepSin)
    edEndFreq: TEdit;               // Поле ввода конечной частоты (SweepSin)
    edSweepTime: TEdit;
    cChart1: cChart;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    TestBtn: TButton;             // Поле ввода времени развертки (SweepSin)
    procedure btnPlayStopClick(Sender: TObject); // Обработчик нажатия кнопки Play/Stop
    procedure FormCreate(Sender: TObject);     // Обработчик создания формы
    procedure FormDestroy(Sender: TObject);    // Обработчик закрытия формы
    procedure rgModeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TestBtnClick(Sender: TObject);      // Обработчик смены режима
  private
    { Private declarations }
    FDacDevice: TDacDevice;       // Экземпляр класса ЦАП
    FBuffer: array of Smallint;   // Буфер для генерации звуковых данных (16-бит)

    // --- Состояние режима SweepSin ---
    FSweepPhase: Double;          // Текущая фаза для генератора SweepSin
    FSweepCurrentFreq: Double;    // Текущая частота для генератора SweepSin
    FSweepStartTime: Cardinal;    // Время начала для режима SweepSin

    // Обработчик события окончания буфера от ЦАП
    procedure DacBufferEndHandler(Sender: TObject);
    // Генерирует и отправляет в ЦАП следующий блок данных
    procedure GenerateAndQueueData;
    // Обновляет видимость панелей с параметрами в зависимости от режима
    procedure UpdateModeView;
  public
    { Public declarations }
  end;

var
  DACFrm: TDACFrm;

implementation

{$R *.dfm}

procedure TDACFrm.btnPlayStopClick(Sender: TObject);
begin
  if FDacDevice.IsActive then
  begin
    FDacDevice.Stop(True);
    btnPlayStop.Caption := 'Play';
  end
  else
  begin
    // Общие настройки
    FDacDevice.SampleRate := 44100;
    FDacDevice.BitsPerSample := 16;
    FDacDevice.Channels := 1;
    // Сообщаем ЦАП желаемый размер буфера в мс
    FDacDevice.BufferSizeMS := 300;
    FDacDevice.Open;

    case rgMode.ItemIndex of
      0: // Sin
      begin
        FDacDevice.Start(1); // Play each buffer once to enable streaming
        GenerateAndQueueData; // Queue first buffer
        GenerateAndQueueData; // Queue second buffer to prevent gaps
      end;
      1: // SweepSin
      begin
        FSweepPhase := 0;
        FSweepCurrentFreq := StrToFloatDef(edStartFreq.Text, 100);
        FSweepStartTime := GetTickCount;
        FDacDevice.Start(1); // Play each buffer once
        GenerateAndQueueData; // Queue first buffer
      end;
    end;

    btnPlayStop.Caption := 'Stop';
  end;
end;

procedure TDACFrm.DacBufferEndHandler(Sender: TObject);
begin
  // This handler is for all streaming modes (Sin, SweepSin, etc.)
  if FDacDevice.IsActive then
    GenerateAndQueueData;
end;

procedure TDACFrm.FormCreate(Sender: TObject);
begin
  FDacDevice := TSoundCardDac.Create;
  FDacDevice.OnBufferEnd := DacBufferEndHandler;
  rgMode.ItemIndex := 0;
  UpdateModeView;
end;

procedure TDACFrm.FormDestroy(Sender: TObject);
begin
  FDacDevice.Free;
end;

procedure TDACFrm.FormShow(Sender: TObject);
begin
  //btnPlayStopClick(nil);
end;

procedure TDACFrm.GenerateAndQueueData;
var
  i: Integer;
  Freq, Ampl, Value: Double;
  BufferSizeSamples: Integer;

  // Sweep vars
  StartFreq, EndFreq, SweepTime, CurrentTime, k: Double;
begin
  BufferSizeSamples := round(FDacDevice.SampleRate * FDacDevice.BufferSizeMS / 1000);
  SetLength(FBuffer, BufferSizeSamples);

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

  FDacDevice.QueueBuffer(FBuffer[0], Length(FBuffer) * SizeOf(Smallint));
end;

procedure TDACFrm.rgModeClick(Sender: TObject);
begin
  UpdateModeView;
end;

procedure TDACFrm.TestBtnClick(Sender: TObject);
var
  ar:tdoubleArray;
  len, freq1, freq2,
  dphase, // скорость фазы
  aPhase, // ускорение фазы
  Amp, phase:double;
  fs:integer;
  I, siglen: Integer;
  tr:cbufftrend1d;
  cfg:TFilterSettings;
begin
  fs:=1000;
  // длина в секундах
  len:=5;
  siglen:=round(len*fs);
  freq1:=10;
  freq2:=50;
  aPhase:=2*pi*(freq2-freq1)/(fs*fs*len); // ускорение фазы
  dphase:=2*pi*freq1/fs; // скорость фазы
  Amp:=1;
  setlength(ar,siglen);
  phase:=0;
  for I := 0 to siglen - 1 do
  begin
    ar[i]:= Amp * Sin(phase);
    phase:=phase+dphase;
    dphase:=dphase+aphase;
  end;
  cfg.Alpha:=0.3;
  cfg.IsFirstCall:=true;
  cfg.PrevOutput:=0;
  ar:=LowPassFilter(ar, cfg);
  tr:=cbufftrend1d(cpage(cchart1.activePage).activeAxis.getChild(0));
  if tr=nil then
  begin
    tr:=cBuffTrend1d.create;
    tr.dx:=1/fs;
    tr.name:='Test1000HzLpf';
    cpage(cchart1.activePage).activeAxis.AddChild(tr);
    tr.AddPoints(ar);
    cpage(cchart1.activePage).normalise;
  end;
end;

procedure TDACFrm.UpdateModeView;
begin
  gbSin.Visible := rgMode.ItemIndex = 0;
  gbSweepSin.Visible := rgMode.ItemIndex = 1;
end;

end.
