unit uFFTfltFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, Spin, ExtCtrls, uChart, uFFTflt,
  uWPservices, uCommonTypes, posbase, Winpos_ole_TLB,
  inifiles,
  utrend,
  MathFunction,
  uComponentServises,
  uCommonMath, DCL_MYOWN, uSpin;

type
  LBRecord = class
    s:iwpsignal;
  end;

  TFFTFltFrm = class(TForm)
    ActionPanel: TPanel;
    RightPanel: TPanel;
    ApplyBtn: TButton;
    ScalesLV: TBtnListView;
    EditCurvePanel: TPanel;
    F1Label: TLabel;
    F2Label: TLabel;
    Indexse_01: TSpinEdit;
    Indexse_02: TSpinEdit;
    F1indLabel: TLabel;
    F2indLabel: TLabel;
    Label5: TLabel;
    SetScaleBtn: TButton;
    ScaleCurveChart: cChart;
    FFTCountLabel: TLabel;
    OffsetLabel: TLabel;
    OffsetSE: TSpinEdit;
    dFLabel: TLabel;
    pCountIE: TIntEdit;
    pCountBtn: TSpinButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    EditScaleBtn: TButton;
    F1SE: TFloatSpinEdit;
    f2se: TFloatSpinEdit;
    ScaleSE: TFloatSpinEdit;
    SaveCfgCB: TComboBox;
    SaveBtn: TButton;
    LoadCfgCB: TComboBox;
    LoadBtn: TButton;
    OpenDialog1: TOpenDialog;
    SignalsLV: TBtnListView;
    procedure pCountBtnUpClick(Sender: TObject);
    procedure pCountBtnDownClick(Sender: TObject);
    procedure SignalsLBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetScaleBtnClick(Sender: TObject);
    procedure ScalesLVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditScaleBtnClick(Sender: TObject);
    procedure LoadCfgCBChange(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
  private
    m_oper:TExtFFTflt;
    curv:ctrend;
  private
    procedure UpdateFs;
    //procedure ShowCurv;
    function Selected:iwpSignal;
    procedure showSignals;
    function getsignal(i:integer):iwpsignal;
    function GetPropStr: string;
    Procedure SetPropStr(str: string);
    function GetNotifyStr(p_opts: string): string;
  public
    procedure link(eo: TExtFFTflt);
    function EditOper: string;
  end;

var
  FFTFltFrm: TFFTFltFrm;

implementation
uses
  uWpExtPack;

{$R *.dfm}

{ TFFTFltFrm }

function TFFTFltFrm.EditOper: string;
var
  res: integer;
  i: integer;
  p2:point2d;

  start, stop: integer;
  param: olevariant;
  wstr: widestring;
  s: iwpsignal;
  iD: idispatch;
  savestr,str:string;
  rec:LBRecord;
  li:tlistitem;
begin
  // переносим свойства в форму
  p2:=GetActiveCursorX;
  showSignals;
  res := showmodal;
  if res = mrok then
  begin
    m_oper.m_Band.Clear;
    for I := 0 to ScalesLV.Items.Count - 1 do
    begin
      li:=ScalesLV.Items[i];
      ScalesLV.GetSubItemByColumnName('F', li, str);
      savestr:=str+';';
      ScalesLV.GetSubItemByColumnName('Scale', li, str);
      savestr:=savestr+str;
      m_oper.m_Band.Add(savestr);
    end;
    // переносим свойства в оператор
    m_oper.SetPropStr(GetPropStr);
    // Вызов обработки
    for i := 0 to SignalsLV.items.count - 1 do
    begin
      li:=SignalsLV.Items[i];
      if li.Checked then
      begin
        rec:=LBRecord(li.data);
        s := rec.s;
        if s.DeltaX<>0 then
        begin
          m_oper.Exec(s, s, iD, iD);
        end;
      end;
    end;
    // Сообщение в журнал что вызывали
    // 'o="/Operators/АвтоСпектр";p="kindFunc=5, numPoints=16384, nBlocks=1, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=1, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";s1_000="/Signals/6363.mera/NI6363-{PXI1Slot18-18- 1}";i1_000=0;c1_000=1000;d1_000="/Signals/Результаты/NI6363-{PXI1Slot18-18- 1}_Real#2";d2_000="/Signals/Результаты/NI6363-{PXI1Slot18-18- 1}_Image#2";dp1_000=3f8f260d;dp2_000=3f8fa48d;'
    str := GetNotifyStr(m_oper.GetPropStrF(wstr));
    param := str;
    // вызов уведомления
    TExtPack(extPack).NotifyPlugin($000F0001, param);
  end;
end;


procedure TFFTFltFrm.FormCreate(Sender: TObject);
begin
  curv:=cTrend.create;
end;

function TFFTFltFrm.GetNotifyStr(p_opts: string): string;
var
  i: integer;
  str, numstr: string;
  s1:iwpsignal;
  n:iwpnode;
begin
  result := 'o="/Расширения/' + 'FFT фильтр' + '";p="' + p_opts + '";';
  for I := 0 to SignalsLV.Items.Count - 1 do
  begin
    s1:=GetSignal(i);
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
    result:=result+
    'i1'+'_'+str+'='+'0'+';'
    +'c1'+'_'+str+'='+inttostr(s1.size)+';'
    +'d1'+'_'+str+'="'+'/Signals/results/'+ s1.sname+'_BalZero';
  end;
end;

function TFFTFltFrm.GetPropStr: string;
var
  pars: tstringlist;
  b: boolean;
  str: string;
begin
  pars := tstringlist.Create;
  addParam(pars, 'FFTCount', inttostr(pCountIE.IntNum));
  addParam(pars, 'OffsetBlock', inttostr(OffsetSE.Value));
  //addParam(pars, 'Curve', inttostr(pCountSE.Value));

  result := ParsToStr(pars);
  delpars(pars);
  pars.Destroy;
end;

function TFFTFltFrm.getsignal(i: integer): iwpsignal;
var
  rec:lbrecord;
  li:tlistitem;
begin
  li:=SignalsLV.Items[i];
  rec:=lbrecord(li.data);
  result:=rec.s;
end;

procedure TFFTFltFrm.link(eo: TExtFFTflt);
begin
  m_oper := eo;
end;


procedure TFFTFltFrm.LoadCfgCBChange(Sender: TObject);
begin
  if CheckFolderComponent(LoadCfgCB, true) then
  begin

  end;
end;

procedure TFFTFltFrm.pCountBtnDownClick(Sender: TObject);
begin
  if PCountIE.IntNum>2 then
    PCountIE.IntNum:=round(PCountIE.IntNum/2);
  OffsetSE.Value:=PCountIE.IntNum;
  updatefs;
end;

procedure TFFTFltFrm.pCountBtnUpClick(Sender: TObject);
begin
  if PCountIE.IntNum>2 then
    PCountIE.IntNum:=PCountIE.IntNum*2;
  OffsetSE.Value:=PCountIE.IntNum;
  updatefs;
end;








procedure TFFTFltFrm.LoadBtnClick(Sender: TObject);
var
   I: Integer;
   str:string;
   f:TextFile;
   slist:tstringlist;
   li:TListItem;
begin
   if FileExists(LoadCfgCB.text) then
   begin
     slist:=TStringList.Create;
     slist.Delimiter:=';';
     System.Assign(f,LoadCfgCB.text);
     Reset(f);
     ScalesLV.Clear;

     while not Eof(f) do
     begin
       ReadLn(f,str);
       slist.DelimitedText:=str;
       li:=ScalesLV.Items.Add;
       ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index+1), li);
       ScalesLV.SetSubItemByColumnName('F', slist.Strings[0], li);
       ScalesLV.SetSubItemByColumnName('Scale', slist.Strings[1], li);
     end;

     LVChange(ScalesLV);
     slist.Destroy;
     CloseFile(f);
   end;
