unit uAlarms;

interface

uses Windows, ActiveX, signal, tags;

type
  VARIANT_BOOL = short;

  BStr = TBStr;
  COLORREF = integer;

const
  Variant_True=-1;
  Variant_False=0;

  ALM_FIXED_VALUE = 0;
	ALM_LINE = 1;

// {25AB9A87-EE0E-4a65-B535-761FD235C232}
  IID_IAlarmEvent: TGUID = (
    D1:$25ab9a87;  D2: $ee0e; D3: $4a65; D4: ($b5, $35, $76, $1f, $d2, $35, $c2, $32 ));

  // {5DCF608C-846A-4af6-8976-636D45D80765}
  IID_IAlarmsHandler: TGUID = (
    D1:$5dcf608c;  D2: $846a; D3: $4af6; D4: ($89, $76, $63, $6d, $45, $d8, $07, $65));

  // {4555B4F4-721B-4781-BF28-2F3B3D51BC20}
  IID_IAlarmsControl_1: TGUID = (
    //   4555b4f4       721b       4781        bf   28   2f   3b   3d   51   bc   20
    D1: $4555b4f4; D2: $721B; D3: $4781; D4: ($bf, $28, $2f, $3b, $3d, $51, $bc, $20));

  // {47248BF5-198C-417c-9A6A-EE3AB8F46020}
  IID_IAlarmsControl: TGUID = (
    //   47248BF5       198C       417c           9a   6a   ee   3a   b8   f4   60   20
    D1: $47248BF5; D2: $198C; D3: $417c;    D4: ($9A, $6A, $EE, $3A, $B8, $F4, $60, $20));

  // {A6C5971C-E555-45f7-9392-01E8C49E8624}
  IID_IAlarm: TGUID = (
    //   a6c5971c       e555       45f7        93   92   01   e8  c4    9e   86   24
    D1: $A6C5971C; D2: $E555; D3: $45F7; D4: ($93, $92, $01, $E8, $C4, $9E, $86, $24));

// {4CBF0ABB-76D7-439c-8F3B-DDE85BB0A138}
  IID_IAlarmEventHandler: TGUID = (
    //   4cbf0abb       76d7       439c        8f   3b   dd   e8   5b   b0   a1   38
    D1: $4CBF0ABB; D2: $76D7; D3: $439C; D4: ($8F, $3B, $DD, $E8, $5B, $B0, $A1, $38));


