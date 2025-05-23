unit MyWord;

interface



const
wdBorderTop=-1;
wdBorderLeft=-2;
wdBorderBottom=-3;
wdBorderRight=-4;

wdLineStyleNone=0;
wdLineStyleSingle=1;
wdLineStyleDot=2;
wdLineStyleDashSmallGap=3;
wdLineStyleDashLargeGap=4;
wdLineStyleDashDot=5;
wdLineStyleDashDotDot=6;
wdLineStyleDouble=7;
wdLineStyleTriple=8;
wdLineStyleThinThickSmallGap=9;
wdLineStyleThickThinSmallGap=10;
wdLineStyleThinThickThinSmallGap=11;
wdLineStyleThinThickMedGap=12;
wdLineStyleThickThinMedGap=13;
wdLineStyleThinThickThinMedGap=14;
wdLineStyleThinThickLargeGap=15;
wdLineStyleThickThinLargeGap=16;
wdLineStyleThinThickThinLargeGap=17;
wdLineStyleSingleWavy=18;
wdLineStyleDoubleWavy=19;
wdLineStyleDashDotStroked=20;
wdLineStyleEmboss3D=21;
wdLineStyleEngrave3D=22;


Function CreateWord:boolean;
Function VisibleWord(visible:boolean):boolean;
Function AddDoc:boolean;
Function SetTextToDoc(text_:string ;InsertAfter_:boolean):boolean;
Function SaveDocAs(file_:string):boolean;
Function SaveDocAsUnicod(file_:string):boolean;
Function SaveDocAsText(file_:string):boolean;
Function SaveDocAsDosText(file_:string):boolean;
Function CloseDoc:boolean;
Function CloseWord:boolean;
Function OpenDoc(file_:string):boolean;
Function StartOfDoc:boolean;
Function FindTextDoc(text_:string):boolean;
Function PasteTextDoc(text_:string):boolean;
Function TypeTextDoc(text_:string):boolean;
Function FindAndPasteTextDoc(findtext_,pastetext_:string):boolean;
Function PrintDialogWord:boolean;
Function CreateTable(NumRows, NumColumns:integer;var index:integer):boolean;
Function SetSizeTable(Table:integer;RowsHeight, ColumnsWidth:real):boolean;
Function GetSizeTable(Table:integer;var RowsHeight,ColumnsWidth:real):boolean;
Function SetHeightRowTable(Table,Row:integer;RowHeight:real):boolean;
Function SetWidthColumnTable(Table,Column:integer;ColumnWidth:real):boolean;
Function SetTextToTable(Table:integer;Row,Column:integer;text:string):boolean;
Function SetLineStyleBorderTable(Table:integer;Row,Column,wdBorderType,wdBorderStyle:integer):boolean;
Function SetMergeCellsTable(Table:integer;Row1,Column1,Row2,Column2:integer):boolean;

Function GetSelectionTable:boolean;
Function GoToNextTable (table_:integer):boolean;
Function GoToPreviousTable (table_:integer):boolean;
Function GetColumnsRowsTable(table_:integer; var Columns,Rows:integer):boolean;
Function GetColumnRowTable(table_:integer; var Column,Row:integer):boolean;
Function AddRowTableDoc (table_:integer):boolean;
Function InsertRowsTableDoc(table_,position_,count_:integer):boolean;
Function InsertRowTableDoc(table_,position_:integer):boolean;


//------------------------------- TextBox ---------------------------------
Function CreateTextBox(Left,Top,Width,Height:real;var name:string):boolean;
Function TextToTextBox(TextBox:variant;text:string):boolean;

//------------------------------- ����� -----------------------------------
Function CreateLine(BeginX,BeginY,EndX,EndY:real;var name:string):boolean;

//------------------------------- ������� ������� -------------------------
Function CreatePicture(FileName:string;Left,Top:real;var name:string):boolean;

//------------------------------- ����� ��� ����� ������� -----------------
Function DeleteShape (NameShape:variant): variant;
Function SetNewNameShape(NameShape:variant;NewNameShape:string):string;
Function GetNameIndexShape(NameIndex:variant):string;




