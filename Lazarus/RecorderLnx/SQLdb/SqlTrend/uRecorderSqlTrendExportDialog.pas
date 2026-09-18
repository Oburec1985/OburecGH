unit uRecorderSqlTrendExportDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, CheckLst, Dialogs,
  uRecorderSqlTrendModel;

procedure ShowRecorderSqlTrendExportDialog(AOwner: TComponent;
  AComponent: TRecorderSqlTrendComponent; AFromUtc, AToUtc: TDateTime);

implementation

uses
  DateUtils, IniFiles, uRecorderMeraPaths, uRecorderSqlDbTypes,
  uRecorderSqlDbRepository, uRecorderSqlDbRuntime,
  uRecorderSqlTrendCsvExport, uRecorderSqlTrendMeraExport;

type
  TSqlTrendExportFormat = (stefCsv, stefMera);

  TRecorderSqlTrendExportDialog = class(TForm)
  private
    fComponent: TRecorderSqlTrendComponent;
    fChannels: TCheckListBox;
    fCloseButton: TButton;
    fExportButton: TButton;
    fFormatCombo: TComboBox;
    fFromEdit: TEdit;
    fToEdit: TEdit;
    fListDirectory: string;
    fBusy: Boolean;
    procedure AddButton(const ACaption: string; ATop: Integer;
      AClick: TNotifyEvent);
    procedure SelectAllClick(Sender: TObject);
    procedure SelectNoneClick(Sender: TObject);
    procedure SaveListClick(Sender: TObject);
    procedure LoadListClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure LoadChannels;
    procedure SelectCurrentLines;
    function SelectedChannels: TStringList;
    function ReadUtcInterval(out AFromUtc, AToUtc: TDateTime): Boolean;
    procedure SaveListDirectory(const AFileName: string);
    procedure CloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ExportFinished(const AFileName, AError: string);
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderSqlTrendComponent;
      AFromUtc, AToUtc: TDateTime);
  end;

  TSqlTrendExportThread = class(TThread)
  private
    fOwner: TRecorderSqlTrendExportDialog;
    fConfigFileName: string;
    fNames: TStringList;
    fFromUtc, fToUtc: TDateTime;
    fFileName: string;
    fFormat: TSqlTrendExportFormat;
    fError: string;
    procedure Deliver;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderSqlTrendExportDialog;
      const AConfigFileName: string; ANames: TStrings;
      AFromUtc, AToUtc: TDateTime; const AFileName: string;
      AFormat: TSqlTrendExportFormat);
    destructor Destroy; override;
  end;

const
  CListSection = 'SqlTrendExport';
  CListDirectoryKey = 'LastListDirectory';
  CTimeFormat = 'dd.mm.yyyy hh:nn:ss';

procedure ShowRecorderSqlTrendExportDialog(AOwner: TComponent;
  AComponent: TRecorderSqlTrendComponent; AFromUtc, AToUtc: TDateTime);
var
  lDialog: TRecorderSqlTrendExportDialog;
begin
  if AComponent = nil then Exit;
  lDialog := TRecorderSqlTrendExportDialog.CreateDialog(AOwner, AComponent,
    AFromUtc, AToUtc);
  try
    lDialog.ShowModal;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderSqlTrendExportDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderSqlTrendComponent; AFromUtc, AToUtc: TDateTime);
