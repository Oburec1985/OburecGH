// �������� ������� ��� ������� �� ��������� �������
unit uPeakFactorAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml, ucommontypes, uFFT, Ap, uSpm, uMyMath, math,
  uHardwareMath,
  pluginclass, sysutils;

type

  cPeakFactorAlg = class(cbasealg)
  public
    m_InTag: cTag;
  protected
    m_outTag: cTag;
    // ��� ��������� ���������/ ��������� �������
    m_type: integer;
    // ����� ����� ��� ������� ������ ��������
    m_PortionSize: integer;
    m_PortionSizeFFT: integer;
    // ������ ������ ��� ������� � ��������
    m_PortionSize_d: double;
  private
  protected
    // ���������� ��������� - ����� �� �������� ��� ��������� ����
    function setinptag(t: itag): boolean;
    procedure doAfterload; override;
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    function genTagName: string; override;
    procedure createOutChan(tname: string);
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    procedure setfirstchannel(t: itag); override;
  protected
    // ���� �� ����� �� �������� �� �������� doOnStart � doGetData
    function ready: boolean; override;
    procedure doOnStart; override;
    procedure doGetData; override;
    procedure doEval(tag: cTag; time: double); override;
  public
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
  end;

const
  sqrt2 = 1.4142135623730950488016887242097;
  C_ExcessOpts = 'dT=1, Type=0, pCount=1000';
  // ������� � �������� ������ ������� ������� ��� ���� ������ ������
  c_mindT = 0.0001;

implementation

{ cExcessAlg }

procedure cPeakFactorAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
var
  str: string;
begin
  inherited;
end;

procedure cPeakFactorAlg.SaveObjAttributes(xmlNode: txmlNode);
begin
  inherited;
end;

procedure cPeakFactorAlg.setfirstchannel(t: itag);
var
  lstr: string;
  fs: double;
begin
  lstr := GetParam(m_Properties, 'Channel');
  m_InTag.tag := t;
  fs := m_InTag.freq;
  // ����� ����� �� ������ ���������
  m_PortionSize := trunc(fs * GetREFRESHPERIOD);
  m_PortionSize_d := GetREFRESHPERIOD;
  AddParamF(m_Properties, 'dT', FLOATTOSTR(m_PortionSize_d));
  m_Properties := AddParamF(m_Properties, 'Channel', m_InTag.tagname);
  if lstr = '' then
  begin
    name := resname;
  end;
end;

function cPeakFactorAlg.setinptag(t: itag): boolean;
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
    // ��� ������� �� �������
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

constructor cPeakFactorAlg.create;
begin
  inherited;
  Properties := C_ExcessOpts;
  m_InTag := cTag.create;
  // addInputTag(m_InTag);
  m_outTag := cTag.create;
  // addInputTag(m_outTag);
end;

destructor cPeakFactorAlg.destroy;
begin
  m_InTag.destroy;
  m_InTag := nil;
  m_outTag.destroy;
  m_outTag := nil;
  inherited;
end;

procedure cPeakFactorAlg.createOutChan(tname: string);
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
    m_outTag.tag := createScalar(tname, true);
    if not FAILED(m_outTag.tag.QueryInterface(IBlockAccess, bl)) then
    begin
      m_outTag.block := bl;
      bl := nil;
    end;
    lcm;
  end;
end;

procedure cPeakFactorAlg.doAfterload;
begin
  inherited;
end;

procedure cPeakFactorAlg.doEval(tag: cTag; time: double);
var
  i1,i2,I, j, len, blCount: integer;
  m, s, res, d,t, dt: double;
begin
  blCount := tag.lastindex div m_PortionSize;
  if blCount=0 then exit;
  
  dt := 1 / tag.freq;
  // ����� ����� �� �������� �����
  dt := dt * (m_PortionSize shr 1);
  for I := 0 to blCount - 1 do
  begin
    i1:=i*m_PortionSize;
    i2:=i1 + m_PortionSize-1;
    m:=SUM_SSE_d(tag.m_ReadData, i1, i2);
    m:=m/m_PortionSize;
    res:=0;
    s:=0;
    for j := i1 to i2 do
    begin
      d:=abs(tag.m_ReadData[j]-m);
      if d>res then
      begin
        res:=d;
      end;
      s:=s+d*d;
    end;
    s := Sqrt(S / m_PortionSize);
    t := time + dt * I;
    // ��� ������ - ����. ����./ ���
    m_outTag.tag.PushValue(res/s, t);
  end;
end;

procedure cPeakFactorAlg.doGetData;
begin
  m_InTag.UpdateTagData(true);
  doEval(m_InTag, m_InTag.m_ReadDataTime);
  m_InTag.ResetTagData(m_PortionSize);
end;

procedure cPeakFactorAlg.doOnStart;
begin
  inherited;
  m_InTag.doOnStart;
  m_outTag.doOnStart;
end;

function cPeakFactorAlg.genTagName: string;
var
  tagname: string;
begin
  tagname := m_InTag.tagname;
  result := tagname + '_PeakFct';
end;

class function cPeakFactorAlg.getdsc: string;
begin
  result := '��� ������';
end;

function cPeakFactorAlg.GetProperties: string;
var
  pars: tstringlist;
  b: boolean;
  t: itag;
  str: string;
begin
  // 'dT=1, Type=0, pCount=1000';
  pars := tstringlist.create;
  addParam(pars, 'dT', replaceChar(FLOATTOSTR(m_PortionSize_d), ',', '.'));
  addParam(pars, 'Type', inttostr(m_type));
  addParam(pars, 'pCount', inttostr(m_PortionSize));
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

procedure cPeakFactorAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
  changeOutName, changed: boolean;
begin
  // inherited;
  m_Properties := updateParams(m_Properties, str, '', ' ');
  changed := false;

  lstr := GetParam(str, 'dT');
  m_PortionSize_d := strtoFloatExt(lstr);

  lstr := GetParam(str, 'Type');
  if isValue(str) then
    m_type := strtoint(lstr)
  else
    m_type := 0;

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
  end;
  if m_intag<>nil then
  begin
    if m_InTag.tag<>nil then
    begin
      m_PortionSize:=trunc(m_InTag.freq*m_PortionSize_d);
    end;
  end;
end;

function cPeakFactorAlg.ready: boolean;
begin
  result := false;
  if m_InTag.tag <> nil then
  begin
    result := true;
  end;
end;

end.
