unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, //Chartfx3,
  OleCtrls, Winpos_ole_TLB, POSBase, VCFI, ComCtrls, StdCtrls,
  TeEngine, Series, ExtCtrls, TeeProcs, Chart,
  //QuickRpt, QRCtrls,
  ComObj, IniFiles,
  Spin;

type
  TForm1 = class(TForm)
    ListViewSignals: TListView;
    PageControlParams: TPageControl;
    TabPressure: TTabSheet;
    TabShifts: TTabSheet;
    TabDeformations: TTabSheet;
    OpenCfgDialog: TOpenDialog;
    LabelFile: TLabel;
    ButtonLoadFile: TButton;
    LabelCfg: TLabel;
    ButtonLoadCfg: TButton;
    ButtonSaveCfg: TButton;
    ButtonAdd: TButton;
    ButtonRemove: TButton;
    SaveCfgDialog: TSaveDialog;
    EditPressureName: TEdit;
    ListViewShifts: TListView;
    ListViewDeformations: TListView;
    EditT0: TEdit;
    EditTk: TEdit;
    ChartPreview: TChart;
    Series1: TFastLineSeries;
    CheckBoxPreview: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    CheckBoxInterval: TCheckBox;
    ButtonExecute: TButton;
    Label3: TLabel;
    EditStep: TEdit;
    SaveReportDialog: TSaveDialog;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Label6: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ButtonClear: TButton;
    ProgressBar1: TProgressBar;
    rbReport_doc: TRadioButton;
    CheckBoxShowWordInRuntime: TCheckBox;
    rbReport_csv: TRadioButton;
    LabelReportName: TEdit;
    EditNagr: TEdit;
    EditDate: TEdit;
    EditNumIzd: TEdit;
    Label8: TLabel;
    LabelFileName: TEdit;
    LabelCfgName: TEdit;
    EditTm0: TEdit;
    Label9: TLabel;
    ButtonSaveReportAs: TButton;
    Label10: TLabel;
    EditTmk: TEdit;
    Series2: TLineSeries;
    Series3: TLineSeries;
    edPikDeltaT: TEdit;
    Label11: TLabel;
    edPikDeltaEff: TEdit;
    Label12: TLabel;
    edPikKEff: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    edDigits: TSpinEdit;
    Label17: TLabel;
    procedure ButtonLoadCfgClick(Sender: TObject);
    procedure ButtonSaveCfgClick(Sender: TObject);
    procedure ButtonLoadFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure ListViewSignalsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ButtonRemoveClick(Sender: TObject);
    procedure ButtonExecuteClick(Sender: TObject);
    procedure DblClickSignals(Sender: TObject);
    procedure ButtonSaveReportAsClick(Sender: TObject);
    procedure CheckBoxPreviewClick(Sender: TObject);
    procedure CheckBoxIntervalClick(Sender: TObject);
    procedure EditTkChange(Sender: TObject);
    procedure OnPressSpace(Sender: TObject; var Key: Char);
    procedure ButtonClearClick(Sender: TObject);
    procedure EditPressureNameClick(Sender: TObject);
    procedure rbReport_docClick(Sender: TObject);
    procedure rbReport_csvClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure EditT0Change(Sender: TObject);
    procedure EditTm0Click(Sender: TObject);
    procedure EditTm0Change(Sender: TObject);
    procedure EditTmkChange(Sender: TObject);
    procedure EditTmkClick(Sender: TObject);
    procedure EditT0Click(Sender: TObject);
    procedure EditTkClick(Sender: TObject);
  private
    buf : array[0..1023] of Char;
    CfgFileName, FileName, ReportFileName : string[255];
    Signal, Pressure : IWPSignal;
    usml    : IWPUSML;
    api     : IWPGraphs;
    szTimesArray : Integer;
    TimesArray : array[0..102300] of double;
    szTimesArray1 : Integer;
    TimesArray1 : array[0..102300] of double;
    NameSignalInChart : String;
    PP:Integer;    

    procedure LoadFile();
    procedure ShowPreview(signame : String);
    procedure ShowPreviewMO(signame : String);    
    function GetSignal( SubPath, Name : String ) : IWPSignal;
    procedure CreateResult( SubPath, Name : String );
    procedure SaveReport();
    procedure SaveReportCSV();    
    procedure LoadConfig();
    procedure SaveConfig();



  public

  end;

var
  Form1: TForm1;

implementation

const
  // Word'овские константы
  wdCell = 12;
  wdLine = 5;
  wdAlignParagraphLeft = 0;
  wdAlignParagraphCenter = 1;
  wdAlignParagraphRight = 2;
  wdAlignParagraphJustify = 3;
  wdAlignParagraphDistribute = 4;
  wdAutoFitFixed = 0;
  wdAutoFitContent = 1;
  wdAutoFitWindow = 2;
  wdFormatDocument = 0;
  // Форматирование чисел
  MM = 9;


{$R *.dfm}

procedure TForm1.SaveConfig();
var inifile : TIniFile;
var item : TListItem;
var s : String;
var i : Integer;
begin
   if (CfgFileName<>'')then
   begin
  inifile:= TIniFile.Create(CfgFileName);
  inifile.WriteString('Common', 'FileName', FileName);
  inifile.WriteBool('Common', 'Preview', CheckBoxPreview.Checked);
  inifile.WriteBool('Common', 'Interval', CheckBoxInterval.Checked);
  inifile.WriteString('Report', 'FileName', ReportFileName);
  inifile.WriteString('Report', 'NumIzd', EditNumIzd.Text);
  inifile.WriteString('Report', 'Date', EditDate.Text);
  inifile.WriteString('Report', 'Nagr', EditNagr.Text);
  inifile.WriteString('Pressure', 'PressureName', EditPressureName.Text);
  inifile.WriteString('Pressure', 'Tm0', EditTm0.Text);
  inifile.WriteString('Pressure', 'Tmk', EditTmk.Text);    
  inifile.WriteString('Pressure', 'T0', EditT0.Text);
  inifile.WriteString('Pressure', 'Tk', EditTk.Text);
  inifile.WriteString('Pressure', 'Step', EditStep.Text);

  inifile.WriteString('Report', 'Digits', edDigits.Text);



  inifile.WriteString('Picks', 'Interval1', edPikDeltaT.Text);
  inifile.WriteString('Picks', 'Interval2', edPikDeltaEff.Text);
  inifile.WriteString('Picks', 'K', edPikKEff.Text);      

  if (rbReport_doc.Checked) then
     inifile.WriteString('Report', 'Type', 'doc')
  else
     inifile.WriteString('Report', 'Type', 'csv');

  inifile.WriteInteger('Shifts', 'Num', ListViewShifts.Items.Count);
  for i:=0 to ListViewShifts.Items.Count-1 do
  begin
    Str(i,s); s:='Param'+Trim(s);
    item:= ListViewShifts.Items.Item[i];
    inifile.WriteString('Shifts', s, item.Caption);
  end;

  inifile.WriteInteger('Deformations', 'Num', ListViewDeformations.Items.Count);
  for i:=0 to ListViewDeformations.Items.Count-1 do
  begin
    Str(i,s); s:='Param'+Trim(s);
    item:= ListViewDeformations.Items.Item[i];
    inifile.WriteString('Deformations', s, item.Caption);
  end;
  inifile.Free;
  end;
