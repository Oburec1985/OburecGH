// Модуль для работы с файлами. Реализует класс, который позволяет в TMainMenu
// автоматически создавать менюху с выбором  recently opened files.
// В событии этого подменю OnClick нужно вызывать метод файлового манагера
// GetClickItem чтобы узнать имя кликнутого файла и делать с ним "чо хошь"
unit ufileMng;

interface
uses Windows,  SysUtils, Forms, Classes,Menus,shellapi, dialogs, inifiles;
 type
  testFunction = function(str:string):boolean;

  // класс для открывания недвних файлов
  cFileMng = class
  private
    // Имя файла из которого загружается спсок недавних файлов
    m_Filename:string;
    fclick:tNotifyevent;
    clickname:string;
    menuitem:TMenuItem;
  public
    // Функция, которая проверяет нужно ли отображать считанный из файла пункт в меню
    TestFunc:testFunction;
    menuname:string; // строка определяет к какому подменю будет конектиться
    // индикатор того, что был кликнут недавний файл. не сбрасывается в фелс автоматически!!!
    bclick:boolean;
    // список имен файлов
    m_RecentFiles:TStringList;
    m_menu:TMainMenu;
  private
    procedure OnOpenClick(sender:tobject);
    // проверяет все подменю item-а на наличие меню с названием menuname
    // в параметр menu возвращается найденное подменю
    function CheckMenuItem(item:TMenuItem;var menu:tmenuitem):boolean;
    // Ищет в подменю переданое в качестве параметра сабитем с именем 'Recently opened files'
    // и добавляет в него сабитемы с названиями файла
    // у каждого добавленного сабитема процедура onClick делает кликнуты итем первым в списке
    procedure LincToMainMenu(var menu:TMenuItem);
  public
    // Узнать имя кликнутого итема
    function GetClickItem:string;
    // Добавить имя файла в список строк
    constructor Create(Filename:string;var menu:TMainMenu;name:string; testProc:testFunction);
    // Добавить имя файла в список строк
    destructor Destroy;
    // Добавить имя файла в список строк
    procedure AddfilePath(filename:string);
    // Сохранить имена файлов
    procedure Save;
  end;
  // добавляет к строке путь запущенного приложения и проверяет наличие файла
  function TestRecentWithAppDir(str:string):boolean;
  // проверяет наличие файла
  function TestRecentFiles(str:string):boolean;
  function ExecuteFile(name:string):boolean;
  function GetFullPath(shortName:string):string;

implementation

const filescount = 8;

function TestRecentWithAppDir(str:string):boolean;
begin
  result:=fileexists(extractfiledir(Application.ExeName)+str);
end;

function TestRecentFiles(str:string):boolean;
begin
  result:=fileexists(str);
end;

function GetFullPath(shortName:string):string;
var
  fullpath:pwidechar;
  buffer:string;
  i:integer;
  ch:char;
begin
  setlength(buffer,255);
  GetFullPathName(@shortname,255,@Buffer[1],fullpath);
  ch:=char(0);
  i:=pos(ch,buffer);
  setlength(buffer,i-1);
  result:=buffer;
end;


// Функция открывает файл связанной с ним (по умолчанию) программой
function ExecuteFile(name:string):boolean;
var folder:string;
    res:integer;
begin
  folder:=extractfiledir(name);
  result:=false;
  res:= ShellExecute(0,'open',
                    @(name[1]),
                    nil,
                    @folder[1],
                    SW_SHOWNORMAL);
  case res of
    0: showmessage('Не хватает памяти открыть файл');
    ERROR_FILE_NOT_FOUND: showmessage('Не найден файл');
    ERROR_PATH_NOT_FOUND: showmessage('Путь не найден');
    ERROR_BAD_FORMAT: showmessage('Невозможно открыть этот тип файла).');
    SE_ERR_ACCESSDENIED: showmessage('В данный момент доступ к файлу запрещен');
    SE_ERR_ASSOCINCOMPLETE: showmessage('неправильное имя файла');
    SE_ERR_DDEBUSY: showmessage('файл открыт кем-то');
    SE_ERR_DDEFAIL: showmessage('The DDE transaction failed.');
    SE_ERR_DDETIMEOUT: showmessage('The DDE transaction could not be completed because the request timed out.');
    SE_ERR_DLLNOTFOUND: showmessage('The specified dynamic-link library (DLL) was not found.');
    SE_ERR_NOASSOC: showmessage('Не известно приложение для открытия файла или недоступен принтер');
    SE_ERR_OOM: showmessage('Не хватает памяти для завершения операции');
    SE_ERR_SHARE: showmessage('доступ запрещен');
  else
    if res>32 then
      result:=true;
  end;
end;

function cFileMng.CheckMenuItem(item:TMenuItem;var menu:tmenuitem):boolean;
var subitem:tmenuitem;
    i:integer;
