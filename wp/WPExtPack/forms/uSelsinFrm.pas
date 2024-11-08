unit uSelsinFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, uwpproc, ucommonmath, ucommontypes, Winpos_ole_TLB,
  posbase, math, uWPProcServices, Spin, ComCtrls, uBtnListView, uEditSelsinFrm,
  Buttons, inifiles, uComponentServises, uwpOpers;

type
  SectrRes = record
    sectr:integer;
    aE,dE, dPrev:double;
    module, addDeg:double;
    tan:double;
    succes:boolean;
  end;

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
    procedure Eval2(s:cselsin);
    procedure Eval3(s:cselsin);
    procedure EvalSinCos(s:cselsin);
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
  tan30 = 0.57735026918962576450914878050196;
  sin60 = 1.7320508075688772935274463415059/2;
  c_radtodeg = 57.295779513;
  c_degtorad = 0.01745329251994329576923690768489;
  c_asin60 = 1.0471975511965977461542144610932;
  c_Threshold = 0.15;
  c_sinCos_Threshold = 0.15;
  c_degThreshold = 0.1;
  tan80 = 5.67139010260751;

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
    begin
      if s.bSelsin then
      begin
        EvalSinCos(s);
      end
      else
      begin
        if s.commonPoint then
        begin
          Eval3(s);
        end
        else
        begin
          Eval2(s);
        end;
      end;
    end;
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
         'nPoints=4800,'+ // размер порции
          'nOfs=4800,'+ // смещение порции
         'bEquivMag=0';

  pars:=ParsStrParamNoSort(opts, ',');
  if FindInPars(pars,'nPoints',ind) then
  begin
    v:=cstring(pars.Objects[ind]);
    v.str:=floattostr(round(dt/src.deltax));
  end;
  if FindInPars(pars,'nOfs',ind) then
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

function ShiftSectSinCos(sectr, shift:integer):integer;
begin
  result:=sectr+shift;
  if result>3 then
  begin
    result:=result-3;
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
  //L1L2L3
  // s0: 110  1 121 241   1*1+2*1+4*0=3
  // s1: 100  61 181 301  1*1+2*0+4*0=1
  // s2: 101  121 241 361 1*1+2*0+4*1=5
  // s3: 001  181 301 61  1*0+2*0+4*1=4
  // s4: 011  241 361 121 1*0+2*1+4*1=6
  // s5: 010  301 61  181 1*0+2*1+4*0=2
  case res of    //L1L2L3
    1:result:=1;
    2:result:=5;
    3:result:=0;
    4:result:=3;
    5:result:=2;
    6:result:=4;
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
  fftcount, numpoints, count, nBlocks:integer;
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

  opts:='kindFunc=23,numPoints=1024,nBlocks=1,nLines=0,typeWindow=1,ofsNextBlock=1024,typeMagnitude=1,type=20,method=0,isMO=1,'
  +'isCorrectFunc=0,isMonFase=0,isFill0=0,fMaxVal=0,fLog=0,fPrSpec=0,f3D=0,fSwapXZ=0,iStandart=1';


  pars:=ParsStrParamNoSort(opts, ',');
  nBlocks:=strtoint(GetParam(opts, 'nBlocks'));
  // меняем число точек fft
  fs:=1/s1.DeltaX;
  numpoints:=round(fs*(interval.y-interval.x)/nBlocks);
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
    begin
      max:=(max+res1.GetY(i+1)+res1.GetY(i-1))/3;
      break;
    end;
  end;
  res1:=iwpsignal(TVarData(r2).VPointer);
  Result:=res1.GetY(i);
  //Result:=max;
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
  snew:cselsin;
  i:integer;
