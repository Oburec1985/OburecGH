unit uBladeReport;

interface
uses
  windows, classes, dialogs, sysutils, variants,
  uDBObject, ubaseobj,
  pathutils, uPathMng,
  uBladeDb, uChart, graphics,
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

  RepSignal = class
  public
    // cExtremum list
    m_BandExtremums:tlist;
    m_name:string;
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
  procedure BuildReportOtk(tmpl, name:string; hideexcel:boolean; toneCount:integer; blCount:integer;
              p_bandlist:blist);

procedure SaveBladeReport(repname, meraFileName: string; slist:tlist; bands:blist;
                      chart:cchart; bl: cBladeFolder; hideExcel:boolean);


implementation


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
  r0, i, j, r,col, c, c2, tCount: integer;
  b: tspmband;
  extr: PExtremum1d;
  date: TDateTime;
  res: boolean;
  rng, rng2, rng3: olevariant;
  str, str1, str2, repPath: string;
  tp:tpoint;
  p3, lp3:point3d;
  minmax: point2d;
  v: double;
  turb: cTurbFolder;
  stage: cStageFolder;
  blade: cBladeFolder;
  err:boolean;
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
    if blade.ToneCount<c then
      tCount:=blade.ToneCount
    else
      tCount:=c;
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
      for j := 0 to tCount - 1 do
      begin
        p3:=blade.Tone(j); //p3.z - допуск
        //lp3: z - демпфирование; y - частота тона (0 если не нашли)
        lp3:=getBand(p2d(p3.x,p3.y), blade, p3.z, err);
        r:=rng2.Row+i;
        col:=rng2.Column+2+j*3;
        SetCell(1, r, col, lp3.y);
        if err or (lp3.y=0) then
        begin
          rng3 := GetRangeObj(1, point(r, col), point(r, col));
          if blade.m_res=1 then
            rng3.Interior.Color := RGB(255, 165, 0); // Оранжевый цвет;
        end;
        // декремент
        col:=rng.Column+j;
        // демпфирование
        SetCell(1, r, col, lp3.z);
      end;
      if blade.m_res=2 then
      begin
        SetCell(1, rng.Row+i,rng.Column+tCount, 'годен');
      end
      else
      begin
        if blade.m_res=1 then
        begin
          rng3 := GetRangeObj(1, point(rng2.row+i, rng2.column),
          // tCount - число тонов в протоколе
                                point(rng2.row+i, rng.column+tCount));
          rng3.Interior.Color := RGB(255, 165, 0); // Оранжевый цвет;
          SetCell(1, rng2.Row+i, rng.Column+tCount // rng - столбец декремент
                                 , 'не годен');
        end
        else
        begin
          SetCell(1, rng2.Row+i, rng.Column+tCount, 'не испытана');
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

procedure BuildReportOtk(tmpl, Name:string;
                         hideexcel:boolean;
                         toneCount:integer;
                         blCount:integer; // сколько лопаток в строку
                         p_bandlist:blist);
