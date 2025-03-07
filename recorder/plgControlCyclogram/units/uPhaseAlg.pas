unit uPhaseAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml, ucommontypes, uFFT,
  //Ap,
  uSpm, uHardwareMath, complex,
  pluginclass, sysutils;

type
  PhaseRecord = record
    r:double;
    im:double;
    // �����
    time:double;
    // ������� ������
    freq:double;
  end;

  cPhaseAlg = class(cbasealg)
  public
    m_Taho: cTag;
    m_InTag: cTag;
    // ������� ������� �����
    m_spm: cspm;
    m_tahoSpm: cspm;
  protected
    m_numGarm:integer;
    // ����� �������� ��� ���������� ����� �������� ������
    m_blockind,
    // ����� ����������� ����� ������ ����� �������� ������
    pCount: integer;
    // ������ ������ � ������������� �������� �� ������� �������� ���������
    m_bandwidth: double;
    fdX: double;
    m_outTag: cTag;
    // �������� ��������� ��� ���/���. ������ ��������������� � m_outTag.m_TagData
    // (�.�. �������� m_TagData ������������� �������� � m_outTagX)
    m_outTagX: array of double;
  // ��������������� ��� ������� ����� ����������
  private
    // ������ ������ � ������������� �������� �� ������� ���������/ ���������� ������
    m_band: point2d;
    // ������������� ���������������� ������� ������� ������ ������� - ��. updateBandWidth
    m_bandwidthint: tpoint;
    sumRe,sumIm,
    sumReTaho,sumImTaho:double;
    // x - �����, y - �������� arcTg
    alfa,alfaTaho:array of point2d;
    // ������ � UpdateBandWidth (doeval)
    m_curTahoValue: double;
    // ������ ���������� �� ������� �������� � ��������� ������
    m_lastblockind:integer;
  protected
    procedure updateSpmByTagsAndCreate;
    procedure updateSpmByTags;
    function  Getdx: double; override;
    procedure doAfterload; override;
    procedure SetProperties(str: string); override;
    function  GetProperties: string; override;
    procedure doOnStart; override;
    function genTagName: string;override;
    procedure doUpdateSrcData(sender: tobject); override;
    procedure doEndEvalBlock(sender: tobject); override;
    // ���� ���������� ��� �������� ������ �� ����������� ��� ��������� ������, � ����� � ���
    // ���������� ��� �������� ��� ��� ��������� �������� ����
    procedure createOutChan;
    procedure updateOutChan;
    procedure updatedx;
    procedure updateBuff;
    function getinptag: itag;
    procedure setTahoTag(t: itag);
    procedure setinptag(t: itag); overload;
    procedure setinptag(t: cTag); overload;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure LoadTags(node: txmlNode); override;
    function ready: boolean; override;
  public
    function lasttime:double;
    constructor create; override;
    class function getdsc: string; override;
  end;

const
  sqrt2 = 1.4142135623730950488016887242097;
  C_PhaseOpts = 'FFTCount=256, Bandwidth=0.1, dX=0.1';
  // ������� � �������� ������ ������� ������� ��� ���� ������ ������
  c_mindT=0.0001;

implementation

{ cPhaseAlg }

constructor cPhaseAlg.create;
begin
  inherited;
  m_numGarm:=1;
  Properties := C_PhaseOpts;
end;



procedure cPhaseAlg.doUpdateSrcData(sender: tobject);
var
  // ������ � ����������� ������� ������� ������� �� ����
  I: integer;
  res: double;
  s: cspm;
  // updatetaho
  t1, t2, x: double;
  bandwidthint, startind, endind, spmInd: integer;
begin
  if sender = m_tahoSpm then
  begin
    // ������������� ������ �� �������� �������� ����
    if m_numGarm <> 0 then
    begin
      x := m_tahoSpm.max.x;
      x := x * m_numGarm;
      m_curTahoValue := x;
      // ���������� �������� � ������� �� ������� ���������
      startind := round(x * m_band.x / m_spm.dX);
      endind := round(x * m_band.y / m_spm.dX);
    end
    else
    begin
      startind := round(m_band.x / m_spm.dX);
      endind := round(m_band.x / m_spm.dX);
    end;
    if startind < 0 then
      startind :=   0;
    if endind = startind then
      endind := startind + 1;
    if endind >= (AlignBlockLength(m_spm.m_rms)) then
      endind := AlignBlockLength(m_spm.m_rms) - 1;
    m_bandwidthint.x := startind;
    m_bandwidthint.y := endind;


    sumReTaho := 0;
    sumImTaho := 0;
    spmInd := round(x / s.dX);
    startind := spmInd - bandwidthint;
    // ������ �������� alglib ���������� ������
    if startind < 1 then
      startind := 1;
    endind := spmInd + bandwidthint;
    if endind >= (AlignBlockLength(s.m_rms)) then
      endind := AlignBlockLength(s.m_rms) - 1;

    for I := startind to endind - 1 do
    begin
      sumReTaho := sumReTaho + TCmxArray_d(s.cmplx_resArray.p)[I].re;
      sumImTaho := sumImTaho + TCmxArray_d(s.cmplx_resArray.p)[I].im;
    end;
    alfaTaho[m_blockind].y := ArcTan(sumImTaho / sumReTaho)*c_radtodeg;
  end;
  if sender = m_spm then
  begin
    // ������������� ������ �� �������� �������� ����
    s := m_spm;

    sumRe := 0;
    sumIm := 0;
    for I := startind to endind - 1 do
    begin
      sumRe := sumRe + TCmxArray_d(s.cmplx_resArray.p)[I].re;
      sumIm := sumIm + TCmxArray_d(s.cmplx_resArray.p)[I].im;
    end;
    alfa[m_blockind].y := ArcTan(sumIm / sumRe) * c_radtodeg;

    m_outTag.m_TagData[m_blockind] := sqrt(res);
    //m_outTag.m_TagData[m_blockind] := m_spm.m_rmsValue;
    m_outTagX[m_blockind] := m_spm.LastBlockTime;
    inc(m_blockind);
    if m_blockind = length(m_outTag.m_TagData) then
      doEndEvalBlock(nil);
  end;
  m_outTag.m_TagData[m_blockind] := alfa[m_blockind].y - alfaTaho[m_blockind].y;