end;

procedure TForm1.LoadConfig();
var inifile : TIniFile;
var item : TListItem;
var s, sname, tmp: String;
var i, j, Num, ToDel : Integer;
begin
   if (CfgFileName<>'')then
   begin

  inifile:= TIniFile.Create(CfgFileName);

  FileName:= inifile.ReadString('Common', 'FileName', '');
  if FileName<>'' then
    LoadFile();
  CheckBoxPreview.Checked:= inifile.ReadBool('Common', 'Preview', true);
  CheckBoxInterval.Checked:= inifile.ReadBool('Common', 'Interval', true);
  ReportFileName:= inifile.ReadString('Report', 'FileName', 'report.doc');
  LabelReportName.Text:= ReportFileName;
  EditNumIzd.Text:= inifile.ReadString('Report', 'NumIzd', '');
  EditDate.Text:= inifile.ReadString('Report', 'Date', '');
  EditNagr.Text:= inifile.ReadString('Report', 'Nagr', '');
  EditPressureName.Text:= inifile.ReadString('Pressure', 'PressureName', 'параметр не выбран');
  EditT0.Text:= inifile.ReadString('Pressure', 'T0', '0');
  EditTk.Text:= inifile.ReadString('Pressure', 'Tk', '0');
  EditStep.Text:= IntToStr(inifile.ReadInteger('Pressure', 'Step', 5));
  EditTm0.Text:= inifile.ReadString('Pressure', 'Tm0', '0');
  EditTmk.Text:= inifile.ReadString('Pressure', 'Tmk', '0');

  edDigits.Text:= inifile.ReadString('Report', 'Digits', '3');  

  edPikDeltaT.Text:= IntToStr(inifile.ReadInteger('Picks', 'Interval1', 50));
  edPikDeltaEff.Text:= inifile.ReadString('Picks', 'Interval2', '50');
  edPikKEff.Text:= inifile.ReadString('Picks', 'K', '1');    

  tmp:= inifile.ReadString('Report', 'Type', 'doc');
  if (tmp='doc')then
  begin
   rbReport_doc.Checked:=true;
   CheckBoxShowWordInRuntime.Enabled:=true;
  end
  else
  begin
   rbReport_csv.Checked:=true;
   CheckBoxShowWordInRuntime.Enabled:=false;
  end;  


  if ListViewSignals.Items.Count>0 then
  begin
  for j:=0 to ListViewSignals.Items.Count-1 do
    if ListViewSignals.Items[j].Caption = EditPressureName.Text then
      ToDel:=j;


  ListViewSignals.Items[ToDel].Delete;
  end;

  ListViewShifts.Clear;
  Num:= inifile.ReadInteger('Shifts', 'Num', 0);
  for i:=0 to Num-1 do
  begin
    Str(i,s); s:='Param'+Trim(s);
    sname:= inifile.ReadString('Shifts', s, '');
    Signal:= GetSignal( '', sname );
    if Assigned(Signal) then
    begin
      item:= ListViewShifts.Items.Add;
      item.Caption:= Signal.SName;
      item.SubItems.Append( Signal.NameY );

      for j:=0 to ListViewSignals.Items.Count-1 do
        if ListViewSignals.Items[j].Caption = Signal.SName then
          ToDel:=j;
      ListViewSignals.Items[ToDel].Delete;
    end;
  end;

  ListViewDeformations.Clear;
  Num:= inifile.ReadInteger('Deformations', 'Num', 0);
  for i:=0 to Num-1 do
  begin
    Str(i,s);
    s:='Param'+Trim(s);
    sname:= inifile.ReadString('Deformations', s, '');
    Signal:= GetSignal( '', sname );
    if Assigned(Signal) then
    begin
      item:= ListViewDeformations.Items.Add;
      item.Caption:= Signal.SName;
      item.SubItems.Append( Signal.NameY );

      for j:=0 to ListViewSignals.Items.Count-1 do
        if ListViewSignals.Items[j].Caption = Signal.SName then
          ToDel:=j;
      ListViewSignals.Items[ToDel].Delete;
    end;
  end;
  inifile.Free;
  end;
end;

function CentimetersToPoints(a:Single) : Single;
begin
{Converts a measurement from centimeters to points (1 cm = 28.35 points).
Returns the converted measurement as a Single.
Syntax
expression.CentimetersToPoints(Centimeters)
expression Optional. An expression that returns an Application object.
Centimeters Required Single. The centimeter value to be converted to points.}
  Result:=28.35*a;
end;

procedure TForm1.ButtonLoadCfgClick(Sender: TObject);
begin
  OpenCfgDialog.Title:='Открытие файла настроек';
  GetModuleFileName( HInstance, buf, SizeOf(buf));
  OpenCfgDialog.InitialDir:= ExtractFilePath(buf);
  OpenCfgDialog.FileName:= CfgFileName;
  if OpenCfgDialog.Execute  then
    CfgFileName:= OpenCfgDialog.FileName
  else
    CfgFileName:= '';
  LabelCfgName.Text:= CfgFileName;

  LoadConfig();
end;

procedure TForm1.ButtonSaveCfgClick(Sender: TObject);
begin
  SaveCfgDialog.Title:='Сохранение файла настроек';
  GetModuleFileName( HInstance, buf, SizeOf(buf));
  SaveCfgDialog.InitialDir:= ExtractFilePath(buf);
  SaveCfgDialog.FileName:= CfgFileName;
  if SaveCfgDialog.Execute then
    CfgFileName:= SaveCfgDialog.FileName
  else
    CfgFileName:= '';
  LabelCfgName.Text:= CfgFileName;

  SaveConfig();
end;

procedure TForm1.ButtonSaveReportAsClick(Sender: TObject);
begin
  SaveReportDialog.Title:='Выбор имени файла отчета';
  GetModuleFileName( HInstance, buf, SizeOf(buf));
  SaveReportDialog.InitialDir:= ExtractFilePath(buf);
  SaveReportDialog.FileName:= ReportFileName;

  if (rbReport_doc.Checked) then
     SaveReportDialog.Filter:= 'Файлы отчетов (*.doc)|*.doc'
  else
     SaveReportDialog.Filter:= 'Файлы отчетов (*.csv)|*.csv';
     
  if SaveReportDialog.Execute then
    ReportFileName:= SaveReportDialog.FileName
  else
    ReportFileName:= '';
  LabelReportName.Text:= ReportFileName;
