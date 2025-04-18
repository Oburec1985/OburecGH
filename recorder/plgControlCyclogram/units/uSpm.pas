unit uSpm;

interface

uses
  classes, Windows, tags, uBaseObj, uBaseObjMng, activeX, nativexml, uRCFunc,
  pluginclass, blaccess, sysutils, uCommonTypes, uFFT,
  //ap, fft,
  uHardwareMath,
  urecorderevents, uCommonMath, uMyMath, mathfunction, math, u2dmath, uBaseAlg,
  complex, urctags;

type

  cSpm = class(cSrcAlg)
  public
    min: point2d;
    max: point2d;
    minmax_i: tpoint;
    // �������� ��� �� ��������� ���������� �� ���� (evalblock)
    // m_rmsValue:double;
    // ���������� ��� � ��������� ����������� �������� ������
    // m_EvalBlockTag:itag;
    m_EvalBlockTag: cfiletag;

    // �������� ������ � ������ ������� (������ ���������)
    m_magI1, m_magI2: array of double;
    // �������� ������ � ������ �������������� 0 - ��� ���������, 1 - 1 �����������, 2 - ����������
    m_I: integer;
    // �������� ������ � ������ ������� (������ ���������)
    m_ReIm1, m_ReIm2: array of TComplex_d;

    // ���������� ����������� ������ �������
    m_ReadyBlockCount: integer;
    // ������� ���
    m_tag: cTag;
  public
    // ������ ������������� tCmxArray_d(cmplx_resArray.p)
    cmplx_resArray,
    // ��� �� ����� �� ��� ����������
    mid_cmplx_resArray: TAlignDCmpx;

    // ���� ������ �� �������� ���� ������. �� �������� �� m_spmData, �.�. ����� ��������� ���������� ������
    // �� ��� ���� �� ����������� ���������� �� 16 ������ �� �� ��������� �������� SSE ��������
    m_EvalBlock: TAlignDarray;
    // ������ �������� (�� �����!!! �� ���)
    m_rms: TAlignDarray;
  protected
    // timestamp �������� �������/ ��������� �����
    m_BlockTime: array of double;
    // ������ ���������� �������� � m_BlockTime
    m_BlockTimeInd: integer;
    m_opts: string;
    m_outTag: cTag;
    FFTProp: TFFTProp;
    // ����� ����� fft, ����� ������ �� ������� ���� ������ ��������,
    m_fftCount,
    m_ZoomOrd,
    m_blockcount,
    // ���������� ������ m_overflowP=(1/ 2^m_overflow)
    m_overflow, m_overflowP: integer;
    // ���������� �������
    m_spmdx: double;
    m_addNulls,
    m_Zoom: boolean;
    // ����
    fWnd: PWndFunc;
  private
    // ����������� ������� ����� �� �������� ���� ������
    // ������ ������� ���������
    fdx: double;
    // ������ ������ �� ������� ���� ������ (dt*fs)
    m_portionsize: integer;
    // ������ ����� �� �������� ���� ������ fft. ���� �� ��������� ������ �� ����� m_fftCount*m_blockcount
    // ����� �������� ������ � ����� ����� m_fftCount*m_blockcount-fNullsPoints
    fOutSize,
    // ���������� �������� ����������� ������
    fNullsPoints,
    // ����� ����� �� ������� ���������� �������� ��� ���� ����� ������� ����� ���� (�� ����� fOutSize ���� ���� ����������)
    fShift: cardinal;
  protected
    function getrestype: integer;
    procedure setrestype(i: integer);
    procedure setWnd(s: string);
    // ������ ���������
    procedure evalMinMax;
    procedure doOnStart; override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    procedure saveTags(node: txmlNode); override;
    procedure LoadTags(node: txmlNode); override;
    procedure settag(str: string); overload;
    procedure settag(t: itag); overload;
    // ��������� ������ � ����� ��������� doUpdateTags
    procedure doGetData; override;
    procedure doEval(intag: cTag; time: double);
    function Getdx: double; override;
    // ������ fdx, foutsize, fnullpoints, fshift, fftcount
    // ���� p_dx =-1 �� ���������� ������ dx �� ��������� ���������� ������ ��� ���������� ������
    // ����� p_blockcount ������������ � ���������� ������ ���������� p_blockcount/ ����� ���������� �����
    procedure evalOutSize(p_overflow: integer; p_fftCount: integer;
      p_blockcount: integer; p_dx: double);
    function GetResName: string; override;
    procedure SetResName(s: string); override;
    function getCreateOutTag: boolean;
    procedure setCreateOutTag(b: boolean);
  public
    // ��������� ���
    procedure SetUseScaleData(b:boolean);
    procedure SetScaleData(pscale:pdoublearray);
    function GetWndFunc: PWndFunc;
    function GetWndType: TWndType;
    function GetWndStr: string;
    function GetProperties: string; override;
    function getExtProp: string; override;
    procedure SetProperties(str: string); override;
    function genTagName: string; override;
    procedure setfirstchannel(t: itag); override;
  public
    procedure updateOutChan; override;
    // ���������� ��� �������� ��� ��� ��������� �������� ����
    procedure createOutChan; override;
    procedure createOutChan(name: string); override;
    property restype: integer read getrestype write setrestype;
    procedure doStopRecord;
    property CreateOutTag: boolean read getCreateOutTag write setCreateOutTag;
    function getIndByX(x: double): integer;
    function LastBlockTime: double;
    function GetPeriod: double;
    procedure UpdatePropStr; override;
    procedure setinptag(t: itag); overload;
    procedure setinptag(t: cTag); overload;
    function ready: boolean; override;
    // ���������� ��� �� ������ � �������
    function SpmDx: double;
    class function getdsc: string; override;
    constructor create; override;
    destructor destroy; override;
  end;

