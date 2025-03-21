unit uSynchroPhaseAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml, ucommontypes, uFFT, Ap, fft,
  dialogs,
  uHardwareMath,
  uSpm,
  complex,
  pluginclass,
  performanceTime,
  uBaseObj,
  sysutils;

type
  PhaseRecord = record
    r: double;
    im: double;
    // �����
    time: double;
    // ������� ������
    freq: double;
  end;

  // �������� ����������� �� cPhaseAlg ��� ��� �� ���������� � �������� ����������
  // ������� ����������� ������ � ���������� ��������� �������, �������������� ����� �� ������� �����
  // � ������� �� ��� �������� ������
  cSyncPhaseAlg = class(cbasealg)
  public
    m_Taho: cTag;
    m_InTag: cTag;
  protected
    fOutIsNew, m_addNulls: boolean;
    // ������ ������ ����� ������ �� ������� ���� ������ (dt*fs) :=fOutSize - fNullsPoints;
    m_portionsize,
    // ������ ����� �� �������� ���� ������ fft. ���� �� ��������� ������ �� ����� m_fftCount*m_blockcount
    // ����� �������� ������ � ����� ����� m_fftCount*m_blockcount-fNullsPoints
    fOutSize,
    // ���������� �������� ����������� ������
    fNullsPoints,
    // ���������� ������ ��� ������� �������
    m_blockcount, m_fftcount: integer;
    // ����� �������� ��� ���������� ����� �������� ������
    m_blockind,
    // ����� ����������� ����� ������ ����� �������� ������
    pCount: integer;
    // ������ ������ � ������������� �������� �� ������� �������� ���������
    m_bandwidth: double;
    // ������ ������, ���.
    fdX: double;
    // ������ ��������� ������, ���.
    fStartPortion: double;
    m_outTag: cTag;

    // �������� ��������� (�������) ��� ���/���. ������ ��������������� � m_outTag.m_TagData
    // (�.�. �������� m_TagData ������������� �������� � m_outTagX)
    m_outTagX: array of double;
  private
    // ��� ������� ���������� �� ������ � ������. ������ ���������� tag.readdata �� ���� ����� ����������� ������
    m_EvalBlock1, m_EvalBlock2: TAlignDarray;
    s1, s2, res: TAlignDCmpx;
    s1_, s2_, res_: TComplex1DArray;
    fftPlan: TFFTProp;

    // ������ ������ � ������������� �������� �� ������� ���������/ ���������� ������
    m_band: point2d;
    // ������������� ���������������� ������� ������� ������ ������� - ��. updateBandWidth
    m_bandwidthint: tpoint;
  protected
    function Getdx: double; override;
    procedure doAfterload; override;
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    function getExtProp: string; override;
    procedure doOnStart; override;
    function genTagName: string; override;
    procedure doEval(tag: cTag; time: double); override;
    procedure doGetData; override;
    // ���� ���������� ��� �������� ������ �� ����������� ��� ��������� ������, � ����� � ���
    // ���������� ��� �������� ��� ��� ��������� �������� ����
    procedure createOutChan;
    procedure updateOutChan;
    procedure updateBuff;
    function getinptag: itag;
    procedure setTahoTag(t: itag);
    procedure setinptag(t: itag); overload;
    procedure setinptag(t: cTag); overload;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    procedure LoadTags(node: txmlNode); override;
    function ready: boolean; override;
    function getresname: string; override;
  public
    procedure setfirstchannel(t: itag); override;
  public
    function lasttime: double;
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
  end;

const
  sqrt2 = 1.4142135623730950488016887242097;
  C_PhaseOpts = 'FFTCount=256, Bandwidth=0.1, dX=0.1';
  // ������� � �������� ������ ������� ������� ��� ���� ������ ������
  c_mindT = 0.0001;

implementation

{ cPhaseAlg }

constructor cSyncPhaseAlg.create;
begin
  inherited;
  m_blockcount := 1;
  Properties := C_PhaseOpts;
  fOutIsNew := false;
  m_InTag := cTag.create;
  m_Taho := cTag.create;
