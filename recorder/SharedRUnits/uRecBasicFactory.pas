unit uRecBasicFactory;

// 2016 GatePlg
interface

uses
  recorder, windows, activex,
  cfreg, blaccess,
  messages,
  // Ole2,
  Classes,
  sysutils,
  dialogs,
  ShlObj,
  inifiles,
  forms,
  uRCFunc,
  uRecorderEvents,
  uEventTypes,
  ulogfile;

type
   // Интерфейс фабрики объектов VForm
  // Каждый тип фабрики должен иметь уникальный идентификатор типа GUID
  // ctrl+shift+G
  ICustomVFormInterface = interface
  ['{F6C43E4C-2FE3-4DEB-B01E-6AE28A10A59F}']
		// вернуть произвольное свойство tag - id того что хотим получить
		function GetCustomProperty(tag:integer):LPCSTR;stdcall;
		function SetCustomProperty(tag:integer; str:lpcstr):integer;stdcall;
		function GetCustomProperty2(obj:integer;prop: LPCSTR):LPCSTR;stdcall;
  end;

   // Интерфейс фабрики объектов VForm
  // Каждый тип фабрики должен иметь уникальный идентификатор типа GUID
  // ctrl+shift+G
  ICustomFactInterface = interface
  ['{119E2EA6-C7B5-4610-B29B-759DF8AAF471}']
		//function getChild(const i:DWORD):IVForm;stdcall;
    function getChild(const i: DWORD; var pIVForm: IVForm): HRESULT; stdcall;
  end;


  cRecBasicFactory = class;
  cRecBasicIFrm = class;

  TRecFrm = class(TForm)
  protected
    m_redraw: boolean;
  public
    m_f: cRecBasicFactory;
    m_init, m_firstShow: boolean;
    // приходится повторно сохранять т.к. иначе BoundRect сбрасывается при инициализации в 0
    m_bounds: trect;
  protected
    procedure doStart;virtual;
    // вызывается фабрикой при обновлении данных
    procedure UpdateData; virtual;
    procedure DoCreate; override;
    procedure DoShow; override;
    procedure Resizing(State: TWindowState); override;
    function getIRecorder: irecorder;
  public
    procedure InitSize(b: trect); virtual;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); virtual;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); virtual;
  end;

  TRecFrmEx = class
  public
    WinClass: TWndClass;
    m_init, m_firstShow: boolean;
    // приходится повторно сохранять т.к. иначе BoundRect сбрасывается при инициализации в 0
    m_bounds: trect;
    R: irecorder;
    m_master: cRecBasicIFrm;
    handle: thandle;
  protected
    // function DoCreate: integer;
    procedure DoShow;
    procedure Resizing(State: TWindowState);
  public
    procedure InitSize(b: trect); virtual;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR);
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR);
  end;

  cRecBasicFactory = class(TObject, IInterface, ICustomFormFactory, ICustomFactInterface)
  public
    m_Guid: TGUID;
    m_lRefCount: integer;
  protected
    m_name, m_picname: string;
    m_CompList: TList;
  protected
    m_pOwner: IUnknown;
  protected
    procedure ExcludeComp(comp: TObject);
  public
    PROcedure setOwner(p_own:IUnknown);
    procedure doUpdateData;virtual;
    constructor create;
    procedure doInit;
    destructor destroy; override;
    // удаление форм созданых фабрикой. Вызывается в методе destroy
    procedure doDestroyForms; virtual;
    function doCreateForm: cRecBasicIFrm; virtual; abstract;
    procedure doSetDefSize(var pSize: SIZE); virtual;
    procedure doAfterLoad;virtual;
    // когда Recorder загрузил конфиги;
    procedure doRecorderInit;virtual;
    procedure doStart;virtual;
    function count: integer;
  public
    function GetFrm(i: integer): TRecFrm;
    function CreateForm(var pIVForm: IVForm): HRESULT; stdcall;
    // Получить идентификатор фабрики
    function GetFactoryID(var pID: TGUID): HRESULT; stdcall;
    // Получить ссылку на владельца (плагин)
    function GetFactoryOwner(var pOwner: IUnknown): HRESULT; stdcall;
    // Получить имя типа формуляра BSTR*
    function GetFormTypeName(var pbstrName: widestring): HRESULT; stdcall;
    // Получить картинку типа формуляра
    function GetFormTypePicture(var pPicture: IPicture): HRESULT; stdcall;
    // Получить дефолтный размер формы в пикселях
    function GetDefaultFormSize(var pSize: SIZE): HRESULT; stdcall;
    // Признак одноканального индикатора
    function GetSingleTagFlag(var pFlag: VARIANT_BOOL): HRESULT; stdcall;
    // IUnknown
    // virtual HRESULT STDMETHODCALLTYPE  QueryInterface(REFIID a_rObjectIID, void** a_ppObject);
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    // virtual ULONG   STDMETHODCALLTYPE AddRef();
    function _AddRef: integer; stdcall;
    // virtual ULONG   STDMETHODCALLTYPE Release();
    function _Release: integer; stdcall;
    function refcount: integer;
  public
    // ICustomFactIntarface
		//function getChild(var i:integer):IVForm;stdcall;
    function getChild(const i: DWORD; var pIVForm: IVForm): HRESULT; stdcall;
  public
  end;

  cRecBasicIFrm = class(TObject, IInterface, IVForm, ISettingsINI, ICustomVFormInterface)
  public
    m_pMasterWnd: TRecFrm;
  protected
    m_lRefCount: integer;
  protected
    m_f: cRecBasicFactory;
    // наша форма компонент
    m_name: LPCSTR;
  protected
    //
    function doGetProperty(tag:integer):lpcstr;virtual;
    function doGetProperty2(obj:integer;prop: LPCSTR):lpcstr;virtual;
    function doSetProperty(tag:integer; str:lpcstr):integer;virtual;
  public
    function getIRecorder: irecorder;
    function doNotify(const dwCommand: DWORD; const dwData: DWORD): boolean;
      virtual;
    function doRepaint: boolean; virtual;
    function doCreateFrm: TRecFrm; virtual; abstract;
    procedure doClose; virtual;
    function doDestroyFrm: TRecFrm; virtual; abstract;
    function dogetname: LPCSTR; virtual;
    function doWriteSettings(const pchPath: LPCSTR;
      const pchSection: LPCSTR): HRESULT; virtual;
    // Прочитать настройки
    function doReadSettings(const pchPath: LPCSTR;
      const pchSection: LPCSTR): HRESULT; virtual;
  public
    // Инициализация формы
    function Init(pParent: irecorder; hParent: HWND; lParam: longint): boolean;
      stdcall;
    // Получить имя формы должно быть уникальным, используется при регистрации
    // Получение имени
    function GetName: LPCSTR; stdcall;
    // Получить HWND формы
    function GetHWND: HWND; stdcall;
    function Close: boolean; stdcall;
    function Prepare: boolean; stdcall;
    function Update: boolean; stdcall;
    // Перерисовка формы
    function Repaint: boolean; stdcall;
    // Привязка к тегам рекордера
    function LinkTags(var pTagsList: TagsArray;
      var nTagsCount: ULONG): boolean; stdcall;
    // Активизация формы
    function Activate: boolean; stdcall;
    // Деактивизация формы
    function Deactivate: boolean; stdcall;
    // Вызов окна редактирования
    function Edit: boolean; stdcall;
    // События, уведомления, команды
    function Notify(const dwCommand: DWORD; const dwData: DWORD): boolean; stdcall;
  public
    // ISettingsINI
    // Сохранить настройки
    // Сохранить настройки
    function WriteSettings(const pchPath: LPCSTR;
      const pchSection: LPCSTR): HRESULT; stdcall;
    // Прочитать настройки
    function ReadSettings(const pchPath: LPCSTR;
      const pchSection: LPCSTR): HRESULT; stdcall;
  // ICustomVFormIntarface
  public
		function GetCustomProperty(tag:integer):LPCSTR;stdcall;
		function GetCustomProperty2(obj:integer;prop: LPCSTR):LPCSTR;stdcall;
    function SetCustomProperty(tag:integer; str:lpcstr):Integer;stdcall;
  public
    // IUnknown
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: integer; stdcall;
    // virtual ULONG   STDMETHODCALLTYPE Release();
    function _Release: integer; stdcall;
  public
    destructor destroy; override;
  end;

