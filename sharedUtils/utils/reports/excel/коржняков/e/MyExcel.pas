unit MyExcel;

interface
  uses Classes,Graphics;

const
//------ ������������ �� ����������� -------------------
xlHAlignCenter=-4108;
xlHAlignDistributed=-4117;
xlHAlignJustify=-4130;
xlHAlignLeft=-4131;
xlHAlignRight=-4152;
xlHAlignCenterAcrossSelection=7;
xlHAlignFill=5;
xlHAlignGeneral=1;


//------ ������������ �� ��������� -------------------
xlVAlignBottom=-4107;
xlVAlignCenter=-4108;
xlVAlignDistributed=-4117;
xlVAlignJustify=-4130;
xlVAlignTop=-4160;


//------- ������ ������������� ������ -----------------
xlUnderlineStyleNone = -4142;
xlUnderlineStyleSingle = 2;
xlUnderlineStyleDouble = -4119;
xlUnderlineStyleSingleAccounting = 4;
xlUnderlineStyleDoubleAccounting = 5;


//------- ����� ������� ������ -----------------
xlInsideHorizontal=12;
xlInsideVertical=11;
xlDiagonalDown=5;
xlDiagonalUp=6;
xlEdgeBottom=9;
xlEdgeLeft=7;
xlEdgeRight=10;
xlEdgeTop=8;


//------- ����� ������� ������ -----------------
xlContinuous=1;
xlDash=-4115;
xlDashDot=4;
xlDashDotDot=5;
xlDot=-4118;
xlDouble=-4119;
xlSlantDashDot=13;
xlLineStyleNone=-4142;


//------- ������� ������� ������ -----------------
xlHairline=1;
xlThin=2;
xlMedium=-4138;
xlThick=4;


//---------- ��� ����� ��� ������ ----------------
xlPatternAutomatic=4105;
xlPatternChecker=9;
xlPatternCrissCross=16;
xlPatternDown=-4121;
xlPatternGray16=17;
xlPatternGray25=-4124;
xlPatternGray50=-4125;
xlPatternGray75=-4126;
xlPatternGray8=18;
xlPatternGrid=15;
xlPatternHorizontal=-4128;
xlPatternLightDown=13;
xlPatternLightHorizontal=11;
xlPatternLightUp=14;
xlPatternLightVertical=12;
xlPatternNone=-4142;
xlPatternSemiGray75=10;
xlPatternSolid=1;
xlPatternUp=-4162;
xlPatternVertical=-4166;



//---------- ������� ----------------
// ������
xlDialogPrint=8;
xlDialogPrinterSetup=9;
xlDialogPrintPreview=222;

//---------- ���������� ������ ------
xlLandscape=2;       // ���������
xlPortrait=1;        // �������

//---------- ������ ������ ----------
xlPaperLetter=1;               //Letter (8-1/2 in. x 11 in.)
xlPaperLetterSmall= 2;         //Letter Small (8-1/2 in. x 11 in.)
xlPaperTabloid= 3;             //Tabloid (11 in. x 17 in.)
xlPaperLedger= 4;              //Ledger (17 in. x 11 in.)
xlPaperLegal= 5;               //Legal (8-1/2 in. x 14 in.)
xlPaperStatement= 6;           //Statement (5-1/2 in. x 8-1/2 in.)
xlPaperExecutive= 7;           //Executive (7-1/2 in. x 10-1/2 in.)
xlPaperA3= 8;                  //A3 (297 mm x 420 mm)
xlPaperA4= 9;                  //A4 (210 mm x 297 mm)
xlPaperA4Small= 10;            //A4 Small (210 mm x 297 mm)
xlPaperA5= 11;                 //A5 (148 mm x 210 mm)
xlPaperB4= 12;                 //B4 (250 mm x 354 mm)
xlPaperB5= 13;                 //B5 (182 mm x 257 mm)
xlPaperFolio= 14;              //Folio (8-1/2 in. x 13 in.)
xlPaperQuarto= 15;             //Quarto (215 mm x 275 mm)
xlPaper10x14= 16;              //10 in. x 14 in.
xlPaper11x17= 17;              //11 in. x 17 in.
xlPaperNote= 18;               //Note (8-1/2 in. x 11 in.)
xlPaperEnvelope9= 19;          //Envelope #9 (3-7/8 in. x 8-7/8 in.)
xlPaperEnvelope10= 20;         //Envelope #10 (4-1/8 in. x 9-1/2 in.)
xlPaperEnvelope11= 21;         //Envelope #11 (4-1/2 in. x 10-3/8 in.)
xlPaperEnvelope12= 22;         //Envelope #12 (4-1/2 in. x 11 in.)
xlPaperEnvelope14= 23;         //Envelope #14 (5 in. x 11-1/2 in.)
xlPaperCsheet= 24;             //C size sheet
xlPaperDsheet= 25;             //D size sheet
xlPaperEsheet= 26;             //E size sheet
xlPaperEnvelopeDL= 27;         //Envelope DL (110 mm x 220 mm)
xlPaperEnvelopeC3= 29;         //Envelope C3 (324 mm x 458 mm)
xlPaperEnvelopeC4= 30;         //Envelope C4 (229 mm x 324 mm)
xlPaperEnvelopeC5= 28;         //Envelope C5 (162 mm x 229 mm)
xlPaperEnvelopeC6= 31;         //Envelope C6 (114 mm x 162 mm)
xlPaperEnvelopeC65= 32;        //Envelope C65 (114 mm x 229 mm)
xlPaperEnvelopeB4= 33;         //Envelope B4 (250 mm x 353 mm)
xlPaperEnvelopeB5= 34;         //Envelope B5 (176 mm x 250 mm)
xlPaperEnvelopeB6= 35;         //Envelope B6 (176 mm x 125 mm)
xlPaperEnvelopeItaly= 36;      //Envelope (110 mm x 230 mm)
xlPaperEnvelopeMonarch= 37;    //Envelope Monarch (3-7/8 in. x 7-1/2 in.)
xlPaperEnvelopePersonal= 38;   //Envelope (3-5/8 in. x 6-1/2 in.)
xlPaperFanfoldUS= 39;          //U.S. Standard Fanfold (14-7/8 in. x 11 in.)
xlPaperFanfoldStdGerman= 40;   //German Standard Fanfold (8-1/2 in. x 12 in.)
xlPaperFanfoldLegalGerman= 41; //German Legal Fanfold (8-1/2 in. x 13 in.)
xlPaperUser= 256;              // User - defined

