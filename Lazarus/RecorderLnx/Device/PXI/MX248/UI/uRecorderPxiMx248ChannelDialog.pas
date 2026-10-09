unit uRecorderPxiMx248ChannelDialog;

{
  Назначение: редактор одного канала MX-248 по структуре оригинального
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
  TPxiMx248ChannelDialog = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    cbGain: TComboBox;
    cbIeee: TComboBox;
    cbInputMode: TComboBox;
    cbLpf: TComboBox;
    chkAmplifier: TCheckBox;
    chkEnabled: TCheckBox;
    lblGain: TLabel;
    lblIeee: TLabel;
    lblInputMode: TLabel;
    lblLpf: TLabel;
    pnButtons: TPanel;
    procedure FormCreate(Sender: TObject);
  end;

function EditPxiMx248Channel(AOwner: TComponent; AChannel: Integer;
  var AEnabled, AAmplifier, AInputMode, ARangeIndex, ALpfIndex,
  AIeeeCurrent: string): Boolean;

implementation

{$R *.lfm}

uses
  SysUtils;

procedure TPxiMx248ChannelDialog.FormCreate(Sender: TObject);
begin
  cbInputMode.Items.Add('Дифференциальный');
  cbInputMode.Items.Add('Однопроводный');
  cbGain.Items.Add('±1000 пКл → ±10 В (0.01 В/пКл, 20 дБ)');
  cbGain.Items.Add('±100 пКл → ±10 В (0.1 В/пКл, 40 дБ)');
  cbGain.Items.Add('±10 пКл → ±10 В (1 В/пКл, 60 дБ)');
  cbLpf.Items.Add('Выключено');
  cbLpf.Items.Add('10 кГц');
  cbIeee.Items.Add('Выключено');
  cbIeee.Items.Add('4 мА');
  cbIeee.Items.Add('10 мА');
end;

function EditPxiMx248Channel(AOwner: TComponent; AChannel: Integer;
  var AEnabled, AAmplifier, AInputMode, ARangeIndex, ALpfIndex,
  AIeeeCurrent: string): Boolean;
var
  lDialog: TPxiMx248ChannelDialog;
begin
  lDialog := TPxiMx248ChannelDialog.Create(AOwner);
  try
    lDialog.Caption := Format('MX-248 — канал %d', [AChannel]);
    lDialog.chkEnabled.Checked := SameText(AEnabled, 'True');
    lDialog.chkAmplifier.Checked := SameText(AAmplifier, 'True');
    if SameText(AInputMode, 'single-ended') then
      lDialog.cbInputMode.ItemIndex := 1
    else
      lDialog.cbInputMode.ItemIndex := 0;
    lDialog.cbGain.ItemIndex := StrToIntDef(ARangeIndex, 0);
    lDialog.cbLpf.ItemIndex := StrToIntDef(ALpfIndex, 0);
    if AIeeeCurrent = '10' then lDialog.cbIeee.ItemIndex := 2
    else if AIeeeCurrent = '4' then lDialog.cbIeee.ItemIndex := 1
    else lDialog.cbIeee.ItemIndex := 0;
    Result := lDialog.ShowModal = mrOk;
    if not Result then Exit;
    AEnabled := BoolToStr(lDialog.chkEnabled.Checked, True);
    AAmplifier := BoolToStr(lDialog.chkAmplifier.Checked, True);
    if lDialog.cbInputMode.ItemIndex = 1 then AInputMode := 'single-ended'
    else AInputMode := 'differential';
    ARangeIndex := IntToStr(lDialog.cbGain.ItemIndex);
    ALpfIndex := IntToStr(lDialog.cbLpf.ItemIndex);
    case lDialog.cbIeee.ItemIndex of
      1: AIeeeCurrent := '4';
      2: AIeeeCurrent := '10';
    else
      AIeeeCurrent := 'off';
    end;
  finally
    lDialog.Free;
  end;
end;

end.
