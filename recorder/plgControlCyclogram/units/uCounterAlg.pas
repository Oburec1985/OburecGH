unit uCounterAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml,
  pluginclass, sysutils;

type
  cCounterAlg = class(cbasealg)
  protected
    // относительные или абсолютные значения
    fRelative:boolean;
    fLo: double;
    fHi: double;
    // минимальный порог срабатывания
    fMinThreshold:double;
    fOutTag: cTag;
    fCounter: cardinal;
    // 0 <lo 1 >lo 2 >hi
    m_statetrig:integer;
  protected
    InTag: cTag;
    TrigTag: cTag;
    NullTag: cTag;
    m_NullPrev:double;
  protected
    procedure LoadTags(node: txmlNode);override;
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    function getExtProp: string;override;
    procedure doOnStart; override;
    procedure doEval(tag: cTag; time: double); override;
    procedure doGetData; override;
    // если поменялось имя входного канала то пересоздаем имя выходного канала, а может и тип
    // вызывается при загрузке или при установке входного тега
    procedure createOutChan;
    procedure updateOutChan;
    function getinptag: itag;
    procedure setinptag(t: itag); overload;
    procedure setinptag(t: cTag); overload;
    function genTagName: string;override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    function ready: boolean;override;
    function getHi:double;
    function getLo:double;
  public
    procedure setfirstchannel(t:itag);override;
  public
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
    // property inpTag:itag read getInptag write setInpTag;
    property lo: double read getLo write fLo;
    property hi: double read getHi write fHi;
    property Relative: boolean read fRelative write fRelative;
  end;

const
  C_CounterOpts = 'Hi=70,Lo=30';

implementation

{ cCounterAlg }

constructor cCounterAlg.create;
begin
  inherited;
  Properties := C_CounterOpts;
  fRelative:=true;
  TrigTag:=cTag.create;
  NullTag:=cTag.create;
end;

destructor cCounterAlg.destroy;
begin
  TrigTag.destroy;
  NullTag.destroy;
  inherited;
end;

procedure cCounterAlg.doEval(tag: cTag; time: double);
var
  I, len: Integer;
  v, null, a, h,l, lmin, lmax: double;
  // уровень выше hi, начинаем искать спад
  b, drop: boolean;
begin
  len := length(tag.m_TagData);
  null:=NullTag.GetMeanEst;
  if null<>m_NullPrev then
  begin
    drop:=true;
    fCounter:=0;
  end;
  if TrigTag.GetMeanEst=0 then
  begin
    for I := 0 to len - 1 do
    begin
      fOutTag.m_TagData[I] := fCounter;
    end;
    fOutTag.tag.PushDataEx(@fOutTag.m_TagData[0], len, 0, time);
    exit;
  end;

  h:=hi;
  l:=lo;
  fOutTag.m_TagData[0] := fCounter;
  lmin:= tag.m_TagData[1];
  lmax:= tag.m_TagData[1];
  for I := 0 to len - 1 do
  begin
    v := tag.m_TagData[I];
    lmin:=min(lmin,v,b);
    lmax:=max(lmax,v, b);
    case m_statetrig of
      0:
      begin
        if v>l then
        begin
          m_statetrig:=1;
        end;
      end;
      1:
      begin
        if v<l then
        begin
          m_statetrig:=0;
        end
        else
        begin
          if v>h then
          begin
            m_statetrig:=2;
          end;
        end;
      end;
      2:
      begin
        if v<l then
        begin
          a:=GetAmp(InTag.tag);
          if a>fMinThreshold then
          begin
            inc(fcounter);
          end;
          m_statetrig:=0;
        end;
      end;
    end;
    fOutTag.m_TagData[I] := fCounter;
  end;
  m_NullPrev:=null;
  fOutTag.tag.PushDataEx(@fOutTag.m_TagData[0], len, 0, time);
end;

procedure cCounterAlg.doGetData;
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
    writeBlockSize := fOutTag.block.GetBlocksSize;
    if writeBlockSize > length(fOutTag.m_TagData) then
    begin
      setlength(fOutTag.m_TagData, writeBlockSize);
    end;
    readyBlockCount := 0;
    if blCount > 0 then
    begin
      // сколько всего
      readyBlockCount := InTag.block.GetReadyBlocksCount;
      //logMessage('ReadyBlock: ' + inttostr(readyBlockCount));
      // если количество блоков больше чем кол-во обработанных блоков (т.е. есть новые данные)
      if readyBlockCount > InTag.m_readyBlock then
      begin
        newBlockCount := readyBlockCount - InTag.m_readyBlock;
        logMessage('newBlockCount: ' + inttostr(newBlockCount));
        BufCount := newBlockCount;
        // если готовых блоков больше чем размер буфера, то есть потери,
        // но с этим уже ничего не поделать
        if newBlockCount > blCount then
          BufCount := newBlockCount;
        for I := 0 to BufCount - 1 do
        begin
          InTag.m_readyBlock := readyBlockCount;
          tare := true;
          // например новых блоков 2. Последний блок в буфере всегда имеет последний тайм штамп.
          // Тогда, в цикле получаем блоки с последнего необработанного
          blInd := I + blCount - newBlockCount;
          //logMessage('blInd: ' + inttostr(newBlockCount));
          if SUCCEEDED(InTag.block.GetVectorR8(pointer(InTag.m_TagData)^,
              blInd, blSize, tare)) then
          begin
            timeinterval := InTag.block.GetBlockDeviceTime(blInd);
          end;
          // logMessage('BlInd:'+inttostr(blInd)+' Time:'+format('%.3g', [timeinterval]));
          // пишем блок данных
          doEval(InTag, timeinterval);
        end;
      end;
    end;
    InTag.block.unLockVector;
  end;
