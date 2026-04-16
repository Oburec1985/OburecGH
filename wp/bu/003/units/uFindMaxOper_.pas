unit uFindMaxOper_;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, Forms, ActiveX, WPExtPack_TLB, Winpos_ole_TLB, StdVcl, PosBase,
  uFindMaxForm, uWPProc, classes, uCommonTypes, uWPservices, sysutils, utrend,
  uSetList, math;

type
  TUnits = (u_Abs, u_percent, u_10Lg, u_20Lg);

  tBand = class
    LevelPos, LevelNeg, NoisePos, NoiseNeg, f1, f2:double;
    PosRes, NegRes,
    // поиск амплитуды как отклонение от среднего а не абсолютное значение
    MO_Offset:boolean;
    units:tunits;
  end;

  cResRec = class
    // координаты точки
    p:point2d;
    // индекс вершины
    i:integer;
    positive:boolean;
  end;

  cResSignal = class(cSetList)
  public
    // сигнал которому принадлежит результат
    name:string;
  public
    procedure deletechild(node:pointer);override;
    function getRec(i:integer):cresrec;
    procedure CopyP(res:cresSignal);
    function Copy:cresSignal;
    procedure clear;
    procedure destroyItem(i:integer);
    constructor create;override;
  end;

  cResultSignal = class
    // сигнал для которого посчитаны маркеры
    src:cwpsignal;
    // сигнал с маркерами
    dst:cwpsignal;
  end;

  cAmpFindSignal = class(cWPSignal)
  public
    res:cresSignal;
  public
    destructor destroy;
  end;

  // алгоритм не знает списка сигналов обработки (он получает по одному
  // сигналу перед вызовом). Работу с группой сигналов реализует форма
  TExtOperAmpFind = class(TAutoObject, IWPExtOper)
  public
    props:string;
    ResFolder:string;
  protected
    frm:tFindMaxForm;
    mng:cWPObjmng;
    // при выполнении алгоритма сюда попадают данные какой сигнал
    // обработан и какой ему сопоставлен результат (campFindSignal)
    results:tstringlist;
  public
    bands:array of tband;
    res:cResSignal;
  protected
    procedure clearResults;

    procedure GetError(out pnerrcode: Integer; out perrstr: WideString); safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
    procedure OnSetup(hwndparent: Integer; out phwnd: Integer); safecall;
    procedure Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch); safecall;
    procedure clearBands;
    procedure processBand(s:iwpsignal;b:tband; res:cResSignal);
  public
    procedure Execute(const psrc1: IDispatch);
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure SetPropStr(const str: WideString); safecall;
    procedure linc(p_mng:cWPObjmng);
    function AddSignal(s:iwpNode):cAmpFindSignal;overload;
    function AddSignal(s:iwpSignal):cAmpFindSignal;overload;
    Constructor create;
    destructor destroy;
  end;

function GetPosLevel(b:tband;x:Double; s:iwpsignal):double;
function GetNegLevel(b:tband;x:Double;s:iwpsignal):double;

const
  FindMaxRegName = 'Поиск экстремумов';

implementation

uses
  ComServ;


procedure TExtOperAmpFind.clearResults;
begin

end;

function TExtOperAmpFind.AddSignal(s:iwpNode):cAmpFindSignal;
begin
  result:=nil;
  if IsSignal(s) then
  begin
    result:=cAmpFindSignal.Create(s);
  end;
end;

function TExtOperAmpFind.AddSignal(s:iwpSignal):cAmpFindSignal;
begin
  result:=AddSignal(TypeCastToIWNode(winpos.getnode(s)));
end;

procedure TExtOperAmpFind.clearBands;
var
  i:integer;
  b:tband;
begin
  for I := 0 to length(bands) - 1 do
  begin
    b:=bands[i];
    b.Destroy;
  end;
  setlength(bands,0);
end;

Constructor TExtOperAmpFind.create;
begin
  res:=cResSignal.Create;
  results:=csetlist.Create;
end;

destructor TExtOperAmpFind.destroy;
begin
  frm.Destroy;
  res.destroy;
  results.destroy;
end;

procedure TExtOperAmpFind.linc(p_mng:cWPObjmng);
begin
  mng:=p_mng;
end;

procedure TExtOperAmpFind.Execute(const psrc1: IDispatch);
var
  d:idispatch;
begin
  exec(psrc1,psrc1,d,d);
end;

