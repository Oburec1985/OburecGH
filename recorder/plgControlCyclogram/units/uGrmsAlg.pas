unit uGrmsAlg;

interface
uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml, ucommontypes, uFFT,
  pluginclass, sysutils;


type
  cGrmsAlg = class(cbasealg)
  protected
    // ������ � ������� ���� ������ ��� � ������
    fband:point2d;
    // ������������ ���� ��� ���������� ������
    fUseTaho,
    // ������ �� ���������� � � ��������� �� ����
    fPercentBand:boolean;
    // ��� �� �������
    fdX:double;
    // ����� ����� FFT
    fFFTCount:integer;
    fTahoTag: cTag;
    fOutTag: cTag;
    // ������ � ������� ���� ������ grms
    m_band:point2d;
    // ����� � ������� ����� ������ ��� ������� �������/ ��� �� �������� ����� �� �������������� �� �����
    // ����� ���� ������ �������� ����� � ������ log2
    fOutDataBuff:TArrayValues;
    // ����� ������� �������� �������� ������
    foutSpm:TArrayValues;
    // ����� ������� �������� ����� Grms
    fRmsDataBuff:array of double;
    // ������ ����� �� �������� ���� ������ Grms (����� ���� ��� ������ ��� ������� �������� ������)
    // � ���������� foutSpm ����� ����� �� ������ fOutSize � ������������� �� ����� ����� fft
    fOutSize,
    // ���������� �������� ������� ������ �� �������� ������ � ��������
    fUsedData,
    // ������� � ������� ������ ������� ���������� ����� ����� �������� ������ ����������� � ��������
    m_curposInBuf,
    // ����� ����� fft
    m_fftCount:integer;
    // ����� ��������� ���������� ������������� ������ = BlockTime+fUsedData*inFreq
    fLastTime:double;
  protected
    InTag: cTag;
  protected
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    procedure doOnStart; override;
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
    function genTagName: string;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure LoadTags(node: txmlNode);override;
    function ready: boolean;override;
  public
    constructor create; override;
    class function getdsc: string; override;
  end;

const
  sqrt2=1.4142135623730950488016887242097;
  C_GrmsOpts = 'Band1=0.9,Band2=1.1,FFTCount=256,UseTaho=true,Percent=true,dX=0.1';

implementation

{ cCounterAlg }

constructor cGrmsAlg.create;
begin
  inherited;
  Properties := C_GrmsOpts;
  m_fftCount:=256;
end;

procedure cGrmsAlg.doEval(tag: cTag; time: double);
var
  I, len, startind, endind: Integer;
  v, infreq, rms, spmdX: double;
  // ������� ���� hi, �������� ������ ����
  startTrig: boolean;
  // ���������� ������ ������� ����� ���� ����������� � �������� �����
  copycount,
  notusedData,
  // ����� ����������� ��� ���������� ������
  fromcopy,
  NCopy,
  spmPointCount,
  // ����� ������� �������� ������. �� ���� ���� ������� ������ ����� ����
  // ��������� ��������� ��������� ��������. ������ ���������� ����� ������� � �������� ����
  blocknum:integer;
  // ��������� ������ ��� ���������� �������� ������ ������ �����
  copyBlocks:boolean;
  knorm:double;
