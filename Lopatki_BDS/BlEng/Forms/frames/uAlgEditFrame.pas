unit uAlgEditFrame;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  ExtCtrls, CommonOptsFrame, StdCtrls,
  ubldeng, uBaseBldAlg, uDensityAlg, uMultiSensor, uPairShape,
  uRestoreVibrationAlg, uTrendAlg, uPairShapeFrame, uEventList;

type
  TAlgEditFrame = class(TFrame)
    CommonAlgOptsGB: TGroupBox;
    SpecPropAlgGB: TGroupBox;
    Splitter1: TSplitter;
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    procedure BaseAlgOptsFrame1SelectSensorsBtnClick(Sender: TObject);
  private
    pairShapeFrame:TpairShapeFrame;
    alg:cbasebldalg;
    events:ceventlist;
  private
    procedure createFrames;
    procedure createevents;
    procedure setVisible;
    function createOpts(a:cbasebldalg):cbaseOpts;
  public
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
    procedure setAlg(a:cbasebldalg);
    procedure Apply;
  end;

implementation

{$R *.dfm}
function TAlgEditFrame.createOpts(a:cbasebldalg):cbaseOpts;
begin
  result:=a.CreateOpts;
end;

procedure TAlgEditFrame.setAlg(a:cbasebldalg);
var
  o:cbaseopts;
begin
  alg:=a;
  setVisible;
  if a<>nil then
  begin
    o:=createOpts(a);
    o.eng:=a.eng;
    BaseAlgOptsFrame1.SetOpts(a.curtaho,a.sensorsList,o);
    if a is cPairShape then
    begin
      pairshapeframe.setopts(a.curtaho,a.sensorsList,cpairshapeopts(o));
    end;
    o.Destroy;
  end;
end;

procedure TAlgEditFrame.createFrames;
begin
  pairShapeFrame:=tpairShapeFrame.Create(self);
  pairShapeFrame.Parent:=SpecPropAlgGB;
  pairShapeFrame.events:=events;
end;

procedure TAlgEditFrame.setVisible;
begin
  if alg is cpairshape then
  begin
    pairShapeFrame.Visible:=true;
  end
  else
  begin
    pairShapeFrame.Visible:=false;
  end;
end;

procedure TAlgEditFrame.BaseAlgOptsFrame1SelectSensorsBtnClick(Sender: TObject);
begin
  BaseAlgOptsFrame1.SelectSensorsBtnClick(Sender);
end;

constructor TAlgEditFrame.create(aowner:tcomponent);
begin
  inherited;
  events:=ceventlist.create(self,true);
  createFrames;
  createevents;
  setVisible;
end;

destructor TAlgEditFrame.destroy;
begin
  events.destroy;
  inherited;
end;

procedure TAlgEditFrame.createevents;
begin
  BaseAlgOptsFrame1.events:=events;
end;

procedure TAlgEditFrame.Apply;
var
  opts:cBaseOpts;
begin
  if alg<>nil then
  begin
    opts:=alg.CreateOpts;
    BaseAlgOptsFrame1.GetOpts(opts);
    if alg is cPairShape then
    begin
      pairshapeframe.getopts(cpairshapeopts(opts));
    end;
    alg.getOpts(opts);
    alg.prepare;
    opts.destroy;
  end;
end;

end.