function GetPosLevel(b:tband;x:Double; s:iwpsignal):double;
var
  r, mo, max, min:double;
begin
  max:=s.MaxY;
  min:=s.MinY;
  r:=max-min;
  if b.MO_Offset then
  begin
    mo:=getMO(s);
  end;
  if b.units=u_Abs then
  begin
    result:=b.LevelPos;
  end;
  if b.units=u_percent then
  begin
    result:=r*(b.LevelPos/100)+min;
  end;
  if b.units=u_10Lg then
  begin
    result:=r*(Power(10, b.LevelPos/10));
  end;
  if b.units=u_20Lg then
  begin
    result:=r*(Power(10, b.LevelPos/20));
  end;
end;

function GetNegLevel(b:tband;x:Double;s:iwpsignal):double;
var
  r:double;
begin
  if b.units=u_Abs then
  begin
    result:=b.LevelNeg;
  end;
  if b.units=u_percent then
  begin
    r:=s.MaxY-s.MinY;
    result:=r*(b.LevelNeg/100)+s.MinY;
  end;
  if b.units=u_10Lg then
  begin
    result:=r*(Power(10, b.LevelNeg/10));
  end;
  if b.units=u_20Lg then
  begin
    result:=r*(Power(10, b.LevelNeg/20));
  end;
end;
// условие позитивного экстремума
function bPosMax(b:tband;val,x:Double;s:iwpsignal):boolean;
begin
  result:=false;
  if val>GetPosLevel(b,x,s) then
    result:=true;
end;

// условие позитивного экстремума
function bNegMax(b:tband;val,x:Double;s:iwpsignal):boolean;
begin
  result:=false;
  if val<GetPosLevel(b,x,s) then
    result:=true;
end;

Function GetNoiseThreshPos(val, range:double;b:tband):double;
begin
  if b.units=u_Abs then
  begin
    result:=val-b.NoisePos;
  end;
  if b.units=u_percent then
  begin
    result:=val-range*(b.NoisePos/100);
  end;
end;

Function GetNoiseThreshNeg(val, range:double;b:tband):double;
begin
  if b.units=u_Abs then
  begin
    result:=val+-range*(b.NoiseNeg/100);
  end;
end;

procedure TExtOperAmpFind.processBand(s:iwpsignal;b:tband; res:cResSignal);
var
  // начало и конец полосы
  i, starti, endi,
  // индекс экстремума
  vali,vali_min,
  // тригер сброса поиска максимума
  loTrig1, hiTrig1, loTrig2, hiTrig2:integer;
  x,
  // текущее значение
  cur,
  // завершить локальный макс. по порогу шума
  noise, range:double;
  // Значение кот, потенциально может оказаться максимумов
  val, val_min:point2d;
  // включение определения максимума
  recval_pos,recval_neg:boolean;
  point:cResRec;
begin
  lotrig1:=0;
  hiTrig1:=0;
  lotrig2:=0;
  hiTrig2:=0;
  starti:=s.IndexOf(b.f1);
  endi:=s.IndexOf(b.f2);
  val.y:=s.MinY;
  val_min.y:=s.MaxY;
  range:=s.MaxY-val.y;
  recval_pos:=false;
  if starti=endi then
    exit;
  for i := starti to endi do
  begin
    x:=s.GetX(i);
    cur:=s.GetY(i);
    // ищем положительный максимум
    if bPosMax(b,cur,x,s) then
    begin
      if not recval_pos then
        hiTrig1:=i;
      recval_pos:=true;
      // обновляем максимум
      if cur>val.y then
      begin
        val.y:=cur;
        val.x:=x;
        vali:=i;
      end;
      if i=endi then
      begin
        if (vali<>hitrig1) and (vali<>hitrig2) then
        begin
          point:=cResRec.Create;
          point.p:=val;
          point.i:=vali;
          vali:=i;
          point.positive:=true;
          res.add(point);
          val.y:=s.MinY;
          hiTrig2:=vali;
          recval_pos:=false;
        end;
      end;
    end
    else
    // если значение меньше порога
    begin
      if recval_pos then
      begin
        // завершаем локальный максимум ЧТОБЫ ИСКАТЬ НОВЫЙ
        if cur<GetNoiseThreshPos(val.y,range,b) then
        begin
          //if (vali<>hitrig1) and (vali<>hitrig2) then
          if (vali<>hitrig2) then
          begin
            point:=cResRec.Create;
            point.p:=val;
            point.i:=vali;
            vali:=i;
            point.positive:=true;
            res.add(point);
            val.y:=s.MinY;
            hiTrig2:=vali;
            recval_pos:=false;
          end;
          if i=endi then
          begin
            if (vali<>hitrig1) and (vali<>hitrig2) then
            begin
              point:=cResRec.Create;
              point.p:=val;
              point.i:=vali;
              vali:=i;
              point.positive:=true;
              res.add(point);
              val.y:=s.MinY;
              hiTrig2:=vali;
              recval_pos:=false;
            end;
          end;
        end;
      end;
    end;
    // ------------------------------------------------------
    // ищем минимумы
    if bNegMax(b, s.GetY(i), x, s) then
    begin
      if not recval_neg then
        lotrig1:=i;
      recval_neg:=true;
      // обновляем максимум
      if cur<val_min.y then
      begin
        val_min.y:=cur;
        val_min.x:=x;
        vali_min:=i;
      end;
    end;
    if recval_neg then
    begin
      // завершаем локальный максимум
      if cur<GetNoiseThreshNeg(val.y, range, b) then
      begin
        //if (vali<>lotrig1) and (vali<>lotrig2) then
        if vali<>lotrig2 then
        begin
          point:=cResRec.Create;
          point.p:=val;
          point.i:=vali;
          vali:=i;
          point.positive:=false;
          res.add(point);
          recval_neg:=false;
          val.y:=s.MaxY;
          loTrig2:=vali;
        end;
      end;
    end;
  end;
