unit uBaseAlg;

interface

uses
  classes, Windows, tags, uBaseObj, uBaseObjMng, activeX, nativexml, uRCFunc,
  pluginclass, blaccess, sysutils, uCommonTypes, uFFT, ap, fft,
  urecorderevents,
  uCommonMath,
  uMyMath,
  mathfunction,
  math,
  uHardwareMath,
  complex,
  uBaseAlgBands,
  uRegClassesList,
  u2dmath;

type
  cAlgConfig = class;

  tAHUnit = (AHmult, // множитель на который надо домножить значение
    AH10db, // units=10lg(Ares/A)
    AH20db, // units=20lg(Ares/A)
    AHpercent); // scale=(1-percent/100)

  cAHgrad = class
  public
    m_name: string;
    m_points: array of point2d;
    m_units: tAHUnit;
  protected
    function getsize: integer;
    procedure setsize(s: integer);
    function getUnitString: string;
  public
    Function CorrectValue(v, freq: double): double;
    Function GetMultDsc(i: integer): string; overload;
    Function GetMultDsc(freq: double): string; overload;
    property size: integer read getsize write setsize;
    property units: string read getUnitString;
    constructor create(name: string);
    destructor destroy;
  end;

  TBaseAlgContainerClass = class of cBaseAlgContainer;

  cBaseAlgContainer = class(cBaseObj)
  public
    m_parentCfg:cAlgConfig;
    // список алгоритмов кот передают данные по подписке сюда
    m_refList: tlist;
  protected
    fready:boolean;
    m_errors: tstringlist;
    m_properties: string;
    // список алгоритмов кот подписаны на обновлеение данных
    m_SubscribeList: tlist;
  protected
    procedure updateReady;virtual;
    procedure SetParentCfg(c:cAlgConfig);
    procedure doStopRecord;virtual;
    procedure doAfterload; virtual;
    procedure UpdatePropStr; virtual;
    procedure SetProperties(str: string); virtual;
    function GetProperties: string; virtual;
    // с учетом входных каналов
    function getExtProp: string; virtual;
    procedure Setdx(d: double); virtual; abstract;
    function Getdx: double; virtual; abstract;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    procedure saveTags(node: txmlNode); virtual; abstract;
    procedure LoadTags(node: txmlNode); virtual; abstract;
    function genTagName: string; virtual;
    procedure doGetData; virtual; abstract;
    // происходит при переходе в просмотр/ запись
    procedure doOnStart; virtual; abstract;
    function GetResName: string; virtual;
    procedure SetResName(s: string); virtual;
    procedure DoSetProperties(sender: tobject); virtual;
    procedure doUpdateSrcData(sender: tobject); virtual;
    procedure doEndEvalBlock(sender: tobject); virtual;
    procedure CallUpdateDataEvent; virtual;
    // Вызывается при завершении расчета блока данных. За одно обновление Recorder может быть расчитано несколько блоков данных.
    // здесь сбрасываем счетчик номера блоков или другие действия завершения расчета блока
    procedure CallEndEvalBlock; virtual;
    // отлинковать алгоритм назначения
    procedure delDstLink(dst: cBaseObj);
  public
    // поискать входные теги
    procedure LinkTags; virtual;
    function NotSaveToXml: boolean;override;
    procedure updateOutChan;virtual;
    procedure createOutChan;overload;virtual;
    procedure createOutChan(name:string);overload;virtual;
    procedure setfirstchannel(t:itag);virtual;
    procedure subscribe(dst: cBaseObj); virtual;
    // отписать алгоритм от источника
    // функция завиртуалена на случай если у приемника несколько источников.
    // соответственно если ранее алгоритм был подписан на другой источник, то его сперва надо отписать от источника при этом понять от какого именно
    procedure unsubscribe(src: cBaseObj); virtual;
    // убрать у алгоритма ссылку на его источник данных
    procedure delRef(a: cBaseObj);
    function ready: boolean; virtual;
    // шаг по времени. Может быть не кратен периоду рекордера (например за период рекордера
    // получаем несколько отсчетов)
    property dX: double read Getdx write Setdx;
    class function getdsc: string; virtual;
    function GetFullProperties: string;virtual;
    property Properties: string read GetProperties write SetProperties;
    property resname: string read GetResName write SetResName;
    property parentCfg: cAlgConfig read m_parentCfg write setParentCfg;
    constructor create; override;
    destructor destroy; override;
  end;

  cAlgConfig = class
  public
    clType:tClass;
    // для автосоздаваемых не треубется сохранение
    m_NotSaveCfg:boolean;
  private
    // родительский список конфигов
    m_cfgList:TList;
    m_str,
    m_name:string;
    // список подписанных алгоритмов
    m_childs: tlist;
  protected
    function getprops(algNum:integer):string;overload;
    function getprops:string;overload;
    procedure setprops(s:string);
  public
    function getwnd:TWndType;
    function ChildCount:integer;
    function getAlg(i:integer):cBaseAlgContainer;
    procedure delAlg(a:cBaseAlgContainer);
    property name:string read m_name write m_name;
    property str:string read getprops write setprops;
    constructor create(cl:TClass);
    destructor destroy;
    procedure AddChild(a:cBaseAlgContainer);
  end;

  cBaseAlg = class(cBaseAlgContainer)
  protected
    m_inpTags: tstringlist;
    m_outTags: tstringlist;
    m_config:cAlgConfig;
  protected
    procedure doOnStart; override;
    procedure destroyTagsList;
    function getInpTag(index: integer): cTag;
    function getOutTag(index: integer): cTag;
    procedure doEval(intag: cTag; time: double); virtual;
    procedure addInputTag(t: cTag);
    procedure addOutTag(t: cTag);
    procedure doGetData; override;
    procedure saveTags(node: txmlNode); override;
    procedure LoadTags(node: txmlNode); override;
  public
    function InpTagsCount: integer;
    function OutTagsCount: integer;
    property InputTag[index: integer]: cTag read getInpTag;
    property OutputTag[index: integer]: cTag read getOutTag;
  public
    constructor create; override;
    destructor destroy; override;
  end;

  cSrcList = class(cBaseObj)
  protected
  public
    constructor create; override;
    destructor destroy; override;
  end;

  cSrcAlg = class(cBaseAlgContainer);

  cAlgMng = class(cBaseObjMng)
  public
    // привязки тегов к ГХ. ключ - имя тега, объект - ГХ
    m_AHNames: tstringlist;
    // список ГХ для корректировки АЧХ
    m_AHList: tlist;
    m_srcList: cSrcList;
    m_bands: tstringlist;
    m_places: TPlaces;
    // список TTagBandPair
    m_TagBandPairList: TTagBandPairList;

    // список настроек алгоритмов
    m_cfgList:Tlist;
    m_enabled:boolean;
  protected
    function getplace(str: string): TPlace;
    // происходит при переходе в просмотр/запись
    procedure doStart;
    procedure doStopRecord;
    procedure doChangeRState(sender: tobject);
    procedure doChangeCfg(sender: tobject);
    procedure createEvents;
    procedure DestroyEvents;
    procedure doUpdateTags(sender: tobject);
    procedure doGetData;
    procedure regObjClasses; override;
    function getAlgClass(str:string): tclass;
    procedure AddBaseObjInstance(obj: cBaseObj); override;
    procedure removeObj(obj: cBaseObj); override;
    procedure doRenameObj(sender: tobject); override;
    function SpmCount: integer;
    procedure doAfterLoadXML; override;
    procedure XMLSaveMngAttributes(node: txmlNode); override;
    procedure XMLlOADMngAttributes(node: txmlNode); override;
    procedure XMLlOADMngAttributesAfterObjects(node:txmlnode);override;

    function getBand(i: integer): tBand; overload;
    function getBand(str: string): tBand; overload;
    procedure UpdateBands;
    procedure clearbands;
  public
    function getAH(i: integer): cAHgrad; overload;
    function getAH(p_name: string): cAHgrad; overload;
    function newAH(name: string): cAHgrad;
    procedure clearAHlist;

    function getCfg(i: integer): cAlgConfig;overload;
    function getCfg(cfgname: string): cAlgConfig;overload;
    function CfgCount:integer;
    function newCfg(name: string; cltype:TClass): cAlgConfig;
    procedure clearCfgList;

    procedure AddAHName(tagname: string; AHGrad: cAHgrad);
    procedure DelAHNames(AHGrad: cAHgrad);
    function GetAHGradByTagName(tagname: string): cAHgrad;
  public
    constructor create; override;
    destructor destroy; override;
    function getSpm(str: string): cBaseAlgContainer;
    function getSpmByTagName(str: string): cBaseAlgContainer;
    function getAlg(i: integer): cBaseAlg; overload;
    function getAlg(s: string): cBaseAlg; overload;
  end;

