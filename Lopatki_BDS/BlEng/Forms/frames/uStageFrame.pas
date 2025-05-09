unit uStageFrame;

interface

uses
  Windows, Classes, Forms,  StdCtrls, Controls, uBldObj, ImgList, ToolWin,
  ComCtrls, uBldEng, ExtCtrls, DCL_MYOWN, uBaseObjPropertyFrame,
  uTurbina, uBaseObjService, uBtnListView, uStage, ueventlist, uframeevents,
  ubldCompProc, Grids, sysutils, uEvalFirstBladeOffset, uCommonMath, uBladeForm,
  uGetSkipBladesAlg, uBldMath, uComponentServises, mathfunction, uchart, uBldGlobalStrings;

type
  TStageFrame = class(TFrame)
    StageGB: TGroupBox;
    SignalSetupPageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    BladesGB: TGroupBox;
    BladesLV: TBtnListView;
    Splitter2: TSplitter;
    SensorsGB: TGroupBox;
    SensorsSG: TStringGrid;
    ShapeGB: TGroupBox;
    ShapeLV: TBtnListView;
    StagePropertysGB: TGroupBox;
    Splitter1: TSplitter;
    BladeCountIE: TIntEdit;
    DiametrFE: TFloatEdit;
    DiametrLabel: TLabel;
    EvalShapeBtn: TButton;
    StageCountLabel: TLabel;
    TurbineCB: TComboBox;
    TurbineLabel: TLabel;
    EvalSensorSkipBtn: TButton;
    UseShapeAlgCB: TCheckBox;
    Button1: TButton;
    EvalSPos: TButton;
    procedure CfgTVChange(Sender: TObject; Node: TTreeNode);
    procedure SensorsSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure EvalShapeBtnClick(Sender: TObject);
    procedure EvalBlPos(Sender: TObject);
    procedure EvalSensorskipBtnClick(Sender: TObject);
    procedure BladesLVDblClickProcess(item: TListItem; lv: TListView);
    procedure EvalSensorPos(sender:tobject);
  private
    stage:cstage;
    eng:cBldEng;
    // ���� ��������������� ������� ��������
    editSG:boolean;
  public
    chart:cchart;
  private
    procedure ShowTurbineInCB(obj:cbldobj);
    //  ������������� ������� ��������
    procedure InitSensorsStrGrid(obj:cbldobj);
    //  ��������� ������ �� ��������������� ������� � �������
    procedure AssigneStrGrid(obj:cbldobj);
    //  ��������� ������ �� ��������������� ������� � �������
    procedure AssigneBlades(obj:cbldobj);
    // ���������� ����� ������
    procedure ShowShape(obj:cbldobj);
  public
    events:ceventlist;
  public
  public
    //  ���������� �������� ������� � �����
    procedure GetObj(obj:cbldobj);
    //  ��������� �������� ������� �� ������ � ������
    procedure SetObj(obj:cbldobj);
    constructor create(aowner:tcomponent);override;
  end;



implementation
uses
  usensor, uBldObjList, uSensorList;

{$R *.dfm}

constructor TStageFrame.create(aowner:tcomponent);
begin
  inherited;
  initBladesLV(BladesLV);
end;

procedure TStageFrame.EvalShapeBtnClick(Sender: TObject);
var
  sensor, taho:csensor;
begin
  taho:=csensor(eng.GetTaho(stage, false));
  sensor:=csensor(eng.GetObjDlg(stage,c_RootSensor));
  if sensor<>nil then
  begin
    // ���������� ������ ���������� ����� ���������
    stage.Shape.Eval(taho, sensor, stage, true,-1,-1);
    ShowShape(stage);
  end;
end;

procedure TStageFrame.EvalSensorskipBtnClick(Sender: TObject);
var
  I, coloffset, colSkip, row: Integer;
  s,t:csensor;
  slist:cAlgSensorList;
  b:boolean;