begin
  len := length(tag.m_TagData);
  m_curposInBuf:=0;
  infreq:=tag.tag.GetFreq;
  // ���� ����� ����� fft ������ �������� ������ �� ����� ��������� ������� ����� ����� �������� ������ ����� ����� ����� fft
  if m_FFTCount>len then
    spmPointCount:=len
  else
    spmPointCount:=m_FFTCount;
  blocknum:=0;
  // ���� �� ������������ ��� ������ �� �������� ������
  while m_curposInBuf<len do
  begin
    copycount:=fOutSize;
    notusedData:=len-m_curposInBuf;
    if copycount>notusedData then
    begin
      copycount:=notusedData;
    end;
    // �������� ������� ������ � �������� �����
    move(tag.m_TagData[m_curposInBuf], fOutDataBuff[fUsedData], copycount*sizeof(double));
    fromcopy:=m_curposInBuf;
    m_curposInBuf:=m_curposInBuf+copycount;
    fUsedData:=fUsedData+copycount;
    // ���� �������� ����� ������� ��������
    if fUsedData=fOutSize then
    begin
      // ���������� ������
      NCopy:=trunc(m_FFTCount/foutsize);
      // �������� ����� ������� � ����� ������ ���������� ������
      if copyBlocks then
      begin
        for I := 0 to NCopy - 1 do
        begin
          if fOutSize+(i+1)*copycount>m_fftCount then
          begin
            Move(tag.m_TagData[fromcopy],
                 fOutDataBuff[fOutSize+i*copycount],
                 (m_FFTCount-copycount*i-fOutSize)*(sizeof(double)));
          end
          else
          begin
            Move(tag.m_TagData[fromcopy],
                 fOutDataBuff[fOutSize+i*copycount],
                 copycount*(sizeof(double)));
          end;
        end;
      end
      else
      // ��������� ������
      begin
        // ��� ������������ ������. ���� ����� 100 ����� � ����� ����� spm 256 �� ������ ���� ����� ������������ ���������� ������
        // ��� 2.56 ��� ������������ �������� ������ � 100 ����� ����� ������ �� ��������
        Move(tag.m_TagData[0],
             fOutDataBuff[0],
             spmPointCount*(sizeof(double)));
      end;
      FFTAnalysis(fOutDataBuff, foutSpm, m_fftCount, length(foutSpm));
      if copyBlocks then
      begin
        Knorm:=1;
      end
      else
      begin
        //Knorm:=(m_fftCount)/spmPointCount;
        Knorm:=2*(m_fftCount)/spmPointCount;
      end;
      fUsedData:=0;
      startind:=0;endind:=length(foutSpm) - 1;
      spmdX:=inFreq/m_fftCount;
      // ������� ������� ���
      if not fUseTaho then
      begin
        // ����������� ������ �� ����������� � ����
        startind:=trunc(m_band.x/spmdX);
        inc(startind);
        endind:=trunc(m_band.y/spmdX);
        if endind>len-1 then
          endind:=len-1
      end;
      rms:=0;
      for I := startind to endind do
      begin
        v:=foutspm[i]/sqrt2;
        rms:=rms+v*v;
      end;
      rms:=sqrt(rms);
      fOutDataBuff[blocknum]:=rms;
      inc(blocknum);
    end;
  end;
  fOutTag.tag.PushDataEx(@fOutDataBuff[0], blocknum, 0, time);
end;

procedure cGrmsAlg.doGetData;
var
  I, BufCount, newBlockCount, blCount, readyBlockCount, blSize, blInd,
    writeBlockSize: Integer;
  tare: boolean;
  timeinterval: double;
begin
  if InTag <> nil then
  begin
    InTag.block.LockVector;
    blCount := InTag.block.GetBlocksCount;
    blSize := InTag.block.GetBlocksSize;
    if blCount > 0 then
    begin
      // ������� �����
      readyBlockCount := InTag.block.GetReadyBlocksCount;
      // ���� ���������� ������ ������ ��� ���-�� ������������ ������ (�.�. ���� ����� ������)
      if readyBlockCount > InTag.m_readyBlock then
      begin
        newBlockCount := readyBlockCount - InTag.m_readyBlock;
        BufCount := newBlockCount;
        // ���� ������� ������ ������ ��� ������ ������ (blCount), = ������,
        // �� � ���� ��� ������ �� ��������
        if newBlockCount > blCount then
          BufCount := newBlockCount;
        for I := 0 to BufCount - 1 do
        begin
          InTag.m_readyBlock := readyBlockCount;
          tare := true;
          // �������� ����� ������ 2. ��������� ���� � ������ ������ ����� ��������� ���� �����.
          // �����, � ����� �������� ����� � ���������� ���������������
          blInd := I + blCount - newBlockCount;
          if SUCCEEDED(InTag.block.GetVectorR8(pointer(InTag.m_TagData)^,
              blInd, blSize, tare)) then
          begin
            timeinterval := InTag.block.GetBlockDeviceTime(blInd);
          end;
          // ����� ���� ������
          doEval(InTag, timeinterval);
        end;
      end;
    end;
    InTag.block.unLockVector;
  end;
end;

procedure cGrmsAlg.doOnStart;
begin
  inherited;
end;

class function cGrmsAlg.getdsc: string;
begin
  result := '��� � ������';
end;

function cGrmsAlg.getinptag: itag;
begin

end;

procedure cGrmsAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;
  if m_inpTags.Count > 0 then
  begin
    InTag := InputTag[0];
    if m_inpTags.Count > 1 then
      fTahoTag := InputTag[1];
  end;
end;

procedure cGrmsAlg.LoadTags(node: txmlNode);
begin

end;

function cGrmsAlg.ready: boolean;
begin
  result:=false;
  if intag<>nil then
  begin
    if intag.tag<>nil then
      result:=true;
  end;
end;

procedure cGrmsAlg.setinptag(t: cTag);
var
  tagname: string;
  bl: IBlockAccess;
  outfreq:double;