function TAHUnToInt(u: tAHUnit): integer;
function IntToAHUn(u: integer): tAHUnit;

const
  c_wiki_spm = 0;
  c_alglib_cpxSpm = 1;
  c_abs = 0;
  c_rate = 1;
  e_OnSetAlgProperties = $00002000;
  e_OnUpdateSrcData = $00004000;
  // событие когда вручную через форму поменяли алгоритмы
  E_OnChangeAlgCfg = $00008000;
  c_debugAlg = false;


var
  g_algMng: cAlgMng;


implementation

uses
  uCounterAlg, uTahoAlg, uGrmsAlg, uGrmsSrcAlg, uPhaseAlg, uFillingFactorAlg,
  uSynchroPhaseAlg, uSpm, uPeakFactorAlg, uIntegralAlg,
  uAriphmAlg;

function TAHUnToInt(u: tAHUnit): integer;
begin
  case u of
    AHmult:
      result := 0;
    AH10db:
      result := 1;
    AH20db:
      result := 2;
    AHpercent:
      result := 3;
  end;
end;

function IntToAHUn(u: integer): tAHUnit;
begin
  case u of
    0:
      result := AHmult;
    1:
      result := AH10db;
    2:
      result := AH20db;
    3:
      result := AHpercent;
  end;
end;


procedure cBaseAlgContainer.CallEndEvalBlock;
var
  i: integer;
  a: cBaseAlgContainer;
begin
  for i := 0 to m_SubscribeList.Count - 1 do
  begin
    a := cBaseAlgContainer(m_SubscribeList.items[i]);
    a.doEndEvalBlock(self);
  end;
end;

procedure cBaseAlgContainer.CallUpdateDataEvent;
var
  i: integer;
  a: cBaseAlgContainer;
begin
  for i := 0 to m_SubscribeList.Count - 1 do
  begin
    a := cBaseAlgContainer(m_SubscribeList.items[i]);
    a.doUpdateSrcData(self);
  end;
end;

constructor cBaseAlgContainer.create;
begin
  inherited;
  m_SubscribeList := tlist.create;
  m_refList := tlist.create;
  m_errors := tstringlist.create;
end;

procedure cBaseAlgContainer.createOutChan;
begin

end;

procedure cBaseAlgContainer.createOutChan(name: string);
begin

end;

destructor cBaseAlgContainer.destroy;
var
  i, j: integer;
  a: cBaseAlgContainer;
begin
  // чистим тех кто подписан на нас
  for i:=0 to m_SubscribeList.Count-1 do
  begin
    a := cBaseAlgContainer(m_SubscribeList.items[i]);
    a.unsubscribe(self);
  end;
  m_SubscribeList.destroy;
  m_SubscribeList := nil;
  // исключаем себя из списка получателей у источника
  for i := 0 to m_refList.Count - 1 do
  begin
    a := cBaseAlgContainer(m_refList.items[i]);
    // отписываем получателя у владельца
    for j:=0 to a.m_SubscribeList.Count - 1 do
    begin
      if a.m_SubscribeList.Items[j]=self then
      begin
        a.m_SubscribeList.Delete(j);
        break;
      end;
    end;
  end;
  m_refList.destroy;
  m_refList := nil;

  m_errors.destroy;
  m_errors := nil;
  inherited;
end;

procedure cBaseAlgContainer.doAfterload;
begin

end;

procedure cBaseAlgContainer.doEndEvalBlock(sender: tobject);
begin

end;