//----------- ��� ��������� ----------------------------------
xlNormalView=1;                // �������
xlPageBreakPreview=2;          // �������� ��������


//----------- ��� ��������� ----------------------------------
xlColumnClustered=51;         //Column  Clustered Column
xl3DColumnClustered=54;       // 3D Clustered Column
xlColumnStacked=52;           // Stacked Column
xl3DColumnStacked=55;         // 3D Stacked Column
xlColumnStacked100=53;        // 100% Stacked Column
xl3DColumnStacked100=56;      // 3D 100% Stacked Column
xl3DColumn=-4100;             // 3D Column
xlBarClustered=57;            // Bar Clustered Bar
xl3DBarClustered=60;          // 3D Clustered Bar
xlBarStacked=58;              // Stacked Bar
xl3DBarStacked=61;            // 3D Stacked Bar
xlBarStacked100=59;           // 100% Stacked Bar
xl3DBarStacked100=62;         // 3D 100% Stacked Bar
xlLine=4;                     // Line    Line
xlLineMarkers=65; // Line with Markers
xlLineStacked=63; //Stacked Line
xlLineMarkersStacked=66; // Stacked Line with Markers
xlLineStacked100=64; // 100% Stacked Line
xlLIneMarkersStacked100=67; // 100% Stacked Line with Markers
xl3DLine=-4101; // 3D Line
xlPie=5; // Pie Pie
xlPieExploded=69; // Exploded Pie
xl3Dpie=-4102; // 3D Pie
xl3DPieExploded=70; // Exploded 3D Pie
xlPieOfPie=68; // Pie of Pie
xlBarOfPie=71; // Bar of Pie
xlXYScatter=-4169; // XY (Scatter)    Scatter
xlXYScatterSmooth=72; // Scatter with Smoothed Lines
xlXYScatterSmoothNoMarkers=73; // Scatter with Smoothed Lines and No Data Markers
xlXYScatterLines=74; // Scatter with Lines
xlXYScatterLinesNoMarkers=75; // Scatter with Lines and No Data Markers
xlBubble=15; // Bubble  Bubble
xlBubble3DEffect=87; // Bubble with 3D effects
xlArea=1; // Area    Area
xl3DArea=-4098; // 3D Area
xlAreaStacked=76; // Stacked Area
xl3DAreaStacked=78; // 3D Stacked Area
xlAreaStacked100=77; // 100% Stacked Area
xl3DAreaStacked100=79; // 3D 100% Stacked Area
xlDoughnut=-4120; // Doughnut    Doughnut
xlDoughnutExploded=80; // Exploded Doughnut
xlRadar=-4151; // Radar   Radar
xlRadarMarkers=81; // Radar with Data Markers
xlRadarFilled=82; // Filled Radar
xlSurface=83; // Surface 3D Surface
xlSurfaceTopView=85; // Surface (Top View)
xlSurfaceWireframe=84; //  3D Surface (wireframe)
xlSurfaceTopViewWireframe=86; // Surface (Top View wireframe)
xlStockHLC=88; // Stock Quotes    High-Low-Close
xlStockVHLC=90; // Volume-High-Low-Close
xlStockOHLC=89; // Open-High-Low-Close
xlStockVOHLC=91; // Volume-Open-High-Low-Close
xlCylinderColClustered=92; // Cylinder    Clustered Cylinder Column
xlCylinderBarClustered=95; // Clustered Cylinder Bar
xlCylinderColStacked=93; // Stacked Cylinder Column
xlCylinderBarStacked=96; // Stacked Cylinder Bar
xlCylinderColStacked100=94; // 100% Stacked Cylinder Column
xlCylinderBarStacked100=97; // 100% Stacked Cylinder Bar
xlCylinderCol=98; // 3D Cylinder Column
xlConeColClustered=99; // Cone    Clustered Cone Column
xlConeBarClustered=102; // Clustered Cone Bar
xlConeColStacked=100; // Stacked Cone Column
xlConeBarStacked=103; // Stacked Cone Bar
xlConeColStacked100=101; // 100% Stacked Cone Column
xlConeBarStacked100=104; // 100% Stacked Cone Bar
xlConeCol=105; // 3D Cone Column
xlPyramidColClustered=106; // Pyramid Clustered Pyramid Column
xlPyramidBarClustered=109; // Clustered Pyramid Bar
xlPyramidColStacked=107; // Stacked Pyramid Column
xlPyramidBarStacked=110; // Stacked Pyramid Bar
xlPyramidColStacked100=108; // 100% Stacked Pyramid Column
xlPyramidBarStacked100=111; // 100% Stacked Pyramid Bar
xlPyramidCol=112; // 3D Pyramid Column

//---- ������ ----
xlColumns=2;       // � ��������
xlRows=1;          // � �������

