unit uCounterFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uSpin, ComCtrls, uBtnListView, ExtCtrls,
  ComObj, types, ActiveX, WPExtPack_TLB, Winpos_ole_TLB,
  StdVcl, PosBase,
  uFindMaxForm, uWPProc, classes, uCommonTypes, uWPservices,  utrend,
  uSetList, math, uWPEvents, ComServ, uCommonMath,
  MathFunction,
  uMyMath,
  uWPOpers,
  uBaseObjMng,
  uWPProcServices,
  uComponentServises,
  Pathutils,
  u2DMath,
  complex,
  ap;

type
  LBRecord = class
    s:iwpsignal;
  end;

  TCounterOper = class;

  TCounterFrm = class(TForm)
    ThresholdLabel1: TLabel;
    ThresholdLabel2: TLabel;
    HiSE: TFloatSpinEdit;
    LoSE: TFloatSpinEdit;
    GroupBox1: TGroupBox;
    SignalsLV: TBtnListView;
    Panel2: TPanel;
    Button1: TButton;
    SearchSignal: TEdit;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    T1Se: TFloatSpinEdit;
    T2Se: TFloatSpinEdit;
    EvalBtn: TButton;
    AllTestBtn: TButton;
    CursorsBtn: TButton;
    procedure ApplyBtnClick(Sender: TObject);
    procedure SignalsLBClick(Sender: TObject);
    procedure SearchSignalChange(Sender: TObject);
    procedure AllTestBtnClick(Sender: TObject);
    procedure CursorsBtnClick(Sender: TObject);
    procedure T2SeChange(Sender: TObject);
  private
    m_oper: TCounterOper;
    useChange:boolean;
    procedure showSignals;
    function Selected: iwpSignal;
    function getsignal(i: integer): iwpsignal;
    function GetPropStr: string;
    Procedure SetPropStr(str: string);
    function GetNotifyStr(p_opts: string): string;
  public
    procedure link(eo: TCounterOper);
    function EditOper: string;
  end;


// алгоритм не знает списка сигналов обработки (он получает по одному
  // сигналу перед вызовом). Работу с группой сигналов реализует форма
  TCounterOper = class(TAutoObject, IWPExtOper)
  private
    m_mng: cBaseObjmng;
    m_Hi, m_Lo:double;
    T1, t2:double;
    // 0 - user; 1 - allTest; 2 - Cursors
    Ttype:integer;
  public
    procedure GetError(out pnerrcode: integer; out perrstr: WideString);safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
    procedure Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);safecall;
    procedure OnSetup(hwndparent: integer; out phwnd: integer); safecall;
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure SetPropStr(const str: WideString); safecall;
  public
    function GetPropStrF(out pstr: WideString):string;
    function Execute(const psrc1: IDispatch): boolean;
    procedure link(m:cbaseObjMng);
    procedure Setup;
    Constructor create;
    destructor destroy;
  end;

var
  CounterFrm: TCounterFrm;

const
  c_OperName = 'Counter';

implementation

{$R *.dfm}
uses
  uWpExtPack;

{$R *.dfm}

{ TExtCounter }

constructor TCounterOper.create;
begin
  m_Hi := 0.7;
  m_Lo := 0.3;
end;

destructor TCounterOper.destroy;
begin
  inherited;
end;

function TCounterOper.Execute(const psrc1: IDispatch): boolean;
var
  D: IDispatch;
begin
  result := true;
  Exec(psrc1, psrc1, D, D);
end;

procedure TCounterOper.Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);
var
  s, res: iwpsignal;
  i: integer;
  count: integer;
  val, max, min, mean, h,l, pp: double;
  wstr:widestring;
  // 0 - start, 1 - triggered , 2 end
  state:integer;
