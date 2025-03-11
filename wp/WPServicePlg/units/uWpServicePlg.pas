unit uWpServicePlg;
{$WARN SYMBOL_PLATFORM OFF}
// в свойствах проекта для дебуга включить опции Delphi Compiler/linking/
// Debug info ,include remote debug , map files,

interface

uses
  Windows, ActiveX, Classes, ComObj, StdVcl, uBaseObjService,
  Winpos_ole_TLB, POSBase, SysUtils, Forms, wpExtPack_TLB,
  dialogs,
  uWPservices,
  variants,
  WPServicePack_TLB,
  Messages,
  uWPEvents,
  uCommonMath,
  uCommonTypes,
  uJournalForm,
  uSyncThread,
  ulogfile,
  PerformanceTime,
  inifiles;

type
  TServicePlg = class(TAutoObject, IWPPlugin)
  protected
    hooktime: double;
    // хендл главного окна
    mainwnd: cardinal;
    // сслыка на sniffDll. Грузиться динамически
    HLib: thandle;
    WM_KeyHOOK: cardinal;
    m_firstHook: boolean;
    tagproc: function(p_tag: integer): integer;
    stdcall;
    oldWndProc, newWndProc: pointer;
  public
    init: boolean;
    // используется для клавиатурного хука
    m_showlegend: boolean;
  private
    procedure CreateSubSignals;
    procedure createWndProc;
    procedure CreateWndHook;
  public
    // надо бы создавать в интерфейсном потоке
    procedure CreateFrm;
    Procedure WndProc(var Msg: TMessage);
    function Connect(const app: IDispatch): integer; safecall;
    function Disconnect: integer; safecall;
    function NotifyPlugin(what: integer; var param: OleVariant): integer;
      safecall;
  end;

var
  startDir: string;
  g_ServicePlg: TServicePlg;

const
  e_OnAddSRC = $00002000;

implementation

uses ComServ;

const
  c_wpservicepack_tag = 100002;
  vbEmpty = 0;
  vbNull = 1;
  vbInteger = 2;
  vbLong = 3;
  vbSingle = 4;
  vbDouble = 5;
  vbCurrency = 6;
  vbDate = 7;
  vbString = 8;
  vbObject = 9;
  vbError = 10;
  vbBoolean = 11;
  vbVariant = 12;
  vbDataObject = 13;
  vbDecimal = 14;
  vbByte = 17;
  vbArray = 8192;
  DllName = 'SniffDll.dll';
  // опции графики
  GROPT_SHOWLEGEND = $0200;

var
  c_vers: string = 'Скомпилирован 06.09.17';

var
  // Событие загрузки файла ((5 shl 16) or 1)
  // 327681 - событие вызывается при загрузке файла
  // $000f0001 событие вызова алгоритма. в событие передается
  InPlugunCode: boolean = false;
  // происходит по событию выполнения алгbitmоритма
  ID_NotifyEvent: cardinal;

procedure TServicePlg.createWndProc;
begin
  mainwnd := WINPOS.mainwnd;
  newWndProc := MakeObjectInstance(WndProc);
  oldWndProc := pointer(SetWindowLong(mainwnd, gwl_wndProc,
      cardinal(newWndProc)));
end;

procedure TServicePlg.CreateWndHook;
var
  StartHookProc: function(switch: boolean; hMainProg: hwnd): integer stdcall;
  res: integer;
  str: string;
begin
  str := startDir + '\' + DllName;
  HLib := LoadLibrary(@str[1]);
  if HLib > HINSTANCE_ERROR then
  begin
    // регестрируем свой тип сообщения в системе
    WM_KeyHOOK := RegisterWindowMessage('WM_OburecKeyHook');
    // получаем указатель на необходимую процедуру
    StartHookProc := GetProcAddress(HLib, 'SetHook');
    tagproc := GetProcAddress(HLib, 'SetTag');
    res := StartHookProc(true, mainwnd);
    logmessage('TServicePlg_MainWnd=' + inttostr(mainwnd));
    res := tagproc(-1);
    if res <> 0 then
    begin
      m_firstHook := false;
      // oldwndproc:=pointer(res);
    end
    else
    begin
      m_firstHook := true;
    end;

  end;
end;

function TServicePlg.Connect(const app: IDispatch): integer;
var
  hbmp, hbmp2: cardinal;
  date: tdatetime;
  str: string;
