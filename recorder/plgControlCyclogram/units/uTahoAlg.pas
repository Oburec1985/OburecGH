unit uTahoAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml, uCommonTypes,
  uHardwareMath,
  uBaseObj,
  complex,
  pluginclass, sysutils,
  uFFT;

type
  cTahoAlg = class(cbasealg)
  protected
    // ������ ��� ������� �� �������
    fLo, fHi: double;
    //
    m_t1, m_t2,
    // ������ ������� �������
    fdX,
    // ���������� �������� �������� ����
    m_prev: double;
    // �������� m_prev �������������������
    m_InitPrev: boolean;
    // true - ������ �� �������; false - ������ �� �������
    fTahoType: boolean;
    // ��� � ������������
    fOutTag: cTag;
    // ���������� ��������� �� ������� ��������� �������
    m_Ncount,
    // ����� �������� ������� ������ ��� ���������
    m_periodCount,
    // ���������� �������� ������� ������ ������ ��� ��������� ������ ��� ��������� ��� ������� ����� 0
    m_minT: integer;

    /////////////////////
    // ������ �� FFT
    // ����� ����� FFT
    m_FFTCount:integer;
    // ���� ��������, ������������ ��������� ��� ���������� ���������
    m_useBand:boolean;
    // ������ � ������� ������ �������� ������
    m_band:point2d;
    // ��������� ������
    m_addNulls:boolean;
    // ����� ��������� �������� ��� ��� ������� ������
    fOutIsNew:boolean;
    // ��� ������� ������� ��� ���������� �� �������
    fWndType:integer;
  public
    m_minValue:double;
  protected
    ffreq: double;
    // ������� ���
    fInTag: cTag;
    // ������ ������ �� ������� ���� ������ (dt*fs)
    m_portionsize:integer;

    // ������� ����� ��� ������� �������. ������������ ����� ������ �� BlockAccess t.m_TagData,
    // �� ��������� ������ ��� ������� �����, � �.�. ���������� ������
    m_spmArray:TAlignDarray;
    m_cmxArr:TAlignDCmpx;
    // ����� ��� ����������� ������
    outarray:TAlignDarray;
    fftPlan:TFFTProp;
    finitbuff:boolean;
  protected
    function getInpTag(index: integer): cTag;override;
    function getOutTag(index: integer): cTag;override;
    procedure updateReady;override;
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    function getExtProp: string;override;
    procedure doOnStart; override;
    procedure doEval(tag: cTag; time: double); override;
    // index - ����� ������� tag.m_outData � �������� ���������� ����� time � �������������� ������
    function EvalTahoFFT(tag: cTag; index:integer; time: double): double;
    procedure doGetData; override;
    // ���� ���������� ��� �������� ������ �� ����������� ��� ��������� ������, � ����� � ���
    // ���������� ��� �������� ��� ��� ��������� �������� ����
    procedure createOutChan;
    procedure updateOutChan;
    procedure setinptag(t: itag); overload;
    procedure setinptag(t: cTag); overload;
    function genTagName: string;override;
    procedure setSpmArray;
    procedure LoadTags(node: txmlNode); override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    function ready:boolean;override;
    function GetResName: string; override;
  public
    procedure setfirstchannel(t:itag);override;
  public
    property InTag:ctag read fintag write fintag;
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
    // property inpTag:itag read getInptag write setInpTag;
  end;

const
  C_TahoOpts = 'TahoType=FFT,MinValue=0.1,LHi=70,LLo=30,FFTCount=16384,Period=0.1,Addnull=1,FFTUseBand=true,FFTBand1=10,FFTBand2=20000';

implementation

procedure cTahoAlg.setfirstchannel(t: itag);
var
  lstr:string;
begin
  setinptag(t);
  lstr := GetParam(m_Properties, 'Channel');
  if fInTag<>nil then
  begin
    m_Properties:=AddParamF(m_Properties,'Channel',fInTag.tagname);
    if lstr='' then
    begin
      name:=genTagName;
    end;
  end;
