unit uSelsinFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, uwpproc, ucommonmath, ucommontypes, Winpos_ole_TLB,
  posbase, math, uWPProcServices, Spin, ComCtrls, uBtnListView, uEditSelsinFrm,
  Buttons, inifiles, uComponentServises, uwpOpers;

type
  TSelsinFrm = class(TForm)
    GroupBox1: TGroupBox;
    ChansLV: TBtnListView;
    dTfe: TFloatEdit;
    Label3: TLabel;
    EvalBtn: TButton;
    EngDelBtn: TBitBtn;
    EngAddBtn: TBitBtn;
    procedure EvalBtnClick(Sender: TObject);
    procedure EngAddBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EngDelBtnClick(Sender: TObject);
    procedure ChansLVDblClickProcess(item: TListItem; lv: TListView);
    procedure ChansLVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    mng:cwpObjMng;
    src:csrc;
  private
    procedure Eval(s:cselsin);
    procedure Eval1(s:cselsin);
    procedure Addselsin(s:cselsin);
    procedure updateLI(li: TListItem);
    procedure CheckList;
    procedure Save;
    procedure Load;
  public
    function Showmodal:integer;override;
    procedure linc(p_mng:cWpObjMng);
  end;

  RptSct = record
    M,
    // дисперсия
    D,
    // СКЗ
    RMS, R,
    // СКО
    E,
    // ассиметрия
    A3,
    // Эксцесс
    A4:double;
  end;


  function RunStats(const src: olevariant; t1,t2:double): RptSct;
  procedure RunFFT(const src: olevariant; t1,t2:double; opts:string;var res1:string;var res2:string);overload;
  procedure RunFFT(const src: olevariant; opts:string; var res1:string;var res2:string);overload;

  function GetAmp(const src: olevariant; t1,t2:double): double;overload;
  function GetAmp(const src: olevariant): double;overload;
  function GetSKO(const src: olevariant; t1,t2:double): double;overload;
  function GetSKO(const src: olevariant): double;overload;
  function GetSKOMinMax(const src: olevariant; dt:double): point2d;
  function GetSKOTrend(const src: olevariant; dt:double): iwpsignal;
  // Фаза через взаимный спектр на частоте главной гармоники
  function GetPhaseDeg(s1, s2:iwpsignal; interval:point2d):double;
  function GetQuad(p1, p2, p3:double):integer;
  function GetSect(p1, p2, p3:double):integer;
  function ShiftSect(sectr, shift:integer):integer;

const
  sqrt3 = 1.7320508075688772935274463415059;
  sin60 = 1.7320508075688772935274463415059/2;
  c_radtodeg = 57.295779513;
  c_asin60 = 1.0471975511965977461542144610932;

var
  SelsinFrm: TSelsinFrm;

implementation
uses
  uWpExtPack;

{$R *.dfm}

// отсчитываем фазу только в положительном направлении (против часовой стрелки)
function GetPhase(r,i:single):single;
var
  // четверть
  c: integer;
begin
  if r>=0 then
  begin
    if r=0 then
    begin
      if i>0 then
        result:=90
      else
        result:=-90;
    end
    else
    begin
      result:=arctan(i/r)*180/pi;
      // 1-я четверть
      if i>0 then
      begin
      end
      else
      // 4-я четверть
      begin
        result:=result+360;
      end;
    end;
  end
  else
  begin
    // 2-я четверть
    if i>0 then
    begin
      result:=arctan(i/r)*180/pi+180;
    end
    else
    // 3-я четверть
    begin
      result:=arctan(i/r)*180/pi+180;
    end;
  end;
end;

procedure RunFFT(const src: olevariant; opts:string; var res1:string;var res2:string);
var
  r1, r2, err: olevariant;
  oper : IWPOperator;
  s1, s2:iwpsignal;
begin
  oper:= WP.GetObject('/Operators/АвтоСпектр') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.loadProperties(opts);

    oper.Exec(src,src,refvar(r1),refvar(r2));

    s1 := iwpsignal(TVarData(r1).VPointer);
    wp.Link('/Signals/results', s1.sname, s1 as IDispatch);
    res1:='/Signals/results/'+s1.sname;

    s2 := iwpsignal(TVarData(r2).VPointer);
    wp.Link('/Signals/results', s2.sname, s2 as IDispatch);
    res2:='/Signals/results/'+s2.sname;
    wp.Refresh;
  end
  else
    Err:= -1001;
end;

