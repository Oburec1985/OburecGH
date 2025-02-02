// ������� �������� ��������
// 1) ������� ���� .ridl � IDE. � ������ �������� �������� CoClass
// 2) �� ������� implements �������� ��������� IWPExtOper
// 3) ������� ������� ���� � ���������� ������� � ����������� ���� ����� ������� �� ������� (������ ���������� ��� safecall)
// 4) �������� ������ initialization ��� � ���� �����
// 5) �������� � ������� Connect �������:
// eoRpt := TExtOperRpt.create(); // RptRegName - ��� ��� ����������� � ����� WP
// WINPOS.RegisterExtOper(eoRpt, 1, 1, RptRegName, 'Rpt', True);

unit uWPExtOperRpt;

interface

uses
  windows, ComObj, types, Forms, ActiveX, WPExtPack_TLB, Winpos_ole_TLB,
  StdVcl, PosBase,
  uFindMaxForm, uWPProc, classes, uCommonTypes, uWPservices, sysutils, utrend,
  uSetList, math, uWPEvents, ComServ, uCommonMath,
  dialogs,
  uMeasureBase,
  Graphics,
  MathFunction,
  uMyMath,
  uWord,
  uWPOpers,
  uWPProcServices,
  // uWPServices,
  Pathutils,
  uExcel;

type
  ResData = class
  public
    data:array of point3d;
  end;

  tband = record
    p2: point2d;
    // ��� 0 -���, 1 - �������, 2 - ��������
    bandType: integer;
    // ���   c_bandInterval_Graph = 0;  c_bandInterval_cursor = 1;  c_bandInterval_abs = 2;  c_bandInterval_fullscale = 3;
    autoband: integer;
    t1, t2: string;
    shift1, shift2: double;
  end;

  bandFFT = record
    // �������� �� X
    f: point2d;
    A: double;
  end;

  cOptRecord = class
  public
    // ������������� ������������ ���������
    estType: string;
    name, dsc: string;
    // ���������� �������� ���� ������������� ��� ������������ �����
    dyn: boolean;
    // ���������� �������� ���������� � ������
    size: integer;
    eval: boolean;
    // ��� ��������� ���������� ���������� ������ � ��������� ��� ���������� �������
    percent: boolean;
    band: point2d;
    // ��� ��������
    iTag:integer;
  public
    function getDsc: string;
    constructor create;
    destructor destroy;
  end;


  // ��������� �������� ������� ��� ���������
  RptSct = record
    error: boolean;
    Vx1, Vx2, M,
    // ���������
    D,
    // ���
    RMS, R,
    // ���
    E,
    // ����������
    A3,
    // �������
    A4, xMin, min, xMax, max,
    // ��������� ������� ���������/ ������� ������� ���������/ rms � ������
    mag1, f1, bandrms, dekr: double;
    // ���������� �������� ���������� � �������
    extA: array of point3d;
  end;

  // ������
  cRptSignal = class
  public
    name: string;
    // ������ ��������� �������
    s: cwpsignal;
    // ������ �� ������ ������� ��������
    src: csrc;
    // ������ ������ �� ������� ��������
    resData:array of RptSct;
  end;

  // �������� �� ����� ������ �������� ��������� (�� �������� �� ������
  // ������� ����� �������). ������ � ������� �������� ��������� �����
  TExtOperRpt = class(TAutoObject, IWPExtOper)
  public
    // trueI ���� �������������� ������ ������ � �����
    firstsignal: boolean;
    ressrc: csrc;

    error: boolean;
    props: string;
    // ���� ��� ���������� ������
    ResFolder: string;
    TmpltFile: string;
    // ��������� spm
    m_spmOpts: string;
    bands: array of tband;
    autobands: array of tband;
    // ������ bandrms � ��������� �� ������� �������
    PercentF: boolean;
    // ����� ������� ������ ������������
    MaxColCount: integer;
    SetEstNames: boolean;
    // ������ �����������, �� ������ �� ������� ��� ���������� �������
    res: array of RptSct;
    // 0 - ����� �� �������, 1 - �� ��������
    repType: integer;
    TmplRepName: string;
    // ����������
    m_autoBand: boolean;
    m_autoBandLen, m_autoBandShift: double;
    // 0 - ���������� �� �����
    // 1 - ���������� �� ����� �������
    m_autobandType:integer;
    m_autoBOffset1, m_autoBOffset2, m_autoBThreshold: double;
    m_AutoBChannel:string;
    m_AutoBChannelSig:cwpsignal;
    // ������ ��������� ����� �� ������
    m_bandlist:array of point2d;
    m_AutoBCount:integer;
  private
  public
    // ������ ����������� ��������
    resSignals: tstringlist;
    srcList: tstringlist;
    // ������ cOptRecord
    opts: tstringlist;
  protected
    mng: cWPObjmng;
    // ���� ��� ������ �����������
    outPutFile: tstringlist;
  public
    // ����� �������� � ����������� �������
    function UniqueNameCount: integer;
    // ������ ������ ������
    function UniqueNameIndex(signame: string): integer;
    procedure Setup;
    function GenEstName(estType: string): string;
    procedure AddEsimate(est: cOptRecord);
    procedure DelEsimate(estname: string);
    function GetEsimate(s: string): cOptRecord;
    function GetOptVal(optname: string): boolean;
    procedure SetOptVal(optname: string; v: boolean);
    // ���������� �������� ������, �.�. ���� ����� ����������� ������������ ���� �����
    function buildreportpath(src: csrc): string; overload;
    function buildreportpath(src: csrc; path: string): string; overload;
    // ������� �����
    procedure BuildReportExcel(fname: string; R: cregFolder);
    procedure AddMDBToReportExcel(fname: string; R: cregFolder);
    procedure BuildReportWord(fname: string);
    procedure setSmpOpts(str: string);
    function getSmpOpts: string;
    procedure EvalBandsByChannel(s:cwpsignal);
  protected
    function getActiveOptsCount: integer;
    // ���������� ����� ������� � ������ � ������� ����� �������� ������
    function GetCollumn(s: string): integer;
    // ���������� ����� ��������� ���������
    function GetSrcInd(s: cwpsignal): integer;
    // p_name - �������� ��� (���������); src - ����� ���������; s - ������ � ������� ������
    // resdata - ������ ��������� �� �������
    procedure AddResult(s: cwpsignal; src: csrc; p_name: string; resdata:array of RptSct);
    procedure ClearResults;
    function GetResult(i: integer): cwpsignal;
    function GetResultSrcSignal(i: integer): cwpsignal; overload;
    function GetResultSrcSignal(res: cRptSignal): cwpsignal; overload;
    function GetResultBySrcSignal(s: cwpsignal): cwpsignal;
    function getBand(i: integer): tband;
    function getBandcount: integer;

    procedure GetError(out pnerrcode: integer; out perrstr: WideString);
      safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
    procedure Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);
      safecall;
    procedure OnSetup(hwndparent: integer; out phwnd: integer); safecall;
  public
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure SetPropStr(const str: WideString); safecall;

    procedure DoEndProcess(sender: tobject);
    function Execute(const psrc1: IDispatch): boolean;
    function eval(s: iwpsignal): iwpsignal;
    procedure linc(p_mng: cWPObjmng);
    Constructor create;
    destructor destroy;
  end;

  // ��� ��������
function GetM_signal(s: iwpsignal): double;
// ���������
function GetD_signal(s: iwpsignal): double;
// ���
function GetE_signal(s: iwpsignal): double;
// ���
function GetRMS_signal(s: iwpsignal): double;
// ������
function GetR_signal(s: iwpsignal): double;
// ���������
function GetA_signal(s: iwpsignal): double;

function RunStats(const src: olevariant; E: TExtOperRpt): RptSct;
function GetAmp(const src: olevariant): double;
// ������� ���-�� ���������
function EvalCounter(const src: iwpsignal; t1, t2: double;  percent: boolean): integer; overload;
function EvalCounter(const src: iwpsignal; t1, t2, start, stop: double;  percent: boolean): integer; overload;
function EvalSpmMax(const src: iwpsignal;  t: double;  fftnum: integer): point3d;

