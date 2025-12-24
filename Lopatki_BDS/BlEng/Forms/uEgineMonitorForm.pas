unit uEgineMonitorForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uComponentServises,
  StdCtrls, uBtnListView, ComCtrls, uBldEng, uBaseObjService, uProcessAlgTask,
  ubldtimeproc, uFileThread, ubldEngEventTypes, uTurbina, ubldGlobalStrings,
  uDataThread;

type
  TEngineMonitorForm = class(TForm)
    CfgLabel: TLabel;
    CfgEdit: TEdit;
    DataLabel: TLabel;
    DataEdit: TEdit;
    DataFileListLV: TBtnListView;
    DataFileListLabel: TLabel;
    Label1: TLabel;
    TaskLV: TBtnListView;
    procedure FormCreate(Sender: TObject);
  private
    eng:cBldEng;
  private
    procedure CreateEvents;
    procedure ShowTasks;
    procedure ShowDataFiles;
    procedure initLV;
    procedure UpdateTasks(sender:tobject);
    procedure UpdateDataFileList(sender:tobject);
    procedure OnDataProc(sender:tobject);    
    procedure OnLoadCfg(sender:tobject);
    procedure OnLoadData(sender:tobject);
    procedure OnAddID(sender:tobject);
  public
    procedure linc(p_eng:cbldeng);
  end;

var
  EngineMonitorForm: TEngineMonitorForm;



implementation


{$R *.dfm}

procedure TEngineMonitorForm.FormCreate(Sender: TObject);
begin
  formstyle:=fsstayontop;
end;

procedure TEngineMonitorForm.initLV;
var
  col:tlistcolumn;
begin
  TaskLV.Columns.Clear;
  // №
  col:=TaskLV.Columns.Add;
  col.Caption:=c_ColNum;
  // Имя задачи
  col:=TaskLV.Columns.Add;
  col.Caption:=c_ColName;
  // время обновления (период потока)
  col:=TaskLV.Columns.Add;
  col.Caption:=v_UpdateTime;
  // размер кадра
  col:=TaskLV.Columns.Add;
  col.Caption:=c_Time;
  // Тахо датчик
  col:=TaskLV.Columns.Add;
  col.Caption:=v_Rot;
  // Время когда был обработан замер
  col:=TaskLV.Columns.Add;
  col.Caption:=v_colProcTime;
  // инициализация списка файлов
  DataFileListLV.Columns.Clear;
  // №
  col:=DataFileListLV.Columns.Add;
  col.Caption:=c_ColNum;
  // Имя
  col:=DataFileListLV.Columns.Add;
  col.Caption:=c_ColName;
  // Время когда был обработан замер
  col:=DataFileListLV.Columns.Add;
  col.Caption:=v_colProcTime;
end;

procedure TEngineMonitorForm.ShowTasks;
var
  I: Integer;
  t:cTask;
  li:tlistitem;
  tproc:cbldtimeproc;
begin
  tasklv.clear;
  tproc:=cbldtimeproc(eng.timeProc);
  for I := 0 to tproc.TaskList.count - 1 do
  begin
    t:=ctask(tproc.TaskList.getobj(i));
    li:=tasklv.Items.add;
    li.data:=t;
    TaskLV.setsubitembycolumnname(c_ColNum,inttostr(i),li);
    TaskLV.setsubitembycolumnname(c_ColName,t.name,li);
    // Обрабатываемый интервал
    TaskLV.setsubitembycolumnname(c_Time,floattostr(t.Thread.dT),li);
    // период
    TaskLV.setsubitembycolumnname(v_UpdateTime,
                                 floattostr(t.Thread.period),li);
    // тахо
    if t.Thread.taho<>nil then
      TaskLV.setsubitembycolumnname(v_Rot,
                                   t.Thread.taho.name,li);
  end;
  LVChange(TaskLV);
end;

procedure TEngineMonitorForm.ShowDataFiles;
var
  I: Integer;
  li:tlistitem;
  FileLoader:cFileThread;
  id:cid;
begin
  DataFileListLV.clear;
  FileLoader:=cFileThread(eng.GetDataThread('cFileThread'));
  for I := 0 to FileLoader.m_idList.count - 1 do
  begin
    id:=FileLoader.m_idList.GetID(i);
    li:=DataFileListLV.Items.add;
    li.Data:=id;
    DataFileListLV.setsubitembycolumnname(c_ColNum,inttostr(i),li);
    DataFileListLV.setsubitembycolumnname(c_ColName,id.fName,li);
    DataFileListLV.setsubitembycolumnname(v_colProcTime,TimeToStr(id.time),li);
  end;
  LVChange(DataFileListLV);
end;

procedure TEngineMonitorForm.OnAddID(sender:tobject);
var
  I: Integer;
  li:tlistitem;
  FileLoader:cFileThread;
  id:cid;
begin
  FileLoader:=cFileThread(eng.GetDataThread('cFileThread'));
  i:=FileLoader.m_idList.count - 1;
  id:=FileLoader.m_idList.GetID(i);
  li:=DataFileListLV.Items.add;
  li.Data:=id;
  DataFileListLV.setsubitembycolumnname(c_ColNum,inttostr(i),li);
  DataFileListLV.setsubitembycolumnname(c_ColName,id.fName,li);
  DataFileListLV.setsubitembycolumnname(v_colProcTime,TimeToStr(id.time),li);
end;

procedure TEngineMonitorForm.CreateEvents;
begin
  eng.Events.AddEvent('EngMonitorF_OnLoadCfg',E_OnEngLoadCfg, OnLoadCfg);
  eng.Events.AddEvent('EngMonitorF_OnLoadData',E_OnEngLoadData, OnLoadData);
  eng.Events.AddEvent('EngMonitorF_OnDataProc',E_OnEngDataProc, OnDataProc);
  eng.Events.AddEvent('EngMonitorF_OnDataProc',E_OnEngAddFile, OnAddID);
end;

procedure TEngineMonitorForm.linc(p_eng:cbldeng);
begin
  initLV;
  eng:=p_eng;
  createevents;
  ShowTasks;
  ShowDataFiles;
  OnLoadCfg(nil);
  OnLoadData(nil);
end;

procedure TEngineMonitorForm.OnLoadCfg(sender:tobject);
begin
  CfgEdit.Text:=eng.curCfg;
end;

procedure TEngineMonitorForm.OnLoadData(sender:tobject);
var
  t:cturbine;
begin
  DataEdit.text:=eng.lastfile;
end;

procedure TEngineMonitorForm.UpdateTasks(sender:tobject);
begin

end;


procedure TEngineMonitorForm.OnDataProc(sender:tobject);
var
  li:tlistitem;
  fileloader:cFilethread;
  id:cid;
begin
  FileLoader:=cFileThread(eng.GetDataThread('cFileThread'));
  if FileLoader.curID>0 then
  begin
    li:=DataFileListLV.Items[FileLoader.curID-1];
    id:=FileLoader.m_IDList.GetId(FileLoader.curID-1);
    DataFileListLV.SetSubItemByColumnName(v_colProcTime,
                   TimeToStr(id.time),li);
  end;
end;

procedure TEngineMonitorForm.UpdateDataFileList(sender:tobject);
begin

end;

end.
