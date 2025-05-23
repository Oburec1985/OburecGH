unit uIntegralAlg;

interface

uses
  classes, windows, activex, ubasealg,
  uCommonMath,
  mathfunction,
  uRCFunc, tags, recorder,
  blaccess, nativexml, math, urctags, dialogs,
  pluginclass, sysutils;

type
  cIntegralAlg = class(cbasealg)
  protected
    fdt: double;
  protected
    m_FileTag: cFileTag;
    m_outFileTag: cFileTag;
    m_FFTfltTag: cFFTFltTag;
    m_FFTShift: integer;

    m_fltType: integer;
    // ����������� ���������
    m_FltReady: boolean;
    m_fltCount: integer;
    // ������ ������� ������� ������ ����� ������
    m_StartInd_InTag,
    m_write, // ���������� �������� ���������� � ���������  doEval
    m_endindex: integer;


    // ��� ��� ������ ����� �������� ����������� �� ����
    fflt: double;
    fltLastInd: integer;
    // ������������ � ��������� ����������� ��������
    fltbuf: array of double;

    fLo: double;
    flastval, // ��������� �������� � ���������� �����
    fIntegral: double;
    m_InTag: cTag;
    m_OutTag: cTag;
  protected
    procedure doStopRecord; override;

    procedure PushFltVal(v: double);
    // i � ��������� -m_fltCount..+m_fltCount
    function GetFltVal(i: integer): double;
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
    function genTagName: string; override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    function ready: boolean; override;
  public
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
  end;

const
  c_Lo=0.0000001;
  C_IntegralOpts = 'Lo=0.0000001, FltType=0, FltCount=3';
  c_FFTflt = 2;

implementation

{ cCounterAlg }

constructor cIntegralAlg.create;
begin
  inherited;

  Properties := C_IntegralOpts;
  m_InTag := cTag.create;
  // addInputTag(m_InTag);
  m_OutTag := cTag.create;
  m_FFTfltTag := cFFTFltTag.create;
  m_FFTfltTag.inTag := m_InTag;
end;

destructor cIntegralAlg.destroy;
begin
  m_InTag.destroy;
  m_InTag := nil;
  m_OutTag.destroy;
  m_OutTag := nil;
  if m_FileTag <> nil then
  begin
    m_FileTag.destroy;
  end;

  if m_outFileTag <> nil then
  begin
    m_outFileTag.destroy;
  end;


  m_FFTfltTag.destroy;
  m_FFTfltTag := nil;
  inherited;
end;

function GetIntegral(v1, v2, dx: double): double;
var
  x: double;
begin
  result:=0;
  if (v1+v2)=0 then
  begin
    exit;
  end;
  if v1 > 0 then
  BEGIN
    if v2 > 0 then
    begin
      result := dx * (v1 + v2) * 0.5;
    end
    else
    begin // v1>0, v2<0
      // ����� ����������� ��� �������
      v2 := abs(v2);
      x := dx * v1 / (v1 + v2);
      result := 0.5 * (x * v1 - (dx - x) * v2);
    end;
  END
  else
  begin
    if v2 > 0 then // v1<0, v2>0
    begin
      v1 := abs(v1);
      // ����� ����������� ��� �������
      x := dx * v1 / (v1 + v2);
      result := 0.5 * ((dx - x) * v2 - x * v1);
    end
    else // v1<0, v2<0
    begin
      v1 := abs(v1);
      v2 := abs(v2);
      result := dx * (v1 + v2) * (-0.5);
    end;
  end;
  if result=0 then
  begin
    //showmessage('v1:'+floattostr(v1) + 'v2:'  +floattostr(v2)+ 'dx:'+floattostr(dx));
  end;
end;

procedure cIntegralAlg.doEval(tag: cTag; time: double);
var
  p:pointer;
  i,ind,len: integer;
  logstr:string;
  dt,dt_block:double;