begin
  startDir := extractfiledir(Application.ExeName) + '\plugins\WPExtPack\';
  g_logFile := clogfile.create(startDir + 'log.txt', ';');
  init := false;
  WINPOS := app as IWinPOS;
  g_ServicePlg := self;

  // создаем клавиатурный хук
{$IFDEF DEBUG}
{$ELSE}
  // g_logFile.addInfoMes('TServicePlg.WndProc_'+' Mess:'+'Release');
  createWndProc;
  CreateWndHook;
{$ENDIF}
  ID_NotifyEvent := 9 shl 16 + 1;
  date := now;
  c_vers := 'Скомпилирован ' + datetostr(now);
  str := c_vers;
  Result := 0;
end;

procedure TServicePlg.CreateFrm;
begin
  // создание форм

end;

function TServicePlg.Disconnect: integer;
var
  StartHookProc: function(switch: boolean; hMainProg: hwnd): integer stdcall;
begin

  Result := 0;
  SetWindowLong(mainwnd, gwl_wndProc, integer(oldWndProc));
  // удаляем клавиатурный хук
  if HLib > HINSTANCE_ERROR then
  begin
    // освобождаем библиотеку
    StartHookProc(false, mainwnd);
    FreeLibrary(HLib);
  end;
  if g_logFile <> nil then
  begin
    g_logFile.destroy;
    g_logFile := nil;
  end;
end;

procedure SigCloud(s: iwpsignal; line: integer);
var
  prop: string;
begin
  prop := s.GetProperty('.cloud');
  if prop = '1' then
  begin
    setLineCloud(line);
  end;
end;

procedure SigNullPoly(s: iwpsignal; line: integer);
var
  prop: string;
begin
  prop := s.GetProperty('.nullpoly');
  if prop = '1' then
  begin
    setLineNullPoly(line);
  end;
end;

procedure SigHist(s: iwpsignal; line: integer);
var
  prop: string;
begin
  prop := s.GetProperty('.gist');
  if prop = '1' then
  begin
    setLineHist(line);
  end;
end;

procedure SigFlags(s: iwpsignal; line: integer);
var
  prop, path: string;
  flags: iwpsignal;
  n: iwpnode;
  i: integer;
  p2: point2d;
begin
  prop := s.GetProperty('Flags');
  if prop <> '' then
  begin
    n := findNode(s);
    path := iwpnode(n.Parent).AbsolutePath + '/Flags/' + prop;
    flags := getISignalByPath(path);
    for i := 0 to flags.size - 1 do
    begin
      p2.x := flags.GetX(i);
      p2.y := flags.GetY(i);
      // устанавливаем флаг
      IWPGraphs(WINPOS.GraphApi).AddLabel(line, 0, p2.x,
        ((p2.x - s.MinX) / (s.MaxX - s.MinX)), 5, ' ');
    end;
  end;
end;

function TServicePlg.NotifyPlugin(what: integer;
  var param: OleVariant): integer;
var
  alg, src: string;
  str1, str2: string;
  strList: tstringlist;
  i, axtype: integer;
  // в алгоритм передается несколько сигналов
  double: boolean;

  pvar: array of variant;
  hgraph, haxis, hline: integer;

  isig, linesig: iwpsignal;
  hword: cardinal;
