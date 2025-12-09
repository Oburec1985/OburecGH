unit u3120Frm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  inifiles,
  Dialogs, ImgList, ExtCtrls, Grids, ComCtrls, StdCtrls, Buttons,
  recorder, cfreg,
  uRecBasicFactory, uEventTypes, uRecorderEvents,
  uComponentServises, uConfirmDlg, uBaseObj,
  u3120Factory, u3120ControlObj,
  uControlObj, uModeObj, uProgramObj,
  MathFunction, uCommonMath,
  pluginclass, urcfunc, uTest,
  uThresholds3120Frm,
  uEditPropertiesFrm, uTransmisNumFrm,
  uGenReport, uCpEngine,
  activex, uPathMng, uEditProg, u3120Db, uMeasureBase,
  pngimage, uStringGridExt;

type
  TFrm3120 = class(TRecFrm)
    DeskGB: TGroupBox;
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
    Panel3: TPanel;
    Edit1: TEdit;
    ReportBtn: TButton;
    ImageList1: TImageList;
    Splitter1: TSplitter;
    ValsSG: TNoWheelStringGrid;
    MainPanel: TPanel;
    AlarmsBtn: TSpeedButton;
    AlarmStopBtn: TImage;
    AlarmStopLabel: TLabel;
    Button1: TButton;
    ConfirmModeCB: TCheckBox;
    ContinueCB: TCheckBox;
    EditProgBtn: TButton;
    FreqConvLamp: TImage;
    GetNotifyCB: TCheckBox;
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
    Label2: TLabel;
    PausePanel: TPanel;
    PauseBtn: TSpeedButton;
    PChLabel: TLabel;
    PlayPanel: TPanel;
    PlayBtn: TSpeedButton;
    ProgramsCB: TComboBox;
    StopOnPause: TCheckBox;
    StopPanel: TPanel;
    StopBtn: TSpeedButton;
    DBPanel: TPanel;
    Label3: TLabel;
    Label5: TLabel;
    ObjNameCb: TComboBox;
    OkDBbtn: TButton;
    TestNameCb: TComboBox;
    ReportPanel: TPanel;
    SaveBtn: TSpeedButton;
    OpenRepBtn: TButton;
    CloseRep: TCheckBox;
    LastCpLabel: TLabel;
    procedure TableModeSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure PlayBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure PauseBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TableModeSGDblClick(Sender: TObject);
    procedure TableModeSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure TableModeSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TableModeSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure AlarmsBtnClick(Sender: TObject);
    procedure AlarmStopBtnClick(Sender: TObject);
    procedure ControlPropSGDblClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure TableModeSGClick(Sender: TObject);
    procedure ValsSGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure TableModeSGTopLeftChanged(Sender: TObject);
    procedure ControlPropSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ControlPropSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ProgramsCBChange(Sender: TObject);
    procedure AddProgBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure ControlPropSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure ControlPropSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure OkDBbtnClick(Sender: TObject);
    procedure OpenRepBtnClick(Sender: TObject);
    procedure TestNameCbChange(Sender: TObject);
    procedure ObjNameCbChange(Sender: TObject);
    procedure EditProgBtnClick(Sender: TObject);
  private
    cs: TRTLCriticalSection;
    m_err: Integer;
    // канал программы. Для отслеживания перехода с 0 на 1
    m_prevState: double;
    mThread: cardinal;
    // Режим подтверждения перехода
    m_CurControl: cControlobj;
    // выбраный в таблице режим
    m_curMode: cmodeobj;
    // выбранный в OnClick режим в таблице редактирования свойств
    SelectCell_m: cmodeobj;
    SelectCell_Col: Integer;
    // список выбраных колонок в таблице режимов
    SelectCols: array [0 .. 30] of Integer;
    SelectColsCount: Integer;

    m_uiThread: Integer;
    // форма посчитана фабрикой класса. Нужно для ограничения числа форм
    m_counted: Boolean;
    m_curCol, m_curRow: Integer;
    finit, fload, fneedUpdate: Boolean;

    m_val: string;
    // индекс выбраной программы
    m_row, m_col: Integer;
    fCurProg:cprogramObj;

    m_apply: Boolean;
    m_timerid, m_timerid_res: cardinal;

    // вставка режиме в TableModeSG; номер колонки для вставки
    m_insert: Integer;
    // работа с отчетом
    m_saveBlockNum: Integer;
    m_excelTmplt: string; // путь к шаблону
    m_lastFile, m_ReportFile: string; // путь к отчету
  protected
    procedure enterCs;
    procedure exitCs;
    function CurProg: cProgramObj;
    // вернуть значение с единицами
    function getTaskVal(t: ctask): string;
    // отмена редактирования режима(перенос настроек режима обратно в таблицу)
    procedure CancelEditMode;
    procedure ConfirmManualSwitchMode(m: TObject);
    procedure CreateEvents;
    procedure DestroyEvents;
    procedure Start;
    procedure Stop;
    procedure pause;
    procedure UpdateTimers;
    procedure updateviews;
    procedure Preview;
    function ToTime(sec: double; b_format: Boolean): string;
    procedure doChangeRState(Sender: TObject);
    procedure doAddObj(Sender: TObject);
    procedure doRcInit(Sender: TObject);
    procedure doShowStop(Sender: TObject);
    procedure doLeaveCfg(Sender: TObject);
    procedure doStartCp(mode: TObject);
    // когда движок Cp завершает КТ
    procedure doStopCp(mode: TObject);
    // когда в движок Cp попадает новый режим
    procedure doNewModeCp(mode: TObject);

    procedure EnablePult(b_state: Boolean);
    function getControlFromTableModeSGByRow(row: Integer): cControlobj;
    function getTableModeSGByCol(col: Integer): cmodeobj;
    procedure SelectControl(c: cControlobj);

    procedure updatedata; override;
    procedure InitControlsPropSG;
    procedure UpdateControlsPropSG;
    procedure UpdateControlsPropSGmode(m: cmodeobj);
    procedure UpdateControlsPropSGCallBack(m: TObject);

    procedure updateModeSG(m: cmodeobj);
    // отредактирована ячейка
    procedure ModeTabSGEditCell(r, c: Integer; val: string);
    function toSec(t: double): double;
    procedure setErrCode(e: Integer);
    procedure DropErrCode(drop: Integer);
    procedure ShowInfoMessage(s: string);
    procedure ShowErrorMessage(s: string);
    procedure SyncAlarmsAndTask;
    procedure SetActiveProg(p:cProgramObj);
    function GetActiveProg:cProgramObj;
  public

    procedure doNextMode(Sender: TObject);
    procedure doBeforeNextMode(Sender: TObject);
    procedure doStart;
    function SecToTime(t: double): double;
    // происходит в doRepaint
    procedure UpdateView;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
    //
    procedure testInit;
    procedure ShowCyclogram;
    // отобразить задания
    procedure ShowModes;
    // отобразить измерения
    procedure ShowMeasured;
    property ActiveProg:cProgramObj read GetActiveProg write SetActiveProg;
  end;

var
  Frm3120: TFrm3120;
  g_3120Factory: c3120Factory;

const

  c_colScale = 1.1;
  c_Munits = 'Нм';
  c_Rpmunits = 'Об/мин';

  clGrass = TColor($00A7FED0);
  c_digits = 4;
  c_MCount = 6;
  c_Prow = 1;
  c_Irow = 2;
  c_Drow = 3;
  c_ForwRow = 4;
  c_TAlarmRow = 5;
  c_TthresholdRow = 6;
  c_PAlarmRow = 7;
  c_PthresholdRow = 8;
  c_MNAlarmRow = 9;
  c_MthresholdRow = 10;
  c_NthresholdRow = 11;
  c_ConditionRow = 12;
  c_ModeRow = 13;
  c_NRampRow = 14;
  c_MRampRow = 15;
  c_StartRow = 16;
  c_StopRow = 17;

implementation

{$R *.dfm}

{ TFrm3120 }
procedure TFrm3120.Preview;
begin
  ShowCyclogram;
  InitControlsPropSG;
  UpdateControlsPropSG;
end;

procedure TFrm3120.ProgramsCBChange(Sender: TObject);
var
  I: Integer;
  p: cProgramObj;
begin
  if ProgramsCB.ItemIndex>-1 then
    fCurProg:=cProgramObj(ProgramsCB.Items.Objects[ProgramsCB.ItemIndex]);
  for I := 0 to g_conmng.ProgramCount - 1 do
  begin
    p := g_conmng.getProgram(I);
    p.m_StartOnPlay := (I = ProgramsCB.ItemIndex);
    if p.m_StartOnPlay then
    begin
      p.fOnNextMode := doNextMode;
      p.fBeforeNextMode := doBeforeNextMode;
      ThresholdFrm.SetControlTag(p.m_ModeIndTag.GetName);
    end;
  end;
  if g_conmng.ProgramCount = 1 then
  begin
    p.m_StartOnPlay := true;
    ThresholdFrm.SetControlTag(p.m_ModeIndTag.GetName);
  end;

  SyncAlarmsAndTask;
  ShowCyclogram;
