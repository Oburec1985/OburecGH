unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Tabnotbk, ExtDlgs, Spin;

type
  TForm1 = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    Button1: TButton;
    ListBox1: TListBox;
    Button2: TButton;
    Button3: TButton;
    Button10: TButton;
    Button4: TButton;
    Memo1: TMemo;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Button9: TButton;
    FontDialog1: TFontDialog;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button25: TButton;
    Button32: TButton;
    TabbedNotebook2: TTabbedNotebook;
    ComboBox3: TComboBox;
    Button24: TButton;
    Button26: TButton;
    Button27: TButton;
    Button28: TButton;
    Button29: TButton;
    Button30: TButton;
    Button31: TButton;
    CheckBox6: TCheckBox;
    Edit1: TEdit;
    Button33: TButton;
    Button34: TButton;
    Button35: TButton;
    Button36: TButton;
    Button37: TButton;
    Button38: TButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button39: TButton;
    Button40: TButton;
    Button41: TButton;
    Label3: TLabel;
    Button42: TButton;
    Button43: TButton;
    Button44: TButton;
    Label4: TLabel;
    Button45: TButton;
    Button46: TButton;
    Button47: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button23Click(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure Button29Click(Sender: TObject);
    procedure Button30Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure ComboBox3Click(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure Button33Click(Sender: TObject);
    procedure Button34Click(Sender: TObject);
    procedure Button35Click(Sender: TObject);
    procedure Button36Click(Sender: TObject);
    procedure Button37Click(Sender: TObject);
    procedure Button38Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure Button39Click(Sender: TObject);
    procedure Button40Click(Sender: TObject);
    procedure Button41Click(Sender: TObject);
    procedure Button42Click(Sender: TObject);
    procedure Button43Click(Sender: TObject);
    procedure Button44Click(Sender: TObject);
    procedure Button45Click(Sender: TObject);
    procedure Button46Click(Sender: TObject);
    procedure Button47Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
   uses MyExcel;
   var ChartName:variant;

procedure TForm1.Button1Click(Sender: TObject);
 var a_:integer;
   rng_:string;
begin
if not CreateExcel then exit;
messagebox(handle,'','Запускаем Excel.',0);
VisibleExcel(true);
messagebox(handle,'','Отобразили Excel на экране.',0);
if AddWorkBook then begin
messagebox(handle,'','Создали новую книгу.',0);
AddSheet('Новый лист');
messagebox(handle,'','Добавили новый лист.',0);
DeleteSheet(2);
messagebox(handle,'','Удалили лист №2.',0);
GetSheets(ListBox1.Items);
messagebox(handle,'','Получили список листов!',0);
for a_:=1 to CountSheets do begin
    ListBox1.ItemIndex:=a_-1;
    SelectSheet(ListBox1.Items.Strings[a_-1]);
    messagebox(handle,'',pchar('Выбираем лист '+ListBox1.Items.Strings[a_-1]+' !'),0);
    end;

SetRange(3,'A1',234.45);
rng_:=GetRange(3,'A1');
messagebox(handle,pchar(rng_),'Записываем и читаем ячейку.',0);

SaveWorkBookAs('c:\1.xls');
messagebox(handle,'','Сохранили книгу как "c:\1.xls".',0);
CloseWorkBook;
messagebox(handle,'','Закрыли книгу "c:\1.xls".',0);
                    end;
CloseExcel;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
if not CreateExcel then exit;
VisibleExcel(true);
if AddWorkBook then begin
   SelectSheet(1);
   Button3.Enabled:=true;
   Button10.Enabled:=true;
   end;
end;


procedure TForm1.Button3Click(Sender: TObject);
 var a_:integer;
   rng_:string;
begin
for a_:=1 to 100 do begin
    SetRange(1,'A'+inttostr(a_),a_);
    SetRange(1,'B'+inttostr(a_),234.45);
    SetRange(1,'C'+inttostr(a_),random(1000));
    end;
Button4.Enabled:=true;
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
SaveWorkBookAs('c:\1.xls');
messagebox(handle,'','Сохранили книгу как "c:\1.xls".',0);
CloseWorkBook;
messagebox(handle,'','Закрыли книгу "c:\1.xls".',0);
CloseExcel;
end;

procedure TForm1.Button4Click(Sender: TObject);
 var a_:integer;
   eee_,bbb_:string;
begin
for a_:=1 to 100 do begin
    eee_:=GetRange(1,'A'+inttostr(a_));
    eee_:=eee_+'/';
    bbb_:=GetRange(1,'B'+inttostr(a_));
    eee_:=eee_+bbb_;
    eee_:=eee_+'/';
    bbb_:=GetRange(1,'C'+inttostr(a_));
    eee_:=eee_+bbb_+'      '+GetFormatRange(1,'C'+inttostr(a_));
    Memo1.Lines.Add(eee_);
    end;
Button5.Enabled:=true;
end;



procedure TForm1.Button5Click(Sender: TObject);
begin
SetColumnWidth(1,2,50.25);
SetRowHeight(1,2,30.10);
Button6.Enabled:=true;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
messagebox(handle,'','Изменение формата данных ячейки A1',0);
SetFormatRange(1,'A1:C5','0,000');
Button7.Enabled:=true;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
SetHorizontalAlignment(1,'A1',xlHAlignCenter);
SetVerticalAlignment(1,'A1',xlVAlignBottom);
Button8.Enabled:=true;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
SetOrientation(1,'A1:C5',-90);
CheckBox1.Enabled:=true;
CheckBox2.Enabled:=true;
CheckBox3.Enabled:=true;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
SetWrapText(1,'A1',CheckBox1.Checked);
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
SetMergeCells(1,'A1:B2',CheckBox2.Checked);
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
SetShrinkToFit(1,'A1',CheckBox3.Checked);
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
if FontDialog1.Execute then SetFontRange(1,'A1',FontDialog1.Font);
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
SetFontRangeEx(1,'A1',xlUnderlineStyleDouble,1,true,false);
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
SetBorderRange(1,'B2',xlDiagonalDown,xlDashDot,xlThin,0,rgb(50,150,230));
SetBorderRange(1,'B2',xlDiagonalUp,xlDashDot,xlThin,0,rgb(50,150,230));
SetBorderRange(1,'B2',xlEdgeBottom,xlDouble,xlThin,0,rgb(0,200,230));
SetBorderRange(1,'B2',xlEdgeLeft,xlDouble,xlThin,0,rgb(0,200,230));
SetBorderRange(1,'B2',xlEdgeRight,xlDouble,xlThin,0,rgb(0,200,230));
SetBorderRange(1,'B2',xlEdgeTop,xlDouble,xlThin,0,rgb(0,200,230));
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
SetPatternRange(1,'A1:C4',xlPatternGray8,-1,-1,rgb(100,25,200),rgb(0,100,200));
end;

procedure TForm1.Button14Click(Sender: TObject);
begin
if not CreateExcel then exit;
VisibleExcel(true);
if AddWorkBook then begin
   SelectSheet(1);
   Button15.Enabled:=true;
   Button16.Enabled:=true;
   end;
ComboBox1.ItemIndex:=0;
ComboBox2.ItemIndex:=0;
end;

procedure TForm1.Button15Click(Sender: TObject);
 var a_:integer;
   rng_:string;
begin
for a_:=1 to 20 do begin
    SetRange(1,'A'+inttostr(a_),a_);
    SetRange(1,'B'+inttostr(a_),234.45);
    SetRange(1,'C'+inttostr(a_),random(1000));
    end;
end;


procedure TForm1.Button16Click(Sender: TObject);
begin
SaveWorkBookAs('c:\1.xls');
messagebox(handle,'','Сохранили книгу как "c:\1.xls".',0);
CloseWorkBook;
messagebox(handle,'','Закрыли книгу "c:\1.xls".',0);
CloseExcel;
end;

procedure TForm1.Button17Click(Sender: TObject);
begin
PrintPreview;
end;

procedure TForm1.Button18Click(Sender: TObject);
begin
ShowPrintDialog;
end;

procedure TForm1.Button19Click(Sender: TObject);
begin
PrintPreviewEx;
end;

procedure TForm1.Button20Click(Sender: TObject);
begin
if not OpenPictureDialog1.Execute then exit;
SetBackgroundPicture(1,OpenPictureDialog1.FileName);
end;

procedure TForm1.CheckBox4Click(Sender: TObject);
begin
DisplayGridlines(CheckBox4.Checked);
end;

procedure TForm1.CheckBox5Click(Sender: TObject);
begin
PrintGridlines(1,CheckBox5.Checked);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
case ComboBox1.ItemIndex of
0:PageOrientation(1,xlPortrait);
1:PageOrientation(1,xlLandscape);
end;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
case ComboBox2.ItemIndex of
0:WindowView(xlNormalView);
1:WindowView(xlPageBreakPreview);
end;
end;

procedure TForm1.Button21Click(Sender: TObject);
begin
AddChart(ChartName,xl3DColumn);
SetSourceData(1{ChartName},2,'A1:F6',xlRows);
end;

procedure TForm1.Button22Click(Sender: TObject);
begin
if not CreateExcel then exit;
VisibleExcel(true);
if AddWorkBook then begin
   SelectSheet(1);
   Button23.Enabled:=true;
   end;
end;

procedure TForm1.Button23Click(Sender: TObject);
begin
SaveWorkBookAs('c:\1.xls');
messagebox(handle,'','Сохранили книгу как "c:\1.xls".',0);
CloseWorkBook;
messagebox(handle,'','Закрыли книгу "c:\1.xls".',0);
CloseExcel;
end;

procedure TForm1.Button24Click(Sender: TObject);
begin
PositionPlotArea(ChartName,1,1,200,200);
end;

procedure TForm1.Button25Click(Sender: TObject);
 var a_:integer;
   rng_:string;
begin
randomize;
SetRange(2,'A1','AAAA');
SetRange(2,'B1','BBBB');
SetRange(2,'C1','CCCC');
SetRange(2,'D1','AAAA');
SetRange(2,'E1','BBBB');
SetRange(2,'F1','CCCC');
for a_:=2 to 5 do begin
    SetRange(2,'A'+inttostr(a_),a_-1);
    SetRange(2,'B'+inttostr(a_),random(1000));
    SetRange(2,'C'+inttostr(a_),random(1000));
    SetRange(2,'D'+inttostr(a_),random(1000));
    SetRange(2,'E'+inttostr(a_),random(1000));
    SetRange(2,'F'+inttostr(a_),random(1000));
    end;
end;

procedure TForm1.Button26Click(Sender: TObject);
begin
BorderPlotArea(ChartName,rgb(100,200,250),xlDashDot,xlThin);
end;

procedure TForm1.Button27Click(Sender: TObject);
begin
BrushPlotArea(ChartName,rgb(100,200,150),xlPatternCrissCross,rgb(200,100,50));
end;

procedure TForm1.Button28Click(Sender: TObject);
 var dir_:string;
begin
GetDir(0,dir_);
if not OpenPictureDialog1.Execute then begin ChDir(dir_); exit; end;
ChDir(dir_);
BrushPlotAreaFromFile(ChartName,OpenPictureDialog1.FileName);
end;

procedure TForm1.Button29Click(Sender: TObject);
begin
BorderChartArea(ChartName,rgb(100,200,250),xlDashDot,xlThin);
end;

procedure TForm1.Button30Click(Sender: TObject);
begin
BrushChartArea(ChartName,rgb(80,230,100),xlPatternCrissCross,rgb(210,80,150));
end;

procedure TForm1.Button31Click(Sender: TObject);
 var dir_:string;
begin
GetDir(0,dir_);
if not OpenPictureDialog1.Execute then begin ChDir(dir_); exit; end;
ChDir(dir_);
BrushChartAreaFromFile(ChartName,OpenPictureDialog1.FileName);
end;

procedure TForm1.Button32Click(Sender: TObject);
 var dir_:string;
begin
messagebox(handle,'','Заголовок диаграммы',0);
TextChartTitle(ChartName,'Заголовок диаграммы');
messagebox(handle,'','Новые координаты заголовка диаграммы',0);
PositionChartTitle(ChartName,1,1);
messagebox(handle,'','Рамка заголовка диаграммы',0);
BorderChartTitle(ChartName,RGB(100,150,245),1,1);
messagebox(handle,'','Цвет области заголовка диаграммы',0);
BrushChartTitle(ChartName,RGB(100,120,210),1,rgb(45,120,170));
messagebox(handle,'','Заливка области заголовка диаграммы из файла',0);
GetDir(0,dir_);
if not OpenPictureDialog1.Execute then begin ChDir(dir_); exit; end;
ChDir(dir_);
BrushChartTitleFromFile(ChartName,OpenPictureDialog1.FileName);
end;



procedure TForm1.ComboBox3Click(Sender: TObject);
begin
SetChartType(ChartName,ComboBox3.ItemIndex+51);
end;

procedure TForm1.CheckBox6Click(Sender: TObject);
begin
if not CheckBox6.Checked then SetChartLocation(ChartName,'Отдельный лист',xlLocationAsNewSheet)
                         else SetChartLocation(ChartName,Edit1.Text,xlLocationAsObject);
end;

procedure TForm1.Button33Click(Sender: TObject);
begin
PositionSizeLegend(ChartName,1,1,200,200);
end;

procedure TForm1.Button34Click(Sender: TObject);
begin
BorderLegend(ChartName,rgb(100,200,250),xlDashDot,xlThin);
end;

procedure TForm1.Button35Click(Sender: TObject);
begin
BrushLegend(ChartName,rgb(100,200,150),xlPatternCrissCross,rgb(200,100,50));
end;

procedure TForm1.Button36Click(Sender: TObject);
 var dir_:string;
begin
GetDir(0,dir_);
if not OpenPictureDialog1.Execute then begin ChDir(dir_); exit; end;
ChDir(dir_);
BrushLegendFromFile(ChartName,OpenPictureDialog1.FileName);
end;

procedure TForm1.Button37Click(Sender: TObject);
begin
if not FontDialog1.Execute then exit;
FontLegendEntries(ChartName,1,FontDialog1.Font);
end;

procedure TForm1.Button38Click(Sender: TObject);
begin
AxisChart(ChartName,'Ось категорий','Ось значений','Ось ряда');
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
ElevationChart(ChartName,SpinEdit1.Value);
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
RotationChart(ChartName,SpinEdit2.Value);
end;

procedure TForm1.Button39Click(Sender: TObject);
begin
BorderWalls(ChartName,rgb(100,200,250),xlDashDot,xlThin);
end;

procedure TForm1.Button40Click(Sender: TObject);
begin
BrushWalls(ChartName,rgb(80,230,100),xlPatternCrissCross,rgb(210,80,150));
end;

procedure TForm1.Button41Click(Sender: TObject);
 var dir_:string;
begin
GetDir(0,dir_);
if not OpenPictureDialog1.Execute then begin ChDir(dir_); exit; end;
ChDir(dir_);
BrushWallsFromFile(ChartName,OpenPictureDialog1.FileName);
end;

procedure TForm1.Button42Click(Sender: TObject);
begin
BorderFloor(ChartName,rgb(100,200,250),xlDashDot,xlThin);
end;

procedure TForm1.Button43Click(Sender: TObject);
begin
BrushFloor(ChartName,rgb(80,230,100),xlPatternCrissCross,rgb(210,80,150));
end;

procedure TForm1.Button44Click(Sender: TObject);
 var dir_:string;
begin
GetDir(0,dir_);
if not OpenPictureDialog1.Execute then begin ChDir(dir_); exit; end;
ChDir(dir_);
BrushFloorFromFile(ChartName,OpenPictureDialog1.FileName);
end;

procedure TForm1.Button45Click(Sender: TObject);
begin
BorderSeries(ChartName,random(SeriesCount(ChartName))+1,rgb(random(256),random(256),random(256)),xlDashDot,xlThin);
end;

procedure TForm1.Button46Click(Sender: TObject);
begin
BrushSeries(ChartName,random(SeriesCount(ChartName))+1,rgb(random(256),random(256),random(256)),xlPatternCrissCross,rgb(random(256),random(256),random(256)));
end;

procedure TForm1.Button47Click(Sender: TObject);
begin
BarShapeSeries(ChartName,random(SeriesCount(ChartName))+1,random(6));
end;

end.
