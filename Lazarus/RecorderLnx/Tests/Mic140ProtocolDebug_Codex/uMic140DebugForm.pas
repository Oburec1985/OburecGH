unit uMic140DebugForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, Graphics, Grids, StdCtrls,
  uMic140Device,
  uRecorderDeviceInterfaces, uRecorderDeviceManager;
// тестовый интерфейс для проврки протокола MIC-140

type

  { TMic140DebugForm }

  TMic140DebugForm = class(TForm)
    // Объектные методы формы, которые вызывает LCL по событиям компонентов.
    //  Это не методы IRecorderDevice и не часть логики устройства.
    btnStart3: TButton;
    lblTitle: TLabel;
    sgTags: TStringGrid;
    procedure btnStart3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgTagsPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  protected
    // ссылка на наш MIC
    // Объектное поле формы.
    //  Это явная ссылка на конкретный MIC-140 только для отладочного примера.
    m_MIC140: TRecorderMic140Device;
  protected
    // Поиск и подключение MIC140
    // Объектный метод формы.
    //  Работает через общий RecorderDeviceManager и IRecorderDevice, но сам
    //  метод не является методом интерфейса устройства.
    function FindAndConnect:boolean;
    procedure ConfigureTestDevice(ADevice: TRecorderMic140Device);
  public
    // Объектный метод формы: освобождение формы и ее объектных ссылок.
    destructor Destroy; override;
    // проверка строки в sgTags
    // Объектный метод формы: решает, красить ли строку sgTags зеленым.
    function CheckRow(i: Integer): Boolean;
  end;

var
  Mic140DebugForm: TMic140DebugForm;

implementation

{$R *.lfm}

function TMic140DebugForm.FindAndConnect:boolean;
var
   iDev: IRecorderDevice;
   lDeviceObject: TObject;
begin
  if m_MIC140 = nil then
  begin
    // Оригинальный Recorder: поиск в register_device_table, затем вызов DevInfo.Creator.
    iDev:=RecorderDeviceManager.Search('MIC140');
    if iDev = nil then
      Exit(False);
    lDeviceObject := iDev.GetNativeObject;
    if not (lDeviceObject is TRecorderMic140Device) then
      Exit(False);
    m_MIC140 := TRecorderMic140Device(lDeviceObject);
   //m_MIC140.AddRef;
  end;
  Result := m_MIC140 <> nil;
  if not Result then
    Exit;

  // Жизненный цикл оригинального Recorder: Connect -> ProgramDevice -> Start.
  m_MIC140.Connect;
  Result := m_MIC140.State = rdsConnected;
  if Result then
    ConfigureTestDevice(m_MIC140);
end;

destructor TMic140DebugForm.Destroy;
begin
  m_MIC140 := nil;
  inherited Destroy;
end;

procedure TMic140DebugForm.ConfigureTestDevice(ADevice: TRecorderMic140Device);
begin
  // Оригинальный Recorder:
  // пользовательские и программные параметры записываются через
  // GetDeviceProperty / SetDeviceProperty до ProgramDevice.
  ADevice.TrySetDeviceProperty(rdpPollFrequencyHz, 10.0);
  ADevice.TrySetDeviceProperty(rdpUpdateTimeMs, 200);
  ADevice.TrySetDeviceProperty(rdpChannelCount, 48);

end;

function TMic140DebugForm.CheckRow(i: Integer): Boolean;
begin
  Result := (i > 0) and ((i mod 2) = 0);
end;

procedure TMic140DebugForm.sgTagsPrepareCanvas(Sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
begin
  // функция заглушка - каждая вторая строка в зеленый
  if CheckRow(aRow) then
    sgTags.Canvas.Brush.Color := $00E0FFE0;
end;

procedure TMic140DebugForm.btnStart3Click(Sender: TObject);
begin
  FindAndConnect;
end;

procedure TMic140DebugForm.FormCreate(Sender: TObject);
begin
  // поиск устройства с тестовыми настройками
  FindAndConnect;
end;

end.
