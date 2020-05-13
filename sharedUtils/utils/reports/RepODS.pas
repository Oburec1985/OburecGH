unit RepODS;

interface
uses Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, StdCtrls, msxml2_tlb, ZipMstr19, ShellApi, Graphics, shlwapi;

const lang = 'ru'; //Закоментарить после перевода
function GetColorString(Color: TColor): string;
function HtmlToColor(htmlcolor: string): TColor;

type
TIntArray = array of integer;

PInt = ^integer;

TCluster = class(TObject)
private
fEl: IXMLDOMNode;
fRowList: IXMLDOMNodeList;
Main: Pointer;
public
constructor Create(el: IXMLDOMNode; P: Pointer);

procedure FindAndReplace(metka: string; text: string);
procedure InsertNumber(number: real; numrow, numcol: integer);
procedure InsertString(text: string; numrow: Integer; numcol: Integer);
procedure CellColor(row, column:integer; color: string);
procedure InsertRows(numrow, rowcount: integer);
procedure DeleteRow(numrow: integer);
end;

TClusters = class(TList)
private
function Get(Index: Integer): TCluster;
procedure Put(Index: Integer; Item: TCluster);
public
property Items[Index: Integer]: TCluster read Get write Put;
end;

TRepODS = class(TComponent)
private
fTab: IXMLDOMNode;
fClusters: TClusters;
fclustercount: Integer;
fShablon: string;
fReportPath: string;
fDoc: IXMLDOMDocument3;
fD: IXMLDomElement;
fRowList: IXMLDOMNodeList;

procedure ExtendRows;
procedure ExtendCells;
public
function GetColCount: integer;
constructor Create(shablon: string; reppath: string);
destructor Destroy;  override;
procedure Open(tab: string);
procedure Close;
procedure ExecRep;
procedure FindAndReplace(metka: string; text: string);
procedure InsertNumber(number: real; numrow, numcol: integer);
procedure InsertString(text: string; numrow: Integer; numcol: Integer);
procedure CellColor(row, column:integer; color: string);
//procedure RowColor(row: Integer; color: string);
procedure InsertRows(numrow, rowcount: integer);
procedure DeleteRow(numrow: integer);
procedure DeleteColumn(column: integer);
procedure MakeCluster(rows: TIntArray);
procedure AddClusters(num: Integer; cluster_id: Integer);
procedure DeleteCluster(id: integer);
procedure CloseClusters;
procedure InsertMetkaPicture(metka: string; fname: string; width, height: integer);
property CountClusters: integer read fclustercount;
property Clusters: TClusters read fClusters;

{procedure ColorRow(tab: string; row: integer; color: string);
procedure InsertPicture(metka, fname:string; width, height: integer);
procedure InsertBreak(metka: string);}

end;

implementation

function ColorToHTML(Color: TColor): Cardinal;
var
RGBColor: TColor;
begin
if Color < 0 then
RGBColor := GetSysColor(Color and $000000FF)
else
RGBColor := Color;

Result := ((RGBColor and $FF0000) shr 16) or (RGBColor and $00FF00) or ((RGBColor and $0000FF) shl 16);
end;

function HtmlToColor(htmlcolor: string): TColor;
var
Color: integer;
begin
if htmlcolor[1] = '#' then delete(htmlcolor,1,1);
strtointex(PChar('0x'+htmlcolor), STIF_SUPPORT_HEX, Color);

Color := (((Color and $FF0000) shr 16) or (Color and $00FF00)
or ((Color and $0000FF) shl 16));
result := color;
end;

function GetColorString(Color: TColor): string;
begin
Result := '#' + IntToHex(ColorToHTML(Color),2);
end;

function column(num: integer): string;
const z = 26;
var s: string;  { buffer }
begin
  if num <= 0 then result:= '';
  s := '';
  while num > z do begin
    s := chr(ord('A') + num mod z -1) + s;
    num := num mod z;
  end;
  s := chr(ord('A') + num - 1) + s;
  result:= s;
end;

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

//==================TCluster====================================================
function TClusters.Get(Index: Integer): TCluster;
var
p: pointer;
begin
p := inherited Get(Index);
result:=TCluster(p);
end;

procedure TClusters.Put(Index: Integer; Item: TCluster);
begin
inherited Put(Index, TCluster(Item));
end;

constructor TCluster.Create(el: IXMLDOMNode; P: Pointer);
begin
fEl := el;
Main := p;
fRowList := fEl.SelectNodes('.//table:table-row');
end;

