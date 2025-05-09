unit uWPProcFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, Winpos_ole_TLB, POSBase, StdCtrls, ugenform,
  uComponentServises, uWPProc, inifiles, ExtCtrls, uWPProcServices, DCL_MYOWN, Menus,
  VirtualTrees, ImgList, uVTServices, uCorrectUTS, EditSignalPathFrm, uSelectIntervalFrm,
  ucommonmath, MathFunction, uGraphMngFrm, usetlist, ToolWin, uAddSignalFrm,
  uTrigsFrm,
  uEditTubeFrm,
  uScriptFrm,
  uIntervalfrm,
  uJournalForm;

type
  cSelectList = class(cSetList)
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;override;
  end;

  selObj = class
  public
    s:string;
    i:integer;
  end;


  TFxForm = class(TForm)
    ProcSignalsGB: TGroupBox;
    SignalsGB: TGroupBox;
    DelBtn: TButton;
    LoadScriptGB: TGroupBox;
    SaveBtn: TButton;
    SavePath: TEdit;
    LoadPath: TEdit;
    LoadBtn: TButton;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    SelectSavePathBtn: TButton;
    SelectLoadPathBtn: TButton;
    OperatorsGB: TGroupBox;
    OperatorsLV: TBtnListView;
    GroupBox1: TGroupBox;
    Splitter1: TSplitter;
    AddBtn: TButton;
    Splitter2: TSplitter;
    StatusBar1: TStatusBar;
    ProgressBar1: TProgressBar;
    MainMenu1: TMainMenu;
    ExtMenuItem: TMenuItem;
    GeneratorMenuItem: TMenuItem;
    N1: TMenuItem;
    VTree1: TVTree;
    GraphMenu: TMenuItem;
    Splitter3: TSplitter;
    GroupBox2: TGroupBox;
    OpersSrc: TBtnListView;
    GroupBox3: TGroupBox;
    SrcLV: TBtnListView;
    ToolBar1: TToolBar;
    EvalBtn: TToolButton;
    ReadGraph: TToolButton;
    GraphBtn: TToolButton;
    TrigsMenu: TMenuItem;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    N2: TMenuItem;
    N3: TMenuItem;
    PopupMenu1: TPopupMenu;
    B1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    procedure SaveBtnClick(Sender: TObject);
    procedure SelectSavePathBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure LoadPathChange(Sender: TObject);
    procedure SavePathChange(Sender: TObject);
    procedure SelectLoadPathBtnClick(Sender: TObject);
    procedure SRCLVClick(Sender: TObject);
    procedure OperSrcLVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure EvalBtnClick(Sender: TObject);
    procedure GraphBtnClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure UpdateProgress(Sender: TObject);
    procedure OperatorsLVDblClickProcess(item: TListItem; lv: TListView);
    procedure GeneratorMenuItemClick(Sender: TObject);
    procedure DelBtnClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure VTree1NodeDblClick(Sender: TBaseVirtualTree;
      const HitInfo: THitInfo);
    procedure OperatorsLVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SrcLVDblClickProcess(item: TListItem; lv: TListView);
    procedure GraphMenuClick(Sender: TObject);
    procedure ReadGraphClick(Sender: TObject);
    procedure VTree1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure VTree1Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TrigsMenuClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  public
    wp:cWPObjMng;
  private
    ifile:tinifile;
    OperTVSelects:cSelectList;
  private
    procedure InfoCallback(sender:tobject; dsc:string);
    procedure ShowFiles;
    procedure AddSrcToLV(sender:tobject);
    procedure AddSrcToOpersLV(sender:tobject);
    procedure ShowOpersSrc;
    // ���������� ���������� ���������
    procedure ShowOperators;
    procedure Save;
    procedure Load;
    procedure CheckLoadPath;
    procedure CheckSavePath;
    procedure InitTV;
    procedure AddOperToTV(o:coperobj);
    procedure createevent;
    procedure destroyevent;
    procedure compareSrc;
    function StatusBar(Sender: TObject; process:integer):integer;
  public
    FUNCTION ShowModal(mng:cWPObjMng):integer;
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
  end;

