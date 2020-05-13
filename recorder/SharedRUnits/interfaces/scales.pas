unit scales;
interface
uses Windows;

const
  CLSID_MeScale              : TGUID = '{39790615-9F2E-4289-AE30-FCDF6CCAC8BE}';
  CLSID_MeScaleMultiplier    : TGUID = '{F24645F8-B97F-4092-BECD-EFCFDEB8A1DA}';
  CLSID_MeScaleLinear        : TGUID = '{09426312-3139-4F2E-90BD-F7494375DC58}';
  CLSID_MeScaleInterpolate   : TGUID = '{42622BC6-8725-4EA7-9709-A96F1F382DC0}';
  CLSID_MeScalePolynomial    : TGUID = '{EDE2D8DF-E3F4-4251-87C1-5C0F6FAFF966}';
  CLSID_MeScaleGenPP         : TGUID = '{255BC92E-46D1-4963-9DBD-94BEB3691F95}';
  CLSID_MeScaleMultiPP       : TGUID = '{CFA6E8C2-4D94-4DFB-8BA5-B2EB552DAEBC}';
  CLSID_MeScaleLinearPP      : TGUID = '{C78371A2-24AF-48BD-820E-25795AB6AEA5}';
  CLSID_MeScaleInterpolatePP : TGUID = '{D71CE096-CE0D-483B-8D98-42C6459F208E}';
  CLSID_MeScalePolynomialPP  : TGUID = '{CB850A08-8C62-44A3-9E17-72B1B5B14674}';
  CLSID_MeScaleCSV           : TGUID = '{80D3A9B4-ECB8-4478-924F-2FA311A37FAA}';
  CLSID_MeScaleMERA          : TGUID = '{F7D81A6E-7329-4C29-8B6D-43500A52F776}';
  CLSID_MeScaleBIN           : TGUID = '{64519417-4C54-44CE-9F5F-834D551CC214}';

  IID_IMeScaleEval        : TGUID = '{98CF0EB1-D654-4462-9922-47E10561B327}';
  IID_IMeScaleModMgr      : TGUID = '{AF210D96-BEB4-410C-B6EC-B004842E5433}';
  IID_IMeScaleEdit        : TGUID = '{CB1A77DE-C791-4F67-8490-B35066E7C975}';
  IID_IMeScaleProp        : TGUID = '{89A605A9-3D45-4907-A13F-C173D81162BC}';
  IID_IMeScaleMultiplier  : TGUID = '{DC67C594-6AE9-4B3A-B77C-F99DE374FD97}';
  IID_IMeScaleLinear      : TGUID = '{40A9C1A0-518A-4283-9E30-9CFC83D70128}';
  IID_IMeScaleInterpolate : TGUID = '{68659592-21E3-4FBD-A9D7-B370F0C964A1}';
  IID_IMeScalePolynomial  : TGUID = '{5900C5A4-FA96-4AB8-88B7-9BC78BC243FC}';
  IID_IMeScaleCSV         : TGUID = '{C845ABB8-6207-4B59-A1C8-F6419C36A649}';
  IID_IMeScaleMERA        : TGUID = '{8FB80773-29A1-41E7-92E9-040FC5D952AC}';
  IID_IMeScaleBIN         : TGUID = '{F0D38514-3B05-49BC-804C-AEDF57761C7F}';
  LIBID_SCALESLib         : TGUID = '{94CE6914-C886-4C8A-B12D-A2781AAED9EF}';

  // MESCALESTATES
  ME_SCALES_READONLY	    = $1;
	ME_SCALES_FIXEDTYPE	    = $2;
	ME_SCALES_EXTRAPOLATE	  = $10;
	ME_SCALES_XCUSTOMRANGE	= $20;
	ME_SCALES_YCUSTOMRANGE	= $40;
	ME_SCALES_CHANGED	      = $100;

  // MESCALEERRORS
  ME_SCERR_RANGE       = $1;
	ME_SCERR_RANGE_IN	   = ( ME_SCERR_RANGE or $2 );
	ME_SCERR_RANGE_OUT   = ( ME_SCERR_RANGE or $4 );
	ME_SCERR_RANGE_LO	   = ( ME_SCERR_RANGE or $8 );
	ME_SCERR_RANGE_HI	   = ME_SCERR_RANGE;
	ME_SCERR_RANGE_INHI	 = ME_SCERR_RANGE_IN;
	ME_SCERR_RANGE_INLO  = ( ME_SCERR_RANGE_IN or ME_SCERR_RANGE_LO );
	ME_SCERR_RANGE_OUTHI = ME_SCERR_RANGE_OUT;
	ME_SCERR_RANGE_OUTLO = ( ME_SCERR_RANGE_OUT or ME_SCERR_RANGE_LO );

  // tagMESCALESIDS
  DISPID_ME_SC_NAME	= $1;
	DISPID_ME_SC_DSC	= $2;
	DISPID_ME_SC_PROPCNT	= $101;
	DISPID_ME_SC_PROPNGET	= $102;
	DISPID_ME_SC_PROPGET	= $103;
	DISPID_ME_SC_PROPSET	= $104;
	DISPID_ME_SC_SRCUNITS	= $2000;
	DISPID_ME_SC_DSTUNITS	= $2001;
	DISPID_ME_SC_GETUNITSTYPE	= $2002;
	DISPID_ME_SC_SETUNITSTYPE	= $2003;
	DISPID_ME_SC_STATE	= $2011;
	DISPID_ME_SC_MODULECHNG	= $2012;
	DISPID_ME_SC_MULTIPLIER	= $2020;
	DISPID_ME_SC_A	= $2021;
	DISPID_ME_SC_B	= $2022;
	DISPID_ME_SC_SETSRCRANGE	= $2050;
	DISPID_ME_SC_GETSRCRANGE	= $2051;
	DISPID_ME_SC_SETDSTRANGE	= $2052;
	DISPID_ME_SC_GETDSTRANGE	= $2053;
	DISPID_ME_SC_SETTIME	= $2054;
	DISPID_ME_SC_GETTIME	= $2055;
	DISPID_ME_SC_GETTYPESTR	= $2056;
	DISPID_ME_SC_GETINFOSTR	= $2057;
	DISPID_ME_SC_CHECK	= $2059;
	DISPID_ME_SC_APPLY	= $205a;
	DISPID_ME_SC_CLONE	= $205b;
	DISPID_ME_SC_COPY	= $205c;
	DISPID_ME_SC_COMPARE	= $205d;
	DISPID_ME_SC_NODESCOUNT	= $2060;
	DISPID_ME_SC_GETNODE	= $2061;
	DISPID_ME_SC_INSERTNODE	= $2062;
	DISPID_ME_SC_DELETENODE	= $2063;
	DISPID_ME_SC_POWER	= $2064;
	DISPID_ME_SC_GETCOEFFICIENT	= $2065;
	DISPID_ME_SC_SETCOEFFICIENT	= $2066;

