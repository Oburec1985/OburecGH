unit uEditProg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uSpin, uProgramObj, uModeObj, uControlObj,
  u3120ControlObj, uCpEngine;

type
  TEditProgFrm = class(TForm)
    ProgramGB: TGroupBox;
    ProgLB: TListBox;
    Splitter1: TSplitter;
    ModeGB: TGroupBox;
    ModesLB: TListBox;
    EnableThresholdCb: TCheckBox;
    ThresholdLabel: TLabel;
    ThresholdSE: TFloatSpinEdit;
    ThresholdType: TRadioGroup;
    BottomPanel: TPanel;
    ModeNameEdit: TEdit;
    ModeLabel: TLabel;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    RepTamplatesCb: TComboBox;
    TmpltLabel: TLabel;
    CpTimeSe: TFloatSpinEdit;
    CpLabel: TLabel;
    AvrTimeLabel: TLabel;
    AvrTimeSe: TFloatSpinEdit;
    AutoCpCb: TCheckBox;
    procedure ApplyBtnClick(Sender: TObject);
    procedure ModesLBClick(Sender: TObject);
    procedure CopyProgBtnClick(Sender: TObject);
    procedure ProgLBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ProgLBKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    m_curP: cprogramObj;
    m_curM: cModeObj;
  private
    procedure ShowProg(p: cprogramObj);
    procedure ShowMode(m: cModeObj);
  public
    procedure showPrograms(mng: cControlMng);
  end;

var
  EditProgFrm: TEditProgFrm;

implementation

uses
  u3120Frm;
{$R *.dfm}

{ TEditProgFrm }
procedure TEditProgFrm.ApplyBtnClick(Sender: TObject);
var
  I: Integer;
  t: cTask;
begin
  m_curM.CheckThreshold := EnableThresholdCb.Checked;
  m_curM.StartTimeOnTolerance := EnableThresholdCb.Checked;
  m_curM.AutoCp := AutoCpCb.Checked;
  for I := 0 to m_curM.TaskCount - 1 do
  begin
    t := m_curM.GetTask(I);
    t.m_tolerance := ThresholdSE.Value;
    t.m_tolType := ThresholdType.ItemIndex;
    t.m_useTolerance := m_curM.CheckThreshold;
  end;
  g_cpEngine.m_Time:=CpTimeSe.Value;
  g_cpEngine.m_avrTime:=AvrTimeSe.Value;
  g_cpEngine.SelTmpltIndex:=RepTamplatesCb.ItemIndex;
end;

procedure TEditProgFrm.CopyProgBtnClick(Sender: TObject);
var
  c: cControlobj;
  p: cprogramObj;
  m, new: cModeObj;
  I: Integer;
begin
  p := cprogramObj.create;
  p.name := 'Prog_0' + inttostr(g_conmng.ProgramCount + 1);
  p.CreateStateTag;
  p.RepeatCount := 1;
  p.m_StartOnPlay := false;
  p.m_enableOnStart := true;
  for I := 0 to m_curP.ControlCount - 1 do
  begin
    c := m_curP.getOwnControl(I);
    p.AddControl(c);
  end;
  g_conmng.Add(p);
  for I := 0 to m_curP.modeCount - 1 do
  begin
    m := m_curP.getMode(I);
    new := m.NewMode();
    p.addmode(new);
    new.name := p.name + '_' + m.name;
    new.caption := m.caption;
  end;
  showPrograms(g_conmng);
end;

procedure TEditProgFrm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i:integer;
  p:cProgramObj;
begin
  if g_conmng=nil then exit;
  if Frm3120<>nil then
  begin
    if g_conmng.ProgramCount<>0 then
    begin
      Frm3120.ProgramsCB.Clear;
      for I := 0 to g_conmng.ProgramCount - 1 do
      begin
        p := g_conmng.getProgram(I);
        Frm3120.ProgramsCB.AddItem(p.name, p);
      end;
    end;
  end;
end;

procedure TEditProgFrm.ModesLBClick(Sender: TObject);
begin
  if ModesLB.ItemIndex > -1 then
  begin
    m_curM := cModeObj(ModesLB.items.Objects[ModesLB.ItemIndex]);
    ShowMode(m_curM);
  end;
end;

procedure TEditProgFrm.ProgLBClick(Sender: TObject);
begin
  if ProgLB.ItemIndex > -1 then
  begin
    m_curP := cprogramObj(ProgLB.items.Objects[ProgLB.ItemIndex]);
    ShowProg(m_curP);
  end;
end;

procedure TEditProgFrm.ProgLBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  p:cProgramObj;
begin
  p:=cProgramObj(progLB.Items.Objects[progLB.ItemIndex]);
  p.destroy;
  showPrograms(g_conmng);
end;

procedure TEditProgFrm.ShowMode(m: cModeObj);
var
  t: cTask;
begin
  ModeNameEdit.Text := m.name;
  EnableThresholdCb.Checked := m.CheckThreshold;
  AutoCpCb.Checked:= m.AutoCp;
  t := m.GetTask(0);
  if t <> nil then
  begin
    ThresholdSE.Value := t.m_tolerance;
    ThresholdType.ItemIndex := t.m_tolType;
  end
  else
  begin
    ThresholdSE.Value := 3;
    ThresholdType.ItemIndex := 0;
  end;
end;

procedure TEditProgFrm.ShowProg(p: cprogramObj);
var
  I: Integer;
  m: cModeObj;
begin
  m_curM := nil;
  ModesLB.Clear;
  for I := 0 to p.modeCount - 1 do
  begin
    m := p.getMode(I);
    ModesLB.AddItem(m.caption, m);
    if I = 0 then
    begin
      m_curM := m;
    end;
  end;
end;

procedure TEditProgFrm.showPrograms(mng: cControlMng);
var
  I: Integer;
  p: cprogramObj;
begin
  m_curP := nil;
  ProgLB.Clear;
  for I := 0 to mng.ProgramCount - 1 do
  begin
    p := mng.getProgram(I);
    ProgLB.AddItem(p.name, p);
    if I = 0 then
    begin
      m_curP := p;
      ShowProg(p);
    end;
  end;
  // מעמבנאזאול Êׂ
  CpTimeSe.Value:=g_cpEngine.m_Time;
  AvrTimeSe.Value:=g_cpEngine.m_avrTime;
  for I := 0 to g_cpEngine.TmpltCount - 1 do
  begin
    RepTamplatesCb.AddItem(extractfilename(g_cpEngine.getTmplt(i)), nil);
  end;
  if g_cpEngine.TmpltCount>0 then
    RepTamplatesCb.ItemIndex:=g_cpEngine.SelTmpltIndex;

  show;
end;

end.
