unit uAlgFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, uBtnListView, Buttons, StdCtrls, uAlgFrame,
  uCounterAlgFrame, uBaseAlg, uAlgAddFrm, uComponentServises, uBaseObj, uPhaseFrame,
  uPhaseCrossSpmFrame,  uTagsListFrame, uTahoAlgFrame, uGrmsFrame, tags,
  ucommonmath,
  ActiveX,
  uGrmsSrcFrame,
  uSpmFrame,
  uAriphmAlgFrame,
  uFillFctFrame,
  uPeakFactorFrame,
  uIntegralAlgFrame,
  uRCFunc, Menus, uBandsFrm, VirtualTrees, uVTServices, ImgList;

type
  TAlgFrm = class(TForm)
    TagsListPanel: TPanel;
    AlgPropPanel: TPanel;
    BottomPanel: TPanel;
    Splitter1: TSplitter;
    Panel1: TPanel;
    AddAlgBtn: TSpeedButton;
    UpdateAlgBtn: TSpeedButton;
    Splitter2: TSplitter;
    AlgsPageControl: TPageControl;
    TagsListFrame1: TTagsListFrame;
    MainMenu1: TMainMenu;
    BandsMenu: TMenuItem;
    AlgsTV: TVTree;
    ImageList1: TImageList;
    procedure AddAlgBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UpdateAlgBtnClick(Sender: TObject);
    procedure BandsMenuClick(Sender: TObject);
    procedure AlgLVCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AlgsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure AlgsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure AlgsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure AlgsTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    m_frameList:tstringlist;
    m_init:boolean;
  private
    function selectalg:cbasealgcontainer;
    procedure delalg(a: cbaseobj);
    procedure showAlgsInTV;
    procedure addframe(fr:TBaseAlgFrame);
    procedure AddAlgToNode(n:PVirtualNode);
  public
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

var
  AlgFrm: TAlgFrm;

implementation

{$R *.dfm}

function getSelectAlgCfg(tv: TVTree): cAlgConfig;
var
  n, parentnode: pvirtualnode;
  d: pnodedata;
begin
  result := nil;
  n := GetSelectNode(tv);
  if n = nil then
  begin
    result:=nil;
    exit;
    //n:=tv.GetFirst(true);
  end;
  if n=nil then exit;
  d := tv.getnodedata(n);
  if tobject(d.data) is cAlgConfig then
  begin
    result := cAlgConfig(d.data);
    if result is cAlgConfig then
    begin
      exit;
    end;
  end
  else
  begin
    n:=n.Parent;
    d := tv.getnodedata(n);
    if tobject(d.data) is cAlgConfig then
    begin
      result := cAlgConfig(d.data);
    end;
  end;
end;

procedure TAlgFrm.showAlgsInTV;
var
  I, j: Integer;
  cfg:cAlgConfig;
  a:cBaseAlgContainer;
  o:cbaseobj;
  n, parnode: pvirtualnode;
  d: pnodedata;
begin
  AlgsTV.Clear;
  for I := 0 to g_algMng.CfgCount - 1 do
  begin
    cfg:=g_algMng.getCfg(i);
    parnode:=AlgsTV.AddChild(nil, nil);
    d:=AlgsTV.getNodeData(parnode);
    d.data:=cfg;
    d.color:=AlgsTV.normalcolor;
    d.Caption:=cfg.name;
    d.ImageIndex:=0;
    for j := 0 to cfg.ChildCount - 1 do
    begin
      a:=cfg.getAlg(j);
      n:=AlgsTV.AddChild(parnode, cfg);
      d:=AlgsTV.getNodeData(n);
      d.Caption:=a.name;
      d.ImageIndex:=1;
      d.data:=a;
      d.color:=AlgsTV.normalcolor;
    end;
  end;
  for I := 0 to g_algMng.count - 1 do
  begin
    o:=g_algMng.getobj(i);
    if o is cbasealgcontainer then
      a:=cbasealgcontainer(o)
    else
      continue;
    if a.parentCfg=nil then
    begin
      parnode:=AlgsTV.AddChild(nil, nil);
      d:=AlgsTV.getNodeData(parnode);
      d.data:=a;
      d.color:=AlgsTV.normalcolor;
      d.Caption:=a.resname;
      d.ImageIndex:=1;
    end;
  end;
