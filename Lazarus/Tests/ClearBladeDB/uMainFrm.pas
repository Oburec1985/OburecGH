unit uMainFrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  FileUtil, LConvEncoding;

type
  TBladeInfo = record
    Name: string;
    DirPath: string;
    XmlPath: string;
    MeraCount: Integer;
    ExcelCount: Integer;
    HasUsefulFiles: Boolean;
  end;

  TStageInfo = record
    Name: string;
    DirPath: string;
    XmlPath: string;
    Blades: array of TBladeInfo;
    MeraCount: Integer;
    ExcelCount: Integer;
    HasUsefulFiles: Boolean;
  end;

  TTurbineInfo = record
    Name: string;
    DirPath: string;
    XmlPath: string;
    Stages: array of TStageInfo;
    MeraCount: Integer;
    ExcelCount: Integer;
    HasUsefulFiles: Boolean;
  end;

  { TMainFrm }

  TMainFrm = class(TForm)
    pnlTop: TPanel;
    lblPath: TLabel;
    edtPath: TEdit;
    btnSelectDir: TButton;
    btnScan: TButton;
    btnClean: TButton;
    btnTest: TButton;
    lstTurbines: TListBox;
    splSplit: TSplitter;
    txtLog: TMemo;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure btnScanClick(Sender: TObject);
    procedure btnCleanClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
  private
    fTurbines: array of TTurbineInfo;
    procedure Log(const lMsg: string);
    procedure ClearTurbines;
    procedure ScanDatabase(const lRootDir: string; lSilent: Boolean);
    procedure CleanDatabase(const lRootDir: string);
    procedure RunAutoTests;
    function CreateTestFile(const lFilePath: string): Boolean;
    function CreateTestDir(const lDirPath: string): Boolean;
  public
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.lfm}

{ TMainFrm }

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  // Русифицируем интерфейс из кода для совместимости с LCL UTF-8
  Caption := CP1251ToUTF8('Очистка пустых турбин ClearBladeDB');
  lblPath.Caption := CP1251ToUTF8('Путь к БД:');
  btnSelectDir.Caption := '...';
  btnScan.Caption := CP1251ToUTF8('Анализ');
  btnClean.Caption := CP1251ToUTF8('Очистить');
  btnTest.Caption := CP1251ToUTF8('Автотест');
  
  Log(CP1251ToUTF8('Программа готова к работе. Выберите путь к базе данных или запустите Автотест.'));
end;

procedure TMainFrm.btnSelectDirClick(Sender: TObject);
begin
  SelectDirectoryDialog1.InitialDir := edtPath.Text;
  if SelectDirectoryDialog1.Execute then
  begin
    edtPath.Text := SelectDirectoryDialog1.FileName;
    Log(CP1251ToUTF8('Выбран каталог: ') + edtPath.Text);
  end;
end;

procedure TMainFrm.btnScanClick(Sender: TObject);
begin
  ScanDatabase(edtPath.Text, False);
end;

procedure TMainFrm.btnCleanClick(Sender: TObject);
var
  lDlgRes: Integer;
begin
  lDlgRes := MessageDlg(
    CP1251ToUTF8('Подтверждение удаления'),
    CP1251ToUTF8('Вы действительно хотите безвозвратно удалить пустые турбины, пустые ступени и их XML файлы?'),
    mtConfirmation,
    [mbYes, mbNo],
    0
  );
  
  if lDlgRes = mrYes then
  begin
    CleanDatabase(edtPath.Text);
  end;
end;

procedure TMainFrm.btnTestClick(Sender: TObject);
begin
  RunAutoTests;
end;

procedure TMainFrm.Log(const lMsg: string);
begin
  txtLog.Lines.Add(lMsg);
  // Прокручиваем к последней строке
  txtLog.SelStart := Length(txtLog.Text);
end;

procedure TMainFrm.ClearTurbines;
begin
  SetLength(fTurbines, 0);
  btnClean.Enabled := False;
end;

procedure TMainFrm.ScanDatabase(const lRootDir: string; lSilent: Boolean);
var
  lSR: TSearchRec;
  lStageSR: TSearchRec;
  lBladeSR: TSearchRec;
  lFileSR: TSearchRec;
  lTurbinePath, lStagePath, lBladePath: string;
  lXmlPath, lStageXmlPath, lBladeXmlPath: string;
  lTurbineIndex, lStageIndex, lBladeIndex: Integer;
  lExt: string;
  lMeraCount, lExcelCount: Integer;