procedure TCluster.FindAndReplace(metka: string; text: string);
var
list: IXMLDOMNodeList;
i: Integer;
begin
 list:=fEl.selectNodes('.//text:*[text() = "'+metka+'"]');
 for i := 0 to List.length - 1 do
    begin
    list.item[i].text:=text;
    end;
end;

procedure TCluster.InsertNumber(number: real; numrow, numcol: integer);
var
cell: IXMLDOMNode;
el: IXMLDOMElement;
attr: IXMLDOMAttribute;
txt: IXMLDOMText;
begin
cell:=fRowList[numrow].SelectSingleNode('table:table-cell['+inttostr(numcol+1)+']');
attr:=TRepODS(Main).fDoc.createAttribute('office:value-type');
attr.value:='float';
cell.attributes.setNamedItem(attr);

attr:=TRepODS(Main).fDoc.createAttribute('office:value');
attr.value:=number;
cell.attributes.setNamedItem(attr);

el:=TRepODS(Main).fDoc.createElement('text:p');
txt:=TRepODS(Main).fDoc.createTextNode(floattostr(number));
el.appendChild(txt);
cell.appendChild(el);
end;

procedure TCluster.InsertString(text: string; numrow: Integer; numcol: Integer);
var
cell: IXMLDOMNode;
el: IXMLDOMElement;
attr: IXMLDOMAttribute;
txt: IXMLDOMText;
//list: IXMLDOMNodeList;
begin
cell:=fRowList[numrow].SelectSingleNode('table:table-cell['+inttostr(numcol+1)+']');
attr:=TRepODS(Main).fDoc.createAttribute('office:value-type');
attr.value:='string';
cell.attributes.setNamedItem(attr);

el:=TRepODS(Main).fDoc.createElement('text:p');
txt:=TRepODS(Main).fDoc.createTextNode(text);
el.appendChild(txt);
cell.appendChild(el);
end;

procedure TCluster.CellColor(row, column: integer; color: string);
var
Styles, OldCellStyle, ColoredCellStyle, Styleattr: IXMLDOMNode;
prop, {RowNode,} CellNode, ColNode: IXMLDOMNode;
Style, CellProp: IXMLDOMElement;
typ_, val, value: OLEVariant;
name: string;
attr: IXMLDOMAttribute;
begin
Styles:=TRepODS(Main).fD.selectSingleNode('office:automatic-styles');
CellNode:=fRowList[row].SelectSingleNode('table:table-cell['+inttostr(column+1)+']');

