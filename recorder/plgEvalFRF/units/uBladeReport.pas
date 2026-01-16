unit uBladeReport;

interface
uses
  windows, classes, dialogs, sysutils, variants,
  uDBObject, ubaseobj,
  pathutils, uPathMng,
  u2dmath, uCommonMath, uCommonTypes, uspmband, uExcel;

type

  cExtremum = class
  public
    Index: Integer; // Индекс элемента в исходном массиве Y
    Value: Double;  // Значение экстремума (найденное Y-значение)
    Freq: Double;  // частота экстремума
    error: Double;  // отклонение от центральной частоты
    BandNum:integer; // в полосе № (-1 если не попал в полосу)
    // главный экстремум в полосе
    Main,
    // в допуске
    InTol:boolean;
    NumInBand:integer; // номер экстремума внут*ри той же полосы
    decrement:double;
    m_b:tSpmBand;
  public
    constructor create;
    destructor destroy;
  end;
  // список найденных экстремумов на линии для сравненияс
  // l: tlist;
  function CheckExtremList(l:tlist; bands:blist):boolean;
  // создать подробный отчет
  procedure Buildreport; overload;
  // путь к шаблону
  procedure Buildreport(tmpl:string; hideexcel:boolean);overload;
  procedure BuildReportOtk(tmpl, name:string; hideexcel:boolean; toneCount:integer; blCount:integer);


implementation
uses
  uBladeDb;


{ TExtremum1d }
constructor cExtremum.create;
begin
  m_b:=nil;
  BandNum:=-1;
  Main:=false;
  NumInBand:=-1;
end;

destructor cExtremum.destroy;
begin

end;

function CheckExtremList(l:tlist; bands:blist):boolean;
var
  I, bnum: Integer;
  e:cExtremum;
begin
  bnum:=0;
  result:=true;
  for I := 0 to l.Count - 1 do
  begin
    e:=cExtremum(l.Items[i]);
    if e.InTol then
    begin
      if bnum=e.BandNum then
      begin
        inc(bnum);
        continue;
      end;
    end;
    // если попался экстремум не в допуске или какая то полоса не заполнена экстремумом
    result:=false;
    break;
  end;
end;


procedure Buildreport;
var
  r0, i, j, r, c: integer;
  b: tspmband;
  extr: PExtremum1d;
  date: TDateTime;
  res: boolean;
  rng: olevariant;
  str, str1, str2, repPath: string;
  minmax: point2d;
  v: double;
  turb: cTurbFolder;
  stage: cStageFolder;
  blade: cBladeFolder;
begin
  if VarIsEmpty(E) then
  begin
    // if not CheckExcelRun then
    begin
      CreateExcel;
      VisibleExcel(true);
    end;
  end;
  turb := g_mbase.SelectTurb;
  stage := g_mbase.SelectStage;
  blade := g_mbase.SelectBlade;
  repPath := turb.getFolder + 'Report.xlsx';
  if fileexists(repPath) then
  begin
    if not IsExcelFileOpen(repPath) then
    begin
      OpenWorkBook(repPath);
      ClearExcelSheet(E,1,false);
    end
  end
  else
  begin
    AddWorkBook;
    AddSheet('Page_01');
  end;
  r0 := GetEmptyRow(1, 1, 2);
  SetCell(1, r0, 2, 'Турбина:');
  SetCell(1, r0, 3, turb.ObjType);
  SetCell(1, r0, 4, 'Ступень:');
  SetCell(1, r0, 5, stage.m_sn);
  inc(r0);
  SetCell(1, r0, 2, 'Число лопаток:');
  SetCell(1, r0, 3, stage.BlCount);
  inc(r0);
  SetCell(1, r0, 2, 'Лопатка');
  SetCell(1, r0, 3, 'Band');
  SetCell(1, r0, 4, 'A1');
  SetCell(1, r0, 5, 'F1');
  // проход по формам (полосам)
  blade := nil;
  for i := 0 to stage.BlCount - 1 do
  begin
    inc(r0);
    blade := cBladeFolder(stage.GetNext(blade));
    if i=0 then
      c:=blade.ToneCount;
    SetCell(1, r0, 2, blade.name);
    // c - число тонов
    for j := 0 to c - 1 do
    begin
      str := getSubStrByIndex(blade.m_resStr, ';', 1, j);
      // f1..f2
      str1 := getSubStrByIndex(str, '_', 1, 0);
      SetCell(1, r0, 3, str1);
      // A
      str1 := getSubStrByIndex(str, '_', 1, 1);
      // F
      str2 := getSubStrByIndex(str, '_', 1, 2);
      SetCell(1, r0, 4, strtofloatext(str1));
      SetCell(1, r0, 5, strtofloatext(str2));
      if blade.m_res = 1 then
      begin
        rng := GetRangeObj(1, point(r0, 2), point(r0, 5));
        rng.Interior.Color := RGB(255, 165, 0); // Оранжевый цвет;
      end;
    end;
  end;
  SaveWorkBookAs(repPath);
  CloseWorkBook;
  CloseExcel;
