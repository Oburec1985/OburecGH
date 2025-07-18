unit uWPservices;

interface
uses
  Windows, sysutils, ActiveX, Classes, ComObj, StdVcl,
  uBaseObjService, variants,
  Winpos_ole_TLB, POSBase, graphics, Forms, uBaseObj, uBaseObjMng, NativeXML,
  uEventList, dialogs, uCommonMath,
  uCommonTypes, uLogFile, uSetList, inifiles, mathfunction,
  uWPEvents, Messages,
  math;

type
  TUnits = (u_Abs, u_percent, u_10Lg, u_20Lg);

  tgraphstruct = record
    hpage, hgraph, haxis, hline: integer;
  end;


// ��������� �������� �� ���� ������
function IsSignal(node: iwpnode): boolean; overload;
function IsSignal(d: idispatch): boolean; overload;

// �������� �������� ������ � ���� ���������� �� ���� ���� ��� ��� usml ����
function GetChildSignal(node: iwpnode; i: integer): iwpsignal; overload;
function GetChildSignal(d: idispatch; i: integer): iwpsignal; overload;
function getChildCount(srcnode:iwpnode):integer;overload;
// �������� ����� �������� ���������.
function getChildCount(d: idispatch): integer;overload;



function getCurSrcInMainWnd:IwpNode;
function getsrcBySignal(s:idispatch):iwpnode;
function getsrcByPath(p:string):iwpnode;

function isUSML(d: idispatch): boolean; overload;
function isUSML(n: iwpnode): boolean; overload;
function isNode(d: idispatch): boolean;
// �������� �������� ���� � �������� ��������� ��� �������
function GetWPRoot: iwpnode;
function GetGraphRoot: iwpnode;
function getparentnode(n: iwpnode): iwpnode;
// ���������. �������� �� ���� ���������� ������ (�������� �� � ���� �������)
// ���������� True � ��� ������ ���� ���� �� ������ iwpUSML!
function IsSrc(node: iwpnode): boolean; overload;
function IsSrc(node: idispatch): boolean; overload;

// ����� � ���� �����
//XType=5 ��� ���
//YType=0 ��� ���
//XUnitsId=0x0 ������� ���������
//YUnitsId=0x0 ������� ���������
procedure setSignalUnits(s: iwpsignal; unitsY: integer; unitsX: integer);

function getSignalViewRangeY(s:iwpsignal):point2d;
function GetGraphStructByHLine(hline:integer):tgraphstruct;
function createline(Signal: iwpsignal): tgraphstruct; overload;
// g,a - ������ � ���
function createline(Signal: iwpsignal; g, a: integer): tgraphstruct; overload;
// � ����� ������ �� ��� �� ��������
function createline(Signal: iwpsignal; p: integer): tgraphstruct; overload;
// ���������� �� �������� ������ ������ � ����� ��� � ��������� ��. ��� ������������� ����������� x �������
function createlineNewAx(Signal: iwpsignal; g: integer): tgraphstruct; overload;
procedure normaliseGraph(g: integer);
// ����� �������� �� �������. ���������� hpage
function FindPageByGraph(graph: integer): integer;
// ��� ���� �� ��� X ��� �������
function Getgraphminmax(g: integer): point2d;
function activeGraph:tgraphstruct;
// �������� �������� ���������� �������
function GetActiveGraphX: point2d;
function GetActiveCursorX: point2d;
function GetGraphX(g: integer): point2d;
function GetGraphCursorX(p,g: integer): point2d;

function GetStartStop(m:iwpusml):point2d;overload;
function GetStartStop(n:iwpnode):point2d;overload;

// ���� � �������� ����������� ������
function findNode(isig:iwpsignal):iwpnode;overload;
function findNode(inst:integer):iwpnode;overload;
function findNode(node:iwpnode;inst:integer):iwpnode;overload;

function findSignal(path:string):iwpsignal;
function GetIWPSignalByHLine(hline: integer): iwpsignal;



function getISignalByPath(str:string):iwpsignal;
function TypeCastToIWPUSML(d: idispatch): iwpusml;overload;
function TypeCastToIWNode(d: idispatch): iwpnode;
function TypeCastToIWSignal(d: idispatch): iwpsignal; overload;
function TypeCastToIWSignal(n: iwpnode): iwpsignal; overload;

procedure setLineCloud(hline:integer);
procedure setLineHist(hline:integer);
procedure setLineNullPoly(hline:integer);

function GetSignalFolder(s:iwpsignal):string;


