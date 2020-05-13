unit uFFTInverseFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath,  Dialogs, StdCtrls, DCL_MYOWN, uExtFFTInverse, posbase, Winpos_ole_TLB,
  uBaseObjService,  VirtualTrees, uVTServices, ImgList, uWPOpers, uWPservices, uCommonTypes,
  uComponentservises,  ComCtrls, CommCtrl, uBtnListView, ExtCtrls;

type
  // возвращает - нужно ли продолжать перечисление
  wpenumProc = function(obj: iwpnode; data: pointer): boolean;

  tNodeData = class
  public
    inst: integer;
  public
    function isUSML: boolean;
    function isSignal: boolean;
    function signal: iwpsignal;
  end;

  TFFTInverseFrm = class(TForm)
    NumPointsCB: TComboBox;
    NumPointsLabel: TLabel;
    Label1: TLabel;
    nBlocksIE: TIntEdit;
    GroupBox1: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    dFfe: TFloatEdit;
    Label3: TLabel;
    ImageList16: TImageList;
    Panel1: TPanel;
    SigTV: TVTree;
    ChannelsLV: TBtnListView;
    FltEdit: TEdit;
    Label2: TLabel;
    procedure ApplyBtnClick(Sender: TObject);
    procedure SrcLVDragDrop(Sender, Source: TObject; X, Y: integer);
    procedure NumPointsCBDragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure ChannelsLVDragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure FltEditChange(Sender: TObject);
  public
    m_createThread: cardinal;
  private
    m_oper: TExtFFTInverse;
  private
    function CheckFlt(nd: tNodeData; HideParent: boolean): boolean;
    procedure cleartv;
    function GetNotifyStr(p_opts: string): string;
    procedure ShowSignalsInTV(tv: TVTree);
    function GetSignaRI(i:integer; p_type:string):iwpsignal;
    function GetSignalRe(i:integer):iwpsignal;
    function GetSignalIm(i:integer):iwpsignal;
  public
    procedure link(eo: TExtFFTInverse);
    function EditOper: string;
    function GetPropStr: string;
    Procedure SetPropStr(str: string);
  end;

var
  FFTInverseFrm: TFFTInverseFrm;

implementation

uses
  uWpExtPack;
{$R *.dfm}

{ TFFTInverseFrm }
function EnumGroupMembers(proc: wpenumProc; node: iwpnode; data: pointer;
  var continue: boolean): boolean;
var
  i: integer;
  obj: iwpnode;
  childNode: iwpnode;
begin
  result := true;
  if continue then
  begin
    continue := proc(node, data);
    if continue then
    begin
      for i := 0 to node.ChildCount - 1 do
      begin
        childNode := iwpnode(node.at(i));
        EnumGroupMembers(proc, childNode, data, continue);
        if not continue then
          exit;
      end;
    end;
  end;
end;

function GetParentNodeByIdisp(tv: TVTree; disp: idispatch): pvirtualnode;
var
  n: pvirtualnode;
  d: PNodeData;
  i: integer;
begin
  result := nil;
  for i := 0 to tv.TotalCount - 1 do
  begin
    if i <> 0 then
      n := tv.GetNext(n)
    else
      n := tv.GetFirst;
    d := tv.GetNodeData(n);
    if d <> nil then
    begin
      if tnodedata(d.data).inst = (disp as iwpnode).Instance then
      begin
        result := n;
        break;
      end;
    end;
  end;
end;

procedure AddUsmlNode(tv: TVTree; d: idispatch);
var
  n: pvirtualnode;
  inode: iwpnode;
  nd: PNodeData;
  m: iwpusml;
begin
  n := tv.AddChild(nil);
  nd := tv.GetNodeData(n);
  nd.Caption := (d as iwpnode).Name;
  nd.ImageIndex := 0;
  nd.color := tv.normalcolor;

  nd.data := tNodeData.Create;
  inode := TypeCastToIWNode(d);
  tNodeData(nd.data).inst := inode.Instance;
end;

procedure AddSignalNode(tv: TVTree; s: iwpnode);
var
  n: pvirtualnode;
  nd: PNodeData;
  parent: iwpnode;
  pnode: pvirtualnode;
begin
  parent := s.parent as iwpnode;
  pnode := GetParentNodeByIdisp(tv, parent);
  if pnode <> nil then
  begin
    n := tv.AddChild(pnode, nil);
    nd := tv.GetNodeData(n);
    nd.Caption := s.Name;
    nd.ImageIndex := 1;
    nd.color := tv.normalcolor;

    nd.data := tNodeData.Create;
    tNodeData(nd.data).inst := s.Instance;
  end;
end;

