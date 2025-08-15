unit uTest;

interface

uses
  sysutils, urcfunc,
  u3120ControlObj, uControlObj, uProgramObj, uModeObj, u3120Factory;

procedure testinit3120;

implementation

procedure testinit3120;
var
  c:cControlObj;
  p:cProgramObj;
  m:cmodeobj;
  mname:string;
  I, j: Integer;
  t:ctask;
begin
  if g_conmng.ProgramCount>0 then exit;

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
      5:mname:='Торможение';
      6:mname:='Поворот';
      7:mname:='Авар. передача';
    else
      mname:='M'+inttostr(i+1);
    end;
    if i<5 then
    begin
      c:=g_conmng.createControl(mname, 'cMNControl');

      cMNControl(c).m_Mtag.tagname:=mname+'_Mtsk';
      if cMNControl(c).m_Mtag.tag=nil then
      begin
        cMNControl(c).m_Mtag.tag:=createScalar(mname+'_Mtsk', true);
      end;
      cMNControl(c).m_Ntag.tagname:=mname+'_Ntsk';
      if cMNControl(c).m_Ntag.tag=nil then
      begin
        cMNControl(c).m_Ntag.tag:=createScalar(mname+'_Ntsk', true);
      end;

      cMNControl(c).m_MtagFB.tagname:=mname+'_Mfb';
      if cMNControl(c).m_MtagFB.tag=nil then
      begin
        cMNControl(c).m_MtagFB.tag:=createScalar(mname+'_Mfb', true);
      end;
      cMNControl(c).m_NtagFB.tagname:=mname+'_Nfb';
      if cMNControl(c).m_NtagFB.tag=nil then
      begin
        cMNControl(c).m_NtagFB.tag:=createScalar(mname+'_Nfb', true);
      end;
    end
    else
    begin
      c:=g_conmng.createControl(mname, 'cControlObj');
      c.m_Tasktag.tagname:=mname+'_tsk';
      if c.m_Tasktag.tag=nil then
      begin
        c.m_Tasktag.tag:=createScalar(mname+'_tsk', true);
      end;
      if c.m_FBtag.tag=nil then
      begin
        c.m_Tasktag.tag:=createScalar(mname+'_fb', true);
      end;
    end;
    g_conmng.Add(c);
    p.AddControl(c);
  end;

  for I := 0 to 3 do
  begin
    m:=cmodeobj.create;
    case i of
      3: m.name:='Стоп';
      else
        m.name:='Режим_'+inttostr(i+1);
    end;
    // включает бесконечный режим, пока не произойдет триггерный переход
    cmodeobj(m).Infinity:=false;
    // включает проверку выхода на режим
    cmodeobj(m).CheckThreshold:=false;
    // время в течении которого ожидается проверка выхода на режим
    cmodeobj(m).CheckLength:=0;
    // длительность режима
    m.ModeLength:=10;
    p.addmode(m);
    for j := 0 to m.TaskCount - 1 do
    begin
      t:=m.GetTask(j);
      case j of
        0:t.task := j;
        1:t.task := j;
        2:t.task := j;
        3:t.task := j;
        4:t.task := j;
        5:t.task := j;
        6:t.task := j;
        7:t.task := j;
      end;
      t.applyed := false;
    end;
  end;
end;



end.