const
  c_Excel_BlackInd = 1;
  c_Excel_WhightInd = 2;
  c_Excel_RedInd = 3;
  c_Excel_lightGreenInd = 4;
  c_Excel_indigoInd = 5;
  c_Excel_YellInd = 6;
  c_Excel_purpleInd = 7;
  c_Excel_BlueInd = 8;
  c_Excel_VinousInd = 9;
  c_Excel_GreenInd = 10;
  c_Excel_TealInd = 14;
  c_Excel_GrayInd = 15;
  c_Excel_LightYellInd = 15;

  c_NoError = 0;
  c_Interval_Error = 1;

  // ����� ��������� ������
  defaultCount = 15;
  RptRegName = '����� Excel';
  �_MainPage = '������ ������';
  �_MDBPage = '������ ���';
  c_offset = 3;
  constColCount = 8;
  sqrt3 = 1.73205080757;
  pi_sqrt3 = 1.813799364;
  c_digs=4;


  // ��������� ������ ���������
  c_estType_A1 = 'A_1';
  // ����� ���������
  c_estType_N = 'N_1';
  // ��� � ������
  c_estType_Rms = 'RMS_1';
  c_estType_SpmMax = 'SpmMax';

implementation

uses
  uRptFrm,
  uWpExtPack;

const
  c_col_Obj = 1;
  c_col_Test = 3;
  c_col_Reg = 5;

function GetAmp(const src: olevariant): double;
var
  r1, r2, opt, err: olevariant;
begin
  RunWPOperator('/Operators/�������. ��������������', src, src, r1, r2, opt,
    err);
  result := r1.GetY(5);
end;

function RunStats(const src: olevariant; E: TExtOperRpt): RptSct;
var
  r1, // ������
  r2, opt, err, optFFT, Er: olevariant;
  y, k, max: double;
  str: string;
  i, j, A1ind, portion, size, first, last: integer;
  s: iwpsignal;
  x: double;

  o: cOptRecord;
  bandrms_val: point2d;
begin
  RunWPOperator('/Operators/�������. ��������������', src, src, r1, r2, opt,
    err);
  str := src.sname + '_' + floattostr(src.minx) + floattostr(src.maxx);
  result.M := r1.GetY(0);
  result.D := r1.GetY(1);
  result.E := r1.GetY(2);
  result.A3 := r1.GetY(3);
  result.A4 := r1.GetY(4);
  result.R := r1.GetY(5) * 2;
  result.RMS := r1.GetY(6);
  // if E.GetOptVal('mag1') or E.GetOptVal('Bandrms') or E.GetOptVal('dekr') then
  if true then
  begin
    // RunFFT(const Src : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
    // typeMagnitude=1 - ����������� �������� typeWindow=1 - ������������� ����
    str := 'kindFunc=4,numPoints=';
    portion := 16384;
    str := str + inttostr(portion) +
      ',nLines=0,typeWindow=1,typeMagnitude=1,type=0,method=0,isMO=1,isCorrectFunc=0,isMonFase=0,isFill0=1,fMaxVal=0,fLog=0,fPrSpec=0,f3D=0,iStandart=1,fFlt=0';
    // ��������� �������� ������� �������
    str := updateParams(str, TExtOperRpt(E).m_spmOpts);
    while src.size < portion do
    begin
      portion := trunc(portion / 2);
    end;
    str := str + ',ofsNextBlock=' + inttostr(portion);
    str := str + ',nBlocks=';
    size := src.size;
    portion := round(size / portion) - 1;
    str:=str+inttostr(portion);
    if portion < 1 then
      portion := 1;
    optFFT := str;
    // ������� ������ ���
    RunFFT(src, r1, r2, optFFT, Er);
    result.mag1 := 0;
    result.bandrms := 0;
    for i := 0 to r1.size - 1 do
    begin
      y := r1.GetY(i);
      if y = r1.MaxY then
      begin
        result.mag1 := y * 1.41421356237;
        result.f1 := r1.getx(i);
        A1ind := i;
        break;
      end;
    end;
    if E.GetOptVal('dekr') then
    begin
      i := A1ind;
      if i <> 0 then
      begin
        while r1.GetY(i) > (result.mag1 / 2) do
        begin
          dec(i);
          if i = 0 then
            break;
        end;
        first := i;
        i := A1ind;
        while r1.GetY(i) > (result.mag1 / 2) do
        begin
          inc(i);
          if i = r1.size then
            break;
        end;
        last := i;
        // d = PI/������(3) * dF/F, ���
        // PI/������(3) = 1.813799364
        // dF - ������ ��������� �� ������ 0,5 (�� ��������� ���� ���������) (� ��)
        // F - ����������� ������� ��������� (� ��)
        result.dekr := pi_sqrt3 * (r1.getx(last) - r1.getx(first)) / result.f1;
      end;
    end;

    setlength(result.extA, E.opts.Count - defaultCount);
    // �������� � �������������� ������
    for i := defaultCount to E.opts.Count - 1 do
    begin
      o := cOptRecord(E.opts.Objects[i]);
      if o.eval then
      begin
        // ������� ��������
        if o.estType = c_estType_A1 then
        begin
          first := r1.IndexOf(o.band.x);
          last := r1.IndexOf(o.band.y);
          s := winpos.GetInterval(r1, first, last - first) as iwpsignal;
          str := inttostr(s.size);
          max := s.MaxY;
          result.extA[i - defaultCount].y := max;
          for j := 0 to s.size do
          begin
            x := s.getx(j);
            y := s.GetY(j);
            if y = max then
            begin
              result.extA[i - defaultCount].x := s.getx(j);
              break;
            end;
          end;
        end;
        // RMS
        if o.estType = c_estType_Rms then
        begin
          if o.percent then
          begin
            bandrms_val.x := result.f1 * o.band.x;
            bandrms_val.y := result.f1 * o.band.y;
          end
          else
          begin
            bandrms_val.x := o.band.x;
            bandrms_val.y := o.band.y;
          end;
          first := r1.IndexOf(bandrms_val.x);
          last := r1.IndexOf(bandrms_val.y);
          if (last - first) > 0 then
          begin
            for j := first to last do
            begin
              result.bandrms := r1.GetY(j) * r1.GetY(j) + result.bandrms;
            end;
            result.bandrms := sqrt(result.bandrms);
          end;
          result.extA[i - defaultCount].y := result.bandrms;
        end;
        // ������� ���������
        if o.estType = c_estType_N then
        begin
          s := iwpsignal(TVarData(src).VPointer);
          result.extA[i - defaultCount].y := round(EvalCounter(s, o.band.x,
              o.band.y, o.percent));
        end;
        // ������� ���������
        if o.estType = c_estType_SpmMax then
        begin
          s := iwpsignal(TVarData(src).VPointer);
          result.extA[i - defaultCount] := EvalSpmMax(s, o.band.x,o.iTag);
        end;
      end;
    end;
  end;
end;

function EvalSpmMax(const src: iwpsignal; t: double;  fftnum: integer): point3d;
var
  x1x2: point2d;
  i, spmsize:integer;
  er,r1,r2, fftopt:olevariant;
  isig, spm:iwpsignal;
  p3:point3d;
  folder,str:string;
