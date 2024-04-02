unit uMainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, SyncObjs, recorder, uRecBasicFactory, tags,
  ComCtrls, IniFiles, uRecorderEvents, PluginClass, uMyRecorderUtils, Buttons, uPidReg,
  PerformanceTime, ulogfile, ActiveX, CFREG;

type TTermoDetectorsType = record
  Name : String;
  Tag : ITag;
  Value : Double;
end;
  TermoDetectors_type_array = array of TTermoDetectorsType;

type TGORNRecord = record
  Name : String;                         // �������� ������� �����
  NameText : String;                     // ��������� �������� ������� �����
  I_Tag, U_Tag, P_Tag : ITag;            // ��� �������� ������ � ����
  I_Max, U_Max, P_max : Double;          // ������������ �������� ������� ����������
  Iizm_Tag, Uizm_Tag, Pizm_Tag : ITag;   // ������ ������ �� �����
  Iizm_Val, Uizm_Val, Pizm_Val : Double; // ������ �� �����

  P_272_Tag, P_273_Tag, P_275_Tag : ITag;// ���� �����

  // ���-���������
  PID_IniFile : String;     // ���� guis � �����������
  //PID_ShowConfig : boolean; // ���������� ������ �������� ���-����������
  PID_Use : boolean;        // ������������ ���-���������
  PID_Global : ITag;        // ���-������������� ����������
  PID_Local : ITag;         // ���-������������� ���������
  PID_P: double;            // ���������������� ����������� (����������� �������� (%/<������� ���. ��������>)
  PID_I: double;            // ������������ ����������� (1/���������������, �����������)
  PID_D: double;            // ���������������� ����������� (������������������, �����������)
  PID_Min: double;          // ����������� �������� ������������ �����������
  PID_Treg: integer;        // ������ �������������, �����������

  Auto_Ustavka_ITag : ITag; // ������� ����� ������� ������� ��� ����������
  Auto_Mode_ITag : ITag;    // ��� �������� ����������
  Auto_Count : Integer;     // ������� ������ �������� (0-�������,���������; 1-��������; 2-����������,old)
  Auto_Ustavka : Double;    // �������� �������
  Auto_Mode : Integer;      // �������� ������
  Auto_Reset_PID : Boolean; // ����� ������ ���

  shum_enable : Boolean;
  shum_pass_count : Integer;

  // ������ �� ����������� ��������� �����
  Manual : Integer; // ����. / ���.
  Apply  : Boolean; // ���������
  Mode : Integer;   // ����� ������ �����
  Ustavka : Double; // �������

  TermoTags : TermoDetectors_type_array; // ������ �������������
  Power_Tag : ITag;                      // ���������� ��������
  Ventilator_Tag : ITag;                 // ���������� ������������
  TermoMidle_Tag : ITag;                 // ����� ��������� ������� �����������
  TermoON, TermoOFF, TermoSave : Double; // ���/���� �������
  TermoUp : Boolean;                     // ������ ���� ������ �� ����������� ����������
end;

type
  TMainFrm = class(TRecFrm)
    GroupBox_Main: TGroupBox;
    Button_Config: TButton;
    LabeledEdit_Ustavka: TLabeledEdit;
    CheckBoxON: TCheckBox;
    ComboBoxMode: TComboBox;
    ComboBoxManual: TComboBox;
    LabelMeasure: TLabel;
    LabelEditText: TLabel;
    PanelGORNPower: TPanel;
    procedure Button_ConfigClick(Sender: TObject);
    procedure ComboBoxModeChange(Sender: TObject);
    procedure ComboBoxManualChange(Sender: TObject);
    procedure LabeledEdit_UstavkaKeyPress(Sender: TObject; var Key: Char);
    procedure CheckBoxONClick(Sender: TObject);
    procedure LabeledEdit_UstavkaChange(Sender: TObject);
    procedure PanelGORNPowerClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  public
    m_drawCount:integer;
    m_redraw    : boolean;
    m_ThID : cardinal;
    m_MainThread : cardinal;

    m_itimer : Int64;
    m_timer : Double;
    i_random, i_pass_count : Integer;

    GORN : TGORNRecord;

    Reg: TPIDreg;

  private
    procedure onRegCycle(Sender: TObject);
    { Private declarations }
  protected
  public
    constructor Create(Aowner: tcomponent); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    destructor destroy; override;

    function Get_U_From_P(P : Double) : Double;
    function Get_U_From_I(I : Double) : Double;
    procedure SetGORNValueByMode(dValue : Double);
    function Get_PID_Max : Double;
    procedure GetGraphValue;

    procedure ApplySettings;
    procedure SetEditColor;
    procedure SetPowerPanel(power : Integer);
    procedure SetPowerPanelColor;

    procedure SetControlMngProp(s : String{lpcstr}); // ��� ��������� �����������
    procedure SetControlMngPropSend;       // ��� ��������� �����������
  end;

type
  cGORNFactory = class(cRecBasicFactory)
  public
  protected
    procedure AddEvents;
    procedure doDestroyForms; override;
    procedure doUpdateTags(Sender: TObject);
    procedure doStatusNONE(Sender: TObject);
    procedure doRedraw(Sender: TObject);
  public
    constructor Create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

  cGORNFrm = class(cRecBasicIFrm)
  public
  public
    function doRepaint: boolean; override;
    procedure UpdateStateByTag;
    procedure UpdateStatusByRC;
    function doCreateFrm: TRecFrm; override;
  end;

var
  MainFrm: TmainFrm;
  m_timerTreshold : double;

const
  // ctrl+shift+G
  IID_MainFrm: TGuid = (D1: $E6E289F7; D2: $EC9D; D3: $48A5;
    D4: ($93, $FC, $B4, $4C, $BA, $DC, $7D, $35));

  str_PID_ini = 'Plagin_GORN_PID_CONFIGURATION';
  c_Manual = 0; // ������ �����
  c_Auto   = 1; // �������������� �����
  //c_minValue = 0.01; // ����������� �������� ������ ����

  MsTime : TDateTime = 1 / (24 * 60 * 60 * 1000); //�������� 1 ������������ � ������� TDateTime

