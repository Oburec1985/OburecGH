unit uIntegralAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml, math, urctags,
  pluginclass, sysutils;

type
  cIntegralAlg = class(cbasealg)
  protected
    fdt:double;
  protected
    m_FileTag:cFileTag;
    m_FFTfltTag:cFFTFltTag;
    m_FFTShift:integer;

    m_fltType:integer;
    // ����������� ���������
    m_FltReady:boolean;
    m_fltCount:integer;
    m_lastindex:integer;

    // ��� ��� ������ ����� �������� ����������� �� ����
    fflt:double;
    fltLastInd:integer;
    fltbuf:array of double;

    fLo:double;
    flastval, // ��������� �������� � ���������� �����
    fIntegral: double;
    m_InTag: cTag;
    m_OutTag: cTag;
  protected
    procedure doStopRecord;override;

    procedure PushFltVal(v:double);
    // i � ��������� -m_fltCount..+m_fltCount
    function GetFltVal(i:integer):double;
    procedure doFlt;

    procedure setfirstchannel(t: itag); override;
    function setinptag(t: itag): boolean;
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    procedure doOnStart; override;
    procedure doEval(tag: cTag; time: double); override;
    procedure doGetData; override;
    // ���� ���������� ��� �������� ������ �� ����������� ��� ��������� ������, � ����� � ���
    // ���������� ��� �������� ��� ��� ��������� �������� ����
    procedure createOutChan(tname: string);
    procedure updateOutChan;
    function getinptag: itag;
    function genTagName: string;override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    function ready: boolean;override;
  public
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
  end;

const
  C_IntegralOpts = 'Lo=0.0001, FltType=0, FltCount=3';
  c_FFTflt = 2;

implementation

{ cCounterAlg }

constructor cIntegralAlg.create;
begin
  inherited;

  Properties := C_IntegralOpts;
  m_InTag := cTag.create;
  // addInputTag(m_InTag);
  m_outTag := cTag.create;
  m_FFTfltTag:=cFFTFltTag.Create;
  m_FFTfltTag.inTag:=m_intag;
end;

destructor cIntegralAlg.destroy;
begin
  m_InTag.destroy;
  m_InTag := nil;
  m_outTag.destroy;
  m_outTag := nil;
  if m_FileTag<>nil then
  begin
    m_FileTag.Destroy;
  end;
  m_FFTfltTag.Destroy;
  m_FFTfltTag:=nil;
  inherited;
end;

function GetIntegral(v1,v2, dx:double):double;
var
  x:double;
begin
  if v1>0 then
  BEGIN
    if v2>0 then
    begin
      result:=dx*(v1+v2)*0.5;
    end
    else
    begin // v1>0, v2<0
      // ����� ����������� ��� �������
      v2:=abs(v2);
      x:=dx*v1/(v1+v2);
      result:=0.5*(x*v1-(dx-x)*v2);
    end;
  END
  else
  begin
    if v2>0 then // v1<0, v2>0
    begin
      v1:=abs(v1);
      // ����� ����������� ��� �������
      x:=dx*v1/(v1+v2);
      result:=0.5*((dx-x)*v2-x*v1);
    end
    else // v1<0, v2<0
    begin
      v1:=abs(v1);
      v2:=abs(v2);
      result:=dx*(v1+v2)*(-0.5);
    end;
  end;
end;

procedure cIntegralAlg.doEval(tag: cTag; time: double);
var
  I, len: Integer;

begin
  doFlt;
  len := m_lastindex;
  fintegral:=fintegral+GetIntegral(flastval, m_intag.m_ReadData[0], fdt);
  m_OutTag.m_ReadData[0]:=fintegral;
  for I := 1 to len - 1 do
  begin
    if abs(m_intag.m_ReadData[I-1])<flo then
    begin
      if abs(m_intag.m_ReadData[I])<flo then
      begin
        m_OutTag.m_ReadData[i]:=fintegral;
        continue;
      end;
    end;
    fintegral:=fintegral+GetIntegral(m_intag.m_ReadData[i-1], m_intag.m_ReadData[i], fdt);
    m_OutTag.m_ReadData[i]:=fintegral;
  end;
  flastval:=m_intag.m_ReadData[len-1];
  m_OutTag.tag.PushDataEx(pointer(m_outtag.m_ReadData)^, len, 0, time);