begin
  // RunFFT(const Src : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
  // typeMagnitude=1 - ����������� �������� typeWindow=1 - ������������� ����
  str := 'kindFunc=4,numPoints=';
  str := str + inttostr(fftnum) +
    ',nLines=0,typeWindow=1,typeMagnitude=1,type=0,method=0,isMO=1,isCorrectFunc=0,isMonFase=0,isFill0=1,fMaxVal=0,fLog=0,fPrSpec=0,f3D=0,iStandart=1,fFlt=0';
  // ��������� �������� ������� �������
  str := str + ',ofsNextBlock=' + inttostr(fftnum);
  str := str + ',nBlocks=';
  x1x2.x:=src.Minx;
  x1x2.y:=x1x2.x+t;
  isig:=winpos.GetInterval(src, src.IndexOf(x1x2.x), src.IndexOf(x1x2.y)) as iwpsignal;
  i := trunc(isig.size / fftnum);
  str:=str+inttostr(i);
  if i < 1 then
  begin // � ������ ����� ������ �����
    exit;
  end;

  spmsize:=fftnum shr 1;
  Result.x:=-1;
  Result.y:=-1;
  Result.z:=-1;
  p3:=Result;
  while x1x2.y<=src.MaxX do
  begin
    isig:=winpos.GetInterval(src, src.IndexOf(x1x2.x), src.IndexOf(x1x2.y)) as iwpsignal;
    //i := round(isig.size / fftnum) - 1;
    //str:=str+inttostr(i);
    //if i < 1 then
    //  i := 1;
    // ������� ������ ���
    fftopt:=str;
    RunFFT(isig, r1, r2, fftopt,  Er);
    spm:=iwpsignal(TVarData(r1).VPointer);
    if p3.x=-1 then
    begin
      p3.x:=spm.GetX(0);
      p3.y:=spm.GetY(0);
      p3.z:=x1x2.x;
    end;
    for I := 1 to spmsize - 1 do
    begin
      if spm.GetY(i)>p3.y then
      begin
        p3.x:=spm.GetX(i);
        p3.y:=spm.GetY(i);
        p3.z:=x1x2.x;
      end;
    end;
    x1x2.x:=x1x2.y;
    x1x2.y:=x1x2.y+t;
  end;
  result:=p3;
  if p3.y<>-1 then
  begin
    x1x2.x:=p3.z;
    x1x2.y:=x1x2.x+t;
    isig:=winpos.GetInterval(src, src.IndexOf(x1x2.x), src.IndexOf(x1x2.y)) as iwpsignal;
    // ������� ������ ���
    fftopt:=str;
    RunFFT(isig, r1, r2, fftopt,  Er);
    spm:=iwpsignal(TVarData(r1).VPointer);
    folder := '/Signals/rpt/' + Datetostr(Now);
    // � ���� folder=Signals/����������/ � s.sname=3- 1
    winpos.Link(folder, src.sname+'SpmMax; T='+floattostr(x1x2.x), spm);
  end;
end;

function EvalCounter(const src: iwpsignal; t1, t2: double;
  percent: boolean): integer;
var
  minmax, lvl: point2d;
  range, y: double;
  i, counter: integer;
  tr1, counted: boolean;
begin
  minmax.x := src.MinY;
  minmax.y := src.MaxY;
  range := minmax.y - minmax.x;
  if percent then
  begin
    lvl.x := range * t1 + minmax.x;
    lvl.y := range * t2 + minmax.x;
  end
  else
  begin
    lvl.x := t1;
    lvl.y := t2;
  end;
  counter := 0;
  counted := false;
  for i := 0 to src.size do
  begin
    y := src.GetY(i);
    if not tr1 then
    begin
      if y < lvl.x then
      begin
        tr1 := true;
        counted := false;
      end;
    end
    else
    begin
      if y > lvl.y then
      begin
        if not counted then
        begin
          inc(counter);
          counted := true;
          tr1 := false;
        end;
      end;
    end;
  end;
  result := counter;
end;

function EvalCounter(const src: iwpsignal; t1, t2, start, stop: double;
  percent: boolean): integer;
var
  s1: iwpsignal;
  i, j: integer;
begin
  i := s1.IndexOf(start);
  j := s1.IndexOf(stop);
  s1 := WP.GetInterval(src, i, j) as iwpsignal;
  result := EvalCounter(s1, t1, t2, percent);
end;

function GetA_signal(s: iwpsignal): double;
begin
  result := GetR_signal(s);
  result := result / 2;
end;

function GetR_signal(s: iwpsignal): double;
var
  i, len: integer;
  min, max, y: double;
begin
  result := 0;
  len := s.size;
  min := s.GetY(0);
  max := min;
  for i := 1 to len - 1 do
  begin
    y := s.GetY(i);
    if y < min then
      min := y
    else
    begin
      if y > max then
        max := y;
    end;
  end;
  result := (max - min);
end;

function GetM_signal(s: iwpsignal): double;
var
  i, len: integer;
begin
  result := 0;
  len := s.size;
  for i := 0 to len - 1 do
  begin
    result := s.GetY(i) + result;
  end;
  result := result / len;
end;

function GetRMS_signal(s: iwpsignal): double;
var
  i, len: integer;
  D: single;
begin
  len := s.size;
  result := 0;
  for i := 0 to len - 1 do
  begin
    D := s.GetY(i);
    result := D * D + result;
  end;
  result := result / len;
  result := sqrt(result);
end;

function GetD_signal(s: iwpsignal): double;
var
  i, len: integer;
  D, M: single;
begin
  len := s.size;
  result := 0;
  M := GetM_signal(s);
  for i := 0 to len - 1 do
  begin
    D := s.GetY(i) - M;
    result := D * D + result;
  end;
  result := result / len;
end;

function GetE_signal(s: iwpsignal): double;
var
  D: single;
begin
  D := GetD_signal(s);
  result := sqrt(D);
end;

Constructor TExtOperRpt.create;
var
  o: cOptRecord;
begin
  MaxColCount := 1;

  m_spmOpts :=
    'isFill0=1,typeWindow=1,typeMagnitude=1,kindFunc=4,numPoints=16384';

  opts := tstringlist.create;
  // 1
  o := cOptRecord.create;
  o.name := 'Vx1';
  o.dsc := '�������� ������ ���������';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 2
  o := cOptRecord.create;
  o.name := 'Vx2';
  o.dsc := '�������� ����� ���������';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 3
  o := cOptRecord.create;
  o.name := 'M';
  o.dsc := 'M��. ��������';
  o.eval := true;
  opts.AddObject(o.name, o);
  // 4
  o := cOptRecord.create;
  o.name := 'D';
  o.dsc := '���������';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 5
  o := cOptRecord.create;
  o.name := 'RMS';
  o.dsc := '���';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 6
  o := cOptRecord.create;
  o.name := 'R';
  o.dsc := '������';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 7
  o := cOptRecord.create;
  o.name := 'E';
  o.dsc := '���';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 8
  o := cOptRecord.create;
  o.name := 'A3';
  o.dsc := '����������';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 9
  o := cOptRecord.create;
  o.name := 'A4';
  o.dsc := '�������';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 10
  o := cOptRecord.create;
  o.name := 'Xmin';
  o.dsc := 'X �������';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 11
  o := cOptRecord.create;
  o.name := 'min';
  o.dsc := '�������';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 12
  o := cOptRecord.create;
  o.name := 'Xmax';
  o.dsc := 'X ��������';
  o.eval := false;
  opts.AddObject(o.name, o);
  // 13
  o := cOptRecord.create;
  o.name := 'max';
  o.dsc := '��������';
  o.eval := false;
  opts.AddObject(o.name, o);
  o := cOptRecord.create;
  // 14, 15
  o.name := 'mag1';
  o.dsc := '��������� �������� ���������';
  o.size := 2;
  o.eval := true;
  opts.AddObject(o.name, o);
  // 16
  o := cOptRecord.create;
  o.name := 'dekr';
  o.dsc := '���������';
  o.eval := false;
  opts.AddObject(o.name, o);

  resSignals := tstringlist.create;
  srcList := tstringlist.create;
end;

function TExtOperRpt.GetEsimate(s: string): cOptRecord;
var
  i: integer;
begin
  result := nil;
  for i := 0 to opts.Count - 1 do
  begin
    if cOptRecord(opts.Objects[i]).name = s then
    begin
      result := cOptRecord(opts.Objects[i]);
      exit;
    end;
  end;
end;

procedure TExtOperRpt.DelEsimate(estname: string);
var
  i: integer;
  o: cOptRecord;
begin
  for i := 0 to opts.Count - 1 do
  begin
    o := cOptRecord(opts.Objects[i]);
    if o.name = estname then
    begin
      o.destroy;
      opts.Delete(i);
      exit;
    end;
  end;
end;

function TExtOperRpt.GenEstName(estType: string): string;
var
  str: string;
  b: boolean;
  i: integer;
  o: cOptRecord;
begin
  b := true;
  str := estType;
  while b do
  begin
    b := false;
    for i := 0 to opts.Count - 1 do
    begin
      o := cOptRecord(opts.Objects[i]);
      if o.name = str then
      begin
        b := true;
        str := ModName(str, false);
        break;
      end;
    end;
  end;
  result := str;
end;

procedure TExtOperRpt.AddEsimate(est: cOptRecord);
begin
  opts.AddObject(est.name, est);
end;

