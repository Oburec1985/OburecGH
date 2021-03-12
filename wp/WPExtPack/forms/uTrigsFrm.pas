unit uTrigsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, uBtnListView, StdCtrls, DCL_MYOWN, Buttons, uWPproc,
  VirtualTrees, uVTServices, ImgList, ActiveX, uCommonMath, uBaseObj, uWpEvents,
  jpeg;

type
  TTrigsFrm = class(TForm)
    TriListGB: TGroupBox;
    AddTrigGB: TGroupBox;
    ExtremumTrigGB: TGroupBox;
    CommonName: TPanel;
    TrigShiftLabel: TLabel;
    TrigNumberLabel: TLabel;
    TrigShiftE: TFloatEdit;
    TrigNumberIE: TIntEdit;
    TrigLabel: TLabel;
    ChanNameCB: TComboBox;
    TrigLvlTypeRG: TRadioGroup;
    UnitsLabel: TLabel;
    SrcIDLabel: TLabel;
    SrcID: TIntEdit;
    LvlLabel: TLabel;
    LvlEdit: TFloatEdit;
    Panel1: TPanel;
    ExtremumTypeRG: TRadioGroup;
    SearchIntervalTypeRG: TRadioGroup;
    SearchIntervalTab: TPageControl;
    TabSheet1: TTabSheet;
    Label4: TLabel;
    AxTypeRG: TComboBox;
    TrigTypeRG: TRadioGroup;
    Panel2: TPanel;
    AddBtn: TSpeedButton;
    DelBtn: TSpeedButton;
    lvlGB: TGroupBox;
    Label8: TLabel;
    TrigResEdit: TFloatEdit;
    UnitsCB: TComboBox;
    Label1: TLabel;
    VTree1: TVTree;
    ImageList_16: TImageList;
    NameEdit: TEdit;
    X2CB: TComboBox;
    Label7: TLabel;
    Label6: TLabel;
    X1CB: TComboBox;
    ApplySBtn: TSpeedButton;
    EvalBtn: TSpeedButton;
    ProgressBar1: TProgressBar;
    FilterGB: TGroupBox;
    Label3: TLabel;
    Label13: TLabel;
    FilterIE: TIntEdit;
    FilterFE: TFloatEdit;
    Image1: TImage;
    LPFCB: TCheckBox;
    HPFCB: TCheckBox;
    TrendCB: TCheckBox;
    H2CB: TCheckBox;
    Label2: TLabel;
    HPFOrder: TIntEdit;
    Label9: TLabel;
    HPFfe: TFloatEdit;
    Label10: TLabel;
    IntEdit1: TIntEdit;
    Label11: TLabel;
    FloatEdit1: TFloatEdit;
    NumPointsLabel: TLabel;
    NumPointsCB: TComboBox;
    ResampleCB: TCheckBox;
    ResampleIE: TIntEdit;
    FolderCB: TComboBox;
    FolderLabel: TLabel;
    procedure TrigTypeRGClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure SearchIntervalTypeRGClick(Sender: TObject);
    procedure VTree1Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure ApplySBtnClick(Sender: TObject);
    procedure FilterFEChange(Sender: TObject);
    procedure VTree1DragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure VTree1DragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure VTree1DragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure EvalBtnClick(Sender: TObject);
  private
    mng:cwpobjmng;
    selSrc:csrc;
    curtr:ctrig;
  private
    // поиск триггера
    function StatusBar(Sender: TObject; process:integer):integer;
    procedure ShowTrigOpts(tr:ctrig);
    procedure ApplyTrigOpts(tr:ctrig);
    procedure addchildTrigs(tr:ctrig; parent:PVirtualNode);
    procedure FillSignalsCB(src:csrc);
    procedure FillFolderCB;
  public
    procedure ShowTriggers;
    procedure linkMng(m:cwpobjmng);
    function ShowModal:integer;
  end;

