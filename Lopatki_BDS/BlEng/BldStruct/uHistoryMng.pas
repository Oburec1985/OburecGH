unit uHistoryMng;

interface
uses
  classes, sysutils, ualarms, uTag, uEventList, ubldtimeproc, ubldeng,
  uAlarmsHistoryForm, uBldEngEventTypes, forms, IBDatabase,
  IBCustomDataSet, uBldPathMng, dialogs;

type

  cHistoryMng = class
  protected
    alarms:cAlarmMng;
    eng:cbldeng;
    tproc:cbldTimeproc;
    // �������� ������ � ��
    fActive:boolean;
    InitDataBase:boolean;
  public
    dataset:TIBDataSet;
    database:tibdatabase;
    Transaction:tibtransaction;
  protected
    procedure createDataBase;
    procedure createevents;
    procedure destroyevents;
    procedure OnAlarm(sender:tobject);
    procedure AddAlarm(a:calarm;time:tDateTime);overload;
    procedure AddAlarm(a:calarm);overload;
  protected
    procedure setactive(b:boolean);
  public
    procedure linc(engine:cbldeng);
    destructor destroy;
    constructor create;
  public
    // �������� ������ ������ � ��
    property Active:boolean read fActive write SetActive;
  end;

implementation

constructor cHistoryMng.create;
begin
  factive:=true;
  InitDataBase:=false;
end;

destructor cHistoryMng.destroy;
begin
  destroyevents;
  if AlarmsHistoryBase<>nil then
    AlarmsHistoryBase.Destroy;
  if InitDataBase then
  begin
    dataset.Destroy;
    database.Destroy;
    transaction.Destroy;
  end;
end;

procedure cHistoryMng.OnAlarm(sender:tobject);
begin
  if fActive then
    AddAlarm(calarm(sender));
end;

procedure cHistoryMng.createevents;
begin
  alarms.Events.AddEvent('cHistoryMng OnAlarm',e_OnChangeAlarm,OnAlarm);
end;

procedure cHistoryMng.destroyevents;
begin
  if alarms is cAlarmMng then
  begin
    if alarms.events is cEventList then
      alarms.Events.removeEvent(OnAlarm,e_OnChangeAlarm);
  end;
end;

procedure cHistoryMng.createDataBase;
var
  path:cbldpathmng;
  str:string;
begin
  // �������� ����� ���� ������
  AlarmsHistoryBase:=TAlarmsHistoryBase.Create(nil);

  path:=eng.PathMng;
  // ����� ���� ������
  str:=path.findCfgPathFile('DB.FDB');
  if str='' then
  begin
    eng.getmessage('���� ���� ������ DD.fdb �� ������',c_errorMessage);
    exit;
  end;
  Transaction:=TIBTransaction.Create(nil);;

  database:=tibDataBase.Create(nil);
  if not fileexists(str) then
  begin
    showmessage('file not found '+str);
    exit;
  end;
  database.DatabaseName:='localhost:'+str;
  database.loginprompt:=false;
  database.DefaultTransaction:=Transaction;
  database.Params.Clear;
  database.Params.Add('user_name=sysdba');
  database.Params.Add('password=masterkey');
  database.Params.Add('lc_ctype=WIN1251');

  Transaction.DefaultDatabase:=database;

  dataset:=TIBDataSet.Create(nil);
  dataset.Database:=database;
  dataset.Transaction:=Transaction;
  dataset.InsertSQL.Text := 'Insert into ALARMS_TBL (NUM,NAME,DSC,THRESHOLD,'+
  'ONTIME,OFFTIME,STATE,TAGNAME,TAGDSC,TAGVALUE) Values (:NUM,:NAME,:DSC,'+
  ':THRESHOLD,:ONTIME,:OFFTIME,:STATE,:TAGNAME,:TAGDSC,:TAGVALUE)';
  dataset.SelectSQL.Text := 'select * from ALARMS_TBL';
  dataset.RefreshSQL.Text := 'select * from ALARMS_TBL where NUM = :OLD_NUM';
  dataset.DeleteSQL.Text := 'delete from alarms_tbl where NUM = :OLD_NUM';
  dataset.GeneratorField.Generator:='GEN_ALARMS_TBL_ID';
  dataset.GeneratorField.Field:='NUM';
  dataset.Open;

  AlarmsHistoryBase.Linc(eng,self);
  AlarmsHistoryBase.DataSource1.DataSet:=dataset;

  InitDataBase:=true;
end;

procedure cHistoryMng.linc(engine:cbldeng);
begin
  eng:=engine;
  tproc:=cbldtimeproc(eng.timeProc);
  alarms:=cAlarmMng(tproc.alarms);
  //createDataBase;
  createevents;
end;

procedure cHistoryMng.AddAlarm(a:calarm;time:tDateTime);
var
  onDateStr,onTimeStr,offDateStr,offTimeStr:string;
  i:smallint;
begin
  a.settime(time);
  if a.enabled then
    i:=1
  else
    i:=0;
  dataset.insert;
  dataset.FieldByName('NAME').AsString := a.name;
  dataset.FieldByName('DSC').AsString := a.dsc;
  dataset.FieldByName('ONTIME').AsDateTime := a.ontime;
  dataset.FieldByName('OFFTIME').AsDateTime := a.offtime;
  dataset.FieldByName('THRESHOLD').Asfloat := a.threshold;
  dataset.FieldByName('STATE').AsInteger := i;
  dataset.FieldByName('TAGNAME').AsString := a.source.name;
  dataset.FieldByName('TAGDSC').AsString := cbasetag(a.source).dsc;
  dataset.FieldByName('TAGVALUE').AsFloat := a.tagvalue;
  dataset.post;
  Transaction.commitretaining;
end;

procedure cHistoryMng.AddAlarm(a:calarm);
var
  date:tdatetime;
begin
  date:=now;
  addalarm(a,now);
end;

procedure cHistoryMng.setactive(b:boolean);
begin
  fActive:=b;
end;

end.
