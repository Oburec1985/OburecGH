unit uAddProperieForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, uBaseObj, uMetaData, ComCtrls, uAddProperieForm;

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
    function Showmodal(obj:cbaseobj):metadata;
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

function TAddPropertieForm.Showmodal(obj:cbaseobj):integer;
var
  res:integer;
  data:MetaData;
begin
  result:=nil;
  res:=inherited showmodal;
  if res=mrok then
  begin
    data:=obj.metadata.callFunc(TypeListBox.Items[TypeListBox.ItemIndex]);
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

end.