end;


function IsSignal(d: idispatch): boolean;
begin
  result := false;
  if d=nil then exit;

  if Supports(d, DIID_IWPNode) then
  begin
    if Supports((d as iwpnode).Reference, DIID_IWPSignal) then
    begin
      result := true;
      exit;
    end;
  end;
  if Supports(d, DIID_IWPSignal) then
  begin
    result := true;
    exit;
  end;
end;

function TForm1.GetSignal( SubPath, Name : String ) : IWPSignal;
var
  d:idispatch;
begin
  result:=nil;
  if (SubPath='') then
  begin
    d:=WinPOS.GetObject('/Signals/'+ExtractFileName(FileName)+'/'+Name);
    if IsSignal(d) then
      Result:=d as IWPSignal;
  end
  else
    Result:= WinPOS.GetObject('/Signals/Результаты/'+SubPath+'/'+ExtractFileName(FileName)+'/'+Name) as IWPSignal;
end;

// Сохранение отчета
procedure TForm1.SaveReport;
var i, j : Integer;
var W : Variant;
var s : String;
var cols, rows : Integer;
var Item: TListItem;
var BarStep, BarSteps: Double;
begin
   PP:=StrToInt(edDigits.Text);

  try
    W:= CreateOleObject('Word.Application');
    W.Visible := CheckBoxShowWordInRuntime.Checked;
    if CheckBoxShowWordInRuntime.Checked then
      W.Application.WindowState := 1;
    W.Documents.Add;

    W.ActiveDocument.PageSetup.LeftMargin := 50;
    W.ActiveDocument.PageSetup.TopMargin := 36;
    W.ActiveDocument.PageSetup.RightMargin := 40;
    W.ActiveDocument.PageSetup.BottomMargin := 36;

    W.Selection.Font.Name := 'Times New Roman';
    W.Selection.Font.Size := 12;

    W.Selection.TypeText(Text:='Номер изделия: '+EditNumIzd.Text);
    W.Selection.TypeParagraph;
    W.Selection.TypeText(Text:='Дата испытания: '+EditDate.Text);
    W.Selection.TypeParagraph;
    W.Selection.TypeText(Text:='Вид нагружения: '+EditNagr.Text);
    W.Selection.TypeParagraph;
    W.Selection.TypeParagraph;
    W.Selection.TypeParagraph;

    // Таблица 1
    W.Selection.Font.Name := 'Courier New';
    W.Selection.Font.Size := 8;

    cols:= szTimesArray+1;
    rows:= ListViewShifts.Items.Count+2;

    BarStep:=75/cols/(rows-2+ListViewDeformations.Items.Count);
    BarSteps:= 0;

    W.ActiveDocument.Tables.Add(Range:=W.Selection.Range, NumRows:=rows, NumColumns:= cols);
    W.Selection.Tables.Item(1).Style:= 'Сетка таблицы';

    Signal:= GetSignal( 'Таблица_1', EditPressureName.Text );

    // Строка времени
    W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).WordWrap:= False;
    W.Selection.TypeText( Text:='время' );
    W.Selection.MoveRight(  Unit:=wdCell );
    for i:=0 to cols-2 do
    begin
      Str(Signal.GetX(i):MM:PP,s); s:= Trim(s);
      W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).WordWrap:= False;
      W.Selection.TypeText( Text:=s );
      W.Selection.MoveRight(  Unit:=wdCell );
    end;

    // Строка давления
    W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).WordWrap:= False;
    W.Selection.TypeText( Text:=Signal.SName+'['+Signal.NameY+']' );
    W.Selection.MoveRight(  Unit:=wdCell );
    for i:=0 to cols-2 do
    begin
      Str(Signal.GetY(i):MM:PP,s); s:= Trim(s);
      W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).WordWrap:= False;
      W.Selection.TypeText( Text:=s );
      W.Selection.MoveRight( Unit:=wdCell );
    end;

    // Строки перемещений
    for j:=0 to rows-3 do
    begin
      item:= ListViewShifts.Items.Item[j];
      Signal:= GetSignal( 'Таблица_1', item.Caption );
      W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).WordWrap:= False;
      W.Selection.TypeText( Text:=Signal.SName+'['+Signal.NameY+']' );
      W.Selection.MoveRight(  Unit:=wdCell );
      for i:=0 to cols-2 do
      begin
        Str(Signal.GetY(i):MM:PP,s); s:= Trim(s);
        W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
        W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
        W.Selection.Cells.Item(1).WordWrap:= False;
        W.Selection.TypeText( Text:=s );
        if not((i=cols-2) and (j=rows-3)) then
          W.Selection.MoveRight(  Unit:=wdCell );

        if (BarSteps>1) then
        begin
          ProgressBar1.StepBy(Trunc(BarSteps));
          BarSteps:= BarSteps-Trunc(BarSteps);
        end;
        BarSteps:= BarSteps+BarStep;
      end;
    end;

    {W.Selection.Tables.Item(1).Select;
    W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).WordWrap:= False;
    W.Selection.Cells.Item(1).FitText:= False;}

    W.Selection.Tables.Item(1).AutoFitBehavior(wdAutoFitWindow);

    W.Selection.MoveDown ( Unit:=wdLine, Count:=2 );

    W.Selection.Font.Name := 'Times New Roman';
    W.Selection.Font.Size := 12;

    W.Selection.ParagraphFormat.Alignment:= wdAlignParagraphCenter;
    W.Selection.TypeText(Text:='Таблица 1. Зависимость перемещения от давления');
    W.Selection.TypeParagraph;
    W.Selection.ParagraphFormat.Alignment:= wdAlignParagraphLeft;
    W.Selection.TypeParagraph;
    W.Selection.TypeParagraph;
    W.Selection.TypeParagraph;

    // Таблица 2
    W.Selection.Font.Name := 'Courier New';
    W.Selection.Font.Size := 8;

    rows:= ListViewDeformations.Items.Count+2;

    W.ActiveDocument.Tables.Add(Range:=W.Selection.Range, NumRows:=rows, NumColumns:= cols);
    W.Selection.Tables.Item(1).Style:= 'Сетка таблицы';

    Signal:= GetSignal( 'Таблица_2', EditPressureName.Text );

    // Строка времени
    W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).WordWrap:= False;
    W.Selection.TypeText( Text:='время' );
    W.Selection.MoveRight(  Unit:=wdCell );
    for i:=0 to cols-2 do
    begin
      Str(Signal.GetX(i):MM:PP,s); s:= Trim(s);
      W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).WordWrap:= False;
      W.Selection.TypeText( Text:=s );
      W.Selection.MoveRight(  Unit:=wdCell );
    end;

    // Строка давления
    W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
    W.Selection.Cells.Item(1).WordWrap:= False;
    W.Selection.TypeText( Text:=Signal.SName+'['+Signal.NameY+']' );
    W.Selection.MoveRight(  Unit:=wdCell );
    for i:=0 to cols-2 do
    begin
      Str(Signal.GetY(i):MM:PP,s); s:= Trim(s);
      W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).WordWrap:= False;
      W.Selection.TypeText( Text:=s );
      W.Selection.MoveRight(  Unit:=wdCell );
    end;

    // Строки деформаций
    for j:=0 to rows-3 do
    begin
      item:= ListViewDeformations.Items.Item[j];
      Signal:= GetSignal( 'Таблица_2', item.Caption );
      W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
      W.Selection.Cells.Item(1).WordWrap:= False;
      W.Selection.TypeText( Text:=Signal.SName+'['+Signal.NameY+']' );
      W.Selection.MoveRight(  Unit:=wdCell );
      for i:=0 to cols-2 do
      begin
        Str(Signal.GetY(i):MM:PP,s); s:= Trim(s);
        W.Selection.Cells.Item(1).LeftPadding:= CentimetersToPoints(0.05);
        W.Selection.Cells.Item(1).RightPadding:= CentimetersToPoints(0.05);
        W.Selection.Cells.Item(1).WordWrap:= False;
        W.Selection.TypeText( Text:=s );
        if not((i=cols-2) and (j=rows-3)) then
          W.Selection.MoveRight(  Unit:=wdCell );

        if (BarSteps>1) then
        begin
          ProgressBar1.StepBy(Trunc(BarSteps));
          BarSteps:= BarSteps-Trunc(BarSteps);
        end;
        BarSteps:= BarSteps+BarStep;
      end;
    end;

    W.Selection.Tables.Item(1).AutoFitBehavior(wdAutoFitWindow);

    W.Selection.MoveDown ( Unit:=wdLine, Count:=2 );

    W.Selection.Font.Name := 'Times New Roman';
    W.Selection.Font.Size := 12;

    W.Selection.ParagraphFormat.Alignment:= wdAlignParagraphCenter;
    W.Selection.TypeText(Text:='Таблица 2. Зависимость деформации от давления');
    W.Selection.TypeParagraph;
    W.Selection.ParagraphFormat.Alignment:= wdAlignParagraphLeft;
    W.Selection.TypeParagraph;
    W.Selection.TypeParagraph;
    W.Selection.TypeText(Text:='Испытания проводил: ________________________________________________________');

    W.ChangeFileOpenDirectory( ExtractFilePath(ReportFileName) );
    W.ActiveDocument.SaveAs( FileName:= ExtractFileName(ReportFileName), FileFormat:=wdFormatDocument,
        LockComments:=False, Password:='', AddToRecentFiles:=True, WritePassword
        :='', ReadOnlyRecommended:=False, EmbedTrueTypeFonts:=False,
        SaveNativePictureFormat:=False, SaveFormsData:=False, SaveAsAOCELetter:=
        False );

    ProgressBar1.Position:= 100;
    W.Visible := True;
    W.Application.WindowState := 1;

  finally
    W:=UnAssigned;
  end;
