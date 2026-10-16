unit uXMLFunc;

{$mode ObjFPC}{$H+}{$codepage UTF8}

interface

uses
  Classes, SysUtils, fgl, dom;

type
  TDOMNodes = specialize TFPGList<TDOMNode>;

  function GetNodesContainingAttr(root: TDOMNode; nodename: string; attrname: string): TDOMNodes;
  function GetNodeByIndex(root: TDOMNode; nodename: string; index: integer): TDOMNode;
  function GetSingleNodeByAttrValue(root: TDOMNode; nodename: string; attrname: string; value: string): TDOMNode;
  function GetNodesByIndexes(root: TDOMNode; nodename: string; indexes: array of integer): TDOMNodes;
  function GetNodesByAttrValue(root: TDOMNode; nodename: string; attrname: string; attrvalue: string): TDOMNodes;
implementation

//Поиск всех узлов содержащих заданный атрибут
function GetNodesContainingAttr(root: TDOMNode; nodename: string; attrname: string): TDOMNodes;
var
  nodes: TDOMNodeList;
  attr: TDOMAttr;
  i: integer;
  output: TDOMNodes;
  s: string;
begin
 nodes := TDOMElement(root).GetElementsByTagName(nodename);
 if not Assigned(nodes) then exit;
 output := TDOMNodes.Create;

 for i := 0 to nodes.Count - 1 do
    begin
    attr := TDOMAttr(nodes[i].Attributes.GetNamedItem(attrname));
    if Assigned(attr) then
      begin
      output.Add(nodes[i]);
      end;
    end;
  result := output;
end;


//Поиск всех узлов содержащих заданный атрибут с заданным значением
function GetNodesByAttrValue(root: TDOMNode; nodename: string; attrname: string; attrvalue: string): TDOMNodes;
var
  nodes: TDOMNodeList;
  attr: TDOMAttr;
  i: integer;
  output: TDOMNodes;
  s: string;
begin
 nodes := TDOMElement(root).GetElementsByTagName(nodename);
 if not Assigned(nodes) then exit;
 output := TDOMNodes.Create;

 for i := 0 to nodes.Count - 1 do
    begin
    attr := TDOMAttr(nodes[i].Attributes.GetNamedItem(attrname));
    if Assigned(attr) and (attr.NodeValue = attrvalue) then
      begin
      output.Add(nodes[i]);
      end;
    end;
  result := output;
end;


//Поиск узла с заданным именем по номеру
function GetNodeByIndex(root: TDOMNode; nodename: string; index: integer): TDOMNode;
var
  nodes: TDOMNodeList;
begin
 result := nil;
 nodes := TDOMElement(root).GetElementsByTagName(nodename);
 if not Assigned(nodes) then exit;

 if index < nodes.count then
   result := nodes.item[index];
end;

//Поиск однотипных узлов с заданным индексами
function GetNodesByIndexes(root: TDOMNode; nodename: string; indexes: array of integer): TDOMNodes;
var
  nodes: TDOMNodes;
  nodelst: TDOMNodeList;
  node: TDOMNode;
  i: integer;
begin
 result := nil;

 nodes := TDOMNodes.Create;
 nodelst := TDOMElement(root).GetElementsByTagName(nodename);

 for i := 0 to length(indexes) - 1 do
    begin
     node := nodelst.Item[indexes[i]];
     nodes.Add(node);
    end;


 if nodes.Count = 0 then FreeAndNil(nodes)
 else
 result := nodes;
end;

//Найти узел по значению атрибута
function GetSingleNodeByAttrValue(root: TDOMNode; nodename: string; attrname: string; value: string): TDOMNode;
var
  nodes: TDOMNodeList;
  attr: TDOMNode;
  i: integer;
begin
 result := nil;
 nodes := TDOMElement(root).GetElementsByTagName(nodename);
 if not Assigned(nodes) then exit;

 for i := 0 to nodes.length - 1 do
    begin
    attr := nodes[i].Attributes.GetNamedItem(attrname);
    if Assigned(attr) and (attr.NodeValue = value) then
      begin
      result := TDOMElement(nodes[i]);
      break;
      end;
    end;
  FreeAndNil(nodes);
end;

end.