begin
  ClearTurbines;
  if not lSilent then
    Log(CP1251ToUTF8('Начало сканирования каталога: ') + lRootDir);

  if not DirectoryExists(lRootDir) then
  begin
    if not lSilent then
      Log(CP1251ToUTF8('Ошибка: Каталог не существует: ') + lRootDir);
    Exit;
  end;

  if FindFirst(lRootDir + DirectorySeparator + '*', faAnyFile, lSR) = 0 then
  begin
    repeat
      // Проверяем, является ли объект папкой и не служебной (. или ..)
      if ((lSR.Attr and faDirectory) <> 0) and (lSR.Name <> '.') and (lSR.Name <> '..') then
      begin
        lTurbinePath := lRootDir + DirectorySeparator + lSR.Name;
        lXmlPath := lRootDir + DirectorySeparator + lSR.Name + '.xml';

        // Уровень 1: Турбина
        if FileExists(lXmlPath) then
        begin
          lTurbineIndex := Length(fTurbines);
          SetLength(fTurbines, lTurbineIndex + 1);
          fTurbines[lTurbineIndex].Name := lSR.Name;
          fTurbines[lTurbineIndex].DirPath := lTurbinePath;
          fTurbines[lTurbineIndex].XmlPath := lXmlPath;
          fTurbines[lTurbineIndex].HasUsefulFiles := False;
          fTurbines[lTurbineIndex].MeraCount := 0;
          fTurbines[lTurbineIndex].ExcelCount := 0;
          SetLength(fTurbines[lTurbineIndex].Stages, 0);

          if not lSilent then
            Log(Format(CP1251ToUTF8('Найдена турбина: %s'), [lSR.Name]));

          // Уровень 2: Ступень
          if FindFirst(lTurbinePath + DirectorySeparator + '*', faAnyFile, lStageSR) = 0 then
          begin
            repeat
              if ((lStageSR.Attr and faDirectory) <> 0) and (lStageSR.Name <> '.') and (lStageSR.Name <> '..') then
              begin
                lStagePath := lTurbinePath + DirectorySeparator + lStageSR.Name;
                lStageXmlPath := lTurbinePath + DirectorySeparator + lStageSR.Name + '.xml';

                if FileExists(lStageXmlPath) then
                begin
                  lStageIndex := Length(fTurbines[lTurbineIndex].Stages);
                  SetLength(fTurbines[lTurbineIndex].Stages, lStageIndex + 1);
                  fTurbines[lTurbineIndex].Stages[lStageIndex].Name := lStageSR.Name;
                  fTurbines[lTurbineIndex].Stages[lStageIndex].DirPath := lStagePath;
                  fTurbines[lTurbineIndex].Stages[lStageIndex].XmlPath := lStageXmlPath;
                  fTurbines[lTurbineIndex].Stages[lStageIndex].HasUsefulFiles := False;
                  fTurbines[lTurbineIndex].Stages[lStageIndex].MeraCount := 0;
                  fTurbines[lTurbineIndex].Stages[lStageIndex].ExcelCount := 0;
                  SetLength(fTurbines[lTurbineIndex].Stages[lStageIndex].Blades, 0);

                  // Уровень 3: Лопатка
                  if FindFirst(lStagePath + DirectorySeparator + '*', faAnyFile, lBladeSR) = 0 then
                  begin
                    repeat
                      if ((lBladeSR.Attr and faDirectory) <> 0) and (lBladeSR.Name <> '.') and (lBladeSR.Name <> '..') then
                      begin
                        lBladePath := lStagePath + DirectorySeparator + lBladeSR.Name;
                        lBladeXmlPath := lStagePath + DirectorySeparator + lBladeSR.Name + '.xml';

                        if FileExists(lBladeXmlPath) then
                        begin
                          lBladeIndex := Length(fTurbines[lTurbineIndex].Stages[lStageIndex].Blades);
                          SetLength(fTurbines[lTurbineIndex].Stages[lStageIndex].Blades, lBladeIndex + 1);
                          fTurbines[lTurbineIndex].Stages[lStageIndex].Blades[lBladeIndex].Name := lBladeSR.Name;
                          fTurbines[lTurbineIndex].Stages[lStageIndex].Blades[lBladeIndex].DirPath := lBladePath;
                          fTurbines[lTurbineIndex].Stages[lStageIndex].Blades[lBladeIndex].XmlPath := lBladeXmlPath;
                          fTurbines[lTurbineIndex].Stages[lStageIndex].Blades[lBladeIndex].HasUsefulFiles := False;
                          fTurbines[lTurbineIndex].Stages[lStageIndex].Blades[lBladeIndex].MeraCount := 0;
                          fTurbines[lTurbineIndex].Stages[lStageIndex].Blades[lBladeIndex].ExcelCount := 0;

                          // Сканируем файлы в лопатке
                          lMeraCount := 0;
                          lExcelCount := 0;
                          if FindFirst(lBladePath + DirectorySeparator + '*', faAnyFile, lFileSR) = 0 then
                          begin
                            repeat
                              if (lFileSR.Attr and faDirectory) = 0 then
                              begin
                                lExt := LowerCase(ExtractFileExt(lFileSR.Name));
                                if lExt = '.mera' then
                                  Inc(lMeraCount)
                                else if Pos('xls', lExt) > 0 then
                                  Inc(lExcelCount);
                              end;
                            until FindNext(lFileSR) <> 0;
                            FindClose(lFileSR);
                          end;

                          fTurbines[lTurbineIndex].Stages[lStageIndex].Blades[lBladeIndex].MeraCount := lMeraCount;
                          fTurbines[lTurbineIndex].Stages[lStageIndex].Blades[lBladeIndex].ExcelCount := lExcelCount;
                          if (lMeraCount > 0) or (lExcelCount > 0) then
                          begin
                            fTurbines[lTurbineIndex].Stages[lStageIndex].Blades[lBladeIndex].HasUsefulFiles := True;
                            fTurbines[lTurbineIndex].Stages[lStageIndex].HasUsefulFiles := True;
                            fTurbines[lTurbineIndex].HasUsefulFiles := True;
                          end;

                          // Суммируем счетчики для ступени и турбины
                          Inc(fTurbines[lTurbineIndex].Stages[lStageIndex].MeraCount, lMeraCount);
                          Inc(fTurbines[lTurbineIndex].Stages[lStageIndex].ExcelCount, lExcelCount);
                          Inc(fTurbines[lTurbineIndex].MeraCount, lMeraCount);
                          Inc(fTurbines[lTurbineIndex].ExcelCount, lExcelCount);
                        end;
                      end;
                    until FindNext(lBladeSR) <> 0;
                    FindClose(lBladeSR);
                  end;
                end;
              end;
            until FindNext(lStageSR) <> 0;
            FindClose(lStageSR);
          end;

          if not lSilent then
          begin
            Log(Format(CP1251ToUTF8('  Ступеней: %d, Mera-файлов: %d, Excel-файлов: %d'),
              [Length(fTurbines[lTurbineIndex].Stages),
               fTurbines[lTurbineIndex].MeraCount,
               fTurbines[lTurbineIndex].ExcelCount]));
          end;
        end;
      end;
    until FindNext(lSR) <> 0;
    FindClose(lSR);
  end;

  // Обновляем список на форме
  lstTurbines.Items.Clear;
  for lTurbineIndex := 0 to Length(fTurbines) - 1 do
  begin
    if fTurbines[lTurbineIndex].HasUsefulFiles then
      lstTurbines.Items.Add(CP1251ToUTF8('[СОХРАНИТЬ] ') + fTurbines[lTurbineIndex].Name)
    else
      lstTurbines.Items.Add(CP1251ToUTF8('[УДАЛИТЬ] ') + fTurbines[lTurbineIndex].Name);

    for lStageIndex := 0 to Length(fTurbines[lTurbineIndex].Stages) - 1 do
    begin
      if fTurbines[lTurbineIndex].Stages[lStageIndex].HasUsefulFiles then
        lstTurbines.Items.Add(CP1251ToUTF8('  [СОХРАНИТЬ] ') + fTurbines[lTurbineIndex].Stages[lStageIndex].Name)
      else
        lstTurbines.Items.Add(CP1251ToUTF8('  [УДАЛИТЬ] ') + fTurbines[lTurbineIndex].Stages[lStageIndex].Name);
    end;
  end;

  if not lSilent then
  begin
    Log(Format(CP1251ToUTF8('Сканирование завершено. Найдено турбин: %d'), [Length(fTurbines)]));
    btnClean.Enabled := Length(fTurbines) > 0;
  end;
