// хранить ссылки на объекты запрещаетс€!! только на узлы iwpNode, т.к.
// адреса объектов мен€ютс€ в процессе работы WP
unit uNIIPMTenzopluginForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, inifiles,
  Dialogs, StdCtrls, ComCtrls, ToolWin, ExtCtrls, uBtnListView, ImgList,
  DCL_MYOWN,
  Winpos_ole_TLB, POSBase, ucommontypes, u2dMath,
  uBaseObjService, uComponentServises, uCommonMath, uChart,
  uBuffTrend1d, uaxis, upage, uEventList, uChartEvents, udoublecursor,
  uFloatLabel, uLabel, MathFunction;

type
  cID = class
  public
    str:string;
    node:wpnode;
  end;

  cPairID = class
    // сигнал по y
    id1,
    // сигнал по y
    id2:cid;
  end;


  TNIIPMForm = class(TForm)
    ActionGB: TGroupBox;
    SignalsGB: TGroupBox;
    SignalsControlPanel: TPanel;
    Splitter1: TSplitter;
    FileLabel: TLabel;
    FileCB: TComboBox;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ImageList_16: TImageList;
    AlgGB: TGroupBox;
    Splitter2: TSplitter;
    ToolButton3: TToolButton;
    CancelBtn: TButton;
    XSignalGB: TGroupBox;
    XSignalLV: TBtnListView;
    ProcSignalsGB: TGroupBox;
    SignalsLV: TBtnListView;
    YLabel: TLabel;
    YFE: TFloatEdit;
    Y0FE: TFloatEdit;
    Y0Label: TLabel;
    YMaxFE: TFloatEdit;
    YMaxLabel: TLabel;
    CSVGB: TGroupBox;
    EvalMinMaxBtn: TButton;
    SelectSignalEdit: TEdit;
    SelectSignalLabel: TLabel;
    FolderPath: TEdit;
    FolderLabel: TLabel;
    SeparatorEdit: TEdit;
    SeparatorName: TLabel;
    SaveCSVCB: TCheckBox;
    CSVNameEdit: TEdit;
    CSVNameLabel: TLabel;
    OkBtn: TButton;
    Splitter3: TSplitter;
    ChartGB: TGroupBox;
    cChart1: cChart;
    Splitter4: TSplitter;
    ImageList_32: TImageList;
    ImageList1: TImageList;
    ScaleTFE: TFloatEdit;
    v: TLabel;
    procedure ToolButton1Click(Sender: TObject);
    procedure SignalsLVClick(Sender: TObject);
    procedure EvalMinMaxBtnClick(Sender: TObject);
    procedure SignalsLVDblClickProcess(item: TListItem; lv: TListView);
    procedure cChart1Init(Sender: TObject);
    procedure cChart1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    ifile:tinifile;
    // ≈сли True по оси X откладываетс€ dt а по оси Y - Y, иначе наоборот
    mainDT:boolean;
    resDir:string;
    trend1,trend2:cBuffTrend1d;
    curs:cdoublecursor;
    axis:caxis;
    // показывает dx между двум€ сигналами
    FLabel:cFloatLabel;
    // флаг разрешающий обновить графику
    UpdateTrendPos, UpdateCursorPos:boolean;

    start,finish:point2d;
    StartEdit, EndEdit:cLabel;
  private
    // добавить строку в ListView сигнал; им€ замера
    procedure Addstring(signal:iwpsignal; fname: string; path:string);
    procedure clearlv;
    procedure InitLV;
    procedure save;
    procedure load;
    // сохранение в csv файл
    procedure SaveCSV;
    // вз€ть сигнал по имени узла
    function getSignal(id:cID):iwpsignal;
    function findX(y:double; s:iwpsignal):double;overload;
    function findX(y:double; s:iwpsignal;from:integer;var index:integer):double;overload;
    // выполнить обработку
    procedure process(pair:cpairid);
    // тобразить замеры в таблицах
    procedure ShowFiles;
    function getSelected:iwpsignal;
    procedure ShowSignal(s:iwpsignal; tr:cBuffTrend1d);
    // событие происходит при движении курсора
    procedure OnMoveCursor(sender:tobject);
    procedure onMoveCursor2(sender:tobject);
    procedure createEvents;
  public
    function showmodal:integer;override;
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
  end;

procedure initstrings;

function TypeCastToIWPUSML(d:idispatch):iwpusml;
function TypeCastToIWNode(d:idispatch):iwpNode;
function TypeCastToIWSignal(d:idispatch):iwpSignal;