begin
  s:=EditSelsinFrm.CreateSelsin;
  if s<>nil then
  begin
    if s.createAll=false then
    begin
      Addselsin(s);
    end
    else
    begin
      for i := 0 to 4 do
      begin
        if s.bSelsin then
        begin
          if i>2 then
            break;
        end;
        snew:=cselsin.Create;
        snew.name:=s.name+'_s'+inttostr(i);
        snew.shiftsectr:=i;
        snew.l1:=s.l1;
        snew.l2:=s.l2;
        snew.l3:=s.l3;
        snew.Exc:=s.exc;
        snew.fExc:=s.fExc;
        snew.fl3:=s.fl3;
        snew.fl2:=s.fl2;
        snew.fl1:=s.fl1;
        snew.minmax1:=s.minmax1;
        snew.minmax2:=s.minmax2;
        snew.minmax3:=s.minmax3;
        snew.reference:=s.reference;
        snew.autocal:=s.autocal;
        snew.freq:=s.freq;
        Addselsin(snew);
      end;
      if s.bSelsin then
      begin
        s.name:=s.name+'_s3';
        s.shiftsectr:=3;
      end
      else
      begin
        s.name:=s.name+'_s5';
        s.shiftsectr:=5;
      end;
      Addselsin(s);
    end;
  end;
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
  ChansLV.SetSubItemByColumnName('Модуль',floattostr(s.reference),li);
  ChansLV.SetSubItemByColumnName('без общ. тчк.', booltostr(s.commonPoint), li);
  ChansLV.SetSubItemByColumnName('без общ. тчк.', booltostr(s.commonPoint), li);
  if s.bSelsin then
    ChansLV.SetSubItemByColumnName('Тип', 'SinCos', li)
  else
    ChansLV.SetSubItemByColumnName('Тип', 'Сельсин', li);
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
  ChansLV.SetSubItemByColumnName('Модуль',floattostr(s.reference),li);
  ChansLV.SetSubItemByColumnName('без общ. тчк.', booltostr(s.commonPoint), li);
end;

function CheckMod(module, reference:double):boolean;
begin
  if ((module/reference)-1)<0.1 then
    result:=true
  else
    result:=false;
end;

function GetK(useL1, useL2, useL3:boolean; sect:integer):integer;
var
  i,j:integer;
const
  Karray: array [0..5,0..2] of integer
         =((0,1,1), //0
           (1,1,1), //1
           (1,2,2), //2
           (2,2,2), //3
           (2,2,2), //4
           (2,3,3)); //5
begin
  result:=0;
  i:=sect;
  if useL1 then
  begin
    j:=0;
  end
  else
  begin
    if useL2 then
    begin
      j:=1;
    end
    else
    begin
      if useL3 then
        j:=2;
    end;
  end;
  result:=Karray[i][j];
end;

function GetK2(sect:integer):integer;
var
  i,j:integer;
const
  Karray: array [0..5] of integer
         =(0, //0
           1, //1
           1, //2
           2, //3
           2, //4
           2);//5
begin
  result:=Karray[sect];
end;

function CheckSystem(u3, tg1, module1:double; sectr:integer; var ampError, degError:double):boolean;
var
  sin, lcos, evalU3, tg3, arg:double;
  checkarg, checkA:boolean;
begin
  lcos:=sqrt(1/(1+tg1*tg1));
  sin:=lcos*tg1;
  evalU3:=-(lcos/2-sin*sqrt3/2)*module1;
  ampError:=(abs(u3)-abs(evalU3))/module1;
  checkA:=ampError<c_Threshold;

  arg:=c_radtodeg*ArcTan(tg1)-120;
  if sectr=2 then
  begin
    arg:=arg+180;
  end;
  evalU3:=Cos(c_degtorad*arg)*module1;
  degError:=abs(u3-evalU3)/module1;
  checkarg:=degError<c_degThreshold;
  result:=checkA and checkarg;
end;

function CheckSystem3(u3, tg1, module1:double; sectr:integer; var ampError, degError:double):boolean;
var
  sin, lcos, evalU3, tg3, arg:double;
  checkarg, checkA:boolean;
begin
  lcos:=sqrt(1/(1+tg1*tg1));
  sin:=lcos*tg1;
  // U31 = a*2 sin120*cos(a+120)
  evalU3:=sqrt3*(lcos*sqrt3/2-sin*sqrt3/2)*module1;
  ampError:=abs((abs(u3)-abs(evalU3))/module1);
  checkA:=ampError<c_Threshold;

  arg:=c_radtodeg*ArcTan(tg1)-120;
  if sectr=2 then
  begin
    arg:=arg+180;
  end;
  evalU3:=Cos(c_degtorad*arg)*module1;
  degError:=abs(u3-evalU3)/module1;
  checkarg:=degError<c_degThreshold;
  result:=checkA and checkarg;
end;

function CheckSystemExt(u3, tg1, module1:double; sectr:integer; var ampError, degError:double):boolean;
var
  sin, lcos, evalU3, tg3, arg:double;
  checkarg, checkA:boolean;
