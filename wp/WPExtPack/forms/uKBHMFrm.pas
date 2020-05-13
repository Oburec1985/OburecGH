unit uKBHMFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uChart, ComCtrls, uBtnListView, StdCtrls, Buttons,
  VirtualTrees, uVTServices, Grids, AdvObj, BaseGrid, AdvGrid, inifiles,
  uWPProc, uCommonMath;

type
  cPropertie = class
  public
    name:string;
    units:string;
    threshold:double;
    value:double;
  end;

  cGroup = class
  public
    name:string;
    Params:tstringlist;
  public
    // ����� �������
    function Count:integer;
    function GetProp(i:integer):cPropertie;
    procedure addProp(p:cPropertie);
    constructor create;
    destructor destroy;
  end;

  TKBHMFrm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    OpenBtn: TBitBtn;
    ObjGB: TGroupBox;
    EngControlPanel: TPanel;
    EngAddBtn: TBitBtn;
    EngDelBtn: TBitBtn;
    ChanGB: TGroupBox;
    GroupControlPanel: TPanel;
    GroupAddBtn: TBitBtn;
    GroupDelBtn: TBitBtn;
    GraphTV: TVTree;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    PropSG: TAdvStringGrid;
  private
    ini:boolean;
    groups:tstringlist;
  private
    procedure Init;
    // ������������������� ������� ����������
    procedure InitSG;
    // ��������� ������ ����������
    procedure loadgroup;
    // ��������� ������ ����������
    procedure savegroup;
    // ���������� ��������������� ��������
    procedure ShowParams;
    function getgroup(i:integer):cgroup;
    procedure ClearGroups;
  public
    function Showmodal:integer;override;
  end;

var
  KBHMFrm: TKBHMFrm;

const
  c_KBHM_HeadSize = 2;
  c_KBHM_GroupCol = 0;
  c_KBHM_NameCol = 1;
  c_KBHM_UnCol = 2;
  c_KBHM_TUCol = 3;
  c_KBHM_ValCol = 4;

implementation
uses
  uWPExtPack;

{$R *.dfm}

function TKBHMFrm.Showmodal:integer;
begin
  // ��������� ������
  Init;
  // ��������� �������
  InitSG;
  result:=inherited;
end;

procedure TKBHMFrm.loadgroup;
var
  f:tinifile;
  sections, keys:TStringList;
  g:cGroup;
  str, pname, gname, pVal:string;
  index:integer;
  I,j, tabpos: Integer;
  p:cPropertie;
begin
  ClearGroups;
  if not fileexists(startdir+'Opers\KBHM\KBHM.ini') then exit;
  f:=tinifile.Create(startdir+'Opers\KBHM\KBHM.ini');

  sections:=TStringList.Create;
  sections.Sorted:=true;
  keys:=TStringList.Create;
  keys.Sorted:=true;

  f.ReadSections(sections);
  str:='G0';
  i:=0;
  while sections.Find(str, index) do
  begin
    gname:=str;
    g:=cGroup.create;
    g.name:=f.ReadString(gname,'name', '');
    keys.Clear;
    f.ReadSection(gname,keys);
    pname:='p0';
    j:=0;
    while keys.Find(pname, index) do
    begin
      p:=cPropertie.Create;
      pVal:=f.ReadString(gname,pname, '');
      p.name:=GetSubStringExt(pval,';',1,'|',tabpos);
      p.units:=GetSubStringExt(pval,';',tabpos+1,'|',tabpos);
      g.addProp(p);
      inc(j);
      pname:='p'+inttostr(j);
    end;
    inc(i);
    str:='G'+inttostr(i);
    groups.AddObject(g.name,g);
  end;
  f.Destroy;
end;

procedure TKBHMFrm.savegroup;
begin

end;

procedure TKBHMFrm.Init;
begin
  if not ini then
  begin
    groups:=TStringList.Create;
    groups.Sorted:=true;
    ini:=true;
    loadgroup;
  end;