var
  NIIPMForm: TNIIPMForm;
  v_colSignal,
  v_colXSignal,
  v_ColFile:string;


implementation

{$R *.dfm}
uses
  uwpextpack;

procedure TNIIPMForm.SaveCSV;
var
  s:iwpsignal;

  TextFile:tstringlist;

  path,
  // строка в отчет
  str:string;

  node:iwpnode;

  D:DOUBLE;
  I, numstr, endsignalscounter: Integer;

  endFile:boolean;
begin
  if not DirectoryExists(FolderPath.Text) then
  begin
    ForceDirectories(FolderPath.Text);
  end;
  path:=FolderPath.Text+CSVNameEdit.Text+'.csv';
  textfile:=tstringlist.create;
  node:=iwpnode(Winpos.Get(resDir));
  endFile:=false;
  str:='';
  // пишем шапку
  for I := 0 to node.ChildCount - 1 do
  begin
    s:=iwpnode(node.at(0)).reference as iwpsignal;
    str:=str+s.SName+';'+';';
  end;
  textfile.Add(str);
  str:='';
  // пишем значени€
  numstr:=0;
  endsignalscounter:=0;
  while not endFile do
  begin
    for I := 0 to node.ChildCount - 1 do
    begin
      s:=iwpnode(node.at(i)).reference as iwpsignal;
      if s.size>=numstr then
      begin
        D:=s.GetY(numstr);
        str:=str+floattostr(s.GetX(numstr))+';'+floattostr(d)+';';
      end
      else
      begin
        inc(endsignalscounter);
        str:=str+';;';
      end;
    end;
    textfile.Add(str);
    str:='';
    inc(numstr);
    if endsignalscounter=node.ChildCount then
    begin
      endFile:=true;
      break;
    end
    else
      endsignalscounter:=0;
  end;
  if FileExists(path) then
  begin
    if RenameFile(path,path) then
    // файл не зан€т
    begin

    end
    else
    begin
      str:=modname(CSVNameEdit.Text, false);
      // файл зан€т
      path:=FolderPath.Text+str+'.csv';
      if fileexists(path) then
      begin
        while not (RenameFile(path,path)) do
        begin
          str:=modname(str,false);
          // файл зан€т
          path:=FolderPath.Text+str+'.csv';
          if not fileexists(path) then
            break;
        end;
      end;
    end;
  end;
  textfile.SaveToFile(path);
  textfile.Destroy;
end;

function TNIIPMForm.findX(y:double; s:iwpsignal;from:integer;var index:integer):double;
var
  I: Integer;
  ly, ly1:double;
begin
  result:=0;
  for I := from to s.size do
  begin
    // получаем текущее значение
    ly:=s.GetY(i);
    if ly>=y then
    begin
      if i>0 then
      begin
        ly1:=s.GetY(i-1);
        if ly1<y then
        begin
          index:=i-1;
          result:=EvalLineX(y,p2d(s.GetX(i-1),ly1),p2d(s.GetX(i),ly));
          exit;
        end;
      end
      else
      // если первый отсчет
      begin
        index:=0;
        result:=s.GetX(0);
        exit;
      end;
    end;
  end;
end;

function TNIIPMForm.findX(y:double; s:iwpsignal):double;
var
  I: Integer;
begin
  result:=findX(y,s,0,i);
end;

procedure TNIIPMForm.process(pair:cpairid);
var
  I, i_xMax: Integer;
  s1,s2:iwpsignal;
  d_xMax,y, x1, x2, dx0, dx:double;
  resSignal:iWPsignal;
  index1,index2:integer;