implementation


uses uSettingsFrm, uCreateNotifyProcess;

{$R *.dfm}

// -------------------------------------------------------------------------

procedure cGORNFactory.AddEvents;
begin
  TExtRecorderPack(GPluginInstance).EList.AddEvent('DataUpdate_GORNFactory', c_RUpdateData, doUpdateTags);
  TExtRecorderPack(GPluginInstance).EList.AddEvent('StatusToNONE_GORNFactory', c_RC_DoChangeRCState, doStatusNONE);
  TExtRecorderPack(GPluginInstance).EList.AddEvent('RecorderRedraw_GORNFactory', c_RC_Redraw, doRedraw);
end;

procedure cGORNFactory.doUpdateTags(Sender: TObject);
var
  i: integer;
  c: cGORNFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    c := cGORNFrm(m_CompList.Items[i]);
    c.UpdateStateByTag;
  end;
end;

procedure cGORNFactory.doStatusNONE(Sender: TObject);
var
  i: integer;
  c: cGORNFrm;
  v : OleVariant;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    c := cGORNFrm(m_CompList.Items[i]);
    c.UpdateStatusByRC;
  end;
  TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_TIMERTICPERIOD, v);
  m_timerTreshold := v;
end;

procedure cGORNFactory.doRedraw(Sender: TObject);
var
  i: integer;
  c: cGORNFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    c := cGORNFrm(m_CompList.Items[i]);
    c.doRepaint;
  end;
end;

// -------------------------------------------------------------------------
constructor cGORNFactory.Create;
begin
  m_lRefCount := 1;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_MainFrm;

  AddEvents;
  //g_Timer:=TPerformanceTime.Create;

  //g_logFile:=cLogFile.create( 'c:\Mera Files\Recorder\cfg2\GORNLog.log' , ';');
end;

destructor cGORNFactory.destroy;
begin
  inherited;
  {g_Timer.Destroy;
  if g_logFile<>nil then
  begin
    g_logFile.destroy;
    g_logFile:=nil;
  end;}
end;

procedure cGORNFactory.doDestroyForms;
begin
end;

function cGORNFactory.doCreateForm: cRecBasicIFrm;
begin
  result := cGORNFrm.Create;
end;

procedure cGORNFactory.doSetDefSize(var pSize: SIZE);
begin
  pSize.cx := c_plugin_defXSize;
  pSize.cy := c_plugin_defYSize;
end;

function cGORNFrm.doCreateFrm: TRecFrm;
begin
  result := TMainFrm.Create(nil);
end;

// ���������� ������ ������
function cGORNFrm.doRepaint: boolean;
var
  str : String;
  i : integer;
  it, fr:int64;
  l_redraw:boolean;
