unit uConfigForm;

interface

uses
  Windows, SysUtils, ComCtrls, forms, Controls, Classes, StdCtrls,
  uBtnListView, uFormEditListItem, dialogs,uMyMath, upair, uLfmFile,
  ubldfile, uBldMath, ubldservice, DCL_MYOWN, umyTypes_, ubldturnmath,
  uTreeStageCfg;
type

  TConfigForm = class(TForm)
    GroupBox1: TGroupBox;
    SensorsLV: TBtnListView;
    CancelBtn: TButton;
    OkBtn: TButton;
    GroupBox2: TGroupBox;
    GroupBox6: TGroupBox;
    Label23: TLabel;
    EndFE: TFloatEdit;
    StartFE: TFloatEdit;
    Label22: TLabel;
    EvalShapeBtn: TButton;
    TabControl: TPageControl;
    Rotor1: TTabSheet;
    Label1: TLabel;
    StageName1: TLabel;
    Label7: TLabel;
    BladesListView1: TBtnListView;
    bladeCountE1: TIntEdit;
    StageNameEdit1: TEdit;
    TahoCBox1: TComboBox;
    GroupBox3: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    SensorsCBox1: TComboBox;
    PosFE1: TFloatEdit;
    Rotor2: TTabSheet;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    BladesListView2: TBtnListView;
    bladeCountE2: TIntEdit;
    StageNameEdit2: TEdit;
    TahoCBox2: TComboBox;
    GroupBox4: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    SensorsCBox2: TComboBox;
    PosFE2: TFloatEdit;
    Rotor3: TTabSheet;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    BladesListView3: TBtnListView;
    bladeCountE3: TIntEdit;
    StageNameEdit3: TEdit;
    TahoCBox3: TComboBox;
    GroupBox5: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    SensorsCBox3: TComboBox;
    PosFE3: TFloatEdit;
    LoadCfgBtn: TButton;
    OpenDialog: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure EvalShapeBtnClick(Sender: TObject);
    procedure SensorsLVDblClickProcess(item: TListItem; lv: TListView);
    procedure LoadCfgBtnClick(Sender: TObject);
  private
    blfile: cBldFileGen;
    stages: tstringlist; // Ступени
    sensors: TStringList; // датчики
  private
    // Перенести данные формы в BldFile
    procedure ChangeStageName(oldname,newname:string);
    // Перенести данные формы в BldFile
    procedure updateBldFileByForm;
    // Отобразить форму массив значений в BladesListView
    procedure ShowBladesOffset(shape:cpoints2;lv:tBtnListView);
    // Процедура заполняет stringlist "sensors" датчиками,
    // ключом является номер канала
    procedure CreateSensors;
    // Процедура заполняет stringlist "sensors" датчиками,
    // ключом является номер канала
    procedure DeleteSensors;
    // Переносит данные из SensorsListView в датчик номер канала которого
    // сопоставляется по ключу (запись в колонке номер канала) с
    // listitem-ом под номером itemindex
    procedure ChangeSensor(itemindex:integer);
    // Получить ссылку на выбранный в таблице датчик
    function GetSelectedSensor:cSensor;
    // Проверка заполнения таблицы датчиков на соответствие ступеней
    function CheckSensorLV:boolean;
    procedure UpdateStageComboBox;
    // Обновить вид формы в соответствии с bldFile-ом
    procedure UpdateForm;
    procedure FillStageByBlFile;
    // Отобразить конфигурацию ступеней в фрейме treeView
    procedure ShowConfig;
  public
    function showmodal(bldfile:cbldfilegen):integer;
  end;
var
  ConfigForm:TConfigForm;

implementation

{$R *.dfm}

procedure TConfigForm.ShowConfig;
begin

end;

procedure TConfigForm.ChangeStageName(oldname,newname:string);
var li:tlistitem;
    len,i:integer;
    str:string;
begin
  len:=SensorsLV.items.count;
  for I := 0 to len - 1 do
  begin
    li:=SensorsLV.Items[i];
    SensorsLV.GetSubItemByColumnName(colstage,li,str);
    if str=oldname then
      SensorsLV.SetSubItemByColumnName(colstage,newname,li);
  end;
end;

function TConfigForm.GetSelectedSensor:cSensor;
var li:tlistitem;
    str:string;
