unit uAlarmsHistoryForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  DBCGrids, ExtCtrls, DBCtrls, Grids, DBGrids, DB, IBDatabase,
  IBCustomDataSet, StdCtrls, ubldeng, ImgList, ToolWin, ComCtrls, IBQuery;

type
  TAlarmsHistoryBase = class(TForm)
    MainGB: TGroupBox;
    DBGrid1: TDBGrid;
    ActionGB: TGroupBox;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    ImageList_32: TImageList;
    DeleteRecordsBtn: TToolButton;
    ToolButton2: TToolButton;
    FilterGB: TGroupBox;
    SettingsGB: TGroupBox;
    TagNameLabel: TLabel;
    AlarmNameLabel: TLabel;
    TagNameCheckBox: TCheckBox;
    TagNameCB: TComboBox;
    AlarmsNameCheckBox: TCheckBox;
    AlarmNameCB: TComboBox;
    OnTimeIntervalGB: TGroupBox;
    OnTimeStartLabel: TLabel;
    OnTimeEndLabel: TLabel;
    OnTimeStartPicker: TDateTimePicker;
    OnTimeEndPicker: TDateTimePicker;
    OnTimeCheckBox: TCheckBox;
    OnTimeIntervalImage: TImage;
    NameslImage: TImage;
    OffTimeIntervalGB: TGroupBox;
    OffTimeStartLabel: TLabel;
    OffTimeEndLabel: TLabel;
    Image1: TImage;
    OffTimeStartPicker: TDateTimePicker;
    OffTimeEndPicker: TDateTimePicker;
    OffTimeCheckBox: TCheckBox;
    StateRadioGB: TRadioGroup;
    ActionsGB: TGroupBox;
    OkBtn: TButton;
    ApplyBtn: TButton;
    DataSource1: TDataSource;
    EnableArhiveCheckBox: TCheckBox;
    procedure DeleteRecordsBtnClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    histMng:tobject;
    eng:cbldeng;
    firstHeader:string;
  private
    function createDeleteString:string;
    function createFilterString:string;
    function createString:string;
  public
    procedure Linc(engine:cbldeng; p_histMng:tobject);
  end;

var
  AlarmsHistoryBase: TAlarmsHistoryBase;

implementation
uses
  uHistoryMng;
{$R *.dfm}

procedure TAlarmsHistoryBase.ApplyBtnClick(Sender: TObject);
begin
  if histmng<>nil then
  begin
    cHistoryMng(histmng).active:=EnableArhiveCheckBox.Checked;
  end;
end;

function TAlarmsHistoryBase.createString:string;
var
  str, Wherestr:string;
begin
  result:='from alarms_tbl';
  str:='';
  Wherestr:=' where ';
  if OnTimeCheckBox.checked then
  begin
    str:=str+'ONTIME between :ONTIME1 and :ONTIME2';
  end;
  if OFFTimeCheckBox.checked then
  begin
    if str<>'' then str:=str+' and ';
    str:=str+'OFFTIME between :OFFTIME1 and :OFFTIME2';
  end;
  if TagNameCheckBox.checked then
  begin
    if str<>'' then str:=str+' and ';
    str:=str+'TAGNAME = :TAGNAME';
  end;
  if AlarmsNameCheckBox.checked then
  begin
    if str<>'' then str:=str+' and ';
    str:=str+'NAME = :NAME';
  end;
  if (StateRadioGB.itemindex<>-1) and (StateRadioGB.itemindex<>2) then
  begin
    if str<>'' then str:=str+' and ';
    str:=str+'STATE = :STATE';
  end;
  if str<>'' then
    result:=result+WHEREstr+str
  else
    result:=result;
end;

function TAlarmsHistoryBase.createDeleteString:string;
begin
  result:='delete '+createString;
end;

function TAlarmsHistoryBase.createFilterString:string;
begin
  result:='select * '+createString;
end;

procedure TAlarmsHistoryBase.DeleteRecordsBtnClick(Sender: TObject);
var
  str:string;
  Q: TIBQuery;
  trz: TIBTransaction;
