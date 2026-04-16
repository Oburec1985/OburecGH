unit uSelectPathForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, uWPProc, ExtCtrls, uChart, ImgList, posbase;

type
  TSelectPathFrm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    StartLabel: TLabel;
    StopLabel: TLabel;
    I1Label: TLabel;
    I2Label: TLabel;
    FolderLabel: TLabel;
    NameLabel: TLabel;
    FloatEdit1: TFloatEdit;
    FloatEdit2: TFloatEdit;
    IntEdit1: TIntEdit;
    IntEdit2: TIntEdit;
    FolderCB: TComboBox;
    NameCB: TComboBox;
    Label1: TLabel;
    cChart1: cChart;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    procedure NameCBChange(Sender: TObject);
  private
    mng:cWPObjMng;
  public
    procedure Linc(p_mng:cWPObjMng);
    procedure ShowFiles;
    procedure ShowSignals(s:csrc);
  end;

var
  SelectPathFrm: TSelectPathFrm;

implementation

{$R *.dfm}

procedure TSelectPathFrm.ShowSignals(s:csrc);
var
  I: Integer;
  sig:cwpsignal;
begin
  namecb.Clear;
  for I := 0 to s.childCount - 1 do
  begin
    sig:=s.getSignalObj(i);
    namecb.AddItem(sig.Name, sig);
  end;
  if s.childCount<>0 then
  begin
    namecb.ItemIndex:=0;
  end;
end;

procedure TSelectPathFrm.Linc(p_mng:cWPObjMng);
begin
  mng:=p_mng;
end;

procedure TSelectPathFrm.NameCBChange(Sender: TObject);
var
  obj:csrc;
begin
  if foldercb.ItemIndex>-1 then
  begin
    obj:=csrc(foldercb.Items.Objects[foldercb.ItemIndex]);
    ShowSignals(obj);
  end;
end;

procedure TSelectPathFrm.ShowFiles;
var
  src:csrc;
  I: Integer;
begin
  folderCb.Clear;
  if mng<>nil then
  begin
    for I := 0 to mng.SrcCount - 1 do
    begin
      src:=mng.GetSrc(i);
      folderCb.AddItem(src.name,src);
    end;
  end;
  if mng.SrcCount<>0 then
  begin
    folderCb.ItemIndex:=0;
  end;
end;

end.
