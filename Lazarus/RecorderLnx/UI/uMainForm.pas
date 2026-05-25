unit uMainForm;

{
  Модуль uMainForm

  Назначение:
    Главная форма RecorderLnx на раннем этапе разработки. Компоновка следует
    рабочему окну Recorder: сверху активные формуляры, в центре область
    формуляра, справа пульт состояния/команд, поиск и список тегов.

  Место в архитектуре:
    UI shell. Форма вызывает готовые core-модели TRecorderStateMachine и
    TRecorderRunControlSettings, но не содержит логики сбора данных, каналов,
    устройств, плагинов или записи.

  Ограничения:
    Список тегов и центральный формуляр пока являются заглушками. Подробная
    настройка открывается отдельной командой и будет расширяться после появления
    следующих core-моделей.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids, Buttons, ImgList,
  uRecorderStateMachine, uRecorderRunControlSettings, uRecorderUiTestData;

type
  TRecorderCommandIcon = (
    rciSettings,
    rciSave,
    rciStop,
    rciPreview,
    rciRecord,
    rciTrigger
  );

  { TMainForm }

  TMainForm = class(TForm)
    btnActiveForm: TButton;
    btnAutoForm: TButton;
    btnBaseForm: TButton;
    btnClearSearch: TButton;
    btnPreview: TSpeedButton;
    btnRecord: TSpeedButton;
    btnSaveConfig: TSpeedButton;
    btnSettings: TSpeedButton;
    btnStop: TSpeedButton;
    btnTrigger: TSpeedButton;
    edTagSearch: TEdit;
    ilCommandButtons: TImageList;
    lbState: TLabel;
    lbTags: TListBox;
    lbTime: TLabel;
    mmLog: TMemo;
    pnMain: TPanel;
    pnRight: TPanel;
    pnRightCommands: TPanel;
    pnRightStatus: TPanel;
    pnTagSearch: TPanel;
    pnToolbar: TPanel;
    sgFormular: TStringGrid;
    SplitterLog: TSplitter;
    procedure btnClearSearchClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnRecordClick(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnTriggerClick(Sender: TObject);
    procedure edTagSearchChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pnToolbarClick(Sender: TObject);
  private
    fStateMachine: TRecorderStateMachine;
    fRunSettings: TRecorderRunControlSettings;
    fProjectConfigDir: string;
    fRunControlFileName: string;

    { Добавляет строку в журнал с локальным временем. }
    procedure AddLog(const AMessage: string);

    { Добавляет bitmap-иконку в список ресурсов правого пульта. }
    function AddCommandImage(AIcon: TRecorderCommandIcon): Integer;

    { Назначает кнопке glyph из списка ресурсов формы. }
    procedure AssignCommandGlyph(AButton: TSpeedButton; AImageIndex: Integer);

    { Создает dev-структуру config/projects/default и дефолтный run-control.ini. }
    procedure EnsureDevConfig;

    { Возвращает базовый каталог проекта для dev-конфигурации.

      При запуске из Lazarus рабочий каталог обычно равен каталогу проекта.
      При запуске exe из lib/x86_64-win64 поднимаемся на два уровня выше.
    }
    function GetDevProjectDir: string;

    { Заполняет центральный формуляр и список тегов временными демонстрационными данными. }
    { Загружает настройки запуска/остановки из проектного каталога. }
    procedure LoadRunSettings;

    { Сохраняет настройки запуска/остановки в проектный каталог. }
    procedure SaveRunSettings;

    { Применяет фильтр поиска к списку тегов-заглушек. }
    procedure RebuildTagList(const AFilter: string);

    { Настраивает командные кнопки правого пульта как кнопки-символы. }
    procedure SetupCommandButtons;

    { Обновляет текстовый индикатор состояния из fStateMachine.State. }
    procedure UpdateStateView;

    { Единая обработка ошибок команд UI. }
    procedure LogCommandError(const ACommand: string; E: Exception);

    { Обработчик события ядра: фиксирует переход состояния в журнале и на форме. }
    procedure StateMachineStateChanged(ASender: TObject;
      AOldState, ANewState: TRecorderState);
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

const
  CDefaultProjectConfigDir = 'config' + DirectorySeparator + 'projects' +
    DirectorySeparator + 'default';
  CRunControlFileName = 'run-control.ini';

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := 'RecorderLnx - config/projects/default';

  fStateMachine := TRecorderStateMachine.Create;
  fStateMachine.OnStateChanged := @StateMachineStateChanged;

  fRunSettings := TRecorderRunControlSettings.Create;
  fProjectConfigDir := IncludeTrailingPathDelimiter(GetDevProjectDir) +
    CDefaultProjectConfigDir;
  fRunControlFileName := IncludeTrailingPathDelimiter(fProjectConfigDir) + CRunControlFileName;

  SetupCommandButtons;
  FillPlaceholderFormular(sgFormular);
  RebuildTagList('');
  EnsureDevConfig;
  LoadRunSettings;
  UpdateStateView;
  AddLog('RecorderLnx started.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fRunSettings);
  FreeAndNil(fStateMachine);
end;

procedure TMainForm.pnToolbarClick(Sender: TObject);
begin

end;

procedure TMainForm.btnPreviewClick(Sender: TObject);
begin
  try
    fStateMachine.StartPreview(rscManual);
  except
    on E: Exception do
      LogCommandError('Preview', E);
  end;
end;

procedure TMainForm.btnRecordClick(Sender: TObject);
begin
  try
    fRunSettings.RequireValid;
    fStateMachine.StartRecord(fRunSettings.StartCondition);
  except
    on E: Exception do
      LogCommandError('Record', E);
  end;
end;

procedure TMainForm.btnTriggerClick(Sender: TObject);
begin
  try
    fStateMachine.StartConditionMet;
  except
    on E: Exception do
      LogCommandError('Trigger', E);
  end;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  try
    fStateMachine.Stop;
  except
    on E: Exception do
      LogCommandError('Stop', E);
  end;
end;

procedure TMainForm.btnSaveConfigClick(Sender: TObject);
begin
  try
    SaveRunSettings;
    AddLog('Project run-control config saved: ' + fRunControlFileName);
  except
    on E: Exception do
      LogCommandError('Save config', E);
  end;
end;

procedure TMainForm.btnSettingsClick(Sender: TObject);
begin
  AddLog('Settings dialog placeholder: detailed project settings will be added after core models.');
end;

procedure TMainForm.btnClearSearchClick(Sender: TObject);
begin
  edTagSearch.Text := '';
end;

procedure TMainForm.edTagSearchChange(Sender: TObject);
begin
  RebuildTagList(edTagSearch.Text);
end;

procedure TMainForm.AddLog(const AMessage: string);
begin
  mmLog.Lines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + AMessage);
end;

function TMainForm.AddCommandImage(AIcon: TRecorderCommandIcon): Integer;
var
  lBitmap: TBitmap;
  lPoints: array[0..2] of TPoint;
begin
  lBitmap := TBitmap.Create;
  try
    lBitmap.SetSize(24, 24);
    lBitmap.PixelFormat := pf24bit;
    lBitmap.TransparentColor := clFuchsia;
    lBitmap.Transparent := True;

    lBitmap.Canvas.Brush.Color := clFuchsia;
    lBitmap.Canvas.FillRect(Rect(0, 0, 24, 24));
    lBitmap.Canvas.Pen.Color := clBlack;
    lBitmap.Canvas.Pen.Width := 2;
    lBitmap.Canvas.Brush.Color := clBlack;

    case AIcon of
      rciSettings:
        begin
          lBitmap.Canvas.Pen.Color := clGray;
          lBitmap.Canvas.Ellipse(8, 8, 16, 16);
          lBitmap.Canvas.Line(12, 3, 12, 7);
          lBitmap.Canvas.Line(12, 17, 12, 21);
          lBitmap.Canvas.Line(3, 12, 7, 12);
          lBitmap.Canvas.Line(17, 12, 21, 12);
          lBitmap.Canvas.Line(5, 5, 8, 8);
          lBitmap.Canvas.Line(16, 16, 19, 19);
          lBitmap.Canvas.Line(19, 5, 16, 8);
          lBitmap.Canvas.Line(8, 16, 5, 19);
          lBitmap.Canvas.Brush.Color := clSilver;
          lBitmap.Canvas.Ellipse(10, 10, 14, 14);
        end;
      rciSave:
        begin
          lBitmap.Canvas.Brush.Color := clSkyBlue;
          lBitmap.Canvas.Rectangle(5, 4, 19, 20);
          lBitmap.Canvas.Brush.Color := clWhite;
          lBitmap.Canvas.Rectangle(8, 6, 16, 10);
          lBitmap.Canvas.Brush.Color := clNavy;
          lBitmap.Canvas.Rectangle(8, 14, 16, 19);
        end;
      rciStop:
        begin
          lBitmap.Canvas.Brush.Color := clBlack;
          lBitmap.Canvas.Rectangle(8, 8, 16, 16);
        end;
      rciPreview:
        begin
          lBitmap.Canvas.Brush.Color := clNavy;
          lPoints[0] := Point(8, 6);
          lPoints[1] := Point(18, 12);
          lPoints[2] := Point(8, 18);
          lBitmap.Canvas.Polygon(lPoints);
        end;
      rciRecord:
        begin
          lBitmap.Canvas.Brush.Color := clRed;
          lBitmap.Canvas.Pen.Color := clMaroon;
          lBitmap.Canvas.Ellipse(7, 7, 17, 17);
        end;
      rciTrigger:
        begin
          lBitmap.Canvas.Pen.Color := clBlue;
          lBitmap.Canvas.Pen.Width := 2;
          lBitmap.Canvas.Line(3, 15, 7, 15);
          lBitmap.Canvas.Line(7, 15, 9, 8);
          lBitmap.Canvas.Line(9, 8, 13, 19);
          lBitmap.Canvas.Line(13, 19, 16, 10);
          lBitmap.Canvas.Line(16, 10, 21, 10);
        end;
    end;

    Result := ilCommandButtons.AddMasked(lBitmap, clFuchsia);
  finally
    lBitmap.Free;
  end;
end;

procedure TMainForm.AssignCommandGlyph(AButton: TSpeedButton; AImageIndex: Integer);
begin
  ilCommandButtons.GetBitmap(AImageIndex, AButton.Glyph);
end;

procedure TMainForm.EnsureDevConfig;
var
  lAppConfigDir: string;
  lAppConfigFileName: string;
  lAppConfig: TStringList;
begin
  ForceDirectories(fProjectConfigDir);

  lAppConfigDir := IncludeTrailingPathDelimiter(GetDevProjectDir) + 'config';
  ForceDirectories(lAppConfigDir);
  lAppConfigFileName := IncludeTrailingPathDelimiter(lAppConfigDir) + 'app.ini';

  if not FileExists(lAppConfigFileName) then
  begin
    lAppConfig := TStringList.Create;
    try
      lAppConfig.Add('[Application]');
      lAppConfig.Add('DefaultProjectConfigDir=projects/default');
      lAppConfig.Add('TimeSource=PC');
      lAppConfig.Add('');
      lAppConfig.Add('[Plugins]');
      lAppConfig.Add('; Plugin list will be added later');
      lAppConfig.SaveToFile(lAppConfigFileName);
    finally
      lAppConfig.Free;
    end;
  end;

  if not FileExists(fRunControlFileName) then
    fRunSettings.SaveToFile(fRunControlFileName);
end;

function TMainForm.GetDevProjectDir: string;
begin
  Result := IncludeTrailingPathDelimiter(GetCurrentDir);

  if FileExists(Result + 'RecorderLnx.lpi') then
    Exit;

  Result := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
    '..' + DirectorySeparator + '..');
  Result := IncludeTrailingPathDelimiter(Result);
end;

procedure TMainForm.LoadRunSettings;
begin
  if FileExists(fRunControlFileName) then
  begin
    fRunSettings.LoadFromFile(fRunControlFileName);
    AddLog('Project run-control config loaded: ' + fRunControlFileName);
  end;
end;

procedure TMainForm.SaveRunSettings;
begin
  ForceDirectories(fProjectConfigDir);
  fRunSettings.SaveToFile(fRunControlFileName);
end;

procedure TMainForm.RebuildTagList(const AFilter: string);
begin
  lbTags.Items.BeginUpdate;
  try
    FillPlaceholderTagList(lbTags.Items, AFilter);
  finally
    lbTags.Items.EndUpdate;
  end;
end;

procedure TMainForm.SetupCommandButtons;
var
  lSettingsImage: Integer;
  lSaveImage: Integer;
  lStopImage: Integer;
  lPreviewImage: Integer;
  lRecordImage: Integer;
  lTriggerImage: Integer;
begin
  ilCommandButtons.Clear;
  ilCommandButtons.Width := 24;
  ilCommandButtons.Height := 24;

  lSettingsImage := AddCommandImage(rciSettings);
  lSaveImage := AddCommandImage(rciSave);
  lStopImage := AddCommandImage(rciStop);
  lPreviewImage := AddCommandImage(rciPreview);
  lRecordImage := AddCommandImage(rciRecord);
  lTriggerImage := AddCommandImage(rciTrigger);

  btnSettings.Caption := '';
  AssignCommandGlyph(btnSettings, lSettingsImage);
  btnSettings.Hint := 'Settings';
  btnSettings.ShowHint := True;

  btnSaveConfig.Caption := '';
  AssignCommandGlyph(btnSaveConfig, lSaveImage);
  btnSaveConfig.Hint := 'Save current config';
  btnSaveConfig.ShowHint := True;

  btnStop.Caption := '';
  AssignCommandGlyph(btnStop, lStopImage);
  btnStop.Hint := 'Stop';
  btnStop.ShowHint := True;

  btnPreview.Caption := '';
  AssignCommandGlyph(btnPreview, lPreviewImage);
  btnPreview.Hint := 'View';
  btnPreview.ShowHint := True;

  btnRecord.Caption := '';
  AssignCommandGlyph(btnRecord, lRecordImage);
  btnRecord.Hint := 'Record';
  btnRecord.ShowHint := True;

  btnTrigger.Caption := '';
  AssignCommandGlyph(btnTrigger, lTriggerImage);
  btnTrigger.Hint := 'Trigger / condition met';
  btnTrigger.ShowHint := True;

  btnClearSearch.Caption := 'X';
  btnClearSearch.Hint := 'Clear tag search';
  btnClearSearch.ShowHint := True;
end;

procedure TMainForm.UpdateStateView;
begin
  lbState.Caption := TRecorderStateMachine.StateToString(fStateMachine.State);
  lbTime.Caption := '00:00:00';

  case fStateMachine.State of
    rsStop:
      pnRightStatus.Color := clSilver;
    rsPreviewArmed, rsPreview, rsRecordArmed:
      pnRightStatus.Color := clYellow;
    rsRecord:
      pnRightStatus.Color := clLime;
  end;

  lbState.Font.Color := clBlack;
  lbState.ParentColor := True;
  lbTime.Font.Color := clBlack;
  lbTime.ParentColor := True;
end;

procedure TMainForm.LogCommandError(const ACommand: string; E: Exception);
begin
  AddLog(ACommand + ' failed: ' + E.Message);
end;

procedure TMainForm.StateMachineStateChanged(ASender: TObject;
  AOldState, ANewState: TRecorderState);
begin
  UpdateStateView;
  AddLog(Format('State changed: %s -> %s',
    [TRecorderStateMachine.StateToString(AOldState),
     TRecorderStateMachine.StateToString(ANewState)]));
end;

end.
