unit uTagMng;

interface
uses
  tags,
  variants,
  recorder,
  classes,
  uBaseobj,
  uBaseObjMng,
  uEventList,
  activex,
  uSetList;

type
  cTagSet = class (cSetList)
  protected
  public
    constructor create;override;
  end;

  cRTag = class(cBaseObj)
  private
    m_Tag:iTag;
  public
    procedure LinkTag(t:iTag);
    procedure UnLinkTag;
  end;

  cTagMng = class(cBaseObjMng)
  private
    m_ir:IRecorder;
    idset:cTagSet;
  private
    procedure createEvents;
    procedure DestroyEvents;
    procedure updateTagsList;
  public
    function GetTagID(id:tagid):cRTag;
    function GetTag(i:integer):cRTag;overload;
    function GetTag(name:string):cRTag;overload;
    function GetTag(it:pointer):cRTag;overload;

    constructor Create(ir:IRecorder);
    destructor destroy;override;
  end;

implementation

function IDSelectListComparator(p1,p2:pointer):integer;
var
  it1, it2:iTag;
  id1,id2:tagid;
begin
  it1:=itag(p1);
  it2:=itag(p2);
  it1.GetTagId(id1);
  it2.GetTagId(id2);

  if id1>id2 then
  begin
    result:=1;
  end
  else
  begin
    if id1<id2 then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;

constructor cTagSet.create;
begin
  inherited;
  comparator:=IDSelectListComparator;
  destroydata:=false;
end;


{ cTagMng }
constructor cTagMng.Create(ir:IRecorder);
begin
  inherited create;
  idset:=cTagSet.create;
  m_ir:=ir;
end;

destructor cTagMng.destroy;
begin
  m_ir:=nil;
  idset.destroy;
  inherited;
end;

procedure cTagMng.updateTagsList;
var
  i,l_count,intid:integer;
  it:iTag;
  t:cRTag;
  id:tagid;

begin
  l_Count := m_ir.GetTagsCount;
  for I := 0 to l_Count - 1 do
  begin
    it:=itag(m_ir.GetTagByIndex(i));
    it.GetTagId(id);
    intid:=integer(id);
    t:=GetTagID(id);
    if t=nil then
    begin
      t:=crtag.create;
      t.LinkTag(it);
      AddBaseObjInstance(t);
    end;
  end;
end;

procedure cTagMng.createEvents;
begin
  //Events.add
end;

procedure cTagMng.DestroyEvents;
begin

end;

function cTagMng.GetTagID(id:tagid):cRTag;
var
  tag:itag;
begin
  //m_ir.GetTagByTagId(id,tag);
  //result:=tag;
end;

function cTagMng.GetTag(i: integer): cRTag;
begin
  result:=cRTag(GetObj(i));
end;

function cTagMng.GetTag(name: string): cRTag;
var
  obj:cbaseobj;
begin
  obj:=getobj(name);
  if obj<>nil then
  begin
    result:=CRtag(obj);
  end
  else
    result:=nil;
end;

function cTagMng.GetTag(it: pointer): cRTag;
var
  I: Integer;
  t:crtag;
begin
  result:=nil;
  for I := 0 to Count - 1 do
  begin
    t:=gettag(i);
    if t.m_Tag=itag(it) then
    begin
      result:=t;
      exit;
    end;
  end;
end;

{ cRTag }
procedure cRTag.LinkTag(t: iTag);
begin
  m_Tag:=t;
end;

procedure cRTag.UnLinkTag;
begin
  m_Tag:=nil;
end;



end.