var
  r0, i, j, r, col, c,
  // количество колонок на лопатку
  colWide: integer;
  date: TDateTime;
  rng, rng2: olevariant;
  str, repPath: string;
  p3, lp3:point3d;
  tol, v: double;
  er:boolean;

  b:tSpmBand;
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
    if not CheckVarObj(rng) then
    begin
      showmessage('не найден регион c_type в шаблоне');
    end;
    rng.value:=turb.ObjType;

    rng:=GetRange(1,'c_date');
    if not CheckVarObj(rng) then
    begin
      showmessage('не найден регион c_date в шаблоне');
    end;
    date:=now;
    rng.value:=FormatDateTime('dd.mm.yyyy hh:nn:ss', date);

    rng:=GetRange(1,'c_name');
    if not CheckVarObj(rng) then
    begin
      showmessage('не найден регион c_type в шаблоне');
    end;
    rng.value:=Name;

    if blCount=0 then
    begin
      rng:=GetRange(1,'c_bladeCount');
      if not CheckVarObj(rng) then
      begin
        blCount:=1;
      end
      else
        blCount:=rng.value;
    end;

    rng:=GetRange(1,'c_start');
    if not CheckVarObj(rng) then
    begin
      showmessage('не найден регион c_start в шаблоне');
    end;
    rng2:=GetRange(1,'c_weight');
    if not CheckVarObj(rng2) then
    begin
      showmessage('не найден регион c_weight в шаблоне');
    end;
    colWide:=rng2.column-rng.column+1;
    // заполняем тоны в таблице лопаток (с позиции Start)

    for I := 0 to stage.ChildCount - 1 do
    begin
      blade:=stage.GetBlade(i);
      r:=i div blCount;
      c:=i mod blCount;
      SetCell(1, rng.Row+r, rng.Column+c*colWide, blade.m_sn);
      SetCell(1, rng.Row+r, rng.Column+c*colWide+colWide-2, blade.m_weight);
      for j := 0 to toneCount - 1 do
      begin
        b:=p_bandlist.getBand(j);
        if i=0 then
        begin
          b.stats.minF:=-1;
          b.stats.maxF:=-1;
        end;
        p3:=blade.Tone(j);
        lp3:=getBand(p2d(p3.x,p3.y), blade, tol, er);
        if lp3.y<>0 then
        begin
          if b.stats.minF=-1 then
            b.stats.minF:=lp3.y
          else
          begin
            if lp3.y<b.stats.minF then
              b.stats.minF:=lp3.y;
          end;
          if b.stats.maxF=-1 then
            b.stats.maxF:=lp3.y
          else
          begin
            if lp3.y>b.stats.maxF then
              b.stats.maxF:=lp3.y;
          end;
        end;

        // Y - частота тона
        if lp3.y>0 then
        begin
          SetCell(1, rng.Row+r, rng.Column+j+1+c*colWide, lp3.y);
          if er then
          begin
            rng2:=GetRangeObj(1,
                              point(rng.Row+r, rng.Column+j+1+c*colWide),
                              point(rng.Row+r, rng.Column+j+1+c*colWide));
            rng2.Interior.Color := RGB(255, 165, 0); // Оранжевый цвет;
          end;
        end
        else
        begin
          SetCell(1, rng.Row+r, rng.Column+j+1+c*colWide, '-');
        end;
      end;
    end;
    rng2:=GetRange(1,'c_tones');
    rng:=GetRange(1,'c_tones_fact');
    if not CheckVarObj(rng2) then
    begin
      showmessage('не найден регион c_tones в шаблоне');
    end
    else
    begin
      for I := 0 to p_bandlist.Count - 1 do
      begin
        b:=p_bandlist.getband(i);
        SetCell(1, rng2.Row+i, rng2.Column, b.m_f1);
        SetCell(1, rng2.Row+i, rng2.Column+2, b.m_f2);
        SetCell(1, rng.Row+i, rng.Column, b.stats.minF);
        SetCell(1, rng.Row+i, rng.Column+2, b.stats.maxF);
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



procedure SaveBladeReport(repname, meraFileName: string; slist:tlist; bands:blist;
                      chart:cchart; bl: cBladeFolder; hideExcel:boolean);
var
  r0, i, j, k, r,r2, c: integer;
  b: tspmband;
  extr: cExtremum;
  s:RepSignal;
  date: TDateTime;
  res: boolean;
  rng, rng2, sh: olevariant;
  str, repPath: string;
  minmax: point2d;
  v, v1, d: double;
  find:boolean;
  pict:tbitmap;
  m_ReportBmp:TBitmap;