//----- ���������� ��������� -------
xlLocationAsNewSheet=1;            //�� ��������� ����� �����
xlLocationAsObject=2;              // ���������� ��������� ����� � �������

//----- ������� ���� ----
xlCategory=1;
xlValue=2;
xlSeries=3;

//---- ��� ����� -----
xlBox=0;
xlPyramidToPoint=1;
xlPyramidToMax=2;
xlCylinder=3;
xlConeToPoint=4;
xlConeToMax=5;








Function  FontToEFont(font:Tfont;EFont:variant):boolean;

Function  CreateExcel:boolean;
Function  VisibleExcel(visible:boolean):boolean;
Function  AddWorkBook:boolean;
Function  OpenWorkBook(file_:string):boolean;
Function  AddSheet(newsheet:string):boolean;
Function  DeleteSheet(sheet:variant):boolean;
Function  CountSheets:integer;
Function  GetSheets(value:TStrings):boolean;
Function  SelectSheet(sheet:variant):boolean;
Function  SaveWorkBookAs(file_:string):boolean;
Function  CloseWorkBook:boolean;
Function  CloseExcel:boolean;


Function  GetRange(sheet:variant;range:string):variant;
Function  SetRange(sheet:variant;range:string;value_:variant):boolean;
Function  SetColumnWidth(sheet:variant;column:variant;width:real):boolean;
Function  SetRowHeight(sheet:variant;row:variant;height:real):boolean;
Function  GetFormatRange(sheet:variant;range:string):string;
Function  SetFormatRange(sheet:variant;range:string;format:string):boolean;
Function  SetHorizontalAlignment(sheet:variant;range:string;alignment:integer):boolean;
Function  SetVerticalAlignment(sheet:variant;range:string;alignment:integer):boolean;
Function  SetOrientation(sheet:variant;range:string;orientation:integer):boolean;
Function  SetWrapText(sheet:variant;range:string;WrapText:boolean):boolean;
Function  SetMergeCells(sheet:variant;range:string;MergeCells:boolean):boolean;
Function  SetShrinkToFit(sheet:variant;range:string;ShrinkToFit:boolean):boolean;
Function  SetFontRange(sheet:variant;range:string;font:Tfont):boolean;
Function  SetFontRangeEx(sheet:variant;range:string;underlinestyle,colorindex:integer;superscript,subscript:boolean):boolean;
Function  SetBorderRange(sheet:variant;range:string;Edge,LineStyle,Weight,ColorIndex,Color:integer):boolean;
Function  SetPatternRange(sheet:variant;range:string;Pattern,ColorIndex,PatternColorIndex,Color,PatternColor:integer):boolean;

Function  PrintPreview:boolean;
Function  PrintPreviewEx:boolean;
Function  ShowPrintDialog:boolean;
Function  SetBackgroundPicture(sheet:variant;file_:string):boolean;
Function  DisplayGridlines(display:boolean):boolean;
Function  PrintGridlines(sheet:variant;gridline:boolean):boolean;
Function  PageOrientation(sheet:variant;orientation:integer):boolean;
Function  PagePaperSize(sheet:variant;papersize:integer):boolean;
Function  WindowView(view:integer):boolean;
Function  PagePrintArea(sheet:variant;printarea:string):boolean;

//------------------------ ��������� -------------------------
Function  AddChart(var Name:variant;ChartType:integer):boolean;
Function  SetSourceData(Name,Sheet:variant;Range:string;XlRowCol:integer):boolean;
Function  PositionChart(Name:variant;Left,Top,Width,Height:real):boolean;
Function  PositionPlotArea(Name:variant;Left,Top,Width,Height:real):boolean;

Function  BorderPlotArea(Name:variant;Color,LineStyle,Weight:integer):boolean;
Function  BrushPlotArea(Name:variant;Color,Pattern,PatternColor:integer):boolean;
Function  BrushPlotAreaFromFile(Name:variant;File_:string):boolean;

Function  BorderChartArea(Name:variant;Color,LineStyle,Weight:integer):boolean;
Function  BrushChartArea(Name:variant;Color,Pattern,PatternColor:integer):boolean;
Function  BrushChartAreaFromFile(Name:variant;File_:string):boolean;

Function  BorderChartTitle(Name:variant;Color,LineStyle,Weight:integer):boolean;
Function  BrushChartTitle(Name:variant;Color,Pattern,PatternColor:integer):boolean;
Function  BrushChartTitleFromFile(Name:variant;File_:string):boolean;
Function  TextChartTitle(Name:variant;text_:string):boolean;
Function  PositionChartTitle(Name:variant;Left,Top:real):boolean;

//------------------------ ��������� (�����������) -------------------------
Function  SetChartType(Name:variant;ChartType:integer):boolean;
Function  SetChartLocation(var name:variant;sheet:variant;xlLocation:integer):boolean;

Function  PositionSizeLegend(Name:variant;Left,Top,Width,Height:real):boolean;
Function  BorderLegend(Name:variant;Color,LineStyle,Weight:integer):boolean;
Function  BrushLegend(Name:variant;Color,Pattern,PatternColor:integer):boolean;
Function  BrushLegendFromFile(Name:variant;File_:string):boolean;
Function  FontLegendEntries(Name,LegendEntries:variant;Font:TFont):boolean;

Function  AxisChart(Name:variant;Category,Series,Value:string):boolean;

Function  ElevationChart(Name:variant;Elevation:real):boolean;
Function  RotationChart(Name:variant;Rotation:real):boolean;

