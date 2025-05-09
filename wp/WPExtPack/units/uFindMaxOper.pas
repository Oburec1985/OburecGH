unit uFindMaxOper;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, Forms, ActiveX, WPExtPack_TLB, Winpos_ole_TLB, StdVcl, PosBase,
  uFindMaxForm, uWPProc, classes, uCommonTypes, uWPProcServices, sysutils, utrend,
  uSetList, math, uWPEvents, u2DMath, uCommonMath, uWPOpers, uWPServices
  // ,dialogs
  ;

type
  TUnits = (u_Abs, u_percent, u_10Lg, u_20Lg);

  tBand = class
  public
    btype:integer;
    // ������ ����� ������
    pl:tlist;
    // ������ ������������� ���������
    PosRes:boolean;
    units: TUnits;
  public
    procedure cleardata;
    constructor create;
    destructor destroy;
    function addpoint(x,y:double):integer;overload;
    function addpoint(p:point2d):integer;overload;
    function count:integer;
    procedure delpoint(i:integer);
    function GetP2d(i:integer):cpoint2d;
    function GetP2(i:integer):point2;
    procedure Setpoint(i:integer; newpos:point2d);overload;
    procedure Setpoint(i:integer; x,y:double);overload;
    function getLevel(x: double; var success:boolean): double;
  end;

  cResRec = class
  public
    // ���������� �����
    p: point2d;
    // ������ �������
    i: integer;
  end;

  // �������� �� ����� ������ �������� ��������� (�� �������� �� ������
  // ������� ����� �������). ������ � ������� �������� ��������� �����
  TExtOperAmpFind = class(TAutoObject, IWPExtOper)
  public
    props: string;
    ResFolder: string;
  protected
    frm: tFindMaxForm;
    mng: cWPObjmng;
    // ��� ���������� ��������� ���� �������� ������ ����� ������
    // ��������� � ����� ��� ����������� ��������� (campFindSignal)
  public
    results: tstringlist;
    bands: array of tBand;
  protected

    procedure GetError(out pnerrcode: integer; out perrstr: WideString); safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
    procedure OnSetup(hwndparent: integer; out phwnd: integer); safecall;
    procedure Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);
      safecall;
    procedure clearBands;
    function processBand(s: iwpsignal; b:tBand):iwpsignal;
    // �������
    procedure OnAddLine(obj: tobject);
  public
    procedure doAddLine(str: string; hline: integer);
    procedure Execute(const psrc1: IDispatch);
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure SetPropStr(const str: WideString); safecall;
    procedure linc(p_mng: cWPObjmng);
    Constructor create;
    destructor destroy;
  end;

function GetPosLevel(b: tBand; x: double; s: iwpsignal): double;
function GetNegLevel(b: tBand; x: double; s: iwpsignal): double;
function GetTBandFromStr(str:string):tband;

const
  FindMaxRegName = '����� �����������';

implementation

uses
  ComServ;


function GetTBandFromStr(str: string): tband;
var
  s: string;
  b: tband;
  x, y: double;
  I, ind, count: Integer;
  pars: tStringList;
begin
  b := tband.create;
  pars := ParsStrParamExt(str, ';', '"');
  // bType;Units;PosRes;pCount;Data
  s := GetParsValue(pars, 'bType');
  if s = '_' then
  begin
    b.destroy;
    result := nil;
    exit;
  end;
  b.btype := strtoint(s);
  s := GetParsValue(pars, 'PosRes');
  if s = '_' then
  begin
    b.destroy;
    result := nil;
    exit;
  end;
  b.PosRes := StrToBool(s);
  s := GetParsValue(pars, 'Pcount');
  if s = '_' then
  begin
    b.destroy;
    result := nil;
    exit;
  end;
  count := strtoint(s);
  s := GetParsValue(pars, 'Data');
  ind:=0;
  for I := 0 to count - 1 do
  begin
    str := GetSubString(s, ';', ind + 1, ind);
    if ind=-1 then
      break;
    x := strtoFloatExt(str);
    if ind=-1 then
      break;
    str := GetSubString(s, ';', ind + 1, ind);
    y := strtoFloatExt(str);
    b.AddPoint(x, y);
  end;
  pars.destroy;
  result := b;
