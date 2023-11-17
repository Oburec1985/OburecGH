unit uSaveSignalForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, umerasignal, umerafile, inifiles,
  Dialogs, StdCtrls, DCL_MYOWN, Controls, uBinFile, ubuffsignal;

type
  TSaveSignalForm = class(TForm)
    ResFreqLabel: TLabel;
    PathBtn: TButton;
    ResFreqIE: TIntEdit;
    PathEdit: TEdit;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    SaveDialog1: TSaveDialog;
    procedure PathBtnClick(Sender: TObject);
  private
    dir:string;
    fname:string;
    signals:cMerafile;
  protected
    procedure SaveHeader;
    procedure SaveData;
  public
    function SaveMera(p_signals:cMerafile):boolean;
  end;

var
  SaveSignalForm: TSaveSignalForm;

implementation
const
  c_mainSection = 'Mera';
  c_TestName = 'Test';
  c_Info = 'Info';
  c_Time = 'Time';
  c_Prod = 'Prod';
  c_freq = 'Freq';
  c_XUnits = 'XUnits';
  c_YUnits = 'YUnits';
  c_CharTP = 'c_CharTP';
  c_k0 ='k0';
  c_k1 ='k1';
  c_YFormat = 'YFormat';
  c_XFormat = 'XFormat';
  c_ChanID = 'ChanID';
  c_ChanNо = 'ChanNо';

{$R *.dfm}

procedure TSaveSignalForm.SaveHeader;
var
  f:tinifile;
  date:tdatetime;
  datestr:string;
  i:integer;
  signal:csignal;
begin
  if not DirectoryExists(dir) then
    ForceDirectories(dir);
  f:=tinifile.Create(dir+name);
  // Время испытания
  date:=now;
  datestr:=DateToStr(date)+' '+TimeToStr(date);
  f.WriteString(c_mainSection, c_Time, datestr);
  for I := 0 to signals.Count - 1 do
  begin
    signal:=signals.getsignal(i);
    // пишем имя сигнала
    f.WriteString(signal.name, 'Dsc', signal.dsc);
    // пишем имя сигнала
    f.WriteFloat(signal.name, c_freq, ResFreqIE.IntNum);
    // Подпись оси x
    f.WriteString(signal.name, c_XUnits, signal.xunits);
    // Подпись оси Y
    f.WriteString(signal.name, c_YUnits, signal.yunits);
    // формат x
    f.WriteString(signal.name, c_XFormat, 'single');
    // формат Y
    f.WriteString(signal.name, c_YFormat, 'single');
    // k0
    f.WriteFloat(signal.name, c_k0, 0);
    // k1
    f.WriteFloat(signal.name, c_k1, 1);
  end;
  f.Destroy;
end;

procedure TSaveSignalForm.PathBtnClick(Sender: TObject);
begin
  if SaveDialog1.Execute(handle) then
  begin
    PathEdit.Text:=SaveDialog1.FileName;
  end;
end;

procedure TSaveSignalForm.SaveData;
var
  dt, t, value:single;
  i:integer;
  s:csignal;
  f:file;
begin
  dt:=1/ResFreqIE.IntNum;
  for I := 0 to signals.Count - 1 do
  begin
    s:=signals.getsignal(i);
    AssignFile(f,dir+s.name+'.dat');
    Rewrite(f,1);
    // если нужна передискретизация
    if s.freqX<>ResFreqIE.IntNum then
    begin
      t:=0;
      while t<s.count do
      begin
        value:=s.gety(t);
        BlockWrite(f,value,sizeof(single));
        t:=t+dt;
      end;
    end
    else
    begin
      BlockWrite(f,cbuffsignal(s).points1d[0],sizeof(single)*s.count);
    end;
    CloseFile(f);
  end;
end;

function TSaveSignalForm.SaveMera(p_signals:cMeraFile):boolean;
begin
  signals:=p_signals;
  if signals.count<>0 then
  begin
    if Showmodal=mrok then
    begin
      SaveDialog1.FileName:=PathEdit.text;
      signals.Save(PathEdit.text);
    end;
  end
  else
    showmessage('Нет сигналов для сохранения');
end;

end.
