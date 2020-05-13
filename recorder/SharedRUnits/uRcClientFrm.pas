unit uRcClientFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, uRcClient, ExtCtrls;

type
  TRcClientFrm = class(TForm)
    HostEdit: TEdit;
    HostLabel: TLabel;
    NameEdit: TEdit;
    NameLabel: TLabel;
    FolderEdit: TEdit;
    FolderLabel: TLabel;
    portRG: TRadioGroup;
    ApplyBtn: TButton;
    EditBtn: TButton;
    DelBtn: TButton;
    procedure portRGClick(Sender: TObject);
    procedure HostEditChange(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure DelBtnClick(Sender: TObject);
  public
    m_curConnection:TRConnection;
  private
    m_rcpan:cRegController;
    procedure updateFldname;
    function getport:integer;
  public
    procedure editConnection(c:TRConnection);
    procedure init(rcpan:cRegController);
  end;

var
  RcClientFrm: TRcClientFrm;

implementation

{$R *.dfm}

procedure TRcClientFrm.ApplyBtnClick(Sender: TObject);
begin
  m_curConnection:=m_rcpan.createConnection(NameEdit.text, FolderEdit.Text, HostEdit.Text, getport);
  close;
end;

procedure TRcClientFrm.DelBtnClick(Sender: TObject);
var
  i:integer;
begin
  if m_curConnection<>nil then
  begin
    i:=m_curConnection.RC_PAN.getConnectionIndex(m_curConnection);
    m_curConnection.RC_PAN.Delete(i);
    m_curConnection.destroy;
    m_curConnection:=nil;
  end;
end;

procedure TRcClientFrm.EditBtnClick(Sender: TObject);
begin
  if m_curConnection<>nil then
  begin
    m_curConnection.name:=NameEdit.text;
    m_curConnection.folder:=FolderEdit.text;
    m_curConnection.Address:=HostEdit.text;
    m_curConnection.port:=getport;
  end;
end;

procedure TRcClientFrm.editConnection(c: TRConnection);
begin
  m_curConnection:=c;
  if c<>nil then
  begin
    HostEdit.Text:=c.Address;
    case c.port of
     DEF_PORT_MR300:portRG.ItemIndex:=1;
     DEF_PORT_RECORDER:portRG.ItemIndex:=0;
     DEF_PORT_VIDEOREG:portRG.ItemIndex:=2;
    end;
    NameEdit.TEXT:=C.name;
    FolderEdit.text:=c.folder;
  end;
  show;
end;

function TRcClientFrm.getport: integer;
begin
  case portRG.ItemIndex of
    0:result:=DEF_PORT_RECORDER;
    1:result:=DEF_PORT_MR300;
    2:result:=DEF_PORT_VIDEOREG;
  end;
end;

procedure TRcClientFrm.HostEditChange(Sender: TObject);
begin
  updateFldname;
end;

procedure TRcClientFrm.init(rcpan: cRegController);
begin
  m_rcpan:=rcpan;
end;

procedure TRcClientFrm.portRGClick(Sender: TObject);
begin
  updateFldname;
end;

procedure TRcClientFrm.updateFldname;
begin
  if portrg.ItemIndex=0 then
  begin
    FolderEdit.Text:=HostEdit.Text+'_Rc';
  end
  else
  begin
    if portrg.ItemIndex=1 then
    begin
      FolderEdit.Text:=HostEdit.Text+'_MR300';
    end
    else
    begin
      if portrg.ItemIndex=2 then
      begin
        FolderEdit.Text:=HostEdit.Text+'_Video';
      end
    end;
  end;
  nameedit.Text:= FolderEdit.Text;
end;

end.