begin
  //showMesageBox();
  Q:=TIBQuery.Create(nil);
  Q.Database := cHistoryMng(histmng).dataset.Database;
  trz := TIBTransaction.Create(nil);
  trz.DefaultDatabase := cHistoryMng(histmng).dataset.Database;
  str:=createDeleteString;
  Q.SQL.Text := str;
  cHistoryMng(histmng).dataset.SelectSQL.Clear;
  cHistoryMng(histmng).dataset.SelectSQL.text:='select * from alarms_tbl';

  if OnTimeCheckBox.checked then
  begin
    Q.ParamByName('ONTIME1').AsDateTime:=OnTimeStartPicker.DateTime;
    Q.ParamByName('ONTIME2').AsDateTime:=OnTimeEndPicker.DateTime;
  end;
  if OFFTimeCheckBox.checked then
  begin
    q.ParamByName('OFFTIME1').AsDateTime:=OFFTimeStartPicker.DateTime;
    q.ParamByName('OFFTIME1').AsDateTime:=OFFTimeEndPicker.DateTime;
  end;
  if TagNameCheckBox.checked then
  begin
    q.ParamByName('TAGNAME').AsString:=TagNameCB.Text;
  end;
  if AlarmsNameCheckBox.checked then
  begin
    q.ParamByName('NAME').AsString:=AlarmNameCB.Text;
  end;
  if (StateRadioGB.itemindex<>-1) and (StateRadioGB.itemindex<>2) then
  begin
    q.ParamByName('STATE').AsInteger:=StateRadioGB.ItemIndex;
  end;

  trz.starttransaction;
  Q.ExecSQL;
  trz.Commit;
  cHistoryMng(histmng).dataset.open;
  Q.Free;
  trz.Free;
end;

procedure TAlarmsHistoryBase.FormCreate(Sender: TObject);
begin
  firstheader:=caption;
end;

procedure TAlarmsHistoryBase.FormShow(Sender: TObject);
begin
  EnableArhiveCheckBox.checked:=cHistoryMng(histmng).Active;
  Caption:=firstheader +'Path: '+ cHistoryMng(histmng).database.DatabaseName;
end;

procedure TAlarmsHistoryBase.Linc(engine:cbldeng; p_histMng:tobject);
begin
  eng:=engine;
  histmng:=p_histMng;
end;

procedure TAlarmsHistoryBase.ToolButton2Click(Sender: TObject);
var
  str:string;
begin
  //cHistoryMng(histmng).dataset.Close;
  cHistoryMng(histmng).dataset.SelectSQL.Clear;
  str:=createFilterString;
  cHistoryMng(histmng).dataset.SelectSQL.Add(str);

  if OnTimeCheckBox.checked then
  begin
    cHistoryMng(histmng).dataset.ParamByName('ONTIME1').AsDateTime:=OnTimeStartPicker.DateTime;
    cHistoryMng(histmng).dataset.ParamByName('ONTIME2').AsDateTime:=OnTimeEndPicker.DateTime;
  end;
  if OFFTimeCheckBox.checked then
  begin
    cHistoryMng(histmng).dataset.ParamByName('OFFTIME1').AsDateTime:=OFFTimeStartPicker.DateTime;
    cHistoryMng(histmng).dataset.ParamByName('OFFTIME1').AsDateTime:=OFFTimeEndPicker.DateTime;
  end;
  if TagNameCheckBox.checked then
  begin
    cHistoryMng(histmng).dataset.ParamByName('TAGNAME').AsString:=TagNameCB.Text;
  end;
  if AlarmsNameCheckBox.checked then
  begin
    cHistoryMng(histmng).dataset.ParamByName('NAME').AsString:=AlarmNameCB.Text;
  end;
  if (StateRadioGB.itemindex<>-1) and (StateRadioGB.itemindex<>2) then
  begin
    cHistoryMng(histmng).dataset.ParamByName('STATE').AsInteger:=StateRadioGB.ItemIndex;
  end;

  cHistoryMng(histmng).dataset.open;
end;

end.
