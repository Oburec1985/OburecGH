unit uDrawObj;

interface

uses
  windows, uBaseObj, uCommonTypes, ueventlist, uChartEvents, types,
  comctrls, classes, uDrawObjMng, NativeXML, uBaseObjMng, dglopengl,
  umatrix, uNode, uMNode, uFontMng, uCommonMath,
  MathFunction, uText,
  uLogFile,
  dialogs;

type

  cDrawObj = class(cBaseObj)
  public
    m_userdata: pointer;
    // ��� ���������
    fChart: tcomponent;
    // ������� �� x
    xUnits,
    // ������� �� y
    yUnits: string;
    // �������� ������������� ������� bound-�
    needUpdateBound: boolean;
    // �������. �������� � ��������������� ���������
    boundrect: frect;
    // ���� �����
    fcolor: point3;
    // ������
    editForm: tobject;
  public
    cs: TRTLCriticalSection;
    // ��������� � ������� ��� ��������� ��� �������� ���� � CS
    m_LastProcName: string;
    m_stackStrings: tstringlist;
  public
    events: ceventlist;
    fvisible: boolean;
  protected
    // ���������� ������� ���������
    m_layer:integer;
    fpos: point2;
    // ������� �������
    scale: single;
    node: cnode;
  protected
    procedure SetLayer(i:integer);
    function checkBound(p: point2): boolean;
    function GetFont(i: integer): cfont;
    procedure BeforeDrawChild; virtual;
    procedure drawData; virtual;
    procedure enddrawData; virtual;
    procedure DeleteEvents; virtual;
    procedure setcolor(p: point3); virtual;
    procedure setname(pname: string); override;
    procedure fupdatebound; virtual;
    procedure SetPos(p: point2); virtual;
    function GetPos: point2; virtual;
    function getDrawObjMng: cdrawobjmng;
    procedure createEvents; virtual;
    procedure destroyEvents; virtual;

    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    procedure ReplaceObjMng(m: tobject); override;
    procedure DoLincParent; override;

    procedure linc(p_chart: tcomponent); virtual;
    procedure InitCS;
    procedure DeleteCS;
    // �������� ������� ������� (������� ������� �������)
    procedure SetPosMatrix;
    function getpage: cDrawObj;
    // ���������� ������������ ������� ������
    procedure SetParentMatrixView; virtual;
    procedure SetSelected(b: boolean);
    function GetSelected: boolean;
    procedure SetVisible(b:boolean);virtual;
  public
    // ���������� ����� ��������� ������� ��� �������
    procedure doUpdateWorldSize(sender: tobject); virtual;
  public
    function getCarrierPage:cdrawobj;
    procedure OnAxisChangeLg; virtual;
    function GetFWidth: single; virtual;
    function GetFHeigth: single; virtual;
    procedure EnterCS;
    procedure ExitCS;
    // -1 ������ �� ������. 1 - ������ ������ ������ �������; 0 - ������ ������� �������
    function CheckCS: integer;
    procedure CallEventsWithSender(e_type: cardinal; sender: tobject);
    procedure CallEvents(e_type: cardinal);
    procedure updatebound;
    // ��������� ������ �� ����������� � ������� �������� ���������� ���
    function GetSize(pixSize: tpoint): point2; overload;
    function GetSize(pixSize: tpoint; fsize: point2; iSize: tpoint): point2;
      overload;
    function GetiSize(Size: point2): tpoint;
    function GetSizeNormalVP(pixSize: tpoint): point2;
    // ����������� �������
    procedure EvalBound; virtual;
    // �������� ������� ������� ������� ���� �����
    // ��� ���� �������� ������� ��������� ��������
    function GetBound: frect; // virtual;
    // � ������ �������� ��������
    function GetAllBound: frect;
    constructor create; override;
    procedure draw; virtual;
    function GetTypeString: string; virtual;
    property color: point3 read fcolor write setcolor;
    destructor destroy; override;
  public
    property visible: boolean read fvisible write setvisible;
    property chart: tcomponent read fChart write linc;
    property drawobjmng: cdrawobjmng read getDrawObjMng;
    // ������� ������� � �������������� �����������
    property Position: point2 read GetPos write SetPos;
    property selected: boolean read GetSelected write SetSelected;
    // ��� ������ ��� ������ ��������
    property layer: integer read m_layer write SetLayer;
  end;

  cMoveObj = class(cDrawObj)
  public
    // ������ �������� ���������������� �������
    fEnabled,
    // �� ������ ������ � ����� ����
    fdrag, fDblClick: boolean;
    fDragBegin, fDragEnd: point2;
    fCurDragI, fDragBeginI, fDragEndI: tpoint;

    // ������ �������
    flocked: boolean;
    // ����� �������� ���� ������� ������
    selectable: boolean;
  protected
    procedure SetEnabled(b: boolean);
    procedure SetLocked(b: boolean);
  public
    // ��������� ���������� �� ����� p2 �� �������
    function TestObj(p2: point2; dist: single): boolean; virtual;
    procedure DoOnMouseMove(p: point2); overload; virtual;
    procedure DoOnMouseMove(p: tpoint); overload;
    procedure DoOnClick(p: point2); overload; virtual;
    procedure DoOnClick(p: tpoint); overload;
    procedure DoOnBtnUp(p: point2); overload; virtual;
    procedure DoOnBtnUp(p: tpoint); overload;
    procedure DoOnDblClick(p: point2); overload; virtual;
    procedure DoOnDblClick(p: tpoint); overload;
    procedure DoOnKeyEnter(key: word); virtual;
    procedure DoOnMove(p: point2); overload; virtual;
    procedure DoOnMove(p: tpoint); overload;
    procedure DoOnExit; virtual;
    procedure DoOnMouseLeave; virtual;
    // ����� �������
    property locked: boolean read flocked write SetLocked;
    // ����� ��������
    property enabled: boolean read fEnabled write SetEnabled;
  end;

 cBoundObj = class(cMoveObj)
  public
  protected

  public
 
 end;