begin
  inherited;
  l_redraw:=false;
  QueryPerformanceCounter(it);
  QueryPerformanceFrequency(fr);
  TmainFrm(m_pMasterWnd).m_timer:=(it-TmainFrm(m_pMasterWnd).m_itimer)/fr;
  if TmainFrm(m_pMasterWnd).m_timer>m_timerTreshold then
  begin
    TmainFrm(m_pMasterWnd).m_iTimer:=it;
    l_redraw:=true;
  end;
  if Not l_redraw  then
    exit;
  with TmainFrm(m_pMasterWnd) do
  begin
    //m_drawCount := m_drawCount + 1;
    str := '';//IntToStr(TmainFrm(m_pMasterWnd).m_drawCount);

    {if GORN.Iizm_Tag <> nil then
      str := 'I��� = ' + FloatToStrF(GORN.Iizm_Val, ffFixed, 10, 2) + ' �'#13#10
    else
      str := 'I��� = ---'#13#10;

    if GORN.Uizm_Tag <> nil then
      str := str + 'U��� = ' + FloatToStrF(GORN.Uizm_Val, ffFixed, 10, 2) + ' �'#13#10
    else
      str := str + 'U��� = ---'#13#10;

    if GORN.Pizm_Tag <> nil then
      str := str + 'P��� = ' + FloatToStrF(GORN.Pizm_Val, ffFixed, 10, 2) + ' ��'
    else
      str := str + 'P��� = ---';}

    if GORN.Iizm_Tag <> nil then
      str := str + Format('I��� = %.2f �'#13#10, [GORN.Iizm_Val])
    else
      str := str + 'I��� = ---'#13#10;

    if GORN.Uizm_Tag <> nil then
      str := str + Format('U��� = %.2f �'#13#10, [GORN.Uizm_Val])
    else
      str := str + 'U��� = ---'#13#10;

    if GORN.Pizm_Tag <> nil then
      str := str + Format('P��� = %.2f ��', [GORN.Pizm_Val])
    else
      str := str + 'P��� = ---';

    LabelMeasure.Caption := str;

    SetPowerPanelColor;

    //MainFrm.Repaint;

    //TmainFrm(m_pMasterWnd).

    GroupBox_Main.Invalidate;

    for i := 0 to GroupBox_Main.ControlCount - 1 do
      GroupBox_Main.Controls[i].Invalidate;

    //GroupBox_Main.Repaint;

    {    Button_Config: TButton;
    LabeledEdit: TLabeledEdit;
    CheckBoxON: TCheckBox;
    ComboBoxMode: TComboBox;
    ComboBoxManual: TComboBox;
    LabelMeasure: TLabel;
    LabelEditText: TLabel;
    PanelGORNPower: TPanel;}

    {m_pMasterWnd.Repaint;

    TmainFrm(m_pMasterWnd).Paint;

    TmainFrm(m_pMasterWnd).Repaint;
    TmainFrm(m_pMasterWnd).Refresh;}
  end;

  Result := true;
end;

function TmainFrm.Get_U_From_P(P : Double) : Double;
var R : Double;
begin // ������� ���������� ��� ��������� �� ������� ��������
    if GORN.Iizm_Val = 0 then GORN.Iizm_Val := GORN.PID_Min;

    R := Abs(GORN.Uizm_Val / GORN.Iizm_Val);
    Get_U_From_P := Sqrt(R * P);
end;

function TmainFrm.Get_U_From_I(I : Double) : Double;
var R : Double;
begin // ������� ���������� ��� ���������� ����
    if GORN.Iizm_Val = 0 then GORN.Iizm_Val := GORN.PID_Min;

    R := Abs(GORN.Uizm_Val / GORN.Iizm_Val);
    Get_U_From_I := I * R;
end;

function TmainFrm.Get_PID_Max : Double;
begin
  {if GORN.Manual = c_Manual then // ������
    begin
      case GORN.Mode of
        0 : Get_PID_Max := GORN.I_Max; // ���
        1 : Get_PID_Max := GORN.U_Max; // ����������
        2 : Get_PID_Max := GORN.P_max; // ��������
        else Get_PID_Max := 0;
      end;
    end
  else
    begin
      case GORN.Auto_Mode of
        0 : Get_PID_Max := GORN.I_Max; // ���
        1 : Get_PID_Max := GORN.U_Max; // ����������
        2 : Get_PID_Max := GORN.P_max; // ��������
        else Get_PID_Max := 0;
      end;
    end;}
  Get_PID_Max := GORN.U_Max; // ����������
end;

procedure TmainFrm.SetGORNValueByMode(dValue : Double);
var
  shum, U_out, temp_Value, Ustavka : Double;
  Mode : Integer;
begin
  // ������ ����� + �� ���������
  if (GORN.Manual = c_Manual) and (Not GORN.Apply) then Exit;

  if dValue < GORN.PID_Min then dValue := GORN.PID_Min;

  if GORN.shum_enable then
    begin
      if i_pass_count >= GORN.shum_pass_count then // ������� ������ ���������
        begin
          i_random := i_random + 1;
          if i_random > 10 then i_random := 0;
          shum := i_random*GORN.PID_Min/10;

          i_pass_count := -1;
        end;

      i_pass_count := i_pass_count + 1;
    end
  else
    begin
      shum := 0;
    end;

  //shum := 0;
  //dValue := dValue + shum;

  GetTagValueWithCheck(GORN.Power_Tag, temp_Value);
  if temp_Value = 2 then
    begin
      //Reg.Active := false;
      Reg.Setting  := 0;
      Reg.Response := 0;
      dValue := 0;
      GORN.Ustavka := 0;
    end;

  GetTagValueWithCheck(GORN.Iizm_Tag, GORN.Iizm_Val);
  GetTagValueWithCheck(GORN.Uizm_Tag, GORN.Uizm_Val);

  if GORN.Manual = c_Manual then // ������ �����
    Mode := GORN.Mode
  else
    begin
      GetTagValueWithCheck(GORN.Auto_Mode_ITag, temp_Value);
      Mode := Round(temp_Value) - 1;
      if (Mode < 0) or (Mode > 2) then Exit; // �������� ������� ������
    end;

  {case Mode of
    0 : begin // ���
          //SetTagValueWithCheck(GORN.U_Tag, (Get_U_From_I(dValue) - shum)*100);
          U_out := Get_U_From_I(dValue);
        end;
    1 : begin // ����������
          //SetTagValueWithCheck(GORN.U_Tag, (dValue - shum) * 100);
          U_out := dValue;
        end;
    2 : begin // ��������
          //SetTagValueWithCheck(GORN.U_Tag, (Get_U_From_P(dValue) - shum)*100);
          U_out := Get_U_From_P(dValue);
        end;
  end;}

  U_out := dValue;

  if U_out > GORN.U_Max then U_out := GORN.U_Max;
  SetTagValueWithCheck(GORN.U_Tag, (U_out - shum)*100);

  SetTagValueWithCheck(GORN.I_Tag, (GORN.I_Max - shum/10)*100);
  SetTagValueWithCheck(GORN.P_Tag, (GORN.P_Max - shum)*10);

  if (Mode = c_Manual) then Exit; // ������ �����
  // �������� ��� �������� ������� � ������ �� �����������
  GetTagValueWithCheck(GORN.Auto_Ustavka_ITag, Ustavka);

  if GORN.Auto_Count = 0 then // ����������
    begin
      if (Mode <> GORN.Auto_Mode) or
         (Ustavka <> GORN.Auto_Ustavka) then
          GORN.Auto_Count := 1; // ������ ����� ��������

      Exit;
    end;

  if GORN.Auto_Count = 1 then // ����������
    begin
      GORN.Auto_Count := 2;
      Exit;
    end;

  if GORN.Auto_Count = 2 then // ����� ����� ��������
    begin
      GORN.Auto_Mode    := Mode;
      GORN.Auto_Ustavka := Ustavka;
      GORN.Auto_Count   := 0; // ���������� �������
      Reg.ResetE;
      GORN.Auto_Reset_PID := true;
      Exit;
    end;
end;

procedure TmainFrm.GetGraphValue;
var
  Val_Out : Double;
begin
  GORN.Manual := ComboBoxManual.ItemIndex;
  GORN.Apply  := CheckBoxON.Checked;
  GORN.Mode   := ComboBoxMode.ItemIndex;
  if TryStrToFloat(LabeledEdit_Ustavka.Text, Val_Out) then  // �������� �� �����
    GORN.Ustavka := Val_Out
  else
    GORN.Ustavka := 0;
end;

procedure TmainFrm.onRegCycle(Sender: TObject);
begin
  SetGORNValueByMode(Reg.OutputFIZ);
end;

procedure cGORNFrm.UpdateStateByTag;
var
  Val_In, Val_Out, d_temp, d_local : Double;
  i, num : Integer;
  bpower : Boolean;
begin
  with TmainFrm(m_pMasterWnd) do
  begin
  // ���������� �������� ����� (1 - ��������, 2 - ���������)
  GetTagValueWithCheck(GORN.Power_Tag, d_temp);
  num := Round(d_temp);
  if num = 1 then SetPowerPanel(1);
  if num = 2 then SetPowerPanel(0);

  // ������ ������
  GetTagValueWithCheck(GORN.Iizm_Tag, GORN.Iizm_Val);
  GetTagValueWithCheck(GORN.Uizm_Tag, GORN.Uizm_Val);
  GORN.Pizm_Val := GORN.Iizm_Val * GORN.Uizm_Val;
  SetTagValueWithCheck(GORN.Pizm_Tag, GORN.Pizm_Val);

  // ���-������������� (1 - ���-�������������, 2 - ��� �������������)
  GetTagValueWithCheck(TmainFrm(m_pMasterWnd).GORN.PID_Global, d_temp);
  GetTagValueWithCheck(TmainFrm(m_pMasterWnd).GORN.PID_Local,  d_local);
  if (d_temp = 1) or (d_temp = 2) then // �������� �� ����������� ����, �������������
    begin
      if d_temp = 1 then TmainFrm(m_pMasterWnd).GORN.PID_Use := true;
      if d_temp = 2 then TmainFrm(m_pMasterWnd).GORN.PID_Use := false;
    end
  else
    begin
      if (d_local = 1) or (d_local = 2) then // �������� �� ���������� ����
        begin
          if d_local = 1 then TmainFrm(m_pMasterWnd).GORN.PID_Use := true;
          if d_local = 2 then TmainFrm(m_pMasterWnd).GORN.PID_Use := false;
        end;
    end;

  //-------------------------------------
  // ������������
  bpower := true;
  Val_In := 0;

  GORN.TermoSave := Get_PID_Max;
  if Length(GORN.TermoTags) <> 0 then
    begin
      // ������� �����
      num := 0;
      for i := 0 to Length(GORN.TermoTags) - 1 do
        begin
          if GORN.TermoTags[i].Tag <> nil then
            begin
              num := num + 1;
              Val_In := Val_In + GORN.TermoTags[i].Tag.GetEstimate(ESTIMATOR_MEAN);
            end;
        end;

      if num <> 0 then
        begin
          Val_In := Val_In / num;

          if GORN.Manual = c_Manual then // ������
            begin
              GORN.Auto_Reset_PID := true;

              if Val_In >= GORN.TermoOFF then // ���������� �����������, ��������� (1 - ��������, 2 - ���������)
                begin
                  GORN.TermoSave := 0;
                  bpower := false;
                  GORN.TermoUp := false;
                end;

              if (Val_In < GORN.TermoOFF) and
                 (Val_In > GORN.TermoON) then
                begin // ���� ���������� �� ������� ������� - ���������
                  if not GORN.TermoUp then
                    begin
                      GORN.TermoSave := 0;
                      bpower := false;
                    end;
                end;

              if Val_In <= GORN.TermoON then // ������ �����������, ��������
              //if GORN.TermoSave < Get_PID_Max then
                begin
                  //Reg.Output := 0;
                  GORN.TermoSave := Get_PID_Max;
                  bpower := true;
                  GORN.TermoUp := true;
                end;
            end;
        end;
    end;
  SetTagValueWithCheck(GORN.TermoMidle_Tag, Val_In);

  //-------------------------------------
  // ��������� �������� I, U, P
  // ������
  if GORN.Manual = c_Manual then
    begin
      if GORN.Apply then // ���������
        begin
          Val_Out := GORN.Ustavka;

          if GORN.PID_Use then // ������������ ���-���������
            begin
              Reg.Active := true;
              if GORN.Auto_Reset_PID then
                begin
                  Reg.ResetE;
                  GORN.Auto_Reset_PID:= false;
                end;

              Reg.P := GORN.PID_P;
              Reg.I := GORN.PID_I;
              Reg.D := GORN.PID_D;

              Reg.Max  := GORN.TermoSave; //GORN.PID_Max; Get_PID_Max
              Reg.Min  := GORN.PID_Min;
              Reg.Treg := GORN.PID_Treg;
              //Reg.Setting := Val_Out;
              Reg.Response := GORN.Uizm_Val;

              case GORN.Mode of
                0 : begin // ���
                      Reg.Setting := Get_U_From_I(Val_Out);
                      //Reg.Response := GORN.Iizm_Val;
                    end;
                1 : begin // ����������
                      Reg.Setting := Val_Out;
                      //Reg.Response := GORN.Uizm_Val;
                    end;
                2 : begin // ��������
                      Reg.Setting := Get_U_From_P(Val_Out);
                      //Reg.Response := GORN.Pizm_Val;
                    end;
              end;
            end
          else // �� ������������ ���-���������
            begin
              Reg.Active := false;

              case GORN.Mode of
                0 : begin // ���
                      Val_Out := Get_U_From_I(Val_Out);
                    end;
                1 : begin // ����������
                      //Val_Out := Val_Out;
                    end;
                2 : begin // ��������
                      Val_Out := Get_U_From_P(Val_Out);
                    end;
              end;

              if not bpower then Val_Out := 0;
              d_temp := Get_PID_Max;
              if Val_Out > d_temp then
                SetGORNValueByMode(d_temp)
              else
                SetGORNValueByMode(Val_Out);
            end;
        end;
      Exit; // ���� ������ - �������
    end;

  // ��������������
  if GORN.Manual = c_Auto then
    begin
      Val_Out := GORN.Auto_Ustavka;

      if GORN.PID_Use then // ������������ ���-���������
        begin
          Reg.Active := true;
          if GORN.Auto_Reset_PID then
            begin
              Reg.ResetE;
              GORN.Auto_Reset_PID:= false;
            end;

          Reg.P := GORN.PID_P;
          Reg.I := GORN.PID_I;
          Reg.D := GORN.PID_D;

          Reg.Max  := GORN.TermoSave; //GORN.PID_Max; Get_PID_Max
          Reg.Min  := GORN.PID_Min;
          Reg.Treg := GORN.PID_Treg;
          //Reg.Setting := Val_Out;
          Reg.Response := GORN.Uizm_Val;

          case GORN.Auto_Mode of
            0 : begin // ���
                  Reg.Setting := Get_U_From_I(Val_Out);
                  //Reg.Response := GORN.Iizm_Val;
                end;
            1 : begin // ����������
                  Reg.Setting := Val_Out;
                  //Reg.Response := GORN.Uizm_Val;
                end;
            2 : begin // ��������
                  Reg.Setting := Get_U_From_P(Val_Out);
                  //Reg.Response := GORN.Pizm_Val;
                end;
          end;
        end
      else // �� ������������ ���-���������
        begin
          Reg.Active := false;

          case GORN.Auto_Mode of
            0 : begin // ���
                  Val_Out := Get_U_From_I(Val_Out);
                end;
            1 : begin // ����������
                  //Val_Out := Val_Out;
                end;
            2 : begin // ��������
                  Val_Out := Get_U_From_P(Val_Out);
                end;
          end;

          //if not bpower then Val_Out := 0;
          d_temp := Get_PID_Max;
          if Val_Out > d_temp then
            SetGORNValueByMode(d_temp)
          else
            SetGORNValueByMode(Val_Out);
        end;
    end;
  end; // with TmainFrm(m_pMasterWnd) do
end;

// ��� ��������� �����������
procedure TMainFrm.SetControlMngProp(s : String{lpcstr});
var
  rep: hresult;
  val: OleVariant;
  UISrv: tagVARIANT;
  FormRegistrator: ICustomFormsRegistrator;
  f: ICustomFormFactory;
  cf: ICustomFactInterface;

  CFrm: IVForm;

  count: cardinal;
  i: ULONG;
  int: integer;
  ws: widestring;
  g: TGUID;
  s2:LPCSTR;
begin
  rep := TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_UISERVERLINK, val);
  UISrv := tagVARIANT(val);
  if (FAILED(rep) or (UISrv.VT <> VT_UNKNOWN)) then
  begin
  end;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator,
    FormRegistrator);
  if FAILED(rep) or (FormRegistrator = niL) then
  begin
  end;
  FormRegistrator.GetFactoriesCount(@count);
  for i := 0 to count - 1 do
  begin
    FormRegistrator.GetFactoryByIndex(f, i);
    f.GetFormTypeName(ws);
    // f._Release;
    // '����� ����������'
    if ws = '����� ����������' then
    begin
      cf := f as ICustomFactInterface;
      int := 0;
      if (cf as ICustomFactInterface).getChild(int, CFrm) <> S_OK then Exit;
      // (cf as ICustomFactInterface).getChild(int, mdb);
      // ������� ������������ �������� tag - id ���� ��� ����� ��������
      // 0: ���� � ��������� 1: ���� � �����������
      s2:= lpcstr(StrToAnsi(s));
      (CFrm as ICustomVFormInterface).SetCustomProperty(0, s2);
    end;
  end;