begin
  result:=false;
  if item.caption=menuname then
  begin
    menu:=item;
    result:=true;
    exit;
  end;
  for I := 0 to item.Count - 1 do
  begin
    // поиск на текущем уровне меню
    if item.Items[i].Caption=menuname then
    begin
      result:=true;
      menu:=item;
      exit;
    end;
    subitem:=item.Items[i];
    // поиск меню с названием menuname в подменю
    if CheckMenuItem(subitem,menu) then
      result:=true;
  end;
end;

destructor cFileMng.Destroy;
var
  i:integer;
  str:string;
begin
  Save;
  m_RecentFiles.Destroy;
end;

constructor cFileMng.Create(filename:string;var menu:TMainMenu;name:string;testproc:testFunction);
var
  i, num:integer;
  f:tinifile;
  str:string;
begin
  testfunc:=testproc;
  m_filename:=filename;
  m_menu:=menu;
  menuname:=name;
  menuitem:=nil;
  // поиск подменю у которого есть нужное меню.
  for I := 0 to menu.Items.Count - 1 do
  begin
    if CheckMenuItem(menu.Items[i],menuitem) then
    begin
      break;
    end;
  end;
  if menuitem=nil then
  begin
    showmessage('Не найдено подменю '+menuname);
    exit;
  end;
  m_RecentFiles:=TStringList.Create;
  m_RecentFiles.Sorted:=false;
  m_RecentFiles.Duplicates:=dupIgnore;
  if ExtractFileExt(filename)<>'.ini' then
  begin
    m_RecentFiles.LoadFromFile(filename);
  end
  else
  begin
    f:=TIniFile.Create(filename);
    num:=0;
    str:=f.ReadString(menu.name,'Path'+inttostr(num),'');
    while str<>'' do
    begin
      m_RecentFiles.Add(str);
      inc(num);
    end;
    f.Destroy;
  end;
  i:=0;
  // Очистка листа от пустых строк
  while I <= m_recentfiles.Count - 1 do
  begin
    if (m_recentfiles.Strings[i]='') then
    begin
      m_recentfiles.Delete(i);
      i:=0;
    end
    else
      inc(i,1);
  end;
  fclick:=OnOpenClick;
  LincToMainMenu(menuitem);
end;

procedure cFileMng.OnOpenClick(sender:tobject);
var replaceitem,mitem:tmenuitem;
    replaceindex:integer;
begin
  // Обмен итемами (0 и тот по которому щелкнули(должен всплыть наверх))
  mitem:=tmenuitem(sender).Parent;
  replaceitem:=mitem.items[0];
  replaceindex:=tmenuitem(sender).MenuIndex;
  mitem.Remove(tmenuitem(sender));
  mitem.Insert(0,tmenuitem(sender));
  mitem.Remove(replaceitem);
  mitem.Insert(replaceindex,replaceitem);
  bclick:=true;
  clickname:=tmenuitem(sender).caption;
  if assigned(mitem.onClick) then
    mitem.onClick(mitem)
end;

function cFileMng.GetClickItem:string;
var ind:integer;
begin
  // не разобрался откуда, но в caption добавляются символы "&"
  ind:=pos('&',clickname);
  delete(clickname,ind,1);
  result:=clickname;
end;

procedure cFileMng.LincToMainMenu(var menu:TMenuItem);
var i:integer;
    Menuitem,subitem:tmenuitem;
    b:boolean;
    str:string;
begin
  Menuitem:=menu.Find(menuname);
  if menuitem=nil then
    menuitem:=menu;
  for I := 0 to m_recentfiles.Count - 1 do
  begin
    str:=m_recentfiles.Strings[i];
    b:=true;
    if assigned(testfunc) then
      b:=testfunc(str);
    if b then
    begin
      subitem:=tmenuitem.Create(menu);
      subitem.Caption:=str;
      subitem.OnClick:=fclick;
      menuitem.Add(subitem);
    end;
  end;
end;

// Добавить имя файла в список строк
procedure cFileMng.AddfilePath(filename:string);
var i:integer;
begin
  // Если такой файл уже есть в списке, то его нужно вытащить наверх списка
  for I := 0 to m_recentfiles.count - 1 do
  begin
    if (filename=m_recentfiles.strings[i]) then
    begin
      m_recentfiles.Exchange(0,i);
      exit;
    end;
  end;
  m_recentfiles.Add(filename);
  if m_recentfiles.Count>filescount then
  begin
    m_recentfiles.Delete(0);
  end;
end;

// Сохранить имена файлов
procedure cFileMng.Save;
var
  str:string;
  I: Integer;
  f:tinifile;
begin
  if extractfileext(m_filename)='.ini' then
  begin
    f:=TIniFile.Create(m_filename);
    for I := 0 to m_RecentFiles.Count - 1 do
    begin
      str:=m_RecentFiles.Strings[i];
      f.WriteString(menuitem.name,'Path'+inttostr(i),str);
    end;
    f.Destroy;
  end
  else
  begin
    m_RecentFiles.SaveToFile(m_Filename);
  end;
end;

end.
