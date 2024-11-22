unit I_DataSource;

interface

uses Windows;

const
  IID_IDataSource : TGUID = '{D190EC18-7506-4249-A820-F73B8EA73222}';

  DSTFLAG_INPUT      = $00000001; // m_pDevChan->isInputChannel()
	DSTFLAG_OUTPUT     = $00000002; // m_pDevChan->isOutputChannel()
	DSTFLAG_IRREGULAR  = $00000004;
	DSTFLAG_UTS        = $00010000; // isUTSChannel

type
   IDataSource = interface
   ['{D190EC18-7506-4249-A820-F73B8EA73222}']
      function Destroy : HRESULT; stdcall;
      function GetTypeFlags(var a_pnFlags : ULONG) : HRESULT; stdcall;
      function GetPermanentId(var a_pbstrId : LPCWSTR) : HRESULT; stdcall;
      function GetFreq(var a_pdblFreq : double) : HRESULT; stdcall; // PROP_CHAN_FREQ

      // PROP_CHAN_FREQ_COUNT
      function GetFreqCount(const a_pnCount : LongWord) : HRESULT; stdcall;
      function GetFreqAt(const a_pdblFreq : double; a_nIndex : LongWord) : HRESULT; stdcall; // PROP_CHAN_FREQ
      function SetFreq(const a_dblFreq : double) : HRESULT; stdcall; // PROP_CHAN_FREQ

      function SetAlias(const a_bstrAlias : LPCWSTR) : HRESULT; stdcall;

      // Получить коррекцию начального временного смещения данных
      // GetProperty(PROP_START_OFFSET, &dblStartOffset);
      function GetStartOffset(var a_pdblOffset : double) : HRESULT; stdcall;

      function GetAddress(var a_pbstrId : LPCWSTR) : HRESULT; stdcall;

      // GetProperty(PROP_INFO
      function GetInfo(var a_pbstrInfo : LPCWSTR) : HRESULT; stdcall;

      // @todo что-то более благозвучное
      // а то подстольные вещи наулицу это жесть
      function LoadTransformerKoef : HRESULT; stdcall;

      // @todo что-то более благозвучное
      // а то подстольные вещи наулицу это жесть
      function UpdateTransformerDB : HRESULT; stdcall;

      // GetFlashTareInfo
      function GetFlashTareInfo(var a_pInfo : LPCWSTR) : HRESULT; stdcall;

      function GetSampleSize(var a_pnSize : LongWord) : HRESULT; stdcall; // GetChanSize * 2

      //	EditObject(m_pDevChan->device, (HWND)a_dwParam)
      function EditOwner(a_hWnd : HWND) : HRESULT; stdcall;

      function UploadTareToDevice : HRESULT; stdcall;
      function WriteCalibratorName(const a_bstrName : LPCWSTR) : HRESULT; stdcall;
      function DownloadTareFromDevice : HRESULT; stdcall;

      // GetProperty(PROP_CHAN_TRANSFORMER, &pTX)
      // В оригинале не происходит увеличение счетчика ссылок
      function GetTare(out ppUnk {IUnknown** a_pObject}) : HRESULT; stdcall;

      // PROP_CHAN_TRANSFORMER
      function SetTare(var ppUnk : IUnknown {IUnknown* a_pObject}) : HRESULT; stdcall;

      function ZBalance(var d : double) : HRESULT; stdcall;
      function GetRange(var dblMin : double; dblmax : double) : HRESULT; stdcall; // PROP_RANGE_MIN PROP_RANGE_MAX

      // GetType
      function GetInternalType(var a_pnType : ULONG) : HRESULT; stdcall;

      // GetChanNo
      function GetChanIndex(var a_pnNo : LongWord) : HRESULT; stdcall;

      // @todo Подумать а не лучше ли у овнера просить, хотя типа "абстрагировались"
      // PROP_CHAN_SERNO
      function GetOwnerSerial(var a_pnNo : LongWord) : HRESULT; stdcall;

      // PROP_OWNER_NAME
      function GetOwnerName(var a_pName : LPCWSTR) : HRESULT; stdcall;

      // А если овнер не IUnknown???....
      function GetOwner(var ppUnk : IUnknown {IUnknown** a_ppOwner}) : HRESULT; stdcall;

      //  Code/Volts/...
      // PROP_CHAN_TYPE_SIGNAL
      function SetSignalType(const nType : LongWord) : HRESULT; stdcall;

      // GetDataType
      function GetDataType(var ppUnk : IUnknown {VARTYPE* vt}) : HRESULT; stdcall;

      // PushOutputValue
      function PushOutputValue(dblVal : double) : HRESULT; stdcall;

      // PushOutputValuesArray
      function PushOutputValuesArray(const a_nCount : ULONG; var a_pData : double) : HRESULT; stdcall;

      // PROP_CHAN_HANDLER_DATA, 0
      // Яй... Хвосты от DevApi...
      function SetChanHandlerData(var ppUnk : IUnknown {void* a_pData}) : HRESULT; stdcall;

      // PROP_CHAN_HANDLER
      function SetChanHandler(var a_pHandler : Integer) : HRESULT; stdcall;

      // PROP_CHAN_T_BLOCK
      function SetDataBlockSize(const a_nSize : ULONG) : HRESULT; stdcall;
      function GetDataBlockSize(var a_npSize : ULONG) : HRESULT; stdcall;

      //RANGE_COUNT_CHAN
      function GetRangesCount(var a_npCount : LongWord) : HRESULT; stdcall;

      // RANGE_CHAN_MIN
      // RANGE_CHAN_MAX
      // GetProperty(RANGE_CHAN_MIN, a_pRangeMin, a_nIndex
      function GetRangeAt(var pMin : double; pMax : double; const a_nIndex : LongWord) : HRESULT; stdcall;

      // GetProperty(RANGE_CHAN_UNITS, zsLine)
      function GetRangeUnits(var a_pUnits : LPCWSTR; const a_nIndex : LongWord) : HRESULT; stdcall;

      //INDEX_RANGE_CHAN
      function SetRangeIndex(const a_nIndex : LongWord) : HRESULT; stdcall;
      function GetRangeIndex(var a_pnIndex : LongWord) : HRESULT; stdcall;

      function SingleScan(const a_dblFreq : double; a_nSamples : ULONG; var a_pData : Integer{void* a_pData}) : HRESULT; stdcall;

      function GetRaw(out ppUnk {IUnknown} {void** pRawSource}) : HRESULT; stdcall;

      function GetUtsChannel(var ppUnk : IUnknown {{void** pRawUts}) : HRESULT; stdcall;

      function BurnSettings(const _Property : ULONG) : HRESULT; stdcall;
   end;

implementation

end.
