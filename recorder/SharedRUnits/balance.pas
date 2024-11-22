unit balance;

interface

uses Windows;

const
    BCTRL_BALANCEALLCHANS = $FFFFFFFF;

type
    // ������ ��� ���������� �������� ����������
    TZBALANCECALLBACKDATA = record
        owner   : Pointer; // ����� ��������, nil
        data    : Pointer; // ����� ������, nil
        percent : double;  // �������� � ��������� (�� �������� � �������)
      end;
    PZBALANCECALLBACKDATA = ^TZBALANCECALLBACKDATA;

    pChans_array = array of Pointer; // ������ ���������� ���������� �������

    {IZBalanceCallback = interface (IUnknown)
        function iOnZBalance(fltProgress: Single; // �������� � ��������� (�� �������� � �������)
                             pAbort: Pbool        // ���� ���������� ���������� (�� ������� � ��������)
                            ): HRESULT; stdcall;
    end;}

    IBalanceControl = interface
    ['{ABE913E1-08A3-11d8-9244-00E029288A7F}']
      // ����������� ������������ ����� ������� ������
      function iAutoZeroBalance(const dwChan: DWORD) : HRESULT; stdcall;
      // ������ ���������� ���������� ������������ ����
      function iManualSetBalanceDAC(const dwChan: DWORD; dwLowiDAC: DWORD; dwHiDAC: DWORD) : HRESULT; stdcall;

      // ������������ ME-340
      // virtual HRESULT STDMETHODCALLTYPE iZBalance(HANDLE* pChans, ULONG a_nCount, IZBalanceCallback* pCallBack)=0;
      function iZBalance(const pChans : pChans_array; const a_nCount: LongWord; pCallBack : Pointer; pCallBackData : Pointer) : HRESULT; stdcall;
    end;

implementation

end.