const
  c_Page_Img = 1;
  c_Trend_Img = 2;
  c_drawobj_img = 3;
  c_Axis_Img = 4;
  c_Cross_Img = 10;

  // ��������� �������. ����� � �������� ����������
  c_compile = $000001;
  c_Change = $000002;

implementation

uses
  uchart, upage, uaxis, uBasePage;

function NameLayerComparator(p1,p2:pointer):integer;
var
  o1,o2:cdrawobj;
  s1,s2:ansistring;
begin
  o1:=cdrawobj(p1);
  o2:=cdrawobj(p2);
  if o1.m_layer=o2.m_layer then
  begin
    s1:=cbaseobj(p1).name;
    s2:=cbaseobj(p2).name;
    result:=NameComparatorStrBaseNum(s1, s2);
  end
  else
  begin
    if o1.m_layer<o2.m_layer then
      result:=1
    else
      result:=-1;
  end;
end;

function getpage(obj: cDrawObj): cpage;
begin
  if obj is cpage then
    result := cpage(obj)
  else
    result := cpage(obj.GetParentByClassName('cPage'));
end;

procedure cDrawObj.createEvents;
begin
  events.AddEvent(name + '_OnUpadeteTextLabelBound', e_onResize + E_OnZoom, doUpdateWorldSize);
end;

procedure cDrawObj.DeleteEvents;
begin
  events.removeEvent(doUpdateWorldSize, e_onResize + E_OnZoom);
end;

procedure cDrawObj.ReplaceObjMng(m: tobject);
begin
  inherited;
  if m <> nil then
  begin
    chart := cchart(cdrawobjmng(m).chart);
    events := cbaseobjmng(m).events;
    createEvents;
  end;
end;

procedure cDrawObj.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;
  // ����� ����
  fcolor.x := xmlNode.ReadAttributeFloat('Color_R');
  fcolor.y := xmlNode.ReadAttributeFloat('Color_G');
  fcolor.z := xmlNode.ReadAttributeFloat('Color_B');
end;

procedure cDrawObj.SaveObjAttributes(xmlNode: txmlNode);
begin
  inherited;
  // ����� ����
  xmlNode.WriteAttributeFloat('Color_R', fcolor.x);
  xmlNode.WriteAttributeFloat('Color_G', fcolor.y);
  xmlNode.WriteAttributeFloat('Color_B', fcolor.z);