begin
  if pair.id2=nil then
    exit;
  s1:=getsignal(pair.id1);
  // сигнал по X
  s2:=getsignal(pair.id2);
  // создаем сигнал
  resSignal:=winpos.CreateSignalXY(VT_R8,VT_R8) as IWPSignal;
  if Assigned(resSignal) then
  begin
    resSignal.sName:=s1.SName+'_'+s2.SName;
    // помещаем сигнал в дерево
    resDir:='/Signals/–езультаты';
    winpos.Link(resDir, resSignal.sName, resSignal as IDispatch);
    winpos.Refresh;
    // зададим длину сигнала
    resSignal.size:= round(ABS((YMaxFE.FloatNum-Y0FE.FloatNum))/YFE.FloatNum);
    if resSignal.size=0 then
      exit;
    resSignal.StartX:= 0;
    resSignal.DeltaX:= YFE.FloatNum;
    resSignal.NameY:= s1.NameY;
    resSignal.NameX:= s1.NameY;
    resSignal.k1:= 1;
    resSignal.k0:= 0;
  end;
  x1:=findX(y0fe.FloatNum,s1,0,index1);
  x2:=findX(y0fe.FloatNum,s2,0,index2);
  dx0:=x1-x2;
  // задаем первую начальную точку
  if mainDT then
  begin
    ressignal.SetX(0,0);
    ressignal.SetY(0,y0fe.FloatNum);
  end
  else
  begin
    ressignal.SetY(0,0);
    ressignal.SetX(0,y0fe.FloatNum);
  end;
  y:=y0fe.FloatNum+yfe.FloatNum;
  // добавл€ем точки в сигнал
  i:=1;
  // начинаем поиск максимума в сигнале 2 начина€ с индекса на котором Y0
  d_xMax:=findX(s1.MaxY,s1,index1,i_xMax);
  while i<=ressignal.size do
  begin
    if y>=s1.MaxY then
    begin
      y:=s1.MaxY;
      ressignal.size:=i;
      x1:=d_xMax;
    end
    else
    begin
      // сигнал по y
      x1:=findX(y,s1,index1,index1);
    end;
    // сигнал по x
    x2:=findX(y,s2,index2,index2);
    dx:=x1-x2-dx0;
    dx:=dx*ScaleTFE.FloatNum;
    if mainDT then
    begin
      ressignal.SetX(i,dx);
      ressignal.SetY(i,y);
    end
    else
    begin
      ressignal.SetY(i,dx);
      ressignal.SetX(i,y);
    end;
    inc(i);
    y:=y+yfe.FloatNum;
  end;
end;

function TNIIPMForm.showmodal:integer;
var
  I: Integer;
begin
  // отображаем замеры в таблицах
  ShowFiles;
  result:=inherited ShowModal;
  if result=mrok then
  begin
    for I := 0 to SignalsLV.items.Count - 1 do
    begin
      // обрабатываем строчки таблицы
      process(cpairid(SignalsLV.items[i].data));
    end;
    if SaveCSVCB.Checked then
    begin
      SaveCSV;
    end;
  end;
end;

procedure TNIIPMForm.SignalsLVClick(Sender: TObject);
var P,p1:TPoint;
    y:integer;
    s:iwpsignal;
begin
  GetCursorPos(P);
  P1:=TBtnListView(sender).ScreenToClient(P);
  windows.ScreenToClient(TBtnListView(sender).Handle,P);
  y:=p.y;
  s:=getSelected;
  SelectSignalEdit.Text:=s.sname;
end;

procedure TNIIPMForm.SignalsLVDblClickProcess(item: TListItem; lv: TListView);
var
  s:iwpsignal;
begin
  s:=getSignal(cpairid(item.data).id1);
  if s<>nil then
  begin
    trend1.clear;
    ShowSignal(s, trend1);
    trend2.clear;
    if cpairid(item.data).id2<>nil then
    begin
      s:=getSignal(cpairid(item.data).id2);
      if s<>nil then
      begin
        ShowSignal(s, trend2);
      end
      else
        Flabel.visible:=false;
    end;
    cpage(cchart1.activePage).Normalise;
  end;
end;

function TNIIPMForm.getSelected:iwpsignal;
var
  li:tlistitem;
begin
  li:=SignalsLV.Selected;
  if li<>nil then
    result:=getSignal(cpairid(li.data).id1)
  else
    result:=nil;
end;

procedure TNIIPMForm.ToolButton1Click(Sender: TObject);
var
  xLi,li:tlistitem;
  i:integer;
  s:wpsignal;
begin
  xLi:=XSignalLV.Selected;
  if xLi=nil then
  begin
    showmessage('Ќеобходимо выбрать сигнал в списке "—игнал по X"');
    exit;
  end;
  if SignalsLV.SelCount=0 then
  begin
    showmessage('Ќеобходимо выбрать сигналы которым будет сопоставлен сигнал по X');
    exit;
  end;
  i:=0;
  while i<SignalsLV.SelCount do
  begin
    if i=0 then
     li:=SignalsLV.Selected
    else
    begin
      li:=SignalsLV.items[SignalsLV.Selected.Index+i];
    end;

    cpairid(li.Data).id2:=cid(xLi.Data);
    s:=getSignal(cid(xLi.data));
    if s<>nil then
      SignalsLV.SetSubItemByColumnName(v_colXSignal, s.sname, li);
    inc(i);
  end;
