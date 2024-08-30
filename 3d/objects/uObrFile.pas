unit uObrFile;

interface

uses
  Windows, SysUtils, Classes, MathFunction, TextureGl, uMeshObr, uMaterial,
  uselectools, uMatrix, uLight, ubasecamera, uSelectLoadedObjects,
  uTestObjects, uNodeObject, uObject, uObjectTypes, uEventList, uNode,
  uGroupObjects,
  uMesh, opengl,
  uConfigFile3d,
  uLoadskin,
  uObaFile,
  uVBOMesh,
  uGlEventTypes,
  uBaseObj,
  uCommonTypes, uShape, uBinFile;

// Записывает объект в файл
procedure writeObject(FileHeaderObjectInfo: cFileHeadObjInfoList;
  const obj: cNodeObject; const F: file);
// Возвращает true если файл формата Obr и список объектов сцены.
// Курсор должен стоять вначале файла
function readHeader(var FileHeaderObjectInfo: cFileHeadObjInfoList;
  const F: file): boolean;
// Читает всю информацию об объекте. Курсор должен стоять на метке начала объекта ABCD
function readObj(const F: file; p_scene: tobject; list: cBaseObjList; var matmng: cmaterialmanager; pathcfgfile: cCfgFile): cNodeObject;
procedure writeHeader(var FileHeaderObjectInfo: cFileHeadObjInfoList; const F: file; MainNode: cNodeObject);
// Загрузить сцену из файла
function LoadObrFile(path: string; pathcfgfile: cCfgFile; scene: tobject): boolean;

//
const
  ID_MATERIAL_SECTION = $ABC1;
  ID_NODE_HEADER = $ABCD;
  ID_MTL_HEADER = $1FF1;
  ID_VERTEX_HEADER = $2FF2;
  ID_TVERTEX_HEADER = $2EE2;
  ID_GROUP_HEADER = $3FF3;
  UseARBVertexBuffer = false;

implementation

uses
  uSceneMng,
  uRender,
  uUI;

procedure writestring(const F: file; const str: string);
var
  ch: char;
begin
  ch := char(0);
  Blockwrite(F, str[1], length(str));
  Blockwrite(F, ch, 1);
end;

procedure readString(const F: file; var str: string);
var
  ch: ansichar;
  Readed: integer;
begin
  str := '';
  BlockRead(F, ch, 1, Readed);
  if ch <> char(0) then
  begin
    str := str + ch;
    while ch <> char(0) do
    begin
      BlockRead(F, ch, 1, Readed);
      if ch <> char(0) then
        str := str + ch;
    end;
  end
end;

// обновить позицию объекта в заголовке. В качестве позиции пишется текущая
// позиция курсора в файле
procedure UpdateObjInfo(var FileHeaderObjectInfo: cFileHeadObjInfoList;
  obj: cNodeObject; const F: file);
var
  index, pos: integer;
  objinfo: cFileHeadObjInfo;
begin
  objinfo := FileHeaderObjectInfo.GetByName(obj.name);
  objinfo.DataPosInFile := filepos(F);
  seek(F, objinfo.DataPosInHeader);
  Blockwrite(F, objinfo.DataPosInFile, 4);
  seek(F, objinfo.DataPosInFile);
end;

procedure WriteTM(const F: file; var m_fTM: matrixgl);
begin
  // TransposeMatrix4(m_fTM);
  // считать матрицу трансформации 3*4*sizeof(single) байт
  Blockwrite(F, m_fTM[0], 3 * sizeof(single));
  Blockwrite(F, m_fTM[4], 3 * sizeof(single));
  Blockwrite(F, m_fTM[8], 3 * sizeof(single));
  Blockwrite(F, m_fTM[12], 3 * sizeof(single));
end;

procedure readTM(const F: file; var m_fTM: array of single);
var
  numcol, Readed, i, j: integer;
  TM: array [0 .. 15] of single;