begin
  lcos:=sqrt(1/(1+tg1*tg1));
  sin:=lcos*tg1;
  evalU3:=-(lcos/2-sin*sqrt3/2)*module1;
  ampError:=(u3-evalU3)/module1;
  checkA:=ampError<c_Threshold;

  arg:=c_radtodeg*ArcTan(tg1)-120;
  evalU3:=Cos(c_degtorad*arg)*module1;
  degError:=abs(u3-evalU3)/module1;
  checkarg:=degError<c_degThreshold;
  result:=checkA and checkarg;
end;


function GetTg(u1,u2:double):double;
begin
  result:=(-2*u2-u1)/(sqrt3*u1);
end;

function GetTg3(u1,u2:double):double;
begin
  result:=(2*u1+u2)/(sqrt3*u2);
end;


function recursEvalext(u1,u2, u3:double; var module:double;var sectr:integer; var aError, degError:double):double;
var
  tg, cos:double;
  sect:integer;
begin
  tg:=GetTg(u1,u2);
  cos:=sqrt(1/(1+tg*tg));
  module:=abs(u1/cos);
  if CheckSystemExt(u3,tg,module, sectr, aError, degError) then
  begin
    result:=tg;
    sectr:=sectr;
    exit;
  end
  else
  begin
    result:=0;
    module:=0;
  end;
end;

function recursEval(u1,u2, u3:double; var module:double;var sectr:integer; var aError, degError:double):double;
var
  tg, cos:double;
  sect:integer;
begin
  tg:=GetTg(u1,u2);
  cos:=sqrt(1/(1+tg*tg));
  module:=abs(u1/cos);
  if CheckSystem(u3,tg,module, sectr, aError, degError) then
  begin
    result:=tg;
    sectr:=sectr;
    exit;
  end
  else
  begin
    result:=0;
    module:=0;
  end;
end;

function GetMinError(s1,s2:SectrRes):SectrRes;
begin
  result.succes:=false;
  if s1.succes then
  begin
    result:=s1;
  end;
  if s2.succes then
  begin
    // если оба верны
    if Result.succes then
    begin
      // если ошибка второго меньше ошибки первого
      if Result.dE>s2.dE then
      begin
        result:=s2;
      end
    end
    else
    begin
      result:=s2;
    end;
  end;
end;

function GetMinError_WithPrevVal(s1,s2:SectrRes):SectrRes;
var
 dprev:double;
begin
  result.succes:=false;
  if s1.succes then
  begin
    result:=s1;
  end;
  if s2.succes then
  begin
    // если оба верны
    if Result.succes then
    begin
      /// Внимание - костыль!!! 12.08.21 Скрипник А.А.
      ///  перескок в 360 разрешен
      if (abs(s2.dPrev)>60) and (abs(s2.dPrev)<310) then
      begin
        if abs(s1.dprev)<abs(s2.dprev) then
        begin
          result:=s1;
          exit;
        end
      end;
      if (abs(s1.dPrev)>60) and (abs(s1.dPrev)<310) then
      begin
        if abs(s2.dprev)<abs(s1.dprev) then
        begin
          result:=s2;
          exit;
        end
      end;
      // если ошибка второго меньше ошибки первого
      if Result.dE>s2.dE then
      begin
        result:=s2;
      end
    end
    else
    begin
      result:=s2;
    end;
  end;
end;

function GetTangAndCheckExt(u1, u2, u3:double; var module:double;var sectr:integer; var aErr, dErr:double):double;
var
  s0,s3,s1,s4,s2,s5, s:SectrRes;