end;


constructor cTahoAlg.create;
begin
  inherited;
  fWndType:=spm_HanningWnd;
  fOutIsNew:=false;
  finitbuff:=false;
  m_minT := 3;
  m_addNulls:=false;
  Properties := C_TahoOpts;
  m_InitPrev := false;
  m_minValue:=0.1;
end;

destructor cTahoAlg.destroy;
begin
  FreeMemAligned(outarray);
  outarray.p:=nil;

  FreeMemAligned(m_spmArray);
  m_spmArray.p:=nil;

  FreeMemAligned(m_cmxArr);
  m_cmxArr.p:=nil;

  if fOutTag<>nil then
  begin
    fOutTag.destroy;
    fOutTag:=nil;
  end;
  inherited;
end;


function cTahoAlg.EvalTahoFFT(tag: cTag; index:integer; time: double): double;
var
  startind, endind,
  blCount, maxind: integer;
  inFreq: double;
  max,
  // ���������� ��� ����� ���������� ������
  Knorm,
  spmdX:double;
  I, len,
  spmPointCount,
  // ����� ����������� ��� ���������� ������
  NCopy: Integer;
begin
  inFreq := tag.tag.GetFreq;
  //m_FFTCount:=256;
  // ���� ����� ����� fft ������ �������� ������ �� ����� ��������� ������� �����
  // ����� �������� ������ ����� ����� ����� fft
  if m_FFTCount>m_portionsize then
    spmPointCount:=m_portionsize
  else
    spmPointCount:=m_FFTCount;

  NCopy:=trunc(m_FFTCount/spmPointCount);
  // ���������� ������
  if m_addNulls then
  begin
    Move(tag.m_ReadData[index],m_spmArray.p^,spmPointCount*(sizeof(double)));
  end
  else
  begin
    Move(tag.m_ReadData[index],m_spmArray.p^,spmPointCount*(sizeof(double)));
  end;

  // ��������� ���������� �� FFTAnalyse �� ������ �����!!!! (�.�. ������� ��������
  // ���� �� ���� ������ � dx) 01.09.19
  fft_al_d_sse(TDoubleArray(m_spmArray.p), tCmxArray_d(m_cmxArr.p), FFTPlan);
  Knorm:=1/(FFTPlan.PCount shr 1);
  // ��� ���� �� ������������� ��� ����� ������ �������� � ����� ����
  //MULT_SSE_al_cmpx_d(tCmxArray_d(m_cmxArr.p), Knorm);
  EvalSpmMag(TCmxArray_d(m_cmxArr.p), TDoubleArray(outarray.p));

  if not m_addNulls then
  begin
    Knorm:=1;
  end
  else
  begin
    Knorm:=Knorm*(m_fftCount)/spmPointCount;
    //Knorm:=(m_fftCount)/spmPointCount;
  end;
  startind:=0;
  len:=AlignBlockLength(outarray);
  endind:=len - 1;
  spmdX:=inFreq/m_fftCount;
  if m_useBand then
  begin
    startind:=trunc(m_band.x/spmdX);
    inc(startind);
    endind:=trunc(m_band.y/spmdX);
    if endind>len-1 then
      endind:=len-1
  end;
  maxind:=startind;
  max:=TArrayValues(outarray.p)[startind];
  for I := startind+1 to endind do
  begin
    if max<TArrayValues(outarray.p)[i] then
    begin
      max:=TArrayValues(outarray.p)[i];
      maxind:=i;
    end;
  end;
  // � ����������� ���������
  max:=max*knorm*1.41;
  if max<m_minValue then
  begin
    result:=0;
  end
  else
  begin
    spmdX:=inFreq/m_fftCount;
    //result:=spmdX+spmdX*maxind;
    // 02.09.19
    result:=spmdX*maxind;
  end;
end;


