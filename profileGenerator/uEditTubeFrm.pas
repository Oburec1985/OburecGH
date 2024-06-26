unit uEditTubeFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, ExtCtrls, StdCtrls, umerafile, uComponentServises,
  inifiles, uCommonMath;

type
  TEditTubeFrm = class(TForm)
    GroupBox1: TGroupBox;
    SignalsLV: TBtnListView;
    OpenTubeDlg: TOpenDialog;
    FilePath: TEdit;
    OpenBtn: TButton;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    TubePath: TEdit;
    Label2: TLabel;
    OpenFileBtn: TButton;
    OpenFileDlg: TOpenDialog;
    procedure OpenBtnClick(Sender: TObject);
    // ��������� ������� ������
    procedure CheckTube(Sender: TObject);
    // ��������� ��� ������
    procedure CheckFile(Sender: TObject);
    procedure OpenFileBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
  public
    function Showmodal:integer;override;
  public
    f:tinifile;
  end;

var
  EditTubeFrm: TEditTubeFrm;

const
  ErrorPathStr = '�� ������ ����';

implementation

{$R *.dfm}

procedure TEditTubeFrm.Button1Click(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
  str,name, path:string;
begin
  for I := 0 to signalsLV.items.Count - 1 do
  begin
    li:=signalsLV.Items[i];
    signalsLV.GetSubItemByColumnName('��� ������ �������',li,str);
    signalsLV.GetSubItemByColumnName('��� �������',li,name);
    str:=extractfilename(str);
    str:=TrimExt(str);
    f.WriteString(name, 'Tube', str);
  end;
  f.destroy;
  f:=nil;
end;

procedure TEditTubeFrm.CheckFile;
begin
  if not fileexists(FilePath.Text) then
  begin
    filepath.Color:=$008080FF;
    filepath.hint:=ErrorPathStr;
  end
  else
  begin
    filepath.Color:=clWindow;
    filepath.hint:='';
  end;
end;

procedure TEditTubeFrm.CheckTube;
begin
  if not fileexists(TubePath.Text) then
  begin
    TubePath.Color:=$008080FF;
    TubePath.hint:=ErrorPathStr;
  end
  else
  begin
    TubePath.Color:=clWindow;
    TubePath.hint:='';
  end;
end;

procedure TEditTubeFrm.OpenBtnClick(Sender: TObject);
var
  i:integer;
  li:tlistitem;
  str:string;
begin
  if signalslv.selcount>0 then
  begin
    for I := signalslv.Selected.Index to (signalslv.Selected.Index+signalslv.SelCount - 1) do
    begin
      li:=signalslv.items[i];
      signalslv.SetSubItemByColumnName('��� ������ �������', TubePath.Text, li);
    end;
  end;
end;

procedure TEditTubeFrm.OpenFileBtnClick(Sender: TObject);
var
  slist:tstringlist;
  I: Integer;
  li:tlistitem;
  str:string;
begin
  if OpenFileDlg.Execute(0) then
  begin
    FilePath.Text:=OpenFileDlg.FileName;
  end
  else
    exit;
  if fileexists(FilePath.Text) then
  begin
    if f<>nil then
    begin
      f.Destroy;
      f:=tinifile.Create(FilePath.Text);
    end
    else
    begin
      f:=tinifile.Create(FilePath.Text);
    end;
    slist:=tstringlist.Create;
    GetSignalList(f, slist);

    signalsLV.Clear;
    for I := 0 to sList.Count - 1 do
    begin
      li:=signalsLV.items.Add;
      signalsLV.SetSubItemByColumnName('�',slist.Strings[i],li);
      str:=f.ReadString(slist.Strings[i],'Tube','');
      signalsLV.SetSubItemByColumnName('��� �������',slist.Strings[i],li);
      signalsLV.SetSubItemByColumnName('��� ������ �������', str, li);
    end;
    slist.Destroy;
    LVChange(signalsLV);
  end;
end;

function TEditTubeFrm.Showmodal:integer;
begin
  result:=inherited showmodal;
end;

end.