const
  c_Vibr_g = 0;
  c_Vibr_ms = 1;
  c_Pres_Pa = 2;
  c_Pres_kPa = 3;
  c_Pres_MPa = 4;
  c_Temp_C = 5;
  c_Volt = 6;

  c_AxX_sec = 0;
  c_AxX_msec = 1;
  c_AxX_min = 2;
  c_AxX_Hour = 3;
  c_AxX_Hz = 4;
  c_AxX_kHz = 5;
  c_AxX_rpm = 6;
  // ������� CreateWNDHook ��� ������
  //debug = true;

implementation

function GetSignalFolder(s:iwpsignal):string;
var
  n:iwpnode;
  i,len:integer;
  str:string;
begin
  n:=winpos.GetNode(s) as iwpnode;
  str:=n.AbsolutePath;
  len:=length(str);
  result:='';
  for I := len downto 1 do
  begin
    if str[i]='/' then
    begin
      result:=copy(str,1, i-1);
      exit;
    end;
  end;
end;

procedure setLineCloud(hline:integer);
begin
  IWPGraphs(WP.GraphAPI).SetLineOpt(hline, LNOPT_ONLYPOINTS, LNOPT_ONLYPOINTS, 0, $00D2D5);
end;

procedure setLineHist(hline:integer);
begin
  IWPGraphs(WP.GraphAPI).SetLineOpt(hline, LNOPT_HIST, LNOPT_HIST, 0, 0);
  IWPGraphs(WP.GraphAPI).SetLineOpt(hline, LNOPT_LINE2BASE, LNOPT_LINE2BASE, 0, 0);
end;

procedure setLineNullPoly(hline:integer);
begin
  IWPGraphs(WP.GraphAPI).SetLineOpt(hline, 0, LNOPT_INTERP, 0, $00D2D5);
end;

function getSignalViewRangeY(s:iwpsignal):point2d;
var
  range:double;
begin
  result.x:=s.MinY;
  result.y:=s.MaxY;
  range:=result.y-result.x;
  result.x := result.x - range*0.05;
  result.y := result.y + range*0.05;
end;

function GetGraphStructByHLine(hline:integer):tgraphstruct;
var
  hg, ha, hp, hl:integer;
  i, j, k, numax:integer;
begin
  result.hpage:=0;
  result.hgraph:=0;
  result.haxis:=0;
  result.hline:=0;

  IWPGraphs(WP.GraphApi).SetLineOpt(hline, LNOPT_HIST, LNOPT_HIST, 0, 0);
  for I := 0 to IWPGraphs(WP.GraphApi).GetPageCount - 1 do
  begin
    hp:=IWPGraphs(WP.GraphApi).GetPage(i);
    for j := 0 to IWPGraphs(WP.GraphApi).GetGraphCount(hp) - 1 do
    begin
      hg:=IWPGraphs(WP.GraphApi).GetGraph(hp, j);
      for k := 0 to IWPGraphs(WP.GraphApi).GetLineCount(hg) - 1 do
      begin
        hl:=IWPGraphs(WP.GraphApi).GetLine(hg, k);
        if hl=hline then
        begin
          numax := IWPGraphs(WP.GraphApi).GetYAxisNum(hline);
          ha := IWPGraphs(WP.GraphApi).GetYAxis(hg, numax);
          result.hpage:=hp;
          result.hgraph:=hg;
          result.haxis:=ha;
          result.hline:=hl;
          exit;
        end;
      end;
    end;
  end;
end;

function createline(Signal: iwpsignal): tgraphstruct;
var
  x1, x2, range: double;
  y1y2:point2d;
begin
  // ������ �������
  result.hpage := IWPGraphs(wp.GraphApi).CreatePage;
  result.hgraph := IWPGraphs(wp.GraphApi).GetGraph(result.hpage, 0);
  result.haxis := IWPGraphs(wp.GraphApi).GetYAxis(result.hgraph, 0);
  result.hline := IWPGraphs(wp.GraphApi).createline(result.hgraph,
    result.haxis, Signal.Instance);

  x1 := Signal.MinX;
  x2 := Signal.MaxX;

  y1y2:=getSignalViewRangeY(signal);

  IWPGraphs(wp.GraphApi).SetXMinMax(result.hgraph, x1, x2);
  IWPGraphs(wp.GraphApi).SetYAxisMinMax(result.haxis, y1y2.x, y1y2.y);
  IWPGraphs(wp.GraphApi).SetGraphOpt(result.hgraph, GROPT_AUTONORM,
    GROPT_AUTONORM);

  IWPGraphs(wp.GraphApi).SetAxisOpt(result.hgraph, 0, AXOPT_RANGE, AXOPT_RANGE,
    x1, x2, '', ' ', 0);
  IWPGraphs(wp.GraphApi).SetAxisOpt(result.hgraph, result.haxis, AXOPT_RANGE,
    AXOPT_RANGE, y1y2.x, y1y2.y, '', '', 0);
