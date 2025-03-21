unit uWpServicePlg;
{$WARN SYMBOL_PLATFORM OFF}
// � ��������� ������� ��� ������ �������� ����� Delphi Compiler/linking/
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
    // ����� �������� ����
    mainwnd: cardinal;
  public
    init: boolean;
    // ������������ ��� ������������� ����
    m_showlegend: boolean;
  private
    procedure CreateSubSignals;
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
  g_ServicePlg: TServicePlg;

const
  c_keydown = $00001FFFF;
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
  // ����� �������
  GROPT_SHOWLEGEND = $0200;

var
  c_vers: string = '������������� 06.09.17';

var
  // ������� �������� ����� ((5 shl 16) or 1)
  // 327681 - ������� ���������� ��� �������� �����
  // $000f0001 ������� ������ ���������. � ������� ����������
  InPlugunCode: boolean = false;
  // ���������� �� ������� ���������� ���bitm������
  ID_NotifyEvent: cardinal;


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
  // ������� ������������ ���  createWndProc;
{$IFDEF DEBUG}
{$ELSE}
  // createWndProc;
  // CreateWndHook;
  // g_logFile.addInfoMes('TServicePlg.WndProc_'+' Mess:'+'Release');
{$ENDIF}
  ID_NotifyEvent := 9 shl 16 + 1;
  date := now;
  c_vers := '������������� ' + datetostr(now);
  str := c_vers;
  Result := 0;
end;

procedure TServicePlg.CreateFrm;
begin
  // �������� ����

end;

function TServicePlg.Disconnect: integer;
var
  StartHookProc: function(switch: boolean; hMainProg: hwnd): integer stdcall;
begin
  Result := 0;
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
      // ������������� ����
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
  // � �������� ���������� ��������� ��������
  double: boolean;

  hgraph, haxis, hline: integer;

  isig, linesig: iwpsignal;
  pvar: array of variant;

  v:variant;
  hword: cardinal;
  int:integer;
  p1:pointer;
  msg:TMessage;
  lpmsg:PMsg;
begin
  Result := 0;
  if not InPlugunCode then
  begin
    InPlugunCode := true;
    try
      try
        // ��� ��������� 0x1FFFF (131071), ������ �������� - ��������� �� ��������� MSG
        // ��� ������ wm_keydown
        if (what = 131071) then
        begin
          // ������: ��������� �������� �������
          if VarIsArray(param) then
          begin
            pvar := (PSafeArray(TVarData(param).VArray).pvdata);
            v := variant(pvar[0]);
            case TVarData(v).VType of
              varSmallInt: ;
              varInteger:
              begin
                int:=TVarData(v).VInteger;
                lpmsg:=pmsg(int);
                //logMessage(inttostr(lpmsg.message));
                msg.Msg:=lpmsg.message;
                msg.WParam:=lpmsg.wParam;
                msg.LParam:=lpmsg.lParam;
              end;
            end;
          end
          else
            v := param;
          WndProc(msg);
        end;
        if (what <> 131071) and (what <> 196607) then
        begin
          hword := HIWORD(what);
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
              // ���� hline �� �������
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

          end;
        end;
        // DEL_GRAPH �������� �������
        if hword = $1004 then
        begin
          // cwpGraph(obj).hgraph = param then
          // ������� ���� ����������� �������� �������
        end;
        // NODE_RENAMING = 0x101f0001
        if what = $101F0001 then
        begin

        end;
        // ����������� ����������� � ������ ������ ���� 0x00070001
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

        // ������� �������� ����� ((5 shl 16) or 1) ��� �������������� ������
        if what = 327681 then
        begin

        end;
        if what = $000A0001 then
        begin

        end
        else
        // ������ �������� ������ ��������� � ������ ��������
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
  // �������� ���� �� �������� saveusml
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
begin
  //if Msg.Msg = WM_KeyHOOK then
  if (Msg.Msg = WM_keydown) or (Msg.Msg = WM_SYSKEYDOWN) then
  begin
    //if (mainwnd = hwnd(Msg.lParam)) then
    // �������� ����� Control
    if GetKeyState(VK_MENU) < 0 then
    begin
      if Msg.wParam = Ord('D') then
      begin
        CreateSubSignals;
      end;
      if Msg.wParam = Ord('T') then
      begin
      end;
      // ������� ����� ��������
      if Msg.wParam = Ord('3') then
      begin
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
end;

initialization

TAutoObjectFactory.create(ComServer, TServicePlg, CLASS_WPServicePlg,
  ciMultiInstance, tmApartment);

end.