end;

// ��� ��������� �����������
procedure TMainFrm.SetControlMngPropSend;
var s, tname : String;
begin
  // ��� ��������� �����������
  // SetControlMngProp('C_1=Ctrl_001;FB_1=Ctrl_001;T_1=Ctrl_001_State;T_2=Ctrl_002_State');
  s := 'C_1=' + GORN.NameText + ';';
  s := s + 'FB_1=;';

  tname := '';
  if GORN.Auto_Ustavka_ITag <> nil then tname := GORN.Auto_Ustavka_ITag.GetName;
  s := s + 'T_1=' + tname + ';';

  tname := '';
  if GORN.Auto_Mode_ITag <> nil then tname := GORN.Auto_Mode_ITag.GetName;
  s := s + 'T_2=' + tname;

  SetControlMngProp(s); // ��������� ��������� �����������
end;

// ���������� �������� ������ ��� ������/����� ���������
procedure cGORNFrm.UpdateStatusByRC;
begin
  with TmainFrm(m_pMasterWnd) do
  begin
  if RcCheckState(RS_VIEW) or RcCheckState(RS_REC) then
    begin
      //SetTagValueWithCheck(GORN.I_Tag, c_minValue);
      //SetTagValueWithCheck(GORN.U_Tag, c_minValue);
      //SetTagValueWithCheck(GORN.P_Tag, c_minValue);

      GORN.TermoSave := Get_PID_Max;

      GORN.Auto_Count := 2;
      GORN.Auto_Reset_PID := true;

      SetControlMngPropSend; // ��������� ��������� �����������
    end;

  if RcCheckState(RS_STOP) then
    begin
      Reg.Active := false;
    end;

  GetGraphValue;

  ApplySettings;
  SetEditColor;
  PanelGORNPower.Color := clBtnFace;
  end;