end;

function createline(Signal: iwpsignal; g, a: integer): tgraphstruct;
var
  opt, color:integer;
  s1,s2:widestring;
  y1,y2:double;
  y1y2:point2d;
begin
  result.hgraph := g;
  result.haxis := a;
  result.hpage := FindPageByGraph(g);
  result.hline := IWPGraphs(wp.GraphApi).createline(result.hgraph,
    result.haxis, Signal.Instance);
  IWPGraphs(wp.GraphApi).GetAxisOpt(g,a,opt,y1,y2,s1,s2,color);
  y1y2:=getSignalViewRangeY(signal);
  if y1y2.x>y1 then
    y1y2.x:=y1;
  if y1y2.y<y2 then
    y1y2.y:=y2;
  IWPGraphs(wp.GraphApi).SetYAxisMinMax(result.haxis, y1y2.x, y1y2.y);
  IWPGraphs(wp.GraphApi).SetGraphOpt(result.hgraph, GROPT_AUTONORM,
    GROPT_AUTONORM);
  IWPGraphs(wp.GraphApi).SetAxisOpt(result.hgraph, result.haxis, AXOPT_RANGE,
    AXOPT_RANGE, y1y2.x, y1y2.y, s1, s2, 0);
end;

function createline(Signal: iwpsignal; p: integer): tgraphstruct;
var
  x1, x2: double;
  y1y2:point2d;
begin
  result.hpage := p;
  result.hgraph := IWPGraphs(wp.GraphApi).CreateGraph(p);
  result.haxis := IWPGraphs(wp.GraphApi).GetYAxis(result.hgraph, 0);
  result.hline := IWPGraphs(wp.GraphApi).createline(result.hgraph,
    result.haxis, Signal.Instance);

  x1 := Signal.MinX;
  x2 := Signal.MaxX;
  y1y2:=getSignalViewRangeY(signal);

  IWPGraphs(wp.GraphApi).SetXMinMax(result.hgraph, x1, x2);
  IWPGraphs(wp.GraphApi).SetYAxisMinMax(result.haxis, y1y2.x, y1y2.y);
  IWPGraphs(wp.GraphApi).SetGraphOpt(result.hgraph, GROPT_AUTONORM,
    GROPT_AUTONORM);

  IWPGraphs(wp.GraphApi).SetAxisOpt(result.hgraph, 0, AXOPT_RANGE, AXOPT_RANGE,
    x1, x2, '', ' ', 0);
  IWPGraphs(wp.GraphApi).SetAxisOpt(result.hgraph, result.haxis, AXOPT_RANGE,
    AXOPT_RANGE, y1y2.x, y1y2.y, '', '', 0);
end;

function createlineNewAx(Signal: iwpsignal; g: integer): tgraphstruct;
var
  x1,x2:double;
  bx:boolean;
  y1y2:point2d;
begin
  result.hgraph := g;
  result.hpage := FindPageByGraph(g);
  result.haxis:=IWPGraphs(wp.GraphApi).CreateYAxis(g);
  result.hline := IWPGraphs(wp.GraphApi).createline(result.hgraph,
                  result.haxis, Signal.Instance);

  y1y2:=getSignalViewRangeY(signal);
  bx:=false;
  IWPGraphs(wp.GraphApi).GetXMinMax(result.hgraph, x1, x2);
  if x1>Signal.minx then
  begin
    x1:=Signal.minx;
    bx:=true;
  end;
  if x2<Signal.maxx then
  begin
    x2:=Signal.maxx;
    bx:=true;
  end;
  if bx then
  begin
    IWPGraphs(wp.GraphApi).SetXMinMax(result.hgraph, x1, x2);
    IWPGraphs(wp.GraphApi).SetAxisOpt(result.hgraph, 0, AXOPT_RANGE, AXOPT_RANGE,
      x1, x2, '', ' ', 0);
  end;

  IWPGraphs(wp.GraphApi).SetYAxisMinMax(result.haxis, y1y2.x, y1y2.y);
  IWPGraphs(wp.GraphApi).SetGraphOpt(result.hgraph, GROPT_AUTONORM,
    GROPT_AUTONORM);
  IWPGraphs(wp.GraphApi).SetAxisOpt(result.hgraph, result.haxis, AXOPT_RANGE,
    AXOPT_RANGE, y1y2.x, y1y2.y, '', '', 0);
