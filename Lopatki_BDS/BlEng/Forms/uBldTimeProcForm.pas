unit uBldTimeProcForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  StdCtrls, ComCtrls, uBtnListView, Buttons, ExtCtrls, ubasebldalg, ubldobj,
  ubldeng, uBldTimeProc, uchart, uCreateTrendFrame, uDrawObj, utrend,
  ugistogram, uShapeAlg, uPairShape, CommonOptsFrame, uAlgEditFrame, uSensorList,
  uSpin, dialogs, uBaseObj, uEvalTahoAlg, uTrendAlg, uRestoreVibrationAlg,
  uTaskFrame, uAlgMng, uBldGlobalStrings;

type
  TBldTimeProcForm = class(TForm)
    CfgGB: TGroupBox;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    EditAlgListGB: TGroupBox;
    AddBtn: TSpeedButton;
    RemoveBtn: TSpeedButton;
    Splitter1: TSplitter;
    UsedAlgLV: TBtnListView;
    Splitter2: TSplitter;
    AlgNameGB: TGroupBox;
    AvailableAlgLabel: TLabel;
    UsedAlgLabel: TLabel;
    SelAlgLV: TBtnListView;
    PropertiesGB: TGroupBox;
    UpdateRateSE: TFloatSpinEdit;
    UpdateRateLabel: TLabel;
    PageControl: TPageControl;
    AlgsTabSheet: TTabSheet;
    TaskTabSheet: TTabSheet;
    AlgGB: TGroupBox;
    ScrollBox1: TScrollBox;
    ScrollBoxGB: TGroupBox;
    AlgEditFrame1: TAlgEditFrame;
    TaskFrame1: TTaskFrame;
    DtSeLabel: TLabel;
    DtSe: TFloatSpinEdit;
    PeriodLabel: TLabel;
    PeriodSE: TFloatSpinEdit;
    procedure AddBtnClick(Sender: TObject);
    procedure UsedAlgLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormShow(Sender: TObject);
    procedure RemoveBtnClick(Sender: TObject);
    procedure UsedAlgLVDblClickProcess(item: TListItem; lv: TListView);
    procedure UsedAlgLVClick(Sender: TObject);
    procedure DtSeChange(Sender: TObject);
    procedure PeriodSEChange(Sender: TObject);
  private
    eng:cbldeng;
    TProc:cBldTimeProc;
    // редактируемый чарт
    curchart:cchart;
    // выбранный объект чарта
    drawObj:cDrawObj;
    // выбранный алгоритм
    selAlg:cBaseBldAlg;
  private
  private
    procedure prepareAvailableAlg;
    // показать созданные алгоритмы
    procedure ShowPreparedAlgs;
    procedure SelectAlg(a:cbasebldalg);
    procedure SelectDrawObj(obj:cdrawobj);
    // отобразить основные свойства rt движка
    procedure ShowTProcProperties;
    procedure GetTProcProperties;
  public
    constructor create(aowner:tcomponent);override;
    procedure linc(timeProc:cBldTimeProc;e:cBldEng; ch:cchart);
    function showmodal(chart:cchart):integer;
  end;

var
  BldTimeProcForm: TBldTimeProcForm;

implementation
uses
  usensor, uProcessAlgTask;
{$R *.dfm}

procedure TBldTimeProcForm.linc(timeProc:cBldTimeProc;e:cBldEng; ch:cchart);
begin
  curchart:=ch;
  eng:=e;
  tProc:=timeproc;
  prepareAvailableAlg;
  ShowPreparedAlgs;
  ShowTProcProperties;
  TaskFrame1.linc(tproc);
  cAlgMng(TProc.algList).chart:=curchart;
end;

procedure TBldTimeProcForm.PeriodSEChange(Sender: TObject);
begin
  tproc.period:=PeriodSE.Value;
end;

procedure TBldTimeProcForm.prepareAvailableAlg;
var
  li:tlistitem;
