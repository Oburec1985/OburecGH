unit uBaseAlgBands;

interface

uses
  classes, Windows, tags, uBaseObj, uBaseObjMng, nativexml, uRCFunc,
  pluginclass, blaccess, sysutils, uCommonTypes, uFFT, ap, fft,
  urecorderevents,
  uCommonMath,
  uMyMath,
  mathfunction,
  math,
  complex,
  u2dmath;

type

  // для добавления алгоритма
  // 1) TAlgFrm.create() зарегить фрейм
  // 2) cAlgMng.regObjClasses зарегить алгоритм;
  // * связывание алгоритма и фрейма происходит по сравнению classname и algClass фрейма
  // компонент расчета частотной полосы k1*f1+kn*fn
  BandTag = class
  protected
    m_id: TAGID;
    m_t: string;
  protected
    procedure settagname(s: string);
  public
    m_it: itag;
    k: double;
  public
    Constructor create;
    destructor destroy;
    property tagname: string read m_t write settagname;
  end;

  tBand = class
  private
  public
    // список Bandtag
    m_TagsList: tstringlist;
    m_owner: tstringlist;
    m_f1f2: point2d;
    m_resultBand: point2d;
    // расчетное значение максимальной частоты
    m_MainFreq: double;
    // относительный абсолютный
    valtype: integer;
    name: string;
  public
    function tagCount: integer;
    procedure eval;
    procedure clearTags;
    procedure addBandTag(bt: BandTag);
    function getbandtag(i: integer): BandTag;overload;
    function getbandtag(tname: string): BandTag;overload;
    constructor create(owner: tstringlist);
    destructor destroy;
  end;

  // список мест установки датчиков
  // каждое место установки датчиков знает список полос частотных tBand
  TPlace = class
  public
    owner: tlist;
    name: string;
    bands: tlist;
  public
    function Bandcount: integer;
    procedure addband(b: tBand);
    procedure delband(b: tBand);
    function getBand(i: integer): tBand;
    constructor create(p_owner: tlist);
    destructor destroy;
  end;

  // список мест куда установлены датчики
  TPlaces = class(tlist)
  public
    procedure addplace(p: TPlace);
    function getplace(str: string): TPlace; overload;
    function getplace(i: integer): TPlace; overload;
    destructor destroy;
  end;

  // связь имени канала и списка полос
  TTagBandPair = class
  protected
    m_places: tlist;
    m_owner: tlist;
    m_t: string;
  public
    m_id: TAGID;
    m_it: itag;
    m_p: TPlace;
  protected
    function getname: string;
    procedure setname(s: string);
  public
    procedure setId(id: TAGID);
    procedure settag(t: itag);
    procedure addplace(p: TPlace);
    function removeplace(p: TPlace): boolean;
    function getplace(i: integer): TPlace;
    function placeCount: integer;
    property id: TAGID read m_id write setId;
    property name: string read getname write setname;
    constructor create;
    destructor destroy;
  end;

  TTagBandPairList = class(tlist)
  public
    function newPair: TTagBandPair;
    function getPair(i: integer): TTagBandPair; overload;
    function getPair(tagname: string): TTagBandPair; overload;
    destructor destroy;
  end;

const
  c_rate = 1;

implementation

{ tBand }
procedure tBand.addBandTag(bt: BandTag);
begin
  m_TagsList.AddObject(bt.m_t, bt);
end;

procedure tBand.clearTags;
var
  i: integer;
  bt: BandTag;
begin
  for i := 0 to m_TagsList.Count - 1 do
  begin
    bt := getbandtag(i);
    bt.destroy;
  end;
  m_TagsList.Clear;
end;

constructor tBand.create(owner: tstringlist);
begin
  m_TagsList := tstringlist.create;
  m_owner := owner;
end;

destructor tBand.destroy;
var
  i: integer;
  t: BandTag;
begin
  clearTags;
  for i := 0 to m_owner.Count - 1 do
  begin
    if m_owner.Objects[i] = self then
    begin
      m_owner.Delete(i);
      break;
    end;
  end;
  m_TagsList.destroy;
end;

procedure tBand.eval;
var
  i: integer;
  t: BandTag;
  v: double;
begin
  m_MainFreq := 0;
  for i := 0 to m_TagsList.Count - 1 do
  begin
    t := getbandtag(i);
    if t.m_it <> nil then
    begin
      v := GetScalar(t.m_it);
    end
    else
    begin
      break;
    end;
    if i = 0 then
    begin
      m_MainFreq := t.k * v;
    end
    else
    begin
      m_MainFreq := m_MainFreq + t.k * v;
    end;
  end;
  if valtype = c_rate then
  begin
    m_resultBand.x := m_MainFreq * m_f1f2.x;
    m_resultBand.y := m_MainFreq * m_f1f2.y;
  end
  else
  begin
    m_MainFreq := m_f1f2.x + (m_f1f2.y - m_f1f2.x) / 2;
    m_resultBand.x := m_f1f2.x;
    m_resultBand.y := m_f1f2.y;
  end;
end;

function tBand.getbandtag(tname: string): BandTag;
var
  I: Integer;
begin
  result:=nil;
  for I := 0 to m_TagsList.Count - 1 do
  begin
    if BandTag(m_TagsList.Objects[i]).m_t=tname then
    begin
      result := BandTag(m_TagsList.Objects[i]);
      exit;
    end;
  end;
