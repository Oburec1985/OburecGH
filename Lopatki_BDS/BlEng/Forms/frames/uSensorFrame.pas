unit uSensorFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uBaseObjPropertyFrame, ComCtrls, uBtnListView, DCL_MYOWN,
  ubldobj, usensor, uBaseObj, ubldCompProc;

type
  TSensorFrame = class(TFrame)
    SensorsGB: TGroupBox;
    TypeLabel: TLabel;
    OffsetLabel: TLabel;
    TypeCB: TComboBox;
    OffsetFE: TFloatEdit;
    ChunLabel: TLabel;
    ChunIE: TIntEdit;
    StateGB: TGroupBox;
    StageCB: TComboBox;
    PairsListView: TBtnListView;
    PairsLVLabel: TLabel;
    TickCountLabel: TLabel;
    TickCountIE: TIntEdit;
    StagesLabel: TLabel;
    SkipBladeIE: TIntEdit;
    SkipBladesLabel: TLabel;
    EvalSkipBladesBtn: TButton;
    TahoDivLabel: TLabel;
    TahoDivEdit: TEdit;
    procedure EvalSkipBladesBtnClick(Sender: TObject);
  private
    curobj:cbldobj;
  private
    // ������ �� �������, ������� �� ��� �� �������
    procedure updateStagesCB(obj:cbldobj);
    procedure setPropertiesFromCB(obj:cbldobj);
  public
    procedure getobj(obj:cbldobj);
    procedure setobj(obj:cbldobj);
    constructor create(aOwner:tComponent);override;
  end;

implementation
uses
  upair, ustage, uturbina;

{$R *.dfm}

procedure TSensorFrame.updateStagesCB(obj:cbldobj);
var
  i:integer;
  stage:cbldobj;
begin
  stagecb.Clear;
  if obj.eng<>nil then
  begin
    for I := 0 to obj.eng.count - 1 do
    begin
      stage:=cbldobj(obj.eng.getobj(i));
      if stage is cstage then
      begin
        StageCB.AddItem(stage.name,stage);
      end;
    end;
  end;
  stage:=cbldobj(csensor(obj).stage);
  if stage<>nil then
  begin
    stage.find(stage.name,i);
    stageCB.ItemIndex:=i;
  end
  else
  begin
    stageCB.ItemIndex:=-1;
  end;
end;

procedure TSensorFrame.setPropertiesFromCB(obj:cbldobj);
begin
  if stageCB.itemindex<>-1 then
    csensor(obj).stage:=cstage(stageCB.Items.Objects[stageCB.itemindex])
  else
    csensor(obj).stage:=nil;
end;

procedure TSensorFrame.EvalSkipBladesBtnClick(Sender: TObject);
begin
  SkipBladeIE.IntNum:=csensor(curobj).EvalSkipBlades;
end;

procedure TSensorFrame.getobj(obj:cbldobj);
var
  taho:csensor;
  stage:cstage;
begin
  curobj:=obj;
  stage:=cstage(csensor(obj).stage);
  if stage<>nil then
  begin
    taho:=stage.GetTaho;
    if taho<>nil then
    begin
      TahoDivEdit.Text:=floattostr(csensor(obj).chan.ticks.count/taho.chan.ticks.count);
    end
    else
    begin
      taho:=csensor(obj.eng.GetTaho(nil, false));
      if taho=nil then
        TahoDivEdit.Text:='�� ����������� ���� ������'
      else
        TahoDivEdit.Text:=floattostr(csensor(obj).chan.ticks.count/taho.chan.ticks.count);
    end;
  end
  else
  begin
    TahoDivEdit.Text:='�� ������������ �������';
  end;
  TypeCB.Text:=csensor(obj).sensorstring;
  OffsetFE.FloatNum:=csensor(obj).pos;
  ChunIE.IntNum:=csensor(obj).ChanNumber;
  SkipBladeIE.IntNum:=csensor(obj).skipBlade;
  TickcountIE.IntNum:=csensor(obj).tickscount;

  showChildPairsInLV(PairsListView,obj);
  updateStagesCB(obj);
end;

procedure TSensorFrame.setobj(obj:cbldobj);
begin
  csensor(obj).sensortype:=SensorStringToInt(TypeCB.Text);
  csensor(obj).pos:=OffsetFE.FloatNum;
  csensor(obj).ChanNumber:=ChunIE.IntNum;
  csensor(obj).skipBlade:=SkipBladeIE.IntNum;
  setPropertiesFromCB(obj);
end;


constructor TSensorFrame.create(aOwner:tComponent);
begin
  inherited;
  initPairsLV(PairsListView);
end;

end.