begin
  if InTag <> nil then
  begin
    if InTag.tag <> nil then
    begin
      ecm;
      fOutTag := cTag.create;
      outfreq:=1/fdX;                                              // irregular   FreqCorr
      fOutTag.tag := createVectorTagR8(genTagName, outfreq, false, false,         false);
      if not FAILED(fOutTag.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        fOutTag.block := bl;
        bl := nil;
      end;
      addOutTag(fOutTag);
      lcm;
      if fOutTag = nil then
        createOutChan
      else
        updateOutChan;
    end;
  end;
end;

procedure cGrmsAlg.setinptag(t: itag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;
  if InTag = nil then
  begin
    InTag := cTag.create;
  end;
  InTag.tag := t;
  InTag.tagname := t.GetName;
  t.GetTagId(InTag.ftagid);
  addInputTag(InTag);
  if not FAILED(t.QueryInterface(IBlockAccess, bl)) then
  begin
    InTag.block := bl;
    bl := nil;
  end;
  if fOutTag = nil then
    createOutChan
  else
    updateOutChan;
end;

procedure cGrmsAlg.setTahoTag(t: itag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;
  if fTahoTag = nil then
  begin
    fTahoTag := cTag.create;
  end;
  fTahoTag.tag := t;
  fTahoTag.tagname := t.GetName;
  t.GetTagId(fTahoTag.ftagid);
  addInputTag(fTahoTag);
end;


function cGrmsAlg.GetProperties: string;
begin
  if m_properties = '' then
    m_properties := C_GrmsOpts;
  result := m_properties;
end;

procedure cGrmsAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
begin
  if str = '' then
    exit;
  inherited;
  //C_GrmsOpts = 'Band1=0.9,Band2=1.1,UseTaho=true,Percent=true';
  lstr := GetParam(str, 'Band1');
  if lstr <> '' then
  begin
    fBand.x := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'Band2');
  if lstr <> '' then
  begin
    fBand.y := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'FFTCount');
  if lstr <> '' then
  begin
    fFFTCount:= strtoInt(lstr);
  end;
  lstr := GetParam(str, 'UseTaho');
  if lstr <> '' then
  begin
    fUseTaho:= strtobool(lstr);
  end;
  lstr := GetParam(str, 'Percent');
  if lstr <> '' then
  begin
    fPercentBand:= strtobool(lstr);
  end;
  lstr := GetParam(str, 'dX');
  if lstr <> '' then
  begin
    fdx:= strtofloatext(lstr);
  end;

  lstr := GetParam(str, 'Channel');
  if lstr <> '' then
  begin
    if InTag = nil then
    begin
      InTag := cTag.create;
      t := getTagByName(lstr);
      setinptag(t);
    end;
    ChangeCTag(InTag, lstr);
  end;

  lstr := GetParam(str, 'Taho');
  if lstr <> '' then
  begin
    if fTahoTag = nil then
    begin
      fTahoTag := cTag.create;
      t := getTagByName(lstr);
      setTahoTag(t);
    end;
    ChangeCTag(fTahoTag, lstr);
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
  // ����������� � ������������ �������� ���������
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MINVALUE, v);
  // m_TestVTag.SetProperty(TAGPROP_MINVALUE, v);
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MAXVALUE, v);
  // m_TestWriteVTag.SetProperty(TAGPROP_MAXVALUE, v);
end;

function cGrmsAlg.genTagName: string;
var
  tagname: string;
begin
  tagname := InTag.tagname;
  result := tagname + '_Grms';
end;

procedure cGrmsAlg.createOutChan;
var
  tagname: string;
  bl: IBlockAccess;
  outfreq:double;
begin
  if InTag <> nil then
  begin
    if InTag.tag <> nil then
    begin
      ecm;
      fOutTag := cTag.create;
      outfreq:=1/fdX;
      fOutTag.tag := createVectorTagR8(genTagName, outfreq, false);
      if not FAILED(fOutTag.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        fOutTag.block := bl;
        bl := nil;
      end;
      addOutTag(fOutTag);
      updateBuff;
      lcm;
    end;
  end;
end;

procedure cGrmsAlg.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  bl: IBlockAccess;
  infreq, outfreq:double;
begin
  ecm;
  str := lpcstr(StrToAnsi(genTagName));
  fOutTag.tag.SetName(str);
  fOutTag.tag.SetFreq(InTag.tag.getfreq);
  fOutTag.block := nil;
  if not FAILED(fOutTag.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    fOutTag.block := bl;
  end;
  updateBuff;
  lcm;
end;

procedure cGrmsAlg.updateBuff;
var
  infreq, outfreq:double;
begin
  // ��������� ������ ������
  infreq:=InTag.tag.GetFreq;
  outfreq:=fOutTag.tag.GetFreq;
  fOutSize:=trunc(infreq*fdX);
  //setlength(fOutDataBuff, trunc(infreq/outfreq));
  setlength(fOutDataBuff, m_fftCount);
  setlength(fOutSpm, m_fftCount shr 1);
  setlength(fRmsDataBuff, fOutTag.fBlock.GetBlocksSize);
  fUsedData:=0;
end;

end.