implementation

uses
  uCounterAlg, uTahoAlg, uGrmsAlg, uGrmsSrcAlg, uPhaseAlg, uFillingFactorAlg,
  uSynchroPhaseAlg;

const
  C_SpmOpts = 'FFTCount=256,Overflow=0,dX=-1,BCount=1,Addnull=0';
  c_Rect = 'Rect';
  c_Hann = 'Hann';
  c_Hamming = 'Hamming';
  c_Blackmann = 'Blackman';
  c_Flattop = 'Flattop';

  { cSpm }

constructor cSpm.create;
begin
  inherited;
  // ������ ������ � ��������
  fdx := -1;
  m_blockcount := 1;
  m_overflow := 0;
  m_addNulls := false;
  m_fftCount := 256;
  m_properties := C_SpmOpts;
  m_outTag := cTag.create;
  m_outTag.m_createOutTag := false;
end;

destructor cSpm.destroy;
begin
  if m_EvalBlockTag <> nil then
  begin
    m_EvalBlockTag.destroy;
    m_EvalBlockTag := nil;
  end;

  FreeMemAligned(m_EvalBlock);
  m_EvalBlock.p := nil;

  FreeMemAligned(cmplx_resArray);
  cmplx_resArray.p := nil;

  FreeMemAligned(mid_cmplx_resArray);
  cmplx_resArray.p := nil;

  FreeMemAligned(m_rms);
  m_rms.p := nil;

  m_tag.destroy;
  m_tag := nil;

  m_outTag.destroy;
  m_outTag := nil;
  inherited;
end;

procedure cSpm.evalMinMax;
var
  i: integer;
  x, y: double;