type

  IMeScaleEval = interface
  ['{98CF0EB1-D654-4462-9922-47E10561B327}']
    function Eval(dSrc : double; var pdDst : double): HRESULT; stdcall;
    function EvalEx(dSrc :  double; var pdDst : double; var pdwState : DWORD): HRESULT; stdcall;
    function EvalInverse(dDst : double; var pdSrc : double): HRESULT; stdcall;
    function EvalInverseEx(dDst : double; var pdSrc : double; var pdwState : DWORD): HRESULT; stdcall;
  end;

  IMeScaleModMgr = interface
  ['{AF210D96-BEB4-410C-B6EC-B004842E5433}']
    function GetModuleClassID(var pClassID : TGUID): HRESULT; stdcall;
    function SetModuleClassID(classID : TGUID): HRESULT; stdcall;
    function GetModuleInterface(classID : TGUID; var ppvObject : IUnknown): HRESULT; stdcall;
    function SetModule(pModule : IUnknown): HRESULT; stdcall;
  end;

  IMeScaleEdit = interface
  ['{CB1A77DE-C791-4F67-8490-B35066E7C975}']
    function get_State(var pState : DWORD): HRESULT; stdcall;
    function put_State(newState : DWORD): HRESULT; stdcall;
    function Clone(var ppvNewScale : IUnknown): HRESULT; stdcall;
    function Copy(pvDestScale : IUnknown): HRESULT; stdcall;
    function Compare(pvTestScale : IUnknown; var pResult : DWORD): HRESULT; stdcall;
    function GetTypeStr(var pVal : WideString): HRESULT; stdcall;
    function GetInfoStr(var pVal : WideString): HRESULT; stdcall;
  end;
        
  IMeScaleProp = interface
  ['{89A605A9-3D45-4907-A13F-C173D81162BC}']
    function get_Name(var pVal : WideString): HRESULT; stdcall;
    function put_Name(newVal : WideString): HRESULT; stdcall;
    function get_Dsc(var pVal : WideString): HRESULT; stdcall;
    function put_Dsc(newVal : WideString): HRESULT; stdcall;
    function get_SrcUnits(var pVal : WideString): HRESULT; stdcall;
    function put_SrcUnits(newVal : WideString): HRESULT; stdcall;
    function get_DstUnits(var pVal : WideString): HRESULT; stdcall;
    function put_DstUnits(newVal :WideString): HRESULT; stdcall;
    function GetSrcRange(var pdwFrom : double; var pdwTo : double): HRESULT; stdcall;
    function SetSrcRange(dwFrom : double; dwTo : double): HRESULT; stdcall;
    function GetDstRange(var pdwFrom : double; var pdwTo : double): HRESULT; stdcall;
    function SetDstRange(dwFrom : double; dwTo : double): HRESULT; stdcall;
    function Check(var state : DWORD): HRESULT; stdcall;
    function GetTime(var pftTime : VARIANT): HRESULT; stdcall;
    function SetTime(ftTime : VARIANT): HRESULT; stdcall;
    function Apply(): HRESULT; stdcall;
    function GetUnitsType(var pulSrcType : ULONG; var pullSrcUnits : ULONGLONG; var pulDstType : ULONG; var pullDstUnits : ULONGLONG): HRESULT; stdcall;
    function SetUnitsType(ulSrcType : ULONG; ullSrcUnits : ULONGLONG; ulDstType : ULONG; ullDstUnits : ULONGLONG): HRESULT; stdcall;
    function PropCount(var pVal : Integer): HRESULT; stdcall;
    function PropNGet(nProp : Integer;var pName : WideString; var pVal : WideString): HRESULT; stdcall;
    function PropGet(Name : WideString; var pVal : WideString): HRESULT; stdcall;
    function PropSet(Name : WideString; Val : WideString): HRESULT; stdcall;
  end;

  IMeScaleMultiplier = interface
  ['{DC67C594-6AE9-4B3A-B77C-F99DE374FD97}']
    function get_Multiplier(var pVal : double): HRESULT; stdcall;
    function put_Multiplier(newVal : double): HRESULT; stdcall;
  end;

  IMeScaleLinear = interface
  ['{40A9C1A0-518A-4283-9E30-9CFC83D70128}']
    function get_A(var pA : double): HRESULT; stdcall;
    function put_A(newA : double): HRESULT; stdcall;
    function get_B(var pB : double): HRESULT; stdcall;
    function put_B(newB : double): HRESULT; stdcall;
  end;
        
  IMeScaleInterpolate = interface
  ['{68659592-21E3-4FBD-A9D7-B370F0C964A1}']
    function get_NodesCount(var pdwCount : DWORD): HRESULT; stdcall;
    function GetNode(var pdblValX : double; var pdblValY : double; nIndex : Integer): HRESULT; stdcall;
    function InsertNode(dblValX : double; dblValY : double; var pnIndex : integer): HRESULT; stdcall;
    function DeleteNode(nIndex : integer): HRESULT; stdcall;
  end;
        
  IMeScalePolynomial = interface
  ['{5900C5A4-FA96-4AB8-88B7-9BC78BC243FC}']
    function get_Power(var pPower : Integer): HRESULT; stdcall;
    function put_Power(newPower : Integer): HRESULT; stdcall;
    function GetCoefficient(var pdblCoefficient : double; pnIndex : Integer): HRESULT; stdcall;
    function SetCoefficient(Coefficient : double; nIndex : Integer): HRESULT; stdcall;
  end;

  IMeScaleCSV = interface
  ['{C845ABB8-6207-4B59-A1C8-F6419C36A649}']
    function Save(var pScale : IUnknown; const fileName : WideString; bSaveType : BOOL): HRESULT; stdcall;
    function Load(var pScale : IUnknown; const fileName : WideString; bDetectType : BOOL): HRESULT; stdcall;
  end;
        
  IMeScaleMERA = interface
  ['{8FB80773-29A1-41E7-92E9-040FC5D952AC}']
    function Load(fileName : WideString; paramName : WideString; var pnCount : DWORD; var pppScales : IUnknown): HRESULT; stdcall;
    function Save(fileName : WideString; paramName : WideString; nCount : DWORD; var ppScales : IUnknown): HRESULT; stdcall;
  end;

  IMeScaleBIN = interface
  ['{F0D38514-3B05-49BC-804C-AEDF57761C7F}']
    function Load(pScale : IUnknown; nCount : DWORD; var pBuf : BYTE): HRESULT; stdcall;
    function Save(pScale : IUnknown; var pnCount : DWORD; var ppBuf : BYTE): HRESULT; stdcall;
  end;
implementation
end.
