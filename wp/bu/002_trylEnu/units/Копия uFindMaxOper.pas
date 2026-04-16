unit uFindMaxOper;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, Forms, ActiveX, WPExtPack_TLB, Winpos_ole_TLB, StdVcl, PosBase,
  uFindMaxForm, uWPProc, classes, uCommonTypes;

type
  cAmpFindSignal = class(cWPSignal)
  public
    bands:array of point2;
  end;

  TExtOperAmpFind = class(TAutoObject, IWPExtOper)
  protected
    frm:tFindMaxForm;
    mng:cWPObjmng;
    // список сигналов
    SignalsList:TStringList;
  protected
    procedure Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch); safecall;
    procedure GetError(out pnerrcode: Integer; out perrstr: WideString); safecall;
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
    procedure OnSetup(hwndparent: Integer; out phwnd: Integer); safecall;
    procedure SetPropStr(const str: WideString); safecall;
  public
    function SignalCount:integer;
    function GetSignal(i:integer):cAmpFindSignal;
    procedure linc(p_mng:cWPObjmng);
    procedure AddSignal(s:iwpNode);overload;
    procedure AddSignal(s:iwpSignal);overload;
    Constructor create;
    destructor destroy;
  end;

implementation

uses
  ComServ;

function TExtOperAmpFind.SignalCount:integer;
begin
  result:=SignalsList.Count;
end;

function TExtOperAmpFind.GetSignal(i:integer):cAmpFindSignal;
begin
  result:=cAmpFindSignal(SignalsList.Objects[i]);
end;

procedure TExtOperAmpFind.AddSignal(s:iwpNode);
var
  signal:cwpsignal;
begin
  if IsSignal(s) then
  begin
    signal:=cAmpFindSignal.Create(s);
    SignalsList.AddObject(s.Name,signal);
  end;
end;

procedure TExtOperAmpFind.AddSignal(s:iwpSignal);
begin
  AddSignal(TypeCastToIWNode(winpos.getnode(s)));
end;

Constructor TExtOperAmpFind.create;
begin
  SignalsList:=TStringList.Create;
  SignalsList.Sorted:=true;
end;

destructor TExtOperAmpFind.destroy;
begin
  SignalsList.Destroy;
end;

procedure TExtOperAmpFind.linc(p_mng:cWPObjmng);
begin
  mng:=p_mng;
end;

procedure TExtOperAmpFind.Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);
var src, dst : IWPSignal;
    sz : Integer;
    i, j, k, szbuf, szret : Integer;
    vysrc, vydst : OleVariant; vx : OleVariant;
    y : Double;
begin
  {src:= psrc1 as IWPSignal;
  sz:= src.size;
  dst:= src.Clone(0,0) as IWPSignal;

  //if sz<MAXBUFBUFSIZE then szbuf:= sz else szbuf:= MAXBUFBUFSIZE;
  //vysrc:= VarArrayCreate([0, szbuf-1], varDouble);
  //vydst:= VarArrayCreate([0, szbuf-1], varDouble);

  k:= 0;
  j:= 0;
  src.GetArray(0, szret, vysrc, vx, TRUE);
  for i:= 0 to sz - 1 do
  begin
     y:= vysrc[j];

     // Это только пример, поэтому не будем рассмативать вариант получения
     // мнимого результата при дробном dblPow и отрицательных значениях
     y:= exp( dblPow * ln(abs(y)) );
     if odd(Trunc(dblPow)) and (vysrc[j]<0) then y:=-y;

     vydst[j]:= y;
     Inc(j);

     if (j=szbuf) or (i=(sz-1)) then // буферизация чтения и записи значений
     begin
        dst.SetArray(k*szbuf, szret, vydst, vx, FALSE);
        if i<(sz-1) then
           src.GetArray(k*szbuf, szret, vysrc, vx, TRUE);
        Inc(k);
        j:= 0;
     end;
  end;

  VarClear(vysrc); VarClear(vydst);
  pdst1:= dst;}
end;

procedure TExtOperAmpFind.GetError(out pnerrcode: Integer; out perrstr: WideString);
begin
  pnerrcode:= 0;
end;

procedure TExtOperAmpFind.GetPropStr(out pstr: WideString);
begin
   pstr:= 'GetPropStr';//+ WideStringReplace( , DecimalSeparator, '.', [rfReplaceAll] );
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
    Application.CreateForm(TFindMaxForm, FindMaxForm);
    frm:=FindMaxForm;
    frm.mng:=mng;
    frm.eo:=self;
  end;
  frm.ShowModal;
  phwnd:= frm.Handle;
end;

procedure TExtOperAmpFind.SetPropStr(const str: WideString);
var position  : Integer;
var stra : AnsiString;
begin
  //stra:= str;
  //position:= pos('pow=', stra); Inc(position, 4);
  //if position <> 0 then
  //  dblPow:= StrToFloat( StringReplace( copy(stra, position, length(stra) - position + 1), '.', DecimalSeparator, [rfReplaceAll] ) );
end;

initialization
  TAutoObjectFactory.Create(ComServer, TExtOperAmpFind, Class_ExtOperAmpFind,
    ciSingleInstance, tmApartment);
end.