end;

procedure Buildreport(tmpl: string; hideexcel:boolean);
var
  r0, i, j, r,col, c, c2: integer;
  b: tspmband;
  extr: PExtremum1d;
  date: TDateTime;
  res: boolean;
  rng, rng2, rng3: olevariant;
  str, str1, str2, repPath: string;
  tp:tpoint;
  p3:point3d;
  minmax: point2d;
  v: double;
  turb: cTurbFolder;
  stage: cStageFolder;
  blade: cBladeFolder;
begin
  KillAllExcelProcesses;
  if tmpl='' then
  begin
    tmpl:=g_mbase.root.Absolutepath+'Template\Report_tmpl.xlsx';
  end;
  if VarIsEmpty(E) then
  begin
    // if not CheckExcelRun then
    begin
      CreateExcel;
      VisibleExcel(true);
    end;
  end;
  turb := g_mbase.SelectTurb;
  if fileexists(tmpl) then
  begin
    if not IsExcelFileOpen(tmpl) then
    begin
      OpenWorkBook(tmpl);
    end;

    stage := g_mbase.SelectStage;
    blade := g_mbase.SelectBlade;

    rng:=GetRange(1,'c_Sketch');
    rng.value:=blade.m_ObjType;
    rng:=GetRange(1,'c_BlCount');
    rng.value:=stage.BlCount;
    rng:=GetRange(1,'c_ToneCount');
    c:=rng.value;
    rng:=GetRange(1,'c_ToneCount2');
    c2:=rng.value;

    rng.value:=blade.ToneCount;
    rng:=GetRange(1,'c_Tone');
    rng2:=GetRange(1,'c_Start');
    // заполняем тоны в таблице лопаток (с позиции Start)
    for I := 0 to blade.ToneCount - 1 do
    begin
      SetCell(1, rng.Row-1, rng.Column+i, i+1);
      p3:=blade.Tone(i);
      // тоны в таблице с c_Tone
      SetCell(1, rng.Row, rng.Column+i, p3.x);
      SetCell(1, rng.Row+1,rng.Column+i, p3.y);
      // тоны в таблице с c_start
      SetCell(1, rng2.Row-1,rng2.Column+2+i*3, p3.x);
      SetCell(1, rng2.Row-1,rng2.Column+4+i*3, p3.y);
    end;
    rng:=GetRange(1,'c_Type');
    rng.value:=turb.m_ObjType;
    rng:=GetRange(1,'c_Stage');
    rng.value:=stage.StageNum;
    rng:=GetRange(1,'c_decr');
    // проход по лопаткам; rng2 - ячейка c_Start
    for I := 0 to stage.BlCount - 1 do
    begin
      blade:=stage.getblade(i);
      SetCell(1, rng2.Row+i,rng2.Column+1, blade.m_sn);
      // проход по тонам
      for j := 0 to blade.ToneCount - 1 do
      begin
        str := getSubStrByIndex(blade.m_resStr, ';', 1, j);
        // numBand
        str2 := getSubStrByIndex(str, '_', 1, 4);
        //if str2<>'0' then
        //  continue;
        // F
        str2 := getSubStrByIndex(str, '_', 1, 2);
        r:=rng2.Row+i;
        col:=rng2.Column+2+j*3;
        SetCell(1, r,col, strtofloatext(str2));
        // декремент
        str2 := getSubStrByIndex(str, '_', 1, 3);
        col:=rng.Column+j;
        SetCell(1, r, col, strtofloatext(str2));
      end;
      if blade.m_res=2 then
      begin
        SetCell(1, rng.Row+i,rng.Column+blade.ToneCount, 'годен');
      end
      else
      begin
        if blade.m_res=1 then
        begin
          rng3 := GetRangeObj(1, point(rng2.row, rng2.column),
                                point(rng2.row, rng.column+1));
          rng3.Interior.Color := RGB(255, 165, 0); // Оранжевый цвет;
          SetCell(1, rng2.Row+i, rng.Column+ // rng - столбец декремент
                                 1, 'не годен');
        end
        else
        begin
          SetCell(1, rng2.Row+i, rng.Column+ // rng - столбец декремент
                                 1, 'не испытана');
        end;
      end;
    end;
    repPath := ExtractFileDir(turb.getFolder) + '\Report.xlsx';
    SaveWorkBookAs(repPath);
    if hideexcel then
    begin
      CloseWorkBook;
      CloseExcel;
    end;
  end
  else
  begin
    showmessage('Не найден шаблон '+ tmpl);
  end;