const
  // ctrl+shift+G
  IID_RecBasicFactor: TGUID = (D1: $0470FC78; D2: $CCF0; D3: $46DB; D4: ($82, $1F, $00, $06, $70, $B4, $80, $11));

  IID_ICustomVForm: TGUID = ( D1:$F6C43E4C;D2:$2FE3;D3:$4DEB;D4:($B0,$1E,$6A,$E2,$8A,$10,$A5,$9F));

  // ['{119E2EA6-C7B5-4610-B29B-759DF8AAF471}']
  IID_ICustomFactInterface: TGUID = (D1: $119E2EA6; D2: $C7B5; D3: $4610;D4: ($B2, $9B, $75, $9D, $F8, $AA, $F4, $71));


  c_defXSize = 150;
  c_defYSize = 15;

implementation

//uses
//  pluginclass;

function cRecBasicFactory.count: integer;
begin
  result := m_CompList.count;
end;

constructor cRecBasicFactory.create;
begin
  m_lRefCount := 1;
  m_name := 'cRecBasicFactory';
  m_picname := 'RECBASICFACTORY';
  m_Guid := IID_RecBasicFactor;
end;

procedure cRecBasicFactory.doInit;
begin
  m_CompList := TList.create;
end;

procedure cRecBasicFactory.doRecorderInit;
begin

