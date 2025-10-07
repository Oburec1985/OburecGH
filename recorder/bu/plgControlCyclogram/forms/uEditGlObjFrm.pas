unit uEditGlObjFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uRcCtrls, uTagsListFrame,
  uNodeObject,
  ueventlist,
  uMNode,
  uQNode,
  u3dTypes,
  uGlEventTypes,
  ExtCtrls;

type
  TEditGLObjFrm = class(TForm)
    RightPanel: TPanel;
    TagsListFrame1: TTagsListFrame;
    Panel1: TPanel;
    NameEdit: TEdit;
    NameLabel: TLabel;
    BottomPanel: TGroupBox;
    TypeCB: TComboBox;
    Xcb: TRcComboBox;
    Ycb: TRcComboBox;
    Zcb: TRcComboBox;
    XTagLabel: TLabel;
    YTagLabel: TLabel;
    ZTagLabel: TLabel;
    ControlCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    m_select:cNodeObject;
  public
    procedure setObj(o:cNodeObject);
  end;

var
  EditGLObjFrm: TEditGLObjFrm;

implementation

{$R *.dfm}

procedure TEditGLObjFrm.FormCreate(Sender: TObject);
begin
  TagsListFrame1.ShowChannels;
  xcb.updateTagsList;
  ycb.updateTagsList;
  zcb.updateTagsList;
end;

procedure TEditGLObjFrm.setObj(o: cNodeObject);
begin
  m_select:=o;
  NameEdit.Text:=o.name;
end;

end.