var
  TrigsFrm: TTrigsFrm;

implementation

{$R *.dfm}

procedure TTrigsFrm.FillSignalsCB(src:csrc);
var
  I: Integer;
  s:cwpsignal;
begin
  ChanNameCB.Items.Clear;
  for I := 0 to s.ChildCount - 1 do
  begin
    s:=selSrc.getSignalObj(i);
    ChanNameCB.Items.AddObject(s.name,s);
  end;
  ChanNameCB.ItemIndex:=-1;
end;

procedure TTrigsFrm.FillFolderCB;
var
  I: Integer;
  s:csrc;
begin
  FolderCB.Items.Clear;
  for I := 0 to mng.SrcCount - 1 do
  begin
    s:=mng.GetSrc(i);
    FolderCB.Items.AddObject(s.name,s);
  end;
  FolderCB.ItemIndex:=0;
end;

procedure TTrigsFrm.FilterFEChange(Sender: TObject);
var
  s:cwpsignal;
begin
  if curtr<>nil then
  begin
    s:=curtr.GetSignal;
    if s<>nil then
    begin
      filterie.IntNum:=round(s.getFs*filterfe.FloatNum);
    end;
  end;
end;

procedure TTrigsFrm.ShowTrigOpts(tr:ctrig);
var
  s:cwpsignal;
  src:csrc;
begin
  x1cb.Enabled:=true;
  if tr.Front then
    TrigLvlTypeRG.ItemIndex:=0
  else
    TrigLvlTypeRG.ItemIndex:=1;
  case tr.trigtype of
    c_Trig_User:
    begin
      TrigTypeRG.ItemIndex:=0;
      trigresedit.FloatNum:=tr.GetTime;
    end;
    c_Trig_search:
    begin
      TrigTypeRG.ItemIndex:=1;
      case tr.extremumType of
        c_Trig_Lvl: ExtremumTypeRG.ItemIndex:=0;
        c_Trig_Dif1: ExtremumTypeRG.ItemIndex:=1;
        c_Trig_Dif2: ExtremumTypeRG.ItemIndex:=2;
      end;
      case tr.SearchIntervalType of
        c_TrigSearchInterval_No: SearchIntervalTypeRG.ItemIndex:=0;
        c_TrigSearchInterval_from:
        begin
          if tr.SearchIntervalT1<>nil then
          begin
            x1cb.ItemIndex:=x1cb.Items.IndexOf(tr.SearchIntervalT1.name);
            if x1cb.ItemIndex<0 then
              x1cb.Text:=tr.SearchIntervalT1.name;
          end
          else
          begin
            x1cb.Text:=floattostr(tr.fSearchInterval.x);
          end;
          SearchIntervalTypeRG.ItemIndex:=1;
        end;
        c_TrigSearchInterval_to: SearchIntervalTypeRG.ItemIndex:=2;
        c_TrigSearchInterval_Interval: SearchIntervalTypeRG.ItemIndex:=3;
      end;
      if tr.parent<>nil then
      begin
        x1cb.Enabled:=false;
      end;
      // границы поска триггера
      if tr.SearchIntervalT1=nil then
        x1cb.Text:=floattostr(tr.fSearchInterval.x)
      else
      begin
        x1cb.Text:=(tr.SearchIntervalT1.name);
      end;
      if tr.SearchIntervalT2=nil then
        x2cb.Text:=floattostr(tr.fSearchInterval.y)
      else
      begin
        x2cb.Text:=tr.SearchIntervalT2.name;
      end;
      src:=mng.getsrcid(tr.srcid);
      s:=src.getSignalObj(tr.TrigName);
      FilterIE.IntNum:=tr.m_fltTrendPoints;
      if s<>nil then
      begin
        FilterFE.FloatNum:=tr.m_fltTrendPoints/s.getFs;
      end
      else
        FilterFE.FloatNum:=0;
    end;

  else
    TrigTypeRG.ItemIndex:=0;
  end;

  nameedit.Text:=tr.name;
  TrigShiftE.FloatNum:=tr.shift;
  srcid.IntNum:=tr.srcid;
  LvlEdit.FloatNum:=tr.Threshold;
  TrigNumberIE.IntNum:=tr.number;
  ChanNameCB.Text:=tr.TrigName;