end;

{TAlgFrm}
procedure TAlgFrm.AddAlgBtnClick(Sender: TObject);
var
  n:pVirtualNode;
begin
  n:=GetSelectNode(AlgsTV);
  AddAlgToNode(n);
end;

procedure TAlgFrm.addframe(fr: TBaseAlgFrame);
var
  page:TTabSheet;
begin
  m_frameList.AddObject(fr.ClassName, fr);
  // создание подфреймов с настройками конкретных реализаций контрола
  page:=TTabSheet.Create(self);
  page.Caption:=fr.GetDsc;
  page.PageControl:=AlgsPageControl;
  fr.Parent:=page;
end;

procedure TAlgFrm.AlgLVCustomDrawItem(Sender: TCustomListView; Item: TListItem;
  State: TCustomDrawState; var DefaultDraw: Boolean);
var
  r:trect;
  str:string;
  I: integer;
begin
 if Item.Selected and not (cdsFocused in State) then
 begin
   DefaultDraw:=false;
   r:=Item.DisplayRect(drBounds);
   with TListView(sender).Canvas do
   begin
     Brush.Color:=clHighlight;
     FillRect(r);
     Brush.Color:=clHighlightText;
     str:=item.Caption;
     for I := 0 to item.SubItems.Count - 1 do
     begin
       str:=str+ ' ' +item.SubItems[i];
     end;
     TextOut(r.Left,R.Top,str);
   end;
 end
 else
 begin
   DefaultDraw:=true;
 end;
end;

procedure TAlgFrm.AddAlgToNode(n: PVirtualNode);
var
  I: Integer;
  li: TListItem;
  cfg:cAlgConfig;
  t:itag;
  a:cBaseAlgContainer;
  controlsNode, child: PVirtualNode;
  d: PNodeData;
  showAlg, newCfg:boolean;
begin
  // перетаскиваем vcl компонент
  I := 0;
  newCfg:=false;
  li:=TagsListFrame1.TagsLV.Selected;
  showalg:=true;
  cfg:=nil;
  while li<>nil do
  begin
    if (cfg=nil) then // на втором кругу закидываем в уже созданную конфигу
    begin
      if n=nil then
      begin
        cfg:=nil
      end
      else
      begin
        // поднимаемся на корневой узел (программа)
        while (n.Parent <> AlgsTV.RootNode) do
        begin
          d:=algstv.GetNodeData(n);
          if (tobject(d.data) is cAlgConfig) then
          begin
            break;
          end;
          n:=n.Parent;
        end;
        if n<>nil then
        begin
          d:=algstv.GetNodeData(n);
          if (tobject(d.data) is cAlgConfig) then
          begin
            cfg:=cAlgConfig(d.data);
          end;
        end;
      end;
    end;
    t:=itag(li.Data);
    if cfg=nil then
      a:=addAlgFrm.CreateAlg(showalg)
    else
      a:=cbasealgcontainer(g_algMng.CreateObjByType(cfg.clType.ClassName));
    if cfg=nil then
    begin
      cfg:=g_algMng.newCfg(a.ClassName,a.ClassType);
      cfg.str:=a.Properties;
      newCfg:=true;
    end;
    cfg.AddChild(a);
    if a<>nil then
    begin
      a.setfirstchannel(t);
      if t<>nil then
      begin
        //a.createOutChan;
        a.updateoutchan;
      end;
      while g_algMng.getAlg(a.name)<>nil do
      begin
        a.name:=modname(a.name, false);
      end;
      g_algMng.Add(a, nil);
    end;
    li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
    showalg:=false;
    inc(i);
  end; // while
  showAlgsInTV;
end;

