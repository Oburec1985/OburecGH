unit uSpm_backup;

interface

uses
  classes, Windows, tags, uBaseObj, uBaseObjMng, activeX, nativexml, uRCFunc,
  pluginclass, blaccess, sysutils, uCommonTypes, uFFT, ap, fft,
  urecorderevents, uCommonMath, uMyMath, mathfunction, math, u2dmath, uBaseAlg;


type


  cSpm = class(cSrcAlg)
  public
    min: point2d;
    max: point2d;
    // �������� ��� �� ��������� ���������� �� ���� (evalblock)
    // m_rmsValue:double;
    // ���������� ��� � ��������� ����������� �������� ������
    // m_EvalBlockTag:itag;
    m_EvalBlockTag: cfiletag;

    m_rms: array of double;
    // �������� ������ � ������ ������� (������ ���������)
    m_magI1, m_magI2: array of double;

    // ����� ������ ����������� �� alglib
    m_rmsTest: array of double;
    cmplx_resArray: array of Complex;
    // �������� ������ � ������ �������������� 0 - ��� ���������, 1 - 1 �����������, 2 - ����������
    m_I:integer;
    // �������� ������ � ������ ������� (������ ���������)
    m_ReIm1, m_ReIm2: array of Complex;

    m_algtype:integer;
    // ���������� ����������� ������ �������
    m_ReadyBlockCount: integer;
    // ������� ���
    m_tag: cTag;
  protected
    // timestamp �������� �������/ ��������� �����
    m_BlockTime: array of double;
    // ������ ���������� �������� � m_BlockTime
    m_BlockTimeInd: integer;

    m_opts: string;
    // ���� ������ �� �������� ���� ������. �� �������� �� m_spmData, �.�. ����� ��������� ���������� ������
    m_EvalBlock: array of double;

    m_outTag: cTag;
    // ����� ����� fft, ����� ������ �� ������� ���� ������ ��������,
    m_fftCount, m_blockcount,
    // ���������� ������ m_overflowP=(1/ 2^m_overflow)
    m_overflow, m_overflowP: integer;
    // ���������� �������
    m_spmdx: double;
    m_addNulls: boolean;
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
    function getrestype:integer;
    procedure setrestype(i:integer);
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
    function GetProperties: string; override;
    procedure SetProperties(str: string); override;
    // ���������� ��� �������� ��� ��� ��������� �������� ����
    procedure createOutChan;overload;
    procedure createOutChan(name:string);overload;
    procedure updateOutChan;
    function genTagName: string; override;
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
    property restype:integer read getrestype write setrestype;
    procedure doStopRecord;
    property CreateOutTag:boolean read getCreateOutTag write setCreateOutTag;
    procedure setfirstchannel(t:itag);override;
    function getIndByX(x: double): integer;
    function LastBlockTime: double;
    function GetPeriod: double;
    procedure UpdatePropStr; override;
    procedure setinptag(t: itag); overload;
    procedure setinptag(t: cTag); overload;
    function ready: boolean; override;
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


{ cSpm }

constructor cSpm.create;
begin
  inherited;
  m_algtype:=c_wiki_spm;
  // ������ ������ � ��������
  fdx := -1;
  m_blockcount := 1;
  m_overflow := 0;
  m_addNulls:=false;
  m_fftCount := 256;
  m_properties:=C_SpmOpts;
  m_outTag := cTag.create;
  m_outTag.m_createOutTag:=false;
end;

destructor cSpm.destroy;
begin
  if m_EvalBlockTag <> nil then
  begin
    m_EvalBlockTag.destroy;
    m_EvalBlockTag := nil;
  end;

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
  min.x := m_rms[0];
  min.y := m_rms[0];
  max := min;
  for i := 1 to length(m_rms) - 1 do
  begin
    x := i * m_spmdx;
    y := m_rms[i];
    if y > max.y then
    begin
      max.y := y;
      max.x := x;
    end
    else
    begin
      if y < min.y then
      begin
        min.y := y;
        min.x := x;
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
  setlength(m_EvalBlock, fOutSize);
  setlength(m_rms, m_fftCount shr 1);
  setlength(m_rmsTest, m_fftCount shr 1);

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
    m_EvalBlockTag.setBlock(fOutSize, m_EvalBlock);
  end;