begin
  Result := 0;
  if not InPlugunCode then
  begin
    InPlugunCode := true;
    try
      try
        if (what <> 131071) and (what <> 196607) then
        begin
          hword := HIWORD(what);
          // what = $1006 then  ADD_LINE нотификация о добавлении линии на график
          if what = 268828673 then
          // if (what = 270073857) or (what=268828673) or (what=269352961) then
          begin
            if PSafeArray(TVarData(param).VArray)
              .rgsabound[0].cElements = 3 then
            begin
              pvar := (PSafeArray(TVarData(param).VArray).pvdata);
              str1 := variant(pvar[0]);
              // pvar[1].lVal;
              hgraph := pvar[1];
              haxis := pvar[2];
              isig := FindSignal(str1);
              // ищем hline по сигналу
              for i := 0 to IWPGraphs(WP.GraphApi).GetLineCount(hgraph) - 1 do
              begin
                hline := IWPGraphs(WP.GraphApi).GetLine(hgraph, i);
                linesig := iwpsignal(IWPGraphs(WP.GraphApi).GetSignal(hline));
                if isig.Instance = linesig.Instance then
                begin
                  break
                end
                else
                  hline := -1;
              end;
              SigCloud(isig, hline);
              SigNullPoly(isig, hline);
              SigHist(isig, hline);
              SigFlags(isig, hline);
              // Events.CallAllEvents(E_OnAddLine);
            end;
          end;
        end;
        // Del_LINE удаление линии с графика
        // if what = $1007 then
        if what = 268894209 then
        begin
          if PSafeArray(TVarData(param).VArray).rgsabound[0].cElements = 3 then
          begin
            pvar := (PSafeArray(TVarData(param).VArray).pvdata);
            str1 := variant(pvar[0]);
            hgraph := pvar[1];
            haxis := pvar[2];

          end;
        end;
        // DEL_GRAPH удаление графика
        if hword = $1004 then
        begin
          // cwpGraph(obj).hgraph = param then
          // удалить если динамически читается графика
        end;
        // NODE_RENAMING = 0x101f0001
        if what = $101F0001 then
        begin

        end;
        // Нотификация прилинковки к дереву нового узла 0x00070001
        if what = $00070001 then
        begin
          init := true;
          // mng.doAddNode(param);
        end;
        // NODE_RENAMED = 0x10200001
        if what = $10200001 then
        begin
          // mng.doRenamedNode(param);
        end;
        // del_node
        // if what = 270401537 then
        if what = $101E0001 then
        begin
          // mng.doDestroyNode(param);
        end;

        // Событие загрузки файла ((5 shl 16) or 1) или восстановления сеанса
        if what = 327681 then
        begin

        end;
        if what = $000A0001 then
        begin

        end
        else
        // строка описания вызова алгоритма и список сигналов
          if what = $000F0001 then
        begin
          str1 := param;

        end;
        Result := 0;
      finally
        begin
          InPlugunCode := false;
        end;
      end
    except
    end;
  end;
end;

procedure TServicePlg.CreateSubSignals;
var
  p2: point2d;
  str, path, savepath: string;
  i, j, start, endind: integer;
  sig, parentsig: iwpsignal;
  d: IDispatch;
  // залипуха пока не работает saveusml
  dir, srcFile, dstFile, fname: string;
  b: boolean;
  n, src: iwpnode;
  f: tinifile;
  datasize, readed: integer;
  fbin1: file;
  data: array of double;
  m: iwpusml;
  parentList: tstringlist;
begin
  p2 := GetActiveCursorX;
  if p2.x <> p2.y then
  begin
    src := GetCurSrcInMainWnd;
    if src <> nil then
    begin
      str := src.AbsolutePath;
      fname := TrimExt(src.name);
      path := str + '/' + fname + '_sub_001';
      d := WP.GetNodeStr(path);
      while Supports(d, DIID_IWPNode) do
      begin
        path := modname(path, false);
        d := WP.GetNodeStr(path);
      end;
      for i := 0 to getChildCount(src) - 1 do
      begin
        sig := GetChildSignal(src, i);
        start := sig.IndexOf(p2.x);
        endind := sig.IndexOf(p2.y);
        sig := sig.Clone(start, endind - start) as iwpsignal;
        WP.Link(path, sig.sname, sig);
      end;
      WP.Refresh;

      sig := nil;
      if isusml(src) then
      begin
        m := TypeCastToIWPUSML(src);
        dir := extractfiledir(m.FileName) + '\';
        savepath := dir;
        for j := length(path) downto 1 do
        begin
          if path[j] = '/' then
          begin
            str := Copy(path, j + 1, length(path) - j);
            savepath := savepath + str + '\' + str + '.mera';
            break;
          end;
        end;
        WP.SaveUSML(path, savepath);
      end;
    end;
  end;
end;

Procedure TServicePlg.WndProc(var Msg: TMessage);

var
  opt, g, p, v, ltag: integer;
  t: double;