end;

procedure BuildReportOtk(tmpl, Name:string; hideexcel:boolean; toneCount:integer; blCount:integer);
var
  r0, i, j, r, col, c: integer;
  date: TDateTime;
  rng, rng2: olevariant;
  str, repPath: string;
  p3, lp3:point3d;
  tol, v: double;
  er:boolean;

  turb: cTurbFolder;
  stage: cStageFolder;
  blade: cBladeFolder;
begin
  KillAllExcelProcesses;
  if tmpl='' then
  begin
    tmpl:=g_mbase.root.Absolutepath+'Template\шаблон ОТК.xlsx';
  end;
  if VarIsEmpty(E) then
  begin
    // if not CheckExcelRun then
    begin
      CreateExcel;
      VisibleExcel(true);
    end;
  end;
  turb := g_mbase.SelectTurb;
  if fileexists(tmpl) then
  begin
    if not IsExcelFileOpen(tmpl) then
    begin
      OpenWorkBook(tmpl);
    end;
    stage := g_mbase.SelectStage;
    blade := g_mbase.SelectBlade;
    tol:=blade.GetTolerance(0);

    rng:=GetRange(1,'c_type');
    rng.value:=turb.ObjType;

    rng:=GetRange(1,'c_date');
    date:=now;
    rng.value:=FormatDateTime('dd.mm.yyyy hh:nn:ss', date);
    rng:=GetRange(1,'c_start');
    // заполняем тоны в таблице лопаток (с позиции Start)
    for I := 0 to stage.ChildCount - 1 do
    begin
      blade:=stage.GetBlade(i);
      r:=i div blCount;
      c:=i mod blCount;
      SetCell(1, rng.Row+r, rng.Column+c, blade.m_sn);
      for j := 0 to toneCount - 1 do
      begin
        p3:=blade.Tone(j);
        lp3:=getBand(p2d(p3.x,p3.y), blade, tol, er);
        // Y - частота тона
        if lp3.y>0 then
        begin
          SetCell(1, rng.Row+r+j+1, rng.Column+c+j+1, lp3.y);
          if er then
          begin
            rng2:=GetRangeObj(1,
                              point(rng.Row+r+j+1, rng.Column+c+j+1),
                              point(rng.Row+r+j+1, rng.Column+c+j+1));
            rng2.Interior.Color := RGB(255, 165, 0); // Оранжевый цвет;
          end;
        end;
      end;
    end;
    repPath := ExtractFileDir(turb.getFolder) + '\ReportOTK.xlsx';
    SaveWorkBookAs(repPath);
    if hideexcel then
    begin
      CloseWorkBook;
      CloseExcel;
    end;
  end;
end;


end.
