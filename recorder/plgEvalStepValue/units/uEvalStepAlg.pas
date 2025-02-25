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
    t: itag;
    id: int64;
  private
    fname: string;
  protected
    function getname: string;
    procedure setname(s: string);
  public
    function CreateTag: itag;
    property name: string read getname write setname;
  end;

  cEvalStepAlg = class
  public
    name: string;
  public
    m_tag: cTag;
    m_outTag: cTag;
    // тип FFT фильтра
    m_fftType,
    // размер блока FFT
    m_fftCount,
    // смещение блока FFT
    m_fftShift: integer;
    // Использовать FFT фильтр
    m_fftFlt: boolean;
    // кривая фильтрации по спектру
    m_band: array of point2d;
    // 0 - AC; 1 - 1/2 LPF; 2 - 10Hz Lpf, 3 - Custom
    m_fltType: integer;

    // использовать скалярный тег
    m_useScalar: boolean;
    m_outScTag: cScalarTag;
    // 0 - мгновенное; 1 - среднее
    m_TrigType: integer;
    // длина порции для усреднения в точках
    m_TrigMeanLenI: integer;
    // порог триггерного перепада
    m_Threshold,
    // время сброса триггера
    m_FallTime: double;
    // смещение в секундах от начала срабатывания триггера
    m_TrigOffset: double;
  protected
    m_iFFTPlan, FFTProp: TFFTProp;
    // кратность блока записи в тег. Имеем право писать только такими блоками
    fblSize: integer;
    // количество обработанных данных которые можно "забыть" после очередного расчета
    fPortionSize: integer;
    // набор множителей для фильтрации спектра (длина = FFTCount)
    m_func: TDoubleArray;
    // первый блок не проверяется на пересечение данных
    fFirstBlock: boolean;
  private
    // сред. ур для расчета триггера
    fMean,
    // время последнего найденного триггера
    fTrigTime: double;
    ftrig: boolean; // триггер сработал
    // индекс последнего отсчета в выходном буфере
    /// flastindex,
    // перекрытие блоков
    fOverlap: integer;
    // размер в секундах для порции выходного тега UpdateTime*freq
    fPeriod, fdt,
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
    procedure UpdateBlSize;
    procedure SetCurveStr(s: string);
    function GetCurveStr: string;
    procedure doOnLeaveCfg;
    procedure doOnStart;
    // попытка найти триггер
    function FindTrig(var res: boolean): point2d;
    function doEval(intag: cTag; time: double): boolean;
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
    // происходит при переходе в просмотр/запись
    procedure doStart;
    procedure doStopRecord;
    constructor create;
    destructor destroy;
  end;

function LoadTag(node: txmlnode; p_t: cScalarTag): cScalarTag;
procedure saveTag(t: cScalarTag; node: txmlnode);

const
  c_instance = 0;
  c_Mean = 1;
  c_MemLength = 1;

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
  m_useScalar := true;
  m_FallTime := 1;
  m_fftCount := 16;
  m_fftShift := 16;
end;

destructor cEvalStepAlg.destroy;
begin
  m_tag.destroy;
  m_tag := nil;

  m_outTag.destroy;
  m_outTag := nil;

  if m_outScTag <> nil then
  begin
    m_outScTag.destroy;
    m_outScTag := nil;
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

function cEvalStepAlg.FindTrig(var res: boolean): point2d;
var
  j, i2, ind, t1i, t2i: integer;
  v, trigTime, lastTime: double;
  checkTrig: boolean;
begin
  res := false;
  lastTime := m_outTag.getReadTime(m_outTag.lastindex);
  fMean := m_outTag.m_ReadData[0];
  // проверяем сбросится ли триггер на данной порции
  i2 := 0;
  if ftrig then
  begin
    if lastTime-fTrigTime>m_TrigMeanLenI *(1 / m_outTag.freq) then
    begin
      checkTrig:=true;
    end;
    //trigTime := fTrigTime + m_FallTime;
    //if trigTime < m_outTag.m_ReadDataTime then
    //begin
    //  ftrig := false;
    //end
    //else
    //begin
    //  if trigTime < m_outTag.getReadTime(m_outTag.lastindex) then
    //  begin
    //    i2 := trunc((trigTime - m_outTag.m_ReadDataTime) / fPeriod);
    //    ftrig := false;
    //  end;
    //end;
  end
  else
  begin
    for j := i2 to m_outTag.lastindex - 1 do
    begin
      v := m_outTag.m_ReadData[j];
      // смещение реигстрируемого значения (Длит.)/dX
      ind := trunc(m_TrigOffset / fPeriod);
      t1i := ind + j;
      // отклонение по мат. ожиданию
      if abs(v - fMean) > m_Threshold then
      begin
        trigTime := m_outTag.m_ReadDataTime + j * fPeriod;
        ftrig := true;
        case m_TrigType of
          c_instance: // мгновенное значение
            begin
              // проверяем что нужное значение не ушло в след порцию
              checkTrig := (trigTime + m_TrigOffset) < lastTime;
              fTrigTime := trigTime + m_TrigOffset;
              Result.y := m_outTag.m_ReadData[t1i];
            end;
          c_Mean:
            begin
              fTrigTime := trigTime + m_TrigOffset;
              checkTrig := (fTrigTime + m_TrigMeanLenI *(1 / m_outTag.freq)) < lastTime;
              if checkTrig then
              begin
                break;
              end;
            end;
        end;
      end;
    end;
  end;
  // триг найден и накопился
  if checkTrig then
  begin
    Result.x := fTrigTime;
    t1i:=m_outTag.getIndex(fTrigTime);
    t2i:=t1i+m_TrigMeanLenI;
    Result.y := tempSUM(m_outTag.m_ReadData, t1i, t2i) / m_TrigMeanLenI;
    m_outScTag.t.PushValue(Result.y, Result.x);
    res := true;
    ftrig := false;
  end;
