unit uCounterAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml,  MathFunction,
  pluginclass, sysutils;

type
  cCounterAlg = class(cbasealg)
  protected
    // сохранять значение при переходе в стоп
    fSaveVal:boolean;
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
    // значение смещения счетчика (принимается извне и суммируется с fCounter)
    ShiftTag: cTag;
    m_NullPrev:double;
  protected
    // поискать входные теги
    procedure LinkTags; override; // doRcInit
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
  c_maxCard = 4294967295;

implementation

{ cCounterAlg }

constructor cCounterAlg.create;
begin
  inherited;
  Properties := C_CounterOpts;
  fSaveVal:=false;
  fRelative:=true;
  TrigTag:=cTag.create;
  NullTag:=cTag.create;
  fOutTag:=cTag.create;
  fOutTag.owner:=m_outTags;
  ShiftTag:=cTag.create;
end;

destructor cCounterAlg.destroy;
begin
  TrigTag.destroy;
  NullTag.destroy;
  fOutTag.destroy;
  ShiftTag.destroy;
  inherited;
end;

procedure cCounterAlg.doEval(tag: cTag; time: double);
var
  I, j, len, blCount: Integer;
  v, null, a, h,l: double;
  // уровень выше hi, начинаем искать спад
  b, drop: boolean;
  lshift:cardinal;
begin
  len := tag.lastindex;
  blCount:=round(len/fOutTag.BlockSize);

  if ShiftTag.tag<>nil then
  begin
    lshift:=round(ShiftTag.GetMeanEst);
  end
  else
    lshift:=0;

  if NullTag.tag<>nil then
  begin
    null:=NullTag.GetMeanEst;
    if null<>m_NullPrev then
    begin
      drop:=true;
      fCounter:=0;
    end;
  end;

  if TrigTag.tag<>nil then
  begin
    if TrigTag.GetMeanEst=0 then
    begin
      for j := 0 to blCount - 1 do
      begin
        for I := 0 to fOutTag.BlockSize - 1 do
        begin
          fOutTag.m_TagData[I] := fCounter+lshift;
        end;
        //logmessage('time: '+formatstrNoE(time,4));
        fOutTag.tag.PushDataEx(@fOutTag.m_TagData[0], fOutTag.BlockSize, time+j*tag.getPortionLen, time+j*tag.getPortionLen);
        exit;
      end;
    end;
  end;

  h:=hi;
  l:=lo;
  fOutTag.m_TagData[0] := fCounter;
  for j := 0 to blCount - 1 do
  begin
    for I := 0 to tag.BlockSize - 1 do
    begin
      v := tag.m_ReadData[I+j*tag.BlockSize];

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
              if fCounter=c_maxCard then
                fcounter:=0
              else
                inc(fcounter);
            end;
            m_statetrig:=0;
          end;
        end;
      end;
      fOutTag.m_TagData[I] := fCounter+lshift;
    end;
    m_NullPrev:=null;
    //logmessage('Counter time: '+formatstrNoE(time+j*tag.m_blLen,4)
    // + ' blCount: '+INTToSTR(blCount)+ ' fCount: '+INTToSTR(fCounter));
    fOutTag.tag.PushDataEx(@fOutTag.m_TagData[0], tag.BlockSize, time+j*tag.m_blLen, time+j*tag.m_blLen);
  end;
end;

procedure cCounterAlg.doGetData;
var
  b:boolean;
begin
  if InTag.block = nil then
    exit;
  if InTag <> nil then
  begin
    b:=InTag.UpdateTagData(true);
    if b then
    begin
      doEval(InTag, InTag.m_ReadDataTime);
      //logmessage('InTag: '+formatstrNoE(InTag.m_ReadDataTime,4));
      //logmessage('InTag: '+inttostr(InTag.lastindex));
      InTag.ResetTagData(InTag.lastindex);
    end;
  end;
end;

procedure cCounterAlg.doOnStart;
begin
  inherited;
  InTag.doOnStart;
  fOutTag.doOnStart;
  if fSaveVal then
  begin

  end
  else
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

procedure cCounterAlg.LinkTags;
var
  mask:Cardinal;
begin
  inherited;
  if intag.tag=nil then
  begin
    InTag.tagname:=InTag.tagname;
    setflag(mask,ESTIMATOR_MEAN);
    setflag(mask,ESTIMATOR_PEAK);
    InTag.tag.SetEstimatorsMask(mask);
  end;

  if fOutTag.tagname<>'' then
  begin
    if fOutTag.tag=nil then
    begin
      if InTag.tag<>nil then
        createOutChan;
    end;
  end;
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
  mask:cardinal;
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
  setflag(mask,ESTIMATOR_MEAN);
  setflag(mask,ESTIMATOR_PEAK);
  t.tag.SetEstimatorsMask(mask);
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
  lstr := GetParam(str, 'SaveVal');
  if lstr <> '' then
  begin
    fSaveVal := StrToBool(lstr);
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
  lstr := GetParam(str, 'ShiftTag');
  if CheckStr(lstr) then
  begin
    ShiftTag.tagname:=lstr;
  end;

  lstr := GetParam(str, 'Channel');
  if lstr <> '' then
  begin
    if InTag = nil then
    begin
      InTag := cTag.create;
      t := getTagByName(lstr);
      if t<>nil then
      begin
        setinptag(t);
        fOutTag.tagname:=lstr+'_cnt';
        if fOutTag.tag = nil then
          createOutChan
        else
        begin
          updateOutChan;
        end;
      end
      else
      begin
        fOutTag.tagname:=lstr+'_cnt';
      end;
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
    exit;
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
  str, tagname: string;
  bl: IBlockAccess;
begin
  if InTag <> nil then
  begin
    if InTag.tag <> nil then
    begin
      ecm;
      str:=genTagName;
      fOutTag.tag:=getTagByName(str);
      if fOutTag.tag=nil then
        fOutTag.tag := createVectorTagR8(str, InTag.tag.getfreq, true);
      if fOutTag.tag=nil then
      begin
        fOutTag.tagname:=fOutTag.tagname;
      end;
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
