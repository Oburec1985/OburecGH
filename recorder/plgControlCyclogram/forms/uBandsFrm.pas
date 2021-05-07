unit uBandsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uTagsListFrame, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons, uBaseAlg,
  uRCFunc, uCommontypes, DCL_MYOWN, uCommonMath, uRcCtrls, Grids, tags, uComponentServises,
  uStringGridExt, VirtualTrees, uVTServices, ImgList, activex, ulogfile;

type

  TBandsFrm = class(TForm)
    TagsListFrame1: TTagsListFrame;
    ActionPanel: TPanel;
    PropGB: TGroupBox;
    PropSG: TStringGridExt;
    Panel1: TPanel;
    BandsGB: TGroupBox;
    BandsLV: TBtnListView;
    installGB: TGroupBox;
    PlacesTV: TVTree;
    BandsActionPanel: TPanel;
    UpdateBandBtn: TSpeedButton;
    AddBandBtn: TSpeedButton;
    PlacesActionPanel: TPanel;
    SpeedButton1: TSpeedButton;
    AddPlaceBtn: TSpeedButton;
    BandPropGB: TGroupBox;
    F1Label: TLabel;
    F2Label: TLabel;
    NameLabel: TLabel;
    F1fe: TFloatEdit;
    F2fe: TFloatEdit;
    AbsCB: TCheckBox;
    NameEdit: TEdit;
    PlacesPropGB: TGroupBox;
    Label3: TLabel;
    PlaceNameEdit: TEdit;
    ImageList1: TImageList;
    ChannelsGB: TGroupBox;
    PairTV: TVTree;
    Splitter1: TSplitter;
    procedure AddBandBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PropSGKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PropSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure PropSGDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PropSGDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure BandsLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure UpdateBandBtnClick(Sender: TObject);
    procedure BandsLVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AddPlaceBtnClick(Sender: TObject);
    procedure PlacesTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure PlacesTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure PlacesTVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PairTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure PairTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure PlacesTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure PairTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    TagBandPairList:TTagBandPairList;
    BandsList:TStringList;
    places:tplaces;
    init:boolean;
    m_val:string;
    m_col:integer;
    m_row:integer;
  private
    procedure UpdateNode(pnode:PVirtualNode);
    procedure UpdatePairNode(pnode:PVirtualNode);
    procedure PropSGEditCell(r,c:integer; v:string);
    procedure initSG;
    procedure LinkRecorder;
    procedure removePlaceFromPairTV(pl:tplace);
    procedure placestotv(pl:tplaces);
    procedure BandToSg(b:tBand);
    procedure BandToLV(b:tBand);
    procedure ShowBands(bl:tstringlist);
    procedure ShowPairList(pl:TTagBandPairList);
    function getK(row:integer):double;
    function getTagName(row:integer):string;
    function genName:string;
  public
    procedure LinkBands(bl:tstringlist; pl:tplaces; pairlist:TTagBandPairList);
    constructor create(aowner:tcomponent);override;
  end;

var
  BandsFrm: TBandsFrm;

const
  c_col_N = 0;
  c_col_tag = 1;
  c_col_K = 2;

  c_im_place = 0;
  c_im_band = 1;
  c_im_TagPair = 2;


implementation

{$R *.dfm}

{ TBandsFrm }


procedure TBandsFrm.AddBandBtnClick(Sender: TObject);
var
  b:tband;
  bt:BandTag;
  name:string;
  i:integer;
begin
  b:=tBand.Create(BandsList);
  name:=genName;
  b.name:=name;
  b.m_f1f2:=p2d(f1fe.FloatNum,f2fe.FloatNum);
  for i:= 1 to PropSG.RowCount - 2 do
  begin
    bt    :=BandTag.Create;
    bt.tagname:=gettagname(i);
    bt.k  :=getK(i);
    b.addBandTag(bt);
  end;
  if abscb.Checked then
    b.valtype:=c_abs
  else
    b.valtype:=c_rate;
  BandsList.AddObject(name, b);
  BandToLV(b);
  LVChange(BandsLV);