end;


procedure normaliseGraph(g: integer);
var
  x1, x2, y1, y2: double;
  axCount, lCount, ax, line, axNum, opt, color: integer;
  i, j: integer;
  str1, str2: widestring;
  s: iwpsignal;
begin
  axCount := IWPGraphs(wp.GraphApi).GetYAxisCount(g);
  lCount := IWPGraphs(wp.GraphApi).GetLineCount(g);
  IWPGraphs(wp.GraphApi).GetAxisOpt(g, 0, opt, x1, x2, str1, str2, color);
  for j := 0 to lCount - 1 do
  begin
    line := IWPGraphs(wp.GraphApi).GetLine(g, j);
    s := IWPGraphs(wp.GraphApi).GetSignal(line) as iwpsignal;
    if s.MinX < x1 then
      x1 := s.MinX;
    if s.MaxX > x2 then
      x2 := s.MaxX;
  end;

  IWPGraphs(wp.GraphApi).SetXMinMax(g, x1, x2);
  IWPGraphs(wp.GraphApi).SetGraphOpt(g, GROPT_AUTONORM, GROPT_AUTONORM);
  IWPGraphs(wp.GraphApi).SetAxisOpt(g, 0, AXOPT_RANGE, AXOPT_RANGE, x1, x2, '',
    ' ', 0);
  for i := 0 to axCount - 1 do
  begin
    ax := IWPGraphs(wp.GraphApi).GetYAxis(g, i);
    IWPGraphs(wp.GraphApi).GetAxisOpt(g, ax, opt, y1, y2, str1, str2, color);
    for j := 0 to lCount - 1 do
    begin
      line := IWPGraphs(wp.GraphApi).GetLine(g, j);
      axNum := IWPGraphs(wp.GraphApi).GetYAxisNum(line);
      if axNum = i then
      begin
        s := IWPGraphs(wp.GraphApi).GetSignal(line) as iwpsignal;
        if s.MinY < y1 then
          y1 := s.MinY;
        if s.MaxY > y2 then
          y2 := s.MaxY;
      end;
      IWPGraphs(wp.GraphApi).SetYAxisMinMax(ax, y1, y2);
      IWPGraphs(wp.GraphApi).SetAxisOpt(g, ax, AXOPT_RANGE, AXOPT_RANGE, y1,
        y2, '', '', 0);
    end;
  end;
end;

function FindPageByGraph(graph: integer): integer;
var
  i, j, p: integer;
begin
  result := 0;
  for i := 0 to IWPGraphs(wp.GraphApi).GetPageCount - 1 do
  begin
    p := IWPGraphs(wp.GraphApi).GetPage(i);
    for j := 0 to IWPGraphs(wp.GraphApi).GetGraphCount(p) - 1 do
    begin
      if IWPGraphs(wp.GraphApi).GetGraph(p, j) = graph then
      begin
        result := p;
        exit;
      end;
    end;
  end;
end;

function Getgraphminmax(g: integer): point2d;
var
  i, hline: integer;

  s: iwpsignal;
  x1, x2: double;
begin
  result.x := 0;
  result.y := 0;
  for i := 0 to IWPGraphs(wp.GraphApi).GetLineCount(g) - 1 do
  begin
    hline := IWPGraphs(wp.GraphApi).GetLine(g, i);
    s := IWPGraphs(wp.GraphApi).GetSignal(hline) as iwpsignal;
    x1 := s.MinX;
    x2 := s.MaxX;
    if x1 < result.x then
      result.x := x1;
    if x2 > result.y then
      result.y := x2;
  end;
end;


function findSignal(path:string):iwpsignal;
var
  d:idispatch;
begin
  d:=WP.GetObject(path);
  result:=TypeCastToIWSignal(d);
end;

function findNode(node:iwpnode;inst:integer):iwpnode;
var
  I: Integer;
  n:iwpnode;
begin
  result:=nil;
  if node.Instance=inst then
  begin
    result:=node;
    exit;
  end;
  for I := 0 to node.childCount - 1 do
  begin
    n:=node.At(i) as iwpnode;
    result:=findNode(n,inst);
    if result<>nil then
      exit;
  end;
end;

function findNode(inst:integer):iwpnode;
var
  root, n:iwpnode;
  I: Integer;
begin
  root:=WP.Get('Signals') as iwpnode;
  for I := 0 to root.ChildCount - 1 do
  begin
    n:=root.at(i) as iwpnode;
    if n.Instance=inst then
    begin
      result:=n;
      exit;
    end
    else
    begin
      result:=findNode(n, inst);
      if result<>nil then
        exit;
    end;
  end;