begin
  doFlt;
  len := m_endindex;
  if len < 1 then
    exit;
  //fIntegral := fIntegral + GetIntegral(flastval, m_InTag.m_ReadData[0], fdt);
  fIntegral := fIntegral + GetIntegral(flastval, m_InTag.m_ReadData[m_StartInd_InTag], fdt);
  m_OutTag.m_ReadData[0] := fIntegral;
  ind:=m_StartInd_InTag+1;
  for i := 1 to len - 1 do
  begin
    if abs(m_InTag.m_ReadData[ind - 1]) < fLo then
    begin
      if abs(m_InTag.m_ReadData[ind]) < fLo then
      begin
        m_OutTag.m_ReadData[i] := fIntegral;
        continue;
      end;
    end;
    fIntegral := fIntegral + GetIntegral(m_InTag.m_ReadData[ind - 1], m_InTag.m_ReadData[ind], fdt);
    m_OutTag.m_ReadData[i] := fIntegral;
    inc(ind);
  end;
  flastval := m_InTag.m_ReadData[len - 1];

  //logstr:='m_OutTag: len'+inttostr(len)+' Time:'+formatstr(m_InTag.m_ReadDataTime,4);
  //logmessage(logstr);

  i:=0;
  dt_block:=m_InTag.block.GetBlocksSize*1/m_InTag.freq;
  dt:=0;
  while i<=len-m_InTag.block.GetBlocksSize do
  begin
    p:=@m_OutTag.m_ReadData[i];
    m_OutTag.tag.PushDataEx(p, m_InTag.block.GetBlocksSize, 0, m_InTag.m_ReadDataTime+dt);
    i:=i+m_InTag.block.GetBlocksSize;
    dt:=dt+dt_block;
  end;
  m_write:=i;
  if m_outFileTag<>nil then
  begin
    if m_outFileTag.recordState then
      m_outFileTag.saveBlock(m_InTag.m_ReadDataTime, m_write);
  end;
end;

procedure cIntegralAlg.doFlt;
var
  k, v: double;
  i, len: integer;
  logstr:string;
begin
  v := 0;
  case m_fltType of
    0:
      m_endindex := m_InTag.lastindex;
    1: // ���������� �������
      begin
        k := 1 / m_fltCount;
        for i := 0 to len - 1 do
        begin
          // 0 - �������� ������� �������
          if m_FltReady then
          begin
            // ���������� ��������
            v := GetFltVal(0);
          end;
          if not m_FltReady then
          begin
            PushFltVal(m_InTag.m_ReadData[i]);
            if fltLastInd = (m_fltCount) then
            begin
              m_FltReady := true;
              fflt := sum(fltbuf);
            end;
          end
          else
          begin
            fflt := fflt - v;
            fflt := fflt + m_InTag.m_ReadData[i];
            // �������� ������� ������ PushFltVal(m_intag.m_ReadData[i]-k*fflt); ???, �.�. ������ ����������������� ��������
            PushFltVal(m_InTag.m_ReadData[i]);
            // PushFltVal(m_intag.m_ReadData[i]-k*fflt);
            m_InTag.m_ReadData[i] := m_InTag.m_ReadData[i] - k * fflt;
          end;
        end;
        m_endindex := m_InTag.lastindex;
      end;
    2: // FFT ������
      begin
        m_endindex:= m_FFTfltTag.EvalDataWithShift;
      end;
  end;
  if m_FileTag <> nil then
  begin
    if m_FileTag.recordState then
    begin
      if m_endindex<> 0 then
      begin
        logstr:='m_FileTag: len'+inttostr(m_endindex)+' Time:'+formatstr(m_InTag.m_ReadDataTime,4);
        logmessage(logstr);
        m_FileTag.saveBlock(m_InTag.m_ReadDataTime, m_StartInd_InTag, (m_endindex-m_StartInd_InTag));
      end;
    end;
  end;
end;

procedure cIntegralAlg.doGetData;
begin
  //if pos('Chan_01',m_InTag.tagname)<1 then exit;

  if m_InTag.UpdateTagData(true) then
  begin
    if m_InTag.lastindex > m_fltCount then
    begin
      doEval(m_InTag, m_InTag.m_ReadDataTime);
      if m_endindex> 0 then
      begin
        if m_fltType = c_FFTflt then
        begin
          // ������ � ������� ���� ��������� ���������
          m_FFTfltTag.resetData(m_write);
          m_StartInd_InTag:=m_FFTfltTag.m_readyPoints;
        end
        else
        begin
          m_InTag.ResetTagDataTimeInd(m_endindex);
        end;
      end;
    end;
  end;
