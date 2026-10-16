unit uRecorder3dPrimitivePropertiesFrame;
{$mode objfpc}{$H+}
{$codepage UTF8}
interface
uses Classes,Forms,Controls,StdCtrls,Spin,u3dPrimitives;
type
  TRecorder3dPrimitivePropertiesFrame=class(TFrame)
  published
    lblShape,lblSizeX,lblSizeY,lblSizeZ:TLabel;
    lblIterationsX,lblIterationsY,lblIterationsZ:TLabel;
    cbShape:TComboBox;
    cbDrawPointNumbers:TCheckBox;
    seSizeX,seSizeY,seSizeZ:TFloatSpinEdit;
    seIterationsX,seIterationsY,seIterationsZ:TSpinEdit;
    procedure ControlChange(Sender:TObject);
  private
    fLoading:Boolean;
    fOnChanged:TNotifyEvent;
  public
    procedure LoadSpec(const ASpec:T3dPrimitiveSpec);
    procedure StoreSpec(var ASpec:T3dPrimitiveSpec);
    property OnChanged:TNotifyEvent read fOnChanged write fOnChanged;
  end;
implementation
{$R *.lfm}
procedure TRecorder3dPrimitivePropertiesFrame.ControlChange(Sender:TObject);
begin
  if (not fLoading) and Assigned(fOnChanged) then fOnChanged(Self);
end;
procedure TRecorder3dPrimitivePropertiesFrame.LoadSpec(const ASpec:T3dPrimitiveSpec);
begin
  fLoading:=True;
  try
    cbShape.ItemIndex:=Ord(ASpec.PointCloudShape);
    cbShape.Visible:=ASpec.Kind=pkPointCloud; lblShape.Visible:=cbShape.Visible;
    cbDrawPointNumbers.Visible:=ASpec.Kind=pkPointCloud;
    cbDrawPointNumbers.Checked:=ASpec.DrawPointNumbers;
    seSizeX.Value:=ASpec.SizeX; seSizeY.Value:=ASpec.SizeY; seSizeZ.Value:=ASpec.SizeZ;
    if ASpec.Kind=pkPointCloud then
    begin
      seIterationsX.Value:=ASpec.IterationsX;
      seIterationsY.Value:=ASpec.IterationsY;
      seIterationsZ.Value:=ASpec.IterationsZ;
    end
    else
    begin
      seIterationsX.Value:=ASpec.Iterations;
      seIterationsY.Value:=ASpec.CrossSectionIterations;
      seIterationsZ.Value:=ASpec.Iterations;
    end;
    lblIterationsY.Visible:=(ASpec.Kind=pkPointCloud) or (ASpec.Kind=pkBeam);
    seIterationsY.Visible:=lblIterationsY.Visible;
    lblIterationsZ.Visible:=ASpec.Kind=pkPointCloud;
    seIterationsZ.Visible:=lblIterationsZ.Visible;
  finally fLoading:=False end;
end;
procedure TRecorder3dPrimitivePropertiesFrame.StoreSpec(var ASpec:T3dPrimitiveSpec);
begin
  if cbShape.ItemIndex>=0 then ASpec.PointCloudShape:=T3dPointCloudShape(cbShape.ItemIndex);
  if ASpec.Kind=pkPointCloud then
    ASpec.DrawPointNumbers:=cbDrawPointNumbers.Checked;
  ASpec.SizeX:=seSizeX.Value; ASpec.SizeY:=seSizeY.Value; ASpec.SizeZ:=seSizeZ.Value;
  if ASpec.Kind=pkPointCloud then
  begin
    ASpec.IterationsX:=seIterationsX.Value;
    ASpec.IterationsY:=seIterationsY.Value;
    ASpec.IterationsZ:=seIterationsZ.Value;
  end
  else
  begin
    ASpec.Iterations:=seIterationsX.Value;
    if ASpec.Kind=pkBeam then ASpec.CrossSectionIterations:=seIterationsY.Value;
  end;
end;
end.
