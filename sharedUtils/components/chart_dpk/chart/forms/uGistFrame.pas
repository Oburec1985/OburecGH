unit uGistFrame;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uTrend, ucommonMath, uGistogram,
  uMarkers, Dialogs, uDrawObjFrame, StdCtrls, ExtCtrls, Spin,
  DCL_MYOWN, uSpin, opengl;
  
type
  TGistFrame = class(TFrame)
    BackGroundColorDialog: TColorDialog;
    ColSizeLabel: TLabel;
    ColSizeSE: TSpinEdit;
    GistTypeRG: TRadioGroup;
    MarkerColorBox: TPanel;
    MarkerColorLabel: TLabel;
    MarkerSizeLabel: TLabel;
    MarkerSizeSE: TSpinEdit;
    MarkerTypeRG: TRadioGroup;
    procedure MarkerColorBoxClick(Sender: TObject);
  private
    curobj:cGistogram;
    m:cmarkerlist;
  public
    procedure SetObj(obj:cGistogram);
    function GetObj:cGistogram;
  end;

implementation

{$R *.dfm}
procedure TGistFrame.MarkerColorBoxClick(Sender: TObject);
begin
  if BackGroundColorDialog.Execute then
    tpanel(sender).color:=BackGroundColorDialog.Color;
end;

procedure TGistFrame.SetObj(obj:cGistogram);
begin
  curobj:=obj;
  m:=cmarkerlist(obj.getChild(0));
  if m<>nil then
  begin
    MarkerColorBox.Color:=rgbtoint(m.color);
    case m.MarkerType of
      c_rectMarker: MarkerTypeRG.ItemIndex:=0;
      c_BoundRectMarker: MarkerTypeRG.ItemIndex:=1;
      c_EmptyRectMarker: MarkerTypeRG.ItemIndex:=2;
      c_pointMarker: MarkerTypeRG.ItemIndex:=3;
    end;
    markersizese.Value:=m.pixelsize.Y;    
  end;
  case obj.DrawType of
    c_Collumn: GistTypeRG.ItemIndex:=0;
    c_Rect: GistTypeRG.ItemIndex:=1;
  end;
  colsizese.Value:=obj.size.y;
  Refresh;
end;

function TGistFrame.GetObj:cGistogram;
begin
  if m<>nil then
  begin
    m.color:=inttorgb(MarkerColorBox.color);
    case MarkerTypeRG.ItemIndex of
      0: m.MarkerType:=c_rectMarker;
      1: m.MarkerType:=c_BoundRectMarker;
      2: m.MarkerType:=c_EmptyRectMarker;
      3: m.MarkerType:=c_pointMarker;
    end;
    m.pixelsize:=point(m.pixelsize.x,markersizese.Value);
  end;
  case GistTypeRG.ItemIndex of
    0: curobj.DrawType:=c_Collumn;
    1: curobj.DrawType:=c_Rect;
  end;
  curobj.size:=point(curobj.size.x,colsizese.Value);
end;


end.
