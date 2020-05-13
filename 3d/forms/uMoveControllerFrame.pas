unit uMoveControllerFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, uBtnListView, DCL_MYOWN, ToolWin, ImgList,
  uMoveController, uUI
  //,uCompFunc
  ;

type
  TMoveControllerFrame = class(TFrame)
    CommonGroupBox: TGroupBox;
    KeysGroupBox: TGroupBox;
    KeyList: TBtnListView;
    FrameCountLabel: TLabel;
    FrameCountIntEdit: TIntEdit;
    FPSIntEdit: TIntEdit;
    TPFIntEdit: TIntEdit;
    FrameRateLabel: TLabel;
    TickPerSecLabel: TLabel;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    RemoveKeyBtn: TToolButton;
    AddKeyBtn: TToolButton;
    TimeIntEdit: TIntEdit;
    TimeLabel: TLabel;
    KeyPropertyGroupBox: TGroupBox;
    IntEdit1: TIntEdit;
    KeyTimeLabel: TLabel;
    KeyTypeLabel: TLabel;
    KeyTypeComboBox: TComboBox;
    MLV: TBtnListView;
    StateMLabel: TLabel;
    Label1: TLabel;
    QLV: TBtnListView;
    procedure KeyListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    ui:cui;
    c:cMoveController;
    k:ckey;
  private
    procedure showKeys;
    procedure showCommonProperty;
    procedure showKey;
    procedure SetKey;
  public
    procedure showControler(p_c:cMoveController);
    procedure lincScene(p_ui:cui);
  end;

  const
    ColNumber = '№ ключа';
    ColTime = 'Время';
    ColType = 'Тип';

implementation

{$R *.dfm}

procedure TMoveControllerFrame.showCommonProperty;
begin
  FrameCountIntEdit.IntNum:=c.framecount;
  FPSIntEdit.IntNum:=trunc(c.tps/c.tpf);
  TPFIntEdit.IntNum:=c.tpf;
  TimeIntEdit.IntNum:=c.t;
end;

procedure TMoveControllerFrame.showKeys;
var key:ckey;
    i:integer;
    li:tlistitem;
begin
  keylist.Clear;
  for I := 0 to c.keys.Count - 1 do
  begin
    key:=c.keys.key[i];
    li:=keylist.Items.Add;
    keylist.SetSubItemByColumnName(ColNumber,inttostr(i+1),li);
    keylist.SetSubItemByColumnName(ColTime,inttostr(key.t),li);
    keylist.SetSubItemByColumnName(ColType,key.keyTypeString,li);
  end;
end;

procedure TMoveControllerFrame.showKey;
begin
  //SetM(k.m,mlv);
  //SetQ(k.q,qlv);
end;

procedure TMoveControllerFrame.SetKey;
begin
  //k.q:=Getq(qlv);
  //k.m:=Getm(mlv);
end;

procedure TMoveControllerFrame.showControler(p_c:cMoveController);
begin
  c:=p_c;
  showCommonProperty;
  showKeys;
end;

procedure TMoveControllerFrame.KeyListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  k:=c.keys.key[item.Index];
  showKey;
end;

procedure TMoveControllerFrame.lincScene(p_ui:cui);
begin
  ui:=p_ui;
end;

end.
