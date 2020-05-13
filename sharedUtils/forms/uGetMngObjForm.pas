unit uGetMngObjForm;

interface

uses
  Windows, SysUtils, Classes, Forms, uBaseObjService,
  StdCtrls, ComCtrls, uBtnListView, uBaseObj, uBaseObjMng, Controls;

type
  TGetMngObjForm = class(TForm)
    ControlGB: TGroupBox;
    ApplyBtn: TButton;
    CancelBtn: TButton;
    ObjectsLV: TBtnListView;
  private
    procedure initObjectsLV;
    procedure showObjects(mng:cBaseObjMng);
  public
    Constructor create(aOwner:tComponent);override;
    function GetObj(mng:cBaseObjMng):cbaseobj;
  end;

implementation

{$R *.dfm}
procedure TGetMngObjForm.initObjectsLV;
var
  col:tlistcolumn;
begin
  objectslv.Columns.Clear;
  col:=objectslv.Columns.add;
  col.Caption:=v_ColNum;
  col:=objectslv.Columns.add;
  col.Caption:=v_ColName;
end;

Constructor TGetMngObjForm.create(aOwner:tComponent);
begin
  inherited;
  initObjectsLV;
end;

procedure TGetMngObjForm.showObjects(mng:cBaseObjMng);
var
  I: Integer;
  li:tlistitem;
  obj:cbaseobj;
begin
  objectslv.Clear;
  for I := 0 to mng.Count - 1 do
  begin
    li:=objectslv.items.add;
    obj:=mng.getobj(i);
    li.Data:=obj;
    objectslv.SetSubItemByColumnName(v_ColNum,inttostr(i),li);
    objectslv.SetSubItemByColumnName(v_ColName,obj.name,li);
  end;
end;

function TGetMngObjForm.GetObj(mng:cBaseObjMng):cbaseobj;
begin
  result:=nil;
  showObjects(mng);
  if inherited showmodal=mrok then
  begin
    if ObjectsLV.Items.Count>0 then
    begin
      if (ObjectsLV.itemindex=-1) then
      begin
        ObjectsLV.itemindex:=1;
      end;
      result:=cbaseobj(ObjectsLV.Items[ObjectsLV.ItemIndex].Data);
    end;
  end;
end;

end.
