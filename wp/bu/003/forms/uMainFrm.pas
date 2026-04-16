unit uMainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, inifiles, uSpin;

type
  TMeraFileMngFrm = class(TForm)
    FileE1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    FileE2: TEdit;
    SelectPathBtn1: TButton;
    SelectPathBtn2: TButton;
    Start1: TLabel;
    PrtCB: TCheckBox;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    Button1: TButton;
    ErrorLogLB: TListBox;
    FileE3: TEdit;
    SelectPathBtn3: TButton;
    Label3: TLabel;
    SaveDialog1: TSaveDialog;
    StartSE1: TFloatSpinEdit;
    Label4: TLabel;
    EvalOffsetCheckBox: TCheckBox;
    procedure SelectPathBtn1Click(Sender: TObject);
    procedure SelectPathBtn2Click(Sender: TObject);
    procedure PrtCBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SelectPathBtn3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure EvalOffsetCheckBoxClick(Sender: TObject);
    procedure FileE1Change(Sender: TObject);
    procedure StartSE1Enter(Sender: TObject);
  private
    ifile:tinifile;
    blocksize:cardinal;
    manualOffset:double;
    auto:boolean;
  private
    procedure Save;
    procedure load;
    procedure checkPath(f1,f2:string);
    procedure ConnectFiles;
  public
  end;

var
  MeraFileMngFrm: TMeraFileMngFrm;

implementation

uses uMeraFile;

{$R *.dfm}

procedure TMeraFileMngFrm.Save;
begin
  ifile.WriteString('main','File1',FileE1.Text);
  ifile.WriteString('main','File2',FileE2.Text);
  ifile.WriteString('main','File3',FileE3.Text);
  ifile.WriteBool('main','WritePrt',PrtCB.Checked);
  ifile.WriteInteger('main', 'BlockSize', blockSize);
  ifile.WriteFloat('main', 'Offset', manualOffset);
  ifile.WriteBool('main','AutoEvalStart',EvalOffsetCheckBox.Checked);
end;

procedure TMeraFileMngFrm.FileE1Change(Sender: TObject);
begin
  checkPath(FileE1.Text, FileE2.Text);
end;

procedure TMeraFileMngFrm.FormCreate(Sender: TObject);
begin
  ifile:=tinifile.Create(extractfiledir(Application.ExeName)+'\MeraFileMng.ini');
  load;
end;

procedure TMeraFileMngFrm.FormDestroy(Sender: TObject);
begin
  save;
  ifile.Destroy;
end;

procedure TMeraFileMngFrm.load;
begin
  PrtCB.Checked:=ifile.ReadBool('main','WritePrt',false);
  FileE1.Text:=ifile.ReadString('main','File1','');
  FileE2.Text:=ifile.ReadString('main','File2','');
  FileE3.Text:=ifile.ReadString('main','File3','');
  // размер блока по умолчанию 20 мегабайт
  blockSize:=ifile.ReadInteger('main','BlockSize',2000000);
  manualOffset:=ifile.ReadFloat('main','Offset',0);
  EvalOffsetCheckBox.Checked:=ifile.ReadBool('main','AutoEvalStart',false);
  StartSE1.Enabled:=not EvalOffsetCheckBox.Checked;
  if not EvalOffsetCheckBox.Checked then
    StartSE1.Value:=manualOffset
  else
  begin
    EvalOffsetCheckBoxClick(nil);
  end;
  checkPath(FileE1.Text, FileE2.Text);  
end;

procedure TMeraFileMngFrm.PrtCBClick(Sender: TObject);
begin
  StartSE1.Enabled:=PrtCB.Checked and (not auto);
  EvalOffsetCheckBox.enabled:=PrtCB.Checked;
end;

procedure TMeraFileMngFrm.SelectPathBtn1Click(Sender: TObject);
begin
  if OpenDialog1.Execute(0) then
  begin
    FileE1.Text:=OpenDialog1.FileName;
  end;
end;

procedure TMeraFileMngFrm.SelectPathBtn2Click(Sender: TObject);
begin
  if OpenDialog2.Execute(0) then
  begin
    FileE2.Text:=OpenDialog2.FileName;
  end;
end;

procedure TMeraFileMngFrm.SelectPathBtn3Click(Sender: TObject);
begin
  if SaveDialog1.Execute(0) then
  begin
    FileE3.Text:=SaveDialog1.FileName;
    if pos('.mera',lowercase(FileE3.Text))<1 then
    begin
      FileE3.Text:=FileE3.Text+'.mera';
    end;
  end;
end;

procedure TMeraFileMngFrm.Button1Click(Sender: TObject);
begin
  ConnectFiles;
end;

procedure TMeraFileMngFrm.checkPath(f1,f2:string);
var
  errorstr,res:string;
  color:tcolor;
