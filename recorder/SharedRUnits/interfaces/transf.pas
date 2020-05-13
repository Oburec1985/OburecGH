{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для управления любым объектом            }
{ вычислителем градуировочной функции                                 }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}

unit transf;
interface
uses Windows, ActiveX, scales, transformers;
const
   //Уведомления трансформеру
   TXN_UPDATELINKS = 0;  //Произвести перепривязку ссылок
   TXN_UPDATEDB    = 1;   //Обновить БД хранящую ГХ
   
   //Команда окну владеющему встраеваемым редактором трансформера
   IDCTF_UPDATEHARDWTARE = $555;
   
type
   TXTYPE =(
      TXT_NULL,
      TXT_SCALE,
      TXT_LINE,
      TXT_INTEPOLATETABLE,
      TXT_POLYNOME,
      TXT_MULTI
   );

// Базовый интерфейс
   ITransformer = interface
   ['{C1A20401-DC60-11d6-9243-00E029288A7F}']
      function GetEditor: HWND; stdcall;
      function GetEmbeddedEditor(const pParent: HWND): HWND; stdcall;

      //Сохранение трансформера в буфер если передать a_pStream==NULL
      //возвращает размер буфера
      function Save(var pStream): integer; stdcall;
      //Восстановление трансформера из буфера если передать a_pStream==NULL
      //возвращает размер буфера
      function Load(var pStream): integer; stdcall;

      //Получить описание трансформера для записи в файл .mera
      function GetInfoStrings(var pnIndex: integer; var pchBuffer: LPCSTR;
                              const pchPath: LPCSTR;
                              const pchTagName: LPCSTR): integer; stdcall;
      {Активизауия окна встроенного редактора для ГФ}
      function Edit: boolean; stdcall;
      function Eval(const dblValue: double): double; stdcall;
      function GetTXType: TXTYPE; stdcall;
      {Параметры ГФ изменены, необходимо обновить окно встроенного редактора}
      function UpdateEditor: HRESULT; stdcall;
      function Reset: HRESULT; stdcall;

      {Получить/установить наименование ГФ}
      {При получении имени параметром функции адрес приемного буфера,
      буфер должен быть не менее 256 символов}
      function GetName(const pchName: LPCSTR): DWORD; stdcall;
      function SetName(const pchName: LPCSTR): HRESULT; stdcall;

      //Импорт из файла .csv
      function ImportFromFile(const a_pchName: LPCSTR;
                              const pchSeparator: LPCSTR): HRESULT; stdcall;
      //Экспорт в файл .csv
      function ExportToFile(const pchName: LPCSTR;
                            const pchSeparator: LPCSTR): HRESULT; stdcall;

      function GetProgID: LPCSTR; stdcall;

      //Вернуть имя типа
      function GetTypeName(const pchName: LPCSTR): DWORD; stdcall;

      //Произвести проверку корректности параметров
      function Check: HRESULT; stdcall;

      // Получить свойство
      function GetProperty(dwPropertyID: DWORD; var Value: OleVariant): HRESULT; stdcall;
      // Задать свойство
      function SetProperty(const dwPropertyID: DWORD;
                           {const} Value: OleVariant): HRESULT; stdcall;

      // Послать уведомление/комманду
      function Notify(const dwCommand: DWORD; const dwParam: DWORD): boolean; stdcall;

      // Проверить файл на возможность загрузки
      function TestImportFile(const pchName: LPCSTR): boolean; stdcall;

      //Расчитать значение обратной финкции TX
      function EvalInverse(const dblValue: double): double; stdcall;

      // Получить путь по умолчанию для хранеия ГХ
      function GetDefaultCalibrPath : PAnsiChar; stdcall;
      // Задать путь по умолчанию для хранеия ГХ
      procedure SetDefaultCalibrPath(const a_pchPath : PAnsiChar); stdcall;

      // Получить статус последнего вычисления по ГХ
      function GetLastEvalState : DWORD; stdcall;

      // Заменить внутренности применяется исключительно для замены IMeScales
      function Attach(const a_pUnk : PUnknown) : HRESULT; stdcall;
   end;

   function ScaleToTransformer(var a_pScale : IMeScaleEdit; var a_ppTransformer : ITransformer) : HRESULT;

implementation

function ScaleToTransformer(var a_pScale : IMeScaleEdit; var a_ppTransformer : ITransformer) : HRESULT;
const
  IID_IUnknown : TGUID = '{00000000-0000-0000-C000-000000000046}';
var
  hr : HRESULT;
  cidType, clsidTare : TGUID;
  pUnk : PUnknown;
  pTrasformer : ITransformer;
  pScaleProp : IMeScaleProp;
  pScaleMgr  : IMeScaleModMgr;
  pInternalObject : IMeScaleEdit;
begin
  if (a_pScale = nil) then Exit(E_INVALIDARG);
  //if (a_ppTransformer = nil) then Exit(E_INVALIDARG);

  hr := a_pScale.QueryInterface(IID_IMeScaleProp, pScaleProp);
  if (FAILED(hr)) then Exit(hr);

  hr := a_pScale.QueryInterface(IID_IMeScaleModMgr, pScaleMgr);
  if (FAILED(hr)) then Exit(hr);

	hr := pScaleMgr.GetModuleClassID(cidType);
	if (FAILED(hr)) then Exit(hr);

 	if (IsEqualCLSID(cidType, CLSID_MeScaleInterpolate)) then
    begin
		  CLSIDFromProgID(PWideChar('MeraRecorder.InterpolateTransformer.1'), clsidTare);
    end
	else
    begin
		  if (IsEqualCLSID(cidType, CLSID_MeScalePolynomial)) then
        begin
			    CLSIDFromProgID(PWideChar('MeraRecorder.PolynomialTransformer.1'), clsidTare);
		    end
		  else
        begin
			    if (IsEqualCLSID(cidType, CLSID_MeScaleLinear)) then
            begin
				      CLSIDFromProgID(PWideChar('MeraRecorder.LinearTransformer.1'), clsidTare);
			      end
			    else
            begin
				      if (IsEqualCLSID(cidType, CLSID_MeScaleMultiplier)) then
                begin
					        CLSIDFromProgID(PWideChar('MeraRecorder.ScaleTransformer.1'), clsidTare);
				        end
				      else
                begin
					        CLSIDFromProgID(PWideChar('MeraRecorder.InterpolateTransformer.1'), clsidTare);
				        end;
			      end;
		    end;
	  end;

  hr := CoGetClassObject(clsidTare, CLSCTX_INPROC, nil, IID_ITransformer, pTrasformer);
	if (FAILED(hr)) then Exit(hr);

	hr := a_pScale.QueryInterface(IID_IUnknown, pUnk);
	if (FAILED(hr)) then Exit(hr);
	hr := pTrasformer.Attach(pUnk);
	if (FAILED(hr)) then Exit(hr);

	a_ppTransformer := pTrasformer;

  Result := S_OK;
end;

end.

