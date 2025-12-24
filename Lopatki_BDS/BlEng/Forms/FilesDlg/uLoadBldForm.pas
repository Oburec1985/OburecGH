unit uLoadBldForm;

interface

uses
  Windows, Messages, Classes, Forms, uBldeng, ubldCompProc, sysutils, uBldGlobalStrings,
  ExtCtrls, StdCtrls, ComCtrls, uBtnListView, Controls, usensor, uchan, uBaseObjService;

type
  TLoadBldDlg = class(TForm)
    CommonGB: TGroupBox;
    SelectModeRG: TRadioGroup;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    SensorsGB: TGroupBox;
    SensorsLV: TBtnListView;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    blfile:tobject;
  private
    procedure AddSensorsToLV(lv:tbtnlistview;sensor:cSensor;chan:cchan);
    procedure showbldfile(f:tobject);
    // при сли€нии конфигураций, данные из файла переписываютс€ в
    // соответствующие каналы
    procedure MergeCfg;
    // «агружает каналы с данными и линкует к двигу. —тарые каналы удал€ет
    procedure NewCfg;
  public
    function showmodal(bldfile:tobject; show:boolean):integer;
  end;

var
  LoadBldDlg: TLoadBldDlg;

const
  c_MergeCfg = 0;
  c_NewCfg = 1;

implementation
uses uBldfile, ubldobj;


{$R *.dfm}

procedure TLoadBldDlg.AddSensorsToLV(lv:tbtnlistview;sensor:cSensor;chan:cchan);
var
  li:tlistitem;
  index:integer;
begin
  li:=lv.items.add;
  // ≈сли ступень всего одна, но датчикам ступени не сопоставлены, то относим
  // все датчики к одной ступени
  lv.SetSubItemByColumnName(c_ColNum,inttostr(sensor.ChanNumber),li);
  lv.SetSubItemByColumnName(v_ColImpulsNum,inttostr(chan.ticksCount),li);
  lv.SetSubItemByColumnName(c_ColName,sensor.Name,li);
  lv.SetSubItemByColumnName(c_ColSensorPos,floattostr(sensor.pos),li);
  // вписать тип датчика
  lv.SetSubItemByColumnName(c_ColType,sensor.sensorstring,li);
end;

procedure TLoadBldDlg.showbldfile(f:tobject);
var
  I, index, number: Integer;
  sensor:csensor;
  chan:cchan;
begin
  caption:=cbldfile(blfile).filename;
  SensorsLV.Clear;
  for I := 0 to cbldfile(blfile).sensors.Count - 1 do
  begin
    sensor:=cbldfile(blfile).getsensor(i);
    number:=sensor.channumber;
    chan:=cbldfile(blfile).findchan(number);
    AddSensorsToLV(sensorslv,sensor,chan);
  end;
end;

procedure TLoadBldDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

procedure TLoadBldDlg.FormShow(Sender: TObject);
begin
  showbldfile(blfile);
end;

procedure TLoadBldDlg.MergeCfg;
var
  bld:cBldFile;
  chan, engChan:cchan;
  i:integer;
  s,s2:csensor;
begin
  bld:=cBldFile(blfile);
  // переписываем датчики
  for I := 0 to bld.sensors.count - 1 do
  begin
    s:=csensor(bld.sensors.getobj(i));
    s2:=csensor(bld.eng.getobj(s.name));
    if s2<>nil then
    begin
      s.destroy;
    end
    else
      bld.eng.Add(bld.sensors.getobj(i));
  end;
  // переписываем каналы
  for I := 0 to bld.channels.Count - 1 do
  begin
    chan:=bld.getchan(i);
    engChan:=cchan(bld.eng.findchan(chan.chan));
    if engchan<>nil then
      engChan.destroy;
    bld.eng.addchan(chan);
  end;
end;

procedure TLoadBldDlg.NewCfg;
var
  bld:cBldFile;
  chan, engChan:cchan;
  i:integer;
begin
  bld:=cBldFile(blfile);
  bld.eng.clear;
  MergeCfg;
end;

function TLoadBldDlg.showmodal(bldfile:tobject; show:boolean):integer;
var bld:cBldFile;
begin
  blfile:=bldfile;
  bld:=cBldFile(bldfile);
  result:=0;
  if show then
  begin
    result:=inherited showmodal;
  end
  else
  begin
    SelectModeRG.itemindex:=c_MergeCfg;
    result:=mrok;
  end;
  if result=mrok then
  begin
    case SelectModeRG.itemindex of
      c_MergeCfg:
      begin
        MergeCfg;
      end;
      c_NewCfg:
      begin
        newCfg;
      end;
    end;
    bld.destroychannels:=false;
    bld.destroysensors:=false;
  end
  else
  begin
    bld.destroychannels:=true;
    bld.destroysensors:=true;
  end;
end;

end.
