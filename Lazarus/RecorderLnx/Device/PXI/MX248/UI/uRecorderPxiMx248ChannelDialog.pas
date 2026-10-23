unit uRecorderPxiMx248ChannelDialog;

{
  Назначение: редактор одного или нескольких каналов MX-248 по структуре оригинального
  Recorder. Работает только с черновиком: прибор программирует общий Apply
  родительского диалога. Enum-поля выбираются из списков, свободный ввод
  аппаратных индексов запрещён.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Forms, Controls, StdCtrls, ExtCtrls;

type
  TMx248ChannelField = (mcfAmplifier, mcfInputMode, mcfRange, mcfLpf,
    mcfIcp, mcfCalibration, mcfFloating);
  { Empty fields mean mixed values on input and keep existing values on output. }
  TMx248ChannelValues = array[TMx248ChannelField] of string;

  TPxiMx248ChannelDialog = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    cbGain: TComboBox;
    cbIeee: TComboBox;
    cbInputMode: TComboBox;
    cbLpf: TComboBox;
    chkAmplifier: TCheckBox;
    chkCalibration: TCheckBox;
    chkFloating: TCheckBox;
    lblGain: TLabel;
    lblIeee: TLabel;
    lblInputMode: TLabel;
    lblLpf: TLabel;
    pnButtons: TPanel;
    procedure FormCreate(Sender: TObject);
  public
    procedure LoadValues(const AValues: TMx248ChannelValues);
    function ReadValues: TMx248ChannelValues;
  end;

function EditPxiMx248Channels(AOwner: TComponent; ACount: Integer;
  var AValues: TMx248ChannelValues): Boolean;

function EditPxiMx248Channel(AOwner: TComponent; AChannel: Integer;
  var AAmplifier, AInputMode, ARangeIndex, ALpfIndex,
  AIeeeCurrent, ACalibrationEnabled, AInputFloating: string): Boolean;

implementation

{$R *.lfm}

uses
  SysUtils;

procedure TPxiMx248ChannelDialog.FormCreate(Sender: TObject);
begin
  cbInputMode.Items.Add('Дифференциальный');
  cbInputMode.Items.Add('Однопроводный');
  { mx248flash.cpp defines indices as 100/10/1 nC. The original Recorder
    displays charge in pC, therefore the same indices are 100000/10000/1000
    pC. Keep item order identical to the DevAPI range index. }
  cbGain.Items.Add('±100000 пКл → ±10 В (0.0001 В/пКл)');
  cbGain.Items.Add('±10000 пКл → ±10 В (0.001 В/пКл)');
  cbGain.Items.Add('±1000 пКл → ±10 В (0.01 В/пКл)');
  cbLpf.Items.Add('Выключено');
  cbLpf.Items.Add('10 кГц');
  cbIeee.Items.Add('Выключено');
  cbIeee.Items.Add('4 мА');
  cbIeee.Items.Add('10 мА');
end;

procedure TPxiMx248ChannelDialog.LoadValues(const AValues: TMx248ChannelValues);

  procedure SetCheck(AControl: TCheckBox; const AValue: string);
  begin
    AControl.AllowGrayed := AValue = '';
    AControl.ShowHint := AControl.AllowGrayed;
    AControl.Hint := 'Серый флажок — сохранить значение каждого канала.';
    if AValue = '' then AControl.State := cbGrayed
    else AControl.Checked := SameText(AValue, 'True');
  end;

  procedure SetChoice(AControl: TComboBox; AIndex: Integer;
    const AValue: string);
  begin
    if (AControl.Items.Count > 0) and
      (AControl.Items[AControl.Items.Count - 1] = 'Разные значения') then
      AControl.Items.Delete(AControl.Items.Count - 1);
    if AValue = '' then AIndex := AControl.Items.Add('Разные значения');
    AControl.ItemIndex := AIndex;
  end;

var
  lIndex: Integer;
begin
  SetCheck(chkAmplifier, AValues[mcfAmplifier]);
  SetCheck(chkCalibration, AValues[mcfCalibration]);
  SetCheck(chkFloating, AValues[mcfFloating]);
  lIndex := Ord(SameText(AValues[mcfInputMode], 'single-ended'));
  SetChoice(cbInputMode, lIndex, AValues[mcfInputMode]);
  SetChoice(cbGain, StrToIntDef(AValues[mcfRange], 0), AValues[mcfRange]);
  SetChoice(cbLpf, StrToIntDef(AValues[mcfLpf], 0), AValues[mcfLpf]);
  lIndex := 0;
  if AValues[mcfIcp] = '4' then lIndex := 1;
  if AValues[mcfIcp] = '10' then lIndex := 2;
  SetChoice(cbIeee, lIndex, AValues[mcfIcp]);
end;

function TPxiMx248ChannelDialog.ReadValues: TMx248ChannelValues;

  function CheckValue(AControl: TCheckBox): string;
  begin
    if AControl.State = cbGrayed then Exit('');
    Result := BoolToStr(AControl.Checked, True);
  end;

  function ChoiceIndex(AControl: TComboBox): string;
  begin
    if (AControl.ItemIndex < 0) or (AControl.Text = 'Разные значения') then
      Exit('');
    Result := IntToStr(AControl.ItemIndex);
  end;

begin
  Result[mcfAmplifier] := CheckValue(chkAmplifier);
  Result[mcfCalibration] := CheckValue(chkCalibration);
  Result[mcfFloating] := CheckValue(chkFloating);
  Result[mcfRange] := ChoiceIndex(cbGain);
  Result[mcfLpf] := ChoiceIndex(cbLpf);
  Result[mcfInputMode] := ChoiceIndex(cbInputMode);
  if Result[mcfInputMode] = '0' then Result[mcfInputMode] := 'differential'
  else if Result[mcfInputMode] = '1' then Result[mcfInputMode] := 'single-ended';
  Result[mcfIcp] := ChoiceIndex(cbIeee);
  case Result[mcfIcp] of
    '0': Result[mcfIcp] := 'off';
    '1': Result[mcfIcp] := '4';
    '2': Result[mcfIcp] := '10';
  end;
end;

function EditPxiMx248Channels(AOwner: TComponent; ACount: Integer;
  var AValues: TMx248ChannelValues): Boolean;
var
  lDialog: TPxiMx248ChannelDialog;
  lValues: TMx248ChannelValues;
  lField: TMx248ChannelField;
begin
  lDialog := TPxiMx248ChannelDialog.Create(AOwner);
  try
    lDialog.Caption := Format('MX-248 — каналов: %d', [ACount]);
    lDialog.LoadValues(AValues);
    Result := lDialog.ShowModal = mrOk;
    if not Result then Exit;
    lValues := lDialog.ReadValues;
    for lField := Low(lField) to High(lField) do
      if lValues[lField] = AValues[lField] then lValues[lField] := '';
    AValues := lValues;
  finally
    lDialog.Free;
  end;
end;

function EditPxiMx248Channel(AOwner: TComponent; AChannel: Integer;
  var AAmplifier, AInputMode, ARangeIndex, ALpfIndex,
  AIeeeCurrent, ACalibrationEnabled, AInputFloating: string): Boolean;
var
  lDialog: TPxiMx248ChannelDialog;
  lValues: TMx248ChannelValues;
begin
  lValues[mcfAmplifier] := AAmplifier;
  lValues[mcfInputMode] := AInputMode;
  lValues[mcfRange] := ARangeIndex;
  lValues[mcfLpf] := ALpfIndex;
  lValues[mcfIcp] := AIeeeCurrent;
  lValues[mcfCalibration] := ACalibrationEnabled;
  lValues[mcfFloating] := AInputFloating;
  lDialog := TPxiMx248ChannelDialog.Create(AOwner);
  try
    lDialog.Caption := Format('MX-248 — канал %d', [AChannel]);
    lDialog.LoadValues(lValues);
    Result := lDialog.ShowModal = mrOk;
    if not Result then Exit;
    lValues := lDialog.ReadValues;
    AAmplifier := lValues[mcfAmplifier];
    AInputMode := lValues[mcfInputMode];
    ARangeIndex := lValues[mcfRange];
    ALpfIndex := lValues[mcfLpf];
    AIeeeCurrent := lValues[mcfIcp];
    ACalibrationEnabled := lValues[mcfCalibration];
    AInputFloating := lValues[mcfFloating];
  finally
    lDialog.Free;
  end;
end;

end.
