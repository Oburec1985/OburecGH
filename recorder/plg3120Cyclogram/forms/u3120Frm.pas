unit u3120Frm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  inifiles,
  Dialogs, ImgList, ExtCtrls, Grids, ComCtrls, StdCtrls, Buttons,
  recorder,
  uRecBasicFactory, uEventTypes, uRecorderEvents,
  uComponentServises, uConfirmDlg,
  u3120Factory,u3120ControlObj,
  uControlObj,
  uModeObj, uProgramObj,
  MathFunction, uCommonMath,
  pluginclass, urcfunc,
  uTest,
  uThresholds3120Frm,
  pngimage;

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
    AlarmsBtn: TSpeedButton;
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
  private
    mThread: cardinal;
    // ����� ������������� ��������
    m_CurControl: cControlobj;
    m_CurMode: cModeObj;
    m_uiThread: Integer;
    // ����� ��������� �������� ������. ����� ��� ����������� ����� ����
    m_counted: boolean;
    m_curCol, m_curRow: Integer;
    finit, fload: boolean;

    m_val: string;
    m_row, m_col: Integer;
    m_apply: boolean;
    m_timerid, m_timerid_res: cardinal;

    // ������� ������ � TableModeSG; ����� ������� ��� �������
    m_insert:integer;
  public
    // ����������� ���������� ��� ���������
    // m_CustSort:boolean;
    // ������ cControlObj ������� ����� ���������� �� ���������� � cProgrObj
    // m_ViewControls:tlist;
  protected
    // ������ �������������� ������(������� �������� ������ ������� � �������)
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
    function ToTime(sec: double; b_format: boolean): string;
    procedure doChangeRState(Sender: TObject);
    procedure doAddObj(Sender: TObject);
    procedure doRcInit(Sender: TObject);
    procedure doShowStop(Sender: TObject);
    procedure doLeaveCfg(Sender: TObject);
    procedure EnablePult(b_state: boolean);
    function getControlFromTableModeSGByRow(row: Integer): cControlobj;
    function getTableModeSGByCol(col: Integer): cModeObj;
    procedure SelectControl(c: ccontrolobj);

    procedure InitControlsPropSG;
    procedure UpdateControlsPropSG;
    procedure UpdateControlsPropSGmode(m: cModeObj);

    // ��������������� ������
    procedure ModeTabSGEditCell(r, c: integer; val: string);
    function toSec(t: double): double;
  public
    function SecToTime(t: double): double;
    // ���������� � doRepaint
    procedure UpdateView;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
    //
    procedure testInit;
    procedure ShowCyclogram;
    // ���������� �������
    procedure ShowModes;
    // ���������� ���������
    procedure ShowMeasured;
  end;

var
  Frm3120: TFrm3120;
  g_3120Factory: c3120Factory;

const
  clGrass = TColor($00A7FED0);
  c_digits = 4;
  c_MCount = 6;

implementation

{$R *.dfm}
{ TFrm3120 }

procedure TFrm3120.Preview;
begin
  ShowCyclogram;
  InitControlsPropSG;
  UpdateControlsPropSG;
end;

procedure TFrm3120.doLeaveCfg(Sender: TObject);
begin
  if not finit then
    exit;
  if not fload then
    exit;
  m_CurControl := nil;
  m_CurMode := nil;
  ControlPropE.text := '';
  if g_createGUI then
    Preview;
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
  Preview;
  // testInit;
  // if ThresholdFrm<>nil then
  begin
    // for I := 0 to ThresholdFrm.m_Groups.Count - 1 do
    begin
      // g:=ThresholdFrm.getGroup(i);
      // ������ ������ ����� ������� �������
      // g.initiface;
    end;
  end;
end;

procedure TFrm3120.doShowStop(Sender: TObject);
begin
  StopPanel.Color := clMoneyGreen;
  PlayPanel.Color := clBtnFace;
  PausePanel.Color := clBtnFace;
  updateviews;
end;