end;

procedure TTrigsFrm.ApplySBtnClick(Sender: TObject);
var
  n:pvirtualnode;
begin
  ApplyTrigOpts(curtr);
  curtr.name:=NameEdit.text;
  ShowTriggers;
  n:=VTree1.GetNodeByName(NameEdit.text);
  VTree1.FocusedNode:=n;
  mng.Events.CallAllEvents(E_OnUpdateTrigs);
end;

function DropStatus(obj:cBaseObj; data:pointer):boolean;
begin
  result:=True;
  ctrig(obj).success:=false;
  ctrig(obj).processed:=false;
end;

procedure TTrigsFrm.ApplyTrigOpts(tr:ctrig);
var
  s:cwpsignal;
  src:csrc;
  str:string;
begin
  case TrigLvlTypeRG.ItemIndex of
    0:tr.Front:=true;
    1:tr.Front:=false;
  end;
  tr.processed:=false;
  tr.TrigName:=ChanNameCB.Text;
  tr.shift:=TrigShiftE.FloatNum;
  tr.srcid:=srcid.IntNum;
  tr.Threshold:=LvlEdit.FloatNum;
  tr.number:=TrigNumberIE.IntNum;
  case TrigTypeRG.ItemIndex of
    0:
    begin
      tr.trigtype:=c_Trig_User;
      tr.Setx(trigresedit.FloatNum);
    end;
    1:
    begin
      tr.trigtype:=c_Trig_search;
      case ExtremumTypeRG.ItemIndex of
        0: tr.extremumType:=c_Trig_Lvl;
        1: tr.extremumType:=c_Trig_Dif1;
        2: tr.extremumType:=c_Trig_Dif2;
      end;
      case SearchIntervalTypeRG.ItemIndex of
        0: tr.SearchIntervalType:=c_TrigSearchInterval_No;
        1:
        begin
          if tr.parent<>nil then
          begin

          end
          else
            tr.SearchIntervalType:=c_TrigSearchInterval_from;
        end;
        2: tr.SearchIntervalType:=c_TrigSearchInterval_to;
        3: tr.SearchIntervalType:=c_TrigSearchInterval_Interval;
      end;
      // границы поска триггера
      if x1cb.ItemIndex>-1 then
      begin
        tr.SearchIntervalT1:=mng.getTrig(x1cb.Text);
      end
      else
      begin
        tr.SearchIntervalT1:=nil;
      end;
      if tr.SearchIntervalT1=nil then
      begin
        if not (isValue(x1cb.Text)) then
          tr.fSearchInterval.x:=0
        else
          tr.fSearchInterval.x:=strtofloat(x1cb.Text);
      end;

      if x2cb.ItemIndex>-1 then
      begin
        tr.SearchIntervalT2:=ctrig(x2cb.Items.Objects[x1cb.ItemIndex]);
      end
      else
      begin
        tr.SearchIntervalT2:=nil;
      end;

      if tr.SearchIntervalT2=nil then
      begin
        if x2cb.Text='' then
          tr.fSearchInterval.y:=0
        else
          tr.fSearchInterval.y:=strtofloat(x2cb.Text);
      end;

      src:=mng.getsrcid(tr.srcid);
      s:=src.getSignalObj(tr.TrigName);
      tr.m_fltTrendPoints:=FilterIE.IntNum;
    end;
  else
    TrigTypeRG.ItemIndex:=0;
  end;
  if tr.ChildCount>0 then
  begin
    tr.EnumGroupMembers(DropStatus, tr);
  end;
end;