Function  BorderWalls(Name:variant;Color,LineStyle,Weight:integer):boolean;
Function  BrushWalls(Name:variant;Color,Pattern,PatternColor:integer):boolean;
Function  BrushWallsFromFile(Name:variant;File_:string):boolean;

Function  BorderFloor(Name:variant;Color,LineStyle,Weight:integer):boolean;
Function  BrushFloor(Name:variant;Color,Pattern,PatternColor:integer):boolean;
Function  BrushFloorFromFile(Name:variant;File_:string):boolean;

Function  SeriesCount(Name:variant):integer;
Function  BorderSeries(Name:variant;series:integer;Color,LineStyle,Weight:integer):boolean;
Function  BrushSeries(Name:variant;series:integer;Color,Pattern,PatternColor:integer):boolean;
Function  BrushSeriesFromFile(Name:variant;series:integer;File_:string):boolean;
Function  BarShapeSeries(Name:variant;series,BarShape:integer):boolean;



implementation


uses windows,forms,ComObj;
 var E:variant;


Function  FontToEFont(font:Tfont;EFont:variant):boolean;
begin
FontToEFont:=true;
try
EFont.Name:=font.Name;
if fsBold in font.Style      then EFont.Bold:=True                         //           ������
                             else EFont.Bold:=False;                       //           ������
if fsItalic in font.Style    then EFont.Italic:=True                       //           ���������
                             else EFont.Italic:=False;                     //           ���������
EFont.Size:=font.Size;                                                     //           ������
if fsStrikeOut in font.Style then EFont.Strikethrough:=True                //           �������������
                             else EFont.Strikethrough:=False;              //           �������������
if fsUnderline in font.Style then EFont.Underline:=xlUnderlineStyleSingle  //           �������������
                             else EFont.Underline:=xlUnderlineStyleNone;   //           �������������
EFont.Color:=font.Color;                                                   //           ����
except
FontToEFont:=false;
end;
End;


//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Superscript = False                '������� ������
//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Subscript = False                  '������ ������
//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.OutlineFont = True                 '�� ������������
//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Shadow = False                     '�� ������������
//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.ColorIndex = 41                    '������ �����




Function CreateExcel:boolean;
begin
CreateExcel:=true;
try
E:=CreateOleObject('Excel.Application');
except
CreateExcel:=false;
end;
End;


Function VisibleExcel(visible:boolean):boolean;
begin
VisibleExcel:=true;
try
E.visible:=visible;
except
VisibleExcel:=false;
end;
End;


Function AddWorkBook:boolean;
begin
AddWorkBook:=true;
try
E.Workbooks.Add;
except
AddWorkBook:=false;
end;
End;


Function OpenWorkBook(file_:string):boolean;
begin
OpenWorkBook:=true;
try
E.Workbooks.Open(file_);
except
OpenWorkBook:=false;
end;
End;


Function  AddSheet(newsheet:string):boolean;
begin
AddSheet:=true;
try
E.ActiveWorkbook.Sheets.Add;
E.ActiveWorkbook.ActiveSheet.Name:=newsheet;
except
AddSheet:=false;
end;
End;



Function  DeleteSheet(sheet:variant):boolean;
begin
DeleteSheet:=true;
try
E.DisplayAlerts:=False;
E.ActiveWorkbook.Sheets[sheet].Delete;
E.DisplayAlerts:=True;
except
DeleteSheet:=false;
end;
End;


Function  CountSheets:integer;
begin
try
CountSheets:=E.ActiveWorkbook.Sheets.Count;
except
CountSheets:=-1;
end;
End;


Function  GetSheets(value:TStrings):boolean;
 var a_:integer;
begin
GetSheets:=true;
value.Clear;
try
for a_:=1 to E.ActiveWorkbook.Sheets.Count do
    value.Add(E.ActiveWorkbook.Sheets.Item[a_].Name);
except
GetSheets:=false;
value.Clear;
end;
End;



Function  SelectSheet(sheet:variant):boolean;
begin
SelectSheet:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Select
except
SelectSheet:=false;
end;
End;



Function SaveWorkBookAs(file_:string):boolean;
begin
SaveWorkBookAs:=true;
try
E.DisplayAlerts:=False;
E.ActiveWorkbook.SaveAs(file_);
E.DisplayAlerts:=True;
except
SaveWorkBookAs:=false;
end;
End;



Function CloseWorkBook:boolean;
begin
CloseWorkBook:=true;
try
E.ActiveWorkbook.Close;
except
CloseWorkBook:=false;
end;
End;



Function CloseExcel:boolean;
begin
CloseExcel:=true;
try
E.Quit;
except
CloseExcel:=false;
end;
End;



//--------------------------------------------------------------------------

Function  SetRange(sheet:variant;range:string;value_:variant):boolean;
begin
SetRange:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range]:=value_;
except
SetRange:=false;
end;
End;


Function  GetRange(sheet:variant;range:string):variant;
begin
try
GetRange:= E.ActiveWorkbook.Sheets.Item[sheet].Range[range];
except
GetRange:=null;
end;
End;



Function  SetColumnWidth(sheet:variant;column:variant;width:real):boolean;
begin
SetColumnWidth:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Columns[column].ColumnWidth:=width;
except
SetColumnWidth:=false;
end;
End;


Function  SetRowHeight(sheet:variant;row:variant;height:real):boolean;
begin
SetRowHeight:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Rows[row].RowHeight:=height;
except
SetRowHeight:=false;
end;
End;


//------------ ������� ����� -----------------------------------
//    "mmmm yy"
//    "#,##0.00_ ;[Red]-#,##0.00 "
//    "@"
//    "#,##0.00$;[Red]#,##0.00$"