end;

procedure TNIIPMForm.createEvents;
begin
  cchart1.objmng.events.AddEvent('OnMoveCursor_TNIIPMForm',e_OnMoveCursor,onMoveCursor);
  cchart1.objmng.events.AddEvent('OnMoveCursor_TNIIPMForm',e_OnMoveCursor2,onMoveCursor2);
end;

procedure TNIIPMForm.cChart1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  x1,x2,y1:double;
  s:iwpsignal;
  li:tlistitem;
  POS:point2;
begin
  if UpdateTrendPos then
  begin
    x1:=curs.getx1;
    y1:=trend1.GetY(x1);
    Y0FE.FloatNum:=y1;
    start:=p2d(x1,y1);
    StartEdit.visible:=true;
    EndEdit.visible:=true;
    StartEdit.Text:=formatstr(start.x,cpage(cchart1.activePage).prec)+'; '+
                       formatstr(start.y,cpage(cchart1.activePage).prec);
    StartEdit.Position:=cPage(cchart1.activePage).TrendPToP2View(p2(start.x,start.y),axis);

    li:=SignalsLV.Selected;
    // если есть X
    if cpairid(li.data).id2<>nil then
    begin
      s:=getSignal(cpairid(li.data).id2);
      x2:=findX(y1,s);
      trend2.x0:=x1-x2;
      finish:=p2d(findX(s.MaxY,s)+trend2.x0,s.MaxY);
      EndEdit.Text:=formatstr(finish.x,cpage(cchart1.activePage).prec)+'; '+
                              formatstr(finish.y,cpage(cchart1.activePage).prec);
      EndEdit.Position:=cPage(cchart1.activePage).TrendPToP2View(p2(finish.x,finish.y),axis);

      //fLabel.Value:=abs(x1-x2);
      //cPage(cchart1.activePage).TrendPToP2(p2(x1,y1),axis);
      //fLabel.Position:=pos;

      cchart1.Refresh;
      UpdateTrendPos:=false;
    end;
  end;
  if UpdateCursorPos then
  begin
    UpdateCursorPos:=false;
    li:=SignalsLV.Selected;
    if li<>nil then
    begin
      // если есть X
      if cpairid(li.data).id2<>nil then
      begin
        x1:=curs.getx2;
        if (x1>=start.x) and (x1<=finish.x) then
        begin
          Flabel.visible:=true;

          y1:=trend1.GetY(x1);

          s:=getSignal(cpairid(li.data).id2);
          x2:=findX(y1,s);

          fLabel.Value:=x2-x1;
          pos:=cPage(cchart1.activePage).TrendPToP2(p2(x1,y1),axis);
          fLabel.Position:=pos;

          cchart1.Refresh;
          UpdateTrendPos:=false;
        end
        else
        begin
          FLabel.visible:=false;
        end;
      end;
    end;
  end;
end;

procedure TNIIPMForm.onMoveCursor2(sender:tobject);
var
  s:iwpsignal;
  li:tlistitem;
begin
  li:=SignalsLV.Selected;
  if li<>nil then
  begin
    // если есть X
    if cpairid(li.data).id2<>nil then
    begin
      UpdateCursorPos:=true;
    end;
  end;
end;

procedure TNIIPMForm.OnMoveCursor(sender:tobject);
var
  s:iwpsignal;
  li:tlistitem;
begin
  li:=SignalsLV.Selected;
  if li<>nil then
  begin
    // если есть X
    if cpairid(li.data).id2<>nil then
    begin
      UpdateTrendPos:=true;
    end;
  end;
end;

