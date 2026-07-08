unit uRecorderMic185SettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Grids,
  uRecorderTags;

type
  TRecorderMic185SettingsForm = class(TForm)
    btnAdditional: TButton;
    btnApply: TButton;
    btnBalance: TButton;
    btnCancel: TButton;
    btnMetrology: TButton;
    btnOk: TButton;
    btnProperties: TButton;
    btnSelectAll: TButton;
    edAddress: TEdit;
    edPort: TEdit;
    edSerial: TEdit;
    edState: TEdit;
    edVersion: TEdit;
    gridChannels: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure btnAdditionalClick(Sender: TObject);
    procedure btnPropertiesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fRegistry: TRecorderTagRegistry;
    fSourceId: string;
    procedure FillGrid;
    procedure RefreshDeviceInfo;
    function SelectedChannelAddress: string;
  public
    procedure LoadSource(ARegistry: TRecorderTagRegistry; const ASourceId: string);
    function BuildSourceId: string;
  end;

function ApplyRecorderMic185SourceDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string): Boolean;

procedure SetRecorderMic185SettingsSelfTestActive(AActive: Boolean);

implementation

{$R *.lfm}

uses
  StrUtils, uRecorderMic185DataSource, uRecorderMic185AdditionalDialog,
  uRecorderMic185ChannelDialog, uRecorderConfiguredSourceEditor,
  uRecorderMic185DeviceInfoProbe;

var
  GRecorderMic185SettingsSelfTestActive: Boolean = False;

procedure SetRecorderMic185SettingsSelfTestActive(AActive: Boolean);
begin
  GRecorderMic185SettingsSelfTestActive := AActive;
end;

procedure TRecorderMic185SettingsForm.FormCreate(Sender: TObject);
begin
  gridChannels.ColCount := 10;
  gridChannels.FixedRows := 1;
  gridChannels.RowCount := 71;
  gridChannels.Cells[0, 0] := '№';
  gridChannels.Cells[1, 0] := 'Имя';
  gridChannels.Cells[2, 0] := 'Диап-н факт.';
  gridChannels.Cells[3, 0] := 'Аппарат. б-ка';
  gridChannels.Cells[4, 0] := 'Прогр. б-ка';
  gridChannels.Cells[5, 0] := 'Ед. изм-ния';
  gridChannels.Cells[6, 0] := 'Коммутация';
  gridChannels.Cells[7, 0] := 'Тип датчика';
  gridChannels.Cells[8, 0] := 'Канал термо';
  gridChannels.Cells[9, 0] := 'Сост. б-ки';
  FillGrid;
end;

procedure TRecorderMic185SettingsForm.FillGrid;
var
  I: Integer;
  lName: string;
begin
  for I := 1 to 70 do
  begin
    if I <= 64 then
      lName := Format('MIC183_185-{%d-%d}', [3, I])
    else if I <= 69 then
      lName := Format('MIC183_185-{%d-t%d}', [3, I - 64])
    else
      lName := 'MIC183_185-{3-uts}';
    gridChannels.Cells[0, I] := IntToStr(I);
    gridChannels.Cells[1, I] := lName;
    gridChannels.Cells[2, I] := '±5.000';
    gridChannels.Cells[3, I] := '0.000';
    gridChannels.Cells[4, I] := '0.000';
    if I <= 64 then
      gridChannels.Cells[5, I] := 'мВ'
    else if I <= 69 then
      gridChannels.Cells[5, I] := '°C'
    else
      gridChannels.Cells[5, I] := 'с';
    gridChannels.Cells[6, I] := 'Вход';
    gridChannels.Cells[7, I] := '-';
    gridChannels.Cells[8, I] := '1';
    gridChannels.Cells[9, I] := '-';
  end;
end;

procedure TRecorderMic185SettingsForm.LoadSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string);
var
  lHost: string;
  lPort: Word;
begin
  fRegistry := ARegistry;
  fSourceId := ASourceId;
  if not TryParseRecorderMic185SourceId(ASourceId, lHost, lPort) then
  begin
    lHost := MIC185DefaultHost;
    lPort := MIC185DefaultPort;
  end;
  edAddress.Text := lHost;
  edPort.Text := IntToStr(lPort);
  edSerial.Text := '';
  edVersion.Text := '';
  edState.Text := 'Норма';
  RefreshDeviceInfo;
