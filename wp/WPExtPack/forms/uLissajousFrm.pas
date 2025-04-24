unit uLissajousFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, uBtnListView, StdCtrls, ImgList, ToolWin,
  uWPproc, uCommonMath, NativeXML, uComponentServises, uExcel, ulogfile,
  uSetList, inifiles, PathUtils, uTrigLvlEditFrm, uTmpltNameFrame,
  uSpin, DCL_MYOWN, uGrahamScan,
  uCommonTypes, Winpos_ole_TLB,
  uChart, uWPServices, uBuffTrend2d, upage;


type
  TLisSig = class
  public
    name:string;
    x, y: cwpsignal;
    m_data:array of point2;
    m_count:integer;
    m_capacity:integer;
    line:cBuffTrend2d;
    grahem:pointsarray;
    p1,p2:point2; // диаметр
    Dtrend:cBuffTrend2d;
    dist:double;
  public
    constructor create (p_x,p_y:cwpsignal);
    destructor destroy();
  end;

  TLissajousFrm = class(TForm)
    RightGB: TGroupBox;
    pNumLabel: TLabel;
    XCb: TComboBox;
    YCb: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    F1Label: TLabel;
    Xmaxfe: TFloatSpinEdit;
    YmaxFe: TFloatSpinEdit;
    Label3: TLabel;
    Chart: cChart;
    SigLV: TBtnListView;
    pCount: TIntEdit;
    xminfe: TFloatSpinEdit;
    YminFe: TFloatSpinEdit;
    StartFe: TFloatEdit;
    Label5: TLabel;
    OkBtn: TButton;
    AutoCB: TCheckBox;
    Panel1: TPanel;
    Label4: TLabel;
    SearchEdit: TEdit;
    Label6: TLabel;
    IncFe: TFloatEdit;
    Timer1: TTimer;
    DistFe: TFloatEdit;
    Label7: TLabel;
    procedure FormShow(Sender: TObject);
    procedure XCbDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure YCbDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure OkBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SearchEditChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure YminFeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure YmaxFeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    wp:cWPObjMng;
    sList:tlist;
    m_updateZoom:boolean;
  public
    procedure ClearSignals;
    procedure UpdateChart;
    procedure save;
    procedure load;
    function NewSig:TLisSig; overload;
    function NewSig(x,y:cwpsignal):TLisSig;overload;
    function GetSignal(i:integer):TLisSig;
    procedure showSignals();
    procedure showSignalsLV();
    procedure LinkMng(mng: cWPObjMng);
  end;

var
  LissajousFrm: TLissajousFrm;

implementation
uses
  uWpExtPack;
{$R *.dfm}

procedure TLissajousFrm.ClearSignals;
var
  I: Integer;
  s:TLisSig;
begin
  for I := 0 to sList.Count - 1 do
  begin
    s:=GetSignal(i);
    s.Destroy;
  end;
  sList.Clear;
end;

procedure TLissajousFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  save;
end;

procedure TLissajousFrm.FormCreate(Sender: TObject);
begin
  sList:=TList.Create;
end;

procedure TLissajousFrm.FormDestroy(Sender: TObject);
begin
  sList.Destroy;
end;

procedure TLissajousFrm.FormShow(Sender: TObject);
begin
  showSignals;
  load;
end;

function TLissajousFrm.GetSignal(i: integer): TLisSig;
begin
  result:=TLisSig(slist.items[i]);
end;

procedure TLissajousFrm.LinkMng(mng: cWPObjMng);
begin
  wp := mng;

end;

function TLissajousFrm.NewSig: TLisSig;
begin
  result:=NewSig(cwpsignal(xcb.Items.Objects[xcb.ItemIndex]),
                         cwpsignal(ycb.Items.Objects[ycb.ItemIndex]));
end;

function TLissajousFrm.NewSig(x,y:cwpsignal):TLisSig;
begin
  result:=TLisSig.create(x, y);
  sList.Add(result);
end;

procedure TLissajousFrm.OkBtnClick(Sender: TObject);
var
  s:cSrc;
  sig: TLisSig;
  t:double;
  y,x:cwpsignal;
  I, j, c1, c2, indX, indY: Integer;