procedure TFrm3120.CreateEvents;
begin
  addplgevent('TFrm3120_doAddObj', E_OnAddObj, doAddObj);
  addplgevent('TFrm3120_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
  addplgevent('TFrm3120_doLeaveCfg', c_RC_LeaveCfg, doLeaveCfg);
  addplgevent('TFrm3120_doRcInit', E_RC_Init, doRcInit);
  g_conmng.Events.AddEvent('TFrm3120_doStopControlMng', E_OnStopControlMng, doShowStop);
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
begin
  ir := getIRecorder;
  if g_conmng.State = c_stop then
  begin
    g_conmng.Start;
    if ContinueCB.Checked then
    begin
      g_conmng.LoadState;
    end;
  end
  else
  begin
    if g_conmng.State = c_Pause then
    begin
      g_conmng.continuePlay;
    end;
  end;
  // ��������� �������
  PlayPanel.Color := clMoneyGreen;
  PausePanel.Color := clBtnFace;
  StopPanel.Color := clBtnFace;
end;

procedure TFrm3120.Stop;
begin
  g_conmng.Stop;
  TableModeSG.FixedRows := 0;
end;

procedure TFrm3120.pause;
begin
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
    p := g_conmng.getprogram(0);
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

constructor TFrm3120.create(Aowner: tcomponent);
begin
  inherited;

  ConfirmFmr := TConfirmFmr.Create(nil);
  ThresholdFrm:=TThresholdFrm.Create(nil);

  CreateEvents;
  testInit;
  m_insert:=-1;
  m_CurMode := nil;
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
  inherited;
end;

procedure TFrm3120.EnablePult(b_state: boolean);
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

function TFrm3120.getControlFromTableModeSGByRow(row: Integer): cControlobj;
var
  str: string;
  p: cProgramObj;
begin
  result := nil;
  if row > 0 then
  begin
    str := TableModeSG.Cells[0, row];
    p := g_conmng.getprogram(0);
    if p <> nil then
    begin
      result := p.getOwnControl(str);
    end;
  end;
end;

function TFrm3120.getTableModeSGByCol(col: Integer): cModeObj;
var
  str: string;
  p: cProgramObj;
begin
  result := nil;
  if col > 0 then
  begin
    str := TableModeSG.Cells[col, 0];
    p := g_conmng.getprogram(0);
    if p <> nil then
    begin
      result := p.getmode(str);
    end;
  end;
end;


procedure TFrm3120.doChangeRState(Sender: TObject);
var
  Rstate: boolean;
  p: cProgramObj;
  c: cControlobj;
  ec, I: Integer;
  str: string;
begin
  if self <> nil then
  begin
    Rstate := RStatePlay;

    EnablePult(Rstate);
    Timer1.Interval := round(GetREFRESHPERIOD * 1000);
    if Rstate then
    begin
      // ShowTrigs;
      // m_timerid_res:=SetTimer(handle, m_timerid, Timer1.Interval, @TimeProc);
      // m_timerid_res:=SetTimer(MainThreadID, m_timerid, Timer1.Interval, @TimeProc);
      Timer1.Enabled := true
    end
    else
    begin
      // ��������� �������� ��� ������������ �������� ���������� � ��������
      p := g_conmng.getprogram(0);
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
      // if g_conmng.state<>c_stop then showmessage('���������� Timer � ��������� c_TryStop');
      Timer1.Enabled := false;

      if g_conmng.State <> c_stop then
      begin
        g_conmng.State := c_stop;
      end;
      if p <> nil then
      begin
        if p.ActiveMode <> nil then
          str := p.ActiveMode.name
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
end;


procedure TFrm3120.PauseBtnClick(Sender: TObject);
VAR
  b: boolean;
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
  b: boolean;
begin
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

procedure TFrm3120.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  I: Integer;
  c:cControlObj;
  s:string;
  ifile:tinifile;
begin
  inherited;
  // �������� ����������� ���������
  a_pIni.WriteBool(str, 'ConfirmModeChange', ConfirmModeCB.Checked);
  a_pIni.WriteInteger(str, 'Units', TimeUnitsCB.ItemIndex);
  a_pIni.WriteInteger(str, 'Table_Controls_Splitter_Pos', RightGB.Width);
  a_pIni.WriteBool(str, 'LoadState', ContinueCB.Checked);
end;

procedure TFrm3120.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  s, s1:string;
  pars:tstringlist;
  c:integer;
  I: Integer;
  con:ccontrolobj;
begin
  inherited;
  ContinueCB.Checked := a_pIni.ReadBool(str, 'LoadState', false);
  ConfirmModeCB.Checked := a_pIni.ReadBool(str, 'ConfirmModeChange', true);
  TimeUnitsCB.ItemIndex := a_pIni.ReadInteger(str, 'Units', 0);
  RightGB.Width := a_pIni.ReadInteger(str, 'Table_Controls_Splitter_Pos', RightGB.Width);
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
        cModeObj(m).TryActive
      else
      begin
        if g_conmng.State = c_Pause then
        begin
          cModeObj(m).active := true;
          cModeObj(m).exec;
        end;
      end;
    end;
  end;
end;

procedure TFrm3120.TableModeSGDblClick(Sender: TObject);
var
  m: cModeObj;
  c: cControlobj;
  pPnt: TPoint; // ���������� �������
  xCol, xRow: Integer; // ����� ������ �������
begin
  GetCursorPos(pPnt);
  pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
  // ������� ������� ����� ������
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
        ConfirmFmr.SetText('���������� ����� ' + m.name);
        ConfirmFmr.Execute;
      end
      else // ����������� �������
      begin
        ConfirmManualSwitchMode(m);
      end;
    end;
  end
  else
    TableModeSG.Invalidate;
end;

procedure TFrm3120.TableModeSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: Integer;
  str: string;
  I: Integer;
  p: cProgramObj;
  m: cModeObj;
  c: cControlobj;
begin
  sg := TStringGrid(Sender);
  Color := sg.Canvas.Brush.Color;
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
    exit;
  end;

  // ���������
  if (ACol = 5) then
  begin
    sg.Canvas.Brush.Color := clYellow;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
  end;

  // ���������
  if (ACol = 6) or (ACol = 7) then
  begin
    sg.Canvas.Brush.Color := clCream;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
  end;

  // ����� ������ ��������� ��������
  if ARow >= 1 then
  begin
    str:=sg.Cells[0, ARow];
    if g_conmng<>nil then
    begin
      c:=g_conmng.getControlObj(str);
      sg.Canvas.Brush.Color := clWindow;
      // ����� ������ � �������� ���������
      if m_CurControl<>nil then
      begin
        if c=m_CurControl  then
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

  // ��������� ������ ��������� ������
  if (g_conmng.State = c_play) or (g_conmng.State = c_Pause) then
  begin
    for I := 0 to g_conmng.ProgramCount - 1 do
    begin
      p := g_conmng.getprogram(I);
      m := p.ActiveMode;
      if m <> nil then
      begin
        // ��� ������
        str := sg.Cells[ACol, 0];
        // ������� �������
        if str = m.name then
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
end;


procedure TFrm3120.AlarmsBtnClick(Sender: TObject);
begin
  if ThresholdFrm=nil then
  begin
    ThresholdFrm:=TThresholdFrm.Create(nil);
  end;
  ThresholdFrm.ShowModal;
end;

procedure TFrm3120.CancelEditMode;
var
  I, col, row: integer;
  j: integer;
  t: ctask;
begin
  //TableModeSG.Cells[col, 0] := m.Caption;
  if m_CurMode=nil then exit;
  m_curCol:= getColumn(TableModeSG, m_CurMode.name);
  if m_CurControl<>nil then
  begin
    m_curRow:= getRow(TableModeSG, m_CurControl.name, 0);
    TableModeSG.Cells[m_curCol, 1] :=ToTime(m_CurMode.ModeLength, false);
    TableModeSG.Cells[0, m_curRow] := m_CurControl.Caption;
    t := m_CurMode.gettask(m_CurControl.name);
    if t <> nil then
    begin
      TableModeSG.Cells[m_curCol, m_curRow] := formatstrnoe(t.task, c_digits);
    end;
    SGChange(TableModeSG);
  end;
end;

procedure TFrm3120.TableModeSGSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  c:cControlObj;
  m:cModeObj;
begin
  //showmessage('str: ' + inttostr(arow)+ '; col: '+inttostr(aCol));
  CancelEditMode;
  m_curRow:=arow;
  m_curCol:=ACol;
  c := getControlFromTableModeSGByRow(m_curRow);
  if c <> nil then
  begin
    m_CurControl := c;
    ControlPropE.text := c.Name;
  end;
  m := getTableModeSGByCol(m_curCol);
  if m <> nil then
    m_CurMode := m;
  if m_CurMode=nil then exit;
  ModePropE.text :=  m_CurMode.name;
  if m_CurMode <> nil then
  begin
    UpdateControlsPropSG;
    if g_conmng.state<>c_play then
      TStringGrid(Sender).Invalidate;
  end;
end;

procedure TFrm3120.TableModeSGSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  m_val := Value;
  m_col := ACol;
  m_row := ARow;
end;

function TFrm3120.SecToTime(t: double): double;
begin
  case TimeUnitsCB.itemindex of
    0:
      result := t; // sec
    1:
      result := t / 60; // min
    2:
      result := t / 3600; // hour
  end;
end;

procedure TFrm3120.SelectControl(c: ccontrolobj);
begin
  m_CurControl := c;
  UpdateControlsPropSG;
end;

procedure TFrm3120.UpdateControlsPropSGmode(m: cModeObj);
var
  I, j, k, n, ind: integer;
  t: ctask;
  str, str1: string;
  d: double;
  MNcontrol:cMNControl;
  //pair: TTagPair;
  //ppair: pTagPair;
begin
  MNcontrol:=nil;
  I := m.modeIndex;
  if m_CurControl <> nil then
  begin
    t := m.gettask(m_CurControl.name);
    if m_CurControl is cMNControl then
    begin
      MNControl:=cMNControl(m_CurControl);
      MNcontrol.m_data := t.m_data;
    end;
  end
  else
  begin
    t := m.gettask(ControlPropE.text);
    if t <> nil then
    begin
      MNcontrol.m_data := t.m_data;
    end;
  end;
  if MNcontrol<>nil then
  begin
    ControlPropSG.Cells[i+1,1]:=formatstrnoe (MNcontrol.m_data.P, c_digits);
    ControlPropSG.Cells[i+1,2]:=formatstrnoe (MNcontrol.m_data.I,c_digits);
    ControlPropSG.Cells[i+1,3]:=formatstrnoe (MNcontrol.m_data.D, c_digits);
    ControlPropSG.Cells[i+1,4]:=BoolToStr(MNcontrol.m_data.TAlarm);
    ControlPropSG.Cells[i+1,5]:=formatstrnoe (MNcontrol.m_data.Tthreshold,c_digits);
    // ��� ������ �� ���� �����
    ControlPropSG.Cells[i+1,6]:=BoolToStr(MNcontrol.m_data.Palarm);
    // �������� �����
    ControlPropSG.Cells[i+1,7]:=formatstrnoe (MNcontrol.m_data.Pthreshold,c_digits);
    ControlPropSG.Cells[i+1,8]:=BoolToStr(MNcontrol.m_data.MNAlarm);
    // ����������� �� ������ M ��� N � ��� �� ���� ������
    ControlPropSG.Cells[i+1,9]:=formatstrnoe (MNcontrol.m_data.MNthreshold,c_digits);
    //ControlPropSG.Cells[0,10]:=m_CurControl.m_data.;
    case MNcontrol.m_data.ModeType of
      mtN: ControlPropSG.Cells[i+1,11]:='N';
      mtM: ControlPropSG.Cells[i+1,11]:='M';
      mtStop: ControlPropSG.Cells[i+1,11]:='����';
    end;
    ControlPropSG.Cells[i+1,12]:=formatstrnoe (MNcontrol.m_data.Nramp,c_digits);
  end
  else
  begin
    for j := 1 to 12 do
    begin
      ControlPropSG.Cells[i+1,j]:='';
    end;
  end;
end;

procedure TFrm3120.InitControlsPropSG;
var
  p:cProgramObj;
begin
  p := g_conmng.getprogram(0);
  ControlPropSG.ColCount := 1 + p.ModeCount;
  ControlPropSG.RowCount:=13;
  ControlPropSG.Cells[0,0]:='��������';
  ControlPropSG.Cells[0,1]:='P';
  ControlPropSG.Cells[0,2]:='I';
  ControlPropSG.Cells[0,3]:='D';
  ControlPropSG.Cells[0,4]:='������ T';
  ControlPropSG.Cells[0,5]:='������� T';
  ControlPropSG.Cells[0,6]:='������ P�';
  ControlPropSG.Cells[0,7]:='������� P�';
  ControlPropSG.Cells[0,8]:='������ M/N';
  ControlPropSG.Cells[0,9]:='������� M/N';
  ControlPropSG.Cells[0,10]:='������ �� ���.';
  ControlPropSG.Cells[0,11]:='��� ������';
  ControlPropSG.Cells[0,12]:='����������� ����. N';
end;

procedure TFrm3120.UpdateControlsPropSG;
var
  p: cProgramObj;
  m: cModeObj;
  t: ctask;
  I, j
  // ��������� �������� �������� ���
    : integer;
  str: STRING;
begin
  // ����������� �� DblClick
  if m_CurControl = nil then
    exit;
  ControlPropE.text := m_CurControl.Caption;

  p := g_conmng.getprogram(0);
  ControlPropSG.ColCount := 1 + p.ModeCount;

  for I := 0 to p.ModeCount - 1 do
  begin
    m := p.getmode(I);
    ControlPropSG.Cells[1+m.modeIndex,0]:=m.name;
    UpdateControlsPropSGmode(m);
  end;
  SGChange(ControlPropSG);
end;

procedure TFrm3120.ShowMeasured;
var
  col, j, I: Integer;
  m: cModeObj;
  p: cProgramObj;
  c: cControlobj;
  t: ctask;
begin
  p := g_conmng.getprogram(0);
  for I := 0 to p.ControlCount - 1 do
  begin
    c := p.getOwnControl(I);
    col := p.ModeCount;
    if c is cMNControl then
    begin
      // M
      TableModeSG.Cells[col + 1, I + 2] := formatstrnoe(cMNControl(c).m_MtagFB.GetMeanEst, 3)+', �';
      // N
      TableModeSG.Cells[col + 2, I + 2] := formatstrnoe(cMNControl(c).m_NtagFB.GetMeanEst, 3)+', ��.';
    end;
  end;
end;

procedure TFrm3120.ShowModes;
var
  col, j, I: Integer;
  m: cModeObj;
  p: cProgramObj;
  t: ctask;
  str:string;
begin
  p := g_conmng.getprogram(0);
  for I := 0 to p.ModeCount - 1 do
  begin
    col := I + 1;
    m := p.getmode(I);
    // ��� ������
    for j := 0 to m.TaskCount - 1 do
    begin
      t := m.GetTask(j);
      str:=formatstrnoe(t.task, 3);
      case t.m_data.ModeType of
        mtN: str:=str+', ��.';
        mtM: str:=str+', �.';
        //mtN: str:=str+', ��.';
      end;
      TableModeSG.Cells[col, j + 2] := str;
    end;
  end;
end;

procedure TFrm3120.ShowCyclogram;
var
  I, col: Integer;
  m: cModeObj;
  p: cProgramObj;
  c: cControlobj;
begin
  // TableModeSG.RowCount:=10;
  // TableModeSG.ColCount:=g_conmng.ModeCount;
  // ����� �������
  p := g_conmng.getprogram(0);
  for I := 0 to p.ModeCount - 1 do
  begin
    col := I + 1;
    m := p.getmode(I);
    // ��� ������
    TableModeSG.Cells[col, 0] := m.name;
    // ������������ ������
    TableModeSG.Cells[col, 1] := floattostr(SecToTime(m.ModeLength));
  end;
  ShowModes;
  ShowMeasured;
  TableModeSG.Cells[p.ModeCount + 1, 0] := '�������� �';
  TableModeSG.Cells[p.ModeCount + 2, 0] := '�������� N';
  // ���������� ��������
  for I := 0 to p.ControlCount - 1 do
  begin
    c := p.getOwnControl(I);
    TableModeSG.Cells[0, 2 + I] := c.name;
  end;
  SGChange(TableModeSG);
end;

procedure TFrm3120.testInit;
var
  I: Integer;
begin
  testinit3120;

  TableModeSG.RowCount := 10;
  TableModeSG.ColCount := c_MCount + 2;
  TableModeSG.Cells[0, 1] := '����� ������';

  m_CurControl:=g_conmng.getControlObj(0);
  Preview;
  exit;

  // ������
  TableModeSG.Cells[1, 0] := '�����_1';
  TableModeSG.Cells[2, 0] := '�����_2';
  TableModeSG.Cells[3, 0] := '�����_3';
  TableModeSG.Cells[4, 0] := '�����_����';
  TableModeSG.Cells[5, 0] := '�������� �';
  TableModeSG.Cells[6, 0] := '�������� N';

  // ����� ������
  TableModeSG.Cells[1, 1] := '1, ���';
  TableModeSG.Cells[2, 1] := '0.5, ���';
  TableModeSG.Cells[3, 1] := '1.5, ���';
  TableModeSG.Cells[4, 1] := '10, ���';
  // ����� ������
  TableModeSG.Cells[0, 2] := 'M1';
  TableModeSG.Cells[1, 2] := '1000 ��/���';
  TableModeSG.Cells[2, 2] := '3000 ��';
  TableModeSG.Cells[3, 2] := '2500 ��';
  TableModeSG.Cells[4, 2] := '0 ��';
  TableModeSG.Cells[5, 2] := '2488 ��';
  TableModeSG.Cells[6, 2] := '2300 ��/���';

  TableModeSG.Cells[0, 3] := 'M2';
  TableModeSG.Cells[1, 3] := '1000 ��/���';
  TableModeSG.Cells[2, 3] := '2500 ��';
  TableModeSG.Cells[3, 3] := '1500 ��';
  TableModeSG.Cells[4, 3] := '0 ��';
  TableModeSG.Cells[5, 3] := '1495 ��';
  TableModeSG.Cells[6, 3] := '1334 ��/���';

  TableModeSG.Cells[0, 4] := 'M3';
  TableModeSG.Cells[1, 4] := '1000 ��/���';
  TableModeSG.Cells[2, 4] := '3000 ��';
  TableModeSG.Cells[3, 4] := '2000 ��';
  TableModeSG.Cells[4, 4] := '0 ��';
  TableModeSG.Cells[5, 4] := '1995 ��';
  TableModeSG.Cells[6, 4] := '1834 ��/���';

  TableModeSG.Cells[0, 5] := 'M4';
  TableModeSG.Cells[1, 5] := '1000 ��/���';
  TableModeSG.Cells[2, 5] := '3000 ��';
  TableModeSG.Cells[3, 5] := '2000 ��';
  TableModeSG.Cells[4, 5] := '0 ��';
  TableModeSG.Cells[5, 5] := '1995 ��';
  TableModeSG.Cells[6, 5] := '1834 ��/���';

  TableModeSG.Cells[0, 6] := 'M5';
  TableModeSG.Cells[1, 6] := '1000 ��/���';
  TableModeSG.Cells[2, 6] := '3000 ��';
  TableModeSG.Cells[3, 6] := '2000 ��';
  TableModeSG.Cells[4, 6] := '0 ��';
  TableModeSG.Cells[5, 6] := '1995 ��';
  TableModeSG.Cells[6, 6] := '1834 ��/���';

  TableModeSG.Cells[0, 7] := '����������';
  TableModeSG.Cells[1, 7] := '0%';
  TableModeSG.Cells[2, 7] := '0%';
  TableModeSG.Cells[3, 7] := '30%';
  TableModeSG.Cells[4, 7] := '0%';
  TableModeSG.Cells[5, 7] := '29%';

  TableModeSG.Cells[0, 8] := '�������';
  TableModeSG.Cells[1, 8] := '0%';
  TableModeSG.Cells[2, 8] := '30%';
  TableModeSG.Cells[3, 8] := '50%';
  TableModeSG.Cells[4, 8] := '80%';
  TableModeSG.Cells[5, 8] := '50,5%';

  TableModeSG.Cells[0, 9] := '����. ��������';
  TableModeSG.Cells[1, 9] := '0%';
  TableModeSG.Cells[2, 9] := '0%';
  TableModeSG.Cells[3, 9] := '0%';
  TableModeSG.Cells[4, 9] := '0%';
  TableModeSG.Cells[5, 9] := '0%';

  SGChange(TableModeSG);
  TableModeSG.ColWidths[0] := TableModeSG.ColWidths[0] + 20;

  ControlPropE.text := 'M2_���';

  ControlPropSG.RowCount := 13;
  ControlPropSG.ColCount := c_MCount;
  ControlPropSG.Cells[0, 0] := '��������';
  ControlPropSG.Cells[1, 0] := '�����_1';
  ControlPropSG.Cells[2, 0] := '�����_2';
  ControlPropSG.Cells[3, 0] := '�����_3';
  ControlPropSG.Cells[4, 0] := '�����_����';

  ControlPropSG.Cells[0, 1] := 'P';
  ControlPropSG.Cells[1, 1] := '1';
  ControlPropSG.Cells[2, 1] := '1';
  ControlPropSG.Cells[3, 1] := '1.1';
  ControlPropSG.Cells[4, 1] := '1';

  ControlPropSG.Cells[0, 2] := 'I';
  ControlPropSG.Cells[1, 2] := '0.1';
  ControlPropSG.Cells[2, 2] := '0.1';
  ControlPropSG.Cells[3, 2] := '0.15';
  ControlPropSG.Cells[4, 2] := '0.1';

  ControlPropSG.Cells[0, 3] := 'D';
  ControlPropSG.Cells[1, 3] := '0.01';
  ControlPropSG.Cells[2, 3] := '0.01';
  ControlPropSG.Cells[3, 3] := '0.015';
  ControlPropSG.Cells[4, 3] := '0.01';

  ControlPropSG.Cells[0, 4] := '������ T';
  ControlPropSG.Cells[1, 4] := '���.';
  ControlPropSG.Cells[2, 4] := '���.';
  ControlPropSG.Cells[3, 4] := '���.';
  ControlPropSG.Cells[4, 4] := '���.';

  ControlPropSG.Cells[0, 5] := '������� T';
  ControlPropSG.Cells[1, 5] := '200, �';
  ControlPropSG.Cells[2, 5] := '200, �';
  ControlPropSG.Cells[3, 5] := '200, �';
  ControlPropSG.Cells[4, 5] := '200, �';

  ControlPropSG.Cells[0, 6] := '������ P�';
  ControlPropSG.Cells[1, 6] := '���.';
  ControlPropSG.Cells[2, 6] := '���.';
  ControlPropSG.Cells[3, 6] := '���.';
  ControlPropSG.Cells[4, 6] := '���.';

  ControlPropSG.Cells[0, 7] := '������� P�';
  ControlPropSG.Cells[1, 7] := '1, ���.';
  ControlPropSG.Cells[2, 7] := '1, ���.';
  ControlPropSG.Cells[3, 7] := '1, ���.';
  ControlPropSG.Cells[4, 7] := '1, ���.';

  ControlPropSG.Cells[0, 8] := '������ M/N';
  ControlPropSG.Cells[1, 8] := '���.';
  ControlPropSG.Cells[2, 8] := '���.';
  ControlPropSG.Cells[3, 8] := '���.';
  ControlPropSG.Cells[4, 8] := '���.';
  // ������� ������������ � ���������� ��� ���������� ������� �� �����
  // ��������� ���������� ����� ���� � ������
  ControlPropSG.Cells[0, 9] := '������� ������';
  ControlPropSG.Cells[1, 9] := '50, ��/���';
  ControlPropSG.Cells[2, 9] := '100, ��';
  ControlPropSG.Cells[3, 9] := '100, ��';
  ControlPropSG.Cells[4, 9] := '10, ��';

  ControlPropSG.Cells[0, 10] := '������ �� ���.';
  ControlPropSG.Cells[1, 10] := '���.';
  ControlPropSG.Cells[2, 10] := '���.';
  ControlPropSG.Cells[3, 10] := '���.';
  ControlPropSG.Cells[4, 10] := '���.';

  ControlPropSG.Cells[0, 11] := '��� ������';
  ControlPropSG.Cells[1, 11] := '���������';
  ControlPropSG.Cells[2, 11] := '���������';
  ControlPropSG.Cells[3, 11] := '���������';
  ControlPropSG.Cells[4, 11] := '����';

  ControlPropSG.Cells[0, 12] := '����������� ����. N';
  ControlPropSG.Cells[1, 12] := '1, ��';
  ControlPropSG.Cells[2, 12] := '1, ��';
  ControlPropSG.Cells[3, 12] := '1, ��';
  ControlPropSG.Cells[4, 12] := '1, ��';

  GridAddColumn(TableModeSG, 6);
  for I := 0 to 12 do
  begin
    TableModeSG.Cells[5, I] := TableModeSG.Cells[4, I];
  end;
  TableModeSG.Cells[5, 0] := '��� ������';

  SGChange(ControlPropSG);
  ControlPropSG.ColWidths[0] := ControlPropSG.ColWidths[0] + 30;
end;

procedure TFrm3120.updateviews;
var
  p: cProgramObj;
  s: string;
  ec: Integer;
begin
  p := g_conmng.getprogram(0);
  s := '';
  if p <> nil then
  begin
    if p.ActiveMode <> nil then
      s := p.ActiveMode.name
    else
      s := '';
    ec := g_conmng.ErrorCount;
    if ec <> 0 then
    begin
      // ActiveModeE.text :=s+' '+g_conmng.ErrorStr;
    end
    else
    begin
      // ActiveModeE.text:=s;
    end;
  end;
  UpdateTimers;
  TableModeSG.Invalidate;
  // UpdateControlsPropSG;
end;

procedure TFrm3120.Timer1Timer(Sender: TObject);
var
  tid: Integer;
begin
  tid := GetCurrentThreadId;
  // ������� �� ������ ������������� ������ �� ������ �������
  if tid = MainThreadID then
  begin
    if g_conmng.exec then
    begin
      // ������������� ������� �����������
      g_conmng.ExecControls;
      // ����������
      updateviews;
    end;
  end
  else
  begin
    if g_conmng.exec then
    begin
      // ������������� ������� �����������
      g_conmng.ExecControls;
      // ����������
      updateviews;
    end;
  end;
end;

function TFrm3120.ToTime(sec: double; b_format: boolean): string;
var
  H, m, s, ATime: Integer;
begin
  if b_format then
  begin
    H := trunc(sec) div 3600;
    m := trunc((sec - H * 3600)) div 60;
    s := trunc(sec - H * 3600 - m * 60);
    // result:= Format('%d � %d � %d �', [H, M, S]);
    result := Format('%d:%d:%d', [H, m, s]);
  end
  else
  begin
    result := formatstrnoe(SecToTime(sec), 2);
  end;
end;

procedure TFrm3120.UpdateView;
begin
  ShowMeasured;
end;

procedure TFrm3120.TableModeSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  sg:tstringgrid;
  mname:string;
  col, row:integer;
  pPnt:tpoint;
  r:trect;
  p:cProgramObj;
  m, newm:cModeObj;
begin
  p := g_conmng.getprogram(0);
  if (key=VK_UP) or (key=VK_Down) then
  begin

  end;
  if key=VK_RETURN then
  begin
    // ������� ������
    if m_insert>-1 then
    begin
      if m_insert=1 then
        inc(m_insert);
      m:=p.getMode(m_insert-2);
      if m<>nil then
      begin
        if m_insert=(m.modeIndex+1) then
        begin
          newm:=m.copyMode(true);
        end
        else
        begin
          newm:=m.copyMode(false);
        end;
        newm.name:=TStringGrid(Sender).Cells[m_insert, 0];
        m_insert:=-1;
        //ShowControlPropsModes;
        UpdateControlsPropSG;
      end;
    end
    else
    begin
      ModeTabSGEditCell(m_row, m_col, m_val);
      // ���� ������������� ��� ������
      if m_row=0 then
      begin
        //ShowControlPropsModes;
        UpdateControlsPropSG;
      end;
    end;
  end;
  // �������� �������
  if key=VK_DELETE then
  begin
    if m_insert>-1 then
    begin
      GridRemoveColumn(TStringGrid(Sender), m_insert);
      m_insert:=-1;
    end
    else
    begin
      if g_conmng.State = c_stop then
      begin
        m:=getTableModeSGByCol(m_curCol);
        if m<>nil then
        begin
          m_CurMode:=nil;
          m.destroy;
          //ShowModeTable;
        end;
      end;
    end;
  end;
  // ������� ������
  if key=VK_INSERT then
  begin
    if m_insert>-1 then exit;
    GetCursorPos(pPnt);
    pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
    // ������� ������� ����� ������
    TStringGrid(Sender).MouseToCell(pPnt.X, pPnt.Y, col, row);
    if col=-1 then exit;
    if col>p.ModeCount then
      col:=p.ModeCount;
    // ���������� ������ ����������� ����� (������� �� esc. ����. �� enter)
    m_insert:=col+1;
    if col>-1 then
    begin
      sg:=TStringGrid(sender);
      mname:=sg.Cells[col, 0];
      if col>0 then
        GridAddColumn(sg, m_insert, sg.Colwidths[col])
      else
        GridAddColumn(sg, m_insert, sg.Colwidths[col+1]);
      sg.Cells[m_insert, 0]:=mname+'_';
    end;
  end;
end;

function TFrm3120.toSec(t: double): double;
begin
  result := uCommonMath.tosec(t, TimeUnitsCB.ItemIndex)
end;

procedure TFrm3120.ModeTabSGEditCell(r, c: integer; val: string);
var
  p: cProgramObj;
  m: cModeObj;
  t: ctask;
  con: ccontrolobj;
  str: string;
begin
  if r<>0 then
  begin
    if not isvalue(val) then
      exit;
  end;
  p := g_conmng.getprogram(0);
  if p = nil then
    exit;
  if c > 0 then
  begin
    m := p.getmode(c - 1);
    // ����������� ������������
    if r = 1 then
    begin
      m.ModeLength := toSec(strtofloatext(val));
    end;
    // � ������ ���� �������� ��� ������
    if r=0 then
    begin
      if m <> nil then
      begin
        // �������������� ������
        if m.name<>TableModeSg.Cells[c, 0] then
        begin
          m.name:=TableModeSg.Cells[c, 0];
        end;
      end;
    end;
    // � ������ ���� �������� �������� �������
    if r > 1 then
    begin
      str := TableModeSG.Cells[0, r];
      con := p.getOwnControl(str);
      if con <> nil then
      begin
        if m <> nil then
        begin
          if r>1 then
          begin
            t := m.gettask(con.name);
            if t <> nil then
            begin
              case t.m_data.ModeType of
                mtN: TableModeSG.Cells[c, r]:=TableModeSG.Cells[c, r]+', ��.';
                mtM: TableModeSG.Cells[c, r]:=TableModeSG.Cells[c, r]+', �';
                //mtN: TableModeSG.Cells[0, r];
              end;
              t.entercs;
              t.task := strtofloatext(val);
              t.applyed := false;
              t.exitcs;
            end;
          end;
        end;
      end;
    end;
  end;
end;

end.
