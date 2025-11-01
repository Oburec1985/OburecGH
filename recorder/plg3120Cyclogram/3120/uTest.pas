unit uTest;

interface

uses
  sysutils, graphics, urcfunc, uThresholds3120Frm, uCommonMath,
  u3120ControlObj, uControlObj, uProgramObj, uModeObj, u3120Factory;

type
  TTagRec = record
    name: string;
  end;

  PTagRec = ^TTagRec;

procedure testinit3120;
procedure testinit3120Thresholds;
procedure testinit3120ThresholdsAbs;

implementation

procedure testinit3120Thresholds;
var
  g, subg:TThresholdGroup;
  a:TAlarms;
  AlarmData:PDataRec;
  pTag:PTagRec;
  new:boolean;
  I: Integer;
  c:cControlObj;
  p:cprogramobj;
begin
  g:=TThresholdGroup.create;
  g.name:='3120Thresholds';
  ThresholdFrm.AddGroup(g);
  g.m_useSubGroups:=true;

  subG:=TThresholdGroup.create;
  subG.m_Data[0].outRange:=0;
  subG.m_Data[0].HH:=1.1;
  subG.m_Data[0].h:=1.05;
  subG.m_Data[0].L:=0.95;
  subG.m_Data[0].LL:=0.9;
  subG.m_Data[0].normalCol:=clWhite;
  subG.m_Data[0].outRangeCol:=clRed;
  subG.m_Data[0].HHCol:=clWebOrange;
  subG.m_Data[0].HCol:=clYellow;
  subG.m_Data[0].LLCol:=clWebOrange;
  subG.m_Data[0].LCol:=clYellow;
  subG.m_Data[0].outRangeCol:=clRed;
  subG.name:='M';
  p:=g_conmng.getProgram(0);
  subg.ControlTag.tagname:=p.m_stateTag.getname;
  for I := 0 to g_conmng.ControlsCount - 1 do
  begin
    c:=g_conmng.getControlObj(i);
    if c is cMNControl then
    begin
      subG.addtag(cMNControl(c).m_MtagFB.tagname,new);
      subg.m_Data[0].LvlTag:=cMNControl(c).m_Mtag.tag;
    end;
  end;
  g.m_SubGroups.Add(subG);

  subG:=TThresholdGroup.create;
  subG.m_Data[0].outRange:=0;
  subG.m_Data[0].HH:=1.1;
  subG.m_Data[0].h:=1.05;
  subG.m_Data[0].L:=0.95;
  subG.m_Data[0].LL:=0.9;
  subG.m_Data[0].normalCol:=clWhite;
  subG.m_Data[0].outRangeCol:=clRed;
  subG.m_Data[0].HHCol:=clWebOrange;
  subG.m_Data[0].HCol:=clYellow;
  subG.m_Data[0].LLCol:=clWebOrange;
  subG.m_Data[0].LCol:=clYellow;
  subG.m_Data[0].outRangeCol:=clRed;
  subG.name:='N';
  subg.ControlTag.tagname:=p.m_stateTag.getname;
  for I := 0 to g_conmng.ControlsCount - 1 do
  begin
    c:=g_conmng.getControlObj(i);
    if c is cMNControl then
    begin
      subG.addtag(cMNControl(c).m_NtagFB.tagname,new);
      subg.m_Data[0].LvlTag:=cMNControl(c).m_Ntag.tag;
    end;
  end;
  g.m_SubGroups.Add(subG);
end;

procedure testinit3120ThresholdsAbs;
var
  g, subg:TThresholdGroup;
  a:TAlarms;
  AlarmData:PDataRec;
  pTag:PTagRec;
  new:boolean;
  I: Integer;
  c:cControlObj;
  p:cprogramobj;
  m:cmodeobj;
  j: Integer;
  t:ctask;
  s:string;
