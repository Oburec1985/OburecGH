unit uEvalStepAlg;

interface

uses
  classes, Windows, tags, uBaseObj, uBaseObjMng, activeX, nativexml, uRCFunc,
  pluginclass, blaccess, sysutils, uCommonTypes, uFFT,
  urecorderevents,
  uCommonMath,
  uMyMath,
  mathfunction,
  math,
  uHardwareMath,
  complex,
  dialogs,
  recorder,
  uRegClassesList, u2dmath;

type
  cScalarTag = class
  public
    t:itag;
    id:int64;
  private
    fname:string;
  protected
    function getname:string;
    procedure setname(s:string);
  public
    function CreateTag:itag;
    property name:string read getname write setname;
  end;

  cEvalStepAlg = class
  public
    name: string;
  public
    // ������ ����� FFT
    m_fftCount,
    // �������� ����� FFT
    m_fftShift: integer;
    // ������������ FFT ������
    m_fftFlt: boolean;
    // ����� ����������� ��������
    m_Threshold,
    // ����� ������ ��������
    m_FallTime: double;
    // �������� � �������� �� ������ ������������ ��������
    m_TrigOffset: double;
    m_tag: cTag;
    m_outTag: cTag;
    // ������������ ��������� ���
    m_useScalar:boolean;
    m_outScTag: cScalarTag;
    // ������ ���������� �� �������
    m_band: array of point2d;
  protected
    m_iFFTPlan, FFTProp: TFFTProp;
    // ��������� ����� ������ � ���. ����� ����� ������ ������ ������ �������
    fblSize:integer;
    // ���������� ������������ ������ ������� ����� "������" ����� ���������� �������
    fPortionSize:integer;
    // ����� ���������� ��� ���������� ������� (����� = FFTCount)
    m_func: TDoubleArray;
    // ������ ���� �� ����������� �� ����������� ������
    fFirstBlock:boolean;
  private
    // ����� ���������� ���������� ��������
    fTrigTime:double;
    ftrig:boolean; // ������� ��������
    // ������ ���������� ������� � �������� ������
    ///flastindex,
    // ���������� ������
    fOverlap: integer;
    // ������ � �������� ��� ������ ��������� ���� UpdateTime*freq
    fPeriod,
    fdt,
    // ���������� �������
    fspmdx: double;
    // ����� � ������� ����� ��������� ������ FFT (������������ ��� SSE) (������ m_fftCount)
    cmplx_resArray: TAlignDCmpx;
    // ��������������� ������� ������ ����� iFFT
    m_inData1: TAlignDCmpx;
    // ����� ��� �������� ������
    m_outData: TDoubleArray;
    // ������� ������ �� ����������� ����� � ������ �������� ���� ������ ����������
    m_OverlapBlock: TDoubleArray;
  protected
    procedure UpdateBlSize;
    procedure SetCurveStr(s:string);
    function GetCurveStr:string;
    procedure doOnLeaveCfg;
    procedure doOnStart;
    function doEval(intag: cTag; time: double):boolean;
    procedure doGetData;
    function ready: boolean;
    // �������� ����������� �������������
    procedure evalFltCurve(p_spmdx: double);
  public
    // ���������� ��� ����������
    procedure UpdateFFTSize;
    constructor create;
    destructor destroy;
  end;

  cAlgList = class(tstringlist)
  private
  public
    procedure doLeaveCfg;
    procedure doSave(sender: tobject);
    procedure doLoad(sender: tobject);
    function getobj(i: integer): cEvalStepAlg; overload;
    function getobj(str: string): cEvalStepAlg; overload;
    function addAlg(name: string): cEvalStepAlg;
    procedure delAlg(a: cEvalStepAlg);
    procedure doUpdateTags(sender: tobject);
    procedure doChangeCfg(sender: tobject);
    procedure doChangeRState(sender: tobject);
    procedure createEvents;
    procedure DestroyEvents;
    // ���������� ��� �������� � ��������/������
    procedure doStart;
    procedure doStopRecord;
    constructor create;
    destructor destroy;
  end;

function LoadTag(node: txmlnode; p_t: cScalarTag):cScalarTag;
procedure saveTag(t: cScalarTag; node: txmlnode);