implementation

uses ComObj;
 var W:variant;

Function CreateWord:boolean;
begin
CreateWord:=true;
try
W:=CreateOleObject('Word.Application');
except
CreateWord:=false;
end;
End;


Function VisibleWord(visible:boolean):boolean;
begin
VisibleWord:=true;
try
W.visible:= visible;
except
VisibleWord:=false;
end;
End;


Function AddDoc:boolean;
 Var Doc_:variant;
begin
AddDoc:=true;
try
Doc_:=W.Documents;
Doc_.Add;
except
AddDoc:=false;
end;
End;



Function SetTextToDoc(text_:string ;InsertAfter_:boolean):boolean;
 var Rng_:variant;
begin
SetTextToDoc:=true;
try
Rng_:=W.ActiveDocument.Range;
if InsertAfter_ then Rng_.InsertAfter(text_) else Rng_.InsertBefore(text_);
except
SetTextToDoc:=false;
end;
End;



Function SaveDocAs(file_:string):boolean;
begin
SaveDocAs:=true;
try
W.ActiveDocument.SaveAs(file_);
except
SaveDocAs:=false;
end;
End;


Function SaveDocAsUnicod(file_:string):boolean;
 const wdFormatUnicodeText=7;
begin
SaveDocAsUnicod:=true;
try
W.ActiveDocument.SaveAs(file_,FileFormat:=wdFormatUnicodeText);
except
SaveDocAsUnicod:=false;
end;
End;


Function SaveDocAsText(file_:string):boolean;
 const  wdFormatText=2;
begin
SaveDocAsText:=true;
try
W.ActiveDocument.SaveAs(file_,FileFormat:= wdFormatText);
except
SaveDocAsText:=false;
end;
End;


Function SaveDocAsDosText(file_:string):boolean;
 const  wdFormatDOSText=4;
begin
SaveDocAsDosText:=true;
try
W.ActiveDocument.SaveAs(file_,FileFormat:= wdFormatDOSText);
except
SaveDocAsDosText:=false;
end;
End;


Function CloseDoc:boolean;
begin
CloseDoc:=true;
try
W.ActiveDocument.Close;
except
CloseDoc:=false;
end;
End;


Function CloseWord:boolean;
begin
CloseWord:=true;
try
W.Quit;
except
CloseWord:=false;
end;
End;


Function OpenDoc(file_:string):boolean;
 Var Doc_:variant;
begin
OpenDoc:=true;
try
Doc_:=W.Documents;
Doc_.Open(file_);
except
OpenDoc:=false;
end;
End;


Function StartOfDoc:boolean;
begin
StartOfDoc:=true;
try
W.Selection.End:=0;
W.Selection.Start:=0;
except
StartOfDoc:=false;
end;
End;




Function FindTextDoc(text_:string):boolean;
begin
FindTextDoc:=true;
Try
W.Selection.Find.Forward:=true;
W.Selection.Find.Text:=text_;
FindTextDoc := W.Selection.Find.Execute;
except
FindTextDoc:=false;
end;
End;



Function PasteTextDoc(text_:string):boolean;
begin
PasteTextDoc:=true;
Try
W.Selection.Delete;
W.Selection.InsertAfter (text_);
except
PasteTextDoc:=false;
end;
End;


Function TypeTextDoc(text_:string):boolean;
begin
TypeTextDoc:=true;
Try
W.Selection.Delete;
W.Selection.TypeText(text_);
except
TypeTextDoc:=false;
end;
End;



Function FindAndPasteTextDoc(findtext_,pastetext_:string):boolean;
begin
FindAndPasteTextDoc:=true;
try
W.Selection.Find.Forward:=true;
W.Selection.Find.Text:= findtext_;
if W.Selection.Find.Execute then begin
W.Selection.Delete;
W.Selection.InsertAfter (pastetext_);
end else FindAndPasteTextDoc:=false;
except
FindAndPasteTextDoc:=false;
end;
End;



