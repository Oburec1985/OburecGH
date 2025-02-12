// ���� ��� �������� ��������. ������� LoadObaFile ���������� ��� �������� obr
// ����� ���� ����� ����� ���� ������� oba.
// ���������� keyframe ��������
unit uObaFile;

interface
uses
  Windows,  SysUtils, Classes, MathFunction, TextureGl, uMaterial,
  uselectools, uMatrix, uLight, uNodeObject, uObject, uObjectTypes,
  uEventList,
  ubaseobj,
  uNode,
  uGroupObjects,
  uMesh,
  uConfigFile3d,
  uLoadskin,
  uBinFile,
  uMoveController
  //,uTickMath
  ;

type
  stime = record
    tpf,fps,framecount:integer;
  end;


// ��������� �������� �� �����
// ui ���������� ����� ������������ � ��� timecontroller-� ��������� moveController
function LoadObaFile(path:string; ui:tobject; sceneobjects:tobject):boolean;

implementation
uses
  uSceneMng,
  uUI;

procedure readTM(const F:file;var m_fTM:array of single);
var numcol,Readed,i,j:integer;
    TM:array[0..15] of single;
begin
  BlockRead(F,TM,3*4*sizeof(single),Readed); // ������� ������� �������������
  numcol:=0;
  for i := 0 to 3 do
    for j := 0 to 2 do
    begin
     m_fTM[i*3+j+numcol]:=TM[i*3+j];
     if j=2 then
     begin
       numcol:=numcol+1;
       if i=3 then
          m_fTM[i*3+j+numcol]:=1
       else
          m_fTM[i*3+j+numcol]:=0;
     end;
  end;
end;  

function readHeader(var f:file; ui:cUI):stime;
begin
  result.fps:=ReadInt(f);
  result.framecount:=ReadInt(f);
  result.tpf:=ReadInt(f);
  ui.TimeCntrl.init(result.tpf,result.fps);
end;

function readNodeKeys(var f:file; ui:cUI;scobj:cbaseobjlist;time:stime):boolean;
var i,fr,frcount:integer;
    str:string;
    obj:cnodeobject;
    c:cMoveController;
    m:matrixgl;
begin
  str:=ReadString(F,char(0)); // ��� �������
  obj:=cnodeobject(scobj.getObj(str));
  if obj=nil then
  begin
    result:=false;
    exit;
  end;
  c:=nil;
  frcount:=ReadInt(f);
  if frcount<>0 then
  begin
    if ui is cUI then
      c:=cMoveController.create(obj,ui.TimeCntrl);
    obj.ModCreator.addMod(c);
    c.tps:=trunc(time.tpf/time.fps);
  end;
  for I := 0 to frcount - 1 do
  begin
    fr:=readint(f);
    readtm(f,m);
    c.keys.addkey(m,fr*time.tpf);
  end;
  str:=ReadString(F,char(0)); // ������ ���� "NextNode"
  result:=true;
  if c<>nil then
  begin
    if cUI(ui).TimeCntrl.maxtime<c.keys.maxtime then
      cUI(ui).TimeCntrl.maxtime:=c.keys.maxtime;
  end;
end;

function LoadObaFile(path:string; ui:tobject;sceneobjects:tobject):boolean;
var f:file;
    str:string;
    time:stime;
begin
  AssignFile(F,path);
  Reset(F,1);
  str:=ReadString(F,char(0));
  if str='Animation' then
  begin
    time:=readHeader(f,cUI(ui));
    while readNodeKeys(f,cUI(ui),cbaseobjlist(sceneobjects),time) do
    begin
      if Eof(f) then
        break;
    end;
  end;
  closefile(f);
end;

end.