end;

procedure cSyncPhaseAlg.doEval(tag: cTag; time: double);
begin

end;

procedure cSyncPhaseAlg.doGetData;
var
  interval1, interval2: point2d;
  interval_i1, interval_i2: tpoint;
  k, resMag, mag, phase: double;
  i, maxind, bCount, startind1, startind2: integer;
  j, N: integer;

  timer: TPerformanceTime;
  t1, t2: double;
begin
  // ��������� ������
  if m_InTag.UpdateTagData(false) then
  begin
  end;
  interval1 := m_InTag.getPortionTime;
  if m_Taho.UpdateTagData(false) then
  begin
  end;
  interval2 := m_Taho.getPortionTime;
  // ������
  interval1 := getCommonInterval(interval1, interval2);
  if (interval1.y - interval1.x) < fdX then
  begin
{$IFDEF DEBUG}
    // logMessage('cSyncPhaseAlg_noCommonInterval');
{$ENDIF}
    exit;
  end;
  bCount := trunc((interval1.y - interval1.x) / fdX);
  for j := 0 to bCount - 1 do
  begin
    interval2.x := interval1.x + fdX * (j);
    interval2.y := interval2.x + fdX;
    interval_i1 := m_InTag.getIntervalInd(interval2);
    interval_i2 := m_Taho.getIntervalInd(interval2);
    // �������� ������� ������ � �������� �����
    startind1 := interval_i1.x;
    startind2 := interval_i2.x;
    if (startind1 < 0) or (startind2 < 0) then
    begin
{$IFDEF DEBUG}
      // logMessage('cSyncPhaseAlg.doGetData: if (startind1<0) or (startind2<0) then...');
      // logMessage('Interval1'+'x:'+floattostr(interval1.x)+' y:'+floattostr(interval1.y));
      // logMessage('Interval2'+'x:'+floattostr(interval2.x)+' y:'+floattostr(interval2.y));
      // logMessage('m_InTag.m_readDataTime'+floattostr(m_InTag.m_readDataTime));
      // logMessage('m_TahoTag.m_readDataTime'+floattostr(m_InTag.m_readDataTime));
      // logMessage('startind1='+inttostr(startind1));
      // logMessage('startind2='+inttostr(startind2));
{$ENDIF}
      break;
    end;

    if (startind1 + m_portionsize) >= length(m_InTag.m_ReadData) then
    begin
{$IFDEF DEBUG}
      // logMessage('cSyncPhaseAlg.doGetData (startind1+m_portionsize)>=length(m_InTag.m_ReadData)');
      // logMessage('ind: ' + inttostr(startind1));
      // logMessage('m_portionsize: ' + inttostr(m_portionsize));
      // logMessage('length: ' + inttostr(length(m_InTag.m_ReadData)));
{$ENDIF}
      break;
    end;
    move(m_InTag.m_ReadData[startind1], m_EvalBlock1.p^,
      (m_portionsize) * sizeof(double));

    if (startind2 + m_portionsize) >= length(m_Taho.m_ReadData) then
    begin
{$IFDEF DEBUG}
      // logMessage('cSyncPhaseAlg.doGetData (startind2+m_portionsize)>=length(m_Taho.m_ReadData');
      // logMessage('ind: ' + inttostr(startind2));
      // logMessage('m_portionsize: ' + inttostr(m_portionsize));
      // logMessage('length: ' + inttostr(length(m_Taho.m_ReadData)));
{$ENDIF}
      break;
    end;
    /// /////// ALARMA@@@@@@@@
    if startind2 < 0 then
      continue;
    /// / ---------------------------------
    /// / �������� ������� ���������� ������ �� �� ������� ������ � �� ����� ������ ���������!!!!
    move(m_Taho.m_ReadData[startind2], m_EvalBlock2.p^,
      (m_portionsize) * sizeof(double));
    // ������ ������� �������
    k := 2 / m_fftcount;
    // FFTR1D(treal1darray(m_EvalBlock1.p), m_fftcount, TComplex1Darray(s1_));
    // FFTR1D(treal1darray(m_EvalBlock2.p), m_fftcount, TComplex1Darray(s2_));
    fft_al_d_sse(TDoubleArray(m_EvalBlock1.p), tCmxArray_d(s1.p), fftPlan);
    fft_al_d_sse(TDoubleArray(m_EvalBlock2.p), tCmxArray_d(s2.p), fftPlan);

    maxind := 0;
    resMag := 0;
    k := k * k; // �.�. ����������� 2 ����� ������� ����� ����������� � ���������� "K"
    // timer:=TPerformanceTime.create;
    for i := 1 to AlignBlockLength(res) - 1 do
    begin
      // ��� ���������� � WinPos k*s1[i].x, ��� k=(2/fftcount) (���� ���� ��������� � WinPos)
      // res[i].x := k*s1[i].x * k*s2[i].x + k*s1[i].y * k*s2[i].y;
      // res[i].y := k*s1[i].y * k*s2[i].x - k*s1[i].x * k*s2[i].y;
      // ���������� ����������� ���������!!!!
      TComplex1DArray(res.p)[i].x := k *
        (TComplex1DArray(s1.p)[i].x * TComplex1DArray(s2.p)
          [i].x + TComplex1DArray(s1.p)[i].y * TComplex1DArray(s2.p)[i].y);
      TComplex1DArray(res.p)[i].y := k *
        (TComplex1DArray(s1.p)[i].y * TComplex1DArray(s2.p)
          [i].x - TComplex1DArray(s1.p)[i].x * TComplex1DArray(s2.p)[i].y);
      mag := sqrt(TComplex1DArray(res.p)[i].y * TComplex1DArray(res.p)
          [i].y + TComplex1DArray(res.p)[i].x * TComplex1DArray(res.p)[i].x);
      if mag > resMag then
      begin
        resMag := mag;
        maxind := i
      end;
    end;
    // timer.Free;
    phase := arctan(TComplex1DArray(res.p)[maxind].y / TComplex1DArray(res.p)
        [maxind].x) * c_radtodeg;
    if j < length(m_outTagX) then
    begin
      m_outTagX[j] := m_InTag.getReadTime(startind1);
      m_outTag.tag.PushValue(phase, m_outTagX[j]);
    end
    else
      m_outTag.tag.PushValue(phase, -1);
  end;
  // ����� ������� ��������� ������
  m_InTag.ResetTagDataTimeInd(interval_i1.y);
  m_Taho.ResetTagDataTimeInd(interval_i2.y);