end;

function cDrawObj.GetSizeNormalVP(pixSize: tpoint): point2;
var
  res: point2;
  wh: tpoint;
  p: cpage;
begin
  p := cpage(getpage);
  if p <> nil then
  begin
    wh.x := p.m_NormalViewport[2];
    wh.y := p.m_NormalViewport[3];
  end;
  res.x := (pixSize.x / wh.x) * 2;
  res.y := (pixSize.y / wh.y) * 2;
  result := res;
end;

function cDrawObj.GetSize(pixSize: tpoint; fsize: point2;
  iSize: tpoint): point2;
begin
  result.x := pixSize.x * fsize.x / iSize.x;
  result.y := pixSize.y * fsize.y / iSize.y;
end;

function cDrawObj.GetSize(pixSize: tpoint): point2;
var
  p: cbasepage;
  ax: caxis;
begin
  p := cbasepage(getpage);
  if p <> nil then
  begin
    if p is cpage then
    begin
      ax := caxis(GetParentByClassName('cAxis'));
      if ax <> nil then
      begin
        result := cpage(p).PixelSizeToTrend(pixSize, ax);
        exit;
      end;
    end;
    pixSize.x := pixSize.x shl 1;
    result.x := pixSize.x / p.getwidth;
    pixSize.y := pixSize.y shl 1;
    result.y := pixSize.y / p.getheight;
  end;
end;

function cDrawObj.GetiSize(Size: point2): tpoint;
var
  p: cbasepage;
begin
  p := cbasepage(getpage);
  //if p<>nil then
  begin
    result.x := round(p.getwidth * Size.x / GetFWidth);
    result.y := round(p.getheight * Size.y / GetFHeigth);
  end
  //else
  //begin
  //  showmessage('p=nil');
  //end;
end;

constructor cDrawObj.create;
begin
  inherited;
  childrens.comparetype:=3; //c_UserCompare
  childrens.setComparator(NameLayerComparator);
  node := cMnode.create;

  editForm := nil;
  InitCS;
  scale := 1;
  chart := nil;
  visible := true;
  childrens.destroydata := true;
  imageindex := c_drawobj_img;

  m_stackStrings := tstringlist.create;
  m_layer:=0;
end;

destructor cDrawObj.destroy;
var
  p:cpage;
begin
  if fChart <> nil then
  begin
    if cchart(fChart).selected = self then
      cchart(fChart).selected := nil;
  end;
  if events <> nil then // �������
    events.CallAllEventsWithSender(E_OnDestroyObject, self);
  DeleteCS;
  node.destroy;
  node := nil;
  // m_callStack.free;
  m_stackStrings.destroy;
  inherited;
end;

procedure cDrawObj.drawData;
begin
  glColor3fv(@color);
end;

procedure cDrawObj.draw;
var
  i: integer;
  obj: cBaseObj;
  TMtype: GLUInt;
begin
  EnterCS;

  // ������ ����� ������� �������
  glGetIntegerv(gl_Matrix_Mode, @TMtype);
  glMatrixMode(GL_Modelview);
  glPushMatrix;

  glloadmatrixf(@node.restm);
  if visible then
  begin
    // SetParentMatrixView;
    drawData;
    enddrawData;
  end;
  for i := 0 to childcount - 1 do
  begin
    obj := getChild(i);
    if obj is cDrawObj then
    begin
      BeforeDrawChild;
      cDrawObj(obj).draw;
    end;
  end;

  glPopMatrix;
  if TMtype = GL_Modelview then
    glMatrixMode(GL_Modelview);
  if TMtype = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
  ExitCS;
end;

procedure cDrawObj.DoLincParent;
begin
  inherited;
  if parent <> nil then
  begin
    node.LincTo(cDrawObj(parent).node);
    if cDrawObj(parent).getDrawObjMng <> nil then
    begin
      setMng(cDrawObj(parent).getDrawObjMng);
    end;
    if events <> nil then
      // ���������� ��� ���������� ��������� ����������
      events.CallAllEventsWithSender(e_onLincParent, self);
  end
  else
  begin
    if node <> nil then
      node.unLinc;
    if events <> nil then
    begin
      events.CallAllEventsWithSender(e_onLincParent, self);
      DeleteEvents;
    end;
  end;
