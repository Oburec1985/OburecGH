
[Setup]
AppName=BlEng
AppVerName=BlEng 0.5
; защита от переустановки запущенной версии
AppMutex=BlEng
DefaultDirName={pf}\Mera\BladeEngine
DefaultGroupName=Mera
UninstallDisplayIcon={app}\BlEng.exe
OutputDir=output
OutputBaseFilename=BlEng-installer

[Types]
Name: "full"; Description: "Полная установка"
Name: "BladeEngine"; Description: "BladeEngine"
Name: "custom"; Description: "Выборочная установка"; Flags: iscustom

[Components]
Name: "program"; Description: "Программа для расчета вибраций лопаток"; Types: full BladeEngine custom; Flags: fixed
Name: "zipmaster"; Description: "ZipMaster - компонент для генерации отчета"; Types: full
Name: "FireBird"; Description: "FireBird - база данных по тревогам"; Types: full

[Files]
Source: "source\BlEng.exe"; DestDir: "{app}"; Components: program
Source: "source\DelZip179.dll"; DestDir: "{app}"; Components: program
Source: "source\gds32.dll"; DestDir: "{app}"; Components: program
Source: "source\files\utils\fastmm\FastMM_FullDebugMode.dll"; DestDir: "{app}"; Components: program
Source: "source\_Cleanup.bat"; DestDir: "{app}"; Components: program

; Hardware
Source: "source\files\utils\hardware\AdvLib.dll" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\DEVAPI.DLL" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\devapi81.dll" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\m1xxx.dll" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\M2070.dll" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\M2081.dll" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\M2081lop.dll" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\Mxxxx.dll" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\MFC42.DLL" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\msvcrt.dll" ; DestDir: "{app}"; Components: program
Source: "source\files\utils\hardware\msvcp60.dll" ;DestDir: "{app}"; Components: program
; файлы прошивок
Source: "source\files\utils\hardware\M2070\*.*";DestDir: "{app}\M2070\";Components: program;Flags: ignoreversion
Source: "source\files\utils\hardware\M2081\*.*";DestDir: "{app}\M2081\";Components: program;Flags: ignoreversion
; драйверы
Source: "source\files\utils\hardware\vxd\*.*";DestDir: "{sys}\vmm32\";Components: program; Flags: ignoreversion
Source: "source\files\utils\hardware\sys\*.*";DestDir: "{sys}\drivers\"; Components: program; Flags: ignoreversion

