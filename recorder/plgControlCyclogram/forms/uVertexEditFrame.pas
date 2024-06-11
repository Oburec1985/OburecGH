unit uVertexEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, ExtCtrls, StdCtrls, Spin,
  ucommontypes,
  uSkin,
  uObject, uMeshObr, uShape;

type
  TVertexEditFrame = class(TFrame)
    TopPanel: TPanel;
    AlPanel: TPanel;
    VertLV: TBtnListView;
    TypeCB: TCheckBox;
    Edit1: TEdit;
    ObjNameLabel: TLabel;
    ChanCountSE: TSpinEdit;
    SensorsLabel: TLabel;
    SkinCB: TCheckBox;
  private
    m_curObj:cobject;
  public
    procedure Apply;
    procedure showObj(o:cObject);
  end;

implementation

{$R *.dfm}

{ TVertexEditFrame }

procedure TVertexEditFrame.Apply;
var
  skin:cskin;
begin
  if m_curObj<>nil then
  begin
    skin:=m_curObj.ModCreator.GetModificator('cSkin');
    if SkinCB.Checked then
    begin
      if skin=nil then
      begin
        skin:=m_curObj.ModCreator.CreateModificator('cSkin');

      end;
    end;
  end;
end;

procedure TVertexEditFrame.showObj(o: cObject);
var
  I, n: Integer;
  s:cShapeObj;
  l:tline;
  li:tlistitem;
  j: Integer;
  p3:point3;
  skin:cskin;
begin
  m_curObj:=o;
  if o is cshapeobj then
  begin
    s:=cShapeObj(o);
    VertLV.Clear;
    skin:=s.ModCreator.GetModificator('cSkin');
    if skin=nil then
    begin
      SkinCB.Checked:=false;
      exit;
    end;
    n:=0;
    for I := 0 to s.LineCount - 1 do
    begin
      l:=s.Lines[i];
      for j := 0 to length(l.data) - 1 do
      begin
        li:=VertLV.Items.Add;
        VertLV.SetSubItemByColumnName('¹',inttostr(n),li);
        p3:=l.data[j];
        VertLV.SetSubItemByColumnName('Pos.',p3ToStr(p3,3),li);
        VertLV.SetSubItemByColumnName('ID',inttostr(i)+'_'+inttostr(j),li);
        inc(n);
      end;
    end;
  end;
end;

end.