Styleattr:=CellNode.attributes.getNamedItem('table:style-name');
if (Styleattr = nil) then //Если в ячейке не указан стиль
    begin
    ColNode:=TRepODS(Main).fTab.selectSingleNode('table:table-column['+IntToStr(column)+']');  //найти колонку ячейки
    if ColNode<>nil then
    value:=ColNode.attributes.getNamedItem('table:default-cell-style-name').nodeValue;      //определить название стиля колонки
    OldCellStyle:=Styles.selectSingleNode('.//style[@name = "'+value+'"]');    //получить ссылку на узел стиля ячеек колонки по умолчанию
    if OldCellStyle = nil then  //если узел не найден
        begin
        name:='ce-colored'+copy(color,2,length(color)-1);

        if (Styles.selectSingleNode('.//style:style[@name = "'+name+'"]') = nil) then //Если стиля с таким именем нет, то
            begin
            Style:=TRepODS(Main).fDoc.createElement('style:style'); //создать новый стиль
            attr:=TRepODS(Main).fDoc.createAttribute('style:name');
            attr.value:=name;
            Style.attributes.setNamedItem(attr);
            attr:=TRepODS(Main).fDoc.createAttribute('style:family');
            attr.value:='table-cell';
            Style.attributes.setNamedItem(attr);
            attr:=TRepODS(Main).fDoc.createAttribute('style:parent-style-name');
            attr.value:='Default';
            Style.attributes.setNamedItem(attr);

            CellProp:=TRepODS(Main).fDoc.createElement('style:table-cell-properties');
            attr:=TRepODS(Main).fDoc.createAttribute('fo:background-color');
            attr.value:=color;
            CellProp.attributes.setNamedItem(attr);
            Style.appendChild(CellProp);

            Styles.appendChild(Style);
            end;
        end else
            begin  //Если найдена ссылка на стиль то
            //проверить совпадение текущего цвета с требуемым
            StyleAttr:=OldCellStyle.selectSingleNode('style:table-cell-properties');
            if StyleAttr<>nil then
            value:=StyleAttr.attributes.getNamedItem('fo:background-color').nodeValue;
            if (value<>color) then //Если цвет не совпадает, тогда
                begin
                name:=value+'-colored'+copy(color,2,length(color)-1);
                if (Styles.selectSingleNode('.//style:style[@name = "'+name+'"]') = nil) then //Если стиля с таким именем нет, то
                    begin
                    ColoredCellStyle:=OldCellStyle.cloneNode(true); //создать копию стиля
                    attr:=TRepODS(Main).fDoc.createAttribute('style:name');
                    attr.value:=name;
                    ColoredCellStyle.attributes.setNamedItem(attr);

                    attr:=TRepODS(Main).fDoc.createAttribute('style:family');
                    attr.value:='table-cell';
                    ColoredCellStyle.attributes.setNamedItem(attr);

                    CellProp:=TRepODS(Main).fDoc.createElement('style:table-cell-properties');
                    attr:=TRepODS(Main).fDoc.createAttribute('fo:background-color');
                    attr.value:=color;
                    CellProp.attributes.setNamedItem(attr);

                    ColoredCellStyle.appendChild(Cellprop);
                    Styles.appendChild(ColoredCellStyle);
                    end;
                end;
            end;
     end else  //Если стиль ячейки указан, то
        begin
        val:=CellNode.attributes.getNamedItem('table:style-name').nodeValue; //определить название стиля
        OldCellStyle:=Styles.selectSingleNode('.//style:style[@style:name = "'+val+'"]');
        //проверить совпадение текущего цвета с требуемым
        StyleAttr:=OldCellStyle.selectSingleNode('style:table-cell-properties');
        if StyleAttr<>nil then
          begin
          prop:=StyleAttr.attributes.getNamedItem('fo:background-color');
          if prop<>nil then
             value:=prop.nodeValue;
          end;
        if (value<>color) then //Если цвет не совпадает, тогда
            begin
            name:=val+'-colored'+copy(color,2,length(color)-1); //Сформировать имя "перекрашенного" стиля
            if (Styles.selectSingleNode('.//style:style[@name = "'+name+'"]') = nil) then //Если стиля с таким именем нет, то
                begin
                ColoredCellStyle:=OldCellStyle.cloneNode(true); //создать копию стиля

                CellProp:=TRepODS(Main).fDoc.CreateElement('style:table-cell-properties');
                attr:=TRepODS(Main).fDoc.createAttribute('fo:background-color');
                attr.value:=color;
                CellProp.attributes.setNamedItem(attr);

                ColoredCellStyle.appendChild(CellProp);

                attr:=TRepODS(Main).fDoc.createAttribute('style:name');
                attr.value:=name;
                ColoredCellStyle.attributes.setNamedItem(attr);
                Styles.appendChild(ColoredCellStyle);
                end;
            end;
        end;

attr:=TRepODS(Main).fDoc.createAttribute('table:style-name');
attr.value:=name;
CellNode.attributes.setNamedItem(attr);
end;

procedure TCluster.InsertRows(numrow, rowcount: integer);
var
Row, NewRowNode: IXMLDOMNode;
i: Integer;
begin
Row := fRowList[numrow];

 for i := 0 to rowcount - 1 do
   begin
   //NewRowNode:=fRowList.item[numrow].cloneNode(true);
   NewRowNode:=Row.cloneNode(true);
   fEl.insertBefore(NewRowNode,fRowList.item[numrow]);
   end;
fRowList := fEl.SelectNodes('.//table:table-row');
end;

procedure TCluster.DeleteRow(numrow: integer);
begin
fRowList.item[numrow].parentNode.removeChild(fRowList.item[numrow]);
fRowList:=fEl.SelectNodes('table:table-row');
end;
//==============================================================================

procedure TRepODS.DeleteRow(numrow: Integer);
begin
fRowList.item[numrow].parentNode.removeChild(fRowList.item[numrow]);
fRowList:=fTab.SelectNodes('table:table-row');
end;

procedure TRepODS.InsertRows(numrow, rowcount: Integer);
var
NewRowNode: IXMLDOMNode;
i: Integer;
begin
 for i:=0 to rowcount - 1 do
   begin
   NewRowNode:=fRowList.item[numrow].cloneNode(true);
   fRowList.item[numrow].ParentNode.insertBefore(NewRowNode,fRowList.item[numrow]);
   end;
fRowList:=fTab.SelectNodes('.//table:table-row');
end;

