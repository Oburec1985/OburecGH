unit u3120Frm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, inifiles,
  Dialogs, ImgList, ExtCtrls, Grids, ComCtrls, StdCtrls, Buttons,
  uRecBasicFactory,
  uComponentServises,
  u3120Factory,
  uControlObj, uModeObj,
  u3120ControlObj, pngimage;

type
  TFrm3120 = class(TRecFrm)
    DeskGB: TGroupBox;
    PlayPanel: TPanel;
    PlayBtn: TSpeedButton;
    PausePanel: TPanel;
    PauseBtn: TSpeedButton;
    StopPanel: TPanel;
    StopBtn: TSpeedButton;
    GroupBox3: TGroupBox;
    ComTimeLabel: TLabel;
    ModeTimeLabel: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    ComTimeEdit: TEdit;
    ModeTimeEdit: TEdit;
    ProgTimeEdit: TEdit;
    TimeUnitsCB: TComboBox;
    ModeStopTime: TEdit;
    ContinueCB: TCheckBox;
    ConfirmModeCB: TCheckBox;
    GetNotifyCB: TCheckBox;
    Timer1: TTimer;
    ImageListBtnStates: TImageList;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    RightGB: TGroupBox;
    ControlPropSG: TStringGrid;
    Panel2: TPanel;
    ControlPropE: TEdit;
    ModePropE: TEdit;
    Splitter3: TSplitter;
    TableModeGB: TGroupBox;
    TableModeSG: TStringGrid;
    AlarmStopLabel: TLabel;
    AlarmStopBtn: TImage;
    PChLabel: TLabel;
    FreqConvLamp: TImage;
    TestTypeLabel: TLabel;
    TestTypeCB: TComboBox;
    Panel3: TPanel;
    Edit1: TEdit;
    ReportBtn: TButton;
    procedure TableModeSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    // Режим подтверждения перехода
    m_CurControl: cControlobj;
    m_CurMode: cModeObj;
    m_uiThread: integer;
    // форма посчитана фабрикой класса. Нужно для ограничения числа форм
    m_counted: boolean;
    m_curCol, m_curRow: integer;
    finit, fload: boolean;


    m_val: string;
    m_row, m_col: integer;
    m_apply:boolean;
    m_timerid, m_timerid_res: cardinal;
 public
    // собственная сортировка для контролов
    m_CustSort:boolean;
    m_ViewControls:tlist;

  public
    // происходит в doRepaint
    procedure UpdateView;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
    //
    procedure testInit;
  end;

var
  Frm3120: TFrm3120;
  g_3120Factory:c3120Factory;

const
  clGrass = TColor($00A7FED0);
  c_MCount = 6;

implementation

{$R *.dfm}

{ TFrm3120 }

constructor TFrm3120.create(Aowner: tcomponent);
begin
  inherited;
  testInit;
end;

destructor TFrm3120.destroy;
begin

  inherited;
end;

procedure TFrm3120.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

procedure TFrm3120.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

procedure TFrm3120.TableModeSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: integer;
  str: string;
  I: integer;
begin
  sg := TStringGrid(Sender);
  Color := sg.Canvas.Brush.Color;
  if aRow=0 then
  begin
    Rect.Left:=Rect.Left+1;
    Rect.Right:=Rect.Right-1;
    Rect.Top:=Rect.Top-1;
    Rect.Bottom:=Rect.Bottom+1;

    sg.Canvas.Brush.Color := clGray;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
    exit;
  end;
  // окрас строки с выбраным контролом
  if ARow=3 then
  begin
    sg.Canvas.Brush.Color := clGrass;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
  end;
  if ACol=3 then
  begin
    sg.Canvas.Brush.Color := CLgREEN;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
  end;
  // измерения
  if (ACol=5) then
  begin
    sg.Canvas.Brush.Color := clYellow;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
  end;
  // измерения
  if (ACol=6) or (ACol=7) then
  begin
    sg.Canvas.Brush.Color := clCream;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
  end;
end;

procedure TFrm3120.testInit;
var
  I: Integer;
