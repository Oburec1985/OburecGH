unit EditSignalPathFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uWPproc, ComCtrls, uBtnListView;

type
  TSignalPathFrm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    DstPath: TEdit;
    CancelBtn: TButton;
    AddBtn: TButton;
    SrcPath: TComboBox;
    Button1: TButton;
  private
    m_wp:cWPObjMng;
  private
    procedure UpdateSrc;
  public
    procedure InitDlg(wp:cWPObjMng);
    procedure EditSignal(o:cOperObj);
  end;

var
  SignalPathFrm: TSignalPathFrm;

implementation

{$R *.dfm}
procedure TSignalPathFrm.InitDlg(wp:cWPObjMng);
var
  I: Integer;
  s:csrc;
begin
  m_wp:=wp;
  UpdateSrc;
end;

procedure TSignalPathFrm.UpdateSrc;
var
  I: Integer;
  s:csrc;
begin
  srcPath.Clear;
  for I := 0 to m_wp.SrcCount - 1 do
  begin
    srcPath.Items.Add(m_wp.GetSrc(i).name);
  end;
  if srcpath.Items.Count>0 then
  begin
    srcpath.ItemIndex:=0;
  end;
end;

procedure TSignalPathFrm.EditSignal(o:cOperObj);
begin
  UpdateSrc;
  srcpath.Text:=o.SrcDir;
  dstPath.Text:=o.DstDir;
  if showmodal=mrok then
  begin
    o.DstDir:=DstPath.Text;
    o.SrcDir:=SrcPath.Text;
  end;
end;

end.