Function PrintDialogWord:boolean;
 Const wdDialogFilePrint=88;
begin
PrintDialogWord:=true;
try
W.Dialogs.Item(wdDialogFilePrint).Show;
except
PrintDialogWord:=false;
end;
End;


//----------- �������  --------------------------------------------------
Function CreateTable(NumRows, NumColumns:integer;var index:integer):boolean;
 var sel_:variant;
begin
CreateTable:=true;
try
sel_:=W.selection;
W.ActiveDocument.Tables.Add(Range:=sel_.Range, NumRows:=NumRows, NumColumns:=NumColumns);
index:=W.ActiveDocument.Tables.Count;
except
CreateTable:=false;
end;
End;



Function SetSizeTable(Table:integer;RowsHeight, ColumnsWidth:real):boolean;
begin
SetSizeTable:=true;
try
W.ActiveDocument.Tables.Item(Table).Columns.Width:=ColumnsWidth;
W.ActiveDocument.Tables.Item(Table).Rows.Height:=RowsHeight;
except
SetSizeTable:=false;
end;
End;



Function GetSizeTable(Table:integer;var RowsHeight,ColumnsWidth:real):boolean;
begin
GetSizeTable:=true;
try
ColumnsWidth:=W.ActiveDocument.Tables.Item(Table).Columns.Width;
RowsHeight:=W.ActiveDocument.Tables.Item(Table).Rows.Height;
except
GetSizeTable:=false;
end;
End;




Function SetHeightRowTable(Table,Row:integer;RowHeight:real):boolean;
begin
SetHeightRowTable:=true;
try
W.ActiveDocument.Tables.Item(Table).Rows.item(Row).Height:=RowHeight;
except
SetHeightRowTable:=false;
end;
End;




Function SetWidthColumnTable(Table,Column:integer;ColumnWidth:real):boolean;
begin
SetWidthColumnTable:=true;
try
W.ActiveDocument.Tables.Item(Table).Columns.Item(Column).Width:=ColumnWidth;
except
SetWidthColumnTable:=false;
end;
End;




Function SetTextToTable(Table:integer;Row,Column:integer;text:string):boolean;
begin
SetTextToTable:=true;
try
W.ActiveDocument.Tables.Item(Table).Columns.Item(Column).Cells.Item(Row).Range.Text:=text;
except
SetTextToTable:=false;
end;
End;



Function SetLineStyleBorderTable(Table:integer;Row,Column,wdBorderType,wdBorderStyle:integer):boolean;
begin
SetLineStyleBorderTable:=true;
try
W.ActiveDocument.Tables.Item(Table).Columns.Item(Column).Cells.Item(Row).Borders.Item(wdBorderType).LineStyle:=wdBorderStyle;
except
SetLineStyleBorderTable:=false;
end;
End;


Function SetMergeCellsTable(Table:integer;Row1,Column1,Row2,Column2:integer):boolean;
 var cel_:variant;
begin
SetMergeCellsTable:=true;
try
cel_:=W.ActiveDocument.Tables.Item(Table).Cell(Row2,Column2);
W.ActiveDocument.Tables.Item(Table).Cell(Row1,Column1).Merge(cel_);
except
SetMergeCellsTable:=false;
end;
End;


Function GetSelectionTable:boolean;
  const wdWithInTable=12;
begin
try
GetSelectionTable :=W.Selection.Information[wdWithInTable];
except
GetSelectionTable :=false;
end;
End;



Function GoToNextTable (table_:integer):boolean;
 const wdGoToTable=2;
begin
 GoToNextTable:=true;
 try
   W.Selection.GoToNext (wdGoToTable);
 except
 GoToNextTable:=false;
 end;
End;


Function GoToPreviousTable (table_:integer):boolean;
 const wdGoToTable=2;
begin
 GoToPreviousTable:=true;
 try
   W.Selection.GoToPrevious(wdGoToTable);
 except
 GoToPreviousTable:=false;
 end;
End;