end;

destructor cRecBasicFactory.destroy;
begin
  // самовыпиливание из CompMng
  // TExtRecorderPack(GPluginInstance).m_CompMng.unregFact(self);
  m_CompList.destroy;
  doDestroyForms;
  inherited;
end;

procedure cRecBasicFactory.doAfterLoad;
begin

end;

procedure cRecBasicFactory.doDestroyForms;
begin

end;

procedure cRecBasicFactory.ExcludeComp(comp: TObject);
var
  i: integer;
begin
  for i := 0 to m_CompList.count - 1 do
  begin
    if m_CompList.Items[i] = comp then
    begin
      m_CompList.Delete(i);
      exit;
    end;
  end;
end;

//function cRecBasicFactory.getChild(const i: DWORD): IVForm;
//begin
//  result:= cRecBasicIFrm(m_CompList.Items[i]) as IVForm;
//end;

function cRecBasicFactory.getChild(const i: DWORD;var pIVForm: IVForm): HRESULT; stdcall;
var
  f:ivform;
begin
  result := S_OK;
  if i<(m_CompList.count) then
  begin
    f:=cRecBasicIFrm(m_CompList.Items[i]) as IVForm;
    pIVForm:=f;
  end
  else
  begin
    result := S_FALSE;
  end;
end;

function cRecBasicFactory.CreateForm(var pIVForm: IVForm): HRESULT;
var
  f: cRecBasicIFrm;
begin
  f := doCreateForm;
  if f <> nil then
  begin
    m_CompList.Add(f);
    f.m_f := self;
    pIVForm := f as IVForm;
    result := S_OK;
    // убираем лишнее присвоение
    // pIVForm._Release;
  end
  else
  begin
    pIVForm := nil;
    result := S_FALSE;
  end;
end;

procedure cRecBasicFactory.doSetDefSize(var pSize: SIZE);
begin

end;

