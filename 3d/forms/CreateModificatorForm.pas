unit CreateModificatorForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, uBtnListView, uModList;

type
  TcCreateModificatorForm = class(TForm)
    GroupBox1: TGroupBox;
    CancelBtn: TButton;
    OkBtn: TButton;
    ModificatorsLV: TBtnListView;
  private
  private
    procedure ShowModificator(modcreator:cModCreator);
  public
    function ShowModal(modcreator:cModCreator):integer;
  end;

var
  cCreateModificatorForm: TcCreateModificatorForm;

const col_ModName = 'Имя модификатора';

implementation

{$R *.dfm}

procedure TcCreateModificatorForm.ShowModificator(modcreator:cModCreator);
var i:integer;
    names:tstrings;
    li:tlistitem;
begin
  names:=modcreator.getnames;
  for I := 0 to names.Count - 1 do
  begin
    li:=ModificatorsLV.items.add;
    ModificatorsLV.SetSubItemByColumnName(col_ModName,names.Strings[i],li)
  end;
end;

function TcCreateModificatorForm.ShowModal(modcreator:cModCreator):integer;
var i:integer;
    li:tlistitem;
    name:string;
begin
  ModificatorsLV.clear;
  ShowModificator(modcreator);
  if inherited ShowModal=mrok then
  begin
    li:=ModificatorsLV.Selected;
    if li<>nil then
    begin
      ModificatorsLV.GetSubItemByColumnName(col_ModName,li,name);
      modcreator.CreateModificator(name);
    end;
  end;
end;

end.