type
  IAlarmHolder = interface
    ['{25AB9A87-EE0E-4a65-B535-761FD235C233}']
    //virtual HRESULT STDMETHODCALLTYPE GetState(ULONG* a_pnState)const=0;
    function GetState(var a_pnState: ULONG): HRESULT;stdcall;
  end;

  // IAlarmEvent
  // callback ��������� ��� ���������� � ������������ �������
  // �������� �������� ������� ������ ����������� �������
  // �������������� IAlarmEvent � ���������������� �� � ��������������� IAlarmHolder
  IAlarmEvent = interface
    ['{25AB9A87-EE0E-4a65-B535-761FD235C232}']
		// ������� - ��������� �������
		// virtual HRESULT STDMETHODCALLTYPE OnAlarm(/*IAlarmHolder* a_pAlarm*/)=0;
    function OnAlarm(var a_pAlarm: IAlarmHolder): HRESULT;stdcall;
		// ������� - ����� �� ��������� "��������� �������"
		// virtual HRESULT STDMETHODCALLTYPE OnAlarmLeave(/*IAlarmHolder* a_pAlarm*/)=0;
    function OnAlarmLeave(var a_pAlarm: IAlarmHolder): HRESULT;stdcall;
  end;


  IAlarmsHandler = interface
    ['{A6C5971C-E555-45f7-9392-01E8C49E8624}']
		// ��������� ��������
		//virtual HRESULT STDMETHODCALLTYPE ProcessValue(double a_dblValue, VARIANT_BOOL* a_pAlarm)=0;
    function ProcessValue(a_dblValue: double; var a_pAlarm: VARIANT_BOOL): HRESULT;stdcall;
  end;

  IAlarm = interface
    ['{A6C5971C-E555-45f7-9392-01E8C49E8624}']
    // �������� �������
    // virtual HRESULT STDMETHODCALLTYPE GetLevel(double* a_pdblLevel)=0;
    function GetLevel(var a_pdblLevel: double): HRESULT;stdcall;
    // ���������� �������
    // virtual HRESULT STDMETHODCALLTYPE SetLevel(double a_dblLevel)=0;
    function SetLevel(a_dblLevel: double): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE GetEnabled(VARIANT_BOOL* a_pbFlag)=0;
    function GetEnabled(var a_pbFlag: VARIANT_BOOL): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE SetEnabled(VARIANT_BOOL a_bFlag)=0;
    function SetEnabled(a_pbFlag: VARIANT_BOOL): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE GetRecTrigger(VARIANT_BOOL* a_pbFlag)=0;
    function GetRecTrigger(var a_pbFlag: VARIANT_BOOL): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE SetRecTrigger(VARIANT_BOOL a_bFlag)=0;
    function SetRecTrigger(a_pbFlag: VARIANT_BOOL): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE GetSignalTo(BSTR* a_pbstrName)=0;
    function GetSignalTo(var a_pbstrName: BStr): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE SetSignalTo(BSTR a_pbstrName)=0;
    function SetSignalTo(a_pbstrName: BStr): HRESULT;stdcall;
	  // virtual HRESULT STDMETHODCALLTYPE GetSignalFrom(BSTR* a_pbstrName) = 0;
    function GetSignalFrom(var a_pbstrName: BStr): HRESULT;stdcall;
	  // virtual HRESULT STDMETHODCALLTYPE SetSignalFrom(BSTR a_pbstrName) = 0;
    function SetSignalFrom(a_pbstrName: BStr): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE GetSignalToValue(double* a_pdblVal)=0;
    function GetSignalToValue(var a_pdblVal: double): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE SetSignalToValue(double a_dblVal)=0;
    function SetSignalToValue(var a_dblVal: double): HRESULT;stdcall;

    // �������� ��� �������
    // ��������� ������ ������������� �������� COM
    // ������� ����� ��������� ����� ��������� ���������� ������
    // virtual HRESULT STDMETHODCALLTYPE GetName(BSTR* a_pbstrName)=0;
    function GetName(var a_pbstrName: BStr): HRESULT;stdcall;
    // ���������� ��� �������
    // virtual HRESULT STDMETHODCALLTYPE SetName(BSTR a_pbstrName)=0;
    function SetName(a_pbstrName: BStr): HRESULT;stdcall;

    // �������� ����
    // virtual HRESULT STDMETHODCALLTYPE GetColor(COLORREF* a_pColor)=0;
    function GetColor(var a_pColor: COLORREF): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE SetColor(COLORREF a_clColor)=0;
    function SetColor(a_clColor: COLORREF): HRESULT;stdcall;

    // virtual HRESULT STDMETHODCALLTYPE Reset()=0;
    function Reset(): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE AddEventHandler(IAlarmEvent* a_pHandler)=0;
    function AddEventHandler(a_pHandler: IAlarmEvent): HRESULT;stdcall;

		// ���� � ��������� ����� ���������������� ��� ������������ �������
		// ���� ������ ������,������ �������� ������ ��������
    //virtual HRESULT STDMETHODCALLTYPE GetSoundName(BSTR* a_pbstrPath)=0;
    function GetSoundName(var a_pbstrPath: BSTR): HRESULT;stdcall;
		//virtual HRESULT STDMETHODCALLTYPE SetSoundName(BSTR a_bstrPath)=0;
    function SetSoundName(a_pbstrName: BStr): HRESULT;stdcall;

    // ���������� � ���������
    // virtual HRESULT STDMETHODCALLTYPE GetGistPerc(double* a_pdblP)=0;
    function GetGistPerc(var a_pdblP: double): HRESULT;stdcall;
    // virtual HRESULT STDMETHODCALLTYPE SetGistPerc(double a_dblP)=0;
    function SetGistPerc(var a_dblP: double): HRESULT;stdcall;

	  // since rc version 3.3.4.29

	  // ��������� ����� ������ ��������������� �� ����� ��������� ����� ����� ��������
	  //virtual HRESULT STDMETHODCALLTYPE GetPlayTillTheEnd(VARIANT_BOOL* a_pbFlag) const = 0;
    function GetPlayTillTheEnd(var a_pbFlag: VARIANT_BOOL): HRESULT;stdcall;

	  // ��������� ����� ������ ��������������� �� ����� ��������� ����� ����� ��������
	  //virtual HRESULT STDMETHODCALLTYPE SetPlayTillTheEnd(VARIANT_BOOL a_bFlag) = 0;
    function SetPlayTillTheEnd(var a_pbFlag: VARIANT_BOOL): HRESULT;stdcall;

	  // ����� ������� ������� - ������������� �������� ��� ����� (�������� ����.�������)
	  //virtual HRESULT STDMETHODCALLTYPE GetMode(ULONG* pnMode) const = 0;
    function GetMode(var pnMode: ULONG): HRESULT;stdcall;
	  //virtual HRESULT STDMETHODCALLTYPE SetMode(ULONG nMode) = 0;
    function SetMode(pnMode: ULONG): HRESULT;stdcall;
  end;

  IAlarmEventHandler = interface
    ['{4CBF0ABB-76D7-439C-8F3B-DDE85BB0A138}']
	  //public:	virtual HRESULT STDMETHODCALLTYPE OnAlarmEvent(
		//	ITag* pTag, 		// ����� �� ������� ��������� �������
		//	IAlarm* pAlarm, // ������� ������� ���������
		// 	int nIndex,			// ������� ������� ��������� �����
		//	double dblVal,	// ��������
		//	ULONG flags			// �����,
		//	)=0;
    function OnAlarmEvent(pTag: ITag; pAlarm:IAlarm; nIndex:integer; dblVal:double; flags:ULONG): HRESULT;stdcall;
  end;

