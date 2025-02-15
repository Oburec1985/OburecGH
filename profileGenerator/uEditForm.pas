unit uEditForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, comctrls, uBtnListView, uSpin, uCommonMath;

type
  TEditForm = class(TForm)
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Button2: TButton;
    LoLoSE: TFloatSpinEdit;
    HiHiSE: TFloatSpinEdit;
    HiSE: TFloatSpinEdit;
    LoSE: TFloatSpinEdit;
    Label1: TLabel;
    ValSE: TFloatSpinEdit;
    Label2: TLabel;
    FreqSE: TFloatSpinEdit;
    Label7: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    procedure initvals(lolo, lo, hi, hihi:double);
    Procedure EditItem(li:tlistitem;lv:TBtnListView);
    function NewItem(lv:TBtnListView):tlistitem;
  end;

var
  EditForm: TEditForm;

implementation

{$R *.dfm}
Procedure TEditForm.EditItem(li:tlistitem;lv:TBtnListView);
var
  str:string;
begin
  lv.GetSubItemByColumnName('LoLo',li,str);
  lolose.Value:=strtofloat(str);
  lv.GetSubItemByColumnName('Lo',li,str);
  lose.Value:=strtofloat(str);
  lv.GetSubItemByColumnName('Hi',li,str);
  hise.Value:=strtofloat(str);
  lv.GetSubItemByColumnName('HiHi',li,str);
  hihise.Value:=strtofloat(str);
  lv.GetSubItemByColumnName('�������',li,str);
  FreqSE.Value:=strtofloat(str);
  lv.GetSubItemByColumnName('��������',li,str);
  ValSE.Value:=strtofloat(str);
  if showmodal=mrok then
  begin
    lv.SetSubItemByColumnName('�������',floattostr(FreqSE.Value),li);
    lv.SetSubItemByColumnName('��������',floattostr(ValSE.Value),li);

    lv.SetSubItemByColumnName('LoLo',floattostr(lolose.Value),li);
    lv.SetSubItemByColumnName('Lo',floattostr(lose.Value),li);
    lv.SetSubItemByColumnName('Hi',floattostr(hise.Value),li);
    lv.SetSubItemByColumnName('HiHi',floattostr(hihise.Value),li);
  end;
end;

procedure TEditForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=VK_EXECUTE) or (key=VK_RETURN) then
  begin
    ModalResult:=mrOk;
  end;
  if (key=VK_ESCAPE) then
  begin
    ModalResult:=mrCancel;
  end;
end;

procedure TEditForm.initvals(lolo, lo, hi, hihi:double);
begin
  LoLoSE.Value:=lolo;
  LoSE.Value:=lo;
  hiSE.Value:=hi;
  hihiSE.Value:=hihi;
end;

function TEditForm.NewItem(lv:TBtnListView):tlistitem;
var
  str:string;
  last:tlistitem;
begin
  last:=lv.Items[lv.Items.Count-1];

  if last=nil then
  begin
    FreqSE.Value:=5;
    ValSE.Value:=1;
    result:=nil;
  end
  else
  begin
    lv.GetSubItemByColumnName('LoLo',last,str);
    LoLoSE.Value:=strtofloatext(str);

    lv.GetSubItemByColumnName('Lo',last,str);
    LoSE.Value:=strtofloatext(str);

    lv.GetSubItemByColumnName('Hi',last,str);
    HiSE.Value:=strtofloatext(str);

    lv.GetSubItemByColumnName('HiHi',last,str);
    HiHiSE.Value:=strtofloatext(str);

    lv.GetSubItemByColumnName('�������',last,str);
    FreqSE.Value:=strtofloatext(str);

    lv.GetSubItemByColumnName('��������',last,str);
    ValSE.Value:=strtofloatext(str);

    result:=nil;
  end;
  if ShowModal=mrok then
  begin
    result:=lv.Items.add;

    lv.SetSubItemByColumnName('�',inttostr(result.Index),result);

    lv.SetSubItemByColumnName('�������',floattostr(FreqSE.Value),result);
    lv.SetSubItemByColumnName('��������',floattostr(ValSE.Value),result);

    lv.SetSubItemByColumnName('LoLo',floattostr(lolose.Value),result);
    lv.SetSubItemByColumnName('Lo',floattostr(lose.Value),result);
    lv.SetSubItemByColumnName('Hi',floattostr(hise.Value),result);
    lv.SetSubItemByColumnName('HiHi',floattostr(hihise.Value),result);
  end;
end;


end.
