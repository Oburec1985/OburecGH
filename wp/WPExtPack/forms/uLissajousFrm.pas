unit uLissajousFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, uBtnListView, StdCtrls, ImgList, ToolWin,
  uWPproc, uCommonMath, NativeXML, uComponentServises, uExcel, ulogfile,
  uSetList, inifiles, PathUtils, uTrigLvlEditFrm, uTmpltNameFrame,
  uSpin, DCL_MYOWN,
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
  public
    constructor create (p_x,p_y:cwpsignal);
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
    Edit1: TEdit;
    Label4: TLabel;
    Chart: cChart;
    SigLV: TBtnListView;
    pCount: TIntEdit;
    xminfe: TFloatSpinEdit;
    YminFe: TFloatSpinEdit;
    StartFe: TFloatEdit;
    Label5: TLabel;
    OkBtn: TButton;
    procedure FormShow(Sender: TObject);
    procedure XCbDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure YCbDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure OkBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    wp:cWPObjMng;
    sList:tlist;
  public
    procedure save;
    procedure load;
    function NewSig:TLisSig; overload;
    function NewSig(x,y:cwpsignal):TLisSig;overload;
    function GetSignal(i:integer):TLisSig;
    procedure showSignals();
    procedure LinkMng(mng: cWPObjMng);
  end;

var
  LissajousFrm: TLissajousFrm;

implementation
uses
  uWpExtPack;
{$R *.dfm}

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
  I, j, indX, indY: Integer;
begin
  t:=startfe.FloatNum;
  for I := 0 to sList.Count - 1 do
  begin
    sig:=TLisSig(sList.Items[i]);
    indX:=sig.x.Signal.IndexOf(t);
    indY:=sig.y.Signal.IndexOf(t);
    sig.m_count:=pCount.IntNum;
    for j := 0 to pCount.IntNum - 1 do
    begin
      sig.m_data[j].x:=sig.x.Signal.GetY(indx+j);
      sig.m_data[j].y:=sig.y.Signal.GetY(indy+j);
    end;
    sig.line.addpoints(sig.m_data, sig.m_count);
  end;
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
  count:=f.ReadInteger('main', 'sCount',0);
  pCount.IntNum:=f.ReadInteger('main', 'Portion',512);
  src:=wp.GetCurSrcInMainWnd;
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
    xcb.AddItem(sig.name, sig);
    ycb.AddItem(sig.name, sig);
    li:=SigLV.Items.Add;
    li.Data:=sig;
    SigLV.SetSubItemByColumnName('Сигнал',sig.name,li);
    SigLV.SetSubItemByColumnName('Fs',floattostr(sig.getFs),li);
  end;
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
end;

end.