procedure cBaseAlgContainer.DoSetProperties(sender: tobject);
begin
  g_algMng.Events.CallAllEventsWithSender(e_OnSetAlgProperties, sender);
end;

procedure cBaseAlgContainer.doStopRecord;
begin

end;

procedure cBaseAlgContainer.doUpdateSrcData(sender: tobject);
begin

end;

function cBaseAlgContainer.genTagName: string;
begin
  result := classname + '_Не перекрыт метод genTagName'
end;

class function cBaseAlgContainer.getdsc: string;
begin

end;

function cBaseAlgContainer.getExtProp: string;
begin

end;

function cBaseAlgContainer.GetFullProperties: string;
begin
  result:=updateParams(Properties, getExtProp);
end;

function cBaseAlgContainer.GetProperties: string;
begin
  if m_parentCfg<>nil then
  begin
    result:=updateParams(m_parentCfg.str, getExtProp);
  end
  else
  begin
    result:=m_properties;
  end;
end;

function cBaseAlgContainer.GetResName: string;
begin
  result := genTagName;
end;

procedure cBaseAlgContainer.SetProperties(str: string);
begin
  m_properties := str;
  DoSetProperties(self);
end;

procedure cBaseAlgContainer.SetResName(s: string);
begin

end;

procedure cBaseAlgContainer.subscribe(dst: cBaseObj);
var
  prevsrc: cBaseAlgContainer;
  I: Integer;
  b:boolean;
begin
  b:=true;
  for I := 0 to cBaseAlgContainer(dst).m_refList.Count - 1 do
  begin
    if cBaseAlgContainer(dst).m_refList.items[i]=self then
    begin
      b:=false;
      break;
    end;
  end;
  if b then
    cBaseAlgContainer(dst).m_refList.Add(self);
  b:=true;
  for I := 0 to m_SubscribeList.Count - 1 do
  begin
    if m_SubscribeList.Items[i]=dst then
    begin
      b:=false;
      break;
    end;
  end;
  if b then
    m_SubscribeList.add(dst);
end;

procedure cBaseAlgContainer.unsubscribe(src: cBaseObj);
begin
  delRef(src);
  cbasealgcontainer(src).delDstLink(self);
end;

procedure cBaseAlgContainer.updateOutChan;
begin

end;

procedure cBaseAlgContainer.delDstLink(dst: cBaseObj);
var
  I: Integer;
  a:cBaseObj;
begin
  for I := 0 to m_SubscribeList.Count - 1 do
  begin
    a:=cBaseAlgContainer(m_SubscribeList.items[i]);
    if a=dst then
    begin
      m_SubscribeList.Delete(i);
      break;
    end;
  end;
end;

procedure cBaseAlgContainer.delRef(a: cBaseObj);
var
  i: integer;
begin
  for i := 0 to m_refList.Count - 1 do
  begin
    if m_refList.items[i] = a then
    begin
      m_refList.Delete(i);
      break;
    end;
  end;
end;

procedure cBaseAlgContainer.UpdatePropStr;
begin

end;

procedure cBaseAlgContainer.updateReady;
begin

end;

procedure cBaseAlgContainer.SaveObjAttributes(xmlNode: txmlNode);
begin
  inherited;
  saveTags(xmlNode);
  xmlNode.WriteAttributeString('Properties', Properties);
end;

procedure cBaseAlgContainer.setfirstchannel(t: itag);
begin

end;

procedure cBaseAlgContainer.setParentCfg(c: cAlgConfig);
begin
  m_ParentCfg:=c;
end;

procedure cBaseAlgContainer.LinkTags;
begin

end;

procedure cBaseAlgContainer.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;
  LoadTags(xmlNode);
  Properties := xmlNode.ReadAttributeString('Properties', '');
end;

function cBaseAlgContainer.NotSaveToXml: boolean;
begin
  if parentCfg=nil then
    result:=m_NotSaveToXml
  else
  begin
    if not m_NotSaveToXml then
    begin
      result:=parentCfg.m_NotSaveCfg;
    end;
  end;
end;

function cBaseAlgContainer.ready: boolean;
begin
  result := fready;
end;

{ cBaseAlg }

procedure cBaseAlg.addInputTag(t: cTag);
var
  i: integer;
  lt: cTag;
begin
  for i := 0 to m_inpTags.Count - 1 do
  begin
    lt := InputTag[i];
    if lt = t then
      exit;
  end;
  m_inpTags.AddObject(t.tagname, t);
end;

procedure cBaseAlg.addOutTag(t: cTag);
var
  i: integer;
  lt: cTag;
begin
  for i := 0 to m_outTags.Count - 1 do
  begin
    lt := OutputTag[i];
    if lt = t then
      exit;
  end;
  m_outTags.AddObject(t.tagname, t);
end;

constructor cBaseAlg.create;
begin
  inherited;
  m_inpTags := tstringlist.create;
  m_outTags := tstringlist.create;
end;

destructor cBaseAlg.destroy;
begin
  destroyTagsList;
  inherited;
end;

procedure cBaseAlg.destroyTagsList;
var
  i: integer;
  t: cTag;
begin
  for i := 0 to InpTagsCount - 1 do
  begin
    t := InputTag[i];
    t.destroy;
  end;
  m_inpTags.Clear;
  m_inpTags.destroy;
  m_inpTags := nil;
  for i := 0 to OutTagsCount - 1 do
  begin
    t := OutputTag[i];
    t.destroy;
  end;
  m_outTags.destroy;
  m_outTags := nil;
end;

procedure cBaseAlg.doEval(intag: cTag; time: double);
begin

end;

procedure cBaseAlg.doGetData;
begin

end;

procedure cBaseAlg.doOnStart;
var
  i: integer;
  t: cTag;
begin
  for i := 0 to m_inpTags.Count - 1 do
  begin
    t := getInpTag(i);
    t.m_readyBlock := 0;
  end;
  for i := 0 to m_outTags.Count - 1 do
  begin
    t := getOutTag(i);
    t.m_readyBlock := 0;
  end;
  updateReady;
end;

function cBaseAlg.getInpTag(index: integer): cTag;
begin
  result := cTag(m_inpTags.Objects[index]);
end;