end;

procedure cIntegralAlg.doOnStart;
begin
  inherited;

  fIntegral := 0;

  flastval := 0;
  fltLastInd := 0;
  m_StartInd_InTag:=0;
  m_write:=0;
  m_FltReady := false;

  m_FFTfltTag.Start;
  m_InTag.doOnStart;
  m_OutTag.doOnStart;

  if m_FileTag <> nil then
  begin
    if not m_FileTag.recordState then
    begin
      if g_merafile <> '' then
        m_FileTag.StartRecord(g_merafile);
    end;
  end;
  if m_outFileTag <> nil then
  begin
    if not m_outFileTag.recordState then
    begin
      if g_merafile <> '' then
        m_outFileTag.StartRecord(g_merafile);
    end;
  end;


end;

procedure cIntegralAlg.doStopRecord;
begin
  if m_FileTag <> nil then
  begin
    m_FileTag.StopRecord;
  end;
  if m_outFileTag <> nil then
  begin
    m_outFileTag.StopRecord;
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
  result := false;
  if m_InTag <> nil then
  begin
    if m_InTag.tag <> nil then
    begin
      result := true;
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

  addParam(pars, 'FltType', inttostr(m_fltType));
  addParam(pars, 'FltCount', inttostr(m_fltCount));
  if m_fltType = c_FFTflt then
  begin
    addParam(pars, 'FltShift', inttostr(m_FFTShift));
  end;
  addParam(pars, 'Lo', replaceChar(FLOATTOSTR(fLo), ',', '.'));
  if m_InTag.tagname <> '' then
  begin
    addParam(pars, 'Channel', m_InTag.tagname);
    // ���� ��� ���������� �� ����� ��� ��� ����� ������� �����
    if m_OutTag.tag <> nil then
    begin
      str := m_OutTag.tagname;
    end
    else
    begin
      str := genTagName;
      b := true;
      while b do
      begin
        t := getTagByName(str);
        if ((t = nil) or (t = m_OutTag.tag)) then
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
  // 07/02/2020
  //if isValue(lstr) then
  //begin
  //  fLo := strtofloatext(lstr);
  //end;
  flo:=c_Lo;

  lstr := GetParam(str, 'FltType');
  if checkstr(lstr) then
    m_fltType := StrToInt(lstr);
  if m_fltType = c_FFTflt then
  BEGIN
    lstr := GetParam(str, 'FltShift');
    if checkstr(lstr) then
      m_FFTShift := StrToInt(lstr);
  END;
  lstr := GetParam(str, 'FltCount');
  if checkstr(lstr) then
  begin
    m_fltCount := StrToInt(lstr);
    setlength(fltbuf, m_fltCount);
  end;

  lstr := GetParam(str, 'Channel');
  if checkstr(lstr) then
  begin
    t := getTagByName(lstr);
    if t <> nil then
    begin
      changeOutName := setinptag(t);
    end;
  end;
  lstr := GetParam(str, 'OutChannel');
  if m_OutTag <> nil then
  begin
    if m_OutTag.tag = nil then
    begin
      if checkstr(lstr) then
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
        m_OutTag.tagname := genTagName
      end
      else
      begin
        if checkstr(lstr) then
        begin
          m_OutTag.tagname := lstr;
        end;
      end;
    end;
    updateOutChan;
  end;
  if m_InTag <> nil then
  begin
    if m_InTag.tag <> nil then
    begin

    end;
  end;
end;

function createVectorTagR8(tagname: string; freq: double;  CfgWritable: boolean): itag;
var
  ir: irecorder;
  Name, errMes: string;
  err: cardinal;
  v: OleVariant;
  bl:IBlockAccess;
