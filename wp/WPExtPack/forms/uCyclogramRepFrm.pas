unit uCyclogramRepFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, uBtnListView, StdCtrls, ImgList, ToolWin,
  uWPproc, uCommonMath, NativeXML, uComponentServises, uExcel, ulogfile,
  uSetList, inifiles, PathUtils, uTrigLvlEditFrm, uTmpltNameFrame;

type
  sTrig = record
    firstval:boolean;
    trigValue: boolean;
    Time: double;
    connectedTo:integer;
  end;

  pTrig = ^sTrig;

  cTrigSetList = class(cSetList)
  public
    constructor create; override;
    function add(v: sTrig): integer;
    procedure SetTrigProp_connectedto(ind, ct:integer );
    function getTrig(i: integer): sTrig;
  protected
    procedure deletechild(node: pointer); override;
  end;

  cpair = class
  public
    first: cwpsignal;
    second: cwpsignal;
    // ������� �� ������� �������
    Lvl1: double;
    // ������� �� ��������� �������
    Lvl2: double;
    // ������� �� ������� �������
    lo_Lvl1: double;
    // ������� �� ��������� �������
    lo_Lvl2: double;
    id: integer;
  public
    constructor create;
    destructor destroy;
  end;

  cSDataList = class
    data: cTrigSetList;
    refData: cTrigSetList;
    s: cpair;
  public
    constructor create;
    destructor destroy;
  end;

  // �������� ������
  cSetRecord = class
  public
    s: cwpsignal;
    ref: cwpsignal;
    t: sTrig;
    reft: sTrig;
    // ������� ���� (������������� ������ �������� �����)
    refData:boolean;
  end;

  // ����� �������� ������ ��� ������� �������� ������� ������ ������������� �������� ��� ����
  cRecords = class(cSetList)
    constructor create; override;
    function add(v: cSetRecord): integer;
    function getRecord(i: integer): cSetRecord;
  protected
    procedure deletechild(node: pointer); override;
  end;

  TCyclogramRepFrm = class(TForm)
    GroupBox1: TGroupBox;
    ChansLV: TBtnListView;
    Splitter1: TSplitter;
    GroupBox3: TGroupBox;
    CommonLV: TBtnListView;
    ToolBar1: TToolBar;
    DelBtn: TToolButton;
    AddBtn: TToolButton;
    ImageList_16: TImageList;
    CommonGB: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    LinkBtn: TToolButton;
    UnLinkBtn: TToolButton;
    LoadBtn: TButton;
    LoadPathEdit: TEdit;
    Label3: TLabel;
    SaveCfgBtn: TButton;
    LoadCfgBtn: TButton;
    ChanTypeRG: TRadioGroup;
    FilterEdit: TEdit;
    Label4: TLabel;
    StartChanCB: TComboBox;
    UnitsCB: TComboBox;
    Label5: TLabel;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    Panel1: TPanel;
    CancelBtn: TButton;
    OkBtn: TButton;
    TmpltNameFrame1: TTmpltNameFrame;
    ShowReportCB: TCheckBox;
    NullCB: TCheckBox;
    FrontCB: TCheckBox;
    FallCB: TCheckBox;
    OpenDialog1vista: TFileOpenDialog;
    MacrosCB: TCheckBox;
    MacrosEdit: TEdit;
    procedure ChanTypeRGClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure DelBtnClick(Sender: TObject);
    procedure LinkBtnClick(Sender: TObject);
    procedure UnLinkBtnClick(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure SaveCfgBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LoadCfgBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChansLVDragDrop(Sender, Source: TObject; X, Y: integer);
    procedure ChansLVDragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure ChansLVDblClickProcess(item: TListItem; lv: TListView);
    procedure TmpltNameFrame1NameRGClick(Sender: TObject);
    procedure TmpltNameFrame1FolderRGClick(Sender: TObject);
    procedure TmpltNameFrame1MakeDefaultNameBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
  private
    wp: cWPObjMng;
    src: csrc;
    outData: cRecords;
    // ������������ ������� ������
    signals: tstringlist;
  protected
    procedure clearLV;
    // ���� �������� ����� �� ������� �������� ���� ���������� ������� ChansLV
    // �� ���� ����������� �������
    procedure RelincPairs;
  public
    function evaltriglist(hi, lo:double; first, b_hi, b_lo:boolean; s:cwpsignal):cTrigSetList;
    procedure SaveParams;
    procedure LoadParams;
    procedure ClearSignalsData;
    procedure SaveCfg(path: string);
    procedure BuildReport(fname: string);
    procedure LoadCfg(path: string);
    procedure LinkMng(mng: cWPObjMng);
    function CheckLV(s: cwpsignal; lv: TBtnListView): boolean;
    procedure ShowCommonChannels(filter: boolean; ChannelsType: integer;
      filter_str: String);
    procedure UpdateStartChanCB;
    procedure AddPair(p: cpair);
    function EvalDataTable(p: cpair): cSDataList;
    procedure Process;
    // �������� ��� ������� �� ���� ������� � ���� ����� �������
    procedure PostProcess;
  end;

const

  c_AllChan = 0;
  c_OutChan = 1;
  c_InChan = 2;
  �_MainPage = '������ ������';

  c_Col_Name = 1;
  c_Col_Value = 2;
  c_Col_Time = 3;
  c_Col_Ref = 4;
  c_Col_RefTime = 5;
  c_Col_dT = 6;

var
  CyclogramRepFrm: TCyclogramRepFrm;

implementation

{$R *.dfm}

uses
  uWPExtPack, uwpservices;

function getRightTime(times:cTrigSetList; t1:strig; var index:integer):strig;
var
  ind:integer;
  val:sTrig;
begin
  index:=-1;
  times.GetHight(@t1,ind);
  if ind=-1 then
  begin
    exit;
  end;
  val:=times.getTrig(ind);
  if t1.trigValue=val.trigValue then
  begin
    if t1.time>val.time then
    begin
      index:=-1;
      exit;
    end;
    result:=val;
    index:=ind;
  end
  else
  begin
    while (t1.trigValue<>val.trigValue) and (ind<times.Count) do
    begin
      inc(ind);
      val:=times.getTrig(ind);
    end;
    if (val.Time>t1.Time) and (t1.trigValue=val.trigValue) then
    begin
      result:=val;
      index:=ind;
    end;
  end;
end;

function getLeftTime(times:cTrigSetList; t2:strig; var index:integer):strig;
var
  ind:integer;
  val:sTrig;
begin
  index:=-1;
  ind:=-1;
  times.GetLow(@t2,ind);
  if ind=-1 then
    exit;
  val:=times.getTrig(ind);
  if t2.trigValue=val.trigValue then
  begin
    result:=val;
    index:=ind;
  end
  else
  begin
    while (t2.trigValue<>val.trigValue) and (ind>=0) do
    begin
      dec(ind);
      val:=times.getTrig(ind);
    end;
    if (val.Time<t2.Time) and (t2.trigValue=val.trigValue) then
    begin
      result:=val;
      index:=ind;
    end;
  end;
end;

procedure TCyclogramRepFrm.LoadCfgBtnClick(Sender: TObject);
begin
  LoadCfg(LoadPathEdit.Text);
end;

procedure TCyclogramRepFrm.OkBtnClick(Sender: TObject);
begin
  BuildReport(TmpltNameFrame1.SavePathEdit.Text);
end;

procedure TCyclogramRepFrm.BuildReport(fname: string);
var
  tmplname, dir: string;
  wb1,WorkBook, sheet2, rngObj, sheet: olevariant;

  row: integer;
  i, index: integer;
  r: cSetRecord;
  b: boolean;
  StartTrig, trig:strig;
  startT, startHi,startLo: double;
  start: cTrigSetList;
  tmplt,
  // ���� ������� ��������� ��������� ������� ������� � �������� � �� ������� (��������� � �����),
  // �� ���� ������� ������� �� ����������
  delstart: boolean;
  k: integer;
  startSig:cwpSignal;
  str:string;
begin
  dir := extractfiledir(fname);
  if not DirectoryExists(dir) then
  begin
    if dir = '' then
      b := false
    else
      b := ForceDirectories(dir);
    if not b then
    begin
      showmessage('�� ���������� ���� � ����������');
      exit;
    end;
  end;
  Process;
  PostProcess;
  delstart:=false;
  if signals.find(StartChanCB.Text, i) then
  begin
    start := cSDataList(signals.Objects[i]).data;
  end
  else
  begin
    startSig:=src.getSignalObj(StartChanCB.Text);
    if startSig<>nil then
    begin
      delstart:=true;
      startHi:=0.7*(startSig.Signal.maxY-startSig.Signal.minY)+startSig.Signal.minY;
      startlo:=0.3*(startSig.Signal.maxY-startSig.Signal.minY)+startSig.Signal.minY;
      start:=evaltriglist(startHi, startLo, true, true, false, startSig);
    end;
  end;

  if not CheckExcelInstall then
  begin
    showmessage('���������� ��������� Excel');
    exit;
  end;
  CreateExcel;
  VisibleExcel(false);
  tmplt := false;
  tmplname := TmpltNameFrame1.GenTmpltPath;
  if fileexists(tmplname) then
  begin
    tmplt := True;
    OpenWorkBook(tmplname);
    wb1:=E.ActiveWorkbook;
    E.ActiveWorkbook.Sheets.item[1].cells.clear;
  end
  else
  begin
    AddWorkBook;
    AddSheet(�_MainPage);
    DeleteSheet(2);
  end;
  // rngObj := GetRangeObj(1, point(1, 1), point(1, 5));
  // rngObj.merge;
  // SetHorizontalAlignment(1, rngObj.Address, xlHAlignCenter);
  SetCell(1, 1, 1, '�����');
  SetCell(1, 1, 2, src.merafile.Date);
  SetCell(1, 1, 3, ''''+src.merafile.time);
  SetCell(1, 1, 4, ''''+src.merafile.FileName);
  SetCell(1, 2, c_Col_Name, '������');
  SetCell(1, 2, c_Col_Value, '��������');
  if UnitsCB.ItemIndex = 0 then
  begin
    SetCell(1, 2, c_Col_Time, '�����, ���.');
    SetCell(1, 2, c_Col_RefTime, '�����, ���.');
    SetCell(1, 2, c_Col_dT, 'dT, ���.');
  end
  else
  begin
    SetCell(1, 2, c_Col_Time, '�����, ��');
    SetCell(1, 2, c_Col_RefTime, '�����, ��');
    SetCell(1, 2, c_Col_dT, 'dT, ��');
  end;
  SetCell(1, 2, c_Col_Ref, '�������� �����');
  if UnitsCB.ItemIndex = 1 then
  begin
    k := 1000;
  end
  else
    k := 1;
  for i := 0 to outData.count - 1 do
  begin
    r := cSetRecord(outData.getRecord(i));
    SetCell(1, 3 + i, c_Col_Name, r.s.name);
    if start <> nil then
    begin
      trig:=r.t;
      // ���� ������ ������
      trig.trigValue:=true;
      getLeftTime(start,trig,index);
      //start.GetLow(@r.t, index);
      if index<>-1 then
      begin
        StartTrig:=start.getTrig(index);
        startT := start.getTrig(index).Time;
      end
      else
      begin
        startT := 0;
      end;
    end
    else
    begin
      startT := 0;
    end;
    // ������ ��� ������� ���������
    if r.refData then
    begin
      SetCell(1, 3 + i, c_Col_Name, r.s.name);
      SetCell(1, 3 + i, c_Col_Ref, r.ref.name);
      SetCell(1, 3 + i, c_Col_RefTime, (r.t.time - startT) * k);
      continue;
    end;


    if startT > r.t.Time then
      startT := 0;

    //if r.s.name = StartChanCB.Text then
    //  startT := 0;

    SetCell(1, 3 + i, c_Col_Time, (r.t.Time - startT) * k);
    // �������� �����/ ����
    if r.t.trigValue then
      SetCell(1, 3 + i, c_Col_Value, 1)
    else
    begin
      SetCell(1, 3 + i, c_Col_Value, 0);
    end;
    // ����
    if r.ref <> nil then
    begin
      if r.t.connectedTo<>-1 then
      begin
        SetCell(1, 3 + i, c_Col_Ref, r.ref.Name);
        SetCell(1, 3 + i, c_Col_RefTime, (r.reft.Time - startT) * k);
        SetCell(1, 3 + i, c_Col_dT, (r.reft.Time - r.t.Time) * k);
      end;
    end;
  end;
  rngObj := E.ActiveSheet.UsedRange;
  SetRangeBorder(rngObj);
  // ����� �������� �� ������������� ������� ����� (� ����� �������� �� � ��������)
  // ����������� ����� ��� ���� ����� �� ��������� ����� ����� ���� ��� ���� �������� ������ ����� �������� ����� ����������
  if e.ActiveWorkBook.sheets.count>1 then
    CopyPage(2);
  if fileexists(fname) then
  begin
    WorkBook:=OpenWorkBookEx(fname);
    str:=datetimetostr(now);
    //str:=DeleteChars(str, ' ');
    //str:=DeleteChars(str, '.');
    str:=replaceChar(str,':', ',');

    sheet2:=AddSheetEx(WorkBook, str);
    CopyPage(wb1, WorkBook, 2, sheet2);
    SaveWorkBookAs(WorkBook,fname);
    wb1.close(false);
    WorkBook.close(false);
    // ��������� ������
    if macroscb.Checked then
    begin
      WorkBook:=OpenWorkBookEx(fname);
      //sheet2.activate;
      //showmessage(fname+'!'+macrosEdit.text);
      RunMacros(extractfilename(fname)+'!'+macrosEdit.text);
      SaveWorkBookAs(WorkBook,fname);
      //g_logfile.addInfoMes('1');
      WorkBook.close(false);
    end;
    VisibleExcel(false);
    CloseExcel;
  end
  else
  begin
    SaveWorkBookAs(fname);
    // ��������� ������
    if macroscb.Checked then
    begin
      //sheet2.activate;
      //Application.Run "rep.xlsm!���������"
      RunMacros(extractfilename(fname)+'!'+macrosEdit.text);
      SaveWorkBookAs(fname);
    end;
    CloseWorkBook;
    CloseExcel;
  end;

  if not ShowReportCB.Checked then
  begin

  end
  else
  begin
    ExecFile(fname);
  end;
  if delstart then
  begin
    start.destroy;
    start:=nil;
  end;
end;

procedure TCyclogramRepFrm.LoadBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute() then
    LoadPathEdit.text:=OpenDialog1.FileName;
end;

procedure TCyclogramRepFrm.LoadCfg(path: string);
var
  i, count: integer;
  srcnode, child: txmlnode;
  doc: TNativeXml;
  li: TListItem;
  str: string;
  p: cpair;
  s: cwpsignal;
begin
  if src = nil then
    exit;
  clearLV;
  if fileexists(path) then
  begin
    doc := TNativeXml.create(nil);
    doc.LoadFromFile(path);
    srcnode := doc.Root.FindNode('CyclogramRep');
    // ����� ��������� �������
    str := srcnode.ReadAttributeString('Start', '');
    s := src.getSignalObj(str);
    if s <> nil then
      StartChanCB.Text := str;
    for i := 0 to srcnode.NodeCount - 1 do
    begin
      child := srcnode.Nodes[i];
      str := child.ReadAttributeString('Type', '');
      if str <> 'Signal' then
        continue;
      str := child.ReadAttributeString('Name', '');
      s := src.getSignalObj(str);
      if s <> nil then
      begin
        p := cpair.create;
        p.first := s;
        p.Lvl1 := (s.Signal.MaxY - s.Signal.MinY) / 2 + s.Signal.MinY;
        p.Lvl1:=child.ReadAttributeFloat('Lvl1', 0.5);
        p.lo_Lvl1 := p.Lvl1;
      end
      else
        continue;
      str := child.ReadAttributeString('RefName', '');
      s := src.getSignalObj(str);
      if s <> nil then
      begin
        p.second := s;
        p.Lvl2 := (s.Signal.MaxY - s.Signal.MinY) / 2 + s.Signal.MinY;
        p.Lvl2:=child.ReadAttributeFloat('Lvl2', 0.5);
        p.lo_Lvl2 := p.Lvl2;
      end;
      AddPair(p);
    end;
  end;
  LVChange(ChansLV);
end;

procedure TCyclogramRepFrm.SaveCfg(path: string);
var
  i: integer;
  b: boolean;
  srcnode, child: txmlnode;
  doc: TNativeXml;
  li: TListItem;
  p: cpair;
  dir: string;
begin
  if fileexists(path) then
  begin
    doc := TNativeXml.create(nil);
    doc.XmlFormat := xfReadable;
    doc.LoadFromFile(path);
    srcnode := doc.Root.FindNode('CyclogramRep');
    if srcnode = nil then
      srcnode := doc.Root.NodeNew('CyclogramRep')
    else
      srcnode.clear;
    if StartChanCB.ItemIndex > -1 then
      srcnode.WriteAttributeString('Start', StartChanCB.Text);
  end
  else
  begin
    doc := TNativeXml.CreateName('Root');
    doc.XmlFormat := xfReadable;
    srcnode := doc.Root.NodeNew('CyclogramRep');
    if StartChanCB.ItemIndex > -1 then
      srcnode.WriteAttributeString('Start', StartChanCB.Text);
  end;
  // ������ ������� ��� ������ �� �����������
  for i := 0 to ChansLV.Items.count - 1 do
  begin
    li := ChansLV.Items[i];
    p := cpair(li.data);
    child := srcnode.NodeNew('S_' + inttostr(i));
    child.WriteAttributeString('Name', p.first.name, '');
    child.WriteAttributeString('Type', 'Signal', '');
    child.WriteAttributeFloat('Lvl1', p.Lvl1, 0.5);
    child.WriteAttributeFloat('Lvl2', p.Lvl2, 0.5);
    if p.second <> nil then
      child.WriteAttributeString('RefName', p.second.name, '');
  end;
  dir := extractfiledir(path);
  b := ForceDirectories(dir);
  if b then
  begin
    doc.SaveToFile(path);
  end
  else
    showmessage('�� ������� ������� ����, �������� ���� �� ����������');
end;

procedure TCyclogramRepFrm.SaveCfgBtnClick(Sender: TObject);
begin
  SaveCfg(LoadPathEdit.Text);
end;

function TCyclogramRepFrm.CheckLV(s: cwpsignal; lv: TBtnListView): boolean;
var
  i: integer;
begin
  result := True;
  for i := 0 to lv.Items.count - 1 do
  begin
    if lv.Items[i].data = s then
    begin
      result := false;
      exit;
    end;
  end;
end;

procedure TCyclogramRepFrm.clearLV;
var
  li: TListItem;
  i: integer;
begin
  for i := 0 to ChansLV.Items.count - 1 do
  begin
    li := ChansLV.Items[i];
    cpair(li.data).destroy;
  end;
  ChansLV.clear;
end;

procedure TCyclogramRepFrm.RelincPairs;
var
  I: Integer;
  li:tlistitem;
  str:string;
  p:cpair;
begin
  //for I := 0 to chansLV.items.Count - 1 do
  //begin
  //  li:=chansLV.Items[i];
  //  cpair(li.data).destroy;
  //end;
  if chansLV.items.Count=0 then exit;

  for I := 0 to chansLV.items.Count - 1 do
  begin
    li:=chansLV.Items[i];
    ChansLV.GetSubItemByColumnName('�����', li, str);
    p:=cpair(li.data);
    p.first:=src.getSignalObj(str);
    ChansLV.GetSubItemByColumnName('�������� �����', li, str);
    p.second:=src.getSignalObj(str);
  end;
  i:=0;
  while I <= chansLV.items.Count - 1 do
  begin
    li:=chansLV.Items[i];
    p:=cpair(li.data);
    //ChansLV.SetSubItemByColumnName('�', inttostr(ChansLV.Items.count), new_li);
    //ChansLV.GetSubItemByColumnName('�����', licwpsignal(li.data).name, new_li);
    if p.first=nil then
    begin
      p.destroy;
      li.Destroy;
      continue;
    end;
    if p.second=nil then
    begin
      ChansLV.SetSubItemByColumnName('�������� �����', '', li);
    end;
    inc(i);
  end;
end;

procedure TCyclogramRepFrm.DelBtnClick(Sender: TObject);
var
  i: integer;
  li: TListItem;
begin
  for i := 0 to ChansLV.SelCount - 1 do
  begin
    li := ChansLV.Items[i + ChansLV.Selected.Index];
    cpair(li.data).destroy;
  end;
  ChansLV.DeleteSelected;
end;

procedure TCyclogramRepFrm.FilterEditChange(Sender: TObject);
begin
  ShowCommonChannels(length(FilterEdit.Text) > 0, ChanTypeRG.ItemIndex,
    FilterEdit.Text);
end;

procedure TCyclogramRepFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveParams;
end;

procedure TCyclogramRepFrm.FormCreate(Sender: TObject);
begin
  signals := tstringlist.create;
  signals.Sorted := True;
  outData := cRecords.create;
end;

procedure TCyclogramRepFrm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  signals.destroy;
  outData.destroy;
end;

procedure TCyclogramRepFrm.FormShow(Sender: TObject);
begin
  src := wp.GetCurSrcInMainWnd;
  if src <> nil then
  begin
    if src.merafile <> nil then
    begin
      TmpltNameFrame1.SetObjectPath(src.merafile.FileName);
    end;
  end;
  if src <> nil then
  begin
    if LoadPathEdit.Text = '' then
      LoadPathEdit.Text := wp.lastcfg;
    UpdateStartChanCB;
    ShowCommonChannels(length(FilterEdit.Text) > 0, ChanTypeRG.ItemIndex,
      FilterEdit.Text);
    // ��������������� ������� � ChansLV
    RelincPairs;
  end;
end;

procedure TCyclogramRepFrm.AddBtnClick(Sender: TObject);
var
  i: integer;
  new_li, li: TListItem;
  p: cpair;
begin
  ChansLV.Items.BeginUpdate;
  for i := 0 to CommonLV.SelCount - 1 do
  begin
    new_li := ChansLV.Items.add;
    li := CommonLV.Items[CommonLV.Selected.Index + i];
    p := cpair.create;
    p.first := cwpsignal(li.data);
    p.Lvl1 := (p.first.Signal.MaxY - p.first.Signal.MinY)
      / 2 + p.first.Signal.MinY;
    if p.Lvl1 = 0 then
      p.Lvl1 := 0.5;
    p.lo_Lvl1 := p.Lvl1;
    new_li.data := p;
    ChansLV.SetSubItemByColumnName('�', inttostr(ChansLV.Items.count), new_li);
    ChansLV.SetSubItemByColumnName('�����', cwpsignal(li.data).name, new_li);
    ChansLV.SetSubItemByColumnName('�������1', floattostr(p.Lvl1), new_li);
  end;
  ChansLV.Items.EndUpdate;
end;

procedure TCyclogramRepFrm.ChansLVDblClickProcess(item: TListItem;
  lv: TListView);
begin
  if TrigLvlFrm = nil then
    TrigLvlFrm := TTrigLvlFrm.create(nil);
  TrigLvlFrm.EditPair(cpair(item.data));
  ChansLV.SetSubItemByColumnName('�������1', floattostr(cpair(item.data).Lvl1),
    item);
  ChansLV.SetSubItemByColumnName('�������2', floattostr(cpair(item.data).Lvl2),
    item);
end;

procedure TCyclogramRepFrm.ChansLVDragDrop(Sender, Source: TObject;
  X, Y: integer);
var
  DragItem, DropItem, CurrentItem, NextItem: TListItem;
begin
  if Sender = Source then
    with TListView(Sender) do
    begin
      DropItem := GetItemAt(X, Y);
      CurrentItem := Selected;
      while CurrentItem <> nil do
      begin
        NextItem := GetNextItem(CurrentItem, SdAll, [IsSelected]);
        if DropItem = nil then
          DragItem := Items.add
        else
          DragItem := Items.Insert(DropItem.Index);
        DragItem.Assign(CurrentItem);
        CurrentItem.Free;
        CurrentItem := NextItem;
      end;
    end;
end;

procedure TCyclogramRepFrm.ChansLVDragOver(Sender, Source: TObject;
  X, Y: integer; State: TDragState; var Accept: boolean);
begin
  Accept := Sender = ChansLV;
end;

procedure TCyclogramRepFrm.ChanTypeRGClick(Sender: TObject);
begin
  ShowCommonChannels(length(FilterEdit.Text) > 0, ChanTypeRG.ItemIndex,
    FilterEdit.Text);
  case ChanTypeRG.ItemIndex of
    0:
      begin
        UnLinkBtn.Enabled := True;
        LinkBtn.Enabled := True;
        AddBtn.Enabled := True;
        DelBtn.Enabled := True;
        UnLinkBtn.Indeterminate := not UnLinkBtn.Enabled;
        LinkBtn.Indeterminate := not LinkBtn.Enabled;
        AddBtn.Indeterminate := not AddBtn.Enabled;
        DelBtn.Indeterminate := not DelBtn.Enabled;
      end;
    1:
      begin
        UnLinkBtn.Enabled := false;
        LinkBtn.Enabled := false;
        AddBtn.Enabled := True;
        DelBtn.Enabled := True;
        UnLinkBtn.Indeterminate := not UnLinkBtn.Enabled;
        LinkBtn.Indeterminate := not LinkBtn.Enabled;
        AddBtn.Indeterminate := not AddBtn.Enabled;
        DelBtn.Indeterminate := not DelBtn.Enabled;
      end;
    2:
      begin
        UnLinkBtn.Enabled := True;
        LinkBtn.Enabled := True;
        AddBtn.Enabled := false;
        DelBtn.Enabled := false;
        UnLinkBtn.Indeterminate := not UnLinkBtn.Enabled;
        LinkBtn.Indeterminate := not LinkBtn.Enabled;
        AddBtn.Indeterminate := not AddBtn.Enabled;
        DelBtn.Indeterminate := not DelBtn.Enabled;
      end;
  end;
end;

procedure TCyclogramRepFrm.UpdateStartChanCB;
var
  i: integer;
  s: cwpsignal;
  text:string;
begin
  text:=StartChanCB.Text;
  StartChanCB.clear;
  for i := 0 to src.childcount - 1 do
  begin
    s := src.getSignalObj(i);
    StartChanCB.AddItem(s.Name, s);
  end;
  for i:= 0 to StartChanCB.items.Count - 1 do
  begin
    if StartChanCB.Items[i]=text then
    begin
      StartChanCB.ItemIndex:=i;
      exit;
    end;
  end;
  StartChanCB.ItemIndex := -1;
end;

procedure TCyclogramRepFrm.ShowCommonChannels(filter: boolean;
  ChannelsType: integer; filter_str: String);
var
  i, num: integer;
  s: cwpsignal;
  sname: string;
  li: TListItem;
  b: boolean;
begin
  if src = nil then
    exit;
  CommonLV.clear;
  CommonLV.Items.BeginUpdate;
  for i := 0 to src.childcount - 1 do
  begin
    s := src.getSignalObj(i);
    sname := s.Signal.GetProperty('modname');
    if ChannelsType = c_OutChan then
    begin
      if not((pos('406', sname) > 0) or (pos('402', sname) > 0) or (pos('819',
            sname) > 0) or (pos('825', sname) > 0)) then
        continue;
    end;
    if ChannelsType = c_InChan then
    begin
      if not((pos('405', sname) > 0) or (pos('401', sname) > 0) or (pos('819',
            sname) > 0) or (pos('825', sname) > 0)) then
        continue;
    end;
    if filter then
    begin
      b := pos(filter_str, s.Name) > 0;
      if not b then
      begin
        continue;
      end;
    end;
    num := CommonLV.Items.count;
    li := CommonLV.Items.add;
    li.data := s;
    CommonLV.SetSubItemByColumnName('�', inttostr(num), li);
    CommonLV.SetSubItemByColumnName('�����', s.name, li);
    CommonLV.SetSubItemByColumnName('��� �����', sname, li);
  end;
  CommonLV.Items.EndUpdate;
  LVChange(CommonLV);
end;

procedure TCyclogramRepFrm.TmpltNameFrame1FolderRGClick(Sender: TObject);
begin
  TmpltNameFrame1.FolderRGClick(Sender);
end;

procedure TCyclogramRepFrm.TmpltNameFrame1MakeDefaultNameBtnClick
  (Sender: TObject);
begin
  TmpltNameFrame1.MakeDefaultNameBtnClick(Sender);

end;

procedure TCyclogramRepFrm.TmpltNameFrame1NameRGClick(Sender: TObject);
begin
  TmpltNameFrame1.NameRGClick(Sender);
end;

function TCyclogramRepFrm.evaltriglist(hi, lo:double; first, b_hi, b_lo:boolean; s:cwpsignal):cTrigSetList;
var
  i:integer;
  v:double;
  trigval: sTrig;
  trig, lo_trig, startSensor:boolean;
begin
  result:=cTrigSetList.create;
  for i := 0 to s.Signal.size - 1 do
  begin
    v := s.Signal.GetY(i);
    // ���������� ����� ����� ������
    if i = 0 then
    begin
      if v > hi then
      begin
        trig := false;
        lo_trig := True;
        if first then
        begin
          trigval.trigValue := True;
          trigval.Time := s.Signal.GetX(i);
          result.add(trigval);
        end;
      end
      else
      begin
        if v < lo then
        begin
          trig := True;
          lo_trig := false;
        end
        else
        begin
          trig := True;
          lo_trig := True;
        end;
      end;
    end;
    // ����� �������
    if trig then
    begin
      if v > hi then
      begin
        trigval.Time := s.Signal.GetX(i);
        trigval.trigValue := True;
        if FrontCB.Checked then
          result.add(trigval);
        trig := false;
        lo_trig := True;
      end;
    end;
    startSensor:=(StartChanCB.text=s.name);
    // ����� ������
    if lo_trig then
    begin
      if v < lo then
      begin
        // �� ����� ������ ��� ������� ��������� �������
        if not startSensor  then
        begin
          trigval.Time := s.Signal.GetX(i);
          trigval.trigValue := false;
          if FallCB.Checked then
            result.add(trigval);
        end;
        lo_trig := false;
        trig := True;
      end;
    end;
  end;
end;

function TCyclogramRepFrm.EvalDataTable(p: cpair): cSDataList;
var
  i: integer;
  v: double;
  // ������� ��������
  Writefirst, find_low, find_hi, lo_trig, trig, startSensor: boolean;
  s: cwpsignal;
  TrigLevel, lo_TrigLevel: double;

  trigval: sTrig;
begin
  result := cSDataList.create;
  result.s := p;
  Writefirst := NullCB.Checked;
  // ������ �����
  find_low := FallCB.Checked;
  // ������ ������
  find_hi := FrontCB.Checked;
  s := p.first;
  if s.Name = StartChanCB.Text then
    startSensor := True
  else
    startSensor := false;
  TrigLevel := p.Lvl1;
  lo_TrigLevel := p.lo_Lvl1;
  for i := 0 to s.Signal.size - 1 do
  begin
    v := s.Signal.GetY(i);
    // ���������� ����� ����� ������
    if i = 0 then
    begin
      if v > TrigLevel then
      begin
        trig := false;
        lo_trig := True;
        // ������ �������� ����� ������ ��� ������ "1"
        if Writefirst then
        begin
          trigval.firstval:=true;
          trigval.trigValue := True;
          trigval.Time := s.Signal.GetX(i);
          result.data.add(trigval);
        end;
      end
      else
      begin
        if v < lo_TrigLevel then
        begin
          trig := True;
          lo_trig := false;
        end
        else
        begin
          trig := True;
          lo_trig := True;
        end;
      end;
    end;
    if find_hi then
    begin
      // ����� �������
      if trig then
      begin
        if v > TrigLevel then
        begin
          trigval.Time := s.Signal.GetX(i);
          trigval.trigValue := True;
          trigval.firstval:=false;
          if FrontCB.Checked then
            result.data.add(trigval);
          trig := false;
          lo_trig := True;
        end;
      end;
    end;
    // ����� ������
    if find_low then
    begin
      if lo_trig then
      begin
        if v < lo_TrigLevel then
        begin
          trigval.Time := s.Signal.GetX(i);
          trigval.trigValue := false;
          trigval.firstval:=false;
          if FallCB.Checked then
            result.data.add(trigval);
          lo_trig := false;
          trig := True;
        end;
      end;
    end;
  end;
  if startSensor then
    exit;
  s := p.second;
  TrigLevel := p.Lvl2;
  lo_TrigLevel := p.lo_Lvl2;
  if s <> nil then
  begin
    for i := 0 to s.Signal.size - 1 do
    begin
      v := s.Signal.GetY(i);
      // ���������� ����� ����� ������
      if i = 0 then
      begin
        if v > TrigLevel then
        begin
          trig := false;
          lo_trig := True;
          trigval.connectedTo:=-1;
          trigval.Time := s.Signal.GetX(i);
          trigval.trigValue := True;
          trigval.firstval:=true;
          result.refData.add(trigval);
        end
        else
        begin
          if v < lo_TrigLevel then
          begin
            trig := True;
            lo_trig := false;
          end
          else
          begin
            trig := True;
            lo_trig := True;
          end;
        end;
      end;
      // ����� �������
      if trig then
      begin
        if v > TrigLevel then
        begin
          trigval.Time := s.Signal.GetX(i);
          trigval.trigValue := True;
          trigval.firstval:=false;
          if FrontCB.Checked then
            result.refData.add(trigval);
          trig := false;
          lo_trig := True;
        end;
      end;
      // ����� ������
      if lo_trig then
      begin
        if v < lo_TrigLevel then
        begin
          trigval.Time := s.Signal.GetX(i);
          trigval.trigValue := false;
          trigval.firstval:=false;
          if FallCB.Checked then
            result.refData.add(trigval);
          lo_trig := false;
          trig := True;
        end;
      end;
    end;
  end;
end;

procedure TCyclogramRepFrm.LinkMng(mng: cWPObjMng);
begin
  wp := mng;
  TmpltNameFrame1.SetIFile(startdir + 'Services.ini', 'CyclRep', 'CyclRep_',
    startdir);

  LoadPathEdit.Text := mng.lastcfg;
  LoadParams;
  TmpltNameFrame1.NameRGClick(nil);
  TmpltNameFrame1.FolderRGClick(nil);
  TmpltNameFrame1.AutoPathCBClick(nil);
end;

procedure TCyclogramRepFrm.SaveParams;
var
  ifile: tinifile;
begin
  ifile := tinifile.create(startdir + 'Services.ini');
  ifile.WriteString('CyclRep', 'CyclCfg', LoadPathEdit.Text);
  ifile.WriteInteger('CyclRep', 'Units', UnitsCB.ItemIndex);
  ifile.WriteBool('CyclRep', 'ShowReport', ShowReportCB.Checked);
  ifile.WriteBool('CyclRep', 'Front', FrontCB.Checked);
  ifile.WriteBool('CyclRep', 'Fall', FallCB.Checked);
  ifile.WriteBool('CyclRep', 'Null', NullCB.Checked);
  ifile.WriteBool('CyclRep', 'ExecMacros', MacrosCB.Checked);
  ifile.WriteString('CyclRep', 'MacrosName', MacrosEdit.text);
  ifile.destroy;
  TmpltNameFrame1.SaveParams;
end;

procedure TCyclogramRepFrm.LoadParams;
var
  ifile: tinifile;
begin
  ifile := tinifile.create(startdir + 'Services.ini');
  LoadPathEdit.Text := ifile.ReadString('CyclRep', 'CyclCfg', '');
  ShowReportCB.Checked := ifile.ReadBool('CyclRep', 'ShowReport', false);
  UnitsCB.ItemIndex := ifile.ReadInteger('CyclRep', 'Units', 0);
  FrontCB.Checked := ifile.ReadBool('CyclRep', 'Front', True);
  FallCB.Checked := ifile.ReadBool('CyclRep', 'Fall', True);
  NullCB.Checked := ifile.ReadBool('CyclRep', 'Null', True);
  MacrosCB.Checked:=ifile.ReadBool('CyclRep', 'ExecMacros', false);
  MacrosEdit.text:=ifile.ReadString('CyclRep', 'MacrosName', '');
  TmpltNameFrame1.LoadParams;
  CyclogramRepFrm.Caption:='��������� ������ ����������� +(������ '+datetostr(now)+')';
end;

procedure TCyclogramRepFrm.Process;
var
  i, index: integer;
  li: TListItem;
  p: cpair;
  d: cSDataList;
  s: cwpsignal;
  t:strig;
begin
  ClearSignalsData;
  for i := 0 to ChansLV.Items.count - 1 do
  begin
    li := ChansLV.Items[i];
    p := cpair(li.data);
    d := EvalDataTable(p);
    signals.AddObject(p.first.name, d);
  end;
end;

procedure TCyclogramRepFrm.PostProcess;
var
  d: cSDataList;
  i, j, index1,index2: integer;
  r: cSetRecord;
  t1, t2:strig;
begin
  for i := 0 to signals.count - 1 do
  begin
    d := cSDataList(signals.Objects[i]);
    // d.data - ������� ������������ ������ ������
    if d.s.second <> nil then
    begin
      //
      for j := 0 to d.data.count - 1 do
      begin
        r := cSetRecord.create;
        r.s := d.s.first;
        r.ref := d.s.second;
        r.t :=d.data.getTrig(j);
        if r.t.firstval then
        begin
          if d.refData.Count>0 then
          begin
            r.reft:=d.refdata.getTrig(0);
            if r.reft.firstval then
            begin
              r.t.connectedTo:=0;
              d.refData.SetTrigProp_connectedto(0, 0);
              r.reft.connectedTo:=0;
            end;
          end;
        end
        else
        begin
          t1:=r.t;
          t2:=getRightTime(d.refData,t1, index2);
          if index2<>-1 then
          begin
            // �������� ��� ���������� ������� �������������� �������������
            // �������� t1 � �� ����� ��������� �������� � ��� �� �������
            getLeftTime(d.data,t2,index1);
            if index1=j then
            begin
              r.t.connectedTo:=index2;
              r.reft := t2;
              d.refData.SetTrigProp_connectedto(index2, index1);
            end;
          end;
        end;
        outData.add(r);
      end;
    end
    else
    begin
      for j := 0 to d.data.count - 1 do
      begin
        r := cSetRecord.create;
        r.s := d.s.first;
        r.t := d.data.getTrig(j);
        outData.add(r);
      end;
    end;
    // ��������� ����� ������� �� ������������� �������� ������ (������ ��������)
    for j := 0 to d.refData.Count - 1 do
    begin
      t2:=d.refData.getTrig(j);
      if t2.connectedTo=-1 then
      begin
        r := cSetRecord.create;
        r.refData:=true;
        r.t:=t2;
        r.s:=d.s.first;
        r.ref:=d.s.second;
        outData.add(r);
      end;
    end;
  end;
end;

procedure TCyclogramRepFrm.AddPair(p: cpair);
var
  li: TListItem;
begin
  li := ChansLV.Items.add;
  li.data := p;
  ChansLV.SetSubItemByColumnName('�', inttostr(ChansLV.Items.count), li);
  ChansLV.SetSubItemByColumnName('�����', p.first.name, li);
  ChansLV.SetSubItemByColumnName('�������1', floattostr(p.Lvl1), li);
  if p.second <> nil then
  begin
    ChansLV.SetSubItemByColumnName('�������� �����', p.second.name, li);
    ChansLV.SetSubItemByColumnName('�������2', floattostr(p.Lvl2), li);
  end;
end;

procedure TCyclogramRepFrm.UnLinkBtnClick(Sender: TObject);
var
  i, ind, count: integer;
  li: TListItem;
begin
  count := ChansLV.SelCount;
  for i := 0 to count - 1 do
  begin
    ind:=ChansLV.Selected.Index+i;
    li := ChansLV.Items[ind];
    cpair(li.data).second := nil;
    ChansLV.SetSubItemByColumnName('�������� �����', '', li);
  end;
end;

procedure TCyclogramRepFrm.LinkBtnClick(Sender: TObject);
var
  i, count: integer;
  li: TListItem;
begin
  count := max(ChansLV.SelCount, CommonLV.SelCount);
  for i := 0 to count - 1 do
  begin
    if ChansLV.Selected = nil then
    begin
      if ChansLV.Items.count > 0 then
        ChansLV.Selected := ChansLV.Items[0]
      else
      begin
        showmessage(
          '����� �������� ������ ����� ����������� �������� ������ �� ������ +'
          );
        exit;
      end;
    end;
    li := ChansLV.Items[ChansLV.Selected.index + i];
    cpair(li.data).second := cwpsignal
      (CommonLV.Items[CommonLV.Selected.Index + i].data);
    cpair(li.data).Lvl2 := (cpair(li.data).second.Signal.MaxY - cpair(li.data)
        .second.Signal.MinY) / 2 + cpair(li.data).second.Signal.MinY;
    ChansLV.SetSubItemByColumnName('�������� �����',
      cpair(li.data).second.name, li);
    ChansLV.SetSubItemByColumnName('�������2', floattostr(cpair(li.data).Lvl2),
      li);
  end;
end;

procedure TCyclogramRepFrm.ClearSignalsData;
var
  i: integer;
  s: cSDataList;
begin
  for i := 0 to signals.count - 1 do
  begin
    s := cSDataList(signals.Objects[i]);
    s.destroy;
  end;
  signals.clear;
  outData.clear;
end;

constructor cSDataList.create;
begin
  data := cTrigSetList.create;
  refData := cTrigSetList.create;
end;

destructor cSDataList.destroy;
begin
  data.destroy;
  refData.destroy;
end;

destructor cpair.destroy;
begin
  first := nil;
  second := nil;
end;

constructor cpair.create;
begin
  id := CyclogramRepFrm.ChansLV.Items.count;
end;

function RecordProccomparator(p1, p2: pointer): integer;
begin
  if cSetRecord(p1).t.Time > cSetRecord(p2).t.Time then
    result := 1
  else
  begin
    if cSetRecord(p1).t.Time < cSetRecord(p2).t.Time then
      result := -1
    else
      result := 0;
  end;
end;

constructor cRecords.create;
begin
  inherited;
  comparator := RecordProccomparator;
end;

function cRecords.add(v: cSetRecord): integer;
begin
  result := AddObj(v);
end;

function cRecords.getRecord(i: integer): cSetRecord;
begin
  if i <= count - 1 then
  begin
    result := cSetRecord(getnode(i));
  end;
end;

procedure cRecords.deletechild(node: pointer);
begin
  cSetRecord(node).destroy;
end;

function Trigproccomparator(p1, p2: pointer): integer;
begin
  if sTrig(p1^).Time > sTrig(p2^).Time then
    result := 1
  else
  begin
    if sTrig(p1^).Time < sTrig(p2^).Time then
      result := -1
    else
      result := 0;
  end;
end;

constructor cTrigSetList.create;
begin
  inherited;
  comparator := Trigproccomparator;
end;

function cTrigSetList.add(v: sTrig): integer;
var
  trig: pTrig;
begin
  getmem(trig, sizeof(sTrig));
  v.connectedTo:=-1;
  trig^ := v;
  result := AddObj(trig);
end;

function cTrigSetList.getTrig(i: integer): sTrig;
begin
  if i <= count - 1 then
  begin
    result := sTrig(getnode(i)^);
  end;
end;

procedure cTrigSetList.SetTrigProp_connectedto(ind, ct:integer );
begin
  sTrig(getnode(ind)^).connectedTo:=ct;
end;

procedure cTrigSetList.deletechild(node: pointer);
begin
  freemem(pTrig(node));
end;

end.