function TExtOperRpt.GetOptVal(optname: string): boolean;
var
  o: cOptRecord;
  i: integer;
begin
  result := false;
  for i := 0 to opts.Count - 1 do
  begin
    o := cOptRecord(opts.Objects[i]);
    if o.name = optname then
    begin
      result := o.eval;
      exit;
    end;
  end;
end;

procedure TExtOperRpt.SetOptVal(optname: string; v: boolean);
var
  o: cOptRecord;
  i: integer;
begin
  for i := 0 to opts.Count - 1 do
  begin
    o := cOptRecord(opts.Objects[i]);
    if o.name = optname then
    begin
      o.eval := o.eval;
      exit;
    end;
  end;
end;

destructor TExtOperRpt.destroy;
var
  i: integer;
  row: tstringlist;
  s: cRptSignal;
  o: cOptRecord;
begin
  for i := 0 to resSignals.Count - 1 do
  begin
    s := cRptSignal(resSignals.Objects[i]);
    s.destroy;
  end;
  resSignals.destroy;

  for i := 0 to opts.Count - 1 do
  begin
    o := cOptRecord(opts.Objects[i]);
  end;
  opts.destroy;

  srcList.destroy;
end;

procedure TExtOperRpt.linc(p_mng: cWPObjmng);
begin
  mng := p_mng;
  mng.Events.AddEvent('RptEO_EndProcess', E_OnEndProcess, DoEndProcess);
end;

procedure TExtOperRpt.GetError(out pnerrcode: integer; out perrstr: WideString);
begin
  pnerrcode := 0;
end;

procedure TExtOperRpt.GetPropStr(out pstr: WideString);
begin
  pstr := props;
end;

function TExtOperRpt.Execute(const psrc1: IDispatch): boolean;
var
  D: IDispatch;
begin
  result := true;
  Exec(psrc1, psrc1, D, D);
  if error then
    result := false;
end;

procedure TExtOperRpt.DoEndProcess(sender: tobject);
begin
  if outPutFile <> nil then
  begin
    outPutFile.destroy;
    outPutFile := nil;
  end;
end;

function TExtOperRpt.getActiveOptsCount: integer;
var
  o: cOptRecord;
  i: integer;
begin
  result := 0;
  for i := 0 to opts.Count - 1 do
  begin
    o := cOptRecord(opts.Objects[i]);
    if o.eval then
    begin
      result := result + o.size;
    end;
  end;
end;

function TExtOperRpt.GetCollumn(s: string): integer;
var
  i: integer;
  sig: cRptSignal;
begin
  for i := 0 to resSignals.Count - 1 do
  begin
    sig := cRptSignal(resSignals.Objects[i]);
    if sig.name = s then
    begin
      result := i;
      exit;
    end;
  end;
end;

function TExtOperRpt.GetSrcInd(s: cwpsignal): integer;
var
  i, j: integer;
  src: csrc;
begin
  for i := 0 to resSignals.Count - 1 do
  begin
    if cRptSignal(resSignals.Objects[i]).s = s then
    begin
      for j := 0 to srcList.Count - 1 do
      begin
        src := csrc(srcList.Objects[j]);
        if src = cRptSignal(resSignals.Objects[i]).src then
        begin
          result := j;
          exit;
        end;
      end;
    end;
  end;
end;

procedure TExtOperRpt.BuildReportWord(fname: string);
var
  str: string;
  src: csrc;
  sig: cwpsignal;
  o: cOptRecord;
  rowInd, colInd, rowCount, ColCount, TableCount, srcCount, ind: integer;
  i, j, k, tabInd, signalind, M, EstNum, EstCount, tableInd: integer;
  band: tband;
