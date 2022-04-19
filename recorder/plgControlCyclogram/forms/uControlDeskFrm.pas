unit uControlDeskFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath,
  mathfunction,
  uRecorderEvents,
  uCyclogramreportFrm,
  uRTrig, uRCFunc,
  tags, ualarms,
  uSetList,
  uConfirmDlg,
  PluginClass, ImgList;

type

  TControlDeskFrm = class(TRecFrm)
    DeskGB: TGroupBox;
    Timer1: TTimer;
    PlayPanel: TPanel;
    PlayBtn: TSpeedButton;
    PausePanel: TPanel;
    PauseBtn: TSpeedButton;
    StopPanel: TPanel;
    StopBtn: TSpeedButton;
    ImageListBtnStates: TImageList;
    InfoLabel: TLabel;
    ModePauseTimeEdit: TEdit;
    Label2: TLabel;
    CfgPanel: TPanel;
    CfgBtn: TSpeedButton;
    CheckLength: TEdit;
    CheckLengthLabel: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Splitter2: TSplitter;
    GroupBox1: TGroupBox;
    ModePanel: TPanel;
    ProgramLabel: TLabel;
    ProgramCB: TComboBox;
    ProgramSG: TStringGrid;
    ModesListPanel: TGroupBox;
    ControlSG: TStringGrid;
    GroupBox2: TGroupBox;
    TrigSG: TStringGrid;
    TabSheet2: TTabSheet;
    TableModeGB: TGroupBox;
    TableModeSG: TStringGrid;
    Splitter3: TSplitter;
    RightGB: TGroupBox;
    ControlPropSG: TStringGrid;
    Panel1: TPanel;
    ControlPropE: TEdit;
    ModePropE: TEdit;
    OpenDialog1: TOpenDialog;
    GroupBox3: TGroupBox;
    ComTimeEdit: TEdit;
    ModeTimeEdit: TEdit;
    ProgTimeEdit: TEdit;
    ComTimeLabel: TLabel;
    ModeTimeLabel: TLabel;
    Label1: TLabel;
    TimeUnitsCB: TComboBox;
    ContinueCB: TCheckBox;
    ConfirmModeCB: TCheckBox;
    ActiveModeE: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure PauseBtnClick(Sender: TObject);
    function getControlFromSG(row: integer): ccontrolobj;
    procedure ControlSGDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure ProgramSGDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure ControlSGDblClick(Sender: TObject);
    procedure ControlSGMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ProgramSGDblClick(Sender: TObject);
    procedure TrigSGDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect;
      State: TGridDrawState);
    procedure CfgBtnClick(Sender: TObject);
    procedure ControlSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure TableModeSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure TableModeSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure TableModeSGDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ControlPropSGDblClick(Sender: TObject);
    procedure TableModeSGClick(Sender: TObject);
    procedure TimeUnitsCBDblClick(Sender: TObject);
    procedure TimeUnitsCBChange(Sender: TObject);
    procedure ControlPropSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
  private
    // Режим подтверждения перехода
    m_CurControl:cControlObj;
    m_CurMode:cModeObj;
    m_uiThread: integer;
    // форма посчитана фабрикой класса. Нужно для ограничения числа форм
    m_counted: boolean;
    m_curCol, m_curRow: integer;
    finit: boolean;
    SGbuttons: tlist;

    m_val:string;
    m_row,m_col:integer;
    m_timerid, m_timerid_res: cardinal;
    m_tolArray:cDoubleList;
  protected
    procedure ConfirmManualSwitchMode(m:tobject);
    function toSec(t:double):double;
    function SecToTime(t:double):double;
    procedure ModeTabSGEditCell(r,c:integer; val:string);
    procedure ControlSGEditCell(ARow, ACol: Integer; const Value: string);
    procedure FormCfgClose(Sender: TObject; var Action: TCloseAction);
    function getprogram(row: integer): cProgramObj;
    function getmode(row: integer): cModeObj;
    function getTableModeSGByCol(col: integer): cModeObj;
    function getControlFromTableModeSGByRow(Row: integer): cControlObj;
    procedure ClearSGButtons;
    procedure WndProc(var Message: TMessage); override;
    procedure CreateSGButtons;
    procedure ShowModeTable;
    // Показать регулояторы
    procedure ShowControls;
    // Показать Таблицу программ и режимов
    procedure ShowModes;
    procedure ShowControlPropsModes;
    // Показать триггеры
    procedure ShowTrigs;
    procedure InitSG;
    procedure updateviews;
    procedure UpdateTrigs;
    procedure UpdateTimers;
    procedure UpdateProgramsSG;
    procedure UpdateControlsSG;
    procedure UpdateControlsPropSG;
    procedure UpdateControlsPropSGmode(m:cModeObj);
    procedure SelectControl(c:cControlObj);
    procedure updateControlRow(c: ccontrolobj);
    function GetSelectMode: cModeObj;
    procedure ShowControlRow(c: ccontrolobj);
    procedure SetConName(con: ccontrolobj; row: integer);
    procedure SetConTask(con: ccontrolobj; row: integer);
    procedure SetConFeedback(con: ccontrolobj; row: integer);
    procedure CreateEvents;
    procedure DestroyEvents;
    procedure EnablePult(b_state: boolean);
    procedure doChangeRState(Sender: TObject);
    procedure doLeaveCfg(Sender: TObject);
    procedure doLoad(Sender: TObject);
    procedure doAddObj(Sender: TObject);
    procedure doShowStop(Sender: TObject);
    // вызывается при смене конфигурации циклограммы
    procedure Preview;
  public
    procedure Start;
    procedure continuePlay;
    procedure pause;
    procedure Stop;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor Create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IControlFrm = class(cRecBasicIFrm)
  public
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cControlFactory = class(cRecBasicFactory)
  private
    m_counter: integer;
  protected
    procedure AddEvents;
    procedure doDestroyForms; override;
    procedure doUpdateTags(Sender: TObject);
    procedure doStatusNONE(Sender: TObject);
  public
    procedure decFrmCounter;
    procedure incFrmCounter;
    constructor Create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

procedure TimeProc(hwnd, uMsg, idEvent, dwTime: DWord); stdcall;

var
  ControlDeskFrm: TControlDeskFrm;

const
  c_Pic = 'CONTROLPULT';
  c_Name = 'Пульт управления';