begin
  ThresholdFrm.m_AlarmTag.tag:=createScalar('AlarmTag', true);
  p:=g_conmng.getProgram(0);
  for I := 0 to g_conmng.ControlsCount - 1 do
  begin
    c:=g_conmng.getControlObj(i);
    if c is cMNControl then
    begin
      g:=TThresholdGroup.create;
      g.ControlTag.tagname:=p.m_ModeIndTag.GetName;
      g.name:='M'+inttostr(i+1);
      ThresholdFrm.AddGroup(g);
      // в группу можно добавлять оба тега т.к. один все равно автоотключается в зависимости от режима
      G.addtag(cMNControl(c).m_MtagFB.tagname,new);
      G.addtag(cMNControl(c).m_NtagFB.tagname,new);
      g.m_useSubGroups:=false;
      g.setCount(6);
      for j := 0 to p.ModeCount - 1 do
      begin
        m:=p.getMode(j);
        t:=m.GetTask(i);
        g.m_Data[j].outRange:=0;
        g.m_Data[j].normalCol:=clWhite;
        g.m_Data[j].outRangeCol:=clRed;
        g.m_Data[j].HHCol:=clWebOrange;
        g.m_Data[j].HCol:=clYellow;
        g.m_Data[j].LLCol:=clWebOrange;
        g.m_Data[j].LCol:=clYellow;
        g.m_Data[j].outRangeCol:=clRed;
        g.m_Data[j].normal:=t.m_data.Task;
        if i<3 then
        begin
          g.m_Data[j].HH:=50;
          g.m_Data[j].h:=30;
          g.m_Data[j].L:=30;
          g.m_Data[j].LL:=50;
        end
        else
        begin
          g.m_Data[j].HH:=10;
          g.m_Data[j].h:=6;
          g.m_Data[j].L:=6;
          g.m_Data[j].LL:=10;
        end;
      end;
    end;
  end;
  // синхронизация с циклограммой
  for I := 0 to ThresholdFrm.m_Groups.Count - 1 do
  begin
    g:=ThresholdFrm.getGroup(i);
    c:=g_conmng.getControlObj(i);
    for j := 0 to p.ModeCount - 1 do
    begin
      m:=p.getMode(j);
      t:=m.GetTask(c.name);
      t.m_data.Mthreshold:= g.m_Data[j].HH+g.m_Data[j].normal;
      t.m_data.Nthreshold:= g.m_Data[j].HH+g.m_Data[j].normal;
    end;
  end;
end;

procedure testinit3120;
var
  c:cControlObj;
  p:cProgramObj;
  m:cmodeobj;
  mname, dsc, s, fbname:string;
  I, j: Integer;
  b:boolean;
  t:ctask;