var
  FxForm: TFxForm;

const
  c_SRCindex = 18;
  c_SignalIndex = 22;

implementation
uses
  uWPExtPack;

{$R *.dfm}

constructor TFxForm.Create(AOwner: TComponent);
begin
  inherited;
  EditTubeFrm:=TEditTubeFrm.Create(nil);
  ifile:=TIniFile.Create(startdir+'WPProc.Ini');
  OperTVSelects:=cSelectList.create;
  load;
  wp:=nil;
end;

destructor TFxForm.destroy;
begin
  ifile.Destroy;
  OperTVSelects.destroy;
  destroyevent;
  inherited;
end;

procedure TFxForm.createevent;
begin
  wp.Events.AddEvent('FxFrm_AddSrc', e_OnAddSRC, AddSrcToLV);
end;

procedure TFxForm.destroyevent;
begin
  wp.Events.removeEvent(AddSrcToLV,e_OnAddSRC);

end;

procedure TFxForm.DelBtnClick(Sender: TObject);
var
  li:tlistitem;
  o:coperobj;
begin
  li:=OperatorsLV.Selected;
  if li=nil then exit;
  o:=coperObj(li.Data);
  o.destroy;
  li.Destroy;
end;


procedure TFxForm.EvalBtnClick(Sender: TObject);
begin
  wp.Execute;
  showfiles;
  BringToFront;
end;

procedure TFxForm.UpdateProgress(Sender: TObject);
begin
  ProgressBar1.Position:=wp.Progress;
  StatusBar1.Panels[1].Text:=wp.ProgressStr;
end;

procedure GetOperObjOpts(o:coperobj; l:cselectlist);
var
  s:cSignalsOpt;
  I: Integer;
begin
  for I := 0 to o.SrcCount - 1 do
  begin
    s:=o.GetSignalsOpts(i);
    l.AddObj(s);
  end;
end;

procedure TFxForm.VTree1Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  I: Integer;
  data:pnodedata;
  obj:tobject;
  g:cwpGraph;
begin
  i:=0;
  OperTVSelects.Clear;
  // �������� ������ ��������� ����
  if VTree1.SelectedCount>0 then
  begin
    node:=VTree1.GetFirstSelected(true);
    while node<>nil do
    begin
      data:=VTree1.GetNodeData(node);
      obj:=data.data;
      if obj is cOperObj then
      begin
        GetOperObjOpts(coperobj(obj),OperTVSelects);
      end;
      if obj is cSignalsOpt then
      begin
        OperTVSelects.AddObj(obj);
      end;
      node:=VTree1.GetNextSelected(node, true);
      inc(i);
    end;
  end;
end;

procedure TFxForm.VTree1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i:integer;
  opts:cSignalsOpt;
  b:boolean;
  o:coperobj;
begin
  if key=VK_DELETE then
  begin
    b:=false;
    if OperTVSelects.Count>0 then
      b:=true;
    for i:=0 to OperTVSelects.Count-1 do
    begin
      opts:=cSignalsOpt(OperTVSelects.Items[i]);
      opts.destroy;
    end;
    if b then
    begin
      o:=coperobj(operatorslv.Selected.data);
      vtree1.Clear;
      AddOperToTV(o);
    end;
    OperTVSelects.clear;
  end;
end;



procedure TFxForm.VTree1NodeDblClick(Sender: TBaseVirtualTree;
  const HitInfo: THitInfo);
var
  d:PNodeData;