end;

procedure TFrm3120.doLeaveCfg(Sender: TObject);
begin
  if not finit then
    exit;
  if not fload then
    exit;
  m_CurControl := nil;
  m_curMode := nil;
  ControlPropE.text := '';
  if g_createGUI then
    Preview;
end;

procedure TFrm3120.doBeforeNextMode(Sender: TObject);
var
  p: cProgramObj;
  m: cmodeobj;
begin
  p := CurProg;
  m := cmodeobj(Sender);
  if m.AutoCpEndMode then
  begin
    SaveBtnClick(Sender);
  end;
end;

procedure TFrm3120.doNextMode(Sender: TObject);
begin
  ThresholdFrm.doUpdateData(self);
  // обновляем теги аварий в
  fneedUpdate := true;
end;

procedure TFrm3120.doAddObj(Sender: TObject);
begin
  if not m_counted then
  begin
    c3120Factory(m_f).incFrmCounter;
    m_counted := true;
  end;
end;

procedure TFrm3120.doRcInit(Sender: TObject);
var
  I: Integer;
  // g:TThresholdGroup;
begin
  finit := true;
  Frm3120 := self;
  Preview;
  if fCurProg<>nil then
  begin
    for I := 0 to ProgramsCB.items.Count - 1 do
    begin
      if ProgramsCB.Items.Objects[i]=fCurProg then
      begin
        ProgramsCB.ItemIndex := i;
      end;
    end;
  end
  else
  begin
    if ProgramsCB.items.count>0 then
      ProgramsCB.ItemIndex:=0;
  end;
  ProgramsCBChange(nil);
  ShowCyclogram;
  if g_CpEngine.Tmplt <> '' then
  begin
    g_CpEngine.Prepare;
  end;

  // testInit;
  // if ThresholdFrm<>nil then
  begin
    // for I := 0 to ThresholdFrm.m_Groups.Count - 1 do
    begin
      // g:=ThresholdFrm.getGroup(i);
      // инитим ифейсы тегов которые созданы
      // g.initiface;
    end;
  end;
end;

procedure TFrm3120.doShowStop(Sender: TObject);
begin
  StopPanel.Color := clMoneyGreen;
  PlayPanel.Color := clBtnFace;
  PausePanel.Color := clBtnFace;
  ProgramsCB.Enabled := true;
  updateviews;
end;

procedure TFrm3120.doStart;
var
  mf: string;
begin
  mf := GetMeraFile;
  m_ReportFile := ExtractFileDir(mf) + '\Report' + '.xlsx';
  // g_CpEngine.Prepare();
end;

procedure TFrm3120.doStartCp(mode: TObject);
begin
  ReportPanel.Color := $000080FF;
end;

procedure TFrm3120.doStopCp(mode: TObject);
begin
  ReportPanel.Color := clGradientActiveCaption;
end;

procedure TFrm3120.doNewModeCp(mode: TObject);
begin
  // нельзя вызывать КТ вручную пока н отбили циклограммой
  if cmodeobj(mode).AutoCp then
    ReportPanel.Color := clGray
  else
  begin // можно вызывать КТ вручную
    ReportPanel.Color := clGradientActiveCaption;
  end;
end;