procedure TAlgFrm.AlgsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  I: Integer;
  nodeIsAlg:boolean;
  n, pn, fn:pVirtualNode;
  d:pNodedata;
  cfg:cAlgConfig;

  fr,firstalgFrame:TBaseAlgFrame;
  firstalg, a:cbasealgcontainer;
  j: Integer;
  li:tlistitem;
begin
  firstalgFrame:=nil;
  if n=nil then exit;
  n:=GetSelectNode(AlgsTV);
  fn:=n;
  d:=AlgsTV.GetNodeData(n);
  nodeIsAlg:=false;
  if d=nil then exit;
  if tobject(d.data) is cAlgConfig then
  begin
    cfg:=cAlgConfig(d.data);
  end
  else
  begin // выбрали алгоритм
    pn:=n.Parent;
    j:=0;
    while n<>nil do
    begin
      if j=0 then
      begin
        d:=AlgsTV.GetNodeData(n);
        a:=cbasealgcontainer(d.data);
        firstalg:=a;
        for I := 0 to m_frameList.Count - 1 do
        begin
          fr:=TBaseAlgFrame(m_frameList.Objects[i]);
          fr.m_a:=a;
          if not fr.ShowAlg(a) then
          begin
            AlgsPageControl.Pages[i].Visible:=false;
            AlgsPageControl.Pages[i].TabVisible:=false;
          end
          else
          begin
            AlgsPageControl.ActivePageIndex:=i;
            AlgsPageControl.Pages[i].Visible:=true;
            AlgsPageControl.Pages[i].TabVisible:=true;
            firstalgFrame:=fr;
          end;
        end;
      end
      else
      begin
        if a.ClassType=firstalg.ClassType then
          firstalgFrame.ShowAlg(a);
      end;
      inc(j);
      n:=AlgsTV.GetNext(n, false);
    end;
  end;
  n:=fn;
  j:=0;
  if n.childcount>0 then
  begin
    if nodeIsAlg then // выбрали алгоритм
    begin
      a:=cbasealgcontainer(d.data);
      firstalg:=a;
      for I := 0 to m_frameList.Count - 1 do
      begin
        fr:=TBaseAlgFrame(m_frameList.Objects[i]);
        fr.m_a:=a;
        if not fr.ShowAlg(a) then
        begin
          AlgsPageControl.Pages[i].Visible:=false;
          AlgsPageControl.Pages[i].TabVisible:=false;
        end
        else
        begin
          AlgsPageControl.ActivePageIndex:=i;
          AlgsPageControl.Pages[i].Visible:=true;
          AlgsPageControl.Pages[i].TabVisible:=true;
          firstalgFrame:=fr;
        end;
      end;
    end
    else // выбрали конфигу
    begin
      for j := 0 to n.ChildCount - 1 do
      begin
        if I <> 0 then
          n:= AlgsTV.GetNext(n)
        else
          n:= AlgsTV.GetFirst;
        d:=AlgsTV.GetNodeData(n);
        a:=cBaseAlgContainer(d.data);
        if j=0 then
        begin
          firstalg:=a;
          for I := 0 to m_frameList.Count - 1 do
          begin
            fr:=TBaseAlgFrame(m_frameList.Objects[i]);
            fr.m_a:=a;
            if not fr.ShowAlg(a) then
            begin
              AlgsPageControl.Pages[i].Visible:=false;
              AlgsPageControl.Pages[i].TabVisible:=false;
            end
            else
            begin
              AlgsPageControl.ActivePageIndex:=i;
              AlgsPageControl.Pages[i].Visible:=true;
              AlgsPageControl.Pages[i].TabVisible:=true;
              firstalgFrame:=fr;
            end;
          end;
        end
        else
        begin
          if a.ClassType=firstalg.ClassType then
            firstalgFrame.ShowAlg(a);
        end;
      end;
    end;
  end;
  if firstalgFrame<>nil then
    firstalgFrame.EndMsel;
end;

procedure TAlgFrm.AlgsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  I: Integer;
  n, sn, new, prev: PVirtualNode;
  d, sd, nd:pnodedata;