procedure cRecBasicFactory.doStart;
var
  j: integer;
  frm: TRecFrm;
begin
  for j := 0 to count - 1 do
  begin
    frm := TRecFrm(getfrm(j));
    frm.doStart;
  end;
end;

procedure cRecBasicFactory.doUpdateData;
var
  j: integer;
  frm: TRecFrm;
begin
  for j := 0 to count - 1 do
  begin
    frm := TRecFrm(getfrm(j));
    frm.UpdateData;
  end;
end;

function cRecBasicFactory.GetDefaultFormSize(var pSize: SIZE): HRESULT;
begin
  result := E_POINTER;
  // дефолтные габариты
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
  result := E_POINTER;
  doSetDefSize(pSize);
end;

function cRecBasicFactory.GetFactoryID(var pID: TGUID): HRESULT;
begin
  pID := m_Guid;
  result := S_OK;
end;

function cRecBasicFactory.GetFactoryOwner(var pOwner: IUnknown): HRESULT;
begin
  //result := E_POINTER;
  result := S_OK;
  //pOwner:=GPluginInstance;
  pOwner:=m_pOwner;
  if (pOwner <> nil) then
  begin
    pOwner := m_pOwner;
    result := S_OK;
  end;
end;

function cRecBasicFactory.GetFormTypeName(var pbstrName: widestring): HRESULT;
begin
  if self <> nil then
  begin
    pbstrName := m_name;
    result := S_OK;
  end;
end;

function cRecBasicFactory.GetFormTypePicture(var pPicture: IPicture): HRESULT;
begin
  // result:=E_POINTER;
  // pPicture := LoadPicFromRes(m_picname);
  pPicture := LoadPicFromRes(m_picname);
  result := S_OK
end;

function cRecBasicFactory.GetFrm(i: integer): TRecFrm;
var
  ifrm: cRecBasicIFrm;
begin
  if i>=m_CompList.count then
  begin
    result:=nil;
  end
  else
  begin
    ifrm := cRecBasicIFrm(m_CompList.Items[i]);
    result := ifrm.m_pMasterWnd;
  end;
end;

function cRecBasicFactory.GetSingleTagFlag(var pFlag: VARIANT_BOOL): HRESULT;
begin
  result := E_POINTER;
  if (pFlag <> S_FALSE) then
  begin
    pFlag := 1;
    result := S_OK;
  end;
end;

function cRecBasicFactory.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  result := E_UNEXPECTED;
  //if pointer(Obj) = nil then
  //begin
  //  result := E_INVALIDARG;
  //end
  //else
  begin
    if IsEqualIID(IID, IID_ICustomFormFactory) then
    begin
      // ВАЖНО ПРИСВААИВАТЬ ИМЕННО РАЗЫМЕНОАВНЫЙ УКАЗАТЕЛЬ ИНАЧЕ УПАДЕТ НЕ ТА ТАБЛИЦА
      ICustomFormFactory(Obj) := ICustomFormFactory(self);
      // as ICustomFormFactory;
      _AddRef();
      result := S_OK;
    end
    else
    begin
      if IsEqualIID(IID, IID_ICustomFactInterface) then
      begin
        // ВАЖНО ПРИСВААИВАТЬ ИМЕННО РАЗЫМЕНОАВНЫЙ УКАЗАТЕЛЬ ИНАЧЕ УПАДЕТ НЕ ТА ТАБЛИЦА
        ICustomFactInterface(Obj) := ICustomFactInterface(self);
        // as ICustomFormFactory;
        _AddRef();
        result := S_OK;
      end
      else
      begin
        pointer(Obj) := nil;
        result := E_NOINTERFACE;
      end;
    end;
  end;
end;

function cRecBasicFactory.refcount: integer;
begin
  result := m_lRefCount;
end;

procedure cRecBasicFactory.setOwner(p_own: IInterface);
begin
  m_pOwner :=p_own;
end;