end;

procedure TBandsFrm.placestotv(pl: tplaces);
var
  I, j: Integer;
  p:tplace;
  b:tband;
  pNode, bNode:pvirtualnode;
  d:pnodedata;
begin
  if pl=nil then exit;
  placestv.Clear;
  for I := 0 to pl.Count - 1 do
  begin
    p:=pl.getplace(i);
    pnode:=placestv.AddChild(nil);
    d:=placestv.GetNodeData(pnode);
    d.ImageIndex:=0;
    d.data:=p;
    d.color:=placestv.normalcolor;
    UpdateNode(pnode);
  end;
end;


procedure TBandsFrm.UpdateNode(pnode: PVirtualNode);
var
  bnode:PVirtualNode;
  d:pnodedata;
  p:tplace;
  b:tband;
  I: Integer;
begin
  d:=PlacesTV.GetNodeData(pnode);
  p:=tplace(d.data);
  d.Caption:=p.name;
  PlacesTV.DeleteChildren(pnode);
  for I := 0 to p.bands.Count - 1 do
  begin
    b:=p.getBand(i);
    bnode:=placestv.AddChild(pnode);
    d:=placestv.GetNodeData(bnode);
    d.Caption:=b.name;
    d.ImageIndex:=1;
    d.color:=placestv.normalcolor;
    d.data:=b;
  end;
  pNode.States:=pNode.States + [vsExpanded];
end;

procedure TBandsFrm.UpdatePairNode(pnode:PVirtualNode);
var
  bnode, placenode:PVirtualNode;
  d:pnodedata;
  p:TTagBandPair;
  place:tplace;
  I: Integer;
begin
  d:=pairTV.GetNodeData(pnode);
  p:=TTagBandPair(d.data);
  d.Caption:=p.name;
  pairTV.DeleteChildren(pnode);
  for I := 0 to p.placeCount - 1 do
  begin
    place:=p.getplace(i);
    placenode:=pairTV.AddChild(pnode);
    d:=pairTV.GetNodeData(placenode);
    d.Caption:=place.name;
    d.ImageIndex:=c_im_place;
    d.color:=pairTV.normalcolor;
    d.data:=place;
  end;
  pNode.States:=pNode.States + [vsExpanded];
end;

procedure TBandsFrm.AddPlaceBtnClick(Sender: TObject);
var
  I, j: Integer;
  p:tplace;
  b:tband;
  pNode, bNode:pvirtualnode;
  d:pnodedata;
  str:string;
  findname:boolean;
begin
  str:=PlaceNameEdit.text;
  findname:=true;
  while findname do
  begin
    findname:=false;
    for I := 0 to places.Count - 1 do
    begin
      p:=places.getplace(i);
      if p.name=str then
      begin
        str:=ModName(str,false);
        findname:=true;
        break;
      end;
    end;
  end;
  PlaceNameEdit.text:=str;
  p:=TPlace.create(places);
  p.name:=PlaceNameEdit.Text;
  pnode:=placestv.AddChild(nil);
  d:=placestv.GetNodeData(pnode);
  d.Caption:=p.name;
  d.ImageIndex:=0;
  d.data:=p;
  d.color:=placestv.normalcolor;
  places.addplace(p);
end;

procedure TBandsFrm.BandsLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  b:tBand;
  row,I, j: Integer;
  bt:BandTag;
  li:tlistitem;