var
  lLabel: TLabel;
  lIni: TIniFile;
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  Caption := 'Экспорт SQL-тренда в CSV';
  Position := poOwnerFormCenter;
  BorderStyle := bsDialog;
  ClientWidth := 650;
  ClientHeight := 565;
  OnCloseQuery := @CloseQuery;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 12, 420, 20);
  lLabel.Caption := 'Каналы из SQL БД (порядок столбцов — порядок списка):';
  fChannels := TCheckListBox.Create(Self);
  fChannels.Parent := Self;
  fChannels.SetBounds(12, 36, 455, 367);
  fChannels.Anchors := [akLeft, akTop, akRight, akBottom];
  AddButton('Выбрать все', 36, @SelectAllClick);
  AddButton('Снять выбор', 70, @SelectNoneClick);
  AddButton('Сохранить список', 120, @SaveListClick);
  AddButton('Загрузить список', 154, @LoadListClick);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 414, 160, 20);
  lLabel.Caption := 'От (UTC):';
  fFromEdit := TEdit.Create(Self);
  fFromEdit.Parent := Self;
  fFromEdit.SetBounds(12, 436, 210, 27);
  fFromEdit.Text := FormatDateTime(CTimeFormat, AFromUtc);
  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(238, 414, 160, 20);
  lLabel.Caption := 'До (UTC):';
  fToEdit := TEdit.Create(Self);
  fToEdit.Parent := Self;
  fToEdit.SetBounds(238, 436, 210, 27);
  fToEdit.Text := FormatDateTime(CTimeFormat, AToUtc);
  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 468, 430, 20);
  lLabel.Caption := 'Формат времени: дд.мм.гггг чч:мм:сс (UTC)';

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 498, 80, 20);
  lLabel.Caption := 'Формат:';
  fFormatCombo := TComboBox.Create(Self);
  fFormatCombo.Parent := Self;
  fFormatCombo.SetBounds(92, 494, 200, 27);
  fFormatCombo.Style := csDropDownList;
  fFormatCombo.Items.Add('CSV');
  fFormatCombo.Items.Add('WinПОС / MERA');
  fFormatCombo.ItemIndex := 0;
  fExportButton := TButton.Create(Self);
  fExportButton.Parent := Self;
  fExportButton.SetBounds(440, 528, 105, 28);
  fExportButton.Caption := 'Экспорт';
  fExportButton.Default := True;
  fExportButton.OnClick := @ExportClick;
  fCloseButton := TButton.Create(Self);
  fCloseButton.Parent := Self;
  fCloseButton.SetBounds(553, 528, 85, 28);
  fCloseButton.Caption := 'Закрыть';
  fCloseButton.Cancel := True;
  fCloseButton.ModalResult := mrCancel;

  fListDirectory := '';
  if FileExists(RecorderAppConfigFileName) then
  begin
    lIni := TIniFile.Create(RecorderAppConfigFileName);
    try
      fListDirectory := lIni.ReadString(CListSection, CListDirectoryKey, '');
    finally
      lIni.Free;
    end;
  end;
  if not DirectoryExists(fListDirectory) then
    fListDirectory := ExtractFilePath(RecorderAppConfigFileName);
  LoadChannels;
  SelectCurrentLines;
end;

procedure TRecorderSqlTrendExportDialog.AddButton(const ACaption: string;
  ATop: Integer; AClick: TNotifyEvent);
var
  lButton: TButton;
begin
  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(477, ATop, 160, 28);
  lButton.Caption := ACaption;
  lButton.OnClick := AClick;
end;

procedure TRecorderSqlTrendExportDialog.LoadChannels;
var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
  lNames: TStringList;
  lError: string;
begin
  lConfig := TRecorderSqlDbConfig.Create;
  lNames := TStringList.Create;
  try
    lConfig.LoadFromFile(fComponent.ConfigFileName);
    if not RecorderSqlServerAvailable(lConfig, lError) then
      raise Exception.Create(lError);
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    try
      lRepository.ListSignalNames(lNames);
      fChannels.Items.Assign(lNames);
    finally
      lRepository.Free;
    end;
  except
    on E: Exception do
      MessageDlg('Каналы SQL БД', E.Message, mtWarning, [mbOK], 0);
  end;
  lNames.Free;
  lConfig.Free;
end;

procedure TRecorderSqlTrendExportDialog.SelectCurrentLines;
var
  lIndex, lItem: Integer;
  lName: string;
begin
  if fComponent.ActiveDisplay = nil then Exit;
  for lIndex := 0 to fComponent.ActiveDisplay.LineCount - 1 do
  begin
    lName := Trim(fComponent.ActiveDisplay.Lines[lIndex].TagName);
    if lName = '' then Continue;
    lItem := fChannels.Items.IndexOf(lName);
    if lItem < 0 then lItem := fChannels.Items.Add(lName);
    fChannels.Checked[lItem] := fComponent.ActiveDisplay.Lines[lIndex].Visible;
  end;
end;

function TRecorderSqlTrendExportDialog.SelectedChannels: TStringList;
var
  lIndex: Integer;
