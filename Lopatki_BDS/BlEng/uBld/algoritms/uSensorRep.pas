unit uSensorRep;

interface
uses
  classes, sysutils,Graphics,  controls, stdctrls,
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uProgressDlg,
  ubldeng, uBaseBldAlg, ustage, uBaseObj, RepODS, uturbina, PathUtils,
  usensorlist, uchart;

type
  cRepOpts = class(cbaseopts)
    repname:tstrings;
    prec:integer;
    singlefile:boolean;
  public
    constructor create;override;
  end;

  cSensorRepAlg = class(cBaseBldAlg)
  protected
    singlefile:boolean;
    repname:tstrings;
    // �������� � ������� ��������� � ����� �����
    floatPrec:integer;
    // ����� ������ � ������
    rowArray:array of integer;
    // ������ ����������� ������ � ������
    RowCounter:integer;
    // ����� ������
    rep: TRepODS;
    // ������ �������� ����� ������� ����� ����������� � ������
    rows: TIntArray;
    eng:cbldeng;
    // �������� ���������� ������
    progress:integer;
    // ����� ����� � ������
    rowcount:integer;
    PrBar:TProgresDlg;
  protected
    // ���������� ��� ������� ����������� ������� CommonSensorProc
    // ��� ���� ������ �������, ������ � ����� �������, ��������� � protected
    // ��������
    function TurnSensorProc(s:csensor):integer;override;
    function BeforeTurnSensorProc:boolean;override;
    function BadTicksProc(s:csensor;i:integer):integer;override;
    procedure CommonSensorProc(taho:csensor;sensors:cAlgSensorList);override;
    // ��������� ������. ���� ��������� ������ ���������� false
    function ProcessErrors(taho:csensor; sensors:cAlgSensorList):boolean;override;
    // ��������� ����� � ������
    procedure GenHeader(s:csensor);
    procedure SetRowColor(row:integer; color:tcolor);
    // �������� ������� � �����, j - ������ �������� �������
    procedure AddRepStr(s:csensor;j:integer);
  public
    procedure getOpts(opts:cBaseOpts);override;
  end;

  procedure GenerateReportName(cb:tcombobox; singlefile:boolean; sensors:calgsensorlist; eng:cbldeng);
  procedure GenerateReport(taho:csensor; sensors:cAlgSensorList; data:pointer);

  const

    c_yellow = $00AFE9F3;
    c_green = clLime;
    c_red = clRed;

implementation
uses
  uSensorRepForm;

const
  defaultPrec = 5;
  startRow = 9;
  // ������, ����� �������
  tab = 0;
  // ����� ������ � ������
  c_Number = 0;
  c_TickIndex =c_Number+1;
  // ����� �������� ������� � �����
  c_T = c_TickIndex + 1;
  // ����� �������� ������� � ��������
  c_TSec = c_T+1;
  // ����� �������
  c_Blade = c_TSec+1;
  // ��������� �������� � �������, �������
  c_Pos0 = c_Blade+1;
  // ��������� ��������� �������� � �������, �������
  c_dPath = c_Pos0+1;
  // ���������� � ��������
  c_Pos = c_dPath+1;
  // ��������� ���� (���������)
  c_dPos = c_Pos+1;
  // ����� �������
  c_Turn = c_dPos+1;
  // ������ �������, ����
  c_T1 = c_Turn+1;
  // ����� �������, ����
  c_T2 = c_T1+1;
  // ������ �������, ���
  c_T1sec = c_T2+1;
  // ����� �������, ���
  c_T2sec = c_T1sec+1;
  // ����� ������� � �����
  c_dT = c_T2sec+1;
  // ����� ������� � ��������
  c_dTsec = c_dT+1;
  // ������� ��������, ��
  c_Freq = c_dTsec+1;

constructor cRepOpts.create;
begin
  inherited;
  singlefile:=true;
  callBadTicksProc:=true;
end;


function cSensorRepAlg.TurnSensorProc(s:csensor):integer;
var
  j:integer;
begin
  // ������������ ����� ��������� �������������� � ������ ������� �����������
  result:=0;
  // ������������ ����� ����� � ������ �� ���
  for j:=sensorind to (sensorind+BladeCount - 1) do
  begin
    if j=sensorind then
      setflag(turnflags,c_NewTurn);
    AddRepStr(s,j);
    progress:=trunc((RowCounter/rowCount)*100);
    if (not PrBar.UpdateProgress(progress,'����� �����: '+inttostr(RowCounter))) or (progress=100) then
    begin
      result:=2;
      exit;
    end;
  end;
