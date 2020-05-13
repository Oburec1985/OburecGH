unit uEditGraphForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms,
  StdCtrls, Spin, uAutoPage, Controls, utag;

type
  TEditGraphForm = class(TForm)
    NameLabel: TLabel;
    AutoScaleCB: TCheckBox;
    SelectSE: TSpinEdit;
    SelectTypeCB: TCheckBox;
    SelectCB: TComboBox;
    CancelBtn: TButton;
    OkBtn: TButton;
    NameEdit: TEdit;
    procedure SelectTypeCBClick(Sender: TObject);
  private
    curobj:cautopage;
    procedure ChangeCB;
    procedure getObj(obj:cautopage);
    procedure setObj;
  public
    procedure ShowModal(obj:cautopage);
  end;

var
  EditGraphForm: TEditGraphForm;

implementation

{$R *.dfm}

procedure TEditGraphForm.getObj(obj:cautopage);
begin
  curobj:=obj;
  SelectTypeCB.Checked:=curobj.offsetLink;
  NameEdit.Text:=obj.name;
  ChangeCB;
end;

procedure TEditGraphForm.SelectTypeCBClick(Sender: TObject);
begin
  changecb;
end;

procedure TEditGraphForm.setObj;
begin
  curobj.offsetlink:=SelectTypeCB.Checked;
  curobj.name:=NameEdit.Text;
  if SelectTypeCB.Checked then
  begin
    curobj.src:=cbasetag(SelectCB.items.objects[SelectCB.ItemIndex]);
  end
  else
  begin
    curobj.src:=nil;
    curobj.id:=Selectse.Value;
  end;
end;

procedure TEditGraphForm.ChangeCB;
begin
  if SelectTypeCB.Checked then
  begin
    if curobj.src<>nil then
    begin
      SelectCB.Enabled:=true;
      SelectCB.Text:=cbasetag(curobj.src).name;
      Selectse.Enabled:=false;
      Selectse.Value:=0;
    end
  end
  else
  begin
    Selectse.Enabled:=true;
    Selectse.Value:=curobj.id;
    SelectCB.Text:='';
    SelectCB.Enabled:=false;
  end;
end;

procedure TEditGraphForm.ShowModal(obj:cautopage);
begin
  getobj(obj);
  if inherited showmodal=mrok then
  begin
    setobj;
  end;
end;



end.
