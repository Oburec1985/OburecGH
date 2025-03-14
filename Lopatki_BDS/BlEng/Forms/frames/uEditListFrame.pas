unit uEditListFrame;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  Dialogs, ComCtrls, ImgList, ToolWin, uCreateObjDlg, uBldEng, ubldobj,
  ueventlist, uchart, uPlat
  ;

type
  TEditEngListFrame = class(TFrame)
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    CreateObjBtn: TToolButton;
    DelObjBtn: TToolButton;
    ClearAll: TToolButton;
    ToolButton1: TToolButton;
    procedure CreateObjBtnClick(Sender: TObject);
    procedure DelObjBtnClick(Sender: TObject);
    procedure ClearAllClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    events:ceventlist;
    eng:cbldeng;
    curobj:cbldobj;
  public
    procedure lincevents(e:ceventlist);
    procedure setobj(obj:cbldobj);
    procedure lincEngine(engine:cbldeng);
    // �������� �������
    procedure deleteobj(obj:cbldobj);
  end;

implementation

{$R *.dfm}
procedure TEditEngListFrame.setobj(obj:cbldobj);
begin
  curobj:=obj;
end;

procedure TEditEngListFrame.ToolButton1Click(Sender: TObject);
begin
  cplatslist(eng.HardWare).Search;
end;

procedure TEditEngListFrame.deleteobj(obj:cbldobj);
begin
  if obj<>nil then
    obj.destroy;
end;

procedure TEditEngListFrame.DelObjBtnClick(Sender: TObject);
begin
  deleteobj(curobj);
end;

procedure TEditEngListFrame.lincEngine(engine:cbldeng);
begin
  eng:=engine;
  CreateObjDlg.linceng(eng);
end;

procedure TEditEngListFrame.ClearAllClick(Sender: TObject);
begin
  eng.clear;
end;

procedure TEditEngListFrame.CreateObjBtnClick(Sender: TObject);
begin
  curobj:=nil;
  CreateObjDlg.ShowModal;
end;

procedure TEditEngListFrame.lincevents(e:ceventlist);
begin
  events:=e;
end;

end.
