unit uLoadSkin;

interface
  uses
    Windows,  SysUtils, Classes, uBinFile, uMeshObr, uMesh, uNodeObject, uSkin;

  // �������� ������������ SKIN
  procedure LoadSkinObj(const f:file; obj:cmeshobr);
  // ������������� ������������ (������������ �� ���, �� ��� �������� �����, �����
  // ���������, ��� �� ������ �������� ������������ skin �� ������� ��� �����,
  // ������� ���������� ���������������� ������ ������ �� ��������� �������� �����)
  procedure InitSkin(obj:cnodeobject; objects:tobject);
  // ���������� ������������
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
  // ���� ����� ��� �� ������ = Skin0
  if str='Skin1' then
  begin
    sdata:=skindata.create;
    skin:=cskin(obj.ModCreator.CreateModificator('cSkin'));
    skin.ImpExpdata:=sdata;
    // ������ ����� ������
    bonecount:=ReadInt(f);
    for I := 0 to bonecount - 1 do
    begin
      // ������ ��� �����
      str:=ReadString(f);
      bdata:=bonedata.Create;
      bdata.name:=str;
      sdata.addobject(str,bdata);
      // ������ ����� ������ �����
      vcount:=readint(f);
      setlength(bdata.data,vcount);
      for j := 0 to vcount - 1 do
      begin
        // ������ �������
        vind:=readint(f);
        // ��� �������
        weight:=readSingle(f);
        bdata.data[j].ind:=vind;
        bdata.data[j].weight:=weight;
      end;
    end;
  end;
end;

// ���������� ������������
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
  // ������ ����� ������
  bonecount:=sdata.Count;
  for I := 0 to bonecount - 1 do
  begin
    // ������ ��� �����
    bdata:=sdata.GetBoneData(i);
    str:=bdata.name;
    WriteString(f,str);
    // ������ ����� ������ �����
    vcount:=length(bdata.data);
    writeint(f,vcount);
    for j := 0 to vcount - 1 do
    begin
      // ������ �������
      vind:=bdata.data[j].ind;
      writeint(f,vind);
      // ��� �������
      weight:=bdata.data[j].weight;
      writeSingle(f,weight);
    end;
  end;
end;


end.