end;

procedure cSyncPhaseAlg.doOnStart;
begin
  inherited;
  pCount := 0;
  fStartPortion := -1;

  if m_InTag <> nil then
  begin
    m_InTag.doOnStart;
  end;
  if m_Taho <> nil then
  begin
    m_Taho.doOnStart;
  end;
  if m_outTag <> nil then
  begin
    m_outTag.doOnStart;
  end;
  ZeroMemory(m_EvalBlock1.p, AlignBlockLength(m_EvalBlock1) * sizeof(double));
  ZeroMemory(m_EvalBlock2.p, AlignBlockLength(m_EvalBlock2) * sizeof(double));
end;

class function cSyncPhaseAlg.getdsc: string;
begin
  result := '���� (�����.������)';
end;

function cSyncPhaseAlg.Getdx: double;
begin
  result := fdX;
end;

function cSyncPhaseAlg.getinptag: itag;
begin

end;

procedure cSyncPhaseAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
var
  tnode, tagnode: txmlNode;
begin
  tnode := xmlNode.FindNode('OutputTag');
  if tnode <> nil then
  begin
    tagnode := tnode.FindNode('OutChan');
    if tagnode <> nil then
    begin
      m_outTag := LoadTag(tagnode, m_outTag);
    end;
  end;
  inherited;
end;

procedure cSyncPhaseAlg.LoadTags(node: txmlNode);
begin

end;