Function  GetFormatRange(sheet:variant;range:string):string;
begin
try
GetFormatRange:=E.ActiveWorkbook.Sheets.Item[sheet].Range[range].NumberFormat;
except
GetFormatRange:='';
end;
End;

Function  SetFormatRange(sheet:variant;range:string;format:string):boolean;
begin
SetFormatRange:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].NumberFormat:=format;
except
SetFormatRange:=false;
end;
End;


//----------------------- ������������ ------------------------

// �� �����������
Function  SetHorizontalAlignment(sheet:variant;range:string;alignment:integer):boolean;
begin
SetHorizontalAlignment:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].HorizontalAlignment:=alignment;
except
SetHorizontalAlignment:=false;
end;
End;

// �� ���������
Function  SetVerticalAlignment(sheet:variant;range:string;alignment:integer):boolean;
begin
SetVerticalAlignment:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].VerticalAlignment:=alignment;
except
SetVerticalAlignment:=false;
end;
End;


//----------------------- ������� ------------------------
Function  SetOrientation(sheet:variant;range:string;orientation:integer):boolean;
begin
SetOrientation:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Orientation:=orientation;
except
SetOrientation:=false;
end;
End;


//----------------------- ���������/������ �������� "������� �� ������" ------------------------
Function  SetWrapText(sheet:variant;range:string;WrapText:boolean):boolean;
begin
SetWrapText:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].WrapText:=WrapText;
except
SetWrapText:=false;
end;
End;


//----------------------- �����������/������ ����������� ����� ------------------------
Function  SetMergeCells(sheet:variant;range:string;MergeCells:boolean):boolean;
begin
SetMergeCells:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].MergeCells:=MergeCells;
except
SetMergeCells:=false;
end;
End;


//----------------------- �����������/������ ����������� ����� ------------------------
Function  SetShrinkToFit(sheet:variant;range:string;ShrinkToFit:boolean):boolean;
begin
SetShrinkToFit:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].ShrinkToFit:=ShrinkToFit;
except
SetShrinkToFit:=false;
end;
End;

//--------------------------- ��������� ������ ������ ---------------------------------

Function  SetFontRange(sheet:variant;range:string;font:Tfont):boolean;
begin
SetFontRange:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Name:=font.Name;
if fsBold in font.Style      then E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Bold:=True             //           ������
                             else E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Bold:=False;           //           ������
if fsItalic in font.Style    then E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Italic:=True           //           ���������
                             else E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Italic:=False;         //           ���������
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Size:=font.Size;                                         //           ������
if fsStrikeOut in font.Style then E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Strikethrough:=True    //           �������������
                             else E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Strikethrough:=False;  //           �������������
//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Superscript = False                '������� ������
//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Subscript = False                  '������ ������
//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.OutlineFont = True                 '�� ������������
//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Shadow = False                     '�� ������������
//E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.ColorIndex = 41                    '������ �����
if fsUnderline in font.Style then E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Underline:=xlUnderlineStyleSingle // '�������������
                             else E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Underline:=xlUnderlineStyleNone;  // '�������������
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Color:=font.Color;                                       //           ����
except
SetFontRange:=false;
end;
End;



Function  SetFontRangeEx(sheet:variant;range:string;underlinestyle,colorindex:integer;superscript,subscript:boolean):boolean;
begin
SetFontRangeEx:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Superscript:=superscript;    //   ������� ������
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Subscript:=subscript;        //   ������ ������
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.ColorIndex:=colorindex;      //   ������ �����
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Font.Underline:=underlinestyle;   //   �������������
except
SetFontRangeEx:=false;
end;
End;



Function  SetBorderRange(sheet:variant;range:string;Edge,LineStyle,Weight,ColorIndex,Color:integer):boolean;
begin
SetBorderRange:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Borders.item[Edge].LineStyle:=LineStyle;       //   ����� ����
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Borders.item[Edge].Weight:=Weight;             //   ������� ����
if ColorIndex>0 then
   E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Borders.item[Edge].ColorIndex:=ColorIndex   //   ������ �����
                else
   E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Borders.item[Edge].Color:=color;            //   ����
except
SetBorderRange:=false;
end;
End;



Function  SetPatternRange(sheet:variant;range:string;Pattern,ColorIndex,PatternColorIndex,Color,PatternColor:integer):boolean;
begin
SetPatternRange:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Interior.Pattern:=Pattern;                                          //   ����� ����
if ColorIndex>0 then E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Interior.ColorIndex:=ColorIndex                //   ������ �����
                else E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Interior.Color:=color;                         //   ����
if PatternColorIndex>0
                then E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Interior.PatternColorIndex:=PatternColorIndex  //   ������ �����
                else E.ActiveWorkbook.Sheets.Item[sheet].Range[range].Interior.PatternColor:=PatternColor;           //   ����
except
SetPatternRange:=false;
end;
End;



Function  PrintPreview:boolean;
begin
PrintPreview:=true;
try
E.ActiveWindow.SelectedSheets.PrintPreview;
except
PrintPreview:=false;
end;
End;



Function  PrintPreviewEx:boolean;
begin
PrintPreviewEx:=true;
try
E.Dialogs.Item[xlDialogPrintPreview].Show;
except
PrintPreviewEx:=false;
end;
End;



Function  ShowPrintDialog:boolean;
begin
ShowPrintDialog:=true;
try
E.Dialogs.Item[xlDialogPrint].Show;
except
ShowPrintDialog:=false;
end;
End;


Function  SetBackgroundPicture(sheet:variant;file_:string):boolean;
begin
SetBackgroundPicture:=true;
try
E.ActiveWorkbook.Sheets.Item[sheet].SetBackgroundPicture(FileName:=file_);
except
SetBackgroundPicture:=false;
end;
End;