begin
  // 0 или 3
  sectr:=0;
  s0.sectr:=sectr;
  s0.succes:=false;
  result:=recursEval(u1,-u2,-u3, module, sectr, s0.aE, s0.dE);
  s0.module:=module;
  if abs(result)<tan30 then
  begin
    if module>0 then
    begin
      s0.tan:=result;
      s0.succes:=true;
    end;
  end;
  sectr:=3;
  s3.sectr:=sectr;
  s3.succes:=false;
  result:=recursEval(-u1,u2,u3, module, sectr, s3.aE, s3.dE);
  if abs(result)<tan30 then
  begin
    if module>0 then
    begin
      s3.tan:=result;
      s3.succes:=true;
    end;
  end;
  // 1 и 4
  sectr:=1;
  s1.sectr:=sectr;
  s1.succes:=false;
  result:=recursEval(u1,-u2,u3, module, sectr, s1.aE, s1.dE);
  s1.module:=module;
  if abs(result)>tan30 then
  begin
    if module>0 then
    begin
      s1.tan:=result;
      s1.succes:=true;
    end;
  end;
  sectr:=4;
  s4.sectr:=sectr;
  s4.succes:=false;
  result:=recursEval(-u1,u2,-u3, module, sectr, s4.aE, s4.dE);
  if abs(result)>tan30 then
  begin
    if module>0 then
    begin
      s4.tan:=result;
      s4.succes:=true;
    end;
  end;
  // 2 и 5
  sectr:=5;
  s5.sectr:=sectr;
  s5.succes:=false;
  result:=recursEval(u1,u2,-u3, module, sectr, s5.aE, s5.dE);
  s5.module:=module;
  if abs(result)>tan30 then
  begin
    if module>0 then
    begin
      s5.tan:=result;
      s5.succes:=true;
    end;
  end;
  sectr:=2;
  s2.sectr:=sectr;
  s2.succes:=false;
  result:=recursEval(-u1,-u2,u3, module, sectr, s2.aE, s2.dE);
  if abs(result)>tan30 then
  begin
    if module>0 then
    begin
      s2.tan:=result;
      s2.succes:=true;
    end;
  end;
  s:=s0;
  s:=GetMinError(s,s1);
  s:=GetMinError(s,s2);
  s:=GetMinError(s,s3);
  s:=GetMinError(s,s4);
  s:=GetMinError(s,s5);

  result:=s.tan;
  module:=s.module;
  sectr:=s.sectr;
  aErr:=s.aE;
  dErr:=s.dE;
end;


function GetTangAndCheck(u1, u2, u3:double; var module:double;var sectr:integer; var aErr, dErr:double; var s03, s14, s25:SectrRes):double;
var
  s:SectrRes;
begin
  // 0 или 3
  sectr:=0;
  s03.sectr:=sectr;
  s03.succes:=false;
  result:=recursEval(u1,-u2,-u3, module, sectr, s03.aE, s03.dE);
  s03.module:=module;
  if abs(result)<tan30 then
  begin
    if module>0 then
    begin
      s03.tan:=result;
      s03.succes:=true;
    end;
  end;
  // 1 и 4
  sectr:=1;
  s14.sectr:=sectr;
  s14.succes:=false;
  result:=recursEval(u1,-u2,u3, module, sectr, s14.aE, s14.dE);
  s14.module:=module;
  if abs(result)>tan30 then
  begin
    if module>0 then
    begin
      s14.tan:=result;
      s14.succes:=true;
    end;
  end;
  // 2 и 5
  sectr:=5;
  s25.sectr:=sectr;
  s25.succes:=false;
  result:=recursEval(u1,u2,-u3, module, sectr, s25.aE, s25.dE);
  s25.module:=module;
  if abs(result)>tan30 then
  begin
    if module>0 then
    begin
      s25.tan:=result;
      s25.succes:=true;
    end;
  end;
  // сравнение результатов
  s:=GetMinError(s03,s14);
  s:=GetMinError(s,s25);
  s:=GetMinError(s,s25);
  // по сути идентично проверке по аргументу. Если на 90' u1=0, u2=u3. При увеличении угла от 90 u1 снижается, u2 растет и наоборот
  if s14.succes and s25.succes then
  begin
    if u2>u3 then
    begin
      s:=s14;
    end
    else
    begin
      s:=s25;
    end;
  end;
  result:=s.tan;
  module:=s.module;
  sectr:=s.sectr;
  aErr:=s.aE;
  dErr:=s.dE;
end;