procedure TNIIPMForm.cChart1Init(Sender: TObject);
begin
  UpdateTrendPos:=false;
  axis:=cpage(cChart1.activePage).activeAxis;

  trend1:=cBuffTrend1d.create;
  trend1.color:=blue;
  trend1.name:='AxisX';
  trend1.parent:=cpage(cChart1.activePage).activeAxis;

  trend2:=cBuffTrend1d.create;
  trend2.color:=red;
  trend2.name:='Parametr';
  trend2.parent:=cpage(cChart1.activePage).activeAxis;

  curs:=cDoubleCursor(cChart1.activepage.getChild('cDoubleCursor'));
  curs.drawYline:=true;
  curs.cursortype:=c_DoubleCursor;

  FLabel:=cFloatLabel.create;
  FLabel.name:='dX';
  FLabel.lincTo(cChart1.activePage);
  FLabel.Position:=p2(0,0);
  FLabel.visible:=false;
  FLabel.Value:=0;

  StartEdit:=cLabel.create;
  StartEdit.name:='Start';
  StartEdit.color:=yellow;
  StartEdit.lincTo(cChart1.activePage);
  StartEdit.Position:=p2(0,0);
  StartEdit.visible:=false;
  StartEdit.Text:='';
  StartEdit.Transparent:=false;

  EndEdit:=cLabel.create;
  EndEdit.name:='Finish';
  EndEdit.lincTo(cChart1.activePage);
  EndEdit.Position:=p2(0,0);
  EndEdit.visible:=false;
  EndEdit.Text:='';
  EndEdit.Transparent:=false;

  createEvents;
end;

procedure TNIIPMForm.clearlv;
var
  I: Integer;
  id:cid;
  pid:cpairid;
begin
  for I := 0 to XsignalLV.items.Count - 1 do
  begin
    id:=cid(XsignalLV.items[i].data);
    id.destroy;
    pid:=cpairid(signalsLV.items[i].data);
    pid.destroy;
  end;
  XSignalLV.Clear;
  SignalsLV.Clear;
end;

procedure TNIIPMForm.Addstring(signal:iwpsignal;fname:string;path:string);
var
  li:tlistitem;
  id:cid;
  pairid:cpairid;
begin
  li:=SignalsLV.Items.Add;
  pairid:=cpairid.create;
  li.Data:=pairid;
  // номер строки
  SignalsLV.SetSubItemByColumnName(v_ColNum, inttostr(li.Index+1), li);
  // номер сигнала
  SignalsLV.SetSubItemByColumnName(v_ColFile, fname, li);
  // номер сигнала по оси X
  SignalsLV.SetSubItemByColumnName(v_colSignal, iwpsignal(signal).sname, li);

  li:=XSignalLV.Items.Add;
  // номер строки
  XSignalLV.SetSubItemByColumnName(v_ColNum, inttostr(li.Index+1), li);
  // номер сигнала
  XSignalLV.SetSubItemByColumnName(v_colSignal, signal.sname, li);
  id:=cid.Create;;
  id.str:=path;
  id.node:=iwpnode(winpos.GetNode(signal));
  li.data:=id;
  pairid.id1:=id;
  //root:=iwpnode(Winpos.Get('/signals'));
  //childNode:=IWPNode(root.At(0));
  //d:=childNode.Reference;
  //merafile:=d as IWPUSML;
  //s:=iwpsignal(merafile.Parameter(0));
end;

procedure TNIIPMForm.InitLV;
var
  col:tlistcolumn;
begin
  signalslv.Columns.Clear;
  // номер строки
  col:=signalslv.Columns.Add;
  col.Caption:=v_ColNum;
  // им€ замера
  col:=signalslv.Columns.Add;
  col.Caption:=v_ColFile;
  // им€ сигнала
  col:=signalslv.Columns.Add;
  col.Caption:=v_colSignal;
  // им€ сигнала по оси X
  col:=signalslv.Columns.Add;
  col.Caption:=v_colXSignal;

  XSignalLV.Columns.Clear;
  // номер строки
  col:=XSignalLV.Columns.Add;
  col.Caption:=v_ColNum;
  // им€ сигнала
  col:=XSignalLV.Columns.Add;
  col.Caption:=v_colSignal;
end;

procedure TNIIPMForm.save;
begin
  // шаг по Y
  ifile.WriteFloat('Main','dY', YFE.FloatNum);
  ifile.WriteFloat('Main','Y0', Y0FE.FloatNum);
  ifile.WriteFloat('Main','Ymax', YMaxFE.FloatNum);
  ifile.WriteFloat('Main','ScaleTime', ScaleTFE.FloatNum);

  ifile.WriteBool('Main','AxisX_DT', mainDT);

  // необходимость сохранени€ в цсв
  ifile.WriteBool('Main','SaveCSV', SaveCSVCB.Checked);
  ifile.WriteString('Main','Separator', SeparatorEdit.text);
  ifile.WriteString('Main','SaveCSVFolder', FolderPath.Text);
  ifile.WriteString('Main','SaveCSVFileName', CSVNameEdit.text);
end;

procedure TNIIPMForm.load;
var
  str:string;