begin
  minmax_i.x := 0;
  minmax_i.y := 0;

  min.x := tdoubleARRAy(m_rms.p)[0];
  min.y := tdoubleARRAy(m_rms.p)[0];
  max := min;
  for i := 1 to length(tdoubleARRAy(m_rms.p)) - 1 do
  begin
    x := i * m_spmdx;
    y := tdoubleARRAy(m_rms.p)[i];
    if y > max.y then
    begin
      max.y := y;
      max.x := x;
      minmax_i.y := i;
    end
    else
    begin
      if y < min.y then
      begin
        min.y := y;
        min.x := x;
        minmax_i.x := i;
      end;
    end;
  end;
end;

procedure cSpm.evalOutSize(p_overflow: integer; p_fftCount: integer;
  p_blockcount: integer; p_dx: double);
var
  i, bCount: integer;
  f: double;
begin
  m_fftCount := p_fftCount;
  m_blockcount := p_blockcount;
  m_overflow := p_overflow;
  fdx := p_dx;
  m_spmdx := m_tag.tag.GetFreq / m_fftCount;
  if m_Zoom then
  begin
    m_spmdx:=m_spmdx/Power(2,m_ZoomOrd);
  end;
  if (fdx = -1) or (not m_addNulls) then
  begin
    fOutSize := m_fftCount * m_blockcount;
    // ������ ���������� ������
    m_overflowP := fOutSize;
    fShift := fOutSize;
    for i := 0 to m_overflow - 1 do
    begin
      m_overflowP := m_overflowP shr 1;
      fShift := fOutSize - m_overflowP;
    end;
    fdx := fShift / m_tag.tag.GetFreq;
    fNullsPoints := 0;
  end
  else
  // � ������ ��������� ������������� ����� �������� ������ ���� ������ ������
  // ������ ����� ����� fft
  begin
    fOutSize := round(p_dx * m_tag.tag.GetFreq);
    fShift := fOutSize;
    m_blockcount := trunc(fOutSize / m_fftCount);
    if m_blockcount = 0 then
    begin
      fNullsPoints := (m_fftCount * (m_blockcount + 1) - fOutSize);
      fOutSize := m_fftCount;
    end
    else
    begin
      fNullsPoints := 0;
      fOutSize := m_fftCount * m_blockcount;
    end;
  end;
  m_portionsize := fOutSize - fNullsPoints;
  bCount := trunc(m_tag.m_ReadSize / (fOutSize - fNullsPoints));

  if fOutSize <> 0 then
    f := fOutSize
  else
    f := 1;
  f := m_tag.freq;

  setlength(m_BlockTime, bCount * 2);
  GetMemAlignedArray_d(fOutSize, m_EvalBlock);
  GetMemAlignedArray_cmpx_d(m_fftCount, cmplx_resArray);
  GetMemAlignedArray_cmpx_d(m_fftCount, mid_cmplx_resArray);

  // ���������� ������ �����������, ������� 1/2 �����
  GetMemAlignedArray_d(m_fftCount shr 1, m_rms);

  setlength(m_magI1, m_fftCount shr 1);
  setlength(m_magI2, m_fftCount shr 1);
  setlength(m_ReIm1, m_fftCount shr 1);
  setlength(m_ReIm2, m_fftCount shr 1);

  if c_debugAlg then
  begin
    if m_EvalBlockTag = nil then
    begin
      m_EvalBlockTag := cfiletag.create(name + '_evBlock', f);
    end
    else
    begin
      m_EvalBlockTag.name := name + '_evBlock';
      m_EvalBlockTag.freq := f;
    end;
    m_EvalBlockTag.setBlock(fOutSize, m_EvalBlock.p);
  end;
  FFTProp := GetFFTPlan(m_fftCount);
  FFTProp.m_Zoom:=m_Zoom;
  FFTProp.m_Zoomord:=m_Zoomord;
end;

procedure cSpm.doEval(intag: cTag; time: double);
var
  ar: tdoubleARRAy;
  // ����� ��������������� ����� � ������� �������� ������
  procBlock,
  // ���������� ������� ������
  bCount, len, startind, endind: integer;
  v, dt: double;
  // ����� ����������� ��� ���������� ������
  NCopy, copycount: integer;
  // ��������� ������ ��� ���������� �������� ������ ������ �����
  copyBlocks: boolean;
  knorm, k: double;
  i, j: integer;