procedure TRepODS.DeleteColumn(column: integer);
var
  i, j, a, ncs: Integer;
  cells: IXMLDOMNodeList; //Список ячеек ряда
  span: IXMLDomNode; //Атрибут с количеством склеенный ячеек
  autostyles, style: IXMLDomNode;
  table, col: IXMLDomNode;
begin
for i := 0 to fRowList.length - 1 do
    begin
    cells := fRowList.item[i].selectNodes('table:table-cell');
    a := 0;
    for j := 0 to Cells.length - 1 do
       begin
       span := cells.item[j].attributes.getNamedItem('table:number-columns-spanned');
       if span<>nil then ncs := span.nodeValue else ncs := 0;
       a := a + ncs + 1;
       if a >= column + 1 then
          begin
          if span = nil then
             fRowList.item[i].removeChild(cells.item[j]) else
             span.nodeValue := ncs - 1;
          break;
          end;
       end;
    end;
autostyles := fDoc.selectSingleNode('//office:automatic-styles');
style := autostyles.selectSingleNode('style:style[@style:family = "table-column"]['+inttostr(column+1)+']');
if style<>nil then
    autostyles.removeChild(style);
col := fTab.selectSingleNode('table:table-column['+inttostr(column+1)+']');
if col<>nil then
    fTab.removeChild(col);
end;

function MakeRowSel(rows: TIntarray): string;
var
i: Integer;
begin
if length(rows) = 0 then
    begin
    result:='';
    exit;
    end;
for i:=0 to Length(rows) - 2 do
   begin
   result := result +'(position() = '+inttostr(rows[i] + 1)+') or ';
   end;
   result:=result +'(position() = '+inttostr(rows[i] + 1)+')';
end;

procedure TRepODS.MakeCluster(rows: TIntArray);
var
Cluster: IXMLDOMElement;
attr: IXMLDOMAttribute;
NewNode: IXMLDOMNode;
row_list: IXMLDOMNodeList;
rowsel: string;
i: Integer;
N: integer;
begin
Cluster:=fDoc.createElement('reportcluster');
attr:=fDoc.createAttribute('id');
attr.value:=fclustercount;
inc(fclustercount);
Cluster.setAttributeNode(attr);
rowsel:=MakeRowSel(rows);
row_list:=fTab.selectNodes('.//table:table-row['+rowsel+']');
{for i:=0 to row_list.length - 1 do
//for i:=0 to row_list.length do
  begin
  NewNode:=row_list.item[i].cloneNode(true);
  Cluster.appendChild(NewNode);
  fTab.removeChild(row_list.item[i]);
  end;}
N := row_list.length;
for i := 0 to N - 1 do
  begin
  NewNode:=row_list.item[i].cloneNode(true);
  Cluster.appendChild(NewNode);
  fTab.removeChild(row_list.item[i]);
  end;

fTab.appendChild(Cluster);
Clusters.Add(TCluster.Create(Cluster, self));
end;

procedure TRepODS.DeleteCluster(id: integer);
var
cluster: IXMLDOMNode;
c: TCluster;
begin
cluster:=fd.selectSingleNode('.//reportcluster[@id = "'+inttostr(id)+'"]');
if cluster<>nil then
  begin
  Cluster.parentNode.removeChild(cluster);
  c:=Clusters.Items[id];
  Clusters.Remove(c);
  c.Free;
  end;
end;


procedure TRepODS.CloseClusters;
var
cluster_list: IXMLDOMnodelist;
i,j: Integer;
NewNode: IXMLDOMNode;
begin
if fClusters.Count = 0 then Exit;

 cluster_list:=fd.selectNodes('.//reportcluster');
 if (cluster_list = nil) or (cluster_list.length = 0) then exit;

 for i:= 0 to cluster_list.length - 1 do
   begin
   for j:=0 to cluster_list.item[i].childNodes.length - 1 do
      begin
      NewNode:=cluster_list.item[i].childNodes.item[j].cloneNode(true);
      cluster_list.item[i].parentNode.appendChild(NewNode);
      end;
   while not cluster_list.item[i].childNodes.length = 0 do
      cluster_list.item[i].removeChild(cluster_list.item[i].childNodes.item[0]);
   end;
   while not cluster_list.length = 0 do
      begin
      cluster_list.item[0].ParentNode.removeChild(cluster_list.item[0]);
      end;

for i := 0 to fClusters.Count - 1 do
    fClusters.Items[i].Free;

fclustercount:=0;
end;