const
  c_Control_defXSize = 770;
  c_Control_defYSize = 490;
  // ctrl+shift+G
  // ['{ACCBBA41-AD43-44D6-8E74-36A32434A1F0}']
  IID_ControlFactory: TGuid = (D1: $ACCBBA41; D2: $AD43; D3: $44D6;
    D4: ($8E, $74, $36, $A3, $24, $34, $A1, $F0));

  c_Log_ControlDeskFrm = true;
  c_ModeTable_headerSize = 2;
  c_ModeTable_headerCol = 2;
  c_headerSize = 1;
  c_Col_Control = 0;
  c_Col_Task = 1;
  c_Col_Feedback = 2;
  c_Col_State = 3;

  c_Col_mode = 0;
  c_Col_Length = 1;
  c_Col_Prog = 2;

  c_Col_TrigName = 0;
  c_Col_TrigState = 1;
  c_Col_TrigEnabled = 2;

  c_color_ON = CLgREEN;
  c_color_OFF = clBtnFace;

  c_Stop_State = 2;
  c_Pause_State = 1;
  c_Play_State = 0;

implementation

{$R *.dfm}
{ cControlFactory }

function TrigBoolToStr(b: boolean): string;
begin
  if b then
    result := 'Вкл.'
  else
    result := 'Выкл.'
end;

procedure cControlFactory.AddEvents;
begin

end;

constructor cControlFactory.Create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_ControlFactory;
  // GateSettingsFrm  := TGateSettingsFrm.Create(nil);
  // SelectChannelFrm := TSelectChannelFrm.Create(nil);

  AddEvents;
end;

procedure cControlFactory.decFrmCounter;
begin
  dec(m_counter);
end;

procedure cControlFactory.incFrmCounter;
begin
  inc(m_counter);
end;

destructor cControlFactory.destroy;
begin
  inherited;
end;

function cControlFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := IControlFrm.Create();
    incFrmCounter;
  end;
end;

procedure cControlFactory.doDestroyForms;
begin
  inherited;
  // decFrmCounter;
end;

procedure cControlFactory.doSetDefSize(var pSize: SIZE);
begin
  pSize.cx := c_Control_defXSize;
  pSize.cy := c_Control_defYSize;
end;

procedure cControlFactory.doStatusNONE(Sender: TObject);
begin

end;

procedure cControlFactory.doUpdateTags(Sender: TObject);
begin

end;

constructor TControlDeskFrm.Create(Aowner: tcomponent);
VAR
  mThread: integer;
begin
  inherited;
  m_counted := false;
  m_uiThread := GetCurrentThreadId;
  mThread := MainThreadID;
  finit := false;
  SGbuttons := tlist.Create;

  EnablePult(false);

  CreateEvents;

  InfoLabel.Caption := 'UIThread: ' + inttostr(m_uiThread)
    + ' mThread: ' + inttostr(mThread);
end;

procedure TControlDeskFrm.CreateEvents;
begin
  addplgevent('TControlDeskFrm_doAddObj', E_OnAddObj, doAddObj);
  addplgevent('TControlDeskFrm_doLoad', E_OnLoadObjMng, doLoad);
  addplgevent('TControlDeskFrm_doChangeRState', c_RC_DoChangeRCState,  doChangeRState);
  addplgevent('TControlDeskFrm_doLeaveCfg', c_RC_LeaveCfg, doLeaveCfg);
  g_conmng.Events.AddEvent('TControlDeskFrm_doStopControlMng', E_OnStopControlMng, doShowStop);
end;

procedure TControlDeskFrm.DestroyEvents;
begin
  removeplgEvent(doAddObj, E_OnAddObj);
  removeplgEvent(doLoad, E_OnLoadObjMng);
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
  removeplgEvent(doLeaveCfg, c_RC_LeaveCfg);
  if g_conmng <> nil then
    g_conmng.Events.removeEvent(doShowStop, E_OnStopControlMng);
end;

procedure TimeProc(hwnd, uMsg, idEvent, dwTime: DWord);
// Procedure TimeProc(uID:UINT;uMsg:UInt;dwUser:DWord;dw1:DWord;dw2:DWord);
begin
  ControlDeskFrm.Timer1Timer(nil);
end;

procedure TControlDeskFrm.doChangeRState(Sender: TObject);
var
  Rstate: boolean;
  p:cprogramobj;
  c:cControlObj;
  I: Integer;
begin
  if self <> nil then
  begin
    Rstate := RStatePlay;
    EnablePult(Rstate);
    Timer1.Interval := round(GetREFRESHPERIOD * 1000);
    if Rstate then
    begin
      ShowTrigs;
      // m_timerid_res:=SetTimer(handle, m_timerid, Timer1.Interval, @TimeProc);
      // m_timerid_res:=SetTimer(MainThreadID, m_timerid, Timer1.Interval, @TimeProc);
      Timer1.Enabled := true
    end
    else
    begin
      // последняя итерация для срабатывания действий заложенных в стоптриг
      p:=g_conmng.getProgram(0);
      if p<>nil then
      begin
        p.exec;
        for I := 0 to p.ControlCount - 1 do
        begin
          c:=p.getOwnControl(i);
          c.exec;
        end;
      end;
      if g_conmng.configChanged then
      begin
        preview;
        g_conmng.configChanged := false;
      end;
      Stop;
      // if g_conmng.state<>c_stop then showmessage('Остановили Timer в состоянии c_TryStop');
      Timer1.Enabled := false;
      ProgramSG.Invalidate;
      // KillTimer(handle,m_timerid);
      // KillTimer(MainThreadID,m_timerid);
    end;
  end;
end;

procedure TControlDeskFrm.doLeaveCfg(Sender: TObject);
begin
  preview;
end;

procedure TControlDeskFrm.doLoad(Sender: TObject);
begin
  preview;
end;

procedure TControlDeskFrm.doAddObj(Sender: TObject);
begin
  if not m_counted then
  begin
    cControlFactory(m_f).incFrmCounter;
    m_counted := true;
  end;
end;

destructor TControlDeskFrm.destroy;
begin

  cControlFactory(m_f).decFrmCounter;
  DestroyEvents;
  ClearSGButtons;
  SGbuttons.destroy;

  inherited;
end;




procedure TControlDeskFrm.FormCreate(Sender: TObject);
begin
  m_timerid := 2;
  m_tolArray:=cDoubleList.create;
  InitSG;
end;

procedure TControlDeskFrm.FormDestroy(Sender: TObject);
begin
  m_tolArray.destroy;
end;

procedure TControlDeskFrm.FormShow(Sender: TObject);
var
  m: cModeObj;
begin
  // m:=GetSelectMode;
  // m.m_StateTag.PushValue(1,-1);
  if g_conmng.configChanged then
  begin
    preview;
    g_conmng.configChanged := false;
  end;
end;