Function  DisplayGridlines(display:boolean):boolean;
begin
DisplayGridlines:=true;
try
E.ActiveWindow.DisplayGridlines:=display;
except
DisplayGridlines:=false;
end;
End;


Function  PrintGridlines(sheet:variant;gridline:boolean):boolean;
begin
PrintGridlines:=true;
try
E.ActiveWorkbook.Sheets[sheet].PageSetup.PrintGridlines:=gridline;
except
PrintGridlines:=false;
end;
End;



Function  PageOrientation(sheet:variant;orientation:integer):boolean;
begin
PageOrientation:=true;
try
E.ActiveWorkbook.Sheets[sheet].PageSetup.Orientation:=orientation;
except
PageOrientation:=false;
end;
End;


Function  PagePaperSize(sheet:variant;papersize:integer):boolean;
begin
PagePaperSize:=true;
try
E.ActiveWorkbook.Sheets[sheet].PageSetup.PaperSize:=papersize;
except
PagePaperSize:=false;
end;
End;


Function  WindowView(view:integer):boolean;
begin
WindowView:=true;
try
E.ActiveWindow.View:=view;
except
WindowView:=false;
end;
End;


Function  PagePrintArea(sheet:variant;printarea:string):boolean;
begin
PagePrintArea:=true;
try
E.ActiveWorkbook.Sheets[sheet].PageSetup.PrintArea:=printarea;
except
PagePrintArea:=false;
end;
End;



//------------------------ ��������� -------------------------
// �������� ���������
Function  AddChart(var name:variant;ChartType:integer):boolean;
 const xl3DArea=-4098;
begin
AddChart:=true;
try
name:=E.Charts.Add.Name;
E.Charts.Item[name].ChartType:=ChartType;
except
AddChart:=false;
end;
End;

// ���������� ������� ������ ���������
Function  SetSourceData(Name,Sheet:variant;Range:string;XlRowCol:integer):boolean;
begin
SetSourceData:=true;
try
E.ActiveWorkbook.Charts.Item[name].SetSourceData(Source:=E.ActiveWorkbook.Sheets.Item[Sheet].Range[Range],PlotBy:=XlRowCol);
except
SetSourceData:=false;
end;
End;

Function  PositionChart(Name:variant;Left,Top,Width,Height:real):boolean;
begin
PositionChart:=true;
try
E.Charts.Item[name].ChartArea.Left:=Left;
E.Charts.Item[name].ChartArea.Top:=Top;
E.Charts.Item[name].ChartArea.Width:=Width;
E.Charts.Item[name].ChartArea.Height:=Height;
except
PositionChart:=false;
end;
End;

// ���������� ������� ���������� ���������
Function  PositionPlotArea(Name:variant;Left,Top,Width,Height:real):boolean;
begin
PositionPlotArea:=true;
try
E.Charts.Item[name].PlotArea.Left:=Left;
E.Charts.Item[name].PlotArea.Top:=Top;
E.Charts.Item[name].PlotArea.Width:=Width;
E.Charts.Item[name].PlotArea.Height:=Height;
except
PositionPlotArea:=false;
end;
End;



// ����� ������� ���������� ���������
Function  BorderPlotArea(Name:variant;Color,LineStyle,Weight:integer):boolean;
begin
BorderPlotArea:=true;
try
E.Charts.Item[name].PlotArea.Border.Color:=Color;
E.Charts.Item[name].PlotArea.Border.Weight:=Weight;
E.Charts.Item[name].PlotArea.Border.LineStyle:=LineStyle;
except
BorderPlotArea:=false;
end;
End;



// ������� ������� ���������� ��������� (����, �������, ���� �������)
Function  BrushPlotArea(Name:variant;Color,Pattern,PatternColor:integer):boolean;
begin
BrushPlotArea:=true;
try
E.Charts.Item[name].PlotArea.Interior.Color:=Color;
E.Charts.Item[name].PlotArea.Interior.Pattern:=Pattern;
E.Charts.Item[name].PlotArea.Interior.PatternColor:=PatternColor;
except
BrushPlotArea:=false;
end;
End;


// ������� ������� ���������� ��������� �� �����
Function  BrushPlotAreaFromFile(Name:variant;File_:string):boolean;
begin
BrushPlotAreaFromFile:=true;
try
E.Charts.Item[name].PlotArea.Fill.UserPicture(PictureFile:=File_);
E.Charts.Item[name].PlotArea.Fill.Visible:=True;
except
BrushPlotAreaFromFile:=false;
end;
End;




// ����� ������� ���������
Function  BorderChartArea(Name:variant;Color,LineStyle,Weight:integer):boolean;
begin
BorderChartArea:=true;
try
E.Charts.Item[name].ChartArea.Border.Color:=Color;
E.Charts.Item[name].ChartArea.Border.Weight:=Weight;
E.Charts.Item[name].ChartArea.Border.LineStyle:=LineStyle;
except
BorderChartArea:=false;
end;
End;



// ������� ������� ��������� (����, �������, ���� �������)
Function  BrushChartArea(Name:variant;Color,Pattern,PatternColor:integer):boolean;
begin
BrushChartArea:=true;
try
E.Charts.Item[name].ChartArea.Interior.Color:=Color;
E.Charts.Item[name].ChartArea.Interior.Pattern:=Pattern;
E.Charts.Item[name].ChartArea.Interior.PatternColor:=PatternColor;
except
BrushChartArea:=false;
end;
End;