end;

// Выбрали сигнал в одном из списков
procedure TForm1.ListViewSignalsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
    ShowPreview(Item.Caption);
end;

// Нажали на кнопку [-->]
procedure TForm1.ButtonAddClick(Sender: TObject);
var item : TListItem;
var s: String;
var hPage, hGraph, hAxis : Integer;
begin
  if ListViewSignals.Selected<>Nil then
  begin
    case PageControlParams.ActivePageIndex of
    0: begin
      EditPressureName.Text:= ListViewSignals.Selected.Caption;
      ListViewSignals.DeleteSelected;
      Signal:= GetSignal( '', EditPressureName.Text );
      Str(Signal.StartX:12:3,s);
      EditT0.Text:= s;
      Str((Signal.StartX + Signal.size * Signal.DeltaX):12:3,s);
      EditTk.Text:= s;

      //Нарисуем давление в WinПОС, чтобы лучше секунды начала видеть
      api:= WinPOS.GraphAPI as IWPGraphs;
      hPage:= api.CreatePage(); //создаем новую страницу для графиков
      hGraph:= api.GetGraph(hPage, 0); //страница всегда создается с одной областью для рисования, поэтому возьмем ее
      hAxis:= api.GetYAxis(hGraph, 0); //получаем ось Y
      api.CreateLine( hGraph, hAxis, Signal.Instance ); //создаем  новую линию в графике
      api.NormalizeGraph(hGraph); //нормализуем график
      self.BringToFront;
      WinPOS.Refresh;
      WinPOS.DoEvents;
      self.BringToFront;
    end;
    1: begin
      Signal:= GetSignal( '', ListViewSignals.Selected.Caption );
      item:= ListViewShifts.Items.Add;
      item.Caption:= Signal.SName;
      item.SubItems.Append( Signal.NameY );
      ListViewSignals.DeleteSelected;
    end;
    2: begin
      Signal:= GetSignal( '', ListViewSignals.Selected.Caption );
      item:= ListViewDeformations.Items.Add;
      item.Caption:= Signal.SName;
      item.SubItems.Append( Signal.NameY );
      ListViewSignals.DeleteSelected;
    end;
    end;
  end;
end;

// Нажали на кнопку [<--]
procedure TForm1.ButtonRemoveClick(Sender: TObject);
var item : TListItem;
begin
  case PageControlParams.ActivePageIndex of
  0: if EditPressureName.Text<>'' then
  begin
    Signal:= GetSignal( '', EditPressureName.Text );
    item:= ListViewSignals.Items.Add;
    item.Caption:= Signal.SName;
    item.SubItems.Append( Signal.NameY );
    EditPressureName.Text:= 'параметр не выбран';
    EditT0.Text:= '0';
    EditTk.Text:= '0';
  end;
  1: begin
    if ListViewShifts.Selected<>Nil then
    begin
      Signal:= GetSignal( '', ListViewShifts.Selected.Caption );
      item:= ListViewSignals.Items.Add;
      item.Caption:= Signal.SName;
      item.SubItems.Append( Signal.NameY );
      ListViewShifts.DeleteSelected;
    end;
  end;
  2: begin
    if ListViewDeformations.Selected<>Nil then
    begin
      Signal:= GetSignal( '', ListViewDeformations.Selected.Caption );
      item:= ListViewSignals.Items.Add;
      item.Caption:= Signal.SName;
      item.SubItems.Append( Signal.NameY );
      ListViewDeformations.DeleteSelected;
    end;
  end;
  end;
end;

procedure TForm1.DblClickSignals(Sender: TObject);
begin
  if Sender=ListViewSignals then
    ButtonAddClick(Sender)
  else
  if (Sender=ListViewShifts) or (Sender=ListViewDeformations) then
    ButtonRemoveClick(Sender);
end;