begin
  if bandsLV.selcount=0 then exit;

  for I := 0 to bandsLV.selcount - 1 do
  begin
    if i=0 then
      li:=bandsLV.selected
    else
      li:=bandsLV.GetNextItem(li, sdBelow, [isSelected]);
    b:=tband(li.Data);
    if i=0 then
    begin
      PropSG.RowCount:=b.tagCount+2;
      // очистка последней строки
      for j := 0 to PropSG.ColCount - 1 do
      begin
        propsg.Cells[j, PropSG.RowCount-1]:='';
      end;
      for j := 0 to b.tagCount - 1 do
      begin
        row:=j+1;
        bt:=b.getbandtag(j);
        propsg.Cells[c_col_tag,row]:=bt.tagname;
        propsg.Cells[c_col_K,row]:=floattostr(bt.k);
      end;
      SGChange(propsg);
    end;
    SetMultiSelectComponentString(nameedit,b.name);
    SetMultiSelectComponentString(f1fe,floattostr(b.m_f1f2.x));
    SetMultiSelectComponentString(f2fe,floattostr(b.m_f1f2.y));
    SetMultiSelectComponentBool(abscb,b.valtype=c_rate);
  end;
  endMultiSelect(nameedit);
  endMultiSelect(f1fe);
  endMultiSelect(f2fe);
  endMultiSelect(abscb);
end;

procedure TBandsFrm.BandsLVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  b:tband;
  li:tlistitem;
  I,j, ind: Integer;
  p:tplace;
  proc: TLVChangeEvent;
begin
  if key=VK_DELETE then
  begin
    for I := 0 to bandslv.Items.Count - 1 do
    begin
      if i=0 then
        li:=bandslv.Selected
      else
        li:=BandsLV.GetNextItem(li,sdAll,[isSelected]);
      if li=nil then
        breAK;
      b:=tband(li.data);
      for j := 0 to places.Count - 1 do
      begin
        p:=places.getplace(j);
        p.delband(b);
      end;
      b.destroy;
      proc:=bandslv.OnChange;
      bandslv.OnChange:=nil;
      li.Destroy;
      bandslv.OnChange:=proc;
    end;
    placestotv(places);
  end;
end;

procedure TBandsFrm.BandToLV(b: tBand);
var
  li:tlistitem;
begin
  li:=BandsLV.items.Add;
  li.data:=b;
  BandsLV.SetSubItemByColumnName('№',inttostr(li.index),li);
  BandsLV.SetSubItemByColumnName('Название',b.name,li);
end;

procedure TBandsFrm.BandToSg(b: tBand);
begin
end;

constructor TBandsFrm.create(aowner: tcomponent);
begin
  inherited;
  init:=false;
  initSG;
end;

procedure TBandsFrm.FormShow(Sender: TObject);
begin
  if not init then
    LinkRecorder;
  ShowBands(BandsList);
  placestotv(places);
  ShowPairList(TagBandPairList);
end;

function findname(sl:tstringlist; name:string):boolean;
var
  I: Integer;
begin
  result:=false;
  for I := 0 to sl.Count - 1 do
  begin
    if sl.strings[i]=name then
    begin
      result:=true;
      exit;
    end;
  end;
end;

function TBandsFrm.genName: string;
var
  i:integer;
begin
  result:=NameEdit.text;
  if bandslist<>nil then
  begin
    while findname(bandsList, result) do
    begin
      result:=modname(result,false);
    end;
  end;
end;

function TBandsFrm.getK(row: integer): double;
begin
  result:=strtofloatext(PropSG.Cells[c_col_K, row]);
end;

function TBandsFrm.getTagName(row: integer): string;
begin
  result:=PropSG.Cells[c_col_tag, row];
end;

procedure TBandsFrm.initSG;
begin
  PropSG.RowCount := 2;
  PropSG.ColCount := 3;

  PropSG.Cells[c_col_N, 0] := '№';
  PropSG.Cells[c_col_tag, 0] := 'Тег';
  PropSG.Cells[c_Col_k, 0] := 'K';
end;

procedure TBandsFrm.LinkBands(bl: tstringlist; pl:tplaces; pairlist:TTagBandPairList);
begin
  BandsList:=bl;
  places:=pl;
  TagBandPairList:=pairlist;
end;