end;

function UpdateBoundEnumProc(obj: cBaseObj; data: pointer): boolean;
var
  l_b_updatebound: boolean;
  bound: frect;
begin
  result := true;
  if obj is cDrawObj then
  begin
    if cDrawObj(obj).visible then
    begin
      bound := cDrawObj(obj).GetBound;
      updatebound(frect(data^), bound.BottomLeft, l_b_updatebound);
      updatebound(frect(data^), bound.TopRight, l_b_updatebound);
    end;
  end;
end;

function cDrawObj.GetAllBound: frect;
var
  res: frect;
begin
  res := boundrect;
  EnumGroupMembers(UpdateBoundEnumProc, @res);
  result := res;
end;

function cDrawObj.GetBound: frect;
var
  offset: point2;
begin
  if needUpdateBound then
  begin
    EvalBound;
  end;
  offset := p2(node.Position.x, node.Position.y);
  result.BottomLeft := p2(boundrect.BottomLeft.x + offset.x,
    boundrect.BottomLeft.y + offset.y);
  result.TopRight := p2(boundrect.TopRight.x + offset.x,
    boundrect.TopRight.y + offset.y);
  updatebound;
end;

function cDrawObj.GetTypeString: string;
begin
  result := '������ �������';
end;

procedure cDrawObj.setcolor(p: point3);
begin
  fcolor := p;
  if events <> nil then
    events.CallAllEventsWithSender(e_OnChangeColor, self);
end;

procedure cDrawObj.SetLayer(i: integer);
var
  p:cbaseobj;
begin
  m_layer:=i;
  p:=parent;
  if p<>nil then
  begin
    p.childrens.Sort(NameLayerComparator);
  end;
end;

procedure cDrawObj.setname(pname: string);
begin
  if pname <> name then
  begin
    inherited;
    if events <> nil then
      events.CallAllEventsWithSender(e_OnChangeName, self);
  end;
end;

procedure cDrawObj.updatebound;
begin
  if needUpdateBound then
  begin
    fupdatebound;
  end;
end;

procedure cDrawObj.fupdatebound;
begin
  needUpdateBound := false;
end;

procedure cDrawObj.destroyEvents;
begin

end;

procedure cDrawObj.SetPos(p: point2);
var
  p3: point3;
begin
  fpos := p;
  p3.x := p.x;
  p3.y := p.y;
  p3.z := 1;
  node.Position := p3;
  node.settoworld;
end;

function cDrawObj.GetPos: point2;
begin
  result := fpos;
end;

function cDrawObj.getCarrierPage: cdrawobj;
var
  node:cdrawobj;
begin
  result:=nil;
  node:=self;
  while (node.parent<>nil) do
  begin
    if node.parent is cbasepage then
    begin
      if cbasepage(node.parent).isCarrier then
      begin
        result:=cdrawobj(node.parent);
        break;
      end;
    end;
    node:=cdrawobj(node.parent);
  end;
end;

function cDrawObj.getDrawObjMng: cdrawobjmng;
begin
  result := cdrawobjmng(getmng);
end;

procedure cDrawObj.linc(p_chart: tcomponent);
begin
  fChart := p_chart;
end;

procedure cDrawObj.CallEventsWithSender(e_type: cardinal; sender: tobject);
begin
  if events <> nil then
  begin
    events.CallAllEventsWithSender(e_type, sender);
  end;
end;

procedure cDrawObj.CallEvents(e_type: cardinal);
begin
  if events <> nil then
  begin
    events.CallAllEvents(e_type);
  end;
end;

procedure cDrawObj.InitCS;
begin
  InitializeCriticalSection(cs);
end;

procedure cDrawObj.DeleteCS;
begin
  DeleteCriticalSection(cs);
end;

procedure cDrawObj.EnterCS;
//var
  //callStack: TJclStackInfoList;