begin
  // ���� ������ ����� ��� ������� ������ ��� ���-�� ������� �������������� ������
  procBlock := 0;
  copycount := fOutSize - fNullsPoints;
  if copycount = 0 then
    exit;

  bCount := trunc(m_tag.lastindex / copycount);
  while procBlock < bCount do
  begin
    // �������� ������� ������ � �������� �����
    // source dest count
    /// Error???
    move(m_tag.m_ReadData[fShift * procBlock], m_EvalBlock.p^,
      copycount * sizeof(double));

    dt := 1 / intag.freq;
    if m_EvalBlockTag <> nil then
    begin
      if m_EvalBlockTag.recordState then
        m_EvalBlockTag.saveBlock(intag.m_ReadDataTime + (dt)
            * fShift * procBlock);
    end;
    FFTProp.startind := 0;
    begin
      ar := tdoubleARRAy(m_rms.p);
      // FFTAnalysis(TArrayValues(m_EvalBlock.p), tarrayValues(ar), m_fftCount, AlignBlockLength(m_rms));
      j := 0;
      while FFTProp.startind < copycount do
      begin
        if fWnd <> nil then
        begin
          fft_al_d_sse(tdoubleARRAy(m_EvalBlock.p), tCmxArray_d(cmplx_resArray.p), FFTProp, fWnd);
        end
        else
        begin
          fft_al_d_sse(tdoubleARRAy(m_EvalBlock.p), tCmxArray_d(cmplx_resArray.p), FFTProp);
        end;
        if FFTProp.startind = 0 then
        begin
          move(cmplx_resArray.p^, mid_cmplx_resArray.p^,
            m_fftCount * sizeof(TComplex_d));
        end
        else
        begin
          for i := 0 to m_fftCount - 1 do
          begin
            tCmxArray_d(mid_cmplx_resArray.p)[i] := tCmxArray_d
              (mid_cmplx_resArray.p)[i] + tCmxArray_d(cmplx_resArray.p)[i];
          end;
        end;
        FFTProp.startind := FFTProp.startind + m_fftCount;
        inc(j);
      end;

      // NormalizeAndScaleSpmMag(TCmxArray_d(cmplx_resArray.p), TDoubleArray(m_rms.p));
      // wnd.scale ������� �� ���� ����
      if fWnd = nil then
        k := 1 / (FFTProp.PCount shr 1)
      else
        k := fWnd.acf / (FFTProp.PCount shr 1);
      if j > 1 then
        k := k / j; // ���������� �������
      MULT_SSE_al_cmpx_d(tCmxArray_d(mid_cmplx_resArray.p), k);
      EvalSpmMag(tCmxArray_d(mid_cmplx_resArray.p), tdoubleARRAy(m_rms.p));
      // ���������� � ������ ���������� ������
      if fNullsPoints = 0 then
      begin
        knorm := 1;
      end
      else
      begin
        knorm := fOutSize / copycount;
        MULT_SSE_al_d(tdoubleARRAy(m_rms.p), knorm);
      end;
      // ������ ����������� ��������
      if m_I > 0 then
      begin
        if m_I = 1 then
        begin
          knorm := 1 / (TwoPi * m_spmdx);
          for i := 1 to length(m_magI1) - 1 do
          begin
            k := knorm / i;
            m_magI1[i] := k * tdoubleARRAy(m_rms.p)[i];
          end;
        end
        else
        begin
          knorm := 1 / (TwoPi * m_spmdx * TwoPi * m_spmdx);
          for i := 1 to length(m_magI2) - 1 do
          begin
            k := knorm / i;
            m_magI2[i] := k * tdoubleARRAy(m_rms.p)[i];
          end;
        end;
      end;
      evalMinMax;
    end;

    m_BlockTime[procBlock] := intag.m_ReadDataTime + fdx * procBlock;
    m_BlockTimeInd := procBlock;
    if m_outTag.tag <> nil then
    begin
      m_outTag.tag.PushDataEx(m_rms.p, AlignBlockLength(m_rms), 0,
        m_BlockTime[procBlock]);
    end;
    inc(m_ReadyBlockCount);
    CallUpdateDataEvent;
    inc(procBlock);
  end;
  if procBlock > 0 then

    CallEndEvalBlock;
