{---------------------------------------------------------------------}
{ ������ (������) ���������� plug-in`� ��� �������������� �� Recorder }
{ ������ �������� ���������� ��� ���������� ����� ��������            }
{ ������������ �������������� �������                                 }
{ ����������: Borland Delphi 6.0                                      }
{ ��� "��� ����" 2004�.                                               }
{---------------------------------------------------------------------}

unit transf;
interface
uses Windows, ActiveX, scales, transformers;
const
   //����������� ������������
   TXN_UPDATELINKS = 0;  //���������� ������������ ������
   TXN_UPDATEDB    = 1;   //�������� �� �������� ��
   
   //������� ���� ���������� ������������ ���������� ������������
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

// ������� ���������
   ITransformer = interface
   ['{C1A20401-DC60-11d6-9243-00E029288A7F}']
      function GetEditor: HWND; stdcall;
      function GetEmbeddedEditor(const pParent: HWND): HWND; stdcall;

      //���������� ������������ � ����� ���� �������� a_pStream==NULL
      //���������� ������ ������
      function Save(var pStream): integer; stdcall;
      //�������������� ������������ �� ������ ���� �������� a_pStream==NULL
      //���������� ������ ������
      function Load(var pStream): integer; stdcall;

      //�������� �������� ������������ ��� ������ � ���� .mera
      function GetInfoStrings(var pnIndex: integer; var pchBuffer: LPCSTR;
                              const pchPath: LPCSTR;
                              const pchTagName: LPCSTR): integer; stdcall;
      {����������� ���� ����������� ��������� ��� ��}
      function Edit: boolean; stdcall;
      function Eval(const dblValue: double): double; stdcall;
      function GetTXType: TXTYPE; stdcall;
      {��������� �� ��������, ���������� �������� ���� ����������� ���������}
      function UpdateEditor: HRESULT; stdcall;
      function Reset: HRESULT; stdcall;

      {��������/���������� ������������ ��}
      {��� ��������� ����� ���������� ������� ����� ��������� ������,
      ����� ������ ���� �� ����� 256 ��������}
      function GetName(const pchName: LPCSTR): DWORD; stdcall;
      function SetName(const pchName: LPCSTR): HRESULT; stdcall;

      //������ �� ����� .csv
      function ImportFromFile(const a_pchName: LPCSTR;
                              const pchSeparator: LPCSTR): HRESULT; stdcall;
      //������� � ���� .csv
      function ExportToFile(const pchName: LPCSTR;
                            const pchSeparator: LPCSTR): HRESULT; stdcall;

      function GetProgID: LPCSTR; stdcall;

      //������� ��� ����
      function GetTypeName(const pchName: LPCSTR): DWORD; stdcall;

      //���������� �������� ������������ ����������
      function Check: HRESULT; stdcall;

      // �������� ��������
      function GetProperty(dwPropertyID: DWORD; var Value: OleVariant): HRESULT; stdcall;
      // ������ ��������
      function SetProperty(const dwPropertyID: DWORD;
                           {const} Value: OleVariant): HRESULT; stdcall;

      // ������� �����������/��������
      function Notify(const dwCommand: DWORD; const dwParam: DWORD): boolean; stdcall;

      // ��������� ���� �� ����������� ��������
      function TestImportFile(const pchName: LPCSTR): boolean; stdcall;

      //��������� �������� �������� ������� TX
      function EvalInverse(const dblValue: double): double; stdcall;

      // �������� ���� �� ��������� ��� ������� ��
      function GetDefaultCalibrPath : PAnsiChar; stdcall;
      // ������ ���� �� ��������� ��� ������� ��
      procedure SetDefaultCalibrPath(const a_pchPath : PAnsiChar); stdcall;

      // �������� ������ ���������� ���������� �� ��
      function GetLastEvalState : DWORD; stdcall;

      // �������� ������������ ����������� ������������� ��� ������ IMeScales
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