procedure TControlDeskFrm.InitSG;
begin
  ControlSG.RowCount := 2;
  ControlSG.ColCount := 4;

  ControlSG.Cells[c_Col_Control, 0] := 'Регулятор';
  ControlSG.Cells[c_Col_Task, 0] := 'Задание';
  ControlSG.Cells[c_Col_Feedback, 0] := 'Измерено';
  ControlSG.Cells[c_Col_State, 0] := 'Состояние';
  SGChange(ControlSG);

  ProgramSG.RowCount := 2;
  ProgramSG.ColCount := 3;
  ProgramSG.Cells[c_Col_mode, 0] := 'Режим';
  ProgramSG.Cells[c_Col_Length, 0] := 'Длит.';
  ProgramSG.Cells[c_Col_Prog, 0] := 'Программа';
  SGChange(ProgramSG);

  TrigSG.RowCount := 2;
  TrigSG.ColCount := 3;
  TrigSG.Cells[c_Col_TrigName, 0] := 'Триггер';
  TrigSG.Cells[c_Col_TrigState, 0] := 'Значение';
  TrigSG.Cells[c_Col_TrigEnabled, 0] := 'Включен';
  SGChange(TrigSG);

  ControlPropSG.RowCount := 5;
  ControlPropSG.ColCount := 2;

  ControlPropSG.Cells[0, 1] := 'Thi';
  ControlPropSG.Cells[0, 2] := 'Tlo';
  ControlPropSG.Cells[0, 3] := 'Мин.';
  ControlPropSG.Cells[0, 4] := 'Макс.';

end;

procedure TControlDeskFrm.ShowControlPropsModes;
var
  I: Integer;
  p:cprogramObj;
  m:cmodeobj;
begin
  p:=g_conmng.getProgram(0);
  if m_CurControl=nil then
  begin
    if p.ControlCount>0 then
      m_CurControl:=p.getOwnControl(0);
  end;
  for I := 0 to p.ModeCount - 1 do
  begin
    m:=p.getMode(i);
    ControlPropSG.Cells[1+i, 0] := m.name;
  end;
  SGChange(ControlPropSG);
end;


procedure TControlDeskFrm.SelectControl(c: cControlObj);
begin
  m_CurControl:=c;
  UpdateControlsPropSG;
end;

procedure TControlDeskFrm.SetConFeedback(con: ccontrolobj; row: integer);
begin
  ControlSG.Cells[c_Col_Task, row] := floattostr(con.Feedback);
end;

procedure TControlDeskFrm.SetConTask(con: ccontrolobj; row: integer);
begin
  ControlSG.Cells[c_Col_Task, row] := floattostr(con.task);
end;

procedure TControlDeskFrm.SetConName(con: ccontrolobj; row: integer);
begin
  ControlSG.Cells[c_Col_Control, row] := con.name;
end;

procedure TControlDeskFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;
  ContinueCB.Checked:=a_pIni.ReadBool(str, 'LoadState', false);
  ConfirmModeCB.Checked:=a_pIni.ReadBool(str, 'ConfirmModeChange', true);
  TimeUnitsCB.ItemIndex:=a_pIni.ReadInteger(str, 'Units', 0);
end;


procedure TControlDeskFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;
  a_pIni.WriteBool(str, 'LoadState', ContinueCB.Checked);
  a_pIni.WriteBool(str, 'ConfirmModeChange', ConfirmModeCB.Checked);
  a_pIni.WriteInteger(str, 'Units', TimeUnitsCB.ItemIndex);
end;



procedure TControlDeskFrm.PauseBtnClick(Sender: TObject);
VAR
  b: boolean;
begin
  //LogRecorderMessage('TControlDeskFrm_PauseBtnClick_enter');
  b := PausePanel.Color = CLgREEN;
  if b then
    b := false
  else
    b := true;
  if b then
    pause
  else
  begin
    //Start;
  end;
  //LogRecorderMessage('TControlDeskFrm_PauseBtnClick_exit');
end;

procedure TControlDeskFrm.PlayBtnClick(Sender: TObject);
VAR
  b: boolean;
begin
  //LogRecorderMessage('TControlDeskFrm_PlayBtnClick_enter');
  b := PlayPanel.Color = CLgREEN;
  if b then
    b := false
  else
    b := true;
  if b then
  begin
    Start
  end
  else
  begin
    //pause;
  end;
  //LogRecorderMessage('TControlDeskFrm_PlayBtnClick_exit');
end;

procedure TControlDeskFrm.ProgramSGDblClick(Sender: TObject);
var
  m: cModeObj;
  pPnt:       TPoint;  // Координаты курсора
  xCol, xRow: integer; // Адрес ячейки таблицы
begin
  GetCursorPos( pPnt );
  pPnt:= TStringGrid(Sender).ScreenToClient( pPnt );
  // Находим позицию нашей ячейки
  xCol:= TStringGrid(Sender).MouseCoord( pPnt.X, pPnt.Y ).X;
  xRow:= TStringGrid(Sender).MouseCoord( pPnt.X, pPnt.Y ).Y;
  if xrow=0 then exit;
  
  if (g_conmng.state=c_Pause) or g_conmng.AllowUserModeSelect then
  begin
    if g_conmng.state<>c_stop then
    begin
      m := getmode(xRow);
      if m=nil then
        exit;
      if g_conmng.state=c_play then
        m.TryActive
      else
      begin
        if g_conmng.state=c_pause then
        begin
          m.active:=true;
          m.Exec;
        end;
      end;
    end;
  end;
end;

procedure TControlDeskFrm.ProgramSGDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: integer;
  p: cProgramObj;
  m: cModeObj;
  str: string;
  I: integer;
begin
  if (g_conmng.state=c_Play) or (g_conmng.state=c_Pause) then
  begin
    for I := 0 to g_conmng.ProgramCount - 1 do
    begin
      p := g_conmng.getprogram(I);
      m := p.ActiveMode;
      if m <> nil then
      begin
        sg := TStringGrid(Sender);
        str := sg.Cells[c_Col_mode, ARow];
        if str = m.name then
        begin
          Color := sg.Canvas.Brush.Color;
          case p.State of
            c_play:
              sg.Canvas.Brush.Color := CLgREEN;
            c_pause:
              sg.Canvas.Brush.Color := clYellow;
          end;
          sg.Canvas.FillRect(Rect);
          sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
          sg.Canvas.Brush.Color := Color;
        end;
      end;
    end;
  end;
end;


procedure TControlDeskFrm.Preview;
begin
  if PageControl1.TabIndex=0 then
  begin
    ShowControls;
    ShowModes;
    ShowTrigs;
  end;
  if PageControl1.TabIndex=1 then
  begin
    ShowControlPropsModes;
    UpdateControlsPropSG;
    ShowModeTable;
  end;
end;

procedure TControlDeskFrm.ShowControls;
var
  I, row: integer;
  con: ccontrolobj;
begin
  ControlSG.RowCount := c_headerSize + g_conmng.ControlsCount;
  for I := 0 to g_conmng.ControlsCount - 1 do
  begin
    row := I + c_headerSize;
    con := g_conmng.getControlObj(I);
    SetConName(con, row);
    SetConTask(con, row);
    ShowControlRow(con);
  end;
  CreateSGButtons;