end;

function cSpm.getIndByX(x: double): integer;
begin
  if m_spmdx <> 0 then
  begin
    result := trunc(x / m_spmdx);
    if result>=(m_fftCount shr 1) then
    begin
      result:=(m_fftCount shr 1)-1;
    end;
  end
  else
  begin
    result := 0;
  end;
end;

procedure cSpm.doGetData;
var
  i, BufCount, newBlockCount, blCount, readyBlockCount, blSize, blInd,
    writeBlockSize: integer;
  tare: boolean;
  timeinterval: double;
begin
  if m_tag.block = nil then
    exit;

  if m_tag <> nil then
  begin
    if m_tag.UpdateTagData(true) then
    begin
      doEval(m_tag, m_tag.m_ReadDataTime);
      m_tag.ResetTagData(m_portionsize);
    end;
  end;
end;

procedure cSpm.doOnStart;
var
  i: integer;
  t: cTag;
begin
  inherited;
  if not ready then
    exit;
  if m_tag <> nil then
  begin
    m_tag.doOnStart;
  end
  else
  begin

  end;
  if m_outTag <> nil then
  begin
    m_outTag.doOnStart;
  end;
  ZeroMemory(m_EvalBlock.p, fOutSize * sizeof(double));
  ZeroMemory(m_rms.p, (m_fftCount shr 1) * sizeof(double));

  m_ReadyBlockCount := 0;
  m_BlockTimeInd := 0;

  if m_EvalBlockTag <> nil then
  begin
    if not m_EvalBlockTag.recordState then
    begin
      if g_merafile <> '' then
        m_EvalBlockTag.StartRecord(g_merafile);
    end;
  end;
end;

procedure cSpm.doStopRecord;
begin
  if m_EvalBlockTag <> nil then
  begin
    m_EvalBlockTag.StopRecord;
  end;
end;

function cSpm.getCreateOutTag: boolean;
begin
  result := m_outTag.m_createOutTag;
end;

procedure cSpm.setCreateOutTag(b: boolean);
begin
  m_outTag.m_createOutTag := b;
end;

class function cSpm.getdsc: string;
begin
  result := '������';
end;

function cSpm.Getdx: double;
begin
  result := fdx;
end;

procedure cSpm.UpdatePropStr;
var
  pars: tstringlist;
  b: boolean;
  t: itag;
  refcount: integer;
  str: string;
begin
  pars := tstringlist.create;
  addParam(pars, 'FFTCount', inttostr(m_fftCount));
  addParam(pars, 'Overflow', inttostr(m_overflow));
  addParam(pars, 'dX', floattostr(fdx));
  addParam(pars, 'BCount', floattostr(m_blockcount));
  addParam(pars, 'FFTresype', inttostr(restype));
  if m_tag <> nil then
  begin
    if m_tag.tagname <> '' then
    begin
      addParam(pars, 'Channel', m_tag.tagname);
      str := m_tag.tagname + '_Spm';
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
      addParam(pars, 'OutChannel', str);
    end;
  end;
  m_properties := ParsToStr(pars);
  delpars(pars);
  pars.destroy;
end;

procedure cSpm.SetProperties(str: string);
var
  lstr: string;
  t: itag;
  changed: boolean;