// ВЫПОЛНИТЬ РАСЧЕТ
procedure TForm1.ButtonExecuteClick(Sender: TObject);
var t0, tk, PStep, nextP, prevP, d, dP, m0,mk ,d0: Double;
var Code : Integer;
var im0,imk,it0, itk : Integer; // индекс времени начала эксперимента (для каждого сигнала он свой - из-за разной дискретизации)
var i, j, sz,k : Integer;
var x0, dx, x : Double;
var MO : Double;
var Signal_flt : IWPSignal;
var Signal_flt_MO, Opt, dst2 : OleVariant;
var oper : IWPOperator;
var s : String;
var item : TListItem;
var goUP : Boolean;
var obj  : Variant;
var node : IWPNode;

var delta_t, delta_max, delta_min, effective_delta, effective_k, tmp_mo, tmp: Double;
var allow_process, last_cycle: boolean;
var ip0, ipk, i_mo, delta_t_points, idelta_max,idelta_min: integer;

var maxs,mins:array[0..256] of Double;
var imaxs,imins:array[0..256] of Integer;
var maxs_count,mins_count:integer;

var fmaxs,fmins:array[0..256] of Double;
var fimaxs,fimins:array[0..256] of Integer;
var fmaxs_count,fmins_count:integer;
begin

  if (LabelReportName.Text<>'') then
  begin
  ProgressBar1.Position:= 0;

  szTimesArray:= 0;
  // Подчищаем старые результаты
  WinPOS.UnlinkStr('/Signals/Результаты/IIRFlt_MO');
  WinPOS.UnlinkStr('/Signals/Результаты/Таблица_1');
  WinPOS.UnlinkStr('/Signals/Результаты/Таблица_2');
  WinPOS.Refresh;
  WinPOS.DoEvents;

  Val(EditTm0.Text, m0, Code);
  Val(EditTmk.Text, mk, Code);
  Val(EditT0.Text, t0, Code);
  Val(EditTk.Text, tk, Code);
  Val(EditStep.Text, PStep, Code);

  if (m0>=t0)then
   ShowMessage('Время начала расчета МО Tmo должно быть меньше, чем To!')
   else
  if (mk<=m0)then
   ShowMessage('Время начала расчета МО Tmo должно быть меньше, чем Tmk!')
   else
  begin

  WinPOS.Refresh;
  WinPOS.DoEvents;

  for i:=0 to usml.ParamCount-1 do
  begin
    // 1) Достаём исходный сигнал и его характеристики
    Signal:= usml.Parameter(i) as IWPSignal;
    sz:= Signal.size;
    x0:= Signal.StartX;
    dx:= Signal.DeltaX;

    // 2) Считаем МО по фрагменту
    it0:= Trunc((t0-x0)/dx);
    im0:= Trunc((m0-x0)/dx);
    imk:= Trunc((mk-x0)/dx);
    MO:= 0;

    for j:= im0 to imk-1 do
      MO:= MO + Signal.GetY(j);

    MO:= MO/(imk-im0);

    // 3) Вычитаем МО (пункт 3 ТЗ)
    Signal_flt:= GetSignal( 'IIRFlt', Signal.SName );
    oper:= WinPOS.GetObject('/Operators/Арифм. операции') as IWPOperator;
    oper.setproperty( 'kind', 1 ); //1
    oper.setproperty( 'const', MO );
    oper.Exec( Signal_flt, Signal_flt, refvar(Signal_flt_MO), refvar(dst2) );

    Signal_flt_MO.SName:= Signal.SName;
    WinPOS.Link('/Signals/Результаты/IIRFlt_MO/'+ExtractFileName(FileName), Signal_flt_MO.SName, Signal_flt_MO);
  end;

  WinPOS.Refresh;
  WinPOS.DoEvents;

  //----------------------------------------------------------------------------
  //ищем перепады
  Val(edPikDeltaT.Text, delta_t, Code);
  Val(edPikDeltaEff.Text, effective_delta, Code);
  effective_k:=StrToFloat(edPikKEff.Text);
  effective_delta:=trunc(effective_delta/2);
  
  //обнуляем массивы и переменные
  ChartPreview.SeriesList.Items[0].Clear;
  ChartPreview.SeriesList.Items[1].Clear;
  ChartPreview.SeriesList.Items[2].Clear;
       

  maxs_count:=0;
  mins_count:=0;
  fmaxs_count:=0;
  fmins_count:=0;

  for i:=0 to 255 do
  begin
   maxs[i]:=0;
   mins[i]:=0;
   imaxs[i]:=0;
   imins[i]:=0;

   fmaxs[i]:=0;
   fmins[i]:=0;
   fimaxs[i]:=0;
   fimins[i]:=0;
  end;

  //подготовка
  Signal:= GetSignal( 'IIRFlt_MO', EditPressureName.Text );
  sz:= Signal.size;
  x0:= Signal.StartX;
  dx:= Signal.DeltaX;
  it0:= Trunc((t0-x0)/dx);
  itk:= Round((tk-x0)/dx);

  allow_process:=true;

  delta_t_points:=Round(delta_t/dx);

  ip0:=it0;
  ipk:=ip0+delta_t_points;

  maxs_count:=0;
  mins_count:=0;  

  //======================================  
  //ищем перепады
  while (allow_process)do
  begin
   delta_max:=Signal.GetY(ip0);
   idelta_max:=ip0;
   delta_min:=delta_max;
   idelta_min:=ip0;

   //ищем максимумы и минимумы на периоде
   for i:=ip0+1 to ipk-1 do
   begin
      d:= Signal.GetY(i);
      if (d>delta_max)then begin delta_max:=d; idelta_max:=i;end;
      if (d<delta_min)then begin delta_min:=d; idelta_min:=i;end;
   end;

   //если индекс максимума не равен индексам границ - сохраням  
   if ((idelta_max<>ipk-1) AND (idelta_max<>ip0))then
   begin
      maxs[maxs_count]:=delta_max;
      imaxs[maxs_count]:=idelta_max;
      Inc(maxs_count);
   end;

   //если индекс минимума не равен индексам границ - сохраням
   if ((idelta_min<>ipk-1) AND (idelta_min<>ip0))then
   begin
      mins[mins_count]:=delta_min;
      imins[mins_count]:=idelta_min;
      Inc(mins_count);
   end;

   //определение периода и возможности продолжения поиска
   if (last_cycle<>true)then
   begin
      ip0:=ipk;
      if (ip0+delta_t_points>itk)then
      begin
         ipk:=itk;
         last_cycle:=true;
      end
      else
         ipk:=ip0+delta_t_points;
         
      allow_process:=true;
   end
   else
      allow_process:=false;
  end;

  //======================================
  //фильтруем перепады по условию
  if (maxs_count<>0)then
     for i:=0 to maxs_count-1 do
     begin
      tmp_mo:=0;

      //подготовка границ
      ip0:=imaxs[i]-round(effective_delta/dx);
      if (ip0<it0)then ip0:=it0;

      ipk:=imaxs[i]+round(effective_delta/dx);
      if (ipk>itk)then ipk:=itk;

      //считаем МО
      for i_mo:=ip0 to ipk-1 do
         tmp_mo:=tmp_mo+Signal.GetY(i_mo);

      tmp_mo:=tmp_mo/(ipk-ip0);

      if (maxs[i]-tmp_mo>=effective_k)then
      begin
         ChartPreview.SeriesList.Items[1].AddXY(imaxs[i]*dx, maxs[i]);
         fmaxs[fmaxs_count]:=maxs[i];
         fimaxs[fmaxs_count]:=imaxs[i];
         Inc(fmaxs_count);
      end;
     end;

  //фильтруем перепады по условию
  if (mins_count<>0)then
     for i:=0 to mins_count-1 do
     begin
      tmp_mo:=0;

      //подготовка границ
      ip0:=imins[i]-round(effective_delta/dx);
      if (ip0<it0)then ip0:=it0;

      ipk:=imins[i]+round(effective_delta/dx);
      if (ipk>itk)then ipk:=itk;
      //считаем МО
      for i_mo:=ip0 to ipk-1 do
         tmp_mo:=tmp_mo+abs(Signal.GetY(i_mo));

      tmp_mo:=tmp_mo/(ipk-ip0);

      if (tmp_mo-abs(mins[i])>=effective_k)then
      begin
         ChartPreview.SeriesList.Items[2].AddXY(imins[i]*dx, mins[i]);
         fmins[fmins_count]:=mins[i];
         fimins[fmins_count]:=imins[i];
         Inc(fmins_count);
      end;
     end;


  // 4) Ищем моменты времени... (пункт 4 ТЗ)
  Signal:= GetSignal( 'IIRFlt_MO', EditPressureName.Text );
  sz:= Signal.size;
  x0:= Signal.StartX;
  dx:= Signal.DeltaX;
  it0:= Trunc((t0-x0)/dx);
  itk:= Round((tk-x0)/dx);

  TimesArray[0]:= t0;
  szTimesArray:= 1;

  dP:= PStep;