end;

procedure TControlDeskFrm.ShowModeTable;
var
  I, col, row: integer;
  con: ccontrolobj;
  p:cProgramObj;
  m:cmodeobj;
  j: Integer;
  t:ctask;
begin
  // 2 - кол-во строк сверху имена режимов
  TableModeSG.RowCount := c_ModeTable_headerSize + g_conmng.ControlsCount;
  p:=g_conmng.getProgram(0);
  if p=nil then
    exit;

  TableModeSG.ColCount:=  c_ModeTable_headerCol +p.ModeCount;
  TableModeSG.Cells[0,1]:='Время работы';
  for I := 0 to p.ModeCount - 1 do
  begin
    row := c_ModeTable_headerSize-1;
    col := i+1;
    m:=p.getMode(i);
    TableModeSG.Cells[col,0]:=m.caption;
    TableModeSG.Cells[col,row]:=formatstrnoe(SecToTime(m.ModeLength), 2);
  end;
  for I := 0 to p.ControlCount - 1 do
  begin
    con:=p.getOwnControl(i);
    TableModeSG.Cells[0,c_ModeTable_headerSize+i]:=con.caption;
    for j := 0 to p.ModeCount - 1 do
    begin
      m:=p.getMode(j);
      t:=m.gettask(con.name);
      if t<>nil then
        TableModeSG.Cells[c_ModeTable_headerCol-1+j,c_ModeTable_headerSize+i]:=formatstrnoe(t.task,2);
    end;
  end;
  SGChange(TableModeSG);
end;

function TControlDeskFrm.getControlFromSG(row: integer): ccontrolobj;
var
  cname: string;
  imageind, X, Y: integer;
begin
  cname := ControlSG.Cells[c_Col_Control, row];
  result := g_conmng.getControlObj(cname);
end;

function TControlDeskFrm.getmode(row: integer): cModeObj;
var
  p: cProgramObj;
  str: string;
begin
  p := getprogram(row);
  str := ProgramSG.Cells[c_Col_mode, row];
  result := p.getmode(str);
end;

function TControlDeskFrm.getprogram(row: integer): cProgramObj;
var
  str: string;
begin
  str := ProgramSG.Cells[c_Col_Prog, row];
  result := g_conmng.getprogram(str);
end;

procedure TControlDeskFrm.ControlPropSGDblClick(Sender: TObject);
var
  m: cModeObj;
  t:ctask;
  pPnt:       TPoint;  // Координаты курсора
  xCol, xRow: integer; // Адрес ячейки таблицы
  str, key:string;
  changebool:boolean;
  function getM(row:integer):cModeObj;
  var
    p:cprogramobj;
  begin
    str:=TStringGrid(Sender).Cells[0, row];
    p:=g_conmng.getProgram(0);
    result:=p.getMode(str);
  end;
begin
  GetCursorPos( pPnt );
  pPnt:= TStringGrid(Sender).ScreenToClient( pPnt );
  // Находим позицию нашей ячейки
  xCol:= TStringGrid(Sender).MouseCoord( pPnt.X, pPnt.Y ).X;
  xRow:= TStringGrid(Sender).MouseCoord( pPnt.X, pPnt.Y ).Y;
  changebool:=false;
  //case xCol of
  //  1: // ШИМ
  //  begin
  //    m:=getM(xrow);
  //    t:=m.GetTask(ControlPropE.Text);
  //    key:='PWM_state';
  //    changebool:=true;
  //  end;
  //  4: // Зоны
  //  begin
  //    m:=getM(xrow);
  //    t:=m.GetTask(ControlPropE.Text);
  //    key:='Zone_state';
  //    changebool:=true;
  //  end;
  //end;
  //if changebool then
  //begin
  //  str:=t.getParam(key);
  //  if str='Вкл' then
  //  begin
  //    str:='Выкл';
  //  end
  //  else
  //  begin
  //    str:='Вкл';
  //  end;
  //  t.setParam(key,str);
  //  TStringGrid(Sender).Cells[xCol, xRow]:=str;
  //end;
end;

procedure TControlDeskFrm.ControlPropSGSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
var
  c, r:integer;
  p:cprogramobj;
  mode:cmodeobj;
  con:ccontrolObj;
  t:ctask;
  str:string;
begin
  m_val:=value;
  m_col:=acol;
  m_row:=arow;
  r:=arow;
  c:=acol;
  p:=g_conmng.getProgram(0);
  if p=nil then exit;

  if r>0 then
  begin
    if checkstr(Value) then
    begin
      // редактирование ШИМ
      if (r=2) or (r=3) then
      begin
        mode:=p.getMode(r-1);
        str:=ControlPropE.text;
        con:=p.getOwnControl(str);
        if con<>nil then
        begin
          t:=mode.gettask(con.name);
          if c=2 then
          begin
            t.setParam('PWM_Thi',Value)
          end
          else
          begin
            t.setParam('PWM_Tlo',Value);


          end;
        end;
        if mode.active then
        begin
          mode.m_applyed:=false;
        end;
      end;
    end;
  end;
end;

procedure TControlDeskFrm.ControlSGDblClick(Sender: TObject);
var
  c: ccontrolobj;
begin
  if m_curCol = c_Col_State then
  begin
    c := getControlFromSG(m_curRow);
    if c = nil then
      exit;
    if c.PlayState then
    begin
      c.State := c_Stop;
    end
    else
    begin
      if (g_conmng.State = c_play) or (g_conmng.State = c_pause) then
      begin
        c.State := c_play;
      end;
    end;
  end;
end;

procedure TControlDeskFrm.ControlSGDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
var
  btn: Tbitmap;
  c: ccontrolobj;
  imageind, X, Y: integer;
begin
  if ARow < c_headerSize then
    exit;
  if ACol = c_Col_State then
  begin // Простое рисование
    ControlSG.Canvas.FillRect(Rect);
    btn := Tbitmap(ControlSG.Objects[ACol, ARow]);
    if btn = nil then
      exit;
    btn.Height := ImageListBtnStates.Height;
    btn.Width := ImageListBtnStates.Width;
    c := getControlFromSG(ARow);
    if c<>nil then
    begin
      case c.State of
        c_play:
          imageind := c_Play_State;
        c_Stop:
          imageind := c_Stop_State;
        c_pause:
          imageind := c_Pause_State;
      else
        begin
          imageind := c_Stop_State;
        end;
      end;
    end
    else
      exit;
    btn.Assign(nil);
    ImageListBtnStates.GetBitmap(imageind, btn);
    X := round((Rect.Left + Rect.Right - btn.Width) / 2);
    Y := round((Rect.Top + Rect.Bottom - btn.Height) / 2);
    ControlSG.Canvas.Draw(X, Y, btn);
  end;