begin
  BlockRead(F, TM, 3 * 4 * sizeof(single), Readed);
  // считать матрицу трансформации
  numcol := 0;
  for i := 0 to 3 do
    for j := 0 to 2 do
    begin
      m_fTM[i * 3 + j + numcol] := TM[i * 3 + j];
      if j = 2 then
      begin
        numcol := numcol + 1;
        if i = 3 then
          m_fTM[i * 3 + j + numcol] := 1
        else
          m_fTM[i * 3 + j + numcol] := 0;
      end;
    end;
end;

procedure WriteHeadObj(const obj: cNodeObject; const F: file);
var
  m, rot, trans: matrixgl;
  ltype: byte;
  header: word;
begin
  writestring(F, obj.name);
  // Записать матрицу перевода в WorldSpace и матрицу узла
  m := obj.noderestm;
  WriteTM(F, m);
  m := obj.LocalTM;
  rot := NoTranslateMatrix4(m);
  trans := EvalRightMatrix(rot, m);
  m := multmatrix4(trans, rot);
  WriteTM(F, m);
  // Запись информацию о родительском объекте
  header := ID_GROUP_HEADER;
  // BlockWrite(F,header,2); //Заголовок группы 3FF3
  ltype := 1;
  if obj.parent <> nil then
  begin
    Blockwrite(F, header, 2); // Заголовок группы 3FF3
    ltype := 0;
    Blockwrite(F, ltype, 1);
    if ltype = 0 then // Если объект дочерний
    begin
      writestring(F, obj.parent.name);
    end
  end
  else
  begin
    ltype := 0;
    Blockwrite(F, ltype, 1);
    Blockwrite(F, ltype, 1);
  end;
end;

procedure readHeadObj(var obj: cNodeObject; Objects: cBaseObjList;
  const F: file);
var
  casestring: string;
  chunk: word;
  Readed: integer;
  ltype: byte;
  parentobj: cNodeObject;
  m, rot, trans: matrixgl;
begin
  readString(F, casestring);
  obj.name := casestring;
  // Считать матрицу перевода в WorldSpace и матрицу узла
  readTM(F, m);
  obj.nodetm := m;
  // ----------------- Локальная система координат ------------------------
  readTM(F, m);
  rot := NoTranslateMatrix4(m);
  trans := NoRotateMatrix4(m);
  // obj.localtm:=multmatrix4(rot,trans);
  obj.LocalTM := m;
  BlockRead(F, chunk, 2, Readed); // Заголовок группы 3FF3
  casestring := IntToHex(chunk, 4);
  if casestring = '3FF3' then
  begin
    // Заголовок группы 3FF3
    BlockRead(F, ltype, 1, Readed);
    if ltype = 0 then // Если объект дочерний
    begin
      readString(F, casestring);
      parentobj := cNodeObject(Objects.getobj(casestring));
      groupto(obj, parentobj);
    end
  end;
  obj.SetObjToWorld;
end;

function readTexture(const F: file; var Texture: TTextureGL;
  texmng: ctexturemanager; pathcfgfile: cCfgFile): boolean;
var
  casestring: string;
  ch: char;
  Readed: integer;
  deep: integer;
begin
  Texture := nil;
  casestring := '';
  BlockRead(F, ch, 1, Readed);
  result := false;
  if ch <> char(0) then
  begin // Если текстура существует.
    Texture := TTextureGL.Create(texmng);
    while ch <> char(0) do
    begin
      BlockRead(F, ch, 1, Readed);
      if ch <> char(0) then
        casestring := casestring + ch;
    end;
    Texture.name := casestring;
    deep := 3;
    Texture.name := pathcfgfile.findTextureFile(Texture.name);
    Texture.LoadFromFile(Texture.name);
    result := true;
  end;
end;

function readMaterial(const F: file; pathcfgfile: cCfgFile;
  matmng: cmaterialmanager): cmaterial;
var
  chunk: word;
  Readed: integer;
  casestring: string;
  shin: single;
  str: string;
  mat: cmaterial;
  t: TTextureGL;