end;

// -------------------------------------------------------------------------
procedure TMainFrm.PanelGORNPowerClick(Sender: TObject);
begin
  {case PanelGORNPower.Color of
    clBtnFace : SetPowerPanel(1);
    clRed     : SetPowerPanel(1);
    clGreen   : SetPowerPanel(0);
    clYellow  : SetPowerPanel(1);
  end;}

  {if PanelGORNPower.Color = clGreen then
    SetPowerPanel(0)
  else
    SetPowerPanel(1); }

  if PanelGORNPower.Color = clGreen then
    SetTagValueWithCheck(GORN.Power_Tag, 2)
  else
    SetTagValueWithCheck(GORN.Power_Tag, 1);
end;

procedure TMainFrm.SetPowerPanel(power : Integer);
var
  dValue : Double;
  old : Boolean;
begin
  if RcCheckState(RS_VIEW) or RcCheckState(RS_REC) then // �� �����
    begin
      old := false;
      GetTagValueWithCheck(GORN.P_272_Tag, dValue);
      if dValue = power then old := true;

      if old then Exit;

      if power = 1 then // ���
        begin
          SetTagValueWithCheck(GORN.P_275_Tag, power);
          SetTagValueWithCheck(GORN.P_272_Tag, power);
          Sleep(50);
          SetTagValueWithCheck(GORN.P_273_Tag, power);

          SetTagValueWithCheck(GORN.Ventilator_Tag, power);
        end;

      if power = 0 then // ����
        begin
          SetTagValueWithCheck(GORN.Ventilator_Tag, power);

          // ������������� ����� � ����
          CheckBoxON.Checked := false;
          GORN.Apply := false;
          GORN.Auto_Ustavka := 0;
          SetTagValueWithCheck(GORN.Auto_Ustavka_ITag, GORN.Auto_Ustavka);
          SetTagValueWithCheck(GORN.U_Tag, GORN.PID_Min*100);
          SetTagValueWithCheck(GORN.I_Tag, GORN.I_Max*100);
          SetTagValueWithCheck(GORN.P_Tag, GORN.P_Max*10);

          SetTagValueWithCheck(GORN.P_275_Tag, power);
          SetTagValueWithCheck(GORN.P_273_Tag, power);
          Sleep(50);
          SetTagValueWithCheck(GORN.P_272_Tag, power);
        end;
    end;