function cSyncPhaseAlg.ready: boolean;
begin
  result := false;
  if m_Taho <> nil then
  begin
    if m_Taho.tag = nil then
    begin
      m_Taho.tag := getTagByName(m_Taho.tagname);
    end;
    if m_Taho.tag <> nil then
    begin
      if m_InTag.tag = nil then
      begin
        m_InTag.tag := getTagByName(m_InTag.tagname);
      end;
      if m_InTag.tag <> nil then
      begin
        if m_InTag.freq = m_Taho.freq then
        begin
          result := true;
        end;
      end;
    end;
  end;
end;

procedure cSyncPhaseAlg.SaveObjAttributes(xmlNode: txmlNode);
var
  tnode, tagnode: txmlNode;
  i: integer;
begin
  inherited;
  tnode := getNode(xmlNode, 'OutputTag');
  tagnode := getNode(tnode, 'OutChan');
  saveTag(m_outTag, tagnode);
end;

procedure cSyncPhaseAlg.setfirstchannel(t: itag);
var
  lstr: string;
begin
  setinptag(t);
  lstr := GetParam(m_Properties, 'Channel');
  if m_InTag <> nil then
  begin
    m_Properties := AddParamF(m_Properties, 'Channel', m_InTag.tagname);
    if lstr = '' then
    begin
      name := genTagName;
    end;
  end;
end;

procedure cSyncPhaseAlg.setinptag(t: cTag);
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

procedure cSyncPhaseAlg.setinptag(t: itag);
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

destructor cSyncPhaseAlg.destroy;
begin
  if m_InTag <> nil then
  begin
    m_InTag.destroy;
    m_InTag := nil;
  end;
  if m_Taho <> nil then
  begin
    m_Taho.destroy;
    m_Taho := nil;
  end;
  if m_outTag <> nil then
  begin
    m_outTag.destroy;
    m_outTag := nil;
  end;

  FreeMemAligned(m_EvalBlock1);
  FreeMemAligned(m_EvalBlock2);
  FreeMemAligned(s1);
  FreeMemAligned(s2);
  FreeMemAligned(res);

  m_EvalBlock2.p := nil;
  m_EvalBlock1.p := nil;
  s1.p := nil;
  s2.p := nil;
  res.p := nil;

  inherited;
end;

procedure cSyncPhaseAlg.doAfterload;
begin

end;

procedure cSyncPhaseAlg.setTahoTag(t: itag);
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

function cSyncPhaseAlg.GetProperties: string;
begin
  if m_Properties = '' then
    m_Properties := C_PhaseOpts;
  if parentCfg = nil then
    result := updateParams(m_Properties, getExtProp)
  else // ������ �������� �������� ����� ������ �� �������� updateParams
    result := m_Properties;
end;

function cSyncPhaseAlg.getExtProp: string;
begin
  if m_InTag <> nil then
    result := 'Channel=' + m_InTag.tagname;
  if m_outTag <> nil then
  begin
    result := result + ',OutChannel=' + m_outTag.tagname;
  end;
end;

function cSyncPhaseAlg.getresname: string;
begin
  result := '';
  if m_outTag <> nil then
  begin
    if m_outTag.tag <> nil then
      result := m_outTag.tag.GetName
    else
      result := m_outTag.tagname;
  end;
end;

function cSyncPhaseAlg.lasttime: double;
begin
  result := m_outTagX[m_blockind];
end;

procedure cSyncPhaseAlg.SetProperties(str: string);
var
  lstr: string;
  fftcount: integer;
  t: itag;
  changed: boolean;