begin
  if autocb.Checked then
  begin
    if not Timer1.Enabled then
      Timer1.Enabled:=true;
  end
  else
    Timer1.Enabled:=false;
  t:=startfe.FloatNum;
  for I := 0 to sList.Count - 1 do
  begin
    sig:=TLisSig(sList.Items[i]);
    indX:=sig.x.Signal.IndexOf(t);
    indY:=sig.y.Signal.IndexOf(t);
    sig.m_count:=pCount.IntNum;
    for j := 0 to pCount.IntNum - 1 do
    begin
      c1:=indx+j;
      c2:=indx+j;
      if (c1>=sig.x.Signal.size-1) or (c2>=sig.y.Signal.size-1) then
      begin
        sig.line.addpoints(sig.m_data, j);
        Timer1.Enabled:=false;
        startfe.FloatNum:=0;
        AutoCB.Checked:=false;
        break;
      end;
      sig.m_data[j].x:=sig.x.Signal.GetY(c1);
      sig.m_data[j].y:=sig.y.Signal.GetY(c2);
    end;
    sig.line.addpoints(sig.m_data, sig.m_count);

    sig.grahem:=GrahamScan(pointsarray(@sig.m_data[0]), sig.m_count);
    FindDiameter(sig.grahem, sig.p1, sig.p2,sig.dist);
    sig.Dtrend.data[0]:=sig.p1;
    sig.Dtrend.data[1]:=sig.p2;

    distfe.FloatNum:=sig.dist;
    sig.Dtrend.needUpdateBound:=true;
    sig.Dtrend.needRecompile:=true;
  end;

  LissajousFrm.Chart.redraw;
  startfe.FloatNum:=startfe.FloatNum+IncFe.FloatNum;
end;

procedure TLissajousFrm.save;
var
  I: Integer;
  li:tlistitem;
  s:TLisSig;
  f:tinifile;
  id:string;
begin
  f:=tinifile.Create(startdir+'\Opers\Lissajous.ini');
  f.WriteInteger('main', 'sCount', slist.Count);
  f.WriteInteger('main', 'Portion', pCount.IntNum);
  for I := 0 to slist.Count - 1 do
  begin
    s:=GetSignal(i);
    id:='S_'+inttostr(i);
    f.WriteString(id,'Name',s.name);
    f.WriteString(id,'x',s.x.name);
    f.WriteString(id,'y',s.y.name);

  end;
end;

procedure TLissajousFrm.SearchEditChange(Sender: TObject);
begin
  showSignalsLV;
end;

procedure TLissajousFrm.load;
var
  I, count: Integer;
  s:TLisSig;
  src:cSrc;
  x,y:cWPSignal;
  f:tinifile;
  id,sname, sx, sy:string;
  fl:double;
begin
  f:=tinifile.Create(startdir+'\Opers\Lissajous.ini');
  //count:=f.ReadInteger('main', 'sCount',1);
  count:=1;
  pCount.IntNum:=f.ReadInteger('main', 'Portion',512);
  src:=wp.GetCurSrcInMainWnd;
  ClearSignals;
  for I := 0 to Count - 1 do
  begin
    id:='S_'+inttostr(i);
    sname:=f.ReadString(id,'Name','');
    sx:=f.ReadString(id,'x','');
    sy:=f.ReadString(id,'y','');
    x:=src.getSignalObj(sx);
    y:=src.getSignalObj(sy);
    if (x<>nil) and (y<>nil) then
    begin
      s:=NewSig(x, y);
      s.m_count:=pCount.IntNum;
      if i=0 then
      begin
        setComboBoxItem(x.name,xcb);
        setComboBoxItem(y.name,ycb);
      end;
    end;
  end;
end;

procedure TLissajousFrm.showSignalsLV();
var
  s:cSrc;
  sig: cWPSignal;
  i: integer;
  li:tlistitem;
begin
  s:=wp.GetCurSrcInMainWnd;
  SigLV.Clear;
  for I := 0 to s.ChildCount - 1 do
  begin
    sig:=s.getSignalObj(i);
    if (pos(lowercase(SearchEdit.text), lowercase(sig.name))>0) or (SearchEdit.text='') then
    begin
      li:=SigLV.Items.Add;
      li.Data:=sig;
      SigLV.SetSubItemByColumnName('Сигнал',sig.name,li);
      SigLV.SetSubItemByColumnName('Fs',floattostr(sig.getFs),li);
    end;
  end;
end;

procedure TLissajousFrm.Timer1Timer(Sender: TObject);
var
  r:frect;
