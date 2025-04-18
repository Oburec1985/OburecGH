unit RepODT;
//������ ����������� � ��������  (DELPHI2009+)

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, StdCtrls,
  msxml2_tlb,
  ZipMstr19,
  ShellApi;

{function OpenRepFile(fname: string): AnsiString;
function InsertIntoCell(s: AnsiString; TabName: AnsiString; Text: AnsiString; Row: Integer; Column: Integer): AnsiString;
function FindAndReplace(s: AnsiString; Metka: AnsiString; Text: AnsiString): AnsiString;
function InsertRows(s: AnsiString; TabName: AnsiString; AnalogRow: Integer; RowCount: Integer): AnsiString;
function ReplaceMetkaPicture(fname, s: AnsiString; Metka: AnsiString; pict: AnsiString; width, hight: Integer; all: boolean): AnsiString;
function DeleteRow(s: AnsiString; TabName: AnsiString; Row: Integer): AnsiString;
function CloseRepFile(fname: string; s: AnsiString): boolean;
function InsertBreak(s: AnsiString; metka: AnsiString): AnsiString;}

const
aSymbol = 0;
aParagraph = 1;

type
TRepOdt = class(TComponent)
private
  fShablon: string;
  fReportPath: string;
  fDoc: IXMLDOMDocument3;
  fD: IXMLDomElement;
  fN: integer;
public
  constructor Create(shablon: string; reppath: string);
  //destructor Destroy;
  procedure Open;
  procedure Close;
  procedure ExecRep;
  procedure FindAndReplace(metka: string; text: string);
  procedure InsertRows(tab: string; numrow, rowcount: integer);
  procedure DeleteRow(tab: string; numrow: integer);
  procedure InsertIntoCell(tab: string; text: string; row, column: integer);
  procedure CellColor(tab: string; row, column:integer; color: string);
  procedure ColorRow(tab: string; row: integer; color: string);
  procedure InsertPicture(metka, fname:string; width, height: real; anchor: integer);
  procedure InsertBreak(metka: string);
  procedure ModifyFormul(objname: string; newformul: string);
end;


implementation

function MyRemoveDir(sDir : string) : Boolean;
var
  iIndex: Integer;
  SearchRec: TSearchRec;
  sFileName: string;
begin
  sDir := sDir + '\*.*';
  iIndex := FindFirst(sDir, faAnyFile, SearchRec);

  while iIndex = 0 do
  begin
    sFileName := ExtractFileDir(sDir)+'\'+SearchRec.name;
    if SearchRec.Attr = faDirectory then
    begin
      if (SearchRec.name <> '' ) and (SearchRec.name <> '.') and
      (SearchRec.name <> '..') then
        MyRemoveDir(sFileName);
    end
    else
    begin
      if SearchRec.Attr <> faArchive then
        FileSetAttr(sFileName, faArchive);
      if not DeleteFile(sFileName) then
        ShowMessage('Could NOT delete ' + sFileName);
    end;
    iIndex := FindNext(SearchRec);
  end;

  FindClose(SearchRec);
  RemoveDir(ExtractFileDir(sDir));
  Result := True;
end;

constructor TRepOdt.Create(shablon: string; reppath: string);
begin
fN:=0;
fShablon:=shablon;
fReportPath:=reppath;
end;

procedure TRepOdt.ExecRep;
begin
ShellExecute(Application.Handle, 'open', PChar(ExtractFileName(fReportPath)), nil, pChar(ExtractFileDir(fReportPath)), SW_RESTORE);
end;

procedure TRepOdt.Open;
var
  zm: TZipMaster19;
  s: AnsiString;
  fcoDoc: CoDOMDocument60;
