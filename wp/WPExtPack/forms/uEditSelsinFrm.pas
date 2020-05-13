unit uEditSelsinFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, StdCtrls, DCL_MYOWN, uwpproc, ucommontypes, uComponentServises;

type
  cSelsin = class
  public
    // создать все 6 датчиков
    createAll:boolean;
    name:string;
    l1:cwpsignal;
    l2:cwpsignal;
    l3:cwpsignal;
    Exc:cwpsignal;
    fExc,fl3,fl2,fl1:string;
    shiftsectr:integer;
    minmax1,minmax2,minmax3:point2d;
    reference:double;
    autocal:boolean;
    freq:double;
  public
    function init:boolean;
    function getL1:string;
    function getL2:string;
    function getL3:string;
    function getExc:string;
    function valid:boolean;
  end;

  TEditSelsinFrm = class(TForm)
    Label6: TLabel;
    Label7: TLabel;
    Label1: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    L1CB: TComboBox;
    L2CB: TComboBox;
    L3CB: TComboBox;
    ExcFreqEdit: TFloatEdit;
    ExcCB: TComboBox;
    NameEdit: TEdit;
    GroupBox1: TGroupBox;
    SKO1Label: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    SKO2Label: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    SKO3Label: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    SKOMax1: TFloatEdit;
    SKOMin1: TFloatEdit;
    SKOMax2: TFloatEdit;
    SKOMin2: TFloatEdit;
    SKOMax3: TFloatEdit;
    SKOMin3: TFloatEdit;
    AutoCalibrCB: TCheckBox;
    ShiftSectr: TSpinEdit;
    OkBtn: TButton;
    CancelBtn: TButton;
    Label3: TLabel;
    RefEdit: TFloatEdit;
    CreateAllCB: TCheckBox;
    procedure L1CBEnter(Sender: TObject);
  private
    src:csrc;
    mng:cWPObjMng;
  private
    procedure FillCB(cb:tcombobox);
    procedure SetCB(name:string; cb:tcombobox);
    function GetSignalCB(cb:TComboBox):cwpsignal;
  public
    procedure EditSelsin(s:cselsin);
    procedure Init(pmng:cWPObjMng);
    Function CreateSelsin:cselsin;
  end;

var
  EditSelsinFrm: TEditSelsinFrm;

implementation

{$R *.dfm}

function cselsin.init:boolean;
begin
  result:=false;
  if EditSelsinFrm.mng.curSrc=nil then exit;

  l1:=EditSelsinFrm.mng.curSrc.getSignalObj(fl1);
  l2:=EditSelsinFrm.mng.curSrc.getSignalObj(fl2);
  l3:=EditSelsinFrm.mng.curSrc.getSignalObj(fl3);
  exc:=EditSelsinFrm.mng.curSrc.getSignalObj(fexc);
  result:=false;
  if l1<>nil then
  begin
    if l2<>nil then
    begin
      if l3<>nil then
      begin
        if exc<>nil then
        begin
          result:=true;
        end;
      end;
    end;
  end;
end;

function cselsin.getL1:string;
begin
  if l1=nil then
    result:=fl1
  else
    result:=l1.name;
end;

function cselsin.getL2:string;
begin
  if l2=nil then
    result:=fl2
  else
    result:=l2.name;
end;

function cselsin.getL3:string;
begin
  if l3=nil then
    result:=fl3
  else
    result:=l3.name;
end;

function cselsin.valid:boolean;
begin
  result:=false;
  if l1<>nil then
  begin
    if l2<>nil then
    begin
      if l3<>nil then
      begin
        if exc<>nil then
        begin
          result:=true;
          exit;
        end;
      end;
    end;
  end;
  result:=init;
end;

function cselsin.getExc:string;
begin
  if exc=nil then
    result:=fexc
  else
    result:=exc.name;
end;

procedure TEditSelsinFrm.FillCB(cb:tcombobox);
var
  i:integer;
  s:cwpsignal;
begin
  cb.Clear;
  for I := 0 to src.ChildCount   - 1 do
  begin
    s:=src.getSignalObj(i);
    cb.AddItem(s.name,s);
  end;
end;

procedure TEditSelsinFrm.SetCB(name:string; cb:tcombobox);
var
  I: Integer;
  s:cwpsignal;
begin
  cb.text:=name;
  for I := 0 to cb.Items.Count - 1 do
  begin
    s:=cwpsignal(cb.Items.Objects[i]);
    if s.name=name then
    begin
      cb.ItemIndex:=i;
      exit;
    end;
  end;