procedure TRepODS.AddClusters(num: Integer; cluster_id: integer);
var
NewNode,Cluster: IXMLDOMNode;
attr: IXMLDOMAttribute;
i: Integer;
begin
Cluster:=fd.SelectSingleNode('.//reportcluster[@id = "'+floattostr(cluster_id)+'"]');
for i := 0 to num - 1 do
  begin
  NewNode:=Cluster.cloneNode(true);
  attr:=fDoc.createAttribute('id');
  attr.value:=fclustercount;
  inc(fclustercount);
  NewNode.attributes.setNamedItem(attr);
  Cluster.parentNode.appendChild(NewNode);
  Clusters.Add(TCluster.Create(NewNode, self));
  end;
end;

procedure TRepODS.CellColor(row: Integer; column: Integer; color: string);
var
Styles, OldCellStyle, ColoredCellStyle, Styleattr: IXMLDOMNode;
prop, CellNode, ColNode: IXMLDOMNode;
Style, CellProp: IXMLDOMElement;
val, value: OLEVariant;
name: string;
attr: IXMLDOMAttribute;
begin
Styles:=fD.selectSingleNode('.//office:automatic-styles');
CellNode:=fRowList[row].SelectSingleNode('table:table-cell['+inttostr(column+1)+']');

Styleattr:=CellNode.attributes.getNamedItem('table:style-name');
if (Styleattr = nil) then //Если в ячейке не указан стиль
//(CellNode.attributes.getNamedItem('table:style-name').nodeValue = 'Default') then //Или указан стиль по умолчанию, то
    begin
    ColNode:=fTab.selectSingleNode('.//table:table-column['+IntToStr(column)+']');  //найти колонку ячейки
    if ColNode<>nil then
    value:=ColNode.attributes.getNamedItem('table:default-cell-style-name').nodeValue;      //определить название стиля колонки
    OldCellStyle:=Styles.selectSingleNode('.//style[@name = "'+value+'"]');    //получить ссылку на узел стиля ячеек колонки по умолчанию
    if OldCellStyle = nil then  //если узел не найден
        begin
        name:='ce-colored'+copy(color,2,length(color)-1);

        if (Styles.selectSingleNode('.//style[@name = "'+name+'"]') = nil) then //Если стиля с таким именем нет, то
            begin
            Style:=fDoc.createElement('style:style'); //создать новый стиль
            attr:=fDoc.createAttribute('style:name');
            attr.value:=name;
            Style.attributes.setNamedItem(attr);
            attr:=fDoc.createAttribute('style:family');
            attr.value:='table-cell';
            Style.attributes.setNamedItem(attr);
            attr:=fDoc.createAttribute('style:parent-style-name');
            attr.value:='Default';
            Style.attributes.setNamedItem(attr);

            CellProp:=fDoc.createElement('style:table-cell-properties');
            attr:=fDoc.createAttribute('fo:background-color');
            attr.value:=color;
            CellProp.attributes.setNamedItem(attr);
            Style.appendChild(CellProp);

            Styles.appendChild(Style);
            end;
        end;
    end else
        begin
        val:=CellNode.attributes.getNamedItem('table:style-name').nodeValue; //определить название стиля
        OldCellStyle:=Styles.selectSingleNode('.//style:style[@style:name = "'+val+'"]');

        if OldCellStyle<>nil then
        //проверить совпадение текущего цвета с требуемым
        StyleAttr:=OldCellStyle.selectSingleNode('.//style:table-cell-properties')
        else exit;
        if StyleAttr<>nil then
          begin
          prop:=StyleAttr.attributes.getNamedItem('fo:background-color');
          if prop<>nil then
             value:=prop.nodeValue;
          end;
        if (value<>color) then //Если цвет не совпадает, тогда
            begin
            name:=val+'-colored'+copy(color,2,length(color)-1); //Сформировать имя "перекрашенного" стиля
            if (Styles.selectSingleNode('.//style:style[@style:name = "'+name+'"]') = nil) then //Если стиля с таким именем нет, то
                begin
                ColoredCellStyle:=OldCellStyle.cloneNode(true); //создать копию стиля

                CellProp:=fDoc.CreateElement('style:table-cell-properties');
                attr:=fDoc.createAttribute('fo:background-color');
                attr.value:=color;
                CellProp.attributes.setNamedItem(attr);

                ColoredCellStyle.appendChild(CellProp);

                attr:=fDoc.createAttribute('style:name');
                attr.value:=name;
                ColoredCellStyle.attributes.setNamedItem(attr);
                Styles.appendChild(ColoredCellStyle);
                end;
            end;
        end;

attr:=fDoc.createAttribute('table:style-name');
attr.value:=name;
CellNode.attributes.setNamedItem(attr);
end;