function cRecBasicFactory._AddRef: integer;
begin
  InterlockedIncrement(&m_lRefCount);
  result := m_lRefCount;
end;

function cRecBasicFactory._Release: integer;
var
  rep: integer;
begin
  result := 0;
  rep := InterlockedDecrement(&m_lRefCount);
  // когда значение счетчика обращений
  // становится равным нулю, объект удаляет сам себя
  if (m_lRefCount = 0) then
  begin
    doDestroyForms;
    free;
  end
  else
  begin
    result := m_lRefCount;
  end;
end;

// =======================================================================

function cRecBasicIFrm.Activate: boolean;
begin
  if m_pMasterWnd <> nil then
  begin
    m_pMasterWnd.Show();
    result := true;
  end
  else
    result := false;
end;

function cRecBasicIFrm.Close: boolean;
begin
  doClose;
  if m_pMasterWnd <> nil then
  begin
    m_pMasterWnd.Close();
    // Parent Window создано в MainThread. При попытке очистить дочерний элемент
    // в другом потоке если дочерний элемент ниразу не был показан будет ошибка!!!
    m_pMasterWnd.Parent := nil;
    m_pMasterWnd.destroy;
    m_pMasterWnd := nil;
  end;
  result := true;
end;

function cRecBasicIFrm.Deactivate: boolean;
begin
  if m_pMasterWnd <> nil then
  begin
    m_pMasterWnd.hide;
  end;
  result := true;
end;

function cRecBasicIFrm.Edit: boolean;
begin
  result := false;
end;

function cRecBasicIFrm.GetCustomProperty(tag: integer): LPCSTR;
begin
  result:=doGetProperty(tag);
end;

function cRecBasicIFrm.GetCustomProperty2(obj:integer;prop: LPCSTR): LPCSTR;
begin
  result:=doGetProperty2(obj, prop);
end;

function cRecBasicIFrm.SetCustomProperty(tag: integer; str: lpcstr): Integer;
begin
  result:=doSetProperty(tag, str);
end;

function cRecBasicIFrm.GetHWND: HWND;
begin
  if m_pMasterWnd <> nil then
  begin
    result := m_pMasterWnd.handle;
  end
  else
    result := 0;
end;

function cRecBasicIFrm.GetName: LPCSTR;
begin
  result := dogetname;
end;

function cRecBasicIFrm.Init(pParent: irecorder; hParent: HWND;
  lParam: integer): boolean;
begin
  // m_pRecorder := pParent;
  m_pMasterWnd := doCreateFrm;
  m_pMasterWnd.m_f := m_f;
  m_pMasterWnd.ParentWindow := hParent;
  m_pMasterWnd.BorderStyle := bsNone;
  // m_pMasterWnd.m_R := pParent;
  Deactivate();
  result := true;
end;

function cRecBasicIFrm.LinkTags(var pTagsList: TagsArray;
  var nTagsCount: ULONG): boolean;
begin
  result := false;
end;

function cRecBasicIFrm.getIRecorder: irecorder;
begin
  result := nil;
  if m_f <> nil then
  begin
    result := getIR;
  end;
end;

procedure cRecBasicIFrm.doClose;
begin

end;

function cRecBasicIFrm.dogetname: LPCSTR;
begin
  result := m_name;
end;

function cRecBasicIFrm.doGetProperty(tag: integer): lpcstr;
begin
  result:=lpcstr(StrToAnsi(classname));
end;

function cRecBasicIFrm.doGetProperty2(obj:integer;prop: LPCSTR): lpcstr;
begin

end;

function cRecBasicIFrm.doNotify(const dwCommand: DWORD;
  const dwData: DWORD): boolean;
var
  pRect: trect;
  str: string;