begin
  KillAllExcelProcesses;
  if not CheckVarObj(E) then
  begin
    if not CheckExcelRun then
    begin
      CreateExcel;
      VisibleExcel(true);
    end;
  end;

  if fileexists(repname) then
  begin
    if not IsExcelFileOpen(repname) then
    begin
      OpenWorkBook(repname);
    end
    else
    begin
      VisibleExcel(true);
    end;
  end
  else
  begin
    AddWorkBook;
    AddSheet('Page_01');
  end;
  // в пятом столбце строки идут заполненные подряд
  //r0 := GetEmptyRow(1, 1, 5);
  //sh:=E.ActiveWorkbook.Worksheets['Page_01'];
  GetSheetDimensions('Page_01', r0, c );
  inc(r0);
  SetCell(1, r0, 2, 'Blade:');
  SetCell(1, r0, 3, bl.m_sn);
  SetCell(1, r0, 4, 'Чертеж:');
  SetCell(1, r0, 5, bl.ObjType);
  SetCell(1, r0, 6, 'MeraFile:');
  SetCell(1, r0, 7, meraFileName);

  inc(r0);
  SetCell(1, r0, 4, 'Time:');
  date := now;
  SetCell(1, r0, 5, DateToStr(date));
  SetCell(1, r0 + 1, 5, TimeToStr(date));
  r := r0 + 2;
  c := 2;

  for i := 0 to slist.count - 1 do
  begin
    s := repsignal(slist.Items[i]);
    str := s.m_name;
    SetCell(1, r - 1, c, str);
    SetCell(1, r, c, 'Band');
    SetCell(1, r, c + 1, 'A1');
    SetCell(1, r, c + 2, 'F1');
    SetCell(1, r, c + 3, 'Dekr');
    SetCell(1, r, c + 4, 'NumBand');
    SetCell(1, r, c + 5, 'Error, %');
    SetCell(1, r, c + 6, 'Res');

    // проход по формам (полосам)
    if s.m_BandExtremums.Count=0 then exit;
    for j := 0 to s.m_BandExtremums.Count - 1 do
    begin
      extr := cExtremum(s.m_BandExtremums.items[j]);
      b := extr.m_b;
      if b<>nil then
      begin
        str:=floattostr(b.m_f1) + '..' + floattostr(b.m_f2);
        SetCell(1, r + 1 + j, c + 4, extr.NumInBand+1);
        SetCell(1, r + 1 + j, c + 5, extr.error);
        if extr.intol then
        begin
          SetCell(1, r + 1 + j, c + 6, 'Годен');
        end
        else
        begin
          rng := GetRangeObj(1, point(r + 1 + j, c), point(r + 1 + j, c + 6));
          rng.Interior.Color := RGB(255, 165, 0); // Оранжевый цвет;
          SetCell(1, r + 1 + j, c + 6, 'Не годен');
        end;
      end
      else
      begin
        str:='0..0';
      end;
      // полоса
      SetCell(1, r + 1 + j, c, str);
      v1 := extr.Freq;
      v := extr.Value;
      d := extr.decrement;
      SetCell(1, r + 1 + j, c + 1, v);
      SetCell(1, r + 1 + j, c + 2, v1);
      SetCell(1, r + 1 + j, c + 3, d);
    end;
    c := c + 7;
  end;
  k:=0;
  r2:=r+j;
  // заполняем не найденые полосы
  for I := 0 to bands.Count - 1 do
  begin
    b:=bands.getband(i);
    find:=false;
    for j := 0 to s.m_BandExtremums.Count - 1 do
    begin
      extr := cextremum(s.m_BandExtremums.Items[j]);
      if extr.m_b=b then
      begin
        find:=true;
        break;
      end;
    end;
    if not find then
    begin
      // полоса
      inc(k);
      rng2:=getRangeObj(1, point(r2+k, 2), point(r2+k, 2+3));
      rng2.Interior.Color := RGB(255, 165, 0); // Оранжевый цвет;
      SetCell(1, r2+k, 2,  floattostr(b.m_f1) + '..' + floattostr(b.m_f2));
      SetCell(1, r2+k, 2 + 1, 0);
      SetCell(1, r2+k, 2 + 2, 0);
      SetCell(1, r2+k, 2 + 3, 0);
    end;
  end;
  // разметка заголовка
  rng := GetRangeObj(1, point(r, 2), point(r, c - 1));
  // c_Excel_GrayInd = 15;
  rng.Interior.ColorIndex := 15;
  rng.Font.Bold := true;
  // ставим сетку всего блока
  rng := GetRangeObj(1, point(r, 2), point(r + s.m_BandExtremums.Count +k, c - 1));
  SetRangeBorder(rng);

  // ставим картинку
  rng := GetRangeObj(1, point(r, 3+6), point(r + s.m_BandExtremums.Count +k, c - 1+1+6));
  m_ReportBmp:=chart.getBitmap;
  SetBmpToExcel(rng, m_ReportBmp);
  m_ReportBmp.free;
  SaveWorkBookAs(repname);
  if hideExcel then
  begin
    CloseWorkBook;
    CloseExcel;
  end;
end;


{ RepSignal }

constructor RepSignal.create;
begin
end;

destructor RepSignal.destroy;
begin
end;

end.