end;

procedure cPhaseAlg.doEndEvalBlock(sender: tobject);
var
  I: integer;
  v: double;
  lastTime:double;
begin
  pCount := m_blockind;
  m_blockind := 0;
  lastTime:=-1;
  if length(m_outTag.m_TagData) = 1 then
  begin
    // m_outTag.tag.PushDataEx(pointer(m_outTag.m_TagData)^,length(m_outTag.m_TagData), 0, m_lastBlockTime);
    m_outTag.tag.PushValue(m_outTag.m_TagData[0], lastTime);
    m_blockind := 0;
    pCount := 0;
  end
  else
  begin
    for I := 0 to pCount - 1 do
    begin
      m_lastblockind := I;
      v := m_outTag.m_TagData[I];
      m_outTag.tag.PushValue(v, m_outTagX[I]);
    end;
    pCount := 0;
  end;
end;

procedure cPhaseAlg.doOnStart;
begin
  inherited;
  pCount := 0;
end;

class function cPhaseAlg.getdsc: string;
begin
  result := '����';
end;

function cPhaseAlg.Getdx: double;
begin
  result:=fdx;
end;

function cPhaseAlg.getinptag: itag;
begin

end;

procedure cPhaseAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;
end;

procedure cPhaseAlg.LoadTags(node: txmlNode);
begin

end;

function cPhaseAlg.ready: boolean;
begin
  result := false;
  if m_Taho <> nil then
  begin
    if m_Taho.tag <> nil then
    begin
      if m_InTag.tag <> nil then
      begin
        if m_spm<>nil then
        begin
          if m_tahoSpm<>nil then
            result := true;
        end;
      end;
    end;
  end;
end;

procedure cPhaseAlg.setinptag(t: cTag);
var
  tagname: string;
  bl: IBlockAccess;
  outfreq: double;
begin
  if m_InTag <> nil then
  begin
    m_InTag.destroy;
  end;
  if t <> m_InTag then
  begin
    m_InTag := t;
    setinptag(t.tag);
  end;
end;

procedure cPhaseAlg.setinptag(t: itag);
var
  bl: IBlockAccess;
  spm: cspm;
begin
  if t = nil then
    exit;
  if m_InTag = nil then
  begin
    m_InTag := cTag.create;
  end;
  m_InTag.tag := t;
  m_InTag.tagname := t.GetName;

  t.GetTagId(m_InTag.ftagid);
  addInputTag(m_InTag);
  if not FAILED(t.QueryInterface(IBlockAccess, bl)) then
  begin
    m_InTag.block := bl;
    bl := nil;
  end;
  if m_outTag = nil then
    createOutChan
  else
    updateOutChan;
end;

procedure cPhaseAlg.doAfterload;
begin
  updateSpmByTagsAndCreate;
end;