Function GetColumnsRowsTable(table_:integer; var Columns,Rows:integer):boolean;
 const
    wdMaximumNumberOfColumns=18;
    wdMaximumNumberOfRows=15;
begin
GetColumnsRowsTable:=true;
try
Columns:=W.Selection.Information[wdMaximumNumberOfColumns];
Rows:=W.Selection.Information[wdMaximumNumberOfRows];
except
GetColumnsRowsTable:=false;
end;
End;



Function GetColumnRowTable(table_:integer; var Column,Row:integer):boolean;
 const
   wdStartOfRangeColumnNumber=16;
   wdStartOfRangeRowNumber=13;
begin
GetColumnRowTable:=true;
try
Column:=W.Selection.Information[wdStartOfRangeColumnNumber];
Row:=W.Selection.Information[wdStartOfRangeRowNumber];
except
GetColumnRowTable:=false;
end;
End;



Function AddRowTableDoc (table_:integer):boolean;
begin
 AddRowTableDoc:=true;
 try
   W.ActiveDocument.Tables.Item(table_).Rows.Add;
 except
 AddRowTableDoc:=false;
 end;
End;



Function InsertRowsTableDoc(table_,position_,count_:integer):boolean;
begin
 InsertRowsTableDoc:=true;
 try
  W.ActiveDocument.Tables.Item(table_).Rows.Item(position_).Select;
  W.Selection.InsertRows (count_);
 except
 InsertRowsTableDoc:=false;
 end;
End;



Function InsertRowTableDoc(table_,position_:integer):boolean;
 var row_:variant;
begin
 InsertRowTableDoc:=true;
 try
 row_:=W.ActiveDocument.Tables.Item(table_).Rows.Item(position_);
 W.ActiveDocument.Tables.Item(table_).Rows.Add(row_);
 except
 InsertRowTableDoc:=false;
 end;
End;



//------------------------------ TextBox ----------------------------------
Function CreateTextBox(Left,Top,Width,Height:real;var name:string):boolean;
 const msoTextOrientationHorizontal=1;
begin
CreateTextBox:=true;
try
name:=W.ActiveDocument.Shapes.AddTextbox(msoTextOrientationHorizontal,Left,Top,Width,Height).Name;
except
CreateTextBox:=false;
end;
End;


Function TextToTextBox(TextBox:variant;text:string):boolean;
 const msoTextBox=17;
begin
TextToTextBox:=true;
try
if w.ActiveDocument.Shapes.Item(TextBox).Type = msoTextBox then
   W.ActiveDocument.Shapes.Item(TextBox).TextFrame.TextRange.Text:=Text
   else TextToTextBox:=false;
except
TextToTextBox:=false;
end;
End;



Function CreateLine(BeginX,BeginY,EndX,EndY:real;var name:string):boolean;
begin
CreateLine:=true;
try
name:=W.ActiveDocument.Shapes.AddLine(BeginX,BeginY,EndX,EndY).Name;
except
CreateLine:=false;
end;
End;


Function CreatePicture(FileName:string;Left,Top:real;var name:string):boolean;
begin
CreatePicture:=true;
try
name:=W.ActiveDocument.Shapes.AddPicture(FileName).Name;
W.ActiveDocument.Shapes.Item(name).Left:=Left;
W.ActiveDocument.Shapes.Item(name).Top:=Top;
except
CreatePicture:=false;
end;
End;




Function GetNameIndexShape(NameIndex:variant):string;
begin
try
GetNameIndexShape:=W.ActiveDocument.Shapes.Item(NameIndex).Name;
except
GetNameIndexShape:='';
end;
End;



Function SetNewNameShape(NameShape:variant;NewNameShape:string):string;
begin
try
W.ActiveDocument.Shapes.Item(NameShape).Name:=NewNameShape;
SetNewNameShape:=NewNameShape;
except
SetNewNameShape:='';
end;
End;


Function DeleteShape (NameShape:variant): variant;
Begin
DeleteShape:=true;
try
W.ActiveDocument.Shapes.Item(NameShape).Delete;
except
DeleteShape:=false;
end;
End;




end.