end;

procedure TControlDeskFrm.ControlSGEditCell(ARow, ACol: Integer; const Value: string);
var
  t:ctask;
  c: ccontrolobj;
  step:cstepval;
  stepname:string;
begin
  if g_conmng.state<>c_Pause then exit;

  if ACol<>c_Col_Task then exit;

  c := getControlFromSG(ARow);
  if c<>nil then
  begin
    if isValue(value) then
    begin
      c.SetManualTask(strtofloatext(value));
    end;
  end;
end;

procedure TControlDeskFrm.ControlSGMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  ControlSG.MouseToCell(X, Y, m_curCol, m_curRow);
  if m_curCol = c_Col_State then
  begin
    ControlSG.Options := ControlSG.Options - [goEditing];
  end
  else
  begin
    ControlSG.Options := ControlSG.Options + [goEditing];
  end;
end;

procedure TControlDeskFrm.ControlSGSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  m_val:=value;
  m_col:=acol;
  m_row:=arow;
  ControlSGEditCell(m_row, m_col, m_val);
end;

procedure TControlDeskFrm.CfgBtnClick(Sender: TObject);
begin
  if CfgPanel.Color = c_color_ON then
  begin
    CyclogramReportFrm.hide;
    CfgPanel.Color := c_color_OFF;
  end
  else
  begin
    if not assigned(CyclogramReportFrm.OnClose) then
      CyclogramReportFrm.OnClose := FormCfgClose;
    CyclogramReportFrm.Show;
    CfgPanel.Color := c_color_ON;
  end;
end;

procedure TControlDeskFrm.FormCfgClose(Sender: TObject;
  var Action: TCloseAction);
begin
  CfgBtnClick(self);
end;

procedure TControlDeskFrm.ClearSGButtons;
var
  btn: Tbitmap;
  I: integer;
begin
  for I := 0 to SGbuttons.Count - 1 do
  begin
    btn := Tbitmap(SGbuttons.Items[I]);
    btn.destroy;
  end;
  SGbuttons.clear;
end;



procedure TControlDeskFrm.TimeUnitsCBChange(Sender: TObject);
var
  r, c, i, j:integer;
  p:cprogramObj;
  m:cmodeobj;
begin
  if TimeUnitsCB.itemindex<>-1 then
  begin
    p:=g_conmng.getprogram(0);
    if p<>nil then
    begin
      // обновляем отображение времени
      for j := 0 to p.ModeCount - 1 do
      begin
        m:=p.getMode(j);
        r := c_ModeTable_headerSize-1;
        c := j+1;
        TableModeSG.Cells[c,r]:=formatstrNoE(SecToTime(m.ModeLength), 2);
      end;
      SGChange(TableModeSG);
    end;
  end;
end;

procedure TControlDeskFrm.TimeUnitsCBDblClick(Sender: TObject);
var
  r, c, i, j:integer;
  p:cprogramObj;
  m:cmodeobj;
begin
  i:=TimeUnitsCB.itemindex;
  inc(i);
  if i<TimeUnitsCB.Items.Count then
  begin
    TimeUnitsCB.itemindex:=i;
  end
  else
    TimeUnitsCB.itemindex:=0;
  TimeUnitsCBChange(self);
end;

function TControlDeskFrm.toSec(t: double): double;
begin
  case TimeUnitsCB.ItemIndex of
    0: result:=t; //sec
    1: result:=t*60; //min
    2: result:=t*3600; //hour
  end;
end;


function TControlDeskFrm.SecToTime(t: double): double;
begin
  case TimeUnitsCB.ItemIndex of
    0: result:=t; //sec
    1: result:=t/60;           //min
    2: result:=t/3600;           //hour
  end;
end;

procedure TControlDeskFrm.CreateSGButtons;
var
  btn: Tbitmap;
  row, I: integer;
begin
  if ControlSG.RowCount < SGbuttons.Count then
  begin
    while ControlSG.RowCount <> SGbuttons.Count do
    begin
      I := SGbuttons.Count - 1;
      btn := Tbitmap(SGbuttons.Items[I]);
      btn.destroy;
      SGbuttons.Delete(I);
    end;
  end;
  while SGbuttons.Count < ControlSG.RowCount - c_headerSize do
  begin
    row := SGbuttons.Count + c_headerSize;
    btn := Tbitmap.Create();
    ControlSG.Objects[c_Col_State, row] := btn;
    SGbuttons.Add(btn);
  end;
end;

procedure TControlDeskFrm.ShowTrigs;
var
  I, j, tcount, row: integer;
  t: cBaseTrig;
begin
  tcount := g_conmng.TrigCount;
  TrigSG.RowCount := c_headerSize + tcount;
  row := c_headerSize;
  for I := 0 to g_conmng.TrigCount - 1 do
  begin
    t := g_conmng.gettrig(I);
    TrigSG.Cells[c_Col_TrigName, row] := t.name;
    TrigSG.Cells[c_Col_TrigState, row] := TrigBoolToStr(t.ownState);
    TrigSG.Cells[c_Col_TrigEnabled, row] := TrigBoolToStr(t.Enabled);
    inc(row);
  end;
  if GetCurrentThreadId = m_uiThread then
    SGChange(TrigSG);
end;

procedure TControlDeskFrm.ShowModes;
var
  I, j, mcount, row: integer;
  p: cProgramObj;
  m: cModeObj;
  c: ccontrolobj;
  t: ctask;
begin
  mcount := g_conmng.ModeCount;
  ProgramSG.RowCount := c_headerSize + mcount;
  row := c_headerSize;
  for I := 0 to g_conmng.ProgramCount - 1 do
  begin
    p := g_conmng.getprogram(I);
    for j := 0 to p.ModeCount - 1 do
    begin
      m := p.getmode(j);
      ProgramSG.Cells[c_Col_mode, row] := m.name;
      ProgramSG.Cells[c_Col_Length, row] := floattostr(SecToTime(m.ModeLength));
      ProgramSG.Cells[c_Col_Prog, row] := p.name;
      inc(row);
    end;
  end;
  if g_conmng.ProgramCount > 0 then
  begin
    SGChange(ProgramSG);
    p := g_conmng.getprogram(0);
    m := p.ActiveMode;
    if m <> nil then
    begin
      for j := 0 to m.taskCount - 1 do
      begin
        c := m.gettask(j).control;
      end;
    end;
  end;
end;

procedure TControlDeskFrm.Start;
var
  ir: irecorder;