//  dP:= PStep/20;
  nextP:= PStep;
  d0:= Signal.GetY(it0);
  prevP:= d-PStep;
  goUP:= true;

  {
  for i:=it0 to itk-1 do
  begin
    x:= x0 + i*dx;
    d:= Signal.GetY(i);
    //if ((d>=nextP) and goUP) or ((d>=nextP+dP) and not goUP) then // Поднялись на полочку выше
    if (d>=nextP) then // Поднялись на полочку выше
    begin
      TimesArray[szTimesArray]:= x;
      Inc(szTimesArray);
      prevP:= prevP+PStep;
      nextP:= nextP+PStep;
    end
    else
    //if ((d<=prevP) and not goUp) or ((d<=prevP-dP) and goUP) then // Спустились на полочку ниже
    if (d<=prevP) then // Спустились на полочку ниже
    begin
      TimesArray[szTimesArray]:= x;
      Inc(szTimesArray);
      nextP:= nextP-PStep;
      prevP:= prevP-PStep;
    end
  end;
  }
  for i:=it0+1 to itk-1 do
  begin
    x:= x0 + i*dx;
    d:=Signal.GetY(i);
    dp:=abs(d0-d);
    if (dp>=PStep) then
    begin
      TimesArray[szTimesArray]:= x;
      Inc(szTimesArray);
      d0:=d;
    end;
  end;


  TimesArray[szTimesArray]:= tk;
  Inc(szTimesArray);

  //-----------------------------------------------------------------
  //добавляем в сигнал значения перепадов
  if (fmaxs_count<>0)then
     for i:=0 to fmaxs_count-1 do
     begin
        TimesArray[szTimesArray]:= fimaxs[i]*dx;
        Inc(szTimesArray);
     end;

  if (fmins_count<>0)then
     for i:=0 to fmins_count-1 do
     begin
        TimesArray[szTimesArray]:= fimins[i]*dx;
        Inc(szTimesArray);
     end;

  //-----------------------------------------------------------------     
  //сортируем
  allow_process:=true;
  while (allow_process) do
  begin
   szTimesArray1:=0;
   for i:=0 to szTimesArray-2 do
   begin
      tmp:=TimesArray[i];

      if (tmp>TimesArray[i+1])then
      begin
         TimesArray[i]:=TimesArray[i+1];
         TimesArray[i+1]:=tmp;
         Inc(szTimesArray1);
      end;
   end;

   if (szTimesArray1=0)then allow_process:=false;
  end;

  // 5) Формируем расчетные сигналы... (пункт 6 и 7 ТЗ)
  CreateResult( 'Таблица_1', EditPressureName.Text );
  CreateResult( 'Таблица_2', EditPressureName.Text );

  for i:=0 to ListViewShifts.Items.Count-1 do
  begin
    item:= ListViewShifts.Items.Item[i];
    CreateResult( 'Таблица_1', item.Caption );
  end;

  for i:=0 to ListViewDeformations.Items.Count-1 do
  begin
    item:= ListViewDeformations.Items.Item[i];
    CreateResult( 'Таблица_2', item.Caption );
  end;

  WinPOS.Refresh;
  WinPOS.DoEvents;

  ProgressBar1.StepBy(25);
  ShowPreview(EditPressureName.Text);

  if (rbReport_doc.Checked) then
     SaveReport
  else
     SaveReportCSV;
  end

  end
    
  else
   ShowMessage('Файл протокола не выбран!');
end;

procedure TForm1.CreateResult( SubPath, Name : String );
var i, ix : Integer;
var NewSignal : IWPSignal;
var x, x0, dx, y : Double;
begin
  NewSignal:= WinPOS.CreateSignalXY(VT_R8,VT_R8) as IWPSignal;
  NewSignal.size:= szTimesArray;
  NewSignal.SName:= Name;
  WinPOS.Link( '/Signals/Результаты/'+SubPath+'/'+ExtractFileName(FileName), Name, NewSignal );

  Signal:= GetSignal( 'IIRFlt_MO', Name );
  x0:= Signal.StartX;
  dx:= Signal.DeltaX;

  NewSignal.NameX:= Signal.NameX;
  NewSignal.NameY:= Signal.NameY;

  for i:= 0 to szTimesArray-1 do
  begin
    x:= TimesArray[i];
    ix:= Trunc((x-x0)/dx);
    y:= Signal.GetY(ix);
    NewSignal.SetX( i, x );
    NewSignal.SetY( i, y );
  end;
end;