var
  g_AlgList: cAlgList;

implementation

uses
  uCreateComponents;

{ cEvalStepAlg }
constructor cEvalStepAlg.create;
begin
  m_tag := cTag.create;
  m_outTag := cTag.create;
  m_useScalar:=true;
  m_FallTime:=1;
end;

destructor cEvalStepAlg.destroy;
begin
  m_tag.destroy;
  m_tag := nil;

  m_outTag.destroy;
  m_outTag := nil;

  if m_outScTag<>nil then
  begin
    m_outScTag.Destroy;
    m_outScTag:=nil;
  end;

  FreeMemAligned(cmplx_resArray);
  cmplx_resArray.p := nil;
  FreeMemAligned(m_inData1);
  cmplx_resArray.p := nil;
end;

procedure multArrays(a1: TDoubleArray; var a2: TCmxArray_d);
var
  i, l: integer;
begin
  l := length(a1);
  for i := 0 to l - 1 do
  begin
    a2[i].re := a2[i].re * a1[i];
    a2[i].im := a2[i].im * a1[i];
  end;
end;

function cEvalStepAlg.doEval(intag: cTag; time: double):boolean;
var
  // ���������� ������� ������ �������� ������
  bCount: integer;
  b: boolean;
  i1, i2: integer;
  i, ind: integer;
  //dt,
  lt, k, v, m, trigTime: double;
  j: Integer;
begin
  result:=false;
  bCount := trunc(m_tag.lastindex / m_fftCount);
  fportionsize:=0;
  if bCount < 1 then
    exit;
  i1:=0;
  if m_tag.lastindex > (i1 + m_fftCount) then
    b := true
  else
    b := false;
  bCount:=0;
  while b do
  begin
    FFTProp.StartInd := i1;
    fft_al_d_sse(TDoubleArray(m_tag.m_ReadData), TCmxArray_d(cmplx_resArray.p), FFTProp);
    // ��������� ��������� �������
    multArrays(m_func, TCmxArray_d(cmplx_resArray.p));

    m_iFFTPlan.StartInd := 0;
    ifft_al_d_sse(TCmxArray_d(cmplx_resArray.p), TCmxArray_d(m_inData1.p), m_iFFTPlan);

    // ���� �� ������ ����
    for i := 0 to m_fftCount - 1 do
    begin
      // ���������� ������
      if (i < (fOverlap - 1)) and (not fFirstBlock) then
      begin
        ind:=fOverlap-i;
        k := (ind) / (fOverlap);
        m_outData[i] := (1-k) * TCmxArray_d(m_inData1.p)[i].re + (k) * m_OverlapBlock[i];
      end
      // ������������ ������
      else
      begin
        m_outData[i] := TCmxArray_d(m_inData1.p)[i].re;
      end;
    end;
    if i1 + m_fftShift + m_fftCount > m_tag.lastindex then
    begin
      b := false
    end
    else
    begin
      i1 := i1 + m_fftShift;
    end;
    begin
      if m_outTag.lastindex=0 then
        m_outTag.m_ReadDataTime:=m_tag.m_ReadDataTime;
      // source, dest, count // �������� ��� ������ �� ������ �� ����������
      move(m_outData[0], m_outTag.m_ReadData[m_outTag.lastindex], (m_fftShift) * sizeof(double));
      fFirstBlock:=false;
      if fOverlap > 0 then
      begin
        move(m_outData[m_fftCount - fOverlap], m_OverlapBlock[0], fOverlap * sizeof(double));
      end;
      // ������� ����� ������ � �������� ������
      m_outTag.lastindex:=m_outTag.lastindex+m_fftShift;
    end;
    // ������� ����� ������ � ������� ������. -fOverlap �.�. ������ ��������� ������ ����� �� ������ ����� ���������� � ���� �������
    if (m_outTag.lastindex)>=fblSize then
    begin
      // ������� ������ ����� ������
      //ind:=trunc((m_outTag.lastindex-fOverlap)/fblSize);
      ind:=trunc((m_outTag.lastindex)/fblSize);
      lt:=0;
      for I := 0 to ind - 1 do
      begin
        m_outTag.tag.PushDataEx(@m_outTag.m_ReadData[i*fblSize], fblSize, 0, m_outTag.m_ReadDataTime+lt);
        // ������ ����� ������ � ��������
        lt:=lt+fdt;
      end;
      // ------------------------------------------------------------------------
      // ����� ��������
      if m_useScalar then
      begin
        m:=tempSUM(m_outTag.m_ReadData,0,m_outTag.lastindex)/(m_outTag.lastindex+1);
        // ��������� ��������� �� ������� �� ������ ������
        i2:=0;
        if ftrig then
        begin
          trigTime:=fTrigTime+m_FallTime;
          if trigTime<m_outTag.m_ReadDataTime then
          begin
            ftrig:=false;
          end
          else
          begin
            if trigTime<m_outTag.getReadTime(m_outTag.lastindex) then
            begin
              i2:=trunc((trigTime-m_outTag.m_ReadDataTime)/fperiod);
              ftrig:=false;
            end;
          end;
        end
        else
        begin
          for j := i2 to m_outTag.lastindex - 1 do
          begin
            v:=m_outTag.m_ReadData[j];
            if abs(v-m)>m_Threshold then
            begin
              trigTime:=m_outTag.m_ReadDataTime+j*fPeriod;
              ftrig:=true;
              if (trigTime+m_TrigOffset)<m_outTag.getReadTime(m_outTag.lastindex) then
              begin
                //  �������� ��������������� ��������
                ind:=trunc(m_TrigOffset/fPeriod);
                fTrigTime:=trigTime+m_TrigOffset;
                m_outScTag.t.PushValue(m_outTag.m_ReadData[j+ind], trigTime+m_TrigOffset);
              end;
              break;
            end;
          end;
        end;
      end;
      m_outTag.ResetTagDataTimeInd(fblSize*ind);
      result:=true;
    end;
    inc(bCount);
  end;
  if bCount>0 then
  begin
    // ������ ����������� m_fftcount-fftShift �.�. ��� ������ ��������� � �������� ���� ���������� ��������
    //fportionsize:=(bCount-1)*m_fftcount+m_fftShift;
    fportionsize:=m_fftShift*bCount;
    if fportionsize>0 then
      m_tag.ResetTagDataTimeInd(fportionsize);
  end;
