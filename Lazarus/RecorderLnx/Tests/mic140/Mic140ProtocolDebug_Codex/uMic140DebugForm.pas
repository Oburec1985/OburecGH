unit uMic140DebugForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Grids, StdCtrls, Dialogs,
  uMic140Device, uRecorderDeviceInterfaces, uRecorderDeviceManager;

type
  TMic140DebugForm = class(TForm)
    btnStart3: TButton;
    lblTitle: TLabel;
    sgTags: TStringGrid;
    procedure btnStart3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgTagsPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  protected
    m_Device: IRecorderDevice;       // держит refcount, иначе объект уничтожается при выходе из FindAndConnect
    m_MIC140: TRecorderMic140Device;
    function FindAndConnect: Boolean;
    procedure ConfigureTestDevice(ADevice: TRecorderMic140Device);
  public
    destructor Destroy; override;
    function CheckRow(i: Integer): Boolean;
  end;

var
  Mic140DebugForm: TMic140DebugForm;

implementation

{$R *.lfm}

function TMic140DebugForm.FindAndConnect: Boolean;
var
  lObj: TObject;
begin
  Result := False;
  if m_Device = nil then
  begin
    m_Device := RecorderDeviceManager.Search('MIC140');
    if m_Device = nil then
    begin
      ShowMessage('MIC-140 не найден в сети 192.168.14.x');
      Exit;
    end;
    lObj := m_Device.GetNativeObject;
    if not (lObj is TRecorderMic140Device) then
    begin
      m_Device := nil;
      ShowMessage('Неверный тип устройства MIC140');
      Exit;
    end;
    m_MIC140 := TRecorderMic140Device(lObj);
  end;

  try
    m_MIC140.Connect;
  except
    on E: ERecorderDeviceError do
    begin
      ShowMessage(E.Message);
      Exit;
    end;
  end;

  Result := m_MIC140.State = rdsConnected;
  if Result then
    ConfigureTestDevice(m_MIC140)
  else
    ShowMessage('Connect: состояние не Connected');
end;

destructor TMic140DebugForm.Destroy;
begin
  m_MIC140 := nil;
  m_Device := nil;
  inherited;
end;

procedure TMic140DebugForm.ConfigureTestDevice(ADevice: TRecorderMic140Device);
var
  C: TMic140ClockMeasureResult;
  M: string;
begin
  ADevice.TrySetDeviceProperty(rdpUpdateTimeMs, 200);
  ADevice.TrySetDeviceProperty(rdpChannelCount, 48);
  ADevice.TrySetDeviceProperty(rdpPollFrequencyHz, 10.0);
  C := ADevice.ClockMeasure;
  case C.Method of
    mcmMeasureFreqModule: M := 'CMD_MEASURE_FREQ_MODULE';
    mcmNominal:           M := 'fallback 16 MHz';
  else M := 'none';
  end;
  lblTitle.Caption := Format(
    'MIC-140  Fclk=%.3f MHz  Fs(ch)=%.3f Hz  Fs(timer)=%.3f Hz  count_aver=%d  [%s]',
    [C.ModuleClockHz / 1e6, ADevice.ScanProgram.Timing.FrequencyHz,
     ADevice.ScanProgram.Mc114.ActualFrequencyHz,
     ADevice.ScanProgram.Timing.AverageSampleCount, M]);
  if C.ErrorText <> '' then
    lblTitle.Caption := lblTitle.Caption + '  err: ' + C.ErrorText;
end;

function TMic140DebugForm.CheckRow(i: Integer): Boolean;
begin
  Result := (i > 0) and ((i mod 2) = 0);
end;

procedure TMic140DebugForm.sgTagsPrepareCanvas(Sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
begin
  if CheckRow(aRow) then sgTags.Canvas.Brush.Color := $00E0FFE0;
end;

procedure TMic140DebugForm.btnStart3Click(Sender: TObject);
begin
  FindAndConnect;
end;

procedure TMic140DebugForm.FormCreate(Sender: TObject);
begin
  { Подключение только по кнопке Run — не при старте формы. }
end;

end.