end;

procedure TMainFrm.CleanDatabase(const lRootDir: string);
var
  lTurbineIndex, lStageIndex: Integer;
  lDeletedTurbinesCount, lDeletedStagesCount: Integer;
  lSuccess: Boolean;
begin
  Log(CP1251ToUTF8('Начало очистки базы данных...'));
  lDeletedTurbinesCount := 0;
  lDeletedStagesCount := 0;

  for lTurbineIndex := 0 to Length(fTurbines) - 1 do
  begin
    if not fTurbines[lTurbineIndex].HasUsefulFiles then
    begin
      Log(Format(CP1251ToUTF8('Удаление турбины: %s'), [fTurbines[lTurbineIndex].Name]));
      
      // 1. Удаляем каталог турбины
      lSuccess := True;
      if DirectoryExists(fTurbines[lTurbineIndex].DirPath) then
      begin
        lSuccess := DeleteDirectory(fTurbines[lTurbineIndex].DirPath, False);
        if lSuccess then
          Log(CP1251ToUTF8('  Каталог турбины удален: ') + fTurbines[lTurbineIndex].DirPath)
        else
        begin
          Log(CP1251ToUTF8('  ОШИБКА удаления каталога турбины: ') + fTurbines[lTurbineIndex].DirPath);
          lSuccess := False;
        end;
      end;

      // 2. Удаляем XML-файл турбины
      if FileExists(fTurbines[lTurbineIndex].XmlPath) then
      begin
        if DeleteFile(fTurbines[lTurbineIndex].XmlPath) then
          Log(CP1251ToUTF8('  XML-файл турбины удален: ') + fTurbines[lTurbineIndex].XmlPath)
        else
        begin
          Log(CP1251ToUTF8('  ОШИБКА удаления XML-файла турбины: ') + fTurbines[lTurbineIndex].XmlPath);
          lSuccess := False;
        end;
      end;

      if lSuccess then
        Inc(lDeletedTurbinesCount);
    end
    else
    begin
      // Турбина сохраняется, но проверяем отдельные ступени
      for lStageIndex := 0 to Length(fTurbines[lTurbineIndex].Stages) - 1 do
      begin
        if not fTurbines[lTurbineIndex].Stages[lStageIndex].HasUsefulFiles then
        begin
          Log(Format(CP1251ToUTF8('  Удаление пустой ступени: %s внутри %s'), 
            [fTurbines[lTurbineIndex].Stages[lStageIndex].Name, fTurbines[lTurbineIndex].Name]));
          
          // 1. Удаляем каталог ступени
          lSuccess := True;
          if DirectoryExists(fTurbines[lTurbineIndex].Stages[lStageIndex].DirPath) then
          begin
            lSuccess := DeleteDirectory(fTurbines[lTurbineIndex].Stages[lStageIndex].DirPath, False);
            if lSuccess then
              Log(CP1251ToUTF8('    Каталог ступени удален: ') + fTurbines[lTurbineIndex].Stages[lStageIndex].DirPath)
            else
            begin
              Log(CP1251ToUTF8('    ОШИБКА удаления каталога ступени: ') + fTurbines[lTurbineIndex].Stages[lStageIndex].DirPath);
              lSuccess := False;
            end;
          end;

          // 2. Удаляем XML-файл ступени
          if FileExists(fTurbines[lTurbineIndex].Stages[lStageIndex].XmlPath) then
          begin
            if DeleteFile(fTurbines[lTurbineIndex].Stages[lStageIndex].XmlPath) then
              Log(CP1251ToUTF8('    XML-файл ступени удален: ') + fTurbines[lTurbineIndex].Stages[lStageIndex].XmlPath)
            else
            begin
              Log(CP1251ToUTF8('    ОШИБКА удаления XML-файла ступени: ') + fTurbines[lTurbineIndex].Stages[lStageIndex].XmlPath);
              lSuccess := False;
            end;
          end;

          if lSuccess then
            Inc(lDeletedStagesCount);
        end;
      end;
    end;
  end;

  Log(Format(CP1251ToUTF8('Очистка завершена. Удалено турбин: %d, удалено ступеней: %d'), 
    [lDeletedTurbinesCount, lDeletedStagesCount]));
  
  // Повторно сканируем, чтобы обновить UI
  ScanDatabase(lRootDir, False);
