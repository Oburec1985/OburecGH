unit uTrigFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PosBase, StdCtrls, DCL_MYOWN, ComCtrls, uBtnListView, uWPproc,
  ExtCtrls;

type
  TTrigFrm = class(TForm)
    Label4: TLabel;
    TrigLabel: TLabel;
    TrigShiftLabel: TLabel;
    TrigTheresholdLabel: TLabel;
    TrigNumberLabel: TLabel;
    Label5: TLabel;
    TrigLV: TBtnListView;
    TrigCB: TComboBox;
    TrigShiftE: TFloatEdit;
    TrigTheresholdE: TFloatEdit;
    TrigNumberIE: TIntEdit;
    AddTrigBtn: TButton;
    TrigApplyBtn: TButton;
    IntEdit1: TIntEdit;
    UnitsRG: TRadioGroup;
    UnitsCB: TComboBox;
    UnitsLabel: TLabel;
    TrigTypeRG: TRadioGroup;
    procedure TrigApplyBtnClick(Sender: TObject);
    procedure AddTrigBtnClick(Sender: TObject);
    procedure TrigLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    mng:cwpobjmng;
    selSrc:csrc;
  public
    procedure ShowTriggers;
    procedure linkMng(m:cwpobjmng);
    function ShowModal:integer;
  end;

var
  TrigFrm: TTrigFrm;

implementation

{$R *.dfm}

procedure TTrigFrm.linkMng(m:cwpobjmng);
begin
  mng:=m;
end;

function TTrigFrm.ShowModal:integer;
begin
  selSrc:=mng.SelectedSrc;
  ShowTriggers;
  result:=inherited showmodal;
end;

procedure TTrigFrm.ShowTriggers;
var
  I: Integer;
  li:tlistitem;
  tr:ctrig;
  s:cwpsignal;
begin
  TrigLV.Clear;
  for I := 0 to mng.TrigList.Count - 1 do
  begin
    tr:=ctrig(mng.TrigList.Objects[i]);
    li:=trigLV.items.add;
    li.data:=tr;
    trigLV.SetSubItemByColumnName('№',inttostr(i),li);
    trigLV.SetSubItemByColumnName('Имя',tr.TrigName,li);
    trigLV.SetSubItemByColumnName('ID',tr.id,li);
    trigLV.SetSubItemByColumnName('Смещение',floattostr(tr.shift),li);
    trigLV.SetSubItemByColumnName('Порог',floattostr(tr.Threshold),li);
    trigLV.SetSubItemByColumnName('Номер срабатывания',inttostr(tr.number),li);
    case tr.units of
      u_Abs: trigLV.SetSubItemByColumnName('Ед.','Абс.',li);
      u_percent:trigLV.SetSubItemByColumnName('Ед.','%',li);
      u_10Lg: trigLV.SetSubItemByColumnName('Ед.','10Lg',li);
      u_20Lg: trigLV.SetSubItemByColumnName('Ед.','20Lg',li);
    end;
    if tr.Front then
      trigLV.SetSubItemByColumnName('Фронт','Да',li)
    else
      trigLV.SetSubItemByColumnName('Фронт','Нет',li)
  end;
  TrigCB.clear;
  if selSRC<>nil then
  begin
    for I := 0 to selSrc.childcount - 1 do
    begin
      s:=selSrc.getSignalObj(i);
      TrigCB.Items.AddObject(s.Name, s);
    end;
    if SelSrc.childCount>0 then
      TrigCB.ItemIndex:=0;
  end;
end;

procedure TTrigFrm.AddTrigBtnClick(Sender: TObject);
var
  tr, t:ctrig;
  Name:string;
  Threshold, shift:double;
  number:integer;
  front:boolean;
  I: Integer;