begin
  if not copyfile(PChar(fShablon), PChar(fReportPath),false) then
  raise Exception.Create('Error aquired coping report file!');

  if fileexists(fReportPath+'\content.xml') then deletefile(fReportPath+'\content.xml');

  zm:=TZipMaster19.Create(nil);
  zm.DLL_Load := true;
  zm.ZipFileName:=fReportPath;
  zm.ExtrBaseDir:=ExtractFileDir(fReportPath);
  zm.FSpecArgs.Clear;
  zm.ExtrOptions:=[ExtrDirNames,ExtrForceDirs,ExtrOverWrite];
  zm.FSpecArgs.Add('content.xml');
  zm.FSpecArgs.Add('META-INF\manifest.xml');
  zm.Extract;
  zm.Free;

  fDoc := CoDOMDocument60.Create;
  fDoc.setProperty('SelectionNamespaces','xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"'+
' xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"'+
' xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"'+
' xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"'+
' xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"'+
' xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"'+
' xmlns:xlink="http://www.w3.org/1999/xlink"'+
' xmlns:dc="http://purl.org/dc/elements/1.1/"'+
' xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"'+
' xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"'+
' xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"'+
' xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"'+
' xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"'+
' xmlns:math="http://www.w3.org/1998/Math/MathML"'+
' xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"'+
' xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"'+
' xmlns:ooo="http://openoffice.org/2004/office"'+
' xmlns:ooow="http://openoffice.org/2004/writer"'+
' xmlns:oooc="http://openoffice.org/2004/calc"'+
' xmlns:dom="http://www.w3.org/2001/xml-events"'+
' xmlns:xforms="http://www.w3.org/2002/xforms"'+
' xmlns:xsd="http://www.w3.org/2001/XMLSchema"'+
' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+
' xmlns:rpt="http://openoffice.org/2005/report"'+
' xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2"'+
' xmlns:rdfa="http://docs.oasis-open.org/opendocument/meta/rdfa#" ');
  fDoc.load(ExtractFileDir(fReportPath)+'\content.xml');
 // s:=fDoc.xml;
  fD:=fDoc.Get_documentElement;
end;


procedure TRepOdt.ModifyFormul(objname: string; newformul: string);
var
  zm: TZipMaster19;
  folder: string;
  tegvalue: string;
  d: IXMLDOMDocument3;
  p: string;
  el: IXMLDOMElement;
begin
  tegvalue:=fd.selectSingleNode('.//draw:frame[@draw:name = "'+objname+'"]/draw:object/attribute::xlink:href').nodeValue;
  folder:=copy(tegvalue,3,length(tegvalue) - 2);
  zm:=TZipMaster19.Create(nil);
  zm.ZipFileName:=fReportPath;
  zm.ExtrBaseDir:=ExtractFileDir(fReportPath);
  zm.FSpecArgs.Clear;
  zm.ExtrOptions:=[ExtrDirNames,ExtrForceDirs,ExtrOverWrite];
  zm.FSpecArgs.Add(folder+'\content.xml');
  zm.Extract;

  d:=CoDomDocument60.Create;
  d.setProperty('SelectionNamespaces','xmlns:math="http://www.w3.org/1998/Math/MathML"');
  p:=ExtractFileDir(fReportPath)+'\'+folder+'\content.xml';
  d.load('D:\Gaz\Poteri\Report\Object 1\content.xml');
  el:=d.get_documentElement;

  el.selectSingleNode('//math:annotation').nodeValue:=newformul;

  zm.Free;
end;


procedure TRepOdt.FindAndReplace(metka: string; text: string);
var
  list: IXMLDOMNodeList;
  i, j: Integer;
begin
 list:=fD.selectNodes('.//text:*[contains(text(), "'+metka+'")]/child::text()');
 for i := 0 to List.length - 1 do
    begin
    list.item[i].Text := StringReplace(list.item[i].Text,metka,text,[rfReplaceAll]);
    //StringReplace(list.item[i].Text,metka,text,[rfReplaceAll]);
    end;
end;

procedure TRepOdt.InsertRows(tab: string; numrow, rowcount: Integer);
var
  TabNode, RowNode, NewRowNode: IXMLDOMNode;
  RowList: IXMLDOMNodeList;
  i: Integer;
begin
 TabNode:=fD.SelectSingleNode('office:body//table:table[@table:name = "'+tab+'"]');
 RowList:=TabNode.selectNodes('.//table:table-row');
 RowNode:=RowList.item[numrow];
 for i:=0 to rowcount - 1 do
   begin
   NewRowNode:=RowNode.cloneNode(true);
   TabNode.appendChild(NewRowNode);
   end;
end;

procedure TRepOdt.DeleteRow(tab: string; numrow: Integer);
var
  TabNode, RowNode: IXMLDOMNode;