begin
  ir := getIRecorder;
  if g_conmng.State = c_Stop then
  begin
    g_conmng.Start;
    if ContinueCB.Checked then
    begin
      g_conmng.LoadState;
    end;
  end
  else
  begin
    if g_conmng.State = c_pause then
    begin
      g_conmng.continuePlay;
    end;
  end;
  // подсветка панелек
  PlayPanel.Color := CLgREEN;
  PausePanel.Color := clBtnFace;
  StopPanel.Color := clBtnFace;
end;

procedure TControlDeskFrm.continuePlay;
var
  ir: irecorder;
begin
  ir := getIRecorder;
  g_conmng.continuePlay;
  // подсветка панелек
  PlayPanel.Color := CLgREEN;
  PausePanel.Color := clBtnFace;
  StopPanel.Color := clBtnFace;
end;

procedure TControlDeskFrm.Stop;
begin
  g_conmng.Stop;
end;

procedure TControlDeskFrm.doShowStop(Sender: TObject);
begin
  StopPanel.Color := CLgREEN;
  PlayPanel.Color := clBtnFace;
  PausePanel.Color := clBtnFace;
end;

procedure TControlDeskFrm.EnablePult(b_state: boolean);
begin
  ControlSG.Enabled:=b_state;

  ProgTimeEdit.Enabled:=b_state;
  ModeTimeEdit.Enabled:=b_state;
  ModePauseTimeEdit.Enabled:=b_state;
  CheckLength.Enabled:=b_state;
  ComTimeEdit.Enabled:=b_state;

  PlayBtn.Enabled := b_state;
  PauseBtn.Enabled := b_state;
  StopBtn.Enabled := b_state;

  PausePanel.Color := clBtnFace;
  PlayPanel.Color := clBtnFace;
  StopPanel.Color := clBtnFace;
end;

procedure TControlDeskFrm.StopBtnClick(Sender: TObject);
begin
  Stop;
  UpdateTimers;
end;

procedure TControlDeskFrm.pause;
begin
  g_conmng.pause;
  PausePanel.Color := CLgREEN;
  PlayPanel.Color := clBtnFace;
  StopPanel.Color := clBtnFace;
end;

procedure TControlDeskFrm.TableModeSGClick(Sender: TObject);
var
  m: cModeObj;
  pPnt:       TPoint;  // Координаты курсора
  xCol, xRow: integer; // Адрес ячейки таблицы
  c:cControlObj;
begin
  GetCursorPos( pPnt );
  pPnt:= TStringGrid(Sender).ScreenToClient( pPnt );
  // Находим позицию нашей ячейки
  xCol:= TStringGrid(Sender).MouseCoord( pPnt.X, pPnt.Y ).X;
  xRow:= TStringGrid(Sender).MouseCoord( pPnt.X, pPnt.Y ).Y;
  c:=getControlFromTableModeSGByRow(xRow);
  if c<>nil then
  begin
    m_CurControl:=c;
    ControlPropE.text:=c.Name;
  end;
  m:=getTableModeSGByCol(xcol);
  if m<>nil then
    m_CurMode:=m;
  ModePropE.text:=m_CurMode.name;
  if m_CurMode<>nil then
    UpdateControlsPropSGmode(m_CurMode);
end;

procedure TControlDeskFrm.ConfirmManualSwitchMode(m: tobject);
begin
  if (g_conmng.state=c_Pause) or g_conmng.AllowUserModeSelect then
  begin
    if g_conmng.state<>c_stop then
    begin
      if m=nil then
        exit;
      if g_conmng.state=c_play then
        cmodeobj(m).TryActive
      else
      begin
        if g_conmng.state=c_pause then
        begin
          cmodeobj(m).active:=true;
          cmodeobj(m).Exec;
        end;
      end;
    end;
  end;
end;

procedure TControlDeskFrm.TableModeSGDblClick(Sender: TObject);
var
  m: cModeObj;
  c:cControlObj;
  pPnt:       TPoint;  // Координаты курсора
  xCol, xRow: integer; // Адрес ячейки таблицы
begin
  if g_conmng.state=c_play then
  begin
    GetCursorPos( pPnt );
    pPnt:= TStringGrid(Sender).ScreenToClient( pPnt );
    // Находим позицию нашей ячейки
    xCol:= TStringGrid(Sender).MouseCoord( pPnt.X, pPnt.Y ).X;
    xRow:= TStringGrid(Sender).MouseCoord( pPnt.X, pPnt.Y ).Y;
    m_CurControl:=getControlFromTableModeSGByRow(xRow);
    m:=getTableModeSGByCol(xcol);
    if xrow=0 then exit;
    c:=m_CurControl;
    if c<>nil then
    begin
      SelectControl(m_CurControl);
    end;
    if ConfirmModeCB.Checked then
    begin
      ConfirmFmr.SecCallBack(ConfirmManualSwitchMode, m);
      ConfirmFmr.SetText('Установить режим '+m.name);
      ConfirmFmr.Execute;
    end
    else // безусловный переход
      ConfirmManualSwitchMode(m);
  end;
end;

procedure TControlDeskFrm.TableModeSGDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: integer;
  p: cProgramObj;
  m: cModeObj;
  str: string;
  I: integer;
begin
  if (g_conmng.state=c_Play) or (g_conmng.state=c_Pause) then
  begin
    for I := 0 to g_conmng.ProgramCount - 1 do
    begin
      p := g_conmng.getprogram(I);
      m := p.ActiveMode;
      if m <> nil then
      begin
        sg := TStringGrid(Sender);
        // имя режима
        str := sg.Cells[ACol, 0];
        if str = m.name then
        begin
          Color := sg.Canvas.Brush.Color;
          case p.State of
            c_play:
              sg.Canvas.Brush.Color := CLgREEN;
            c_pause:
              sg.Canvas.Brush.Color := clYellow;
          end;
          sg.Canvas.FillRect(Rect);
          sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
          sg.Canvas.Brush.Color := Color;
        end;
      end;
    end;
  end;
end;

procedure TControlDeskFrm.TableModeSGSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  m_val:=value;
  m_col:=acol;
  m_row:=arow;
  ModeTabSGEditCell(m_row, m_col, m_val);
end;

procedure TControlDeskFrm.ModeTabSGEditCell(r,c:integer; val:string);
var
  p:cProgramObj;
  m:cmodeobj;
  t:ctask;
  con:cControlObj;
  str:string;
begin
  if not isValue(val) then exit;
  p:=g_conmng.getProgram(0);
  if p=nil then exit;
  if c>0 then
  begin
    // редактируем длительность
    if r=1 then
    begin
      m:=p.getMode(c-1);
      m.ModeLength:=ToSec(strtoFloatExt(val));
    end;
    if r>1 then
    begin
      str:=TableModeSG.Cells[0,r];
      con:=p.getOwnControl(str);
      if con<>nil then
      begin
        m:=p.getMode(c-1);
        if m<>nil then
        begin
          t:=m.gettask(con.name);
          if t<>nil then
          begin
            t.entercs;
            t.task:=strtoFloatExt(val);
            t.applyed:=false;
            t.exitcs;
          end;
        end;
      end;
    end;
  end;