procedure TFrm3120.CreateEvents;
begin
  addplgevent('TFrm3120_doAddObj', E_OnAddObj, doAddObj);
  addplgevent('TFrm3120_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
  addplgevent('TFrm3120_doLeaveCfg', c_RC_LeaveCfg, doLeaveCfg);
  addplgevent('TFrm3120_doRcInit', E_RC_Init, doRcInit);
  g_conmng.Events.AddEvent('TFrm3120_doStopControlMng', E_OnStopControlMng,
    doShowStop);
end;

function TFrm3120.CurProg: cProgramObj;
begin
  if fCurProg=nil then
  begin
    if ProgramsCB.ItemIndex > -1 then
      result := g_conmng.getProgram(ProgramsCB.ItemIndex)
    else
    begin
      if g_conmng.ProgramCount = 0 then
        result := nil
      else
        result := g_conmng.getProgram(0);
    end;
    fCurProg:=result;
  end
  else
  begin
    result:=fCurProg;
  end;
end;

procedure TFrm3120.DestroyEvents;
begin
  removeplgEvent(doAddObj, E_OnAddObj);
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
  removeplgEvent(doLeaveCfg, c_RC_LeaveCfg);
  removeplgEvent(doRcInit, E_RC_Init);
  if g_conmng <> nil then
    g_conmng.Events.removeEvent(doShowStop, E_OnStopControlMng);
end;

procedure TFrm3120.Start;
var
  ir: irecorder;
  p: cProgramObj;
begin
  ir := getIRecorder;
  if g_conmng.State = c_stop then
  begin
    g_conmng.Start;
    if ContinueCB.Checked then
    begin
      g_conmng.LoadState;
    end;
    TableModeSG.Invalidate;
  end
  else
  begin
    if g_conmng.State = c_Pause then
    begin
      p := CurProg;
      if p.ActiveMode <> nil then
      begin
        p.ActiveMode.applyed := false;
      end;
      g_conmng.continuePlay;
    end;
    TableModeSG.Invalidate;
  end;
  // подсветка панелек
  PlayPanel.Color := clMoneyGreen;
  PausePanel.Color := clBtnFace;
  StopPanel.Color := clBtnFace;
end;

procedure TFrm3120.Stop;
begin
  g_conmng.Stop;
  TableModeSG.FixedRows := 0;
  ShowInfoMessage('Стоп');
end;

procedure TFrm3120.pause;
var
  c: cControlobj;
  I: Integer;
begin
  if StopOnPause.Checked then
  begin
    for I := 0 to g_conmng.ControlsCount - 1 do
    begin
      c := g_conmng.getControlObj(I);
      c.Stop;
    end;
  end;
  g_conmng.pause;
  PausePanel.Color := clMoneyGreen;
  PlayPanel.Color := clBtnFace;
  StopPanel.Color := clBtnFace;
end;

procedure TFrm3120.UpdateTimers;
var
  p: cProgramObj;
begin
  p := nil;
  // ComTimeEdit.Text:=Format( '%.2f', [g_conmng.getComTime]);
  // ComTimeEdit.Text := format('%.2g', [g_conmng.getComTime]);
  ComTimeEdit.text := ToTime(g_conmng.getComTime, true);
  if g_conmng.ProgramCount > 0 then
  begin
    p := CurProg;
  end;
  if p = nil then
    exit;

  // ModeTimeEdit.Text := format('%.2g', [g_conmng.getModeTime(p)]);
  ModeTimeEdit.text := ToTime(g_conmng.getModeTime(p), true);

  // ProgTimeEdit.Text := format('%.2g', [g_conmng.getProgTime(p)]);
  ProgTimeEdit.text := ToTime(g_conmng.getProgTime(p), true);
  if p.ActiveMode <> nil then
  begin
    ModeStopTime.text := ToTime(p.ActiveMode.ModeLength - g_conmng.getModeTime
        (p), true); ;
  end;
  // ModePauseTimeEdit.text := formatstrnoe(g_conmng.getModePauseTime(p),2);
  // CheckLength.text := formatstrnoe(g_conmng.getModeCheckLength(p), 2);
end;

procedure TFrm3120.StopBtnClick(Sender: TObject);
begin
  Stop;
  UpdateTimers;
end;

procedure TFrm3120.SyncAlarmsAndTask;
var
  i, j,num:integer;
  g:TThresholdGroup;
  d:PDataRec;
  p:cProgramObj;
  m:cModeObj;
begin
  for i:=0 to ThresholdFrm.m_Groups.Count-1 do
  begin
    g:=ThresholdFrm.getGroup(i);
    p:=CurProg;
    if g.m_size<p.ModeCount then
    begin
      g.setCount(p.ModeCount);
    end;
    for j := 0 to p.ModeCount - 1 do
    begin
      m:=p.getmode(j);
      d:=@g.m_Data[j];
      num:=strtoint(g.name[2]);
      if num<6 then
      begin
        d.normal:=m.GetTask(num-1).task;
      end;
    end;
  end;
end;

constructor TFrm3120.create(Aowner: tcomponent);
begin
  inherited;
  InitializeCriticalSection(cs);

  m_err := 0;

  ConfirmFmr := TConfirmFmr.create(nil);
  ThresholdFrm := TThresholdFrm.create(nil);
  EditPropertiesFrm := TEditPropertiesFrm.create(nil);
  if ThresholdFrm <> nil then
    ThresholdFrm.AttachAlarms;

  CreateEvents;
  testInit;
  m_insert := -1;
  m_curMode := nil;
  // m_ViewControls:=TList.Create;
  m_counted := false;
  m_uiThread := GetCurrentThreadId;
  mThread := MainThreadID;
  // SGbuttons := tlist.Create;
  finit := false;
  EnablePult(false);
  // InfoLabel.Caption := 'UIThread: ' + inttostr(m_uiThread)
  // + ' mThread: ' + inttostr(mThread);
end;

destructor TFrm3120.destroy;
begin
  DeleteCriticalSection(cs);

  g_CpEngine.destroy;
  inherited;
end;

procedure TFrm3120.EditProgBtnClick(Sender: TObject);
var
  obj: cxmlfolder;
begin
  EditProgFrm.m_units := TimeUnitsCB.ItemIndex;
  EditProgFrm.showPrograms(g_conmng);
end;

procedure TFrm3120.EnablePult(b_state: Boolean);
begin
  ProgTimeEdit.Enabled := b_state;
  ModeTimeEdit.Enabled := b_state;
  ComTimeEdit.Enabled := b_state;

  PlayBtn.Enabled := b_state;
  PauseBtn.Enabled := b_state;
  StopBtn.Enabled := b_state;

  PausePanel.Color := clBtnFace;
  PlayPanel.Color := clBtnFace;
  StopPanel.Color := clBtnFace;
end;

procedure TFrm3120.enterCs;
begin
  EnterCriticalSection(cs);
end;

procedure TFrm3120.exitCs;
begin
  LeaveCriticalSection(cs);
end;

function TFrm3120.getControlFromTableModeSGByRow(row: Integer): cControlobj;
var
  str: string;
  p: cProgramObj;
begin
  result := nil;
  if row > 0 then
  begin
    str := TableModeSG.Cells[0, row];
    p := CurProg;
    if p <> nil then
    begin
      result := p.getOwnControl(str);
    end;
  end;
end;

function TFrm3120.getTableModeSGByCol(col: Integer): cmodeobj;
var
  str: string;
  p: cProgramObj;
begin
  result := nil;
  if col > 0 then
  begin
    str := TableModeSG.Cells[col, 0];
    p := CurProg;
    if p <> nil then
    begin
      result := p.getmode(col - 1);
    end;
  end;
end;

function TFrm3120.getTaskVal(t: ctask): string;
var
  c: cControlobj;
  str: string;
begin
  c := t.control;
  if c is cMnControl then
  begin
    case t.m_data.ModeType of
      mtN:
        str := str + ', ' + c_Rpmunits;
      mtM:
        str := str + ', ' + c_Munits;
    end;
    result := formatstrnoe(t.task, c_digits) + str;
  end
  else
  begin
    str := ', %';
    result := formatstrnoe(t.task, c_digits) + str;
  end;
end;

procedure TFrm3120.doChangeRState(Sender: TObject);
var
  Rstate: Boolean;
  p: cProgramObj;
  c: cControlobj;
  ec, I: Integer;
  str: string;
begin
  Rstate := RStatePlay;

  EnablePult(Rstate);
  Timer1.Interval := round(GetRefreshPeriod * 1000);
  if Rstate then
  begin
    // ShowTrigs;
    // m_timerid_res:=SetTimer(MainThreadID, m_timerid, Timer1.Interval, @TimeProc);
    Timer1.Enabled := true
  end
  else
  begin
    // последняя итерация для срабатывания действий заложенных в стоптриг
    p := CurProg;
    if p <> nil then
    begin
      p.exec;
      for I := 0 to p.ControlCount - 1 do
      begin
        c := p.getOwnControl(I);
        c.exec;
      end;
    end;
    if g_conmng.configChanged then
    begin
      Preview;
      g_conmng.configChanged := false;
    end;
    Stop;
    // if g_conmng.state<>c_stop then showmessage('Остановили Timer в состоянии c_TryStop');
    Timer1.Enabled := false;

    if g_conmng.State <> c_stop then
    begin
      g_conmng.State := c_stop;
    end;
    if p <> nil then
    begin
      if p.ActiveMode <> nil then
        str := p.ActiveMode.caption
      else
        str := '';
    end;
    ec := g_conmng.ErrorCount;
    if ec <> 0 then
    begin
      // ActiveModeE.text :=str+' '+g_conmng.ErrorStr;
    end
    else
    begin
      // ActiveModeE.text :=str;
    end;
    TableModeSG.Invalidate;
  end;
end;

procedure TFrm3120.PauseBtnClick(Sender: TObject);
VAR
  b: Boolean;
begin
  b := PausePanel.Color = clMoneyGreen;
  if b then
    b := false
  else
    b := true;
  if b then
    pause
  else
  begin
    // Start;
  end;
end;

procedure TFrm3120.PlayBtnClick(Sender: TObject);
var
  b: Boolean;
begin
  ProgramsCB.Enabled := false;
  TableModeSG.FixedRows := 1;
  b := PlayPanel.Color = clMoneyGreen;
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
    // pause;
  end;
end;

procedure TFrm3120.SaveBtnClick(Sender: TObject);
var
  dir, rep, Tmplt, objpath, lpath: string;
  d: TDataReport;
  m: cmodeobj;
  p: cProgramObj;
  b: Boolean;
  err:integer;
begin
  m := CurProg.ActiveMode;
  if m = nil then
    exit;
  if m.AutoCp then
  begin
    // не даем снимать КТ если режим пока не отбили по циклограмме
    if g_CpEngine.State = 2 then
      exit;
  end;

  // testpath := GetMDBTestPath;
  lpath := testpath;
  if testpath <> '' then
  begin
    Tmplt := g_CpEngine.Tmplt;
    dir := lpath;
  end
  else
  begin
    Tmplt := 'c:\Mera Files\mdb\3120\template\tmplt_report.xlsx';
  end;

  d.m := m;
  // сброс тегов
  g_CpEngine.resettags;
  b := genreport(dir, 'Report.xlsx', Tmplt, true, d, g_CpEngine.m_tagslist, err);
  if not b then
  begin
    setErrCode(12);
    ShowErrorMessage('некорректный шаблон протокола, err='+inttostr(err));
  end
  else
  begin
    DropErrCode(12);
  end;
  p := CurProg;
  LastCpLabel.caption := 'КТ: ' + formatstrnoe(p.getModeTime, 3);
end;

procedure TFrm3120.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  dir, SectionStr: string;
begin
  inherited;
  SectionStr := String(str);

  a_pIni.EraseSection(SectionStr);
  a_pIni.WriteBool(SectionStr, 'StopOnPause', StopOnPause.Checked);
  a_pIni.WriteBool(SectionStr, 'ContinueCB', ContinueCB.Checked);
  a_pIni.WriteBool(SectionStr, 'ConfirmModeCB', ConfirmModeCB.Checked);
  a_pIni.WriteBool(SectionStr, 'GetNotifyCB', GetNotifyCB.Checked);
  a_pIni.WriteInteger(SectionStr, 'TimeUnitsCB', TimeUnitsCB.ItemIndex);
  a_pIni.WriteBool(SectionStr, 'CloseRep', CloseRep.Checked);
  a_pIni.WriteInteger(SectionStr, 'Table_Controls_Splitter_Pos', RightGB.Width);
  a_pIni.WriteString(SectionStr, 'TransNumCfg', TransNumFrm.ToStr);
  if fCurProg.name<>'' then
    a_pIni.WriteString(SectionStr, 'ActivProg', fCurProg.name)
  else
    a_pIni.WriteString(SectionStr, 'ActivProg', '');
  a_pIni.WriteString(SectionStr, 'DBTestObj', ObjNameCb.text);
  a_pIni.WriteString(SectionStr, 'DBTest', TestNameCb.text);
  a_pIni.WriteFloat(SectionStr, 'Cp_AvrTime', g_CpEngine.m_avrTime);
  a_pIni.WriteFloat(SectionStr, 'Cp_StartTime', g_CpEngine.m_Time);
  a_pIni.WriteString(SectionStr, 'Cp_Tmplt', g_CpEngine.Tmplt);

  dir := ExtractFileDir(a_pIni.FileName);
  ThresholdFrm.save(dir + '\Alarms.ini');
end;

procedure TFrm3120.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  SectionStr, s, dir: string;
  p: cProgramObj;
  I: Integer;
  li: tlistitem;
begin
  inherited;

  SectionStr := String(str);

  StopOnPause.Checked := a_pIni.ReadBool(SectionStr, 'StopOnPause', false);
  ContinueCB.Checked := a_pIni.ReadBool(SectionStr, 'ContinueCB', false);
  ConfirmModeCB.Checked := a_pIni.ReadBool(SectionStr, 'ConfirmModeCB', false);
  GetNotifyCB.Checked := a_pIni.ReadBool(SectionStr, 'GetNotifyCB', false);
  TimeUnitsCB.ItemIndex := a_pIni.ReadInteger(SectionStr, 'TimeUnitsCB', 0);
  CloseRep.Checked := a_pIni.ReadBool(SectionStr, 'CloseRep', false);
  s := a_pIni.ReadString(SectionStr, 'ActivProg', '');
  if s<>'' then
  begin
    fCurProg:=g_conmng.getProgram(s);
  end;

  initdb;
  g_CpEngine := TCPengine.create;
  g_CpEngine.init(TExtRecorderPack(g_plg));
  g_CpEngine.fstartCp := doStartCp;
  g_CpEngine.fstopCp := doStopCp;
  g_CpEngine.fNewModeCp := doNewModeCp;

  ObjNameCb.text := a_pIni.ReadString(SectionStr, 'DBTestObj', '');
  TestNameCb.text := a_pIni.ReadString(SectionStr, 'DBTest', '');
  ShowDB(ObjNameCb, TestNameCb, ObjNameCb.text, TestNameCb.text);
  g_CpEngine.m_avrTime := a_pIni.ReadFloat(SectionStr, 'Cp_AvrTime', 1);
  g_CpEngine.m_Time := a_pIni.ReadFloat(SectionStr, 'Cp_StartTime', 1);
  g_CpEngine.Tmplt := a_pIni.ReadString(SectionStr, 'Cp_Tmplt', '');
  // if g_cpEngine.checkRepPath then
  begin

  end;

  RightGB.Width := a_pIni.ReadInteger(SectionStr,
    'Table_Controls_Splitter_Pos', RightGB.Width);
  s := a_pIni.ReadString(SectionStr, 'TransNumCfg', '');
  if s <> '' then
  begin
    TransNumFrm.FromStr(s);
    TransNumFrm.ShowColumns;
  end;

  SGChange(TableModeSG, c_colScale);
  SGChange(ControlPropSG, c_colScale);

  // упрощакем доступ к контролам
  p := CurProg;
  p.fOnNextMode := doNextMode;
  p.fBeforeNextMode := doBeforeNextMode;

  dir := ExtractFileDir(a_pIni.FileName);
  ThresholdFrm.load(dir + '\Alarms.ini');

  // отображаем список программ в Combobox
  ProgramsCB.Clear;
  for I := 0 to g_conmng.ProgramCount - 1 do
  begin
    p := g_conmng.getProgram(I);
    ProgramsCB.AddItem(p.name, p);
    if (I = 0) then
    begin
      ProgramsCB.ItemIndex := 0;
    end
    else
    begin
      if fCurProg<>nil then
      begin
        if fCurProg.name=p.name then
        begin
          ProgramsCB.ItemIndex := i;
        end;
      end;
    end;
  end;
  if g_conmng.ProgramCount = 1 then
  begin
    p.m_StartOnPlay := true;
  end;
end;

procedure TFrm3120.ConfirmManualSwitchMode(m: TObject);
begin
  if (g_conmng.State = c_Pause) or g_conmng.AllowUserModeSelect then
  begin
    if g_conmng.State <> c_stop then
    begin
      if m = nil then
        exit;
      if g_conmng.State = c_play then
        cmodeobj(m).TryActive
      else
      begin
        if g_conmng.State = c_Pause then
        begin
          cmodeobj(m).active := true;
          cmodeobj(m).exec;
        end;
      end;
    end;
  end;
end;

procedure TFrm3120.ControlPropSGDblClick(Sender: TObject);
var
  p: cProgramObj;
  m: cmodeobj;
  t: ctask;
  c: cControlobj;
  pPnt: TPoint; // Координаты курсора
  xCol, xRow: Integer; // Адрес ячейки таблицы
  str, Key: string;
  changebool: Boolean;
begin
  // exit;
  GetCursorPos(pPnt);
  pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
  // Находим позицию нашей ячейки
  xCol := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).X;
  xRow := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).Y;
  p := CurProg;
  m := p.getmode(xCol - 1);
  if m <> nil then
  begin
    if m_CurControl <> nil then
    begin
      t := m.GetTask(m_CurControl.name);
      EditPropertiesFrm.showMN(t);
      EditPropertiesFrm.cb := UpdateControlsPropSGCallBack;
      EditPropertiesFrm.mode := m;
      UpdateControlsPropSGmode(m);
      updateModeSG(m);
      TableModeSG.Invalidate;
    end;
  end;
