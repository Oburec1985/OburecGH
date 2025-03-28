unit uAddScriptItemFrm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, DCL_MYOWN, uScriptFrm, uWPproc, POSBase, Winpos_ole_TLB,
  VirtualTrees, uVTServices, ExtCtrls, ImgList, usetlist, uWPServices;

type
  cSelectList = class(cSetList)
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;override;
  end;

  TAddScriptItemFrm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    Panel3: TPanel;
    NameLabel: TLabel;
    FSLabel: TLabel;
    UnitsLabel: TLabel;
    DscLabel: TLabel;
    NameEdit: TEdit;
    FsEdit: TFloatEdit;
    DscEdit: TEdit;
    Label1: TLabel;
    UnitsCBX: TComboBox;
    Label2: TLabel;
    UnitsCBY: TComboBox;
    procedure FormShow(Sender: TObject);
  public
    minFS:double;
    ressrc:csrc;
    outSI:tscriptitem;
  private
    mng:cWpObjMng;
    // �������� �����
    sl, signalsList:cSelectList;
    fAddTaggProc:tnotifyevent;
  private
    // jnj,hfpobnm �������� ���������
    procedure ShowSignalsProperties;
    procedure SetSignalsProperties;
  public
    procedure LinkMng(m:cWpObjMng; res:csrc; addTagProc:tnotifyevent);
    // s - ������� � ������� ��������� ������
    function CreateTag(s:csrc):TscriptItem;
    Function ShowModal:integer;override;
  end;

const
  c_SrcIndex = 18;
  c_SignalIndex = 22;

var
  AddScriptItemFrm: TAddScriptItemFrm;


implementation

{$R *.dfm}

procedure TAddScriptItemFrm.SetSignalsProperties;
var
  s:cWPSignal;
  I: Integer;
begin
  if signalsList.Count>0 then
  begin
    s:=cWPSignal(signalslist.Items[i]);
    {if SelNameEdit.Text<>'' then
    begin
      s.Name:=SelNameEdit.Text;
    end;
    if SelFsEdit.text<>'' then
    begin
      if s.virt then
        s.fs:=SelFsEdit.FloatNum;
    end;
    if SelUnitsEdit.text<>'' then
    begin

    end;}
  end;
end;

procedure TAddScriptItemFrm.ShowSignalsProperties;
var
  s:cWPSignal;
  I: Integer;
begin
  {SelNameEdit.enabled:=true;
  SelDscEdit.enabled:=true;

  if signalsList.Count>0 then
  begin
    s:=cWPSignal(signalsList.Items[0]);
    SelNameEdit.Text:=s.Name;
    SelFsEdit.FloatNum:=s.fs;
    SelUnitsEdit.Text:=s.UnitName;
    SelDscEdit.Text:=s.Signal.comment;
  end;
  if signalsList.Count>1 then
  begin
    for I := 1 to signalsList.Count - 1 do
    begin
      s:=cWPSignal(signalsList.Items[i]);
      // ���
      SelNameEdit.Text:='';
      SelNameEdit.Enabled:=false;
      // ������� ������
      if SelFsEdit.text<>'' then
      begin
        if SelFsEdit.FloatNum<>s.fs then
        begin
          SelFsEdit.text:='';
        end;
      end;
      // �������
      if SelUnitsEdit.text<>'' then
      begin
        if SelUnitsEdit.text<>s.UnitName then
        begin
          SelUnitsEdit.text:='';
        end;
      end;
      // ����������
      if SelDscEdit.text<>'' then
      begin
        if SelDscEdit.text<>s.Signal.comment then
        begin
          SelDscEdit.text:='';
        end;
      end;
    end;

    //s:=cWPSignal(signalsList.Items[0]);
    //SelNameEdit.Text:=s.Name;
    //SelFsEdit.FloatNum:=s.fs;
    //SelUnitsEdit.Text:=s.UnitName;
    //SelDscEdit.Text:=s.Signal.comment;
  end;}
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

procedure GetSrcSignals(s:cSrc; l:cselectlist);
var
  sig:cWPSignal;
  I: Integer;
begin
  for I := 0 to s.childCount - 1 do
  begin
    sig:=s.getSignalObj(i);
    l.AddObj(sig);
  end;
end;


Function TAddScriptItemFrm.ShowModal:integer;
var
  i:integer;
  si:tscriptitem;
begin
  result:=inherited;
  if result=mrok then
  begin
    si:=CreateTag(ressrc);
    // ���������� AddSI
    fAddTaggProc(si);
    ModalResult:=mrok;
  end
  else
  begin
    outSI:=nil;
  end;
end;

procedure TAddScriptItemFrm.LinkMng(m:cWpObjMng; res:csrc; addTagProc:tnotifyevent);
begin
  mng:=m;
  sl:=cSelectList.create;
  ressrc:=res;
  fAddTaggProc:=addTagProc;
end;



function TAddScriptItemFrm.CreateTag(s:csrc):TscriptItem;
var
  isig:iwpsignal;
  sig:cwpSignal;
begin
  result:=TScriptItem.Create;
  result.ScriptChannel:=true;
  sig:=s.getSignalObj(nameedit.text);
  if sig=nil then
  begin
    isig:=wp.CreateSignal(VT_R4) as iwpsignal;
    isig.size:=trunc(ScriptFrm.GetLen*FsEdit.FloatNum);
    isig.StartX:=ScriptFrm.T1FE.FloatNum;
    isig.sname:=nameedit.text;
    result.funits.x:=unitsCBX.ItemIndex;
    result.funits.y:=unitsCBY.ItemIndex;
    setSignalUnits(isig, unitsCBY.ItemIndex, unitsCBX.ItemIndex);
    if unitsCBY.ItemIndex=-1 then
    begin
      isig.NameY:=unitsCBY.Text;
    end;
    // ��������� ���������� ��� �� ����������� �������
    sig:=s.CreateSignal(isig);
  end
  else
    setSignalUnits(sig.signal, unitsCBY.ItemIndex, unitsCBX.ItemIndex);
  Result.initSignal(sig);
  result.freq:=FsEdit.FloatNum;
  outSI:=result;
  wp.Refresh;
end;

procedure TAddScriptItemFrm.FormShow(Sender: TObject);
begin
  if minFS<>0 then
    FSEdit.FloatNum:=1/minFS;
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