begin
  if str = '' then
    exit;
  inherited;
  lstr := GetParam(str, 'dX');
  if CheckStr(lstr) then
  begin
    if strtofloatext(lstr) <> fdX then
    begin
      changed := true;
      fdX := strtofloatext(lstr);
    end;
  end;
  lstr := GetParam(str, 'BCount');
  if CheckStr(lstr) then
  begin
    m_blockcount := strtoInt(lstr);
  end;
  lstr := GetParam(str, 'FFTCount');
  if CheckStr(lstr) then
  begin
    if strtoInt(lstr) <> m_fftcount then
    begin
      m_fftcount := strtoInt(lstr);
      changed := true;
    end;
  end;

  lstr := GetParam(str, 'Addnull');
  if CheckStr(lstr) then
  begin
    if strtoboolext(lstr) <> m_addNulls then
    begin
      changed := true;
      m_addNulls := strtoboolext(lstr);
    end;
  end;

  lstr := GetParam(str, 'Bandwidth');
  if lstr <> '' then
  begin
    m_bandwidth := strtofloatext(lstr);
  end;

  lstr := GetParam(str, 'Channel');
  if CheckStr(lstr) then
  begin
    if m_InTag = nil then
    begin
      m_InTag := cTag.create;
      t := getTagByName(lstr);
      setinptag(t);
    end;
    if ChangeCTag(m_InTag, lstr) then
      changed := true;
  end;

  lstr := GetParam(str, 'Taho');
  if lstr <> '' then
  begin
    if m_Taho = nil then
    begin
      m_Taho := cTag.create;
      t := getTagByName(lstr);
      setTahoTag(t);
    end;
    if ChangeCTag(m_Taho, lstr) then
      changed := true;
  end;

  lstr := GetParam(str, 'OutChannel');
  if CheckStr(lstr) then
  begin
    if m_outTag = nil then
      createOutChan
    else
    begin
      if m_outTag.tag = nil then
        createOutChan;
    end;
    m_outTag.tagname := lstr;
  end;

  if changed then
  begin
    if m_outTag <> nil then
      updateOutChan;
  end;
end;

function cSyncPhaseAlg.genTagName: string;
var
  tagname: string;
begin
  tagname := m_InTag.tagname;
  result := tagname + '_PhaseCr';
end;

procedure cSyncPhaseAlg.createOutChan;
var
  tagname: string;
  bl: IBlockAccess;
  outfreq: double;
  inTag: cTag;
  t: itag;
begin
  if inTag <> nil then
  begin
    if inTag.tag <> nil then
    begin
      ecm;
      fOutIsNew := true;
      m_outTag := cTag.create;
      outfreq := 1 / fdX;
      if m_outTag.tag = nil then
      begin
        m_outTag.tag := createVectorTagR8(genTagName, outfreq, true, false,
          false);
        // m_outTag.tag := createScalar(genTagName, false);
        if m_outTag.tag <> nil then
        begin
          if not FAILED(m_outTag.tag.QueryInterface(IBlockAccess, bl)) then
          begin
            m_outTag.block := bl;
            bl := nil;
          end;
          updateBuff;
        end;
      end;
      lcm;
    end;
  end;
end;

procedure cSyncPhaseAlg.updateOutChan;
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
  if m_outTag <> nil then
  begin
    m_outTag.tagname := str;
    if m_outTag.tag <> nil then
    begin
      m_outTag.tag.SetFreq(1 / fdX);
      m_outTag.block := nil;
      if not FAILED(m_outTag.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        m_outTag.block := bl;
      end;
      updateBuff;
    end;
  end;
  lcm;
end;

procedure cSyncPhaseAlg.updateBuff;
var
  len: integer;
  ldx: double;
begin
  fOutSize := m_blockcount * m_fftcount;
  if m_addNulls then
  begin
    m_portionsize := trunc(fdX * m_InTag.freq);
    fNullsPoints := fOutSize - m_portionsize;
  end
  else
  begin
    fNullsPoints := 0;
    m_portionsize := fOutSize;
  end;
  len := m_outTag.fBlock.GetBlocksSize;

  GetMemAlignedArray_d(fOutSize, m_EvalBlock1);
  GetMemAlignedArray_d(fOutSize, m_EvalBlock2);
  GetMemAlignedArray_cmpx_d(m_fftcount, s1);
  GetMemAlignedArray_cmpx_d(m_fftcount, s2);
  GetMemAlignedArray_cmpx_d(m_fftcount, res);
  fftPlan := getFFTPlan(m_fftcount);

  setlength(m_outTag.m_TagData, len);
  setlength(m_outTagX, len * c_blockCount);
end;

end.
