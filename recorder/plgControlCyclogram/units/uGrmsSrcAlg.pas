unit uGrmsSrcAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml, ucommontypes, uFFT, ubaseobj,
  pluginclass, sysutils, uSpm, uHardwaremath;

type
  cGrmsSrcAlg = class(cbasealg)
  private
    m_addNull: boolean;
    m_lastblockind: integer;
  public
    m_Taho: cTag;
    m_InTag: cTag;
    // спектры входных тегов
    m_spm: cspm;
    m_tahoSpm: cspm;
    // номер анализируемой гармоники
    m_numGarm: integer;
    m_outTag: cTag;
    // значение аргумента для АЧХ/ФЧХ. массив синхронизирован с m_outTag.m_TagData
    // (т.е. значению m_TagData соответствует значение в m_outTagX)
    m_outTagX: array of double;
  protected
    m_lastname: string;
    // номер значения при заполнении блока выходных данных
    // например число точек 13 000. Блок данных 4800. Тогда нужно заполнить 3 блока (m_blockind - номер блока)
    m_blockind,
    // число расчитанных точек внутри блока выходных данных
    pCount: integer;
    // ширина полосы в относительных единицах от частоты гармоники/ абсолютная полоса
    m_band: point2d;
    // пересчитанная непосредственно в индексы спектра полоса анализа - см. updateBandWidth
    m_bandwidthint: tpoint;
    fdX: double;
  private
    // расчет в UpdateBandWidth (doeval)
    m_curTahoValue: double;
  protected
    function genTagName: string; override;
    function Getdx: double; override;
    procedure doAfterload; override;
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    procedure doOnStart; override;
    procedure doEval(tag: cTag; time: double); override;
    procedure doGetData; override;
    procedure doUpdateSrcData(sender: tobject); override;
    procedure doEndEvalBlock(sender: tobject); override;
    // если поменялось имя входного канала то пересоздаем имя выходного канала, а может и тип
    // вызывается при загрузке или при установке входного тега
    procedure createOutChan;
    procedure updateOutChan;
    procedure updatedx;
    procedure updateBuff;
    function getinptag: itag;
    procedure setTahoTag(t: itag); overload;
    procedure setTahoTag(t: cTag); overload;
    procedure setinptag(t: itag); overload;
    procedure setinptag(t: cTag); overload;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure saveTags(node: txmlNode); override;
    procedure LoadTags(node: txmlNode); override;
    function ready: boolean; override;
    function getlasttime: double;
  public
    function readyBlockCount: integer;
    property lastTime: double read getlasttime;
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
  end;

const
  sqrt2 = 1.4142135623730950488016887242097;
  // NumGarm = 0 абсолютная полоса
  C_GrmsSrcOpts =
    'FFTCount=256, Band1=0.9, Band2=1.1, dX=0.1, Percent=1, NumGarm=1, Addnull=1';
  // разница в секундах меньше которой считаем что были потери данных
  c_mindT = 0.0001;

implementation

{ cPhaseAlg }

constructor cGrmsSrcAlg.create;
begin
  inherited;
  Properties := C_GrmsSrcOpts;
end;

procedure cGrmsSrcAlg.doUpdateSrcData(sender: tobject);
var
  // индекс в тестируемом спектре главной частоты по тахо
  I: integer;
  res: double;
  s: cspm;
  // updatetaho
  t1, t2, x: double;
  bandwidthint, startind, endind, spmInd: integer;
begin
  if sender = m_tahoSpm then
  begin
    // пересчитываем полосу по текущему значению тахо
    if m_numGarm <> 0 then
    begin
      x := m_tahoSpm.max.x;
      x := x * m_numGarm;
      m_curTahoValue := x;
      // количество отсчетов в спектре по которым усредняем
      startind := round(x * m_band.x / m_spm.dX);
      endind := round(x * m_band.y / m_spm.dX);
    end
    else
    begin
      startind := round(m_band.x / m_spm.dX);
      endind := round(m_band.x / m_spm.dX);
    end;
    if startind < 0 then
      startind := 0;
    if endind = startind then
      endind := startind + 1;
    if endind >= (AlignBlockLength(m_spm.m_rms)) then
      endind := AlignBlockLength(m_spm.m_rms) - 1;

    m_bandwidthint.x := startind;
    m_bandwidthint.y := endind;
  end;
  if sender = m_spm then
  begin
    // пересчитываем полосу по текущему значению тахо
    s := m_spm;
    res := 0;
    for I := m_bandwidthint.x to m_bandwidthint.y - 1 do
    begin
      res := res + tdoublearray(s.m_rms.p)[I] * tdoublearray(s.m_rms.p)[I];
    end;
    m_outTag.m_TagData[m_blockind] := sqrt(res);
    //m_outTag.m_TagData[m_blockind] := m_spm.m_rmsValue;
    m_outTagX[m_blockind] := m_spm.LastBlockTime;
    inc(m_blockind);
    if m_blockind = length(m_outTag.m_TagData) then
      doEndEvalBlock(nil);
  end;