function getAddDeg(s, q:integer; deg:double):double;
begin
      case s of
      0:
      begin
        if (q=0) or (q=1) or (q=5)  then // 3
        begin
          result:=180
        end;
        if q=5 then
        begin
          if deg>0 then // 0
            result:=0
          else
            result:=360 // 3
        end;
        if q=4 then
        begin
          if deg>0 then // 0
            result:=0
          else
            result:=360 // 3
        end;
      end;
      1:
      begin
        if (q=0) or (q=1) or (q=2) then // 4    5, 0
        //if (quad=4) or (quad=5) or (quad=0) then // 4    5, 0
          result:=180
        else
          result:=0    // 1    3
      end;
      2:
      begin
        if (q=1) or (q=2) or (q=3) then // 4    5, 0
        //if quad<3 then // 2
          result:=180
        else
          result:=360  // 5
      end;
      3:
      begin
        if (q=2) or (q=3) or (q=4) then // 4    5, 0
        //if quad<3 then // 3
          result:=180
        else
          result:=0    // 0
      end;
      4:
      begin
        if (q=3) or (q=4) or (q=5) then // 4    5, 0
        //if quad<3 then // 4
          result:=180
        else
          result:=0    // 1
      end;
      5:
      begin
        if (q=4) or (q=5) or (q=0) then // 4  5, 0
        //if quad>2 then // 2
          result:=180
        else
        begin
          result:=360;
          if q=1 then
          begin
            if deg<0 then
            begin
              result:=180
            end;
          end;
        end;
      end;
    end;
end;

procedure TSelsinFrm.Eval2(s: cselsin);
var
  sig:iwpsignal;
  mod1, mod2, mod3, p1,p2,p3,SKO1,SKO2,SKO3, Sect, iQuad, resSignal:iwpsignal;

  u1,u2,u3,
  tg1,tg2,tg3,
  module1, module2, module3, phase1, phase2, phase3, deg, addDeg, Module, lcos,
  // угол для проверок
  a_s03,a_s14,a_s25,
  // сохраняем значение угла для следующего шага
  res:double;
  // нельзя использовать в 2 и 4 секторах
  useTg1:boolean;

  interval, time:point2d;
  i,quad, sectr, sectr1: Integer;

  aErr, dErr:double;

  s03,s14,s25:SectrRes;
begin

  SKO1:=GetSKOTrend(s.l1.Signal, dtFe.FloatNum);
  SKO2:=GetSKOTrend(s.l2.Signal, dtFe.FloatNum);
  SKO3:=GetSKOTrend(s.l3.Signal, dtFe.FloatNum);
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

  // фазы
  mod1:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  mod2:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  mod3:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;

  Sect:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  iQuad:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;

  //-- помещаем сигнал в дерево
  posbase.winpos.Link('/Signals/Selsin', s.name, resSignal as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_p1', p1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_p2', p2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'_p3', p3 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'mod_1', mod1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'mod_2', mod2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'mod_3', mod3 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'sko_1', sko1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'sko_2', sko2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'sko_3', sko3 as IDispatch);

  posbase.winpos.Link('/Signals/Selsin', s.name+'sect', Sect as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'quad', iQuad as IDispatch);


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

  sect.size:= round((time.y-time.x)/dTfe.FloatNum);
  sect.DeltaX:=dTfe.FloatNum;
  iQuad.size:= round((time.y-time.x)/dTfe.FloatNum);
  iQuad.DeltaX:=dTfe.FloatNum;


  mod1.size:= round((time.y-time.x)/dTfe.FloatNum);
  mod1.DeltaX:=dTfe.FloatNum;
  mod2.size:= round((time.y-time.x)/dTfe.FloatNum);
  mod2.DeltaX:=dTfe.FloatNum;
  mod3.size:= round((time.y-time.x)/dTfe.FloatNum);
  mod3.DeltaX:=dTfe.FloatNum;

  resSignal.StartX:=time.x;
  // настраиваем шаг обработки
  interval.x:=time.x;
  interval.y:=interval.x+dTfe.FloatNum;
  i:=0;
  while interval.y<time.y do
  begin
    u1:=SKO1.GetY(i);
    u2:=SKO2.GetY(i);
    u3:=SKO3.GetY(i);
                                                             // 0,1,5
    tg1:=GetTangAndCheck(u1,u2,u3,module1,sectr, aErr, dErr, s03,s14,s25);

    mod1.setY(i,module1);
    mod2.setY(i,module2);
    mod3.setY(i,module3);

    // считаем фазы
    phase1:=GetPhaseDeg(s.l1.Signal,s.exc.Signal,interval);
    phase2:=GetPhaseDeg(s.l2.Signal,s.exc.Signal,interval);
    phase3:=GetPhaseDeg(s.l3.Signal,s.exc.Signal,interval);

    p1.setY(i,phase1);

    p2.setY(i,phase2);
    p3.setY(i,phase3);

    // Вычисляем конечное значение угла по таблице квадрантов
    quad:=GetSect(phase1,phase2,phase3);
    quad:=ShiftSect(quad,s.ShiftSectr);
    iQuad.setY(i,quad);
    sect.setY(i,sectr);

    deg:=arctan(tg1)*c_radtodeg;
    adddeg:=getAddDeg(sectr, quad, deg);
    if s03.succes then
    begin
      deg:=arctan(s03.tan)*c_radtodeg;
      a_s03:=getAddDeg(s03.sectr, quad, deg);
      s03.dPrev:=deg+a_s03-res;
      s03.addDeg:=a_s03;
    end;
    if s14.succes then
    begin
      deg:=arctan(s14.tan)*c_radtodeg;
      a_s14:=getAddDeg(s14.sectr, quad, deg);
      s14.dPrev:=deg+a_s14-res;
      s14.addDeg:=a_s14;
    end;
    if s25.succes then
    begin
      deg:=arctan(s25.tan)*c_radtodeg;
      a_s25:=getAddDeg(s25.sectr, quad, deg);
      s25.dPrev:=deg+a_s25-res;
      s25.addDeg:=a_s25;
    end;
    // пишем в s03 самый точный результат
    s03:=GetMinError_WithPrevVal(s03, s14);
    s03:=GetMinError_WithPrevVal(s03, s25);

    res:=arctan(s03.tan)*c_radtodeg+s03.addDeg;
    resSignal.SetY(i,res);

    interval.x:=interval.x+dTfe.FloatNum;
    interval.y:=interval.y+dTfe.FloatNum;
    inc(i);
  end;