begin
  // ���� ������ ���� (��������)
  d:=sender.GetNodeData(hitinfo.HitNode);
  if d.data<>nil then
  begin
    if tobject(d.data) is cSignalsOpt then
    begin
      EditSignalsListFrm.edit(coperobj(operatorsLV.Selected.data),coperobj(operatorsLV.Selected.data).GetSrc);
      vtree1.Clear;
      // ���������� � ������
      AddOperToTV(coperobj(operatorsLV.Selected.data));
    end
    else
    begin
      SignalPathFrm.EditSignal(coperobj(d.Data));
      if d.ColumnText.Count>0 then
      begin
        d.ColumnText[0]:='�������� = '+coperobj(d.Data).srcdir+'; ��������� = '+coperobj(d.Data).DstDir;
      end;
      coperobj(d.Data).PrepareSignalsID;
      if coperobj(d.Data).fstatus=c_AlgStatusOk then
      begin
        d.color:=VTree1.normalcolor;
      end;
    end;
  end;
end;

procedure TFxForm.FormResize(Sender: TObject);
begin
  StatusBar1.Panels[1].Width:=StatusBar1.Width-StatusBar1.Panels[0].Width-StatusBar1.Panels[2].Width;
  inherited;
end;

procedure TFxForm.GeneratorMenuItemClick(Sender: TObject);
begin
  GenFrm.ShowModal;
end;

procedure TFxForm.GraphBtnClick(Sender: TObject);
begin
  wp.EvalTrigs(StatusBar);
  wp.CreateGraphs;
  ProgressBar1.Position:=0;
  StatusBar1.Panels[1].Text:='';
  ModalResult:=mrok;
end;

procedure TFxForm.GraphMenuClick(Sender: TObject);
begin
  if GraphFrm.ShowModal=mrok then
  begin

  end;
end;

procedure TFxForm.save;
begin
  ifile.WriteString('Main','LastPath', SavePath.text);
  ifile.WriteString('Main','LoadPath', LoadPath.text);
end;

procedure TFxForm.load;
begin
  savepath.Text:=ifile.ReadString('Main','LastPath','');
  Loadpath.Text:=ifile.ReadString('Main','LoadPath','');

  SaveDialog1.FileName:=savepath.Text;
  OpenDialog1.FileName:=Loadpath.Text;
end;

procedure TFxForm.LoadBtnClick(Sender: TObject);
var
  I, j: Integer;
  src:csrc;
  li:tlistitem;
  s:string;
begin
  if fileexists(loadpath.Text) then
  begin
    wp.load(loadpath.Text);
    ifile.WriteString('Main','LoadPath', LoadPath.text);
  end;
  // ���������� ���������
  ShowOperators;
  for I := 0 to wp.SrcCount - 1 do
  begin
    src:=wp.GetSrc(i);
    StatusBar1.Panels[1].Text:='����� ������ ���������';
    Application.ProcessMessages;
    src.EvalStartStop(StatusBar);
    for j := 0 to srclv.items.Count - 1 do
    begin
      li:=SrcLV.Items[j];
      if li.data=src then
      begin
        s:='t1='+formatstr(wp.SelectedSrc.t1,4)+'; t2='+formatstr(wp.SelectedSrc.t2,4);
        srclv.SetSubItemByColumnName('�������',s, li);
        case wp.SelectedSrc.IntervalOpts of
          c_IntervalAllTest:s:='��� ���������';
          c_IntervalTime:s:='����� ������ �������';
          c_IntervalTrigs:s:='����� ������ �� ���������� ��������';
          c_IntervalCursor:s:='����� ������ �� ������� �������� ���� ������';
        end;
        srclv.SetSubItemByColumnName('��������� ������',s, li);
      end;
    end;
  end;
  StatusBar1.Panels[1].Text:='';
  ProgressBar1.Position:=0;
end;

procedure TFxForm.LoadPathChange(Sender: TObject);
begin
  CheckLoadPath;
end;


procedure TFxForm.N1Click(Sender: TObject);
begin
  // ��������� �������
  CorrectUTSFrm.ShowModal;
  modalresult:=mrOk;
end;

procedure TFxForm.N2Click(Sender: TObject);
begin
  ScriptFrm.ShowModal;
end;

