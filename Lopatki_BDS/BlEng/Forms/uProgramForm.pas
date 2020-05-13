unit uProgramForm;

interface

uses
  Windows, SysUtils, Forms,
  Dialogs, ComCtrls, StdCtrls,
  inifiles, ubldeng, uCommonMath, uErrorProc, Controls, Classes,
  uSaveEng, uTurbina, uBldTimeProc;

type
  TEditProjForm = class(TForm)
    ProgramEditTabList: TPageControl;
    TabSheet1: TTabSheet;
    EngGB: TGroupBox;
    WriteJournalCb: TCheckBox;
    ShowMessagesCB: TCheckBox;
    MainFormGB: TGroupBox;
    ShowMouseInputCB: TCheckBox;
    ShowChartEventsCB: TCheckBox;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    OpenDialog1: TOpenDialog;
    MainGB: TGroupBox;
    DefaultCfgBtn: TButton;
    DefaultCfgEdit: TEdit;
    ReplayDataGroupBox: TGroupBox;
    ReplayFolderLabel: TLabel;
    ReplayFolderEdit: TEdit;
    ReplayFNameLabel: TLabel;
    ReplayFNameEdit: TEdit;
    ReplayFolderSelect: TButton;
    ReplayFNameSelect: TButton;
    ReplayFolderDlg: TOpenDialog;
    ReplayFNameDlg: TOpenDialog;
    SaveFolderBtn: TButton;
    SaveFolderLabel: TLabel;
    SaveFolderEdit: TEdit;
    SaveFolderDlg: TOpenDialog;
    DefaultCfgLabel: TLabel;
    Label1: TLabel;
    ModeCB: TComboBox;
    procedure DefaultCfgBtnClick(Sender: TObject);
    procedure ReplayFolderSelectClick(Sender: TObject);
    procedure ReplayFNameSelectClick(Sender: TObject);
    procedure SaveFolderBtnClick(Sender: TObject);
  private
  public
    Function Showmodal(form:tform;eng:cBldEng):integer;
  end;

var
  EditProjForm: TEditProjForm;

const
  c_Files = $00000001;
  c_Device = $00000002;
  c_Demo = $00000004;

implementation
uses
  mainform;

{$R *.dfm}

procedure TEditProjForm.DefaultCfgBtnClick(Sender: TObject);
begin
  if opendialog1.Execute(0) then
  begin
    DefaultCfgEdit.Text:=OpenDialog1.FileName;
  end;
end;

procedure TEditProjForm.ReplayFNameSelectClick(Sender: TObject);
begin
  if ReplayFNameDlg.Execute(0) then
  begin
    ReplayFNameEdit.Text:=ReplayFNameDlg.FileName;
  end;
end;

procedure TEditProjForm.ReplayFolderSelectClick(Sender: TObject);
begin
  if ReplayFolderDlg.Execute(0) then
  begin
    ReplayFolderEdit.Text:=ReplayFolderDlg.FileName;
  end;
end;

procedure TEditProjForm.SaveFolderBtnClick(Sender: TObject);
begin
  if SaveFolderDlg.Execute(0) then
  begin
    SaveFolderEdit.Text:=SaveFolderDlg.FileName;
  end;
end;

Function TEditProjForm.Showmodal(form:tform;eng:cBldEng):integer;
begin
  WriteJournalCb.Checked:=CheckFlag(eng.flags, c_LogMessage);
  ShowMessagesCB.Checked:=CheckFlag(eng.flags, c_ShowMessage);
  // пишем параметры главной формы
  //ShowChartEventsCB.Checked:=TMainBldForm(form).chartframe1.EventsListView.Visible;
  ShowMouseInputCB.Checked:=TMainBldForm(form).MouseGB.Visible;
  DefaultCfgEdit.Text:=eng.curCfg;
  // отобразить режим воспроизведения
  ReplayFNameEdit.Text:=eng.GetFName;
  ReplayFolderEdit.Text:=eng.GetFolder;
  ModeCB.itemindex:=TMainBldForm(form).fMode;
  SaveFolderEdit.Text:=eng.SaveFolder;
  if inherited Showmodal=mrok then
  begin
    eng.setEngFlag(c_LogMessage,WriteJournalCb.Checked);
    eng.setEngFlag(c_ShowMessage,ShowMessagesCB.Checked);
    // режим воспроизведения
    eng.SetFolderPath(ReplayFolderEdit.Text,ReplayFNameEdit.Text);
    case ModeCB.itemindex of
      0:TMainBldForm(form).fMode:=c_Demo;
      1:TMainBldForm(form).fMode:=c_Files;
      2:TMainBldForm(form).fMode:=c_Device;
    end;
    // пишем форму
    //TMainBldForm(form).chartframe1.EventsListView.Visible:=ShowChartEventsCB.Checked;
    TMainBldForm(form).MouseGB.Visible:=ShowMouseInputCB.Checked;
    eng.curCfg:=DefaultCfgEdit.Text;
    if length(SaveFolderEdit.Text)>0 then
    begin
      if SaveFolderEdit.Text[length(SaveFolderEdit.Text)]<>'\' then
        SaveFolderEdit.Text:=SaveFolderEdit.Text+'\';
    end;
    eng.SaveFolder:=SaveFolderEdit.Text;
    saveEng(form, eng);
  end;
end;


end.