procedure TRepODS.ExtendRows;
var
tabl, newrow: IXMLDOMNode;
i,j, count: Integer;
list: IXMLDOMNodeList;
begin
list:=fTab.selectNodes('table:table-row[@table:number-rows-repeated]');
if list<>nil then
for i := 0 to List.Length - 1 do
  begin
  tabl:=list.item[0].parentNode;
    count:=list.item[i].attributes.getNamedItem('table:number-rows-repeated').nodeValue;
    list.item[i].attributes.removeNamedItem('table:number-rows-repeated');
    if count>=2 then
    for j := 0 to Count - 2 do
      begin
      newrow:=list.item[i].cloneNode(true);
      tabl.insertBefore(newrow,list.item[i]);
      end;
  end;
end;

procedure TRepODS.ExtendCells;
var
row, newcell: IXMLDOMNode;
i,j, count: Integer;
list: IXMLDOMNodeList;
begin
list:=fTab.selectNodes('table:table-row/table:table-cell[@table:number-columns-repeated]');
if list<>nil then
for i := 0 to List.Length - 1 do
begin
  count:=list.item[i].attributes.getNamedItem('table:number-columns-repeated').nodeValue;
  list.item[i].attributes.removeNamedItem('table:number-columns-repeated');
  row:=list.item[i].parentNode;
  if count>=2 then
  for j := 0 to Count - 2 do
     begin
     newcell:=list.item[i].cloneNode(true);
     row.insertBefore(newcell,list.item[i]);
     end;
end;
end;

function TRepODS.GetColCount: integer;
var
cnt, spanned: integer;
lst: IXMLDOMNodeList;
attr: IXMLDOMNode;
i: integer;
begin
result := 0;
cnt := 0;
lst := fRowList.item[0].selectNodes('./table:table-cell');
if lst <> nil then
    begin
    for i := 0 to lst.length - 1 do
       begin
       attr := lst[i].attributes.getNamedItem('table:number-columns-spanned');
       if attr <> nil then
          spanned := attr.nodeValue else spanned := 1;

       cnt := cnt + spanned;
       end;
    result := cnt;
    end;
end;

procedure TRepODS.InsertMetkaPicture(metka, fname: string; width,
  height: integer);
var
DocManifest: IXMLDOMDocument3;
MainElMan: IXMLDOMElement;
ElMan: IXMLDOMElement;
ManAttr: IXMLDOMAttribute;
ext, img, xlink: string;
attr: IXMLDOMAttribute;