// wpenumProc = function(obj:iwpnode; data:pointer):boolean;
function enumReadSRC(obj: iwpnode; data: pointer): boolean;
begin
  result := true;
  // ЕСЛИ УЗЕЛ СОДЕРЖИТ УЗЛЫ СИГНАЛЫ
  if IsSrc(obj) or isUSML(obj) then
  begin
    AddUsmlNode(TVTree(data), obj);
  end;
  if isSignal(obj) then
  begin
    AddSignalNode(TVTree(data), obj);
  end;
end;

procedure TFFTInverseFrm.ShowSignalsInTV(tv: TVTree);
var
  node: iwpnode;
  b: boolean;
begin
  node := iwpnode((posbase.winpos.Get('/signals')));
  b := true;
  cleartv;
  EnumGroupMembers(enumReadSRC, node, tv, b);
end;

function TFFTInverseFrm.GetSignalIm(i: integer): iwpsignal;
begin
  result:=GetSignaRI(i, 'Im');
end;

function TFFTInverseFrm.GetSignalRe(i: integer): iwpsignal;
begin
  result:=GetSignaRI(i, 'Re');
end;

function TFFTInverseFrm.GetSignaRI(i: integer; p_type:string): iwpsignal;
var
  path, str:string;
  li:tlistitem;
  b:boolean;
  n:pvirtualnode;
  d:pnodedata;
begin
  result:=nil;
  b := false;
  // ПОЛУЧЕНИЕ КОРневого узла в дереве (замер)
  for i := 0 to SigTV.TotalCount - 1 do
  begin
    if i <> 0 then
      n := SigTV.GetNext(n)
    else
      n := SigTV.GetFirst;
    d := SigTV.GetNodeData(n);
    if d <> nil then
    begin
      if tNodeData(d.data).isUSML then
      begin
        b := true;
        break;
      end;
    end;
  end;
  if not b then
  begin
    n := nil;
    exit;
  end;
  li:=ChannelsLV.items[i];
  ChannelsLV.GetSubItemByColumnName(p_type, li, str);
  //'/Signals/signal0210_sub_0004.MERA'
  path := '/Signals/' + d.Caption + '/' + str;
  result := findSignal(path);
end;

procedure TFFTInverseFrm.ApplyBtnClick(Sender: TObject);
var
  i, start, stop: integer;
  param: olevariant;
  wstr: widestring;
  sRe, sIm: iwpsignal;
  iD: idispatch;
  str:string;
begin
  // Вызов обработки
  for i := 0 to ChannelsLV.items.count - 1 do
  begin
    sRe := GetSignalRe(i);
    if sre=nil then continue;
    sIm := GetSignalIm(i);
    if sIm=nil then continue;
    m_oper.Exec(sRe, sIm, iD, iD);
  end;
  BringToFront;
  // Сообщение в журнал что вызывали
  // 'o="/Operators/АвтоСпектр";p="kindFunc=5, numPoints=16384, nBlocks=1, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=1, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";s1_000="/Signals/6363.mera/NI6363-{PXI1Slot18-18- 1}";i1_000=0;c1_000=1000;d1_000="/Signals/Результаты/NI6363-{PXI1Slot18-18- 1}_Real#2";d2_000="/Signals/Результаты/NI6363-{PXI1Slot18-18- 1}_Image#2";dp1_000=3f8f260d;dp2_000=3f8fa48d;'
  str := GetNotifyStr(m_oper.GetPropStrF(wstr));
  param := str;
  // вызов уведомления
  TExtPack(extPack).NotifyPlugin($000F0001, param);
end;

procedure TFFTInverseFrm.SrcLVDragDrop(Sender, Source: TObject; X, Y: integer);
var
  screenLeftTopLV, P, p1: TPoint;
  li: tlistitem;
  liInd, i, w, colind: integer;

  s: iwpsignal;
  n: pvirtualnode;
  d: PNodeData;

  col: TListColumn;
  parent: twincontrol;
