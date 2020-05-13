unit uGraphMngFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, StdCtrls, ImgList, ComCtrls, uBtnListView,
  uWPProc, ExtCtrls, DCL_MYOWN, uSetList, PosBase, ActiveX, Spin;

type
  cSelectList = class(cSetList)
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;override;
  end;


  TGraphFrm = class(TForm)
    ActionGB: TGroupBox;
    OkBtn: TButton;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabControl: TPageControl;
    TabSheet3: TTabSheet;
    SrcLV: TBtnListView;
    GraphTV: TVTree;
    Splitter1: TSplitter;
    YAxisLabel: TLabel;
    YmaxFE: TFloatEdit;
    YminLabel: TLabel;
    YmaxLabel: TLabel;
    YminFE: TFloatEdit;
    LogYCB: TCheckBox;
    ScaleYCB: TCheckBox;
    UnitsYEdit: TEdit;
    UnitsYLabel: TLabel;
    SelObjLB: TListBox;
    XAxisLabel: TLabel;
    XminLabel: TLabel;
    XFEmin: TFloatEdit;
    XmaxLabel: TLabel;
    XFEmax: TFloatEdit;
    UnitsXLabel: TLabel;
    UnitsXEdit: TEdit;
    LogXCB: TCheckBox;
    ScaleXCB: TCheckBox;
    LineNameLabel: TLabel;
    LineNameEdit: TEdit;
    DrawLineCB: TCheckBox;
    DrawPointsCB: TCheckBox;
    LineColorLabel: TLabel;
    LineColorCB: TColorBox;
    LineSrcLabel: TLabel;
    LineSrcCB: TComboBox;
    LineWidthLabel: TLabel;
    LineBaseCB: TCheckBox;
    LineTypeLabel: TLabel;
    LineTypeCB: TComboBox;
    ProfileCB: TCheckBox;
    LineWidthEdit: TIntEdit;
    GroupBox1: TGroupBox;
    StartTrigLabel: TLabel;
    StopTrigLabel: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    StartThresholdLabel: TLabel;
    StopThresholdLabel: TLabel;
    StopTrigCB: TComboBox;
    StartTrigCB: TComboBox;
    StartXFE: TFloatEdit;
    StopXFE: TFloatEdit;
    FindIntervalCB: TCheckBox;
    SignalLengthFE: TFloatEdit;
    StartThresholdFE: TFloatEdit;
    StopThresholdFE: TFloatEdit;
    StartTrigNumber: TIntEdit;
    StartNumberLabel: TLabel;
    StopNumberLabel: TLabel;
    StoptTrigNumber: TIntEdit;
    AxisColorBox: TColorBox;
    AxisColor: TLabel;
    Страницы: TTabSheet;
    Label5: TLabel;
    ColSE: TSpinEdit;
    RowSE: TSpinEdit;
    PageStyleRG: TRadioGroup;
    Label4: TLabel;
    AxisStyleRG: TRadioGroup;
    TrigX1FE: TFloatEdit;
    TrigX2FE: TFloatEdit;
    Label6: TLabel;
    Label7: TLabel;
    SyncCursorsCB: TCheckBox;
    procedure GraphTVGetImageIndexEx(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer;
      var ImageList: TCustomImageList);
    procedure GraphTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure OkBtnClick(Sender: TObject);
    procedure XFEminEnter(Sender: TObject);
    procedure XFEmaxEnter(Sender: TObject);
    procedure UnitsXEditEnter(Sender: TObject);
    procedure LogXCBEnter(Sender: TObject);
    procedure ScaleXCBEnter(Sender: TObject);
    procedure TabControlEnter(Sender: TObject);
    procedure YminFEEnter(Sender: TObject);
    procedure YmaxFEEnter(Sender: TObject);
    procedure UnitsYEditEnter(Sender: TObject);
    procedure LogYCBEnter(Sender: TObject);
    procedure ScaleYCBEnter(Sender: TObject);
    procedure SelObjLBDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SelObjLBMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TabControlChange(Sender: TObject);
    procedure FindIntervalCBClick(Sender: TObject);
    procedure SrcLVClick(Sender: TObject);
    procedure GraphTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure GraphTVDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure GraphTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure AxisStyleRGEnter(Sender: TObject);
    procedure StartTrigCBChange(Sender: TObject);
    procedure StopTrigCBChange(Sender: TObject);
    procedure PageStyleRGClick(Sender: TObject);
  private
    mng:cWpObjMng;
    selAxis, selPages, SelGraphs, selLines:cSelectList;
    changeG, changeA:boolean;
    selSrc:csrc;
  protected
    procedure ShowGraph;
    // отобразить свойства осей
    procedure GetAxisOpts;
    procedure GetGraphOpts;
    procedure GetLinesOpts;
    procedure GetPageOpts;
    procedure SetLinesOpts;
    procedure SetAxisOpts;
    procedure SetGraphOpts;
    procedure SetPagesOpts;
    procedure ShowSelAxis;
    procedure ShowSelPages;
    procedure ShowSelGraphs;
    procedure ShowSelLines;
    procedure FillGraphCB;
  public
    function showmodal:integer; override;
    procedure Linc(p_mng:cWpObjMng);
    constructor Create(AOwner: TComponent);override;
    destructor destroy;override;
  end;



