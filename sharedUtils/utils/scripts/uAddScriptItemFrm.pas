unit uAddScriptItemFrm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, DCL_MYOWN, uScriptFrm, uWPproc, POSBase, Winpos_ole_TLB,
  VirtualTrees, uVTServices, ExtCtrls, ImgList, usetlist;

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
    UnitsEdit: TEdit;
    DscEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    SelNameEdit: TEdit;
    SelFsEdit: TFloatEdit;
    SelUnitsEdit: TEdit;
    SelDscEdit: TEdit;
    Label6: TLabel;
    SelAplyBtn: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    minFS:double;
    ressrc:csrc;
  private
    mng:cWpObjMng;
    // �������� �����
    sl, signalsList:cSelectList;
    // ������ �� ������� scriptItem-�
    sList:tstringlist;
  private
    // jnj,hfpobnm �������� ���������
    procedure ShowSignalsProperties;
    procedure SetSignalsProperties;
  public
    procedure LinkMng(m:cWpObjMng;scriptList:tstringlist; res:csrc);
    // s - ������� � ������� ��������� ������
    function CreateTag(s:csrc):TscriptItem;
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
    if SelNameEdit.Text<>'' then
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

    end;
  end;
end;

procedure TAddScriptItemFrm.ShowSignalsProperties;
var
  s:cWPSignal;
  I: Integer;
begin
  SelNameEdit.enabled:=true;
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

procedure GetSrcSignals(s:cSrc; l:cselectlist);
var
  sig:cWPSignal;
  I: Integer;
begin
  for I := 0 to s.Count - 1 do
  begin
    sig:=s.GetWPSignal(i);
    l.AddObj(sig);
  end;
end;

procedure TAddScriptItemFrm.LinkMng(m:cWpObjMng;scriptList:tstringlist; res:csrc);
begin
  mng:=m;
  sl:=cSelectList.create;
  slist:=scriptList;
  ressrc:=res;
end;

procedure TAddScriptItemFrm.Button1Click(Sender: TObject);
var
  i:integer;
begin
  if not sList.find(nameedit.text,i) then
  begin
    CreateTag(ressrc);
    ModalResult:=mrok;
  end;
end;

function TAddScriptItemFrm.CreateTag(s:csrc):TscriptItem;
var
  isig:iwpsignal;
  sig:cwpSignal;
  n:iwpnode;
begin
  result:=TScriptItem.Create;
  isig:=wp.CreateSignal(VT_R4) as iwpsignal;
  isig.sname:=nameedit.text;
  n := iwpnode(wp.Link(s.name, isig.sname, isig));
  // ��������� ���������� ��� �� ����������� �������
  sig:=s.CreateSignal(isig);
  Result.initSignal(sig);
  result.ffreq:=FsEdit.FloatNum;
  //result.Units:=UnitsEdit.Text;
  //result.dsc:=DscEdit.Text;
  // ��������� �����
  slist.AddObject(result.Name, result);
end;

procedure TAddScriptItemFrm.FormShow(Sender: TObject);
begin
  FSEdit.FloatNum:=minFS;
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