end;

function cEvalStepAlg.doEval(intag: cTag; time: double): boolean;
var
  // количество готовых блоков входного буфера
  bCount: integer;
  b, bRes: boolean;
  i1: integer;
  i, ind: integer;
  // dt,
  lt, k, v: double;
  j: integer;
  trigPoint: point2d;
begin
  Result := false;
  bCount := trunc(m_tag.lastindex / m_fftCount);
  fPortionSize := 0;
  if bCount < 1 then
    exit;
  i1 := 0;
  if m_tag.lastindex > (i1 + m_fftCount) then
    b := true
  else
    b := false;
  bCount := 0;
  while b do
  begin
    FFTProp.StartInd := i1;
    fft_al_d_sse(TDoubleArray(m_tag.m_ReadData), TCmxArray_d(cmplx_resArray.p),
      FFTProp);
    // частотная коррекция спектра
    multArrays(m_func, TCmxArray_d(cmplx_resArray.p));

    m_iFFTPlan.StartInd := 0;
    ifft_al_d_sse(TCmxArray_d(cmplx_resArray.p), TCmxArray_d(m_inData1.p),
      m_iFFTPlan);

    // если не первый блок
    for i := 0 to m_fftCount - 1 do
    begin
      // перекрытые данные
      if (i < (fOverlap - 1)) and (not fFirstBlock) then
      begin
        ind := fOverlap - i;
        k := (ind) / (fOverlap);
        m_outData[i] := (1 - k) * TCmxArray_d(m_inData1.p)[i].re + (k)
          * m_OverlapBlock[i];
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
    begin
      if m_outTag.lastindex = 0 then
        m_outTag.m_ReadDataTime := m_tag.m_ReadDataTime;
      // source, dest, count // копируем все данные не взирая на перекрытие
      move(m_outData[0], m_outTag.m_ReadData[m_outTag.lastindex],
        (m_fftShift) * sizeof(double));
      fFirstBlock := false;
      if fOverlap > 0 then
      begin
        move(m_outData[m_fftCount - fOverlap], m_OverlapBlock[0],
          fOverlap * sizeof(double));
      end;
      // сколько можно забыть в выходном буфере
      m_outTag.lastindex := m_outTag.lastindex + m_fftShift;
    end;
    // сколько можно забыть в входном буфере. -fOverlap т.к. нельзя сохранять данные котор не прошли через усреднение с след порцией
    if (m_outTag.lastindex) >= fblSize then
    begin
      // поиск триггера
      if m_useScalar then
      begin
        trigPoint := FindTrig(bRes);
      end;
      if not ftrig then
      begin
      //if m_outTag.getPortionLen>c_MemLength then
        begin
          // сколько блоков можно забыть
          ind := trunc((m_outTag.lastindex) / fblSize);
          m_outTag.tag.PushDataEx(@m_outTag.m_ReadData[0], fblSize, 0, m_outTag.m_ReadDataTime);
          m_outTag.ResetTagDataTimeInd(fblSize * ind);
        end;
      end;
      Result := true;
    end;
    inc(bCount);
  end;
  if bCount > 0 then
  begin
    // нельзя отбрасывать m_fftcount-fftShift т.к. эти данные участвуют в расчетах двух перекрытых спектров
    // fportionsize:=(bCount-1)*m_fftcount+m_fftShift;
    fPortionSize := m_fftShift * bCount;
    if fPortionSize > 0 then
      m_tag.ResetTagDataTimeInd(fPortionSize);
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
  fTrigTime := 0;
  ftrig := false;
  fFirstBlock := true;
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
  /// flastindex := 0;
  // ZeroMemory(m_EvalBlock.p, fOutSize * sizeof(double));
