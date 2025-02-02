unit uWPservices;

interface
uses
  uCommonMath, classes, sysUtils, uMeraSignal, uBasicTrend, uTrend, uCommonTypes,
  uBuffTrend1d, posbase, Winpos_ole_TLB;

type
  cString =Class
  public
    str:string;
  End;

  cSignalDesc = class
  public
    // ���� � ������� � ������ Win���
    path:string;
    // ������ ��������������� ���������
    i0:integer;
    // �����
    count:integer;
  end;

  // ����� ������������� ������������ ������ ���������
  cSignalsOpt = class
    // ������������ ������������ ��������� ������� �� ����������� �������
    // ���� � ������� � ������ Win��� cSignalOpt
    pathSrcList:tStringlist;
    // ���� � ���������� ����������� ����� � cWPSignal
    pathDstList:tStringlist;
    // ����� �� cWPObject;
    srcSignals:tlist;
  private
    operObj:tobject;
  public
    constructor create(oper:tobject);
    destructor destroy;
    function GetDst(i:integer):string;
    function GetSrcName(i:integer):string;
    procedure addDst(s:string);
    procedure addSrc(s:cSignalDesc);
    function GetSrcStart(i:integer):integer;
    // �������� ����� �� ������
    function GetSignal(i:integer):tobject;
    // �������� ������ ��� ��������� � ������ ���������� ���������� ���������
    //function GetResSignal(i:integer):tobject;
    // ����� �����
    function GetSrcCount(i:integer):integer;
    procedure setoperObj(o:tobject);
  end;

// �������� �� ��������� ��������. ����������� ����� ������ ��������� �
// ��������� '='. ����������� ����� ����������� ;
function FindInPars(pars:tstringlist; key:string; var ind:integer):boolean;
function ParsStrParamNoSort(src:string; separator:string):tstringlist;
function ParsStrParam(src:string):tstringlist;overload;
function ParsStrParam(src:string; separator:string):tstringlist;overload;
function ParsStrParamExt(src:string; separator:string; bracketChar:char):tstringlist;overload;
function ParsToStr(pars:tstringlist):string;
function  updateParams(src:string; newparams:string):string;
procedure ChangeParam(pars:tstringlist; key:string; v:string);
function ChangeParamF(str:string; key:string; v:string):string;
function GetParam(str:string; key:string):string;

// �������� ������ �� ������ �����
function GetParsValue(pars:tstringlist;i:integer):string;overload;
function GetParsValue(pars:tstringlist;key:string):string;overload;
procedure DeleteParsResult(parsres:tstringlist);
// ��� ���������
function GetOperName(parsres:tstringlist):string;
// ������ ���������
function GetOperParams(parsres:tstringlist):string;
// i ����� ��������� ������� ������� � 0
function GetSignalOpts(parsres:tstringlist; i:integer):cSignalsOpt;
// ������� ������� �� ������
function DeleteSpace(src:string):string;

function CreateTrend(tr:ctrend;s:tobject):cbasictrend;overload;
function CreateTrend(tr:cBufftrend1d;s:tobject):cbasictrend;overload;
function intToStrSrv(i:integer):string;
// �������� ��������� ����� � ������ ������
function GetNumPointsFFT(count:integer):integer;

function getinterval(s:iwpsignal; interval:point2d):iwpsignal;

implementation
uses
  uWPProc;

function ExtractSignalName(s: string): string;
var
  folder: string;
  i: integer;