end;

procedure cCounterAlg.doOnStart;
begin
  inherited;
  fCounter := 0;
  m_statetrig:=0;
end;

class function cCounterAlg.getdsc: string;
begin
  result := 'Счетчик';
end;

function cCounterAlg.getExtProp: string;
begin
  result:='';
  if NullTag.tag<>nil then
    result:='NullTag='+NullTag.tagname;

  if TrigTag.tag<>nil then
    result:='TrigTag='+TrigTag.tagname;

  if intag<>nil then
    result:='Channel='+intag.tagname;
  if fOutTag<>nil then
    result:=result+',OutChannel='+foutTag.tagname;
end;

function cCounterAlg.getHi: double;
var
  m,a:double;
begin
  if fRelative then
  begin
    m:=GetMean(InTag.tag);
    a:=GetAmp(InTag.tag);
    // m-a+(2/100)*a*0.7
    result:=m+a*(0.02*fhi-1);
  end
  else
  begin
    result:=fHi;
  end;
end;

function cCounterAlg.getLo: double;
var
  m,a:double;
begin
  if fRelative then
  begin
    m:=GetMean(InTag.tag);
    a:=GetAmp(InTag.tag);
    result:=m+a*(0.02*flo-1);
  end
  else
  begin
    result:=fLo;
  end;
end;

function cCounterAlg.getinptag: itag;
begin

end;

procedure cCounterAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;
  if m_inpTags.Count > 0 then
  begin
    InTag := InputTag[0];
  end;
end;

procedure cCounterAlg.LoadTags(node: txmlNode);
begin

end;

function cCounterAlg.ready: boolean;
begin
  result:=false;
  if intag<>nil then
  begin
    if intag.tag<>nil then
    begin
      result:=true;
    end;
  end;
end;

procedure cCounterAlg.setfirstchannel(t: itag);
var
  lstr:string;
begin
  setinptag(t);
  lstr := GetParam(m_Properties, 'Channel');
  if InTag<>nil then
  begin
    m_Properties:=AddParamF(m_Properties,'Channel',InTag.tagname);
    if lstr='' then
    begin
      name:=genTagName;
    end;
  end;
end;

procedure cCounterAlg.setinptag(t: cTag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;
  if intag<>nil then
  begin
    InTag.destroy;
    InTag:=nil;
  end;
  InTag := t;
  addInputTag(InTag);
  if not FAILED(t.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    InTag.block := bl;
    bl := nil;
  end;
  if fOutTag = nil then
    createOutChan
  else
    updateOutChan;
end;

procedure cCounterAlg.setinptag(t: itag);
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

function cCounterAlg.GetProperties: string;
begin
  if m_properties = '' then
    m_properties := C_CounterOpts;
  result := m_properties;
end;

procedure cCounterAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
begin
  if str = '' then
    exit;
  m_properties:=updateParams(m_properties, str, '', ' ');
  lstr := GetParam(str, 'Lo');
  if lstr <> '' then
  begin
    fLo := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'Hi');
  if lstr <> '' then
  begin
    fHi := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'MinThreshold');
  if checkstr(lstr) then
  begin
    fMinThreshold := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'TrigTag');
  if CheckStr(lstr) then
  begin
    TrigTag.tagname:=lstr;
  end;

  lstr := GetParam(str, 'NullTag');
  if CheckStr(lstr) then
  begin
    NullTag.tagname:=lstr;
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
end;

function createVectorTagR8(tagname: string; freq: double;  CfgWritable: boolean): itag;
var
  ir: irecorder;
  Name, errMes: string;
  err: cardinal;
  v: OleVariant;
begin
  ir := getIR;
  result := itag(ir.CreateTag(lpcstr(StrToAnsi(tagname)), LS_VIRTUAL, nil));
  if result = nil then // ошибка создания виртуального тега
  begin
    err := ir.GetLastError;
    errMes := ir.ConvertErrorCodeToString(err);
    // showmessage(errMes);
  end;
  // установка типа тега : вектор, прием и передача
  VariantInit(v);
  VariantClear(v);
  TPropVariant(v).vt := VT_UI4;
  v := TTAG_VECTOR or TTAG_INPUT;
  result.SetProperty(TAGPROP_TYPE, v);
  // частота опроса
  result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, true);
  VariantClear(v);
  // v := fintag.tag.GetFreq; // частота опроса датчика
  result.SetFreq(freq);
  // тип передаваемых данных
  VariantClear(v);
  TPropVariant(v).vt := VT_R8;
  // v := VarAsType(v, varDouble);
  result.SetProperty(TAGPROP_DATATYPE, v);
  result.CfgWritable(CfgWritable);
  // минимальное и максимальное значение диапазона
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MINVALUE, v);
  // m_TestVTag.SetProperty(TAGPROP_MINVALUE, v);
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MAXVALUE, v);
  // m_TestWriteVTag.SetProperty(TAGPROP_MAXVALUE, v);
end;

function cCounterAlg.genTagName: string;
var
  tagname: string;
begin
  tagname := InTag.tagname;
  result := tagname + '_cnt';
end;

procedure cCounterAlg.createOutChan;
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
      fOutTag.tag := createVectorTagR8(genTagName, InTag.tag.getfreq, false);
      if not FAILED(fOutTag.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        fOutTag.block := bl;
        bl := nil;
      end;
      addOutTag(fOutTag);
      lcm;
    end;
  end;
end;

procedure cCounterAlg.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  bl: IBlockAccess;
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
  lcm;
end;

end.
