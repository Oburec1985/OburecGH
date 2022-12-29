unit uGlFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  inifiles,
  StdCtrls,
  ExtCtrls,
  recorder,
  activex,
  uExtFrm,
  uglTurbine,
  uLight,
  uCommonTypes,
  uglfrmedit,
  uObjCtrFrame,
  uTrfrmToolsFrame,
  ComObj,
  uBaseGlComponent,
  uBasecamera,
  uSceneMng,
  uRecBasicFactory,
  cfreg;

type
  cGLfrm = class;

  TGLScene = class(TRecFrm)
    GL: cBaseGlComponent;
    ToolsGB: TGroupBox;
    procedure GLInitScene(Sender: TObject);
  protected
    m_TransformToolsFrame:TTrfrmToolsFrame;
  public
    m_cFrm:cglfrm;
    m_init, m_firstShow:boolean;
    // приходится повторно сохранять т.к. иначе BoundRect сбрасывается при инициализации в 0
    m_bounds:trect;
    R:irecorder;
  private
    procedure initComponents;
    procedure LinkFrames;
    procedure destroyframes;
    procedure Edit;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    destructor destroy;override;
  end;


  // автосоздание методов ctrl+shift+C
  //cGLFact = class(Tinterfacedobject, ICustomFormFactory)
  cGLFact = class(cRecBasicFactory)
	public
		constructor create;
  public
    procedure doDestroyForms;override;
    function doCreateForm: cRecBasicIFrm;override;
  end;

  // УЗНАТЬ КОГДА СОЗДАЕТСЯ И КОГДА УДАЛЯЕТСЯ

  cGLFrm = class(cRecBasicIFrm)
	private
    fShowTools:boolean;
	private
    PROCEDURE SetShowTools(b:boolean);
    //function doNotify(const dwCommand: DWORD; const dwData: DWORD): boolean; virtual;
    function doCreateFrm:TRecFrm;override;
    function doWriteSettings(const pchPath: LPCSTR; const pchSection: LPCSTR):HRESULT;override;
    // Прочитать настройки
    function doReadSettings(const pchPath: LPCSTR; const pchSection: LPCSTR):HRESULT;override;
	public

  public
    constructor create;
    property ShowTools:boolean read fShowTools write SetShowTools;
end;


const
  // ctrl+shift+G
  IID: TGUID = (
    D1:$CAFA6896;D2:$0C76;D3:$4A34;D4:($BC,$C2,$FC,$D6,$CA,$AF,$E3,$23));

  //---------------------------------------------------------
  nDefWidth = 150;
  nDefHeight = 15;
  c_Pic= '3DPIC';
  c_Name= 'TGLScene';

implementation
uses
  PluginClass;

{$R *.dfm}

constructor cGLFrm.create;
begin
  fShowTools:=true;
end;

function cGLFrm.doCreateFrm:TRecFrm;
begin
  result:=TGLScene.Create(nil);
  TGLScene(result).m_cfrm:=self;
end;

function cGLFrm.doReadSettings(const pchPath: LPCSTR;CONST pchSection: LPCSTR): HRESULT;
var
  ifile:TIniFile;
begin
	ifile:=TIniFile.Create(pchPath);
	result:=S_OK;
  ShowTools:=ifile.ReadBool(pchSection, 'ShowTrnsfrms', true);
  ifile.Destroy;
end;

function cGLFrm.doWriteSettings(const pchPath: LPCSTR;CONST pchSection: LPCSTR): HRESULT;
var
  ifile:TIniFile;
begin
	ifile:=TIniFile.Create(pchPath);
  ifile.WriteBool(pchSection, 'ShowTrnsfrms', ShowTools);
	result:=S_OK;
  ifile.Destroy;
end;

procedure cGLFrm.SetShowTools(b:boolean);
begin
  fShowTools:=b;
  TGLScene(m_pMasterWnd).toolsGB.visible:=b;
end;

// ========================================================

constructor cGLFact.create;
begin
  m_lRefCount := 1;
  m_name:=c_Name;
  m_picname:=c_Pic;
  m_Guid:=IID;
end;


procedure cGLFact.doDestroyForms;
begin
  if glFrmEdit<>nil then
    glFrmEdit.Destroy;
  glFrmEdit:=nil;
end;

function cGLFact.doCreateForm: cRecBasicIFrm;
begin
  result:= cGLFrm.Create;
end;

// ========================================================
procedure TGLScene.WndProc(var Message: TMessage);
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
        WM_RBUTTONDOWN:
        begin
          Edit;
        end;
      end;
    end;
  end;
  inherited;
end;


procedure TGLScene.GLInitScene(Sender: TObject);
begin
  initComponents;
  LinkFrames;
end;


procedure TGLScene.initComponents;
var
  l:clight;
  c:cbasecamera;
  t:cglturbine;
begin
  if GL.mUI<>nil then
  begin
    t:=cglturbine.create(GL);
    t.Name:='glTurbine';
    t.node.RotateNodeGlobal(0,-45,0);
    l:=GL.mUI.scene.lights.getlight(0);
    if l<>nil then
      l.position:=p3(1.2,1.5,-2.5);
    c:=gl.mUI.m_RenderScene.Getactivecamera;
    c.target:=t.node.Node;
    c.rotateAroundTarget(c.target,p3(1,0,0),-45);
    t.getstage(0).bladecount:=45;
    c.target:=nil;
  end;
end;

procedure TGLScene.LinkFrames;
begin
  // линкуем фрейм
  m_TransformToolsFrame:=TTrfrmToolsFrame.Create(ToolsGB);
  m_TransformToolsFrame.Align:=alClient;
  m_TransformToolsFrame.Parent :=ToolsGB;
  m_TransformToolsFrame.lincScene(gl.mUI);
end;

procedure TGLScene.destroyframes;
begin
  m_TransformToolsFrame.Destroy;
  m_TransformToolsFrame:=nil;
end;

procedure TGLScene.Edit;
begin
  if glFrmEdit=nil then
  begin
    glFrmEdit:=TglFrmEdit.create(nil);
  end;
  glFrmEdit.edit(m_cFrm);
end;

destructor TGLScene.destroy;
begin
  destroyframes;
  inherited;
end;

end.