begin

  // (msg.msg>128) and (msg.msg<>275)
  //if Msg.Msg = WM_KEYDOWN then
  {if (Msg.Msg<>WM_TIMER) and (Msg.Msg<>WM_NOTIFY) and (Msg.Msg<>WM_paint)
  and (Msg.Msg<>WM_size) and (Msg.Msg<>WM_ERASEBKGND) and (Msg.Msg<>WM_MOVE)
  and (Msg.Msg<>WM_GETMINMAXINFO) and (Msg.Msg<>WM_GETMINMAXINFO)
  and (Msg.Msg<>WM_WINDOWPOSCHANGING)  and (Msg.Msg<>WM_nccreate)
  and (Msg.Msg<>WM_setcursor) and (Msg.Msg<>146) and (Msg.Msg<>147)
  and (Msg.Msg<>831) and (Msg.Msg<>878) and (Msg.Msg<>28) and (Msg.Msg<>6) and (Msg.Msg<>7) and (Msg.Msg<>8)
  and (Msg.Msg<>145) and (Msg.Msg<>134) and (Msg.Msg<>71) and (Msg.Msg<>31) and (Msg.Msg<>124) and (Msg.Msg<>125) and (Msg.Msg<>127)
  and (Msg.Msg<>799) and (Msg.Msg<>866) and (Msg.Msg<>8) and (Msg.Msg<>13) and (Msg.Msg<>12) and (Msg.Msg<>148)
  and (Msg.Msg<>289) and (Msg.Msg<>293) and (Msg.Msg<>533) and (Msg.Msg<>287) and (Msg.Msg<>85) and (Msg.Msg<>877)
  and (Msg.Msg<>641) and (Msg.Msg<>642) and (Msg.Msg<>133) and (Msg.Msg<>131) and (Msg.Msg<>1154) and (Msg.Msg<>10)
  and (Msg.Msg<>875) and (Msg.Msg<>1575) and (Msg.Msg<>874) and (Msg.Msg<>174) and (Msg.Msg<>297) and (Msg.Msg<>133)
  and (Msg.Msg<>885) and (Msg.Msg<>132) and (Msg.Msg<>160) and (Msg.Msg<>674)
  then
    logmessage('TServicePlg_ltag='+inttostr(Msg.Msg));}
  if Msg.Msg = WM_KeyHOOK then
  //if (Msg.Msg = WM_CHAR) or (Msg.Msg = WM_keydown) then
  begin
    ltag := tagproc(c_wpservicepack_tag);
    //logmessage('TServicePlg_ltag='+inttostr(ltag));
    if ltag = -1 then
    begin
      t := gettimeinsec;
      //logmessage(floattostr(t - hooktime));
      if abs(t - hooktime) > 0.1 then
      begin
        if (mainwnd = hwnd(Msg.lParam)) then
        begin
          // добавить замер Control
          if GetKeyState(VK_MENU) < 0 then
          begin
            if Msg.wParam = Ord('D') then
            begin
              CreateSubSignals;
            end;
            if Msg.wParam = Ord('T') then
            begin
              //logmessage('TServicePlg_T');
            end;
            // перебор типов курсоров
            if Msg.wParam = Ord('3') then
            begin
              //logmessage('TServicePlg_3');
              p := IWPGraphs(WP.GraphApi).ActiveGraphPage;
              g := IWPGraphs(WP.GraphApi).ActiveGraph(p);
              v := IWPGraphs(WP.GraphApi).GetCursorType(p);
              if v < 4 then
                inc(v)
              else
                v := 1;
              IWPGraphs(WP.GraphApi).ShowCursor(p, v);
              IWPGraphs(WP.GraphApi).invalidate(g);
            end;
            if Msg.wParam = Ord('L') then
            begin
              //logmessage('TServicePlg_L');
              if not m_showlegend then
              begin
                m_showlegend := true;
                p := IWPGraphs(WP.GraphApi).ActiveGraphPage;
                g := IWPGraphs(WP.GraphApi).ActiveGraph(p);
                IWPGraphs(WP.GraphApi).SetGraphOpt(g, GROPT_SHOWLEGEND, GROPT_SHOWLEGEND);
              end
              else
              begin
                m_showlegend := false;
                p := IWPGraphs(WP.GraphApi).ActiveGraphPage;
                g := IWPGraphs(WP.GraphApi).ActiveGraph(p);
                IWPGraphs(WP.GraphApi).SetGraphOpt(g, 0, GROPT_SHOWLEGEND);
              end;
            end;
          end;
        end;
        hooktime := t;
      end;
      //logmessage('TServicePlg_exit');
    end
    else
    begin
      if ltag <> c_wpservicepack_tag then
      begin
        //logmessage('TServicePlg_tagproc(-1)');
      end;
    end;
    tagproc(-1);
  end;
  case Msg.Msg of
    WM_KeyDown:
      begin

      end;
  end;
  Msg.Result := CallWindowProc(oldWndProc, mainwnd, Msg.Msg, Msg.wParam, Msg.lParam);
end;

initialization

TAutoObjectFactory.create(ComServer, TServicePlg, CLASS_WPServicePlg,
  ciMultiInstance, tmApartment);

end.