begin
  result := nil;
  // -------------- Чтение информации о материале -------------------------
  BlockRead(F, chunk, 2, Readed); // 1ff1 либо 0000
  casestring := IntToHex(chunk, 4);
  if casestring <> '1FF1' then
  begin
  end
  else
  begin // если материал есть
    mat := cmaterial.Create(matmng);
    readString(F, str);
    mat.name := str;
    BlockRead(F, mat.Ambient, 12, Readed);
    BlockRead(F, mat.Diffuse, 12, Readed);
    BlockRead(F, mat.Specular, 12, Readed);
    BlockRead(F, shin, 4, Readed);
    mat.Shininess := round(128 * shin);
    mat.MtlExist := true;
    if readTexture(F, t, matmng.m_texturemanager, pathcfgfile) then
    begin
      mat.difTexture := matmng.m_texturemanager.Add(t);
      if mat.difTexture <> t then
        t.Destroy;
    end;
    if readTexture(F, t, matmng.m_texturemanager, pathcfgfile) then
    begin
      mat.BumpTexture := matmng.m_texturemanager.Add(t);
      if mat.BumpTexture <> t then
        t.Destroy;
    end;
    result := mat;
  end;
end;

function readHeader(var FileHeaderObjectInfo: cFileHeadObjInfoList;
  const F: file): boolean;
var
  str: string;
  pos, Readed: integer;
  objinfo: cFileHeadObjInfo;
begin
  FileHeaderObjectInfo.cleardata;
  readString(F, str);
  if str <> 'ObrFile' then
  begin
    result := false;
    exit;
  end
  else
  begin
    while str <> 'ObrFile_Body' do
    begin
      result := true;
      readString(F, str);
      if str = 'ObrFile_Body' then
        exit;
      BlockRead(F, pos, 4, Readed);
      objinfo := cFileHeadObjInfo.Create;
      objinfo.DataPosInFile := pos;
      objinfo.objname := str;
      FileHeaderObjectInfo.AddObject(str, objinfo);
    end;
  end;
end;

procedure writeObjInfo(FileHeaderObjectInfo: cFileHeadObjInfoList;
  obj: cNodeObject; const F: file);
var
  zero, i, index: integer;
  world: cNodeObject;
  child: cNodeObject;
  objinfo: cFileHeadObjInfo;
  count: integer;
begin
  if not obj.fHelper then
  begin
    // Если объект был добавлен в сцену, а не загружен, то создаем его,
    // иначе получаем из списка загруженных объектов
    objinfo := FileHeaderObjectInfo.GetByName(obj.name);
    if objinfo = nil then
    begin
      objinfo := cFileHeadObjInfo.Create;
      objinfo.objname := obj.name;
      FileHeaderObjectInfo.AddObject(obj.name, objinfo);
    end;
    writestring(F, objinfo.objname);
    zero := 0;
    // Пишем в позицию объекта ересь, чтобы позже перезаписать данные
    objinfo.DataPosInHeader := filepos(F);
    Blockwrite(F, zero, 4);
  end;
  count := obj.ChildCount;
  for i := 0 to count - 1 do
  begin
    child := cNodeObject(obj.getChild(i));
    writeObjInfo(FileHeaderObjectInfo, child, F);
  end;
end;

procedure writeHeader(var FileHeaderObjectInfo: cFileHeadObjInfoList;
  const F: file; MainNode: cNodeObject);
var
  str: string;
  i, pos, Readed: integer;
  objinfo: cFileHeadObjInfo;
begin
  str := 'ObrFile';
  writestring(F, str);
  // Запись заголовочной информации
  FileHeaderObjectInfo.ClearAndDeleteObjects;
  writeObjInfo(FileHeaderObjectInfo, MainNode, F);
  str := 'ObrFile_Body';
  writestring(F, str);
end;

function readObj(const F: file; p_scene: tobject; list: cBaseObjList;
  var matmng: cmaterialmanager; pathcfgfile: cCfgFile): cNodeObject;
