// Форма служит для опционального выбора загружаемых из файла объектов
unit uSelectLoadedObjects;

interface

uses
  Windows, Forms, uBtnListView, StdCtrls, sysutils,
  Classes, Controls, ComCtrls;

type
 cFileHeadObjInfo = class
   DataPosInHeader:integer; // позиция начала объекта в заголовке файла
   DataPosInFile:integer; // позиция начала объекта в теле файла
   objname:string;
   load:boolean; // содержит бит - считывать или нет объект из файла
 public
   destructor destroy;
   constructor create;
 end;
 // Класс для хранения списка объектов, которые хранят заголовочную информацию
 // об объектах сцены.
 cFileHeadObjInfoList = class(TStringList)
 public
   destructor destroy;
   constructor create;
   procedure cleardata;
   Function GetByName(name:string):cFileHeadObjInfo;
   procedure ClearAndDeleteObjects;
 end;

 TInfoForm = class(TForm)
   BtnListView1: TBtnListView;
   CancelBtn: TButton;
   OkBtn: TButton;
 private
   infolist:cFileHeadObjInfoList;
   procedure showInfoList;
   procedure GetObjInfoFromForm;
 public
   { Public declarations }
   function ShowModal(var p_infolist:cFileHeadObjInfoList):integer;
 end;

var
  InfoForm: TInfoForm;

implementation
const
  ObjName = 'Имя объекта';
  ObjType = 'Тип';
  ObjPos = 'Позиция';

{$R *.dfm}

constructor cFileHeadObjInfo.create;
begin
  inherited;
end;

destructor cFileHeadObjInfo.destroy;
begin
  inherited;
end;

constructor cFileHeadObjInfoList.create;
begin
  sorted:=false;
end;

procedure cFileHeadObjInfoList.cleardata;
var i:integer;
    objinfo:cFileHeadObjInfo;
begin
  for i := 0 to count - 1 do
  begin
    objinfo:=cFileHeadObjInfo(objects[i]);
    objinfo.Destroy;
  end;
  clear;
end;

destructor cFileHeadObjInfoList.destroy;
begin
  cleardata;
  inherited;
end;

Function cFileHeadObjInfoList.GetByName(name:string):cFileHeadObjInfo;
var
  I: Integer;
  info:cFileHeadObjInfo;
begin
  result:=nil;
  for I := 0 to count - 1 do
  begin
    info:=cFileHeadObjInfo(objects[i]);
    if info.objname=name then
    begin
      result:=info;
      exit;
    end;
  end;
end;

procedure cFileHeadObjInfoList.ClearAndDeleteObjects;
var
  I: Integer;
  info:cFileHeadObjInfo;
begin
  for I := 0 to Count - 1 do
  begin
    info:=cFileHeadObjInfo(objects[i]);
    info.Destroy;
  end;
  clear;
end;

procedure TInfoForm.showInfoList;
var i:integer;
    li:tlistitem;
    info:cFileHeadObjInfo;
begin
  BtnListView1.Clear;
  for I := 0 to infolist.Count - 1 do
  begin
    info:=cFileHeadObjInfo(infolist.objects[i]);
    li:=BtnListView1.Items.Add;
    BtnListView1.SetSubItemByColumnName(ObjName,info.objname,li);
    BtnListView1.SetSubItemByColumnName(ObjType,'Пока заголовок не хранит',li);
    BtnListView1.SetSubItemByColumnName(ObjPos,inttostr(info.DataPosInFile),li);
  end;
end;

procedure TInfoForm.GetObjInfoFromForm;
var i:integer;
    li:tlistitem;
    info:cFileHeadObjInfo;
begin
  for I := 0 to infolist.Count - 1 do
  begin
    info:=cFileHeadObjInfo(infolist.objects[i]);
    li:=BtnListView1.Items[i];
    info.load:=li.Checked;
  end;
end;

function TInfoForm.ShowModal(var p_infolist:cFileHeadObjInfoList):integer;
begin
  infolist:=p_infolist;
  showInfoList;
  if inherited showmodal = mrok then
  begin
    GetObjInfoFromForm;
  end;
end;

end.