begin
 TabNode:=fD.selectSingleNode('office:body//table:table[@table:name = "'+tab+'"]');
 RowNode:=TabNode.selectSingleNode('table:table-row['+IntToStr(numrow+1)+']');
 TabNode.removeChild(RowNode);
end;

procedure TRepOdt.InsertIntoCell(tab: string; text: string; row, column: Integer);
var
  TabNode, RowNode, CellNode: IXMLDOMNode;
  RowList: IXMLDOMNodeList;
  txt: IXMLDOMText;
begin
 TabNode:=fD.selectSingleNode('office:body//table:table[@table:name = "'+tab+'"]');
 RowList:=TabNode.selectNodes('.//table:table-row');
 RowNode:=RowList.Item[row];
 CellNode:=RowNode.selectSingleNode('table:table-cell['+IntToStr(column+1)+']/text:p');
 txt:=fDoc.createTextNode(text);
 CellNode.appendChild(txt);
end;

procedure TRepOdt.CellColor(tab: string; row, column:integer; color: string);
var
  Styles, OldCellStyle, ColoredCellStyle, Styleattr: IXMLDOMNode;
  TabNode, RowNode, CellNode: IXMLDOMNode;
  val, value: OLEVariant;
  name: string;
  attr: IXMLDOMAttribute;
begin
  Styles:=fD.selectSingleNode('office:automatic-styles');
  TabNode:=fD.selectSingleNode('//table:table[@table:name = "'+tab+'"]');
  RowNode:=TabNode.selectSingleNode('table:table-row['+IntToStr(row)+']');
  CellNode:=RowNode.selectSingleNode('table:table-cell['+IntToStr(column)+']');
  value:=RowNode.selectSingleNode('table:table-cell['+IntToStr(column)+']/@table:style-name').nodeValue;
  OldCellStyle:=Styles.selectSingleNode('style:style[@style:name = "'+value+'"]');
  val:=CellNode.attributes.getNamedItem('table:style-name').nodeValue;
  name:=value+'colored'+color;
  if val <> name then
  if (Styles.selectSingleNode('style:style[@name = "'+name+'"]') = nil) then
  begin
    ColoredCellStyle:=OldCellStyle.cloneNode(true);
    StyleAttr:=ColoredCellStyle.selectSingleNode('style:table-cell-properties');
    attr:=fDoc.createAttribute('fo:background-color');
    attr.value:=color;
    StyleAttr.attributes.setNamedItem(attr);
    attr:=fDoc.createAttribute('style:name');
    attr.value:=name;
    ColoredCellStyle.attributes.setNamedItem(attr);
    Styles.appendChild(ColoredCellStyle);
  end;
  attr:=fDoc.createAttribute('table:style-name');
  attr.value:=name;
  CellNode.attributes.setNamedItem(attr);
end;

procedure TRepOdt.ColorRow(tab: string; row: integer; color: string);
var
TabNode, RowNode: IXMLDOMNode;
list: IXMLDOMNodeList;
i: Integer;
begin
  TabNode:=fD.selectSingleNode('//table:table[@table:name = "'+tab+'"]');
  RowNode:=TabNode.selectSingleNode('table:table-row['+IntToStr(row)+']');
  list:=RowNode.selectNodes('table:table-cell');
  for i := 0 to list.length - 1 do
    CellColor(tab,row,i+1,color);
end;

procedure TRepOdt.InsertPicture(metka, fname:string; width, height: real; anchor: integer);
var
  DocManifest: IXMLDOMDocument3;
  MainElMan: IXMLDOMElement;
  ElMan: IXMLDOMElement;
  ManAttr: IXMLDOMAttribute;
  //������ <manifest:file-entry manifest:media-type="image/png" manifest:full-path="Pictures/10000000000001B1000000B3CBCB907F.png" />

  StyleNode, PropNode, PictNode, Picture: IXMLDOMElement;
  attr: IXMLDOMAttribute;
  St_sect, Styles, St, Node: IXMLDOMNode;
  ext, img: string;
  list: IXMLDOMNodeList;
  i: integer;