begin
  // inherited;
  m_properties := updateParams(m_properties, str, '', ' ');
  changed := false;
  // FFTCount=256,Overflow=0,dx=-1,blockcount=1
  lstr := GetParam(str, 'FFTCount');
  if CheckStr(lstr) then
  begin
    if strtoInt(lstr) <> m_fftCount then
    begin
      m_fftCount := strtoInt(lstr);
      changed := true;
    end;
  end;
  lstr := GetParam(str, 'FFTrestype');
  if CheckStr(lstr) then
  begin
    if strtoInt(lstr) <> restype then
    begin
      restype := strtoInt(lstr);
      changed := true;
    end;
  end;
  lstr := GetParam(str, 'Wnd');
  if CheckStr(lstr) then
  begin
    if lstr <> GetWndStr then
    begin
      setWnd(lstr);
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
  lstr := GetParam(str, 'Zoom');
  if CheckStr(lstr) then
  begin
    if strtoboolext(lstr) <> m_Zoom then
    begin
      changed := true;
      m_Zoom := strtoboolext(lstr);
      FFTProp.m_zoom:=m_Zoom;
    end;
  end;
  lstr := GetParam(str, 'ZoomOrd');
  if CheckStr(lstr) then
  begin
    if strtointext(lstr) <> m_ZoomOrd then
    begin
      changed := true;
      m_ZoomOrd := strtoIntExt(lstr);
      FFTProp.m_ZoomOrd:=m_ZoomOrd;
    end;
  end;
  lstr := GetParam(str, 'dX');
  if CheckStr(lstr) then
  begin
    if strtofloatext(lstr) <> fdx then
    begin
      changed := true;
      if lstr <> '0' then
        fdx := strtofloatext(lstr);
    end;
  end;
  lstr := GetParam(str, 'BCount');
  if CheckStr(lstr) then
  begin
    m_blockcount := strtoInt(lstr);
  end;
  lstr := GetParam(str, 'Channel');
  if CheckStr(lstr) then
  begin
    if m_tag = nil then
    begin
      m_tag := cTag.create;
      t := getTagByName(lstr);
      setinptag(t);
      changed := true;
    end;
    if ChangeCTag(m_tag, lstr) then
      changed := true;
  end;
  lstr := GetParam(str, 'OutChannel');
  if CheckStr(lstr) then
  begin
    m_outTag.tagname := lstr;
  end;
  lstr := GetParam(str, 'Overflow');
  if CheckStr(lstr) then
  begin
    m_overflow := strtoInt(lstr);
  end;
  if changed then
  begin
    updateOutChan;
  end;
  DoSetProperties(self);
end;

function cSpm.GetPeriod: double;
begin
  result := fdx;
end;

function cSpm.GetProperties: string;
begin
  if m_properties = '' then
    m_properties := C_SpmOpts;
  result := m_properties;
end;

function cSpm.getExtProp: string;
begin
  result := '';
  if m_tag <> nil then
    result := 'Channel=' + m_tag.tagname;
  if m_outTag <> nil then
    result := result + ',OutChannel=' + m_outTag.tagname;
end;

function cSpm.LastBlockTime: double;
begin
  if m_ReadyBlockCount = 0 then
    result := -1
  else
    result := m_BlockTime[m_BlockTimeInd];
end;

procedure cSpm.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
var
  str: string;
begin
  inherited;
  str := xmlNode.ReadAttributeString('ResName', resname);
  updateOutChan;
  if m_outTag.tag = nil then
  begin
    m_outTag.tagname := str;
  end;
end;

procedure cSpm.SaveObjAttributes(xmlNode: txmlNode);
begin
  inherited;
  xmlNode.WriteAttributeString('ResName', resname);
end;

procedure cSpm.LoadTags(node: txmlNode);
var
  tnode: txmlNode;
  i: integer;
  t: cTag;
begin
  tnode := node.FindNode('InputTag');
  if tnode <> nil then
  begin
    t := loadTag(tnode, m_tag);
    setinptag(t);
  end;