function TTrigsFrm.StatusBar(Sender: TObject; process:integer):integer;
begin
  result:=1;
  // поиск триггера
  ProgressBar1.Position:=trunc(process);
end;

procedure TTrigsFrm.EvalBtnClick(Sender: TObject);
var
  n,selectnode:pvirtualnode;
  d:PNodeData;
  name:string;
  I: Integer;
begin
  selectnode:=VTree1.FocusedNode;
  name:='';
  if selectnode<>nil then
  begin
    d:=VTree1.GetNodeData(selectnode);
    name:=d.Caption;
  end;
  mng.EvalTrigs(StatusBar);
  ShowTriggers;
  if name<>'' then
  begin
    n:=vtree1.GetNodeByName(name);
    VTree1.FocusedNode:=n;
  end;
  ProgressBar1.Position:=0;
end;

procedure TTrigsFrm.AddBtnClick(Sender: TObject);
var
  tr, t:ctrig;
  Name:string;
  Threshold, shift:double;
  number:integer;
  front:boolean;
  I: Integer;
begin
  tr:=cTrig.Create();
  tr.list:=mng.TrigList;

  ApplyTrigOpts(tr);

  for I := 0 to tr.list.Count - 1 do
  begin
    t:=ctrig(tr.list.Objects[i]);
    if tr.Compare(t) then
    begin
      showmessage('Уже есть аналогичный триггер');
      tr.destroy;
      break;
    end;
    if i=(tr.list.Count - 1) then
    begin
      tr.GenID;
    end;
  end;
  if tr.list.Count=0 then
    tr.GenID;
  ShowTriggers;
  mng.Events.CallAllEvents(E_OnUpdateTrigs);
end;

procedure TTrigsFrm.linkMng(m:cwpobjmng);
begin
  mng:=m;
end;

procedure TTrigsFrm.addchildTrigs(tr:ctrig; parent:PVirtualNode);
var
  child:ctrig;
  node:PVirtualNode;
  d:pnodedata;
  I: Integer;
  f:double;
  str:string;
begin
  //VTree1.AddChild(node);
  node:=VTree1.AddChild(parent);
  //VTree1.RootNodeCount
  UpdateNode(node, VTree1);

  d:=VTree1.GetNodeData(node);
  d.data:=tr;
  d.Caption:=tr.name;
  d.color:=VTree1.normalcolor;
  // Тип
  str:=tr.GetTypeString;
  d.ColumnText.add(str);
  // порог
  if tr.trigtype=c_Trig_User then
  begin
    d.ColumnText.add('-');
  end
  else
  begin
    d.ColumnText.add(floattostr(tr.Threshold));
  end;
  // Номер срабатывания
  d.ColumnText.add(inttostr(tr.number));
  // Shift
  f:=tr.shift;
  d.ColumnText.add(floattostr(f));
  // Результат
  f:=tr.X;
  d.ColumnText.add(floattostr(f));
  for I := 0 to tr.childCount - 1 do
  begin
    child:=ctrig(tr.getChild(i));
    addchildTrigs(child,node);
  end;
  if not tr.Success then
  begin
    d.color:=clRed;
  end
  else
  begin
    d.color:=VTree1.normalcolor;
  end;
end;

procedure TTrigsFrm.ShowTriggers;
var
  I: Integer;
  li:tlistitem;
  tr, ch:ctrig;
  s:cwpsignal;

  node:PVirtualNode;
begin
  VTree1.Clear;
  TrigTypeRGClick(nil);
  for I := 0 to mng.TrigList.Count - 1 do
  begin
    tr:=ctrig(mng.TrigList.Objects[i]);
    if tr.isHeader then
      addchildTrigs(tr, nil);
  end;
  FillSignalsCB(selSrc);
  FillFolderCB;
  VTree1.Header.AutoFitColumns(false,smaAllColumns,0,VTree1.Header.Columns.Count);
end;