begin
  SelAlgLV.clear;
  // добавляем алгоритм "форма венца"
  li:=SelAlgLV.items.Add;
  SelAlgLV.SetSubItemByColumnName('№', inttostr(li.Index), li);
  SelAlgLV.SetSubItemByColumnName('Алгоритм', v_sPairShape, li);
  SelAlgLV.SetSubItemByColumnName('Тип объекта', v_Sensor, li);
  // добавляем алгоритм "Статистика импульсов"
  li:=SelAlgLV.items.Add;
  SelAlgLV.SetSubItemByColumnName('№', inttostr(li.Index), li);
  SelAlgLV.SetSubItemByColumnName('Алгоритм', v_sStat, li);
  SelAlgLV.SetSubItemByColumnName('Тип объекта', v_Sensor, li);
  // добавляем алгоритм "Построить тахо"
  li:=SelAlgLV.items.Add;
  SelAlgLV.SetSubItemByColumnName('№', inttostr(li.Index), li);
  SelAlgLV.SetSubItemByColumnName('Алгоритм', v_sTaho, li);
  SelAlgLV.SetSubItemByColumnName('Тип объекта', v_Sensor, li);
  // добавляем алгоритм "восстановить сигнал"
  li:=SelAlgLV.items.Add;
  SelAlgLV.SetSubItemByColumnName('№', inttostr(li.Index), li);
  SelAlgLV.SetSubItemByColumnName('Алгоритм', v_sRestore, li );
  SelAlgLV.SetSubItemByColumnName('Тип объекта', v_Sensor, li);
  // добавляем алгоритм "тренд по лопатке"
  li:=SelAlgLV.items.Add;
  SelAlgLV.SetSubItemByColumnName('№', inttostr(li.Index), li);
  SelAlgLV.SetSubItemByColumnName('Алгоритм', v_sTrend, li );
  SelAlgLV.SetSubItemByColumnName('Тип объекта', v_Sensor, li);
  // добавляем алгоритм "Форма венца"
  li:=SelAlgLV.items.Add;
  SelAlgLV.SetSubItemByColumnName('№', inttostr(li.Index), li);
  SelAlgLV.SetSubItemByColumnName('Алгоритм', v_sShape, li );
  SelAlgLV.SetSubItemByColumnName('Тип объекта', v_Pair, li);
end;

procedure TBldTimeProcForm.RemoveBtnClick(Sender: TObject);
begin
  tproc.deleteAlg(selAlg);
  SelectAlg(nil);
  showpreparedalgs;
end;

function TBldTimeProcForm.showmodal(chart:cchart):integer;
begin
  ShowPreparedAlgs;
  ShowTProcProperties;
  //crTrendFrame.linc(chart);
  result:=inherited showmodal;
  if result=mrok then
  begin
    AlgEditFrame1.apply;
    GetTProcProperties;
  end;
end;

procedure TBldTimeProcForm.AddBtnClick(Sender: TObject);
var
  i:integer;
  li:tlistitem;
  algname:string;
  alg:cbasebldalg;
  opts:cBaseOpts;
  slist:cAlgsensorList;
begin
  li:=SelAlgLV.Selected;
  SelAlgLV.GetSubItemByColumnName('Алгоритм', li, algname);
  if algname=v_sTaho then
  begin
    alg:=cTahoAlg.create;
    alg.eng:=tproc.eng;
    alg.drawobj:=drawobj;
  end;
  if algname=v_sPairShape then
  begin
  end;
  if algname=v_sStat then
  begin
  end;
  if algname=v_sRestore then
  begin
    alg:=cRestoreAlg.create;
    alg.eng:=tproc.eng;
  end;
  if algname=v_sShape then
  begin
    alg:=cPairShape.create;
    alg.eng:=tproc.eng;
  end;
  if algname=v_sTrend then
  begin
    alg:=cTrendAlg.create;
    alg.eng:=tproc.eng;
  end;
  if algname=v_sStageShape then
  begin
  end;
  slist:=calgSensorList.create;
  slist.destroydata:=false;
  alg.sensorsList:=slist;
  alg.ownerSensorList:=true;  
  SelectAlg(alg);
  TProc.addAlg(alg);
  ShowPreparedAlgs;
end;