begin
  result := s;
  for i := length(s) downto 1 do
  begin
    if (s[i] = '\') or (s[i] = '/') then
    begin
      folder := s;
      // -1 �.�. �������� ����
      setlength(folder, i - 1);
      // i+1 �.�. �������� ����
      result := Copy(s, i + 1, length(s) - i);
      break;
    end;
  end;
end;



function DeleteSpace(src:string):string;
var
  I: Integer;
begin
  result:='';
  for I := 1 to length(src) do
  begin
    if src[i]<>' ' then
      result:=result+src[i];
  end;
end;

procedure DeleteParsResult(parsres:tstringlist);
var
  I: Integer;
  obj:cString;
begin
  for I := 0 to parsres.Count - 1 do
  begin
    obj:=cString(parsres.Objects[i]);
    obj.Destroy;
  end;
  parsres.Destroy;
end;

function GetOperName(parsres:tstringlist):string;
var
  o, p:string;
  i:integer;
  res:cString;
begin
  res:=nil;
  if parsres.find('o',i) then
  begin
    res:=cstring(parsres.objects[i]);
  end;
  if res<>nil then
    result:=res.str
  else
    result:='';
end;

function GetParsValue(pars:tstringlist;i:integer):string;
var
  res:cString;
begin
  res:=cstring(pars.objects[i]);
  result:=res.str;
end;

function GetParsValue(pars:tstringlist;key:string):string;
var
  i:integer;
begin
  if findinpars(pars, key, i) then
  begin
    result:=cstring(cstring(pars.objects[i])).str;
  end
  else
    result:='_';
end;

function GetOperParams(parsres:tstringlist):string;
var
  o, p:string;
  i:integer;
  res:cString;
begin
  if parsres.find('p',i) then
  begin
    res:=cstring(parsres.objects[i]);
  end;
  result:=res.str;
end;

function intToStrSrv(i:integer):string;
begin
  result:=inttostr(i);
  if length(result)=1 then
  begin
    result:='00'+result;
  end
  else
  begin
    if length(result)=2 then
    begin
      result:='0'+result;
    end;
  end;
end;

// i ����� ���������
// paramNumber - ����� ������� ������ ����� ���������
// ��������� - �������� ���������
function GetSignalOpts(parsres:tstringlist; i:integer):cSignalsOpt;
var
  srcKey1:string;
  str, strInt:string;
  ind, paramNumber:integer;
  s:cSignalDesc;
begin
  paramNumber:=1;
  result:=nil;
  strInt:=intToStrSrv(i);
  while paramnumber>0 do
  begin
    srcKey1:='s'+inttostr(paramNumber)+'_';
    srcKey1:=srcKey1+strInt;
    // ������
    str:=GetParsValue(parsres,srckey1);
    if (str<>'') and (str<>'_') then
    begin
      //str:=DeleteChars(str,'"');
      if result=nil then
        result:=cSignalsOpt.Create(nil);
      s:=cSignalDesc.Create;
      s.path:=str;
      // ������ ���������
      srcKey1:='i'+inttostr(paramNumber)+'_'+strInt;
      str:=GetParsValue(parsres,srckey1);
      if str<>'' then
        s.i0:=strtoint(str);
      // ����� ���������
      srcKey1:='c'+inttostr(paramNumber)+'_'+strInt;
      str:=GetParsValue(parsres,srckey1);
      if str<>'' then
        s.count:=strtoint(str);
      Result.pathSrcList.AddObject(s.path, s);
      inc(paramnumber);
    end
    else
      paramnumber:=0;
  end;
  if result=nil then
    exit;
  paramNumber:=1;
  while paramnumber>0 do
  begin
    // ���������
    srcKey1:='d'+inttostr(paramNumber)+'_'+strInt;
    str:=GetParsValue(parsres,srckey1);
    if str<>'' then
    begin
      if str='_' then
      begin
        break;
      end;
      Result.pathDstList.Add(str);
      inc(paramnumber);
    end
    else
    begin
      str:='<src>';
      Result.pathDstList.Add(str);
      inc(paramnumber);
      //paramnumber:=0;
    end;
  end;
end;

function  updateParams(src:string; newparams:string):string;
var
  p, p1:tstringlist;
  I, j: Integer;
  key:string;
  cstr, cstr1:cstring;
begin
  p:=ParsStrParamNoSort(newparams, ',');
  p1:=ParsStrParamNoSort(src, ',');
  for I := 0 to p.Count - 1 do
  begin
    key:=p.Strings[i];
    cstr:=cstring(p.Objects[i]);
    if FindInPars(p1,key, j) then
    begin
      cstr1:=cstring(p1.Objects[j]);
      cstr1.str:=cstr.str;
    end
    else
    begin
      cstr1:=cString.Create;
      cstr1.str:=cstr.str;
      p1.AddObject(key,cstr1);
    end;
  end;
  result:=ParsToStr(p1);
  p.Destroy;
  p1.Destroy;
end;

function GetParam(str:string; key:string):string;
var
  p:tstringlist;
  ind:integer;
  cstr:cstring;
begin
  p:=ParsStrParamNoSort(str, ',');
  if FindInPars(p,key,ind) then
  begin
    cstr:=cstring(p.Objects[ind]);
    result:=cstr.str;
  end;
  p.Destroy;
end;

function ChangeParamF(str:string; key:string; v:string):string;
var
  p:tstringlist;
  ind:integer;
  cstr:cstring;
begin
  p:=ParsStrParamNoSort(str, ',');
  if FindInPars(p,key,ind) then
  begin
    cstr:=cstring(p.Objects[ind]);
    cstr.str:=v;
  end;
  str:=ParsToStr(p);
  result:=str;
  p.Destroy;
end;

procedure ChangeParam(pars:tstringlist; key:string; v:string);
var
  ind:integer;
  cstr:cstring;
begin
  if FindInPars(pars,key,ind) then
  begin
    cstr:=cstring(pars.Objects[ind]);
    cstr.str:=v;
  end;
end;

function ParsToStr(pars:tstringlist):string;
var
  v:cstring;
  I: Integer;
begin
  result:='';
  for I := 0 to pars.Count - 1 do
  begin
    v:=cstring(pars.Objects[i]);
    if i<>pars.Count - 1 then
      result:=result+pars.Strings[i]+'='+v.str+','
    else
      result:=result+pars.Strings[i]+'='+v.str;
  end;
end;

function ParsStrParamExt(src:string; separator:string; bracketChar:char):tstringlist;
var
  i,j,p:integer;
  str, param:string;
  Value:cString;
begin
  i:=0;
  result:=tstringlist.Create;
  result.Sorted:=true;
  while i<=length(src) do
  begin
    str:=GetSubStringExt(src,separator,i, bracketChar,i);
    if str<>'' then
    begin
      p:=pos('=',str);
      if p>0 then
      begin
        param:=DeleteSpace(GetSubStringExt(str,'=',1,bracketChar,j));
        value:=cString.Create;
        value.str:=deleteOuterBracket(GetSubStringExt(str,separator,j+1,bracketChar,j),'"');
        Result.addobject(param, value);
      end;
    end;
    if i=-1 then
      break;
    i:=i+1;
  end;
end;

function FindInPars(pars:tstringlist; key:string; var ind:integer):boolean;
var
  I: Integer;
begin
  ind:=-1;
  result:=false;
  for I := 0 to pars.Count - 1 do
  begin
    if pars.strings[i]=key then
    begin
      result:=true;
      ind:=i;
      exit;
    end;
  end;
end;

function ParsStrParamNoSort(src:string; separator:string):tstringlist;
var
  i,j,p:integer;
  str, param:string;
  Value:cString;
begin
  i:=0;
  result:=tstringlist.Create;
  while i<=length(src) do
  begin
    str:=GetSubString(src,separator,i, i);
    if str<>'' then
    begin
      p:=pos('=',str);
      if p>0 then
      begin
        param:=DeleteSpace(GetSubString(str,'=',1,j));
        value:=cString.Create;
        value.str:=deletechars(GetSubString(str,separator,j+1,j),'"');
        Result.addobject(param, value);
      end;
    end;
    if i=-1 then
      break;
    i:=i+1;
  end;
end;

function ParsStrParam(src:string; separator:string):tstringlist;overload;
var
  i,j,p:integer;
  str, param:string;
  Value:cString;
begin
  i:=0;
  result:=tstringlist.Create;
  result.Sorted:=true;
  while i<=length(src) do
  begin
    str:=GetSubString(src,separator,i, i);
    if str<>'' then
    begin
      p:=pos('=',str);
      if p>0 then
      begin
        param:=DeleteSpace(GetSubString(str,'=',1,j));
        value:=cString.Create;
        value.str:=deletechars(GetSubString(str,separator,j+1,j),'"');
        Result.addobject(param, value);
      end;
    end;
    if i=-1 then
      break;
    i:=i+1;
  end;
end;

function ParsStrParam(src:string):tstringlist;
var
  i,j,p:integer;
  str, param:string;
  Value:cString;
begin
  i:=0;
  result:=tstringlist.Create;
  result.Sorted:=true;
  while i<=length(src) do
  begin
    if src[i]='p' then
    begin
      if src[i+1]='=' then
      begin
        str:=GetSubString(src,'"',i+3, i);
        str:='p="'+str+'"';
        inc(i);
      end;
    end
    else
    begin
      str:=GetSubString(src,';',i, i);  // i �������� �� ����� �����������
    end;
    if str<>'' then
    begin
      p:=pos('=',str);
      if p>0 then
      begin
        param:=DeleteSpace(GetSubString(str,'=',1,j));
        value:=cString.Create;
        // ���� ����� ��� ��� � ������� �� "____"
        //value.str:=deletechars(GetSubString(str,';',j+1,j),'"');
        value.str:=deletechars(GetSubStringExt(str,';',j+1,'"',j),'"');
        Result.addobject(param, value);
        if i=-1 then
          break;
      end;
    end;
    i:=i+1;
  end;
end;

constructor cSignalsOpt.create(oper:tobject);
begin
  operObj:=oper;
  pathSrcList:=tStringlist.Create;
  pathDstList:=tStringlist.Create;
  // ����� �� cWPObject;
  srcSignals:=tlist.Create;
end;

destructor cSignalsOpt.destroy;
var
  i:integer;
begin
  if operObj<>nil then
  begin
    for i:=0 to coperobj(operObj).SrcCount-1 do
    begin
      if coperobj(operObj).GetSignalsOpts(i)=self then
      begin
        coperobj(operObj).srclist.Delete(i);
        break;
      end;
    end;
  end;
  pathSrcList.destroy;
  pathDstList.destroy;
  srcSignals.destroy;
end;

function cSignalsOpt.GetDst(i:integer):string;
begin
  if i<pathDstList.count then
  begin
    result:=pathDstList.Strings[i];
    if result='<src>' then
    begin
      result:='/Signals/Results/'+ExtractSignalName(GetSrcName(i))+'_';
    end
    else
    begin
      if pos('Signals',result)<1 then
      begin
        result:='/Signals/Results/'+ExtractSignalName(result);
      end;
    end;
  end
  else
    result:='';
end;

function cSignalsOpt.GetSrcName(i:integer):string;
begin
  result:=cSignalDesc(pathSrcList.Objects[i]).path;
end;

procedure cSignalsOpt.addDst(s:string);
var
  signal:cwpSignal;
  src:csrc;
begin
  pathDstList.Add(s);
  //signal:=cWPSignal.create;
  //signal.name:=s;
  // �������������� ���� �� 18.03.15 (���������� � Src ������� ����������)
  //src:=coperobj(operObj).GetSrc;
  //if src<>nil then
  //begin
    // ��������� ������ ��������
    //src.AddObject(signal.fname, signal);
  //end;
end;

procedure cSignalsOpt.addSrc(s:cSignalDesc);
begin
  pathSrcList.AddObject(s.path,s);
end;

function cSignalsOpt.GetSrcStart(i:integer):integer;
begin
  result:=cSignalDesc(pathSrcList.Objects[i]).i0;
end;


function cSignalsOpt.GetSrcCount(i:integer):integer;
begin
  result:=cSignalDesc(pathSrcList.Objects[i]).count;
end;

procedure cSignalsOpt.setoperObj(o:tobject);
begin
  operObj:=o;
end;

function cSignalsOpt.GetSignal(i:integer):tobject;
begin
  result:=tobject(srcSignals.Items[i]);
end;

//function cSignalsOpt.GetResSignal(i:integer):tobject;
//var
//  s:iwpsignal;
//  o:cwpsignal;
//  start, intervalcount:cardinal;
//begin
//  o:=cwpsignal(getsignal(i));
//  if defaultTime then
//  begin
//    start:=cSignalOpt(pathSrcList.Objects[i]).i0;
//    intervalcount:=cSignalOpt(pathSrcList.Objects[i]).count;
//    s:=wp.GetInterval(o.node.Reference ,start,intervalcount) as iwpsignal;
//  end
// else
//  begin
//
//  end;
//end;

function getinterval(s:iwpsignal; interval:point2d):iwpsignal;
var
  i:integer;
begin
  i:=s.IndexOf(interval.x);
  result:=wp.GetInterval(s ,i,s.IndexOf(interval.y)-i) as iwpsignal;
end;

function CreateTrend(tr:cBuffTrend1d;s:tobject):cbasictrend;
var
  sig:cwpsignal;
  //x,y:olevariant;
  i:integer;
begin
  sig:=cwpsignal(s);
  tr.Count:=sig.count;
  tr.dx:=sig.Signal.DeltaX;
  for I := 0 to tr.Count - 1 do
  begin
    tr.AddPoint(sig.Signal.GetY(i), i);
  end;
  //i:=sig.count;
  //sig.Signal.GetArray(0, i, x, y,true);
  //tr.data_r:=y;
end;

function CreateTrend(tr:ctrend;s:tobject):cbasictrend;
var
  i:integer;
  dx:single;
begin
  for I := 0 to cwpsignal(s).count - 1 do
  begin
    tr.addpoint(cwpsignal(s).GetP2(i));
  end;
end;

function GetNumPointsFFT(count:integer):integer;
var
  i, i2:integer;
begin
  i:=2;
  while count>i do
  begin
    i2:=i*2;
    if i2>count then
    begin
      result:=i;
      exit;
    end;
    i:=i2;
  end;
end;


end.