end;

function TEditSelsinFrm.GetSignalCB(cb:TComboBox):cwpsignal;
begin
  result:=nil;
  if cb.ItemIndex<0 then exit;
  if cb.ItemIndex<=cb.Items.Count-1 then
  begin
    if cb.Items.objects[cb.ItemIndex]<>nil  then
    begin
      result:=cwpsignal(cb.Items.objects[cb.ItemIndex]);
    end;
  end;
end;

procedure TEditSelsinFrm.init(pmng:cWPObjMng);
begin
  mng:=pmng;
  src:=mng.curSrc;
  if src=nil then exit;
  FillCB(l1cb);
  SetCB('L1', l1cb);
  FillCB(l2cb);
  SetCB('L2',l2cb);
  FillCB(l3cb);
  SetCB('L3',l3cb);
  FillCB(exccb);
  SetCB('Exc',Exccb);
end;

procedure TEditSelsinFrm.L1CBEnter(Sender: TObject);
begin
  setcomboboxitem(TComboBox(sender).text, TComboBox(sender));
end;

procedure TEditSelsinFrm.EditSelsin(s:cselsin);
begin
  Init(mng);
  SetCB(s.getL1,L1CB);
  SetCB(s.getL2,L2CB);
  SetCB(s.getL3,L3CB);
  SetCB(s.getExc,ExcCB);
  NameEdit.text:=s.name;
  SKOMin1.FloatNum:=s.minmax1.x;
  SKOMax1.FloatNum:=s.minmax1.y;
  SKOMin2.FloatNum:=s.minmax2.x;
  SKOMax2.FloatNum:=s.minmax2.y;
  SKOMin3.FloatNum:=s.minmax3.x;
  SKOMax3.FloatNum:=s.minmax3.y;
  refedit.FloatNum:=s.reference;
  ShiftSectr.Value:=s.shiftsectr;
  AutoCalibrCB.Checked:=s.autocal;
  ExcFreqEdit.FloatNum:=s.freq;

  if ShowModal=mrok then
  begin
    S.name:=NameEdit.Text;
    S.l1:=GetSignalCB(l1cb);
    if s.l1=nil then
      s.fl1:=l1cb.text;

    S.l2:=GetSignalCB(l2cb);
    if s.l2=nil then
      s.fl2:=l2cb.text;

    S.l3:=GetSignalCB(l3cb);
    if s.l3=nil then
      s.fl3:=l3cb.text;

    S.exc:=GetSignalCB(exccb);
    if s.exc=nil then
      s.fexc:=exccb.text;

    S.minmax1:=p2d(SKOMin1.FloatNum,SKOMax1.FloatNum);
    S.minmax2:=p2d(SKOMin2.FloatNum,SKOMax2.FloatNum);
    S.minmax3:=p2d(SKOMin3.FloatNum,SKOMax3.FloatNum);
    S.autocal:=AutoCalibrCB.Checked;
    S.shiftsectr:=ShiftSectr.Value;
    S.freq:=ExcFreqEdit.FloatNum;
    s.reference:=refedit.FloatNum;
  end;
end;

Function TEditSelsinFrm.CreateSelsin:cselsin;
begin
  result:=nil;
  src:=mng.curSrc;
  Init(mng);
  if inherited ShowModal=mrok then
  begin
    Result:=cSelsin.Create;
    Result.name:=NameEdit.Text;
    Result.l1:=cwpsignal(l1cb.Items.Objects[l1cb.ItemIndex]);
    Result.l2:=cwpsignal(l2cb.Items.Objects[l2cb.ItemIndex]);
    Result.l3:=cwpsignal(l3cb.Items.Objects[l3cb.ItemIndex]);
    Result.exc:=cwpsignal(l3cb.Items.Objects[exccb.ItemIndex]);
    Result.minmax1:=p2d(SKOMin1.FloatNum,SKOMax1.FloatNum);
    Result.minmax2:=p2d(SKOMin2.FloatNum,SKOMax2.FloatNum);
    Result.minmax3:=p2d(SKOMin3.FloatNum,SKOMax3.FloatNum);
    Result.autocal:=AutoCalibrCB.Checked;
    Result.shiftsectr:=ShiftSectr.Value;
    Result.freq:=ExcFreqEdit.FloatNum;
    Result.reference:=refEdit.FloatNum;
    Result.createAll:=CreateAllCB.Checked;
  end;
end;

end.