end;

procedure TMainFrm.SetPowerPanelColor;
var
  p : Integer;
begin
  if RcCheckState(RS_STOP) then // �����
    begin
      PanelGORNPower.Color := clBtnFace;
    end
  else
    begin
      p := 0;

      if (GORN.P_272_Tag = nil) and (GORN.P_273_Tag = nil) and (GORN.P_275_Tag = nil) then
        begin
          p := -1;
        end
      else
        begin
          if GORN.P_272_Tag <> nil then
            if GORN.P_272_Tag.GetEstimate(ESTIMATOR_MEAN) >= 1 then
              p := p + 1;

          if GORN.P_273_Tag <> nil then
            if GORN.P_273_Tag.GetEstimate(ESTIMATOR_MEAN) >= 1 then
              p := p + 1;

          if GORN.P_275_Tag <> nil then
            if GORN.P_275_Tag.GetEstimate(ESTIMATOR_MEAN) >= 1 then
              p := p + 1;
        end;

      case p of
        -1   : PanelGORNPower.Color := clBtnFace;
        0    : PanelGORNPower.Color := clRed;
        1..2 : PanelGORNPower.Color := clYellow;
        3    : PanelGORNPower.Color := clGreen;
        else PanelGORNPower.Color := clBtnFace;
      end;
    end;
end;

procedure TMainFrm.Button_ConfigClick(Sender: TObject);
begin
  SettingsFrm.ShowModal(self); // ��������� ����� �������� � �������� ��
end;

procedure TMainFrm.CheckBoxONClick(Sender: TObject);
var
  d_Set : double;
begin
  ComboBoxMode.Enabled := not CheckBoxON.Checked;
  if ComboBoxManual.ItemIndex = c_Auto then ComboBoxMode.Enabled := false;

  if CheckBoxON.Checked then
  if ComboBoxManual.ItemIndex = c_Manual then // ������
    begin
      if TryStrToFloat(LabeledEdit_Ustavka.Text, d_Set) then  // �������� �� �����
        begin
          //Reg.Setting := d_Set;

          GORN.Mode := ComboBoxMode.ItemIndex;

          d_Set := 0;
          case GORN.Mode of
            0 : begin // ���
                  GetTagValueWithCheck(GORN.Iizm_Tag, d_Set);
                end;
            1 : begin // ����������
                  GetTagValueWithCheck(GORN.Uizm_Tag, d_Set);
                end;
            2 : begin // ��������
                  GetTagValueWithCheck(GORN.Pizm_Tag, d_Set);
                end;
          end;
          //Reg.Response := d_Set;
        end;
    end;

  //Reg.Active := CheckBoxON.Checked;
  GORN.Auto_Reset_PID := true;
  //Reg.Output := Reg.Response * 100 / (Get_PID_Max - GORN.PID_Min) - GORN.PID_Min;

  SetEditColor;
  GetGraphValue;
end;

procedure TMainFrm.ComboBoxManualChange(Sender: TObject);
begin
  LabelEditText.Enabled       := ComboBoxManual.ItemIndex = c_Manual;
  LabeledEdit_Ustavka.Enabled := ComboBoxManual.ItemIndex = c_Manual;
  CheckBoxON.Enabled          := ComboBoxManual.ItemIndex = c_Manual;
  ComboBoxMode.Enabled        := ComboBoxManual.ItemIndex = c_Manual;

  if not CheckBoxON.Enabled then
    begin
      CheckBoxON.Checked := false;
      //Reg.Active := false;
    end
  else
    Reg.ResetE;

  SetEditColor;
  GetGraphValue;
end;

procedure TMainFrm.ComboBoxModeChange(Sender: TObject);
begin
  GORN.Mode := ComboBoxMode.ItemIndex;

  case GORN.Mode of
    0 : begin // ���
          LabeledEdit_Ustavka.EditLabel.Caption := '�';
          if GORN.I_Tag <> nil then
            LabeledEdit_Ustavka.Text := FloatToStr(GORN.I_Tag.GetEstimate(ESTIMATOR_MEAN) / 100)
          else
            LabeledEdit_Ustavka.Text := '';
        end;
    1 : begin // ����������
          LabeledEdit_Ustavka.EditLabel.Caption := '�';
          if GORN.U_Tag <> nil then
            LabeledEdit_Ustavka.Text := FloatToStr(GORN.U_Tag.GetEstimate(ESTIMATOR_MEAN) / 100)
          else
            LabeledEdit_Ustavka.Text := ''
        end;
    2 : begin // ��������
          LabeledEdit_Ustavka.EditLabel.Caption := '��';
          if GORN.P_Tag <> nil then
            LabeledEdit_Ustavka.Text := FloatToStr(GORN.P_Tag.GetEstimate(ESTIMATOR_MEAN) / 10)
          else
            LabeledEdit_Ustavka.Text := ''
        end;
  end;

  SetEditColor;
  GetGraphValue;
end;

constructor TMainFrm.Create(Aowner: tcomponent);
begin
  inherited;
  if not Assigned(Reg) then
  begin
  Reg := TPIDreg.Create;
  Reg.OnCycleEvent := onRegCycle;
  end;
  m_timer := 0;
  m_drawCount:=0;
end;