var
  i, Readed, count: integer;
  casestring: string;
  chunk: word;
  bbuf, objtype: byte;
  obj: cNodeObject;
  mesh_obr, inst: cMeshObr;
  shape: cShapeObj;
  material: cmaterial;
  VPointer: cVPointer;
  m: matrixgl;
  dir: point3;
  function readVPoint(const p_f: file): cVPointer;
  var
    VPointer: cVPointer;
    j, c: integer;
  begin
    VPointer := cVPointer.Create;
    BlockRead(F, VPointer.ind, 4, Readed); // Число уникальных вершин
    BlockRead(F, c, 4, Readed); // Число уникальных вершин
    setlength(VPointer.Pointers, c);
    for j := 0 to c - 1 do
    begin
      BlockRead(F, VPointer.Pointers[j], 4, Readed); // Число уникальных вершин
    end;
    result := VPointer;
  end;

begin
  result := nil;
  BlockRead(F, chunk, 2, Readed);
  casestring := IntToHex(chunk, 4);
  if casestring <> 'ABCD' then
    exit; // Если тип файла не Obr, выход из процедуры
  BlockRead(F, objtype, 1, Readed); // тип объекта
  objtype:=constShape;
  case objtype of
    constCamera:
      begin
        obj := cBaseCamera.Create;
        obj.objtype := objtype;
        readHeadObj(obj, list, F);
        obj.RotateNodeLocal(0, 180, 0);
        result := obj;
      end;
    constLight:
      begin
        obj := clight.Create(gl_light0, p_scene);
        obj.objtype := objtype;
        readHeadObj(obj, list, F);
        result := obj;
      end;
    constdummy: // пустышка
      begin
        obj := cobject.Create;
        obj.fHelper := false;
        obj.objtype := objtype;
        readHeadObj(obj, list, F);
        result := obj;
      end;
      constShape:
      begin
        shape := cShapeObj.Create;
        readHeadObj(cNodeObject(shape), list, F);
        shape.LineCount := ReadInt(F);
        setlength(shape.Lines, shape.LineCount);
        for i := 0 to shape.LineCount - 1 do
        begin
          shape.Lines[i].closed := ReadByte(F);
          count := ReadInt(F);
          setlength(shape.Lines[i].data, count);
          BlockRead(F, shape.Lines[i].data[0], sizeof(point3) * count, Readed);
          // Число вершин
        end;
        shape.UpdateBounds;
        shape.needRecompile := true;
        result := shape;
      end;
    constmesh: // меш
      begin
        mesh_obr := cMeshObr.Create;
        readHeadObj(cNodeObject(mesh_obr), list, F);
        BlockRead(F, chunk, 2, Readed); // Заголовок вершинного экспорта 2FF2
        casestring := IntToHex(chunk, 4);
        if casestring <> '2FF2' then
          exit;
        BlockRead(F, bbuf, 1, Readed); // Заголовок вершинного экспорта 2FF2
        if bbuf = 1 then
        begin
          if UseARBVertexBuffer then
            mesh_obr.Mesh := cARBMesh.Create
          else
            mesh_obr.Mesh := cMesh.Create;
          BlockRead(F, mesh_obr.Mesh.FaceCount, 4, Readed); // Число вершин
          BlockRead(F, mesh_obr.Mesh.VertexCount, 4, Readed); // Число вершин
          setlength(mesh_obr.Mesh.FaceArray, mesh_obr.Mesh.FaceCount);
          setlength(mesh_obr.Mesh.DrawArray, mesh_obr.Mesh.VertexCount);
          setlength(mesh_obr.Mesh.DrawNormals, mesh_obr.Mesh.VertexCount);
          setlength(mesh_obr.Mesh.TexVertexArray, mesh_obr.Mesh.VertexCount);
          BlockRead(F, mesh_obr.Mesh.FaceArray[0],
            4 * 3 * mesh_obr.Mesh.FaceCount, Readed); // указатель вершин
          BlockRead(F, mesh_obr.Mesh.DrawArray[0],
            4 * 3 * mesh_obr.Mesh.VertexCount, Readed); // вершинный массив
          BlockRead(F, mesh_obr.Mesh.DrawNormals[0],
            4 * 3 * mesh_obr.Mesh.VertexCount, Readed); // массив нормалей
          BlockRead(F, mesh_obr.Mesh.TexVertexArray[0],
            4 * 2 * mesh_obr.Mesh.VertexCount, Readed); // массив нормалей
          BlockRead(F, count, 4, Readed); // Число уникальных вершин
          for i := 0 to count - 1 do
          begin
            mesh_obr.Mesh.VPointers.AddObject(@i, readVPoint(F));
          end;
        end
        else
        begin
          readString(F, casestring);
          mesh_obr.instname := casestring;
          mesh_obr.inst := true;
          inst := cMeshObr(list.getobj(casestring));
          mesh_obr.Mesh := inst.Mesh;
        end;
        LoadSkinObj(F, mesh_obr);
        // ---------------- Запись цвета ---------------------------------------
        BlockRead(F, bbuf, 1, Readed); // красный
        mesh_obr.Mesh.defoultcolor.x := bbuf / 255;
        BlockRead(F, bbuf, 1, Readed); // зеленый
        mesh_obr.Mesh.defoultcolor.y := bbuf / 255;
        BlockRead(F, bbuf, 1, Readed); // голубой
        mesh_obr.Mesh.defoultcolor.z := bbuf / 255;
        // -------------- Чтение информации о материале -------------------------
        material := readMaterial(F, pathcfgfile, matmng);
        if material = nil then
          material := matmng.defMat;
        mesh_obr.m_MatMng := matmng;
        if not mesh_obr.AddMaterial(material) then
        begin
          if material <> matmng.defMat then
            material.Destroy;
        end;
        mesh_obr.UpdateBounds;
        // цвета вершин
        setlength(mesh_obr.Mesh.colorArray, mesh_obr.Mesh.VertexCount);
        for i := 0 to mesh_obr.Mesh.VertexCount - 1 do
        begin
          initp3array(blue, mesh_obr.Mesh.colorArray);
        end;
        mesh_obr.Mesh.prepareVertexBuffer;
        result := cNodeObject(mesh_obr);
      End; // Конец файла
  end; // case