end;

Function GetAngel(u1,u2,u3:double; var a:double; var d:double):boolean;
var
  tg, cos, sin, module, module1, err:double;
begin
  tg:=(2*u1+u2)/(sqrt3*u2);
  cos:=sqrt(1/(1+tg*tg));
  sin:=tg*cos;
  // U12=a(sina-sin(a+120))->a=u12/(1.5sina-sqrt3/2*cosa)
  module:=u1/(1.5*sin-cos*sin60);
  // U31 = a*(sin240-sina)
  module1:=module*(-1.5*sin-cos*sin60);
  Err:=abs((abs(u3)-abs(module1))/module);
  result:=Err<c_Threshold;
  if result then
  begin
    a:=module;
    d:=radtodeg(arctan(tg));
    exit;
  end;

  // проверяем отрицательный cos
  cos:=-cos;
  sin:=-sin;
  // U12=a(sina-sin(a+120))->a=u12/(1.5sina-sqrt3/2*cosa)
  module:=u1/(1.5*sin-cos*sqrt3/2);
  // U31 = a*(sin240-sina)
  module1:=module*(-1.5*sin-cos*sin60);
  Err:=abs((abs(u3)-abs(module1))/module);
  result:=Err<c_Threshold;
  if result then
  begin
    a:=module;
    d:=radtodeg(arctan(tg));
    exit;
  end;
end;

procedure TSelsinFrm.Eval3(s: cselsin);
var
  sig:iwpsignal;
  mod1, SKO1,SKO2,SKO3, Sect, iQuad, resSignal:iwpsignal;

  u1,u2,u3,
  tg, cos, sin,
  phase1, phase2, phase3, deg, addDeg, Module:double;
  // нельзя использовать в 2 и 4 секторах
  b:boolean;

  interval, time:point2d;
  i,quad, sectr, sectr1: Integer;

  // ошибка по амплитуде
  aErr,
  // ошибка по углу
  dErr:double;