end;

function tBand.getbandtag(i: integer): BandTag;
begin
  result := BandTag(m_TagsList.Objects[i]);
end;

function tBand.tagCount: integer;
begin
  result := m_TagsList.Count;
end;

{ TPlace }

procedure TPlace.addband(b: tBand);
var
  i: integer;
begin
  for i := 0 to bands.Count - 1 do
  begin
    if bands.items[i] = b then
    begin
      exit;
    end;
  end;
  bands.add(b);
end;

function TPlace.Bandcount: integer;
begin
  result := bands.Count;
end;

constructor TPlace.create(p_owner: tlist);
begin
  owner := p_owner;
  bands := tlist.create;
end;

procedure TPlace.delband(b: tBand);
var
  i: integer;
begin
  for i := 0 to bands.Count - 1 do
  begin
    if b = bands.items[i] then
    begin
      bands.Delete(i);
      exit;
    end;
  end;
end;

destructor TPlace.destroy;
var
  i: integer;
begin
  for i := 0 to owner.Count - 1 do
  begin
    if owner.items[i] = self then
    begin
      owner.Delete(i);
      break;
    end;
  end;
  bands.destroy;
end;

function TPlace.getBand(i: integer): tBand;
begin
  result := tBand(bands.items[i]);
end;

{ TPlaces }
procedure TPlaces.addplace(p: TPlace);
begin
  add(p);
end;

destructor TPlaces.destroy;
var
  i: integer;
  p: TPlace;
begin
  while Count > 0 do
  begin
    p := getplace(0);
    p.destroy;
  end;
  inherited;
end;

function TPlaces.getplace(str: string): TPlace;
var
  i: integer;
begin
  result := nil;
  for i := 0 to Count - 1 do
  begin
    if getplace(i).name = str then
    begin
      result := getplace(i);
      exit;
    end;
  end;
end;

function TPlaces.getplace(i: integer): TPlace;
begin
  result := TPlace(items[i]);
end;

{ TTagBandPair }
procedure TTagBandPair.addplace(p: TPlace);
var
  i: integer;
  b: boolean;
begin
  b := false;
  for i := 0 to m_places.Count - 1 do
  begin
    if (getplace(i) = p) then
    begin
      b := true;
      break;
    end;
  end;
  if not b then
    m_places.add(p);
end;

constructor TTagBandPair.create;
begin
  m_places := tlist.create;
end;

destructor TTagBandPair.destroy;
var
  i: integer;
begin
  for i := 0 to m_owner.Count - 1 do
  begin
    if m_owner.items[i] = self then
    begin
      m_owner.Delete(i);
      break;
    end;
  end;
  m_places.destroy;
  inherited;
end;

function TTagBandPair.getname: string;
begin
  if m_it <> nil then
    result := m_it.getname
  else
    result := m_t;
end;

function TTagBandPair.getplace(i: integer): TPlace;
begin
  result := TPlace(m_places.items[i]);
end;

function TTagBandPair.placeCount: integer;
begin
  result := m_places.Count;
end;

function TTagBandPair.removeplace(p: TPlace): boolean;
var
  i: integer;
begin
  result := false;
  for i := 0 to m_places.Count - 1 do
  begin
    if m_places.items[i] = p then
    begin
      m_places.Delete(i);
      result := true;
      exit;
    end;
  end;
end;

procedure TTagBandPair.setId(id: TAGID);
begin
  if m_id <> id then
  begin
    m_it := getTagById(id);
    m_id := id;
  end;
end;

procedure TTagBandPair.setname(s: string);
var
  b: boolean;
  astr: ansistring;
begin
  b := false;
  m_it := getTagByName(s);
  m_t := s;
  if m_it <> nil then
  begin
    m_it.GetTagId(m_id);
  end;
end;

procedure TTagBandPair.settag(t: itag);
begin
  m_it := t;
  m_t := t.getname;
  if t <> nil then
  begin
    m_it.GetTagId(m_id);
  end;
end;

{ TTagBandPairList }
destructor TTagBandPairList.destroy;
var
  i: integer;
  p: TTagBandPair;
begin
  while Count > 0 do
  begin
    p := getPair(0);
    p.destroy;
  end;
  inherited;
end;

function TTagBandPairList.getPair(i: integer): TTagBandPair;
begin
  result := TTagBandPair(items[i]);
end;

function TTagBandPairList.getPair(tagname: string): TTagBandPair;
var
  i: integer;
  t: TTagBandPair;
begin
  result := nil;
  for i := 0 to Count - 1 do
  begin
    t := getPair(i);
    if t.m_t = tagname then
    begin
      result := t;
      exit;
    end;
  end;
end;

function TTagBandPairList.newPair: TTagBandPair;
begin
  result := TTagBandPair.create;
  result.m_owner := self;
  add(result);
end;

{ BandTag }
constructor BandTag.create;
begin
  m_t := '';
  m_id := 0;
end;

destructor BandTag.destroy;
begin
  m_t := '';
end;

procedure BandTag.settagname(s: string);
begin
  m_t := s;
  m_it := getTagByName(s);
  if m_it <> nil then
  begin
    m_it.GetTagId(m_id);
  end;
end;

end.
