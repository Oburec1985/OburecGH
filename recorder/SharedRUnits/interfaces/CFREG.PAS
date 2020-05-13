unit CFREG;


interface
uses
  Windows,
  recorder,
  classes, graphics, ExtCtrls, AXCtrls,
  ActiveX;

type
  tagCB_MESSAGE= record
    uMsg:integer;
    uID:integer;
    uParam:integer;
    pObjects:IEnumUnknown;
    hWnd:thandle;
  end;
  PCB_MESSAGE = ^tagCB_MESSAGE;
  PPicture = ^IPicture;

  ICustomButtonsToolBar = interface
  ['{894B2A27-D490-4e77-8CE0-6BCF20654C8A}']
    // Получить имя тулбара
    // выделение памяти соответствует правилам COM
    // поэтому после получения имени требуется освободить память
    function GetName(pbstrName:LPCSTR):HRESULT;stdcall;

    // Добавить кнопку в тулбар
    function AddButton(
        pPicture:IPicture;         // [in] Основное изображение на кнопке
        pPictureSel:IPicture;      // [in] Изображение на выбраной кнопке, может быть NULL
        pPictureFocus:IPicture;    // [in] Изображение на кнопке с фокусом, может быть NULL
        pPictureDisabled:IPicture; // [in] Изображение на дизабленной кнопке , может быть NULL
        const bstrCaption:lpcSTR;     // [in] Текст кнопки
        const bstrToolTipText:lpcSTR; // [in] Текст всплывающей подсказки
        pOwner:IUnknown;           // [in] Владелец кнопки
        out puID:ULONG                 // [out] Идентификатор кнопки
        ):HRESULT;stdcall;
    // Удалить кнопку из тулбара
    function RemoveButton(uID:ULONG):HRESULT;stdcall;
    // Дизаблить/енаблить кнопку
    function EnableButton(uID:ULONG; bEnable:BOOL):HRESULT;stdcall;
    /// Добавить режим кнопки
    /// По-сути дополнительный набор картинок
    function AddButtonMode(
        uID:ULONG;                 // Ид уже существующей кнопки
        pPicture:IPicture;         // [in] Основное изображение на кнопке
        pPictureSel:IPicture;      // [in] Изображение на выбраной кнопке, может быть NULL
        pPictureFocus:IPicture;    // [in] Изображение на кнопке с фокусом, может быть NULL
        pPictureDisabled:IPicture; // [in] Изображение на дизабленной кнопке , может быть NULL
        const bstrCaption:lpcSTR;     // [in] Текст кнопки
        const bstrToolTipText:lpcSTR; // [in] Текст всплывающей подсказки
        var puID:ULONG               // [out] Идентификатор кнопки
    ):HRESULT;stdcall;
    /// Выбрать режим / набор
    function SelectMode(uID:ULONG;nMode:ULONG):HRESULT;stdcall;
  end;
  PCustomButtonsToolBar = ^ICustomButtonsToolBar;

// Интерфейс фабрики объектов VForm
// Каждый тип фабрики должен иметь уникальный идентификатор типа GUID
  ICustomFormFactory = interface
  ['{18B5643F-FF89-479d-880F-043C92DC8476}']
		function CreateForm(var pIVForm: IVForm):HRESULT;stdcall;
		// Получить идентификатор фабрики
    function GetFactoryID(var pID: TGuid):HRESULT;stdcall;
		// Получить ссылку на владельца (плагин)
		function  GetFactoryOwner(var pOwner:IUnknown):HRESULT;stdcall;
		// Получить имя типа формуляра BSTR*
		function GetFormTypeName(var pbstrName:widestring):HRESULT;stdcall;
		// Получить картинку типа формуляра
		function GetFormTypePicture(var pPicture:IPicture):HRESULT;stdcall;
		// Получить дефолтный размер формы в пикселях
		function GetDefaultFormSize(var pSize:SIZE):HRESULT;stdcall;
		// Признак одноканального индикатора
		function GetSingleTagFlag(var pFlag:VARIANT_BOOL):HRESULT;stdcall;
  end;
  PCustomFormFactory = ^ICustomFormFactory;

  // Интерфейс для управления списком зарегистрированных фабрик
  ICustomFormsRegistrator = interface
  ['{A9A3A065-369D-42d7-8105-426F38C80531}']
    // Зарегистрировать новую фабрику
		function RegisterFormFactory(pFactory:ICustomFormFactory):HRESULT;stdcall;
		// Вычеркнуть из списка зарегистрированных фабрик
		function UnRegisterFormFactory(pFactory:ICustomFormFactory):HRESULT;stdcall;
		// Найти фабрику по идентификатороу
		function FindFactoryById(ppFactory:ICustomFormFactory; pID:pGUID):HRESULT;stdcall;
		// Получить количество фабрик
		function GetFactoriesCount(nCount:PDWORD):HRESULT;stdcall;
		// Найти фабрику по индексу
		function GetFactoryByIndex(ppFactory:ICustomFormFactory;nIndex:ULONG):HRESULT;stdcall;
  end;
  PCustomFormsRegistrator = ^ICustomFormsRegistrator;

  ICustomButtonsControl = interface
  ['{B2AB12D0-A34F-415e-AE8C-345E1CFD4726}']
    function EnumerateToolBars(a_ppToolBarsEnum:IEnumUnknown):HRESULT;stdcall;
    function GetToolBarByName(const a_bstrName:LPCSTR;var a_ppToolBar:ICustomButtonsToolBar):HRESULT;stdcall;
  end;


 const
  IID_ICustomFormFactory: TGUID = (
    D1:$18b5643f;D2:$ff89;D3:$479d;D4:($88,$0f,$04,$3C,$92,$dc,$84,$76));

  IID_ICustomFormsRegistrator: TGUID = (
    D1:$A9A3A065;D2:$369D;D3:$42d7;D4:($81,$05,$42,$6F,$38,$c8,$05,$31));

  IID_IUnknown: TGUID = (
    D1:$00000000;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));

  IID_IPicture: TGUID = (
    D1:$7BF80980;D2:$BF32;D3:$101A;D4:($8B,$BB,$00,$AA,$00,$30,$0C,$AB));

  IID_ICustomButtonsControl: TGUID = (
    D1:$B2AB12D0;D2:$A34F;D3:$415e;D4:($ae,$8c,$34,$5e,$1c,$fd,$47,$26));

// {894B2A27-D490-4e77-8CE0-6BCF20654C8A}
  IID_ICustomButtonsToolBar: TGUID = (
    D1:$894b2a27;D2:$d490;D3:$4e77;D4:($8c,$e0,$6b,$cf,$20,$65,$4c,$8a));

function LoadPicFromRes(name: string): ipicture;
function LoadJPG(S: IStream; Sz: LongInt; fMode: BOOL; const iid: TGUID; out vObj): HRESULT; stdcall; external 'olepro32.dll' name 'OleLoadPicture';


implementation

function LoadPicFromRes(name: string): ipicture;
var
  im:timage;
  p:ipicturedisp;
  rs:cardinal;
begin
  im:=TImage.Create(nil);
  Rs := FindResource(hInstance, pchar(name), RT_Bitmap);
  if rs<>0 then
  begin
    im.Picture.Bitmap.LoadFromResourceName(HInstance, name);
    // AxCtrl
    GetOlePicture( im.Picture, p);
    result:=p as ipicture;
  end
  else
    result:=nil;
  Im.Destroy;
  Im:=nil;
end;

end.