; Утилиты __________________________________________________________________________________________________________________
Source: "source\files\utils\zipmaster\zm190setup0113.exe" ; DestDir: "{app}\files\utils\install\zipmaster\"; Components: zipmaster
Source: "source\files\utils\zipmaster\unins000.exe" ; DestDir: "{app}\files\utils\install\zipmaster\"; Components: zipmaster
; база данных
Source: "source\files\utils\FireBird\Firebird_ODBC_2.0.0.150_Win32.exe" ; DestDir: "{app}\files\utils\install\FireBird\"; Components: FireBird
Source: "source\files\utils\FireBird\Firebird-2.5.0.26074_1_Win32.exe" ; DestDir: "{app}\files\utils\install\FireBird\"; Components: FireBird
Source: "source\files\utils\FireBird\db.fdb" ; DestDir: "{app}\files\BASE\"; Components: FireBird
; файл шаблон отчета __________________________________________________________________________________________________________________
Source: "source\files\Reports\Templates\SensorRep.ods"; DestDir: "{app}\files\Reports\Templates"; Components: program
; Иконки
Source: "source\files\icons\BladesIcon.bmp" ; DestDir: "{app}\files\icons\"; Components: program
; конфигурационные файлы 3d компонента ________________________________________________________________________________________________
Source: "source\files\3d\UIConfig.ini" ; DestDir: "{app}\files\3d\"; Components: program
Source: "source\files\3d\resources.ini" ; DestDir: "{app}\files\3d\"; Components: program
; пути к файлам для отрисовки 3d ______________________________________________________________________________________________________
Source: "source\files\3d\meshes\turbina_insts_1Blade.OBR" ; DestDir: "{app}\files\3d\meshes\"; Components: program
Source: "source\files\3d\meshes\turbina_insts.OBR" ; DestDir: "{app}\files\3d\meshes\"; Components: program
; пути к текстурам
Source: "source\files\3d\meshes\tex\Metal1.bmp" ; DestDir: "{app}\files\3d\meshes\tex\"; Components: program
Source: "source\files\3d\meshes\tex\Metal.bmp" ; DestDir: "{app}\files\3d\meshes\tex\"; Components: program
Source: "source\files\3d\meshes\tex\Metal.jpg" ; DestDir: "{app}\files\3d\meshes\tex\"; Components: program
; Файлы примеры __________________________________________________________________________________________________________________
Source: "source\files\данные\SunRise_te016.bld" ; DestDir: "{app}\files\данные"; Components: program
Source: "source\files\данные\xmlCfg_26.02.11.xml" ; DestDir: "{app}\files\данные"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\sunrise16.sdt" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\0.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\1.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\2.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\3.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\4.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\5.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\6.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\7.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\8.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\9.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\10.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\11.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\12.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\13.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\14.dat" ; DestDir: "{app}\files\данные\sunrise16_1\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\15.dat" ; DestDir: "{app}\files\данные"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\16.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\17.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\18.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\19.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program
Source: "source\files\данные\sdt\sunrise16_1\20.dat" ; DestDir: "{app}\files\данные\sunrise16_1"; Components: program

; конфигурационные файлы ______________________________________________________________________________________________________________
Source: "source\files\BldEngCfgPath.cfg" ; DestDir: "{app}\files"; Components: program
Source: "source\files\Cfgfiles\GenChartCfg.cfg"; DestDir: "{app}\files\Cfgfiles"; Components: program
Source: "source\files\Cfgfiles\Main.ini"; DestDir: "{app}\files\Cfgfiles"; Components: program
Source: "source\files\Cfgfiles\GenFormCfg.Ini"; DestDir: "{app}\files\Cfgfiles"; Components: program
Source: "source\files\Cfgfiles\helpfiles.cfg"; DestDir: "{app}\files\Cfgfiles"; Components: program
Source: "source\files\Cfgfiles\RecentFiles.cfg"; DestDir: "{app}\files\Cfgfiles"; Components: program
Source: "source\files\Cfgfiles\Services.Ini" ; DestDir: "{app}\files\Cfgfiles"; Components: program
; хелпы файлы __________________________________________________________________________________________________________________
Source: "source\files\Документация\Шаблон отчета.xls"; DestDir: "{app}\files\Документация"; Components: program
Source: "source\files\Документация\BladeProcessor_Guide.doc"; DestDir: "{app}\files\Документация"; Components: program
; инсталяционные файлы ________________________________________________________________________________________________________________
Source: "source\files\install\Readme.txt"; DestDir: "{app}"; Flags: isreadme; Components: program

[Registry]
Root: HKLM; Subkey: "Software\Mera"; Flags: uninsdeletekeyifempty
Root: HKLM; Subkey: "Software\Mera\BlEng"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\Mera\BlEng"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"
Root: HKLM; Subkey: "Software\Mera\BlEng"; ValueType: string; ValueName: "Version"; ValueData: "1.00.0b"