begin

  SKO1:=GetSKOTrend(s.l1.Signal, dtFe.FloatNum);
  SKO2:=GetSKOTrend(s.l2.Signal, dtFe.FloatNum);
  SKO3:=GetSKOTrend(s.l3.Signal, dtFe.FloatNum);
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

  // модули
  mod1:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;

  Sect:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  iQuad:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;

  //-- помещаем сигнал в дерево
  posbase.winpos.Link('/Signals/Selsin', s.name, resSignal as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'mod_1', mod1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'sko_1', sko1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'sko_2', sko2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'sko_3', sko3 as IDispatch);

  posbase.winpos.Link('/Signals/Selsin', s.name+'sect', Sect as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+'quad', iQuad as IDispatch);


  posbase.winpos.Refresh();
  //-- зададим длину сигнала
  resSignal.size:= round((time.y-time.x)/dTfe.FloatNum);
  resSignal.DeltaX:=dTfe.FloatNum;

  sect.size:= round((time.y-time.x)/dTfe.FloatNum);
  sect.DeltaX:=dTfe.FloatNum;

  iQuad.size:= round((time.y-time.x)/dTfe.FloatNum);
  iQuad.DeltaX:=dTfe.FloatNum;


  mod1.size:= round((time.y-time.x)/dTfe.FloatNum);
  mod1.DeltaX:=dTfe.FloatNum;

  resSignal.StartX:=time.x;
  // настраиваем шаг обработки
  interval.x:=time.x;
  interval.y:=interval.x+dTfe.FloatNum;
  i:=0;
  while interval.y<time.y do
  begin
    u1:=SKO1.GetY(i);
    u2:=SKO2.GetY(i);
    u3:=SKO3.GetY(i);


    // считаем фазы
    phase1:=GetPhaseDeg(s.l1.Signal,s.exc.Signal,interval);
    phase2:=GetPhaseDeg(s.l2.Signal,s.exc.Signal,interval);
    phase3:=GetPhaseDeg(s.l3.Signal,s.exc.Signal,interval);
    // Вычисляем конечное значение угла по таблице квадрантов
    quad:=GetSect(phase1,phase2,phase3);
    quad:=ShiftSect(quad,s.ShiftSectr);
    case quad of
      0: b:=GetAngel(u1,-u2,u3,module, deg ); // сектор  0, 3
      3: b:=GetAngel(u1,-u2,u3,module, deg ); // сектор  0, 3
      1: b:=GetAngel(-u1,-u2,u3, module, deg ); // сектор  1, 4
      4: b:=GetAngel(-u1,-u2,u3, module, deg ); // сектор  1, 4
      2: b:=GetAngel(-u1,u2,u3, module, deg); // сектор  2, 5
      5: b:=GetAngel(-u1,u2,u3, module, deg); // сектор  2, 5
    end;
    if b then
    begin
      mod1.setY(i,module);
    end;

    resSignal.SetY(i,deg+addDeg);
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
    f.WriteFloat(id,'Ref',s.reference);
    f.WriteString(id,'AutoCalibr',booltostr(s.autocal));
    f.WriteString(id,'commonPoint',booltostr(s.commonPoint));
    f.WriteBool(id,'Selsin',s.bSelsin);
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

    s.bSelsin:= f.readBool(id,'Selsin',false);

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
    s.reference:=f.ReadFloat(id,'Ref',1);
    str:=f.ReadString(id,'AutoCalibr',booltostr(s.autocal));
    if str='1' then
      s.autocal:=true
    else
      s.autocal:=false;
    str:=f.ReadString(id, 'CommonPoint', booltostr(s.commonPoint));
    if str='1' then
      s.commonPoint:=true
    else
      s.commonPoint:=false;
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

Function GetAngelSinCos(u1,u2:double; var a:double; var d:double):boolean;
var
  tg, rad,  lcos, err:double;
begin
  tg:=(u1/u2);
  rad:=ArcTan(tg);
  lcos:=cos(rad);
  a:=u2/lcos;
  d:=RadToDeg(rad);
  result:=true;
end;

Function GetSectSinCos(PSIN, PcOS, asin, acos:double):integer;
var
  lThreshold:double;
begin
  lThreshold:=5*c_degtorad;
  if (pcos>=lThreshold) and (psin>=lThreshold) then
    result:=0;
  if (pcos<=lThreshold) and (psin>=lThreshold) then
    result:=1;
  if (pcos<=lThreshold) and (psin<=lThreshold) then
    result:=2;
  if (pcos>=lThreshold) and (psin<=lThreshold) then
    result:=3;
end;


procedure TSelsinFrm.EvalSinCos(s: cselsin);
var
  sig:iwpsignal;
  mod1, SKO1,SKO2, Sect, iQuad, resSignal, ip1,ip2, ip1p2:iwpsignal;

  u1,u2,u3,
  tg, cos, sin,
  phase1, phase2, p1p2,deg, addDeg, Module:double;
  // нельзя использовать в 2 и 4 секторах
  b:boolean;

  interval, time:point2d;
  i,quad, sectr, sectr1: Integer;

  // ошибка по амплитуде
  aErr,
  // ошибка по углу
  dErr:double;