procedure TBandsFrm.LinkRecorder;
begin
  TagsListFrame1.ShowChannels;
  init:=true;
end;

function findNode(li:tlistitem; tv:TVTree):boolean;
var
  I: Integer;
  n:PVirtualNode;
  d:pNodeData;
begin
  result:=false;
  if tv.TotalCount=0 then exit;
  for I := 0 to tv.TotalCount - 1 do
  begin
    if I <> 0 then
      n := tv.GetNext(n)
    else
      n := TV.GetFirst;
    d:=TV.GetNodeData(n);
    if d.Caption=itag(li.data).GetName then
    begin
      result:=true;
      exit;
    end;
  end;
end;

procedure TBandsFrm.PairTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  b:tband;
  p:TTagBandPair;
  place:tplace;
  I: Integer;
  li:tlistitem;
  pnode,placeNode, tnode:PVirtualNode;
  d:pnodedata;
begin
  if Source=TagsListFrame1.TagsLV then
  begin
    for I := 0 to TagsListFrame1.TagsLV.SelCount - 1 do
    begin
      if i=0 then
        li:=TagsListFrame1.TagsLV.Selected
      else
        li:=TagsListFrame1.TagsLV.GetNextItem(li,sdAll,[isSelected]);
      if li=nil then
        breAK;
      if not findnode(li,pairtv) then
      begin
        tnode:=pairtv.AddChild(nil);
        d:=pairtv.GetNodeData(tnode);
        d.ImageIndex:=c_im_TagPair;
        d.color:=pairtv.normalcolor;
        p:=TagBandPairList.newPair;
        d.data:=p;
        p.settag(itag(li.Data));
        UpdatePairNode(tnode);
      end;
    end;
    exit;
  end;
  pnode:=pairTV.DropTargetNode;
  if pnode=nil then
    exit;
  d:=pairTV.GetNodeData(pnode);
  p:=TTagBandPair(d.data);
  for I := 0 to placesTV.SelectedCount-1 do
  begin
    if (i=0) then
    begin
      placeNode:=PlacesTV.GetFirstSelected(true);;
      d:=PlacesTV.GetNodeData(placeNode);
      if tobject(d.data) is tplace then
        place:=tplace(d.data)
      else
        place:=nil;
      place:=tplace(d.data);
    end
    else
    begin
      placeNode:=placesTV.GetNextSelected(placeNode, false);
      d:=PlacesTV.GetNodeData(placeNode);
      if tobject(d.data) is tplace then
        place:=tplace(d.data)
      else
        place:=nil;
    end;
    if place<>nil then
      p.addplace(place);
  end;
  UpdatePairNode(pnode);
  pNode.States := pNode.States + [vsExpanded];
end;

procedure TBandsFrm.PairTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
begin
  accept:=false;
  if source=TagsListFrame1.TagsLV then
    Accept:=true;
  if source=PlacesTV then
    Accept:=true;
end;

procedure TBandsFrm.PairTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  node,next: PVirtualNode;
  D: PNodeData;
  I: Integer;
  p:ttagbandpair;
  b:tband;
begin
  if Key = VK_DELETE then
  begin
    Node := PairTV.GetFirstSelected(true);
    while Node <> nil do
    begin
      next := PairTV.GetNextSelected(Node, false);
      if next<>nil then
      begin
        while next.Parent=node do
        begin
          next:=PairTV.GetNextSelected(next, false);
          if next=nil then
            break;
        end;
      end;
      D := PairTV.GetNodeData(Node);
      if tobject(d.Data) is TTagBandPair then
      begin
        p:=TTagBandPair(d.Data);
        p.destroy;
        placestv.DeleteNode(node);
      end;
      Node := next;
      inc(I);
    end;
  end;end;

procedure TBandsFrm.PlacesTVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  n: PVirtualNode;
  Data: PNodeData;
