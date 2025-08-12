unit uTest;

interface

uses
  sysutils,
  uControlObj, uProgramObj, uModeObj, u3120Factory, u3120ControlObj;

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
  p:=cProgramObj.create;
  p.name:='Prog_01';
  p.RepeatCount:=1;
  p.m_StartOnPlay:=false;
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
    c:=g_conmng.createControl(mname, 'cControlObj');
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