procedure cTahoAlg.doEval(tag: cTag; time: double);
var
  I, len: integer;
  v, lHi, lLo, mean, peak, min,
  // ����� ������� � ���������� �������� � ������
  curT:double;
  // ������� ���� hi, �������� ������ ����
  startTrig: boolean;
  // ������������ � �������� ����� ������ �������� ����
  inFreq: double;
  // ���������� �������� ������� ������� �� fft
  periodCount:integer;
begin
  len := tag.lastindex;
  inFreq := tag.tag.GetFreq;
  periodCount:=0;
  //inTagDataLength := len / inFreq;
  // ������ �� �������
  if fTahoType then
  begin
    if m_InitPrev then
    begin
      m_prev := tag.m_ReadData[0];
      // �������� ������ � ��� (��� ��������) � �������� ����� ����� ��� � ����������
      ffreq := 0;
    end
    else
    begin

    end;
    mean := GetMean(tag.tag);
    peak := GetAmp(tag.tag);
    min := mean - peak;
    lHi := min + (0.02 * peak * fHi);
    lLo := min + (0.02 * peak * fLo);
    startTrig := m_prev > lHi;
    if peak<m_minValue then
    begin
      ffreq:=0;
      fOutTag.tag.PushValue(ffreq, curT);
      inc(fOutTag.m_ReadyVals);
    end
    else
    begin
      for I := 1 to len - 1 do
      begin
        v := tag.m_ReadData[I];
        curT := I / inFreq + time;
        if m_prev <> v then
        begin
          m_prev := v;
          if startTrig then
          begin
            if v < lLo then
            begin
              startTrig := false;
              inc(m_Ncount);
              if m_Ncount = 1 then
              begin
                m_t1 := curT;
              end
              else
              begin
                if m_Ncount > 1 then
                begin
                  m_t2 := curT;
                end;
              end;
            end;
          end
          else
          begin
            startTrig := v > lHi;
          end;
        end;
        if (curT - time) >= fdX then
        begin
          if m_Ncount > 1 then
          begin
            ffreq := (m_Ncount - 1) / (m_t2 - m_t1);
            m_Ncount := 0;
            m_periodCount := 0;
            fOutTag.tag.PushValue(ffreq, curT);
            inc(fOutTag.m_ReadyVals);
          end
          else
          begin
            if m_periodCount >= m_minT then
            begin
              m_Ncount := 0;
              ffreq := 0;
              m_periodCount := 0;
              fOutTag.tag.PushValue(ffreq, curT);
              inc(fOutTag.m_ReadyVals);
            end;
          end;
        end;
      end;
    end;
  end
  else
  // ������ �� �������
  begin
    i:=0;
    if (tag<>nil) and (m_portionsize<>0) then
    begin
      periodCount:=trunc(tag.lastindex/m_portionsize);
      while i<periodCount do
      begin
        ffreq := EvalTahoFFT(tag, i*m_portionsize, time+i*(fdx));
        fOutTag.tag.PushValue(ffreq, time+i*(fdx));
        //fOutTag.tag.PushValue(ffreq, -1);
        inc(i);
      end;
      fOutTag.m_ReadyVals:=fOutTag.m_ReadyVals+periodCount;
    end;
  end;
  fInTag.ResetTagData(m_portionsize);
end;

procedure cTahoAlg.doGetData;
begin
  if not finitbuff then exit;

  if fInTag <> nil then
  begin
    fInTag.UpdateTagData(true);
    doEval(fInTag, fInTag.m_ReadDataTime);
  end;
end;

procedure cTahoAlg.doOnStart;
begin
  inherited;
  if not ready then exit;
  if fInTag<>nil then
    fInTag.doOnStart;
  if fOutTag<>nil then
    fOutTag.doOnStart;

  ZeroMemory(m_spmArray.p, length(TArrayValues(m_spmArray.p))*sizeof(double));

  ffreq := 0;
end;