end;

procedure TRecorderMic185SettingsForm.RefreshDeviceInfo;
var
  lAcquiring: Boolean;
  lErrorText: string;
  lPort: Integer;
  lSerialNumber: LongWord;
  lVersionText: string;
begin
  if not TryStrToInt(Trim(edPort.Text), lPort) then
    Exit;
  if (lPort < 1) or (lPort > 65535) then
    Exit;

  if RecorderMic185ProbeDeviceInfo(Trim(edAddress.Text), Word(lPort),
    lSerialNumber, lVersionText, lAcquiring, lErrorText, 3000) then
  begin
    if lSerialNumber <> 0 then
      edSerial.Text := IntToStr(lSerialNumber)
    else
      edSerial.Text := '';
    edVersion.Text := lVersionText;
    if lAcquiring then
      edState.Text := 'Опрос активен'
    else
      edState.Text := 'Подключён';
    Exit;
  end;

  edSerial.Text := '';
  edVersion.Text := '';
  if lErrorText <> '' then
    edState.Text := lErrorText
  else if Trim(edAddress.Text) <> '' then
    edState.Text := 'Нет связи';
end;

function TRecorderMic185SettingsForm.BuildSourceId: string;
var
  lPort: Integer;
begin
  if not TryStrToInt(Trim(edPort.Text), lPort) then
    lPort := MIC185DefaultPort;
  Result := RecorderMic185SourceId(Trim(edAddress.Text), Word(lPort));
end;

function TRecorderMic185SettingsForm.SelectedChannelAddress: string;
var
  lRow: Integer;
begin
  lRow := gridChannels.Row;
  if lRow < 1 then
    lRow := 1;
  Result := gridChannels.Cells[1, lRow];
end;

procedure TRecorderMic185SettingsForm.btnAdditionalClick(Sender: TObject);
begin
  ShowRecorderMic185AdditionalDialog(Self);
end;

procedure TRecorderMic185SettingsForm.btnPropertiesClick(Sender: TObject);
var
  I: Integer;
  lAddress: string;
  lTag: TRecorderTag;
begin
  lTag := nil;
  lAddress := SelectedChannelAddress;
  if fRegistry <> nil then
    for I := 0 to fRegistry.TagCount - 1 do
      if SameText(fRegistry.Tags[I].SourceId, fSourceId) and
        SameText(fRegistry.Tags[I].Address, lAddress) then
      begin
        lTag := fRegistry.Tags[I];
        Break;
      end;
  ShowRecorderMic185ChannelDialog(Self, lTag);
end;

function ApplyRecorderMic185SourceDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string): Boolean;
var
  lForm: TRecorderMic185SettingsForm;
begin
  lForm := TRecorderMic185SettingsForm.Create(AOwner);
  try
    lForm.LoadSource(ARegistry, ASourceId);
    if GRecorderMic185SettingsSelfTestActive then
    begin
      Result := True;
      ANewSourceId := lForm.BuildSourceId;
      Exit;
    end;
    Result := lForm.ShowModal in [mrOk, mrYes];
    if Result then
      ANewSourceId := lForm.BuildSourceId
    else
      ANewSourceId := ASourceId;
  finally
    lForm.Free;
  end;
end;

type
  TRecorderMic185ConfiguredSourceEditor = class(TInterfacedObject,
    IRecorderConfiguredSourceEditor)
  public
    function SupportsSource(const ASourceId, AModuleType: string): Boolean;
    function EditSource(AOwner: TComponent; ARegistry: TRecorderTagRegistry;
      const ASourceId: string; out ANewSourceId: string): Boolean;
  end;

function TRecorderMic185ConfiguredSourceEditor.SupportsSource(
  const ASourceId, AModuleType: string): Boolean;
begin
  Result := SameText(AModuleType, 'MIC183/185') or
    SameText(AModuleType, 'MIC185') or
    RecorderIsHardwareMic185TagSource(ASourceId);
end;

function TRecorderMic185ConfiguredSourceEditor.EditSource(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string): Boolean;
begin
  Result := ApplyRecorderMic185SourceDialog(AOwner, ARegistry, ASourceId,
    ANewSourceId);
end;

initialization
  RecorderRegisterConfiguredSourceEditor(TRecorderMic185ConfiguredSourceEditor.Create);

end.
