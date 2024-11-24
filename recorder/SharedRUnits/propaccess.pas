unit propaccess;

interface

uses Windows, DevAPI_const;

const
  IID_IPropertyAccess : TGUID = '{46E03D04-068A-4dd4-881F-0D8E54158828}';

  // ”ниверсальный интерфейс доступа к свойствам объекта
  // через функции Get/SetProperty

type
   IPropertyAccess = interface
   ['{46E03D04-068A-4dd4-881F-0D8E54158828}']
      function SetProperty(const nPropertyID : DWORD; var Value : OleVariant; const nIndex : Integer) : HRESULT; stdcall;
      function GetProperty(const nPropertyID : DWORD; var Value : OleVariant; const nIndex : Integer) : HRESULT; stdcall;
   end;

(*
// {46E03D04-068A-4dd4-881F-0D8E54158828}
static const GUID IID_IPropertyAccess =
{ 0x46e03d04, 0x68a, 0x4dd4, { 0x88, 0x1f, 0xd, 0x8e, 0x54, 0x15, 0x88, 0x28 } };

--------------------------------------------------------------

extern const GUID IID_IPropertyAccess;
class IPropertyAccess : public IUnknown
{
public:
	virtual HRESULT STDMETHODCALLTYPE SetProperty(
			ULONG nPropertyID,
			const VARIANT& varValue,
			int nIndex
		) = 0;

	virtual HRESULT STDMETHODCALLTYPE GetProperty(
			ULONG nPropertyID,
			VARIANT& varValue,
			int nIndex
		) = 0;
};
*)

implementation

end.