end;

procedure writeObject(FileHeaderObjectInfo: cFileHeadObjInfoList;
  const obj: cNodeObject; const F: file);
var
  i: integer;
  material: cmaterial;
  shin: single;
  header: word;
  buf: byte;
  procedure WriteVPoint(const p_f: file; p: cVPointer);
  var
    j, len: integer;
  begin
    Blockwrite(F, p.ind, 4); // Число уникальных вершин
    len := length(p.Pointers);
    Blockwrite(F, len, 4); // Число уникальных вершин
    for j := 0 to len - 1 do
    begin
      Blockwrite(F, p.Pointers[j], 4); // Число уникальных вершин
    end;
  end;
  procedure WriteTexture(const F: file; const Texture: TTextureGL);
  var
    ch: char;
  begin
    if Texture <> nil then
      ch := char(1)
    else
      ch := char(0);
    Blockwrite(F, ch, 1);
    // Если текстура существует.
    if ch <> char(0) then
    begin
      writestring(F, extractfilename(Texture.name));
    end;
  end;

begin
  UpdateObjInfo(FileHeaderObjectInfo, obj, F);
  if obj.parent.fHelper then
    obj.parent := nil;
  header := ID_NODE_HEADER;
  Blockwrite(F, header, 2);
  Blockwrite(F, obj.objtype, 1); // тип объекта
  WriteHeadObj(obj, F);
  case obj.objtype of
    3: // пустышка
      begin
      end;
    0: // меш
      begin
        header := ID_VERTEX_HEADER;
        Blockwrite(F, header, 2); // Заголовок вершинного экспорта 2FF2
        if cMeshObr(obj).inst then
        begin
          buf := 0;
          Blockwrite(F, buf, 1);
          writestring(F, cMeshObr(obj).instname);
        end
        else
        begin
          buf := 1;
          Blockwrite(F, buf, 1);
          Blockwrite(F, cMeshObr(obj).Mesh.FaceCount, 4); // Число вершин
          Blockwrite(F, cMeshObr(obj).Mesh.VertexCount, 4); // Число вершин
          Blockwrite(F, cMeshObr(obj).Mesh.FaceArray[0],
            4 * 3 * cMeshObr(obj).Mesh.FaceCount); // указатель вершин
          Blockwrite(F, cMeshObr(obj).Mesh.DrawArray[0],
            4 * 3 * cMeshObr(obj).Mesh.VertexCount); // вершинный массив
          Blockwrite(F, cMeshObr(obj).Mesh.DrawNormals[0],
            4 * 3 * cMeshObr(obj).Mesh.VertexCount); // массив нормалей
          Blockwrite(F, cMeshObr(obj).Mesh.TexVertexArray[0],
            4 * 2 * cMeshObr(obj).Mesh.VertexCount); // массив нормалей
          Blockwrite(F, cMeshObr(obj).Mesh.VPointers.count, 4);
          for i := 0 to cMeshObr(obj).Mesh.VPointers.count - 1 do
          begin
            WriteVPoint(F, cMeshObr(obj).Mesh.UnicVert[i]);
          end;
        end;
        material := cMeshObr(obj).getmaterial;
        SaveSkin(F, cMeshObr(obj));
        // ---------------- Запись цвета ---------------------------------------
        buf := round(cMeshObr(obj).Mesh.defoultcolor.x * 255);
        Blockwrite(F, buf, 1); // красный
        buf := round(cMeshObr(obj).Mesh.defoultcolor.y * 255);
        Blockwrite(F, buf, 1); // зеленый
        buf := round(cMeshObr(obj).Mesh.defoultcolor.z * 255);
        Blockwrite(F, buf, 1); // голубой
        // -------------- Чтение информации о материале -------------------------
        if material.MtlExist then
          header := ID_MTL_HEADER
        else
          header := 0;
        Blockwrite(F, header, 2); // 1ff1 либо 0000
        if material.MtlExist then
        begin // если материал есть
          writestring(F, material.name);
          Blockwrite(F, material.Ambient, 12);
          Blockwrite(F, material.Diffuse, 12);
          Blockwrite(F, material.Specular, 12);
          shin := material.Shininess / 128;
          Blockwrite(F, shin, 4); // массив нормалей
          material.MtlExist := true;
          WriteTexture(F, material.difTexture);
          WriteTexture(F, material.BumpTexture);
        end;
      End; // Конец файла
  end; // case