end;

procedure cEvalStepAlg.doGetData;
var
  i, BufCount, newBlockCount, blCount, readyBlockCount, blSize, blind,
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
    end;
  end;
end;

procedure cEvalStepAlg.doOnLeaveCfg;
begin
  UpdateBlSize;
end;

procedure cEvalStepAlg.doOnStart;
var
  i: integer;
  t: cTag;
begin
  fTrigTime:=0;
  ftrig:=false;
  fFirstBlock:=true;
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
  ///flastindex := 0;
  // ZeroMemory(m_EvalBlock.p, fOutSize * sizeof(double));
end;

function cEvalStepAlg.ready: boolean;
begin
  result := false;
  if m_fftCount=0 then exit;

  if m_tag = nil then exit;
  if m_outTag = nil then exit;
  result:=true;
end;

procedure cEvalStepAlg.UpdateFFTSize;
var
  i, bCount: integer;
  f: double;
begin
  if m_fftCount<>0 then
    fspmdx := m_tag.tag.GetFreq / m_fftCount;
  // ������ ���������� ������
  fOverlap := m_fftCount - m_fftShift;
  f := m_tag.freq;
  fPeriod:=1/m_tag.tag.GetFreq;
  if m_fftCount>0 then
  begin
    setlength(m_outData, m_fftCount);
    // ������� ���������� ������
    setlength(m_OverlapBlock, fOverlap);
    GetMemAlignedArray_cmpx_d(m_fftCount, cmplx_resArray);
    GetMemAlignedArray_cmpx_d(m_fftCount, m_inData1);
    FFTProp := GetFFTPlan(m_fftCount);
    m_iFFTPlan := GetInverseFFTPlan(m_fftCount);
    setlength(m_func, m_fftCount);
    evalFltCurve(fspmdx);
  end;
  UpdateBlSize;
