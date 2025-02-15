unit uTagOwnerObj;

interface
uses
  utag, ubaseobj, uBldObj;

  type
    cTagOwnerObj = class(cbldobj)
    public
      tags:cBaseObjList;
    protected
      constructor create;override;
      destructor destroy;override;
      procedure createTags;virtual;
      function gettag(i:integer):cbasetag;overload;
      function gettag(p_name:string):cbasetag;overload;
    end;

implementation

constructor cTagOwnerObj.create;
begin
  inherited;
  tags:=cBaseObjList.create;
  tags.destroydata:=true;
end;

destructor cTagOwnerObj.destroy;
var
  i:integer;
  tag:cbasetag;
begin
  for I := 0 to tags.Count - 1 do
  begin
    tag:=cBaseTag(tags.getobj(i));
    if Tag<>nil then
      tag.destroy;
  end;
  tags.clear;
  tags.Destroy;
  inherited;
end;

procedure cTagOwnerObj.createTags;
begin

end;

function cTagOwnerObj.gettag(i:integer):cbasetag;
begin
  result:=cbasetag(tags.getobj(i));
end;

function cTagOwnerObj.gettag(p_name:string):cbasetag;
begin
  result:=cbasetag(tags.getobj(p_name));
end;

end.