begin
  n := GetSelectNode(placesTV);
  Data := placesTV.GetNodeData(n);
  if Data <> nil then
  begin
    if tobject(data.data) is tplace then
      placenameedit.text:=tplace(data.data).name;
  end;
end;

procedure TBandsFrm.PlacesTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  b:tband;
  p:tplace;
  I, j: Integer;
  li:tlistitem;
  pnode:PVirtualNode;
  pdata:pnodedata;
  bt:bandtag;
  tb:TTagBandPair;
begin
  pnode:=PlacesTV.DropTargetNode;
  if pnode=nil then
    exit;
  pdata:=PlacesTV.GetNodeData(pnode);
  p:=tplace(pdata.data);
  for I := 0 to BandsLV.SelCount-1 do
  begin
    if (i=0) then
    begin
      li:=BandsLV.Selected;
      b:=tband(li.data);
      p.addband(b);
    end
    else
    begin
      li:=BandsLV.GetNextItem(li,sdAll,[isSelected]);
      b:=tband(li.data);
      p.addband(b);
      for j := 0 to b.tagCount - 1 do
      begin
        bt:=b.getbandtag(j);
        tb:=TagBandPairList.getPair(bt.tagname);
        if tb<>nil then
        begin
          tb.addplace(p);
        end;
      end;
    end;
  end;
  UpdateNode(pnode);
  pNode.States := pNode.States + [vsExpanded];
end;

procedure TBandsFrm.PlacesTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
begin
  accept:=false;
  if source=bandslv then
    accept:=true;
end;

procedure TBandsFrm.PlacesTVKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
var
  node,next: PVirtualNode;
  D: PNodeData;
  I: Integer;
  p:tplace;
  b:tband;
begin
  if Key = VK_DELETE then
  begin
    Node := PlacesTV.GetFirstSelected(true);
    while Node <> nil do
    begin
      next := placesTV.GetNextSelected(Node, false);
      if next<>nil then
      begin
        while next.Parent=node do
        begin
          next:=placesTV.GetNextSelected(next, false);
          if next=nil then
            break;
        end;
      end;
      D := placesTV.GetNodeData(Node);
      if tobject(d.Data) is tplace then
      begin
        p:=tplace(d.Data);
        removePlaceFromPairTV(p);
        p.destroy;
        D.data:=nil;
        placestv.DeleteNode(node);
      end
      else
      begin
        if tobject(d.Data) is tband then
        begin
          p.delband(tband(d.Data));
          placestv.DeleteNode(node);
        end;
      end;
      Node := next;
      inc(I);
    end;
  end;
end;

procedure TBandsFrm.PropSGDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  r,c:integer;
  t:itag;
  li:tlistitem;
  str:string;
begin
  propsg.MouseToCell(x,y,c, r);
  str:='';
  if Source is  tlistview then
  begin
    if r>0 then
    begin
      li:=tbtnlistview(Source).selected; //tbtnlistview(source).GetItemAt(x,y);
      t:=itag(li.data);
      str:=t.GetName;
      propsg.Cells[c,r]:=str;
      if propsg.Cells[c_col_k,r]='' then
      begin
        propsg.Cells[c_col_k,r]:='1';
      end;
      if r=propsg.RowCount-1 then
      begin
        propsg.RowCount:=propsg.RowCount+1;
      end;
    end;
    SGChange(propsg);
  end;
end;

procedure TBandsFrm.PropSGDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept:=false;
  if source=TagsListFrame1.tagslv then
  begin
    Accept:=true;
  end;
end;

procedure TBandsFrm.PropSGEditCell(r, c: integer; v: string);
begin
  case c of
    c_col_tag:;
    c_col_k:
    begin

    end;
  end;
end;

procedure TBandsFrm.PropSGKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  sg: TStringGridExt;
begin
  sg := TStringGridExt(Sender);
  if key=VK_RETURN then
  begin
    PropSGEditCell(m_row, m_col, m_val);
  end;
  if Key = VK_DELETE then
  begin
    if sg.rowcount = 1 then
      sg.rowcount := 2;
  end;