begin
  str:=ifile.ReadString('Main','dY', '1');
  YFE.FloatNum:=strtoFloatExt(str);

  str:=ifile.ReadString('Main','Y0', '0');
  Y0FE.FloatNum:=strtoFloatExt(str);

  str:=ifile.ReadString('Main','YMax', '4');
  YMaxFE.FloatNum:=strtoFloatExt(str);

  mainDT:=ifile.ReadBool('Main','AxisX_DT', false);

  str:=ifile.ReadString('Main','ScaleTime', '1');
  ScaleTFE.FloatNum:= strtoFloatExt(str);

  SaveCSVCB.Checked:=ifile.ReadBool('Main','SaveCSV', false);
  SeparatorEdit.text:=ifile.ReadString('Main','Separator', ';');
  FolderPath.Text:=ifile.ReadString('Main','SaveCSVFolder', extractfiledir(Application.ExeName)+'\plugins\NIIPM\Reports\');
  CSVNameEdit.text:=ifile.ReadString('Main','SaveCSVFileName', 'Report');
end;

procedure initstrings;
begin
  v_colSignal:= GetConstString('ColSignal');
  v_colXSignal:= GetConstString('ColXSignal');
  v_ColFile:= GetConstString('ColFile');
end;

constructor TNIIPMForm.Create(AOwner: TComponent);
begin
  inherited;
  ifile:=TIniFile.Create(startDir);
  initstrings;
  InitLV;
  load;
end;

destructor TNIIPMForm.destroy;
begin
  save;
  ifile.Destroy;
  inherited;
end;

procedure TNIIPMForm.EvalMinMaxBtnClick(Sender: TObject);
var
  s:iwpsignal;
begin
  s:=getSelected;
  if s<>nil then
  begin
    Y0FE.FloatNum:=s.MinY;
    YMaxFE.FloatNum:=s.MaxY;
  end;
end;

function TNIIPMForm.getSignal(id:cid):iwpsignal;
begin
  result:=iwpsignal(id.node.Reference);
end;

procedure TNIIPMForm.ShowSignal(s:iwpsignal; tr:cBuffTrend1d);
var
  I: Integer;
begin
  // создаем тренд
  tr.Count:=s.size;
  tr.dx:=s.DeltaX;
  for I := 0 to s.size-1 do
  begin
    tr.AddPoint(s.GetY(i), i);
  end;
  tr.boundrect.BottomLeft.x:=s.MinX;
  tr.boundrect.TopRight.x:=s.MaxX;
  tr.boundrect.BottomLeft.y:=s.MinY;
  tr.boundrect.TopRight.y:=s.MaxY;
end;

procedure TNIIPMForm.ShowFiles;
var
  Node, childNode:IWPNode;
  signal:wpsignal;
  merafile:IWPUSML;
  d:iDispatch;
  i,j,count:integer;
  fname:string;
begin
  // очищаем списки
  clearlv;
  node:=IWPNode((winpos.Get('/signals')));
  count:=node.ChildCount;
  // проход по узлам файлов
  for i := 0 to Count - 1 do
  begin
    childNode:=IWPNode(Node.At(i));
    d:=childNode.Reference;
    if Supports(d,DIID_IWPUSML) then
    begin
      merafile:=d as IWPUSML;
      // ќбновл€ем комбобокс с замерами
      fname:=merafile.FileName;
      fname:=ExtractFileName(fname);
      filecb.AddItem(fname, pointer(childNode.Instance));
      for j:=0 to merafile.ParamCount-1 do
      begin
        d:=merafile.Parameter(j);
        if Supports(d,DIID_IWPSignal) then
        begin
          signal:=d as iwpsignal;
          Addstring(signal, fname, childNode.AbsolutePath+'/'+signal.SName);
        end;
      end;
    end;
    FileCB.ItemIndex:=0;
    LVChange(signalslv);
    LVChange(XSignallv);
  end;
end;


function TypeCastToIWPUSML(d:idispatch):iwpusml;
begin
  if d.QueryInterface(DIID_IWPUSML, result) = S_OK then
  begin

  end
  else
    result:=nil;
end;

function TypeCastToIWNode(d:idispatch):iwpNode;
begin
  if d.QueryInterface(DIID_IWPNode, result) = S_OK then
  begin

  end
  else
    result:=nil;
end;

function TypeCastToIWSignal(d:idispatch):iwpSignal;
begin
  if d.QueryInterface(DIID_IWPSignal, result) = S_OK then
  begin

  end
  else
    result:=nil;
end;


end.