end;

procedure cIntegralAlg.doFlt;
var
  k, v:double;
  i, len:integer;
begin
  v:=0;
  case m_flttype of
    0:
      m_lastindex:=m_intag.lastindex;
    1: // ���������� �������
    begin
      k:=1/m_fltCount;
      for I := 0 to len - 1 do
      begin
        // 0 - �������� ������� �������
        if m_fltReady then
        begin
          // ���������� ��������
          v:=GetFltVal(0);
        end;
        if not m_FltReady then
        begin
          PushFltVal(m_intag.m_ReadData[i]);
          if fltLastInd=(m_fltCount) then
          begin
            m_FltReady:=true;
            fflt:=sum(fltbuf);
          end;
        end
        else
        begin
          fflt:=fflt-v;
          fflt:=fflt+m_intag.m_ReadData[i];
          // �������� ������� ������ PushFltVal(m_intag.m_ReadData[i]-k*fflt); ???, �.�. ������ ����������������� ��������
          PushFltVal(m_intag.m_ReadData[i]);
          //PushFltVal(m_intag.m_ReadData[i]-k*fflt);
          m_intag.m_ReadData[i]:=m_intag.m_ReadData[i]-k*fflt;
        end;
      end;
      m_lastindex:=m_intag.lastindex;
    end;
    2: // FFT ������
    begin
      m_lastindex:=m_FFTfltTag.EvalData;
      move(m_FFTfltTag.m_outData[0], m_intag.m_ReadData[0], m_lastindex*sizeof(double));
    end;
  end;
  if m_FileTag <> nil then
  begin
    if m_FileTag.recordState then
      m_FileTag.saveBlock(m_intag.m_ReadDataTime, m_lastindex);
  end;
end;

procedure cIntegralAlg.doGetData;
begin
  if m_InTag.UpdateTagData(true) then
  begin
    if m_InTag.lastindex>m_fltCount then
    begin
      doEval(m_InTag, m_InTag.m_ReadDataTime);
      m_InTag.ResetTagDataTimeInd(m_lastindex);
    end;
  end;
end;

procedure cIntegralAlg.doOnStart;
begin
  inherited;

  fIntegral:=0;

  flastval:=0;
  fltLastInd:=0;
  m_FltReady:=false;

  m_InTag.doOnStart;
  m_outTag.doOnStart;

  if m_FileTag <> nil then
  begin
    if not m_FileTag.recordState then
    begin
      if g_merafile <> '' then
        m_FileTag.StartRecord(g_merafile);
    end;
  end;
end;

procedure cIntegralAlg.doStopRecord;
begin
  if m_FileTag <> nil then
  begin
    m_FileTag.StopRecord;
  end;
end;

class function cIntegralAlg.getdsc: string;
begin
  result := '��������';
end;

function cIntegralAlg.getinptag: itag;
begin

end;

procedure cIntegralAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;
end;


function cIntegralAlg.ready: boolean;
begin
  result:=false;
  if m_intag<>nil then
  begin
    if m_intag.tag<>nil then
    begin
      result:=true;
    end;
  end;
end;

function cIntegralAlg.GetProperties: string;
var
  pars: tstringlist;
  b: boolean;
  t: itag;
  str: string;