begin
  li:=SensorsLV.Selected;
  if li=nil then
  begin
    result:=nil;
    showmessage('Необходимо выбрать канал, по которому будет строиться статистика!');
    exit;
  end;
  SensorsLV.GetSubItemByColumnName(ColSensorName,li,str);
  result:=blfile.GetSensor(str);
end;

procedure TConfigForm.FillStageByBlFile;
var i:integer;
    stage:cstage;
begin
  for i := 0 to blfile.stages.Count - 1 do
  begin
    case i of
      0:
      begin
        stage:=blfile.stages.stages[i];
        StageNameEdit1.text:=stage.name;
        BladeCountE1.IntNum:=stage.bladenumber;
      end;
      1:
      begin
        stage:=blfile.stages.stages[i];
        StageNameEdit2.text:=stage.name;
        BladeCountE2.IntNum:=stage.bladenumber;
      end;
      2:
      begin
        stage:=blfile.stages.stages[i];
        StageNameEdit2.text:=stage.name;
        BladeCountE2.IntNum:=stage.bladenumber;
      end;
    end;
  end;
end;

procedure TConfigForm.UpdateForm;
begin
  // Отобразить информацию о датчиках хранящуюся в файле bld в ListView
  // Информация раскидывается по колонкам, которые должны быть названы определленным
  // образом. Имена колонок хранятся константами в файле uBldService
  showSensorsInLV(sensorslv,blfile);
  // Создает stringlist (sensors) и складывает туда sBldSensors,
  // ключом является номер канала
  CreateSensors;
  // Обновляет состояния комбобоксов на форме
  FormEditListItem.UpdateComboBox(blfile);
  // Обновить комбобоксы с сенсорами на ступенях
  UpdateStageComboBox;
end;

procedure TConfigForm.LoadCfgBtnClick(Sender: TObject);
var cfg:cConfiFile_lfm;
begin
  if OpenDialog.Execute then
  begin
    cfg:=cConfiFile_lfm.create;
    cfg.readFile(OpenDialog.FileName);
    blfile.stages:=cfg.stages;
    blfile.Sensors:=cfg.sensors;
    cfg.Destroy;
    // обновить число и имена ступеней из blFile
    FillStageByBlFile;
    UpdateForm;
    // Отобразить конфигурацию в виде дерева
    ShowConfig;
  end;
end;

procedure TConfigForm.ShowBladesOffset(shape:cpoints2;lv:tBtnListView);
var li:tlistitem;
    len,i:integer;
    str:string;
begin
  lv.Clear;
  len:=length(shape.ar);
  for I := 0 to len - 1 do
  begin
    li:=LV.Items.Add;
    lv.SetSubItemByColumnName(ColBladeNum,intToStr(i),li);
    str:=GetRoundNumString(shape.ar[i].x,2);
    lv.SetSubItemByColumnName(ColSensorPos,str,li);
  end;
end;

procedure TConfigForm.EvalShapeBtnClick(Sender: TObject);
var i,j:integer;
    shape:cpoints2;
    offset:single;
    function getBlCountFromForm(var SCBox:TComboBox;var TCBox:TComboBox;
                        const blFile:cBldFilegen):integer;
    var sensorind, tahoind:integer;
        sensor:cSensor;
    begin
      sensorind:=blfile.GetSensorInd(SensorsCBox1.Text);
      sensor:=blfile.GetSensor(SensorsCBox1.Text);
      tahoind:=blfile.GetSensorInd(TahoCBox1.Text);
      result:=EvalStageBladeCount(blfile.trends[tahoind].ticks.ticks,
                                               blfile.trends[sensorind].ticks.ticks, 1);
    end;
