unit balance;

interface

uses Windows;

const
    BCTRL_BALANCEALLCHANS = $FFFFFFFF;

type
    // данные для обработчик процесса калибровки
    TZBALANCECALLBACKDATA = record
        owner   : Pointer; // некий владелец, nil
        data    : Pointer; // некие данные, nil
        percent : double;  // прогресс в процентах (от драйвера к плагину)
      end;
    PZBALANCECALLBACKDATA = ^TZBALANCECALLBACKDATA;

    pChans_array = array of Pointer; // массив указателей аппаратных каналов

    {IZBalanceCallback = interface (IUnknown)
        function iOnZBalance(fltProgress: Single; // прогресс в процентах (от драйвера к плагину)
                             pAbort: Pbool        // флаг аварийного завершения (от плагина к драйверу)
                            ): HRESULT; stdcall;
    end;}

    IBalanceControl = interface
    ['{ABE913E1-08A3-11d8-9244-00E029288A7F}']
      // Производить балансировку нулей каналов модуля
      function iAutoZeroBalance(const dwChan: DWORD) : HRESULT; stdcall;
      // Ручное управление регистрами балансировки нуля
      function iManualSetBalanceDAC(const dwChan: DWORD; dwLowiDAC: DWORD; dwHiDAC: DWORD) : HRESULT; stdcall;

      // балансировка ME-340
      // virtual HRESULT STDMETHODCALLTYPE iZBalance(HANDLE* pChans, ULONG a_nCount, IZBalanceCallback* pCallBack)=0;
      function iZBalance(const pChans : pChans_array; const a_nCount: LongWord; pCallBack : Pointer; pCallBackData : Pointer) : HRESULT; stdcall;
    end;

implementation

end.