procedure RunFFT(const src: olevariant; t1,t2:double; opts:string;var res1:string;var res2:string);
var
  start, stop:integer;
  s:iwpsignal;
begin
  start:=src.IndexOf(t1);
  stop:=src.IndexOf(t2);
  s:= wp.GetInterval(src, start, stop - start) as iwpsignal;
  RunFFT(s, opts, res1, res2);
end;


function RunStats(const src: olevariant; t1,t2:double): RptSct;
var
  r1, r2, opt, err: olevariant;
  start, stop:integer;
  s:iwpsignal;
begin
  start:=src.IndexOf(t1);
  stop:=src.IndexOf(t2);
  s:= wp.GetInterval(src, start, stop - start) as iwpsignal;

  RunWPOperator('/Operators/Вероятн. характеристики', src, src, r1, r2, opt,
    err);
  result.M := r1.GetY(0);
  result.D := r1.GetY(1);
  result.E := r1.GetY(2);
  result.A3 := r1.GetY(3);
  result.A4 := r1.GetY(4);
  result.R := r1.GetY(5) * 2;
  result.RMS := r1.GetY(6);
end;

function GetSKO(const src: olevariant; t1,t2:double): double;
var
  r1, r2, opt, err: olevariant;
  start, stop:integer;
  s:iwpsignal;
begin
  start:=src.IndexOf(t1);
  stop:=src.IndexOf(t2);
  s:= wp.GetInterval(src, start, stop - start) as iwpsignal;
  RunWPOperator('/Operators/Вероятн. характеристики', s, s, r1, r2, opt,
    err);
  result:= r1.GetY(2);
end;

function GetSKO(const src: olevariant): double;
var
  r1, r2, opt, err: olevariant;
begin
  RunWPOperator('/Operators/Вероятн. характеристики', src, src, r1, r2, opt,
    err);
  result:= r1.GetY(2);
end;

function GetAmp(const src: olevariant; t1,t2:double): double;
var
  r1, r2, opt, err: olevariant;
  start, stop:integer;
  s:iwpsignal;
begin
  start:=src.IndexOf(t1);
  stop:=src.IndexOf(t2);
  s:= wp.GetInterval(src, start, stop - start) as iwpsignal;
  RunWPOperator('/Operators/Вероятн. характеристики', s, s, r1, r2, opt,
    err);
  result:= r1.GetY(5);
end;

function GetAmp(const src: olevariant): double;
var
  r1, r2, opt, err: olevariant;
begin
  RunWPOperator('/Operators/Вероятн. характеристики', src, src, r1, r2, opt,
    err);
  result:= r1.GetY(5);
end;