end;

procedure cEvalStepAlg.UpdateBlSize;
begin
  fblSize:=m_outTag.BlockSize;
  fdt:=fblSize*fPeriod;
end;

procedure cEvalStepAlg.evalFltCurve(p_spmdx: double);
var
  i, j, ind, irange, i1, i2: integer;
  p1, p2: point2d;
  str: string;
  pars: tstringlist;
  d: double;
begin
  pars := tstringlist.create;
  pars.Delimiter := ';';
  for i := 0 to length(m_func) - 1 do
    m_func[i] := 1;
  m_func[0] := 1;

  if length(m_band) = 0 then
    exit;
  p1 := m_band[0];
  for i := 1 to length(m_band) - 1 do
  begin
    p2 := m_band[i];
    // ������ �������� ������ ����� � ��������� � � curvescales
    i1 := Ceil(p1.x / p_spmdx); // ceil - ��������� �����
    i2 := trunc(p2.x / p_spmdx);
    irange := m_fftCount shr 1;
    if i2 > irange - 1 then
    begin
      i2 := irange - 1;
    end;
    // d:=frac(i1);
    for j := i1 to i2 do
    begin
      m_func[j] := EvalLineYd(j * fspmdx, p1, p2);
      // ��������������� ������
      m_func[m_fftCount - j - 1] := m_func[j];
    end;
    p1:=p2;
  end;
  pars.destroy;
end;

function cEvalStepAlg.GetCurveStr: string;
var
  I: Integer;
begin
  result:='';
  for I := 0 to length(m_band) - 1 do
  begin
    result:=result+floattostr(m_band[i].x)+';'+floattostr(m_band[i].y)+';'
  end;
end;

procedure cEvalStepAlg.SetCurveStr(s:string);
var
  sub:string;
  b, first:boolean;
  p:point2d;
  i, pCount:integer;
begin
  if s='' then exit;
  
  b:=true;
  sub:='';
  i:=1;
  pCount:=0;
  first:=true;
  setlength(m_band, 100);
  ZeroMemory(@m_band[0],Length(m_band)*sizeof(point2d));
  while b do
  begin
    if i>Length(s) then
      break;
    if s[i]=';' then
    begin
      if first then
      begin
        p.x:=strtofloatext(sub);
        first:=false;
        sub:='';
      end
      else
      begin
        p.y:=strtofloatext(sub);
        first:=true;
        m_band[pCount]:=p;
        inc(pCount);
        sub:='';
      end;
    end
    else
    begin
      sub:=sub+s[i];
    end;
    inc(i);
  end;
  SetLength(m_band, pCount);
end;

{ cAlgList }
function cAlgList.addAlg(name: string): cEvalStepAlg;
var
  i: integer;
begin
  result := cEvalStepAlg.create;
  for i := 0 to Count - 1 do
  begin
    while getobj(name) <> nil do
    begin
      name := ModName(name, false);
    end;
  end;
  AddObject(name, result);
  result.name := name;
end;

