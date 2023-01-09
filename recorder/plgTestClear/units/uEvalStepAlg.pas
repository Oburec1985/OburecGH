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
  uRegClassesList, u2dmath;

type
  cEvalStepAlg = class
  public
    name: string;
  public
    // размер блока FFT
    m_fftCount,
    // смещение блока FFT
    m_fftShift: integer;
    // Использовать FFT фильтр
    m_fftFlt: boolean;
    // порог триггерного перепада
    m_Threshold: double;
    // смещение в секундах от начала срабатывания триггера
    m_TrigOffset: double;
    m_tag: cTag;
    m_outTag: cTag;
    // кривая фильтрации по спектру
    m_band: array of point2d;
  protected
    m_iFFTPlan, FFTProp: TFFTProp;
    // кратность блока записи в тег. Имеем право писать только такими блоками
    fblSize:integer;
    // количество обработанных данных которые можно "забыть" после очередного расчета
    fportionsize,
    // индекс последнего элемента в m_BlockTime
    m_BlockTimeInd: integer;
    // набор множителей для фильтрации спектра (длина = FFTCount)
    m_func: TDoubleArray;
    // первый блок не проверяется на пересечение данных
    fFirstBlock:boolean;
  private
    // индекс последнего отсчета в выходном буфере
    ///flastindex,
    // перекрытие блоков
    fOverlap: integer;
    // разрешение спектра
    fspmdx: double;
    // буфер в котором лежит очередной расчет FFT (выравнивание под SSE) (размер m_fftCount)
    cmplx_resArray: TAlignDCmpx;
    // восстановленные входные данных через iFFT
    m_inData1: TAlignDCmpx;
    // буфер под выходные данные
    m_outData: TDoubleArray;
    // кусочек данных из предыдущего блока с учетом которого надо делать перекрытие
    m_OverlapBlock: TDoubleArray;
  protected
    procedure doOnStart;
    function doEval(intag: cTag; time: double):boolean;
    procedure doGetData;
    function ready: boolean;
    // пересчет фильтрующих коэффициентов
    procedure evalFltCurve(p_spmdx: double);
  public
    // вызывается при обновлении
    procedure UpdateFFTSize;
    constructor create;
    destructor destroy;
  end;

  cAlgList = class(tstringlist)
  private
  public
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
    // происходит при переходе в просмотр/запись
    procedure doStart;
    procedure doStopRecord;
    constructor create;
    destructor destroy;
  end;

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
end;

destructor cEvalStepAlg.destroy;
begin
  m_tag.destroy;
  m_tag := nil;

  m_outTag.destroy;
  m_outTag := nil;

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
  // количество готовых блоков
  bCount: integer;
  b: boolean;
  i1, i2: integer;
  i, ind: integer;
  //dt,
  k: double;