end;

procedure TFrm3120.TableModeSGClick(Sender: TObject);
begin
  TableModeSG.Invalidate;
end;

procedure TFrm3120.TableModeSGDblClick(Sender: TObject);

var
  m: cmodeobj;
  c: cControlobj;
  pPnt: TPoint; // Координаты курсора
  xCol, xRow: Integer; // Адрес ячейки таблицы
begin
  GetCursorPos(pPnt);
  pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
  // Находим позицию нашей ячейки
  xCol := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).X;
  xRow := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).Y;
  m_CurControl := getControlFromTableModeSGByRow(xRow);
  m := getTableModeSGByCol(xCol);
  if xRow <> 0 then
  begin
    c := m_CurControl;
    SelectControl(m_CurControl);
  end;

  if g_conmng.State = c_play then
  begin
    if m <> nil then
    begin
      if ConfirmModeCB.Checked then
      begin
        ConfirmFmr.SecCallBack(ConfirmManualSwitchMode, m);
        ConfirmFmr.SetText('Установить режим ' + m.caption);
        ConfirmFmr.Execute;
      end
      else // безусловный переход
      begin
        ConfirmManualSwitchMode(m);
      end;
    end;
  end
  else
    TableModeSG.Invalidate;
end;

procedure TFrm3120.ControlPropSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  setErrCode(4);
  //
  if ControlPropSG.Cells[ACol, ARow] = c_left_str then
  begin
    ControlPropSG.Canvas.Brush.Color := clGrass;
    ControlPropSG.Canvas.FillRect(Rect);
    ControlPropSG.Canvas.TextOut(Rect.Left, Rect.Top,
      ControlPropSG.Cells[ACol, ARow]);
    ControlPropSG.Canvas.Brush.Color := Color;
  end;
  DropErrCode(4);
end;

procedure TFrm3120.ControlPropSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  m_t: ctask;
  sg: TStringGrid;
  col, r: Integer;
  str: string;
begin
  if Key = VK_RETURN then
  begin
    if SelectCell_m <> nil then
    begin
      m_t := SelectCell_m.GetTask(m_CurControl.name);
      if m_t <> nil then
      begin
        sg := ControlPropSG;
        col := SelectCell_Col;
        m_t.applyed := false;
        m_t.m_data.p := strtofloatext(sg.Cells[col, c_Prow]);
        m_t.m_data.I := strtofloatext(sg.Cells[col, c_Irow]);
        m_t.m_data.d := strtofloatext(sg.Cells[col, c_Drow]);
        str := sg.Cells[col, c_ForwRow];
        if str = '2' then
        begin
          str := c_left_str;
        end
        else
        begin
          if (str = '1') or (str = '0') then
          begin
            str := c_right_str;
          end
          else
          begin
            if (str <> c_left_str) and (str <> c_left_str) then
            begin
              // возвращаем что было
              str := dirtostr(m_t.m_data.forw);
            end;
          end;
        end;
        sg.Cells[col, c_ForwRow] := str;
        m_t.m_data.forw := dirtobool(str);
        m_t.m_data.TAlarm := StrToB(sg.Cells[col, c_TAlarmRow]);
        m_t.m_data.Tthreshold := strtofloatext(sg.Cells[col, c_TthresholdRow]);
        m_t.m_data.Palarm := StrToB(sg.Cells[col, c_PAlarmRow]);
        m_t.m_data.Pthreshold := strtofloatext(sg.Cells[col, c_PthresholdRow]);
        m_t.m_data.MNAlarm := StrToB(sg.Cells[col, c_MNAlarmRow]);
        m_t.m_data.Mthreshold := strtofloatext(sg.Cells[col, c_MthresholdRow]);
        m_t.m_data.Nthreshold := strtofloatext(sg.Cells[col, c_NthresholdRow]);
        m_t.m_data.ModeType := strToModeType(sg.Cells[col, c_ModeRow]);
        m_t.m_data.Nramp := strtofloatext(sg.Cells[col, c_NRampRow]);
        m_t.m_data.Mramp := strtofloatext(sg.Cells[col, c_MRampRow]);
        m_t.m_data.cmd_start := StrToB(sg.Cells[col, c_StartRow]);
        m_t.m_data.cmd_stop := StrToB(sg.Cells[col, c_StopRow]);
        UpdateControlsPropSGmode(cmodeobj(SelectCell_m));
        // обновляем единицы измерения. Поиск строки по имени контрола в 0 колонке
        r := getRow(TableModeSG, m_CurControl.name, 0);
        col := getColumn(TableModeSG, SelectCell_m.caption);
        TableModeSG.Cells[col, r] := getTaskVal(m_t);
      end;
    end;
  end;
  // TStringGrid(Sender).EditorMode:=false;
end;

procedure TFrm3120.ControlPropSGSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
var
  p: cProgramObj;
begin
  setErrCode(8);
  p := CurProg;
  if p <> nil then
  begin
    if ACol > 0 then
    begin
      SelectCell_m := p.getmode(ACol - 1);
      if SelectCell_m <> nil then
      begin
        SelectCell_Col := ACol;
        ModePropE.text := SelectCell_m.caption;
      end;
    end;
  end;
  DropErrCode(8);
