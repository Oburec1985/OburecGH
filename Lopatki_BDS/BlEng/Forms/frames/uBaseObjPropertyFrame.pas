unit uBaseObjPropertyFrame;

interface

uses
  Classes, Forms,  StdCtrls, Controls, uBldObj, ImgList, ToolWin,
  ComCtrls, uBldEng, ExtCtrls, graphics, uBtnListView, uBldGlobalStrings,
  uBaseObjService, uBaseObj, uMetaData, sysutils, uAddPropertieForm;

type
  TBaseObjPropertyFrame = class(TFrame)
    NameEdit: TEdit;
    NameLabel: TLabel;
    TypeEdit: TEdit;
    TypeLabel: TLabel;
    TypeImage: TImage;
    Label1: TLabel;
    AddFieldBtn: TButton;
    DelPropertieBtn: TButton;
    MetaDataLV: TBtnListView;
    procedure AddFieldBtnClick(Sender: TObject);
    procedure DelPropertieBtnClick(Sender: TObject);
    procedure MetaDataLVDblClickProcess(item: TListItem; lv: TListView);
  private
    eng:cbldeng;
    curobj:cbaseobj;
  private
    procedure init;
    procedure ShowObjMetaData(obj:cBaseObj);
    procedure AddItem(data:metadata);
  public
    procedure LincToEng(p_eng:cBldEng);
    //  отобразить свойства объекта в фрейм
    procedure GetObj(obj:cBldObj);
    //  перенести свойства объекта из фрейма в объект
    procedure SetObj(obj:cBldObj);
    constructor create(aowner:tComponent);override;
  end;

implementation

{$R *.dfm}

procedure TBaseObjPropertyFrame.LincToEng(p_eng:cBldEng);
begin
  eng:=p_eng;
end;

procedure TBaseObjPropertyFrame.MetaDataLVDblClickProcess(item: TListItem;
  lv: TListView);
var
  obj:MetaData;
begin
  obj:=metadata(item.data);
  AddPropertieForm.editPropertie(obj);
  ShowObjMetaData(curobj);
end;

procedure TBaseObjPropertyFrame.GetObj(obj:cBldObj);
var images:timagelist;
    bitmap:tbitmap;
begin
  if obj<>nil then
  begin
    if obj.objtype<>c_bldObj then
    begin
      curobj:=obj;
      nameEdit.Text:=obj.name;
      TypeEdit.Text:=obj.typestring;
      // отрисовка иконки
      images:=obj.getimages32;
      // так можно делать утечек памяти не будет.......
      TypeImage.Picture:=nil;
      images.GetBitmap(obj.imageindex, TypeImage.Picture.Bitmap);
    end;
    ShowObjMetaData(obj);
  end;
end;

procedure TBaseObjPropertyFrame.SetObj(obj:cBldObj);
begin
  obj.name:=nameEdit.Text;
end;

procedure TBaseObjPropertyFrame.init;
var
  col:tlistcolumn;
begin
  metadatalv.Columns.Clear;
  col:=metadatalv.Columns.Add;
  col.Caption:=c_ColNum;
  col.width:=100;
  // добавляем колонки с стандартными именами
  col:=metadatalv.Columns.Add;
  col.Caption:=c_ColName;
  col.width:=100;
  // добавляем колонку тип
  col:=metadatalv.Columns.Add;
  col.Caption:=c_ColType;
  col.width:=100;
  // добавляем колонку описание
  col:=metadatalv.Columns.Add;
  col.Caption:=c_ColDsc;
  col.width:=100;
  // добавляем колонку значение
  col:=metadatalv.Columns.Add;
  col.Caption:=c_ColValue;
  col.width:=100;
end;


procedure TBaseObjPropertyFrame.AddFieldBtnClick(Sender: TObject);
var
  data:metadata;
begin
  data:=AddPropertieForm.Showmodal(curobj);
  if data<>nil then
  begin
    curobj.metadata.AddObj(data);
    AddItem(data);
  end;
end;

constructor TBaseObjPropertyFrame.create(aowner:tComponent);
begin
  inherited;
  init;
end;

procedure TBaseObjPropertyFrame.DelPropertieBtnClick(Sender: TObject);
var
  lname:string;
  li:tlistitem;
begin
  li:=MetaDataLV.Selected;
  curobj.metadata.DeleteObj(metadata(li.data).Name);
  li.Destroy;
end;

procedure TBaseObjPropertyFrame.ShowObjMetaData(obj:cBaseObj);
var
  I: Integer;
  data:metadata;
  li:tlistitem;
begin
  MetaDataLv.Clear;
  for I := 0 to obj.metadata.Count - 1 do
  begin
    data:=obj.metadata.GetObj(i);
    AddItem(data);
  end;
end;

procedure TBaseObjPropertyFrame.AddItem(data:metadata);
var
  li:tlistitem;
begin
  li:=MetaDataLv.Items.Add;
  MetaDataLv.SetSubItemByColumnName(c_ColNum,inttostr(li.Index),li);
  MetaDataLv.SetSubItemByColumnName(c_ColName,data.name,li);
  MetaDataLv.SetSubItemByColumnName(c_ColType,data.ClassName,li);
  MetaDataLv.SetSubItemByColumnName(c_ColDsc,data.dsc,li);
  MetaDataLv.SetSubItemByColumnName(c_ColValue,data.SValue,li);
  li.Data:=data;
end;


end.