begin
  if not CheckSensorLV then exit;
  for I := 0 to blfile.stages.count - 1 do
  begin
    case i of
    0:
      begin
        BladeCountE1.IntNum:=getBlCountFromForm(SensorsCBox1, TahoCBox1, blFile);
        // Вычисление формы турбины
        shape:=cpoints2.create;
        offset := PosFE1.FloatNum;
        EvalStageShape(blfile.trends[blfile.getsensorind(SensorsCBox1.Text)].ticks.ticks,
        blfile.trends[blfile.getsensorind(TahoCBox1.Text)].ticks.ticks,
        StartFE.FloatNum, EndFE.FloatNum,offset, shape);
        setlength(blFile.stages.stages[i].blades,BladeCountE1.IntNum);
        for j := 0 to BladeCountE1.IntNum - 1 do
        begin
          blFile.stages.stages[i].blades[j].offset:=shape.ar[j].x;
        end;
        ShowBladesOffset(shape,BladesListView1);
        shape.destroy;
      end;
    1:
      begin
        BladeCountE2.IntNum:=getBlCountFromForm(SensorsCBox2, TahoCBox2, blFile);
        // Вычисление формы турбины
        shape:=cpoints2.create;
        offset := PosFE2.FloatNum;
        EvalStageShape(blfile.trends[blfile.getsensorind(SensorsCBox2.Text)].ticks.ticks,
        blfile.trends[blfile.getsensorind(TahoCBox2.Text)].ticks.ticks,
        StartFE.FloatNum, EndFE.FloatNum,offset, shape);
        setlength(blFile.stages.stages[i].blades,BladeCountE1.IntNum);
        for j := 0 to BladeCountE2.IntNum - 1 do
        begin
          blFile.stages.stages[i].blades[j].offset:=shape.ar[j].x;
        end;
        ShowBladesOffset(shape,BladesListView2);
        shape.destroy;
      end;
    2:
      begin
        BladeCountE3.IntNum:=getBlCountFromForm(SensorsCBox3, TahoCBox3, blFile);
        // Вычисление формы турбины
        shape:=cpoints2.create;
        offset := PosFE3.FloatNum;
        EvalStageShape(blfile.trends[blfile.getsensorind(SensorsCBox3.Text)].ticks.ticks,
        blfile.trends[blfile.getsensorind(TahoCBox3.Text)].ticks.ticks,
        StartFE.FloatNum, EndFE.FloatNum,offset, shape);
        setlength(blFile.stages.stages[i].blades,BladeCountE1.IntNum);
        for j := 0 to BladeCountE3.IntNum - 1 do
        begin
          blFile.stages.stages[i].blades[j].offset:=shape.ar[j].x;
        end;
        ShowBladesOffset(shape,BladesListView3);
        shape.destroy;
      end;
    end;
  end;
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  // Ступени
  stages:=tstringlist.create;
  stages.Sorted:=true;
  stages.Duplicates:=dupIgnore;
  // Датчики
  sensors:=tstringlist.create;
  sensors.Sorted:=true;
  sensors.Duplicates:=dupIgnore;
end;

procedure TConfigForm.SensorsLVDblClickProcess(item: TListItem; lv: TListView);
var str:string;
begin
  if FormEditListItem.ShowModal(item, tBtnListView(lv)) = mrok then
  begin
    // запись имени ступени
    tBtnListView(lv).SetSubItemByColumnName(ColStage,
                                            FormEditListItem.StageComboBox.Text,
                                            item);
    // запись положения датчика
    str:=floattostr(FormEditListItem.OffsetFloatEdit.FloatNum);
    tBtnListView(lv).SetSubItemByColumnName(ColSensorPos,
                                            str,
                                            item);
    // запись имени датчика
    tBtnListView(lv).SetSubItemByColumnName(ColSensorName,
                                            FormEditListItem.NameEdit.Text,
                                            item);
    // запись типа датчика
    tBtnListView(lv).SetSubItemByColumnName(ColType,
                                            FormEditListItem.SensorTypeComboBox.Text,
                                            item);
    blfile.stages.destroy;
    blfile.stages:=GetStagesFromLV(tBtnListView(lv));
    UpdateStageComboBox;
  end;
end;

// Процедура переносит названия датчиков из sensorslistview в combobox-ы
// на соответствующих ступеням. (Если в sensorsListView датчику
// сопоставлено имя ступени)
procedure tconfigform.UpdateStageComboBox;
var i,j,rotorcount,stageind:integer;
    str,stype:string;
    li:tlistitem;
    sensor:cSensor;