end;

procedure cGrmsSrcAlg.doEndEvalBlock(sender: tobject);
var
  I: integer;
  v: double;
begin
  pCount := m_blockind;
  m_blockind := 0;
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

procedure cGrmsSrcAlg.doEval(tag: cTag; time: double);
begin

end;

procedure cGrmsSrcAlg.doGetData;
begin

end;

procedure cGrmsSrcAlg.doOnStart;
var
  I: integer;
begin
  pCount := 0;
  m_lastblockind := 0;
  ZeroMemory(@m_outTagX[0], length(m_outTagX) * sizeof(double));
  // inherited;
end;

class function cGrmsSrcAlg.getdsc: string;
begin
  result := 'СКЗ в полосе 1.0';
end;

function cGrmsSrcAlg.Getdx: double;
begin
  result := fdX;
end;

function cGrmsSrcAlg.getinptag: itag;
begin

end;

procedure cGrmsSrcAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;
end;

procedure cGrmsSrcAlg.LoadTags(node: txmlNode);
var
  tnode: txmlNode;
  I: integer;
  t: cTag;
begin
  tnode := node.FindNode('InTag');
  if tnode <> nil then
  begin
    t := loadTag(tnode, t);
    setinptag(m_InTag);
  end;

  tnode := node.FindNode('InTaho');
  if tnode <> nil then
  begin
    t := loadTag(tnode, m_Taho);
    setTahoTag(t);
  end;
end;

procedure cGrmsSrcAlg.saveTags(node: txmlNode);
var
  tnode: txmlNode;
  I: integer;
begin
  tnode := node.NodeNew('InTag');
  saveTag(m_InTag, tnode);

  tnode := node.NodeNew('InTaho');
  saveTag(m_Taho, tnode);
end;

function cGrmsSrcAlg.ready: boolean;
begin
  result := false;
  if m_Taho <> nil then
  begin
    if m_Taho.tag <> nil then
    begin
      if m_InTag.tag <> nil then
        result := true;
    end;
  end;
end;

function cGrmsSrcAlg.readyBlockCount: integer;
begin
  result := m_lastblockind;
end;

procedure cGrmsSrcAlg.setinptag(t: cTag);
var
  tagname: string;
  bl: IBlockAccess;
  outfreq: double;
begin
  if m_InTag <> nil then
  begin
    if t <> m_InTag then
    begin
      m_InTag.destroy;
      m_InTag := nil;
    end;
  end;
  if t <> m_InTag then
  begin
    m_InTag := t;
    setinptag(t.tag);
  end;
end;

function cGrmsSrcAlg.getlasttime: double;
begin
  result := m_outTagX[m_lastblockind];
end;

destructor cGrmsSrcAlg.destroy;
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
  inherited;
end;

procedure cGrmsSrcAlg.doAfterload;
begin
  if m_InTag <> nil then
  begin
    setinptag(m_InTag);
  end;
  if m_Taho <> nil then
  begin
    setTahoTag(m_Taho);
  end;
end;

procedure cGrmsSrcAlg.setinptag(t: itag);
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

  if m_spm <> nil then
    unsubscribe(m_spm);
  m_spm := cspm(g_algMng.getSpmByTagName(m_InTag.tagname));
  // не корректно плодить спектры источники если еще не загрузилась конфигурация!
  //if m_spm = nil then
  //begin
    //m_spm := cspm.create;
    //m_spm.setinptag(m_InTag.tag);
    //m_spm.name := m_spm.resname;
    //m_spm.Properties := Properties;
    //m_spm.UpdatePropStr;
    //g_algMng.Add(m_spm, nil);
  //end;
  if m_spm<>nil then
    m_spm.subscribe(self);

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

procedure cGrmsSrcAlg.setTahoTag(t: cTag);
var
  bl: IBlockAccess;
  tname: string;
begin
  if t = nil then
    exit;
  tname := t.tagname;

  if m_Taho = t then
    exit;
  if m_Taho <> nil then
    m_Taho.destroy;

  m_Taho := t;
  setTahoTag(t.tag);
end;