begin
  tr:=cTrig.Create();
  tr.list:=mng.TrigList;
  case UnitsCB.ItemIndex of
    0:
      tr.units := u_Abs;
    1:
      tr.units := u_percent;
    2:
      tr.units := u_10Lg;
    3:
      tr.units := u_20Lg;
  end;
  tr.trigtype:=TrigTypeRG.ItemIndex;
  case tr.trigtype of
    c_Trig_Search:
    begin
      tr.trigname:=trigCB.text;
    end;
    c_Trig_Start: tr.trigname:='Старт замера';
    c_Trig_Stop: tr.trigname:='Стоп замера';
  end;

  tr.srcid:=mng.GetSrcBySignal(cwpsignal(trigcb.Items.Objects[trigcb.ItemIndex])).id;
  tr.Threshold:=TrigTheresholdE.FloatNum;
  tr.shift:=TrigShiftE.FloatNum;
  tr.Front:=(unitsRG.ItemIndex=0);
  tr.number:=TrigNumberIE.IntNum;
  for I := 0 to tr.list.Count - 1 do
  begin
    t:=ctrig(tr.list.Objects[i]);
    if tr.Compare(t) then
    begin
      showmessage('Уже есть аналогичный триггер');
      tr.destroy;
      break;
    end;
    if i=(tr.list.Count - 1) then
    begin
      tr.GenID;
    end;
  end;
  if tr.list.Count=0 then
    tr.GenID;
  ShowTriggers;
end;

procedure TTrigFrm.TrigApplyBtnClick(Sender: TObject);
var
  li:tlistitem;
  tr, t:ctrig;
  Name:string;
  Threshold, shift:double;
  number:integer;
  front:boolean;
  I: Integer;
begin
  li:=TrigLV.Selected;
  if li<>nil then
  begin
    tr:=cTrig(Li.Data);
    case UnitsCB.ItemIndex of
      0:
        tr.units := u_Abs;
      1:
        tr.units := u_percent;
      2:
        tr.units := u_10Lg;
      3:
        tr.units := u_20Lg;
    end;
    tr.trigname:=trigCB.text;
    tr.srcid:=mng.GetSrcBySignal(cwpsignal(trigcb.Items.Objects[trigcb.ItemIndex])).id;
    tr.Threshold:=TrigTheresholdE.FloatNum;
    tr.shift:=TrigShiftE.FloatNum;
    tr.Front:=UnitsRG.itemindex=0;
    tr.number:=TrigNumberIE.IntNum;
    trigLV.SetSubItemByColumnName('Имя',tr.TrigName,li);
    trigLV.SetSubItemByColumnName('ID',tr.id,li);
    trigLV.SetSubItemByColumnName('Смещение',floattostr(tr.shift),li);
    trigLV.SetSubItemByColumnName('Порог',floattostr(tr.Threshold),li);
    trigLV.SetSubItemByColumnName('Номер срабатывания',inttostr(tr.number),li);
    if tr.Front then
      trigLV.SetSubItemByColumnName('Фронт','Да',li)
    else
      trigLV.SetSubItemByColumnName('Фронт','Нет',li);
    case tr.units of
      u_Abs: trigLV.SetSubItemByColumnName('Ед.','Абс.',li);
      u_percent:trigLV.SetSubItemByColumnName('Ед.','%',li);
      u_10Lg: trigLV.SetSubItemByColumnName('Ед.','10Lg',li);
      u_20Lg: trigLV.SetSubItemByColumnName('Ед.','20Lg',li);
    end;
  end;
end;

procedure TTrigFrm.TrigLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  tr:ctrig;
  li:tlistitem;
  str:string;
begin
  if change=ctState then
  begin
    tr:=ctrig(item.data);
    li:=item;
    li.data:=tr;
    // Имя канала
    trigLV.GetSubItemByColumnName('Имя',li,str);
    tr.TrigName:=str;
    // строковый идентификатор
    trigLV.GetSubItemByColumnName('ID',li,str);
    tr.id:=str;
    // Смещение
    trigLV.GetSubItemByColumnName('Смещение',li,str);
    tr.shift:=strtofloat(str);
    // порог срабатывания
    trigLV.GetSubItemByColumnName('Порог',li,str);
    tr.Threshold:=strtofloat(str);
    // номер срабатывания
    trigLV.GetSubItemByColumnName('Номер срабатывания',li,str);
    tr.number:=strtoint(str);
    // Фронт/ Спад
    trigLV.GetSubItemByColumnName('Фронт',li,str);
    tr.Front:=str='Да';
  end;
end;

end.