end;

function LoadObrFile(path: string; pathcfgfile: cCfgFile;
  scene: tobject): boolean;
var
  F: file; // читаемый файл
  obj: cNodeObject;
  texturedir, fullpath: string;
  bRead: boolean;
  sc: cScene;
  bufferscene: cBaseObjList;
  i: integer;
begin
  result := false;
  if not FileExists(path) then
  begin
    fullpath:=pathcfgfile.findMeshFile(path);
    if not FileExists(fullpath) then
    begin
      exit;
    end
    else
      path:=fullpath;
  end;
  AssignFile(F, path);
  bufferscene := cBaseObjList.Create; // Создаем промежуточную сцену и помещаем считанные объекты в нее
  result := true;
  obj := nil;
  sc := cScene(scene);
  Reset(F, 1); // второй параметр - длина одной читаемой записи.
  readHeader(sc.FileHeaderObjectInfo, F);
  bRead := true;
  while bRead do
  Begin
    obj := readObj(F, sc, bufferscene, crender(sc.render).m_MatMng, pathcfgfile);
    bRead := (obj <> nil);
    if bRead then
      bufferscene.addobj(obj);
  end;
  CloseFile(F);
  // инициация модификаторов
  for i := 0 to bufferscene.count - 1 do
  begin
    InitSkin(cNodeObject(bufferscene.getobj(i)), bufferscene);
  end;
  for i := 0 to bufferscene.count - 1 do
  begin
    sc.Add(cNodeObject(bufferscene.getobj(i)));
  end;
  path := ChangeFileExt(path, '.oba');
  if FileExists(path) then
  begin
    LoadObaFile(path, cui(crender(cScene(scene).render).ui), bufferscene);
  end;
  bufferscene.Clear;
  bufferscene.Destroy;
  cScene(scene).Events.CallAllEvents(E_glLoadScene);
end;

end.