begin
  if stage.SensorsCount=0 then
    exit;
  slist:=cAlgSensorList.create;
  slist.destroydata:=false;
  for I := 0 to stage.SensorsCount - 1 do
  begin
    s:=stage.GetSensor(i);
    if s.sensortype<>c_Rot then
      slist.add(s);
    // ����������� ��������� ������� � ������� �������
    if not UseShapeAlgCB.Checked then
      s.EvalSkipBlades;
  end;
  t:=csensor(eng.GetTaho(slist.GetObj(0), false));
  if UseShapeAlgCB.Checked then
  begin
    b:=GetSkipBlades(t,slist, chart);
  end;
  if b then
  begin
    // ������ �������� �� 1-� �������
    EvalFirstBladeOffset(t,slist, chart);
    // ��������� ���������� � ���������� ��������
    coloffset:=getcolumn(SensorsSG,v_Colfirstoffset);
    colSkip:=getcolumn(SensorsSG,v_ColSkipBlades);
    for I := 0 to slist.Count - 1 do
    begin
      // 1-� ��������
      s:=slist.GetSensor(i);
      row:=getrow(SensorsSG,s.name,1);
      SensorsSG.Cells[colskip,row]:=inttostr(s.skipBlade);
      SensorsSG.Cells[coloffset,row]:=formatstr(s.firstBladeOffset,4);
    end;
    EvalSensorPos(nil);
  end;
  slist.destroy;
end;

procedure TStageFrame.EvalBlPos(Sender: TObject);
begin
  prepareBlades(stage.Shape.blades,stage.Shape.offset);
  showBladesInLV(bladeslv, stage);
end;

procedure TStageFrame.EvalSensorPos(sender:tobject);
var
  s:csensor;
  i,col,row:integer;
begin
  for I := 0 to stage.SensorsCount - 1 do
  begin
    s:=stage.GetSensor(i);
    if s.sensortype<>c_Rot then
    begin
      s.pos:=s.EvalPosition;
      // ������� �������
      col:=getcolumn(SensorsSG,v_ColSensorPos);
      row:=getrow(SensorsSG,s.name,1);
      SensorsSG.Cells[col,row]:=formatstr(s.pos,4);
    end;
  end;
end;

//  ���������� �������� ������� � �����
procedure TStageFrame.BladesLVDblClickProcess(item: TListItem; lv: TListView);
var
  strpos:string;
  pos:single;
begin
  tbtnlistview(lv).GetSubItemByColumnName(v_ColSensorPos,item,strpos);
  pos:=strtofloat(strpos);
  pos:=BladeForm.ShowModal(pos);
  tbtnlistview(lv).SetSubItemByColumnName(v_ColSensorPos,formatstr(pos,4),item);
end;

procedure TStageFrame.AssigneBlades(obj:cbldobj);
var
  I: Integer;
  pos:single;
  strpos:string;
  li:tlistitem;
begin
  for I := 0 to cStage(obj).BladeCount - 1 do
  begin
    li:=BladesLV.Items[i];
    if li=nil then
      exit;
    tbtnlistview(BladesLV).GetSubItemByColumnName(v_ColSensorPos,li,strpos);
    pos:=strtofloat(strpos);
    cStage(obj).Shape.blades[i]:=pos;
  end;
end;

procedure TStageFrame.CfgTVChange(Sender: TObject; Node: TTreeNode);
begin
  if events<>nil then
  begin
    // ���������� ��� ������ ������ ����
    events.CallAllEventsWithSender(SelectStageEvent,node.data);
  end;
end;

procedure TStageFrame.GetObj(obj:cbldobj);
begin
  eng:=obj.eng;
  stage:=cstage(obj);
  DiametrFE.FloatNum:=cstage(obj).diametr;
  BladeCountIE.IntNum:=cstage(obj).BladeCount;
  // ����������� ������������ �������
  ShowTurbineInCB(obj);
  showBladesInLV(bladeslv,cstage(obj));
  ShowShape(obj);
  // ����������� ��������
  InitSensorsStrGrid(obj);
end;

procedure TStageFrame.ShowTurbineInCB(obj:cbldobj);
var
  i:integer;
  turbine:cbldobj;
begin
  TurbineCB.Clear;
  if obj.eng<>nil then
  begin
    for I := 0 to obj.eng.count - 1 do
    begin
      turbine:=cbldobj(obj.eng.getobj(i));
      if turbine is cturbine then
      begin
        TurbineCB.AddItem(turbine.name,turbine);
      end;
      turbine:=cbldobj(cstage(obj).turbine);
      if turbine<>nil then
        TurbineCB.Text:=turbine.name
      else
        TurbineCB.itemindex:=0;
    end;
  end;
