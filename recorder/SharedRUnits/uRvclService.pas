unit uRvclService;

interface
uses
  recorder, tags, classes, controls, StdCtrls, uRCFunc
  ;

procedure tagsToCB(r:irecorder;cb:tcombobox);


implementation

procedure tagsToCB(r:irecorder;cb:tcombobox);
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
    str:=t.GetName;
    cb.Items.AddObject(str,tobject(pointer(t)));
  end;
end;

end.