var
  GraphFrm: TGraphFrm;

const
  c_pageindex=1;
  c_axisindex=4;
  c_lineindex=11;

implementation

{$R *.dfm}

procedure TGraphFrm.GraphTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  case TabControl.TabIndex of
    0:GetGraphOpts; // отобразить свойства графиков
    1:GetAxisOpts; // отобразить свойства осей
    2:GetLinesOpts; // отобразить свойства осей;
    3:GetPageOpts; // отобразить свойства осей;
  end;
end;

procedure TGraphFrm.GraphTVDragAllowed(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := True;
end;

procedure TGraphFrm.GraphTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  pSource, pTarget: PVirtualNode;
  attMode: TVTNodeAttachMode;
  data:pnodedata;
  srcObj, dstObj:cwpobj;
begin
  pSource := TVirtualStringTree(Source).FocusedNode;
  pTarget := Sender.DropTargetNode;

  data:=GraphTV.GetNodeData(pSource);
  srcObj:=cwpobj(data.data);

  data:=GraphTV.GetNodeData(pTarget);
  dstObj:=cwpobj(data.data);
  if srcObj is cwpline then
  begin
    if dstObj is cwpAxis then
      srcobj.parent:=dstObj;
  end;
  ShowGraph;

  //case Mode of
  //  dmNowhere: attMode := amNoWhere;
  //  dmAbove: attMode := amInsertBefore;
  //  dmOnNode, dmBelow: attMode := amInsertAfter;
  //end;
  //Sender.MoveTo(pSource, pTarget, attMode, False);
end;

procedure TGraphFrm.GraphTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
begin
  Accept:=(Source = Sender);
end;

procedure TGraphFrm.GraphTVGetImageIndexEx(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer;
  var ImageList: TCustomImageList);
var
  data:pnodedata;
begin
  // For this demo only the normal image is shown, you can easily
  // change this for the state and overlay images.
  case Kind of
    ikNormal, ikSelected:
      begin
        Data := Sender.GetNodeData(Node);
        //Ghosted := Node.Index = 1;
        ImageIndex := Data.ImageIndex;
        //case Column of
          //-1, // general case
          //0:  // main column

          //1: // image only column
          //  if Sender.FocusedNode = Node then
          //    ImageIndex := 6;
        //end;
      end;
    ikOverlay:
      begin
        // Enable this code to show an arbitrary overlay for each image.
        // Note the high overlay index. Standard overlays only go up to 15.
        // Virtual Treeview allows for any number.
        // ImageList := ImageList1;
        // ImageIndex := 58;
      end;
  end;
end;

procedure TGraphFrm.Linc(p_mng:cWpObjMng);
begin
  mng:=p_mng;
end;

procedure TGraphFrm.LogXCBEnter(Sender: TObject);
begin
  changeG:=true;
end;

procedure TGraphFrm.LogYCBEnter(Sender: TObject);
begin
  changeA:=true;
end;

procedure TGraphFrm.OkBtnClick(Sender: TObject);
begin
  case TabControl.TabIndex of
    0:SetGraphOpts; // отобразить свойства графиков
    1:SetAxisOpts; // отобразить свойства осей
    2:SetLinesOpts;
    3:SetPagesOpts;
  end;
  wp.Refresh;
end;

procedure TGraphFrm.PageStyleRGClick(Sender: TObject);
begin
  case PageStyleRG.ItemIndex of
    c_pageStyle_Row:
    begin
      rowSE.Value:=1;
      rowSE.Enabled:=false;
      ColSE.Enabled:=false;
    end;
    c_pageStyle_col:
    begin
      ColSE.Value:=1;
      rowSE.Enabled:=false;
      ColSE.Enabled:=false;
    end;
    c_pageStyle_table:
    begin
      rowSE.Enabled:=true;
      ColSE.Enabled:=true;
    end;
  end;
end;

procedure TGraphFrm.AxisStyleRGEnter(Sender: TObject);
begin
  changeG:=true;
end;

constructor TGraphFrm.Create(AOwner: TComponent);
begin
  inherited;
  selAxis:=cSelectList.create;
  selPages:=cSelectList.create;
  SelGraphs:=cSelectList.create;
  selLines:=cSelectlist.create;
end;

destructor TGraphFrm.destroy;
begin
  selAxis.destroy;
  selPages.destroy;
  selGraphs.destroy;
  selLines.destroy;
end;

procedure TGraphFrm.FindIntervalCBClick(Sender: TObject);
begin
  StartTrigCB.Enabled:=FindIntervalCB.Checked;
  StopTrigCB.Enabled:=FindIntervalCB.Checked;
  if StopTrigCB.ItemIndex<>-1 then
  begin
    if StopTrigCB.Items.Objects[StopTrigCB.ItemIndex]=nil then
    begin
      SignalLengthFE.Enabled:=FindIntervalCB.Checked;
    end
    else
      SignalLengthFE.Enabled:=false;
    end;
end;

function TGraphFrm.showmodal:integer;
var
  I: Integer;
  s:csrc;
begin
  changeG:=false;
  changeA:=true;
  SelObjLB.Clear;
  selAxis.clear;
  selPages.clear;
  selGraphs.clear;
  LineSrcCB.Clear;

  for I := 0 to mng.SrcCount - 1 do
  begin
    s:=mng.GetSrc(i);
    if i=0 then
    begin
      selSrc:=mng.SelectedSrc;
      FillGraphCB;
    end;
    LineSrcCB.Items.Add(s.name);
    LineSrcCB.ItemIndex:=-1;
  end;

  ShowGraph;

  if inherited=mrok then
  begin

  end;
end;

procedure GetGraphAxisWP(g:cwpGraph; l:cselectlist);
var
  I: Integer;
  a:cwpaxis;
begin
  for I := 0 to g.ChildCount - 1 do
  begin
    a:=cwpaxis(g.getChild(i));
    l.AddObj(a);
  end;
end;

procedure GetPageAxisWP(p:cwppage; l:cselectlist);
var
  g:cwpgraph;
  I: Integer;
begin
  for I := 0 to p.ChildCount - 1 do
  begin
    G:=cwpgraph(p.getChild(i));
    GetGraphAxisWP(g, l);
  end;
end;

procedure GetPageGraphWP(p:cwppage; l:cselectlist);
var
  g:cwpgraph;
  I: Integer;
begin
  for I := 0 to p.ChildCount - 1 do
  begin
    G:=cwpgraph(p.getChild(i));
    if g is cwpgraph then
      l.AddObj(g);
  end;
end;

procedure GetAxisLineWP(a:cwpaxis; l:cselectlist);
var
  I: Integer;
  line:cwpline;
begin
  for I := 0 to a.ChildCount - 1 do
  begin
    line:=cwpline(a.getChild(i));
    l.AddObj(line);
  end;
end;

procedure GetGraphLineWP(g:cwpgraph; l:cselectlist);
var
  a:cwpaxis;
  I: Integer;
begin
  for I := 0 to g.ChildCount - 1 do
  begin
    a:=cwpaxis(g.getChild(i));
    GetAxisLineWP(a, l);
  end;
end;

procedure GetPageLineWP(p:cwppage; l:cselectlist);
var
  g:cwpgraph;
  I: Integer;
begin
  for I := 0 to p.ChildCount - 1 do
  begin
    G:=cwpgraph(p.getChild(i));
    GetGraphLineWP(g,l);
  end;
end;


procedure GetLineAxisWP(line:cwpLine; l:cselectlist);
var
  a:cwpaxis;
  I: Integer;
begin
  a:=cwpaxis(line.parent);
  l.AddObj(a);
end;

procedure TGraphFrm.GetAxisOpts;
var
  I: Integer;
  node:PVirtualNode;
  data:pnodedata;
  obj:cwpobj;
  ax:cwpaxis;
begin
  i:=0;
  selAxis.Clear;
  // получаем список выбранных осей
  if GraphTV.SelectedCount>0 then
  begin
    node:=GraphTV.GetFirstSelected(true);
    while node<>nil do
    begin
      data:=GraphTV.GetNodeData(node);
      obj:=cwpobj(data.data);
      if obj is cwppage then
      begin
        GetPageAxisWP(cwppage(obj),selAxis);
      end;
      if obj is cwpGraph then
      begin
        GetGraphAxisWP(cwpGraph(obj),selAxis);
      end;
      if obj is cwpAxis then
      begin
        selAxis.AddObj(obj);
      end;
      if obj is cwpLine then
      begin
        GetLineAxisWP(cwpLine(obj),selAxis);
      end;
      node:=GraphTV.GetNextSelected(node, true);
      inc(i);
    end;
  end;
  // получаем опции
  if selAxis.Count>0 then
  begin
    ax:=cwpaxis(selAxis.Items[0]);
    // настройки первой оси
    YminFE.FloatNum:=ax.ZoomAxis.x;
    YmaxFE.FloatNum:=ax.ZoomAxis.y;
    UnitsYEdit.Text:=ax.szName;
    LogYCB.Checked:=ax.log;
    AxisColorBox.Enabled:=selAxis.Count=1;
    if AxisColorBox.Enabled then
      AxisColorBox.Color:=ax.color
    else
      AxisColorBox.Color:=clBlack;
    if LogYCB.Checked then
    begin
      LogYCB.State:=cbChecked;
    end
    else
    begin
      LogYCB.State:=cbUnchecked;
    end;
    ScaleYCB.Checked:=ax.autoscale;
    if ScaleYCB.Checked then
    begin
      ScaleYCB.State:=cbChecked;
    end
    else
    begin
      ScaleYCB.State:=cbUnchecked;
    end;

    for I := 1 to selAxis.Count - 1 do
    begin
      ax:=cwpaxis(selAxis.Items[i]);
      if YminFE.FloatNum<>ax.ZoomAxis.x then
      begin
        YminFE.Text:='';
      end;
      if YmaxFE.FloatNum<>ax.ZoomAxis.y then
      begin
        YmaxFE.Text:='';
      end;
      if UnitsYEdit.Text<>ax.szName then
      begin
        UnitsYEdit.Text:='';
      end;
      if LogYCB.Checked<>ax.log then
      begin
        LogYCB.State:= cbGrayed;
      end;
      if ScaleYCB.Checked<>ax.autoscale then
      begin
        ScaleYCB.State:= cbGrayed;
      end;
    end;
  end;
  ShowSelAxis;
end;

procedure TGraphFrm.ScaleXCBEnter(Sender: TObject);
begin
  changeG:=true;
end;

procedure TGraphFrm.ScaleYCBEnter(Sender: TObject);
begin
  changeA:=true;
end;

procedure TGraphFrm.SelObjLBDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  obj:cwpobj;
  red:boolean;
begin
  red:=false;
  with SelObjLB.Canvas do
  begin
    obj := cwpobj(SelObjLB.Items.Objects[Index]);
    if obj is cwpGraph then
    begin
      if cwpGraph(obj).hgraph=0 then
        red:=true;
    end;
    if obj is cwpAxis then
    begin
      if cwpAxis(obj).haxis=0 then
        red:=true;
    end;
    if obj is cwpLine then
    begin
      if (cwpLine(obj).hline=0) or (cwpLine(obj).Signal=nil) then
        red:=true;
    end;

    if red then
    begin
      //Если прорисовываемая строка чётная.
      Brush.Color := $008080FF;
      FillRect(Rect);
      Font.Color :=clBlack; //RGB(255, 255, 255);
      TextOut(Rect.Left, Rect.Top, SelObjLB.Items[Index]);
    end
    else
    begin
      FillRect(Rect);
      if Index >= 0 then
        TextOut(Rect.Left + 2, Rect.Top, SelObjLB.Items[Index]);
      // дефолтная отрисовка
    end;
  end;
end;

procedure TGraphFrm.SelObjLBMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i:integer;
  obj:cwpobj;
  h:boolean;
begin
  i:=selObjLB.ItemAtPos(point(x,y),true);
  h:=false;
  if i>=0 then
  begin
    obj := cwpobj(SelObjLB.Items.Objects[i]);
    if obj is cwpGraph then
    begin
      if cwpGraph(obj).hgraph=0 then
        h:=true;
    end;
    if obj is cwpAxis then
    begin
      if cwpAxis(obj).haxis=0 then
        h:=true;
    end;
    if obj is cwpLine then
    begin
      if cwpLine(obj).hline=0 then
        h:=true;
    end;
  end;
  SelObjLB.ShowHint:=h;
end;

procedure TGraphFrm.SetAxisOpts;
var
  i:integer;
  ax:cwpaxis;
begin
  for I := 0 to selAxis.Count - 1 do
  begin
    ax:=cwpaxis(selAxis.Items[i]);
    if YminFE.text<>'' then
      ax.ZoomAxis.x:=YminFE.FloatNum;
    if YmaxFE.text<>'' then
      ax.ZoomAxis.y:=YmaxFE.FloatNum;
    if UnitsYEdit.text<>'' then
      ax.szName:=UnitsYEdit.Text;
    if LogYCB.state<>cbGrayed then
      ax.log:=LogYCB.Checked;
    if ScaleYCB.state<>cbGrayed then
      ax.autoscale:=ScaleYCB.Checked;
    if AxisColorBox.Enabled then
      ax.color:=AxisColorBox.Color;
    if changeA then
    begin
      if ax.haxis<>0 then
      begin
        ax.ApplyOpts;
      end;
    end;
  end;
end;

procedure TGraphFrm.SetGraphOpts;
var
  i:integer;
  g:cwpGraph;
begin
  changeG:=true;
  for I := 0 to selGraphs.Count - 1 do
  begin
    g:=cwpGraph(selGraphs.Items[i]);
    if XFEmin.text<>'' then
      g.ZoomXAxis.x:=XFEmin.FloatNum;
    if XFEmax.text<>'' then
      g.ZoomXAxis.y:=XFEmax.FloatNum;
    if UnitsXEdit.text<>'' then
      g.XName:=UnitsXEdit.Text;
    if LogXCB.state<>cbGrayed then
      g.LogX:=LogXCB.Checked;
    if ScaleXCB.state<>cbGrayed then
      g.autoscale:=ScaleXCB.Checked;

    // Включение поиска границ отображения
    if FindIntervalCB.state<>cbGrayed then
    begin
      g.FindInterval:=FindIntervalCB.Checked;
    end;
    // Длина сигнала
    if SignalLengthFE.text<>'' then
      g.SignalLength:=SignalLengthFE.FloatNum;
    // канал триггер по СТАРТу
    if StartTrigCB.text<>'' then
    begin
      if StartTrigCB.ItemIndex<>-1 then
        g.StartTrig:=ctrig(StartTrigCB.Items.Objects[StartTrigCB.ItemIndex]);
    end
    else
    begin
      g.StartTrig:=nil;
    end;
    // канал триггер по СТОПу
    if StopTrigCB.text<>'' then
    begin
      if StopTrigCB.ItemIndex<>-1 then
        g.StopTrig:=ctrig(StopTrigCB.Items.Objects[StopTrigCB.ItemIndex])
    end
    else
    begin
      g.StopTrig:=nil;
    end;
    if ProfileCB.state<>cbGrayed then
      g.Tubes:=ProfileCB.Checked;
    // расположение осей
    if AxisStyleRG.ItemIndex<>-1 then
    begin
      g.AXROW:=(AxisStyleRG.ItemIndex=1);
    end;
    if changeG then
    begin
      if g.hgraph<>0 then
      begin
        g.ApplyOpts;
      end;
    end;
  end;
  changeG:=false;
end;

procedure TGraphFrm.SetLinesOpts;
var
  i:integer;
  l:cwpLine;
begin
  for I := 0 to selLines.Count - 1 do
  begin
    l:=cwpLine(selLines.Items[i]);
    if LineColorCB.Colors[LineColorCB.ItemIndex]<>clblack then
      l.color:=LineColorCB.Colors[LineColorCB.ItemIndex];
    if LineWidthEdit.text<>'' then
      l.width:=LineWidthEdit.IntNum;
    // сплошная / пунктир
    if LineTypeCB.text<>'' then
      l.LineType:=LineTypeCB.ItemIndex;
    // только точки
    l.ONLYPOINTS:=not drawlinecb.Checked;
    // вертикальные линии
    l.LINE2BASE:=linebasecb.Checked;
    if l.hline<>0 then
    begin
      l.ApplyOpts;
    end;
  end;
  wp.Refresh;
end;

procedure TGraphFrm.GetLinesOpts;
var
  I: Integer;
  node:PVirtualNode;
  data:pnodedata;
  obj:cwpobj;
  line, l:cwpLine;
  s:csrc;
begin
  i:=0;
  SelLines.Clear;
  // получаем список выбранных линий
  if GraphTV.SelectedCount>0 then
  begin
    node:=GraphTV.GetFirstSelected(true);
    while node<>nil do
    begin
      data:=GraphTV.GetNodeData(node);
      obj:=cwpobj(data.data);
      if obj is cwppage then
      begin
        GetPagelineWP(cwppage(obj),SelLines);
      end;
      if obj is cwpGraph then
      begin
        GetGraphlineWP(cwpgraph(obj),SelLines);
      end;
      if obj is cwpAxis then
      begin
        GetAxisLineWP(cwpaxis(obj),SelLines);
      end;
      if obj is cwpLine then
      begin
        SelLines.AddObj(cwpObj(obj));
      end;
      node:=GraphTV.GetNextSelected(node, true);
      inc(i);
    end;
  end;
  // Получаем опции
  if SelLines.Count>0 then
  begin
    line:=cwpLine(SelLines.Items[0]);
    // сплошная, прерывистая
    linetypecb.ItemIndex:=line.linetype;
    for I := 1 to SelLines.Count - 1 do
    begin
      l:=cwpline(SelLines.Items[i]);
      if LineTypeCB.ItemIndex<>l.LineType then
      begin
        LineNameEdit.text:='';
        break;
      end;
    end;
    // настройки первой оси
    LineNameEdit.text:=line.signalname;
    for I := 1 to SelLines.Count - 1 do
    begin
      l:=cwpline(SelLines.Items[i]);
      if LineNameEdit.text<>l.signalname then
      begin
        LineNameEdit.text:='';
        break;
      end;
    end;
    // только точки
    drawlinecb.Checked:=not line.onlypoints;
    if drawlinecb.Checked then
    begin
      drawlinecb.State:= cbChecked;
    end
    else
    begin
      drawlinecb.State:= cbUnchecked;
    end;
    for I := 1 to SelLines.Count - 1 do
    begin
      l:=cwpline(SelLines.Items[i]);
      if drawlinecb.Checked<>not l.onlypoints then
      begin
        drawlinecb.State:= cbGrayed;
      end;
    end;
    // Вертикальные линии
    LineBaseCB.Checked:=line.LINE2BASE;
    if not LineBaseCB.Checked then
    begin
      LineBaseCB.State:= cbUnchecked;
    end
    else
    begin
      LineBaseCB.State:= cbChecked;
    end;
    for I := 1 to SelLines.Count - 1 do
    begin
      l:=cwpline(SelLines.Items[i]);
      if LineBaseCB.Checked<>l.LINE2BASE then
      begin
        LineBaseCB.State:= cbGrayed;
      end;
    end;

    LineColorCB.Color:=line.color;
    for I := 1 to SelLines.Count - 1 do
    begin
      l:=cwpline(SelLines.Items[i]);
      if LineColorCB.Color<>l.Color then
      begin
        LineColorCB.Color:=clBlack;
        break;
      end;
    end;
    LineWidthEdit.intNum:=line.width;
    for I := 1 to SelLines.Count - 1 do
    begin
      l:=cwpline(SelLines.Items[i]);
      if LineWidthEdit.intNum<>l.width then
      begin
        LineWidthEdit.Text:='';
        break;
      end;
    end;

    s:=mng.GetSrcID(line.srcid);
    if s<>nil then
      LineSrcCB.text:=s.name
    else
      LineSrcCB.text:='';
    for I := 1 to SelLines.Count - 1 do
    begin
      l:=cwpline(SelLines.Items[i]);
      s:=mng.GetSrcID(l.srcid);
      if s<>nil then
      begin
        if LineSrcCB.text<>s.name then
        begin
          LineNameEdit.text:='';
          break;
        end;
      end;
    end;
  end;
  // отображаем линии
  ShowSelLines;
end;

procedure TGraphFrm.GetPageOpts;
var
  I: Integer;
  node:PVirtualNode;
  data:pnodedata;
  obj:cwpobj;
  p:cwpPage;
begin
  i:=0;
  selPages.Clear;
  // получаем список выбранных осей
  if GraphTV.SelectedCount>0 then
  begin
    node:=GraphTV.GetFirstSelected(true);
    while node<>nil do
    begin
      data:=GraphTV.GetNodeData(node);
      obj:=cwpobj(data.data);
      if obj is cwppage then
      begin
        SelPages.AddObj(obj);
      end;
      if obj is cwpGraph then
      begin
        SelPages.AddObj(obj.parent);
      end;
      if obj is cwpAxis then
      begin
        SelPages.AddObj(obj.parent.parent);
      end;
      if obj is cwpLine then
      begin
        SelPages.AddObj(obj.parent.parent.parent);
      end;
      node:=GraphTV.GetNextSelected(node, true);
      inc(i);
    end;
  end;
  // получаем опции
  if SelPages.Count>0 then
  begin
    p:=cwppage(selPages.Items[0]);
    SyncCursorsCB.Checked:=p.SyncCursors;
    // устанавливаем расположение графиков
    PageStyleRG.ItemIndex:=p.GetPageStyle;
    ColSE.Value:=p.graphtable.y;
    RowSE.Value:=p.graphtable.x;
    if SelPages.Count>1 then
    begin
      for I := 1 to SelPages.Count - 1 do
      begin
        p:=cwppage(selPages.Items[i]);
        // Стиль страницы
        if PageStyleRG.ItemIndex<>-1 then
        begin
          if PageStyleRG.ItemIndex<>p.GetPageStyle then
          begin
            PageStyleRG.ItemIndex:=-1;
          end;
        end;
        // Число столбцов
        if ColSE.text<>'' then
        begin
          if ColSE.Value<>p.graphtable.y then
            ColSE.text:='';
        end;
        // Число строк
        if RowSE.text<>'' then
        begin
          if RowSE.Value<>p.graphtable.x then
            RowSE.text:='';
        end;
        // Синхронизация курсора
        if SyncCursorsCB.State<>cbGrayed then
        begin
          if p.SyncCursors<>SyncCursorsCB.Checked then
            SyncCursorsCB.State:=cbGrayed;
        end;
      end;
    end;
  end;
  ShowSelPages;
end;

procedure TGraphFrm.SetPagesOpts;
var
  i:integer;
  p:cwppage;
begin
  for I := 0 to SelPages.Count - 1 do
  begin
    p:=cwppage(selPages.Items[i]);
    if SyncCursorsCB.State<>cbGrayed then
    begin
      p.SyncCursors:=SyncCursorsCB.Checked;
    end;
    p.graphtable.X:=RowSE.Value;
    p.graphtable.y:=colSE.Value;
    p.ApplyOpts;
  end;
end;

procedure TGraphFrm.GetGraphOpts;
var
  I: Integer;
  node:PVirtualNode;
  data:pnodedata;
  obj:cwpobj;
  g:cwpGraph;
begin
  i:=0;
  SelGraphs.Clear;
  // получаем список выбранных осей
  if GraphTV.SelectedCount>0 then
  begin
    node:=GraphTV.GetFirstSelected(true);
    while node<>nil do
    begin
      data:=GraphTV.GetNodeData(node);
      obj:=cwpobj(data.data);
      if obj is cwppage then
      begin
        GetPageGraphWP(cwppage(obj),selGraphs);
      end;
      if obj is cwpGraph then
      begin
        SelGraphs.AddObj(obj);
      end;
      if obj is cwpAxis then
      begin
        SelGraphs.AddObj(cwpObj(obj).parent);
      end;
      if obj is cwpLine then
      begin
        SelGraphs.AddObj(cwpObj(obj).parent.parent);
      end;
      node:=GraphTV.GetNextSelected(node, true);
      inc(i);
    end;
  end;
  // получаем опции
  if SelGraphs.Count>0 then
  begin
    g:=cwpGraph(selGraphs.Items[0]);
    // настройки первой оси
    XFEmin.FloatNum:=g.ZoomXAxis.x;
    XFEmax.FloatNum:=g.ZoomXAxis.y;
    UnitsXEdit.Text:=g.XName;
    LogXCB.Checked:=g.LogX;
    if LogXCB.Checked then
    begin
      LogXCB.State:=cbChecked;
    end
    else
    begin
      LogXCB.State:=cbUnchecked;
    end;

    ProfileCB.Checked:=g.Tubes;
    if ProfileCB.Checked then
    begin
      ProfileCB.State:=cbChecked;
    end
    else
    begin
      ProfileCB.State:=cbUnchecked;
    end;


    ScaleXCB.Checked:=g.autoscale;
    if ScaleXCB.Checked then
    begin
      ScaleXCB.State:=cbChecked;
    end
    else
    begin
      ScaleXCB.State:=cbUnchecked;
    end;
    // расположение осей
    if g.AXROW then
    begin
      AxisStyleRG.ItemIndex:=1;
    end
    else
    begin
      AxisStyleRG.ItemIndex:=0;
    end;

    FindIntervalCB.Checked:=g.FindInterval;
    if FindIntervalCB.Checked then
    begin
      FindIntervalCB.state:=cbChecked;
    end
    else
    begin
      FindIntervalCB.state:=cbUnchecked;
    end;

    if (g.startTrig<>nil) then
    begin
      StartTrigCB.text:=g.StartTrig.TrigName;
      StartThresholdFE.FloatNum:=g.StartTrig.Threshold;
      StartXFE.FloatNum:=g.StartTrig.shift;
      trigX1FE.FloatNum:=g.StartTrig.GetTime;
    end
    else
    begin
      StartTrigCB.text:='';
    end;
    if (g.stopTrig<>nil) then
    begin
      StopTrigCB.text:=g.StopTrig.TrigName;
      StopThresholdFE.FloatNum:=g.StopTrig.Threshold;
      StopXFE.FloatNum:=g.StopTrig.shift;
      trigX2FE.FloatNum:=g.StopTrig.GetTime;
    end
    else
    begin
      StopTrigCB.text:='';
    end;
    SignalLengthFE.FloatNum:=g.SignalLength;

    for I := 1 to selGraphs.Count - 1 do
    begin
      g:=cwpgraph(selGraphs.Items[i]);
      if g.StartTrig<>nil then
      begin
        if (StartTrigCB.text<>g.StartTrig.TrigName) then
        begin
          if (StartTrigCB.Text<>'') then
            StartTrigCB.Text:='';
        end;
        if (StartThresholdFE.FloatNum<>g.starttrig.Threshold) and (StartThresholdFE.Text<>'') then
        begin
          StartThresholdFE.Text:='';
        end;
        if (StartXFE.FloatNum<>g.starttrig.shift) and (StartXFE.Text<>'') then
        begin
          StartXFE.Text:='';
        end;
      end;
      if g.StopTrig<>nil then
      begin
        if (StopTrigCB.text<>g.StopTrig.TrigName) then
        begin
          if StopTrigCB.Text<>'' then
            StopTrigCB.Text:='';
        end;
        if (StopThresholdFE.FloatNum<>g.stoptrig.Threshold) and (StopThresholdFE.Text<>'') then
        begin
          StopThresholdFE.Text:='';
        end;
        if (StopXFE.FloatNum<>g.StopTrig.shift) and (StopXFE.Text<>'') then
        begin
          StopXFE.Text:='';
        end;
      end;
      if (SignalLengthFE.FloatNum<>g.SignalLength) and (SignalLengthFE.Text<>'') then
      begin
        SignalLengthFE.Text:='';
      end;
      if (FindIntervalCB.Checked<>g.FindInterval) and (FindIntervalCB.State<>cbGrayed) then
      begin
        FindIntervalCB.State:= cbGrayed;
      end;

      if (XFEmin.FloatNum<>g.ZoomXAxis.x) and (XFEmin.Text<>'') then
      begin
        XFEmin.Text:='';
      end;
      if (XFEmax.FloatNum<>g.ZoomXAxis.y) and (XFEmax.Text<>'') then
      begin
        XFEmax.Text:='';
      end;
      if (UnitsXEdit.Text<>g.XName) and (UnitsXEdit.Text<>'') then
      begin
        UnitsXEdit.Text:='';
      end;
      if (LogXCB.Checked<>g.logX) and (LogXCB.State<>cbGrayed) then
      begin
        LogXCB.State:= cbGrayed;
      end;
      if (ScaleXCB.Checked<>g.autoscale) and (ScaleXCB.State<>cbGrayed) then
      begin
        ScaleXCB.State:= cbGrayed;
      end;
      // расположение осей
      if AxisStyleRG.ItemIndex<>-1 then
      begin
        if g.AXROW then
        begin
          if AxisStyleRG.ItemIndex=0 then
            AxisStyleRG.ItemIndex:=-1;
        end
        else
        begin
          if AxisStyleRG.ItemIndex=1 then
            AxisStyleRG.ItemIndex:=-1;
        end;
      end;
      if (ProfileCB.Checked<>g.Tubes) and (LogXCB.State<>cbGrayed) then
      begin
        LogXCB.State:= cbGrayed;
      end;
    end;
  end;
  ShowSelGraphs;
end;

procedure TGraphFrm.ShowSelGraphs;
var
  i:integer;
  g:cwpGraph;
begin
  selObjLB.Clear;
  for I := 0 to selGraphs.Count - 1 do
  begin
    g:=cwpGraph(selGraphs.Items[i]);
    selObjLB.AddItem(g.name,g);
  end;
end;

procedure TGraphFrm.ShowSelLines;
var
  i:integer;
  line:cwpLine;
begin
  selObjLB.Clear;
  for I := 0 to selLines.Count - 1 do
  begin
    line:=cwpLine(selLines.Items[i]);
    selObjLB.AddItem(line.signalname,line);
  end;
end;

procedure TGraphFrm.SrcLVClick(Sender: TObject);
begin
  //if srclv.Items[srclv.ItemIndex]<>nil then
  //begin
  //  selsrc:=csrc(srclv.Items[srclv.ItemIndex]);
  //end;
  //FillGraphCB;
end;

procedure TGraphFrm.StartTrigCBChange(Sender: TObject);
var
  t:ctrig;
begin
  t:=ctrig(starttrigcb.Items.Objects[starttrigcb.ItemIndex]);
  StartThresholdFE.FloatNum:=t.Threshold;
  StartXFE.FloatNum:=t.shift;
  StartTrigNumber.IntNum:=t.number;
  TrigX1FE.FloatNum:=t.GetTime;
end;

procedure TGraphFrm.StopTrigCBChange(Sender: TObject);
var
  t:ctrig;
begin
  t:=ctrig(stoptrigcb.Items.Objects[stoptrigcb.ItemIndex]);
  stopThresholdFE.FloatNum:=t.Threshold;
  stopXFE.FloatNum:=t.shift;
  StoptTrigNumber.IntNum:=t.number;
  TrigX2FE.FloatNum:=t.GetTime;
end;

procedure TGraphFrm.TabControlChange(Sender: TObject);
begin
  GraphTVChange(nil,nil);
end;

procedure TGraphFrm.TabControlEnter(Sender: TObject);
begin
  changeA:=true;
end;

procedure TGraphFrm.UnitsXEditEnter(Sender: TObject);
begin
  changeG:=true;
end;

procedure TGraphFrm.UnitsYEditEnter(Sender: TObject);
begin
  changeA:=true;
end;

procedure TGraphFrm.XFEmaxEnter(Sender: TObject);
begin
  changeG:=true;
end;

procedure TGraphFrm.XFEminEnter(Sender: TObject);
begin
  changeG:=true;
end;

procedure TGraphFrm.YmaxFEEnter(Sender: TObject);
begin
  changeA:=true;
end;

procedure TGraphFrm.YminFEEnter(Sender: TObject);
begin
  changeA:=true;
end;

procedure TGraphFrm.ShowSelAxis;
var
  i:integer;
  ax:cwpaxis;
begin
  selObjLB.Clear;
  for I := 0 to selAxis.Count - 1 do
  begin
    ax:=cwpaxis(selAxis.Items[i]);
    selObjLB.AddItem(ax.name,ax);
  end;
end;

procedure TGraphFrm.ShowSelPages;
var
  i:integer;
  p:cwpPage;
begin
  selObjLB.Clear;
  for I := 0 to selPages.Count - 1 do
  begin
    p:=cwpPage(selPages.Items[i]);
    selObjLB.AddItem(p.name,p);
  end;
end;

procedure TGraphFrm.FillGraphCB;
var
  I: Integer;
  s:cwpSignal;
begin
  StartTrigCB.Clear;
  StopTrigCB.Clear;
  for I := 0 to mng.TrigList.Count - 1 do
  begin
    StartTrigCB.Items.AddObject(ctrig(mng.TrigList.Objects[i]).Trigname, ctrig(mng.TrigList.Objects[i]));
    StopTrigCB.Items.AddObject(ctrig(mng.TrigList.Objects[i]).Trigname, ctrig(mng.TrigList.Objects[i]));
  end;
end;

procedure TGraphFrm.ShowGraph;
var
  obj:cWPObj;
  page:cwppage;
  graph:cwpGraph;
  ax:cwpaxis;
  line:cwpline;
  i, j, k, n:integer;
  node,
  axNode, graphNode, PageNode, LineNode:PVirtualNode;
  d:pnodedata;
begin
  GraphTV.Clear;
  for I := 0 to mng.count - 1 do
  begin
    obj := mng.getWPObj(i);
    if obj is cWPPage then
    begin
      page:=cwppage(obj);
      node:=GraphTV.AddChild(nil);
      PageNode:=node;
      d:=GraphTV.GetNodeData(node);
      d.color:=GraphTV.normalcolor;
      if (obj is cwpline) then
        d.caption:=cwpline(obj).signalname
      else
        d.caption:=obj.name;
      d.imageindex:=c_pageindex;
      d.data:=obj;
      for j := 0 to page.ChildCount - 1 do
      begin
        obj:=cwpobj(page.getChild(j));
        if obj is cwpGraph then
        begin
          graph:=cwpgraph(obj);
          node:=GraphTV.AddChild(PageNode);
          GraphNode:=node;
          d:=GraphTV.GetNodeData(node);
          d.color:=GraphTV.normalcolor;
          d.caption:=obj.name;
          d.imageindex:=c_pageindex;
          d.data:=obj;
          for k := 0 to graph.childCount - 1 do
          begin
            obj:=cwpobj(graph.getChild(k));
            if obj is cWPAxis then
            begin
              ax:=cwpaxis(obj);
              node:=GraphTV.AddChild(GraphNode);
              axNode:=Node;
              d:=GraphTV.GetNodeData(node);
              d.color:=GraphTV.normalcolor;
              d.caption:=obj.name;
              d.imageindex:=c_axisindex;
              d.data:=obj;
              for n := 0 to ax.ChildCount - 1 do
              begin
                obj := cWPObj(ax.getChild(n));
                if obj is cWPLine then
                begin
                  line:=cWPLine(cWPLine(ax.getChild(n)));
                  node:=GraphTV.AddChild(AxNode);
                  d:=GraphTV.GetNodeData(node);
                  d.color:=GraphTV.normalcolor;
                  d.caption:=obj.name;
                  d.imageindex:=c_lineindex;
                  d.data:=obj;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function IDComparator(p1,p2:pointer):integer;
begin
  if cardinal(p1)>cardinal(p2) then
  begin
    result:=1;
  end
  else
  begin
    if cardinal(p1)<cardinal(p2) then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;

constructor cSelectList.create;
begin
  inherited;
  comparator:=IDComparator;
  destroydata:=false;
end;

procedure cSelectList.deletechild(node:pointer);
begin
  tobject(node).destroy;
end;



end.