list: IXMLDOMNodeList;
n, Styles, el, el2, el3: IXMLDOMNode;
a: IXMLDOMAttribute;
i: Integer;
begin
 list:=fTab.selectNodes('.//text:*[text() = "'+metka+'"]');

 if List.length > 0 then
    begin
    if not DirectoryExists(ExtractFileDir(fReportPath)+'\Pictures') then
      ForceDirectories(ExtractFileDir(fReportPath)+'\Pictures');
    CopyFile(PChar(fname), PChar(ExtractFileDir(fReportPath)+'\Pictures\'+ExtractFileName(fname)), false);

    Styles := fDoc.selectSingleNode('.//office:automatic-styles');
    n := Styles.selectSingleNode('.//style:style[@name = "inserted_graph"]');

    if n = nil then
    begin

    //Формирование графического стиля
    el := fDoc.createElement('style:style');

    a := fDoc.createAttribute('style:name');
    a.value := 'inserted_graph';
    el.attributes.setNamedItem(a);

    a := fDoc.createAttribute('style:family');
    a.value := 'graphic';
    el.attributes.setNamedItem(a);

    el2 := fDoc.createElement('style:graphic-properties');
    a := fDoc.createAttribute('draw:stroke');
    a.value := 'none';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:fill');
    a.value := 'none';
    el.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:textarea-horizontal-align');
    a.value := 'center';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:textarea-vertical-align');
    a.value := 'middle';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:color-mode');
    a.value := 'standard';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:luminance');
    a.value := '0%';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:contrast');
    a.value := '0%';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:gamma');
    a.value := '100%';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:red');
    a.value := '0%';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:green');
    a.value := '0%';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:blue');
    a.value := '0%';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('fo:clip');
    a.value := 'rect(0in, 0in, 0in, 0in)';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:image-opacity');
    a.value := '100%';
    el2.attributes.setNamedItem(a);

    a := fDoc.createAttribute('style:mirror');
    a.value := 'none';
    el2.attributes.setNamedItem(a);

    el.appendChild(el2);
    //---------------------
    Styles.appendChild(el);
    end;

 for i := 0 to List.length - 1 do
    begin

    //Объявление картинки в манифесте
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

    el := fDoc.createElement('draw:frame');

    a := fDoc.createAttribute('draw:name');
    a.value := fname + floattostr(i);
    el.attributes.setNamedItem(a);

    a := fDoc.createAttribute('draw:style-name');
    a.value := 'inserted_graph';
    el.attributes.setNamedItem(a);

    a := fDoc.createAttribute('svg:width');
    a.value := floattostr(width)+'cm';
    el.attributes.setNamedItem(a);

    a := fDoc.createAttribute('svg:height');
    a.value := floattostr(height)+'cm';
    el.attributes.setNamedItem(a);

    a := fDoc.createAttribute('svg:x');
    a.value := '0cm';
    el.attributes.setNamedItem(a);

    a := fDoc.createAttribute('svg:y');
    a.value := '0cm';
    el.attributes.setNamedItem(a);

        el2 := fDoc.createElement('draw:image');

        a := fDoc.createAttribute('xlink:href');
        a.value := 'Pictures/'+ExtractFileName(fname);
        el2.attributes.setNamedItem(a);

        a := fDoc.createAttribute('xlink:type');
        a.value := 'simple';
        el2.attributes.setNamedItem(a);

        a := fDoc.createAttribute('xlink:show');
        a.value := 'embed';
        el2.attributes.setNamedItem(a);

        a := fDoc.createAttribute('xlink:actuate');
        a.value := 'onLoad';
        el2.attributes.setNamedItem(a);
    el.appendChild(el2);

    list.item[i].parentNode.replaceChild(el, list.item[i]);
    end;

    end;


{<style:style style:name="inserted_graph" style:family="graphic">
<style:graphic-properties draw:stroke="none" draw:fill="none" draw:textarea-horizontal-align="center" draw:textarea-vertical-align="middle" draw:color-mode="standard" draw:luminance="0%" draw:contrast="0%" draw:gamma="100%" draw:red="0%" draw:green="0%" draw:blue="0%" fo:clip="rect(0in, 0in, 0in, 0in)" draw:image-opacity="100%" style:mirror="none"/>
</style:style>}

{<draw:frame table:end-cell-address="Лист1.B5" table:end-x="0.5154in" table:end-y="0.1555in" draw:z-index="0" draw:name="Изображения 1" draw:style-name="gr1" draw:text-style-name="P1" svg:width="1.7232in" svg:height="0.9205in" svg:x="0in" svg:y="0in">
<draw:image xlink:href="Pictures/10000201000002270000016E379D735F.png" xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad">
<text:p/>
</draw:image>
</draw:frame>}
end;

procedure TRepODS.InsertNumber(number: Real; numrow: Integer; numcol: Integer);
var
cell: IXMLDOMNode;
el: IXMLDOMElement;
attr: IXMLDOMAttribute;
txt: IXMLDOMText;
//list: IXMLDOMNodeList;
begin
cell:=fRowList[numrow].SelectSingleNode('table:table-cell['+inttostr(numcol+1)+']');

attr:=fDoc.createAttribute('office:value-type');
attr.value:='float';
cell.attributes.setNamedItem(attr);

attr:=fDoc.createAttribute('office:value');
attr.value:=number;
cell.attributes.setNamedItem(attr);

el:=fDoc.createElement('text:p');
txt:=fDoc.createTextNode(floattostr(number));
el.appendChild(txt);
cell.appendChild(el);
end;

procedure TRepODS.InsertString(text: string; numrow: Integer; numcol: Integer);
var
cell: IXMLDOMNode;
el: IXMLDOMElement;
attr: IXMLDOMAttribute;
txt: IXMLDOMText;
begin
cell:=fRowList[numrow].SelectSingleNode('table:table-cell['+inttostr(numcol+1)+']');

attr:=fDoc.createAttribute('office:value-type');
attr.value:='string';
cell.attributes.setNamedItem(attr);

el:=fDoc.createElement('text:p');
txt:=fDoc.createTextNode(text);
el.appendChild(txt);
cell.appendChild(el);
end;

constructor TRepODS.Create(shablon: string; reppath: string);
begin
inherited Create(nil);
fShablon:=shablon;
fReportPath:=reppath;
fClusters:=TClusters.Create;
end;

destructor TRepODS.Destroy;
begin
fClusters.free;
inherited;
end;

procedure TRepODS.ExecRep;
var
shExecInfo: PShellExecuteInfo;
begin
  ShellExecute(Application.Handle, 'open', PChar(ExtractFileName(fReportPath)), nil, pChar(ExtractFileDir(fReportPath)), SW_RESTORE);
end;

procedure TRepODS.Open(tab: string);
var
zm: TZipMaster19;
s: AnsiString;
fcoDoc: CoDOMDocument60;
begin
fclustercount:=0;

  if not DirectoryExists(ExtractFileDir(fReportPath)) then
    CreateDirectory(pchar(ExtractFileDir(fReportPath)),nil);

  if not copyfile(PChar(fShablon), PChar(fReportPath), false) then
  raise Exception.Create('Report is using');


  if fileexists(fReportPath+'\content.xml') then deletefile(fReportPath+'\content.xml');

  zm:=TZipMaster19.Create(nil);
  zm.DLL_Load := true;
  zm.ZipFileName:=fReportPath;
  zm.ExtrOptions:=[ExtrOverWrite];
  zm.ExtrBaseDir:=ExtractFileDir(fReportPath);
  zm.FSpecArgs.Clear;
  zm.FSpecArgs.Add('content.xml');
  zm.Extract;
  zm.Free;

  fDoc:=CoDOMDocument60.Create;
  fDoc.setProperty('SelectionNamespaces','xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" '+
  'xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" '+
  'xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" '+
  'xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" '+
  'xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" '+
  'xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" '+
  'xmlns:xlink="http://www.w3.org/1999/xlink" '+
  'xmlns:dc="http://purl.org/dc/elements/1.1/" '+
  'xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" '+
  'xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" '+
  'xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0" '+
  'xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" '+
  'xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" '+
  'xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" '+
  'xmlns:math="http://www.w3.org/1998/Math/MathML" '+
  'xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" '+
  'xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" '+
  'xmlns:ooo="http://openoffice.org/2004/office" '+
  'xmlns:ooow="http://openoffice.org/2004/writer" '+
  'xmlns:oooc="http://openoffice.org/2004/calc" '+
  'xmlns:dom="http://www.w3.org/2001/xml-events" '+
  'xmlns:xforms="http://www.w3.org/2002/xforms" '+
  'xmlns:xsd="http://www.w3.org/2001/XMLSchema" '+
  'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '+
  'xmlns:rpt="http://openoffice.org/2005/report" '+
  'xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" '+
  'xmlns:rdfa="http://docs.oasis-open.org/opendocument/meta/rdfa#"');
  fDoc.load(ExtractFileDir(fReportPath)+'\content.xml');
  s:=fDoc.xml;
  fD:=fDoc.Get_documentElement;


  fTab:=fD.SelectSingleNode('office:body/office:spreadsheet/table:table[@table:name = "'+tab+'"]');
  if fTab = nil then
  raise Exception.Create('Error in table name (Opening report)');

  ExtendRows;
  ExtendCells;

  fRowList:=fTab.selectNodes('table:table-row');
end;

procedure TRepODS.FindAndReplace(metka: string; text: string);
var
list: IXMLDOMNodeList;
i: Integer;
begin
 list:=fTab.selectNodes('.//text:*[text() = "'+metka+'"]');
 for i := 0 to List.length - 1 do
    begin
    list.item[i].text:=text;
    end;
end;

procedure TRepODS.Close;
var
zm: TZipMaster19;
begin
CloseClusters;
fDoc.save(ExtractFileDir(fReportPath)+'\content.xml');

zm:=TZipMaster19.Create(nil);
zm.DLL_Load := true;
zm.AddOptions:=[AddDirNames];
zm.ZipFileName:=fReportPath;
zm.FSpecArgs.Clear;
zm.RootDir:=ExtractFileDir(fReportPath);
zm.AddCompLevel := 5; //ВАЖНО! При неправильном выборе компрессии опенофис считает документ поврежденным!


if DirectoryExists(fReportPath+'\Pictures') then
  begin
  zm.FSpecArgs.Add('>Pictures\*.jpg');
  zm.FSpecArgs.Add('>Pictures\*.png');
  zm.FSpecArgs.Add('>Pictures\*.gif');
  zm.FSpecArgs.Add('>Pictures\*.bmp');
  end;
zm.FSpecArgs.Add('|content.xml');
zm.Add;
zm.Free;

if fileexists(ExtractFileDir(fReportPath)+'\content.xml') then
deletefile(ExtractFileDir(fReportPath)+'\content.xml');
if DirectoryExists(ExtractFileDir(fReportPath)+'\Pictures') then

MyRemoveDir(ExtractFileDir(fReportPath)+'\Pictures');
end;

end.