procedure TForm1.LoadFile();
var i : Integer;
var item : TListItem;
var Freq : Double;
var Signal_flt, OptIIRFilt, Err : OleVariant;
var S : string;
var obj : Variant;
begin
  LabelFileName.Text:= FileName;
  if FileName<>'' then // если файл был выбран
  begin
    // загружаем файл
    usml:= WinPOS.LoadUsml(FileName) as IWPUSML;
    BringToFront;

    // Подчищаем старые результаты
    WinPOS.UnlinkStr('/Signals/Результаты/IIRFlt');
    WinPOS.Refresh;
    WinPOS.DoEvents;

    ListViewSignals.Clear;

    for i:=0 to usml.ParamCount-1 do
    begin
      Signal:= usml.Parameter(i) as IWPSignal;
      Freq:= 1/Signal.DeltaX;
      //2.4 Рекурсивная фильтрация:
      // Настройка параметров:
      //   - тип аппроксимации: Баттерворт (1)
      //   - тип фильтра: ФНЧ (1)
      //   - число двухполюсников (порядок*2): 4
      //   - частота среза: 2.0000
      //   - неравномерность в полосе пропускания: 1
      Str(Freq:15:6,s);
      if (Freq>=10) then
        OptIIRFilt:= ' iType = 1 , iKind = 1 , nOrder = 2 , nRipple = 1 , fsr = 2.0 , fs = ' + s
      else
      if (Freq>=5) and (Freq<10) then
        OptIIRFilt:= ' iType = 1 , iKind = 1 , nOrder = 2 , nRipple = 1 , fsr = 1.0 , fs = ' + s;

      RunIIRFiltering( Signal, Signal_flt, OptIIRFilt, Err);

      Signal_flt.SName:= Signal.SName;
      WinPOS.Link('/Signals/Результаты/IIRFlt/'+ExtractFileName(FileName), Signal_flt.SName, Signal_flt);

      item:= ListViewSignals.Items.Add;
      item.Caption:= Signal.SName;
      item.SubItems.Append( Signal.NameY );
    end;

    WinPOS.Refresh;
    WinPOS.DoEvents;
  end;
end;

procedure TForm1.ButtonLoadFileClick(Sender: TObject);
begin
  // открываем файл с помощью стандартного диалога WinПОС
  FileName:= WinPOS.USMLDialog();
  LoadFile;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //ItemInChart:= Nil;
end;

procedure TForm1.CheckBoxPreviewClick(Sender: TObject);
var item : TListItem;
begin
  if CheckBoxPreview.Checked then
  begin
  item:=nil;
    if ListViewSignals.Selected<>Nil then
      item:= ListViewSignals.Selected
    else
    if ListViewShifts.Selected<>Nil then
      item:= ListViewShifts.Selected
    else
    if ListViewDeformations.Selected<>Nil then
      item:= ListViewDeformations.Selected;
    if (item<>nil)then
    ShowPreview(item.Caption);
  end
  else
    ShowPreview('');
end;

procedure TForm1.ShowPreview(signame : String);
var i, sz, Code ,cnt: Integer;
var x, x0, dx : Double;
var t0, tk : Double;
var it0, itk : Integer;
var M : Integer;
begin
  if CheckBoxPreview.Checked and (signame<>'') and (signame<>'параметр не выбран') then
  begin
    Signal:= GetSignal( 'IIRFlt', signame );
    ChartPreview.SeriesList.Items[0].Clear;

    ChartPreview.Title.Text.Clear;
    ChartPreview.Title.Text.Append(Signal.SName);
    sz:= Signal.size;
    x0:= Signal.StartX;
    dx:= Signal.DeltaX;

    // Отрисовка только выбранного участка времени
    Val(EditT0.Text, t0, Code);
    Val(EditTk.Text, tk, Code);
    if (CheckBoxInterval.Checked) and (t0<>tk) then
    begin
      it0:= Trunc((t0-x0)/dx);
      itk:= Round((tk-x0)/dx);
    end
    else
    begin
      it0:= 0;
      itk:= sz-1;
    end;

    // Прореживание на случай очень больших сигналов (рисуем не более 2000 точек)
    M:= 1;
    if (itk-it0)>2000 then
      M:= (itk-it0) div 2000;

    cnt:=0;
    for i:=it0 to (itk-1) do
    begin
    if (cnt>=M)then
    begin
      x:= x0 + i*dx;
      ChartPreview.SeriesList.Items[0].AddXY( x, Signal.GetY(i));
      cnt:=0;
    end;
      Inc(cnt);
    end;
    NameSignalInChart:= Signal.SName;
  end
  else
  begin
    ChartPreview.SeriesList.Items[0].Clear;
    ChartPreview.Title.Text.Clear;
    ChartPreview.Title.Text.Append('Предварительный просмотр отключен');
  end;
end;

procedure TForm1.ShowPreviewMO(signame : String);
var i, sz, Code ,cnt: Integer;
var x, x0, dx : Double;
var t0, tk : Double;
var it0, itk : Integer;
var M : Integer;
begin
  if CheckBoxPreview.Checked and (signame<>'') and (signame<>'параметр не выбран') then
  begin
    Signal:= GetSignal( 'IIRFlt', signame );
    ChartPreview.SeriesList.Items[0].Clear;

    ChartPreview.Title.Text.Clear;
    ChartPreview.Title.Text.Append(Signal.SName);
    sz:= Signal.size;
    x0:= Signal.StartX;
    dx:= Signal.DeltaX;

    // Отрисовка только выбранного участка времени
    Val(EditTm0.Text, t0, Code);
    Val(EditTmk.Text, tk, Code);
    if (CheckBoxInterval.Checked) and (t0<>tk) then
    begin
      it0:= Trunc((t0-x0)/dx);
      itk:= Round((tk-x0)/dx);
    end
    else
    begin
      it0:= 0;
      itk:= sz-1;
    end;

    // Прореживание на случай очень больших сигналов (рисуем не более 2000 точек)
    M:= 0;
    if (itk-it0)>119000 then
      M:= (itk-it0) div 119000;

    cnt:=0;
    for i:=it0 to (itk-1) do
    begin
    if (cnt>=M)then
    begin
      x:= x0 + i*dx;
      ChartPreview.SeriesList.Items[0].AddXY( x, Signal.GetY(i));
      cnt:=0;
    end;
      Inc(cnt);
    end;
    NameSignalInChart:= Signal.SName;
  end
  else
  begin
    ChartPreview.SeriesList.Items[0].Clear;
    ChartPreview.Title.Text.Clear;
    ChartPreview.Title.Text.Append('Предварительный просмотр отключен');
  end;
end;

procedure TForm1.CheckBoxIntervalClick(Sender: TObject);
begin
  ShowPreview(NameSignalInChart);
end;

procedure TForm1.EditTkChange(Sender: TObject);
begin
  if CheckBoxInterval.Checked then
    ShowPreview(NameSignalInChart);
end;

procedure TForm1.OnPressSpace(Sender: TObject; var Key: Char);
begin
  if Key=' ' then
     DblClickSignals(Sender);
end;