begin
  //g_conmng.clear;
  p:=cProgramObj.create;
  p.CreateStateTag;
  p.name:='Prog_01';
  p.RepeatCount:=1;
  p.m_StartOnPlay:=true;
  p.m_enableOnStart:=true;
  g_conmng.Add(p);
  for I := 0 to 7 do
  begin
    case i of
      5:mname:=c_Break_Name;
      6:mname:=c_Turn_Name;
      7:mname:=c_Emerg_Name;
    else
      mname:='M'+inttostr(i+1);
    end;
    if i<5 then
    begin
      begin
        c:=g_conmng.createControl(mname, 'cMNControl');
        g_Marray[i]:=cmncontrol(c);
      end;
      cMNControl(c).m_Mtag.tagname:=mname+'_SetPoint_M_Nm';
      cMNControl(c).m_Ntag.tagname:=mname+'_SetPoint_N_rpm';
      if cMNControl(c).m_Mtag.tag=nil then
      begin
        cMNControl(c).m_Mtag.tag:=createScalar(cMNControl(c).m_Mtag.tagname, true);
      end;
      if cMNControl(c).m_Ntag.tag=nil then
      begin
        cMNControl(c).m_Ntag.tag:=createScalar(cMNControl(c).m_Ntag.tagname, true);
      end;
      // обратная связь по моменту
      cMNControl(c).m_MtagFB.tagname:=mname+'(v)';
      if cMNControl(c).m_MtagFB.tag=nil then
      begin
        cMNControl(c).m_MtagFB.tag:=createScalar(cMNControl(c).m_MtagFB.tagname, true);
      end;
      // обратная связь по оборотам
      //cMNControl(c).m_NtagFB.tagname:=mname+'_Nfb';
      cMNControl(c).m_NtagFB.tagname:='Fm'+inttostr(i+1);
      if cMNControl(c).m_NtagFB.tag=nil then
      begin
        cMNControl(c).m_NtagFB.tag:=createScalar(cMNControl(c).m_NtagFB.tagname, true);
      end;
      // Команда старт
      cMNControl(c).m_CmdStart.tagname:='Cmd_'+mname+'_Start';
      if cMNControl(c).m_CmdStart.tag=nil then
      begin
        cMNControl(c).m_CmdStart.tag:=createScalar(cMNControl(c).m_CmdStart.tagname, true);
      end;
      // Команда стоп
      cMNControl(c).m_CmdStop.tagname:='Cmd_'+mname+'_Stop';
      if cMNControl(c).m_CmdStop.tag=nil then
      begin
        cMNControl(c).m_CmdStop.tag:=createScalar(cMNControl(c).m_CmdStop.tagname, true);
      end;
    end
    else
    begin // создание и настройка актуаторов
      c:=g_conmng.createControl(mname, 'cActControl');
      case i of
        5: // тормоз
        begin
          mname:='SP_Position_brake';
          dsc:='Задание Положение актутораа тормоза ,в %';
          fbname:='SP_brake_fb';
        end;
        6: // Поворот
        begin
          mname:='SP_Position_turnActuators';
          dsc:='Задание Положение актуатора поворота ,в %';
          fbname:='SP_turn_fb';
        end;
        7: // Авар. передача
        begin
          mname:='SP_Position_emergencyGearActuators';
          dsc:='Задание Положение актуатора аварийной передачи ,в %';
          fbname:='SP_emerg_fb';
        end;
      end;
      c.m_Tasktag.tagname:=mname;
      if c.m_Tasktag.tag=nil then
      begin
        c.m_Tasktag.tag:=createScalar(mname, true);
      end;
      c.m_TaskTag.describe:=dsc;
      // FeedBack
      c.m_FBtag.tagname:=mname;
      if c.m_FBtag.tag=nil then
      begin
        c.m_FBtag.tag:=createScalar(fbname, true);
      end;
      c.m_FBtag.describe:='Положение актуатора аварийной передачи ,в %';
    end;
    g_conmng.Add(c);
    p.AddControl(c);
  end;
  for I := 0 to 6 do
  begin
    m:=cmodeobj.create;
    case i of
      6: m.name:='Стоп';
      else
        m.name:='Режим_'+inttostr(i+1);
    end;
    // включает бесконечный режим, пока не произойдет триггерный переход
    cmodeobj(m).Infinity:=false;
    // включает проверку выхода на режим
    cmodeobj(m).CheckThreshold:=false;
    // время в течении которого ожидается проверка выхода на режим
    cmodeobj(m).CheckLength:=0;
    // m1 по ПМИ len; M1;M2;M3;M4;M5;break;rot;emerg
    case i of // проход по режимам
      0: dsc:= '22;2045;2640;2640;35;35;100;50;100';
      1: dsc:= '32;2028;1726;1726;35;35;100;50;100';
      2: dsc:= '77;1994;1424;1424;35;35;100;50;100';
      3: dsc:= '123;1996;1004;1004;35;35;100;50;100';
      4: dsc:= '90;1996;593;593;35;35;100;50;100';
      5: dsc:= '16;1772;578;578;35;35;100;50;100';
      // режим стоп
      6: dsc:= '22;0;0;0;0;0;100;50;100';
    end;
    s:=getSubStrByIndex(dsc,';',1,0);
    // длительность режима
    m.ModeLength:=toSec(strtofloat(s),1);
    p.addmode(m);
    for j := 0 to m.TaskCount-1 do
    begin
      s:=getSubStrByIndex(dsc,';',1,j+1);
      t:=m.GetTask(j);
      t.applyed := false;
      if j<5 then
      begin
        if j=0 then
          t.m_data.ModeType:=mtN
        else
          t.m_data.ModeType:=mtM
      end;
      t.task:=strtofloat(s);
      if j=0 then // M1 по часовой
        b:=true
      else
        b:=false;
      t.m_data.forw:=b;
    end;
  end;
end;




end.