[Run]
Filename: "{sys}\vmm32\wdreg.exe";   Parameters: "-vxd install"; Check: IsComponentSelected('program');  Flags: runminimized  skipifdoesntexist
Filename: "{sys}\drivers\wdreg.exe"; Parameters:" -name ""KPTMI"" remove";  Check: IsComponentSelected('program');  Flags: runminimized  skipifdoesntexist
Filename: "{sys}\drivers\wdreg.exe"; Parameters:" -name ""KPLOP"" remove";  Check: IsComponentSelected('program');  Flags: runminimized  skipifdoesntexist
Filename: "{sys}\drivers\wdreg.exe"; Parameters:" -name ""KPTMI"" install"; Check: IsComponentSelected('program');  Flags: runminimized  skipifdoesntexist
Filename: "{sys}\drivers\wdreg.exe"; Parameters:" -name ""KPLOP"" install"; Check: IsComponentSelected('program');  Flags: runminimized  skipifdoesntexist

[UninstallRun]
Filename: "{sys}\vmm32\wdreg.exe"; Parameters: "-vxd delete";  Flags: runminimized skipifdoesntexist
Filename: "{sys}\drivers\wdreg.exe"; Parameters:" -file KPTMI.sys remove";  Flags: runminimized  skipifdoesntexist
Filename: "{sys}\drivers\wdreg.exe"; Parameters:" -file KPLOP.sys remove";  Flags: runminimized  skipifdoesntexist

[Icons]
Name: "{group}\BldEng"; Filename: "{app}\BlEng.exe"
Name: "{userdesktop}\BlEng"; Filename: "{app}\BlEng.exe" ;WorkingDir: "{app}"; IconFilename: {app}\files\icons\BladesIcon.bmp;

[Code]

procedure CurStepChanged(CurStep: TSetupStep);
var
  ZipName, FireBirdName:string;
  ResultCode:integer;
begin
  // инсталяция завершена
  if CurStep = ssDone then
  begin
    // попытка проинсталировать ZipMaster
    if IsComponentSelected('zipmaster') then
    begin
      ZipName:=WizardDirValue+'\files\utils\install\zipmaster\zm190setup0113.exe';
      if FileExists(ZipName) then
        Exec(ZipName, '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    end;
    // попытка проинсталировать ZipMaster
    if IsComponentSelected('FireBird') then
    begin
      FireBirdName:=WizardDirValue+'\files\utils\FireBird\install\Firebird-2.5.0.26074_1_Win32.exe';
      if FileExists(FireBirdName) then
        Exec(FireBirdName, '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      FireBirdName:=WizardDirValue+'\files\utils\install\FireBird\Firebird-2.5.0.26074_1_Win32.exe';
      if FileExists(FireBirdName) then
        Exec(FireBirdName, '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    end;
  end;
end;

{
procedure WordButtonOnClick(Sender: TObject);
var
  Word: Variant;
begin
  if MsgBox('Setup will now check whether Microsoft Word is running. Do you want to continue?', mbInformation, mb_YesNo) = idNo then
    Exit;
  // Try to get an active Word COM Automation object
  try
    Word := GetActiveOleObject('Word.Application');
  except
  end;
  if VarIsEmpty(Word) then
    MsgBox('Microsoft Word is not running.', mbInformation, mb_Ok)
  else
    MsgBox('Microsoft Word is running.', mbInformation, mb_Ok)
end;

procedure CreateButton(ALeft, ATop: Integer; ACaption: String; ANotifyEvent: TNotifyEvent);
begin
  with TButton.Create(WizardForm) do begin
    Left := ALeft;
    Top := ATop;
    Width := WizardForm.CancelButton.Width;
    Height := WizardForm.CancelButton.Height;
    Caption := ACaption;
    OnClick := ANotifyEvent;
    Parent := WizardForm.WelcomePage;
  end;
end;

// происходит перед созданием формы приветствия
procedure InitializeWizard();
var
  Left, Top, TopInc: Integer;
begin
  Left := WizardForm.WelcomeLabel2.Left;
  TopInc := WizardForm.CancelButton.Height + 8;
  Top := WizardForm.WelcomeLabel2.Top + WizardForm.WelcomeLabel2.Height - 4*TopInc;
  CreateButton(Left, Top, '&Word...', @WordButtonOnClick);
end;}