end;

procedure TBandsFrm.PropSGSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  m_val:=value;
  m_col:=acol;
  m_row:=arow;
  PropSGEditCell(m_row, m_col, m_val);
end;

procedure TBandsFrm.removePlaceFromPairTV(pl: tplace);
var
  I: Integer;
  n:pvirtualnode;
  d:PNodeData;
  t:TTagBandPair;
begin
  n := pairtv.GetFirst;
  while n<>nil do
  begin
    d:=pairtv.GetNodeData(n);
    if tobject(d.data) is TTagBandPair then
    begin
      t:=TTagBandPair(d.data);
      if t.removeplace(pl) then
      begin
        UpdatePairNode(n);
      end;
    end;
    n := pairtv.GetNext(n)
  end;
end;

procedure TBandsFrm.ShowBands(bl: tstringlist);
var
  I: Integer;
  li:tlistitem;
  b:tBand;
begin
  if bl=nil then exit;
  bandslv.clear;
  for I := 0 to bl.Count - 1 do
  begin
    li:=bandslv.Items.add;
    b:=tband(bl.Objects[i]);
    li.data:=b;
    b:=tband(bl.Objects[i]);
    bandslv.SetSubItemByColumnName('№', inttostr(i), li);
    bandslv.SetSubItemByColumnName('Название', b.name, li);
  end;
  LVChange(bandslv);
end;



procedure TBandsFrm.ShowPairList(pl: TTagBandPairList);
var
  I, j: Integer;
  p:TTagBandPair;
  b:tband;
  pNode, bNode:pvirtualnode;
  d:pnodedata;
begin
  if pl=nil then exit;
  PairTV.Clear;
  for I := 0 to pl.Count - 1 do
  begin
    p:=pl.getPair(i);
    pnode:=PairTV.AddChild(nil);
    d:=PairTV.GetNodeData(pnode);
    d.ImageIndex:=c_im_TagPair;
    d.data:=p;
    d.color:=PairTV.normalcolor;
    UpdatePairNode(pnode);
  end;
end;

procedure TBandsFrm.UpdateBandBtnClick(Sender: TObject);
var
  li:tlistitem;
  b:TBand;
  bt:BandTag;
  I, j, ind: Integer;
  f1, f2, lname:string;
  brate, rateerror:boolean;
begin

  f1:=F1fe.Text;
  f2:=F2fe.Text;
  lname:=NameEdit.Text;
  brate:=GetMultiSelectComponentBool(abscb, rateerror);
  for I := 0 to bandslv.SelCount - 1 do
  begin
    if i=0 then
      li:=bandslv.Selected
    else
      li:=bandslv.GetNextItem(li, sdBelow, [isSelected]);
    if li<>nil then
    begin
      b:=tband(li.data);
      // меняем имя
      if lname<>'' then
      begin
        ind:=-1;
        for j := 0 to BandsList.Count - 1 do
        begin
          if b=BandsList.Objects[j] then
          begin
            BandsList.Delete(j);
            ind:=j;
            break;
          end;
        end;
        if ind=-1 then exit;
        b.name:=genname;
        BandsList.AddObject(b.name,b);
        BandsLV.SetSubItemByColumnName('Название', b.name, li);
      end;
      if f1<>'' then
        b.m_f1f2.x:=strtofloatext(f1);
      if f2<>'' then
        b.m_f1f2.y:=strtofloatext(f2);
      if bandslv.SelCount=1 then
      begin
        b.clearTags;
        for j:= 1 to PropSG.RowCount - 2 do
        begin
          bt    :=BandTag.Create;
          bt.tagname:=gettagname(j);
          bt.k  :=getK(j);
          b.addBandTag(bt);
        end;
      end;
      if not rateerror then
      begin
        if not brate then
          b.valtype:=c_abs
        else
          b.valtype:=c_rate;
      end;
    end;
  end;
end;


end.