end;

procedure TExtOperAmpFind.Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);
var
  src, dst : IWPSignal;
  i: Integer;
  rec:cResRec;
  hline, page, graph:integer;
  folder:string;
begin
  inherited;
  src:= psrc1 as IWPSignal;
  res.clear;
  for i := 0 to length(bands) - 1 do
  begin
    processBand(src, bands[i], res);
  end;
  // создаем страницу
  if res.Count<>0 then
  begin
    page:=mng.GraphApi.CreatePage;
    //graph:=mng.GraphApi.CreateGraph(page);
    graph:=mng.GraphApi.GetGraph(page, 0);
    // выкладываем сигнал на график
    hline:=mng.GraphApi.CreateLine(graph,mng.GraphApi.GetYAxis(graph, 0),src.instance);
    mng.GraphApi.SetXMinMax(graph, src.MinX, src.MaxX);
    mng.GraphApi.SetYAxisMinMax(mng.GraphApi.GetYAxis(graph, 0), src.MinY, src.MaxY+0.1*(src.MaxY-src.MinY));
  end
  else
  begin
    exit;
  end;
  dst:= iwpsignal(wp.CreateSignalXY(5,5));
  dst.size:=res.Count;
  dst.SName:=src.SName+'_AFlg';
  res.name:=dst.SName;
  // 0 - lab_single (на одну линию)
  for I := 0 to res.Count - 1 do
  begin
    rec:=res.getRec(i);
    dst.SetY(i,rec.p.y);
    dst.SetX(i,rec.p.x);
    // создаем метки
    if rec.positive then
    begin
      // устанавливаем флаг
      mng.GraphApi.AddLabel(hline,0,rec.p.x,100*(rec.p.x/(src.MaxX-src.MinX)),5,' ');
    end;
    ResFolder:='/Signals/FindExt/'+datetostr(now);
  end;
  folder:=ResFolder;
  //winpos.Link( 'Signals/', s.sname, s );
  // в виде folder=Signals/Результаты/ и s.sname=3- 1
  winpos.Link( folder, dst.sname, dst);
  winpos.Refresh;
  pdst1:= dst;
  pdst2:= dst;
  winpos.AddTextInLog(FindMaxRegName, props, true);
  WinPOS.DoEvents;
end;

procedure TExtOperAmpFind.GetError(out pnerrcode: Integer; out perrstr: WideString);
begin
  pnErrCode:=0;
end;

procedure TExtOperAmpFind.GetPropStr(out pstr: WideString);
begin
   pstr:=props;
end;

procedure TExtOperAmpFind.OnApply;
var Code  : Integer;
begin
   //Val(frm.ValPower.Text, dblPow, Code);
end;

procedure TExtOperAmpFind.OnClose;
begin
  frm.Destroy;
  FindMaxForm:=nil;
end;

