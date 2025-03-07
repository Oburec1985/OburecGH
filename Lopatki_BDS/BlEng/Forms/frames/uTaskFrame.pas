unit uTaskFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, utaskmng, uEventTypes, uComponentServises,
  StdCtrls, ExtCtrls, ImgList, ComCtrls, ToolWin, uBtnListView, uSpin, uBldGlobalStrings,
  uBaseObjService, uProcessAlgTask, Controls, uBaseBldAlg, uBldTimeProc, usensor;

type
  TTaskFrame = class(TFrame)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Splitter1: TSplitter;
    ToolBar: TToolBar;
    AddTagBtn: TToolButton;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    TaskLV: TBtnListView;
    AlgLV: TBtnListView;
    TaskPropertiesGB: TGroupBox;
    tahoLabel: TLabel;
    SelectSensorsBtn: TButton;
    TahoCB: TComboBox;
    FrameTimeSE: TFloatSpinEdit;
    FrameTimeLabel: TLabel;
    Button1: TButton;
    procedure TaskLVClick(Sender: TObject);
    procedure SelectSensorsBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure AddTagBtnClick(Sender: TObject);
  private
    tproc:cbldTimeProc;
    curtask:ctask;
  private
    procedure InitTaskLV;
    procedure InitAlgLV;
    procedure CreateEvents;
    procedure destroyEvents;
    // ��� ������ ������ � �� ��������� �������� ��������� ������
    procedure UpdateTask(task:ctask);
    // ���������� �������� � ��������
    procedure UpdateTaskLV;
    procedure OnAlgDelete(sender:tobject);
  public
    constructor create(aowner:tcomponent);override;
    procedure linc(timeproc:cbldtimeproc);
  end;

implementation


{$R *.dfm}
procedure TTaskFrame.InitTaskLV;
var
  col:tlistcolumn;
begin
  // �
  col:=TaskLV.Columns.Add;
  col.Caption:=v_ColNum;
  // ��� ������
  col:=TaskLV.Columns.Add;
  col.Caption:=v_ColName;
  // ����� ���������� (������ ������)
  col:=TaskLV.Columns.Add;
  col.Caption:=v_UpdateTime;
  // ������ �����
  col:=TaskLV.Columns.Add;
  col.Caption:=v_Time;
  // ���� ������
  col:=TaskLV.Columns.Add;
  col.Caption:=v_Rot;
end;

procedure TTaskFrame.InitAlgLV;
var
  col:tlistcolumn;
begin
  // �
  col:=AlgLV.Columns.Add;
  col.Caption:=v_ColNum;
  // ��������
  col:=AlgLV.Columns.Add;
  col.Caption:=v_ColAlgName;
end;

procedure TTaskFrame.UpdateTask(task:ctask);
var
  I: Integer;
  a:cbasebldalg;
  li:tlistitem;
begin
  curtask:=task;
  AlgLV.clear;
  if task<>nil then
  begin
    for I := 0 to task.Thread.AlgCount - 1 do
    begin
      li:=AlgLV.items.add;
      li.data:=a;
      a:= task.Thread.getalg(i);
      AlgLV.setsubitembycolumnname(v_ColNum,inttostr(i),li);
      AlgLV.setsubitembycolumnname(v_ColAlgName,a.name,li);
    end;
    Frametimese.Value:=task.Thread.dT;
    if task.Thread.taho<>nil then
    begin
      TahoCB.Items.AddObject(task.Thread.taho.name,task.Thread.taho);
      TahoCB.ItemIndex:=0;
    end;
    LVChange(Tasklv);
  end;
end;

procedure TTaskFrame.UpdateTaskLV;
var
  I: Integer;
  t:cTask;
  li:tlistitem;
begin
  tasklv.clear;
  for I := 0 to tproc.TaskList.count - 1 do
  begin
    t:=ctask(tproc.TaskList.getobj(i));
    li:=tasklv.Items.add;
    li.data:=t;
    TaskLV.setsubitembycolumnname(v_ColNum, inttostr(i),li);
    TaskLV.setsubitembycolumnname(v_ColName, t.name,li);
    // �������������� ��������
    TaskLV.setsubitembycolumnname(v_Time, floattostr(t.Thread.dT),li);
    // ������
    TaskLV.setsubitembycolumnname(v_UpdateTime,
                                 floattostr(t.Thread.period),li);
    // ����
    if t.Thread.taho<>nil then
      TaskLV.setsubitembycolumnname(v_Rot,
                                   t.Thread.taho.name,li);
  end;
  if tproc.TaskList.count<>0 then
    UpdateTask(ctask(TaskLV.items[0].data))
  else
    UpdateTask(ctask(nil));
end;

procedure TTaskFrame.AddTagBtnClick(Sender: TObject);
var
  t:ctask;
begin
  t:=cTask.create;
  tproc.TaskList.Add(t);
  t.Thread.linc(TPROC.feng);
  UpdateTaskLV;
end;

procedure TTaskFrame.Button1Click(Sender: TObject);
begin
  curtask.thread.dt:=FrameTimeSE.Value;
  curtask.thread.taho:=csensor(TahoCB.Items.Objects[TahoCB.itemindex]);
  UpdateTaskLV;
end;

constructor TTaskFrame.create(aowner:tcomponent);
begin
  inherited;
  InitTaskLV;
  InitAlgLV;
end;

procedure TTaskFrame.linc(timeproc:cbldtimeproc);
begin
  tproc:=timeproc;
  UpdateTaskLV;
  CreateEvents;
end;

procedure TTaskFrame.SelectSensorsBtnClick(Sender: TObject);
var
  taho:csensor;
begin
  if curtask=nil then exit;
  taho:=csensor(curtask.Thread.eng.GetTaho(nil,true));
  if taho<>nil then
  begin
    tahocb.Clear;
    TahoCB.Items.AddObject(taho.name, taho);
    TahoCB.ItemIndex:=0;
  end;
end;

function GetListItem(sender:TObject):TListItem;
var P,P1:TPoint;
    y:integer;
    li:TListItem;
begin
  GetCursorPos(P);
  P1:=TBtnListView(sender).ScreenToClient(P);
  ScreenToClient(TBtnListView(sender).Handle,P);
  y:=p.y;
  Result:=TListView(Sender).GetItemAt(TListView(Sender).TopItem.Position.X,Y);
end;


procedure TTaskFrame.TaskLVClick(Sender: TObject);
var
  li:tlistitem;
begin
  li:=GetListItem(tasklv);
  if li<>nil then
    UpdateTask(ctask(li.data));
end;

procedure TTaskFrame.CreateEvents;
begin
  if tproc.alglist<>nil then
  begin
    tproc.alglist.Events.AddEvent('TTaskFrame_OnChangeAlgsList',E_OnDestroyObject,OnAlgDelete);
  end;
end;

procedure TTaskFrame.destroyEvents;
begin
  if tproc.alglist<>nil then
  begin
    tproc.alglist.Events.removeEvent(OnAlgDelete,E_OnDestroyObject);
  end;
end;

procedure TTaskFrame.OnAlgDelete(sender:tobject);
begin
  UpdateTask(curtask);
end;


end.