end;

procedure TControlDeskFrm.Timer1Timer(Sender: TObject);
var
  tid: integer;
begin
  //LogRecorderMessage('TControlDeskFrm_Timer_enter');
  tid := GetCurrentThreadId;
  // деления на случай необходимости вызова из разных потоков
  if tid = MainThreadID then
  begin
    LogRecorderMessage('tid = MainThreadID========================================================', c_Log_ControlDeskFrm);
    LogRecorderMessage('TControlDeskFrm_Timer1Timer_BeforeExec', c_Log_ControlDeskFrm);
    g_conmng.Exec;
    LogRecorderMessage('TControlDeskFrm_Timer1Timer_BeforeExecControls', c_Log_ControlDeskFrm);
    // пересчитываем реакцию регуляторов
    g_conmng.ExecControls;
    // отображаем
    LogRecorderMessage('TControlDeskFrm_Timer1Timer_BeforeExecupdateviews',c_Log_ControlDeskFrm);
    updateviews;
    LogRecorderMessage('TControlDeskFrm_Timer1Timer_exit==========================================', c_Log_ControlDeskFrm);
  end
  else
  begin
    LogRecorderMessage('TControlDeskFrm_Timer1Timer_BeforeExec====================================', c_Log_ControlDeskFrm);
    // перерасчитываем все режимы и регуляторы
    g_conmng.Exec;
    LogRecorderMessage('TControlDeskFrm_Timer1Timer_BeforeExecControls',c_Log_ControlDeskFrm);
    // пересчитываем реакцию регуляторов
    g_conmng.ExecControls;
    // отображаем
    LogRecorderMessage('TControlDeskFrm_Timer1Timer_BeforeExecupdateviews',c_Log_ControlDeskFrm);
    updateviews;
    LogRecorderMessage('TControlDeskFrm_Timer1Timer_exit==========================================',c_Log_ControlDeskFrm);
  end;
  //LogRecorderMessage('TControlDeskFrm_Timer_exit');
end;

