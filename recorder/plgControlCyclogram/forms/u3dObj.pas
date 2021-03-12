unit u3dObj;

interface


uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath, uDoubleCursor, uChartEvents, uLabel,
  uRecorderEvents, ubaseObj, uEditProfileFrm, uControlWarnFrm,
  uRTrig, uRCFunc, ubasealg, uBuffTrend1d, utextlabel, tags,
  PluginClass,
  ImgList, usetlist, upage,
  uCommonTypes,
  OpenGL,
  math,
  uObject, uNodeObject,
  uHardwareMath,
  uLight,
  uglfrmedit,
  uObjCtrFrame,
  uTrfrmToolsFrame,
  ComObj,
  uBaseGlComponent,
  uBasecamera,
  uSceneMng;

type
  TObjFrm3d = class(TRecFrm)
    GL: cBaseGlComponent;
    ToolsGB: TGroupBox;
    procedure GLInitScene(Sender: TObject);
  private
    m_TransformToolsFrame:TTrfrmToolsFrame;
    fshowtools:boolean;
  public
    airplane: cnodeobject;
  private
    // инициаци€ сцены
    procedure initComponents;
    procedure RBtnClick(Sender: TObject);
  protected
    procedure createevents;
    procedure destroyevents;
    procedure UpdateView;
    procedure updateData;
    procedure doStart;
  protected
    procedure SetShowTools(b:boolean);
    procedure WndProc(var Message: TMessage); override;
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
    procedure linkFrames;
  public
    property ShowTools:boolean read fShowTools write SetShowTools;
  end;

  IObjFrm3d = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cObjFrm3dFactory = class(cRecBasicFactory)
  private
    m_counter: integer;
  protected
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
  public
    procedure doAfterLoad; override;
    procedure doUpdateData(sender: tobject);
    procedure doChangeRState(sender: tobject);
    procedure doStart;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;


var
  ObjFrm3d: TObjFrm3d;
  g_ObjFrm3dFactory: cObjFrm3dFactory;

const
  c_Pic = '3DPIC';
  c_Name = '3d формул€р';
  c_defXSize = 400;
  c_defYSize = 400;

  // ctrl+shift+G
  // ['{C7E9BC06-C4A6-4466-A2F0-C1FCDF4EEBB6}']
  IID_3DFRM: TGuid = (D1: $C7E9BC06; D2: $C4A6; D3: $4466; D4: ($A2, $F0, $C1, $FC, $DF, $4E, $EB, $B6));


implementation

{$R *.dfm}

{ TObjFrm3d }
procedure TObjFrm3d.LinkFrames;
begin
  // линкуем фрейм
  m_TransformToolsFrame:=TTrfrmToolsFrame.Create(ToolsGB);
  m_TransformToolsFrame.Align:=alClient;
  m_TransformToolsFrame.Parent :=ToolsGB;
  m_TransformToolsFrame.lincScene(gl.mUI);
end;



constructor TObjFrm3d.create(Aowner: tcomponent);
begin
  inherited;
  GL.OnRBtn:=RBtnClick;
end;

procedure TObjFrm3d.createevents;
begin

end;

destructor TObjFrm3d.destroy;
begin

  inherited;
end;

procedure TObjFrm3d.destroyevents;
begin

end;

procedure TObjFrm3d.doStart;
begin

end;

procedure TObjFrm3d.initComponents;
var
  l:clight;
  c:cbasecamera;
begin
  if GL.mUI<>nil then
  begin
    gl.mUI.scene.LoadFile_Obr('airplane.OBR');
    airplane:=cnodeobject(gl.mUI.scene.getobj('line001'));
    airplane.name:='Airplane';
    //t:=cglturbine.create(GL);
    //t.Name:='glTurbine';
    //t.node.RotateNodeGlobal(0,-45,0);
    l:=GL.mUI.scene.lights.getlight(0);
    if l<>nil then
      l.position:=p3(1.2,1.5,-2.5);
    c:=gl.mUI.m_RenderScene.Getactivecamera;
    //c.target:=t.node.Node;
    //c.rotateAroundTarget(c.target,p3(1,0,0),-45);
    //t.getstage(0).bladecount:=45;
    c.target:=nil;
  end;
end;


procedure TObjFrm3d.GLInitScene(Sender: TObject);
begin
  initComponents;
  LinkFrames;
end;

procedure TObjFrm3d.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;
end;

procedure TObjFrm3d.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

procedure TObjFrm3d.SetShowTools(b: boolean);
begin
  fshowtools:=b;
end;

procedure TObjFrm3d.RBtnClick(Sender: TObject);
begin
  if ObjFrm3dEdit <> nil then
  begin
    ObjFrm3dEdit.Edit(self);
  end;
end;

procedure TObjFrm3d.updateData;
begin

end;

procedure TObjFrm3d.UpdateView;
begin

end;

procedure TObjFrm3d.WndProc(var Message: TMessage);
var
  str:string;
begin
  str:=inttostr(message.msg);
  case message.msg of
    WM_PARENTNOTIFY:
    begin
      //TExtRecorderPack(GPluginInstance).LogRecorderMessage(str+' WM_PARENTNOTIFY');
      case message.WParam of
        WM_RBUTTONUP:
        begin
          //CPoint pnt(GET_X_LPARAM(lParam),GET_Y_LPARAM(lParam));
          //::ClientToScreen(m_pForm->getHWND(),&pnt);
          //ScreenToClient(&pnt);
          //return SendMessage(wParam,MK_RBUTTON,MAKELPARAM(pnt.x,pnt.y));
        end;
      end;
    end;
  end;
  inherited;
end;

{ IObjFrm3d }

procedure IObjFrm3d.doClose;
begin
  inherited;
  m_lRefCount := 1;
end;

function IObjFrm3d.doCreateFrm: TRecFrm;
begin
  result := TObjFrm3d.create(nil);
end;

function IObjFrm3d.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function IObjFrm3d.doRepaint: boolean;
begin
  TObjFrm3d(m_pMasterWnd).UpdateView;
end;

{ cObjFrm3dFactory }

constructor cObjFrm3dFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_3DFRM;
  createevents;
end;

destructor cObjFrm3dFactory.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cObjFrm3dFactory.createevents;
begin
  addplgevent('c3DFrm_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('c3DFrmFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
end;

procedure cObjFrm3dFactory.destroyevents;
begin
  removeplgEvent(doUpdateData, c_RUpdateData);
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cObjFrm3dFactory.doAfterLoad;
begin
  inherited;

end;

procedure cObjFrm3dFactory.doChangeRState(sender: tobject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
      end;
    RSt_StopToView:
      begin
        doStart;
      end;
    RSt_StopToRec:
      begin
        doStart;
      end;
    RSt_ViewToStop:
      begin

      end;
    RSt_ViewToRec:
      begin

      end;
    RSt_initToRec:
      begin
        doStart;
      end;
    RSt_initToView:
      begin
        doStart;
      end;
    RSt_RecToStop:
      begin
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

function cObjFrm3dFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  result := IObjFrm3d.create();
end;

procedure cObjFrm3dFactory.doDestroyForms;
begin
  inherited;

end;

procedure cObjFrm3dFactory.doSetDefSize(var PSize: SIZE);
begin
  inherited;
  PSize.cx := c_defXSize;
  PSize.cy := c_defYSize;
end;

procedure cObjFrm3dFactory.doStart;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TObjFrm3d(Frm).doStart;
  end;
end;

procedure cObjFrm3dFactory.doUpdateData(sender: tobject);
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TObjFrm3d(Frm).updateData;
  end;
end;

end.
