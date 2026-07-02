unit uFloatEdit;

interface
uses
  ubaseobj, udrawobj, uTrend, uCommonTypes, opengl, uOglExpFunc, classes,
  stdctrls,
  Graphics, windows, uAxis, messages, utext, sysutils, uEventList, mathfunction,
  uChartEvents, uPoint, dialogs, types, controls, forms, uAlignEdit,
  uDoubleCursor, usimpleobjects, NativeXML, uBasePage, Clipbrd, uEdit;

type

  cFloatEdit = class(cEdit)
  protected
    fValue:double;
  protected
    procedure SetValue(v:double);
  public
    property Value:double read fValue write setValue;
    constructor create;override;
  end;

implementation

procedure cFloatEdit.SetValue(v:double);
begin
  fValue:=v;
  Text:=FloatToStr(v);
end;

constructor cFloatEdit.create;
begin
  inherited;
  value:=0;
end;

end.
