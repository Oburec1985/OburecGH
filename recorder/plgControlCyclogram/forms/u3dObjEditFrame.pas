unit u3dObjEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uRcCtrls, uSpin,
  ucommontypes,
  uComponentServises,
  MathFunction,
  uMatrix,
  uSkin, uUI, usceneMng, uRender, uGlEventTypes,
  uNodeObject,
  uObject,
  uMeshObr,
  uShape,
  uBaseDeformer,
  DCL_MYOWN,
  uRcFunc,
  u3dMoveEngine;

type
  TObjEditFrame = class(TFrame)
    PosGB: TGroupBox;
    XposSE: TFloatSpinEdit;
    YposSE: TFloatSpinEdit;
    ZposSE: TFloatSpinEdit;
    XposLab: TLabel;
    YposLab: TLabel;
    ZposLab: TLabel;
    XTagCB: TRcComboBox;
    YTagCB: TRcComboBox;
    ZTagCB: TRcComboBox;
    OrientationGB: TGroupBox;
    XrotLab: TLabel;
    YrotLab: TLabel;
    ZrotLab: TLabel;
    XrotSE: TFloatSpinEdit;
    YrotSE: TFloatSpinEdit;
    ZrotSE: TFloatSpinEdit;
    XrotTagCB: TRcComboBox;
    YrotTagCB: TRcComboBox;
    ZrotTagCB: TRcComboBox;
  protected
    m_curObj: cNodeObject;
  private
  public
    procedure initframe;
    procedure SetEditObj(o: cnodeobject);
  end;

implementation

{$R *.dfm}
{ TObjEditFrame }

procedure TObjEditFrame.initframe;
begin
  XTagCB.updateTagsList;
  YTagCB.updateTagsList;
  ZTagCB.updateTagsList;
  XrotTagCB.updateTagsList;
  YrotTagCB.updateTagsList;
  ZrotTagCB.updateTagsList;
end;

procedure TObjEditFrame.SetEditObj(o: cnodeobject);
var
  p3:point3;
  m:MatrixGl;
begin
  initframe;

  m_curObj := o;
  p3:=o.position;
  XposSE.Value:=p3.x;
  YposSE.Value:=p3.y;
  ZposSE.Value:=p3.z;

  m:=o.Node.restm;
  p3:=MatrixglToEuler(m);
  XrotSE.Value:=p3.x;
  YrotSE.Value:=p3.y;
  ZrotSE.Value:=p3.z;

  if o is c3dMoveObj then
  begin
    XrotTagCB.SetTagName(c3dMoveObj(o).RotXTag.tagname);
    YrotTagCB.SetTagName(c3dMoveObj(o).RotYTag.tagname);
    ZrotTagCB.SetTagName(c3dMoveObj(o).RotZTag.tagname);
  end;
end;

end.