begin
  // перетаскиваем vcl компонент
  n := Sender.DropTargetNode;
  if n<>nil then
  begin
    d:=AlgsTV.GetNodeData(n);
  end;
  if source=TagsListFrame1.TagsLV then
  begin
    if DataObject = nil then
    begin
      AddAlgToNode(n);
    end;
  end
  else
  begin
    if source=AlgsTV then // если источник само дерево алгоритмов
    begin
      sn:=AlgsTV.GetFirstSelected(false);
      while sn<>nil do
      begin
        sd:=AlgsTV.GetNodeData(sn);
        if tobject(d.data) is cBaseAlgContainer then
        begin
          n:=n.Parent;
          d:=AlgsTV.GetNodeData(n);
        end;
        if tobject(d.data) is cAlgConfig then // если дропаем в конфиг
        begin
          if tobject(sd.data) is cbasealgcontainer then
          begin
            if cbasealgcontainer(sd.data).ClassType=cAlgConfig(d.data).clType then
            begin
              new:=AlgsTV.AddChild(n, nil);
              nd:=AlgsTV.GetNodeData(new);
              nd.data:=sd.data;
              nd.ImageIndex:=sd.ImageIndex;
              nd.color:=sd.color;
              nd.Caption:=sd.Caption;
              cAlgConfig(d.data).AddChild(cbasealgcontainer(sd.data));
              prev:=sn;
              sn:=AlgsTV.GetNextSelected(sn, false);
              AlgsTV.DeleteNode(prev,true);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TAlgFrm.AlgsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
VAR
  n, tn:PVirtualNode;
  d, td:pnodedata;
  a:cBaseAlgContainer;
begin
  Accept := false;
  if Source = TagsListFrame1.TagsLV then
    Accept := true
  else
  begin
    if Source = AlgsTV then
    begin
      n:=AlgsTV.GetFirstSelected(false);
      d:=AlgsTV.GetNodeData(n);
      if tobject(d.data) is cBaseAlgContainer then
      begin
        a:=cBaseAlgContainer(d.data);
        tn:=AlgsTV.GetNodeAt(pt.X,pt.y);
        if tn<>nil then
        begin
          td:=AlgsTV.GetNodeData(tn);
          if tobject(td.data) is cAlgConfig then
          begin
            if cAlgConfig(td.data).clType=a.ClassType then
              Accept := true;
          end
          else
          begin
            tn:=tn.Parent;
            if tn<>nil then
            begin
              td:=AlgsTV.GetNodeData(tn);
              if tobject(td.data) is cAlgConfig then
              begin
                if cAlgConfig(td.data).clType=a.ClassType then
                  Accept := true;
              end
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TAlgFrm.AlgsTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  n:pVirtualNode;
  d:pNodedata;
  o:cBaseObj;
begin
  if key=VK_DELETE then
  begin
    n:=AlgsTV.GetFirstSelected(false);
    while n<>nil do
    begin
      d:=AlgsTV.GetNodeData(n);
      o:=cbaseobj(d.data);
      o.destroy;
      n:=AlgsTV.GetNextSelected(n, false);
    end;
    AlgsTV.DeleteSelectedNodes;
  end;
end;

procedure TAlgFrm.BandsMenuClick(Sender: TObject);
begin
  bandsFrm.showmodal;
end;

procedure TAlgFrm.delalg(a: cbaseobj);
var
  I: Integer;
  li:tlistitem;
begin
  // удаление из таблицы контролов
  {for I := 0 to AlgLV.items.Count - 1 do
  begin
    li:=AlgLV.items[i];
    if li.data=a then
    begin
      li.Destroy;
      break;
    end;
  end;
  a.destroy;}
end;

constructor TAlgFrm.create(aowner: tcomponent);
var
  fr:TBaseAlgFrame;