begin
  //���������� �������� � ���������
  DocManifest := CoDOMDocument60.Create;
  DocManifest.setProperty('SelectionNamespaces','xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"');
  DocManifest.load(ExtractFileDir(fReportPath)+'\META-INF\manifest.xml');
  MainElMan:=DocManifest.Get_DocumentElement;

  ElMan:=DocManifest.createElement('manifest:file-entry');

  ext:=ExtractFileExt(fname);
  img:='Pictures/'+ExtractFileName(fname);

  attr:= DocManifest.createAttribute('manifest:media-type');
  attr.value:='image/'+copy(ext,2,length(ext)-1);
  ElMan.setAttributeNode(attr);

  attr:= DocManifest.createAttribute('manifest:full-path');
  attr.value:=img;
  ElMan.setAttributeNode(attr);
  MainElMan.appendChild(ElMan);

  DocManifest.save(ExtractFileDir(fReportPath)+'\META-INF\manifest.xml');


  Styles := fD.selectSingleNode('office:automatic-styles');
  St := Styles.SelectSingleNode('.//style[@*="fr1"]');

  if St = nil then
  begin
  StyleNode:=fDoc.createElement('style:style');

  attr:=fDoc.createAttribute('style:name');
  attr.value:='fr1';
  StyleNode.setAttributeNode(attr);

  attr:=fDoc.createAttribute('style:family');
  attr.value:='graphic';
  StyleNode.setAttributeNode(attr);

  attr:=fDoc.createAttribute('style:parent-style-name');
  attr.value:='Graphics';
  StyleNode.setAttributeNode(attr);

      PropNode:=fDoc.createElement('style:graphic-properties');

      attr:=fDoc.createAttribute('style:horizontal-pos');
      attr.value:='center';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('style:horizontal-rel');
      attr.value:='paragraph';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('style:mirror');
      attr.value:='none';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('fo:clip');
      attr.value:='rect(0cm, 0cm, 0cm, 0cm)';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('draw:luminance');
      attr.value:='0%';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('draw:contrast');
      attr.value:='0%';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('draw:red');
      attr.value:='0%';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('draw:green');
      attr.value:='0%';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('draw:blue');
      attr.value:='0%';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('draw:gamma');
      attr.value:='100%';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('draw:color-inversion');
      attr.value:='false';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('draw:image-opacity');
      attr.value:='100%';
      PropNode.setAttributeNode(attr);

      attr:=fDoc.createAttribute('draw:color-mode');
      attr.value:='standard';
      PropNode.setAttributeNode(attr);

      StyleNode.appendChild(PropNode);
  //<style:style style:name="Sect1" style:family="section">
  St_sect:=Styles.selectSingleNode('.//style:style[@*="section"]');
  if St_sect<>nil then

  Styles.insertBefore(StyleNode, St_sect) else
  Styles.appendChild(StyleNode);
  end;

  PictNode:=fDoc.createElement('draw:frame');

  attr:=fDoc.createAttribute('draw:style-name');
  attr.value:='fr1';
  PictNode.setAttributeNode(attr);

  attr:=fDoc.createAttribute('draw:name');
  attr.value:='pict'+ExtractFileName(fname);//inttostr(fN);
  //inc(fN);
  PictNode.setAttributeNode(attr);

  attr:=fDoc.createAttribute('text:anchor-type');
    case anchor of
      0:attr.value:='symbol';
      1:attr.value:='paragraph';
    end;


  PictNode.setAttributeNode(attr);

  attr:=fDoc.createAttribute('svg:width');
  attr.value:=floattostr(width)+'cm';
  PictNode.setAttributeNode(attr);

  attr:=fDoc.createAttribute('svg:height');
  attr.value:=floattostr(height)+'cm';
  PictNode.setAttributeNode(attr);

  attr:=fDoc.createAttribute('draw:z-index');
  attr.value:='0';
  PictNode.setAttributeNode(attr);

  CreateDirectory(PChar(ExtractFileDir(fReportPath)+'\Pictures'),nil);
  CopyFile(PChar(fname),PChar(ExtractFileDir(fReportPath)+'\Pictures\'+ExtractFileName(fname)),false);
  img:='Pictures/'+ExtractFileName(fname);

  Picture:=fDoc.createElement('draw:image');

  attr:=fDoc.createAttribute('xlink:href');
  attr.value:=img;
  Picture.setAttributeNode(attr);

  attr:=fDoc.createAttribute('xlink:type');
  attr.value:='simple';
  Picture.setAttributeNode(attr);

  attr:=fDoc.createAttribute('xlink:show');
  attr.value:='embed';
  Picture.setAttributeNode(attr);

  attr:=fDoc.createAttribute('xlink:actuate');
  attr.value:='onLoad';
  Picture.setAttributeNode(attr);

  PictNode.appendChild(Picture);

  list:=fD.selectNodes('//text:*[text() = "'+metka+'"]');
  for i := 0 to List.length - 1 do
  begin
    Node:=PictNode.cloneNode(true);

    {attr:=fDoc.createAttribute('xlink:actuate');
    attr.value:='P7';
    list.item[i].attributes.setNamedItem(attr); }

    list.item[i].text:='';
    list.item[i].appendChild(Node);
  end;
end;



procedure TRepOdt.InsertBreak(metka: string);
var
StyleNode, PropNode: IXMLDOMElement;
St, Styles: IXMLDOMNode;
attr: IXMLDOMAttribute;
list: IXMLDOMNodeList;
i,j: Integer;
begin
Styles:=fD.selectSingleNode('office:automatic-styles');
St:= Styles.selectSingleNode('style:style[@style:name = "P-Break"]');

if St = nil then
begin
StyleNode:=fDoc.createElement('style:style');
attr:=fDoc.createAttribute('style:name');
attr.value:='P-Break';
StyleNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('style:family');
attr.value:='paragraph';
StyleNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('style:parent-style-name');
attr.value:='Standard';

PropNode:=fDoc.createElement('style:paragraph-properties');
attr:=fDoc.createAttribute('fo:text-align');
attr.value:='center';
PropNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('style:justify-single-word');
attr.value:='false';
PropNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('fo:break-before');
attr.value:='page';
PropNode.setAttributeNode(attr);
StyleNode.appendChild(PropNode);

PropNode:=fDoc.createElement('style:text-properties');
attr:=fDoc.createAttribute('fo:font-size');
attr.value:='14pt';
PropNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('fo:language');
attr.value:='en';
PropNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('fo:country');
attr.value:='US';
PropNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('fo:font-weight');
attr.value:='bold';
PropNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('style:font-size-asian');
attr.value:='14pt';
PropNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('style:font-weight-asian');
attr.value:='bold';
PropNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('style:font-size-complex');
attr.value:='14pt';
PropNode.setAttributeNode(attr);
attr:=fDoc.createAttribute('style:font-weight-complex');
attr.value:='bold';
PropNode.setAttributeNode(attr);
StyleNode.appendChild(PropNode);

Styles.appendChild(StyleNode);
end;
list:= fD.selectNodes('//text:p[text() = "'+metka+'"]');
for i:=0 to List.length - 1 do
    begin
    attr:=fDoc.createAttribute('text:style-name');
    attr.value:='P-Break';
    List.item[i].attributes.setNamedItem(attr);
    for j := 0 to List.item[i].childNodes.length - 1 do
      if List.item[i].childNodes.item[j].text = metka then
        List.item[i].removeChild(List.item[i].childNodes.item[j]);
    end;
end;

procedure TRepOdt.Close;
var
zm: TZipMaster19;
dir: string;
begin
dir:=ExtractFileDir(fReportPath);

fDoc.save(dir+'\content.xml');

zm:=TZipMaster19.Create(nil);
zm.DLL_Load := true;
zm.AddOptions:=[AddRecurseDirs, AddDirNames];
zm.ZipFileName:=fReportPath;
zm.FSpecArgs.Clear;
zm.RootDir:=dir;
zm.AddCompLevel := 5; //�����! ��� ������������ ������ ���������� �������� ������� �������� ������������!

if DirectoryExists(ExtractFileDir(fReportPath)+'\Pictures') then
  begin
  zm.FSpecArgs.Add('>Pictures\*.jpg');
  zm.FSpecArgs.Add('>Pictures\*.png');
  zm.FSpecArgs.Add('>Pictures\*.gif');
  zm.FSpecArgs.Add('>Pictures\*.bmp');
  zm.FSpecArgs.Add('>META-INF\manifest.xml');
  end;
zm.FSpecArgs.Add('|content.xml');
zm.Add;
zm.Free;

if fileexists(dir+'\content.xml') then
deletefile(dir+'\content.xml');
if DirectoryExists(dir+'\Pictures') then

MyRemoveDir(dir+'\Pictures');
MyRemoveDir(dir+'\META-INF');
end;

//===������� ���������� ��� �������=============================================
//�������� ����� ��������
{function InsertIntoStr(s, s_to_insert: AnsiString; pos: Integer): AnsiString;
var
bufstr: AnsiString;
begin
bufstr:=copy(s, 1, pos);
delete(s, 1, length(bufstr));
result:=bufstr+s_to_insert+s;
end;

function ReplaceText(s, s_to_replace, s_repl: AnsiString; pos: Integer): AnsiString;
var
bufstr: AnsiString;
begin
bufstr:=copy(s, 1, pos-1);
delete(s, 1, pos+length(s_to_replace)-1);
result:=bufstr+s_repl+s;
end;

function OpenRepFile(fname: String): AnsiString;
var
zm: TZipMaster;
fs: TFileStream;
s: AnsiString;
begin
if fileexists(ExtractFileDir(fname)+'\content.xml') then deletefile(ExtractFileDir(fname)+'\content.xml');
  zm:=TZipMaster.Create(nil);
  zm.ZipFileName:=fname;
  zm.ExtrOptions:=[ExtrOverWrite];
  zm.ExtrBaseDir:=ExtractFileDir(fname);
  zm.FSpecArgs.Clear;
  zm.FSpecArgs.Add('content.xml');
  zm.Extract;
  zm.Free;
  try
  fs:=TFileStream.Create(ExtractFileDir(fname)+'\content.xml', fmOpenRead);
  SetString(s, nil, fs.Size);
  fs.ReadBuffer(pointer(s)^,fs.Size);
  finally
  fs.Free;
  end;
result:=s;
end;

function GetMetkaTeg(s, metka: AnsiString): AnsiString;
var
bufstr, bstr: AnsiString;
begin
bufstr:=s;
while length(bufstr)<>0 do
    begin
    bstr:=Copy(bufstr, pos('<text:p',bufstr),pos('</text:p>',bufstr)-pos('<text:p',bufstr)+9);
    if Pos(metka, bstr)<>0 then
        begin
        result:=bstr;
        break;
        end;
    delete(bufstr, 1, pos('</text:p>',bufstr)+9);
    end;
end;

function CloseRepFile(fname: string; s: AnsiString): boolean;
var
zm: TZipMaster;
fs: TFileStream;
begin
try
fs:=TFileStream.Create(ExtractFileDir(fname)+'\content.xml', fmOpenWrite);
fs.Size:=0;
fs.Position:=0;
fs.WriteBuffer(pointer(s)^,Length(s));
fs.Free;

zm:=TZipMaster.Create(nil);
zm.AddOptions:=[AddDirNames];
zm.ZipFileName:=fname;
zm.FSpecArgs.Clear;
zm.RootDir:=ExtractFileDir(fname);
if DirectoryExists(ExtractFileDir(fname)+'\Pictures') then
  begin
  zm.FSpecArgs.Add('>Pictures\*.jpg');
  zm.FSpecArgs.Add('>Pictures\*.png');
  zm.FSpecArgs.Add('>Pictures\*.gif');
  zm.FSpecArgs.Add('>Pictures\*.bmp');
  zm.FSpecArgs.Add('>Pictures\*.jpg');
  end;

zm.FSpecArgs.Add('|content.xml');
zm.Add;
zm.Free;
if fileexists(ExtractFileDir(fname)+'\content.xml') then deletefile(ExtractFileDir(fname)+'\content.xml');
if DirectoryExists(ExtractFileDir(fname)+'\Pictures') then
MyRemoveDir(ExtractFileDir(fname)+'\Pictures');
result:=true;
except
result:=false;
zm.Free;
end;

end;


function InsertIntoCell(s: AnsiString; TabName: AnsiString; Text: AnsiString; Row: Integer; Column: Integer): AnsiString;
var
new_tabstr, tabstr: AnsiString;
new_rowstr, rowstr: AnsiString;
new_colstr, colstr: AnsiString;
celltext: AnsiString;

bufstr: AnsiString;

pos_tab, pos_row, pos_column, pos_text: Integer;
i: Integer;
st: AnsiString;

begin
  pos_tab:=Pos('<table:table table:name="'+TabName+'"', s);
  if pos_tab<>0 then
      begin
      tabstr:= Copy(s, pos_tab, Pos('</table:table>',Copy(s,pos_tab,length(s)-pos_tab))+13);
      Pos_Row:=0;
      bufstr:=tabstr;
      for i:=0 to Row-1 do
          begin
          if Pos('<table:table-row',bufstr)=0 then exit;
          Pos_Row:=Pos_Row+Pos('<table:table-row',bufstr);
          delete(bufstr, 1, Pos('<table:table-row',bufstr));
          end;
      rowstr:=Copy(tabstr, Pos_Row, Pos('</table:table-row>',Copy(tabstr, Pos_Row, length(tabstr)-Pos_Row))+17);
      bufstr:=rowstr;
      pos_column:=0;
      for i:=0 to Column-1 do
          begin
          if Pos('<table:table-cell',bufstr)=0 then exit;

          pos_column:=pos_column+Pos('<table:table-cell',bufstr);
          delete(bufstr, 1, Pos('<table:table-cell',bufstr));
          end;
      colstr:=Copy(rowstr, pos_column, Pos('</table:table-cell>', bufstr)+19);
      pos_text:=Pos('<text:p ', colstr);
      st:=Copy(colstr, pos_text, length(colstr)-pos_text-18);
      if Pos('</text:p>', colstr)=0 then
          begin
          celltext:=Copy(st,1,length(st)-2)+'>'+AnsiToUtf8(Text)+'</text:p>';
          end else
              begin
              celltext:=Copy(st,1,Pos('>',st))+AnsiToUtf8(Text)+'</text:p>';
              end;

      new_colstr:=ReplaceText(colstr, st, celltext, pos_text);
      new_rowstr:=ReplaceText(rowstr, colstr, new_colstr, pos_column);
      new_tabstr:=ReplaceText(tabstr, rowstr, new_rowstr, pos_row);
      s:=ReplaceText(s, tabstr, new_tabstr, pos_tab);
      end;
  result:=s;
end;

function FindAndReplace(s: AnsiString; Metka: AnsiString; Text: AnsiString): AnsiString;
begin
while Pos(Metka, s)<>0 do
s:=ReplaceText(s, Metka, AnsiToUtf8(Text), pos(Metka, s));
result:=s;
end;

function ReplaceMetkaPicture(fname, s: AnsiString; Metka: AnsiString; pict: AnsiString; width, hight: Integer; all: boolean): AnsiString;
var
stylestring: AnsiString;
pict_str: AnsiString;
i: integer;
strwdt, strhgt: AnsiString;
begin
if pos(Metka, s)=0 then
    begin
    result:=s;
    exit;
    end;

if not DirectoryExists(ExtractFileDir(fname)+'\Pictures') then
CreateDirectory(PChar(ExtractFileDir(fname)+'\Pictures'),nil);

CopyFile(Pchar(pict),PChar(ExtractFileDir(fname)+'\Pictures'+'\'+ExtractFileName(pict)),false);

if Pos('<style:style style:name="fr1"',s)=0 then
begin
stylestring:='<style:style style:name="fr1" style:family="graphic" style:parent-style-name="Graphics">'+
'<style:graphic-properties style:vertical-pos="middle" style:vertical-rel="paragraph" style:horizontal-pos="center"'+
' style:horizontal-rel="paragraph" style:mirror="none" fo:clip="rect(0cm, 0cm, 0cm, 0cm)" draw:luminance="0%"'+
' draw:contrast="0%" draw:red="0%" draw:green="0%" draw:blue="0%" draw:gamma="100%" draw:color-inversion="false"'+
' draw:image-opacity="100%" draw:color-mode="standard"/></style:style>';
s:=InsertIntoStr(s,stylestring,Pos('<office:automatic-styles>',s)+length('<office:automatic-styles>')-1);
end;

if width=0 then strwdt:='100%' else strwdt:=floattostr(width)+'cm';
if hight=0 then strhgt:='100%' else strhgt:=floattostr(hight)+'cm';
i:=0;
if all then
begin
while pos(Metka, s)<>0 do
    begin
    pict_str:='<draw:frame draw:style-name="fr1" draw:name="'+extractfilename(pict)+'_'+IntToStr(i)+'" text:anchor-type="as-char" svg:width="'+
    strwdt+'" svg:height="'+strhgt+'" draw:z-index="0"><draw:image xlink:href="Pictures/'+
    extractfilename(pict)+'" xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad"/></draw:frame>';
    s:=ReplaceText(s, Metka, pict_str, pos(Metka, s));
    inc(i);
    end;
end else
    begin
    pict_str:='<draw:frame draw:style-name="fr1" draw:name="'+extractfilename(pict)+'" text:anchor-type="as-char" svg:width="'+
    strwdt+'" svg:height="'+strhgt+'" draw:z-index="0"><draw:image xlink:href="Pictures/'+
    extractfilename(pict)+'" xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad"/></draw:frame>';
    s:=ReplaceText(s, Metka, pict_str, pos(Metka, s));
    end;
result:=s;
end;


function InsertRows(s: AnsiString; TabName: AnsiString; AnalogRow: Integer; RowCount: Integer): AnsiString;
var
new_tabstr, tabstr: AnsiString;
rowstr: AnsiString;
bufstr: AnsiString;
pos_tab: integer;
pos_row: integer;
i: Integer;
begin
if RowCount<=0 then
    begin
    result:=s;
    Exit;
    end;
  try
  pos_tab:=Pos('<table:table table:name="'+TabName+'"', s);
  if pos_tab<>-1 then
      begin
      tabstr:= Copy(s, pos_tab, Pos('</table:table>',Copy(s,pos_tab,length(s)-pos_tab))+13);
      bufstr:=tabstr;
      pos_row:=0;
      for i := 0 to AnalogRow - 1 do
          begin
          if pos('<table:table-row',bufstr)<>0 then
              begin
              pos_row:=pos_row+pos('<table:table-row',bufstr);
              delete(bufstr,1,pos('<table:table-row',bufstr))
              end else break;
          end;
      if pos_row = 0  then
          begin
          result:=s;
          Exit;
          end;
      rowstr:=Copy(tabstr,pos_row,Pos('</table:table-row>',Copy(tabstr, pos_row, length(tabstr)-pos_row))+17);
      new_tabstr:=tabstr;
      for i:=0 to RowCount - 1 do
         new_tabstr:=InsertIntoStr(new_tabstr, rowstr, Pos('</table:table>',new_tabstr)-1);
      Result:=ReplaceText(s, tabstr, new_tabstr, pos_tab);
      end;
  except
  result:=s;
  end;
end;

function DeleteRow(s: AnsiString; TabName: AnsiString; Row: Integer): AnsiString;
var
new_tabstr, tabstr: string;
rowstr: string;
bufstr: string;
pos_tab: integer;
pos_row: integer;
i: Integer;
begin
  try
  pos_tab:=Pos('<table:table table:name="'+TabName+'"', s);
  if pos_tab<>-1 then
      begin
      tabstr:= Copy(s, pos_tab, Pos('</table:table>',Copy(s,pos_tab,length(s)-pos_tab))+13);
      bufstr:=tabstr;
      pos_row:=0;
      for i := 0 to Row - 1 do
          begin
          if pos('<table:table-row',bufstr)<>0 then
              begin
              pos_row:=pos_row+pos('<table:table-row',bufstr);
              delete(bufstr,1,pos('<table:table-row',bufstr))
              end else break;
          end;
      if pos_row = 0  then
          begin
          result:=s;
          Exit;
          end;
      rowstr:=Copy(tabstr,pos_row,Pos('</table:table-row>',Copy(tabstr, pos_row, length(tabstr)-pos_row))+17);
      new_tabstr:=tabstr;
      delete(new_tabstr, Pos_Row, length(rowstr));
      Result:=ReplaceText(s, tabstr, new_tabstr, pos_tab);
      end;
  except
  result:=s;
  end;
end;

function InsertBreak(s: AnsiString; metka: AnsiString): AnsiString;
var
stylestring: AnsiString;
metkateg: AnsiString;
begin
stylestring:='<style:style style:name="PageBr" style:family="paragraph">'+
  '<style:paragraph-properties fo:break-before="page" />'+
  '</style:style>';
s:=InsertIntoStr(s,stylestring,Pos('<office:automatic-styles>',s)+length('<office:automatic-styles>')-1);

metkateg:=GetMetkaTeg(s, metka);
if metkateg<>'' then
result:=ReplaceText(s, metkateg, '<text:h text:style-name="PageBr" text:outline-level="1" />', pos(metkateg, s))
else result:=s;
end;}


end.