begin
  if not CheckExcelInstall then
  begin
    showmessage('���������� ��������� MSWord');
    exit;
  end;
  CreateWord;
  VisibleWord(true);
  OpenDoc(startdir + '\Opers\' + 'WrdTmpl.docx');
  src := csrc(srcList.Objects[0]);
  FindAndPasteTextDoc('<SignalName>', extractfilename(src.name));
  FindAndPasteTextDoc('<Date>', Datetostr(Now));
  EstCount := getActiveOptsCount;
  str := '';
  for i := 0 to opts.Count - 1 do
  begin
    o := cOptRecord(opts.Objects[i]);
    if o.eval then
    begin
      str := str + o.name;
      if i <> EstCount - 1 then
      begin
        str := str + ',';
      end
      else
        break;
    end;
  end;
  FindAndPasteTextDoc('<Format>', str);
  rowCount := getBandcount;
  tableInd := 0;

  tabInd := 0;
  for i := 0 to srcList.Count - 1 do
  begin
    signalind := 0;
    src := csrc(srcList.Objects[i]);
    ColCount := src.childCount;
    if ColCount > MaxColCount then
    begin
      ColCount := MaxColCount;
    end;
    TableCount := src.childCount div ColCount;
    if (src.childCount mod ColCount <> 0) then
      inc(TableCount);

    for tabInd := 0 to TableCount - 1 do
    begin
      // �������� ������� ������� � ����� ���������
      EndOfDoc;
      // ������� �������
      SetCarret;
      // ������� �������
      SetTextToDoc('������: ' + src.name + '����:' + src.merafile.Date, false);
      SetCarret;
      if tabInd < TableCount - 1 then
      begin
      end
      else
      begin
        ColCount := src.childCount - (TableCount - 1) * ColCount;
      end;
      CreateTable(rowCount + 1, ColCount + 1, ind);
      inc(tableInd);
      // ������� ������ ������
      SetTextToTable(tableInd, 1, 1, '��������');
      for j := 0 to ColCount - 1 do
      begin
        // ������� ������ ������
        sig := src.getSignalObj(j + signalind);
        SetTextToTable(tableInd, 1, j + 2, sig.name)
      end;
      // ��������� ���� �������
      // i - ����� ��������� �������, j - ����� ���������, k - ����� ������� � ���������
      for j := 0 to rowCount - 1 do
      begin
        band := getBand(j);
        if band.bandType = c_bandType_phis then
          str := ' ���.'
        else
          str := ' ���.';
        SetTextToTable(tableInd, 2 + j, 1,
          formatstr(band.p2.x, 3) + '..' + formatstr(band.p2.y, 3) + str);
        for k := 0 to ColCount - 1 do
        begin
          sig := src.getSignalObj(k + signalind);
          // �������� ����� �� ������ ���������
          sig := GetResultBySrcSignal(sig);
          if sig = nil then
            continue;
          EstNum := 0;
          str := '';
          for M := 0 to opts.Count - 1 do
          begin
            o := cOptRecord(opts.Objects[M]);
            if o.eval then
            begin
              if SetEstNames then
                str := str + o.name + ':' + formatstr
                  (sig.GetP2(opts.Count * j + EstNum).y, 3)
              else
                str := str + formatstr(sig.GetP2(opts.Count * j + EstNum).y, 3);
              if EstNum <> EstCount - 1 then
              begin
                // #10 - ����� ������ #13 - ������� �������
                str := str + char(10); // +char(13);
              end;
              inc(EstNum);
              if EstNum = EstCount then
                break;
            end;
          end;
          SetTextToTable(tableInd, j + 2, k + 2, str);
        end;
      end;
      signalind := signalind + ColCount;
    end;
  end;
  // CreateTable(NumRows, NumColumns: integer; var index: integer): boolean;
  SaveDocAs(fname);
  CloseWord;
end;

procedure TExtOperRpt.AddMDBToReportExcel(fname: string; R: cregFolder);
var
  row, col: integer;
  o, t: cXmlFolder;
  rng, page: olevariant;
  i: integer;
begin
  if not fileexists(fname) then
    exit;
  OpenWorkBook(fname);
  page:=AddSheetEx(e.activeWorkBook,�_MDBPage);
  row := 1;
  col := 1;
  SetCell(page.index, row, col,
    '���� ������ ���������: ' + g_Mbase.m_BaseFolder.Absolutepath);
  o := cXmlFolder(R.GetParentByClassName('cObjFolder'));
  t := cXmlFolder(R.GetParentByClassName('cTestFolder'));

  row := 2;
  col := c_col_Obj;
  SetCell(page.index, row, col, '������: ' + o.caption);
  rng := GetRangeObj(page.index, point(row, col), point(row, col + 1));
  rng.merge;

  row := 2;
  col := c_col_Test;
  SetCell(page.index, row, col, '���������: ' + t.caption);
  rng := GetRangeObj(page.index, point(row, col), point(row, col + 1));
  rng.merge;

  row := 2;
  col := c_col_Reg;
  SetCell(page.index, row, col, '�����������: ' + R.caption);
  rng := GetRangeObj(page.index, point(row, col), point(row, col + 1));
  rng.merge;

  row := 3;
  col := c_col_Obj;
  for i := 0 to o.PropCount - 1 do
  begin
    SetCell(page.index, row + i, col, o.getPropertyName(i));
    SetCell(page.index, row + i, col + 1, o.getProperty(i));
  end;

  row := 3;
  col := c_col_Test;
  for i := 0 to t.PropCount - 1 do
  begin
    SetCell(page.index, row + i, col, t.getPropertyName(i));
    SetCell(page.index, row + i, col + 1, t.getProperty(i));
  end;

  row := 3;
  col := c_col_Reg;
  for i := 0 to r.PropCount - 1 do
  begin
    SetCell(page.index, row + i, col, R.getPropertyName(i));
    SetCell(page.index, row + i, col + 1, R.getProperty(i));
  end;
end;

procedure TExtOperRpt.BuildReportExcel(fname: string; r:cregfolder);
var
  handle: thandle;
  blockcount, blockrow, blockSize, // �������� �������� ������ ����� (�������� �� ������������ ����� ������� ������)
  i, j, k, num, signalind, srcInd, ColCount, bcount, ind,
  // ����� ������� ������� � ������� ������
  colInd, row, row1: integer;
  rng, str: string;
  rptsig:cRptSignal;
  sig: cwpsignal;
  src: csrc;
  o: cOptRecord;
  v: point3d;
  band: tband;
  tr: ctrig;
  rngObj, sheet: olevariant;
begin
  if not CheckExcelInstall then
  begin
    showmessage('���������� ��������� Excel');
    exit;
  end;
  handle := 0;
  CreateExcel;
  VisibleExcel(false);
  begin
    if fileexists(TmpltFile) then
    begin
      str := RelativePathToAbsolute(TmpltFile);
      OpenWorkBook(str);
      E.ActiveWorkbook.Sheets.Item[1].cells.clear;
    end
    else
    begin
      if fileexists(fname) then
      begin
        OpenWorkBook(fname);
        E.ActiveWorkbook.Sheets.Item[1].cells.clear;
      end
      else
      begin
        AddWorkBook;
        AddSheet(�_MainPage);
        DeleteSheet(2);
      end;
    end;
    // ������� ����� �������� ���� ������
    blockrow := 0;
    v.y := UniqueNameCount / MaxColCount;
    blockcount := round(v.y);
    if blockcount < v.y then
      inc(blockcount);
    blockSize := getBandcount * srcList.Count;
    // ���������� �������� ������ 3-� ����� A1
    // SetRange(1,'A1',234.45);
    rng := GetRange(1, 'A1');
    // ������� ����� ������
    for i := 0 to blockcount - 1 do
    begin
      SetCell(1, 1 + i * (blockSize + 2), 1, '������:');
      rngObj := GetRangeObj(1, point(1 + i * (blockSize + 2), 1),
        point(1 + i * (blockSize + 2), 2));
      rngObj.ColumnWidth := 30;
      // E.ActiveWorkbook.Sheets.Item[1].columns[1].ColumnWidth:=30;
      rngObj.merge;
      SetCell(1, 2 + i * (blockSize + 2), 1, '�����');
      SetCell(1, 2 + i * (blockSize + 2), 2, '�����');
    end;
    // ��������� ����� ������
    ColCount := getActiveOptsCount;
    for i := 0 to resSignals.Count - 1 do
    begin
      sig := GetResult(i);
      // ind:=UniqueNameIndex(cRptSignal(resSignals.Objects[i]).name);
      signalind := GetCollumn(cRptSignal(resSignals.Objects[i]).name);
      blockrow := trunc(signalind / MaxColCount);

      if (signalind < i) then
        continue;
      // �������� �� ������������ ����� �������
      colInd := signalind - MaxColCount * trunc(signalind / MaxColCount);
      num := colInd * ColCount + c_offset;

      SetCell(1, 1 + blockrow * (blockSize + 2), num,
        cRptSignal(resSignals.Objects[i]).name);
      rngObj := GetRangeObj(1, point(1 + blockrow * (blockSize + 2), num),
        point(1 + blockrow * (blockSize + 2),
          ((colInd + 1) * ColCount + c_offset - 1)));
      // rng:=RangeObjToAdress(rngObj);
      // SetMergeCells(1,rng,true);
      rngObj.merge;
      if (i mod 2) = 0 then
      begin
        rngObj.Interior.ColorIndex := c_Excel_GrayInd;
      end;
      rngObj.HorizontalAlignment := xlHAlignCenter;
      j := 0;
      k := 0;
      while k <= opts.Count - 1 do
      begin
        o := cOptRecord(opts.Objects[k]);
        if o.eval then
        begin
          if o.name = 'mag1' then
          begin
            SetCell(1, 2 + blockrow * (blockSize + 2),
              colInd * ColCount + j + c_offset, 'F1');
            SetCell(1, 2 + blockrow * (blockSize + 2),
              colInd * ColCount + j + c_offset + 1, o.name);
          end
          else
          begin
            if (pos('A_', o.name) > 0) or (pos('RMS_', o.name) > 0) then
            begin
              SetCell(1, 2 + blockrow * (blockSize + 2),
                colInd * ColCount + j + c_offset,
                o.name + '_' + floattostr(o.band.x) + '..' + floattostr
                  (o.band.y));
              SetCell(1, 2 + blockrow * (blockSize + 2),
                colInd * ColCount + j + c_offset + 1, o.name);
            end
            else
            begin
              SetCell(1, 2 + blockrow * (blockSize + 2),
                colInd * ColCount + j + c_offset, o.name);
            end;
          end;
          j := j + o.size;
        end;
        // ����; ������; �������; ��������
        inc(k);
      end;
    end;
    bcount := getBandcount;
    // ��������� ������
    for i := 0 to srcList.Count - 1 do
    begin
      // ��������� ������
      src := csrc(srcList.Objects[i]);
      for j := 0 to bcount - 1 do
      begin
        band := getBand(j);
        if band.bandType = c_bandType_trig then
        begin
          tr := mng.getTrig(band.t1);
          band.p2.x := tr.GetTime(src);
          tr := mng.getTrig(band.t2);
          band.p2.y := tr.GetTime(src);
        end;
        // ��������� � ����� ��������� ���������
        rng := formatstr(band.p2.x, c_digs) + '..' + formatstr(band.p2.y, c_digs);
        if band.bandType = c_bandType_ind then
          rng := rng + ' ���.';
        for k := 0 to blockcount - 1 do
        begin
          row:=j + 3 + i*bcount + k * (bcount * srcList.Count + 2);
          SetCell(1, row, 2, rng);
        end;
      end;
      for k := 0 to blockcount - 1 do // ��������� � ���� �� �������?
      begin // i ����� ����������
        //row:=(j - 1) + 3 + i * (srcList.Count - 1) * bcount + k *(bcount * srcList.Count + 2);
        row:=(j - 1) + 3 + i*bcount + k *(bcount * srcList.Count + 2);
        // ��������� ��� ������
        SetCell(1, row, 1, src.name + #10 + ' ����:' + src.merafile.Date);
        //row:=3 + i * (srcList.Count - 1) * bcount + k *(bcount * srcList.Count + 2);
        row1:=row+bcount-1;
        rngObj := GetRangeObj(1,point(row, 1), point(row1, 1));
        rngObj.merge;
      end;
    end;
    // ��������� ������ ������
    for i := 0 to resSignals.Count - 1 do
    begin
      sig := GetResult(i);
      rptsig:=cRptSignal(resSignals.Objects[i]);
      signalind := GetCollumn(cRptSignal(resSignals.Objects[i]).name);
      // blockrow:=trunc(i/maxcolcount);
      blockrow := trunc(signalind / MaxColCount);
      colInd := signalind - MaxColCount * trunc(signalind / MaxColCount);

      srcInd := GetSrcInd(sig);
      for j := 0 to bcount - 1 do
      begin
        num := 0;
        for k := 0 to opts.Count - 1 do
        begin
          o := cOptRecord(opts.Objects[k]);
          if o.eval then
          begin
            v.y := sig.Signal.GetY(j * opts.Count + k);
            v.x := sig.Signal.getx(j * opts.Count + k);
            if (k-defaultCount)>=0 then
            begin
              v.z:= rptsig.resdata[j].extA[k-defaultCount].z;
            end;
            if o.name = 'mag1' then
            begin
              // i - ����� ������ (������ �������� ��������)
              // num - �����  ������ ������ �������� �������
              // k - ������� �� ������ ������
              // j - ������� �� ������ ������
              SetCell(1, j + 3 + srcInd * bcount + blockrow *
                  (bcount * srcList.Count + 2),
                colInd * ColCount + num + c_offset,
                sig.Signal.getx(j * opts.Count + k));
                SetCell(1, j + 3 + srcInd * bcount + blockrow *
                    (bcount * srcList.Count + 2),
                    colInd * ColCount + num + c_offset + 1, v.y);
            end
            else
            begin
              if o.estType = c_estType_A1 then
              begin
                // i - ����� ������ (������ �������� ��������)
                // num - ����� ������ ������ �������� �������
                // k - ������� �� ������ ������
                // j - ������� �� ������ ������
                str := formatstr(o.band.x, 3) + '..' + formatstr(o.band.y, 3);
                SetCell(1, j + 3 + srcInd * bcount + blockrow *
                          (bcount * srcList.Count + 2),
                          colInd * ColCount + num + c_offset, v.x);
                SetCell(1, j + 3 + srcInd * bcount + blockrow *
                          (bcount * srcList.Count + 2),
                          colInd * ColCount + num + c_offset + 1, v.y);
              end
              else
              begin
                if o.estType = c_estType_SpmMax then
                begin
                  v.z:=rptsig.resData[j].extA[k-defaultCount].z;
                  SetCell(1, j + 3 + srcInd * bcount + blockrow *
                            (bcount * srcList.Count + 2),
                            colInd * ColCount + num + c_offset, v.x);
                  SetCell(1, j + 3 + srcInd * bcount + blockrow *
                            (bcount * srcList.Count + 2),
                            colInd * ColCount + num + c_offset + 1, v.y);
                  SetCell(1,
                          // row
                          j + 3 + srcInd * bcount + blockrow *(bcount * srcList.Count + 2),
                          // col
                          colInd * ColCount + num + c_offset + 2,
                          v.z);
                end
                else
                begin
                  SetCell(1, j + 3 + srcInd * bcount + blockrow *
                      (bcount * srcList.Count + 2),
                      colInd * ColCount + num + c_offset, v.y);
                end;
              end;
            end;
            // ����; ������; �������; ��������
            num := num + o.size;
          end;
        end;
      end;
    end;
    // �������� ��� �������
    // sheet:=E.ActiveWorkbook.ActiveSheet;
    // ���������� int ����� ����� � ��������
    // Rows := MyExcel.ActiveSheet.UsedRange.Rows.Count;
    // Columns := MyExcel.ActiveSheet.UsedRange.Columns.Count;
    rngObj := E.ActiveSheet.UsedRange;
    // rngObj := GetRangeObj(1,point(1,1),point(rngObj.Rows.Count,rngObj.Columns.Count));
    SetRangeBorder(rngObj);
    try
      SaveWorkBookAs(fname);
    except
      showmessage(
        '�� ������� ��������� �����. ������������� ������� ��� ���� ������� �� ������');
    end;
  end;
  ClearResults;
  if r=nil then
  begin
    CloseWorkBook;
    CloseExcel;
  end
  else
  begin
    AddMDBToReportExcel(fname,r);
    try
      SaveWorkBookAs(fname);
    except
      showmessage(
        '�� ������� ��������� �����. ������������� ������� ��� ���� ������� �� ������');
    end;
    CloseWorkBook;
    CloseExcel;
  end;
end;

function TExtOperRpt.buildreportpath(src: csrc; path: string): string;
begin
  // ���� ���� ���� ����� �������� ������������� ����
  if src.merafile <> nil then
  begin
    if path[1] = '.' then
    begin
      result := ExtractFileDir(src.merafile.FileName) + Copy(path, 2,
        length(ResFolder) - 1);
    end
    else
    begin
      result := path;
    end;
  end
  else
  begin
    result := path;
  end;
end;

function TExtOperRpt.buildreportpath(src: csrc): string;
begin
  // ���� ���� ���� ����� �������� ������������� ����
  if src.merafile <> nil then
  begin
    if ResFolder[1] = '.' then
    begin
      result := ExtractFileDir(src.merafile.FileName) + Copy(ResFolder, 2,
        length(ResFolder) - 1);
    end
    else
    begin
      result := ResFolder;
    end;
  end
  else
  begin
    result := ResFolder;
  end;
end;

function IsFileClosed(fname: string; wait: dword): boolean;
var
  h, i: dword;
begin
  result := false;
  i := 0;
  repeat
    h := CreateFile(PChar(fname), GENERIC_READ or GENERIC_WRITE, 0, nil,
      OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    If (h <> INVALID_HANDLE_VALUE) then
    begin
      CloseHandle(h);
      result := true;
      exit;
    end;
    Sleep(100);
    inc(i);
  until (i > wait) or (wait = 0);
end;

procedure TExtOperRpt.SetPropStr(const str: WideString);
var
  stra: AnsiString;
  lopts: tstringlist;
  o: cOptRecord;
  A: boolean;
  BandCount, i, j: integer;
  sval, band: string;
begin
  // props := DeleteSpace(str);
  props := str;
  stra := props;
  // ������ ��������� ���������
  lopts := ParsStrParamExt(props, ';', '"');
  // ����� ����� �������
  sval := GetParsValue(lopts, 'BandCount');
  if m_autoBand then
  begin

  end
  else
  begin
    if isvalue(sval) then
      BandCount := strtoint(sval)
    else
      BandCount := 0;
  end;

  // ����� ����� �������
  sval := GetParsValue(lopts, 'MaxColCount');
  if sval <> '_' then
    MaxColCount := strtoint(sval);
  stra := GetParsValue(lopts, 'SetEstNames');
  SetEstNames := stra = '1';

  setlength(bands, BandCount);

  if not A then
  begin
    j := 0;
    // ������� ������ �� �������
    band := GetParsValue(lopts, 'X');
    for i := 0 to BandCount - 1 do
    begin
      // ��� 0 -���, 1 - �������, 2 - ��������
      sval := GetSubString(band, ';', j + 1, j);
      bands[i].bandType := strtoint(sval);
      if bands[i].bandType = c_bandType_trig then
      begin
        sval := GetSubString(band, ';', j + 1, j);
        bands[i].t1 := sval;
        sval := GetSubString(band, ';', j + 1, j);
        bands[i].t2 := sval;
        sval := GetSubString(band, ';', j + 1, j);
        bands[i].shift1 := strtoFloatExt(sval);
        sval := GetSubString(band, ';', j + 1, j);
        bands[i].shift2 := strtoFloatExt(sval);
        bands[i].autoband := c_bandType_phis;
      end
      else
      begin
        sval := GetSubString(band, ';', j + 1, j);
        if sval = '_' then
          bands[i].p2.x := 0
        else
          bands[i].p2.x := strtoFloatExt(sval);
        sval := GetSubString(band, ';', j + 1, j);
        if sval = '_' then
          bands[i].p2.y := 0
        else
          bands[i].p2.y := strtoFloatExt(sval);
      end;
    end;
  end;
  for i := 0 to opts.Count - 1 do
  begin
    o := cOptRecord(opts.Objects[i]);
    o.eval := (GetParsValue(lopts, o.name) = '1');
  end;
  PercentF := (GetParsValue(lopts, 'PercentF') = '1');
  sval := GetParsValue(lopts, 'RMSf1');
  m_autoBand := GetParsValue(lopts, 'AutoBand') = '1';
  sval := GetParsValue(lopts, 'AutoBandLen');
  if sval <> '_' then
    m_autoBandLen := strtofloat(sval);
  sval := GetParsValue(lopts, 'AutoBandShift');
  if sval <> '_' then
    m_autoBandShift := strtofloat(sval);

  sval:=GetParsValue(lopts, 'AutoBandType');
  if sval <> '_' then
    m_autobandType:=strtoint(sval)
  else
  begin
    m_autobandType:=0;
  end;
  if m_autobandType=1 then
  begin
    m_autoBOffset1:=strtoFloatExt(GetParsValue(lopts, 'AutoBOffset1'));
    m_autoBOffset2:=strtoFloatExt(GetParsValue(lopts, 'AutoBOffset2'));
    m_AutoBThreshold:=strtoFloatExt(GetParsValue(lopts, 'AutoBThreshold'));
    m_AutoBChannel:=GetParsValue(lopts, 'AutoBChannel');
  end;

  ResFolder := GetParsValue(lopts, 'SavePath');
  TmpltFile := GetParsValue(lopts, 'TmpltPath');

  lopts.destroy;
end;

procedure TExtOperRpt.OnApply;
var
  Code: integer;
begin

end;

procedure TExtOperRpt.OnClose;
begin
  Rptfrm.destroy;
  Rptfrm := nil;
end;

procedure TExtOperRpt.Setup;
var
  h: integer;
begin
  OnSetup(0, h);
end;

procedure TExtOperRpt.OnSetup(hwndparent: integer; out phwnd: integer);
begin
  if not Assigned(Rptfrm) then
  begin
    Rptfrm := TRptFrm.create(nil);
    mng.ReadSrc;

    Rptfrm.Init(self, mng);
  end;
  Rptfrm.editoper;
  phwnd := Rptfrm.handle;
end;

function TExtOperRpt.UniqueNameCount: integer;
var
  i, ind: integer;
  str: string;
  l: tstringlist;
begin
  l := tstringlist.create;
  l.Sorted := true;
  for i := 0 to resSignals.Count - 1 do
  begin
    str := cRptSignal(resSignals.Objects[i]).name;
    if not l.find(str, ind) then
      l.Add(str);
  end;
  result := l.Count;
  l.destroy;
end;

function TExtOperRpt.UniqueNameIndex(signame: string): integer;
var
  i, ind: integer;
  str: string;
  l: tstringlist;
begin
  result := -1;
  l := tstringlist.create;
  l.Sorted := true;
  for i := 0 to resSignals.Count - 1 do
  begin
    str := cRptSignal(resSignals.Objects[i]).name;
    if not l.find(str, ind) then
      l.Add(str);
  end;
  if l.find(signame, ind) then
  begin
    result := ind;
  end;
  l.destroy;
end;

function TExtOperRpt.eval(s: iwpsignal): iwpsignal;
var
  i, j, bcount, start, finish, ColCount, ind: integer;
  sInterval, isig: iwpsignal;
  rec: RptSct;
  opt: cOptRecord;
  sig: cwpsignal;
  folder: string;
  D: IDispatch;

  src: csrc;
  error: integer;

  tr: ctrig;
  v, x, y: double;
begin
  src := mng.GetSrcBySignal(s);
  if m_autoBand then
  begin
    if m_autobandType=0 then
    begin
      bcount := trunc((src.t2 - src.t1) / (m_autoBandLen + m_autoBandShift));
      if (src.t2 - src.t1) > bcount * (m_autoBandLen + m_autoBandShift) then
      begin
        inc(bcount);
      end;
    end
    else
    begin
      bcount:=m_AutoBCount;
    end;
  end
  else
  begin
    bcount := length(bands);
  end;
  setlength(res, bcount);
  setlength(autobands, bcount);
  error := 0;
  for i := 0 to bcount - 1 do
  begin
    if m_autoBand then
    begin
      if m_autobandType=0 then
      begin
        autobands[i].p2.x := src.t1 + i * (m_autoBandLen + m_autoBandShift);
        autobands[i].p2.y := autobands[i].p2.x + m_autoBandLen;
        start := s.IndexOf(autobands[i].p2.x);
        finish := s.IndexOf(autobands[i].p2.y);
      end;
      if m_autobandType=1 then
      begin
        autobands[i].p2 := m_bandlist[i];
        start := s.IndexOf(autobands[i].p2.x);
        finish := s.IndexOf(autobands[i].p2.y);
      end;
    end
    else
    begin
      if bands[i].bandType = c_bandType_phis then
      begin
        start := s.IndexOf(bands[i].p2.x);
        finish := s.IndexOf(bands[i].p2.y);
      end
      else
      begin
        if bands[i].bandType = c_bandType_trig then
        begin
          tr := mng.getTrig(bands[i].t1);
          if tr <> nil then
          begin
            v := tr.GetTime(src) + bands[i].shift1;
            start := s.IndexOf(v);
            bands[i].p2.x := v;
          end;
          tr := mng.getTrig(bands[i].t2);
          if tr <> nil then
          begin
            v := tr.GetTime(src) + bands[i].shift2;
            finish := s.IndexOf(v);
            bands[i].p2.y := v;
          end;
        end
        else
        begin
          start := round(bands[i].p2.x);
          finish := round(bands[i].p2.y);
        end;
      end;
    end;
    error:=0;
    if finish - start < 1 then
    begin
      error := c_Interval_Error;
    end;
    res[i].error:=(error=c_Interval_Error);
    if not res[i].error then
    begin
      sInterval := winpos.GetInterval(s, start, finish - start) as iwpsignal;
      res[i] := RunStats(sInterval, self);
      res[i].Vx1 := sInterval.GetY(0);
      res[i].Vx2 := sInterval.GetY(sInterval.size);
      res[i].min := sInterval.MinY;
      for j := 0 to sInterval.size - 1 do
      begin
        if sInterval.GetY(j) = sInterval.MinY then
        begin
          res[i].xMin := sInterval.getx(j);
          break;
        end;
      end;
      for j := 0 to sInterval.size - 1 do
      begin
        if sInterval.GetY(j) = sInterval.MaxY then
        begin
          res[i].xMax := sInterval.getx(j);
          break;
        end;
      end;
      res[i].max := sInterval.MaxY;
    end
    else
    begin

    end;
  end;
  // ������� ������ ��� ����������
  result := iwpsignal(WP.CreateSignalXY(VT_R8, VT_R8));
  // ������ ������� - ����� ����� * ����� ������
  result.size := bcount * opts.Count;
  result.sname := s.sname + '_Report';

  ColCount := getActiveOptsCount;
  for i := 0 to bcount - 1 do
  begin
    rec := res[i];
    if res[i].error then
    begin
      for j := 0 to opts.Count - 1 do
        result.SetY(i * opts.Count + j, 0);
    end
    else
    begin
      for j := 0 to opts.Count - 1 do
      begin
        opt := cOptRecord(opts.Objects[j]);
        // ������� ���������� ������ ��������� � �������� ���������� � ������������!!!
        if opt.name = 'Vx1' then
          result.SetY(i * opts.Count + j, rec.Vx1);
        if opt.name = 'Vx2' then
          result.SetY(i * opts.Count + j, rec.Vx2);
        if opt.name = 'M' then
          result.SetY(i * opts.Count + j, rec.M);
        if opt.name = 'D' then
          result.SetY(i * opts.Count + j, rec.D);
        if opt.name = 'RMS' then
          result.SetY(i * opts.Count + j, rec.RMS);
        if opt.name = 'R' then
          result.SetY(i * opts.Count + j, rec.R);
        if opt.name = 'E' then
          result.SetY(i * opts.Count + j, rec.E);
        if opt.name = 'A3' then
          result.SetY(i * opts.Count + j, rec.A3);
        if opt.name = 'A4' then
          result.SetY(i * opts.Count + j, rec.A4);
        if opt.name = 'Xmin' then
          result.SetY(i * opts.Count + j, rec.xMin);
        if opt.name = 'min' then
          result.SetY(i * opts.Count + j, rec.min);
        if opt.name = 'Xmax' then
          result.SetY(i * opts.Count + j, rec.xMax);
        if opt.name = 'max' then
          result.SetY(i * opts.Count + j, rec.max);
        if opt.name = 'mag1' then
        begin
          result.SetX(i * opts.Count + j, rec.f1);
          result.SetY(i * opts.Count + j, rec.mag1);
        end;
        if opt.name = 'dekr' then
          result.SetY(i * opts.Count + j, rec.dekr);
        if opt.estType <> '' then
        begin
          bcount := length(rec.extA);
          if length(rec.extA) > 0 then
          begin
            y := rec.extA[j - defaultCount].y;
            x := rec.extA[j - defaultCount].x;
            // i  ������� �� ������� + j - ����� ������
            result.SetY(i * opts.Count + j, y);
            result.SetX(i * opts.Count + j, x);
          end;
        end;
      end;
    end;
  end;
  folder := '/Signals/rpt/' + Datetostr(Now);
  // � ���� folder=Signals/����������/ � s.sname=3- 1
  D := winpos.Link(folder, result.sname, result);

  if firstsignal then
  begin
    mng.doAddNode(folder);
    // ������� getwpsignal(iwpsignal) �� ������� �.�. iwpsignal ���������� ��� �������� �� �������� � ����
    sig := mng.GetWPSignal(result);
    ressrc := mng.GetSrcBySignal(sig);
  end
  else
  begin
    isig := TypeCastToIWSignal(D);
    if ressrc.find(isig.sname, ind) then
    begin
      sig := ressrc.getSignalObj(isig.sname);
    end
    else
    begin
      sig := ressrc.CreateSignal(D);
    end;
  end;
  AddResult(sig, src, s.sname, res);
end;

procedure TExtOperRpt.ClearResults;
var
  i: integer;
  sigRpt: cRptSignal;
begin
  for i := 0 to resSignals.Count - 1 do
  begin
    sigRpt := cRptSignal(resSignals.Objects[i]);
    sigRpt.destroy;
  end;
  resSignals.clear;
end;

procedure TExtOperRpt.AddResult(s: cwpsignal; src: csrc; p_name: string; resdata:array of RptSct);
var
  sigRpt: cRptSignal;
  i, c: integer;
  find: boolean;
begin
  sigRpt := cRptSignal.create;
  c:=length(resdata);
  setlength(sigRpt.resData, c);
  for I := 0 to c - 1 do
  begin
    sigRpt.resData[i]:=resdata[i];
  end;

  sigRpt.name := p_name;
  sigRpt.s := s;
  sigRpt.src := src;
  resSignals.AddObject(s.Name, sigRpt);
  find := false;
  // ������ ���������� ���������� ������
  for i := 0 to srcList.Count - 1 do
  begin
    if srcList.Objects[i] = src then
    begin
      find := true;
    end;
  end;
  if not find then
    srcList.AddObject(src.name, src);
end;

procedure TExtOperRpt.setSmpOpts(str: string);
begin
  m_spmOpts := str;
end;

function TExtOperRpt.getSmpOpts: string;
begin
  result := m_spmOpts;
end;

function TExtOperRpt.GetResult(i: integer): cwpsignal;
begin
  result := cRptSignal(resSignals.Objects[i]).s;
end;

function TExtOperRpt.getBandcount: integer;
begin
  if m_autoBand then
    result := length(autobands)
  else
    result := length(bands);
end;

function TExtOperRpt.getBand(i: integer): tband;
begin
  if m_autoBand then
  begin
    result := autobands[i];
  end
  else
  begin
    result := bands[i];
  end;
end;

function TExtOperRpt.GetResultBySrcSignal(s: cwpsignal): cwpsignal;
var
  i: integer;
  rptSig: cRptSignal;
  sObj: cwpsignal;
begin
  for i := 0 to resSignals.Count - 1 do
  begin
    rptSig := cRptSignal(resSignals.Objects[i]);
    sObj := GetResultSrcSignal(rptSig);
    if sObj = s then
    begin
      result := rptSig.s;
    end;
  end;
end;

function TExtOperRpt.GetResultSrcSignal(i: integer): cwpsignal;
var
  src: csrc;
begin
  src := cRptSignal(resSignals.Objects[i]).src;
  result := src.getSignalObj(cRptSignal(resSignals.Objects[i]).name);
end;

function TExtOperRpt.GetResultSrcSignal(res: cRptSignal): cwpsignal;
var
  src: csrc;
begin
  src := res.src;
  result := src.getSignalObj(res.name);
end;

procedure TExtOperRpt.EvalBandsByChannel(s: cwpsignal);
var
  i, index:integer;
  v,lastVal, dur:double;
begin
  if s=nil then
  begin
    m_AutoBCount:=0;
    exit;
  end;
  if s=m_AutoBChannelSig then
  begin
    exit
  end
  else
  begin
    m_AutoBCount:=0;
    m_AutoBChannelSig:=s;
  end;
  m_AutoBChannel:=s.name;
  lastVal:=s.Signal.GetY(0);
  m_bandlist[0].x:=s.Signal.minx+m_autoBOffset1;
  m_bandlist[0].y:=0;
  for I := 1 to s.Signal.size - 1 do
  begin
    v:=s.Signal.GetY(i);
    if abs(v-lastval)>m_autoBThreshold then
    begin
      lastval:=v;
      m_AutoBCount:=m_AutoBCount+1;
      if (m_AutoBCount)>1 then
      begin
        m_bandlist[m_AutoBCount-1].x:=m_bandlist[m_AutoBCount-2].y+2*m_autoBOffset1;
      end;
      m_bandlist[m_AutoBCount-1].y:=s.Signal.GetX(i)-m_autoBOffset2;
      dur:=m_bandlist[m_AutoBCount-1].y-m_bandlist[m_AutoBCount-1].x;
      if dur>0 then
      begin
        // ��������� lastval
        index:=s.Signal.indexof(m_bandlist[m_AutoBCount-1].x);
        lastval:=s.Signal.gety(index);
        if m_AutoBCount>length(m_bandlist) then
        begin
          setlength(m_bandlist, length(m_bandlist)+500);
        end;
      end
      else
      begin
        // ������� ������
        m_AutoBCount:=m_AutoBCount-1;
      end;
    end
    else
    begin
      if i=s.Signal.size - 1 then
      begin
        inc(m_AutoBCount);
        if m_AutoBCount>1 then
        begin
          m_bandlist[m_AutoBCount-1].x:=m_bandlist[m_AutoBCount-2].y+2*m_autoBOffset1;
          m_bandlist[m_AutoBCount-1].y:=s.Signal.GetX(i)-m_autoBOffset2;
        end
        else
        begin
          m_bandlist[m_AutoBCount-1].x:=s.Signal.GetX(0);
          m_bandlist[m_AutoBCount-1].y:=s.Signal.GetX(i);
        end;
      end;
    end;
  end;
end;

procedure TExtOperRpt.Exec(const psrc1, psrc2: IDispatch;
  out pdst1, pdst2: IDispatch); safecall;
var
  s, sInterval, dst: iwpsignal;
  i, start, finish, bcount: integer;
  srcdir: csrc;
begin
  inherited;
  error := false;
  srcdir := mng.GetSrcBySignal(psrc1);
  s := psrc1 as iwpsignal;

  pdst1 := eval(s);

  // if  proccount>0 then
  // begin
  winpos.Refresh;
  winpos.DoEvents;
  winpos.AddTextInLog(RptRegName, props, true);
  // end;
end;

function cOptRecord.getDsc: string;
begin
  if estType = '' then
  begin
    result := dsc;
    exit;
  end;
  if estType = c_estType_A1 then
  begin
    result := 'F1=' + floattostr(band.x) + ' F2=' + floattostr(band.y);
  end;
  if estType = c_estType_Rms then
  begin
    result := 'F1=' + floattostr(band.x) + ' F2=' + floattostr(band.y);
  end;
  if estType = c_estType_N then
  begin
    result := 'T1=' + floattostr(band.x) + ' T2=' + floattostr(band.y);
  end;
  if estType = c_estType_SpmMax then
  begin
    result := 'T=' + floattostr(band.x) + ' FFTNum=' + floattostr(iTag);
  end;
end;

constructor cOptRecord.create;
begin
  estType := '';
  size := 1;
  dyn := false;
end;

destructor cOptRecord.destroy;
begin
  size := 0;
end;

initialization

// TAutoObjectFactory.create(ComServer, TExtOperRpt, CLASS_ExtOperRpt,
// ciSingleInstance, tmApartment);

end.
