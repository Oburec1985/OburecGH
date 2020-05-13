unit uEditListFrame;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  Dialogs, ComCtrls, ImgList, ToolWin, uCreateObjDlg, uBldEng, ubldobj
  ;

type
  TEditEngListFrame = class(TFrame)
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    CreateObjBtn: TToolButton;
    DelObjBtn: TToolButton;
    procedure CreateObjBtnClick(Sender: TObject);
    procedure DelObjBtnClick(Sender: TObject);
  private
    eng:cbldeng;
    curobj:cbldobj;
  public
    procedure setobj(obj:cbldobj);
    procedure lincEngine(engine:cbldeng);
    // удаление объекта
    procedure deleteobj(obj:cbldobj);
  end;

implementation

{$R *.dfm}
procedure TEditEngListFrame.setobj(obj:cbldobj);
begin
  curobj:=obj;
end;

procedure TEditEngListFrame.deleteobj(obj:cbldobj);
begin
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

procedure TEditEngListFrame.CreateObjBtnClick(Sender: TObject);
begin
  CreateObjDlg.ShowModal;
end;

end.