end;

function cEvalStepAlg.ready: boolean;
begin
  Result := false;
  if m_fftCount = 0 then
    exit;

  if m_tag = nil then
    exit;
  if m_outTag = nil then
    exit;
  Result := true;
end;

procedure cEvalStepAlg.UpdateFFTSize;
var
  i, bCount: integer;
  f: double;
begin
  if m_tag.tag <> nil then
  begin
    f := m_tag.freq;
    if m_fftCount <> 0 then
    begin
      fspmdx := m_tag.tag.GetFreq / m_fftCount;
    end;
  end
  else
    exit;
  // размер перекрытия блоков
  fOverlap := m_fftCount - m_fftShift;
  fPeriod := 1 / m_tag.tag.GetFreq;
  if m_fftCount > 0 then
  begin
    setlength(m_outData, m_fftCount);
    // кусочек перекрытых данных
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
  fblSize := m_outTag.BlockSize;
  fdt := fblSize * fPeriod;
end;

procedure cEvalStepAlg.evalFltCurve(p_spmdx: double);
var
  i, j, ind, irange, i1, i2: integer;
  p1, p2: point2d;
  str: string;
  pars: tstringlist;
  d, spmdx: double;
begin
  case m_fltType of
    // ac
    0:
      begin
        m_func[0] := 0;
        for i := 0 to length(m_func) - 1 do
        begin
          m_func[i] := 1;
        end;
      end;
    // lpf1/2
    1:
      begin
        irange := length(m_func) shr 1;
        ZeroMemory(@m_func[0], length(m_func) * sizeof(double));
        for i := 0 to irange do
        begin
          m_func[i] := 1;
          m_func[m_fftCount - i - 1] := m_func[i];
        end;
      end;
    // lpf10
    2:
      begin
        spmdx := m_tag.freq / m_fftCount;
        irange := round(10 / spmdx);
        ZeroMemory(@m_func[0], length(m_func) * sizeof(double));
        for i := 0 to irange do
        begin
          m_func[i] := 1;
          m_func[m_fftCount - i - 1] := m_func[i];
        end;
      end;
    // user
    3:
      begin
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
          for j := i1 to i2 do
          begin
            m_func[j] := EvalLineYd(j * fspmdx, p1, p2);
            // ЗЕРКАЛИРОВАННЫЙ СПЕКТР
            m_func[m_fftCount - j - 1] := m_func[j];
          end;
          p1 := p2;
        end;
      end;
  end;
end;

function cEvalStepAlg.GetCurveStr: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to length(m_band) - 1 do
  begin
    Result := Result + floattostr(m_band[i].x) + ';' + floattostr(m_band[i].y)
      + ';'
  end;
end;

procedure cEvalStepAlg.SetCurveStr(s: string);
var
  sub: string;
  b, first: boolean;
  p: point2d;
  i, pCount: integer;
begin
  if s = '' then
    exit;
  b := true;
  sub := '';
  i := 1;
  pCount := 0;
  first := true;
  setlength(m_band, 100);
  ZeroMemory(@m_band[0], length(m_band) * sizeof(point2d));
  while b do
  begin
    if i > length(s) then
      break;
    if s[i] = ';' then
    begin
      if first then
      begin
        p.x := strtofloatext(sub);
        first := false;
        sub := '';
      end
      else
      begin
        p.y := strtofloatext(sub);
        first := true;
        m_band[pCount] := p;
        inc(pCount);
        sub := '';
      end;
    end
    else
    begin
      sub := sub + s[i];
    end;
    inc(i);
  end;
  setlength(m_band, pCount);
end;

{ cAlgList }
function cAlgList.addAlg(name: string): cEvalStepAlg;
var
  i: integer;
begin
  Result := cEvalStepAlg.create;
  for i := 0 to Count - 1 do
  begin
    while getobj(name) <> nil do
    begin
      name := ModName(name, false);
    end;
  end;
  AddObject(name, Result);
  Result.name := name;
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
  i: integer;
  a: cEvalStepAlg;