// ������� ������� ��������� �� �����
Function  BrushChartAreaFromFile(Name:variant;File_:string):boolean;
begin
BrushChartAreaFromFile:=true;
try
E.Charts.Item[name].ChartArea.Fill.UserPicture(PictureFile:=File_);
E.Charts.Item[name].ChartArea.Fill.Visible:=True;
except
BrushChartAreaFromFile:=false;
end;
End;


// ��������� ���������
Function  TextChartTitle(Name:variant;text_:string):boolean;
begin
TextChartTitle:=true;
try
E.Charts.Item[name].HasTitle:=True;
E.Charts.Item[name].ChartTitle.Text:=text_;
except
TextChartTitle:=false;
end;
End;



Function  PositionChartTitle(Name:variant;Left,Top:real):boolean;
begin
PositionChartTitle:=true;
try
E.Charts.Item[name].ChartTitle.Left:=Left;
E.Charts.Item[name].ChartTitle.Top:=Top;
except
PositionChartTitle:=false;
end;
End;



Function  BorderChartTitle(Name:variant;Color,LineStyle,Weight:integer):boolean;
begin
BorderChartTitle:=true;
try
E.Charts.Item[name].ChartTitle.Border.Color:=Color;
E.Charts.Item[name].ChartTitle.Border.Weight:=Weight;
E.Charts.Item[name].ChartTitle.Border.LineStyle:=LineStyle;
except
BorderChartTitle:=false;
end;
End;



Function  BrushChartTitle(Name:variant;Color,Pattern,PatternColor:integer):boolean;
begin
BrushChartTitle:=true;
try
E.Charts.Item[name].ChartTitle.Interior.Color:=Color;
E.Charts.Item[name].ChartTitle.Interior.Pattern:=Pattern;
E.Charts.Item[name].ChartTitle.Interior.PatternColor:=PatternColor;
except
BrushChartTitle:=false;
end;
End;



Function  BrushChartTitleFromFile(Name:variant;File_:string):boolean;
begin
BrushChartTitleFromFile:=true;
try
E.Charts.Item[name].ChartTitle.Fill.UserPicture(PictureFile:=File_);
E.Charts.Item[name].ChartTitle.Fill.Visible:=True;
except
BrushChartTitleFromFile:=false;
end;
End;


//------------------------ ��������� (�����������) -------------------------
// ��� ���������
Function  SetChartType(Name:variant;ChartType:integer):boolean;
begin
SetChartType:=true;
try
E.Charts.Item[name].ApplyCustomType(ChartType:=ChartType);
except
SetChartType:=false;
end;
End;


// ���������� ��������� (�� ����� � �������, �� ��������� �����)
Function  SetChartLocation(var name:variant;sheet:variant;xlLocation:integer):boolean;
 var eee_:string;
begin
SetChartLocation:=true;
try
eee_:=name;messagebox(application.handle,pchar(eee_),'',0);
//name:=
E.Charts.Item[name].Location(Where:=xlLocation,Name:=sheet);
name:=E.ActiveChart.Name;
//if xlLocation=xlLocationAsNewSheet then name:=E.Sheets.Item[sheet].Charts.Item[name].Location(Where:=xlLocationAsNewSheet).name;
//if xlLocation=xlLocationAsObject   then name:=E.Charts.Item[name].Location(Where:=xlLocationAsObject,Name:=sheet).name;
eee_:=name;messagebox(application.handle,pchar(eee_),'',0);
except
SetChartLocation:=false;
end;
End;



// �������
//E.Charts.Item[name].Legend
//E.Charts.Item[name].HasLegend
Function PositionSizeLegend(Name:variant;Left,Top,Width,Height:real):boolean;
begin
PositionSizeLegend:=true;
try
E.Charts.Item[name].Legend.Left:=Left;
E.Charts.Item[name].Legend.Top:=Top;
E.Charts.Item[name].Legend.Width:=Width;
E.Charts.Item[name].Legend.Height:=Height;
except
PositionSizeLegend:=false;
end;
End;



Function  BorderLegend(Name:variant;Color,LineStyle,Weight:integer):boolean;
begin
BorderLegend:=true;
try
E.Charts.Item[name].Legend.Border.Color:=Color;
E.Charts.Item[name].Legend.Border.Weight:=Weight;
E.Charts.Item[name].Legend.Border.LineStyle:=LineStyle;
except
BorderLegend:=false;
end;
End;



Function  BrushLegend(Name:variant;Color,Pattern,PatternColor:integer):boolean;
begin
BrushLegend:=true;
try
E.Charts.Item[name].Legend.Interior.Color:=Color;
E.Charts.Item[name].Legend.Interior.Pattern:=Pattern;
E.Charts.Item[name].Legend.Interior.PatternColor:=PatternColor;
except
BrushLegend:=false;
end;
End;



Function  BrushLegendFromFile(Name:variant;File_:string):boolean;
begin
BrushLegendFromFile:=true;
try
E.Charts.Item[name].Legend.Fill.UserPicture(PictureFile:=File_);
E.Charts.Item[name].Legend.Fill.Visible:=True;
except
BrushLegendFromFile:=false;
end;
End;



Function  FontLegendEntries(Name,LegendEntries:variant;Font:TFont):boolean;
begin
FontLegendEntries:=true;
try
FontLegendEntries:=FontToEFont(Font,E.Charts.Item[name].Legend.LegendEntries.Item[LegendEntries].Font);
except
FontLegendEntries:=false;
end;
End;