end;

constructor tband.create;
begin
  pl:=TList.Create;
end;

destructor tband.destroy;
begin
  cleardata;
  pl.destroy;
end;

function tBand.getLevel(x: double; var success:boolean): double;
var
  ind:integer;
  I: Integer;
  p1, p2:point2;
begin
  p1:=GetP2(0);
  for I := 1 to Count - 1 do
  begin
    p2:=GetP2(i);
    if x>p1.x then
    begin
      if x<p2.x then
      begin
        result:=EvalLineY(x, p1, p2);
        exit;
      end;
    end;
    p1:=p2;
  end;
end;

procedure tband.cleardata;
var
  I: Integer;
  cp:cpoint2d;
begin
  for I := 0 to pl.Count - 1 do
  begin
    cp:=cpoint2d(pl.Items[i]);
    cp.Destroy;
  end;
  pl.clear;
end;

function tband.addpoint(p:point2d):integer;
var
  cp:cpoint2d;
begin
  cp:=cpoint2d.Create;
  cp.x:=p.x;
  cp.y:=p.y;
  result:=pl.Add(cp);
end;

function tband.count:integer;
begin
  result:=pl.Count;
end;

function tband.addpoint(x,y:double):integer;
var
  cp:cpoint2d;
begin
  cp:=cpoint2d.Create;
  cp.x:=x;
  cp.y:=y;
  result:=pl.Add(cp);
end;

procedure tband.delpoint(i:integer);
var
  cp:cpoint2d;
begin
  cp:=cpoint2d(pl.Items[i]);
  cp.Destroy;
  pl.Delete(i);
end;

function tband.GetP2d(i:integer):cpoint2d;
begin
  result:=cpoint2d(pl.Items[i]);
end;

function tband.GetP2(i:integer):point2;
var
  p:cpoint2d;
begin
  p:=GetP2d(i);
  result.x:=p.x;
  result.y:=p.y;
end;

procedure tband.Setpoint(i:integer; newpos:point2d);
var
  p:cpoint2d;
begin
  p:=GetP2d(i);
  p.x:=newpos.x;
  p.y:=newpos.y;
end;

procedure tband.Setpoint(i:integer; x,y:double);
var
  p:cpoint2d;
begin
  p:=GetP2d(i);
  p.x:=x;
  p.y:=y;
end;

procedure TExtOperAmpFind.clearBands;
var
  i: integer;
  b: tBand;
begin
  for i := 0 to length(bands) - 1 do
  begin
    b := bands[i];
    b.destroy;
  end;
  setlength(bands, 0);
end;

Constructor TExtOperAmpFind.create;
begin
  results := tstringlist.create;
  results.Sorted := true;
end;

destructor TExtOperAmpFind.destroy;
begin
  frm.destroy;
  results.destroy;
  mng.Events.removeEvent(OnAddLine, E_OnAddLine);
end;

procedure TExtOperAmpFind.linc(p_mng: cWPObjmng);
begin
  mng := p_mng;
  mng.Events.AddEvent('TExtOperAmpFind_addLine', E_OnAddLine, OnAddLine);
end;

procedure TExtOperAmpFind.Execute(const psrc1: IDispatch);
var
  d: IDispatch;
begin
  Exec(psrc1, psrc1, d, d);
end;

procedure TExtOperAmpFind.OnAddLine(obj: tobject);
begin
  doAddLine(mng.m_str, mng.m_hline);
end;

procedure TExtOperAmpFind.doAddLine(str: string; hline: integer);
var
  i: integer;
  x, y: double;
begin
  begin
    // 0 - lab_single (�� ���� �����)
    //for i := 0 to s.dst.Count - 1 do
    //begin
      // ������������� ����
      // mng.GraphApi.AddLabel(hline,0, x, 100*(x/(s.src.signal.MaxX-s.src.signal.MinX)),5,' ');
    //  mng.GraphApi.AddLabel(hline, 0, x, 5, 5, ' ');
    //  ResFolder := '/Signals/FindExt/' + datetostr(now);
    //end;
  end;
end;