end;

procedure TFrm3120.ControlPropSGSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: string);
var
  p: cProgramObj;
begin
  exit;
  p := CurProg;
  if p <> nil then
  begin
    if ACol > 0 then
    begin
      SelectCell_m := p.getmode(ACol - 1);
      if SelectCell_m <> nil then
      begin
        SelectCell_Col := ACol;
        ModePropE.text := SelectCell_m.caption;
      end;
    end;
  end;
end;

procedure TFrm3120.ValsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: Integer;
  str: string;
  I: Integer;
  p: cProgramObj;
  m: cmodeobj;
  c: cControlobj;
  t: ctask;
  a: TAlarms;
  b: Boolean;
begin
  if (ARow < 0) or (ACol < 0) then
    exit;
  if GetCurrentThreadId <> m_uiThread then
  begin
    exit;
  end;
  sg := TStringGrid(Sender);
  Color := sg.Canvas.Brush.Color;
  // красим заголовок
  if ARow < 2 then
  begin
    Rect.Left := Rect.Left + 1;
    Rect.Right := Rect.Right - 1;
    Rect.Top := Rect.Top - 1;
    Rect.Bottom := Rect.Bottom + 1;

    sg.Canvas.Brush.Color := clGray;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
    DropErrCode(0);
    exitCs;
    exit;
  end;
  p := CurProg;
  if p <> nil then
  begin
    m := p.ActiveMode;
    c := g_conmng.getControlObj(ARow - 2);
  end;
  // измерения
  if (ACol = 0) or (ACol = 1) then
  begin
    str := sg.Cells[0, ARow];
    a := nil;
    if c <> nil then
    begin
      if c is cMnControl then
      begin
        if ACol = (0) then // предпосл. колонка - момент
          a := ThresholdFrm.getalarm(cMnControl(c).m_Mtagfb.tagname)
        else // посл. колонка - обороты
          a := ThresholdFrm.getalarm(cMnControl(c).m_Ntagfb.tagname);
      end;
    end;
    b := false;
    if a <> nil then
    begin
      b := a.activeA <> nil;
    end;
    if b then
    begin
      a.activeA.GetColor(Color);
      sg.Canvas.Brush.Color := Color;
    end
    else
    begin
      sg.Canvas.Brush.Color := clCream;
    end;
    if not b then
    begin
      if m <> nil then
      begin
        t := m.GetTask(c.name);
        if t <> nil then
        begin
          if t.m_useTolerance then
          begin
            t.CheckTaskRes;
            case t.ftolres of
              // не контролим
              0:
                sg.Canvas.Brush.Color := clCream;
              // не в допуске
              1:
                sg.Canvas.Brush.Color := clCream;
              // в допуске
              2:
                sg.Canvas.Brush.Color := clGrass;
              // не проверяем
              3:
                sg.Canvas.Brush.Color := clLtGray;
            end;
          end;
        end;
      end;
    end;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
  end;
end;

procedure TFrm3120.TableModeSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: Integer;
  str: string;
  I: Integer;
  p: cProgramObj;
  m: cmodeobj;
  c: cControlobj;
  t: ctask;
  a: TAlarms;
  b: Boolean;
begin
  setErrCode(3);
  sg := TStringGrid(Sender);
  Color := sg.Canvas.Brush.Color;
  // красим заголовок
  if ARow = 0 then
  begin
    Rect.Left := Rect.Left + 1;
    Rect.Right := Rect.Right - 1;
    Rect.Top := Rect.Top - 1;
    Rect.Bottom := Rect.Bottom + 1;

    sg.Canvas.Brush.Color := clGray;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
    DropErrCode(3);
    exit;
  end;

  p := CurProg;
  if p <> nil then
    m := p.ActiveMode;

  // окрас строки выбраного контрола
  if ARow >= 1 then
  begin
    str := sg.Cells[0, ARow];
    if g_conmng <> nil then
    begin
      c := g_conmng.getControlObj(str);
      sg.Canvas.Brush.Color := clWindow;
      // окрас строки с выбраным контролом
      if m_CurControl <> nil then
      begin
        if c = m_CurControl then
        begin
          Color := sg.Canvas.Brush.Color;
          sg.Canvas.Brush.Color := clGrass;
          sg.Canvas.FillRect(Rect);
          sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
          sg.Canvas.Brush.Color := Color;
        end;
      end;
    end;
  end;

  // отрисовка цветов активного режима
  if (g_conmng.State = c_play) or (g_conmng.State = c_Pause) then
  begin
    for I := 0 to g_conmng.ProgramCount - 1 do
    begin
      if m <> nil then
      begin
        // имя режима
        str := sg.Cells[ACol, 0];
        // окраска столбца
        if str = m.caption then
        begin
          Color := sg.Canvas.Brush.Color;
          case p.State of
            c_play:
              sg.Canvas.Brush.Color := clMoneyGreen;
            c_Pause:
              sg.Canvas.Brush.Color := clYellow;
          end;
          sg.Canvas.FillRect(Rect);
          sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
          sg.Canvas.Brush.Color := Color;
        end;
      end;
    end;
  end;
  // окрас выключеного режима
  if (ACol > 0) and (ARow > 1) then
  begin
    m := CurProg.getmode(ACol - 1);
    if m <> nil then
    begin
      str := sg.Cells[0, ARow];
      c := g_conmng.getControlObj(str);
      if c is cMnControl then
      begin
        t := m.GetTask(c.name);
        if t.m_data.cmd_stop then
        begin
          Color := sg.Canvas.Brush.Color;
          sg.Canvas.Brush.Color := clGray;
          sg.Canvas.FillRect(Rect);
          sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
          sg.Canvas.Brush.Color := Color;
        end;
      end;
    end;
  end;
  DropErrCode(3);
end;

procedure TFrm3120.AlarmsBtnClick(Sender: TObject);
begin
  if ThresholdFrm = nil then
  begin
    ThresholdFrm := TThresholdFrm.create(nil);
  end;
  ThresholdFrm.ShowModal;
end;

procedure TFrm3120.AlarmStopBtnClick(Sender: TObject);
begin
  g_conmng.Stop;
end;

procedure TFrm3120.Button1Click(Sender: TObject);
var
  obj: cxmlfolder;
begin
  TransNumFrm.show;
end;

procedure TFrm3120.setActiveProg(p: cProgramObj);
var
  I: Integer;
begin
  for I := 0 to ProgramsCB.items.Count - 1 do
  begin
    if ProgramsCB.items.Objects[i]=p then
    begin
      ProgramsCB.ItemIndex:=i;
      exit;
    end;
  end;
end;

function TFrm3120.GetActiveProg:cProgramObj;
begin
  result:=fCurProg;
end;

procedure TFrm3120.AddProgBtnClick(Sender: TObject);
var
  p: cProgramObj;
  c: cControlobj;
  I: Integer;
  m: cmodeobj;
  t: ctask;
  s, dsc: string;
  b: Boolean;
begin
  p := cProgramObj.create;
  p.CreateStateTag;
  p.name := 'Prog_' + inttostr(g_conmng.ProgramCount + 1);
  p.RepeatCount := 1;
  p.m_StartOnPlay := false;
  p.m_enableOnStart := true;
  g_conmng.Add(p);
  for I := 0 to g_conmng.ControlsCount - 1 do
  begin
    c := g_conmng.getControlObj(I);
    p.AddControl(c);
  end;
  m := cmodeobj.create;
  // 22 минуты в сек.
  m.ModeLength := toSec(22);
  // включает бесконечный режим, пока не произойдет триггерный переход
  cmodeobj(m).Infinity := false;
  // включает проверку выхода на режим
  cmodeobj(m).CheckThreshold := false;
  // время в течении которого ожидается проверка выхода на режим
  cmodeobj(m).CheckLength := 0;
  p.addmode(m);
  dsc := '2045;2640;2640;35;35;100;50;100';
  for I := 0 to m.TaskCount - 1 do
  begin
    s := getSubStrByIndex(dsc, ';', 1, I + 1);
    t := m.GetTask(I);
    t.applyed := false;
    if I < 5 then
    begin
      if I = 0 then
        t.m_data.ModeType := mtN
      else
        t.m_data.ModeType := mtM
    end;
    t.task := strtofloat(s);
    if I = 0 then // M1 по часовой
      b := true
    else
      b := false;
    t.m_data.forw := b;
  end;
end;

procedure TFrm3120.CancelEditMode;
var
  I, col, row: Integer;
  j: Integer;
  t: ctask;
  str: string;
begin
  // TableModeSG.Cells[col, 0] := m.Caption;
  if m_curMode = nil then
    exit;
  m_curCol := getColumn(TableModeSG, m_curMode.caption);
  if m_CurControl <> nil then
  begin
    m_curRow := getRow(TableModeSG, m_CurControl.name, 0);
    TableModeSG.Cells[m_curCol, 1] := ToTime(m_curMode.ModeLength, false);
    TableModeSG.Cells[0, m_curRow] := m_CurControl.caption;
    t := m_curMode.GetTask(m_CurControl.name);
    if t <> nil then
    begin
      TableModeSG.Cells[m_curCol, m_curRow] := getTaskVal(t);
    end;
    SGChange(TableModeSG, c_colScale);
  end;
