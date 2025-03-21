unit uTmpltNameFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uCommonMath, uWPProc, PathUtils, inifiles,
  uComponentServises;

type
  TTmpltNameFrame = class(TFrame)
    tmpltLabel: TLabel;
    TmpltEdit: TEdit;
    FolderLabel: TLabel;
    FolderEdit: TEdit;
    FolderBtn: TButton;
    TmpltBtn: TButton;
    DateCB: TCheckBox;
    MakeDefaultNameBtn: TButton;
    NameEdit: TEdit;
    NameLabel: TLabel;
    AutoPathCB: TCheckBox;
    Label2: TLabel;
    SavePathEdit: TEdit;
    NameRG: TRadioGroup;
    FolderRG: TRadioGroup;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    PathBtn: TButton;
    OpenDialog1vista: TFileOpenDialog;
    procedure TmpltBtnClick(Sender: TObject);
    procedure FolderBtnClick(Sender: TObject);
    procedure FolderRGClick(Sender: TObject);
    procedure NameRGClick(Sender: TObject);
    procedure AutoPathCBClick(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure DateCBClick(Sender: TObject);
    procedure MakeDefaultNameBtnClick(Sender: TObject);
    procedure PathBtnClick(Sender: TObject);
    procedure FolderEditChange(Sender: TObject);
    procedure TmpltEditChange(Sender: TObject);
  private
    // ��������� ���������� ������������
    m_ifile, m_section,
    // ������� ��� ���� ����������� ������
    m_key,
    // ���� � �������
    m_startdir:string;
    // ��������� ��� �������� � ����� �� ���������
    defName, defFolder,
    // ���� �� ��������� �������� ��������� �������������� ����
    objectName: string;
  private
    function GenName: string;
    function GenFolder: string;
    function CheckTmpltPath(str: string): boolean;
  public
    function GenPath: string;
    // ���������� ���� �� �������� ����� ����������� ���������
    Procedure SetIFile(fname, section, key, startdir:string);
    procedure SaveParams;
    procedure LoadParams;
    // ������� ���� � �������
    function GenTmpltPath: string;
    // ���� �� ��������� �������� ��������� �������������� ����
    Procedure SetObjectPath(ObjName:string);
  end;

implementation

{$R *.dfm}

procedure TTmpltNameFrame.SaveParams;
var
  ifile: tinifile;
begin
  ifile := tinifile.create(m_ifile);
  if FolderRG.ItemIndex = 0 then
    ifile.WriteString(m_section, m_key+'DefFolder', FolderEdit.Text)
  else
    ifile.WriteString(m_section, m_key+'DefFolder', defFolder);

  ifile.WriteString(m_section, m_key+'DefName', defName);
  ifile.WriteInteger(m_section,m_key+ 'DefFolderRG', FolderRG.ItemIndex);
  ifile.WriteInteger(m_section,m_key+ 'DefNameRG', NameRG.ItemIndex);
  ifile.WriteBool(m_section, m_key+'AutoPath', AutoPathCB.Checked);
  ifile.WriteBool(m_section, m_key+'IncludeDate', DateCB.Checked);
  ifile.WriteString(m_section, m_key+'Temlate', TmpltEdit.Text);
  ifile.destroy;
end;

procedure TTmpltNameFrame.LoadParams;
var
  ifile: tinifile;
begin
  ifile := tinifile.create(m_ifile);
  defFolder := ifile.ReadString(m_section, m_key+'DefFolder', '');
  defName := ifile.ReadString(m_section, m_key+'DefName', '');
  FolderRG.ItemIndex := ifile.ReadInteger(m_section, m_key+'DefFolderRG', 0);
  case FolderRG.ItemIndex of
    0: // ������� �� ���������
    begin
      folderedit.Text:=defFolder;
    end;
    1: // ������� ������
    begin

    end;
  end;
  NameRG.ItemIndex := ifile.ReadInteger(m_section, m_key+'DefNameRG', 0);
  Nameedit.Text:=ifile.ReadString(m_section,m_key+ 'DefName', 'Rep.xls');
  AutoPathCB.Checked := ifile.ReadBool(m_section, m_key+'AutoPath', True);
  DateCB.Checked := ifile.ReadBool(m_section, m_key+'IncludeDate', True);
  TmpltEdit.Text := ifile.ReadString(m_section, m_key+'Temlate','����� �����������.xls');
  TmpltEditChange(nil);
end;

function TTmpltNameFrame.GenTmpltPath: string;
begin
  result := TmpltEdit.Text;
  if ((pos('/', TmpltEdit.Text) < 1) or (pos('.', TmpltEdit.Text) > 0) or
      (pos('.', TmpltEdit.Text) > 0)) then
  begin
    result := RelativePathToAbsolute(m_startdir, TmpltEdit.Text);
  end;
end;

Procedure TTmpltNameFrame.SetObjectPath(ObjName:string);
begin
  objectName:=ObjName;
  GenPath;
end;

function TTmpltNameFrame.GenName: string;
var
  subname, ext,str, tmpltext:string;
begin
  tmpltext:=ExtractFileext(TmpltEdit.text);
  case NameRG.ItemIndex of
    0:
      begin
        if DateCB.Checked then
        begin
          subname:=TrimExt(defName);
          ext:=ExtractFileExt(defName);
          NameEdit.Text := subname + '_' + datetostr(now)+ext;
        end
        else
          NameEdit.Text := defName;
      end;
    1:
      begin
        if objectName<>'' then
        begin
          str:=ExtractFileName(objectname);
          str:=trimExt(str);
          if DateCB.Checked then
            str:=str+'_'+datetostr(now);
        end;
      end;
  end;
  if tmpltext<>'' then
  begin
    ext:=tmpltext;
  end
  else
  begin
    ext:=ExtractFileExt(str);
  end;
  result := str+ext;
end;

function TTmpltNameFrame.GenPath: string;
var
  l:integer;
  f, n:string;
begin
  case FolderRG.ItemIndex of
    0:
      begin
        FolderBtn.Enabled := True;
        FolderLabel.Caption := '������� �� ���������';
        FolderEdit.text:=GenFolder;
      end;
    1:
      begin
        FolderLabel.Caption := '������� ������';
        FolderBtn.Enabled := false;
        FolderEdit.text:=GenFolder;
      end;
  end;
  l:=length(FolderEdit.Text);
  f:=GenFolder;
  n:=GenName;
  if l<>0 then
  begin
    if FolderEdit.Text[l]<>'\' then
      SavePathEdit.Text := FolderEdit.Text + '\' + NameEdit.Text
    else
      SavePathEdit.Text := FolderEdit.Text + NameEdit.Text;

    result:=SavePathEdit.Text;
  end;
end;

procedure TTmpltNameFrame.MakeDefaultNameBtnClick(Sender: TObject);
begin
  defName := NameEdit.Text;
  defFolder:=FolderEdit.Text;
  NameRG.ItemIndex := 0;
  FolderRG.ItemIndex := 0;
end;

procedure TTmpltNameFrame.AutoPathCBClick(Sender: TObject);
begin
  if AutoPathCB.Checked then
    GenPath;
end;

procedure TTmpltNameFrame.DateCBClick(Sender: TObject);
begin
  NameRGClick(nil);
end;

procedure TTmpltNameFrame.FolderBtnClick(Sender: TObject);
begin
  FolderEdit.Text := Opendialog(OpenDialog1vista,folderedit.Text);
end;

procedure TTmpltNameFrame.FolderEditChange(Sender: TObject);
begin
  GenPath;
end;

function TTmpltNameFrame.GenFolder: string;
begin
  result:='';
  case FolderRG.ItemIndex of
    0:
    begin
      result := defFolder;
    end;
    1:
    begin
      if objectName <> '' then
        result:=extractfiledir(objectName);
    end;
  end;
end;

procedure TTmpltNameFrame.FolderRGClick(Sender: TObject);
begin
  case FolderRG.ItemIndex of
    0:
      begin
        FolderBtn.Enabled := True;
        FolderLabel.Caption := '������� �� ���������';
        FolderEdit.text:=GenFolder;
      end;
    1:
      begin
        FolderLabel.Caption := '������� ������';
        FolderBtn.Enabled := false;
        FolderEdit.text:=GenFolder;
      end;
  end;
  GenPath;
end;

procedure TTmpltNameFrame.NameEditChange(Sender: TObject);
begin
  // ���������������� ���
  if NameEdit.Focused then
    NameRG.ItemIndex := 2;
  GenPath;
end;

procedure TTmpltNameFrame.NameRGClick(Sender: TObject);
begin
  case NameRG.ItemIndex of
    0:
      begin
        NameRG.Caption := '��� ������ �� ���������';
        GenName;
      end;
    1:
      begin
        NameRG.Caption := '��� ������';
        NameEdit.text:=GenName;
      end;
  end;
  AutoPathCBClick(nil);
end;

procedure TTmpltNameFrame.PathBtnClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    SavePathEdit.Text := SaveDialog1.filename;
  end;
end;

function TTmpltNameFrame.CheckTmpltPath(str: string): boolean;
begin
  if fileexists(str) then
  begin
    result := True;
    TmpltEdit.Color := clwindow;
  end
  else
  begin
    result := false;
    TmpltEdit.Color := $008080FF;
  end;
end;

procedure TTmpltNameFrame.TmpltBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    TmpltEdit.Text := OpenDialog1.filename;
  end;
end;

procedure TTmpltNameFrame.TmpltEditChange(Sender: TObject);
begin
  TmpltEdit.hint:=RelativePathToAbsolute(TmpltEdit.Text);
end;

Procedure TTmpltNameFrame.SetIFile(fname, section, key, startdir:string);
begin
  m_ifile:=fname;
  m_section:=section;
  m_key:=key;
  m_startdir:=startdir;
end;

end.