function GetPosLevel(b: tBand; x: double; s: iwpsignal): double;
var
  r, max, min: double;
begin
  max := s.MaxY;
  min := s.MinY;
  r := max - min;

  if b.units = u_Abs then
  begin
    //result := EvalLineYd(x, p2d(b.f1, b.LevelPos1), p2d(b.f2, b.LevelPos2));
  end;
  if b.units = u_percent then
  begin
    //result := EvalLineYd(x, p2d(b.f1, b.LevelPos1), p2d(b.f2, b.LevelPos2));
    result := r * (result / 100) + min;
  end;
  if b.units = u_10Lg then
  begin
    //result := EvalLineYd(x, p2d(b.f1, b.LevelPos1), p2d(b.f2, b.LevelPos2));
    result := r * (Power(10, result / 10));
  end;
  if b.units = u_20Lg then
  begin
    //result := EvalLineYd(x, p2d(b.f1, b.LevelPos1), p2d(b.f2, b.LevelPos2));
    result := r * (Power(10, result / 20));
  end;
end;

function GetNegLevel(b: tBand; x: double; s: iwpsignal): double;
var
  r: double;
begin
  if b.units = u_Abs then
  begin
    //result := EvalLineYd(x, p2d(b.f1, b.LevelNeg1), p2d(b.f2, b.LevelNeg2));
    result := result;
  end;
  if b.units = u_percent then
  begin
    r := s.MaxY - s.MinY;
    //result := EvalLineYd(x, p2d(b.f1, b.LevelNeg1), p2d(b.f2, b.LevelNeg2));
    result := r * (result / 100) + s.MinY;
  end;
  if b.units = u_10Lg then
  begin
    //result := EvalLineYd(x, p2d(b.f1, b.LevelNeg1), p2d(b.f2, b.LevelNeg2));
    result := r * (Power(10, result / 10));
  end;
  if b.units = u_20Lg then
  begin
    //result := EvalLineYd(x, p2d(b.f1, b.LevelNeg1), p2d(b.f2, b.LevelNeg2));
    result := r * (Power(10, result / 20));
  end;
end;

// ������� ����������� ����������
function bPosMax(b: tBand; val, x: double; s: iwpsignal): boolean;
begin
  result := false;
  if val > GetPosLevel(b, x, s) then
    result := true;
end;

// ������� ����������� ����������
function bNegMax(b: tBand; val, x: double; s: iwpsignal): boolean;
begin
  result := false;
  if val < GetPosLevel(b, x, s) then
    result := true;
end;

Function GetNoiseThreshPos(val, range: double; b: tBand): double;
begin
  if b.units = u_Abs then
  begin
    //result := val - b.NoisePos;
  end;
  if b.units = u_percent then
  begin
    //result := val - range * (b.NoisePos / 100);
  end;
end;

Function GetNoiseThreshNeg(val, range: double; b: tBand): double;
begin
  if b.units = u_Abs then
  begin
    //result := val + -range * (b.NoiseNeg / 100);
  end;
end;

function TExtOperAmpFind.processBand(s: iwpsignal; b: tBand):iwpsignal;
var
  // ������ � ����� ������
  i, // ���� �� �������
  j, // ���� �� ������ � �������
  starti, endi:integer;
  // ������ ������ � �����
  p1, p2:point2;
  v, level, maxX, maxY, x:double;
  // ������ ��������� ��������
  findmax:boolean;
  // ������ � ������� ��� �����������
  list:tlist;
  cp:cpoint2d;