begin
  if chart <> nil then
  begin
    if assigned(cchart(chart).OnEnterCS) then
      cchart(chart).OnEnterCS(self);
  end;
  if cchart(chart) <> nil then
  begin
    if cchart(chart).debugMode then
    begin
      // ����� ���� ��� ������ ����� �������� � ���
      // Raw � ���������� �����, ������������ ��� ��������� ���������� � ����� ������. ��� �������� False ������������� ������ �������� ������. ������������� �������� True ��������� �������� ������ ��������������� ����� ��������� � �� ����� ������ ����������, ������� ������������ ��� ������ ����������� (� ��������� �������� ������� call) � ���� ������� �������� ����� ������ ���������� � ����� ������� �����������.
      // AIgnoreLevels � ���������� ���������� ������ ������� ����������� � �����, ������� �� ����� ���������������. ��������, ��� �������� ���������� ������ � ������� ������� JclCreateStackList � ����� ����� ������. �� ������ ������� ������������ ����������� ������ �����������. ��������� �������� ������� ��������� ������ 1, ����� ���������� ������ ������ ������ �������.
      // FirstCaller � ����� ������������, � ������� ��������� �������� ���������� ������������� � ������� ����������� �� ����� �������. �������� ������ ������������ ��� ������� ����������.
      //callStack := JclCreateStackList(true, 3, nil);
      m_stackStrings.Clear;
      // ������ �����, ��� ������, �������� ������
      //callStack.AddToStrings(m_stackStrings, false, false, true);
      if m_LastProcName <> '' then
      begin
        cchart(chart).deadLockDSC := m_LastProcName + '__' +
          m_stackStrings.Strings[0] + '_' + name;
        if assigned(cchart(chart).OnDeadLock) then
          cchart(chart).OnDeadLock(self);
      end;
      m_LastProcName := m_stackStrings.Strings[0];
      //callStack.Free;
    end;
  end;
  EnterCriticalSection(cs);
end;

procedure cDrawObj.EvalBound;
begin

end;

procedure cDrawObj.ExitCS;
begin
  m_LastProcName := '';
  if chart <> nil then
  begin
    if assigned(cchart(chart).OnExitCS) then
      cchart(chart).OnExitCS(self);
  end;
  LeaveCriticalSection(cs);
end;

function cDrawObj.CheckCS: integer;
begin
  result := -1;
  GetCurrentThreadId;
  if cs.LockCount <> 0 then
  begin
    if cs.OwningThread <> GetCurrentThreadId then
    begin
      result := 1;
    end
    else
      result := 0;
  end;
end;

procedure cDrawObj.SetPosMatrix;
begin

end;

function cDrawObj.GetFont(i: integer): cfont;
var
  mng: cdrawobjmng;
  fmng: cFontMng;
begin
  result := nil;
  mng := cdrawobjmng(getmng);
  if mng <> nil then
  begin
    fmng := mng.fmng;
    if fmng <> nil then
      result := fmng.font(i);
  end;
end;

procedure cDrawObj.SetSelected(b: boolean);
begin

end;

procedure cDrawObj.SetVisible(b: boolean);
begin
  fvisible:=b;
end;

function cDrawObj.GetSelected: boolean;
begin
  if self = cchart(chart).selected then
    result := true
  else
    result := false;
end;

procedure cDrawObj.enddrawData;
begin

end;

procedure cDrawObj.doUpdateWorldSize(sender: tobject);
begin

end;

function cDrawObj.GetFWidth: single;
var
  ax: caxis;
begin
  ax := caxis(GetParentByClassName('cAxis'));
  if ax <> nil then
  begin
    result := ax.max.x - ax.min.x;
  end
  else
  begin
    result := 2;
  end;
end;

procedure cDrawObj.BeforeDrawChild;
begin

end;

function cDrawObj.GetFHeigth: single;
var
  ax: caxis;
begin
  ax := caxis(GetParentByClassName('cAxis'));
  if ax <> nil then
  begin
    result := ax.max.y - ax.min.y;
  end
  else
  begin
    result := 2;
  end;
end;

function cDrawObj.checkBound(p: point2): boolean;
begin
  result := false;
  if p.x > boundrect.BottomLeft.x then
  begin
    if p.x < boundrect.TopRight.x then
    begin
      if p.y > boundrect.BottomLeft.y then
      begin
        if p.y < boundrect.TopRight.y then
        begin
          result := true;
        end;
      end;
    end;
  end;
end;