procedure TTrigsFrm.TrigTypeRGClick(Sender: TObject);
begin
  if TrigTypeRG.ItemIndex=0 then
  begin
    ExtremumTrigGB.Visible:=false;
    FilterGB.Visible:=false;
    LvlGB.Visible:=true;
    lvledit.Visible:=false;
    LvlLabel.Visible:=false;
    TrigNumberIE.Visible:=false;
    TrigNumberLabel.Visible:=false;
    ChanNameCB.Visible:=false;
    TrigLabel.Visible:=false;
    unitscb.Visible:=false;
    UnitsLabel.Visible:=false;
    srcIDLabel.Visible:=false;
    srcID.Visible:=false;
  end;
  if TrigTypeRG.ItemIndex=1 then
  begin
    ExtremumTrigGB.Visible:=true;
    FilterGB.Visible:=true;
    LvlGB.Visible:=false;

    lvledit.Visible:=true;
    LvlLabel.Visible:=true;
    TrigNumberIE.Visible:=true;
    TrigNumberLabel.Visible:=true;
    ChanNameCB.Visible:=true;
    TrigLabel.Visible:=true;
    unitscb.Visible:=true;
    UnitsLabel.Visible:=true;
    srcIDLabel.Visible:=true;
    srcID.Visible:=true;
  end;
end;

procedure TTrigsFrm.VTree1Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  data:pnodedata;
begin
  // получаем список выбранных осей
  if vtree1.SelectedCount>0 then
  begin
    node:=vtree1.GetFirstSelected(true);
    while node<>nil do
    begin
      data:=vtree1.GetNodeData(node);
      curtr:=ctrig(data.data);
      ShowTrigOpts(curtr);
      // УБРАТЬ!!!
      exit;
      node:=vtree1.GetNextSelected(node, true);
    end;
  end;
end;


procedure TTrigsFrm.VTree1DragAllowed(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := True; // Указываем, что данный узел можно drag'ать
end;

procedure TTrigsFrm.VTree1DragDrop(Sender: TBaseVirtualTree; Source: TObject;
  // ActiveX
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  node:pvirtualnode;
  src,dst:pnodedata;
  srctrig,dsttrig:ctrig;
begin
  //Node := Sender.GetNodeAt(Pt.x, Pt.y);
  node:=Sender.DropTargetNode;
  if Node = Sender.focusednode then Exit;
  if Sender.focusednode=nil then exit;


  dst:=VTree1.GetNodeData(Node);
  src:=VTree1.GetNodeData(Sender.focusednode);

  dsttrig:=cTrig(dst.data);
  srctrig:=cTrig(src.data);
  if (dsttrig.trigtype=c_Trig_Start) or (dsttrig.trigtype=c_Trig_Stop)  then
    exit;
  if (srctrig.trigtype=c_Trig_Start) or (srctrig.trigtype=c_Trig_Stop)  then
    exit;
  Sender.MoveTo(Sender.focusednode, Node, amAddChildLast, False); // перемещаем узел
  srctrig.parent:=dsttrig;
end;

procedure TTrigsFrm.VTree1DragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
begin
  Accept := Sender.GetNodeAt(Pt.x, Pt.y) <> Sender.focusednode; // Drop'ать узел сам на себя нельзя
end;

procedure TTrigsFrm.SearchIntervalTypeRGClick(Sender: TObject);
begin
  case SearchIntervalTypeRG.ItemIndex of
    c_TrigSearchInterval_No:;
    c_TrigSearchInterval_from:;
    c_TrigSearchInterval_To:;
    c_TrigSearchInterval_Interval:;
  end;
end;

function TTrigsFrm.ShowModal:integer;
begin
  // VirtualTree поддерживает так же и OLE Drag&Drop, поэтому явно указываем, что будем исполользовать механизм, реализованный в VCL
  VTree1.DragType:=dtVCL;
  VTree1.DragMode := dmAutomatic;

  selSrc:=mng.SelectedSrc;
  ShowTriggers;
  result:=inherited showmodal;
end;


end.