function cBaseAlg.getOutTag(index: integer): cTag;
begin
  result := cTag(m_outTags.Objects[index]);
end;

function cBaseAlg.InpTagsCount: integer;
begin
  result := m_inpTags.Count;
end;

function cBaseAlg.OutTagsCount: integer;
begin
  result := m_outTags.Count;
end;

procedure cBaseAlg.saveTags(node: txmlNode);
var
  tnode, tagnode: txmlNode;
  i: integer;
  t: cTag;
begin
  tnode := getNode(node,'InputTags');
  for i := 0 to m_inpTags.Count - 1 do
  begin
    t := InputTag[i];
    tagnode := getNode(tnode,'Tag_' + inttostr(i));
    saveTag(t, tagnode);
  end;
  tnode := getNode(node,'OutputTags');
  for i := 0 to m_outTags.Count - 1 do
  begin
    t := OutputTag[i];
    tagnode := getNode(tnode,'Tag_' + inttostr(i));
    saveTag(t, tagnode);
  end;
end;

procedure cBaseAlg.LoadTags(node: txmlNode);
var
  tnode, tagnode: txmlNode;
  i: integer;
  t: cTag;
begin
  tnode := node.FindNode('InputTags');
  if tnode <> nil then
  begin
    for i := 0 to tnode.NodeCount - 1 do
    begin
      tagnode := tnode.FindNode('Tag_' + inttostr(i));
      t := loadTag(tagnode, nil);
      if t <> nil then
        addInputTag(t);
    end;
  end;
  tnode := getNode(node,'OutputTags');
  if tnode <> nil then
  begin
    for i := 0 to tnode.NodeCount - 1 do
    begin
      tagnode := getNode(tnode,'Tag_' + inttostr(i));
      t := loadTag(tagnode, nil);
      if t <> nil then
        addOutTag(t);
    end;
  end;
end;

{ cAlgMng }
procedure cAlgMng.AddAHName(tagname: string; AHGrad: cAHgrad);
begin
  m_AHNames.AddObject(tagname, AHGrad);
end;

procedure cAlgMng.AddBaseObjInstance(obj: cBaseObj);
begin
  inherited;
  if obj is cSrcAlg then
  begin
    obj.parent := m_srcList;
  end;
end;

procedure cAlgMng.clearbands;
var
  i: integer;
  b: tBand;
begin
  while m_bands.Count>0 do
  begin
    b := tBand(m_bands.Objects[0]);
    b.destroy;
  end;
  Clear;
end;


constructor cAlgMng.create;
begin
  inherited;
  m_enabled:=true;
  createEvents;
  m_AHNames := tstringlist.create;
  m_AHNames.Sorted := true;
  m_AHNames.Duplicates := dupIgnore;
  m_AHList := tlist.create;

  m_srcList := cSrcList.create;
  m_srcList.autocreate := true;
  add(m_srcList);

  m_bands := tstringlist.create;
  m_places := TPlaces.create;
  m_TagBandPairList := TTagBandPairList.create;

  m_cfgList:=TList.Create;
end;

destructor cAlgMng.destroy;
var
  I: Integer;
begin
  DestroyEvents;

  clearahlist;
  m_AHList.destroy;
  m_AHNames.destroy;

  clearbands;
  m_bands.destroy;

  m_places.destroy;
  m_TagBandPairList.destroy;
  // функция из uRCFunc
  FreeFFTPlanList;
  FreeInverseFFTPlanList;

  inherited;
end;

