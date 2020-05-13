unit uAlgAddFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, uRegClassesList,
  Dialogs, StdCtrls, ExtCtrls, ubaseAlg, uCounteralg, uTahoAlg, uGrmsAlg, uPhaseAlg, uGrmsSrcAlg;

type
  // инструкция по добавлению фреймов и алгоритмов в uAlgMng
  TAddAlgFrm = class(TForm)
    Panel1: TPanel;
    AlgsList: TListBox;
    procedure AlgsListDblClick(Sender: TObject);
  private
    lastalg:cbaseobjclass;
  public
    procedure Init(algMng:cAlgMng);
    function CreateAlg(showdlg:boolean):cbaseAlgContainer;
  end;

var
  AddAlgFrm: TAddAlgFrm;

implementation

{$R *.dfm}

{ TAddAlgFrm }

procedure TAddAlgFrm.AlgsListDblClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

function TAddAlgFrm.CreateAlg(showdlg:boolean): cbaseAlgContainer;
var
  i:integer;
  r:cObjCreator;
begin
  result:=nil;
  if showdlg then
  begin
    if showmodal=mrok then
    begin
      r:=cObjCreator(AlgsList.Items.Objects[AlgsList.ItemIndex]);
      result:=cbaseAlgContainer(r.createfunc.create);
      lastalg:=r.createfunc;
    end;
  end
  else
  begin
    result:=cbaseAlgContainer(lastalg.create);
  end;
end;

procedure TAddAlgFrm.Init(algMng: cAlgMng);
var
  i:integer;
  r:cObjCreator;
begin
  AlgsList.Clear;
  for i := 0 to algMng.regclasses.Count - 1 do
  begin
    r:=cRegClassesList(algMng.regclasses).GetObj(i);
    if cObjCreator(r).createfunc.InheritsFrom(cBaseAlgContainer) then
    begin
      AlgsList.AddItem(TBaseAlgContainerClass(cObjCreator(r).createfunc).getdsc, r);
    end;
  end;
end;

end.