begin
  p1:=b.GetP2(0);
  // ������ � ������� ��� �����������
  list:=tlist.Create;
  result:=nil;
  for I := 1 to b.count - 1 do
  begin
    p2:=b.GetP2(i);
    starti:=s.IndexOf(p1.x);
    endi:=s.IndexOf(p2.x);
    if starti<endi then
    begin
      findmax:=false;
      for j := starti to endi do
      begin
        v:=s.GetY(j);
        x:=s.GetX(j);
        level:=EvalLineY(x, p1, p2);
        if v>level then
        begin
          if (v>maxY) or (not findmax) then
          begin
            maxY:=v;
            maxX:=x;
          end;
          findmax:=true;
        end
        else
        begin
          if findmax then
          begin
            cp:=cpoint2d.Create;
            cp.x:=maxX;
            cp.y:=maxY;
            List.add(cp);
            findmax:=false;
          end;
        end;
      end;
    end
    else
      break;
    p1:=p2;
  end;
  if List.count>0 then
  begin
    result:=iwpsignal(wp.CreateSignalXY(5, 5));
    result.size:=list.Count;
    result.SName := s.SName + '_AFlg';
    // ������ ����������
    for I := 0 to List.Count - 1 do
    begin
      cp:=list.Items[i];
      result.SetX(i,cp.x);
      result.SetY(i,cp.y);
    end;
  end;
  // ������ ����������
  for I := 0 to List.Count - 1 do
  begin
    cp:=list.Items[i];
    cp.Destroy;
  end;
  list.Destroy;
end;

procedure TExtOperAmpFind.Exec(const psrc1, psrc2: IDispatch;
  out pdst1, pdst2: IDispatch);
var
  isig,dst: iwpsignal;
  i: integer;
  folder: string;
  src:iwpnode;
  p2:point2d;
begin
  inherited;
  isig:= psrc1 as iwpsignal;
  for i := 0 to length(bands) - 1 do
  begin
    dst:=processBand(isig, bands[i]);
  end;
  if dst=nil then
    exit;
  src:=findNode(isig);
  src:=src.Parent as iwpnode;
  folder:=src.AbsolutePath;
  // ���������� ����������
  ResFolder := folder+'/Flags/';
  folder := ResFolder;
  // � ���� folder=Signals/����������/ � s.sname=3- 1
  winpos.Link(folder, dst.SName, dst);
  isig.SetProperty('Flags',dst.SName);


  winpos.refresh;
  pdst1 := dst;
  pdst2 := dst;
  winpos.AddTextInLog(FindMaxRegName, props, true);
  winpos.DoEvents;
end;

procedure TExtOperAmpFind.GetError(out pnerrcode: integer;
  out perrstr: WideString);
begin
  pnerrcode := 0;
end;

procedure TExtOperAmpFind.GetPropStr(out pstr: WideString);
begin
  pstr := props;
end;

procedure TExtOperAmpFind.OnApply;
var
  Code: integer;
begin
  // Val(frm.ValPower.Text, dblPow, Code);
end;

procedure TExtOperAmpFind.OnClose;
begin
  frm.destroy;
  FindMaxForm := nil;
end;

procedure TExtOperAmpFind.OnSetup(hwndparent: integer; out phwnd: integer);
begin
  if not Assigned(FindMaxForm) then
  begin
    frm := tFindMaxForm.create(nil);
    frm.mng := mng;
    frm.eo := self;
  end;
  frm.ShowModal;
  phwnd := frm.Handle;
end;

procedure TExtOperAmpFind.SetPropStr(const str: WideString);
var
  stra: AnsiString;
  opts: tstringlist;
  BandCount, i: integer;
  SName, lstr: string;
  b: tBand;
begin
  clearBands;
  props := DeleteSpace(str);
  stra := props;
  // ������ ��������� ���������
  opts := ParsStrParamExt(stra, ';', '"');
  // ����� ����� �������
  BandCount := strtoint(GetParsValue(opts, 'BandCount'));
  setlength(bands, BandCount);
  for i := 0 to BandCount - 1 do
  begin
    lstr:=GetParsValue(opts, inttostr(i));
    b :=GetTBandFromStr(lstr);
    bands[i]:=b;
  end;
  // ������� ��������� �������
  DelPars(opts);
end;



function ResComparator(p1, p2: pointer): integer;
begin
  if cResRec(p1).p.x > cResRec(p2).p.x then
  begin
    result := 1;
  end
  else
  begin
    if cResRec(p1).p.x < cResRec(p2).p.x then
    begin
      result := -1;
    end
    else
    begin
      result := 0;
    end;
  end;
end;



initialization

TAutoObjectFactory.create(ComServer, TExtOperAmpFind, Class_ExtOperAmpFind,
  ciSingleInstance, tmApartment);

end.