end;

function findSignalInNode(s:iwpsignal; n:iwpnode):iwpnode;
var
  i:integer;
  ch:iwpnode;
  sig:iwpsignal;
begin
  result:=nil;
  if supports(n.Reference, iwpsignal) then
  begin
    sig:=n.Reference as iwpsignal;
    if sig.Instance=s.Instance then
    begin
      result:=n;
      exit;
    end;
  end
  else
  begin
    for I := 0 to n.ChildCount - 1 do
    begin
      ch:=n.at(i) as iwpnode;
      result:=findSignalInNode(s, ch);
      if result<>nil then
      begin
        exit;
      end;
    end;
  end;
end;

function findNode(isig:iwpsignal):iwpnode;
var
  root:iwpnode;
begin
  root:=WP.Get('Signals') as iwpnode;
  result:=findSignalInNode(isig,root);
end;

function TypeCastToIWPUSML(d: idispatch): iwpusml;
begin
  result := nil;
  if Supports(d, DIID_IWPUSML) then
  begin
    result := d as iwpusml;
  end;
  if Supports(d, DIID_IWPNode) then
  begin
    d := (d as iwpnode).Reference;
    if Supports(d, DIID_IWPUSML) then
    begin
      result := d as iwpusml;
    end;
  end;
end;

function TypeCastToIWNode(d: idispatch): iwpnode;
var
  n:iwpnode;
begin
  result := nil;
  if Supports(d, DIID_IWPNode) then
  begin
    result := d as iwpnode;
  end
  else
  begin
    if Supports(d, DIID_IWPUSML) then
    begin
      d:=WP.GetNode(d);
      if Supports(d, DIID_IWPNode) then
      begin
        result := d as iwpnode;
      end
    end;
  end;
end;

function TypeCastToIWSignal(n: iwpnode): iwpsignal;
begin
  result := nil;
  if Supports(n.Reference, DIID_IWPSignal) then
  begin
    result := n.Reference as iwpsignal;
  end;
end;

function TypeCastToIWSignal(d: idispatch): iwpsignal;
begin
  result := nil;
  if Supports(d, DIID_IWPSignal) then
  begin
    result := d as iwpsignal;
    exit;
  end;
  if Supports(d, DIID_IWPNode) then
  begin
    if Supports((d as iwpnode).Reference, DIID_IWPSignal) then
    begin
      result := (d as iwpnode).Reference as iwpsignal;
    end;
  end;
end;

function getISignalByPath(str:string):iwpsignal;
var
  d:idispatch;
begin
  d:=wp.GetNodeStr(str);
  result:=TypeCastToIWSignal(d);
end;

function activeGraph: tgraphstruct;
begin
  result.hpage:=IWPGraphs(wp.GraphApi).ActiveGraphPage;
  if result.hpage=0 then
    result.hgraph:=0
  else
    result.hgraph:=IWPGraphs(wp.GraphApi).ActiveGraph(result.hpage);
end;

function GetActiveGraphX: point2d;
var
  hpage, hgraph: integer;
begin
  result.x := 0;
  result.y := 0;
  if IWPGraphs(wp.GraphApi).GetPageCount = 0 then
  begin
    exit;
  end;
  hpage := IWPGraphs(wp.GraphApi).ActiveGraphPage;
  if (IWPGraphs(wp.GraphApi).GetGraphCount(hpage) <= 0) then
  begin
    exit;
  end;
  hgraph := IWPGraphs(wp.GraphApi).ActiveGraph(hpage);
  IWPGraphs(wp.GraphApi).getXMinMax(hgraph, result.x, result.y);
end;

function GetActiveCursorX: point2d;
var
  hpage, hgraph, hline, ntrack: integer;
begin
  result.x := 0;
  result.y := 0;
  if (IWPGraphs(wp.GraphApi).GetPageCount = 0) then
  begin
    exit;
  end;
  hpage := IWPGraphs(wp.GraphApi).ActiveGraphPage;
  if (IWPGraphs(wp.GraphApi).GetGraphCount(hpage) <= 0) then
  begin
    exit;
  end;
  hgraph := IWPGraphs(wp.GraphApi).ActiveGraph(hpage);
  // if (GraphApi.GetLineCount(hgraph)<= 0) then
  // exit;
  // hline:=GraphApi.GetLine(hgraph, 0);

  ntrack := IWPGraphs(wp.GraphApi).GetTrackMode(hpage);
  // 8-������� ������
  if (ntrack <> 8) then
  begin
    result := GetActiveGraphX;
    exit;
  end;
  IWPGraphs(wp.GraphApi).GetXCursorPos(hgraph, &result.x, false);
  IWPGraphs(wp.GraphApi).GetXCursorPos(hgraph, &result.y, true);