begin
  result:=false;
  bCount := trunc(m_tag.lastindex / m_fftCount);
  if bCount < 1 then
    exit;

  i1 := 0;
  ///if flastindex > 0 then
  ///begin
  ///  i1 := flastindex - foverflow;
  ///  if i1 < 0 then
  ///    i1 := 0;
  ///end
  ///else
  ///  i1 := flastindex;

  if m_tag.lastindex > (i1 + m_fftCount) then
    b := true
  else
    b := false;
  while b do
  begin
    FFTProp.StartInd := i1;
    fft_al_d_sse(TDoubleArray(m_tag.m_ReadData), TCmxArray_d(cmplx_resArray.p), FFTProp);
    // частотная коррекция спектра
    multArrays(m_func, TCmxArray_d(cmplx_resArray.p));

    m_iFFTPlan.StartInd := 0;
    ifft_al_d_sse(TCmxArray_d(cmplx_resArray.p), TCmxArray_d(m_inData1.p), m_iFFTPlan);

    // если не первый блок
    for i := 0 to m_fftCount - 1 do
    begin
      // перекрытые данные
      if (i < (fOverlap - 1)) and (not fFirstBlock) then
      begin
        ind:=fOverlap-i;
        k := (ind) / (fOverlap);
        m_outData[i] := (k-1) * TCmxArray_d(m_inData1.p)[i].re + (k) * m_OverlapBlock[i];
      end
      // неперекрытые данные
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
    //if flastindex - foverflow > 0 then
    begin
      if m_outTag.lastindex=0 then
        m_outTag.m_ReadDataTime:=m_tag.m_ReadDataTime;
      // source, dest, count // копируем все данные не взирая на перекрытие
      move(m_outData[0], m_outTag.m_ReadData[m_outTag.lastindex], (m_fftShift) * sizeof(double));
      fFirstBlock:=false;
      if fOverlap > 0 then
      begin
        move(m_outData[m_fftCount - fOverlap], m_OverlapBlock[0], fOverlap * sizeof(double));
      end;
      // сколько можно забыть в выходном буфере
      m_outTag.lastindex:=m_outTag.lastindex+m_fftShift;
    end;
    // сколько можно забыть в входном буфере. -fOverlap т.к. нельзя сохранять данные котор не прошли через усреднение с след порцией
    if (m_outTag.lastindex)>=fblSize then
    begin
      // сколько блоков можно забыть
      ind:=trunc((m_outTag.lastindex-fOverlap)/fblSize);
      m_outTag.tag.PushDataEx(@m_outTag.m_ReadData[0], fblSize, 0, m_outTag.m_ReadDataTime);
      m_outTag.ResetTagDataTimeInd(fblSize*ind);
      result:=true;
    end;
  end;
  if bCount>0 then
    fportionsize:=(bCount-1)*m_fftcount+m_fftShift;
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
      // вычисляется в doEval
      if fportionsize>0 then
        m_tag.ResetTagDataTimeInd(fportionsize);
    end;
  end;
end;

procedure cEvalStepAlg.doOnStart;
var
  i: integer;
  t: cTag;
begin
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
  m_BlockTimeInd := 0;
end;

function cEvalStepAlg.ready: boolean;
begin
  result := false;
  if m_tag <> nil then
  begin
    if m_outTag <> nil then
      result := true;
  end;
end;

procedure cEvalStepAlg.UpdateFFTSize;
var
  i, bCount: integer;
  f: double;
begin
  fspmdx := m_tag.tag.GetFreq / m_fftCount;
  // размер перекрытия блоков
  fOverlap := m_fftCount - m_fftShift;
  f := m_tag.freq;
  setlength(m_outData, m_fftCount);
  // кусочек перекрытых данных
  setlength(m_OverlapBlock, fOverlap);
  GetMemAlignedArray_cmpx_d(m_fftCount, cmplx_resArray);
  GetMemAlignedArray_cmpx_d(m_fftCount, m_inData1);
  FFTProp := GetFFTPlan(m_fftCount);
  m_iFFTPlan := GetInverseFFTPlan(m_fftCount);
  fblSize:=m_outTag.BlockSize;
  setlength(m_func, m_fftCount);
  evalFltCurve(fspmdx);
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
    // расчет индексов границ полос и установка К в curvescales
    i1 := Ceil(p1.x / p_spmdx); // ceil - округлить вверх
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
      // ЗЕРКАЛИРОВАННЫЙ СПЕКТР
      m_func[m_fftCount - j - 1] := m_func[j];
    end;
  end;
  pars.destroy;
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
      a.m_Threshold := child.ReadAttributeFloat('TrigThreshold', 0);
      a.m_TrigOffset := child.ReadAttributeFloat('TrigThreshold', 0);
      tagnode := child.FindNode('inTag');
      if tagnode <> nil then
        LoadTag(tagnode, a.m_tag);
      tagnode := child.FindNode('OutTag');
      if tagnode <> nil then
        LoadTag(tagnode, a.m_outTag);
      a.UpdateFFTSize;
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
    tagnode := child.NodeNew('inTag');
    saveTag(a.m_tag, tagnode);
    tagnode := child.NodeNew('OutTag');
    saveTag(a.m_outTag, tagnode);
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
  // предрасчет
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

end.