// ������� ����
Function  AxisChart(Name:variant;Category,Series,Value:string):boolean;
begin
AxisChart:=true;
try
if Category<>'' then E.Charts.Item[name].Axes[xlCategory].HasTitle:=True else E.Charts.Item[name].Axes[xlCategory].HasTitle:=False;
if Series<>''   then E.Charts.Item[name].Axes[xlSeries].HasTitle:=True   else E.Charts.Item[name].Axes[xlSeries].HasTitle:=False;
if Value<>''    then E.Charts.Item[name].Axes[xlValue].HasTitle:=True    else E.Charts.Item[name].Axes[xlValue].HasTitle:=False;
E.Charts.Item[name].Axes[xlCategory].AxisTitle.Text:=Category;
E.Charts.Item[name].Axes[xlSeries].AxisTitle.Text:=Series;
E.Charts.Item[name].Axes[xlValue].AxisTitle.Text:=Value;
except
AxisChart:=false;
end;
End;


//������
Function  ElevationChart(Name:variant;Elevation:real):boolean;
begin
ElevationChart:=true;
try
E.Charts.Item[name].Elevation:=Elevation;
except
ElevationChart:=false;
end;
End;


//�������
Function  RotationChart(Name:variant;Rotation:real):boolean;
begin
RotationChart:=true;
try
E.Charts.Item[name].Rotation:=Rotation;
except
RotationChart:=false;
end;
End;


//�����
// ����� - ������� ����
Function  BorderWalls(Name:variant;Color,LineStyle,Weight:integer):boolean;
begin
BorderWalls:=true;
try
E.Charts.Item[name].Walls.Border.Color:=Color;
E.Charts.Item[name].Walls.Border.Weight:=Weight;
E.Charts.Item[name].Walls.Border.LineStyle:=LineStyle;
except
BorderWalls:=false;
end;
End;


// ���� � ������� ����
Function  BrushWalls(Name:variant;Color,Pattern,PatternColor:integer):boolean;
begin
BrushWalls:=true;
try
E.Charts.Item[name].Walls.Interior.Color:=Color;
E.Charts.Item[name].Walls.Interior.Pattern:=Pattern;
E.Charts.Item[name].Walls.Interior.PatternColor:=PatternColor;
except
BrushWalls:=false;
end;
End;


// ������� ���� �� �����
Function  BrushWallsFromFile(Name:variant;File_:string):boolean;
begin
BrushWallsFromFile:=true;
try
E.Charts.Item[name].Walls.Fill.UserPicture(PictureFile:=File_);
E.Charts.Item[name].Walls.Fill.Visible:=True;
except
BrushWallsFromFile:=false;
end;
End;


//���������
// ����� - ������� ���������
Function  BorderFloor(Name:variant;Color,LineStyle,Weight:integer):boolean;
begin
BorderFloor:=true;
try
E.Charts.Item[name].Floor.Border.Color:=Color;
E.Charts.Item[name].Floor.Border.Weight:=Weight;
E.Charts.Item[name].Floor.Border.LineStyle:=LineStyle;
except
BorderFloor:=false;
end;
End;


// ���� � ������� ���������
Function  BrushFloor(Name:variant;Color,Pattern,PatternColor:integer):boolean;
begin
BrushFloor:=true;
try
E.Charts.Item[name].Floor.Interior.Color:=Color;
E.Charts.Item[name].Floor.Interior.Pattern:=Pattern;
E.Charts.Item[name].Floor.Interior.PatternColor:=PatternColor;
except
BrushFloor:=false;
end;
End;


// ������� ���� �� ���������
Function  BrushFloorFromFile(Name:variant;File_:string):boolean;
begin
BrushFloorFromFile:=true;
try
E.Charts.Item[name].Floor.Fill.UserPicture(PictureFile:=File_);
E.Charts.Item[name].Floor.Fill.Visible:=True;
except
BrushFloorFromFile:=false;
end;
End;


//--------------------- ��������� ----------------
// ����������
Function  SeriesCount(Name:variant):integer;
begin
SeriesCount:=-1;
try
SeriesCount:=E.Charts.Item[name].SeriesCollection.Count;
except
SeriesCount:=-1;
end;
End;


// ����� - ������� ���������
Function  BorderSeries(Name:variant;series:integer;Color,LineStyle,Weight:integer):boolean;
begin
BorderSeries:=true;
try
E.Charts.Item[name].SeriesCollection.Item[series].Border.Color:=Color;
E.Charts.Item[name].SeriesCollection.Item[series].Border.Weight:=Weight;
E.Charts.Item[name].SeriesCollection.Item[series].Border.LineStyle:=LineStyle;
except
BorderSeries:=false;
end;
End;


// ���� � ������� ���������
Function  BrushSeries(Name:variant;series:integer;Color,Pattern,PatternColor:integer):boolean;
begin
BrushSeries:=true;
try
E.Charts.Item[name].SeriesCollection.Item[series].Interior.Color:=Color;
E.Charts.Item[name].SeriesCollection.Item[series].Interior.Pattern:=Pattern;
E.Charts.Item[name].SeriesCollection.Item[series].Interior.PatternColor:=PatternColor;
except
BrushSeries:=false;
end;
End;


// ������� ������� ���������
Function  BrushSeriesFromFile(Name:variant;series:integer;File_:string):boolean;
begin
BrushSeriesFromFile:=true;
try
E.Charts.Item[name].SeriesCollection.Item[series].Fill.UserPicture(PictureFile:=File_);
E.Charts.Item[name].SeriesCollection.Item[series].Fill.Visible:=True;
except
BrushSeriesFromFile:=false;
end;
End;


// ��� ���������
Function  BarShapeSeries(Name:variant;series,BarShape:integer):boolean;
begin
BarShapeSeries:=true;
try
E.Charts.Item[name].SeriesCollection.Item[series].BarShape:=BarShape;
except
BarShapeSeries:=false;
end;
End;



end.