end;

function GetGraphX(g: integer): point2d;
begin
  IWPGraphs(wp.GraphApi).getXMinMax(g, result.x, result.y);
end;

function GetGraphCursorX(p, g: integer): point2d;
var
  ntrack: integer;
  v:double;
begin
  ntrack := IWPGraphs(wp.GraphApi).GetTrackMode(p);
  // 2-������� ������
  if (ntrack <> 8) then
  begin
    result := GetActiveGraphX;
    exit;
  end;
  IWPGraphs(wp.GraphApi).GetXCursorPos(g, &result.x, false);
  IWPGraphs(wp.GraphApi).GetXCursorPos(g, &result.y, true);
  if result.x>result.y then
  begin
    v:=result.x;
    result.x:=result.y;
    result.y:=v;
  end;
end;

// ����� � ���� �����
//XType=5 ��� ���
//YType=0 ��� ���
//XUnitsId=0x0 ������� ���������
//YUnitsId=0x0 ������� ���������
procedure setSignalUnits(s: iwpsignal; unitsY: integer; unitsX: integer);
begin
  case unitsY of
    c_Vibr_g:
    begin
      // 1 - ������  ��� ���; 1 - ������ ��� Y; 80 - ����� ���
      s.SetSType(1, 1, 80);
      // 2 - ������  ��� �������� ������; 0 - ������ ����� �� Y; 4294972687 - g
      s.SetSType(2, 1, 4294972687);
    end;
    c_Volt:
    begin
      // 1 - ������  ��� ���; 1 - ������ ��� Y; 160 - �������
      s.SetSType(1, 1, 160);
      // 2 - ������  ��� �������� ������; 0 - ������ ����� �� Y; 0x100003201 - V
      s.SetSType(2, 1, $100003201);
    end;
    c_Vibr_ms:
    begin
      // 1 - ������  ��� ���; 0 - ������ ��� X; 5 - ��������� ���
      s.SetSType(1, 1, 80);
      // 2 - ������  ��� �������� ������; 0 - ������ ����� �� X; 4294972673 - ms
      s.SetSType(2, 1, 4294972673);
    end
    else
    begin
      if unitsY=0 then
      begin
        s.SetSType(1, 1, 0);
        // 2 - ������  ��� �������� ������;
        // 0 - ������ ����� �� X;
        // 0 - ������������
        s.SetSType(2, 1, 0);
      end;
    end;
  end;
  case unitsX of
    c_AxX_sec:
      begin
        // nTypeAx; nTypeVal
        // 0 - ������  ��� �������; 0 - ������ �������� ���������; 1 - ��������� �������, 2 - ����������
        s.SetSType(0, 0, 1);
        // 1 - ������  ��� ���; 0 - ������ ��� X; 5 - ��������� ���, 10 - ���������
        s.SetSType(1, 0, 5);
        // 2 - ������  ��� �������� ������; 0 - ������ ����� �� X; 4294968577 - �������
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_msec:
      begin
        s.SetSType(0, 0, 1);
        s.SetSType(1, 0, 5);
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_min:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 5);
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_Hour:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 5);
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_Hz:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 10);
        s.SetSType(2, 0, 4294968833);
      end;
    c_AxX_kHz:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 10);
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_rpm:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 10);
        s.SetSType(2, 0, 4294968577);
      end;
  end;
end;


function isUSML(d: idispatch): boolean;
begin
  result := false;
  if Supports(d, DIID_IWPNode) then
  begin
    if Supports((d as iwpnode).Reference, DIID_IWPUSML) then
    begin
      result := true;
    end;
  end
  else
  begin
    if Supports(d, DIID_IWPUSML) then
      result := true
    else
      result := false;
  end;
end;

function isUSML(n: iwpnode): boolean;
begin

  // n.GetReferenceType//2-signal, 0-������� �����, 1 - ���� ����/USML
  if Supports(n.Reference, DIID_IWPUSML) then
    result := true
  else
    result := false;
end;

function isNode(d: idispatch): boolean;
begin
  if Supports(d, DIID_IWPNode) then
    result := true
  else
    result := false;
end;

function GetWPRoot: iwpnode;
begin
  result := iwpnode((winpos.Get('/signals')));
end;

function GetGraphRoot: iwpnode;
begin
  result := iwpnode((winpos.Get('/Graphs')));
end;