end;

function cSpm.ready: boolean;
begin
  result := false;
  if m_tag = nil then
    exit;
  if fOutSize = 0 then
    updateOutChan;

  if m_tag.tag <> nil then
  begin
    result := true;
  end
  else
  begin
    m_tag.tag := getTagByName(m_tag.tagname);
    if m_tag.tag <> nil then
    begin
      updateOutChan;
      result := true;
    end;
  end;
end;

procedure cSpm.setrestype(i: integer);
begin
  if i < 3 then
  begin
    m_I := i;
  end
  else
  begin
    m_I := i - 3;
  end;
end;

procedure cSpm.SetScaleData(pscale: pdoublearray);
begin
  FFTProp.m_scaleCurve:=pscale;
end;

procedure cSpm.SetUseScaleData(b:boolean);
begin
  FFTProp.m_useScaleCurve:=b;
end;

function cSpm.getrestype: integer;
begin
  case m_I of
    0:
      result := 0;
    1:
      result := 1;
    2:
      result := 2;
  end;
end;

function cSpm.GetWndFunc: PWndFunc;
begin
  result := fWnd;
end;

function cSpm.GetWndStr: string;
begin
  if fWnd = nil then
    result := c_Rect
  else
  begin
    case fWnd.wndtype of
      wdRect:
        result := c_Rect;
      wdHann:
        result := c_Hann;
      wdHamming:
        result := c_Hamming;
      wdBlackman:
        result := c_Blackmann;
      wdFlattop:
        result := c_Flattop;
    end;
  end;
end;

function cSpm.GetWndType: TWndType;
begin
  if fWnd = nil then
    result := wdRect
  else
    result := fWnd.wndtype;
end;

function cSpm.GetResName: string;
begin
  if m_outTag.tag <> nil then
    result := m_outTag.tag.getname
  else
    result := m_outTag.tagname;
end;

procedure cSpm.SetResName(s: string);
var
  pstr: pansichar;
  b: boolean;
begin
  m_outTag.tagname := s;
  if m_outTag.tag <> nil then
  begin
    ecm(b);
    pstr := lpcstr(StrToAnsi(s));
    m_outTag.tag.setname(pstr);
    lcm;
  end;
end;

procedure cSpm.saveTags(node: txmlNode);
var
  tnode: txmlNode;
  t: cTag;
begin
  t := m_tag;
  if t <> nil then
  begin
    tnode := getNode(node, 'InputTag');

    saveTag(t, tnode);
  end;
end;

// ���� ���������� ��� �������� ������ �� ����������� ��� ��������� ������, � ����� � ���
// ���������� ��� �������� ��� ��� ��������� �������� ����
procedure cSpm.createOutChan;
var
  bl: IBlockAccess;
  // ������� ��������� ������� (���������� ��������� ����� ��������� �������)
  outfreq: double;
begin
  createOutChan(genTagName);
end;

procedure cSpm.createOutChan(name: string);
var
  bl: IBlockAccess;
  // ������� ��������� ������� (���������� ��������� ����� ��������� �������)
  outfreq: double;
begin
  if CreateOutTag then
  begin
    if m_tag <> nil then
    begin
      if m_tag.tag <> nil then
      begin
        // ecm;
        outfreq := m_fftCount / m_tag.tag.GetFreq;
        m_outTag.tag := createVectorTagR8(name, outfreq, false, true, false);
        if not FAILED(m_outTag.tag.QueryInterface(IBlockAccess, bl)) then
        begin
          m_outTag.block := bl;
          bl := nil;
        end;
        // lcm;
      end;
    end;
  end
  else
  begin
    m_outTag.tagname := name;
  end;
end;

function cSpm.genTagName: string;
var
  tagname: string;
begin
  tagname := m_tag.tagname;
  result := tagname + '_spm';
end;