begin
  GetCursorPos(P);

  // получить итем под курсором
  p1 := TBtnListView(Sender).ScreenToClient(P);
  Y := P.Y;
  li := nil;
  if TListView(Sender).TopItem <> nil then
  begin
    li := TListView(Sender).GetItemAt(TListView(Sender).TopItem.Position.X,
      p1.Y);
    liInd := li.index;
  end;

  w := 0;
  colind := -1;
  parent := TBtnListView(Sender).parent;
  screenLeftTopLV := parent.ClientToScreen(point(TBtnListView(Sender).left,
      TBtnListView(Sender).top));
  for i := 0 to TBtnListView(Sender).Columns.count - 1 do
  begin
    col := TBtnListView(Sender).Columns[i];
    if (P.X - screenLeftTopLV.X) < w + col.width then
    begin
      colind := i;
      break;
    end
    else
    begin
      w := w + col.width;
    end;
  end;
  n := TVTree(Source).GetFirstSelected(true);
  liInd:=0;
  for i := 0 to TVTree(Source).SelectedCount - 1 do
  begin
    if i = 0 then
    begin
      if li = nil then
      begin
        li := TListView(Sender).items.Add;
      end
      else
      begin

      end;
      inc(liInd);
    end
    else
    begin
      if liInd < TListView(Sender).items.count then
      begin
        li := TListView(Sender).items[liInd];
      end
      else
      begin
        li := TListView(Sender).items.Add;
      end;
      inc(liInd);
    end;
    if i = 0 then
    begin

    end
    else
    begin
      n := TVTree(Source).GetNextSelected(n, true);
    end;
    d := TVTree(Source).GetNodeData(n);
    s := tNodeData(d.data).signal;
    li.data := tNodeData(d.data);
    case colind of
      0:
        begin
          TBtnListView(Sender).SetSubItemByColumnName('Re', s.sname, li);
          TBtnListView(Sender).SetSubItemByColumnName('FFTCount', inttostr(s.size), li);
        end;
      1:
        begin
          TBtnListView(Sender).SetSubItemByColumnName('Im', s.sname, li);
        end;
    end;
  end;
  lvchange(ChannelsLV);
end;

procedure TFFTInverseFrm.ChannelsLVDragOver(Sender, Source: TObject;
  X, Y: integer; State: TDragState; var Accept: boolean);
begin
  if Source = SigTV then
  begin
    Accept := true;
  end
  else
  begin
    Accept := false;
  end;
end;

procedure TFFTInverseFrm.cleartv;
var
  i: integer;
  n: pvirtualnode;
  d: PNodeData;
  nd: tNodeData;
  tv: TVTree;
begin
  tv := SigTV;
  if tv.TotalCount <> 0 then
  begin
    for i := 0 to tv.TotalCount - 1 do
    begin
      if i <> 0 then
        n := tv.GetNext(n)
      else
      begin
        n := tv.GetFirst;
      end;
      d := tv.GetNodeData(n);
      nd := tNodeData(d.data);
      nd.Destroy;
    end;
    tv.Clear;
  end;
  ChannelsLV.Clear;
end;

function TFFTInverseFrm.EditOper: string;
var
  res: integer;
  i: integer;
begin
  // переносим свойства в форму
  ShowSignalsInTV(SigTV);
  if GetCurrentThreadId <> m_createThread then
    exit;
  res := showmodal;
  if res = mrok then
  begin
    // переносим свойства в оператор
    m_oper.SetPropStr(GetPropStr);
    ApplyBtnClick(nil);
  end;
end;

// Рекурсивный обход дерева
procedure FindInTree(Tree: TVirtualStringTree; node: pvirtualnode;
  var Hide: boolean);
var
  childNode: pvirtualnode;
  str: string;
  d: PNodeData;
  nd: tNodeData;
  hideChild,
  // Если false то будет отображаться даже если все дочерние элементы спрятаны
  HideThisNode,
  // один из потомков видимый
  childVisible: boolean;
begin
  childVisible := false;
  d := Tree.GetNodeData(node);
  if Assigned(d) then
  begin
    nd := tNodeData(d.data);
    // Проверка на соответствие фильтру
    Hide := not FFTInverseFrm.CheckFlt(nd, Hide);
    HideThisNode := Hide;
    if (node.ChildCount > 0) then
    begin
      childNode := Tree.GetFirstChild(node);
      while childNode <> nil do
      begin
        hideChild := true;
        FindInTree(Tree, childNode, hideChild);
        if not hideChild then
        begin
          childVisible := true;
        end;
        childNode := childNode.NextSibling;
      end;
    end;
    if (not HideThisNode) or (childVisible) then
    begin
      node.States := node.States + [vsVisible];
      Hide := false;
    end
    else
    begin
      node.States := node.States - [vsVisible]
    end;
    // не корневые узлы и так перебираются
    if Tree.GetNodeLevel(node) = 0 then
    begin
      node := node.NextSibling;
      if node <> nil then
      begin
        FindInTree(Tree, node, Hide);
      end;
    end;
  end;
end;

procedure TFFTInverseFrm.FltEditChange(Sender: TObject);
var
  b: boolean;
begin
  b := true;
  FindInTree(SigTV, SigTV.GetFirstChild(nil), b);
  SigTV.Invalidate;
end;

function TFFTInverseFrm.CheckFlt(nd: tNodeData; HideParent: boolean): boolean;
var
  s: iwpsignal;
  str: string;
begin
  if FltEdit.text = '' then
  begin
    result := true;
    exit;
  end;
  result := false;
  s := nd.signal;
  if s <> nil then
  begin
    str := s.sname;
    result := pos(FltEdit.text, str) > 0;
  end
  else
  begin
    result := true;
  end;
end;

function TFFTInverseFrm.GetNotifyStr(p_opts: string): string;
var
  i: integer;
  str, numstr: string;
  s1,s2:iwpsignal;
  n:iwpnode;