end;

procedure cSpm.doEval(intag: cTag; time: double);
var
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
  i: integer;
begin
  // ���� ������ ����� ��� ������� ������ ��� ���-�� ������� �������������� ������
  procBlock := 0;
  copycount := fOutSize - fNullsPoints;
  bCount := trunc(m_tag.lastindex / (fOutSize - fNullsPoints));
  while procBlock < bCount do
  begin
    // �������� ������� ������ � �������� �����
    // source dest count
    /// Error???
    move(m_tag.m_ReadData[fShift * procBlock], m_EvalBlock[0],
      copycount * sizeof(double));
    // m_EvalBlockTag.PushDataEx(pointer(m_EvalBlock)^, length(m_EvalBlock), 0, intag.m_ReadDataTime+(1/intag.freq)*fShift * procBlock);
    dt := 1 / intag.freq;
    if m_EvalBlockTag <> nil then
    begin
      if m_EvalBlockTag.recordState then
        m_EvalBlockTag.saveBlock(intag.m_ReadDataTime + (dt)
            * fShift * procBlock);
    end;
    if m_algtype=c_wiki_spm then
    begin
      FFTAnalysis(m_EvalBlock, m_rms, m_fftCount, length(m_rms));
      // ����������
      if fNullsPoints = 0 then
      begin
        knorm := 1;
      end
      else
      begin
        // Knorm:=(m_fftCount)/spmPointCount;
        // Knorm:=2*(m_fftCount)/fOutSize;
        knorm := fOutSize / copycount;
        for i := 0 to length(m_rms) - 1 do
        begin
          m_rms[i] := m_rms[i] * knorm;
        end;
        if m_I>0 then
        begin
          m_magI1[i]:=(k*m_rms[i])/(TwoPi*(i+1)*m_spmdx);
          if m_I>1 then
          begin
            m_magI2[i]:=(m_magI1[i])/(TwoPi*(i+1)*m_spmdx);
          end;
        end;
      end;
      evalMinMax;
    end
    else
    begin
      // ������ � alglib
      FFTR1D(treal1darray(m_EvalBlock), m_fftCount, TComplex1Darray(cmplx_resArray));
      k := 1 / m_fftCount;
      for i := 0 to length(m_rms) - 1 do
      begin
        m_rmsTest[i] := k * sqrt(cmplx_resArray[i].x*cmplx_resArray[i]
            .x + cmplx_resArray[i].y * cmplx_resArray[i].y);
        if m_I>0 then
        begin
          m_ReIm1[i].x:=(k*cmplx_resArray[i].x)/(TwoPi*(i+1)*m_spmdx);
          m_ReIm1[i].y:=(k*cmplx_resArray[i].y)/(TwoPi*(i+1)*m_spmdx);
          if m_I>1 then
          begin
            m_ReIm2[i].x:=(m_ReIm1[i].x)/(TwoPi*(i+1)*m_spmdx);
            m_ReIm2[i].y:=(m_ReIm1[i].y)/(TwoPi*(i+1)*m_spmdx);
          end;
        end;
      end;
    end;
    m_BlockTime[procBlock] := intag.m_ReadDataTime + fdx * procBlock;
    m_BlockTimeInd := procBlock;
    if m_outTag.tag<>nil then
    begin
      m_outTag.tag.PushDataEx(pointer(m_rms)^, length(m_rms), 0,m_BlockTime[procBlock]);
    end;
    inc(m_ReadyBlockCount);
    CallUpdateDataEvent;
    inc(procBlock);
  end;
  CallEndEvalBlock;