begin
  Result := TStringList.Create;
  for lIndex := 0 to fChannels.Count - 1 do
    if fChannels.Checked[lIndex] then
      Result.Add(fChannels.Items[lIndex]);
end;

procedure TRecorderSqlTrendExportDialog.SelectAllClick(Sender: TObject);
var
  lIndex: Integer;
begin
  for lIndex := 0 to fChannels.Count - 1 do
    fChannels.Checked[lIndex] := True;
end;

procedure TRecorderSqlTrendExportDialog.SelectNoneClick(Sender: TObject);
var
  lIndex: Integer;
begin
  for lIndex := 0 to fChannels.Count - 1 do
    fChannels.Checked[lIndex] := False;
end;

procedure TRecorderSqlTrendExportDialog.SaveListDirectory(
  const AFileName: string);
var
  lIni: TIniFile;
begin
  fListDirectory := ExtractFilePath(ExpandFileName(AFileName));
  ForceDirectories(ExtractFilePath(RecorderAppConfigFileName));
  lIni := TIniFile.Create(RecorderAppConfigFileName);
  try
    lIni.WriteString(CListSection, CListDirectoryKey, fListDirectory);
  finally
    lIni.Free;
  end;
end;

procedure TRecorderSqlTrendExportDialog.SaveListClick(Sender: TObject);
var
  lDialog: TSaveDialog;
  lNames: TStringList;
begin
  lNames := SelectedChannels;
  lDialog := TSaveDialog.Create(Self);
  try
    try
    if lNames.Count = 0 then
      raise Exception.Create('Выберите хотя бы один канал.');
    lDialog.Title := 'Сохранить список каналов экспорта';
    lDialog.Filter := 'Список каналов (*.txt)|*.txt';
    lDialog.DefaultExt := 'txt';
    lDialog.InitialDir := fListDirectory;
    if lDialog.Execute then
    begin
      lNames.SaveToFile(lDialog.FileName);
      SaveListDirectory(lDialog.FileName);
    end;
    except
      on E: Exception do MessageDlg('Список каналов', E.Message,
        mtError, [mbOK], 0);
    end;
  finally
    lDialog.Free;
    lNames.Free;
  end;
end;

procedure TRecorderSqlTrendExportDialog.LoadListClick(Sender: TObject);
var
  lDialog: TOpenDialog;
  lNames: TStringList;
  lIndex, lItem: Integer;
  lName: string;
begin
  lNames := TStringList.Create;
  lDialog := TOpenDialog.Create(Self);
  try
    try
    lDialog.Title := 'Загрузить список каналов экспорта';
    lDialog.Filter := 'Список каналов (*.txt)|*.txt|Все файлы|*.*';
    lDialog.InitialDir := fListDirectory;
    if not lDialog.Execute then Exit;
    lNames.LoadFromFile(lDialog.FileName);
    SelectNoneClick(nil);
    for lIndex := 0 to lNames.Count - 1 do
    begin
      lName := Trim(lNames[lIndex]);
      if lName = '' then Continue;
      lItem := fChannels.Items.IndexOf(lName);
      if lItem < 0 then lItem := fChannels.Items.Add(lName);
      fChannels.Checked[lItem] := True;
    end;
    SaveListDirectory(lDialog.FileName);
    except
      on E: Exception do MessageDlg('Список каналов', E.Message,
        mtError, [mbOK], 0);
    end;
  finally
    lDialog.Free;
    lNames.Free;
  end;
end;

function TRecorderSqlTrendExportDialog.ReadUtcInterval(
  out AFromUtc, AToUtc: TDateTime): Boolean;
var
  lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.ShortDateFormat := 'dd.mm.yyyy';
  lFormat.DateSeparator := '.';
  lFormat.LongTimeFormat := 'hh:nn:ss';
  lFormat.TimeSeparator := ':';
  Result := TryStrToDateTime(Trim(fFromEdit.Text), AFromUtc, lFormat) and
    TryStrToDateTime(Trim(fToEdit.Text), AToUtc, lFormat) and
    (AToUtc > AFromUtc);
end;

