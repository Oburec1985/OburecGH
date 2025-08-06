unit frmSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, sSkinManager, acAlphaHints, StdCtrls, sListBox, acAlphaImageList,
  sLabel, sComboBox, Buttons, sBitBtn, ExtCtrls, sSplitter, ImgList, sMemo,
  ComCtrls, sPageControl, sPanel, PluginClass, tags, blaccess, UCommon,
  sCheckBox, sEdit, sSpinEdit, IniFiles, Menus, StrUtils;

type
  TfrmTestSettings = class(TForm)
    SkinManager: TsSkinManager;
    sPageControl1: TsPageControl;
    sPanel1: TsPanel;
    sTabSheet1: TsTabSheet;
    sTabSheet2: TsTabSheet;
    memProtocol: TsMemo;
    imgList: TsAlphaImageList;
    sPanel2: TsPanel;
    sPanel3: TsPanel;
    sSplitter1: TsSplitter;
    btnOK: TsBitBtn;
    VirtualImageList: TsVirtualImageList;
    sLabel2: TsLabel;
    sLabel3: TsLabel;
    lbRecorder: TsListBox;
    lbPluginSelected: TsListBox;
    AlphaHints: TsAlphaHints;
    TimerCleanProt: TTimer;
    btnStart: TsBitBtn;
    sTabSheet3: TsTabSheet;
    memData: TsMemo;
    sLabel4: TsLabel;
    seAdr: TsSpinEdit;
    chbPort: TsCheckBox;
    chbStart: TsCheckBox;
    ImgListTabs: TsAlphaImageList;
    memMsg: TsMemo;
    sSplitter2: TsSplitter;
    PopupMenuMemMsg: TPopupMenu;
    J1: TMenuItem;
    edPort: TsEdit;
    sLabel1: TsLabel;
    PopupMenu1: TPopupMenu;
    J2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure TimerCleanProtTimer(Sender: TObject);
    procedure lbPluginSelectedDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbPluginSelectedDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure btnStartClick(Sender: TObject);
    procedure lbPluginSelectedKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure J1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure J2Click(Sender: TObject);
    procedure edPortKeyPress(Sender: TObject; var Key: Char);
  private
    fStarted: Boolean;
    fPlugin: TTestPlugin;
    {Динамический массив используемых в данный момент тегов}
    fTags: DynTagsArray;
    fUsedTags: DynTagsArray;
    procedure PrepareTagsView;
    procedure ExcludeDeletedTags;
    procedure LoadUsedTags(fname: string);
    procedure SaveUsedTags(fname: string);
    procedure GetUsedTags;
    procedure FillModbusList(txt: string);
    procedure SetStarted(const Value: boolean);

    {ссылка на объект plug-in`а}

    { Private declarations }
  public
    property Started: boolean read fStarted write SetStarted;
    function BeginConfigure: boolean;
    procedure EndConfigure(const Tags: DynTagsArray);
    procedure RecorderGotData;
    //procedure LoadIniSettings;
    //procedure SaveIniSettings;
    procedure Load_Tags;
    constructor Create(plugin: TTestPlugin); reintroduce;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  frmTestSettings: TfrmTestSettings;
  ConfigFileIniPatch: string;
  ConfigFileTxtPatch: string;
implementation

{$R *.dfm}

uses recorder;
{ TForm1 }

//------ Создание - удаление главного модуля ------------------------------------------------------------------------
constructor TfrmTestSettings.Create(plugin: TTestPlugin);
begin
  inherited Create(nil);
  memMsg.Clear;
  fPlugin := plugin;
  IUnknown(fPlugin)._AddRef; //!Очень важно, иначе плагин некорректно закрывается
  fStarted := false;
end;

destructor TfrmTestSettings.Destroy;
var
  i: integer;
begin
  for i := 0 to length(fTags) - 1 do
     fTags[i] := nil;
  fPlugin := nil;
  inherited;
end;
//------------------------------------------------------------------------------

//------ Создание - удаление главного окна ------------------------------------------------------------------------
procedure TfrmTestSettings.FormCreate(Sender: TObject);
begin
  memProtocol.Clear;
  memData.Clear;
  edPort.Text := '502';
end;

procedure TfrmTestSettings.FormDestroy(Sender: TObject);
begin
  //SaveIniSettings;
  SaveUsedTags(ConfigFileTxtPatch);
end;

procedure TfrmTestSettings.FormShow(Sender: TObject);
begin
  Load_Tags;
  try
  if chbStart.Checked then
     btnStartClick(self);
  except
  on e: exception do
    memMsg.Lines.Add(TimeToStr(time) + ' Ошибка запуска измерений! ' + e.Message);
  end;
end;
//------------------------------------------------------------------------------

//------ Сохранение - восстановление настроек в ini файл ------------------------------------------------------------------------
{procedure TfrmTestSettings.SaveIniSettings;
var
  f: TIniFile;
begin
  f := TIniFile.Create(ConfigFileIniPatch);
  try
  f.WriteBool(fPlugin.ConfigName + 'FormSettings', 'chbPort', chbPort.Checked);
  f.WriteBool(fPlugin.ConfigName + 'FormSettings', 'chbStart', chbStart.Checked);
  f.WriteString(fPlugin.ConfigName + 'FormSettings', 'Port', edPort.Text);
  f.WriteInteger(fPlugin.ConfigName + 'FormSettings', 'seAdr', seAdr.Value);
  finally
  FreeAndNil(f);
  end;
end;

procedure TfrmTestSettings.LoadIniSettings;
var
  f: TIniFile;
begin
  f := TIniFile.Create(ConfigFileIniPatch);
  try
  chbPort.Checked := f.ReadBool(fPlugin.ConfigName + 'FormSettings', 'chbPort', false);
  chbStart.Checked := f.ReadBool(fPlugin.ConfigName + 'FormSettings', 'chbStart', false);
  edPort.Text := f.ReadString(fPlugin.ConfigName + 'FormSettings', 'Port', '502');
  seAdr.Value := f.ReadInteger(fPlugin.ConfigName + 'FormSettings', 'seAdr', 1);
  finally
  FreeAndNil(f);
  end;
end;}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//----- КНОПКИ -------------------------------------------------------------------------
//----- Проверка на цифры -------------------------------------------------------------------------
procedure TfrmTestSettings.edPortKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', #8]) then
     Key := Char(0);
end;
//----- Старт - стоп просмотра рекордера -------------------------------------------------------------------------
procedure TfrmTestSettings.btnStartClick(Sender: TObject);
begin
   fStarted := not fStarted;

   if fStarted then
      begin
        fPlugin.StartMeasure;
      end else
      begin
        fPlugin.StopMeasure;
      end;
end;
//----- Если запуск просмотра из самого рекордера -------------------------------------------------------------------------
procedure TfrmTestSettings.SetStarted(const Value: boolean);
begin
  fStarted := Value;

  if fStarted then
      begin
        btnStart.ImageIndex := 3;
      end else
      begin
        btnStart.ImageIndex := 2;
      end;
end;
//------------------------------------------------------------------------------


//----- СПИСКИ ТЕГОВ -------------------------------------------------------------------------
//----- Метод подготовки формы к изменению конфигурации
function  TfrmTestSettings.BeginConfigure: boolean;
begin
  SetLength(FTags, 0);   //очистить список внутренний тегов
  Result:= true;
end;
//----- Метод подготовки формы после того, как конфигурация была изменена
procedure TfrmTestSettings.EndConfigure(const Tags: DynTagsArray);
var
  i: integer;
begin
  SetLength(FTags, Length(Tags));
  for i := Low(Tags) to High(Tags) do
  begin
    FTags[i] := Tags[i];
  end;

  PrepareTagsView;   //Обновление списка отображающего теги
  Load_Tags;
end;
//---- Метод подготовки формы после изменения списка тегов
procedure TfrmTestSettings.PrepareTagsView;
var
  i: integer;
begin
  lbRecorder.Clear;                      //Список тегов на форме очистить

  for i:= Low(FTags) to High(FTags) do   //и по всему списку ссылок на теги...
  begin
    lbRecorder.Items.Add(String(fTags[i].GetName)); //добавить элемент в список отображения
  end;
end;
//----- Добавлять тэги можно только в определенное окно -------------------------------------------------------------------------
procedure TfrmTestSettings.lbPluginSelectedDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = lbRecorder) and (lbRecorder.ItemIndex >= 0);
end;
//----- Перетащили тэг в список -------------------------------------------------------------------------
procedure TfrmTestSettings.lbPluginSelectedDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i: integer;
begin
for i := 0 to lbRecorder.Items.Count - 1 do
  if (lbRecorder.Selected[i]) and (lbPluginSelected.Items.IndexOf(lbRecorder.Items[i]) < 0) then
      lbPluginSelected.Items.Add(lbRecorder.Items[i]);
 GetUsedTags;
 SaveUsedTags(ConfigFileTxtPatch);
end;
//----- Удалили тэг из списка -------------------------------------------------------------------------
procedure TfrmTestSettings.lbPluginSelectedKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = VK_DELETE) then
    begin
      TListBox(Sender).DeleteSelected;
      GetUsedTags;

      SaveUsedTags(ConfigFileTxtPatch);
    end;
end;
//----- Процедура удаляет из списка Modbus переменных теги отсутствующие в Recorder'е
procedure TfrmTestSettings.ExcludeDeletedTags;
var
  i: integer;
begin
i := 0;
  while (i < lbPluginSelected.Count) do
      begin
      //Если тэг не найден в списке тэгов рекордера, то удаляем его из списка Modbus
      if (lbRecorder.Items.IndexOf(lbPluginSelected.Items[i]) < 0) then
         lbPluginSelected.Items.Delete(i)
         else
         inc(i);
      end;
end;
//----- Сохранение выбранных тегов в файл -------------------------------------------------------------------------
procedure TfrmTestSettings.SaveUsedTags(fname: string);
var
  fs: TFileStream;
  i: integer;
  tag: string;
  bytes: TBytes;
begin
 fs := TFileStream.Create(fname, fmCreate);
 try
 for i := 0 to lbPluginSelected.Count - 1 do
    begin
    tag := lbPluginSelected.Items[i] + #13#10;

    bytes := BytesOf(tag);
    bytes := TEncoding.Convert(TEncoding.Default, TEncoding.UTF8, bytes);
    fs.Write(bytes[0], length(bytes));
    end;
 finally
  FreeAndNil(fs);
 end;
end;
//----- Загрузка выбранных тегов из файла -------------------------------------------------------------------------
procedure TfrmTestSettings.Load_Tags;
begin
  if fileexists(ConfigFileTxtPatch) then
    LoadUsedTags(ConfigFileTxtPatch);
end;
//----- Загрузка выбранных тегов во внутренний рабочий массив тэгов -------------------------------------------------------------------------
procedure TfrmTestSettings.GetUsedTags;
var
  i, j, k: integer;
begin
 setlength(fUsedTags, 0);
 k := 0;

  for i := 0 to lbPluginSelected.Items.Count - 1 do
      begin
      for j := 0 to length(fTags) - 1 do
          begin
          if (String(fTags[j].GetName) = lbPluginSelected.Items[i]) then
              begin
              setlength(fUsedTags, k + 1);
              fUsedTags[k] := fTags[j];
              inc(k);
              break;
              end;
          end;
      end;
end;
//----- Загрузка сохраненных тегов из файла -------------------------------------------------------------------------
procedure TfrmTestSettings.LoadUsedTags(fname: string);
var
  txt: TBytes;
  fs: TFileStream;
  str: string;
begin
 lbPluginSelected.Clear;
 if not FileExists(fname) then Exit;

 fs := TFileStream.Create(fname, fmOpenRead);
 try
  setlength(txt, fs.Size);
  fs.Read(txt[0], fs.Size);
  str := TEncoding.UTF8.GetString(txt);
  FillModbusList(str);
 finally
 FreeAndNil(fs);
 end;
 ExcludeDeletedTags;
 GetUsedTags;
end;
//----- Загрузка сохраненных тегов из файла (удаляем каретку переноса строки) -------------------------------------------------------------------------
procedure TfrmTestSettings.FillModbusList(txt: string);
var
  tagname: string;
  p: cardinal;
  offs: cardinal;
  delimeter: string;
begin
  offs := 1;
  p := 1;
  delimeter := #13#10;
  lbPluginSelected.Clear;

  while p > 0 do
    begin
    p := PosEx(delimeter, txt, offs);
    if p > 0 then
       begin
       tagname := copy(txt, offs, p - offs);
       lbPluginSelected.Items.Add(tagname);
       end;
    offs := p + Cardinal(Length(delimeter));
    end;
end;
//------------------------------------------------------------------------------

//----- Рекордер получил данные, выбираем тэги из внутреннего массива тэгов -------------------------------------------------------------------------
procedure TfrmTestSettings.RecorderGotData;
var
 i: integer;
 value: double;
 name: string;
begin
  for i := 0 to length(fUsedTags) - 1 do
     begin
     value := GetLastValue(fUsedTags[i]);
     name := String(fUsedTags[i].GetName);

     memData.Lines.Add(name + ' = ' + floattostr(value));
     end;
end;
//------------------------------------------------------------------------------






procedure TfrmTestSettings.J1Click(Sender: TObject);
begin
  memMsg.Clear;
end;

procedure TfrmTestSettings.J2Click(Sender: TObject);
begin
  MemProtocol.Clear;
end;

//----- Очистка протоколов от переполнения -------------------------------------------------------------------------
procedure TfrmTestSettings.TimerCleanProtTimer(Sender: TObject);
begin
  memProtocol.Clear;
  memData.Clear;
end;




end.