class function cTahoAlg.getdsc: string;
begin
  result := '����';
end;


procedure cTahoAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
var
  tnode, tagnode: txmlNode;
begin
  tnode := xmlNode.FindNode('OutputTag');
  if tnode <> nil then
  begin
    tagnode := tnode.FindNode('OutChan');
    if tagnode <> nil then
    begin
      fOutTag := LoadTag(tagnode, fOutTag);
    end;
  end;
  inherited;
end;

procedure cTahoAlg.LoadTags(node: txmlNode);
begin
  inherited;
  if m_inpTags.Count > 0 then
  begin
    fInTag := ctag(m_inpTags.objects[0]);
    if fInTag.tag <> nil then
      SetPeakEval(fInTag.tag, true);
  end;
end;

procedure cTahoAlg.SaveObjAttributes(xmlNode: txmlNode);
var
  tnode, tagnode: txmlNode;
  I: integer;
begin
  inherited;
  if fOutTag<>nil then
  begin
    tnode := getNode(xmlNode,'OutputTag');
    tagnode := getNode(tnode,'OutChan');
    saveTag(fOutTag, tagnode);
  end;

end;


function cTahoAlg.ready: boolean;
begin
  result:=fready;
end;

procedure cTahoAlg.setinptag(t: cTag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;
  fInTag := t;
  addInputTag(fInTag);
  if not FAILED(t.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    fInTag.block := bl;
    bl := nil;
  end;
  if fOutTag = nil then
    createOutChan
  else
    updateOutChan;
end;

procedure cTahoAlg.setinptag(t: itag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;
  if fInTag = nil then
  begin
    fInTag := cTag.create;
  end;
  fInTag.tag := t;
  addInputTag(fInTag);
  if not FAILED(t.QueryInterface(IBlockAccess, bl)) then
  begin
    fInTag.block := bl;
    bl := nil;
  end;

 if fOutTag = nil then
  begin
    createOutChan
  end
  else
  begin
    if fouttag.tag=nil then
      createOutChan
    else
      updateOutChan;
  end;
end;

function cTahoAlg.GetProperties: string;
begin
  if m_properties = '' then
    m_properties := C_TahoOpts;
  result := m_properties;
end;

function cTahoAlg.getExtProp: string;
begin
  result:='';
  if fInTag<>nil then
    result:='Channel='+fInTag.tagname;
  //if m_outTag<>nil then
  //  result:=result+',OutChannel='+m_outTag.tagname;
end;

function cTahoAlg.getInpTag(index: integer): cTag;
begin
  result:=fInTag;
end;


function cTahoAlg.getOutTag(index: integer): cTag;
begin
  result:=fOutTag;
end;


function cTahoAlg.GetResName: string;
begin
  result:=inherited GetResName;
  if fOutTag<>nil then
  begin
    if fOutTag.tag<>nil then
    begin
      result:=fOutTag.tagname;
    end;
  end;
end;

procedure cTahoAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
begin
  if str = '' then
    exit;
  inherited;
  lstr := GetParam(str, 'LLo');
  if checkstr(lstr) then
  begin
    fLo := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'WndType');
  if checkstr(lstr) then
  begin
    fWndType := StrToInt(lstr);
  end;
  lstr := GetParam(str, 'TahoType');
  if checkstr(lstr) then
  begin
    fTahoType := lstr = 'Level';
  end;
  lstr := GetParam(str, 'LHi');
  if checkstr(lstr) then
  begin
    fHi := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'Period');
  if checkstr(str) then
  begin
    fdX := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'FFTCount');
  if checkstr(lstr) then
  begin
    m_FFTCount := StrToInt(lstr);
  end;
  lstr := GetParam(str, 'Addnull');
  if checkstr(lstr) then
  begin
    m_addNulls := strtoboolext(lstr);
  end;
  lstr := GetParam(str, 'MinValue');
  if checkstr(lstr) then
  begin
    m_minValue:=StrToFloatExt(lstr);
  end;
  lstr := GetParam(str, 'FFTUseBand');
  if checkstr(lstr) then
  begin
    m_useBand := StrToBoolext(lstr);
  end;
  lstr := GetParam(str, 'FFTBand1');
  if checkstr(lstr) then
  begin
    m_band.x := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'FFTBand2');
  if checkstr(lstr) then
  begin
    m_band.y := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'Channel');
  if checkstr(lstr) then
  begin
    if fInTag = nil then
    begin
      fInTag := cTag.create;
      t := getTagByName(lstr);
      setinptag(t);
    end;
    ChangeCTag(fInTag, lstr);
  end;
  setSpmArray;
  // ������ ��������� ������
  if fOutTag <>nil then
  begin
    if fTahoType then // ������ �� �������
    begin
      fOutTag.InitWriteData(fintag.m_ReadSize shr 2);
      updateOutChan;
    end
    else // ������ �� �������
    begin
      if fOutTag.tag=nil then
      begin
        if fOutTag.tagname<>'' then
        begin
          createOutChan;
        end;
      end
      else
      begin
        fOutTag.tagname:=resname;
      end;
      fOutTag.InitWriteData(fOutTag.blockCount)
    end;
  end
  else
  begin
    createOutChan;
  end;