begin
  inherited;
  m_init:=false;
  m_frameList:=TStringList.Create;

  // создаем фремй прямого управления DAC
  fr:=TTahoAlgFrame.Create(self);
  addframe(fr);

  fr:=TCounterAlgFrame.Create(self);
  addframe(fr);

  //fr:=TGrmsFrame.Create(self);
  //addframe(fr);

  fr:=TSynchroPhasePhrame.Create(self);
  addframe(fr);

  fr:=TGrmsSrcFrame.Create(self);
  addframe(fr);

  fr:=TSpmFrame.Create(self);
  addframe(fr);

  fr:=TPhaseFrame.Create(self);
  addframe(fr);

  fr:=TFillFctFrame.Create(self);
  addframe(fr);

  fr:=TPeakFactorFrame.Create(self);
  addframe(fr);

  fr:=TIntegralAlgFrame.Create(self);
  addframe(fr);

  fr:=TAriphmAlgFrame.Create(self);
  addframe(fr);
end;

destructor TAlgFrm.destroy;
begin
  m_frameList.Destroy;
  inherited;
end;

procedure TAlgFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if g_algMng<>nil then
    g_algMng.Events.CallAllEvents(E_OnChangeAlgCfg);
end;

procedure TAlgFrm.FormShow(Sender: TObject);
var
  I: Integer;
  fr:TBaseAlgFrame;
begin
  //FullDebugModeScanMemoryPoolBeforeEveryOperation:=true;
  TagsListFrame1.ShowChannels;
  for I := 0 to m_frameList.Count - 1 do
  begin
    fr:=TBaseAlgFrame(m_frameList.Objects[i]);
    fr.doShow;
  end;
  showAlgsInTV;
  //FullDebugModeScanMemoryPoolBeforeEveryOperation:=false;
end;

function TAlgFrm.selectalg: cbasealgcontainer;
var
  n:pVirtualNode;
  d:PNodeData;
begin
  result:=nil;AlgsTV.GetFirstSelected(false);
  n:=AlgsTV.GetFirstSelected(false);
  if n<>nil then
  begin
    d:=AlgsTV.GetNodeData(n);
    if tobject(d.data) is cbasealgcontainer then
    begin
      result:=cbasealgcontainer(d.data);
    end
    else
    begin
      if tobject(d.data) is cAlgConfig then
      begin
        n:=n.FirstChild;
        d:=AlgsTV.GetNodeData(n);
        if tobject(d.data) is cbasealgcontainer then
        begin
          result:=cbasealgcontainer(d.data);
        end
      end;
    end;
  end;
end;

procedure TAlgFrm.UpdateAlgBtnClick(Sender: TObject);
var
  a:cbasealgcontainer;
  fr:TBaseAlgFrame;
  firsAlg:TClass;
  I: Integer;

  n, pn:pVirtualNode;
  d, pd:pNodeData;
  str:string;
begin
  fr:=TBaseAlgFrame(m_frameList.Objects[AlgsPageControl.ActivePageIndex]);
  str:=fr.properties;
  for I := 0 to AlgsTV.SelectedCount - 1 do
  begin
    if i=0 then
    begin
      n:=AlgsTV.GetFirstSelected;
      d:=AlgsTV.GetNodeData(n);
    end
    else
    begin
      n:=AlgsTV.GetNext(n, true);
      d:=AlgsTV.GetNodeData(n);
    end;
    if tobject(d.data) is cbasealgcontainer then
    begin
      pn:=n.Parent;
      pd:=AlgsTV.GetNodeData(pn);
      if tobject(pd.Data) is cAlgConfig then
      begin
        n:=pn;
        d:=pd;
      end;
    end;
    // выбран алгоритм
    if tobject(d.data) is cbasealgcontainer then
    begin
      a:=cbasealgcontainer(d.Data);
      if i=0 then
        firsAlg:=a.ClassType;
      if a<>nil then
      begin
        if a.ClassType=firsAlg then
        begin
          a.Properties:=str;
          if lowercase(a.name)<>lowercase(a.resname) then
          begin
            if a.resname<>'' then
            begin
              a.name:=a.resname;
            end;
          end;
        end;
      end;
    end
    else
    // выбран конфиг
    begin
      if tobject(d.data) is cAlgConfig then
      begin
        cAlgConfig(d.data).str:=str;
        exit;
      end;
    end;
  end;
end;

end.