destructor TMainFrm.destroy;
begin
  SetLength(fTags, 0);
  FreeAndNil(Reg);
  inherited;
end;

procedure TMainFrm.FormPaint(Sender: TObject);
begin
  m_drawCount:=m_drawCount+1;
end;

procedure TMainFrm.LabeledEdit_UstavkaChange(Sender: TObject);
begin
  SetEditColor;
  GetGraphValue;
end;

procedure TMainFrm.LabeledEdit_UstavkaKeyPress(Sender: TObject; var Key: Char);
begin
  LabeledEdit_Ustavka.Text := CheckKeyForFloatStr(LabeledEdit_Ustavka.Text, Key, true);
  SetEditColor;
  GetGraphValue;
end;

// ��������� ��������� �� ini �����
procedure TMainFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, len : Integer;
  val: OleVariant;
  PID_pIni: TIniFile;
begin
  // ��������� ���-����������
  GORN.PID_IniFile := a_pIni.ReadString(String(str), 'PID_IniFile', '');
  if GORN.PID_IniFile <> '' then
    begin
      PID_pIni := TIniFile.Create(GORN.PID_IniFile);

      //GORN.PID_ShowConfig := PID_pIni.ReadBool(str_PID_ini, 'PID_ShowConfig', true);
      GORN.PID_P          := StrToFloatDecimalSeparator(PID_pIni.ReadString(str_PID_ini, 'PID_P', '0'));
      GORN.PID_I          := StrToFloatDecimalSeparator(PID_pIni.ReadString(str_PID_ini, 'PID_I', '0'));
      GORN.PID_D          := StrToFloatDecimalSeparator(PID_pIni.ReadString(str_PID_ini, 'PID_D', '0'));
      GORN.PID_Min        := StrToFloatDecimalSeparator(PID_pIni.ReadString(str_PID_ini, 'PID_Min', '0.01'));
      GORN.PID_Treg       := PID_pIni.ReadInteger(str_PID_ini, 'PID_Treg', 0);
      PID_pIni.Free;
    end;

  // ��������� �������
  GORN.Name     := a_pIni.ReadString(String(str), 'Name',     '---');
  GORN.NameText := a_pIni.ReadString(String(str), 'NameText', '');

  len := a_pIni.ReadInteger(String(str), 'TermoCount', 0);
  SetLength(GORN.TermoTags, len);
  for i := 0 to len - 1 do
    begin
      GORN.TermoTags[i].Name := a_pIni.ReadString(String(str), 'Termo_' + IntToStr(i) + '_Name', '---');
    end;

  GORN.I_Max := a_pIni.ReadFloat(String(str), 'I_Max', 1);
  GORN.U_Max := a_pIni.ReadFloat(String(str), 'U_Max', 1);
  GORN.P_Max := a_pIni.ReadFloat(String(str), 'P_Max', 1);

  GORN.PID_Use := a_pIni.ReadBool(String(str), 'PID_Use', true);

  Reg.Max := a_pIni.ReadFloat(String(str), 'P_Max', 1);
  Reg.Min := 0;

  GORN.TermoON    := a_pIni.ReadFloat(String(str), 'TermoON',  -999);
  GORN.TermoOFF   := a_pIni.ReadFloat(String(str), 'TermoOFF', 999);

  GORN.shum_enable     := a_pIni.ReadBool(String(str),    'shum_enable',     false);
  GORN.shum_pass_count := a_pIni.ReadInteger(String(str), 'shum_pass_count', 0);

  ApplySettings;

  //LabelMeasure.Caption := 'I��� = 0 �'#13#10 + 'U��� = 0 �'#13#10 + 'P��� = 0 ��';
end;

// ��������� ��������� � ini ����
procedure TMainFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, len : Integer;
begin
  a_pIni.EraseSection(String(str));

  a_pIni.WriteString(String(str), 'Name',     GORN.Name);
  a_pIni.WriteString(String(str), 'NameText', GORN.NameText);

  len := Length(GORN.TermoTags);
  a_pIni.WriteInteger(String(str), 'TermoCount', len);
  for i := 0 to len - 1 do
    begin
      a_pIni.WriteString(String(str), 'Termo_' + IntToStr(i) + '_Name', GORN.TermoTags[i].Name);
    end;

  a_pIni.WriteFloat(String(str), 'I_Max', GORN.I_Max);
  a_pIni.WriteFloat(String(str), 'U_Max', GORN.U_Max);
  a_pIni.WriteFloat(String(str), 'P_Max', GORN.P_Max);

  a_pIni.WriteBool(String(str),   'PID_Use',     GORN.PID_Use);
  a_pIni.WriteString(String(str), 'PID_IniFile', GORN.PID_IniFile);

  a_pIni.WriteFloat(String(str), 'TermoON',    GORN.TermoON);
  a_pIni.WriteFloat(String(str), 'TermoOFF',   GORN.TermoOFF);

  a_pIni.WriteBool(String(str),    'shum_enable',     GORN.shum_enable);
  a_pIni.WriteInteger(String(str), 'shum_pass_count', GORN.shum_pass_count);
end;

// ��������� ���������
procedure TMainFrm.ApplySettings;
var
  i, j, len : Integer;
  tags_ok : Boolean;
  Tags_selected_temp : TermoDetectors_type_array;
  Termo_temp : TTermoDetectorsType;