begin
  s := iwpsignal(psrc1);
  res := iwpsignal(wp.CreateSignal(vt_r8));
  res.StartX := s.StartX;
  res.DeltaX := s.DeltaX;
  res.size := s.size;
  mean:=GetMO(s);
  min:=s.MinY;
  max:=s.MaxY;
  pp:=max-min;
  h:=pp*m_hi+min;
  l:=pp*m_lo+min;

  count := 0;
  state:=0;

  for i := 0 to s.size - 1 do
  begin
    val := s.GetY(i) - mean;
    case state of
      0: //search
      begin
        if val>l then
        begin
          state:=1;
          if val>h then
          begin
            state:=2;
            inc(count);
          end;
        end;
      end;
      1:
      begin
        if val>h then
        begin
          state:=2;
          inc(count);
        end;
      end;
      2:
      begin
        if (val<l) then
        begin
          state:=0;
        end;
      end;
    end;
    res.SetY(i, count);
  end;

  wp.Link('/Signals/results', s.sname+'_'+'cnt',
          res as IDispatch);

  winpos.Refresh;
  GetPropStr(wstr);
  winpos.AddTextInLog(c_OperName, wstr, true);
  winpos.DoEvents;


  pdst1 := res as IDispatch;
  pdst2 := nil;
end;

procedure TCounterOper.GetError(out pnerrcode: integer; out perrstr: WideString);
begin
  pnerrcode := 0;
  perrstr := '';
end;

function TCounterOper.GetPropStrF(out pstr: WideString):string;
var
  wstr:WideString;
begin
  GetPropStr(pstr);
  result:=pstr;
end;

procedure TCounterOper.GetPropStr(out pstr: WideString);
var
  pars: tstringlist;
begin
  pars := tstringlist.Create;
  addParam(pars, 'Hi', floattostrex(m_hi,'.'));
  addParam(pars, 'Lo', floattostrex(m_lo,'.'));
  pstr := ParsToStr(pars);
  delpars(pars);
  pars.Destroy;
end;

procedure TCounterOper.SetPropStr(const str: WideString);
begin
  m_Hi := strtofloatext(GetParam(str, 'Hi'));
  m_Lo := strtofloatext(GetParam(str, 'Lo'));
end;

procedure TCounterOper.link(m: cbaseObjMng);
begin
  m_mng := m;
end;

procedure TCounterOper.OnApply;
begin
end;

procedure TCounterOper.OnClose;
begin
end;

procedure TCounterOper.OnSetup(hwndparent: integer; out phwnd: integer);
begin
  if CounterFrm=nil then
  begin
    CounterFrm := TCounterFrm.Create(nil);
    CounterFrm.link(self);
  end;
  CounterFrm.EditOper;
  phwnd := CounterFrm.Handle;
end;

procedure TCounterOper.Setup;
var
  h:integer;
begin
  OnSetup(0,h);
end;




function TCounterFrm.EditOper: string;
var
  res: integer;
  i: integer;
  s, interv: iwpsignal;
  iD: idispatch;
  str: widestring;
  rec: LBRecord;
  li: tlistitem;
  param: olevariant;
  t1t2:point2d;
begin
  showSignals;
  SetPropStr(m_oper.GetPropStrF(str));
  res := showmodal;
  if res = mrok then
  begin
    m_oper.SetPropStr(GetPropStr);
    m_oper.t1:=t1se.Value;
    m_oper.t2:=t1se.Value;
    for i := 0 to SignalsLV.items.count - 1 do
    begin
      li := SignalsLV.Items[i];
      if li.Checked then
      begin
        rec := LBRecord(li.data);
        s := rec.s;
        t1t2.x:=t1se.Value;
        t1t2.y:=t2se.Value;
        interv:=getinterval(s, t1t2);
        if s.DeltaX <> 0 then
        begin
          m_oper.Exec(interv, interv, iD, iD);
        end;
      end;
    end;
    str := GetNotifyStr(m_oper.GetPropStrF(str));
    param:=str;
    TExtPack(extPack).NotifyPlugin($000F0001, param);
  end;
end;

function TCounterFrm.GetNotifyStr(p_opts: string): string;
var
  i: integer;
  str, numstr: string;
  s1: iwpsignal;
  n: iwpnode;
begin
  result := 'o="/Operators/Counter";p="' + p_opts + '";';
  for I := 0 to SignalsLV.Items.Count - 1 do
  begin
    s1 := GetSignal(i);
    numstr := inttostr(i);
    str := numstr;
    if length(str) < 3 then
    begin
      while length(str) <> 3 do
      begin
        str := '0' + str;
      end;
    end;
    n := findNode(s1);
    result := result + 's1' + '_' + str + '="' + n.AbsolutePath + '";';
    result := result +
      'i1' + '_' + str + '=' + '0' + ';'
      + 'c1' + '_' + str + '=' + inttostr(s1.size) + ';'
      + 'd1' + '_' + str + '="' + '/Signals/results/' + s1.sname + '_cnt';
  end;