begin
  // 'dT=1, Type=0, pCount=1000';
  pars := tstringlist.create;

  addParam(pars, 'FltType', inttostr(m_FltType));
  addParam(pars, 'FltCount', inttostr(m_FltCount));
  if m_FltType=c_FFTflt then
  begin
    addParam(pars, 'FltShift', inttostr(m_FFTShift));
  end;
  addParam(pars, 'Lo', replaceChar(FLOATTOSTR(fLo), ',', '.'));
  if m_InTag.tagname <> '' then
  begin
    addParam(pars, 'Channel', m_InTag.tagname);
    // ���� ��� ���������� �� ����� ��� ��� ����� ������� �����
    if m_outTag.tag <> nil then
    begin
      str := m_outTag.tagname;
    end
    else
    begin
      str := genTagName;
      b := true;
      while b do
      begin
        t := getTagByName(str);
        if ((t = nil) or (t = m_outTag.tag)) then
        begin
          b := false
        end
        else
          str := ModName(str, false);
      end;
    end;
    addParam(pars, 'OutChannel', str);
  end;
  m_Properties := ParsToStr(pars);
  result := m_Properties;
  delpars(pars);
  pars.destroy;
end;

procedure cIntegralAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
  changeOutName, changed: boolean;
begin
  // inherited;
  m_Properties := updateParams(m_Properties, str, '', ' ');
  changed := false;

  lstr := GetParam(str, 'Lo');
  if isValue(lstr) then
  begin
    fLo:=strtofloatext(lstr);
  end;
  lstr := GetParam(str, 'FltType');
  if checkstr(lstr) then
    m_FltType:=StrToInt(lstr);
  if m_FltType=c_FFTflt then
  BEGIN
    lstr := GetParam(str, 'FltShift');
    if checkstr(lstr) then
      m_FFTShift:=StrToInt(lstr);
  END;
  lstr := GetParam(str, 'FltCount');
  if checkstr(lstr) then
  begin
    m_FltCount:=StrToInt(lstr);
    setlength(fltbuf, m_FltCount);
  end;

  lstr := GetParam(str, 'Channel');
  if CheckStr(lstr) then
  begin
    t := getTagByName(lstr);
    if t <> nil then
    begin
      changeOutName := setinptag(t);
    end;
  end;
  lstr := GetParam(str, 'OutChannel');
  if m_outTag <> nil then
  begin
    if m_outTag.tag = nil then
    begin
      if CheckStr(lstr) then
      begin
        // ������� ����� ��� ��� ������������� � �������������
        createOutChan(lstr);
      end
      else
      begin
        lstr := genTagName;
        createOutChan(lstr);
      end;
    end
    else // ���� ��� ����������
    begin
      if changeOutName then
      begin
        m_outTag.tagname := genTagName
      end
      else
      begin
        if CheckStr(lstr) then
        begin
          m_outTag.tagname := lstr;
        end;
      end;
    end;
    updateOutChan;
  end;
  if m_intag<>nil then
  begin
    if m_InTag.tag<>nil then
    begin

    end;
  end;
end;

function createVectorTagR8(tagname: string; freq: double;
  CfgWritable: boolean): itag;
var
  ir: irecorder;
  Name, errMes: string;
  err: cardinal;
  v: OleVariant;
begin
  ir := getIR;
  result := itag(ir.CreateTag(lpcstr(StrToAnsi(tagname)), LS_VIRTUAL, nil));
  if result = nil then // ������ �������� ������������ ����
  begin
    err := ir.GetLastError;
    errMes := ir.ConvertErrorCodeToString(err);
    // showmessage(errMes);
  end;
  // ��������� ���� ���� : ������, ����� � ��������
  VariantInit(v);
  VariantClear(v);
  TPropVariant(v).vt := VT_UI4;
  v := TTAG_VECTOR or TTAG_INPUT;
  result.SetProperty(TAGPROP_TYPE, v);
  // ������� ������
  result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, true);
  VariantClear(v);
  // v := fintag.tag.GetFreq; // ������� ������ �������
  result.SetFreq(freq);
  // ��� ������������ ������
  VariantClear(v);
  TPropVariant(v).vt := VT_R8;
  // v := VarAsType(v, varDouble);
  result.SetProperty(TAGPROP_DATATYPE, v);
  result.CfgWritable(CfgWritable);
end;

function cIntegralAlg.genTagName: string;
var
  tagname: string;
begin
  tagname := m_InTag.tagname;
  result := tagname + '_Intl';