begin
  GetRecorderTags;

  // ���� �����
  if GORN.Name = '' then GORN.Name := '---';
  GroupBox_Main.Caption := GORN.NameText + ' (' + GORN.Name + ')';

  GORN.I_Tag := GetTagByName('I_' + GORN.Name);
  GORN.U_Tag := GetTagByName('U_' + GORN.Name);
  GORN.P_Tag := GetTagByName('P_' + GORN.Name);

  // ���� ��� ������ �����������
  GORN.Iizm_Tag := GetTagByName('I���_' + GORN.Name);
  GORN.Uizm_Tag := GetTagByName('U���_' + GORN.Name);
  GORN.Pizm_Tag := GetTagByName('P���_' + GORN.Name);

  // ���� �����
  GORN.P_272_Tag := GetTagByName('272 ������� ������� �����_' + GORN.Name);
  GORN.P_273_Tag := GetTagByName('273 ��������� ��������� ����_' + GORN.Name);
  GORN.P_275_Tag := GetTagByName('275 ��������� ���������� ��������_' + GORN.Name);

  // ���������� ��������
  GORN.Power_Tag := GetTagByName('�������_' + GORN.Name);

  // ���������� ������������
  GORN.Ventilator_Tag := GetTagByName('����_' + GORN.Name);

  // ������� ����������
  GORN.Auto_Ustavka_ITag := GetTagByName(String('�������_' + GORN.Name));
  GORN.Auto_Mode_ITag    := GetTagByName(String('���_' + GORN.Name));
  GORN.PID_Local  := GetTagByName(String('PID_' + GORN.Name));
  GORN.PID_Global := GetTagByName(String('Global_PID'));

  // ������� �����������
  GORN.TermoMidle_Tag := GetTagByName(String('������_' + GORN.Name));

  // �������� � �������� ������ �����
  if GORN.Name <> '---' then
    begin
      tags_ok := true;

      if GORN.I_Tag = nil then tags_ok := false;
      if GORN.U_Tag = nil then tags_ok := false;
      if GORN.P_Tag = nil then tags_ok := false;

      //if GORN.Iizm_Tag = nil then tags_ok := false;
      //if GORN.Uizm_Tag = nil then tags_ok := false;
      if GORN.Pizm_Tag = nil then tags_ok := false;

      if GORN.P_272_Tag = nil then tags_ok := false;
      if GORN.P_273_Tag = nil then tags_ok := false;
      if GORN.P_275_Tag = nil then tags_ok := false;

      if GORN.Power_Tag = nil then tags_ok := false;

      if GORN.Auto_Ustavka_ITag = nil then tags_ok := false;
      if GORN.Auto_Mode_ITag    = nil then tags_ok := false;
      if GORN.PID_Local  = nil then tags_ok := false;
      if GORN.PID_Global = nil then tags_ok := false;

      if GORN.TermoMidle_Tag = nil then tags_ok := false;

      if not tags_ok then
        begin
          Rc_EnterConfigMode;
            if GORN.I_Tag = nil then CreateNewVirtualTagQuick('I_' + GORN.Name, GORN.I_Tag);
            if GORN.U_Tag = nil then CreateNewVirtualTagQuick('U_' + GORN.Name, GORN.U_Tag);
            if GORN.P_Tag = nil then CreateNewVirtualTagQuick('P_' + GORN.Name, GORN.P_Tag);

            //if GORN.Iizm_Tag = nil then tags_ok := false;
            //if GORN.Uizm_Tag = nil then tags_ok := false;
            if GORN.Pizm_Tag = nil then CreateNewVirtualTagQuick('P���_' + GORN.Name, GORN.Pizm_Tag);

            if GORN.P_272_Tag = nil then CreateNewVirtualTagQuick('272 ������� ������� �����_' + GORN.Name,         GORN.P_272_Tag);
            if GORN.P_273_Tag = nil then CreateNewVirtualTagQuick('273 ��������� ��������� ����_' + GORN.Name,      GORN.P_273_Tag);
            if GORN.P_275_Tag = nil then CreateNewVirtualTagQuick('275 ��������� ���������� ��������_' + GORN.Name, GORN.P_275_Tag);

            if GORN.Power_Tag = nil then CreateNewVirtualTagQuick('�������_' + GORN.Name, GORN.Power_Tag);

            if GORN.Auto_Ustavka_ITag = nil then CreateNewVirtualTagQuick('�������_' + GORN.Name, GORN.Auto_Ustavka_ITag);
            if GORN.Auto_Mode_ITag    = nil then CreateNewVirtualTagQuick('���_' + GORN.Name,     GORN.Auto_Mode_ITag);
            if GORN.PID_Local  = nil then CreateNewVirtualTagQuick('PID_' + GORN.Name, GORN.PID_Local);
            if GORN.PID_Global = nil then CreateNewVirtualTagQuick('Global_PID',       GORN.PID_Global);

            if GORN.TermoMidle_Tag = nil then CreateNewVirtualTagQuick('������_' + GORN.Name,  GORN.TermoMidle_Tag);
          Rc_LeaveConfigMode;
        end;
    end;

  // ���� �������������
  Tags_selected_temp := GORN.TermoTags;
  len := Length(GORN.TermoTags);
  SetLength(GORN.TermoTags, 0);
  j := 0;
  for i := 0 to len - 1 do // ������� �������� ����
    begin
      Tags_selected_temp[i].Tag := GetTagByName(Tags_selected_temp[i].Name);

      if Tags_selected_temp[i].Tag = nil then Continue;

      SetLength(GORN.TermoTags, j + 1); // ����������� ������
      GORN.TermoTags[j] := Tags_selected_temp[i];

      j := j + 1;
    end;

  // ��������� �� �����
  len := Length(GORN.TermoTags);
  for i := 0 to len - 1 do
  for j := 0 to len - 2 do
    if GORN.TermoTags[j].Name > GORN.TermoTags[j+1].Name then
      begin
        Termo_temp := GORN.TermoTags[j];
        GORN.TermoTags[j] := GORN.TermoTags[j+1];
        GORN.TermoTags[j+1] := Termo_temp;
      end;

  SetControlMngPropSend; // ��������� ��������� �����������
end;

// ������ ���� ���� ����� �����
procedure TMainFrm.SetEditColor;
var
  val : Double;
begin
  LabeledEdit_Ustavka.Color := clWindow;

  if not CheckBoxON.Checked then Exit;

  if ComboBoxManual.ItemIndex = c_Manual then
    if TryStrToFloat(LabeledEdit_Ustavka.Text, val) then  // �������� �� �����
      LabeledEdit_Ustavka.Color := clMoneyGreen
    else
      LabeledEdit_Ustavka.Color := clRed;
end;

// -----------------------------------------------------------------------------

end.