end;

































procedure TFFTFltFrm.SaveBtnClick(Sender: TObject);
var
  I: Integer;
  li: TListItem;
  str, savestr:string;
  f:TextFile;
begin
  if SaveCfgCB.text='' then
    exit;
  str:=extractfiledir(SaveCfgCB.text);
  if not DirectoryExists(str) then
  begin
    ForceDirectories(str);
  end;
  System.Assign(f, SaveCfgCB.text);
  // открываем для записи
  Rewrite(f);
  for I := 0 to ScalesLV.items.Count - 1 do
  begin
    li:=ScalesLV.Items[i];
    ScalesLV.GetSubItemByColumnName('F', li, str);
    savestr:=str+';';
    ScalesLV.GetSubItemByColumnName('Scale', li, str);
    savestr:=savestr+str;
    // запись строки во второй файл
    writeln(f, savestr);
  end;
  CloseFile(f);
end;

procedure TFFTFltFrm.ScalesLVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  li:TListItem;
begin
  if key=VK_DELETE then
  begin
    while ScalesLV.SelCount<>0 do
    begin
      li:=ScalesLV.Selected;
      li.Delete;
    end;
  end;
end;

function TFFTFltFrm.Selected: iwpSignal;
var
  li:tlistitem;
begin
  if SignalsLV.Items.Count=0 then
  begin
    result:=nil;
    exit;
  end;
  if SignalsLV.ItemIndex>-1 then
  begin
    li:=SignalsLV.selected;
    result:=LBRecord(li.data).s;
  end
  else
  begin
    li:=SignalsLV.items[0];
    result:=LBRecord(li.data).s;
  end;