end;

//  ��������� �������� ������� �� ������ � ������
procedure TStageFrame.SetObj(obj:cbldobj);
begin
  cstage(obj).diametr:=DiametrFE.FloatNum;
  cstage(obj).BladeCount:=BladeCountIE.IntNum;
  if TurbineCB.ItemIndex>=0 then
    cstage(obj).turbine:=cbldobj(TurbineCB.Items.Objects[TurbineCB.ItemIndex]);
  // ��������������� �������
  AssigneStrGrid(obj);
  AssigneBlades(obj);
end;

procedure SetSensor(SG:TStringGrid; s:csensor; row:integer);
var
  col:integer;
begin
  // ��� �������
  col:=getcolumn(sg,v_colName);
  s.name:=sg.Cells[col,row];
  // ��� �������
  col:=getcolumn(sg,v_ColType);
  s.sensorstring:=sg.Cells[col,row];
  // ������� �������
  col:=getcolumn(sg,v_ColSensorPos);
  s.pos:=strtofloat(sg.Cells[col,row]);
  // ������� �������
  col:=getcolumn(sg,v_ColSkipBlades);
  s.skipBlade:=strtoint(sg.Cells[col,row]);
  // 1-� ��������
  col:=getcolumn(sg,v_Colfirstoffset);
  s.firstBladeOffset:=strtoFloat(sg.Cells[col,row]);
end;

procedure AddSensor(SG:TStringGrid; s:csensor; row:integer);
var
  col:integer;
begin
  // ����� ������
  col:=getcolumn(sg,v_colNum);
  sg.Cells[col,row]:=inttostr(row);
  // ��� �������
  col:=getcolumn(sg,v_colName);
  sg.Cells[col,row]:=s.name;
  // ��� �������
  col:=getcolumn(sg,v_ColType);
  sg.Cells[col,row]:=s.sensorstring;
  // ������� �������
  col:=getcolumn(sg,v_ColSensorPos);
  sg.Cells[col,row]:=formatstr(s.pos,4);
  // ������� �������
  col:=getcolumn(sg,v_Colskipblades);
  sg.Cells[col,row]:=inttostr(s.skipBlade);
  // 1-� ��������
  col:=getcolumn(sg,v_Colfirstoffset);
  sg.Cells[col,row]:=formatstr(s.firstBladeOffset,4);
end;

procedure TStageFrame.SensorsSGSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  editSG:=true;
end;

procedure TStageFrame.AssigneStrGrid(obj:cbldobj);
var
  I: Integer;
  s:csensor;
begin
  if editSG then
  begin
    for I := 1 to SensorsSG.RowCount - 1 do
    begin
      s:=cstage(obj).GetSensor(i-1);
      SetSensor(SensorsSG,s,i);
      editSG:=false;
    end;
  end;
end;

procedure TStageFrame.InitSensorsStrGrid(obj:cbldobj);
var i:integer;
begin
  SensorsSG.RowCount:=cstage(obj).SensorsCount+1;
  SensorsSG.ColCount:=6;
  // ���� ��������������� ������� ��������
  editSG:=false;
  // ������������� ������� ��������
  for I := 0 to 5 do
  begin
    case i of
      0: SensorsSG.Cells[i,0]:=v_colNum;
      1: SensorsSG.Cells[i,0]:=v_colName;
      2: SensorsSG.Cells[i,0]:=v_ColType;
      3: SensorsSG.Cells[i,0]:=v_ColSensorPos;
      4: SensorsSG.Cells[i,0]:=v_ColSkipBlades;
      5: SensorsSG.Cells[i,0]:=v_ColFirstOffset;
    end;
  end;
  //��������� �������� ���������
  for I := 1 to cstage(obj).SensorsCount do
  begin
    AddSensor(SensorsSG,cstage(obj).GetSensor(i-1),i);
  end;
end;

procedure TStageFrame.ShowShape(obj:cbldobj);
begin
  showShapeInLV(shapelv,cstage(obj));
end;



end.