end;

procedure cSensorRepAlg.AddRepStr(s:csensor;j:integer);
var
  t:stickdata;
  dTurnsec:single;
  rowind, blade, dturn:integer;
  // ������ ������ � ��������
  row:integer;
begin
  if rowCounter>=rowCount-1 then
  begin
    exit;
  end;
  if (j-sensorind)<bladecount then
    EvalTurnCluster(s,j)
  else
  begin
    turncluster.blade:=-1;
    turncluster.p0:=-1;
    turncluster.path:=-1;
    turncluster.p2.y:=-1;
  end;
  // �������� ����� ������
  rowind:=startRow+rowArray[CurSensorInd];
  row:=rowArray[CurSensorInd];
  rep.Clusters.items[CurSensorInd].InsertNumber( row, rowind, c_Number+tab);
  rep.Clusters.items[CurSensorInd].InsertNumber( j, rowind, c_TickIndex+tab);
  t:=s.chan.ticks.gettick(j);
  // �������� ����� �������� � �����
  rep.Clusters.items[CurSensorInd].InsertString(TickToStr(t), rowind, c_T+tab);
  // �������� ����� �������� � ��������
  //rep.Clusters.items[CurSensorInd].InsertNumber(RoundSignificant(TickToSec(t),floatprec),rowind, c_Tsec+tab);
  rep.Clusters.items[CurSensorInd].InsertNumber(turnCluster.p2.x,rowind, c_Tsec+tab);
  // �������� ����� �������
  rep.Clusters.items[CurSensorInd].InsertNumber(turnCluster.blade,rowind, c_Blade+tab);
  // �������� ��������� �������� � �������
  rep.Clusters.items[CurSensorInd].InsertNumber(turnCluster.p,rowind, c_Pos+tab);
  // �������� ��������� ��������� �������� � �������
  rep.Clusters.items[CurSensorInd].InsertNumber(turnCluster.p0,rowind, c_Pos0+tab);
  // �������� ��������� ����
  rep.Clusters.items[CurSensorInd].InsertNumber(turncluster.path, rowind, c_dPath + tab);
  // �������� ���������� �� ���������� ����
  rep.Clusters.items[CurSensorInd].InsertNumber(turncluster.p2.y, rowind, c_dPos + tab);
  // �������� ����� �������
  rep.Clusters.items[CurSensorInd].InsertNumber(turnind, rowind, c_Turn+tab);
  // ������ �������, ����
  rep.Clusters.items[CurSensorInd].InsertString(TickToStr(t1), rowind, c_T1+tab);
  // ����� �������, ����
  rep.Clusters.items[CurSensorInd].InsertString(TickToStr(t2), rowind, c_T2+tab);
  // ������ �������, ���
  rep.Clusters.items[CurSensorInd].InsertNumber(Ticktosec(t1),rowind, c_T1sec+tab);
  // ����� �������, ���
  rep.Clusters.items[CurSensorInd].InsertNumber(Ticktosec(t2),rowind, c_T2sec+tab);
  // ����� ������� � �����
  dturn:=getdturn;
  rep.Clusters.items[CurSensorInd].InsertNumber(dturn, rowind, c_dT+tab);
  // ����� ������� � ��������
  dTurnsec:=ticktosec(dturn);
  rep.Clusters.items[CurSensorInd].InsertNumber(dTurnsec, rowind, c_dTsec+tab);
  // ������� ��������, ��
  rep.Clusters.items[CurSensorInd].InsertNumber(1/dTurnsec, rowind, c_freq+tab);
  if checkflag(turnflags,c_NewTurn) then
  begin
    setRowColor(rowind,c_Yellow);
    dropflag(turnflags,c_NewTurn);
  end
  else
  begin
    if checkflag(turnflags,c_drop) then
    begin
      setRowColor(rowind,c_Red);
    end
  end;
  inc(rowArray[CurSensorInd]);
  inc(rowCounter);
end;

function cSensorRepAlg.BadTicksProc(s:csensor;i:integer):integer;
var
  count,j:integer;
