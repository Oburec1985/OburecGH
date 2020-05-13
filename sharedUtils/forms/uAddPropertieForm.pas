unit uAddPropertieForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, uBaseObj, uMetaData, ComCtrls;

type
  TAddPropertieForm = class(TForm)
    TypeListBox: TListBox;
    TypeLabel: TLabel;
    ValueEdit: TEdit;
    ValueLabel: TLabel;
    CancelBtn: TButton;
    OkBtn: TButton;
    DscEdit: TEdit;
    DscLabel: TLabel;
    NameEdit: TEdit;
    NameLabel: TLabel;
  private
    procedure ShowClasses;
  public
    constructor create(aOwner:TComponent);override;
    function Showmodal(obj:cbaseobj):metadata;
    procedure editPropertie(data:MetaData);
  end;

var
  AddPropertieForm: TAddPropertieForm;

implementation

{$R *.dfm}

procedure TAddPropertieForm.ShowClasses;
begin
  TypeListBox.AddItem('IntMetaData',nil);
  TypeListBox.AddItem('StringMetaData',nil);
  TypeListBox.AddItem('DoubleMetaData',nil);
end;

function TAddPropertieForm.Showmodal(obj:cbaseobj):metadata;
var
  res:integer;
  data:MetaData;
begin
  result:=nil;
  typelistbox.enabled:=true;
  res:=inherited showmodal;
  if res=mrok then
  begin
    if TypeListBox.ItemIndex=-1 then
      exit;
    data:=obj.metadata.callFunc(TypeListBox.Items[TypeListBox.ItemIndex]);
    if data=nil then exit;
    data.name:=NameEdit.Text;
    data.dsc:=DscEdit.Text;
    if data is IntMetaData then
    begin
      data.ivalue:=strtoint(ValueEdit.Text);
    end;
    if data is DoubleMetaData then
    begin
      data.dvalue:=strtoFloat(ValueEdit.Text);
    end;
    if data is StringMetaData then
    begin
      data.svalue:=ValueEdit.Text;
    end;
    result:=data;
  end;
end;

constructor TAddPropertieForm.create(aOwner:TComponent);
begin
  inherited;
  ShowClasses;
end;

procedure TAddPropertieForm.EditPropertie(data:MetaData);
var
  res:integer;
begin
  NameEdit.Text:=data.name;
  DscEdit.Text:=data.dsc;
  ValueEdit.Text:=data.SValue;
  res:= inherited showmodal;
  if res=mrok then
  begin
    typelistbox.enabled:=false;
    data.name := NameEdit.Text;
    data.dsc := DscEdit.Text;
    if data is IntMetaData then
    begin
      data.ivalue := strtoint(ValueEdit.Text);
    end;
    if data is DoubleMetaData then
    begin
      data.dvalue := strtoFloat(ValueEdit.Text);
    end;
    if data is StringMetaData then
    begin
      data.svalue := ValueEdit.Text;
    end;
  end;
end;

end.