end;

procedure cIntegralAlg.createOutChan(tname: string);
var
  tagname: string;
  bl: IBlockAccess;
  t: itag;
begin
  if m_outTag.tag <> nil then
  begin
    if isalive(m_outTag.tag) then
      exit
    else
      m_outTag.tag := nil;
  end;
  t := getTagByName(tname);
  if t <> nil then
    m_outTag.tag := t
  else
  begin // ������� ���� �� ����������
    ecm;
    m_OutTag := cTag.create;
    m_OutTag.tag := createVectorTagR8(genTagName, m_InTag.tag.getfreq, true);
    if not FAILED(m_OutTag.tag.QueryInterface(IBlockAccess, bl)) then
    begin
      m_OutTag.block := bl;
      bl := nil;
    end;
    lcm;
  end;
end;

procedure cIntegralAlg.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  bl: IBlockAccess;
  blsize:integer;
  p:pointer;
begin
  ecm;
  str := lpcstr(StrToAnsi(genTagName));
  m_OutTag.tag.SetName(str);
  m_OutTag.tag.SetFreq(m_InTag.tag.getfreq);
  m_OutTag.block := nil;
  if not FAILED(m_OutTag.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    m_OutTag.block := bl;
  end;
  blSize := m_InTag.block.GetBlocksSize;
  setlength(m_OutTag.m_TagData, blSize);
  fdt:=1/m_InTag.freq;

  if m_flttype=c_FFTflt then
    m_FFTfltTag.setFFTCount(m_fltCount, m_FFTShift);

  if m_FileTag=nil then
  begin
    m_FileTag:=cFileTag.create( 'FileTag', m_InTag.tag.getfreq);
    ////p:=addr(m_InTag.m_TagData);
    p:=m_InTag.m_ReadData;
    m_FileTag.setBlock(blSize, p);
  end;
  lcm;
end;

procedure cIntegralAlg.setfirstchannel(t: itag);
var
  lstr: string;
  fs: double;
begin
  lstr := GetParam(m_Properties, 'Channel');
  m_InTag.tag := t;
  fs := m_InTag.freq;
  // ����� ����� �� ������ ���������
  m_Properties := AddParamF(m_Properties, 'Channel', m_InTag.tagname);
  if lstr = '' then
  begin
    name := resname;
  end;
end;

procedure cIntegralAlg.PushFltVal(v: double);
var
  ind:integer;
begin
  if fltLastInd=m_fltCount then
  begin
    fltLastInd:=0;
  end;
  ind:=fltLastInd;
  if ind>=m_fltCount then
    ind:=ind-m_fltCount;
  fltbuf[ind]:=v;
  inc(fltLastInd);
end;

function cIntegralAlg.GetFltVal(i: integer): double;
var
  ind:integer;
begin
  ind:=fltLastInd+i;
  if ind>=m_fltCount then
  begin
    if ind<0 then
    begin
      ind:=ind+m_fltCount
    end
    else
    begin
      ind:=ind-m_fltCount;
    end;
  end;
  result:=fltbuf[ind];
end;

function cIntegralAlg.setinptag(t: itag): boolean;
var
  bl: IBlockAccess;
  tname: string;
begin
  result := false;
  if t = nil then
    exit;
  if m_InTag.tag = nil then
  begin
    m_InTag.tag := t;
    if not FAILED(t.QueryInterface(IBlockAccess, bl)) then
    begin
      m_InTag.block := bl;
      bl := nil;
    end;
    // ��� ������� �� ������
    result := false
  end
  else
  begin
    // ���� ������ ������ �� �����
    if m_InTag.tag <> t then
    begin
      m_InTag.tag := t;
      if not FAILED(t.QueryInterface(IBlockAccess, bl)) then
      begin
        m_InTag.block := bl;
        bl := nil;
      end;
      result := true;
    end
    else
    // ���� ����������� ��� �� ��� ��� � ���
    begin
      // �� ������ ��� ������
      result := false;
    end;
  end;
end;

end.