procedure TFxForm.N3Click(Sender: TObject);
begin
  JournalForm.ShowModal;
end;

procedure TFxForm.N5Click(Sender: TObject);
begin
  EditTubeFrm.ShowModal;
end;

procedure TFxForm.SaveBtnClick(Sender: TObject);
begin
  save;
  wp.Save(savepath.Text);
end;

procedure TFxForm.SavePathChange(Sender: TObject);
begin
  CheckSavePath;
end;

procedure TFxForm.SelectLoadPathBtnClick(Sender: TObject);
begin
  if opendialog1.execute then
  begin
    LoadPath.Text:=opendialog1.FileName;
  end;
end;

procedure TFxForm.SelectSavePathBtnClick(Sender: TObject);
begin
  SaveDialog1.FileName:=savepath.Text;
  if SaveDialog1.Execute(0) then
  begin
    savepath.Text:=SaveDialog1.FileName;
  end;
end;

procedure TFxForm.ShowOperators;
var
  I: Integer;
  o:cOperObj;
  li:tlistitem;
begin
  OperatorsLV.Clear;
  for I := 0 to wp.opers.Count - 1 do
  begin
    o:=wp.GetOper(i);
    li:=OperatorsLV.Items.Add;
    li.data:=o;
    OperatorsLV.SetSubItemByColumnName('�',inttostr(i+1),li);
    OperatorsLV.SetSubItemByColumnName('��������',o.operstr,li);
    OperatorsLV.SetSubItemByColumnName('���������',o.params,li);
  end;
  LVChange(OperatorsLV);
  ShowOpersSrc;
end;

procedure TFxForm.OperatorsLVDblClickProcess(item: TListItem; lv: TListView);
var
  o:coperobj;
begin
  o:=coperobj(item.data);
  wp.EditOperator(o);
end;

procedure TFxForm.OperatorsLVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i:integer;
  li:tlistitem;
begin
  if key=VK_DELETE then
  begin
    for I := 0 to OperatorsLV.SelCount - 1 do
    begin
      li:=OperatorsLV.Items[OperatorsLV.Selected.Index+i];
      coperObj(li.Data).destroy;
    end;
    // �������� ������� ������
    for I := 0 to OperatorsLV.SelCount - 1 do
    begin
      li:=OperatorsLV.Items[OperatorsLV.Selected.Index];
      li.Delete;
    end;
  end;
end;

procedure TFxForm.InitTV;
//var
  //I: Integer;
  //n1, n2: PVirtualNode;
  //data:PNodeData;
begin
  //col.CaptionText:='��������';
  {vtree1.RootNodeCount:=1;
  n1:=VTree1.GetFirst;
  //while VTree1.RootNodeCount=1 do
  begin
    data:=VTree1.GetNodeData(n1);
    data.Caption:='123';
    n2:=VTree1.AddChild(n1);
    if n2<>nil then
    begin
      data:=VTree1.GetNodeData(n2);
      data.Caption:='~~~~~~';
    end;
    n1:=VTree1.GetNext(n1);
  end;}
end;


procedure TFxForm.OperSrcLVSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  o:coperobj;
  opts:cSignalsOpt;
  opt:cSignalDesc;
  I, j:Integer;
  li:tlistitem;
  str:string;
begin
  // ���� �� ������ �������� �� ����� �������� ����� ��� �������� ������
  if OperatorsLV.SelCount=1 then
  begin
    if (item<>nil) and (item.Data<>nil) then
    begin
      o:=coperobj(item.data);
      vtree1.Clear;
      // ���������� � ������
      ////showOper(o);
      AddOperToTV(o);
    end;
  end;
end;

procedure TFxForm.ReadGraphClick(Sender: TObject);
begin
  wp.readgraphs;
end;

procedure TFxForm.AddOperToTV(o:coperobj);
var
  parent,n:PVirtualNode;
  d:PNodeData;
  i, j: Integer;
  sOpts:cSignalsOpt;
  sOpt:cSignalDesc;
  str:string;