end;

procedure TFrm3120.TableModeSGSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  c: cControlobj;
  m: cmodeobj;
  I, prevCol: Integer;
  find: Boolean;
begin
  setErrCode(9);
  // showmessage('str: ' + inttostr(arow)+ '; col: '+inttostr(aCol));
  CancelEditMode;
  prevCol := m_curRow;
  m_curRow := ARow;
  m_curCol := ACol;
  c := getControlFromTableModeSGByRow(m_curRow);
  if c <> nil then
  begin
    m_CurControl := c;
    ControlPropE.text := c.Name;
  end;
  m := getTableModeSGByCol(m_curCol);
  if m <> nil then
    m_curMode := m
  else
  begin
    SelectColsCount := 0;
  end;
  // механика выбора нескольких колонок
  if getKeyState(VK_CONTROL) = 0 then
  begin
    SelectColsCount := 1;
    SelectCols[0] := ACol;
    // Edit1.Text:=inttostr(SelectColsCount);
  end;
  // механика выбора нескольких колонок
  if getKeyState(VK_CONTROL) < 0 then
  begin
    find := false;
    for I := 0 to SelectColsCount - 1 do
    begin
      // исключаем элемент
      if SelectCols[I] = ACol then
      begin
        if I = (SelectColsCount - 1) then
        begin
        end
        else
        begin
          move(SelectCols[I + 1], SelectCols[I],
            (SelectColsCount - I) * sizeof(Integer));
        end;
        dec(SelectColsCount);
        find := true;
        break;
      end;
    end;
    if not find then
    begin
      SelectCols[SelectColsCount] := ACol;
      inc(SelectColsCount);
    end;
    // Edit1.Text:=inttostr(SelectColsCount);
  end;

  if m_curMode = nil then
    exit;
  ModePropE.text := m_curMode.caption;
  if m_curMode <> nil then
  begin
    UpdateControlsPropSG;
    if g_conmng.State <> c_play then
      TStringGrid(Sender).Invalidate;
  end;
  DropErrCode(9);
end;

procedure TFrm3120.TableModeSGSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  m_val := Value;
  m_col := ACol;
  m_row := ARow;
end;

procedure TFrm3120.TableModeSGTopLeftChanged(Sender: TObject);
begin
  setErrCode(10);
  ValsSG.TopRow := TableModeSG.TopRow;
  DropErrCode(10);
end;

function TFrm3120.SecToTime(t: double): double;
begin
  case TimeUnitsCB.ItemIndex of
    0:
      result := t; // sec
    1:
      result := t / 60; // min
    2:
      result := t / 3600; // hour
  end;
end;

procedure TFrm3120.SelectControl(c: cControlobj);
begin
  m_CurControl := c;
  UpdateControlsPropSG;
end;

procedure TFrm3120.setErrCode(e: Integer);
begin
  if m_err = 0 then
  begin
    m_err := e;
  end;
end;

procedure TFrm3120.DropErrCode(drop: Integer);
begin
  // разрешаем сброс ошибки в которой стоим
  if drop = m_err then
  begin
    m_err := 0;
  end;
end;

// обновить в таблице настройки контрола столбец с режимом
procedure TFrm3120.UpdateControlsPropSGmode(m: cmodeobj);
var
  I, j, k, n, ind: Integer;
  t: ctask;
  str, str1: string;
  d: double;
  MNcontrol: cMnControl;
  // pair: TTagPair;
  // ppair: pTagPair;
begin
  MNcontrol := nil;
  I := m.modeIndex;
  if m_CurControl <> nil then
  begin
    t := m.GetTask(m_CurControl.name);
    if m_CurControl is cMnControl then
    begin
      MNcontrol := cMnControl(m_CurControl);
      MNcontrol.m_data := t.m_data;
    end;
  end
  else
  begin
    t := m.GetTask(ControlPropE.text);
    if t <> nil then
    begin
      MNcontrol.m_data := t.m_data;
    end;
  end;
  if MNcontrol <> nil then
  begin
    ControlPropSG.RowCount := c_StopRow + 1;
    ControlPropSG.Cells[I + 1, c_Prow] := formatstrnoe(MNcontrol.m_data.p,
      c_digits);
    ControlPropSG.Cells[I + 1, c_Irow] := formatstrnoe(MNcontrol.m_data.I,
      c_digits);
    ControlPropSG.Cells[I + 1, c_Drow] := formatstrnoe(MNcontrol.m_data.d,
      c_digits);
    ControlPropSG.Cells[I + 1, c_ForwRow] := dirtostr(MNcontrol.m_data.forw);
    ControlPropSG.Cells[I + 1, c_TAlarmRow] := btostr(MNcontrol.m_data.TAlarm);
    ControlPropSG.Cells[I + 1, c_TthresholdRow] := formatstrnoe
      (MNcontrol.m_data.Tthreshold, c_digits);
    // вкл защиту по давл масла
    ControlPropSG.Cells[I + 1, c_PAlarmRow] := btostr(MNcontrol.m_data.Palarm);
    // Давление масла
    ControlPropSG.Cells[I + 1, c_PthresholdRow] := formatstrnoe
      (MNcontrol.m_data.Pthreshold, c_digits);
    ControlPropSG.Cells[I + 1, c_MNAlarmRow] := btostr
      (MNcontrol.m_data.MNAlarm);
    // ограничение по уровню M или N в зав от типа режима
    ControlPropSG.Cells[I + 1, c_MthresholdRow] := formatstrnoe
      (MNcontrol.m_data.Mthreshold, c_digits);
    ControlPropSG.Cells[I + 1, c_NthresholdRow] := formatstrnoe
      (MNcontrol.m_data.Nthreshold, c_digits);
    // ControlPropSG.Cells[i+1,c_ConditionRow]:=(MNcontrol.m_data.,c_digits);
    case MNcontrol.m_data.ModeType of
      mtN:
        ControlPropSG.Cells[I + 1, c_ModeRow] := 'N';
      mtM:
        ControlPropSG.Cells[I + 1, c_ModeRow] := 'M';
      mtStop:
        ControlPropSG.Cells[I + 1, c_ModeRow] := 'Стоп';
    end;
    ControlPropSG.Cells[I + 1, c_NRampRow] := formatstrnoe
      (MNcontrol.m_data.Nramp, c_digits);
    ControlPropSG.Cells[I + 1, c_MRampRow] := formatstrnoe
      (MNcontrol.m_data.Mramp, c_digits);
    ControlPropSG.Cells[I + 1, c_StartRow] := btostr
      (MNcontrol.m_data.cmd_start);
    ControlPropSG.Cells[I + 1, c_StopRow] := btostr(MNcontrol.m_data.cmd_stop);
  end
  else
  begin
    // отображаем актуаторы
    ControlPropSG.RowCount := 2;
    for j := 1 to 1 do
    begin
      ControlPropSG.Cells[I + 1, j] := '';
    end;
  end;
end;

procedure TFrm3120.updatedata;
var
  p: cProgramObj;
  v: double;
begin
  // обработка старта циклограммы. Отрисовка иначе не срабатывает т.к. тег взводится с задержкой в итерацию
  p := CurProg;
  v := round(GetMean(p.m_stateTag));
  if m_prevState <> v then
  begin
    fneedUpdate := true;
  end;
  m_prevState := round(v);
end;

procedure TFrm3120.updateModeSG(m: cmodeobj);
var
  I, col, row: Integer;
  j: Integer;
  t: ctask;
  str: string;
begin
  if m_curMode = nil then
    exit;
  m_curCol := getColumn(TableModeSG, m_curMode.caption);
  if m_CurControl <> nil then
  begin
    m_curRow := getRow(TableModeSG, m_CurControl.name, 0);
    // TableModeSG.Cells[m_curCol, 1] :=ToTime(m_CurMode.ModeLength, false);
    // TableModeSG.Cells[0, m_curRow] := m_CurControl.Caption;
    t := m_curMode.GetTask(m_CurControl.name);
    if t <> nil then
    begin
      TableModeSG.Cells[m_curCol, m_curRow] := getTaskVal(t);
    end;
    SGChange(TableModeSG, c_colScale);
  end;
end;

procedure TFrm3120.InitControlsPropSG;
var
  p: cProgramObj;
