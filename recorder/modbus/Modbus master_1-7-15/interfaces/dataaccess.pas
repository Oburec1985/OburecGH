unit dataaccess;

interface
uses variants;

type

/// Типы разметки данных
TDATA_LAYOUT_TYPE = (
	DLT_PLAIN, ///< Плоские данные (осциллограмы, тренды, вейв форма и прочее)
	DLT_FRAMES
);

TDATA_READ_OPTION_FLAGS = (
	DROPTF_TIME_AS_UTS = $00001
);

TDACCESS = (
DACCESS_SEEK_BEGIN,
DACCESS_SEEK_CUR,
DACCESS_SEEK_NEW_DATA);

PDataAccessIndex = ^IDataAccessIndex;

IDataAccessIndex = interface(IUnknown)
['{275A9AB0-8207-413f-AB53-C2C7F97FF7F9}']
  function Rewind(nPos: int64; nParam: longword): HRESULT; stdcall;
end;

IDataAccess = interface;

IDataAccessEvents = interface(IUnknown)
['{FC20643C-9644-453c-8D14-5AD460990541}']
  function OnDataReady(pDataAccess: IDataAccess): HRESULT; stdcall;
end;

PSingle = ^Single;
PPointer = ^Pointer;

IDataAccess = interface
['{71DE6EAE-1516-4FE7-80AD-2FFEE1D7D4C1}']
  //Открыть сессию чтения данных
	//Создается индекс для чтения и есть возможность подписаться на уведомления
	function Open(pIndex: PDataAccessIndex; pDataAccessEvents: IDataAccessEvents): HRESULT; stdcall;

  // Закрыть сессию чтения данных
  function Close(pIndex: IDataAccessIndex): HRESULT; stdcall;

  /// Прочитать данные
	/// @param pBufferX - буфер значений для оси абсцисс может быть равным 0
	///
  function ReadData(
      pIndex: IDataAccessIndex;
			pBufferY: PSingle;
			pBufferX: PSingle;
      nBufferLen: UInt64;
			nParamFlags: Cardinal
		): HRESULT; stdcall;

  /// Прочитать данные в заданном формате
	/// @param pBufferX - буфер значений для оси абсцисс может быть равным 0

  function ReadDataEx(
      pIndex: IDataAccessIndex;
			pBufferY: Pointer;
			vtY: variant;
      nBufferLen: UInt64;
			nParamFlags: UInt64
		): HRESULT; stdcall;
end;

implementation

end.
