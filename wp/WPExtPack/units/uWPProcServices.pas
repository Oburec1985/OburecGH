unit uWPProcServices;

interface
uses
  uCommonMath, classes, sysUtils, uMeraSignal, uBasicTrend, uTrend, uCommonTypes,
  uBuffTrend1d, posbase, Winpos_ole_TLB;

type

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



// ��� ���������
function GetOperName(parsres:tstringlist):string;
// ������ ���������
function GetOperParams(parsres:tstringlist):string;
// i ����� ��������� ������� ������� � 0
function GetSignalOpts(parsres:tstringlist; i:integer):cSignalsOpt;

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
      if checkstr(str) then
        s.i0:=strtoint(str);
      // ����� ���������
      srcKey1:='c'+inttostr(paramNumber)+'_'+strInt;
      str:=GetParsValue(parsres,srckey1);
      if checkstr(str) then
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
