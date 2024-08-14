unit uIRGraphFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, uBtnListView,
  Spin, uWPServices, PosBase, mathfunction,
  Winpos_ole_TLB, uComponentServises, Math, ucommonmath, uCommonTypes,
  PathUtils,
  DCL_MYOWN, IniFiles
  ;

type
  TNode = class
    name:string;
    n:iwpnode;
    s:iwpsignal;
  end;

  TIRGraphFrm = class(TForm)
    Splitter1: TSplitter;
    pCountBtn: TSpinButton;
    FFTpoints: TIntEdit;
    FFTCountLabel: TLabel;
    OffsetSE: TSpinEdit;
    OffsetLabel: TLabel;
    dFLabel: TLabel;
    LoadCfgCB: TComboBox;
    TahoLabel: TLabel;
    RightPanel: TPanel;
    SearchPanel: TPanel;
    SearchE: TEdit;
    SearchLabel: TLabel;
    SignalsLV: TBtnListView;
    BlockSizeLabel: TLabel;
    StepBox: TFloatEdit;
    Label2: TLabel;
    Label3: TLabel;
    blocksAmount: TSpinEdit;
    CheckBox1: TCheckBox;
    Button1: TButton;
    Label4: TLabel;
    t1FE: TFloatEdit;
    Label5: TLabel;
    t2FE: TFloatEdit;
    CheckBox2: TCheckBox;
    Label6: TLabel;
    WndCB: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure FFTdecrease(Sender: TObject);
    procedure FFTincrease(Sender: TObject);
    procedure SearchTextChanged(Sender: TObject);
    procedure OnBlocksChange(Sender: TObject);
    procedure OnStepChange(Sender: TObject);
    procedure GetFS(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure OffsetSEChange(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure saveConfig(Sender: TObject);
    procedure loadConfig(Sender: TObject);
    procedure LoadCfgCBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure LoadCfgCBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure updateLabelsOnFFTChange;
  private
    m_curSrcNode:iwpnode;
    m_T1T2:point2d;
    m_prev:point2d;
    // m_buf:array of point2d;
  private
    procedure GetRI(s_r: iwpsignal; s_i: iwpsignal;mainFrIndex : integer; var complex : point2d);
    procedure FindReIm(signal: IWPSignal; var re, im:iwpsignal);
    function GetMainFreq_(signal : IWPSignal) : integer;
    function findangle(signal: IWPSignal;freq : Double) : double;
    procedure FindReImPoints(signal: IWPSignal;freq : Double;fixangle : Double;index : integer);
    function GetFFTarg(kindFunc : integer; nBlocks : integer; ofsNextBlock : integer ) : olevariant;
    { Private declarations }
    procedure ShowWP;
    procedure ShowTahoBox;
  public
   { Public declarations }
   procedure ForceUpdate;

  end;

const
  c_wnd = 5;
  c_pi : Double = 3.141593;
var
  config : TextFile;
  g_graph, g_temp : IWPSignal;
  FFTpointsVal : integer = 512;
  offset : integer = 512;
  sync_FFT_offset : boolean = True;
  use_part_signal : boolean = True;
  fs : double = 0;
  BlockCount : integer = 1;
  step : double = 1.0;
  IRGraphFrm: TIRGraphFrm;

implementation
uses
  uOperPack;

{$R *.dfm}

procedure TIRGraphFrm.saveConfig(Sender: TObject); // save FFTpointsVal  sync_FFT_offset  use_part_signal  BlockCount
var
  ifile:TIniFile;
  i,i2 : integer;
  li : TListItem;
  tn:TNode;
begin
  ifile:=TIniFile.Create(g_startdir+ 'WpOperPlg.cfg');
  ifile.WriteInteger('Main','FFTNum',FFTpointsVal);
  ifile.WriteInteger('Main','BCount',BlockCount);
  ifile.WriteInteger('Main','offset',offset);
  ifile.WriteInteger('Main','wnd_index',WndCB.ItemIndex);
  ifile.WriteBool('Main','sync_FFT_offset',sync_FFT_offset);
  ifile.WriteBool('Main','use_part_signal',use_part_signal);

  ifile.WriteString('Signals','taho',LoadCfgCB.Text);

  i2:=0;
  for i := 0 to signalslv.GetCount - 1 do
  begin
    li:=SignalsLV.items[i];
    if li.Checked then
    begin
      tn:=li.data;
      ifile.WriteString('Signals',inttostr(i2),tn.name);
      i2:=i2+1;
    end;
  end;
  ifile.WriteInteger('Signals','len',i2);
  ifile.Destroy;

end;

procedure TIRGraphFrm.loadConfig(Sender: TObject);
var
  ifile:tinifile;
  buf,buf2 : string;
  len,i,j : integer;
begin
  buf:=g_startdir+'WpOperPlg.cfg';
  ifile:=TIniFile.Create(buf);
  FFTpointsVal:=ifile.ReadInteger('Main','FFTNum',FFTpointsVal);
  FFTpoints.Text := inttostr(FFTpointsVal);
  BlockCount:=ifile.ReadInteger('Main','BCount',BlockCount);
  blocksAmount.Text := inttostr(BlockCount);
  offset:=ifile.ReadInteger('Main','offset',offset);
  OffsetSE.text := inttostr(offset);
  WndCB.ItemIndex:= ifile.ReadInteger('Main','wnd_index',WndCB.ItemIndex);
  sync_FFT_offset:=ifile.ReadBool('Main','sync_FFT_offset',sync_FFT_offset);
  CheckBox1.Checked := sync_FFT_offset;
  use_part_signal:=ifile.ReadBool('Main','use_part_signal',use_part_signal);
  CheckBox2.Checked := use_part_signal;

  LoadCfgCB.Text:= ifile.ReadString('Signals','taho',LoadCfgCB.Text);
  len:= ifile.ReadInteger('Signals','len',0);
  for i := 0 to signalslv.GetCount - 1 do
  begin
    buf:=ifile.ReadString('Signals',inttostr(i),'');
    for j := 0 to signalslv.GetCount - 1 do
    begin
      SignalsLV.GetSubItemByColumnName('Имя',SignalsLV.items[j],buf2);
      if buf = buf2 then
      begin
        SignalsLV.items[j].Checked:=true;
      end;
    end;
  end;
  ifile.Destroy;
end;


procedure TIRGraphFrm.ForceUpdate;
begin
  OffsetSE.Text := inttostr(offset);
  ShowWP;
  ShowTahoBox;
  FFTpoints.Text := inttostr(FFTpointsVal);
end;

procedure TIRGraphFrm.FFTincrease(Sender: TObject);
begin
  FFTpointsVal :=  FFTpointsVal shl 1;
  FFTpoints.Text := inttostr(FFTpointsVal);
  OnBlocksChange(nil);
  if sync_FFT_offset then
  begin
    Offset := FFTpointsVal;
    OffsetSE.text := inttostr(offset);
  end;
  updateLabelsOnFFTChange;
end;

procedure TIRGraphFrm.CheckBox1Click(Sender: TObject);
begin
  sync_FFT_offset := CheckBox1.Checked;
  if sync_FFT_offset then
  begin
    Offset := FFTpointsVal;
    OffsetSE.text := inttostr(offset);
  end;
end;



procedure TIRGraphFrm.CheckBox2Click(Sender: TObject);
var
  lp2:point2d;
begin
  use_part_signal := CheckBox2.Checked;
  if CheckBox2.Checked then
  BEGIN
    t1FE.FloatNum:=m_T1T2.x;
    t2FE.FloatNum:=m_T1T2.y;
    CheckBox2.Caption:='Старт-Стоп: выбраный график';
  END
  else
  begin
    if m_curSrcNode<>nil then
    begin
      lp2:=GetStartStop(m_curSrcNode);
      t1FE.FloatNum:=lp2.x;
      t2FE.FloatNum:=lp2.y;
    end;
    CheckBox2.Caption:='Старт-Стоп: весь сигнал';
  end;
end;

procedure TIRGraphFrm.FFTdecrease(Sender: TObject);
begin
  FFTpointsVal :=  FFTpointsVal shr 1;
  if(FFTpointsVal=0) then FFTpointsVal := 1;
  FFTpoints.Text := inttostr(FFTpointsVal);
  OnBlocksChange(nil);
  if sync_FFT_offset then
  begin
    Offset := FFTpointsVal;
    OffsetSE.text := inttostr(offset);
  end;
  updateLabelsOnFFTChange;
end;

procedure TIRGraphFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  saveConfig(nil);
end;

procedure TIRGraphFrm.FormShow(Sender: TObject);
var
  p2:point2d;
  g:tgraphstruct;
begin
  g:=activeGraph;
  //p2:=GetGraphX(g.hgraph);
  p2:=GetActiveCursorX;
  m_T1T2:=P2;
  t1fe.FloatNum:=p2.x;
  t2fe.FloatNum:=p2.y;
  ForceUpdate;
  // загрузка
  loadConfig(nil);
end;

function TIRGraphFrm.GetFFTarg(kindFunc : integer; nBlocks : integer; ofsNextBlock : integer ) : olevariant;
begin
  result := 'type=0,kindFunc='+inttostr(kindFunc)+',method=0,numPoints='+inttostr(FFTpointsVal)+',typeWindow='+inttostr(WndCB.ItemIndex+1)+
  ',nBlocks='+inttostr(nBlocks)+',ofsNextBlock='+inttostr(ofsNextBlock)+',typeMagnitude=2,isMO=0,isFill0=1,fMaxVal=1';
end;

procedure TIRGraphFrm.FindReImPoints(signal: IWPSignal;freq : Double;fixangle : Double;index : integer);
var
  re,im,ampl,selfangle : Double;
  signal_re,signal_im : IWPSignal;
  arg,
  spectr_re,
  spectr_im,
  Err : OleVariant;
begin
  //str:='type=0,kindFunc=5,method=0,numPoints='+inttostr(FFTpointsVal)+
  //',nBlocks=1,ofsNextBlock=1,typeWindow=1,typeMagnitude=2,isMO=0,isFill0=1,fMaxVal=1';
  arg :=GetFFTarg(5,BlockCount,FFTpointsVal);;
  runFFT(signal, spectr_re, spectr_im,arg, Err);
  signal_re:=iwpsignal(TVarData(spectr_re).VPointer);
  signal_im:=iwpsignal(TVarData(spectr_im).VPointer);

  //wp.Link('/Signals/debug/real', 'real_spectr_part', signal_re);
  //wp.Link('/Signals/debug/imag', 'imag_spectr_part', signal_im);


  re := signal_re.GetY(round(freq/signal_re.getX(1)));
  im := signal_im.GetY(round(freq/signal_im.getX(1)));

  selfangle := ArcTan(im/re);
  ampl := power(im*im+re*re,0.5);
  im := ampl * Sin(selfangle-fixangle);
  re := ampl * Cos(selfangle-fixangle);

  g_graph.SetY(index,im);
  g_graph.setX(index,re);
end;

function TIRGraphFrm.findangle(signal: IWPSignal;freq : Double) : double;
var
  re,im, f : Double;
  signal_re,signal_im : IWPSignal;
  arg,
  spectr_re,
  spectr_im,
  Err : OleVariant;
  i : integer;
begin
  arg := GetFFTarg(5,BlockCount,FFTpointsVal);
  runFFT(signal, spectr_re, spectr_im,arg, Err);
  signal_re:=iwpsignal(TVarData(spectr_re).VPointer);
  signal_im:=iwpsignal(TVarData(spectr_im).VPointer);

  re := signal_re.GetY(round(freq/signal_re.getX(1)));
  im := signal_im.GetY(round(freq/signal_im.getX(1)));

  findangle := ArcTan(im/re);
end;


procedure TIRGraphFrm.GetFS(Sender: TObject; Item: TListItem;
  Selected: Boolean);
  var s:string;
begin
  //signalslv.GetSubItemByColumnName('Fs', Item,s);
  //fs := strtoIntExt(s);
end;


procedure TIRGraphFrm.LoadCfgCBDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  li:TListItem;
  s:string;
begin
  li:=SignalsLV.Selected;
  s:=li.Caption;
  SignalsLV.GetSubItemByColumnName('Имя',li,s);
  setComboBoxItem(s,LoadCfgCB);
end;

procedure TIRGraphFrm.LoadCfgCBDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Source=SignalsLV then
  begin
    Accept:=true;
  end;
end;

procedure TIRGraphFrm.GetRI(s_r: iwpsignal; s_i: iwpsignal;mainFrIndex : integer; var complex : point2d);
begin
  complex.x := s_r.GetY(mainFrIndex);
  complex.y := s_i.GetY(mainFrIndex);
end;

procedure TIRGraphFrm.FindReIm(signal: IWPSignal; var re, im:iwpsignal);
var
  arg,
  spectr_re,
  spectr_im,
  Err : OleVariant;

begin
  arg := GetFFTarg(5,BlockCount,FFTpointsVal);
  runFFT(signal, spectr_re, spectr_im,arg, Err);
  re:=iwpsignal(TVarData(spectr_re).VPointer);
  im:=iwpsignal(TVarData(spectr_im).VPointer);
end;

function TIRGraphFrm.GetMainFreq_(signal : IWPSignal) : integer;
var
  maxfreq : Double;
  arg,
  spectr,
  spectr2,
  Err : OleVariant;
  r1:iwpsignal;
  pars:tstringlist;
  i, imax: Integer;
  max: Double;
begin
  arg := GetFFTarg(1,BlockCount,FFTpointsVal);
  runFFT(signal, spectr, spectr2,arg, Err);
  r1:=iwpsignal(TVarData(spectr).VPointer);
  //wp.Link('/Signals/debug/taho', 'taho_spectr_part', r1);
  // wp.Refresh();
  imax:=-1;
  max := -99999.0;
  for i := 0 to r1.size - 1 do
  begin
    if r1.GetY(i)>max then
    begin
      imax:=i;
      max := r1.GetY(i);
    end;
  end;
  result:=imax;
end;

function getMod(p:point2d):double;
begin
  result:=sqrt(p.x*p.x+p.y*p.y);
end;

function getCos(p1,p2:point2d):double;
begin
  result:=(p1.x*p2.x+p1.y*p2.y)/(getmod(p1)*getmod(p2));
end;

function getSin(p1,p2:point2d):double;
begin
  result:=(p1.x*p2.y-p1.y*p2.x)/(getmod(p1)*getmod(p2));
end;

procedure TIRGraphFrm.Button1Click(Sender: TObject);
var
  li,li2:TListItem;
  tn,tn2:TNode;
  n:iwpnode;
  signal,taho:iwpsignal;
  tahoBlock, signalBlock : IWPSignal;
  SignalName : string;
  // косинус и угол между Taho и сигналом
  lcos, lsin_inv, lalfa, deg_cos, deg_sin,
  // амплитуда сигнала
  lAmp:double;
  j,t, index, i,i2, mainFrIndex : Cardinal;
  Taho_r, Taho_i,  Sig_r, Sig_i:iwpsignal;
  taho_ri, Sig_ri, lOut:point2d;
begin
  // поиск тахо
  //tn2:=LoadCfgCb.Items.Objects[LoadCfgCb.ItemIndex];
  for j := 0 to signalslv.GetCount - 1 do
  begin
    li2:=SignalsLV.items[j];
    SignalsLV.GetSubItemByColumnName('Имя',li2,SignalName);
    if SignalName = LoadCfgCB.Text then
    begin
      tn2:=tnode(li2.Data);
      break;
    end;
  end;

  for j := 0 to signalsLV.items.Count - 1 do
  begin
    li:=signalsLV.items[j];
    if li.Checked then
    begin
      tn:=tnode(li.Data);
      signal := tn.s;
      taho := tn2.s;
      if use_part_signal then
      begin
        i:=taho.IndexOf(t1fe.FloatNum);
        i2:=taho.IndexOf(t2fe.FloatNum);
        taho := wp.GetInterval(taho,i, i2-i) as iwpsignal;
        i:=signal.IndexOf(t1fe.FloatNum);
        i2:=signal.IndexOf(t2fe.FloatNum);
        signal := wp.GetInterval(signal,i, i2-i) as iwpsignal;
      end;
      // цикл по длине сигнала
      g_graph := wp.CreateSignalXY(VT_R8, VT_R8) as IWPSignal;
      g_graph.size := trunc(signal.size/offset);

      g_temp := wp.CreateSignal(VT_R8) as IWPSignal;
      g_temp.size := trunc(signal.size/offset);
      g_temp.DeltaX:=offset*signal.DeltaX;

      //setlength(m_buf, g_temp.size+1);

      t:=0;
      index := 0;
      m_prev.x:=0;
      m_prev.y:=0;
      while t<(signal.size-FFTpointsVal*BlockCount) do
      begin
      tahoBlock := wp.GetInterval(taho, t, FFTpointsVal*BlockCount) as iwpsignal;
      signalBlock := wp.GetInterval(signal, t, FFTpointsVal*BlockCount) as iwpsignal;
      // Поиск RI тахо
      FindReIm(tahoBlock,Taho_r,Taho_i);
      // Поиск RI сигнала
      FindReIm(signalBlock,Sig_r,Sig_i);

      // поиск spm Taho
      // поиск главной частоты
      mainFrIndex := GetMainFreq_(tahoBlock);
      // заполнение RI структур для Taho и Сигнала
      taho_ri.x:=taho_r.GetY(mainFrIndex);
      taho_ri.y:=taho_i.GetY(mainFrIndex);
      Sig_ri.x:=Sig_r.GetY(mainFrIndex);
      Sig_ri.y:=sig_i.GetY(mainFrIndex);
      // Cos угла           00
      lcos:=getCos(taho_ri, Sig_ri);
      deg_sin:=getSin(taho_ri, Sig_ri);
      deg_sin:=arcsin(deg_sin)*180/c_pi;
      if lcos=1 then
        lalfa:=0
      else
        lalfa:=arccos(lcos);
      deg_cos:=lalfa*180/c_pi;

      // Синтез RI для результирующего сигнала
      lAmp:=getMod(Sig_ri);
      if index<>0 then
      begin
        //  если вектора имеют около нулевой сдвиг
        if deg_cos-deg_sin<0.01 then
        begin
        end
        else
        begin
          if abs(deg_cos+deg_sin-180)<0.01 then
          begin
          end
          else // если разница векторов около 180'
          begin
            lalfa:=2*c_pi-lalfa;
          end;
        end;
      end;
      lOut.x:=lAmp*lcos;
      lOut.y:=lAmp*sin(lalfa);
      g_temp.SetY(index,deg_cos);
      // setLineCloud
      g_graph.SetY(index,lOut.x);
      g_graph.setX(index,lOut.y);

      t := t + offset;
      index := index +1;
      m_prev:=lout;
    end;
    wp.Link('/Signals/result', signal.sname+'_ir', g_graph);
    wp.Link('/Signals/result', signal.sname+'_alpha', g_temp);
    wp.Refresh();
    end;
  end;
  //li:=signalslv.Selected;
  //tn:=tnode(li.Data);

end;


procedure TIRGraphFrm.OffsetSEChange(Sender: TObject);
var proc:TNotifyEvent;
begin
  if sync_FFT_offset then
  begin
    Offset := FFTpointsVal;
    OffsetSE.text := inttostr(offset);
  end;
  if (OffsetSE.Text<>'') and (not sync_FFT_offset) then
  offset := strtoint(OffsetSE.Text);
end;

procedure TIRGraphFrm.OnBlocksChange(Sender: TObject);
var
  proc,proc2:TNotifyEvent;
begin
  if (blocksAmount.Text<>'') and (fs<>0) then
  begin
    BlockCount := strtoint(blocksAmount.Text);
    if BlockCount < 1 then
    begin
      BlockCount := 1;
    end;
    step := (BlockCount*FFTpointsVal)/fs; // шаг от блоков
    proc:=BlocksAmount.OnChange;
    proc2 := StepBox.OnChange;
    BlocksAmount.OnChange:=nil;
    StepBox.OnChange:=nil;
    blocksAmount.Text := inttostr(BlockCount);
    StepBox.Text := floattostr(step);
    BlocksAmount.OnChange:=proc;
    StepBox.OnChange:=proc2;
  end;
end;

procedure TIRGraphFrm.OnStepChange(Sender: TObject);
var
  proc:TNotifyEvent;
begin
  if (StepBox.Text<>'') and (fs<>0) then
  begin
    step := strtofloatext(StepBox.Text);
    BlockCount := ceil((step*fs) / FFTpointsVal);

    proc:=BlocksAmount.OnChange;
    BlocksAmount.OnChange:=nil;
    BlocksAmount.Text := inttostr(BlockCount);
    BlocksAmount.OnChange:=proc;
  end;
end;



procedure TIRGraphFrm.SearchTextChanged(Sender: TObject);
begin
  ShowWP;
end;

procedure TIRGraphFrm.ShowWP;
var
  d:IDispatch;
  o:tobject;
  n:iwpnode;
  tn:TNode;
  child:idispatch;
  I: Integer;
  li:tlistitem;
begin
  d := posbase.WINPOS.GetSelectedNode;
  //showmessage('d1 '+inttostr(posbase.WINPOS.GetObjectType(d)));
  for I := 0 to signalslv.GetCount - 1 do
  begin
    li:=SignalsLV.items[i];
    tnode(li.data).Destroy;
  end;
  SignalsLV.clear;
  m_curSrcNode:=nil;
  n:=getsrcBySignal(d);
  if n=nil then
  begin
    if d<>nil then
    begin
      n:=TypeCastToIWNode(d);
      m_curSrcNode:=n;
    end
  end;
  if m_curSrcNode=nil then
    exit;
  if Supports(n, DIID_IWPNode) then
  begin
    for I := 0 to n.ChildCount - 1 do
    begin
      child:=n.At(i);
      if IsSignal(child) then
      begin
        tn:=tnode.Create;
        tn.n:=TypeCastToIWNode(child);
        tn.s:=TypeCastToIWSignal(child);
        tn.name:=tn.s.sname;
        if ((Pos(Trim(AnsiLowerCase(SearchE.Text)),Trim(AnsiLowerCase(tn.s.sname)))<>0) or (SearchE.Text = '')) then
        begin
          li:=signalslv.items.add();
          li.Data:=tn;
          signalslv.SetSubItemByColumnName('№', inttostr(li.Index), li);
          signalslv.SetSubItemByColumnName('Имя', tn.s.sname, li);
          signalslv.SetSubItemByColumnName('Fs', formatstrnoe(1/tn.s.DeltaX, 4), li);
        end;
      end;
      LVChange(signalslv);
    end;
  end;
end;




procedure TIRGraphFrm.updateLabelsOnFFTChange;
var
  I: Integer;
  li:tlistitem;
  n:tnode;
  s:iwpsignal;
  fs:Double;
begin
  s:=nil;
  for I := 0 to signalsLV.items.Count - 1 do
  begin
    li:=signalsLV.items[i];
    if li.Checked then
    begin
      n:=tnode(li.data);
      s:=n.s;
      break;
    end;
  end;
  if s<>nil then
  begin
    fs:=1/s.DeltaX;
    BlockSizeLabel.Caption:='Размер блока, сек '+formatstrNoE(s.DeltaX*FFTpoints.IntNum, 4);
    dFlabel.Caption:='dF, Hz '+formatstrNoE(fs/FFTpoints.IntNum, 4);
  end;
end;

procedure TIRGraphFrm.ShowTahoBox;
var
  d:IDispatch;
  o:tobject;
  n:iwpnode;
  tn:TNode;
  child:idispatch;
  I: Integer;
begin
  d := posbase.WINPOS.GetSelectedNode;

  //showmessage('d1 '+inttostr(posbase.WINPOS.GetObjectType(d)));
  for I := 0 to LoadCfgCB.GetCount - 1 do
  LoadCfgCB.clear;
  n:=getsrcBySignal(d);
  if n=nil then
    n:=TypeCastToIWNode(d);


  if Supports(n, DIID_IWPNode) then
  begin
    for I := 0 to n.ChildCount - 1 do
    begin
      child:=n.At(i);
      if IsSignal(child) then
      begin
        tn:=tnode.Create;
        //tn.n:=TypeCastToIWNode(child);
        tn.s:=TypeCastToIWSignal(child);
        //tn.name:=tn.s.sname;
        if ((Pos(Trim(AnsiLowerCase(SearchE.Text)),Trim(AnsiLowerCase(tn.s.sname)))<>0) or (SearchE.Text = '')) then
        begin
          LoadCfgCB.items.add(tn.s.sname);
        end;
        tn.Destroy;
      end;
    end;
  end;
end;


end.