procedure cPhaseAlg.setTahoTag(t: itag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;

  if m_Taho = nil then
  begin
    m_Taho := cTag.create;
  end;
  m_Taho.tag := t;
  m_Taho.tagname := t.GetName;
  t.GetTagId(m_Taho.ftagid);

  addInputTag(m_Taho);
  updateOutChan;
end;

function cPhaseAlg.GetProperties: string;
begin
  if m_properties = '' then
    m_properties := C_PhaseOpts;
  result := m_properties;
end;

function cPhaseAlg.lasttime: double;
begin
  result:=m_outTagX[m_lastblockind];
end;

procedure cPhaseAlg.SetProperties(str: string);
var
  lstr: string;
  fftcount: integer;
  t: itag;
begin
  if str = '' then
    exit;
  inherited;
  lstr := GetParam(str, 'dX');
  if lstr <> '' then
  begin
    fdX := strtofloatext(lstr);
  end;

  lstr := GetParam(str, 'FFTCount');
  if lstr <> '' then
  begin
    fftcount := strtoint(lstr);
  end;

  lstr := GetParam(str, 'Bandwidth');
  if lstr <> '' then
  begin
    m_bandwidth := strtofloatext(lstr);
  end;

  lstr := GetParam(str, 'Channel1');
  if lstr <> '' then
  begin
    if m_InTag = nil then
    begin
      m_InTag := cTag.create;
      t := getTagByName(lstr);
      setinptag(t);
    end;
    ChangeCTag(m_InTag, lstr);
  end;

  lstr := GetParam(str, 'Channel2');
  if lstr <> '' then
  begin
    if m_Taho = nil then
    begin
      m_Taho := cTag.create;
      t := getTagByName(lstr);
      setTahoTag(t);
    end;
    ChangeCTag(m_Taho, lstr);
  end;
  updateSpmByTags;
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
  //result.SetFreq(freq);
  // ��� ������������ ������
  VariantClear(v);
  TPropVariant(v).vt := VT_R8;
  // v := VarAsType(v, varDouble);
  result.SetProperty(TAGPROP_DATATYPE, v);
  result.CfgWritable(CfgWritable);
  // ����������� � ������������ �������� ���������
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MINVALUE, v);
  // m_TestVTag.SetProperty(TAGPROP_MINVALUE, v);
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MAXVALUE, v);
  // m_TestWriteVTag.SetProperty(TAGPROP_MAXVALUE, v);
end;

function cPhaseAlg.genTagName: string;
var
  tagname: string;
begin
  tagname := m_InTag.tagname;
  result := tagname + '_Ph';
end;

procedure cPhaseAlg.createOutChan;
var
  tagname: string;
  bl: IBlockAccess;
  outfreq: double;
  inTag: cTag;
  t:itag;
begin
  if inTag <> nil then
  begin
    if inTag.tag <> nil then
    begin
      ecm;
      m_outTag := cTag.create;
      updatedx;
      outfreq := 1 / fdX;
      //m_outTag.tag := createVectorTagR8(genTagName, outfreq, false);
      tagname:=genTagName;
      t:=getTagByName(tagname);
      if t<>nil then
        m_outTag.tag:=t
      else
        m_outTag.tag := createScalar(tagname, false);
      if not FAILED(m_outTag.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        m_outTag.block := bl;
        bl := nil;
      end;
      addOutTag(m_outTag);
      updateBuff;
      lcm;
    end;
  end;
end;

procedure cPhaseAlg.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  bl: IBlockAccess;
  infreq, outfreq: double;
  OutTag: cTag;
begin
  ecm;
  str := lpcstr(StrToAnsi(genTagName));
  m_outTag := OutputTag[0];
  m_outTag.tag.SetName(str);
  updatedx;
  //m_outTag.tag.SetFreq(1 / dX);
  m_outTag.block := nil;
  if not FAILED(m_outTag.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    m_outTag.block := bl;
  end;
  updateBuff;
  lcm;
end;

procedure cPhaseAlg.updateSpmByTags;
begin
  if m_InTag <> nil then
  begin
    if m_InTag.tag <> nil then
    begin
      m_spm := cspm(g_algMng.getSpmByTagName(m_InTag.tagname));
    end;
  end;
  if m_Taho <> nil then
  begin
    if m_Taho.tag <> nil then
    begin
      m_tahoSpm := cspm(g_algMng.getSpmByTagName(m_Taho.tagname));
    end;
  end;
end;

procedure cPhaseAlg.updateSpmByTagsAndCreate;
begin
  if m_InTag <> nil then
  begin
    if m_InTag.tag <> nil then
    begin
      m_spm := cspm(g_algMng.getSpmByTagName(m_InTag.tagname));
      if m_spm = nil then
      begin
        m_spm := cspm.create;
        m_spm.setinptag(m_InTag.tag);
        m_spm.Properties := Properties;
      end;
    end;
  end;
  if m_Taho <> nil then
  begin
    if m_Taho.tag <> nil then
    begin
      m_tahoSpm := cspm(g_algMng.getSpmByTagName(m_Taho.tagname));
      if m_tahoSpm = nil then
      begin
        m_tahoSpm := cspm.create;
        m_tahoSpm.setinptag(m_Taho.tag);
        m_tahoSpm.Properties := Properties;
      end;
    end;
  end;
end;

procedure cPhaseAlg.updatedx;
var
  len: integer;
  ldx:double;
begin
  ldx:=fdx;
  if m_spm<>nil then
  begin
    ldx:=m_spm.dX;
    if m_tahoSpm<>nil then
    begin
      if m_tahoSpm.dx>ldx then
      begin
        ldx:=m_tahoSpm.dx;
      end;
    end;
  end;
  fdX:=ldx;
end;

procedure cPhaseAlg.updateBuff;
var
  len: integer;
  ldx: double;
begin
  len := m_outTag.fBlock.GetBlocksSize;
  setlength(m_outTag.m_TagData, len);
  setlength(m_outTagX, len);
  setlength(alfa, len);
  setlength(alfaTaho, len);
end;

end.