begin
  // 'o="/Operators/АвтоСпектр";p="kindFunc=4, numPoints=16384, nBlocks=530, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=0, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";
  // s1_000="/Signals/signal0436.mera/3- 1";i1_000=0;c1_000=8694000;d1_000="/Signals/Результаты/signal0436.mera_СA/3- 1_СA";dp1_000=1e9a008d;
  // s1_001="/Signals/signal0436.mera/18- 1_Taho";i1_001=0;c1_001=8715600;d1_001="/Signals/Результаты/signal0436.mera_СA/18- 1_Taho_СA";
  // dp1_001=1e95690d;
  // s1_002="/Signals/signal0436.mera/18- 3_Stop";i1_002=0;c1_002=8715600;d1_002="/Signals/Результаты/signal0436.mera_СA/18- 3_Stop_СA";dp1_002=1e96a90d;s1_003="/Signals/signal0436.mera/18- 4_Start";i1_003=0;c1_003=8715600;d1_003="/Signals/Результаты/signal0436.mera_СA/18- 4_Start_СA";dp1_003=1e98248d;'

  // 'o="/Operators/ПоискЭкстремумов";
  // p="BandCount=1,bx_0=5,by_0=2000,L_pos_0=90,L_neg_0=10,N_pos_0=5,N_neg_0=5,N_Max_0=+,N_Neg_0=+,Units_0=%";
  // s1_001="3- 1_СA"i1_001=0;c1_001=2048;d1_001="3- 1_СA_AFlg" s2_002="18- 1_Taho_СA"i2_002=0;c2_002=2048;d2_002="3- 1_СA_AFlg"s3_003="18- 3_Stop_СA"i3_003=0;c3_003=2048;d3_003="18- 3_Stop_СA_AFlg"s4_004="18- 4_Start_СA"i4_004=0;c4_004=2048;d4_004="18- 4_Start_СA_AFlg"'
  result := 'o="/Расширения/' + 'FFTInverse' + '";p="' + p_opts + '";';
  for I := 0 to ChannelsLV.items.Count - 1 do
  begin
    s1:=GetSignalRe(i);
    s2:=GetSignalIm(i);
    numstr:=inttostr(i);
    str:=numstr;
    if length(str)<3 then
    begin
      while length(str)<>3 do
      begin
       str:='0'+str;
      end;
    end;
    // важно писать полный путь, т.к. по нему потом определяется источник
    // и соответствующий ID
    n:=findNode(s1);
    result:=result+'s1'+'_'+str+'="'+n.AbsolutePath+'";';
    n:=findNode(s2);
    result:=result+'s2'+'_'+str+'="'+n.AbsolutePath+'";';
    result:=result+
    'i1'+'_'+str+'='+'0'+';'
    +'c1'+'_'+str+'='+inttostr(s1.size)+';'
    +'d1'+'_'+str+'="'+'/Signals/results/'+ s1.sname+'_'+s2.sname+'fftInv';
  end;
end;

function TFFTInverseFrm.GetPropStr: string;
var
  pars: tstringlist;
  b: boolean;
  str: string;
begin
  pars := tstringlist.Create;
  addParam(pars, 'FFTCount', (NumPointsCB.text));
  addParam(pars, 'dX', dFfe.text);
  addParam(pars, 'BCount', nBlocksIE.text);
  result := ParsToStr(pars);
  delpars(pars);
  pars.Destroy;
end;



procedure TFFTInverseFrm.SetPropStr(str: string);
var
  s: iwpsignal;
  P: tstringlist;
begin
  P := ParsStrParamNoSort(str, ',');

  NumPointsCB.text := GetParsValue(P, 'FFTCount');
  nBlocksIE.text := GetParsValue(P, 'BCount');
  dFfe.text := GetParsValue(P, 'dX');

  P.Destroy;
end;

procedure TFFTInverseFrm.link(eo: TExtFFTInverse);
begin
  m_oper := eo;
end;

procedure TFFTInverseFrm.NumPointsCBDragOver(Sender, Source: TObject;
  X, Y: integer; State: TDragState; var Accept: boolean);
begin
  Accept := true;
end;

{ tNodeData }

function tNodeData.isSignal: boolean;
var
  n: iwpnode;
begin
  n := findNode(inst);
  if n <> nil then
  begin
    result := uWPservices.isSignal(n);
  end;
end;

function tNodeData.isUSML: boolean;
var
  n: iwpnode;
begin
  result := false;
  n := findNode(inst);
  if n <> nil then
  begin
    result := uWPservices.isUSML(n);
  end;
end;

function tNodeData.signal: iwpsignal;
var
  n: iwpnode;
begin
  n := findNode(inst);
  if n <> nil then
  begin
    result := TypeCastToIWSignal(n);
  end;
end;

end.
