unit uTimeIntervalAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml,
  pluginclass, sysutils;

type
 cTimeIntervalAlg = class(cbasealg)
  protected
    fAbs:boolean;
    // пороги при расчете по уровням
    fLo, fHi: double;
    // тег с результатами
    fOutTag: cTag;
  public
    m_minValue:double;
  protected
    ffreq: double;
    // входной тег
    fInTag: cTag;
    // размер порции по которой идет расчет (dt*fs)
    m_portionsize:integer;

    finitbuff:boolean;
  protected
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
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
    procedure LoadTags(node: txmlNode); override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    function ready:boolean;override;
  public
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
  end;

const
  C_TimeOpts = 'Hi=70,Lo=30,Abs=0';

implementation

{ cCounterAlg }

constructor cTimeIntervalAlg.create;
begin
  inherited;
  Properties := C_TimeOpts;
end;

destructor cTimeIntervalAlg.destroy;
begin
  if fOutTag<>nil then
  begin
    fOutTag.destroy;
    fOutTag:=nil;
  end;
  inherited;
end;





procedure cTimeIntervalAlg.doEval(tag: cTag; time: double);
var
  I, len: integer;
  v, lHi, lLo, mean, peak, min,
  // время первого и последнего импульса в порции
  curT:double;
  // уровень выше hi, начинаем искать спад
  startTrig: boolean;
  // длительность в секундах блока данных входного тега
  inFreq: double;
  // количество значений которое считаем по fft
  periodCount:integer;
begin
  len := tag.lastindex;
  {inFreq := tag.tag.GetFreq;

  mean := GetMean(tag.tag);
  peak := GetAmp(tag.tag);
  min := mean - peak;
  lHi := min + (0.02 * peak * fHi);
  lLo := min + (0.02 * peak * fLo);
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
  end;}
  fInTag.ResetTagData(m_portionsize);
end;

procedure cTimeIntervalAlg.doGetData;
begin
  if not finitbuff then exit;

  if fInTag <> nil then
  begin
    fInTag.UpdateTagData(true);
    doEval(fInTag, fInTag.m_ReadDataTime);
  end;
end;

procedure cTimeIntervalAlg.doOnStart;
begin
  inherited;
  if fInTag<>nil then
    fInTag.doOnStart;
  if fOutTag<>nil then
    fOutTag.doOnStart;

  ffreq := 0;
end;

class function cTimeIntervalAlg.getdsc: string;
begin
  result := 'Тахо';
end;

function cTimeIntervalAlg.getinptag: itag;
begin

end;

procedure cTimeIntervalAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
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

procedure cTimeIntervalAlg.LoadTags(node: txmlNode);
begin
  inherited;
  if m_inpTags.Count > 0 then
  begin
    fInTag := InputTag[0];
    if fInTag.tag <> nil then
      SetPeakEval(fInTag.tag, true);
  end;
end;

procedure cTimeIntervalAlg.SaveObjAttributes(xmlNode: txmlNode);
var
  tnode, tagnode: txmlNode;
  I: integer;
begin
  inherited;
  if fOutTag<>nil then
  begin
    tnode := xmlNode.NodeNew('OutputTag');
    tagnode := tnode.NodeNew('OutChan');
    saveTag(fOutTag, tagnode);
  end;

end;


function cTimeIntervalAlg.ready: boolean;
begin
  result:=false;
  if fintag<>nil then
  begin
    if fintag.tag<>nil then
    begin
      result:=true;
    end;
  end;
end;

procedure cTimeIntervalAlg.setinptag(t: cTag);
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

procedure cTimeIntervalAlg.setinptag(t: itag);
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

function cTimeIntervalAlg.GetProperties: string;
begin
 { if m_properties = '' then
    m_properties := C_TahoOpts;
  result := m_properties;}
end;


procedure cTimeIntervalAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
begin
  if str = '' then
    exit;
  inherited;
  lstr := GetParam(str, 'Lo');
  if checkstr(lstr) then
  begin
    fLo := strtoFloatExt(lstr);
  end;
  lstr := GetParam(str, 'WndType');

  lstr := GetParam(str, 'Hi');
  if checkstr(lstr) then
  begin
    fHi := strtoFloatExt(lstr);
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
  // размер выхожного буфера
  if fOutTag <>nil then
  begin

  end
  else
  begin
    createOutChan;
  end;
end;

function cTimeIntervalAlg.genTagName: string;
var
  tagname: string;
begin
{  tagname := InTag.tagname;
  result := tagname + '_Taho';}
end;

procedure cTimeIntervalAlg.createOutChan;
var
  tagname: string;
  bl: IBlockAccess;
begin
{  if InTag <> nil then
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
  end;}
end;

procedure cTimeIntervalAlg.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  bl: IBlockAccess;
begin
  ecm;
{  str := lpcstr(StrToAnsi(genTagName));
  if fOutIsNew then
  begin
    fOutTag.tag.SetName(str);
  end;
  if fTahoType then
    fOutTag.tag.SetFreq(InTag.tag.GetFreq)
  else
    fOutTag.tag.SetFreq(1/fdx);
  fOutTag.block := nil;
  if not FAILED(fOutTag.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    fOutTag.block := bl;
  end;
  lcm;}
end;
end.