end;

procedure TKBHMFrm.InitSG;
begin
  propsg.FontSizes[0,0]:=12;
  propsg.FontSizes[1,0]:=12;
  propsg.FontSizes[2,0]:=12;
  propsg.FontSizes[3,0]:=12;
  propsg.FontSizes[4,0]:=12;
  propsg.FontSizes[3,1]:=12;
  propsg.FontSizes[4,1]:=12;


  propsg.SaveFixedCells := false;
  propsg.Cells[0,0]:='������';
  propsg.MergeCells(0, 0, 1, 2);
  propsg.Cells[1,0]:='����������� ���������';
  propsg.MergeCells(1,0,1,2);
  propsg.Cells[2,0]:='�����������';
  propsg.MergeCells(2,0,1,2);
  propsg.Cells[3,0]:='��������';
  propsg.MergeCells(3,0,2,1);
  propsg.Cells[3,1]:='�� ��';
  propsg.Cells[4,1]:='����.';

  propsg.ColWidths[0]:=60;
  propsg.ColWidths[1]:=60;

  //propsg.ColumnSize.Rows:=arAll;
  propsg.ColumnSize.Stretch:=true;
  // ��� �������� ������� ������� � ������� ������� ����������� ��� �������
  propsg.ColumnSize.StretchAll:=true;
  // ������������� ��������  ������ ����� �� ��� ������ ����������
  propsg.ColumnSize.SynchWithGrid:=true;
  // ���������� ��������� � �������
  ShowParams;
end;

function TKBHMFrm.getgroup(i:integer):cgroup;
begin
  result:=cgroup(groups.Objects[i]);
end;

procedure TKBHMFrm.ClearGroups;
var
  I: Integer;
  g:cgroup;
begin
  for I := 0 to groups.Count - 1 do
  begin
    g:=getgroup(i);
    g.destroy;
  end;
  groups.Clear;
end;

procedure TKBHMFrm.ShowParams;
var
  i,r,c,
  propind,
  // ��������� ������ ������ ������
  startrow,
  rowcount:integer;
  g:cGroup;
  p:cPropertie;
begin
  startrow:=0;
  rowcount:=c_KBHM_HeadSize;
  for I := 0 to groups.Count - 1 do
  begin
    g:=getgroup(i);
    rowcount:=rowcount+g.Count;
  end;
  propsg.RowCount:=rowcount;
  for I := 0 to groups.Count - 1 do
  begin
    g:=getgroup(i);
    r:=c_KBHM_HeadSize + startrow;
    c:=c_KBHM_GroupCol;
    propsg.MergeCells(c,r, 1,g.Count);
    propsg.Cells[c,r]:=g.name;

    for propind := 0 to g.Count - 1 do
    begin
      p:=g.GetProp(propind);
      // ���
      r:=c_KBHM_HeadSize + startrow+ propind;
      c:=c_KBHM_NameCol;
      propsg.Cells[c,r ]:=p.name;
      // �����
      r:=c_KBHM_HeadSize + startrow+ propind;
      c:=c_KBHM_UnCol;
      propsg.Cells[c,r]:=p.units;
    end;
    startrow:=startrow+g.Count;
  end;
end;

constructor cGroup.create;
begin
  Params:=TStringList.Create;
  Params.Sorted:=true;
end;

destructor cGroup.destroy;
var
  I: Integer;
  p:cPropertie;
begin
  for I := 0 to params.Count - 1 do
  begin
    p:=GetProp(i);
    p.Destroy;
  end;
  Params.Destroy;
end;

function cGroup.Count:integer;
begin
  result:=Params.Count;
end;

function cGroup.GetProp(i:integer):cPropertie;
begin
  result:=cPropertie(Params.Objects[i]);
end;

procedure cGroup.addProp(p:cPropertie);
begin
  Params.AddObject(p.name, p);
end;

end.