procedure TSelsinFrm.EvalBtnClick(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
  s:cselsin;
begin
  for I := 0 to chansLV.items.Count - 1 do
  begin
    li:=ChansLV.Items[i];
    s:=cselsin(li.Data);
    if s.valid then
      Eval1(s);
  end;
end;

procedure TSelsinFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Save;
end;

function GetSKOTrend(const src: olevariant; dt:double): iwpsignal;
var
  opts, str:string;
  v:cString;
  pars:tstringlist;
  ind:integer;
  oper:iwpoperator;
  r1, r2, opt, err: olevariant;
  s1:iwpsignal;
begin
  result:=nil;
  //12:12:51|Выполнение алгоритма ""|typeRez=6,nPoints=4800,bEquivMag=0,
  opts:='typeRez=6,'+ // Re Im спектр
         'nPoints=4800,'+ // Число точек БПФ
         'bEquivMag=0';

  pars:=ParsStrParamNoSort(opts, ',');
  if FindInPars(pars,'nPoints',ind) then
  begin
    v:=cstring(pars.Objects[ind]);
    v.str:=floattostr(round(dt/src.deltax));
  end;
  str:=ParsToStr(pars);
  pars.Destroy;
  oper:= WP.GetObject('/VibroOpers/Последовательная обработка (тренды)') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.loadProperties(str);
    oper.Exec(src,src,refvar(r1),refvar(r2));

    s1 := iwpsignal(TVarData(r1).VPointer);
    result:=s1;
  end;
end;

// Размер порции dt
function GetSKOMinMax(const src: olevariant; dt:double): point2d;
var
  opts, str:string;
  v:cString;
  pars:tstringlist;
  ind:integer;
  oper:iwpoperator;
  r1, r2, opt, err: olevariant;
  s1:iwpsignal;
begin
  //12:12:51|Выполнение алгоритма ""|typeRez=6,nPoints=4800,bEquivMag=0,
  opts:='typeRez=6,'+ // Re Im спектр
         'nPoints=4800,'+ // Число точек БПФ
         'bEquivMag=0';

  pars:=ParsStrParamNoSort(opts, ',');
  if FindInPars(pars,'nPoints',ind) then
  begin
    v:=cstring(pars.Objects[ind]);
    v.str:=floattostr(round(dt/src.deltax));
  end;
  str:=ParsToStr(pars);
  pars.Destroy;

  oper:= WP.GetObject('/VibroOpers/Последовательная обработка (тренды)') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.loadProperties(opts);
    oper.Exec(src,src,refvar(r1),refvar(r2));

    s1 := iwpsignal(TVarData(r1).VPointer);
    result:=p2d(s1.MinY,s1.MaxY);
  end;
end;

function ShiftSect(sectr, shift:integer):integer;
begin
  result:=sectr+shift;
  if result>5 then
  begin
    result:=result-6;
  end;
end;

function GetSect(p1, p2, p3:double):integer;
var
  b1,b2,b3:byte;
  res:integer;
begin
  if p1>0 then
    b1:=1
  else
    b1:=0;
  if p2>0 then
    b2:=1
  else
    b2:=0;
  if p3>0 then
    b3:=1
  else
    b3:=0;
  // 010
  res:=b1*1+b2*2+b3*4;
  case res of
    2:result:=0; // 010
    6:result:=1; // 011
    4:result:=2; // 001
    5:result:=3; // 101
    1:result:=4; // 100
    3:result:=5; // 110
  end;
end;

function GetQuad(p1, p2, p3:double):integer;
var
  b1,b2,b3:boolean;
begin
  b1:=p1>0;
  b2:=p2>0;
  b3:=p3>0;
  // 0 1 0
  // 0 1 1
  // Четверть 0 (alfa)
  if b2 then
  begin
    //if (not b1) and (not b3) then
    if (not b1) then
    begin
      result:=0;
      exit;
    end;
  end;
  // 0 0 1
  // 0 1 1
  // Четверть 1 (pi- alfa)
  if b3 then
  begin
    if not b1 then
    begin
      result:=1;
      exit;
    end;
  end;
  // 1 0 1
  // 1 0 0
  // Четверть 2 (pi + alfa)
  if b1 then
  begin
    if (not b2) and b3 then
    begin
      result:=2;
      exit;
    end;
  end;
  // 1 0 0
  // 1 1 0
  // Четверть 3 (2pi- alfa)
  if b1 then
  begin
    if not b3 then
    begin
      result:=3;
      exit;
    end;
  end;
end;



function GetPhaseDeg(s1, s2:iwpsignal; interval:point2d):double;
var
  opts, str:string;
  pars:tstringlist;
  r1, r2:olevariant;
  res1:iwpsignal;
  oper:iwpoperator;
  fftcount, numpoints, count:integer;
  fs, max:double;
  I: Integer;
begin
//13:33:18|Выполнение алгоритма
//|  8192
  oper:= WP.GetObject('/Operators/Взаимный спектр') as IWPOperator;
  //opts:='kindFunc=23,numPoints=1024,nBlocks=4,nLines=0,typeWindow=1,ofsNextBlock=1024,typeMagnitude=1,type=20,method=0,isMO=1,'
  //+'isCorrectFunc=0,isMonFase=0,isFill0=0,'
  //+'fMaxVal=0,fLog=0,fPrSpec=0,f3D=0,'
  //+'fSwapXZ=0,iStandart=1,fFlt=0,fQual=6,log_kind=0,log_OpZn=2e-005,log_fOpZn=0,'
  //+'prs_kind=1,prs_loFreq=1,prs_s2n=100,prs_fCorr=0,prs_strCorr=9.09071e-318,prs_typeCorr=0';

  opts:='kindFunc=23,numPoints=1024,nBlocks=2,nLines=0,typeWindow=1,ofsNextBlock=1024,typeMagnitude=1,type=20,method=0,isMO=1,'
  +'isCorrectFunc=0,isMonFase=0,isFill0=0,fMaxVal=0,fLog=0,fPrSpec=0,f3D=0,fSwapXZ=0,iStandart=1';


  pars:=ParsStrParamNoSort(opts, ',');
  // меняем число точек fft
  fs:=1/s1.DeltaX;
  numpoints:=round(fs*(interval.y-interval.x)/4);
  numpoints:=GetNumPointsFFT(numpoints);
  ChangeParam(pars,'numPoints',inttostr(numpoints));
  ChangeParam(pars,'ofsNextBlock',inttostr(numpoints));
  i:=trunc(fs*(interval.y-interval.x)/numpoints);
  if i=0 then
    i:=1;
  ChangeParam(pars,'nBlocks', inttostr(i) );
  str:=ParsToStr(pars);
  pars.Destroy;

  //for I := 0 to length(str) do
  //begin
  //  if opts[i]<>str[i] then
  //    showmessage(';');
  //end;

  oper.loadProperties(str);

  s1:=getinterval(s1, interval);
  s2:=getinterval(s2, interval);
  oper.Exec(s1, s2, refvar(r1), refvar(r2));
  res1:=iwpsignal(TVarData(r1).VPointer);
  max:=res1.MaxY;
  for I := 0 to res1.size - 1 do
  begin
    if res1.GetY(i)=max then
      break;
  end;
  res1:=iwpsignal(TVarData(r2).VPointer);
  Result:=res1.GetY(i);
end;

function EqvNull(d:double):boolean;
begin
  if abs(d)<0.0000001 then
    result:=true
  else
    result:=false;
end;

function booltof(v:boolean):double;
begin
  if v then
    result:=1
  else
    result:=0
end;


procedure TSelsinFrm.ChansLVDblClickProcess(item: TListItem; lv: TListView);
var
  s:cselsin;
begin
  s:=cselsin(item.data);
  EditSelsinFrm.EditSelsin(s);
  updateLI(item);
  CheckList;
end;

procedure TSelsinFrm.ChansLVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_DELETE then
    EngDelBtnClick(nil);
end;

procedure TSelsinFrm.EngAddBtnClick(Sender: TObject);
var
  s:cselsin;
begin
  s:=EditSelsinFrm.CreateSelsin;
  if s<>nil then
    Addselsin(s);
  CheckList;
  LVChange(ChansLV);
end;

procedure TSelsinFrm.EngDelBtnClick(Sender: TObject);
var
  li:tlistitem;
begin
  while ChansLV.SelCount<>0 do
  begin
    li:=ChansLV.Selected;
    cselsin(li.Data).Destroy;
    li.Delete;
  end;
end;

Function BoolTostr(b:boolean):string;
begin
  if b then
    result:='1'
  else
    result:='0';
end;

procedure tSelsinFrm.updateLI(li: TListItem);
var
  s:cselsin;
begin
  s:=cselsin(li.data);
  ChansLV.SetSubItemByColumnName('№',inttostr(li.index),li);
  ChansLV.SetSubItemByColumnName('Имя',s.name,li);
  ChansLV.SetSubItemByColumnName('L1',s.getL1,li);
  ChansLV.SetSubItemByColumnName('L2',s.getL2,li);
  ChansLV.SetSubItemByColumnName('L3',s.getL3,li);
  ChansLV.SetSubItemByColumnName('Exc',s.getExc,li);
  ChansLV.SetSubItemByColumnName('Min1',floattostr(s.minmax1.x),li);
  ChansLV.SetSubItemByColumnName('Max1',floattostr(s.minmax1.y),li);
  ChansLV.SetSubItemByColumnName('Min2',floattostr(s.minmax2.x),li);
  ChansLV.SetSubItemByColumnName('Max2',floattostr(s.minmax2.y),li);
  ChansLV.SetSubItemByColumnName('Min3',floattostr(s.minmax3.x),li);
  ChansLV.SetSubItemByColumnName('Max3',floattostr(s.minmax3.y),li);
  ChansLV.SetSubItemByColumnName('AutoCalibr',booltostr(s.autocal),li);
  ChansLV.SetSubItemByColumnName('SectShift',inttostr(s.shiftsectr),li);
end;

procedure tSelsinFrm.Addselsin(s:cselsin);
var
  li:tlistitem;
begin
  li:=ChansLV.Items.Add;
  li.data:=s;
  ChansLV.SetSubItemByColumnName('№',inttostr(li.index),li);
  ChansLV.SetSubItemByColumnName('Имя',s.name,li);
  ChansLV.SetSubItemByColumnName('L1',s.getL1,li);
  ChansLV.SetSubItemByColumnName('L2',s.getL2,li);
  ChansLV.SetSubItemByColumnName('L3',s.getL3,li);
  ChansLV.SetSubItemByColumnName('Exc',s.getExc,li);
  ChansLV.SetSubItemByColumnName('Min1',floattostr(s.minmax1.x),li);
  ChansLV.SetSubItemByColumnName('Max1',floattostr(s.minmax1.y),li);
  ChansLV.SetSubItemByColumnName('Min2',floattostr(s.minmax2.x),li);
  ChansLV.SetSubItemByColumnName('Max2',floattostr(s.minmax2.y),li);
  ChansLV.SetSubItemByColumnName('Min3',floattostr(s.minmax3.x),li);
  ChansLV.SetSubItemByColumnName('Max3',floattostr(s.minmax3.y),li);
  ChansLV.SetSubItemByColumnName('AutoCalibr',booltostr(s.autocal),li);
  ChansLV.SetSubItemByColumnName('SectShift',inttostr(s.shiftsectr),li);
end;

procedure tSelsinFrm.Eval(s:cselsin);
var
  sig:iwpsignal;
  p1,p2,p3,SKO1,SKO2,SKO3, SKOEXC:iwpsignal;

  norm1, norm2, norm3, resSignal,
  smod1,smod2,smod3,
  smod_u1u2,smod_u3u1,smod_u2u3: iwpsignal;
  phase1, phase2, phase3:double;
  asin1,asin2,asin3,
  u1,u2,u3,
  cos1,cos2,cos3,
  sin1,sin2,sin3,
  sinmod1,sinmod2,sinmod3,
  tg1,tg2,tg3,
  ctg1,ctg2,ctg3,
  mod1,mod2,mod3, modcom:double;
  interval, time:point2d;
  i,quad: Integer;
begin

  SKO1:=GetSKOTrend(s.l1.Signal, dtFe.FloatNum);
  SKO2:=GetSKOTrend(s.l2.Signal, dtFe.FloatNum);
  SKO3:=GetSKOTrend(s.l3.Signal, dtFe.FloatNum);
  SKOExc:=GetSKOTrend(s.Exc.Signal, dtFe.FloatNum);
  // нормализуем в сигнал 0..1
  norm1:=Normalise0_1(SKO1, p2d(sko1.MinY,sko1.MaxY));
  norm2:=Normalise0_1(SKO2, p2d(sko2.MinY,sko2.MaxY));
  norm3:=Normalise0_1(SKO3, p2d(sko3.MinY,sko3.MaxY));
  // выбираем интервал обработки
  time.x:=norm1.minx;
  if time.x<norm2.minx then
    time.x:=norm2.minx;
  if time.x<norm3.minx then
    time.x:=norm3.minx;
  time.y:=norm1.maxx;
  if time.y>norm2.maxx then
    time.y:=norm2.maxx;
  if time.y>norm2.maxx then
    time.y:=norm3.maxx;

  resSignal:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  p1:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  p2:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  p3:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;

  smod1:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  smod1.size:= round((time.y-time.x)/dTfe.FloatNum);
  smod1.DeltaX:=dTfe.FloatNum;
  smod2:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  smod2.size:= round((time.y-time.x)/dTfe.FloatNum);
  smod2.DeltaX:=dTfe.FloatNum;
  smod3:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  smod3.size:= round((time.y-time.x)/dTfe.FloatNum);
  smod3.DeltaX:=dTfe.FloatNum;
  smod_u1u2:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  smod_u1u2.size:= round((time.y-time.x)/dTfe.FloatNum);
  smod_u1u2.DeltaX:=dTfe.FloatNum;
  smod_u3u1:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  smod_u3u1.size:= round((time.y-time.x)/dTfe.FloatNum);
  smod_u3u1.DeltaX:=dTfe.FloatNum;
  smod_u2u3:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  smod_u2u3.size:= round((time.y-time.x)/dTfe.FloatNum);
  smod_u2u3.DeltaX:=dTfe.FloatNum;


  //-- помещаем сигнал в дерево
  posbase.winpos.Link('/Signals/Selsin', s.name, resSignal as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_p1', p1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_p2', p2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_p3', p3 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_mod1', smod1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_mod2', smod2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_mod3', smod3 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_mod_u1u2', smod_u1u2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_mod_u3u1', smod_u3u1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_mod_u2u3', smod_u2u3 as IDispatch);

  posbase.winpos.Refresh();
  //-- зададим длину сигнала
  resSignal.size:= round((time.y-time.x)/dTfe.FloatNum);
  resSignal.DeltaX:=dTfe.FloatNum;
  p1.size:= round((time.y-time.x)/dTfe.FloatNum);
  p1.DeltaX:=dTfe.FloatNum;
  p2.size:= round((time.y-time.x)/dTfe.FloatNum);
  p2.DeltaX:=dTfe.FloatNum;
  p3.size:= round((time.y-time.x)/dTfe.FloatNum);
  p3.DeltaX:=dTfe.FloatNum;

  // настраиваем шаг обработки
  interval.x:=time.x;
  interval.y:=interval.x+dTfe.FloatNum;
  i:=0;
  while interval.y<time.y do
  begin
    u1:=SKO1.GetY(i);
    u2:=SKO2.GetY(i);
    u3:=SKO3.GetY(i);

    ctg1:=(2*u2-u1)/(u1*sqrt3);
    sin1:=sqrt(1/(1+ctg1*ctg1));
    mod1:=u1/sin1;
    smod1.SetY(i,mod1);
    asin1:=ArcSin(sin1);

    tg1:=(u1-2*u2)/(sqrt3*u1);
    cos1:=sqrt(1/(1+tg1*tg1));

    mod1:=u1/cos1;
    smod_u1u2.SetY(i,mod1);
    mod2:=u2/sin(asin1+c_asin60);
    smod2.SetY(i,mod2);
    mod3:=u3/sin(asin1+c_asin60*2);
    smod3.SetY(i,mod3);


    tg2:=(u1-2*u3)/((sqrt3)*u1);
    cos2:=sqrt(1/(1+tg2*tg2));
    //sin2:=tg2*cos2;
    mod2:=u3/cos2;
    smod_u3u1.SetY(i,mod2);


    ctg2:=(2*u1-u3)/(u3*sqrt3);
    sin2:=sqrt(1/(1+ctg2*ctg2));

    tg3:=(u2-2*u3)/(sqrt3*u2);
    cos3:=sqrt(1/(1+tg3*tg3));
    //sin3:=tg3*cos3;
    mod3:=u2/cos3;
    smod_u2u3.SetY(i,mod3);

    ctg3:=(2*u3-u2)/(u2*sqrt3);
    sin3:=sqrt(1/(1+ctg3*ctg3));

    // считаем фазы
    phase1:=GetPhaseDeg(s.l1.Signal,s.exc.Signal,interval);
    phase2:=GetPhaseDeg(s.l2.Signal,s.exc.Signal,interval);
    phase3:=GetPhaseDeg(s.l3.Signal,s.exc.Signal,interval);

    p1.setY(i,booltof(phase1>0));
    p2.setY(i,booltof(phase2>0));
    p3.setY(i,booltof(phase3>0));
    // считаем arcsin
    quad:=norm1.IndexOf(interval.y-dTfe.FloatNum*0.5);
    asin1:=norm1.gety(quad);
    quad:=norm2.IndexOf(interval.y-dTfe.FloatNum*0.5);
    asin2:=norm2.gety(quad);
    quad:=norm3.IndexOf(interval.y-dTfe.FloatNum*0.5);
    asin3:=norm3.gety(quad);

    // Вычисляем конечное значение угла по таблице квадрантов
    quad:=GetSect(phase1,phase2,phase3);
    quad:=ShiftSect(quad,s.ShiftSectr);


    case quad of
      0:modcom:=mod3;
      1:modcom:=mod1;
      2:modcom:=mod3;
      3:modcom:=mod3;
      4:modcom:=mod1;
      5:modcom:=mod3;
    end;
    sinmod1:=u1/modcom;
    sinmod2:=u2/modcom;
    sinmod3:=u3/modcom;


    asin1:=sinmod1;
    asin2:=sinmod2;
    asin3:=sinmod3;

    // вычисляем угол
    if EqvNull(asin1-1) then
    begin
      asin1:=90
    end
    else
    begin
      asin1:=ArcSin(asin1)*180/pi;
    end;
    if EqvNull(asin2-1) then
    begin
      asin2:=90
    end
    else
    begin
      asin2:=ArcSin(asin2)*180/pi;
    end;
    if EqvNull(asin3-1) then
    begin
      asin3:=90
    end
    else
    begin
      asin3:=ArcSin(asin3)*180/pi
    end;

    case quad of
      0:resSignal.SetY(i,asin1);
      1:
      begin
        resSignal.SetY(i,180-asin2-60);
      end;
      2:
      begin
        resSignal.SetY(i,180-asin1);
      end;
      3:
      begin
        resSignal.SetY(i,180+asin1);
      end;
      4:
      begin
        resSignal.SetY(i,360-asin2-60);
      end;
      5:
      begin
        resSignal.SetY(i,360-asin1);
      end;
    end;
    interval.x:=interval.x+dTfe.FloatNum;
    interval.y:=interval.y+dTfe.FloatNum;
    inc(i);
  end;
end;

function GetTg(u1,u2:double):double;
begin
  result:=(2*u2-u1)/(sqrt(3)*u1);
end;

procedure TSelsinFrm.Eval1(s: cselsin);
var
  sig:iwpsignal;
  p1,p2,p3,SKO1,SKO2,SKO3, SKOEXC, resSignal:iwpsignal;


  phase1, phase2, phase3, deg1, deg2, deg3:double;
  u1,u2,u3,

  tg1,tg2,tg3:double;
  interval, time:point2d;
  i,quad: Integer;
begin

  SKO1:=GetSKOTrend(s.l1.Signal, dtFe.FloatNum);
  SKO2:=GetSKOTrend(s.l2.Signal, dtFe.FloatNum);
  SKO3:=GetSKOTrend(s.l3.Signal, dtFe.FloatNum);
  SKOExc:=GetSKOTrend(s.Exc.Signal, dtFe.FloatNum);
  // выбираем интервал обработки
  time.x:=SKO1.minx;
  if time.x<SKO2.minx then
    time.x:=SKO2.minx;
  if time.x<SKO3.minx then
    time.x:=SKO3.minx;
  time.y:=SKO1.maxx;
  if time.y>SKO2.maxx then
    time.y:=SKO2.maxx;
  if time.y>SKO2.maxx then
    time.y:=SKO3.maxx;

  resSignal:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  // фазы
  p1:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  p2:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  p3:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;

  //-- помещаем сигнал в дерево
  posbase.winpos.Link('/Signals/Selsin', s.name, resSignal as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_p1', p1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_p2', p2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_p3', p3 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'sko_1', sko1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'sko_2', sko2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'sko_3', sko3 as IDispatch);


  posbase.winpos.Refresh();
  //-- зададим длину сигнала
  resSignal.size:= round((time.y-time.x)/dTfe.FloatNum);
  resSignal.DeltaX:=dTfe.FloatNum;
  p1.size:= round((time.y-time.x)/dTfe.FloatNum);
  p1.DeltaX:=dTfe.FloatNum;
  p2.size:= round((time.y-time.x)/dTfe.FloatNum);
  p2.DeltaX:=dTfe.FloatNum;
  p3.size:= round((time.y-time.x)/dTfe.FloatNum);
  p3.DeltaX:=dTfe.FloatNum;

  // настраиваем шаг обработки
  interval.x:=time.x;
  interval.y:=interval.x+dTfe.FloatNum;
  i:=0;
  while interval.y<time.y do
  begin
    u1:=SKO1.GetY(i);
    u2:=SKO2.GetY(i);
    u3:=SKO3.GetY(i);

    tg1:=GetTg(u1, u2);
    tg2:=GetTg(u2, u3);
    tg3:=GetTg(u3, u1);

    // считаем фазы
    phase1:=GetPhaseDeg(s.l1.Signal,s.exc.Signal,interval);
    phase2:=GetPhaseDeg(s.l2.Signal,s.exc.Signal,interval);
    phase3:=GetPhaseDeg(s.l3.Signal,s.exc.Signal,interval);

    //p1.setY(i,booltof(phase1>0));
    //p2.setY(i,booltof(phase2>0));
    //p3.setY(i,booltof(phase3>0));
    p1.setY(i,phase1);
    p2.setY(i,phase2);
    p3.setY(i,phase3);

    // Вычисляем конечное значение угла по таблице квадрантов
    quad:=GetSect(phase1,phase2,phase3);
    quad:=ShiftSect(quad,s.ShiftSectr);

    deg1:=arctan(tg1)*c_radtodeg;
    deg2:=arctan(tg2)*c_radtodeg;
    deg3:=arctan(tg3)*c_radtodeg;

    case quad of
      0:resSignal.SetY(i,deg1);
      1:
      begin
        resSignal.SetY(i,deg2+60);
      end;
      2:
      begin
        resSignal.SetY(i,deg3+120);
      end;
      3:
      begin
        resSignal.SetY(i,180+deg1);
      end;
      4:
      begin
        resSignal.SetY(i,deg2+60+180);
      end;
      5:
      begin
        resSignal.SetY(i,deg3+120+180);
      end;
    end;
    interval.x:=interval.x+dTfe.FloatNum;
    interval.y:=interval.y+dTfe.FloatNum;
    inc(i);
  end;
end;

procedure tSelsinFrm.CheckList;
var
  I: Integer;
  li:tlistitem;
  s:cselsin;
begin
  ChansLV.clearcolors;
  for I := 0 to ChansLV.items.Count - 1 do
  begin
    li:=ChansLV.items[i];
    s:=cselsin(li.data);
    if not s.valid then
    begin
      ChansLV.addColorItem(i,clRed);
    end;
  end;
end;

procedure tSelsinFrm.Save;
var
  I: Integer;
  li:tlistitem;
  s:cselsin;
  f:tinifile;
  id:string;
begin
  f:=tinifile.Create(startdir+'\Opers\Selsin.ini');
  f.WriteInteger('main', 'sCount',ChansLV.items.Count);
  for I := 0 to ChansLV.items.Count - 1 do
  begin
    li:=ChansLV.Items[i];
    s:=cselsin(li.data);
    id:='S_'+inttostr(i);
    f.WriteString(id,'Name',s.name);
    f.WriteString(id,'L1',s.getL1);
    f.WriteString(id,'L2',s.getL2);
    f.WriteString(id,'L3',s.getL3);
    f.WriteString(id,'Exc',s.getexc);
    f.WriteInteger(id,'SectShift',s.shiftsectr);
    f.WriteFloat(id,'Min1',s.minmax1.x);
    f.WriteFloat(id,'Max1',s.minmax1.y);
    f.WriteFloat(id,'Min2',s.minmax2.x);
    f.WriteFloat(id,'Max2',s.minmax2.y);
    f.WriteFloat(id,'Min3',s.minmax3.x);
    f.WriteFloat(id,'Max3',s.minmax3.y);
    f.WriteString(id,'AutoCalibr',booltostr(s.autocal));
  end;
end;

procedure tSelsinFrm.Load;
var
  I, count: Integer;
  s:cselsin;
  sig:cWPSignal;
  f:tinifile;
  id, str:string;
  fl:double;
begin
  f:=tinifile.Create(startdir+'\Opers\Selsin.ini');
  count:=f.ReadInteger('main', 'sCount',0);
  for I := 0 to Count - 1 do
  begin
    s:=cselsin.Create;
    id:='S_'+inttostr(i);
    s.name:=f.ReadString(id,'Name',s.name);

    str:=f.ReadString(id,'L1','');
    s.fl1:=str;
    if src<>nil then
    begin
      sig:=src.getSignalObj(str);
      if sig<>nil then
        s.l1:=sig;
    end;

    str:=f.ReadString(id,'L2','');
    s.fl2:=str;
    if src<>nil then
    begin
      sig:=src.getSignalObj(str);
      if sig<>nil then
        s.l2:=sig;
    end;

    str:=f.ReadString(id,'L3','');
    s.fl3:=str;
    if src<>nil then
    begin
      sig:=src.getSignalObj(str);
      if sig<>nil then
        s.l3:=sig;
    end;

    str:=f.ReadString(id,'Exc','');
    s.fexc:=str;
    if src<>nil then
    begin
      sig:=src.getSignalObj(str);
      if sig<>nil then
        s.exc:=sig;
    end;

    s.shiftsectr:=f.ReadInteger(id,'SectShift',s.shiftsectr);
    s.minmax1.x:=f.ReadFloat(id,'Min1',s.minmax1.x);
    s.minmax1.y:=f.ReadFloat(id,'Max1',s.minmax1.y);
    s.minmax2.x:=f.ReadFloat(id,'Min2',s.minmax2.x);
    s.minmax2.y:=f.ReadFloat(id,'Max2',s.minmax2.y);
    s.minmax3.x:=f.ReadFloat(id,'Min3',s.minmax3.x);
    s.minmax3.y:=f.ReadFloat(id,'Max3',s.minmax3.y);
    str:=f.ReadString(id,'AutoCalibr',booltostr(s.autocal));
    if str='1' then
      s.autocal:=true
    else
      s.autocal:=false;
    Addselsin(s);
  end;
  CheckList;
end;


procedure tSelsinFrm.linc(p_mng:cWpObjMng);
begin
  mng:=p_mng;
  EditSelsinFrm.Init(p_mng);
  load;
end;

function tSelsinFrm.Showmodal:integer;
//var
  //oper:iwpoperator;
begin
  //oper:= WP.GetObject('/VibroOpers/Последовательная обработка (тренды)') as IWPOperator;
  //wp.Link('VibroOpers','Последовательная обработка (тренды)',oper);
  //wp.Refresh;
  CheckList;
  if inherited showmodal=mrok then
  begin

  end;
end;

end.