begin
  SKO1:=GetSKOTrend(s.l1.Signal, dtFe.FloatNum);
  SKO2:=GetSKOTrend(s.l2.Signal, dtFe.FloatNum);
  // выбираем интервал обработки
  time.x:=SKO1.minx;
  if time.x<SKO2.minx then
    time.x:=SKO2.minx;
  time.y:=SKO1.maxx;
  if time.y>SKO2.maxx then
    time.y:=SKO2.maxx;

  if time.x<s.Exc.signal.minx then
    time.x:=s.Exc.signal.minx;
  if time.y>s.Exc.signal.maxx then
    time.y:=s.Exc.signal.maxx;


  resSignal:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;

  // модули
  mod1:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;

  iQuad:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  iQuad.size:= round((time.y-time.x)/dTfe.FloatNum);
  iQuad.DeltaX:=dTfe.FloatNum;

  ip1:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  ip1.size:= round((time.y-time.x)/dTfe.FloatNum);
  ip1.DeltaX:=dTfe.FloatNum;

  ip2:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  ip2.size:= round((time.y-time.x)/dTfe.FloatNum);
  ip2.DeltaX:=dTfe.FloatNum;

  ip1p2:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
  ip1p2.size:= round((time.y-time.x)/dTfe.FloatNum);
  ip1p2.DeltaX:=dTfe.FloatNum;

  //-- помещаем сигнал в дерево
  posbase.winpos.Link('/Signals/Selsin', s.name, resSignal as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+' mod_1', mod1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+' sko_1', sko1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+' sko_2', sko2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+' Quad', iQuad as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+' Phase_1', ip1 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+' Phase_2', ip2 as IDispatch);
  posbase.winpos.Link('/Signals/Selsin', s.name+' p1p2', ip1p2 as IDispatch);

  posbase.winpos.Refresh();
  //-- зададим длину сигнала
  resSignal.size:= round((time.y-time.x)/dTfe.FloatNum);
  resSignal.DeltaX:=dTfe.FloatNum;

  mod1.size:= round((time.y-time.x)/dTfe.FloatNum);
  mod1.DeltaX:=dTfe.FloatNum;

  resSignal.StartX:=time.x;
  // настраиваем шаг обработки
  interval.x:=time.x;
  interval.y:=interval.x+dTfe.FloatNum;
  i:=0;
  while interval.y<time.y do
  begin
    u1:=SKO1.GetY(i);
    u2:=SKO2.GetY(i);

    // считаем фазы
    phase1:=GetPhaseDeg(s.l1.Signal,s.exc.Signal,interval);
    phase2:=GetPhaseDeg(s.l2.Signal,s.exc.Signal,interval);
    p1p2:=GetPhaseDeg(s.l1.Signal,s.l2.Signal,interval);
    if abs(p1p2)<25 then
    begin
      if (phase1>0)<>(phase2>0) then
      begin
        if u1>u2 then
        begin
          phase2:=phase1;
        end
        else
        begin
          phase1:=phase2;
        end;
      end;
    end;

    b:=GetAngelSinCos(u1,u2, module, deg);
    // Вычисляем конечное значение угла по таблице квадрантов
    //if u1/module<c_sinCos_Threshold then
    //begin
    //  phase1:=0;
    //end;
    //if u2/module<c_sinCos_Threshold then
    //begin
    //  phase2:=1;
    //end;
    ip1.setY(i,phase1);
    ip2.setY(i,phase2);
    ip1p2.setY(i,p1p2);

    quad:=GetSectSinCos(phase1,phase2, u1, u2);
    quad:=ShiftSectSinCos(quad,s.shiftsectr);
    //quad:=0;
    iQuad.setY(i,quad);

    adddeg:=0;
    case quad of
      0:adddeg:=0;
      1:deg:=180-deg;
      2:deg:=180+deg;
      3:deg:=360-deg;
    end;
    if b then
    begin
      mod1.setY(i,module);
    end;
    resSignal.SetY(i,deg+addDeg);
    interval.x:=interval.x+dTfe.FloatNum;
    interval.y:=interval.y+dTfe.FloatNum;
    inc(i);
  end;
end;

end.