procedure TRecorderSqlTrendExportDialog.ExportClick(Sender: TObject);
var
  lDialog: TSaveDialog;
  lNames: TStringList;
  lFromUtc, lToUtc: TDateTime;
  lFormat: TSqlTrendExportFormat;
  lTask: TSqlTrendExportThread;
begin
  if fBusy then Exit;
  lNames := SelectedChannels;
  lDialog := TSaveDialog.Create(Self);
  try
    try
    if lNames.Count = 0 then
      raise Exception.Create('Выберите хотя бы один канал.');
    if not ReadUtcInterval(lFromUtc, lToUtc) then
      raise Exception.Create('Укажите корректный интервал UTC: от < до.');
    if fFormatCombo.ItemIndex = 1 then
    begin
      lFormat := stefMera;
      lDialog.Filter := 'WinПОС / MERA (*.mera)|*.mera';
      lDialog.DefaultExt := 'mera';
      lDialog.FileName := 'sql-trend.mera';
    end
    else
    begin
      lFormat := stefCsv;
      lDialog.Filter := 'CSV (*.csv)|*.csv';
      lDialog.DefaultExt := 'csv';
      lDialog.FileName := 'sql-trend.csv';
    end;
    lDialog.Title := 'Экспорт SQL-тренда';
    lDialog.InitialDir := fListDirectory;
    if not lDialog.Execute then Exit;
    lTask := TSqlTrendExportThread.Create(Self, fComponent.ConfigFileName,
      lNames, lFromUtc, lToUtc, lDialog.FileName, lFormat);
    fBusy := True;
    fExportButton.Enabled := False;
    fCloseButton.Enabled := False;
    Caption := 'Экспорт SQL-тренда — выполнение...';
    try
      lTask.Start;
    except
      lTask.Free;
      fBusy := False;
      fExportButton.Enabled := True;
      fCloseButton.Enabled := True;
      Caption := 'Экспорт SQL-тренда в CSV / MERA';
      raise;
    end;
    except
      on E: Exception do MessageDlg('Экспорт SQL-тренда', E.Message,
        mtError, [mbOK], 0);
    end;
  finally
    lDialog.Free;
    lNames.Free;
  end;
end;

procedure TRecorderSqlTrendExportDialog.CloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not fBusy;
end;

procedure TRecorderSqlTrendExportDialog.ExportFinished(
  const AFileName, AError: string);
begin
  fBusy := False;
  fExportButton.Enabled := True;
  fCloseButton.Enabled := True;
  Caption := 'Экспорт SQL-тренда в CSV / MERA';
  if AError <> '' then
    MessageDlg('Экспорт SQL-тренда', AError, mtError, [mbOK], 0)
  else
    MessageDlg('Экспорт SQL-тренда', 'Экспорт сохранён: ' + AFileName,
      mtInformation, [mbOK], 0);
end;

constructor TSqlTrendExportThread.Create(AOwner: TRecorderSqlTrendExportDialog;
  const AConfigFileName: string; ANames: TStrings;
  AFromUtc, AToUtc: TDateTime; const AFileName: string;
  AFormat: TSqlTrendExportFormat);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fConfigFileName := AConfigFileName;
  fNames := TStringList.Create;
  fNames.Assign(ANames);
  fFromUtc := AFromUtc;
  fToUtc := AToUtc;
  fFileName := AFileName;
  fFormat := AFormat;
end;

destructor TSqlTrendExportThread.Destroy;
begin
  fNames.Free;
  inherited Destroy;
end;

procedure TSqlTrendExportThread.Execute;
begin
  try
    if fFormat = stefMera then
      ExportSqlTrendMera(fConfigFileName, fNames, fFromUtc, fToUtc, fFileName)
    else
      ExportSqlTrendCsv(fConfigFileName, fNames, fFromUtc, fToUtc, fFileName);
  except
    on E: Exception do fError := E.Message;
  end;
  TThread.Queue(nil, @Deliver);
end;

procedure TSqlTrendExportThread.Deliver;
var
  lReportedFileName: string;
begin
  lReportedFileName := fFileName;
  if fFormat = stefMera then
    lReportedFileName := IncludeTrailingPathDelimiter(
      ChangeFileExt(fFileName, '')) + ExtractFileName(fFileName);
  fOwner.ExportFinished(lReportedFileName, fError);
  Free;
end;

end.
