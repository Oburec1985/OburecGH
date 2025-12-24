unit uTagPropertiesFrame;

interface

uses
  Windows, SysUtils,Forms,  StdCtrls, uBtnListView, uCreateObjForm,
  uChart, uDrawObj, ExtCtrls, utag, Controls, ComCtrls, Classes, ToolWin,
  ImgList, uBldTimeProc, uAlarms, uBaseObjService, uEditAlarmForm;

type
  TTagPropertiesFrame = class(TFrame)
    TagNameEdit: TEdit;
    TagNameLabel: TLabel;
    DscEdit: TEdit;
    DscLabel: TLabel;
    TheresholdLabel: TLabel;
    TheresholdsLV: TBtnListView;
    DrawObjEdit: TEdit;
    DrawObjLabel: TLabel;
    DrawObjSelectBtn: TButton;
    ToolBar: TToolBar;
    AddAlarmBtn: TToolButton;
    DelAlarmBtn: TToolButton;
    ImageList1: TImageList;
    procedure DrawObjSelectBtnClick(Sender: TObject);
    procedure TheresholdsLVDblClickProcess(item: TListItem; lv: TListView);
    procedure AddAlarmBtnClick(Sender: TObject);
  private
    t:cbasetag;
    drawobj:cdrawobj;
    tproc:cBldTimeProc;
    alarms:cAlarmMng;
  private
    procedure addalarm(a:calarm);
    procedure InitAlarmsLV;
  public
    procedure showAlarms;
    procedure linc(tp:cBldTimeProc);
    procedure setTag(tag:cbasetag);
    // применить изменения
    procedure gettag;
    constructor create(aowner:tcomponent);override;
  end;

implementation

{$R *.dfm}

constructor TTagPropertiesFrame.create(aowner:tcomponent);
begin
  inherited;
  InitAlarmsLV;
end;

procedure TTagPropertiesFrame.InitAlarmsLV;
var
  col:tlistcolumn;
begin
  TheresholdsLV.Columns.Clear;
  // Колонка с номером
  col:=TheresholdsLV.Columns.Add;
  col.Caption:=c_ColNum;
  col.width:=30;
  // Колонка с именем
  col:=TheresholdsLV.Columns.Add;
  col.Caption:=c_ColName;
  col.width:=60;
  // Колонка с описанием
  col:=TheresholdsLV.Columns.Add;
  col.Caption:=c_ColDSC;
  col.width:=60;
  // Колонка типом
  col:=TheresholdsLV.Columns.Add;
  col.Caption:=c_ColType;
  col.width:=60;
  // Колонка с значением
  col:=TheresholdsLV.Columns.Add;
  col.Caption:=c_ColValue;
  col.width:=60;
end;

procedure TTagPropertiesFrame.linc(tp:cBldTimeProc);
begin
  tproc:=tp;
  alarms:=cAlarmMng(tp.alarms);
end;

procedure TTagPropertiesFrame.setTag(tag:cbasetag);
begin
  t:=tag;
  if tag<>nil then
  begin
    tagnameedit.Text:=tag.name;
    dscEdit.text:=tag.dsc;
    if tag.DrawObj<>nil then
      DrawObjEdit.text:=tag.DrawObj.name
    else
      DrawObjEdit.text:='';
  end;
  showAlarms;
end;

procedure TTagPropertiesFrame.AddAlarmBtnClick(Sender: TObject);
begin
  t.addalarm(EditAlarmForm.CreateAlarm(alarms,t));
  showalarms;
end;

procedure TTagPropertiesFrame.DrawObjSelectBtnClick(Sender: TObject);
begin
  DrawObj:=CreateObjForm.getobj;
  if drawObj<>nil then
    DrawObjEdit.text:=drawobj.name
  else
    DrawObjEdit.text:='';
  t.DrawObj:=drawobj;
end;

procedure TTagPropertiesFrame.gettag;
begin
  t.DrawObj:=drawobj;
  t.name:=tagnameedit.Text;
end;

procedure TTagPropertiesFrame.addalarm(a:calarm);
var
  li:tlistitem;
begin
  li:=TheresholdsLV.Items.add;
  li.Data:=a;
  TheresholdsLV.SetSubItemByColumnName(c_colNum,inttostr(li.index),li);
  TheresholdsLV.SetSubItemByColumnName(c_colName,a.name,li);
  TheresholdsLV.SetSubItemByColumnName(c_colType,a.TypeString,li);
  TheresholdsLV.SetSubItemByColumnName(c_colValue,floattostr(a.threshold),li);
  TheresholdsLV.SetSubItemByColumnName(c_colDSC,a.dsc,li);
end;

procedure TTagPropertiesFrame.showAlarms;
var
  I: Integer;
  alarms:calarmslist;
  a:calarm;
begin
  alarms:=calarmslist(t.alarms);
  TheresholdsLV.Clear;
  for I := 0 to t.alarmcount - 1 do
  begin
    a:=alarms.GetAlarm(i);
    addalarm(a);
  end;
end;

procedure TTagPropertiesFrame.TheresholdsLVDblClickProcess(item: TListItem;
  lv: TListView);
var
  a:calarm;
begin
  a:=calarm(item.data);
  editalarmform.editAlarm(calarm(item.data));
  TheresholdsLV.SetSubItemByColumnName(c_colNum, inttostr(item.index), item);
  TheresholdsLV.SetSubItemByColumnName(c_colName, a.name, item);
  TheresholdsLV.SetSubItemByColumnName(c_colType, a.TypeString, item);
  TheresholdsLV.SetSubItemByColumnName(c_colValue, floattostr(a.threshold), item);
  TheresholdsLV.SetSubItemByColumnName(c_colDSC,a.dsc,item);
end;

end.
