unit uXMLFile;

interface
uses
  uBaseObjMng, uchart, ubldeng, uBldTimeProc, uturbina, ubldfile, sysutils,
  uBladeTicksFile, NativeXml, ubldEngEventTypes, uchan;

procedure saveXMLFile(fname:string; eng:cbldeng; chart:cchart);
function LoadXMLFile(fname:string; eng:cbldeng; chart:cchart):boolean;

implementation
uses
  utag, udrawobj, uBaseBldAlg, uPlat;

procedure saveXMLFile(fname:string; eng:cbldeng; chart:cchart);
var
  doc:TNativeXml;
  node:txmlnode;
  str:UTF8String;
begin
  eng.SaveToXML(FName,'ObjectsCfg');
  chart.OBJmNG.AddToXML(fname, 'UICfg');
  eng.HardWare.AddToXML(fname, 'HardWare');
  cbldtimeproc(eng.timeProc).TaskList.AddToXML(fname, 'TaskCfg');
  cbldtimeproc(eng.timeProc).alglist.AddToXML(fname, 'AlgCfg');
  cbldtimeproc(eng.timeProc).fTagMng.AddToXML(fname, 'TagsMng');
  // ���������� ����� �������
  doc:=TNativeXml.Create(nil);
  doc.LoadFromFile(fname);
  node:=doc.Root;

  node:=node.NodeNew('CommonProperties');
  str:=eng.GetFolder;
  node.WriteAttributeString('Folder',str);
  str:=eng.GetFName;
  node.WriteAttributeString('FileName',str);
  Doc.XmlFormat := xfReadable;
  doc.SaveToFile(fname);
  doc.Destroy;
end;

function LoadXMLFile(fname:string; eng:cbldeng; chart:cchart):boolean;
var
  t:cturbine;
  i:integer;
  tag:cbasetag;
  ext, folder, namepart:string;
  doc:TNativeXml;
  node:txmlnode;
  obj:cchan;
begin
  result:=eng.LoadFromXML(fname, 'ObjectsCfg');
  chart.ObjMng.LoadFromXML(fname, 'UICfg');
  t:=cturbine(eng.getTurbine);
  if t<>nil then
  begin
    if fileexists(eng.lastfile) then
    begin
      ext:=extractfileext(eng.lastfile);
      if ext='.bld' then
        ReadBldData(eng.lastfile,eng);
      if ext='.sdt' then
      begin
        ReadData(eng.lastfile,eng.channels);
        for I := 0 to eng.channels.childCount - 1 do
        begin
          obj:=cchan(eng.channels.getChild(i));
          if obj.eng=nil then
          begin
            obj.eng:=eng;
          end;
        end;
        NamePart:=extractfilename(eng.lastfile);
        //loader.addid(eng.lastfile);
        eng.Events.CallAllEvents(E_OnEngLoadData);
      end;
    end;
  end;
  cbldtimeproc(eng.timeProc).TaskList.LoadFromXML(fname, 'TaskCfg');
  cbldtimeproc(eng.timeProc).algList.LoadFromXML(fname, 'AlgCfg');
  for I := 0 to cbldtimeproc(eng.timeProc).algList.Count - 1 do
  begin
    cbldtimeproc(eng.timeProc).addalgtags(cbasebldalg(cbldtimeproc(eng.timeProc).algList.getobj(i)));
  end;
  for i := 0 to cbldtimeproc(eng.timeProc).fTagMng.count - 1 do
  begin
    tag:=cbldtimeproc(eng.timeProc).fTagMng.gettag(i);
    if tag.active then
    begin
      if tag.opts<>'' then
      begin
        tag.drawobj:=cdrawobj(chart.OBJmNG.getobj(tag.opts));
      end;
    end;
  end;
  // ��������� ����� ��������
  doc:=TNativeXml.Create(nil);
  doc.LoadFromFile(fname);
  node:=doc.Root;
  node:=node.FindNode('CommonProperties');

  if node<>nil then
  begin
    namepart:=node.ReadAttributeString('FileName');
    folder:=node.ReadAttributeString('Folder');
    eng.SetFolderPath(folder,namepart);
  end;

  cbldtimeproc(eng.timeProc).fTagMng.LoadFromXML(fname, 'TagsMng');

  if eng.HardWare.count=0 then
  begin
    cPlatsList(eng.HardWare).Search;
  end;
  cPlatsList(eng.HardWare).AddFromXML(fname, 'HardWare');
  eng.Events.CallAllEvents(E_OnEngLoadCfg);
  doc.Destroy;
end;

end.