begin
  p := CurProg;
  ControlPropSG.ColCount := 1 + p.ModeCount;
  ControlPropSG.RowCount := c_StopRow + 2;
  ControlPropSG.Cells[0, 0] := 'Свойство';
  ControlPropSG.Cells[0, c_Prow] := 'P';
  ControlPropSG.Cells[0, c_Irow] := 'I';
  ControlPropSG.Cells[0, c_Drow] := 'D';
  ControlPropSG.Cells[0, c_ForwRow] := 'Направление';
  ControlPropSG.Cells[0, c_TAlarmRow] := 'Защита T';
  ControlPropSG.Cells[0, c_TthresholdRow] := 'Уровень T';
  ControlPropSG.Cells[0, c_PAlarmRow] := 'Защита Pм';
  ControlPropSG.Cells[0, c_PthresholdRow] := 'Уровень Pм';
  ControlPropSG.Cells[0, c_MNAlarmRow] := 'Защита M/N';
  ControlPropSG.Cells[0, c_MthresholdRow] := 'Уровень уставки M';
  ControlPropSG.Cells[0, c_NthresholdRow] := 'Уровень уставки N';
  ControlPropSG.Cells[0, c_ConditionRow] := 'Работа по усл.';
  ControlPropSG.Cells[0, c_ModeRow] := 'Тип режима';
  ControlPropSG.Cells[0, c_NRampRow] := 'Ограничение скор. N';
  ControlPropSG.Cells[0, c_MRampRow] := 'Ограничение скор. M';
  ControlPropSG.Cells[0, c_StartRow] := 'Команда старт';
  ControlPropSG.Cells[0, c_StopRow] := 'Команда стоп';
end;

procedure TFrm3120.UpdateControlsPropSG;
var
  p: cProgramObj;
  m: cmodeobj;
  t: ctask;
  I, j
  // состояние парсинга значений зон
    : Integer;
  str: STRING;
begin
  // обновляется по DblClick
  if m_CurControl = nil then
    exit;
  ControlPropE.text := m_CurControl.caption;

  p := CurProg;
  ControlPropSG.ColCount := 1 + p.ModeCount;

  for I := 0 to p.ModeCount - 1 do
  begin
    m := p.getmode(I);
    ControlPropSG.Cells[1 + m.modeIndex, 0] := m.caption;
    UpdateControlsPropSGmode(m);
  end;
  SGChange(ControlPropSG, c_colScale);
end;

procedure TFrm3120.UpdateControlsPropSGCallBack(m: TObject);
begin
  UpdateControlsPropSGmode(cmodeobj(m));
end;

procedure TFrm3120.ShowMeasured;
var
  col, j, I: Integer;
  m: cmodeobj;
  p: cProgramObj;
  c: cControlobj;
  t: ctask;
begin
  p := CurProg;
  for I := 0 to p.ControlCount - 1 do
  begin
    c := p.getOwnControl(I);
    col := p.ModeCount;
    if c is cMnControl then
    begin
      // M
      ValsSG.Cells[0, I + 2] := formatstrnoe(cMnControl(c).m_Mtagfb.GetMeanEst,
        c_digits) + ', ' + c_Munits;
      // N
      ValsSG.Cells[1, I + 2] := formatstrnoe(cMnControl(c).m_Ntagfb.GetMeanEst,
        c_digits) + ', ' + c_Rpmunits;
    end
    else
    begin
      ValsSG.Cells[0, I + 2] := formatstrnoe(cActControl(c).m_FBtag.GetMeanEst,
        c_digits) + ', %';
    end;
  end;
end;

procedure TFrm3120.ShowModes;
var
  col, j, I: Integer;
  m: cmodeobj;
  p: cProgramObj;
  t: ctask;
  str: string;
begin
  p := CurProg;
  for I := 0 to p.ModeCount - 1 do
  begin
    col := I + 1;
    m := p.getmode(I);
    // имя режима
    for j := 0 to m.TaskCount - 1 do
    begin
      t := m.GetTask(j);
      TableModeSG.Cells[col, j + 2] := getTaskVal(t);
    end;
  end;
end;

procedure TFrm3120.Splitter1Moved(Sender: TObject);
begin
  exit;
  setErrCode(6);
  SGChange(ValsSG);
  DropErrCode(6);
end;

procedure TFrm3120.ShowCyclogram;
var
  I, col: Integer;
  m: cmodeobj;
  p: cProgramObj;
  c: cControlobj;
begin
  setErrCode(11);
  p := CurProg;
  // имена режимов
  TableModeSG.ColCount := p.ModeCount + 1;
  for I := 0 to p.ModeCount - 1 do
  begin
    col := I + 1;
    m := p.getmode(I);
    // имя режима
    TableModeSG.Cells[col, 0] := m.caption;
    // длительность режима
    TableModeSG.Cells[col, 1] := formatstrnoe(SecToTime(m.ModeLength),
      c_digits);
  end;
  ShowModes;
  ShowMeasured;
  ValsSG.Cells[0, 0] := 'Измерено М';
  ValsSG.Cells[1, 0] := 'Измерено N';
  // отображаем контролы
  for I := 0 to p.ControlCount - 1 do
  begin
    c := p.getOwnControl(I);
    TableModeSG.Cells[0, 2 + I] := c.name;
  end;
  SGChange(TableModeSG, c_colScale);
  SGChange(ValsSG, c_colScale);
  DropErrCode(11);
end;

procedure TFrm3120.ShowErrorMessage(s: string);
begin
  Edit1.text := s;
  Edit1.Color := c_lightRed;
end;

procedure TFrm3120.ShowInfoMessage(s: string);
begin

  case m_err of
    0:
      begin
        if g_conmng.ErrorCount <> 0 then
        begin
          Edit1.text := g_conmng.ErrorStr;
        end
        else
        begin
          if s <> '' then
          begin
            Edit1.text := s;
          end;
        end;
        Edit1.Color := clWindow;
      end;
    1:
      Edit1.text := 'updateviews';
    2:
      Edit1.text := 'UpdateView';
    3:
      Edit1.text := 'TableModeSGDrawCell';
    4:
      Edit1.text := 'ControlPropSGDrawCell';
    //5:
      //Edit1.text := 'ValsSGDrawCell';
    6:
      Edit1.text := 'Splitter1Moved';
    7:
      Edit1.text := 'UpdateTimer';
    8:
      Edit1.text := 'SelectCell';
    9:
      Edit1.text := 'SelectCell';
    10:
      Edit1.text := 'TopLeftChanged';
    11:
      Edit1.text := 'Не корректный шаблон протокола';
    12:
      Edit1.text := 'Не корректный шаблон протокола';
    13:
      Edit1.text := 'Не корректный шаблон протокола';
    14:
      Edit1.text := 'Не корректный шаблон протокола';
    15:
      Edit1.text := 'Не корректный шаблон протокола';

  end;
  if m_err > 0 then
    Edit1.Color := c_lightRed;
end;

procedure TFrm3120.testInit;
var
  I: Integer;
begin
  if g_conmng.ProgramCount = 0 then
  begin
    testinit3120;
    testinit3120ThresholdsAbs;
  end;

  TableModeSG.RowCount := 11;
  TableModeSG.ColCount := c_MCount + 1;
  TableModeSG.Cells[0, 1] := 'Время работы';

  // ValsSG:=TNoWheelStringGrid.create(nil);
  // ValsSG.Font:=TableModeSG.Font;
  // ValsSG.align:=alClient;
  // ValsSG.BevelInner:=bvLowered;
  // ValsSG.BevelKind:=bkFlat;
  // ValsSG.Options:=TableModeSG.Options;
  // ValsSG.parent:=panel4;
  ValsSG.OnDrawCell := ValsSGDrawCell;
  ValsSG.RowCount := 11;
  ValsSG.ColCount := 2;
  ValsSG.EditorMode := false;

  m_CurControl := g_conmng.getControlObj(0);
  Preview;
end;

procedure TFrm3120.updateviews;
var
  p: cProgramObj;
  s: string;
  ec: Integer;
begin
  if (not fneedUpdate) and (g_conmng.State = c_play) then
    exit;
  p := CurProg;
  s := '';
  if p <> nil then
  begin
    if p.ActiveMode <> nil then
      s := p.ActiveMode.caption
    else
      s := '';
  end;
  UpdateTimers;
  TableModeSG.Invalidate;
  fneedUpdate := false;
end;

procedure TFrm3120.Timer1Timer(Sender: TObject);
var
  tid: Integer;
begin
  setErrCode(7);
  tid := GetCurrentThreadId;
  // деления на случай необходимости вызова из разных потоков
  if tid = MainThreadID then
  begin
    if g_conmng.exec then
    begin
      // пересчитываем реакцию регуляторов
      g_conmng.ExecControls;
      // отображаем
      fneedUpdate := true;
      // updateviews;
    end;
  end
  else
  begin
    if g_conmng.exec then
    begin
      // пересчитываем реакцию регуляторов
      g_conmng.ExecControls;
      // отображаем
      fneedUpdate := true;
      // updateviews;
    end;
  end;
  DropErrCode(7);
end;

function TFrm3120.ToTime(sec: double; b_format: Boolean): string;
var
  H, m, s, ATime: Integer;
begin
  if b_format then
  begin
    H := trunc(sec) div 3600;
    m := trunc((sec - H * 3600)) div 60;
    s := trunc(sec - H * 3600 - m * 60);
    result := Format('%d:%d:%d', [H, m, s]);
  end
  else
  begin
    result := formatstrnoe(SecToTime(sec), 2);
  end;
