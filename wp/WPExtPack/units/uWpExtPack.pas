unit uWpExtPack;
{$WARN SYMBOL_PLATFORM OFF}
// � ��������� ������� ��� ������ �������� ����� Delphi Compiler/linking/
// Debug info ,include remote debug , map files,

interface

uses
  Windows, ActiveX, Classes, ComObj, uNiiPMlib_TLB, StdVcl, uBaseObjService,
  Winpos_ole_TLB, POSBase, SysUtils, Forms, uWPProcFrm, wpExtPack_TLB,
  uNIIPMTenzopluginForm,
  uWPProc,
  dialogs,
  uLogFile,
  variants,
  uCommonMath,
  uWPServices,
  libniipm_tlb,
  uselectIntervalFrm,
  uFindMaxForm,
  uGenForm,
  uSelectPathForm,
  uCorrectUTS,
  Messages,
  EditSignalPathFrm,
  uGraphMngFrm,
  uWPEvents,
  uAddSignalFrm,
  uCommonTypes,
  uCyclogramRepFrm,
  uTrigFrm,
  uTrigsFrm,
  uKBHMFrm,
  uSelsinFrm,
  uSpmFrm,
  uEditSelsinFrm,
  uScriptFrm,
  uJournalForm,
  uSaveSimpleMeraFrm,
  uIEPlgClass,
  uRzdfrm,
  uExtOperMng,
  uSyncThread,
  uFrmSync,
  uWPProcServices,
  uIEManchester2087,
  PerformanceTime,
  inifiles;

type
  TExtPack = class(TAutoObject, IWPPlugin)
  protected
    // ����� �������� ����
    mainwnd: cardinal;
    // ������ �� sniffDll. ��������� �����������
    HLib: thandle;
    WM_KeyHOOK: cardinal;
    hooktime:double;
    hooktimer:TPerformanceTime;

    // ������ ��� �������� ������� ���������
    m_firstHook:boolean;

    oldWndProc, newWndProc: pointer;
    m_ExtOperMng: TExtOperMng;

    tagproc: function(p_tag: integer): integer;
    stdcall;
  public
    init: boolean;
    // ������������ ��� ������������� ����
    m_showlegend: boolean;
  private
    procedure createWndProc;
    procedure CreateWndHook;
    procedure CreateSubSignals;
    procedure compiletubes(slist: tstringlist);
  public
    // ���� �� ��������� � ������������ ������
    procedure CreateFrm;
    Procedure WndProc(var Msg: TMessage);
    function Connect(const app: IDispatch): integer; safecall;
    function Disconnect: integer; safecall;
    function NotifyPlugin(what: integer; var param: OleVariant): integer;
      safecall;
  end;

var
  startDir: string;
  mng: cWPObjMng;
  extPack: TExtPack;

const
  e_OnAddSRC = $00002000;

implementation

uses ComServ;

const
  c_wpextpack_tag = 10001;
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

var
  c_vers: string = '������������� 06.09.17';

var
  // ������� �������� ����� ((5 shl 16) or 1)
  // 327681 - ������� ���������� ��� �������� �����
  // $000f0001 ������� ������ ���������. � ������� ����������
  InPlugunCode: boolean = false;
  // ������ �������� ������ ���� 16x16!!!
  ID_CyclogramReport: integer = 1;
  ID_TimeCor: integer = 3;
  ID_RunFx: integer = 4;
  ID_RunKBHM: integer = 5;
  ID_RunSelsin: integer = 6;
  ID_RunRZD: integer = 7;
  // ���������� �� ������� ���������� ���bitm������
  ID_NotifyEvent: cardinal;

procedure TExtPack.CreateWndHook;
var
  StartHookProc: function(switch: boolean; hMainProg: hwnd): integer stdcall;
  res: integer;
  str: string;
begin
  str := startDir + '\' + DllName;
  HLib := LoadLibrary(@str[1]);
  if HLib > HINSTANCE_ERROR then
  begin
    logMessage('TExtPack_CreateWndHook');
    // ������������ ���� ��� ��������� � �������
    WM_KeyHOOK := RegisterWindowMessage('WM_OburecKeyHook');
    // �������� ��������� �� ����������� ���������
    StartHookProc := GetProcAddress(HLib, 'SetHook');
    res := StartHookProc(true, mainwnd);
    logmessage('TExtPack_MainWnd=' + inttostr(mainwnd));
    tagproc := GetProcAddress(HLib, 'SetTag');
    res := tagproc(-1);
    if res <> 0 then
    begin
      m_firstHook:=false;
      // oldwndproc:=pointer(res);
    end
    else
    begin
      m_firstHook:=true;
    end;
  end;