begin
  errorstr:='';
  if not fileexists(f1) then
  begin
    errorstr:='Не корректный путь к файлу File1';
    FileE1.Color:=$008080FF;
    FileE1.hint:=errorstr;
  end
  else
  begin
    FileE1.Color:=clWindow;
    FileE1.hint:='';
  end;

  if not fileexists(f2) then
  begin
    FileE2.Color:=$008080FF;
    errorstr:='Не корректный путь к файлу File2';
    FileE2.hint:=errorstr;
  end
  else
  begin
    FileE2.Color:=clWindow;
    FileE2.hint:='';
  end;

  f1:=lowercase(f1);
  f2:=lowercase(f2);
  res:=lowercase(filee3.Text);

  if res=f1 then
  begin
    FileE3.Color:=$008080FF;
    errorstr:='Результирующий файл совпадает с файлом 1';
    FileE3.Hint:=errorstr;
  end
  else
  begin
    FileE3.Color:=clWindow;
    FileE3.Hint:='';
  end;

  if res=f2 then
  begin
    FileE3.Color:=$008080FF;
    errorstr:='Результирующий файл совпадает с файлом 2';
    FileE3.Hint:=errorstr;
  end
  else
  begin
    FileE3.Color:=clWindow;
    FileE3.Hint:='';
  end;
  if (errorstr<>'') then
  begin
    evaloffsetcheckbox.Enabled:=false;
    Button1.Hint:=errorstr;
    Button1.Enabled:=false;
    prtcb.Enabled:=false;
    EvalOffsetCheckBox.Enabled:=false;
    startse1.Enabled:=false;
  end
  else
  begin
    prtcb.Enabled:=true;
    if prtcb.Checked then
      EvalOffsetCheckBox.Enabled:=true;
    if not EvalOffsetCheckBox.Checked then
    begin
      startse1.Enabled:=true;
    end
    else
      startse1.Enabled:=false;
    Button1.Enabled:=true;
    Button1.Hint:='Сшить файлы';
  end;
end;

function getdatestr(str:string):string;
var
  I, j: Integer;
begin
  result:='';
  j:=0;
  for I := 1 to length(str) do
  begin
    if (str[i]='.') or (str[i]=',') or (str[i]=':') then
    begin
      inc(j);
      if j=2 then
      begin
        break;
      end;
    end;
  end;
  for j := i+1 to length(str) do
  begin
    if (str[j]='.') or (str[j]=',') then
    begin
      if str[j]<>DecimalSeparator then
      begin
        str[j]:=DecimalSeparator;
      end;
    end;
  end;
  result:=str;
end;

procedure TMeraFileMngFrm.EvalOffsetCheckBoxClick(Sender: TObject);
var
  date,date1,date2,date3:tdatetime;
  m1,m2:tinifile;

  d1,d2,y,d,
  h,m,min,s,ms:word;
  datestr:string;
begin
  if EvalOffsetCheckBox.Checked then
  begin
    if (fileexists(FileE1.Text) and fileexists(FileE2.Text)) then
    begin
      auto:=true;
      StartSE1.Enabled:=false;
      m1:=TIniFile.Create(FileE1.Text);
      m2:=TIniFile.Create(FileE2.Text);

      datestr:=m1.ReadString('MERA', 'Time', '0:0:0');
      datestr:=getdatestr(datestr);
      date1:=StrToDateTime(datestr);

      datestr:=m2.ReadString('MERA', 'Time', '0:0:0');
      datestr:=getdatestr(datestr);
      date2:=StrToDateTime(datestr);

      date3:=date2-date1;
      DecodeTime(date3, h, min, s, ms);

      datestr:=m1.ReadString('MERA', 'Date', '0.0.0');
      date1:=StrToDateTime(datestr);
      DecodeDate(Date1, Y, M, D1);

      datestr:=m2.ReadString('MERA', 'Date', '0.0.0');
      date2:=StrToDateTime(datestr);
      DecodeDate(Date2, Y, M, D2);

      d:=d2-d1;
      StartSE1.Value:=d*86400 + h*3600 + min*60 + s + ms/1000;
    end;
  end
  else
  begin
    auto:=false;
    StartSE1.Enabled:=true;
    StartSE1.Value:=manualOffset;
  end;
end;

procedure TMeraFileMngFrm.StartSE1Enter(Sender: TObject);
begin
  if not EvalOffsetCheckBox.Checked then
    manualOffset:=StartSE1.Value;
end;

procedure TMeraFileMngFrm.ConnectFiles;
var
  errors:tstringlist;
  I: Integer;
begin
  errors:=tstringlist.Create;
  umerafile.connectfiles(filee1.text, filee2.text, filee3.text, blocksize, startse1.Value, errors, true);
  ErrorLogLB.clear;
  if errors<>nil then
  begin
    for I := 0 to errors.Count - 1 do
    begin
      ErrorLogLB.AddItem(errors.Strings[i], nil);
    end;
  end;
  errors.destroy;
end;

end.