procedure TForm1.ButtonClearClick(Sender: TObject);
begin
  ListViewShifts.Clear;
  ListViewDeformations.Clear;
  EditPressureName.Text:= 'параметр не выбран';
  EditStep.Text:= '5';
end;

procedure TForm1.EditPressureNameClick(Sender: TObject);
begin
  ShowPreview(EditPressureName.Text);
end;

procedure TForm1.rbReport_docClick(Sender: TObject);
var FileName:String;
begin
   CheckBoxShowWordInRuntime.Enabled:=true;
   if (ReportFileName<>'')then
   begin
      ReportFileName:=ChangeFileExt(ReportFileName,'.doc');
      LabelReportName.Text:=ReportFileName;
   end;
end;

procedure TForm1.rbReport_csvClick(Sender: TObject);
begin
   CheckBoxShowWordInRuntime.Enabled:=false;
   if (ReportFileName<>'')then
   begin
      ReportFileName:=ChangeFileExt(ReportFileName,'.csv');
      LabelReportName.Text:=ReportFileName;
   end;
end;

procedure TForm1.SaveReportCSV();
var i, j : Integer;
var W : Variant;
var s, ToWrite : String;
var cols, rows : Integer;
var Item: TListItem;
var BarStep, BarSteps: Double;
var F1: TextFile;
begin
   PP:=StrToInt(edDigits.Text);

   AssignFile(F1, ReportFileName);
   Rewrite(F1);
   ToWrite:='Номер изделия:;'+EditNumIzd.Text+';';
   WriteLn(F1,ToWrite);

   ToWrite:='Дата испытания:;'+EditDate.Text+';';
   WriteLn(F1,ToWrite);

   ToWrite:='Вид нагружения:;'+EditNagr.Text+';';
   WriteLn(F1,ToWrite);

   WriteLn(F1,'');
   WriteLn(F1,'');
   WriteLn(F1,'');      

    // Таблица 1
    cols:= szTimesArray+1;
    rows:= ListViewShifts.Items.Count+2;

    BarStep:=75/cols/(rows-2+ListViewDeformations.Items.Count);
    BarSteps:= 0;    

    Signal:= GetSignal( 'Таблица_1', EditPressureName.Text );

    // Строка времени
    ToWrite:=';;время;';
    for i:=0 to cols-2 do
    begin
      Str(Signal.GetX(i):MM:PP,s);
      s:= Trim(s);
      ToWrite:=ToWrite+s+';';
    end;
    WriteLn(F1,ToWrite);


    // Строка давления
    ToWrite:=';;'+Signal.SName+'['+Signal.NameY+']'+';';
    for i:=0 to cols-2 do
    begin
      Str(Signal.GetY(i):MM:PP,s); s:= Trim(s);
      ToWrite:=ToWrite+s+';';
    end;
    WriteLn(F1,ToWrite);    

    // Строки перемещений
    for j:=0 to rows-3 do
    begin
      item:= ListViewShifts.Items.Item[j];
      Signal:= GetSignal( 'Таблица_1', item.Caption );
      ToWrite:=';;'+Signal.SName+'['+Signal.NameY+']'+';';

      for i:=0 to cols-2 do
      begin
        Str(Signal.GetY(i):MM:PP,s); s:= Trim(s);
        ToWrite:=ToWrite+s+';';

        if (BarSteps>1) then
        begin
          ProgressBar1.StepBy(Trunc(BarSteps));
          BarSteps:= BarSteps-Trunc(BarSteps);
        end;
        BarSteps:= BarSteps+BarStep;
      end;
      WriteLn(F1,ToWrite);
    end;

    ToWrite:=';;Таблица 1. Зависимость перемещения от давления';
    WriteLn(F1,ToWrite);

   WriteLn(F1,'');
   WriteLn(F1,'');
   WriteLn(F1,'');

    // Таблица 2
    rows:= ListViewDeformations.Items.Count+2;

    Signal:= GetSignal( 'Таблица_2', EditPressureName.Text );

    // Строка времени
    ToWrite:=';;время;';
    for i:=0 to cols-2 do
    begin
      Str(Signal.GetX(i):MM:PP,s);
      s:= Trim(s);
      ToWrite:=ToWrite+s+';';
    end;
    WriteLn(F1,ToWrite);    

    // Строка давления
    ToWrite:=';;'+Signal.SName+'['+Signal.NameY+']'+';';
    for i:=0 to cols-2 do
    begin
      Str(Signal.GetY(i):MM:PP,s); s:= Trim(s);
      ToWrite:=ToWrite+s+';';
    end;
    WriteLn(F1,ToWrite);

    // Строки деформаций
    for j:=0 to rows-3 do
    begin
      item:= ListViewDeformations.Items.Item[j];
      Signal:= GetSignal( 'Таблица_2', item.Caption );
      ToWrite:=';;'+Signal.SName+'['+Signal.NameY+']'+';';

      for i:=0 to cols-2 do
      begin
        Str(Signal.GetY(i):MM:PP,s); s:= Trim(s);
        ToWrite:=ToWrite+s+';';        

        if (BarSteps>1) then
        begin
          ProgressBar1.StepBy(Trunc(BarSteps));
          BarSteps:= BarSteps-Trunc(BarSteps);
        end;
        BarSteps:= BarSteps+BarStep;
      end;
      WriteLn(F1,ToWrite);
    end;

    ToWrite:=';;Таблица 2. Зависимость деформации от давления';
    WriteLn(F1,ToWrite);    

    WriteLn(F1,'');
    WriteLn(F1,'');

    ToWrite:='Испытания проводил;___________________';
    WriteLn(F1,ToWrite);

    ProgressBar1.Position:= 100;

   CloseFile(F1);  
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
SaveReportCSV;
end;

procedure TForm1.EditT0Change(Sender: TObject);
begin
  if CheckBoxInterval.Checked then
    ShowPreview(NameSignalInChart);
end;

procedure TForm1.EditTm0Click(Sender: TObject);
begin
  if CheckBoxInterval.Checked then
    ShowPreviewMO(EditPressureName.Text);
end;

procedure TForm1.EditTm0Change(Sender: TObject);
begin
  if CheckBoxInterval.Checked then
    ShowPreviewMO(NameSignalInChart);
end;

procedure TForm1.EditTmkChange(Sender: TObject);
begin
  if CheckBoxInterval.Checked then
    ShowPreviewMO(NameSignalInChart);
end;

procedure TForm1.EditTmkClick(Sender: TObject);
begin
  if CheckBoxInterval.Checked then
    ShowPreviewMO(EditPressureName.Text);
end;

procedure TForm1.EditT0Click(Sender: TObject);
begin
  if CheckBoxInterval.Checked then
    ShowPreview(EditPressureName.Text);
end;

procedure TForm1.EditTkClick(Sender: TObject);
begin
  if CheckBoxInterval.Checked then
    ShowPreview(EditPressureName.Text);
end;

end.
