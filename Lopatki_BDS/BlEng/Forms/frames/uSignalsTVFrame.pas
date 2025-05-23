unit uSignalsTVFrame;

interface

uses
  Windows, SysUtils, Classes, Forms,  ComCtrls, Controls, udrawobj,utrend,
  ubldeng, ueventlist, uchartevents, usavesignalform, uMeraSignal,
  uTrendSignal, uBaseBldAlg, umerafile, uTag, uUtsSensor, uTagSignal, uBasicTrend;

type
  TSignalsTVFrame = class(TFrame)
    SignalsTV: TTreeView;
    procedure SignalsTVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SignalsTVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private
    feng:cbldeng;
    list:tstringlist;
    events:ceventlist;
  private
    procedure doChangeName(sender:tobject);
    procedure renamekey(name:string;newname:string);
    function find(sender:tobject):integer;
    procedure addevents;
    procedure AddSignal(obj:cdrawobj; node:ttreenode);
  public
    procedure save;
    procedure GetEng(eng:cbldeng);
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

implementation

{$R *.dfm}

procedure TSignalsTVFrame.SignalsTVDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  srcNode, dstNode: TTreeNode;
  src:cdrawobj;
begin
  //if cchart1.TV.Selected = nil then Exit;
  dstNode := SignalsTV.GetNodeAt(X, Y);
  srcNode:=ttreeview(source).selected;
  src:=cdrawobj(srcNode.Data);
  if src<>nil then
  begin
    if (src is cbasictrend) then
    begin
      AddSignal(src, dstNode);
    end
  end;
end;

procedure TSignalsTVFrame.SignalsTVDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  srcNode, dstNode:TTreeNode;
  src:cdrawobj;
begin
  accept:=false;
  if sender=signalstv then
  begin
    srcNode:=ttreeview(source).Selected;
    src:=cdrawobj(srcNode.Data);
    //if (dstNode<>nil) and (srcNode<>nil) then
    if src<>nil then
    begin
      if src is cbasictrend then
      begin
        accept:=true;
        dstNode := signalsTV.GetNodeAt(X, Y);
        if dstNode<>nil then
        begin
          if dstNode.data<>nil then
            accept:=false;
        end;
      end;
    end;
  end;
end;

procedure TSignalsTVFrame.AddSignal(obj:cdrawobj; node:ttreenode);
var
  i:integer;
begin
  if node=nil then
  begin
    // ������� ����� ��������
    if SignalsTV.Items.Count=0 then
    begin
      node:=SignalsTV.Items.AddChildObject (nil,'�������',nil);
      node.ImageIndex:=18;
      node.SelectedIndex:=18;
      events:=cdrawobj(obj).events;
      addevents;
    end
    else
    // �������� ������ �� ����� ��������
      node:=SignalsTV.Items[0];
  end;
  // ��������� ����
  obj.blocked:=true;
  node:=SignalsTV.Items.AddChildObject (node, obj.name, obj);
  node.ImageIndex:=obj.imageindex;
  node.SelectedIndex:=obj.imageindex;
end;

procedure TSignalsTVFrame.GetEng(eng:cbldeng);
begin
  SignalsTV.Images:=eng.images_16;
  feng:=eng;
end;

procedure TSignalsTVFrame.renamekey(name:string;newname:string);
var
  i:integer;
  node,child:ttreenode;
begin
  if list.Find(name,i) then
  begin
    list.Delete(i);
    list.Add(newname);
    node:=SignalsTV.Items[0];
    for I := 0 to node.Count - 1 do
    begin
      child:=node.Item[i];
      if child.Text=name then
      begin
        child.Text:=newname;
      end;
    end;
  end;
end;

constructor TSignalsTVFrame.create(aowner:tcomponent);
begin
  inherited;
  list:=tstringlist.Create;
  events:=nil;
end;

destructor TSignalsTVFrame.destroy;
begin
  list.Destroy;
  inherited;
end;

procedure TSignalsTVFrame.addevents;
begin
  events.AddEvent('TSignalsTVFrame_ObjChangeName', e_OnChangeName, doChangeName);
end;

function TSignalsTVFrame.find(sender:tobject):integer;
var
  i:integer;
begin
  result:=-1;
  for  i := 0 to List.Count - 1 do
  begin
    if sender=list.Objects[i] then
    begin
      result:=i;
      exit;
    end;
  end;
end;

procedure TSignalsTVFrame.doChangeName(sender:tobject);
var
  oldname:string;
  i:integer;
begin
  i:=find(sender);
  if i<>-1 then
  begin
    oldname:=list.strings[i];
    renamekey(oldname, cdrawobj(sender).name);
  end;
end;

procedure TSignalsTVFrame.save;
var
  opts:cBaseOpts;
  fileopts:tmeraopts;
  merafile:cmerafile;
  UTSTag:c2dVectorTag;
  // ���
  uts:ctagsignal;
  folder:ttreenode;
  i:integer;
  trendSignal:cTrendSignal;
begin
  if SignalsTV.items.Count=0 then exit;
  folder:=SignalsTV.items[0];
  if folder=nil then
    exit;

  opts:=cBaseOpts.create;
  opts.eng:=feng;
  opts.testname:='Signals';
  SaveSignalsForm.ShowModal(opts);

  fileopts.TestName:=opts.testname;
  fileopts.TestDsc:=opts.dsc;
  fileopts.freq:=opts.SampleRate;

  list.Clear;
  // ������� ������ ��� ����������
  for i:=0 to folder.Count-1 do
  begin
    trendSignal:=cTrendSignal.create;
    trendSignal.obj:=tobject(folder.Item[i].Data);
    trendSignal.freqX:=opts.SampleRate;
    if opts.SampleRate<=0 then
    begin
      trendSignal.WriteXY:=true;
    end;
    trendSignal.b_3d:=opts.b_3D;
    trendSignal.dz:=opts.dz;
    //s.portionsize:=opts.portionsize;
    list.Addobject(cdrawobj(trendSignal.obj).name, trendSignal);
  end;
  UTSTag:=nil;
  if cUTSSensor(feng.uts)<>nil then
    UTSTag:=cUTSSensor(feng.uts).createtag;
  // ������� � ������ ���
  if UTSTag<>nil then
  begin
    uts:=cTagSignal.Create;
    uts.obj:=UTSTag;
    uts.k1:=1;
    uts.k0:=0;
    uts.WriteXY:=true;
    uts.yUnits:='���.';
    uts.xUnits:='���.';
  end
  else
    uts:=nil;
  merafile:=cmerafile.create(opts.path,opts.path, list, fileopts ,uts);
  merafile.save;
  merafile.DestroySignals;
  merafile.Destroy;
  opts.Destroy;
end;


end.