procedure cAlgList.createEvents;
begin
  AddPlgEvent('cAlgList_doUpdateTags', c_RUpdateData, doUpdateTags);
  AddPlgEvent('cAlgList_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
  AddPlgEvent('cAlgList_doChangeCfg', c_RC_LeaveCfg, doChangeCfg);
end;

procedure cAlgList.delAlg(a: cEvalStepAlg);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Objects[i] = a then
    begin
      a.destroy;
      Delete(i);
    end;
  end;
end;

constructor cAlgList.create;
begin
  createEvents;
end;

destructor cAlgList.destroy;
begin
  DestroyEvents;
end;

procedure cAlgList.DestroyEvents;
begin
  RemovePlgEvent(doUpdateTags, c_RUpdateData);
  RemovePlgEvent(doChangeRState, c_RC_DoChangeRCState);
  RemovePlgEvent(doChangeCfg, c_RC_LeaveCfg);
end;

procedure cAlgList.doChangeCfg(sender: tobject);
begin

end;

procedure cAlgList.doChangeRState(sender: tobject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin

      end;
    RSt_StopToView:
      begin
        doStart;
      end;
    RSt_StopToRec:
      begin
        doStart;
      end;
    RSt_ViewToStop:
      begin

      end;
    RSt_ViewToRec:
      begin
        doStart;
      end;
    RSt_initToRec:
      begin
        doStart;
      end;
    RSt_initToView:
      begin
        doStart;
      end;
    RSt_RecToStop:
      begin
        doStopRecord;
      end;
    RSt_RecToView:
      begin
        doStopRecord;
        doStart;
      end;
  end;
end;

procedure cAlgList.doLeaveCfg;
var
  I: Integer;
  a:cEvalStepAlg;
begin
  for I := 0 to Count - 1 do
  begin
    a:=getobj(i);
    a.doOnLeaveCfg;
  end;
end;

procedure cAlgList.doLoad(sender: tobject);
var
  dir, name, newpath: string;

  doc: TNativeXml;
  node, child, tagnode: txmlnode;
  i, N: integer;
  a: cEvalStepAlg;
begin
  dir := extractfiledir(g_cfgpath);
  name := trimext(extractfilename(g_cfgpath));

  newpath := dir + '\' + name + '.xml';
  doc := TNativeXml.create(nil);
  doc.XmlFormat := xfReadable;
  doc.LoadFromFile(newpath);
  node := doc.Root;
  node := node.FindNode('EvalStepAlg');
  if node = nil then
    exit;

  N := node.readAttributeInteger('AlgCount', 0);
  for i := 0 to N - 1 do
  begin
    child := node.FindNode('Alg_' + inttostr(i));
    if child <> nil then
    begin
      name := child.ReadAttributeString('AlgName', '');
      a := addAlg(Name);
      a.m_fftCount := child.readAttributeInteger('numFFT', 32);
      a.m_fftShift := child.readAttributeInteger('OffsetFFT', 32);
      a.m_fftFlt := child.ReaDAttributeBool('UseFFTflt', false);
      a.SetCurveStr(child.ReadAttributeString('Band', ''));
      tagnode := child.FindNode('inTag');
      if tagnode <> nil then
        urcfunc.LoadTag(tagnode, a.m_tag);
      tagnode := child.FindNode('OutTag');
      if tagnode <> nil then
        urcfunc.LoadTag(tagnode, a.m_outTag);
      a.UpdateFFTSize;

      a.m_Threshold := child.ReadAttributeFloat('TrigThreshold', 0);
      a.m_useScalar := child.ReaDAttributeBool('UseScalarTag', true);
      tagnode := child.FindNode('TrigTag');
      if tagnode <> nil then
      begin
        LoadTag(tagnode, a.m_outScTag);
        if a.m_outScTag.name='' then
        begin
          a.m_outScTag.name:=a.m_tag.tagname+'_trig';
          a.m_outScTag.CreateTag;
        end;
      end
      else
      begin
        if a.m_useScalar then
        begin
          if a.m_outScTag=nil then
          begin
            a.m_outScTag:=cScalarTag.Create;
            a.m_outScTag.fname:=a.m_tag.tagname+'_trig';
            if a.m_outScTag.t=nil then
            begin
              a.m_outScTag.CreateTag;
            end;
          end;
        end;
      end;
    end;
  end;
  doc.destroy;
end;

procedure cAlgList.doSave(sender: tobject);
var
  dir, name, newpath: string;

  doc: TNativeXml;
  node, child, tagnode: txmlnode;
  i: integer;
  a: cEvalStepAlg;
begin
  dir := extractfiledir(g_cfgpath);
  name := trimext(extractfilename(g_cfgpath));

  newpath := dir + '\' + name + '.xml';
  doc := TNativeXml.create(nil);
  node := doc.Root;
  node := node.NodeNew('EvalStepAlg');
  node.WriteAttributeInteger('AlgCount', g_AlgList.Count, 0);
  for i := 0 to g_AlgList.Count - 1 do
  begin
    a := getobj(i);
    child := node.NodeNew('Alg_' + inttostr(i));
    child.WriteAttributeString('AlgName', a.name, '');
    child.WriteAttributeInteger('numFFT', a.m_fftCount, 32);
    child.WriteAttributeInteger('OffsetFFT', a.m_fftShift, 32);
    child.WriteAttributeBool('UseFFTflt', a.m_fftFlt, false);
    child.WriteAttributeFloat('TrigThreshold', a.m_Threshold, 0);
    child.WriteAttributeFloat('TrigThreshold', a.m_TrigOffset, 0);
    child.WriteAttributeString('Band', a.getCurveStr, '');
    tagnode := child.NodeNew('inTag');
    uRcFunc.saveTag(a.m_tag, tagnode);
    tagnode := child.NodeNew('OutTag');
    uRcFunc.saveTag(a.m_outTag, tagnode);
    child.WriteAttributeBool('UseScalarTag', a.m_useScalar);
    if a.m_useScalar then
    begin
      tagnode := child.NodeNew('TrigTag');
      saveTag(a.m_outScTag, tagnode);
    end;
    if tagnode <> nil then
    begin
      LoadTag(tagnode, a.m_outScTag);
      if a.m_outScTag.name='' then
      begin
        a.m_outScTag.name:=a.m_tag.tagname+'_trig';
        a.m_outScTag.CreateTag;
      end;
    end;
  end;
  doc.XmlFormat := xfReadable;
  doc.SaveToFile(newpath);
  doc.destroy;
end;

procedure cAlgList.doStart;
var
  i: integer;
  a: cEvalStepAlg;
begin
  for i := 0 to Count - 1 do
  begin
    a := getobj(i);
    if a.ready then
      a.doOnStart;
  end;
end;

procedure cAlgList.doStopRecord;
begin

end;

procedure cAlgList.doUpdateTags(sender: tobject);
var
  a: cEvalStepAlg;
  i: integer;
begin
  // ����������
  for i := 0 to Count - 1 do
  begin
    a := getobj(i);
    if not a.ready then
    begin
      continue;
    end;
    a.doGetData;
  end;
end;

function cAlgList.getobj(i: integer): cEvalStepAlg;
begin
  result := cEvalStepAlg(Objects[i]);
end;

function cAlgList.getobj(str: string): cEvalStepAlg;
var
  i: integer;
  o: cEvalStepAlg;
begin
  result := nil;
  for i := 0 to Count - 1 do
  begin
    o := getobj(i);
    if getobj(i).name = str then
    begin
      result := o;
      exit;
    end;
  end;
end;

{ cScalarTag }

procedure saveTag(t: cScalarTag; node: txmlnode);
begin
  node.WriteAttributeString('TagName', t.name);
  node.WriteAttributeInt64('TagID', t.id);
end;

function LoadTag(node: txmlnode; p_t: cScalarTag):cScalarTag;
var
  t: itag;
  ir: irecorder;
  id: tagid;
  refcount: integer;
begin
  if p_t = nil then
  begin
    result := cScalarTag.create;
  end
  else
  begin
    result := p_t;
  end;
  result.name := node.ReadAttributeString('TagName', '');
  result.id := node.ReadAttributeInt64('TagID', -1);
  if result.name <> '' then
  begin
    t := getTagByName(result.name);
    if t <> nil then
    begin
      // t.GetTagId(result.tagid)
      t.GetTagId(result.id);
    end
    else
    begin
      ir := getIR;
      t := getTagById(result.id);
      if t <> nil then
      begin
        result.t := t;
      end;
    end;
  end;
end;

function cScalarTag.CreateTag: itag;
begin
  if t=nil then
  begin
    t:=createScalar(fname,true);
  end
  else
    result:=t;
end;

function cScalarTag.Getname: string;
begin
  if t <> nil then
    result := t.GetName
  else
    result := fname;
end;

procedure cScalarTag.setname(s: string);
var
  b: boolean;
  astr: ansistring;
begin
  b := false;
  if Getname <> s then
  begin
    if not RStateConfig then
    begin
      b := true;
      ecm;
    end;
    astr := s;
    if t <> nil then
    begin
      t.SetName(pansichar(lpcstr(StrToAnsi(s))));
    end
    else
    begin
      t := getTagByName(s);
    end;
    fname := s;
    if b then
      lcm;
  end;
end;

end.