procedure cGrmsSrcAlg.setTahoTag(t: itag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;

  if m_Taho = nil then
    m_Taho := cTag.create;

  if m_Taho <> nil then
  begin
    m_Taho.tag := t;
    begin
      if m_tahoSpm <> nil then
        m_tahoSpm.unsubscribe(self);
      m_tahoSpm := cspm(g_algMng.getSpmByTagName(m_Taho.tagname));
      if m_tahoSpm = nil then
      begin
        m_tahoSpm := cspm.create;
        m_tahoSpm.setinptag(m_Taho.tag);
        m_tahoSpm.Properties := Properties;
        g_algMng.Add(m_tahoSpm, nil);
      end;
      m_tahoSpm.subscribe(self);
    end;
  end;

  updateOutChan;
end;

function cGrmsSrcAlg.GetProperties: string;
begin
  if m_properties = '' then
    m_properties := C_GrmsSrcOpts;
  result := m_properties;
end;

procedure cGrmsSrcAlg.SetProperties(str: string);
var
  lstr, spmstr: string;
  fftcount: integer;
  t: itag;
  change: boolean;
begin
  if str = '' then
    exit;
  inherited;
  // необходимо обновить выходной канал
  change := false;
  spmstr := '';
  if m_spm <> nil then
  begin
    spmstr := m_spm.Properties;
  end;

  lstr := GetParam(str, 'dX');
  if lstr <> '' then
  begin
    if fdX <> strtofloatext(lstr) then
    begin
      change := true;
      fdX := strtofloatext(lstr);
      if spmstr <> '' then
        spmstr := ChangeParamF(spmstr, 'dX', lstr);
    end;
  end;

  lstr := GetParam(str, 'Addnull');
  if checkstr(lstr) then
  begin
    m_addNull := strtoboolext(lstr);
    if spmstr <> '' then
      spmstr := ChangeParamF(spmstr, 'Addnull', lstr);
  end;

  lstr := GetParam(str, 'FFTCount');
  if lstr <> '' then
  begin
    fftcount := strtoint(lstr);
    if spmstr <> '' then
      spmstr := ChangeParamF(spmstr, 'FFTCount', lstr);
  end;

  lstr := GetParam(str, 'Band1');
  if lstr <> '' then
  begin
    m_band.x := strtofloatext(lstr);
  end;
  lstr := GetParam(str, 'Band2');
  if lstr <> '' then
  begin
    m_band.y := strtofloatext(lstr);
  end;

  lstr := GetParam(str, 'NumGarm');
  if lstr <> '' then
  begin
    m_numGarm := strtoint(lstr);
  end;

  lstr := GetParam(str, 'Channel');
  if lstr <> '' then
  begin
    if m_InTag = nil then
    begin
      m_InTag := cTag.create;
      t := getTagByName(lstr);
      setinptag(t);
      // сбрасываем обновл5ение вых канала т.к. только что обновили
      change := false;
    end;
    ChangeCTag(m_InTag, lstr);
  end;

  lstr := GetParam(str, 'Taho');
  if lstr <> '' then
  begin
    if m_Taho = nil then
    begin
      m_Taho := cTag.create;
    end;
    t := getTagByName(lstr);
    setTahoTag(t);
    change := false;
  end;
  if change then
    updateOutChan;

  if m_spm <> nil then
    m_spm.Properties := spmstr;
end;

function cGrmsSrcAlg.genTagName: string;
var
  tagname: string;
  b: boolean;
  t: itag;
begin
  result := '';
  if m_InTag = nil then
    exit;
  tagname := m_InTag.tagname;
  result := tagname + '_rms';

  b := true;
  while b do
  begin
    t := getTagByName(result);
    if (t = nil) or (result = m_lastname) then
    begin
      b := false;
      m_lastname := result;
    end
    else
      result := ModName(result, false);
  end;
end;

procedure cGrmsSrcAlg.createOutChan;
var
  tagname: string;
  bl: IBlockAccess;
  outfreq: double;
  inTag: cTag;
begin
  if inTag <> nil then
  begin
    if inTag.tag <> nil then
    begin
      ecm;
      m_outTag := cTag.create;
      updatedx;
      outfreq := 1 / fdX;
      m_outTag.tag := createVectorTagR8(genTagName, outfreq, false, false, false);
      // m_outTag.tag := createScalar(genTagName, false);
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

procedure cGrmsSrcAlg.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  bl: IBlockAccess;
  infreq, outfreq: double;
  OutTag: cTag;
begin
  if m_outTag <> nil then
  begin
    ecm;
    str := lpcstr(StrToAnsi(genTagName));
    m_outTag := OutputTag[0];
    m_outTag.tag.SetName(str);
    // updatedx;
    m_outTag.tag.SetFreq(1 / fdX);
    m_outTag.block := nil;
    if not FAILED(m_outTag.tag.QueryInterface(IBlockAccess, bl)) then
    begin
      m_outTag.block := bl;
    end;
    updateBuff;
    lcm;
  end;
end;

procedure cGrmsSrcAlg.updatedx;
var
  len: integer;
  ldx: double;
begin
  ldx := fdX;
  if m_spm <> nil then
  begin
    ldx := m_spm.getperiod;
    if m_tahoSpm <> nil then
    begin
      if m_tahoSpm.dX > ldx then
      begin
        ldx := m_tahoSpm.getperiod;
      end;
    end;
  end;
  fdX := ldx;
end;

procedure cGrmsSrcAlg.updateBuff;
var
  len: integer;
  ldx: double;
begin
  len := m_outTag.fBlock.GetBlocksSize;
  setlength(m_outTag.m_TagData, len);
  setlength(m_outTagX, len);
end;

end.
