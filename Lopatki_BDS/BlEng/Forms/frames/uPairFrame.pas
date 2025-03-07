unit uPairFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, uBaseObjPropertyFrame, ComCtrls, uBtnListView, DCL_MYOWN,
  ubldobj, ustage,upair, usensor, uBldCompProc, uBldEng, uGetSensorsForm,
  uSensorList;

type
  TPairFrame = class(TFrame)
    PairGB: TGroupBox;
    SensorsLV: TBtnListView;
    StageCountLabel: TLabel;
    StageLabel: TLabel;
    BladeLeftIE: TIntEdit;
    StageCB: TComboBox;
    SensorsNameCB: TComboBox;
    SensorNameLabel: TLabel;
    SelectSensorsBtn: TButton;
    BaseFE: TFloatEdit;
    BaseLabel: TLabel;
    procedure SelectSensorsBtnClick(Sender: TObject);
  private
    pair:cpair;
  private
    // ��������� ������ ��������� �������� � ���������
    procedure updatecombobox(obj:cbldobj);
    procedure updateSList(Sender: TObject);
    procedure ShowSensorsNames(cb:TComboBox);
  public
    procedure setobj(obj:cbldobj);
    procedure getobj(obj:cbldobj);
    constructor create(aOwner:tcomponent);override;
  end;


implementation

{$R *.dfm}
procedure TPairFrame.ShowSensorsNames(cb:TComboBox);
var
  i:integer;
  s:csensor;
begin
  cb.Clear;
  for I := 0 to pair.SensorsCount - 1 do
  begin
    s:=pair.GetSensor(i);
    cb.Items.AddObject(s.name,s);
  end;
  if pair.sensorsCount>0 then
  begin
    cb.ItemIndex:=0;
    // ���������� �������� ������
    ShowSensorsInLV(SensorsLV,pair.sensors);
  end;
end;


procedure TPairFrame.updateSList(Sender: TObject);
var
  I: Integer;
  st:cstage;
  s:csensor;
  slist:cAlgSensorList;
begin
  i:=0;
  slist:=cAlgSensorList(sender);
  // ���������� ���������� �������
  while I < slist.Count - 1 do
  begin
    if slist.GetSensor(i).sensortype=c_rot then
    begin
      slist.Delete(i);
    end;
    inc(i);
  end;
  pair.removesensors;
  for I := 0 to sList.Count - 1 do
  begin
    s:=sList.GetSensor(i);
    if s.stage=nil then
    begin
      s.stage:=pair.stage;
    end;
    // ��������� ������� ������ � ������������� �������
    if s.stage<>pair.stage then
      continue;
    pair.AddSensor(s);
  end;
  ShowSensorsNames(SensorsNameCB);
end;

procedure TPairFrame.SelectSensorsBtnClick(Sender: TObject);
var
  slist:cAlgSensorList;
begin
  if pair.eng<>nil then
  begin
    slist:=cAlgSensorList.create;
    slist.destroydata:=false;
    SelectSensorsForm.ShowModal(slist, pair.eng);
    updateSList(slist);
    slist.destroy;
  end
end;

procedure TPairFrame.setobj(obj:cbldobj);
begin
  // ����� ������� ������� ���� ���������� ����� ��������� ����
  pair.bladesleft:=bladeleftIE.IntNum;
  pair.stagename:=StageCB.Text;
  if StageCB.ItemIndex<>-1 then
    pair.stage:=cbldobj(stagecb.Items.Objects[StageCB.ItemIndex]);
end;

procedure TPairFrame.updatecombobox(obj:cbldobj);
var 
  eng:cbldeng;
  stage:cbldobj;
  i:integer;
begin
  stagecb.clear;
  eng:=obj.eng;
  for I := 0 to eng.count - 1 do
  begin
    obj:=cbldobj(eng.getobj(i));
    if obj is cstage then
    begin
      StageCB.AddItem(obj.name,obj);
    end;
    stage:=cbldobj(cpair(obj).stage);
    if stage<>nil then
      stageCB.Text:=stage.name
    else
      stageCB.ItemIndex:=0;
  end;
end;

procedure TPairFrame.getobj(obj:cbldobj);
begin
  pair:=cpair(obj);
  // ����� ������� ������� ���� ���������� ����� ��������� ����
  bladeleftIE.IntNum:=pair.bladesleft;
  if pair.sensorsCount=2 then
  begin
    BaseFE.FloatNum:=abs(pair.GetSensor(0).pos-pair.GetSensor(1).pos);
  end
  else
  begin
    BaseFE.FloatNum:=0;
  end;
  // ���������� �������� ������
  ShowSensorsInLV(SensorsLV,pair.sensors);
  // ���������� ��� �������
  updatecombobox(obj);
end;

constructor TPairFrame.create(aOwner:tcomponent);
begin
  inherited;
  initSensorsLV(SensorsLV);
end;

end.
