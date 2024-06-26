unit uMeraFile;

interface
uses
  Messages, dialogs,controls, ComCtrls, classes, SysUtils,Windows,
  uTickData, uSensor, uBaseObj, ubldeng, ubinfile, uCommonTypes,
  uVectorlist, uchan, uSetList, inifiles, uMeraSignal, uTag;

  type
  TMeraOpts = record
    // ��� ���������
    TestName:string;
    // �������� ���������
    TestDsc:string;
    // ������� ��������� ��������� �������
    freq:single;
  end;

  cMeraFile = class
  protected
    opts:TMeraOpts;
    // ��� �����
    dir,name:string;
    // ������ ����������� ��������
    // ������� ������ ���� ��������� cBaseObj
    signals:tstringlist;
    // ������ ���
    fUts:csignal;
  protected
    procedure SaveSignalToHeader(signal:cSignal; f:tinifile);
    procedure SaveTrend(signal:cSignal);
    procedure ModNames;
  public
    procedure Save;
    constructor create(p_filename:string; folder:string; p_signals:tstringlist; meraopts:tmeraopts; uts:csignal);
    //destructor destroy;
    procedure DestroySignals;
  end;

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
  c_ChanNo = 'ChanN�';
  c_Start = 'Start';
  c_Z = 'ZSize';
  c_Zstep = 'ZStep';

procedure cMeraFile.ModNames;
var
  i:integer;
begin
  if pos('.mera', name)>0 then
  begin
    dir:=extractfiledir(name)+'\';
    name:=extractfilename(name);
  end
  else
  begin
    for I := length(dir) downto 1 do
    begin
      if dir[i]='\' then
      begin
        name:=copy(dir,i+1,length(dir)-i)+'.mera';
        break;
      end;
    end;
    dir:=dir+'\';
  end;
end;

constructor cMeraFile.create(p_filename:string; folder:string;p_signals:tstringlist; meraopts:tmeraopts; uts:csignal);
begin
  dir:=folder;
  name:=p_filename;
  // ������ ����������� ��������
  signals:=p_signals;
  // ����� mera ����� (������� �������������, �������� ���������, ��� ���������)
  opts:=meraopts;
  modnames;
  fUts:=uts;
end;

procedure cMeraFile.Save;
var
  f:tinifile;
  date:tdatetime;
  datestr:string;
  i:integer;
begin
  if not DirectoryExists(dir) then
    ForceDirectories(dir);
  f:=tinifile.Create(dir+name);
  // ��� ���������
  f.WriteString(c_mainSection, c_TestName, opts.TestName);
  // �������� ���������
  f.WriteString(c_mainSection, c_Info, opts.TestDsc);
  // ����� ���������
  date:=now;
  datestr:=DateToStr(date)+' '+TimeToStr(date);
  f.WriteString(c_mainSection, c_Time, datestr);
  for I := 0 to signals.Count - 1 do
  begin
    // ��������� ������������ ����������
    SaveSignalToHeader(cSignal(signals.objects[i]),f);
    // ��������� ������
    SaveTrend(cSignal(signals.objects[i]));
  end;
  if fUts<>nil then
  begin
    // ��������� ������������ ����������
    SaveSignalToHeader(fUts,f);
    // ��������� ���
    SaveTrend(futs);
  end;
    //SaveSignalToHeader(futs,f);
  f.Destroy;
end;

procedure cMeraFile.SaveSignalToHeader(signal:cSignal; f:tinifile);
var
  t:extended;
  str:string;
begin
  if signal.WriteXY then
  begin
    // ����� ��� �������
    f.WriteString(signal.getname, 'XFile', signal.getname + '.x');
  end;
  // ����� ��� �������
  f.WriteFloat(signal.getname, c_freq, signal.freqx);
  // ������� ��� x
  f.WriteString(signal.getname, c_XUnits, signal.xunits);
  // ������� ��� Y
  f.WriteString(signal.getname, c_YUnits, signal.yunits);
  if signal.VType=c_float then
    str:='single'
  else
    str:='double';
  f.WriteString(signal.getname, c_XFormat, str);
  // ������ Y
  f.WriteString(signal.getname, c_YFormat, str);
  // k0
  f.WriteFloat(signal.getname, c_k0, signal.k0);
  // k1
  f.WriteFloat(signal.getname, c_k1, signal.k1);
  // ���
  if (fUTS<>nil) and (signal<>fUTS) then
  begin
    f.WriteString(signal.getname, 'UTS_Channel', fUTS.getname);
  end;
  // ����� ����
  t:=signal.GetT0;
  if futs<>nil then
  begin
    t:=t-cbasetag(futs.obj).offset;
  end;
  f.WriteFloat(signal.getname, c_Start, t);
  if signal.b_3d then
  begin
    f.WriteInteger(signal.getname,c_Z , round(signal.count/ signal.portionsize));
    f.WriteInteger(signal.getname,c_Zstep , signal.dZ);
  end
  else
    f.WriteInteger(signal.getname, c_Zstep, 0);
end;

procedure cMeraFile.SaveTrend(signal:cSignal);
var
  f,fx:file;
  i:integer;
  dt, x, endT, y:double;
  p2d:point2d;
  p2:point2;
begin
  AssignFile(f,dir+signal.getname+'.dat');
  Rewrite(f,1);
  if signal.WriteXY then
  begin
    AssignFile(fx,dir+signal.getname+'.x');
    Rewrite(fx,1);
  end;
  if signal.Count<1 then exit;
  dt:=1/signal.freqX;
  if signal.WriteXY or signal.b_3d then
  begin
    // ���� ������ ���������� �� ����� � �������� ������������� ��������� � �����
    for I := 0 to signal.count - 1 do
    begin
      if signal.VType=c_float then
      begin
        p2:=signal.GetP2(i);
        WriteSingle(f,p2.y);
        if not signal.b_3d then
          WriteSingle(fx,P2.x);
      end
      else
      begin
        p2d:=signal.GetP2d(i);
        WriteDouble(f,p2d.y);
        if not signal.b_3d then
          WriteDouble(fx,p2d.x);
      end;
    end;
  end
  else
  begin
    x:=signal.GetP2(0).x;
    endT:=signal.GetTEnd;
    // ����� y �������
    while x<endT do
    begin
      y:=signal.GetY(x);
      WriteSingle(f,y);
      x:=x+dt;
    end;
  end;
  // ����� ����� ������������ �������.
  CloseFile(f); // ������� ����
  if signal.WriteXY then
  begin
    CloseFile(fx);
  end;
end;

procedure cMeraFile.DestroySignals;
var
  I: Integer;
  s:csignal;
begin
  for I := 0 to signals.Count - 1 do
  begin
    s:=csignal(signals.Objects[i]);
    s.Destroy;
  end;
  if fUts<>nil then
    fUTS.Destroy;
  signals.clear;
end;

end.