end;

function TCounterFrm.GetPropStr: string;
var
  pars: tstringlist;
begin
  pars := tstringlist.Create;
  addParam(pars, 'Hi', floattostrex(HiSE.Value/100, '.'));
  addParam(pars, 'Lo', floattostrex(LoSE.Value/100, '.'));
  result := ParsToStr(pars);
  delpars(pars);
  pars.Destroy;
end;

procedure TCounterFrm.SetPropStr(str: string);
begin
  if not checkstr(str) then
  begin
    str:='Hi=0.7, Lo=0.3';
  end;
  HiSE.Value := 100*strtofloatext(GetParam(str, 'Hi'));
  LoSE.Value := 100*strtofloatext(GetParam(str, 'Lo'));
end;


function TCounterFrm.getsignal(i: integer): iwpsignal;
var
  rec: lbrecord;
  li: tlistitem;
begin
  li := SignalsLV.Items[i];
  rec := lbrecord(li.data);
  result := rec.s;
end;

procedure TCounterFrm.link(eo: TCounterOper);
begin
  m_oper := eo;
  useChange:=true;
end;

procedure TCounterFrm.SearchSignalChange(Sender: TObject);
begin
  showSignals;
end;

function TCounterFrm.Selected: iwpSignal;
var
  rec: LBRecord;
  li: tlistitem;
begin
  li := SignalsLV.Selected;
  if li = nil then
    result := nil
  else
  begin
    rec := LBRecord(li.data);
    result := rec.s;
  end;
end;


procedure TCounterFrm.showSignals;
var
  n, ch:iwpnode;
  s:iwpsignal;
  li:tlistitem;
  I: Integer;
  rec:LBRecord;
  sname:string;
begin
  n:=getCurSrcInMainWnd;
  // очистка текущих записей
  for I := 0 to signalsLV.Items.Count - 1 do
  begin
    li:=signalsLV.Items[i];
    rec:=LBRecord(li.data);
    rec.Destroy;
  end;
  SignalsLV.Clear;

  for I := 0 to n.ChildCount - 1 do
  begin
    ch:=n.At(i) as iwpnode;
    if issignal(ch) then
    begin
      s:=TypeCastToIWSignal(ch);
      sname:=s.sname;
      if (pos(lowercase(SearchSignal.text), lowercase(sname))>0) or (SearchSignal.text='') then
      begin
        rec:=LBRecord.Create;
        rec.s:=s;
        li:=SignalsLV.Items.Add;
        li.Data:=rec;
        signalsLV.SetSubItemByColumnName('Signal',sname,li);
        if s.deltaX=0 then
          signalsLV.SetSubItemByColumnName('Fs','-', li)
        else
          signalsLV.SetSubItemByColumnName('Fs',formatstrnoe(1/s.DeltaX, 4),li);
      end;
    end;
  end;
  LVChange(signalsLV);
end;

procedure TCounterFrm.SignalsLBClick(Sender: TObject);
begin
  //EvalBtn.Enabled := Selected <> nil;
end;

procedure TCounterFrm.T2SeChange(Sender: TObject);
begin
  if useChange then
    m_oper.Ttype:=0;
end;

procedure TCounterFrm.AllTestBtnClick(Sender: TObject);
var
  n:iwpnode;
  p:point2d;
begin
  m_oper.Ttype:=1;
  useChange:=false;
  n:=getCurSrcInMainWnd;
  p:=GetStartStop(n);
  t1se.Value:=p.x;
  t2se.Value:=p.y;
  useChange:=true;
end;

procedure TCounterFrm.CursorsBtnClick(Sender: TObject);
var
  n:iwpnode;
  p:point2d;
begin
  m_oper.Ttype:=2;
  useChange:=false;
  n:=getCurSrcInMainWnd;
  p:=GetActiveCursorX;
  t1se.Value:=p.x;
  t2se.Value:=p.y;
  useChange:=true;
end;

procedure TCounterFrm.ApplyBtnClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.