end;

function cSpm.getIndByX(x: double): integer;
begin
  result := trunc(x / m_spmdx);
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
  if m_tag <> nil then
  begin
    m_tag.doOnStart;
  end;

  if m_outTag <> nil then
  begin
    m_outTag.doOnStart;
  end;
  ZeroMemory(@m_EvalBlock[0], length(m_EvalBlock) * sizeof(double));

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
  result:=m_outTag.m_createOutTag;
end;

procedure cSpm.setCreateOutTag(b: boolean);
begin
  m_outTag.m_createOutTag:=b;
end;

class function cSpm.getdsc: string;
begin
  result := '������';
end;

function cSpm.Getdx: double;
begin
  result := m_spmdx;
end;

procedure cSpm.UpdatePropStr;
var
  pars: tstringlist;
  b: boolean;
  t: itag;
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
  //inherited;
  m_properties:=updateParams(m_properties, str, '', ' ');
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
    if strtoint(lstr)<> restype then
    begin
      restype:=strtoint(lstr);
      changed:=true;
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
    t := loadTag(tnode);
    setinptag(t);
  end;
end;

function cSpm.ready: boolean;
begin
  result := false;
  if m_Tag.tag <> nil then
  begin
    result := true;
  end;
end;

procedure cSpm.setrestype(i: integer);
begin
  if i<3 then
  begin
    m_algtype:=c_wiki_spm;
    m_i:=i;
  end
  else
  begin
    m_algtype:=c_alglib_cpxSpm;
    m_i:=i-3;
  end;
end;

function cSpm.getrestype: integer;
begin
  if m_algtype= c_wiki_spm then
  begin
    case m_I of
      0: result:=0;
      1: result:=1;
      2: result:=2;
    end;
  end
  else
  begin
    case m_I of
      3: result:=0; // ����������� ����������� ������
      4: result:=1;  // �������� ����������� ������
      5: result:=2; // 2�������� ����������� ������
    end;
  end;
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
begin
  m_outTag.tagname := s;
  if m_outTag.tag <> nil then
  begin
    ecm;
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
    tnode := node.NodeNew('InputTag');
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
  createoutchan(genTagName);
end;

procedure cSpm.createOutChan(name:string);
var
  bl: IBlockAccess;
  // ������� ��������� ������� (���������� ��������� ����� ��������� �������)
  outfreq: double;
begin
  if createOutTag then
  begin
    if m_tag <> nil then
    begin
      if m_tag.tag <> nil then
      begin
        //ecm;
        outfreq := m_fftCount / m_tag.tag.GetFreq;
        m_outTag.tag := createVectorTagR8(name, outfreq, false, true,false);
        if not FAILED(m_outTag.tag.QueryInterface(IBlockAccess, bl)) then
        begin
          m_outTag.block := bl;
          bl := nil;
        end;
        //lcm;
      end;
    end;
  end
  else
  begin
    m_outTag.tagname:=name;
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
    m_errors.add('cSpm.updateOutChan ����������� ������� ���: ' +
        m_tag.tagname);
    exit;
  end;
  if m_outTag.tag = nil then
  begin
    changeCfgMode := ecm;
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
    if m_outTag.tag<>nil then
      m_outTag.tagname:=lstr;
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
      if m_outTag.tag<>nil then
      begin
        m_outTag.tag.setname(str);
        // setlength(m_real, m_fftCount shr 1);
        // setlength(m_im, m_fftCount shr 1);
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
  lstr:string;
begin
  setinptag(t);
  lstr := GetParam(m_Properties, 'Channel');
  if m_tag<>nil then
  begin
    m_Properties:=AddParamF(m_Properties,'Channel',m_tag.tagname);
    if lstr='' then
    begin
      name:=resname;
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
    updateOutChan;
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

procedure cSpm.settag(str: string);
var
  t: itag;
begin
  t := getTagByName(str);
  settag(t);
end;


end.