procedure cAlgMng.createEvents;
begin
  AddPlgEvent('cAlgMng_doUpdateTags', c_RUpdateData, doUpdateTags);
  AddPlgEvent('cAlgMng_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
  AddPlgEvent('cAlgMng_doChangeCfg', c_RC_LeaveCfg, doChangeCfg);
end;

procedure cAlgMng.DelAHNames(AHGrad: cAHgrad);
var
  i: integer;
begin
  i := 0;
  while i < m_AHNames.Count do
  begin
    if m_AHNames.Objects[i] = AHGrad then
    begin
      m_AHNames.Delete(i);
      continue;
    end
    else
    begin
      inc(i);
    end;
  end;
end;

procedure cAlgMng.DestroyEvents;
begin
  RemovePlgEvent(doUpdateTags, c_RUpdateData);
  RemovePlgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cAlgMng.doAfterLoadXML;
var
  i: integer;
  a: tobject;
begin
  inherited;
  for i := 0 to Count - 1 do
  begin
    a := getAlg(i);
    if a is cBaseAlgContainer then
      cBaseAlgContainer(a).doAfterload;
  end;
end;

procedure cAlgMng.doChangeCfg(sender: tobject);
var
  a: cbaseobj;
  i: integer;
begin
  // предрасчет
  for i := 0 to Count - 1 do
  begin
    a := getobj(i);
    if a is cSrcAlg then
    begin
      // в методе ready зашита инициализация спектров
      if not cSrcAlg(a).ready then
      begin

      end;
    end;
    if a is cGrmsSrcAlg then
    begin
      // в методе ready зашита инициализация спектров
      if not cGrmsSrcAlg(a).ready then
      begin

      end;
    end;
  end;
end;

procedure cAlgMng.doChangeRState(sender: tobject);
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

procedure cAlgMng.doGetData;
begin

end;

procedure cAlgMng.doRenameObj(sender: tobject);
begin
  inherited;
end;

procedure cAlgMng.doStart;
var
  i: integer;
  a: cBaseObj;
begin
  for i := 0 to Count - 1 do
  begin
    a := getobj(i);
    if a is cBaseAlgContainer then
    begin
      cBaseAlgContainer(a).doOnStart;
    end;
  end;
end;

procedure cAlgMng.doStopRecord;
var
  a: cBaseAlgContainer;
  i: integer;
begin
  // предрасчет
  for i := 0 to Count - 1 do
  begin
    a := getAlg(i);
    if a=nil then continue;

    if a is cSrcAlg then
    begin
      if not a.ready then
        continue;
      if a is cSpm then
        cSpm(a).doStopRecord;
    end
    else
    begin

      a.doStopRecord;
    end;
  end;
end;

procedure cAlgMng.UpdateBands;
var
  i: integer;
  b: tBand;
begin
  for i := 0 to m_bands.Count - 1 do
  begin
    b := getBand(i);
    b.eval;
  end;
end;

procedure cAlgMng.doUpdateTags(sender: tobject);
var
  a: cbaseobj;
  i: integer;
begin
  if not m_enabled then exit;

  // предрасчет
  for i := 0 to Count - 1 do
  begin
    a := getobj(i);
    if a is cSrcAlg then
    begin
      if not cSrcAlg(a).ready then
      begin
        continue;
      end;
      cSrcAlg(a).doGetData;
    end;
  end;
  for i := 0 to Count - 1 do
  begin
    a := getAlg(i);
    if a is cBaseAlg then
    begin
      if not cBaseAlg(a).ready then
        continue;
      if (a is cBaseAlg) then
      begin
        cBaseAlg(a).doGetData;
      end;
    end;
  end;
  UpdateBands;
end;

function cAlgMng.getAlg(i: integer): cBaseAlg;
var
  o:cbaseobj;
begin
  o:=getobj(i);
  if o is cbasealg then
    result := cBaseAlg(getobj(i))
  else
    result:=nil;
end;

function cAlgMng.getAH(i: integer): cAHgrad;
begin
  result := cAHgrad(m_AHList.items[i]);
end;

function cAlgMng.getAH(p_name: string): cAHgrad;
var
  i: integer;
  a: cAHgrad;
begin
  result := nil;
  for i := 0 to m_AHList.Count - 1 do
  begin
    a := getAH(i);
    if a.m_name = p_name then
    begin
      result := a;
      break;
    end;
  end;
end;

function cAlgMng.GetAHGradByTagName(tagname: string): cAHgrad;
var
  i: integer;
begin
  if m_AHNames.Find(tagname, i) then
  begin
    result := getAH(i);
  end
  else
    result := nil;
end;

function cAlgMng.newAH(name: string): cAHgrad;
begin
  result := cAHgrad.create(name);
  m_AHList.add(result);
end;

function cAlgMng.CfgCount:integer;
begin
  result:=m_cfgList.Count;
end;

procedure cAlgMng.clearCfgList;
var
  I: Integer;
  cfg:cAlgConfig;
begin
  while CfgCount<>0 do
  begin
    cfg:=getCfg(0);
    cfg.destroy;
  end;
end;

function cAlgMng.getCfg(i: integer): cAlgConfig;
begin
  result:=cAlgConfig(m_cfgList.Items[i]);
end;

function cAlgMng.getCfg(cfgname: string): cAlgConfig;
var
  I: Integer;
begin
  result:=nil;
  for I := 0 to m_cfgList.Count - 1 do
  begin
    if cAlgConfig(m_cfgList.Items[i]).name=cfgname then
    begin
      result:=cAlgConfig(m_cfgList.Items[i]);
      exit;
    end;
  end;
end;

function cAlgMng.newCfg(name: string; cltype:TClass): cAlgConfig;
begin
  result:=cAlgConfig.create(cltype);
  result.name:=name;
  result.m_cfgList:=m_cfgList;
  m_cfgList.Add(result);
end;

procedure cAlgMng.clearahlist;
var
  i: integer;
  a: cAHgrad;
begin
  for i := 0 to m_AHList.Count - 1 do
  begin
    a := getAH(i);
    a.destroy;
  end;
  m_AHNames.Clear;
  m_AHList.Clear;
end;

function cAlgMng.getAlg(s: string): cBaseAlg;
var
  obj: cBaseObj;
  i: integer;
begin
  result := nil;
  for i := 0 to Count - 1 do
  begin
    obj := getobj(i);
    if obj is cBaseAlgContainer then
    begin
      if s = cBaseAlgContainer(obj).resname then
      begin
        result := cBaseAlg(obj);
        exit;
      end;
    end;
  end;
end;

function cAlgMng.getBand(i: integer): tBand;
begin
  result := tBand(m_bands.Objects[i]);
end;

function cAlgMng.getBand(str: string): tBand;
var
  i: integer;
begin
  result := nil;
  for i := 0 to m_bands.Count - 1 do
  begin
    if str = m_bands.Strings[i] then
    begin
      result := getBand(i);
      exit;
    end;
  end;
end;

function cAlgMng.getplace(str: string): TPlace;
begin
  result := m_places.getplace(str);
end;

function cAlgMng.getSpm(str: string): cBaseAlgContainer;
var
  i: integer;
  a: cBaseAlgContainer;
begin
  result := nil;
  for i := 0 to Count - 1 do
  begin
    a := cBaseAlgContainer(getobj(i));
    if a is cSpm then
    begin
      if lowercase(cSpm(a).resname) = lowercase(str) then
      begin
        result := a;
        exit;
      end;
    end;
  end;
end;

function cAlgMng.getSpmByTagName(str: string): cBaseAlgContainer;
var
  i: integer;
  a: cbaseobj;
begin
  result := nil;
  for i := 0 to Count - 1 do
  begin
    a := getobj(i);
    if a is cSpm then
    begin
      if cSpm(a).m_tag.tagname = str then
      begin
        result := cBaseAlgContainer(a);
        exit;
      end;
    end;
  end;
end;

procedure cAlgMng.regObjClasses;
begin
  regclass(cCounterAlg);
  regclass(cTahoAlg);
  // regclass(cGrmsAlg);
  regclass(cSyncPhaseAlg);
  regclass(cGrmsSrcAlg);
  regclass(cSrcList);
  regclass(cSpm);
  regclass(cPhaseAlg);
  regclass(cFillingFactorAlg);
  regclass(cPeakFactorAlg);
  regclass(cIntegralAlg);
  regclass(cAriphmAlg);
end;

function cAlgMng.getAlgClass(str:string): tclass;
var
  I: Integer;
begin
  result:=nil;
  for I := 0 to regclasses.Count - 1 do
  begin
    if regclasses.strings[i]=str then
    begin
      result:=tclass(cObjCreator(regclasses.Objects[i]).createfunc);
      exit;
    end;
  end;
end;

procedure cAlgMng.removeObj(obj: cBaseObj);
begin
  inherited;
end;

function cAlgMng.SpmCount: integer;
var
  i: integer;
  a: cBaseAlgContainer;
begin
  result := 0;
  for i := 0 to Count - 1 do
  begin
    a := getAlg(i);
    if a is cSpm then
    begin
      inc(result);
    end;
  end;
end;

procedure cAlgMng.XMLlOADMngAttributes(node: txmlNode);
var
  child, bnode, pnode, tnode, n: txmlNode;
  i, j, k, tcount: integer;
  id: TAGID;
  b: tBand;
  p: TPlace;
  pair: TTagBandPair;
  t: BandTag;
  nodetype, str, str1, substr: string;
  a:cahgrad;
begin
  inherited;
  child := node.FindNode('BandsNode');
  if child <> nil then
  begin
    for i := 0 to child.NodeCount - 1 do
    begin
      bnode := child.Nodes[i];
      nodetype := bnode.ReadAttributeString('NodeType', '');
      if nodetype = 'BNode' then
      begin
        b := tBand.create(m_bands);
        b.name := bnode.ReadAttributeString('NodeName', '');
        b.m_f1f2.x := bnode.ReadAttributeFloat('F1', 0);
        b.m_f1f2.y := bnode.ReadAttributeFloat('F2', 0);
        b.valtype := bnode.ReadAttributeInteger('BType', 0);
        tcount := bnode.ReadAttributeInteger('TagCount', 0);
        for j := 0 to bnode.NodeCount - 1 do
        begin
          tnode := bnode.Nodes[j];
          nodetype := tnode.ReadAttributeString('NodeType', '');
          if nodetype = 'TNode' then
          begin
            t := BandTag.create;
            t.tagname := tnode.ReadAttributeString('TagName', '');
            t.k := tnode.ReadAttributeFloat('Kmult', 0);
            //b.m_TagsList.AddObject(t.m_t, t);
            b.addBandTag(t);
          end;
        end;
        m_bands.AddObject(b.name, b);
      end;
    end;
  end;
  child := node.FindNode('PlacesNode');
  if child <> nil then
  begin
    for i := 0 to child.NodeCount - 1 do
    begin
      pnode := child.Nodes[i];
      nodetype := pnode.ReadAttributeString('NodeType', '');
      if nodetype = 'PlaceNode' then
      begin
        p := TPlace.create(m_places);
        m_places.addplace(p);
        p.name := pnode.ReadAttributeString('NodeName', ''); ;
        for j := 0 to pnode.NodeCount - 1 do
        begin
          bnode := pnode.Nodes[j];
          nodetype := bnode.ReadAttributeString('NodeType', '');
          if nodetype = 'BNode' then
          begin
            b := getBand(bnode.ReadAttributeString('NodeName', ''));
            if b <> nil then
            begin
              p.addband(b);
            end;
          end;
        end;
      end;
    end;
  end;
  child := node.FindNode('TagsBandPairNode');
  if child <> nil then
  begin
    for i := 0 to child.NodeCount - 1 do
    begin
      pnode := child.Nodes[i];
      nodetype := pnode.ReadAttributeString('NodeType', '');
      if nodetype = 'TagBandNode' then
      begin
        pair := m_TagBandPairList.newPair;
        pair.name := pnode.ReadAttributeString('NodeName', '');
        if pair.m_it = nil then
        begin
          id := pnode.ReadAttributeInt64('TagID', -1);
          pair.setId(id);
        end;
        for j := 0 to pnode.NodeCount - 1 do
        begin
          bnode := pnode.Nodes[j];
          nodetype := bnode.ReadAttributeString('NodeType', '');
          if nodetype = 'TagPlace' then
          begin
            p := getplace(bnode.ReadAttributeString('NodeName', ''));
            if p <> nil then
            begin
              pair.addplace(p);
            end;
          end;
        end;
      end;
    end;
  end;
  // загрузка корректировки ачх
  child := node.FindNode('AHGradList');
  if child <> nil then
  begin
    for i := 0 to child.NodeCount - 1 do
    begin
      n := child.Nodes[i];
      nodetype := pnode.ReadAttributeString('NodeType', '');
      if nodetype = 'AHNode' then
      begin
        str:=n.ReadAttributeString('NodeName', '');
        a:=newAH(str);
        a.m_units:=IntToAHUn(n.readAttributeInteger('AHUnits',0));
        a.size:=n.readAttributeInteger('AHCount', 0);
        str :=n.ReadAttributeString('AHpoints', '');
        substr:=GetSubString(str, ';', 0, j);
        k:=0;
        while substr<>'' do
        begin
          a.m_points[k].x:=strtofloatext(substr);
          substr:=GetSubString(str, ';', j, j);
          a.m_points[k].y:=strtofloatext(substr);
          substr:=GetSubString(str, ';', j, j);
          inc(k);
        end;
      end;
    end;
  end;
  // загрузка списка корректируемых тегов
  child := node.FindNode('AHNameList');
  if child <> nil then
  begin
    for i := 0 to child.NodeCount - 1 do
    begin
      n := child.Nodes[i];
      nodetype := pnode.ReadAttributeString('NodeType', '');
      if nodetype = 'AHNameNode' then
      begin
        str:=n.ReadAttributeString('NodeName', '');
        substr:=n.ReadAttributeString('AHgrad', '');
        a:=getAH(substr);
        if a<>nil then
        begin
          m_AHNames.AddObject(str,a);
        end;
      end;
    end;
  end;
end;

procedure cAlgMng.XMLlOADMngAttributesAfterObjects(node: txmlNode);
var
  child, n: txmlNode;
  i, j, tcount: integer;
  b: tBand;
  nodetype, str, str1: string;
  alg:cBaseAlgContainer;
  cfg:cAlgConfig;
begin
  child := node.FindNode('CfgList');
  if child<>nil then
  begin
    for i := 0 to child.NodeCount - 1 do
    begin
      n:=child.Nodes[i];
      nodetype := n.ReadAttributeString('NodeType', '');
      if nodetype='AlgCfgNode' then
      begin
        str:=n.ReadAttributeString('NodeName',  '');
        str1:=n.ReadAttributeString('AlgClass',  '');
        if str1<>'' then
        begin
          cfg:=g_algMng.newCfg(str,g_algMng.getAlgClass(str1));
          cfg.str := n.ReadAttributeString('Cfg', '');
          tcount:=n.ReadAttributeInteger('AlgCount', 0);
          for j := 0 to tcount - 1 do
          begin
            str:=n.ReadAttributeString('A_'+inttostr(j), '');
            alg:=cbasealgcontainer(g_algMng.getObj(str));
            if alg<>nil then
              cfg.AddChild(alg);
          end;
        end;
      end;
    end;
  end;
end;

procedure cAlgMng.XMLSaveMngAttributes(node: txmlNode);
var
  child, n, bnode, pnode, tnode: txmlNode;
  i, j, k: integer;
  b: tBand;
  p: TPlace;
  pair: TTagBandPair;
  t: BandTag;
  a: cAHgrad;
  alg:cbasealgcontainer;
  cfg:cAlgConfig;
  str:string;
begin
  inherited;
  child := getNode(node,'BandsNode');
  for i := 0 to m_bands.Count - 1 do
  begin
    b := tBand(m_bands.Objects[i]);
    bnode := getNode(child,'Band_' + inttostr(i));
    bnode.WriteAttributeString('NodeName', b.name, '');
    bnode.WriteAttributeString('NodeType', 'BNode', '');
    bnode.WriteAttributeFloat('F1', b.m_f1f2.x, 0);
    bnode.WriteAttributeFloat('F2', b.m_f1f2.y, 0);
    bnode.WriteAttributeInteger('BType', b.valtype, 0);
    bnode.WriteAttributeInteger('TagCount', b.tagCount, 0);
    for j := 0 to b.tagCount - 1 do
    begin
      tnode := getNode(bnode,b.name);
      tnode.WriteAttributeString('NodeType', 'TNode', '');
      t := b.getbandtag(j);
      tnode.WriteAttributeString('TagName', t.tagname, '');
      tnode.WriteAttributeFloat('Kmult', t.k, 0);
    end;
  end;

  child := getNode(node,'PlacesNode');
  for i := 0 to m_places.Count - 1 do
  begin
    p := m_places.getplace(i);
    pnode := getNode(child,'Place_' + inttostr(i));
    pnode.WriteAttributeString('NodeName', p.name, '');
    pnode.WriteAttributeString('NodeType', 'PlaceNode', '');
    for j := 0 to p.Bandcount - 1 do
    begin
      b := p.getBand(j);
      bnode := getNode(pnode,'Band_' + inttostr(j));
      bnode.WriteAttributeString('NodeType', 'BNode', '');
      bnode.WriteAttributeString('NodeName', b.name, '');
    end;
  end;

  child := getNode(node,'TagsBandPairNode');
  for i := 0 to m_TagBandPairList.Count - 1 do
  begin
    pair := m_TagBandPairList.getPair(i);
    pnode := getNode(child,'BandPair_' + inttostr(i));
    pnode.WriteAttributeString('NodeType', 'TagBandNode', '');
    pnode.WriteAttributeString('NodeName', pair.name, '');
    pnode.WriteAttributeInt64('TagID', pair.m_id, -1);
    for j := 0 to pair.placeCount - 1 do
    begin
      p := pair.getplace(j);
      bnode := getNode(pnode,'TagPlace_' + inttostr(j));
      bnode.WriteAttributeString('NodeType', 'TagPlace', '');
      bnode.WriteAttributeString('NodeName', p.name, '');
    end;
  end;
  // корректировка АЧХ
  child := getNode(node,'AHGradList');
  for i := 0 to m_AHList.Count - 1 do
  begin
    a := getAH(i);
    n := getNode(child,'AHNode_' + inttostr(i));
    n.WriteAttributeString('NodeType', 'AHNode', '');
    n.WriteAttributeString('NodeName', a.m_name, '');
    n.WriteAttributeInteger('AHUnits', TAHUnToInt(a.m_units), 0);
    n.WriteAttributeInteger('AHCount', a.size, 0);
    str := '';
    for j := 0 to a.size - 1 do
    begin
      str := str + floattostr(a.m_points[j].x) + ';' + floattostr(a.m_points[j].y);
      if j <> a.size - 1 then
        str := str + ';';
    end;
    n.WriteAttributeString('AHpoints', str, '');
  end;
  child := getNode(node,'AHNameList');
  for i := 0 to m_AHNames.Count - 1 do
  begin
    str := m_AHNames.Strings[i];
    n := getNode(child,'AHNode_' + inttostr(i));
    n.WriteAttributeString('NodeType', 'AHNameNode', '');
    n.WriteAttributeString('NodeName', str, '');
    n.WriteAttributeString('AHgrad', cAHGrad(m_AHNames.Objects[i]).m_name, '');
  end;

  child := getNode(node,'CfgList');
  for i := 0 to m_cfgList.Count - 1 do
  begin
    cfg:=getCfg(i);
    if cfg.m_NotSaveCfg then
      continue;
    str := cfg.name;
    n := getNode(child,'AlgCfgNode_' + inttostr(i));
    n.WriteAttributeString('NodeType', 'AlgCfgNode', '');
    n.WriteAttributeString('NodeName', str, '');
    n.WriteAttributeString('AlgClass', cfg.clType.ClassName, '');
    str := cfg.m_str;
    n.WriteAttributeString('Cfg', str, '');
    k:=0;
    for j := 0 to cfg.ChildCount - 1 do
    begin
      alg:=cfg.getAlg(j);
      if alg.notSaveToXml then
        continue;
      n.WriteAttributeString('A_'+inttostr(k), alg.name, '');
      inc(k);
    end;
    n.WriteAttributeInteger('AlgCount', cfg.ChildCount, 0);
  end;
end;

{ cSpmList }
constructor cSrcList.create;
begin
  inherited;
  fHelper := true;
  // нельзя ставить True кт.к. будет разрушен и не восстановлен при загрузке
  autocreate := true;
  blocked := true;
end;

destructor cSrcList.destroy;
begin
  inherited;
end;



{ cAHgrad }
function cAHgrad.CorrectValue(v, freq: double): double;
var
  point: double;
  i: integer;
begin
  for i := 1 to size - 1 do
  begin
    if i < size - 1 then
    begin
      if (m_points[i - 1].x < freq) and (m_points[i].x > freq) then
      begin
        point := EvalLineYd(freq, m_points[i - 1], m_points[i]);
        break;
      end;
    end
    else
    begin
      point := EvalLineYd(freq, m_points[i - 1], m_points[i]);
      break;
    end;
  end;
  case m_units of
    AHmult:
      result := point * v;
    AH10db:
      result := v * (Power(10, point / 10));
    AH20db:
      result := v * (Power(10, point / 20));
    AHpercent:
      result := v * (1 + point / 100);
  end;
end;

function cAHgrad.GetMultDsc(i: integer): string;
var
  point: double;
begin
  point := m_points[i].y;
  case m_units of
    AHmult:
      result := formatstrNoE(point, 3);
    AH10db:
      result := 'Значение*10^(' + formatstrNoE(point / 10, 3) + ')';
    // point*(Power(10,percent/20));
    AH20db:
      result := 'Значение*10^(' + formatstrNoE(point / 20, 3) + ')';
    // point*(Power(10,percent/20));
    AHpercent:
      result := formatstrNoE(1 + point / 100, 3);
  end;
end;

constructor cAHgrad.create(name: string);
begin
  m_name := name;
end;

destructor cAHgrad.destroy;
var
  i: integer;
begin
  for i := 0 to g_algMng.m_AHList.Count - 1 do
  begin
    if g_algMng.m_AHList.items[i] = self then
    begin
      g_algMng.m_AHList.Delete(i);
      break;
    end;
  end;
  g_algMng.DelAHNames(self);
end;

function cAHgrad.GetMultDsc(freq: double): string;
var
  point, k: double;
  i: integer;
begin
  for i := 1 to size - 1 do
  begin
    if i < size - 1 then
    begin
      if (m_points[i - 1].x < freq) and (m_points[i].x > freq) then
      begin
        point := EvalLineYd(freq, m_points[i - 1], m_points[i]);
        break;
      end;
    end
    else
    begin
      point := EvalLineYd(freq, m_points[i - 1], m_points[i]);
      break;
    end;
  end;
  case m_units of
    AHmult:
      result := formatstrNoE(point, 3);
    AH10db:
      result := 'Значение*10^(' + formatstrNoE(point / 10, 3) + ')';
    // point*(Power(10,percent/20));
    AH20db:
      result := 'Значение*10^(' + formatstrNoE(point / 20, 3) + ')';
    // point*(Power(10,percent/20));
    AHpercent:
      result := formatstrNoE(1 + point / 100, 3);
  end;
end;

function cAHgrad.getsize: integer;
begin
  result := length(m_points);
end;

function cAHgrad.getUnitString: string;
begin
  case m_units of
    AHmult:
      result := 'Множитель';
    AH10db:
      result := '10Lg(Aизм./Ареалн.)';
    AH20db:
      result := '20Lg(Aизм./Ареалн.)';
    AHpercent:
      result := '%';
  end;
end;

procedure cAHgrad.setsize(s: integer);
begin
  setlength(m_points, s);
end;

{ cAlgConfig }
constructor cAlgConfig.create(cl:TClass);
begin
  clType:=cl;
  m_childs:=TList.Create;
end;

destructor cAlgConfig.destroy;
var
  I: Integer;
  c:cAlgConfig;
  a:cbasealgcontainer;
begin
  if m_cfgList<>nil then
  begin
    for I := 0 to m_cfgList.Count - 1 do
    begin
      c:=cAlgConfig(m_cfgList.Items[i]);
      if c=self then
      begin
        m_cfgList.Delete(i);
        break;
      end;
    end;
  end;
  for I := m_childs.Count - 1 downto 0 do
  begin
    a:=getAlg(i);
    a.destroy;
  end;
  m_childs.destroy;
end;

procedure cAlgConfig.AddChild(a: cBaseAlgContainer);
var
  I: Integer;
  b:boolean;
begin
  if a.ClassType=clType then
  begin
    b:=false;
    for I := 0 to ChildCount - 1 do
    begin
      if getAlg(i)=a then
      begin
        b:=true;
        break;
      end;
    end;
    if not b then
    begin
      a.parentCfg:=self;
      a.Properties:=m_str;
      m_childs.Add(a);
    end;
  end;
end;

function cAlgConfig.ChildCount:integer;
begin
  result:=m_childs.Count;
end;

function cAlgConfig.getAlg(i:integer):cBaseAlgContainer;
begin
  result:=cBaseAlgContainer(m_childs.Items[i]);
end;

procedure cAlgConfig.delAlg(a:cBaseAlgContainer);
var
  I: Integer;
begin
  for I := 0 to ChildCount-1 do
  begin
    if a=getAlg(i) then
    begin
      m_childs.Delete(i);
      exit;
    end;
  end;
end;

function cAlgConfig.getprops(algNum:integer): string;
var
  extstr:string;
  a:cbasealgcontainer;
begin
  extstr:='';
  if algNum<(ChildCount-1) then
  begin
    a:=getAlg(algNum);
    extstr:=a.getExtProp;
  end;
  result:=updateParams(m_str,extstr);
end;

function cAlgConfig.getprops:string;
begin
  result:=getprops(0);
end;

function cAlgConfig.getwnd: TWndType;
var
  a:cbasealgcontainer;
  s:cspm;
begin
  a:=getAlg(0);
  result:=wdRect;
  if a is cspm then
  begin
    s:=cspm(a);
    Result:=s.GetWndType;
  end;
end;

procedure cAlgConfig.setprops(s: string);
var
  a:cbasealgcontainer;
  I: Integer;
begin
  ///m_str:=s;
  m_str:=updateParams(m_str, s);
  if ChildCount>0 then
  begin
    if ChildCount=1 then
      m_str:=updateParams(m_str, s)
    else
    begin
      a:=getAlg(0);
      m_str:=DelParams(m_str,a.getExtProp, ',');
    end;
    for I := 0 to ChildCount - 1 do
    begin
      a:=getAlg(i);
      a.Properties:=m_str;
    end;
  end;
end;

end.
