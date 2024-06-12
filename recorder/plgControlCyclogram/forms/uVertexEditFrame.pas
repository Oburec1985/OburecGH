unit uVertexEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, ExtCtrls, StdCtrls, Spin,
  ucommontypes,
  uSkin, uUI, usceneMng, uRender, uGlEventTypes,
  uObject, uMeshObr, uShape, DCL_MYOWN, uSpin;

type
  TVertexEditFrame = class(TFrame)
    TopPanel: TPanel;
    AlPanel: TPanel;
    VertLV: TBtnListView;
    TypeCB: TCheckBox;
    NameEdit: TEdit;
    ObjNameLabel: TLabel;
    ChanCountSE: TSpinEdit;
    SensorsLabel: TLabel;
    SkinCB: TCheckBox;
    GroupBox1: TGroupBox;
    PNameLabel: TLabel;
    PointNumEdit: TIntEdit;
    WeightLabel: TLabel;
    PointWeight: TFloatSpinEdit;
    procedure VertLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  public
    m_ui:cUI;
  private
    finit:Boolean;
    m_curObj:cobject;
  protected
    procedure OnSelectVertex(sender:tobject);
  public
    procedure createevents;
    procedure destroyevents;
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
    skin:=cskin(m_curObj.ModCreator.GetModificator('cSkin'));
    if SkinCB.Checked then
    begin
      if skin=nil then
      begin
        skin:=cskin(m_curObj.ModCreator.CreateModificator('cSkin'));

      end;
    end;
  end;
end;

procedure TVertexEditFrame.createevents;
begin
  m_ui.eventlist.AddEvent('TVertexEditFrame_OnSelVert',E_glSelectMeshPoint,OnSelectVertex);
end;

procedure TVertexEditFrame.destroyevents;
begin
  m_ui.eventlist.removeEvent(OnSelectVertex, E_glSelectMeshPoint);
end;

procedure TVertexEditFrame.OnSelectVertex(sender: tobject);
var
  p:tpoint;
  s,s1:string;
  I: Integer;
  li:tlistitem;
begin
  if m_curObj<>nil then
  begin
    if m_curObj is cshapeObj then
    begin
      p:=cshapeObj(m_curObj).selectPoints;
      s:=inttostr(p.x)+'_'+inttostr(p.Y);
      for I := 0 to VertLV.items.Count - 1 do
      begin
        li:=VertLV.Items[i];
        s1:=li.SubItems[1];
        if s=s1 then
        begin
          VertLV.clearcolors;
          VertLV.addColorItem(li.Index, clHighlight);
          VertLV.Invalidate;
          break;
        end;
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
  NameEdit.Text:=m_curObj.name;
  VertLV.Clear;
  if m_curObj is cshapeobj then
  begin
    n:=0;
    s:=cShapeObj(o);
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
  m_ui:=cui(cRender(cscene(o.getmng).render).ui);
  if o is cshapeobj then
  begin
    skin:=cskin(s.ModCreator.GetModificator('cSkin'));
    if skin=nil then
    begin
      SkinCB.Checked:=false;
      exit;
    end;
  end;
end;

procedure TVertexEditFrame.VertLVDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if True then

end;

end.