begin
  SensorsCBox1.Clear;
  SensorsCBox2.Clear;
  SensorsCBox3.Clear;
  TahoCBox1.Clear;
  TahoCBox2.Clear;
  TahoCBox3.Clear;
  // Переписываем названия ступеней в форму
  for I := 0 to sensorslv.items.Count - 1 do
  begin
    li:= sensorslv.Items[i];
    sensorslv.GetSubItemByColumnName(ColStage,li,str);
    if str<>'' then
    begin
      stageind:=stages.Add(str);
      case stageind of
        0:
        begin
          // вычитываем из таблицы имя датчика
          sensorslv.GetSubItemByColumnName(ColSensorName,li,str);
          // вычитываем из таблицы тип датчика
          sensorslv.GetSubItemByColumnName(ColType,li,stype);
          if stype='Тахо' then
            TahoCBox1.Items.Add(str)
          else
            SensorsCBox1.Items.Add(str);
          sensorslv.GetSubItemByColumnName(ColStage,li,str);
          StageNameEdit1.Text:=str;
        end;
        1:
        begin
          // вычитываем из таблицы имя датчика
          sensorslv.GetSubItemByColumnName(ColSensorName,li,str);
          // вычитываем из таблицы тип датчика
          sensorslv.GetSubItemByColumnName(ColType,li,stype);
          if stype='Тахо' then
            TahoCBox2.Items.Add(str)
          else
            SensorsCBox2.Items.Add(str);
          sensorslv.GetSubItemByColumnName(ColStage,li,str);
          StageNameEdit2.Text:=str;
        end;
        2:
        begin
          // вычитываем из таблицы имя датчика
          sensorslv.GetSubItemByColumnName(ColSensorName,li,str);
          // вычитываем из таблицы тип датчика
          sensorslv.GetSubItemByColumnName(ColType,li,stype);
          if stype='Тахо' then
            TahoCBox3.Items.Add(str)
          else
            SensorsCBox3.Items.Add(str);
          sensorslv.GetSubItemByColumnName(ColStage,li,str);
          StageNameEdit3.Text:=str;
        end;
      end;
    end;
  end;
  if SensorsCBox1.items.count<>0 then
    SensorsCBox1.ItemIndex:=0;
  if SensorsCBox2.items.count<>0 then
    SensorsCBox2.ItemIndex:=0;
  if SensorsCBox3.items.count<>0 then
    SensorsCBox3.ItemIndex:=0;
  if TahoCBox1.items.count<>0 then
    TahoCBox1.ItemIndex:=0;
  if TahoCBox2.items.count<>0 then
    TahoCBox2.ItemIndex:=0;
  if TahoCBox3.items.count<>0 then
    TahoCBox3.ItemIndex:=0;
  rotorcount:=stages.count;
end;

procedure tconfigform.ChangeSensor(itemindex:integer);
var sensor:csensor;
    s:cSensor;
    count,i,index:integer;
    find:boolean;
begin
  // Заполняем список датчиков из таблице на форме.
  s:=getSensorFromLV(SensorsLV,itemindex);
  find:=sensors.Find(inttostr(s.mChanNumber),index);
  if find then
  begin
    sensor:=csensor(sensors.objects[index]);
  end
  else
  begin
    sensor:=csensor.Create;
  end;
  if not find then
  begin
    count:=sensors.AddObject(inttostr(s.mChanNumber),sensor);
  end;
end;

procedure tconfigform.CreateSensors;
var i:integer;
begin
  // Заполняем список датчиков из таблице на форме.
  for i := 0 to sensorsLV.items.count - 1 do
  begin
    ChangeSensor(i);
  end;
end;

procedure tconfigform.DeleteSensors;
var i:integer;
begin
  for i := 0 to sensors.Count - 1 do
  begin
    sensors.Objects[i].Destroy;
  end;
  sensors.clear;
end;

function tconfigform.showmodal(bldfile:cbldfilegen):integer;
begin
  // Запоминает ссылку на bldfile в форме
  blfile:=bldfile;
  // переносит информацию из blFile-а в форму
  UpdateForm;
  // Перенести данные из формы в bldFile
  if (inherited showmodal = mrok) then
  begin

  end;
  sensorslv.Clear;
  DeleteSensors;
end;

function tconfigform.CheckSensorLV:boolean;
var i:integer;
    li:tlistitem;
    str:string;
begin
  result:=true;
  for I := 0 to sensorslv.items.count - 1 do
  begin
    li:=sensorslv.Items[i];
    if not sensorslv.GetSubItemByColumnName(colstage,li,str) or (str='') then
    begin
      showmessage('для датчика с индексом '+inttostr(i)+' не определена ступень' );
      result:=false;
    end;
  end;
end;

procedure tconfigform.updateBldFileByForm;
begin

end;

end.