begin
  result := true;
  if dwCommand <> Wm_paint then
  begin
    // str := inttostr(dwCommand);
    // (str + ' WM_PARENTNOTIFY');
  end;
  case dwCommand of
    VSN_RESIZE:
      begin
        // Изменение размеров
        if dwData = 0 then
        begin
          result := false;
        end
        else
        begin
          pRect := trect(pointer(dwData)^);
          if m_pMasterWnd <> nil then
          begin
            m_pMasterWnd.BoundsRect := pRect;
            m_pMasterWnd.m_bounds := pRect;
            m_pMasterWnd.InitSize(pRect);
            result := true;
          end;
        end;
      end;
    VSN_EditIFrm:
      begin
      end;
  end;
end;

function cRecBasicIFrm.doWriteSettings(const pchPath: LPCSTR;
  const pchSection: LPCSTR): HRESULT;
var
  ifile: TIniFile;
begin
  ifile := TIniFile.create(pchPath);
  if m_pMasterWnd <> nil then
  begin
    m_pMasterWnd.SaveSettings(ifile, pchSection);
  end;
  result := S_OK;
  ifile.destroy;
end;

// Прочитать настройки
function cRecBasicIFrm.doReadSettings(const pchPath: LPCSTR;
  const pchSection: LPCSTR): HRESULT;
var
  ifile: TIniFile;
  str: string;
begin
  str := pchPath;
  ifile := TIniFile.create(str);
  m_pMasterWnd.LoadSettings(ifile, pchSection);
  result := S_OK;
  ifile.destroy;
end;

function cRecBasicIFrm.doRepaint: boolean;
begin

end;

function cRecBasicIFrm.doSetProperty(tag:integer; str:lpcstr): integer;
begin
  result:=-1;
end;

function cRecBasicIFrm.Notify(const dwCommand, dwData: DWORD): boolean;
begin
  result := doNotify(dwCommand, dwData);
end;

function cRecBasicIFrm.Prepare: boolean;
begin
  result := false;
end;

function cRecBasicIFrm.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  result := E_UNEXPECTED;
  { if GetInterface(IID, Obj) then
    Result := 0
    else
    Result := E_NOINTERFACE; }
  if IsEqualIID(IID, IID_IVForm) then
  begin
    IVForm(Obj) := IVForm(self); // self as IVForm;
    // _AddRef();
    result := S_OK;
  end
  else
  begin
    if IsEqualIID(IID, IID_ISettingsINI) then
    begin
      ISettingsINI(Obj) := ISettingsINI(self); // as ISettingsINI;
      // _AddRef();
      result := S_OK;
    end
    else
    begin
      if IsEqualIID(IID, IID_IUnknown) then
      begin
        IUnknown(Obj) := IUnknown(self); // self as IVForm;
        // _AddRef();
        result := S_OK;
      end
      else
      begin
        if IsEqualIID(IID, IID_ICustomVForm) then
        begin
          ICustomVFormInterface(Obj) := ICustomVFormInterface(self); // self as IVForm;
          // _AddRef();
          result := S_OK;
        end
        else
        begin
          pointer(Obj) := nil;
          result := E_NOINTERFACE;
        end;
      end;
    end;
  end;
end;

function cRecBasicIFrm.Repaint: boolean;
begin
  result := doRepaint;
  result := false;
end;



function cRecBasicIFrm.Update: boolean;
begin
  result := false;
end;

function cRecBasicIFrm.ReadSettings(const pchPath: LPCSTR;
  const pchSection: LPCSTR): HRESULT;
begin
  result := doReadSettings(pchPath, pchSection);
end;

function cRecBasicIFrm.WriteSettings(const pchPath: LPCSTR;
  const pchSection: LPCSTR): HRESULT;
begin
  result := doWriteSettings(pchPath, pchSection);
end;

function cRecBasicIFrm._AddRef: integer;
var
  str: LPCSTR;
  str1: string;
begin
  str := dogetname;
  str1 := str;
  setlength(str1, length(str1));
  InterlockedIncrement(&m_lRefCount);
  result := m_lRefCount;
end;