begin
  // ������������ ����� ��������� �������������� � ������ ������� �����������
  result:=0;
  count:=TickCountInTurn(t1,t2,s.chan.ticks);
  // ������������ ����� ����� � ������ �� ���
  for j:=i to (i+count-1) do
  begin
    if j=sensorind then
      setflag(turnflags,c_NewTurn);
    AddRepStr(s,j);
    progress:=trunc((RowCounter/rowCount)*100);
    if (not PrBar.UpdateProgress(progress,'����� �����: '+
        inttostr(RowCounter)))
        or (progress=100)
    then
    begin
      result:=2;
      exit;
    end;
  end;
end;

procedure cSensorRepAlg.SetRowColor(row:integer; color:tcolor);
var
  i:integer;
  colorBGR:integer;
  str:string;
begin
  colorBGR:=RGBtoBGR(color);
  str:='#'+inttohex(colorBGR,6);
  for i := Tab + c_Number to C_Freq+tab do
  begin
    rep.Clusters.Items[CurSensorInd].CellColor(row, i, str);
  end;
end;
// ���������� ���� ������ �������
function cSensorRepAlg.BeforeTurnSensorProc:boolean;
begin

end;

procedure cSensorRepAlg.getOpts(opts:cBaseOpts);
begin
  inherited;
  floatprec:=cRepOpts(opts).prec;
  repname:=cRepOpts(opts).repname;
  singlefile:=cRepOpts(opts).singlefile;
end;

procedure cSensorRepAlg.CommonSensorProc(taho:csensor;sensors:cAlgSensorList);
var
  // ��� ������� ������
  TmplRepName,
  // ��� ������
  RepPath:string;
  i,j:integer;
begin
  PrBar:=TProgresDlg.Create(nil);
  PrBar.showProgress('������������ ������');
  eng:=taho.eng;
  TmplRepName:=relativepathtoabsolute(eng.PathMng.findRepPathFile('SensorRep.ods'));
  // ���� ����� ������� ���
  if not (fileexists(TmplRepName)) then exit;
    repPath:=repname[0];
  // ������ ��������� ������ ������ � ���������
  setlength(rowArray,sensors.Count);
  for j := 0  to sensors.Count-1 do
    rowArray[j]:=0;
  // ��������� ������ ������������ ����� � ������
  setlength(rows,10);
  for j := 0  to 9 do
    rows[j]:=j;
  for I := 0 to sensors.Count - 1 do
  begin
    if not singlefile then
      repPath:=repname[i]
    else
      if i>0 then break;
    rep:=TRepODS.Create(TmplRepName,RepPath);
    rep.Open('����1');
    rep.MakeCluster(rows);
    if singlefile and (sensors.Count>1) then
    begin
      rep.AddClusters(sensors.Count-1,0);
    end;
    // ��������� ����� ������
    if singlefile then
    begin
      for j := 0 to sensors.Count - 1 do
      begin
        GenHeader(sensors.GetSensor(j));
      end;
    end
    else
      GenHeader(sensors.GetSensor(i));
    inherited;
    for j := 0 to sensors.Count - 1 do
    begin
      rep.Clusters.Items[j].FindAndReplace('<����������� ��������>', inttostr(curtaho.tickscount-1 - sstruct[j].validturns));
    end;
    rep.Close;
    rep.ExecRep;
    rep.destroy;
  end;
  PrBar.destroy;
end;

procedure GenerateReportName(cb:tcombobox; singlefile:boolean; sensors:calgsensorlist; eng:cbldeng);
var
  pathlist:tstringlist;
  I: Integer;
  str:string;
begin
  cb.Clear;
  eng.PathMng.MakeCurrentStartAppDir;
  pathlist:=eng.PathMng.getReplist;
  if singlefile then
  begin
    for I := 0 to sensors.Count - 1 do
    begin
      str:=relativepathtoabsolute(pathlist.Strings[0]+sensors.GetSensor(i).name+'.ods');
      cb.Items.Add(str);
    end;
  end
  else
  begin
    str:='';
    for I := 0 to sensors.Count - 1 do
    begin
      str:=str+sensors.GetSensor(i).name+'_';
      str:=relativepathtoabsolute(pathlist.Strings[0]+str+'.ods');
      cb.Items.Add(str);
    end;
  end;
  if cb.Items.Count>0 then
    cb.ItemIndex:=0;
