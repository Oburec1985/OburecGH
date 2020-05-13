unit uLoadSkin;

interface
  uses
    Windows,  SysUtils, Classes, uBinFile, uMeshObr, uMesh, uNodeObject, uSkin;

  // «агрузка модификатора SKIN
  procedure LoadSkinObj(const f:file; obj:cmeshobr);
  // инициализаци€ модификатора (производитс€ из вне, тк при загрузке сцены, может
  // оказатьс€, что на момент создани€ модификатора skin не созданы все кости,
  // поэтому приходитс€ инициализировать массив костей по окончании загрузки сцены)
  procedure InitSkin(obj:cnodeobject; objects:tobject);
  // —охранение модификатора
  procedure SaveSkin(const f:file; obj:cmeshobr);

implementation

uses
  uSceneMng,
  uModList;

procedure InitSkin(obj:cnodeobject; objects:tobject);
var
  I: Integer;
  skin:cskin;
begin
  if obj is cmeshobr then
  begin
    for I := 0 to cmeshobr(obj).ModCreator.count - 1 do
    begin
      if cmeshobr(obj).ModCreator.getitem(i) is cskin then
      begin
        skin:=cskin(cmeshobr(obj).ModCreator.getitem(i));
        skin.linc(objects);
      end;
    end;
  end;
end;

procedure LoadSkinObj(const f:file; obj:cmeshobr);
var
  str:string;
  skin:cskin;
  I,j,vcount,vind,bonecount:integer;
  weight:single;
  // -----------------
  sdata:skindata;
  bdata:bonedata;
begin
  str:=ReadString(f, char(0));
  //str:=ReadString(f);
  // если скина нет то строка = Skin0
  if str='Skin1' then
  begin
    sdata:=skindata.create;
    skin:=cskin(obj.ModCreator.CreateModificator('cSkin'));
    skin.ImpExpdata:=sdata;
    // читаем число костей
    bonecount:=ReadInt(f);
    for I := 0 to bonecount - 1 do
    begin
      // читаем им€ кости
      str:=ReadString(f);
      bdata:=bonedata.Create;
      bdata.name:=str;
      sdata.addobject(str,bdata);
      // читаем число вершин кости
      vcount:=readint(f);
      setlength(bdata.data,vcount);
      for j := 0 to vcount - 1 do
      begin
        // индекс вершины
        vind:=readint(f);
        // вес вершины
        weight:=readSingle(f);
        bdata.data[j].ind:=vind;
        bdata.data[j].weight:=weight;
      end;
    end;
  end;
end;

// —охранение модификатора
procedure SaveSkin(const f:file; obj:cmeshobr);
var
  str:string;
  skin:cskin;
  I,j,vcount,vind,bonecount:integer;
  weight:single;
  // -----------------
  sdata:skindata;
  bdata:bonedata;
begin
  skin:= cskin(obj.ModCreator.GetModificator('cSkin'));
  if skin<>nil then
    str:='Skin1'
  else
  begin
    str:='Skin0';
    WriteCString(f,str);
    exit;
  end;
  WriteCString(f,str);
  sdata:=skin.ImpExpdata;
  // читаем число костей
  bonecount:=sdata.Count;
  for I := 0 to bonecount - 1 do
  begin
    // читаем им€ кости
    bdata:=sdata.GetBoneData(i);
    str:=bdata.name;
    WriteString(f,str);
    // читаем число вершин кости
    vcount:=length(bdata.data);
    writeint(f,vcount);
    for j := 0 to vcount - 1 do
    begin
      // индекс вершины
      vind:=bdata.data[j].ind;
      writeint(f,vind);
      // вес вершины
      weight:=bdata.data[j].weight;
      writeSingle(f,weight);
    end;
  end;
end;


end.