procedure TExtOperAmpFind.OnSetup(hwndparent: Integer; out phwnd: Integer);
begin
  if not Assigned(FindMaxForm) then
  begin
    frm:=tFindMaxForm.Create(nil);
    frm.mng:=mng;
    frm.eo:=self;
  end;
  frm.ShowModal;
  phwnd:= frm.Handle;
end;

procedure TExtOperAmpFind.SetPropStr(const str: WideString);
var
  stra : AnsiString;
  opts:tstringlist;
  BandCount,I: Integer;
  sname:string;
  b:tband;
begin
  clearBands;

  props:=DeleteSpace(str);
  stra:= props;
  // парсим настройки алгоритма
  opts:=ParsStrParam(stra,',');
  // число полос сигнала
  BandCount:=strtoint(GetParsValue(opts,'BandCount'));
  setlength(bands, BandCount);
  for I := 0 to BandCount - 1 do
  begin
    b:=tBand.Create;
    bands[i]:=b;
    // минимум полосы по частоте
    sname:='bx_'+inttostr(i);
    bands[i].f1:=strtofloat(GetParsValue(opts,sname));
    // максимум полосы по частоте
    sname:='by_'+inttostr(i);
    bands[i].f2:=strtofloat(GetParsValue(opts,sname));
    // настройки детектора амплитуды
    sname:='L_pos_'+inttostr(i);
    bands[i].LevelPos:=strtofloat(GetParsValue(opts,sname));
    sname:='L_neg_'+inttostr(i);
    bands[i].LevelNeg:=strtofloat(GetParsValue(opts,sname));
    sname:='N_pos_'+inttostr(i);
    bands[i].NoisePos:=strtofloat(GetParsValue(opts,sname));
    sname:='N_neg_'+inttostr(i);
    bands[i].NoiseNeg:=strtofloat(GetParsValue(opts,sname));
    sname:='Units_'+inttostr(i);
    sname:=GetParsValue(opts,sname);
    if sname='10lg' then
    begin
      bands[i].Units:=u_10Lg;
    end;
    if sname='20lg' then
    begin
      bands[i].Units:=u_20Lg;
    end;
    if sname='Абс.' then
    begin
      bands[i].Units:=u_Abs;
    end;
    if sname='%' then
    begin
      bands[i].Units:=u_percent;
    end;
  end;
  // удаляем результат парсера
  DeleteParsResult(opts);
end;

procedure cressignal.CopyP(res:cresSignal);
var
  I: Integer;
  rec:cresrec;
begin
  res.clear;
  for I := 0 to Count - 1 do
  begin
    rec:=cResRec.Create;
    rec.p:=getRec(i).p;
    rec.i:=getRec(i).i;
    res.Add(rec);
  end;
end;

function cressignal.Copy:cresSignal;
var
  I: Integer;
  rec:cresrec;
begin
  result:=cResSignal.Create;
  result.name:=name;
  for I := 0 to Count - 1 do
  begin
    rec:=cResRec.Create;
    rec.p:=getRec(i).p;
    rec.i:=getRec(i).i;
    result.Add(rec);
  end;
end;

procedure cressignal.deletechild(node:pointer);
begin
  cresrec(node).Destroy;
end;

function cressignal.getRec(i:integer):cresrec;
begin
  if i<count then
  begin
    result:=cResRec(Items[i]);
  end
  else
    result:=nil;
end;

procedure cressignal.clear;
var
  I: Integer;
  s:cResRec;
begin
  for I := 0 to Count - 1 do
  begin
    s:=cresrec(Items[i]);
    s.Destroy;
  end;
  inherited clear;
end;

function ResComparator(p1,p2:pointer):integer;
begin
  if cResRec(p1).p.x>cResRec(p2).p.x then
  begin
    result:=1;
  end
  else
  begin
    if cResRec(p1).p.x<cResRec(p2).p.x then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;


constructor cressignal.create;
begin
  inherited;
  comparator:=ResComparator;
  destroydata:=true;
end;

procedure cressignal.destroyItem(i:integer);
var
  s:cResRec;
begin
  if (i>-1) and (i<Count) then
  begin
    s:=cresrec(Items[i]);
    s.Destroy;
    Delete(i);
  end;
end;

destructor cAmpFindSignal.destroy;
begin
  if res<>nil then
    res.destroy;
  inherited;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TExtOperAmpFind, Class_ExtOperAmpFind,
    ciSingleInstance, tmApartment);
end.