end;

procedure cSensorRepAlg.GenHeader(s:csensor);
var
  str:string;
  obj:cbldobj;
  i:integer;
begin
  i:=sensorsList.GetIndex(s);
  rep.Clusters.Items[i].FindAndReplace('<��� �������>',s.name);
  // �������� ������ �� �������
  obj:=s.getTurbine;
  // ��������� ������ � �������
  if obj<>nil then
  begin
    rep.Clusters.Items[i].FindAndReplace('<��� ������������� �����>',eng.lastfile);
    rep.Clusters.Items[i].FindAndReplace('<��� �������>',cturbine(obj).name);
    rep.Clusters.Items[i].FindAndReplace('<����� ��������>',inttostr(cturbine(obj).StageCount));
  end
  else
  begin
    rep.Clusters.Items[i].FindAndReplace('<��� ������������� �����>','');
    rep.Clusters.Items[i].FindAndReplace('<��� �������>','');
    rep.Clusters.Items[i].FindAndReplace('<����� ��������>','');
  end;
  // ��������� ������ � �������
  obj:=s.stage;
  // ��������� ������ � �������
  if obj<>nil then
  begin
    rep.Clusters.Items[i].FindAndReplace('<��� �������>',cstage(obj).name);
    rep.Clusters.Items[i].FindAndReplace('<����� �������>',inttostr(cstage(obj).BladeCount));
    rep.Clusters.Items[i].FindAndReplace('<������� �������>',floattostr(cstage(obj).diametr));
  end
  else
  begin
    rep.Clusters.Items[i].FindAndReplace('<��� �������>','');
    rep.Clusters.Items[i].FindAndReplace('<����� �������>','');
    rep.Clusters.Items[i].FindAndReplace('<������� �������>','');
  end;
  // ��������� ������ � �����������
  rep.Clusters.Items[i].FindAndReplace('<��� ���� �������>',curtaho.name);
  rep.Clusters.Items[i].FindAndReplace('<����� ����� ����>',inttostr(curtaho.tickscount));
  rep.Clusters.Items[i].FindAndReplace('<��������� ���� �������>',floattostr(curtaho.pos));
  // ��������� ������ � �������
  rep.Clusters.Items[i].FindAndReplace('<��� �������>',s.name);
  rep.Clusters.Items[i].FindAndReplace('<����� �����>',inttostr(s.tickscount));
  rep.Clusters.Items[i].FindAndReplace('<��������� �������>',floattostr(s.pos));
  // ��������� ������ � �������
  rep.Clusters.Items[i].FindAndReplace('<����� ��������>',inttostr(curtaho.tickscount-1));
  rep.Clusters.Items[i].FindAndReplace('<��������� �������>',floattostr(s.pos));
  rowCount:=(EndInd-beginInd+1)*bladecount;
  // ��������� � ����� ������ ��� ���������� ���������� �� ��������
  rep.Clusters.Items[i].InsertRows(startRow, (EndInd-beginInd+1)*bladecount);
end;

procedure GenerateReport(taho:csensor; sensors:cAlgSensorList; data:pointer);
var
  rep: cSensorRepAlg;
  RepForm: TSensorRepForm;
  opts:crepopts;
begin
  opts:=cRepOpts.Create;
  opts.chart:=cchart(data);
  opts.useBladesPos:=true;
  opts.prec:=defaultprec;
  opts.callBadTicksProc:=true;
  opts.eng:=taho.eng;
  opts.stage:=cStage(sensors.stage);
  Repform:=TSensorRepForm.Create(nil);
  if Repform.ShowModal(taho,sensors,opts)=mrok then
  begin
    rep:=cSensorRepAlg.create;
    rep.getOpts(opts);
    rep.apply(taho,sensors,opts);
    rep.Destroy;
  end;
  Repform.Destroy;
  opts.Destroy;
end;

function cSensorRepAlg.ProcessErrors(taho:csensor;sensors:cAlgsensorList):boolean;
var
  l:integer;
  sensor:csensor;
begin
  if inherited ProcessErrors(taho,sensors)=false then
  begin
    result:=false;
    exit;
  end;
  result:=ProcClusterError(taho,sensors);
end;



end.
