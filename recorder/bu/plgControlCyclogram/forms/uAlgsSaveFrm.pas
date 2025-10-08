unit uAlgsSaveFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, uBtnListView, uControlWarnFrm,
  uComponentServises,
  ShellApi,
  uRCFunc;

type
  Dsc = class
    name:string;
    dx,
    x0:double;
    l:TWrkPoint;
  end;

  TSaveAlgsFrm = class(TForm)
    ActionPanel: TPanel;
    Label3: TLabel;
    BaseFolderEdit: TEdit;
    mdbBtn: TButton;
    Panel1: TPanel;
    SignalsLV: TBtnListView;
    procedure FormShow(Sender: TObject);
    procedure mdbBtnClick(Sender: TObject);
  private

  public

  end;

var
  g_SaveAlgsFrm: TSaveAlgsFrm;

implementation

{$R *.dfm}

procedure TSaveAlgsFrm.FormShow(Sender: TObject);
var
  i, j, sCount:integer;
  line:TWrkPoint;
  f, g:TCntrlWrnChart;
  names:TStringList;
  d:dsc;
  li:tlistitem;
begin
  sCount:=0;
  SignalsLV.Clear;
  for I := 0 to g_CtrlWrnFactory.Count - 1 do
  begin
    f:=TCntrlWrnChart(g_CtrlWrnFactory.GetFrm(i));
    for j := 0 to f.GraphCount - 1 do
    begin
      line:=f.getWP(j);
      if line.m_tr.count>0 then
      begin
        inc(sCount);
        li:=SignalsLV.Items.add;
        li.Data:=line;
        SignalsLV.SetSubItemByColumnName('№', IntToStr(sCount), li);
        SignalsLV.SetSubItemByColumnName('Имя сигнала', line.name, li);
      end;
      //d:=Dsc.Create;
      //d.name:=line.name;
      //d.dx:=line.m_dx;
      //d.x0:=line.
    end;
  end;
  LVChange(SignalsLV);
  BaseFolderEdit.Text:=extractfiledir(GetMeraFile)+'\res\Algs.mera';
end;

procedure TSaveAlgsFrm.mdbBtnClick(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
  line:TWrkPoint;
  dir:string;
begin
  dir:=extractfiledir(BaseFolderEdit.Text);
  g_CtrlWrnFactory.SaveMera(BaseFolderEdit.Text);
  ShellExecute(0,nil,pwidechar(BaseFolderEdit.Text),nil,nil, SW_HIDE);
end;

end.