begin
  for i := 0 to Count - 1 do
  begin
    a := getobj(i);
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

  newpath := dir + '\' + name + 'EvSt.xml';
  if not fileexists(newpath) then exit;

  doc := TNativeXml.create(nil);
  doc.XmlFormat := xfReadable;
  doc.LoadFromFile(newpath);
  if not FileExists(newpath) then
    exit;
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
        uRCFunc.LoadTag(tagnode, a.m_tag);
      tagnode := child.FindNode('OutTag');
      if tagnode <> nil then
        uRCFunc.LoadTag(tagnode, a.m_outTag);
      a.m_fltType := child.readAttributeInteger('FltType', 0);
      a.UpdateFFTSize;

      a.m_Threshold := child.ReadAttributeFloat('TrigThreshold', 0);
      a.m_TrigOffset := child.ReadAttributeFloat('TrigOffset', 0);
      a.m_TrigType := child.readAttributeInteger('TrigValType', 0);
      a.m_TrigMeanLenI := child.readAttributeInteger('TrigMeanLen', 10);
      a.m_useScalar := child.ReaDAttributeBool('UseScalarTag', true);
      tagnode := child.FindNode('TrigTag');
      if tagnode <> nil then
      begin
        LoadTag(tagnode, a.m_outScTag);
        if a.m_useScalar then
        begin
          if a.m_outScTag = nil then
          begin
            a.m_outScTag := cScalarTag.create;
            a.m_outScTag.name := a.m_tag.tagname + '_trig';
            if a.m_outScTag.t = nil then
            begin
              a.m_outScTag.CreateTag;
            end;
          end;
        end;
      end
      else
      begin
        if a.m_useScalar then
        begin
          if a.m_outScTag = nil then
          begin
            a.m_outScTag := cScalarTag.create;
            a.m_outScTag.fname := a.m_tag.tagname + '_trig';
            if a.m_outScTag.t = nil then
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

  newpath := dir + '\' + name + 'EvSt.xml';
  doc := TNativeXml.create(nil);
  doc.XmlFormat := xfReadable;
  if FileExists(newpath) then
    doc.LoadFromFile(newpath);

  node := doc.Root;
  node := getNode(node, 'EvalStepAlg');
  node.WriteAttributeInteger('AlgCount', g_AlgList.Count, 0);
  for i := 0 to g_AlgList.Count - 1 do
  begin
    a := getobj(i);
    child := getNode(node, 'Alg_' + inttostr(i));
    child.WriteAttributeString('AlgName', a.name, '');
    child.WriteAttributeInteger('numFFT', a.m_fftCount, 32);
    child.WriteAttributeInteger('OffsetFFT', a.m_fftShift, 32);
    child.WriteAttributeBool('UseFFTflt', a.m_fftFlt, false);
    child.WriteAttributeString('Band', a.GetCurveStr, '');
    child.WriteAttributeInteger('FltType', a.m_fltType, 0);

    child.WriteAttributeFloat('TrigThreshold', a.m_Threshold, 0);
    child.WriteAttributeFloat('TrigOffset', a.m_TrigOffset, 0);
    child.WriteAttributeInteger('TrigValType', a.m_TrigType, 0);
    child.WriteAttributeInteger('TrigMeanLen', a.m_TrigMeanLenI, 10);

    tagnode := getNode(child, 'inTag');
    uRCFunc.saveTag(a.m_tag, tagnode);
    tagnode := getNode(child, 'OutTag');
    uRCFunc.saveTag(a.m_outTag, tagnode);
    child.WriteAttributeBool('UseScalarTag', a.m_useScalar);
    if a.m_useScalar then
    begin
      tagnode := getNode(child, 'TrigTag');
      saveTag(a.m_outScTag, tagnode);
    end;
  end;
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
  Result := cEvalStepAlg(Objects[i]);
end;

function cAlgList.getobj(str: string): cEvalStepAlg;
var
  i: integer;
  o: cEvalStepAlg;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    o := getobj(i);
    if getobj(i).name = str then
    begin
      Result := o;
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

function LoadTag(node: txmlnode; p_t: cScalarTag): cScalarTag;
var
  t: itag;
  ir: irecorder;
  id: tagid;
  refcount: integer;
begin
  if p_t = nil then
  begin
    Result := cScalarTag.create;
  end
  else
  begin
    Result := p_t;
  end;
  Result.name := node.ReadAttributeString('TagName', '');
  Result.id := node.ReadAttributeInt64('TagID', -1);
  if Result.name <> '' then
  begin
    t := getTagByName(Result.name);
    if t <> nil then
    begin
      // t.GetTagId(result.tagid)
      t.GetTagId(Result.id);
    end
    else
    begin
      ir := getIR;
      t := getTagById(Result.id);
      if t <> nil then
      begin
        Result.t := t;
      end;
    end;
  end;
end;

function cScalarTag.CreateTag: itag;
begin
  if t = nil then
  begin
    t := createScalar(fname, true);
  end
  else
    Result := t;
end;

function cScalarTag.getname: string;
begin
  if t <> nil then
    Result := t.getname
  else
    Result := fname;
end;

procedure cScalarTag.setname(s: string);
var
  b: boolean;
  astr: ansistring;
begin
  b := false;
  if getname <> s then
  begin
    if not RStateConfig then
    begin
      b := true;
      ecm;
    end;
    astr := s;
    if t <> nil then
    begin
      t.setname(pansichar(lpcstr(StrToAnsi(s))));
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