begin
  parent:=VTree1.AddChild(nil);
  updateNode(parent,VTree1);
  d:=VTree1.GetNodeData(parent);
  d.Caption:=o.operstr;
  d.color:=vtree1.normalcolor;
  d.data:=o;
  d.ImageIndex:=c_SRCindex;
  o.PrepareSignalsID;
  if o.fstatus<>c_AlgStatusOk then
  begin
    if o.fstatus=c_AlgStatusSrc then
    begin
      d.color:=clRed;
    end;
  end
  else
    d.color:=VTree1.normalcolor;
  str:='�������� = '+o.srcdir+'; ��������� = '+o.DstDir;
  d.ColumnText.Add(str);
  for I := 0 to o.SrcCount - 1 do
  begin
    sOpts:=o.GetSignalsOpts(i);
    for j := 0 to sOpts.pathSrcList.Count - 1 do
    begin
      n:=VTree1.AddChild(parent);
      updateNode(n,VTree1);
      d:=VTree1.GetNodeData(n);
      // �������� � ����������
      d.Caption:=trimname(sOpts.GetSrcName(j));
      d.data:=sopts;
      d.ImageIndex:=c_SignalIndex;
      str:=trimname(sOpts.GetDst(j));
      d.ColumnText.Add(str);
    end;
  end;
end;

procedure TFxForm.AddSrcToLV(sender:tobject);
var
  s:csrc;
  li:tlistitem;
begin
  li:=srclv.items.Add;
  s:=csrc(sender);
  srclv.SetSubItemByColumnName('�',inttostr(li.index),li);
  srclv.SetSubItemByColumnName('����',s.name,li);
  srclv.SetSubItemByColumnName('ID',inttostr(s.id),li);
end;

procedure TFxForm.AddSrcToOpersLV(sender:tobject);
var
  li:tlistitem;
  select:selobj;
begin
  select:=selobj(sender);
  li:=OpersSrc.items.Add;
  OpersSrc.SetSubItemByColumnName('�',inttostr(li.index),li);
  OpersSrc.SetSubItemByColumnName('����',select.s,li);
  OpersSrc.SetSubItemByColumnName('ID',inttostr(select.i),li);
end;

procedure TFxForm.ShowOpersSrc;
var
  I, ind: Integer;
  o:coperobj;
  srcID:selObj;
  str:string;
  src:csrc;
  list:tstringList;
begin
  OpersSrc.Clear;
  list:=TStringList.Create;
  list.Sorted:=true;
  for I := 0 to wp.opers.Count - 1 do
  begin
    o:=wp.GetOper(i);
    if not list.Find(o.SrcDir, ind) then
    begin
      srcID:=selObj.Create;
      srcID.s:=o.SrcDir;
      srcID.i:=o.srcId;
      list.AddObject(srcid.s,srcid);
    end;
    if not list.Find(o.DstDir, ind) then
    begin
      srcID:=selObj.Create;
      srcID.s:=o.DstDir;
      srcID.i:=o.DstId;
      list.AddObject(srcid.s,srcid);
    end;
  end;
  for I := 0 to List.Count - 1 do
  begin
    AddSrcToOpersLV(list.Objects[i]);
    selobj(list.Objects[i]).Destroy;
  end;
  LVChange(OpersSrc);
  list.Destroy;
end;

procedure TFxForm.compareSrc;
begin

end;

procedure TFxForm.ShowFiles;
var
  Node, childNode:IWPNode;
  i,j:integer;
  li:tlistitem;
  s:csrc;
  STR:STRING;
