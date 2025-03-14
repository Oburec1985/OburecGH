unit uGlTurbineFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  Dialogs, uBaseGlComponent, uglTurbine, ExtCtrls, uLight, uCommonTypes,
  uBldPathMng, uBasecamera, uScenemng, uObjCtrFrame, StdCtrls, DCL_MYOWN;

type
  TglTurbineFrame = class(TFrame)
    EditTurbGB: TGroupBox;
    ApplyBtn: TButton;
    BlCountLabel: TLabel;
    StCountLabel: TLabel;
    cBaseGlComponent1: cBaseGlComponent;
    BlCountIE: TIntEdit;
    StCountIE: TIntEdit;
    procedure cBaseGlComponent1InitScene(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
  private
    init:boolean;
    t:cglturbine;
    fr:TCtrlViewFrame;
  private
    procedure initComponents;
  public
    procedure ChangePhase(dPhase:single);
    procedure initres(pathMng:cBldPathMng);
    constructor create(aowner:tcomponent);override;
  end;

implementation
{$R *.dfm}

procedure TglTurbineFrame.initComponents;
var
  l:clight;
  c:cbasecamera;
  sc:cscene;
begin
  if not init then
  begin
    if cBaseGlComponent1.mUI<>nil then
    begin
      sc:=cBaseGlComponent1.mUI.m_RenderScene.scene;
      t:=cglturbine.create(cBaseGlComponent1);
      t.Name:='glTurbine';
      t.node.RotateNodeGlobal(0,-45,0);
      init:=true;
      l:=sc.lights.getlight(0);
      l.position:=p3(1.2,1.5,-2.5);
      c:=sc.getactivecamera;
      c.target:=t.node.Node;
      c.rotateAroundTarget(c.target,p3(1,0,0),-45);
      t.getstage(0).bladecount:=10;
      // ������� �����
      fr.lincScene(cBaseGlComponent1.mUI);
    end;
  end;
end;

procedure TglTurbineFrame.ApplyBtnClick(Sender: TObject);
var
  st:cglStage;
begin
  st:=t.GetStage(0);
  st.bladecount:=BlCountIE.IntNum;
end;

procedure TglTurbineFrame.ChangePhase(dPhase:single);
begin
  if t<>nil then
    t.phase:=t.phase+dPhase;
end;

procedure TglTurbineFrame.cBaseGlComponent1InitScene(Sender: TObject);
begin
  initComponents;
end;

constructor TglTurbineFrame.create(aowner:tcomponent);
begin
  inherited create(aowner);
  fr:=TCtrlViewFrame.create(self);
  fr.Parent:=self;
  fr.Align:=alBottom;
  fr.Height:=40;
  init:=false;
end;

procedure TglTurbineFrame.initRes(pathMng:cBldPathMng);
var
  res:string;
begin
  res:=pathMng.findCfgPathFile('resources.ini');
  cBaseGlComponent1.resources:=res;
end;


end.