end;

procedure cTahoAlg.setSpmArray;
begin
  if fInTag<>nil then
  begin
    finitbuff:=true;
    GetMemAlignedArray_d(m_FFTCount shr 1, outarray);
    GetMemAlignedArray_d(m_FFTCount, m_spmArray);
    GetMemAlignedArray_cmpx_d(m_FFTCount, m_cmxArr);

    m_portionsize:=round(fdx*fInTag.freq);
    fftPlan:=GetFFTPlan(m_FFTCount);
  end;
end;

function cTahoAlg.genTagName: string;
var
  tagname: string;
begin
  if InTag<>nil then
  begin
    tagname := InTag.tagname;
    result := tagname + '_Taho';
  end
  else
    result:='';
end;

procedure cTahoAlg.createOutChan;
var
  tagname: string;
  bl: IBlockAccess;
begin
  if InTag <> nil then
  begin
    if InTag.tag <> nil then
    begin
      ecm;
      fOutTag := cTag.create;
      if tagname='' then
        tagname := genTagName;
      if fOutTag.tagname<>'' then
      begin
        if fOutTag.tagname<>tagname then
          tagname:=fOutTag.tagname;
      end;
      fOutIsNew := true;
      if fOutTag.tag = nil then
      begin
        while getTagByName(tagname) <> nil do
        begin
          tagname := modname(tagname, false);
        end;
        fOutTag.tag := createVectorTagR8(tagname, 1/fdx, true, false, false);
      end;
      if not FAILED(fOutTag.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        fOutTag.block := bl;
        bl := nil;
      end;
      lcm;
    end;
  end;
end;

procedure cTahoAlg.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  bl: IBlockAccess;
begin
  ecm;
  str := lpcstr(StrToAnsi(genTagName));
  if fOutIsNew then
  begin
    fOutTag.tag.SetName(str);
  end;
  fOutTag.tag.SetFreq(1/fdx);
  fOutTag.block := nil;
  if not FAILED(fOutTag.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    fOutTag.block := bl;
  end;
  lcm;
end;

procedure cTahoAlg.updateReady;
begin
  fready:=false;
  if fintag<>nil then
  begin
    if fintag.tag<>nil then
    begin
      fready:=true;
      if not finitbuff then
      begin
        setSpmArray;
      end;
    end
    else
    begin
      fintag.tag:=getTagByName(fintag.tagname);
      if fintag.tag<>nil then
      begin
        fready:=true;
        updateOutChan;
        setSpmArray;
      end
      else
      begin
        fready:=false;
      end;
    end;
  end;
end;

end.