// @interface IAlarmsControl
// ��������� ��������� � ���������� ��������� ����
// ����� �������� ����������� ITag::QueryInterface(IID_IAlarmsControl)
// ��������� ��� ���������� �����
  IAlarmsControl = interface
    ['{47248BF5-198C-417c-9a6a-ee3ab8f46020}']
    // ��������� / ��������� ��������� �������
    //virtual HRESULT STDMETHODCALLTYPE EnableAlarmsProcessing(VARIANT_BOOL vbEnable) = 0;
    function EnableAlarmsProcessing(vbEnable: VARIANT_BOOL): HRESULT; stdcall;

    // �������� ����� �������
    //virtual HRESULT STDMETHODCALLTYPE GetAlarmsCount(/*[out, retval]*/ULONG* punCount) = 0;
    function GetAlarmsCount(var punCount: ULONG): HRESULT; stdcall;

    // �������� �������
    //virtual HRESULT STDMETHODCALLTYPE GetAlarm(/*[in]*/ ULONG a_unIndex, /*[out]*/IAlarm** ppAlarm) = 0;
    function GetAlarm(const a_unIndex : ULONG; var ppAlarm: IAlarm): HRESULT; stdcall;

    // �������� ������� ������������� �������� ���� ��� ����������� ��������� �������
    //virtual HRESULT STDMETHODCALLTYPE GetIsStateTagUsed(VARIANT_BOOL * isStateTagUsed) = 0;
    function GetIsStateTagUsed(var isStateTagUsed: VARIANT_BOOL): HRESULT; stdcall;

    // ���������� ������� ������������� �������� ���� ��� ����������� ��������� �������
    //virtual HRESULT STDMETHODCALLTYPE SetIsStateTagUsed(VARIANT_BOOL isStateTagUsed) = 0;
    function SetIsStateTagUsed(isStateTagUsed: VARIANT_BOOL): HRESULT; stdcall;

    // �������� ��� �������� ���� ��� ����������� ��������� �������
    //virtual HRESULT STDMETHODCALLTYPE GetStateTag(BSTR * StateTag) = 0;
    function GetStateTag(var StateTag: BSTR): HRESULT; stdcall;

    // ���������� ��� �������� ���� ��� ����������� ��������� �������
    //virtual HRESULT STDMETHODCALLTYPE SetStateTag(BSTR StateTag) = 0;}
    function SetStateTag(StateTag: BSTR): HRESULT; stdcall;
  end;

implementation

end.