function IsSignal(d: idispatch): boolean;
begin
  result := false;
  if Supports(d, DIID_IWPNode) then
  begin
    if Supports((d as iwpnode).Reference, DIID_IWPSignal) then
    begin
      result := true;
      exit;
    end;
  end;
  if Supports(d, DIID_IWPSignal) then
  begin
    result := true;
    exit;
  end;
end;

function IsSignal(node: iwpnode): boolean;
begin
  result := false;
  if Supports(node.Reference, DIID_IWPSignal) then
  begin
    result := true;
    exit;
  end;
end;

function getChildCount(d: idispatch): integer;
Var
  m: iwpusml;
  n: iwpnode;
begin
  result := 0;
  m := TypeCastToIWPUSML(d);
  if m <> nil then
  begin
    result := m.ParamCount;
    exit;
  end;
  n := TypeCastToIWNode(d);
  if n <> nil then
  begin
    result := n.childcount;
    exit;
  end;
end;

function getparentnode(n: iwpnode): iwpnode;
var
  s: string;
  i: integer;
begin
  if n = nil then
  begin
    result := nil;
    exit;
  end;
  s := n.AbsolutePath;
  for i := length(s) downto 1 do
  begin
    if s[i] = '/' then
    begin
      setlength(s, i - 1);
      break;
    end;
  end;
  result := TypeCastToIWNode(winpos.GetNodeStr(s));
end;

function GetChildSignal(d: idispatch; i: integer): iwpsignal;
var
  m: iwpusml;
  n: iwpnode;
begin
  result := nil;
  if Supports(d, DIID_IWPUSML) then
  begin
    m := d as iwpusml;
    if i <= (m.ParamCount - 1) then
    begin
      result := m.Parameter(i) as iwpsignal;
    end;
  end;
  if Supports(d, DIID_IWPNode) then
  begin
    n := d as iwpnode;
    if i <= n.childcount then
    begin
      if IsSrc(n) then
      begin
        result := TypeCastToIWSignal(n.at(i) as iwpnode);
      end;
    end;
  end;
end;

function GetChildSignal(node: iwpnode; i: integer): iwpsignal;
var
  m: iwpusml;
  d: idispatch;
begin
  if IsSrc(node) then
  begin
    if i < (node.childcount - 1) then
    begin
      result := TypeCastToIWSignal(node.at(i) as iwpnode);
    end;
  end
  else
  begin
    if Supports(node.Reference, DIID_IWPUSML) then
    begin
      m := node.Reference as iwpusml;
      if i <= (m.ParamCount - 1) then
      begin
        result := m.Parameter(i) as iwpsignal;
      end
      else
        result:=nil;
    end
  end;
end;



function IsSrc(node: idispatch): boolean;
var
  n: iwpnode;
begin
  n := TypeCastToIWNode(node);
  result := IsSrc(n);
end;

function IsSrc(node: iwpnode): boolean;
var
  d: idispatch;
  childNode: iwpnode;
  i: integer;
begin
  result := false;
  if node <> nil then
  begin
    d := node.Reference;
    if not Supports(d, DIID_IWPUSML) then
    begin
      for i := 0 to node.childcount - 1 do
      begin
        childNode := node.at(i) as iwpnode;
        if Supports(childNode.Reference, DIID_IWPSignal) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end;
end;

function getsrcByPath(p:string):iwpnode;
var
  n:iwpnode;
begin
  n :=winpos.GetNodeStr(p) as iwpnode;
end;

function getsrcBySignal(s:idispatch):iwpnode;
var
  path, str: string;
  usml:IWPUSML;
  n, root, srcnode : iwpnode;
  ch, ch1:IDispatch;
  ls:IWPSignal;
  i, j: integer;
begin
  result := nil;
  if IsSignal(s) then
  begin
    n := TypeCastToIWNode(s);
    if n=nil then
    begin
      root:=GetWPRoot;
      for I := 0 to root.ChildCount - 1 do
      begin
        ch:=root.At(i);
        // ���� �� usml
        if isSrc(ch) then
        begin
          srcnode:=TypeCastToIWNode(ch);
          for j := 0 to srcnode.ChildCount - 1 do
          begin
            ch1:=srcnode.At(j);
            if issignal(ch1) then
            begin
              ls:=TypeCastToIWSignal(ch1);
              if ls.SName=(s as iwpsignal).sname then
              begin
                result:=srcnode;
                exit;
              end;
            end;
          end;
        end;
       if isUSML(ch) then
        begin
          usml:=TypeCastToIWPUSML(ch);
          for j := 0 to usml.ParamCount - 1 do
          begin
            ch1:=usml.Parameter(j);
            if issignal(ch1) then
            begin
              ls:=TypeCastToIWSignal(ch1);
              if ls.SName=(s as iwpsignal).sname then
              begin
                // ������� node
                result:=TypeCastToIWNode(ch);
                exit;
              end;
            end;
          end;
        end;
      end;
    end;
    str := n.AbsolutePath;
    for i := length(str) downto 1 do
    begin
      if str[i] = '/' then
      begin
        setlength(str, i);
        n :=winpos.GetNodeStr(str) as iwpnode;
        result:=n;
        exit;
      end;
    end;
  end;