procedure TControlDeskFrm.TrigSGDrawCell(Sender: TObject; ACol, ARow: integer;
  Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: integer;
  str: string;
  t: cBaseTrig;
  I: integer;
begin
  sg := TStringGrid(Sender);
  str := sg.Cells[c_Col_TrigName, ARow];
  t := g_conmng.gettrig(str);
  if t <> nil then
  begin
    if t.ownState then
    begin
      if t.State then
      begin
        Color := sg.Canvas.Brush.Color;
        sg.Canvas.Brush.Color := CLgREEN;
        sg.Canvas.FillRect(Rect);
        sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
        sg.Canvas.Brush.Color := Color;
      end
      else
      begin
        Color := sg.Canvas.Brush.Color;
        sg.Canvas.Brush.Color := clYellow;
        sg.Canvas.FillRect(Rect);
        sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
        sg.Canvas.Brush.Color := Color;
      end;
    end;
  end;
end;

procedure TControlDeskFrm.updateControlRow(c: ccontrolobj);
var
  I: integer;
  txt: string;
begin
  for I := 1 to ControlSG.RowCount - 1 do
  begin
    txt := ControlSG.Cells[c_Col_Control, I];
    if txt = c.name then
    begin
      ControlSG.Cells[c_Col_Feedback, I] := c.getFBstr;
      if (g_conmng.state<>c_Stop) and (g_conmng.state<>c_pause) then
      begin
        ControlSG.Cells[c_Col_Task, I] := floattostr(c.task);
      end;
    end;
  end;
  // вызов перерисовки статуса регуляторов
  ControlSG.Invalidate();
end;

function TControlDeskFrm.GetSelectMode: cModeObj;
var
  p: cProgramObj;
begin
  result := nil;
  if g_conmng.ProgramCount > 0 then
  begin
    p := g_conmng.getprogram(0);
    if p.ModeCount > 0 then
    begin
      result := p.ActiveMode;
      if result = nil then
        result := p.getmode(0);
    end;
  end;
end;

function TControlDeskFrm.getTableModeSGByCol(col: integer): cModeObj;
var
  str:string;
  p:cprogramobj;
begin
  result:=nil;
  if col>0 then
  begin
    str:=TableModeSG.Cells[col, 0];
    p:=g_conmng.getprogram(0);
    if p<>nil then
    begin
      result:=p.getMode(str);
    end;
  end;
end;


function TControlDeskFrm.getControlFromTableModeSGByRow(Row: integer): cControlObj;
var
  str:string;
  p:cprogramobj;
begin
  result:=nil;
  if Row>0 then
  begin
    str:=TableModeSG.Cells[0, Row];
    p:=g_conmng.getprogram(0);
    if p<>nil then
    begin
      result:=p.getOwnControl(str);
    end;
  end;
end;

procedure TControlDeskFrm.ShowControlRow(c: ccontrolobj);
var
  txt: string;
  I: integer;
  m: cModeObj;
  t: ctask;
begin
  m := GetSelectMode;
  if m = nil then
    exit;
  t := nil;
  for I := 0 to m.taskCount - 1 do
  begin
    t := m.gettask(I);
    if t.control = c then
      break
    else
    begin
      if I = m.taskCount - 1 then
        t := nil;
    end;
  end;
  for I := 1 to ControlSG.RowCount - 1 do
  begin
    txt := ControlSG.Cells[c_Col_Control, I];
    if txt = c.name then
    begin
      ControlSG.Cells[c_Col_Task, I] := format('%.2g', [t.task]);
      break;
    end;
  end;
end;

procedure TControlDeskFrm.UpdateControlsSG;
var
  I: integer;
  c: ccontrolobj;
begin
  for I := 0 to g_conmng.ControlsCount - 1 do
  begin
    c := g_conmng.getControlObj(I);
    updateControlRow(c);
  end;
end;

procedure TControlDeskFrm.UpdateProgramsSG;
begin
  ProgramSG.Invalidate;
end;

procedure TControlDeskFrm.UpdateTimers;
var
  p: cProgramObj;
begin
  p:=nil;
  // ComTimeEdit.Text:=Format( '%.2f', [g_conmng.getComTime]);

  // ComTimeEdit.Text := format('%.2g', [g_conmng.getComTime]);
  ComTimeEdit.Text := formatstrnoe(SecToTime(g_conmng.getComTime), 2);
  if g_conmng.ProgramCount > 0 then
  begin
    p := g_conmng.getprogram(0);
  end;
  if p=nil then
    exit;

  // ModeTimeEdit.Text := format('%.2g', [g_conmng.getModeTime(p)]);
  ModeTimeEdit.Text := formatstrnoe(SecToTime(g_conmng.getModeTime(p)), 2);

  // ProgTimeEdit.Text := format('%.2g', [g_conmng.getProgTime(p)]);
  ProgTimeEdit.Text := formatstrnoe(SecToTime(g_conmng.getProgTime(p)), 2);

  // ModePauseTimeEdit.Text := format('%.2g', [g_conmng.getModePauseTime(p)]);
  ModePauseTimeEdit.Text := formatstrnoe(g_conmng.getModePauseTime(p), 2);

  CheckLength.Text := formatstrnoe(g_conmng.getModeCheckLength(p), 2);
end;

procedure TControlDeskFrm.updateviews;
var
  p:cProgramObj;
begin
  p:=g_conmng.getProgram(0);
  if p<>nil then
  begin
    if p.ActiveMode<>nil then
      ActiveModeE.Text:=p.ActiveMode.name
    else
      ActiveModeE.Text:='';
  end;
  UpdateTimers;
  if PageControl1.TabIndex=0 then
  begin
    UpdateProgramsSG;
    UpdateControlsSG;
    UpdateTrigs;
  end
  else
  begin
    TableModeSG.Invalidate;
    //UpdateControlsPropSG;
  end;
end;

procedure TControlDeskFrm.UpdateControlsPropSGmode(m:cModeObj);
var
  i, j, k, posstate,state:integer;
  t:ctask;
  str, str1:string;
  d:double;
begin
  i:=m.modeIndex;
  if m_CurControl<>nil then
    t:=m.GetTask(m_CurControl.name)
  else
  begin
    t:=m.GetTask(ControlPropE.text);
    if t<>nil then
      m_CurControl:=t.control;
  end;

  //if T.m_Params.count=0 then exit;
  str := t.getParam('PWM_Thi');
  ControlPropSG.Cells[i+1, 1] := str;
  str := t.getParam('PWM_Tlo');
  ControlPropSG.Cells[i+1, 2] := str;
  str := T.getParam('Vals');
  state:=0;
  k:=1;
  m_tolArray.Listclear;
  while k <=length(str) do
  begin
    case state of
      // имя зоны не отпарсено до символа :
      0:
      begin
        if str[k]=':' then
        begin
          posstate:=k;
          state:=1;
          continue;
        end;
      end;
      // парсим толеранс до первой ;
      1:
      begin
        if str[k]=';' then
        begin
          for j := k-1 downto posState do
          begin
            if (not isDigit(str[j])) and (not (str[j]='-'))  then
            begin
              str1:=Copy(str, j+1, k-j-1);
              d:=strtofloat(str1);
              m_tolArray.addObj(d);
              state:=2;
              break;
            end;
          end;
        end;
      end;
      // ищем новую зону
      2:
      begin
        if (str[k]='_') or (str[k]=char(10)) then
        begin
          state:=0;
        end;
      end;
    end;
    inc(k);
  end;
  if m_tolArray.Count>0 then
  begin
    d:=m_tolArray.GetDouble(0);
    str:=formatstrnoe(t.task+d, 4);
    ControlPropSG.Cells[i+1, 3] := str;
    d:=m_tolArray.GetDouble(m_tolArray.Count-1);
    str:=formatstrnoe(t.task+d, 4);
    ControlPropSG.Cells[i+1, 4] := str;
  end
  else
  begin

  end;
end;

procedure TControlDeskFrm.UpdateControlsPropSG;
var
  p:cProgramObj;
  m:cmodeobj;
  t:ctask;
  I, j
  // состояние парсинга значений зон
  : Integer;
  STR:STRING;
begin
  // обновляется по DblClick
  if m_CurControl=nil then exit;
  ControlPropE.text:= m_CurControl.caption;

  p := g_conmng.getprogram(0);
  ControlPropSG.ColCount:=1+p.ModeCount;

  for I := 0 to p.ModeCount - 1 do
  begin
    m:=p.getMode(i);
    UpdateControlsPropSGmode(m);
  end;
end;


{ TControlDeskFrm }
procedure TControlDeskFrm.UpdateTrigs;
var
  I, j, tcount, row: integer;
  t: cBaseTrig;
begin
  tcount := g_conmng.TrigCount;
  TrigSG.RowCount := c_headerSize + tcount;
  row := c_headerSize;
  for I := 0 to tcount - 1 do
  begin
    t := g_conmng.gettrig(I);
    TrigSG.Cells[c_Col_TrigState, row] := TrigBoolToStr(t.ownState);
    TrigSG.Cells[c_Col_TrigEnabled, row] := TrigBoolToStr(t.Enabled);
    inc(row);
  end;
end;

procedure TControlDeskFrm.WndProc(var Message: TMessage);
var
  str: string;
begin
  case message.msg of
    WM_ERASEBKGND:
      begin
        m_redraw := true;
      end;
    WM_NCPAINT:
      begin
        // An application can intercept the WM_NCPAINT message and paint its own custom window frame.
        // the clipping region for a window is always rectangular, even if the shape of the frame is altered.
        // The wParam value can be passed to GetDCEx as in the following example.
        // HDC hdc;
        // hdc = GetDCEx(hwnd, (HRGN)wParam, DCX_WINDOW|DCX_INTERSECTRGN);
        // ReleaseDC(hwnd, hdc);
        if m_redraw then
        begin
          m_redraw := false;
          inherited;
        end;
      end;
    wm_paint:
      begin
        if m_redraw then
        begin
          m_redraw := false;
          inherited;
        end;
        exit;
      end;
  else
    begin
      m_redraw := true;
    end;
  end;
  str := inttostr(message.msg);
  // TExtRecorderPack(GPluginInstance).LogRecorderMessage(str);
  case message.msg of
    WM_PARENTNOTIFY:
      begin
        // TExtRecorderPack(GPluginInstance).LogRecorderMessage(str+' WM_PARENTNOTIFY');
        case message.WParam of
          WM_RBUTTONUP:
            begin
              // CPoint pnt(GET_X_LPARAM(lParam),GET_Y_LPARAM(lParam));
              // ::ClientToScreen(m_pForm->getHWND(),&pnt);
              // ScreenToClient(&pnt);
              // return SendMessage(wParam,MK_RBUTTON,MAKELPARAM(pnt.x,pnt.y));
            end;
          WM_RBUTTONDOWN:
            begin
              // Edit;
            end;
        end;
      end;
  end;
  inherited;
end;

{ IControlFrm }
procedure IControlFrm.doClose;
begin
  m_lRefCount := 1;
end;

function IControlFrm.doCreateFrm: TRecFrm;
begin
  result := TControlDeskFrm.Create(nil);
end;

function IControlFrm.doGetName: LPCSTR;
begin
  result := 'ControlCyclogram';
end;


end.
