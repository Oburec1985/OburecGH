unit uObjXML;

interface
uses
  NativeXml,
  //NativeXmlAppend,
  NativeXmlObjectStorage, uBaseObj, uBaseObjMng,
  sysutils, uCommonMath ;

procedure XMLSaveObjects(doc:TNativeXml; eng:cBaseObjMng; section:string);
procedure XMLloadObjects(doc:TNativeXml; eng:cBaseObjMng; section:string);overload;
procedure XMLloadObjects(doc:TNativeXml; eng:cBaseObjMng; node:tXMLNode);overload;

const
  c_type = 'ObjType';
  c_Node = 'Node';

implementation

// rootObj - объект к которому должны линковатьс€ все дочерние узлы загружаемого узла. ≈сли nil
// то родитель - самт загружаемый узел
function LoadObj(xmlNode:TXmlNode;rootObj:cbaseObj;eng:cBaseObjMng):cbaseobj;
var
  nodename, nodetype, str:string;
  obj, child:cbaseobj;
  i:integer;
  childNode:tXmlNode;
  autocreate:boolean;
begin
  result:=nil;
  nodeType:=xmlNode.ReadAttributeString(c_type);
  if nodetype='' then exit;

  nodename:=xmlNode.Name;
  str:=xmlNode.ReadAttributeString(c_Node);
  if str<>'' then
  begin
    if str<>nodename then
    begin
      nodename:=str;
    end;
  end;
  autocreate:=xmlNode.ReadAttributeBool('AutoCreate');
  if not autocreate then
  begin
    obj:=eng.CreateObjByType(nodeType);
    eng.Add(obj,nil);
  end
  else
  begin
    obj:=eng.getobj(nodename);
    if obj<>nil then
    begin
      // чтение свойств автосоздаваемых объектов
      obj.LoadObjAttributes(xmlNode, eng);
    end;
    // WTF??? «акоментировал 07.10.2017 ƒалее по тексту добавлено р€дом с if obj=nil if not obj.autocreate
    // obj:=nil;
  end;
  if obj<>nil then
  begin
    if not obj.autocreate then
    begin
      obj.name:=nodename;
      obj.LoadObjAttributes(xmlNode, eng);
    end;
  end;
  for I := 0 to xmlNode.NodeCount - 1 do
  begin
    childNode:=xmlNode.nodes[i];
    if childNode.Name='Properties' then
    begin
      if obj<>nil then
        obj.metadata.LoadXml(childNode);
    end
    else
    begin
      // веро€тно надо закоментировать or (obj.autocreate) и оставить этот вариант только дл€ (obj=nil)
      if (obj=nil) or (obj.autocreate) then
        child:=LoadObj(ChildNode,rootObj, eng)
      else
        child:=LoadObj(ChildNode,obj, eng);
      if child<>nil then
      begin
        if (obj<>nil) and (not obj.autocreate) then
        begin
          child.mainParent:=obj;
        end
        else
        begin
          // условие добавлено 07.10.17
          if (rootObj=nil) and (obj<>nil) then
          begin
            if child.mainParent<>obj then
              child.mainParent:=obj;
          end
          else
            child.mainParent:=rootObj;
        end;
      end;
    end;
  end;
  result:=obj;
end;

procedure XMLloadObjects(doc:TNativeXml; eng:cBaseObjMng; node:tXmlNode);
var
  childNode:tXmlNode;
  I: Integer;
  obj:cbaseobj;
begin
  for I := 0 to node.nodeCount - 1 do
  begin
    childNode:=node.Nodes[i];
    obj:=LoadObj(childNode,nil,eng);
     if obj<>nil then
    begin
      if eng.getobj(obj.name)=nil then
      begin
        eng.Add(obj, nil);
      end;
    end;
  end;
end;

function FindNode(node:tXmlNode;name:string):txmlNode;
begin
end;

function FindNodeInDoc(doc:tnativeXML;section:string):txmlNode;
var
  xmlNode:tXmlNode;
begin
end;

procedure XMLloadObjects(doc:TNativeXml; eng:cBaseObjMng; section:string);
var
  xmlNode:tXmlNode;
begin
  xmlNode:=doc.Root.FindNode(section);
  XMLloadObjects(doc,eng,xmlNode);
end;

procedure saveObj(xmlRoot:TXmlNode;obj:cbaseobj; eng:cBaseObjMng);
var
  ChildXmlNode, PropertieNode:tXmlNode;
  i:integer;
  str:string;
begin
  str:=obj.name;
  for I := 1 to length(obj.name) - 1 do
  begin
    if str[i]=' ' then
    begin
      str[i]:='_';
    end;
  end;
  ChildXmlNode:=xmlRoot.FindNode(str);
  if ChildXmlNode=nil then
    ChildXmlNode:=xmlRoot.NodeNew(str);
  if obj.metadata.Count>0 then
  begin
    PropertieNode:=ChildXmlNode.NodeNew('Properties');
    obj.metadata.SaveToXml(PropertieNode);
  end;
  ChildXmlNode.WriteAttributeString(c_type, obj.classname);
  ChildXmlNode.WriteAttributeString(c_Node, obj.name);
  obj.SaveObjAttributes(ChildXmlNode);
  for I := 0 to obj.ChildCount - 1 do
  begin
    SaveObj(ChildXmlNode,obj.getChild(i),eng);
  end;
end;

procedure XMLSaveObjects(doc:TNativeXml; eng:cBaseObjMng; section:string);
var
  xmlNode:tXmlNode;
  I: Integer;
  obj:cbaseobj;
begin
  xmlNode:=doc.Root.FindNode(section);
  if (xmlNode=nil) then
  begin
    xmlNode:=doc.Root.NodeNew(section);
  end;
  for I := 0 to eng.Count - 1 do
  begin
    obj:=eng.getobj(i);
    if obj.parent=nil then
    begin
      saveObj(xmlNode,obj, eng);
    end;
  end;
end;

end.