end;

function getCurSrcInMainWnd:IwpNode;
var
  d:idispatch;
  s:iwpsignal;
  n:iwpnode;
  i, hpage, hline, hgraph: integer;
begin
  d := winpos.GetSelectedObject;
 // ���� iwpNode
  if IsSrc(d) then
  begin
    n := TypeCastToIWNode(d);
    result := n;
    exit;
  end
  else
  begin
    if Supports(d, DIID_IWPUSML) then
    begin
      //m := TypeCastToIWPUSML(d);
      result := TypeCastToIWNode(d);
      exit;
    end;
    if IsSignal(d) then
    begin
      n := GetSrcBySignal(d);
      result := n;
      exit;
    end;
    // �������� �� ������ ���� ������ ��������
    // (�������� ����� ������� �����������)
    d := winpos.GetSelectedNode;
    n := TypeCastToIWNode(d);
    // �������� ���� ���� ������� �������
    if n = nil then
    begin
      result := nil;
      if (IWPGraphs(wp.GraphApi).GetPageCount = 0) then
      begin
        exit;
      end;
      hpage := IWPGraphs(wp.GraphApi).ActiveGraphPage;
      if IWPGraphs(wp.GraphApi).GetGraphCount(hpage) = 0 then
      begin
      end
      else
      begin
        hgraph := IWPGraphs(wp.GraphApi).ActiveGraph(hpage);
        if IWPGraphs(wp.GraphApi).GetLineCount(hgraph) = 0 then
        begin
        end
        else
        begin
          hline := IWPGraphs(wp.GraphApi).GetLine(hgraph, 0);
          s := GetIWPSignalByHLine(hline);
          result := getsrcBySignal(s);
          exit;
        end;
      end;
    end
    else
    begin
      result := n;
      exit;
    end;
  end;
  // �������� �� ����� ���������� getSelectObject
  //if src = nil then
  //begin
  //  if SrcCount > 0 then
  //  begin
  //    src := cSrc(srcList.Objects[i]);
  //    result := src;
  //  end;
  //end;
end;

function GetIWPSignalByHLine(hline: integer): iwpsignal;
var
  d: idispatch;
begin
  d := IWPGraphs(wp.GraphApi).GetSignal(hline);
  result := TypeCastToIWSignal(d);
end;

function getChildCount(srcnode:iwpnode):integer;
begin
  result:=srcnode.ChildCount;
end;

function GetStartStop(n:iwpnode):point2d;overload;
var
  d:idispatch;
  ch:idispatch;
  s:iwpsignal;
  I: Integer;
  min, max:double;
begin
  result:=p2d(0,0);
  if n.ChildCount=0 then
    exit;
  ch:=n.At(0);
  s:=TypeCastToIWSignal(ch);
  min:=s.MinX;
  max:=s.MaxX;
  for I := 1 to n.ChildCount - 1 do
  begin
    d:=n.at(i);
    s:=TypeCastToIWSignal(d);
    if s<>nil then
    begin
      if min>s.MinX then
      begin
        min:=s.MinX;
      end;
      if max<s.MaxX then
      begin
        max:=s.MaxX;
      end;
    end;
  end;
  result:=p2d(min, max);
end;


function GetStartStop(m:iwpusml):point2d;
var
  d:idispatch;
  s:iwpsignal;
  I: Integer;
  min, max:double;
begin
  if m.ParamCount=0 then
    exit;
  s:=m.Parameter(0) as iwpsignal;

  min:=s.MinX;
  max:=s.MaxX;
  for I := 1 to m.ParamCount - 1 do
  begin
    d:=m.Parameter(i);
    if Supports(d, DIID_IWPSignal) then
    begin
      s:=d as iwpsignal;
      if min>s.MinX then
      begin
        min:=s.MinX;
      end;
      if max<s.MaxX then
      begin
        max:=s.MaxX;
      end;
    end
    else
      break;
  end;
  result:=p2d(min, max);
end;

end.