begin
  if Timer1.Enabled then
  begin
    if m_updateZoom then
    begin
      m_updateZoom:=false;
      r.BottomLeft.x:=LissajousFrm.xminfe.Value;
      r.BottomLeft.y:=LissajousFrm.yminfe.Value;
      r.TopRight.x:=LissajousFrm.xmaxfe.Value;
      r.TopRight.y:=LissajousFrm.ymaxfe.Value;
      cpage(LissajousFrm.Chart.activepage).ZoomfRect(r);
      LissajousFrm.Chart.redraw;
    end;
  end;
  OkBtnClick(nil);
end;


procedure TLissajousFrm.showSignals;
var
  s:cSrc;
  sig: cWPSignal;
  i: integer;
  li:tlistitem;
begin
  s:=wp.GetCurSrcInMainWnd;
  SigLV.Clear;
  XCb.Clear;
  YCb.Clear;
  if s=nil then exit;
  for I := 0 to s.ChildCount - 1 do
  begin
    sig:=s.getSignalObj(i);
    XCb.AddItem(sig.name, sig);
    YCb.AddItem(sig.name, sig);
  end;
  showSignalsLV;
end;

procedure TLissajousFrm.XCbDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Source=SigLV then
    Accept:=true;
end;

procedure TLissajousFrm.YCbDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  s:TLisSig;
begin
  setComboBoxItem(cwpSignal(SigLV.Selected.Data).name,tcombobox(Sender));
  if Sender=XCb then
  begin
    xminfe.Value:=cwpSignal(SigLV.Selected.Data).Signal.MinY;
    xmaxfe.Value:=cwpSignal(SigLV.Selected.Data).Signal.MaxY;
  end;
  if Sender=YCb then
  begin
    Yminfe.Value:=cwpSignal(SigLV.Selected.Data).Signal.MinY;
    Ymaxfe.Value:=cwpSignal(SigLV.Selected.Data).Signal.MaxY;
  end;
  if sList.Count=0 then
  begin
    if (xCB.ItemIndex>-1) and (yCB.ItemIndex>-1) then
    begin
      NewSig;
    end;
  end
  else
  begin
    s:=GetSignal(0);
    s.x:=cwpSignal(xcb.Items.Objects[xcb.ItemIndex]);
    s.y:=cwpSignal(ycb.Items.Objects[ycb.ItemIndex]);
  end;
end;


procedure TLissajousFrm.UpdateChart;
var
  r:frect;
begin
  if not Timer1.Enabled then
  begin
    r.BottomLeft.x:=LissajousFrm.xminfe.Value;
    r.BottomLeft.y:=LissajousFrm.yminfe.Value;
    r.TopRight.x:=LissajousFrm.xmaxfe.Value;
    r.TopRight.y:=LissajousFrm.ymaxfe.Value;
    cpage(LissajousFrm.Chart.activepage).ZoomfRect(r);
    m_updateZoom:=false;
    LissajousFrm.Chart.redraw;
  end;
end;

procedure TLissajousFrm.YmaxFeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
  begin
    m_updateZoom:=true;
    if sender=Ymaxfe then
      Xmaxfe.Value:= Ymaxfe.Value
    else
      Ymaxfe.Value:=Xmaxfe.Value;
    UpdateChart;
  end;
end;

procedure TLissajousFrm.YminFeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
  begin
    m_updateZoom:=true;
    if sender=Yminfe then
      Xminfe.Value:= Yminfe.Value
    else
      Yminfe.Value:=Xminfe.Value;
    UpdateChart;
  end;
end;

{ TLisSig }

constructor TLisSig.create(p_x, p_y: cwpsignal);
var
  r:frect;
begin
  x:=p_x;
  y:=p_y;
  name:=x.name+'_'+y.name;
  line:=cBuffTrend2d.create;
  cpage(LissajousFrm.Chart.activepage).activeAxis.addchild(line);

  r.BottomLeft.x:=LissajousFrm.xminfe.Value;
  r.BottomLeft.y:=LissajousFrm.yminfe.Value;
  r.TopRight.x:=LissajousFrm.xmaxfe.Value;
  r.TopRight.y:=LissajousFrm.ymaxfe.Value;
  cpage(LissajousFrm.Chart.activepage).ZoomfRect(r);
  m_capacity:=16384;
  SetLength(m_data,m_capacity);
  Dtrend:=cBuffTrend2d.create;
  cpage(LissajousFrm.Chart.activepage).activeAxis.addchild(Dtrend);
  Dtrend.Count:=2;
  Dtrend.drawLines:=true;
  Dtrend.drawpoint:=true;
  Dtrend.visible:=true;
  Dtrend.color:=green;
end;

destructor TLisSig.destroy;
begin
  name:=x.name+'_'+y.name;
  Dtrend.destroy;
end;

end.