end;

function TMainFrm.CreateTestDir(const lDirPath: string): Boolean;
begin
  Result := ForceDirectories(lDirPath);
end;

// Заменяет или создает файл с некоторым контентом
function TMainFrm.CreateTestFile(const lFilePath: string): Boolean;
var
  lF: TextFile;
begin
  Result := False;
  try
    AssignFile(lF, lFilePath);
    Rewrite(lF);
    Writeln(lF, 'Dummy data for ClearBladeDB auto test');
    CloseFile(lF);
    Result := True;
  except
    // игнорируем ошибки
  end;
end;

procedure TMainFrm.RunAutoTests;
var
  lTestDbDir: string;
  lSuccess: Boolean;
  lScanOk: Boolean;
  lCleanOk: Boolean;
  lT1Index, lT2Index, lT3Index, lT4Index: Integer;
  lStageKeepIdx, lStageDelIdx: Integer;
  i, j: Integer;
begin
  Log(CP1251ToUTF8('--- ЗАПУСК АВТОТЕСТОВ ---'));
  lTestDbDir := ExtractFilePath(ParamStr(0)) + '_test_db_';

  // Очистим если остался с прошлого раза
  if DirectoryExists(lTestDbDir) then
    DeleteDirectory(lTestDbDir, False);

  lSuccess := True;
  
  // Создаем тестовую структуру
  // 1. Turbine_Keep (Все ступени имеют полезные файлы)
  lSuccess := lSuccess and CreateTestDir(lTestDbDir + DirectorySeparator + 'Turbine_Keep' + DirectorySeparator + 'Stage1' + DirectorySeparator + 'Blade1');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Keep.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Keep' + DirectorySeparator + 'Stage1.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Keep' + DirectorySeparator + 'Stage1' + DirectorySeparator + 'Blade1.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Keep' + DirectorySeparator + 'Stage1' + DirectorySeparator + 'Blade1' + DirectorySeparator + 'data.mera');

  // 2. Turbine_Mixed (ОДНА СТУПЕНЬ ПОЛЕЗНАЯ, ДРУГАЯ ПУСТАЯ. Полезная должна остаться, пустая удалиться!)
  lSuccess := lSuccess and CreateTestDir(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Keep' + DirectorySeparator + 'Blade1');
  lSuccess := lSuccess and CreateTestDir(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Delete' + DirectorySeparator + 'Blade1');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Mixed.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Keep.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Keep' + DirectorySeparator + 'Blade1.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Keep' + DirectorySeparator + 'Blade1' + DirectorySeparator + 'data.xlsx');
  
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Delete.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Delete' + DirectorySeparator + 'Blade1.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Delete' + DirectorySeparator + 'Blade1' + DirectorySeparator + 'readme.txt');

  // 3. Turbine_Delete (Вся турбина пустая)
  lSuccess := lSuccess and CreateTestDir(lTestDbDir + DirectorySeparator + 'Turbine_Delete' + DirectorySeparator + 'Stage1' + DirectorySeparator + 'Blade1');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Delete.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Delete' + DirectorySeparator + 'Stage1.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Delete' + DirectorySeparator + 'Stage1' + DirectorySeparator + 'Blade1.xml');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Delete' + DirectorySeparator + 'Stage1' + DirectorySeparator + 'Blade1' + DirectorySeparator + 'readme.txt');

  // 4. Turbine_Delete_Empty (Вообще без ступеней)
  lSuccess := lSuccess and CreateTestDir(lTestDbDir + DirectorySeparator + 'Turbine_Delete_Empty');
  lSuccess := lSuccess and CreateTestFile(lTestDbDir + DirectorySeparator + 'Turbine_Delete_Empty.xml');

  if not lSuccess then
  begin
    Log(CP1251ToUTF8('Ошибка: Не удалось создать тестовую БД'));
    Exit;
  end;

  Log(CP1251ToUTF8('Тестовая БД успешно создана. Сканирование...'));
  
  // Сканируем
  ScanDatabase(lTestDbDir, True);

  // Проверяем результаты сканирования
  lScanOk := Length(fTurbines) = 4;
  if lScanOk then
  begin
    lT1Index := -1; lT2Index := -1; lT3Index := -1; lT4Index := -1;
    for i := 0 to 3 do
    begin
      if fTurbines[i].Name = 'Turbine_Keep' then lT1Index := i
      else if fTurbines[i].Name = 'Turbine_Mixed' then lT2Index := i
      else if fTurbines[i].Name = 'Turbine_Delete' then lT3Index := i
      else if fTurbines[i].Name = 'Turbine_Delete_Empty' then lT4Index := i;
    end;

    lScanOk := (lT1Index <> -1) and (lT2Index <> -1) and (lT3Index <> -1) and (lT4Index <> -1);
    if lScanOk then
    begin
      lScanOk := lScanOk and (fTurbines[lT1Index].HasUsefulFiles = True);
      lScanOk := lScanOk and (fTurbines[lT2Index].HasUsefulFiles = True);
      lScanOk := lScanOk and (fTurbines[lT3Index].HasUsefulFiles = False);
      lScanOk := lScanOk and (fTurbines[lT4Index].HasUsefulFiles = False);

      // Проверяем ступени в Turbine_Mixed
      lStageKeepIdx := -1; lStageDelIdx := -1;
      for j := 0 to Length(fTurbines[lT2Index].Stages) - 1 do
      begin
        if fTurbines[lT2Index].Stages[j].Name = 'Stage_Keep' then lStageKeepIdx := j
        else if fTurbines[lT2Index].Stages[j].Name = 'Stage_Delete' then lStageDelIdx := j;
      end;

      lScanOk := lScanOk and (lStageKeepIdx <> -1) and (lStageDelIdx <> -1);
      if lScanOk then
      begin
        lScanOk := lScanOk and (fTurbines[lT2Index].Stages[lStageKeepIdx].HasUsefulFiles = True);
        lScanOk := lScanOk and (fTurbines[lT2Index].Stages[lStageDelIdx].HasUsefulFiles = False);
      end;
    end;
  end;

  if lScanOk then
    Log(CP1251ToUTF8('  [OK] Проверка сканирования пройдена'))
  else
  begin
    Log(CP1251ToUTF8('  [FAIL] Ошибка проверки сканирования'));
    lSuccess := False;
  end;

  // Запуск очистки
  Log(CP1251ToUTF8('Очистка тестовой БД...'));
  CleanDatabase(lTestDbDir);

  // Проверяем результаты удаления на диске
  lCleanOk := 
    // Turbine_Keep должна остаться
    DirectoryExists(lTestDbDir + DirectorySeparator + 'Turbine_Keep') and
    FileExists(lTestDbDir + DirectorySeparator + 'Turbine_Keep.xml') and
    
    // Turbine_Delete должна быть удалена
    not DirectoryExists(lTestDbDir + DirectorySeparator + 'Turbine_Delete') and
    not FileExists(lTestDbDir + DirectorySeparator + 'Turbine_Delete.xml') and
    
    // Turbine_Delete_Empty должна быть удалена
    not DirectoryExists(lTestDbDir + DirectorySeparator + 'Turbine_Delete_Empty') and
    not FileExists(lTestDbDir + DirectorySeparator + 'Turbine_Delete_Empty.xml') and
    
    // Turbine_Mixed должна остаться
    DirectoryExists(lTestDbDir + DirectorySeparator + 'Turbine_Mixed') and
    FileExists(lTestDbDir + DirectorySeparator + 'Turbine_Mixed.xml') and
    
    // Внутри Turbine_Mixed: Stage_Keep остается, а Stage_Delete и ее xml удаляются
    DirectoryExists(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Keep') and
    FileExists(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Keep.xml') and
    not DirectoryExists(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Delete') and
    not FileExists(lTestDbDir + DirectorySeparator + 'Turbine_Mixed' + DirectorySeparator + 'Stage_Delete.xml');

  if lCleanOk then
    Log(CP1251ToUTF8('  [OK] Проверка удаления файлов пройдена'))
  else
  begin
    Log(CP1251ToUTF8('  [FAIL] Ошибка проверки удаления файлов'));
    lSuccess := False;
  end;

  // Финальная очистка
  if DirectoryExists(lTestDbDir) then
    DeleteDirectory(lTestDbDir, False);

  if lSuccess and lScanOk and lCleanOk then
    Log(CP1251ToUTF8('=== АВТОТЕСТЫ УСПЕШНО ПРОЙДЕНЫ! ==='))
  else
    Log(CP1251ToUTF8('=== АВТОТЕСТЫ ПРОВАЛЕНЫ! ==='));
end;

end.