end;

procedure TFFTFltFrm.SetPropStr(str: string);
begin

end;

procedure TFFTFltFrm.SetScaleBtnClick(Sender: TObject);
var
  li:TListItem;
  str:string;
begin
  // новый элемент
  li:=ScalesLV.Items.Add;
  ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index+1), li);
  // преобразование с плав.точ.в строку
  str:=floattostr(f1se.Value)+'..'+floattostr(f2se.Value);
  ScalesLV.SetSubItemByColumnName('F', str, li);
  ScalesLV.SetSubItemByColumnName('Scale', ScaleSE.Text , li);
  LVChange(ScalesLV);
end;

procedure TFFTFltFrm.EditScaleBtnClick(Sender: TObject);
var
  // ссылка на данные компанента
  li,  next :TListItem;
  str:string;
  I: Integer;
begin
  li:=ScalesLV.Selected;
  while li<>nil do
  begin
    if ScalesLV.SelCount=1 then
    begin
      str:=floattostr(f1se.Value)+'..'+floattostr(f2se.Value);
      ScalesLV.SetSubItemByColumnName('F', str, li);
    end;
    ScalesLV.SetSubItemByColumnName('Scale', ScaleSE.Text , li);
    next:=ScalesLV.GetNextItem(li,sdAll,[isSelected]);
    li:=next;
  end;
  LVChange(ScalesLV);
end;


procedure TFFTFltFrm.showSignals;
var
  n, ch:iwpnode;
  s:iwpsignal;
  li:tlistitem;
  I: Integer;
  rec:LBRecord;
begin
  n:=getCurSrcInMainWnd;
  for I := 0 to signalsLV.Items.Count - 1 do
  begin
    li:=signalsLV.Items[i];
    rec:=LBRecord(li.data);
    rec.Destroy;
  end;
  SignalsLV.Clear;
  for I := 0 to n.ChildCount - 1 do
  begin
    ch:=n.At(i) as iwpnode;
    if issignal(ch) then
    begin
      s:=TypeCastToIWSignal(ch);
      rec:=LBRecord.Create;
      rec.s:=s;
      li:=SignalsLV.Items.Add;
      li.Data:=rec;
      signalsLV.SetSubItemByColumnName('Инд.',inttostr(li.Index+1),li);
      signalsLV.SetSubItemByColumnName('Сигналы',s.sname,li);
      if s.deltaX=0 then
        signalsLV.SetSubItemByColumnName('Fs','-', li)
      else
        signalsLV.SetSubItemByColumnName('Fs',formatstrnoe(1/s.DeltaX, 4),li);
    end;
  end;
  LVChange(signalsLV);
end;

procedure TFFTFltFrm.SignalsLBClick(Sender: TObject);
begin
  updatefs;
end;

procedure TFFTFltFrm.UpdateFs;
var
  s:iwpsignal;
begin
  s:=Selected;
  if s<>nil then
  begin
    dfLabel.Caption:='dF='+formatstrNoE((1/s.DeltaX)/pCountIE.IntNum,4);
  end;
end;

end.