procedure cSpm.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  lstr: string;
  bl: IBlockAccess;

  changeCfgMode, b: boolean;
begin
  changeCfgMode := false;
  if m_tag = nil then
  begin
    m_errors.add('cSpm.updateOutChan ������� ��� �� ������:');
    exit;
  end;
  if m_tag.tag = nil then
  begin
    m_tag.tag := getTagByName(m_tag.tagname);
    if m_tag.tag = nil then
    begin
      m_errors.add('cSpm.updateOutChan ����������� ������� ���: ' +
          m_tag.tagname);
      exit;
    end;
  end;
  if m_outTag.tag = nil then
  begin
    changeCfgMode := ecm(b);
    lstr := genTagName;
    b := true;
    while b do
    begin
      t := getTagByName(lstr);
      if t = nil then
      begin
        b := false;
      end
      else
        lstr := ModName(lstr, false);
    end;
    createOutChan(lstr);
    if m_outTag.tag <> nil then
      m_outTag.tagname := lstr;
    if changeCfgMode then
      lcm;
  end
  else
  begin
    changeCfgMode := ecm;
    if resname = '' then
    begin
      str := lpcstr(StrToAnsi(genTagName));
    end
    else
    begin
      str := lpcstr(StrToAnsi(resname));
    end;
    if m_outTag <> nil then
    begin
      m_outTag.freq := m_fftCount shr 1;
      if m_outTag.tag <> nil then
      begin
        m_outTag.tag.setname(str);
        if not FAILED(m_outTag.tag.QueryInterface(IBlockAccess, bl)) then
        begin
          m_outTag.block := bl;
        end;
      end;
    end;

    if changeCfgMode then
      lcm;
  end;
  evalOutSize(m_overflow, m_fftCount, m_blockcount, fdx);
end;

procedure cSpm.setfirstchannel(t: itag);
var
  lstr: string;
begin
  setinptag(t);
  lstr := GetParam(m_properties, 'Channel');
  if m_tag <> nil then
  begin
    m_properties := AddParamF(m_properties, 'Channel', m_tag.tagname);
    if lstr = '' then
    begin
      name := genTagName;
    end;
  end;
end;

procedure cSpm.setinptag(t: cTag);
begin
  m_tag := t;
  setinptag(t.tag);
end;

procedure cSpm.setinptag(t: itag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;
  if m_tag = nil then
  begin
    m_tag := cTag.create;
  end;
  m_tag.tag := t;
  if not FAILED(t.QueryInterface(IBlockAccess, bl)) then
  begin
    m_tag.block := bl;
    bl := nil;
  end;
  if m_outTag = nil then
    createOutChan
  else
  begin
    // ��������� ������ � setprops � � loadprops
    // updateOutChan;
  end;
end;

procedure cSpm.settag(t: itag);
begin
  m_tag.settag(t);
  if m_tag.tagname <> m_outTag.tagname then
  begin
    m_outTag.tagname := m_tag.tagname;
  end;
  if t <> nil then
  begin

  end;
end;

procedure cSpm.setWnd(s: string);
begin
  if s = c_Rect then
  begin
    fWnd := GetFFTWnd(m_fftCount, wdRect);
  end;
  if s = c_Hann then
  begin
    fWnd := GetFFTWnd(m_fftCount, wdHann);
  end;
  if s = c_Hamming then
  begin
    fWnd := GetFFTWnd(m_fftCount, wdHamming);
  end;
  if s = c_Blackmann then
  begin
    fWnd := GetFFTWnd(m_fftCount, wdBlackman);
  end;
  if s = c_Flattop then
  begin
    fWnd := GetFFTWnd(m_fftCount, wdFlattop);
  end;
end;

function cSpm.SpmDx: double;
begin
  result := m_spmdx;
end;

procedure cSpm.settag(str: string);
var
  t: itag;
begin
  t := getTagByName(str);
  settag(t);
end;

end.
