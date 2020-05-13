unit uVTServices;

interface
uses
  classes, VirtualTrees, Graphics, types, imglist, dialogs;

type
  //TGetNodeDataSizeProc = procedure (Sender: TBaseVirtualTree; var NodeDataSize: Integer) of object;

  TGetNodeText = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode;
                      Column: TColumnIndex; TextType: TVSTTextType;
                      var CellText: UnicodeString) of object;


  PNodeData = ^TNodeData;

  TNodeData = record
    Caption,
    StaticText,
    ForeignText: UnicodeString;
    ImageIndex:integer;
    color:integer;
    data:pointer;
    init:boolean;
    ColumnText:tstringlist;
  end;

  TVTree = class (TVirtualStringTree)
  public
    normalcolor:integer;
    // если установлен флаг то строке сопоставляется цвет родительского узла
    parentColor:boolean;
  protected
    procedure InitNode(Node: PVirtualNode); override;
    procedure doVSTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure doVSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
                      Column: TColumnIndex; TextType: TVSTTextType;
                      var CellText: UnicodeString);
    function DoBeforeItemPaint(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect): Boolean; override;
    procedure DoAfterItemPaint(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect); override;
    procedure DoFreeNode(Node: PVirtualNode); override;
    function DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: Integer): TCustomImageList; override;
  public
    // инициализируе5т размер данных для nodeData (надо вызывать принудительно для добавляемых программно нодов в событиях дерева)
    procedure initChildNode(Node: PVirtualNode);
    function GetNodeByName(name:string):pvirtualnode;
    // p = nodedata.data
    function GetNodeByPointer(p:pointer):pvirtualnode;
  public
    //procedure UpdateColumnSize;
    constructor Create(AOwner: TComponent); override;
  end;
  // выделение памяти узлу
  procedure UpdateNode(n:PVirtualNode; t:TVTree);

implementation

procedure UpdateNode(n:PVirtualNode; t:TVTree);
var
  d:pNodeData;
begin
  d:=t.GetNodeData(n);
  //d.caption:='';
  //d.ColumnText:=nil;
  if t.Header.Columns.Count>1 then
  begin
    if not d.init then
    begin
      d.init:=true;
      // устанавливаем число колонок
      d.ColumnText:=TStringList.Create;
      d.color:=t.normalcolor;
    end;
    //setlength(d.ColumnText,t.Header.Columns.Count-1);
  end
  else
  begin
    d.ColumnText:=nil;
  end;
end;

procedure TVTree.InitNode(Node: PVirtualNode);
begin
  inherited;
  UpdateNode(node, self);
end;


function TVTree.DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: Integer): TCustomImageList;
var
  data:pnodedata;
begin
  if not Assigned(OnGetImageIndexEx) then
  begin
    // For this demo only the normal image is shown, you can easily
    // change this for the state and overlay images.
    case Kind of
      //ikNormal, ikSelected:
      ikNormal:
      begin
        Data := GetNodeData(Node);
        //Ghosted := Node.Index = 1;
        case Column of
          -1:Index := Data.ImageIndex;  // general case
          0:Index := Data.ImageIndex;  // main column
          1:; // image only column
        end;
        //  if Sender.FocusedNode = Node then
        //    ImageIndex := 6;
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
  end
  else
  begin
    inherited;
  end;
end;

function TVTree.GetNodeByName(name:string):pvirtualnode;
var
  n:pvirtualnode;
  d:PNodeData;
  I: Integer;
begin
  result:=nil;
  for I := 0 to TotalCount - 1 do
  begin
    if I <> 0 then
      n := GetNext(n)
    else
      n := GetFirst;
    d:=GetNodeData(n);
    if d<>nil then
    begin
      if d.Caption=name then
      begin
        result:=n;
        break;
      end;
    end;
  end;
end;

function TVTree.GetNodeByPointer(p:pointer):pvirtualnode;
var
  n:pvirtualnode;
  d:PNodeData;
  I: Integer;
begin
  result:=nil;
  for I := 0 to TotalCount - 1 do
  begin
    if I <> 0 then
      n := GetNext(n)
    else
      n := GetFirst;
    d:=GetNodeData(n);
    if d<>nil then
    begin
      if d.data=p then
      begin
        result:=n;
        break;
      end;
    end;
  end;
end;



procedure TVTree.initChildNode(Node: PVirtualNode);
var
  d:pnodedata;
begin
  d:=GetNodeData(node);
  if not d.init then
  begin
    InitNode(node);
  end;
end;

constructor TVTree.Create(AOwner: TComponent);
begin
  INHERITED;
  parentColor:=false;
  normalcolor:=clWindow;
  OnGetNodedatasize:=doVSTGetNodeDataSize;
  OnGetText:=doVSTGetText;
  nodeDataSize:=sizeof(TNodeData);
end;

procedure TVTree.DoFreeNode(Node: PVirtualNode);
var
  d:pnodedata;
begin
  d:=GetNodeData(node);
  d.Caption:='';
  if d.init then
  begin
    if Header.Columns.Count>0 then
    begin
      if d.ColumnText<>nil then
      begin
        d.ColumnText.Destroy;
        d.ColumnText:=nil;
      end;
    end;
  end;
  inherited;
end;

function TVTree.DoBeforeItemPaint(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect): Boolean;
var
  data:PNodeData;
  //rootnode:PVirtualNode;
begin
  result:=inherited;
  if node<>nil then
  begin
    if parentColor then
    begin
      while pointer(node.parent.parent)<>pointer(self) do
      begin
        node:=node.Parent;
      end;
    end;
    data:=getnodedata(node);
    color:=data.color;
  end;
end;

procedure TVTree.DoAfterItemPaint(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect);
begin
  inherited;
  color:=normalcolor;
  Refresh;
end;

procedure TVTree.doVSTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize:= SizeOf(TNodeData);
end;

procedure TVTree.doVSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
                      Column: TColumnIndex; TextType: TVSTTextType;
                      var CellText: UnicodeString);
var
  Data: PNodeData;
begin
  if node=nil then exit;
  
  //CellText := Format('Node Level %d, Index %d', [Sender.GetNodeLevel(Node), Node.Index]);
  Data := Sender.GetNodeData(Node);
  if Header.Columns.Count<1 then
  begin
    CellText := data.Caption;
  end
  else
  begin
    case Column of
      0: // main column (has two different captions)
        case TextType of
          ttNormal:
            CellText := Data.Caption;
          ttStatic:
            CellText := Data.StaticText;
        end;
      else
      begin
        // если текст колонок заполнен
        if Data.ColumnText<>nil then
        begin
          if (Data.ColumnText.Count)>(Column-1) then
          begin
            if column>0 then
            begin
              CellText := Data.ColumnText[Column-1];
            end;
          end
          else
          begin
            CellText:='';
          end;
        end;
      end;
    end;
  end;
end;


end.
