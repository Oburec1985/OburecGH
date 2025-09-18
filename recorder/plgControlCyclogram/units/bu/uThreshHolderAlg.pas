unit uThreshHolderAlg;


interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml,  MathFunction,
  pluginclass, sysutils, uQueue, uCommonTypes;

type

  // класс движок дл€ расчета thresHld без механизма тегов
  cThresHld = class
  protected
    m_data: cQueue<point2d>;
    m_max: double;
    m_histLen: double; // History length
    procedure RecalcMax;
  public
    constructor create(histLen: double); // Pass history length in constructor
    destructor destroy;
    // кладет в очередь новую точку и возвращает максимум
    function PushValue(p2: point2d): double;
  end;

  cThresHoldAlg = class(cbasealg)
  protected
    // длина предыстории в сек.
    fhistLen:double;
    fhistArray:array of double;
    InTag, outTag: cTag;
    // номер отсчета в буфере
    fValue:double;
    // номер отсчета в буфере
    fIndex:integer;
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
    // если помен€лось им€ входного канала то пересоздаем им€ выходного канала, а может и тип
    // вызываетс€ при загрузке или при установке входного тега
    procedure createOutChan;
    procedure updateOutChan;
    function getinptag: itag;
    procedure setinptag(t: itag); overload;
    procedure setinptag(t: cTag); overload;
    function genTagName: string;override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    function ready: boolean;override;
  public
    procedure setfirstchannel(t:itag);override;
  public
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
  end;

const
  C_TresHoldOpts = 'HistLen = 10';

implementation

{ cCounterAlg }

constructor cThresHoldAlg.create;
begin
  inherited;
  Properties := C_TresHoldOpts;
  OutTag:=cTag.create;
  OutTag.owner:=m_outTags;
  fhistLen:=10;
end;

destructor cThresHoldAlg.destroy;
begin
  OutTag.destroy;
  inherited;
end;

procedure cThresHoldAlg.doEval(tag: cTag; time: double);
var
  I, j, len, blCount: Integer;
  v, null, a, h,l: double;
  // уровень выше hi, начинаем искать спад
  b, drop: boolean;
  lshift:cardinal;
begin
  len := tag.lastindex;
  OutTag.tag.PushDataEx(@OutTag.m_TagData[0], tag.BlockSize, time+j*tag.m_blLen, time+j*tag.m_blLen);
end;

procedure cThresHoldAlg.doGetData;
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
      InTag.ResetTagData(InTag.lastindex);
    end;
  end;
end;

procedure cThresHoldAlg.doOnStart;
begin
  inherited;
  InTag.doOnStart;
  OutTag.doOnStart;
end;

class function cThresHoldAlg.getdsc: string;
begin
  result := '—четчик';
end;

function cThresHoldAlg.getExtProp: string;
begin
  result:='';

  if intag<>nil then
    result:='Channel='+intag.tagname;
  result:=result+',OutChannel='+outTag.tagname;
end;


function cThresHoldAlg.getinptag: itag;
begin

end;

procedure cThresHoldAlg.LinkTags;
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

  if OutTag.tagname<>'' then
  begin
    if OutTag.tag=nil then
    begin
      if InTag.tag<>nil then
        createOutChan;
    end;
  end;
end;

procedure cThresHoldAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;
  if m_inpTags.Count > 0 then
  begin
    InTag := InputTag[0];
  end;
end;

procedure cThresHoldAlg.LoadTags(node: txmlNode);
begin

end;

function cThresHoldAlg.ready: boolean;
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

procedure cThresHoldAlg.setfirstchannel(t: itag);
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

procedure cThresHoldAlg.setinptag(t: cTag);
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
end;

procedure cThresHoldAlg.setinptag(t: itag);
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

function cThresHoldAlg.GetProperties: string;
begin
  if m_properties = '' then
  begin
    m_properties := C_TresHoldOpts;
  end;
  result := m_properties;
end;

procedure cThresHoldAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
begin
  if str = '' then
    exit;
  m_properties:=updateParams(m_properties, str, '', ' ');

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
        OutTag.tagname:=lstr+'_Hold';
        if OutTag.tag = nil then
          createOutChan
        else
        begin
          updateOutChan;
        end;
      end
      else
      begin
        OutTag.tagname:=lstr+'_Hold';
      end;
    end;
    ChangeCTag(InTag, lstr);
  end;
end;


function cThresHoldAlg.genTagName: string;
var
  tagname: string;
begin
  tagname := InTag.tagname;
  result := tagname + '_Hold';
end;

procedure cThresHoldAlg.createOutChan;
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
      OutTag.tag:=getTagByName(str);
      if OutTag.tag=nil then
      begin
        OutTag.tag:=createScalar(str, false);
        //OutTag.tag := createVectorTagR8(str, InTag.tag.getfreq, true);
      end;
      if OutTag.tag=nil then
      begin
        OutTag.tagname:=OutTag.tagname;
      end;
      if not FAILED(OutTag.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        OutTag.block := bl;
        bl := nil;
      end;
      addOutTag(OutTag);
      lcm;
    end;
  end;
end;

procedure cThresHoldAlg.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  bl: IBlockAccess;
begin
  ecm;
  str := lpcstr(StrToAnsi(genTagName));
  OutTag.tag.SetName(str);
  OutTag.tag.SetFreq(InTag.tag.getfreq);
  OutTag.block := nil;
  if not FAILED(OutTag.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    OutTag.block := bl;
  end;
  lcm;
end;

{ cThresHld }

constructor cThresHld.create(histLen: double);
begin
  m_data := cQueue<point2d>.create;
  m_histLen := histLen;
  m_max := -1.0/0.0; // Negative infinity
end;

destructor cThresHld.destroy;
begin
  m_data.destroy;
  inherited;
end;

procedure cThresHld.RecalcMax;
var
  i: integer;
begin
  m_max := -1.0/0.0; // Negative infinity
  for i := 0 to m_data.size - 1 do
  begin
    if m_data.Peak(i).y > m_max then
      m_max := m_data.Peak(i).y;
  end;
end;

function cThresHld.PushValue(p2: point2d): double;
var
  removed: boolean;
begin
  m_data.push_back(p2);

  if p2.y > m_max then
    m_max := p2.y;

  removed := false;
  while (m_data.size > 0) and (p2.x - m_data.front.x > m_histLen) do
  begin
    if m_data.front.y = m_max then
      removed := true;
    m_data.pop_front;
  end;

  if removed then
    RecalcMax;

  result := m_max;
end;

end.