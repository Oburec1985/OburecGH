unit uErrorProc;

interface
uses ubldobj, dialogs, uCommonMath;

  // ����������, ����� � ������� � ����������� ���� ������ �������
  procedure errorSensorPair_notSameStageProc(s:cbldObj;p:cbldObj;flags:cardinal);
  // ����������, ����� � ������� ���������� ��������� �� ����� ������� ������ �������
  procedure errorSensor_BladePos(s:cbldObj;flags:cardinal);
  // ���������� ��� ������� �������� � ������� ������������� ���� ������
  procedure errorStage_noTaho(s:cbldObj;flags:cardinal);
  // ���������� ��� ������� ��������� � �������������� ������� � �������
  procedure errorObj_noStage(s:cbldObj; flags:cardinal);
  // ���������� ��� ������� ��������� � �������������� �������
  procedure errorObj_noTurbine(s:cbldObj; flags:cardinal);
  // � ������� �� ��������� ��������� �������
  procedure errorStage_noBladesPos(stage:cbldObj; flags:cardinal);
  // ����������, ����� � ������� �� ���������� ����� �������
  procedure errorStage_noBlades(stage:cbldObj; flags:cardinal);
  // ����������, ����� � ������� �� ���������� ����� �������
  procedure errorSensorList_DifStage(eng:tobject;flags:cardinal);
  // ���������� ��� ������� ��������� ������� �������������� ���
  procedure errorSensor_ErrorType(s:cbldObj;flags:cardinal);
  // ���������� ����� � ��������� ���� ��������� � ������� � ������� ������ �����
  procedure errorTicksCount_ErrorType(s:cbldObj;flags:cardinal);

implementation
uses usensor, ustage, uLogFile, ubldeng;

procedure errorStage_noBladesPos(stage:cbldObj; flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  if stage is cstage then
  begin
    str:='�� ������� '+stage.name+' �� ��������� ����� (������������ �������)';
    if checkflag(flags,c_ShowMessage) then
    begin
      showmessage(str);
    end;
    if checkflag(flags,c_LogMessage) then
    begin
      log:=stage.eng.logFile;
      log.addErrorMes(str);
    end;
  end;
end;

procedure errorSensor_BladePos(s:cbldObj;flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  if s is csensor then
  begin
    str:='� �������� '+s.name+
      ' ����������� ���������� ��� ���������� ������ ������� (��� �������/ ��� �� �������� shape)';
    if checkflag(flags,c_ShowMessage) then
    begin
      showmessage(str);
    end;
    if checkflag(flags,c_LogMessage) then
    begin
      log:=s.eng.logFile;
      log.addErrorMes(str);
    end;
  end;
end;

procedure errorObj_noStage(s:cbldObj; flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  if s is csensor then
  begin
    str:='������� '+s.name+' �� ������� ����������� �������';
    if checkflag(flags,c_ShowMessage) then
    begin
      showmessage(str);
    end;
    if checkflag(flags,c_LogMessage) then
    begin
      log:=s.eng.logFile;
      log.addErrorMes(str);
    end;
  end;
end;

procedure errorObj_noTurbine(s:cbldObj; flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  if s is cstage then
  begin
    str:='������� '+s.name+' �� ������� ����������� �������';
    showmessage(str);
    exit;
  end;
  if s is csensor then
  begin
    str:='������� '+s.name+' �� ������� ����������� �������';
    showmessage(str);
    exit;
  end;
  if s is cstage then
  begin
    str:='������� '+s.name+' �� ������� ����������� �������';
    showmessage(str);
    exit;
  end;
  if checkflag(flags,c_LogMessage) then
  begin
    log:=s.eng.logFile;
    log.addErrorMes(str);
  end;
end;

procedure errorSensorPair_notSameStageProc(s:cbldObj;p:cbldObj;flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  str:='������ '+s.name+'� ����' +p.name + ' �� ������ ��������';
  if checkflag(flags,c_ShowMessage) then
  begin
    showmessage(str);
  end;
  if checkflag(flags,c_LogMessage) then
  begin
    log:=s.eng.logFile;
    log.addErrorMes(str);
  end;
end;

procedure errorStage_noTaho(s:cbldObj;flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  str:='������� '+s.name+' �� ����� ���� �������';
  if checkflag(flags, c_ShowMessage) then
  begin
    showmessage(str);
  end;
  if checkflag(flags,c_LogMessage) then
  begin
    log:=s.eng.logFile;
    log.addErrorMes(str);
  end;
end;

procedure errorSensor_ErrorType(s:cbldObj;flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  str:='������������ ��� ������� '+s.name;
  if checkflag(flags, c_ShowMessage) then
  begin
    showmessage(str);
  end;
  if checkflag(flags,c_LogMessage) then
  begin
    log:=s.eng.logFile;
    log.addErrorMes(str);
  end;
end;

procedure errorTicksCount_ErrorType(s:cbldObj;flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  str:='� ������ ������� '+s.name+' 0 �����';
  if checkflag(flags, c_ShowMessage) then
  begin
    showmessage(str);
  end;
  if checkflag(flags,c_LogMessage) then
  begin
    log:=s.eng.logFile;
    log.addErrorMes(str);
  end;
end;

// ����������, ����� � ������� �� ���������� ����� �������
procedure errorStage_noBlades(stage:cbldobj; flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  str:='� ������� '+stage.name + ' �� ���������� ����� �������';
  if checkflag(flags, c_ShowMessage) then
  begin
    showmessage(str);
  end;
  if checkflag(flags,c_LogMessage) then
  begin
    log:=stage.eng.logFile;
    log.addErrorMes(str);
  end;
end;

procedure errorSensorList_DifStage(eng:tobject;flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  str:='������� ��������� � ������ ��������';
  if checkflag(flags, c_ShowMessage) then
  begin
    showmessage(str);
  end;
  if checkflag(flags,c_LogMessage) then
  begin
    log:=cbldeng(eng).logFile;
    log.addErrorMes(str);
  end;
end;

end.