function cRecBasicIFrm._Release: integer;
var
  rep: integer;
begin
  result := 0;
  rep := InterlockedDecrement(&m_lRefCount);
  // когда значение счетчика обращений
  // становится равным нулю, объект удаляет сам себя
  if (m_lRefCount = 0) then
  begin
    result := m_lRefCount;
    free;
  end
  else
  begin
    result := m_lRefCount;
  end;
end;

destructor cRecBasicIFrm.destroy;
begin
  ///TExtRecorderPack(GPluginInstance).EList.CallAllEventsWithSender (E_RC_DestroyObject, self);
  // удаляем компонент из спсика зарегестрированных объектов в фабрике классов
  m_f.ExcludeComp(self);
  // потенциально опасно!!!
  if m_f.count = 0 then
  begin
    /// если идет удаление плагина а не просто так выпилили все компоненты одного типа
    //if TExtRecorderPack(GPluginInstance).delPlg then
    ///  m_f._Release;
  end;
  m_f := nil;
  inherited;
end;

// ===============================================================
function TRecFrm.getIRecorder: irecorder;
begin
  result := nil;
  if m_f <> nil then
  begin
    result := getIR;
  end;
end;

procedure TRecFrm.InitSize(b: trect);
begin
  if not m_init then
  begin
    m_init := true;
  end;
end;

procedure TRecFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
end;

procedure TRecFrm.UpdateData;
begin

end;

procedure TRecFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  rect:trect;
begin

end;

procedure TRecFrm.Resizing(State: TWindowState);
var
  str: string;
begin
  //str := 'resize X:' + inttostr(BoundsRect.Left) + ' Y:' + inttostr
  //  (BoundsRect.top);
  if (BoundsRect.Left<>m_bounds.Left) or (BoundsRect.Top<>m_bounds.top) then
  begin
    BoundsRect:=m_bounds;
  end;
  inherited;
end;

procedure TRecFrm.DoShow;
begin
  if m_firstShow then
  begin
    m_firstShow := false;
  end;
  inherited;
end;

procedure TRecFrm.doStart;
begin

end;

procedure TRecFrm.DoCreate;
begin
  m_init := false;
  m_firstShow := true;
  inherited;
end;

function WndProc(hnd, wmsg, wparam, lParam: integer): integer; stdcall;
begin
  case wmsg of
    WM_COMMAND:
      begin

      end;
    WM_DESTROY:
      begin
        PostQuitMessage(0);
      end;
  else
    result := DefWindowProc(hnd, wmsg, wparam, lParam);
  end;
end;
{
  function TRecFrmEx.DoCreate:integer;
  begin
  with WinClass do
  begin
  lpszClassName:=WinTitle;
  lpfnWndProc:=@WndProc;
  cbClsExtra:=0;
  cbWndExtra:=0;
  hInstance:=hInstance;
  style:=CS_HREDRAW+CS_VREDRAW+CS_DBLCLKS;
  hIcon:=LoadIcon(hInstance, IconName);
  hCursor:=LoadCursor(hInstance, IDC_ARROW);
  hbrBackground:=COLOR_WINDOW;
  end;
  RegisterClass(WinClass);
  Handle:=CreateWindowEx(WS_EX_WINDOWEDGE, WinTitle, 'BaseWnd',
  WS_VISIBLE or WS_MINIMIZEBOX or WS_CAPTION or WS_SYSMENU or WS_CLIPSIBLINGS or ,
  integer(CW_USEDEFAULT), integer(CW_USEDEFAULT),
  //X, Y,  W, H
  170, 63, 0, 0, hInstance, nil);
  end; }

procedure TRecFrmEx.DoShow;
begin

end;

procedure TRecFrmEx.Resizing(State: TWindowState);
begin

end;

procedure TRecFrmEx.InitSize(b: trect);
begin

end;

procedure TRecFrmEx.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin

end;

procedure TRecFrmEx.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin

end;

end.