end;

procedure TFrm3120.UpdateView;
var
  p: cProgramObj;
begin
  ShowInfoMessage('');
  setErrCode(2);
  updateviews;
  ShowMeasured;
  DropErrCode(2);
  p := CurProg;
  if p <> nil then
  begin
    if g_conmng.State = c_play then
    begin
      case p.stateTag of
        c_Prog_CheckTol:
          ShowInfoMessage('Выход на режим ' + p.ActiveMode.caption);
        // программа закончилась
        c_Prog_EndTag:
          ShowInfoMessage('Программа закончилась');
        // программа проверяет режим
        c_Prog_CheckModeTag:
          ShowInfoMessage('Проверка допусков ' + p.ActiveMode.caption);
        // программа на бесконечном режиме
        c_Prog_InfinitiModeTag:
          ShowInfoMessage('Бесконечный режим ' + p.ActiveMode.caption);
        // программа продолжается
        c_Prog_PlayTag:
          ShowInfoMessage('Работа ' + p.ActiveMode.caption);
        // программа в паузе
        c_Prog_PauseTag:
          ShowInfoMessage('Пауза ' + p.ActiveMode.caption);
        // программа в стопе
        c_Prog_StopTag:
          ShowInfoMessage('Стоп');
      end;
    end;
  end;
end;

procedure TFrm3120.TableModeSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  sg: TStringGrid;
  mname: string;
  col, row: Integer;
  pPnt: TPoint;
  r: TRect;
  p: cProgramObj;
  m, newm: cmodeobj;
  I: Integer;
begin
  p := CurProg;
  if (Key = VK_UP) or (Key = VK_Down) then
  begin

  end;
  if Key = VK_RETURN then
  begin
    // вставка режима
    if m_insert > -1 then
    begin
      if m_insert = 1 then
        inc(m_insert);
      m := p.getmode(m_insert - 2);
      if m <> nil then
      begin
        if m_insert = (m.modeIndex + 1) then
        begin
          newm := m.copyMode(true);
        end
        else
        begin
          newm := m.copyMode(false);
        end;
        newm.name := TStringGrid(Sender).Cells[m_insert, 0];
        newm.caption := TStringGrid(Sender).Cells[m_insert, 0];
        m_insert := -1;
        // ShowControlPropsModes;
        UpdateControlsPropSG;
      end;
    end
    else
    begin
      ModeTabSGEditCell(m_row, m_col, m_val);
      // если редактировали имя режима
      if m_row = 0 then
      begin
        // ShowControlPropsModes;
        UpdateControlsPropSG;
      end;
    end;
  end;
  // отменяем вставку
  if Key = VK_DELETE then
  begin

    if m_insert > -1 then
    begin
      if not TStringGrid(Sender).EditorMode then
      begin
        GridRemoveColumn(TStringGrid(Sender), m_insert);
        m_insert := -1;
      end;
    end
    else
    begin
      if g_conmng.State = c_stop then
      begin
        m := getTableModeSGByCol(m_curCol);
        if not TStringGrid(Sender).EditorMode then
        begin
          if m <> nil then
          begin
            m_curMode := nil;
            m.destroy;
            ShowCyclogram;
            // ShowModes;
            // ShowMeasured;
            TableModeSG.Invalidate;
          end;
        end;
      end;
    end;
  end;
  // вставка режима
  if Key = VK_INSERT then
  begin
    // если на момент нажатия insert выбрано несколько режимов
    { if SelectColsCount>1 then
      begin
      for I := 0 to SelectColsCount - 1 do
      begin
      m := p.getmode(selectcols[i]-1);
      if m <> nil then
      begin
      newm := m.copyMode(false);
      newm.name := TStringGrid(Sender).Cells[selectcols[i]-1, 0];
      // ShowControlPropsModes;
      end;
      end;
      SelectColsCount:=0;
      UpdateControlsPropSG;
      end
      else }
    begin
      if m_insert > -1 then
        exit;
      GetCursorPos(pPnt);
      pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
      // Находим позицию нашей ячейки
      TStringGrid(Sender).MouseToCell(pPnt.X, pPnt.Y, col, row);
      if col = -1 then
        exit;
      if col > p.ModeCount then
        col := p.ModeCount;
      // переменная хранит добавляемый режим (удаляет по esc. прим. по enter)
      m_insert := col + 1;
      if col > -1 then
      begin
        sg := TStringGrid(Sender);
        mname := sg.Cells[col, 0];
        if col > 0 then
          GridAddColumn(sg, m_insert, sg.Colwidths[col])
        else
          GridAddColumn(sg, m_insert, sg.Colwidths[col + 1]);
        sg.Cells[m_insert, 0] := mname + '_';
      end;
    end;
  end;
  TableModeSG.Invalidate;
end;

function TFrm3120.toSec(t: double): double;
begin
  result := uCommonMath.toSec(t, TimeUnitsCB.ItemIndex)
end;

procedure TFrm3120.ModeTabSGEditCell(r, c: Integer; val: string);
var
  p: cProgramObj;
  m: cmodeobj;
  o: cBaseObj;
  t: ctask;
  con: cControlobj;
  str: string;
  I, sepCount: Integer;
begin
  if r <> 0 then
  begin
    str := '';
    sepCount := 0;
    if not isvalue(val) then
    begin
      for I := 1 to length(val) do
      begin
        if isvalue(val[I]) then
        begin
          str := str + val[I];
        end
        else
        begin
          if (val[I] = '.') or (val[I] = ',') then
          begin
            inc(sepCount);
            if sepCount > 1 then
              break;
          end
          else
          begin
            break;
          end;
        end;
      end;
      if not isvalue(str) then
        exit
      else
        val := str;
    end;
  end;
  p := CurProg;
  if p = nil then
    exit;
  if c > 0 then
  begin
    m := p.getmode(c - 1);
    // редактируем длительность
    if r = 1 then
    begin
      m.ModeLength := toSec(strtofloatext(val));
    end;
    // в случае если поменяли имя режима
    if r = 0 then
    begin
      if m <> nil then
      begin
        // переименование режима
        if m.name <> TableModeSG.Cells[c, 0] then
        begin
          // o:=g_conmng.getobj(TableModeSG.Cells[c, 0]);
          // if o<>nil then
          begin
            m.name := p.name + '_' + TableModeSG.Cells[c, 0];
            m.caption := TableModeSG.Cells[c, 0];
          end;
        end;
      end;
    end;
    // в случае если поменяли значение задания
    if r > 1 then
    begin
      str := TableModeSG.Cells[0, r];
      con := p.getOwnControl(str);
      if con <> nil then
      begin
        if m <> nil then
        begin
          if r > 1 then
          begin
            t := m.GetTask(con.name);
            if t <> nil then
            begin
              case t.m_data.ModeType of
                mtN:
                  TableModeSG.Cells[c, r] := TableModeSG.Cells[c,
                    r] + ', ' + c_Rpmunits;
                mtM:
                  TableModeSG.Cells[c, r] := TableModeSG.Cells[c,
                    r] + ',' + c_Munits;
                // mtN: TableModeSG.Cells[0, r];
              end;
              t.enterCs;
              t.task := strtofloatext(val);
              t.applyed := false;
              t.exitCs;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TFrm3120.TestNameCbChange(Sender: TObject);
begin
  if TestNameCb.ItemIndex > -1 then
  begin
    g_test := cxmlfolder(TestNameCb.items.objects[TestNameCb.ItemIndex]);
  end;
end;

procedure TFrm3120.ObjNameCbChange(Sender: TObject);
begin
  if TestNameCb.ItemIndex > -1 then
  begin
    g_obj := cxmlfolder(ObjNameCb.items.objects[ObjNameCb.ItemIndex]);
    // работает с глобальным g_obj
    ShowObj(TestNameCb);
  end;

end;

procedure TFrm3120.OkDBbtnClick(Sender: TObject);
begin
  createObj(ObjNameCb.text, TestNameCb.text);
  // объект в combobox
  if g_obj <> nil then
  begin
    ObjNameCb.AddItem(g_obj.name, g_obj);
    setComboBoxItem(g_obj.name, ObjNameCb);
  end;
  if g_test <> nil then
  begin
    // испытание в combobox
    TestNameCb.AddItem(g_test.caption, g_test);
    setComboBoxItem(g_test.caption, TestNameCb);
    OkDBbtn.ShowHint := true;
    OkDBbtn.Hint := g_test.Absolutepath;
  end;
  CheckCBItemInd(ObjNameCb);
  CheckCBItemInd(TestNameCb);
end;

procedure TFrm3120.OpenRepBtnClick(Sender: TObject);
var
  s: string;
begin
  g_CpEngine.OpenReport;
  s := testpath + '\' + 'Report.xlsx';
  if not g_CpEngine.checkRepPath then
  begin
    ShowErrorMessage('Протокол не создан ' + s);
  end
  else
  begin
    Edit1.Color := clWindow;
  end;
end;

end.
