unit uRvclService;

interface
uses
  recorder, tags, classes, controls, StdCtrls, uRCFunc
  ;

procedure tagsToCB(r:irecorder;cb:tcombobox);overload;
procedure tagsToCB(r:irecorder;cb:tcombobox; vector:boolean);overload;


implementation

procedure tagsToCB(r:irecorder;cb:tcombobox; vector:boolean);
var
  t:itag;
  str:string;
  tcount, i:integer;
begin
  tcount:=r.GetTagsCount;
  cb.Clear;
  for I := 0 to tcount - 1 do
  begin
    t:=GetTagByIndex(i);
    if vector then
    begin
      if isVector(t) then
      begin
        str:=t.GetName;
        cb.Items.AddObject(str,tobject(pointer(t)));
      end;
    end
    else
    begin
      str:=t.GetName;
      cb.Items.AddObject(str,tobject(pointer(t)));
    end;
  end;
end;

procedure tagsToCB(r:irecorder;cb:tcombobox);
var
  t:itag;
  str:string;
  tcount, i:integer;
begin
  tagsToCB(r,cb,false);
end;

end.