constructor TBldTimeProcForm.create(aowner:tcomponent);
begin
  inherited;
  //crTrendFrame:=TEditChartCfgFrame.Create(self);
  //crTrendFrame.Parent:=ChartGb;
  //crTrendFrame.onchangeObj:=onchangeobj;
end;


procedure TBldTimeProcForm.DtSeChange(Sender: TObject);
begin
  TProc.dt:=dtse.Value;
end;

procedure TBldTimeProcForm.FormShow(Sender: TObject);
begin
  WindowState:=wsMaximized;
end;

procedure TBldTimeProcForm.SelectDrawObj(obj:cdrawobj);
begin
  if drawobj<>obj then
  begin
    drawObj:=cdrawobj(obj);
    //crTrendFrame.SetSelected(drawObj);
  end;
end;

procedure TBldTimeProcForm.ShowPreparedAlgs;
var
  i:integer;
  a:cbasebldalg;
  li:tlistitem;
begin
  UsedAlgLV.Clear;
  for I := 0 to TProc.AlgCount - 1 do
  begin
    a:=TProc.Getalg(i);
    // добавляем алгоритм "Статистика импульсов"
    li:=UsedAlgLV.items.Add;
    li.Data:=a;
    UsedAlgLV.SetSubItemByColumnName('№', inttostr(li.Index), li);
    UsedAlgLV.SetSubItemByColumnName('Алгоритм', a.name, li);
    if a.task<>nil then
      UsedAlgLV.SetSubItemByColumnName('Задача', a.task.name, li);
  end;
end;

procedure TBldTimeProcForm.UsedAlgLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  i:integer;
  li:tlistitem;
  algname:string;
  alg:cbasebldalg;
  opts:cBaseOpts;
begin
  li:=UsedAlgLV.Selected;
  if li=nil then exit;
  UsedAlgLV.GetSubItemByColumnName('Алгоритм', li, algname);
  alg:=TProc.getalg(algname);
  // обновить фрейм с опциями алгоритма
  SelectAlg(alg);
  // обновить фрейм с редактируемым рисуемым объектом
  SelectDrawObj(alg.drawObj);
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


procedure TBldTimeProcForm.UsedAlgLVClick(Sender: TObject);
var
  i:integer;
  li:tlistitem;
  algname:string;
  alg:cbasebldalg;
  opts:cBaseOpts;
begin
  li:=GetListItem(sender);
  //li:=UsedAlgLV.Selected;
  if li<>nil then
  begin
    if li=nil then exit;
    UsedAlgLV.GetSubItemByColumnName('Алгоритм', li, algname);
    alg:=TProc.getalg(algname);
    // обновить фрейм с опциями алгоритма
    SelectAlg(alg);
    // обновить фрейм с редактируемым рисуемым объектом
    SelectDrawObj(alg.drawObj);
  end;
end;

procedure TBldTimeProcForm.UsedAlgLVDblClickProcess(item: TListItem;
  lv: TListView);
var
  i:integer;
  li:tlistitem;
  task:ctask;
begin
  if selalg=nil then exit;
  task:=ctask(tproc.TaskList.getobjdlg);
  if task<>nil then
  begin
    task.thread.addalg(selalg);
    for I := 0 to UsedAlgLV.items.Count - 1 do
    begin
      li:=UsedAlgLV.Items[i];
      if li.Data=selalg then
      begin
        if selalg.task<>nil then
          UsedAlgLV.SetSubItemByColumnName('Задача',selalg.task.name,li)
        else
          UsedAlgLV.SetSubItemByColumnName('Задача','',li)
      end;
    end;
  end;
end;

procedure TBldTimeProcForm.SelectAlg(a:cbasebldalg);
begin
  selAlg:=a;
  AlgEditFrame1.setAlg(a);
end;

procedure TBldTimeProcForm.ShowTProcProperties;
begin
  UpdateRateSE.Value:=tproc.ViewTime;
  PeriodSE.Value:=tproc.period;
  DTSE.Value:=tproc.dt;
end;

procedure TBldTimeProcForm.GetTProcProperties;
begin
  tproc.ViewTime:=UpdateRateSE.Value;
end;

end.
