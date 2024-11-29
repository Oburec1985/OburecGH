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
  uModList,
  uSkin,
  uBaseDeformer,
  uBaseModificator,
  uShape,
  uMeshObr,
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
  uMeasureBase,
  uPathMng,
  uMBaseControl,
  u3dSceneEditFrame,
  uSkinFrame,
  u3dMoveEngine,
  umatrix,
  uSceneMng;

type
  TObjFrm3d = class(TRecFrm)
    GL: cBaseGlComponent;
    ToolsGB: TGroupBox;
    RightGB: TGroupBox;
    RightSplitter: TSplitter;
    ErrorEdit: TEdit;
    BotSplitter: TSplitter;
    procedure GLInitScene(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    M_camera:matrixgl;
    m_TransformToolsFrame: TTrfrmToolsFrame;
    // TTreeView - дерево объектов
    m_EditFrame:TGlSceneEditFrame;
    fshowtools: boolean;
    m_cfgLoad:boolean;
  public
    m_ScenePath, m_SceneName, m_inifile, m_loadsect: string;
    airplane: cnodeobject;
  private
    // инициаци€ сцены
    procedure initComponents;
    procedure RBtnClick(Sender: TObject);
  protected
    procedure doRcInit(sender:tobject);
    procedure createevents;
    procedure destroyevents;
    procedure UpdateView;
    procedure updateData;
    procedure doStart;
    procedure loadscene(path:string);
  protected
    procedure SetShowTools(b: boolean);
    procedure WndProc(var Message: TMessage); override;
  public
    procedure UpdateTreeView;
    function MBasePath:string;
    function BuildPath: string;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSkinIni;
    procedure LoadCtrlObjIni;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
    procedure linkFrames;
  public
    property ShowTools: boolean read fshowtools write SetShowTools;
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
    procedure doRecorderinit; override;
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doStart;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

var
  g_ObjFrm3dFactory: cObjFrm3dFactory;

const
  c_Pic = '3DPIC';
  c_Name = '3d формул€р';
  c_defXSize = 400;
  c_defYSize = 400;

  // ctrl+shift+G
  // ['{C7E9BC06-C4A6-4466-A2F0-C1FCDF4EEBB6}']
  IID_3DFRM: TGuid = (D1: $C7E9BC06; D2: $C4A6; D3: $4466;
    D4: ($A2, $F0, $C1, $FC, $DF, $4E, $EB, $B6));

implementation

uses uThresholdsFrm;

{$R *.dfm}

{ TObjFrm3d }
procedure TObjFrm3d.linkFrames;
begin
  // линкуем фрейм
  m_TransformToolsFrame := TTrfrmToolsFrame.create(ToolsGB);
  m_TransformToolsFrame.Align := alClient;
  m_TransformToolsFrame.Parent := ToolsGB;
  m_TransformToolsFrame.lincScene(GL.mUI);
  m_EditFrame.lincScene(GL.mUI);
end;

function TObjFrm3d.BuildPath: string;
var
  o: cObjFolder;
  t: cTestFolder;
  f, path: string;
begin
  if g_MBaseControl <> nil then
  begin
    o := g_MBaseControl.GetSelectObj;
    t := g_MBaseControl.GetSelectTest;
    if o <> nil then
    begin
      path := MBasePath;
      if o.ObjType <> '' then
      begin
        path := path + '\3dTypes' + '\' + o.ObjType + '\';
        f := path + o.ObjType + '.obr';
        result := f;
      end;
    end;
  end
  else
  begin
    result:=m_ScenePath+'\'+m_SceneName;
  end;
end;

constructor TObjFrm3d.create(Aowner: tcomponent);
begin
  inherited;
  GL.OnRBtn := RBtnClick;
  m_EditFrame:=TGlSceneEditFrame.Create(nil);
  m_EditFrame.Parent:=RightGB;
  createevents;
end;

destructor TObjFrm3d.destroy;
begin
  destroyevents;
  inherited;
end;

procedure TObjFrm3d.createevents;
begin
  addplgevent('TObjFrm3d_doRcInit', E_RC_Init, doRcInit);
end;

procedure TObjFrm3d.destroyevents;
begin
  RemovePlgEvent(doRcInit, E_RC_Init);
end;

procedure TObjFrm3d.doStart;
begin
  g_CtrlObjList.doStart;
end;

procedure TObjFrm3d.FormShow(Sender: TObject);
begin
  RightSplitter.Left:=RightSplitter.Left;
  RightGB.Realign;
  Realign;

  BotSplitter.Top:=BotSplitter.Top;
  ToolsGB.Realign;
  Realign;
  BotSplitter.Color:=clBackground;
end;

procedure TObjFrm3d.loadscene(path: string);
begin
  if GL.mUI.scene.LoadFile_Obr(m_SceneName) then
  begin
    m_EditFrame.ShowScene;
  end;
end;

procedure TObjFrm3d.initComponents;
var
  l: clight;
  c: cbasecamera;
  b:boolean;
begin
  if GL.mUI <> nil then
  begin
    loadscene(m_SceneName);
    l := GL.mUI.scene.lights.getlight(0);
    if l <> nil then
      l.position := p3(1.2, 1.5, -2.5);
    c := GL.mUI.m_RenderScene.Getactivecamera;
    c.target := nil;
  end;
end;

procedure TObjFrm3d.GLInitScene(Sender: TObject);
var
  c:cbasecamera;
begin
  initComponents;
  linkFrames;
  c:=gl.mUI.scene.getactivecamera;
  c.Node.setlocalTM(M_camera);
  c.SetObjToWorld;
  if not m_cfgLoad then
  begin
    doRcInit(nil);
  end;
end;

function TObjFrm3d.MBasePath: string;
begin
  result:='';
  if g_mbase<>nil then
  begin
    result:=g_mbase.m_BaseFolder.Absolutepath
  end;
end;

procedure TObjFrm3d.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  s, s1, s2:string;
  c:cBaseCamera;
  i, j, k, n:integer;
  skin:cbasemodificator;
  o:cNodeObject;
  p:cDeformPoint;
  //ctrl:c3dCtrlObj;
  ctrl:cnodeobject;
  t:ctag;
begin
  inherited;
  a_pIni.WriteString(str, 'ScenePath', m_ScenePath);
  a_pIni.WriteString(str, 'SceneName', m_SceneName);
  a_pIni.WriteBool(str, 'ShowEditor', ShowTools);
  if GL.mUI=nil then exit;
  c:=GL.mUI.scene.getactivecamera;
  s:=matrixToStr(c.restm);
  a_pIni.WriteString(str, 'CameraPos', s);
  n:=0;
  // пишем управл€ющие объекты
  for I := 0 to g_CtrlObjList.count - 1 do
  begin
    ctrl:=(g_CtrlObjList.GetObj(i));
    if ctrl is c3dMoveObj then
    begin
      a_pIni.WriteString(str, 'Ctrl_'+inttostr(n), c3dMoveObj(ctrl).name);
      t:=c3dMoveObj(ctrl).RotXTag;
      a_pIni.WriteString(str, 'Ctrl_Xrot_'+inttostr(n), t.tagname);
      t:=c3dMoveObj(ctrl).RotYTag;
      a_pIni.WriteString(str, 'Ctrl_Yrot_'+inttostr(n), t.tagname);
      t:=c3dMoveObj(ctrl).RotZTag;
      a_pIni.WriteString(str, 'Ctrl_Zrot_'+inttostr(n), t.tagname);
      a_pIni.WriteInteger(str, 'ChildCount_'+inttostr(n), ctrl.ChildCount);
      s:='';
      for j := 0 to ctrl.ChildCount - 1 do
      begin
        o:=cnodeobject(ctrl.getChild(j));
        s:=s+o.name+';';
      end;
      a_pIni.WriteString(str, 'ChildNames_'+inttostr(n), s);
      inc(n);
    end;
  end;
  // сохранение инф-ии о анимации ориентации
  a_pIni.WriteInteger(str, 'CtrlObjCount', g_CtrlObjList.count);
  // сохранение инф-ии о вершинной деформации
  for I := 0 to GL.mUI.scene.Count - 1 do
  begin
    o:=cnodeobject(GL.mUI.scene.getobj(i));
    if (o is cmeshobr) or (o is cShapeObj) then
    begin
      skin:=o.ModCreator.GetModificator('cSkin');
      if skin<>nil then
      begin
        a_pIni.WriteString(str, 'SkinObj_'+inttostr(n), o.name);
        // костей в скине
        a_pIni.WriteInteger(str, 'SkinBCount_'+inttostr(n), cskin(skin).count);
        // имена костей
        s:='';
        for j:=0 to cskin(skin).count-1 do
        begin
          ctrl:=cskin(skin).getbone(j).fbone;
          s:=s+ctrl.name+';';
        end;
        a_pIni.WriteString(str, 'SkinObjBNames_'+inttostr(n), s);
        // число вершин контролируемое каждой костью
        s:='';
        for j:=0 to cskin(skin).count-1 do
        begin
          ctrl:=cskin(skin).getbone(j).fbone;
          s:=s+inttostr(c3dSkinObj(ctrl).m_bone.count)+';';
        end;
        a_pIni.WriteString(str, 'SkinVCount_'+inttostr(n), s);
        // номера точек
        s:='';
        // id точек
        s2:='';
        for j:=0 to cskin(skin).count-1 do
        begin
          ctrl:=cskin(skin).getbone(j).fbone;
          s1:='';
          // проход по вершинам
          for k := 0 to c3dSkinObj(ctrl).m_bone.count - 1 do
          begin
            p:=c3dSkinObj(ctrl).m_bone.getpoint(k);
            s1:=s1+Tpointtostr(p.p)+'_'+floattostr(p.weight)+';';
          end;
          a_pIni.WriteString(str, 'SkinVerts_'+inttostr(j), s1);
          s:=s+inttostr(c3dSkinObj(ctrl).m_PName)+';';
          s2:=s2+tpointtostr(c3dSkinObj(ctrl).PId)+';';
        end;
        a_pIni.WriteString(str, 'SkinObjPNums_'+inttostr(n), s);
        a_pIni.WriteString(str, 'SkinObjPID_'+inttostr(n), s2);
        // теги
        s:='';
        for j:=0 to cskin(skin).count-1 do
        begin
          ctrl:=cskin(skin).getbone(j).fbone;
          s:=s+c3dSkinObj(ctrl).xTag.tagname+'/'+c3dSkinObj(ctrl).yTag.tagname+
             '/'+c3dSkinObj(ctrl).zTag.tagname+';';
        end;
        a_pIni.WriteString(str, 'SkinBTags_'+inttostr(n), s);
        inc(n);
      end;
    end;
  end;
end;

procedure TObjFrm3d.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  basepath, path, s, s1, s2, s3, s4:string;
  b:boolean;
  m:MatrixGl;
  c:cBaseCamera;
  skin:cbasedeformer;
  o, mesh:cnodeobject;
  tp:tpoint;
  w:single;
  I,j,k,vn,n: Integer;
begin
  inherited;
  m_inifile:=a_pIni.FileName;
  m_loadsect:=str;
  m_ScenePath := a_pIni.ReadString(str, 'ScenePath', '');
  m_SceneName := a_pIni.ReadString(str, 'SceneName', '');
  ShowTools:=a_pIni.ReadBool(str, 'ShowEditor', true);
  if MBasePath<>'' then
  begin
    basepath:=FindFile('resources.ini',MBasePath+'\3dTypes\',2);
    //basepath:=MBasePath+'\3dTypes\'+'resources.ini';
  end
  else
  begin
    if m_ScenePath<>'' then
    begin
      // отрезаем 1 уровень
      path:=ExtractFileDir(m_ScenePath);
      basepath:=FindFile('resources.ini',path, 2);
    end;
  end;

  if fileexists(basepath) then
  begin
    GL.resources:=basepath;
  end
  else
  begin
    if mbasePath='' then
    begin
      ErrorEdit.Text:='ѕуть к Ѕƒ» не найден (ресурсы дл€ загрузки 3д —цены)';
    end;
  end;
  s:=a_pIni.readString(str, 'CameraPos', '1;0;0;0;1;0;0;0;1;0;0;0');
  M_camera:=StrToMatrix(s);
end;

procedure TObjFrm3d.doRcInit(sender: tobject);
begin
  if (GL.mUI=nil) then exit;
  if m_cfgLoad then exit;
  // загрузить сцену
  LoadSkinIni;
  LoadCtrlObjIni;
  m_cfgLoad:=true;
end;


procedure TObjFrm3d.LoadCtrlObjIni;
var
  str,s:string;
  a_pIni:TIniFile;
  n,c,i,j, ind:integer;
  m:c3dMoveObj;
  o:cnodeobject;
begin
  //exit;
  a_pIni:=TIniFile.Create(m_inifile);
  // сохранение инф-ии о анимации ориентации
  n:=a_pIni.ReadInteger(m_loadsect, 'CtrlObjCount', g_CtrlObjList.count);
  for I := 0 to n - 1 do
  begin
    str:=a_pIni.ReadString(m_loadsect, 'Ctrl_'+inttostr(i), '');
    if checkstr(str) then
    begin
      m:=c3dMoveObj.create;
      m.name:=str;
      g_CtrlObjList.addObj(m);
      GL.mUI.scene.Add(m, GL.mUI.scene.World);
      m.fHelper:=false;
      // поиск тегов
      str:=a_pIni.ReadString(m_loadsect, 'Ctrl_Xrot_'+inttostr(i), '');
      m.RotXTag.tagname:=str;
      str:=a_pIni.ReadString(m_loadsect, 'Ctrl_Yrot_'+inttostr(i), '');
      m.RotyTag.tagname:=str;
      str:=a_pIni.ReadString(m_loadsect, 'Ctrl_Zrot_'+inttostr(i), '');
      m.RotzTag.tagname:=str;
      // поиск и линковка дочерних узлов
      c:=a_pIni.ReadInteger(m_loadsect, 'ChildCount_'+inttostr(i), 0);
      str:=a_pIni.ReadString(m_loadsect, 'ChildNames_'+inttostr(i), '');
      for j := 0 to c - 1 do
      begin
        s:=getSubStrByIndex(str,';', 1, ind);
        if checkstr(s) then
        begin
          o:=cnodeobject(GL.mUI.scene.getobj(s));
        end;
        if j=0 then
        begin
          m.nodetm:=o.nodeResTm;
        end;
        m.addchild(o);
      end;
    end;
  end;
  UpdateTreeView;
  a_pIni.Destroy;
end;

procedure TObjFrm3d.LoadSkinIni;
var
  str,s, s1, s2, s3, s4, s5, s6:string;
  b:boolean;
  c:cBaseCamera;
  skin:cBaseModificator;
  DeformP:cDeformPoint;
  o, mesh:cnodeobject;
  bone:cbone;
  tp:tpoint;
  w:single;
  I,j,k,vn,n, ocount: Integer;
  a_pIni:TIniFile;
  p3:point3;
  m:matrixgl;
begin
  //exit;
  a_pIni:=TIniFile.Create(m_inifile);
  ocount:=a_pIni.ReadInteger(m_loadsect, 'CtrlObjCount', g_CtrlObjList.count);
  b:=true;
  n:=-1;
  while b do
  begin
    inc(n);
    if n>=ocount then
      break;
    s:=a_pIni.ReadString(m_loadsect, 'SkinObj_'+inttostr(n), '');
    if s='' then
      continue;
    o:=cnodeobject(GL.mUI.scene.getobj(s));
    mesh:=o;
    if o is cShapeObj then
    begin
      skin:=cskin(o.ModCreator.CreateModificator('cSkin'));
      //skin:=cShapeObj(o).ModCreator.CreateModificator('cSkin');
    end;
    // костей в скине
    j:=a_pIni.ReadInteger(m_loadsect, 'SkinBCount_'+inttostr(n), 0);
    // имена костей
    s:=a_pIni.ReadString(m_loadsect, 'SkinObjBNames_'+inttostr(n), '');
    // число вершин
    s2:=a_pIni.ReadString(m_loadsect, 'SkinVCount_'+inttostr(n), '');
    // имена точек
    s3:=a_pIni.ReadString(m_loadsect, 'SkinObjPNums_'+inttostr(n), '');
    s5:=a_pIni.ReadString(m_loadsect, 'SkinObjPID_'+inttostr(n), '');
    s6:=a_pIni.ReadString(m_loadsect, 'SkinBTags_'+inttostr(n), '');
    for i:=0 to j-1 do
    begin
      // имена
      s1:=getSubStrByIndex(s,';',1,i);
      o:=c3dSkinObj.create;
      o.name:=s1;
      // число вершин
      s1:=getSubStrByIndex(s2,';',1,i);
      vn:=strtoint(s1);
     // id вершин точек
      s4:=a_pIni.ReadString(m_loadsect, 'SkinVerts_'+inttostr(i), '');
      // номера точек
      s1:=getSubStrByIndex(s3,';',1,i);
      c3dSkinObj(o).m_PName:=strtoint(s1);
      // id точек
      s1:=getSubStrByIndex(s5,';',1,i);
      c3dSkinObj(o).PId:=strtotpoint(s1);
      // теги
      s1:=getSubStrByIndex(s6,';',1,i);
      str:=getSubStrByIndex(s6,'/',1,0);
      if str<>'' then
      begin
        c3dSkinObj(o).xTag.tagname:=str;
      end;
      str:=getSubStrByIndex(s6,'/',1,1);
      if str<>'' then
      begin
        c3dSkinObj(o).yTag.tagname:=str;
      end;
      str:=getSubStrByIndex(s6,'/',1,2);
      if (str<>'') then
      begin
        if str<>';' then
          c3dSkinObj(o).zTag.tagname:=str;
      end;

      // прив€зываем к сцене
      c3dSkinObj(o).fHelper:=false;
      GL.mUI.scene.Add(o, GL.mUI.scene.world);
      if mesh is cShapeObj then
      begin
        p3:=cShapeObj(mesh).getPoint(c3dSkinObj(o).PId);
        m:=cShapeObj(mesh).nodeResTm;
        c3dSkinObj(o).position:=MultP3byM(m, p3);
        c3dSkinObj(o).startpos:=c3dSkinObj(o).position;
      end;
      // число вершин
      bone:=cskin(skin).AddBone(o);
      c3dSkinObj(o).m_bone:=bone;
      c3dSkinObj(o).m_defObj:=cnodeobject(cskin(skin).owner);
      // id вершин
      for k := 0 to vn - 1 do
      begin
        s1:=getSubStrByIndex(s4,';',1,k);
        if s1<>'' then
        begin
          tp.X:=strtoint(getSubStrByIndex(s1,'_',1,0));
          tp.y:=strtoint(getSubStrByIndex(s1,'_',1,1));
          w:=strtofloat(getSubStrByIndex(s1,'_',1,2));
          // прив€зка к модификатору точки
          deformP:=c3dSkinObj(o).m_bone.AddPoint(tp, w);
          deformP.weight:=w;
        end;
        //c3dCtrlObj(o).PId
      end;
      g_CtrlObjList.addObj(c3dSkinObj(o));
    end;
    inc(n);
  end;
  UpdateTreeView;
  a_pIni.Destroy;
end;

procedure TObjFrm3d.SetShowTools(b: boolean);
begin
  fshowtools := b;
  RightGB.Visible:=b;
  RightSplitter.Visible:=b;
  FormShow(nil);
end;

procedure TObjFrm3d.RBtnClick(Sender: TObject);
begin
  if g_ObjFrm3dEdit <> nil then
  begin
    g_ObjFrm3dEdit.Edit(self);
  end;
end;

procedure TObjFrm3d.updateData;
begin

end;

procedure TObjFrm3d.UpdateTreeView;
begin
  m_EditFrame.ShowScene;
end;

procedure TObjFrm3d.UpdateView;
begin
  g_CtrlObjList.updateObjPos;
end;

procedure TObjFrm3d.WndProc(var Message: TMessage);
var
  str: string;
begin
  str := inttostr(message.msg);
  case message.msg of
    WM_PARENTNOTIFY:
      begin
        case message.WParam of
          WM_RBUTTONUP:
          begin
            // CPoint pnt(GET_X_LPARAM(lParam),GET_Y_LPARAM(lParam));
            // ::ClientToScreen(m_pForm->getHWND(),&pnt);
            // ScreenToClient(&pnt);
            // return SendMessage(wParam,MK_RBUTTON,MAKELPARAM(pnt.x,pnt.y));
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
  g_CtrlObjList:=cCntrlObjList.Create;
end;

destructor cObjFrm3dFactory.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cObjFrm3dFactory.createevents;
begin
  addplgevent('c3DFrm_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('c3DFrmFactory_doChangeRState', c_RC_DoChangeRCState,
    doChangeRState);
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

procedure cObjFrm3dFactory.doChangeRState(Sender: TObject);
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


procedure cObjFrm3dFactory.doRecorderinit;
begin
  g_ObjFrm3dEdit.doRecroderInit;
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

procedure cObjFrm3dFactory.doUpdateData(Sender: TObject);
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