begin
  srclv.clear;
  // ������ �� ����� ������
  for i := 0 to wp.srcCount - 1 do
  begin
    li:=srclv.items.Add;
    s:=wp.GetSrc(i);
    li.data:=s;
    srclv.SetSubItemByColumnName('�',inttostr(i+1),li);
    srclv.SetSubItemByColumnName('����',s.name,li);
    srclv.SetSubItemByColumnName('ID',inttostr(s.id),li);
    str:='t1='+formatstr(wp.SelectedSrc.t1,4)+'; t2='+formatstr(wp.SelectedSrc.t2,4);
    srclv.SetSubItemByColumnName('�������',str,li);
    case wp.SelectedSrc.IntervalOpts of
      c_IntervalAllTest:str:='��� ���������';
      c_IntervalTime:str:='����� ������ �������';
      c_IntervalTrigs:str:='����� ������ �� ���������� ��������';
      c_IntervalCursor:str:='����� ������ �� ������� �������� ���� ������';
    end;
    srclv.SetSubItemByColumnName('��������� ������',str,li);
  end;
  if wp.srcCount >0 then
    LVChange(srclv);
end;


function TFxForm.StatusBar(Sender: TObject; process:integer):integer;
begin
  result:=1;
  ProgressBar1.Position:=trunc(process);
end;

procedure TFxForm.TrigsMenuClick(Sender: TObject);
begin
  TrigsFrm.ShowModal;
end;

procedure  TFxForm.InfoCallback(Sender: TObject; dsc:string);
begin
  StatusBar1.Panels[1].text:=dsc;
  Application.ProcessMessages;
end;

FUNCTION TFxForm.ShowModal(mng:cWPObjMng):integer;
begin
  if wp=nil then
  begin
    wp:=mng;
    wp.InfoCallBack:=InfoCallback;
    createevent;
  end;
  wp.OnUpdateStatus:=updateProgress;
  wp.OnUpdateStatus:=updateProgress;
  //mng.readsrc;
  showfiles;
  ShowOperators;
  InitTV;
  wp.readgraphs;
  result:=inherited showmodal;
end;

procedure TFxForm.SRCLVClick(Sender: TObject);
var
  li:tlistitem;
  P:TPoint;
  y:integer;
  str:string;
begin
  if SrcLV.items.Count>0 then
  begin
    GetCursorPos(P);
    //P1:=SrcLV.ScreenToClient(P);
    windows.ScreenToClient(SrcLV.Handle,P);
    y:=p.y;
    li:=SrcLV.GetItemAt(SrcLV.TopItem.Position.X,Y);
    if li<>nil then
    begin
      SrcLV.GetSubItemByColumnName('����',li,str);
      wp.SelectedSrc:=wp.GetSrc(str);
    end;
  end;
end;

procedure TFxForm.SrcLVDblClickProcess(item: TListItem; lv: TListView);
var
  s:string;
begin
  if wp.SelectedSrc<>nil then
  begin
    if SelectIntervalFrm.showmodal(wp.SelectedSrc)=mrok then
    begin
      s:='t1='+formatstr(wp.SelectedSrc.t1,4)+'; t2='+formatstr(wp.SelectedSrc.t2,4);
      srclv.SetSubItemByColumnName('�������',s, item);
      case wp.SelectedSrc.IntervalOpts of
        c_IntervalAllTest:s:='��� ���������';
        c_IntervalTime:s:='����� ������ �������';
        c_IntervalTrigs:s:='����� ������ �� ���������� ��������';
        c_IntervalCursor:s:='����� ������ �� ������� �������� ���� ������';
      end;
      srclv.SetSubItemByColumnName('��������� ������',s,item);
      srclv.SetSubItemByColumnName('ID',inttostr(wp.SelectedSrc.id),item);
      LVChange(srclv);
    end;
  end;
end;

procedure TFxForm.CheckLoadPath;
begin
  if fileexists(LoadPath.Text) then
  begin
    LoadPath.Color:=clwindow;
  end
  else
  begin
    LoadPath.Color:=$008080FF;
  end;
end;

procedure TFxForm.CheckSavePath;
begin
  if fileexists(SavePath.Text) then
  begin
    SavePath.Color:=clwindow;
  end
  else
  begin
    SavePath.Color:=$008080FF;
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
