unit uSelectAlgDlg;

interface

uses
  Windows, SysUtils, Classes, Forms, uchart, uBldObjList, uComponentServises,
  uSelAlgFrame, ImgList, ComCtrls, ToolWin, ubldobj, Controls;

type
  TSelAlgDlg = class(TForm)
    SelectAlgFrame1: TSelectAlgFrame;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    curobjlist:cbldobjlist;
    curchart:cchart;

  public
    procedure getobj(obj:cbldobjlist);
    procedure getChart(chart:cchart);
    function showmodal:integer;
  end;

var
  SelAlgDlg: TSelAlgDlg;

implementation

{$R *.dfm}

procedure TSelAlgDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

procedure TSelAlgDlg.getChart(chart:cchart);
begin
  curchart:=chart;
end;

procedure TSelAlgDlg.getobj(obj:cbldobjlist);
begin
  curobjlist:=obj;
end;

function TSelAlgDlg.showmodal:integer;
begin
  SelectAlgFrame1.getObj(curobjlist);
  SelectAlgFrame1.getChart(curchart);
  LVChange(SelectAlgFrame1.SelAlgLV);
  if inherited showmodal=mrok then
  begin
    SelectAlgFrame1.apply;
  end;
end;

end.