function cDrawObj.getpage: cDrawObj;
begin
  if self is cbasepage then
    result := self
  else
    result := cDrawObj(GetParentByClassName('cBasePage'));
end;

procedure cDrawObj.SetParentMatrixView;
var
  ax: caxis;
begin
  ax := caxis(GetParentByClassName('cAxis'));
  if ax <> nil then
  begin
    ax.loadstate;
  end
  else
  begin
    glMatrixMode(GL_PROJECTION_MATRIX);
    glloadidentity;
  end;
end;

function cMoveObj.TestObj(p2: point2; dist: single): boolean;
begin
  result := false;
end;

procedure cMoveObj.DoOnMouseMove(p: point2);
begin
  //fDragEnd := p;
end;

procedure cMoveObj.DoOnMouseMove(p: tpoint);
var
  ax: caxis;
  page: cbasepage;
  lp: point2;
begin
  ax := caxis(GetParentByClassName('cAxis'));
  if ax <> nil then
  begin
    lp := ax.p2iToP2(p);
  end
  else
  begin
    page := cpage(GetParentByClassName('cBasePage'));
    lp := page.p2iToP2(p);
  end;
  DoOnMouseMove(lp);
end;

procedure cMoveObj.DoOnClick(p: tpoint);
var
  ax: caxis;
  page: cbasepage;
  lp: point2;
begin
  ax := caxis(GetParentByClassName('cAxis'));
  if ax <> nil then
  begin
    lp := ax.p2iToP2(p);
  end
  else
  begin
    page := cbasepage(GetParentByClassName('cBasePage'));
    lp := page.p2iToP2(p);
  end;
  fDragBeginI:=p;
  DoOnClick(lp);
end;

procedure cMoveObj.DoOnClick(p: point2);
begin
  fDragBegin := p;
  fdrag := true;
  fDblClick := false;
end;

procedure cMoveObj.DoOnDblClick(p: point2);
begin
  fDblClick := true;
end;

procedure cMoveObj.DoOnDblClick(p: tpoint);
var
  ax: caxis;
  page: cbasepage;
  lp: point2;
begin
  ax := caxis(GetParentByClassName('cAxis'));
  if ax <> nil then
  begin
    lp := ax.p2iToP2(p);
  end
  else
  begin
    page := cbasepage(GetParentByClassName('cBasePage'));
    lp := page.p2iToP2(p);
  end;
  DoOnDblClick(lp);
end;

procedure cMoveObj.DoOnKeyEnter(key: word);
begin

end;

procedure cMoveObj.DoOnMove(p: point2);
begin
  fDragEnd := p;
end;

procedure cMoveObj.DoOnMove(p: tpoint);
var
  ax: caxis;
  page: cbasepage;
  lp: point2;
begin
  ax := caxis(GetParentByClassName('cAxis'));
  if ax <> nil then
  begin
    lp := ax.p2iToP2(p);
  end
  else
  begin
    page := cbasepage(GetParentByClassName('cBasePage'));
    lp := page.p2iToP2(p);
  end;
  fCurDragI:=p;
  DoOnMove(lp);
end;

procedure cMoveObj.DoOnBtnUp(p: point2);
begin
  fdrag := false;
end;

procedure cMoveObj.DoOnBtnUp(p: tpoint);
var
  ax: caxis;
  page: cbasepage;
  lp: point2;
begin
  ax := caxis(GetParentByClassName('cAxis'));
  if ax <> nil then
  begin
    lp := ax.p2iToP2(p);
  end
  else
  begin
    page := cbasepage(GetParentByClassName('cBasePage'));
    lp := page.p2iToP2(p);
  end;
  fDragEndI := p;
  DoOnBtnUp(lp);
end;

procedure cMoveObj.DoOnExit;
begin

end;

procedure cMoveObj.DoOnMouseLeave;
begin

end;

procedure cMoveObj.SetLocked(b: boolean);
begin
  flocked := b;
  if not b then
  begin
    fEnabled := not b;
  end;
end;

procedure cMoveObj.SetEnabled(b: boolean);
begin
  fEnabled := b;
  if not b then
  begin
    flocked := true;
  end;
end;

procedure cDrawObj.OnAxisChangeLg;
begin

end;

end.