begin
  ir := getIR;
  result := itag(ir.CreateTag(lpcstr(StrToAnsi(tagname)), LS_VIRTUAL, nil));
  if result = nil then // ������ �������� ������������ ����
  begin
    err := ir.GetLastError;
    errMes := ir.ConvertErrorCodeToString(err);
  end;
  // ��������� ���� ���� : ������, ����� � ��������
  VariantInit(v);
  VariantClear(v);
  TPropVariant(v).vt := VT_UI4;
  //v := TTAG_VECTOR or TTAG_INPUT;
  v := TTAG_VECTOR or TTAG_INPUT or TTAG_IRREGULAR;


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

  if not FAILED(result.QueryInterface(IBlockAccess, bl)) then
  begin
    //bl.
    //bl._Release;
  end;
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
  if m_OutTag.tag <> nil then
  begin
    if isalive(m_OutTag.tag) then
      exit
    else
      m_OutTag.tag := nil;
  end;
  t := getTagByName(tname);
  if t <> nil then
    m_OutTag.tag := t
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
  blcount, blsize: integer;

  p: pointer;
  pCtrl:ITagBlockVectorControl;
begin
  ecm;
  // 21.09.19
  ///str := lpcstr(StrToAnsi(genTagName));
  ///m_OutTag.tag.SetName(str);
  m_OutTag.tag.SetFreq(m_InTag.tag.getfreq);
  m_OutTag.block := nil;
  if not FAILED(m_OutTag.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    m_OutTag.block := bl;
  end;
  blsize := m_InTag.block.GetBlocksSize;
  setlength(m_OutTag.m_TagData, blsize);
  fdt := 1 / m_InTag.freq;

  if m_fltType = c_FFTflt then
  begin
    m_FFTfltTag.setFFTCount(m_fltCount, m_FFTShift);
    if not FAILED(m_OutTag.tag.QueryInterface(ITagBlockVectorControl, pCtrl)) then
    //if not FAILED(m_OutTag.tag.QueryInterface(IID_ITagBlockVectorControl, pCtrl)) then
    begin
      pCtrl.ConfigBlockVector(m_fltCount, 4);
      //lcm;
      //ecm;
      //ShowMessage(inttostr(bl.GetBlocksSize));
    end;
  end
  else
  begin
    m_FFTfltTag.setFFTCount(m_fltCount, m_FFTShift);
    //if not FAILED(m_OutTag.tag.QueryInterface(ITagBlockVectorControl, pCtrl)) then
    if not FAILED(m_OutTag.tag.QueryInterface(IID_ITagBlockVectorControl, pCtrl)) then
    begin
      blsize := m_InTag.block.GetBlocksSize;
      blcount:= m_InTag.block.GetBlocksCount;
      pCtrl.ConfigBlockVector(blsize, blcount);
    end;
  end;

  if true then
  begin
    if m_FileTag = nil then
    begin
      m_FileTag := cFileTag.create(m_InTag.tagname+'FT', m_InTag.tag.getfreq);
      p := m_InTag.m_ReadData;
      m_FileTag.setBlock(blsize, p);
    end;
    if m_outFileTag = nil then
    begin
      m_outFileTag := cFileTag.create(m_InTag.tagname+'FT_out', m_InTag.tag.getfreq);
      /// /p:=addr(m_InTag.m_TagData);
      p := m_OutTag.m_ReadData;
      m_outFileTag.setBlock(blsize, p);
    end;
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
  ind: integer;
begin
  if fltLastInd = m_fltCount then
  begin
    fltLastInd := 0;
  end;
  ind := fltLastInd;
  if ind >= m_fltCount then
    ind := ind - m_fltCount;
  fltbuf[ind] := v;
  inc(fltLastInd);
end;

function cIntegralAlg.GetFltVal(i: integer): double;
var
  ind: integer;
begin
  ind := fltLastInd + i;
  if ind >= m_fltCount then
  begin
    if ind < 0 then
    begin
      ind := ind + m_fltCount
    end
    else
    begin
      ind := ind - m_fltCount;
    end;
  end;
  result := fltbuf[ind];
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
