unit uFrmSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, IniFiles, uRCFunc;

type
  TFrmSettings = class(TForm)
    PortLabel: TLabel;
    BaudLabel: TLabel;
    ParityLabel: TLabel;
    IntervalLabel: TLabel;
    InputTagLabel: TLabel;
    OutputTagLabel: TLabel;
    PortCombo: TComboBox;
    BaudCombo: TComboBox;
    ParityCombo: TComboBox;
    IntervalEdit: TEdit;
    InputTagEdit: TEdit;
    OutputTagEdit: TEdit;
    OkBtn: TButton;
    CancelBtn: TButton;
    InputCommandLabel: TLabel;
    InputCommandEdit: TEdit;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    FIniPath: string;
    procedure LoadSettings;
    procedure SaveSettings;
  public
  end;

implementation

{$R *.dfm}

procedure TFrmSettings.FormCreate(Sender: TObject);
begin
  FIniPath := ExtractFileDir(string(getRConfig)) + '\plgCalibratorPascal.ini';
  LoadSettings;
end;

procedure TFrmSettings.LoadSettings;
var
  lIni: TIniFile;
begin
  lIni := TIniFile.Create(FIniPath);
  try
    PortCombo.Text := lIni.ReadString('Connection', 'Port', 'COM3');
    BaudCombo.Text := IntToStr(lIni.ReadInteger('Connection', 'BaudRate', 19200));
    case lIni.ReadInteger('Connection', 'Parity', 1) of
      0: ParityCombo.ItemIndex := 0; // None
      1: ParityCombo.ItemIndex := 1; // Odd
      2: ParityCombo.ItemIndex := 2; // Even
    else
      ParityCombo.ItemIndex := 1;
    end;
    IntervalEdit.Text := IntToStr(lIni.ReadInteger('Connection', 'Interval', 500));
    InputTagEdit.Text := lIni.ReadString('Tags', 'InputTag', 'Pascal_Pressure');
    OutputTagEdit.Text := lIni.ReadString('Tags', 'OutputTag', 'Pascal_Range');
    InputCommandEdit.Text := lIni.ReadString('Tags', 'InputCommand', 'PRESSURE? 2');
  finally
    lIni.Free;
  end;
end;

procedure TFrmSettings.SaveSettings;
var
  lIni: TIniFile;
  lParity: Integer;
begin
  lIni := TIniFile.Create(FIniPath);
  try
    lIni.WriteString('Connection', 'Port', PortCombo.Text);
    lIni.WriteInteger('Connection', 'BaudRate', StrToIntDef(BaudCombo.Text, 19200));
    case ParityCombo.ItemIndex of
      0: lParity := 0; // None
      1: lParity := 1; // Odd
      2: lParity := 2; // Even
    else
      lParity := 1;
    end;
    lIni.WriteInteger('Connection', 'Parity', lParity);
    lIni.WriteInteger('Connection', 'Interval', StrToIntDef(IntervalEdit.Text, 500));
    lIni.WriteString('Tags', 'InputTag', InputTagEdit.Text);
    lIni.WriteString('Tags', 'OutputTag', OutputTagEdit.Text);
    lIni.WriteString('Tags', 'InputCommand', InputCommandEdit.Text);
  finally
    lIni.Free;
  end;
end;

procedure TFrmSettings.OkBtnClick(Sender: TObject);
begin
  SaveSettings;
  ModalResult := mrOk;
end;

end.