end;

procedure TExtPack.createWndProc;
begin
  mainwnd := WINPOS.mainwnd;
  newWndProc := MakeObjectInstance(WndProc);
  oldWndProc := pointer(SetWindowLong(mainwnd, gwl_wndProc,
      cardinal(newWndProc)));
end;

function TExtPack.Connect(const app: IDispatch): integer;
var
  hbmp, hbmp2: cardinal;
  date: tdatetime;
  str: string;
begin
  Ieplg := TMeraExtPlg.Create;
  Ieplg.Connect(app);
  Ie2087 := TIEManchester2087.Create;
  Ie2087.Connect(app);

  startDir := extractfiledir(Application.ExeName) + '\plugins\WPExtPack\';
  g_logFile := clogfile.Create(startDir + 'log1.txt', ';');


  init := false;
  WINPOS := app as IWinPOS;
  extPack := self;
  // ������� ������� ���������
  createWndProc;

  mng := cWPObjMng.Create;
  m_ExtOperMng := TExtOperMng.Create(mng);

  ID_NotifyEvent := 9 shl 16 + 1;
  ID_RunFx := WINPOS.RegisterCommand();
  ID_RunKBHM := WINPOS.RegisterCommand();
  ID_RunSelsin := WINPOS.RegisterCommand();
  // ��� �����
  ID_CyclogramReport := WINPOS.RegisterCommand();
  ID_TimeCor := WINPOS.RegisterCommand();

  // hinstans - ���������� ���������� ������� �������� ��������������� ����������
  hbmp := LoadBitmap(HInstance, 'NIIPMBUTTON');
  hbmp2 := LoadBitmap(HInstance, 'Fx');

  date := now;
  c_vers := '������������� ' + datetostr(now);
  str := c_vers;
  WINPOS.CreatetoolbarButton(bar_ID, ID_RunFx, hbmp2,
    '�������� ���������'#10'�������� ��������� ' + str);

  hbmp := LoadBitmap(HInstance, 'CyclRep');
  WINPOS.CreatetoolbarButton(bar_ID, ID_CyclogramReport, hbmp,
    '����� �� �����������'#10'����� �� �����������');

  hbmp := LoadBitmap(HInstance, 'UTSCor');
  WINPOS.CreatetoolbarButton(bar_ID, ID_TimeCor, hbmp,
    '��������� �������'#10'��������� �������');

  hbmp := LoadBitmap(HInstance, 'KBHM');
  WINPOS.CreatetoolbarButton(bar_ID, ID_RunKBHM, hbmp, 'KBHM ���'#10'KBHM ���');

  hbmp := LoadBitmap(HInstance, 'SELSIN');
  WINPOS.CreatetoolbarButton(bar_ID, ID_RunSelsin, hbmp,
    '������ ���� ��� ������� �������'#10'������ ���� ��� ������� �������');

  hbmp := LoadBitmap(HInstance, 'RZD');
  ID_RunRZD := WINPOS.RegisterCommand();
  WINPOS.CreatetoolbarButton(bar_ID, ID_RunRZD, hbmp,
    '������ ���� ����������� �� �����'#10'������ ���� ����������� �� �����');

  Result := 0;
  LoadStrings(startDir + 'Services.Ini');

  PostMessage(MainThreadID, wmCreateInterface, 0, 0);

  // synchronise(CreateFrm);
  FrmSync := TFrmSync.Create(nil);
  FrmSync.fCreateProc := CreateFrm;
  SendMessage(FrmSync.Handle, WM_CreateFrms, 0, 0);
  // ������� ������������ ���
{$IFDEF DEBUG}
{$ELSE}
  CreateWndHook;
{$ENDIF}
end;

procedure TExtPack.CreateFrm;
begin
  // �������� ����
  NIIPMForm := TNIIPMForm.Create(nil);
  FxForm := TFxForm.Create(nil);
  GenFrm := TGenFrm.Create(nil);
  GraphFrm := TGraphFrm.Create(nil);
  KBHMFrm := TKbhmFrm.Create(nil);

  CyclogramRepFrm := TCyclogramRepFrm.Create(nil);
  CyclogramRepFrm.LinkMng(mng);

  CorrectUTSFrm := TCorrectUTSFrm.Create(nil);
  CorrectUTSFrm.linc(mng);

  SelectPathFrm := TSelectPathFrm.Create(nil);
  SelectPathFrm.linc(mng);

  SignalPathFrm := TSignalPathFrm.Create(nil);
  SignalPathFrm.InitDlg(mng);

  SelectIntervalFrm := TSelectIntervalFrm.Create(nil);
  SelectIntervalFrm.LincMng(mng);

  EditSignalsListFrm := TEditSignalsListFrm.Create(nil);
  EditSignalsListFrm.LincMng(mng);

  JournalForm := TJournalForm.Create(nil);
  JournalForm.init(g_logFile);

  TrigFrm := TTrigFrm.Create(nil);
  TrigFrm.LinkMng(mng);

  TrigsFrm := TTrigsFrm.Create(nil);
  TrigsFrm.LinkMng(mng);

  GraphFrm.linc(mng);

  ScriptFrm := TScriptFrm.Create(nil);
  ScriptFrm.linc(mng);

  EditSelsinFrm := TEditSelsinFrm.Create(nil);
  EditSelsinFrm.init(mng);
  SelsinFrm := TSelsinFrm.Create(nil);
  SelsinFrm.linc(mng);

  SpmFrm := TSpmFrm.Create(nil);

  SaveSimpleMerafrm := TSaveSimpleMerafrm.Create(nil);
  // ���� � ������������ ����������� �������
  SaveSimpleMerafrm.init('IEPlg', startDir + 'WPProc.ini');

  RZDFrm := TRZDFrm.Create(nil);
  RZDFrm.init('RZDHexa', startDir + 'WPProc.ini', mng);

end;

function TExtPack.Disconnect: integer;
var
  StartHookProc: function(switch: boolean; hMainProg: hwnd): integer stdcall;
begin
  if g_logFile <> nil then
  begin
    g_logFile.destroy;
    g_logFile := nil;
  end;

  Ieplg.Disconnect;
  Ie2087.Disconnect;

  Result := 0;
  SetWindowLong(mainwnd, gwl_wndProc, integer(oldWndProc));
  // ������� ������������ ���
  if HLib > HINSTANCE_ERROR then
  begin
    // ����������� ����������
    StartHookProc(false, mainwnd);
    FreeLibrary(HLib);
  end;
  m_ExtOperMng.destroy;
end;

procedure TExtPack.compiletubes(slist: tstringlist);
var
  srcKey, v, resfolder, strint: string;
  S: cwpsignal;
  n: iwpnode;
  tube: cwptube;
  i: integer;
begin
  for i := 0 to slist.Count - 1 do
  begin
    strint := inttostr(i);
    srcKey := 's1' + '_' + strint;
    v := GetParsValue(slist, srcKey);
    if (v <> '') and (v <> '_') then
    begin
      S := mng.GetWPSignal(v);
      if S = nil then
        exit;
      if S.tube <> nil then
      begin
        tube := S.tube;
        srcKey := 'd1' + '_' + strint;
        v := GetParsValue(slist, srcKey);
        if (v <> '') and (v <> '_') then
        begin
          S := mng.GetWPSignal(v);
          S.tube := tube;
        end
        else
        begin
          exit;
        end;
      end;
    end
    else
    begin
      exit;
    end;
  end;
end;

function TExtPack.NotifyPlugin(what: integer; var param: OleVariant): integer;
var
  alg, src: string;
  str1, str2: string;
  strList: tstringlist;
  o: coperobj;
  signalopts: csignalsopt;
  i, axtype: integer;
  S: csrc;
  // � �������� ���������� ��������� ��������
  double: boolean;

  pvar: array of variant;
  hgraph, haxis, hline: integer;
  obj: cwpobj;
  sig: cwpsignal;
  isig: iwpsignal;
  t: cwptube;
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
          m_ExtOperMng.NotifyPlugin(what);
          // what = $1006 then  ADD_LINE ����������� � ���������� ����� �� ������
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
              sig := mng.GetWPSignal(isig);
              // for i := 0 to mng.SrcCount - 1 do
              // begin
              // S := mng.GetSrc(i);
              // sig := S.getSignalObj(TrimName(str1));
              // if sig <> nil then
              // begin
              // break;
              // end;
              // end;
              if sig <> nil then
              begin
                if sig.tube <> nil then
                begin
                  if sig.tube.XAxis = c_AxX_Hz then
                  begin
                    // ������ �������� nTypeType - ��� ����� �������
                    // 1 -������  ��� ���; 2 - ��� ������ ���������
                    // ������ �������� - ����� ���. 0 - ��� X
                    axtype := sig.Signal.GetSType(1, 0);
                    // ���� ��������� ���
                    // 5 - ���������
                    if axtype = 10 then
                    begin
                      sig.tube.CreateLines(hgraph, haxis);
                    end;
                  end;
                end;
              end;

              mng.m_str := str1;
              mng.m_haxis := haxis;
              mng.m_hgraph := hgraph;
              for i := 0 to mng.GraphApi.GetLineCount(mng.m_hgraph) - 1 do
              begin
                mng.m_hline := mng.GraphApi.GetLine(mng.m_hgraph, i);
                isig := iwpsignal(mng.GraphApi.GetSignal(mng.m_hline));
                if sig.Signal.Instance = isig.Instance then
                begin
                  break
                end
                else
                  mng.m_hline := -1;
              end;
              mng.Events.CallAllEvents(E_OnAddLine);
            end;
          end;
        end;
        // Del_LINE �������� ����� � �������
        // if what = $1007 then
        if what = 268894209 then
        begin
          if PSafeArray(TVarData(param).VArray).rgsabound[0].cElements = 3 then
          begin
            pvar := (PSafeArray(TVarData(param).VArray).pvdata);
            str1 := variant(pvar[0]);
            hgraph := pvar[1];
            haxis := pvar[2];
            for i := 0 to mng.SrcCount - 1 do
            begin
              S := mng.GetSrc(i);
              sig := S.getSignalObj(TrimName(str1));
              if sig <> nil then
              begin
                break;
              end;
            end;
            if sig <> nil then
            begin
              if sig.tube <> nil then
                sig.tube.delLines(hgraph);
            end;
          end;
        end;
        // DEL_GRAPH �������� �������
        if hword = $1004 then
        begin
          for i := 0 to cWPObjMng(mng).Count - 1 do
          begin
            obj := cWPObjMng(mng).getWPObj(i);
            if obj is cwpGraph then
            begin
              if cwpGraph(obj).hgraph = param then
                obj.destroy;
            end;
          end;
          // ������� ���� ����������� �������� �������
          for i := 0 to cWPObjMng(mng).tubes.Count - 1 do
          begin
            t := cwptube(cWPObjMng(mng).tubes.Objects[i]);
            t.delGraph(hgraph);
          end;
        end;
        // NODE_RENAMING = 0x101f0001
        if what = $101F0001 then
        begin

        end;
        // ����������� ����������� � ������ ������ ���� 0x00070001
        if what = $00070001 then
        begin
          init := true;
          mng.doAddNode(param);
        end;
        // NODE_RENAMED = 0x10200001
        if what = $10200001 then
        begin
          mng.doRenamedNode(param);
        end;
        // del_node
        // if what = 270401537 then
        if what = $101E0001 then
        begin
          mng.doDestroyNode(param);
        end;
        // ����� �� ������� ������������ case, �.�. ID_Run1 - ����������, � �� ���������
        // ����� LoWord(what)=2 - "2" ������������� ������� ������ �������
        if HIWORD(what) = ID_CyclogramReport then
        begin
          // if debug then
          // CreateSubSignals;
          if CyclogramRepFrm <> nil then
            CyclogramRepFrm.ShowModal;
        end;
        // ������ �������
        if HIWORD(what) = ID_TimeCor then
        begin
          CorrectUTSFrm.ShowModal;
        end;
        // ������ �������
        if HIWORD(what) = ID_RunKBHM then
        begin
          if KBHMFrm <> nil then
            KBHMFrm.ShowModal;
        end;
        if HIWORD(what) = ID_RunSelsin then
        begin
          SelsinFrm.ShowModal;
        end;

        // ������ �������
        if HIWORD(what) = ID_RunFx then
        begin
{$IFDEF DEBUG}
          mng.AddHelpTrig;
{$ELSE}
{$ENDIF}
          FxForm.ShowModal(mng);
        end;
        if HIWORD(what) = ID_RunRZD then
        begin
          RZDFrm.Show;
        end;

        // ������� �������� ����� ((5 shl 16) or 1) ��� �������������� ������
        if what = 327681 then
        begin
          // ������ �������� � ������� winpos ��� ��� � ������ �������� ������ winpos
          // � ���� ������������ ����� �� ������������������ reference
          // mng.ReadSrc;
        end;
        if what = $000A0001 then
        begin

        end
        else
        // ������ �������� ������ ��������� � ������ ��������
          if what = $000F0001 then
        begin
          // ������ 'o="/Operators/����������";p="kindFunc=5, numPoints=16384, nBlocks=1, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=1, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";s1_000="/Signals/6363.mera/NI6363-{PXI1Slot18-18- 1}";i1_000=0;c1_000=1000;d1_000="/Signals/����������/NI6363-{PXI1Slot18-18- 1}_Real#2";d2_000="/Signals/����������/NI6363-{PXI1Slot18-18- 1}_Image#2";dp1_000=3f8f260d;dp2_000=3f8fa48d;'
          str1 := param;
          // ������ ��� �� �������� ��� ������
          strList := ParsStrParam(str1);
          if GetOperName(strList) = '' then
          begin
            DelPars(strList);
            strList := nil;
            exit;
          end;
          // ������������ ������ ���������� ������ �������� �����������
          compiletubes(strList);

          o := mng.AddOper(GetOperName(strList), GetOperParams(strList));
          // �������� ��� ��������� ���������
          signalopts := GetSignalOpts(strList, 0);
          signalopts.setoperObj(o);
          if signalopts <> nil then
          begin
            o.AddSrc(signalopts);
            for i := 1 to strList.Count - 1 do
            begin
              signalopts := GetSignalOpts(strList, i);
              if signalopts <> nil then
              begin
                signalopts.setoperObj(o);
                o.AddSrc(signalopts);
              end
              else
              begin
                break;
              end;
            end;
          end;
          // ������� ��������� ��������
          DelPars(strList);
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

procedure TExtPack.CreateSubSignals;
var
  p2: point2d;
  src: csrc;
  str, path, savepath: string;
  i, j, start, endind: integer;
  sig, parentsig: iwpsignal;
  d: IDispatch;
  // �������� ���� �� �������� saveusml
  dir, srcFile, dstFile, fname: string;
  b: boolean;
  n: iwpnode;
  f: tinifile;
  datasize, readed: integer;
  fbin1: file;
  data: array of double;

  parentList: tstringlist;
begin
  p2 := GetActiveCursorX;
  if p2.x <> p2.y then
  begin
    src := mng.GetCurSrcInMainWnd;
    if src <> nil then
    begin
      str := src.node.AbsolutePath;
      fname := TrimExt(src.node.Name);
      path := str + '/' + fname + '_sub_001';
      d := wp.GetNodeStr(path);
      while Supports(d, DIID_IWPNode) do
      begin
        path := modname(path, false);
        d := wp.GetNodeStr(path);
      end;
      for i := 0 to src.childCount - 1 do
      begin
        start := src.getSignalObj(i).Signal.IndexOf(p2.x);
        endind := src.getSignalObj(i).Signal.IndexOf(p2.y);
        // sig:=wp.GetInterval(src.GetWPSignal(i).Signal,start, endind-start) as iwpsignal;
        sig := src.getSignalObj(i).Signal.Clone(start, endind - start)
          as iwpsignal;
        wp.Link(path, sig.sname, sig);
      end;
      wp.Refresh;

      sig := nil;
      if src.merafile <> nil then
      begin
        dir := extractfiledir(src.merafile.FileName) + '\';
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
        wp.SaveUSML(path, savepath);
      end;
    end;
  end;
end;

Procedure TExtPack.WndProc(var Msg: TMessage);

var
  opt, g, p, v: integer;
  ltag: integer;
  t:double;
begin
  ltag:=0;
  if Msg.Msg = WM_KeyHOOK then
  begin
    //logMessage('TExtPack_WndProc_enter');
    ltag := tagproc(c_wpextpack_tag);
    if ltag=-1 then
    begin
      t:=gettimeinsec;
      if abs(t-hooktime)>0.1 then
      begin
        logMessage(floattostr(t-hooktime));
        if (mainwnd = hwnd(Msg.lParam)) then
        begin
          if Msg.wParam = VK_F6 then
          begin
            ScriptFrm.ShowModal;
          end;
          if Msg.wParam = VK_F5 then
          begin
            CorrectUTSFrm.ShowModal;
          end;
          // �������� �����
          if GetKeyState(VK_Menu) < 0 then
          begin
            logMessage('TExtPack_Alt');
            if Msg.wParam = Ord('T') then
            begin
              logMessage('TExtPack_VK_Menu+T');
              mng.AddHelpTrig;
            end;
          end;
        end;
        hooktime:=t;
      end;
    end
    else
    begin
      // ���� ������ ����� �� ������� ��� ����
      if ltag<>c_wpextpack_tag then
      begin
        logMessage('TExtPack_tagproc(ltag)');
      end
    end;
    tagproc(-1);
    //logMessage('TExtPack_WndProc_exit');
  end;
  Msg.Result := CallWindowProc(oldWndProc, mainwnd, Msg.Msg, Msg.wParam,  Msg.lParam);
end;

initialization

TAutoObjectFactory.Create(ComServer, TExtPack, Class_ExtPack, ciMultiInstance,
  tmApartment);

end.
