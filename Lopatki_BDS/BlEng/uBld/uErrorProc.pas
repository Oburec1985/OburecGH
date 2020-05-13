unit uErrorProc;

interface
uses ubldobj, dialogs, uCommonMath;

  // происходит, когда у датчика и назначенной пары разные ступени
  procedure errorSensorPair_notSameStageProc(s:cbldObj;p:cbldObj;flags:cardinal);
  // происходит, когда у датчика невозможно посчитать от какой лопатки пришел импульс
  procedure errorSensor_BladePos(s:cbldObj;flags:cardinal);
  // происходит при попытке получить у ступени отсутствующий тахо датчик
  procedure errorStage_noTaho(s:cbldObj;flags:cardinal);
  // происходит при попытке обращени€ к несуществующей ступени у датчика
  procedure errorObj_noStage(s:cbldObj; flags:cardinal);
  // происходит при попытке обращени€ к несуществующей турбине
  procedure errorObj_noTurbine(s:cbldObj; flags:cardinal);
  // у ступени не заполнены положени€ лопаток
  procedure errorStage_noBladesPos(stage:cbldObj; flags:cardinal);
  // происходит, когда у ступени не определено число лопаток
  procedure errorStage_noBlades(stage:cbldObj; flags:cardinal);
  // происходит, когда у ступени не определено число лопаток
  procedure errorSensorList_DifStage(eng:tobject;flags:cardinal);
  // происходит при попытке назначить датчику несуществующий тип
  procedure errorSensor_ErrorType(s:cbldObj;flags:cardinal);
  // происходит когда в алгоритме идет обращение к датчику с нулевым числом тиков
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
    str:='Ќа ступени '+stage.name+' не заполнена форма (расположение лопаток)';
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
    str:='” датччика '+s.name+
      ' отсутствует информаци€ дл€ вычислени€ номера лопатки (нет ступени/ или не заполнен shape)';
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
    str:='ƒатчику '+s.name+' не удаетс€ сопоставить ступень';
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
    str:='—тупени '+s.name+' не удаетс€ сопоставить турбину';
    showmessage(str);
    exit;
  end;
  if s is csensor then
  begin
    str:='ƒатчику '+s.name+' не удаетс€ сопоставить турбину';
    showmessage(str);
    exit;
  end;
  if s is cstage then
  begin
    str:='—тупени '+s.name+' не удаетс€ сопоставить турбину';
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
  str:='ƒатчик '+s.name+'и пара' +p.name + ' на разных ступен€х';
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
  str:='ступень '+s.name+' не имеет тахо датчика';
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
  str:='неправильный тип датчика '+s.name;
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
  str:='у канала датчика '+s.name+' 0 тиков';
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

// происходит, когда у ступени не определено число лопаток
procedure errorStage_noBlades(stage:cbldobj; flags:cardinal);
var
  log:clogfile;
  str:string;
begin
  str:='у ступени '+stage.name + ' не определено число лопаток';
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
  str:='датчики прив€заны к разным ступен€м';
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