begin
  TableModeSG.RowCount:=10;
  TableModeSG.ColCount:=c_MCount+2;
  TableModeSG.Cells[0, 1] := 'Время работы';
  //режимы
  TableModeSG.Cells[1,0]:='Режим_1';
  TableModeSG.Cells[2,0]:='Режим_2';
  TableModeSG.Cells[3,0]:='Режим_3';
  TableModeSG.Cells[4,0]:='Режим_Стоп';
  TableModeSG.Cells[5,0]:='Измерено М';
  TableModeSG.Cells[6,0]:='Измерено N';

  // время работы
  TableModeSG.Cells[1,1]:='1, час';
  TableModeSG.Cells[2,1]:='0.5, час';
  TableModeSG.Cells[3,1]:='1.5, час';
  TableModeSG.Cells[4,1]:='10, мин';
  // время работы
  TableModeSG.Cells[0,2]:='M1';
  TableModeSG.Cells[1,2]:='1000 об/мин';
  TableModeSG.Cells[2,2]:='3000 Нм';
  TableModeSG.Cells[3,2]:='2500 Нм';
  TableModeSG.Cells[4,2]:='0 Нм';
  TableModeSG.Cells[5,2]:='2488 Нм';
  TableModeSG.Cells[6,2]:='2300 Об/мин';


  TableModeSG.Cells[0,3]:='M2';
  TableModeSG.Cells[1,3]:='1000 об/мин';
  TableModeSG.Cells[2,3]:='2500 Нм';
  TableModeSG.Cells[3,3]:='1500 Нм';
  TableModeSG.Cells[4,3]:='0 Нм';
  TableModeSG.Cells[5,3]:='1495 Нм';
  TableModeSG.Cells[6,3]:='1334 Об/мин';


  TableModeSG.Cells[0,4]:='M3';
  TableModeSG.Cells[1,4]:='1000 об/мин';
  TableModeSG.Cells[2,4]:='3000 Нм';
  TableModeSG.Cells[3,4]:='2000 Нм';
  TableModeSG.Cells[4,4]:='0 Нм';
  TableModeSG.Cells[5,4]:='1995 Нм';
  TableModeSG.Cells[6,4]:='1834 Об/мин';

  TableModeSG.Cells[0,5]:='M4';
  TableModeSG.Cells[1,5]:='1000 об/мин';
  TableModeSG.Cells[2,5]:='3000 Нм';
  TableModeSG.Cells[3,5]:='2000 Нм';
  TableModeSG.Cells[4,5]:='0 Нм';
  TableModeSG.Cells[5,5]:='1995 Нм';
  TableModeSG.Cells[6,5]:='1834 Об/мин';

  TableModeSG.Cells[0,6]:='M5';
  TableModeSG.Cells[1,6]:='1000 об/мин';
  TableModeSG.Cells[2,6]:='3000 Нм';
  TableModeSG.Cells[3,6]:='2000 Нм';
  TableModeSG.Cells[4,6]:='0 Нм';
  TableModeSG.Cells[5,6]:='1995 Нм';
  TableModeSG.Cells[6,6]:='1834 Об/мин';


  TableModeSG.Cells[0,7]:='Торможение';
  TableModeSG.Cells[1,7]:='0%';
  TableModeSG.Cells[2,7]:='0%';
  TableModeSG.Cells[3,7]:='30%';
  TableModeSG.Cells[4,7]:='0%';
  TableModeSG.Cells[5,7]:='29%';

  TableModeSG.Cells[0,8]:='Поворот';
  TableModeSG.Cells[1,8]:='0%';
  TableModeSG.Cells[2,8]:='30%';
  TableModeSG.Cells[3,8]:='50%';
  TableModeSG.Cells[4,8]:='80%';
  TableModeSG.Cells[5,8]:='50,5%';

  TableModeSG.Cells[0,9]:='Авар. передача';
  TableModeSG.Cells[1,9]:='0%';
  TableModeSG.Cells[2,9]:='0%';
  TableModeSG.Cells[3,9]:='0%';
  TableModeSG.Cells[4,9]:='0%';
  TableModeSG.Cells[5,9]:='0%';


  SGChange(TableModeSG);
  TableModeSG.ColWidths[0] := TableModeSG.ColWidths[0]+20;

  ControlPropE.Text:='M2_лев';

  ControlPropSG.RowCount:=13;
  ControlPropSG.ColCount:=c_MCount;
  ControlPropSG.Cells[0,0]:='Свойство';
  ControlPropSG.Cells[1,0]:='Режим_1';
  ControlPropSG.Cells[2,0]:='Режим_2';
  ControlPropSG.Cells[3,0]:='Режим_3';
  ControlPropSG.Cells[4,0]:='Режим_Стоп';

  ControlPropSG.Cells[0,1]:='P';
  ControlPropSG.Cells[1,1]:='1';
  ControlPropSG.Cells[2,1]:='1';
  ControlPropSG.Cells[3,1]:='1.1';
  ControlPropSG.Cells[4,1]:='1';

  ControlPropSG.Cells[0,2]:='I';
  ControlPropSG.Cells[1,2]:='0.1';
  ControlPropSG.Cells[2,2]:='0.1';
  ControlPropSG.Cells[3,2]:='0.15';
  ControlPropSG.Cells[4,2]:='0.1';


  ControlPropSG.Cells[0,3]:='D';
  ControlPropSG.Cells[1,3]:='0.01';
  ControlPropSG.Cells[2,3]:='0.01';
  ControlPropSG.Cells[3,3]:='0.015';
  ControlPropSG.Cells[4,3]:='0.01';


  ControlPropSG.Cells[0,4]:='защита T';
  ControlPropSG.Cells[1,4]:='Вкл.';
  ControlPropSG.Cells[2,4]:='Вкл.';
  ControlPropSG.Cells[3,4]:='Вкл.';
  ControlPropSG.Cells[4,4]:='Вкл.';

  ControlPropSG.Cells[0,5]:='Уровень T';
  ControlPropSG.Cells[1,5]:='200, С';
  ControlPropSG.Cells[2,5]:='200, С';
  ControlPropSG.Cells[3,5]:='200, С';
  ControlPropSG.Cells[4,5]:='200, С';


  ControlPropSG.Cells[0,6]:='защита Pм';
  ControlPropSG.Cells[1,6]:='Вкл.';
  ControlPropSG.Cells[2,6]:='Вкл.';
  ControlPropSG.Cells[3,6]:='Вкл.';
  ControlPropSG.Cells[4,6]:='Вкл.';

  ControlPropSG.Cells[0,7]:='Уровень Pм';
  ControlPropSG.Cells[1,7]:='1, Атм.';
  ControlPropSG.Cells[2,7]:='1, Атм.';
  ControlPropSG.Cells[3,7]:='1, Атм.';
  ControlPropSG.Cells[4,7]:='1, Атм.';

  ControlPropSG.Cells[0,8]:='защита M/N';
  ControlPropSG.Cells[1,8]:='Вкл.';
  ControlPropSG.Cells[2,8]:='Вкл.';
  ControlPropSG.Cells[3,8]:='Вкл.';
  ControlPropSG.Cells[4,8]:='Вкл.';
  // уставка отправляемая в контроллер при превышении которой во время
  // измерения контроллер может уйти в защиту
  ControlPropSG.Cells[0,9]:='Уровень защита';
  ControlPropSG.Cells[1,9]:='50, об/мин';
  ControlPropSG.Cells[2,9]:='100, Нм';
  ControlPropSG.Cells[3,9]:='100, Нм';
  ControlPropSG.Cells[4,9]:='10, Нм';

  ControlPropSG.Cells[0,10]:='Работа по усл.';
  ControlPropSG.Cells[1,10]:='Вкл.';
  ControlPropSG.Cells[2,10]:='Вкл.';
  ControlPropSG.Cells[3,10]:='Вкл.';
  ControlPropSG.Cells[4,10]:='Вкл.';

  ControlPropSG.Cells[0,11]:='Тип режима';
  ControlPropSG.Cells[1,11]:='Приводной';
  ControlPropSG.Cells[2,11]:='Тормозной';
  ControlPropSG.Cells[3,11]:='Тормозной';
  ControlPropSG.Cells[4,11]:='Стоп';

  ControlPropSG.Cells[0,12]:='Ограничение скор. N';
  ControlPropSG.Cells[1,12]:='1, Гц';
  ControlPropSG.Cells[2,12]:='1, Гц';
  ControlPropSG.Cells[3,12]:='1, Гц';
  ControlPropSG.Cells[4,12]:='1, Гц';


  GridAddColumn(TableModeSG, 6);
  for I := 0 to 12 do
  begin
    TableModeSG.Cells[5,i]:=TableModeSG.Cells[4,i];
  end;
  TableModeSG.Cells[5,0]:='Имя режима';

  SGChange(ControlPropSG);
  ControlPropSG.ColWidths[0] := ControlPropSG.ColWidths[0]+30;
end;

procedure TFrm3120.UpdateView;
begin

end;

end.
