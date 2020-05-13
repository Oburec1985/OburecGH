unit uFindMaxForm_;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, uSpin, ExtCtrls, uChart, uWPProc,
  Winpos_ole_TLB, PosBase, uBinFile, uComponentServises, uCommonMath,
  MathFunction,
  utrend, uAxis, upage, ubasepage, uWPServices, ImgList, uMarkers, uCommonTypes,
  uDoubleCursor, Clipbrd, DCL_MYOWN, Spin, inifiles;

type
  TFindMaxForm = class(TForm)
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    TabPanel: TPageControl;
    AlgOptsTabSheet: TTabSheet;
    AlgOptsGB: TGroupBox;
    SignalsGB: TGroupBox;
    GroupBox7: TGroupBox;
    SignalsLB: TListBox;
    ExtremumLB: TListBox;
    BandList: TBtnListView;
    SavePage: TTabSheet;
    SaveDialog1: TSaveDialog;
    IdentBandsGB: TGroupBox;
    NameEdit: TEdit;
    NameLabel: TLabel;
    EditBandGB: TGroupBox;
    UnitsLabel: TLabel;
    LevelLabel: TLabel;
    NoisePositiveLabel: TLabel;
    LevelPosLabel: TLabel;
    NoiseNegLabel: TLabel;
    LevelPosSE: TFloatSpinEdit;
    NoisePosSE: TFloatSpinEdit;
    LevelNegSE: TFloatSpinEdit;
    NoiseNegSE: TFloatSpinEdit;
    UnitsCB: TComboBox;
    X1: TLabel;
    X1SE: TFloatSpinEdit;
    F2Label: TLabel;
    X2SE: TFloatSpinEdit;
    negCB: TCheckBox;
    Label1: TLabel;
    AddBandBtn: TButton;
    DelBandBtn: TButton;
    PosCB: TCheckBox;
    ExpBtn: TButton;
    ImportBtn: TButton;
    PathBtn: TButton;
    GroupBox1: TGroupBox;
    MainSplitter: TSplitter;
    cChart1: cChart;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    GroupBox2: TGroupBox;
    SavePathLabel: TLabel;
    SavePathEdit: TEdit;
    LgY: TCheckBox;
    SavePathBtn: TButton;
    Splitter1: TSplitter;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    SpinEdit1: TSpinEdit;
    ApplyBandItemBtn: TButton;
    FloatSpinEdit1: TFloatSpinEdit;
    Label3: TLabel;
    SaveBtn: TButton;
    MOOffsetCB: TCheckBox;
    procedure SavePathBtnClick(Sender: TObject);
    procedure AddBandBtnClick(Sender: TObject);
    procedure ExpBtnClick(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure PathBtnClick(Sender: TObject);
    procedure ImportBtnClick(Sender: TObject);
    procedure DelBandBtnClick(Sender: TObject);
    procedure SignalsLBDblClick(Sender: TObject);
    procedure BandListResize(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure SignalsLBClick(Sender: TObject);
    procedure cChart1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ExtremumLBKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FloatEdit1MouseEnter(Sender: TObject);
    procedure LgYClick(Sender: TObject);
    procedure BandListClick(Sender: TObject);
    procedure ApplyBandItemBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SignalsLBDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SaveBtnClick(Sender: TObject);
  public
    eo: TObject;
    mng: cWPObjMng;
    markers: cMarkerList;
    cursig: TObject;
    clip: tclipboard;
    tr, Lo, Hi: ctrend;
  private
    function GetNotifyStr:string;
    procedure updatemarkers(s: TObject);
    procedure ShowMarkrsInLB(s: TObject);
    procedure ShowSignalInChart(s: TObject);
    // присвоить сигналу полосу из таблицы
    procedure AssigneBand;
    procedure AddBandToLV(b: TObject);
    function GetPropertyStr: String;
    procedure ShowLevels(s:tobject);
    procedure Save;
    procedure load;
  public
    // нужно вызывать когда в дереве винпос выбран новый объект
    procedure updateSelect;
    function ShowModal: integer; override;
    // constructor create;override;
  end;

var
  FindMaxForm: TFindMaxForm;

implementation

uses
  uFindMaxOper, uWPExtPack;
{$R *.dfm}

function TFindMaxForm.GetNotifyStr:string;
var
  i:integer;
  signal:cAmpFindSignal;
  str, numstr:string;
begin
//'o="/Operators/АвтоСпектр";p="kindFunc=4, numPoints=16384, nBlocks=530, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=0, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";
//s1_000="/Signals/signal0436.mera/3- 1";i1_000=0;c1_000=8694000;d1_000="/Signals/Результаты/signal0436.mera_СA/3- 1_СA";dp1_000=1e9a008d;
//s1_001="/Signals/signal0436.mera/18- 1_Taho";i1_001=0;c1_001=8715600;d1_001="/Signals/Результаты/signal0436.mera_СA/18- 1_Taho_СA";
//dp1_001=1e95690d;
//s1_002="/Signals/signal0436.mera/18- 3_Stop";i1_002=0;c1_002=8715600;d1_002="/Signals/Результаты/signal0436.mera_СA/18- 3_Stop_СA";dp1_002=1e96a90d;s1_003="/Signals/signal0436.mera/18- 4_Start";i1_003=0;c1_003=8715600;d1_003="/Signals/Результаты/signal0436.mera_СA/18- 4_Start_СA";dp1_003=1e98248d;'

//'o="/Operators/ПоискЭкстремумов";
// p="BandCount=1,bx_0=5,by_0=2000,L_pos_0=90,L_neg_0=10,N_pos_0=5,N_neg_0=5,N_Max_0=+,N_Neg_0=+,Units_0=%";
// s1_001="3- 1_СA"i1_001=0;c1_001=2048;d1_001="3- 1_СA_AFlg" s2_002="18- 1_Taho_СA"i2_002=0;c2_002=2048;d2_002="3- 1_СA_AFlg"s3_003="18- 3_Stop_СA"i3_003=0;c3_003=2048;d3_003="18- 3_Stop_СA_AFlg"s4_004="18- 4_Start_СA"i4_004=0;c4_004=2048;d4_004="18- 4_Start_СA_AFlg"'
  result:='o="/Расширения/'+FindMaxRegName+'";p="'+TExtOperAmpFind(eo).props+'";';
  for I := 0 to SignalsLB.Count - 1 do
  begin
    signal:=cAmpFindSignal(SignalsLB.Items.Objects[i]);
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
    result:=result+'s1'+'_'+str+'="'+signal.node.AbsolutePath+'";'
          +'i1'+'_'+str+'='+'0'+';'
          +'c1'+'_'+str+'='+inttostr(signal.Signal.size)+';'
          +'d1'+'_'+str+'="'+TExtOperAmpFind(eo).resfolder+'/'+
          signal.name+'_AFlg'+'";';
  end;
end;

procedure TFindMaxForm.updateSelect;
var
  d: idispatch;
  I, count: integer;
  s: iwpsignal;
  signal: cAmpFindSignal;
begin
  // чистка старых результатов
  for I := 0 to SignalsLB.count - 1 do
  begin
    signal := cAmpFindSignal(SignalsLB.Items.Objects[I]);
    signal.destroy;
  end;
  SignalsLB.Clear;

  d := WINPOS.getselectedObject;
  count := getChildCount(d);
  if count <> 0 then
  begin
    // если к узлу крепяться сигналы
    for I := 0 to count - 1 do
    begin
      s := GetChildSignal(d, I);
      signal := TExtOperAmpFind(eo).AddSignal(s);
      SignalsLB.AddItem(signal.Name, signal);
    end;
  end
  else
  begin
    if IsSignal(d) then
    begin
      signal := TExtOperAmpFind(eo).AddSignal(d as iwpsignal);
      SignalsLB.AddItem(signal.Name, signal);
    end
    else
    begin
      // залипуха на случай если объект пустышка
      // (например папка создана генератором)
      d:=winpos.GetSelectedNode;
      count := getChildCount(d);
      if count <> 0 then
      begin
        // если к узлу крепяться сигналы
        for I := 0 to count - 1 do
        begin
          s := GetChildSignal(d, I);
          signal := TExtOperAmpFind(eo).AddSignal(s);
          SignalsLB.AddItem(signal.Name, signal);
        end;
      end
    end;
  end;
end;

function TFindMaxForm.ShowModal: integer;
begin
  TabPanel.TabIndex := 0;
  updateSelect;
  result := inherited ShowModal;
end;

procedure TFindMaxForm.ShowMarkrsInLB(s: TObject);
var
  j: integer;
  str: string;
begin
  cursig := s;
  ExtremumLB.Clear;
  if cAmpFindSignal(s).res <> nil then
  begin
    // заполняем лист экстремумами
    for j := 0 to cAmpFindSignal(s).res.count - 1 do
    begin
      str := 'x: ' + formatstr(cAmpFindSignal(s).res.getRec(j).p.x, 4) + ';';
      str := str + 'y:' + formatstr(cAmpFindSignal(s).res.getRec(j).p.y, 4);
      ExtremumLB.AddItem(str, nil);
    end;
  end;
end;

procedure TFindMaxForm.SignalsLBClick(Sender: TObject);
var
  s: cAmpFindSignal;
  str: string;
  I, j: integer;
begin
  if SignalsLB.SelCount = 1 then
  begin
    for I := 0 to SignalsLB.count - 1 do
    begin
      if SignalsLB.Selected[I] then
      begin
        s := cAmpFindSignal(SignalsLB.Items.Objects[I]);
        ShowMarkrsInLB(s);
        exit;
      end;
    end;
  end;
end;

procedure TFindMaxForm.updatemarkers(s: TObject);
var
  I: integer;
begin
  if markers = nil then
  begin
    markers := cMarkerList.create;
    cpage(cChart1.activePage).activeAxis.AddChild(markers);
  end
  else
    markers.Clear;
  for I := 0 to cAmpFindSignal(s).res.count - 1 do
  begin
    markers.AddMarker(p2(cAmpFindSignal(s).res.getRec(I).p.x,
                      cAmpFindSignal(s).res.getRec(I).p.y));
  end;
end;

procedure TFindMaxForm.ShowSignalInChart(s: TObject);
var
  I: integer;
  sig: cAmpFindSignal;
begin
  sig := cAmpFindSignal(s);
  if tr = nil then
  begin
    tr := ctrend(cpage(cChart1.activePage).activeAxis.AddTrend);
    tr.drawpoint := false;
  end
  else
    tr.Clear;
  if cAmpFindSignal(s).count > 0 then
  begin
    CreateTrend(tr, cAmpFindSignal(s));
    cpage(cChart1.activePage).Normalise;
    if cAmpFindSignal(s).res <> nil then
    begin
      updatemarkers(s);
    end
    else
    begin
      showmessage('Результат не посчитан для сигнала');
    end;
    cChart1.redraw;
  end;
  ShowLevels(sig);
end;

procedure TFindMaxForm.SignalsLBDblClick(Sender: TObject);
var
  s: cAmpFindSignal;
  I, j: integer;
begin
  // применить
  AssigneBand;
  if SignalsLB.SelCount = 1 then
  begin
    for I := 0 to SignalsLB.count - 1 do
    begin
      if SignalsLB.Selected[I] then
      begin
        s := cAmpFindSignal(SignalsLB.Items.Objects[I]);
        ShowMarkrsInLB(s);
        // Если активна вкладка с настройкой полос
        // Если активна вкладка результатов
        ShowLevels(s);
        if TabPanel.ActivePageIndex = 1 then
        begin
          ShowSignalInChart(s);
        end;
      end;
    end;
  end;
end;

procedure TFindMaxForm.SignalsLBDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  obj:tobject;
  red:boolean;
begin
  red:=false;
  with SignalsLB.Canvas do
  begin
    if red then
    begin
      Brush.Color := $008080FF;
      FillRect(Rect);
      Font.Color :=clBlack; //RGB(255, 255, 255);
      TextOut(Rect.Left, Rect.Top, SignalsLB.Items[Index]);
    end
    else
    begin
      FillRect(Rect);
      if Index >= 0 then
        TextOut(Rect.Left + 2, Rect.Top, SignalsLB.Items[Index]);
      // дефолтная отрисовка
    end;
  end;
end;

procedure TFindMaxForm.AddBandBtnClick(Sender: TObject);
var
  b: tband;
begin
  b := tband.create;
  b.LevelPos := LevelPosSE.Value;
  b.LevelNeg := LevelNegSE.Value;
  b.f1 := X1SE.Value;
  b.f2 := X2SE.Value;
  b.NoisePos := NoisePosSE.Value;
  b.NoiseNeg := NoiseNegSE.Value;
  b.PosRes := PosCB.Checked;
  b.NegRes := negCB.Checked;
  b.MO_Offset := MOOffsetCB.Checked;
  case UnitsCB.ItemIndex of
    0:
      b.units := u_Abs;
    1:
      b.units := u_percent;
    2:
      b.units := u_10Lg;
    3:
      b.units := u_20Lg;
  end;
  AddBandToLV(b);
  b.destroy;
end;

procedure TFindMaxForm.AddBandToLV(b: TObject);
var
  li: tlistitem;
begin
  li := BandList.Items.Add;
  BandList.SetSubItemByColumnName('№', inttostr(li.index), li);
  BandList.SetSubItemByColumnName('X1', floattostr(tband(b).f1), li);
  BandList.SetSubItemByColumnName('X2', floattostr(tband(b).f2), li);
  BandList.SetSubItemByColumnName('Level "+"', floattostr(tband(b).LevelPos),
    li);
  BandList.SetSubItemByColumnName('Level "-"', floattostr(tband(b).LevelNeg),
    li);
  BandList.SetSubItemByColumnName('Noise "+"', floattostr(tband(b).NoisePos),
    li);
  BandList.SetSubItemByColumnName('Noise "-"', floattostr(tband(b).NoisePos),
    li);

  if tband(b).PosRes then
    BandList.SetSubItemByColumnName('Искать "+" макс.', '+', li)
  else
    BandList.SetSubItemByColumnName('Искать "+" макс.', '-', li);

  if tband(b).NegRes then
    BandList.SetSubItemByColumnName('Искать "-" макс.', '+', li)
  else
    BandList.SetSubItemByColumnName('Искать "-" макс.', '-', li);

  if tband(b).MO_Offset then
    BandList.SetSubItemByColumnName('Отклонение от среднего', '+', li)
  else
    BandList.SetSubItemByColumnName('Отклонение от среднего', '-', li);

  // единицы
  if tband(b).units = u_Abs then
  begin
    BandList.SetSubItemByColumnName('Единицы', 'Абс.', li);
  end;
  if tband(b).units = u_percent then
  begin
    BandList.SetSubItemByColumnName('Единицы', '%', li);
  end;
  if tband(b).units = u_10Lg then
  begin
    BandList.SetSubItemByColumnName('Единицы', '10Lg', li);
  end;
  if tband(b).units = u_20Lg then
  begin
    BandList.SetSubItemByColumnName('Единицы', '20Lg', li);
  end;
end;

procedure TFindMaxForm.ApplyBandItemBtnClick(Sender: TObject);
var
  li: tlistitem;
begin
  li := BandList.Selected;
  if li=nil then
  begin
    showmessage('выберите точку в настройке профиля, которую нужно изменить');
    exit;
  end;
  BandList.SetSubItemByColumnName('X1', floattostr(X1SE.Value), li);
  BandList.SetSubItemByColumnName('X2', floattostr(X2SE.Value), li);
  BandList.SetSubItemByColumnName('Level "+"', floattostr(LevelPosSE.Value),
    li);
  BandList.SetSubItemByColumnName('Level "-"', floattostr(LevelNegSE.Value),
    li);
  BandList.SetSubItemByColumnName('Noise "+"', floattostr(NoisePosSE.Value),
    li);
  BandList.SetSubItemByColumnName('Noise "-"', floattostr(NoiseNegSE.Value),
    li);
  if PosCB.Checked then
    BandList.SetSubItemByColumnName('Искать "+" макс.', '+', li)
  else
    BandList.SetSubItemByColumnName('Искать "+" макс.', '-', li);
  if negCB.Checked then
    BandList.SetSubItemByColumnName('Искать "-" макс.', '+', li)
  else
    BandList.SetSubItemByColumnName('Искать "-" макс.', '-', li);
  // единицы
  if UnitsCB.ItemIndex = 0 then
  begin
    BandList.SetSubItemByColumnName('Единицы', 'Абс.', li);
  end;
  if UnitsCB.ItemIndex = 1 then
  begin
    BandList.SetSubItemByColumnName('Единицы', '%', li);
  end;
  if UnitsCB.ItemIndex = 3 then
  begin
    BandList.SetSubItemByColumnName('Единицы', '10Lg', li);
  end;
  if UnitsCB.ItemIndex = 2 then
  begin
    BandList.SetSubItemByColumnName('Единицы', '20Lg', li);
  end;
  if MOOffsetCB.Checked then
    BandList.SetSubItemByColumnName('Отклонение от среднего', '+', li)
  else
    BandList.SetSubItemByColumnName('Отклонение от среднего', '-', li)
end;

function GetStrFromBand(b: tband; I: integer): string;
var
  s: string;
begin
  // X1
  s := 'bx_' + inttostr(I) + '=' + floattostr(tband(b).f1) + ',';
  // X2
  s := s + 'by_' + inttostr(I) + '=' + floattostr(tband(b).f2) + ',';
  // Level+
  s := s + 'L_pos_' + inttostr(I) + '=' + floattostr(tband(b).LevelPos) + ',';
  // Level-
  s := s + 'L_neg_' + inttostr(I) + '=' + floattostr(tband(b).LevelNeg) + ',';
  // Noise+
  s := s + 'N_pos_' + inttostr(I) + '=' + floattostr(tband(b).NoisePos) + ',';
  // Noise-
  s := s + 'N_neg_' + inttostr(I) + '=' + floattostr(tband(b).NoiseNeg) + ',';
  // Pos искать максимумы
  if tband(b).PosRes then
    s := s + 'N_Max_' + inttostr(I) + '=' + '+' + ','
  else
    s := s + 'N_Max_' + inttostr(I) + '=' + '-' + ',';
  // Neg искать минимумы
  if tband(b).PosRes then
    s := s + 'N_Neg_' + inttostr(I) + '=' + '+' + ','
  else
    s := s + 'N_Neg_' + inttostr(I) + '=' + '-' + ',';
  // единицы
  s := s + 'Units_' + inttostr(I) + '=';
  if tband(b).units = u_Abs then
  begin
    s := s + 'Абс.';
  end;
  if tband(b).units = u_percent then
  begin
    s := s + '%';
  end;
  if tband(b).units = u_10Lg then
  begin
    s := s + '10Lg';
  end;
  if tband(b).units = u_20Lg then
  begin
    s := s + '20Lg';
  end;
  result := s;
end;

function TFindMaxForm.GetPropertyStr: String;
var
  props: string;
  b: tband;
  I: integer;
begin
  props := 'BandCount=' + inttostr(length(TExtOperAmpFind(eo).bands)) + ',';
  for I := 0 to length(TExtOperAmpFind(eo).bands) - 1 do
  begin
    b := TExtOperAmpFind(eo).bands[I];
    if i>0 then
    begin
      props:=props+';';
    end;
    props := props + GetStrFromBand(b, I);
  end;
  result := props;
end;

procedure TFindMaxForm.ApplyBtnClick(Sender: TObject);
var
  I, j: integer;
  b: tband;
  s: TObject;
  str, resstr: string;
  param:OleVariant;
begin
  AssigneBand;
  str := GetPropertyStr;
  for I := 0 to SignalsLB.count - 1 do
  begin
    s := SignalsLB.Items.Objects[I];
    // установка свойств
    TExtOperAmpFind(eo).SetPropStr(str);
    TExtOperAmpFind(eo).Execute(cAmpFindSignal(s).signal);
    cAmpFindSignal(s).res := TExtOperAmpFind(eo).res.Copy;
  end;
  BringToFront;
  str:=GetNotifyStr;
  param:=str;
  // вызов уведомления
  TExtPack(extPack).NotifyPlugin($000F0001, param);
  //modalresult:=mrok;
end;

procedure TFindMaxForm.ShowLevels(s:tobject);
var
  I: Integer;
  p:point2;
begin
  if lo=nil then
  begin
    lo:= ctrend(cpage(cChart1.activePage).activeAxis.AddTrend);
    lo.color:=red;
    lo.name:='Lo';
  end;
  if hi=nil then
  begin
    hi:= ctrend(cpage(cChart1.activePage).activeAxis.AddTrend);
    hi.color:=red;
    hi.name:='Hi';
  end;
  hi.Clear;
  hi.visible:=posCB.Checked;
  lo.Clear;
  lo.visible:=negCB.Checked;
  for I := 0 to length(TExtOperAmpFind(eo).bands) - 1 do
  begin
    if posCB.Checked then
    begin
      p.x:=TExtOperAmpFind(eo).bands[0].f1;
      p.y:=GetPosLevel(TExtOperAmpFind(eo).bands[0], p.x, cwpSignal(s).Signal);
      hi.AddPoint(p);

      p.x:=TExtOperAmpFind(eo).bands[0].f2;
      p.y:=GetPosLevel(TExtOperAmpFind(eo).bands[0], p.x, cwpSignal(s).Signal);
      hi.AddPoint(p);
    end;
    if negCB.Checked then
    begin
      p.x:=TExtOperAmpFind(eo).bands[0].f1;
      p.y:=GetNegLevel(TExtOperAmpFind(eo).bands[0], p.x, cwpSignal(s).Signal);
      lo.AddPoint(p);

      p.x:=TExtOperAmpFind(eo).bands[0].f2;
      p.y:=GetNegLevel(TExtOperAmpFind(eo).bands[0], p.x, cwpSignal(s).Signal);
      lo.AddPoint(p);
    end;
  end;
end;

procedure TFindMaxForm.BandListClick(Sender: TObject);
var
  li: tlistitem;
  str: string;
begin
  if BandList.Items.count = 0 then
    exit;
  li := BandList.Selected;
  if li = nil then
    li := BandList.Items[0];
  BandList.GetSubItemByColumnName('X1', li, str);
  X1SE.Value := strtofloat(str);
  BandList.GetSubItemByColumnName('X2', li, str);
  X2SE.Value := strtofloat(str);
  BandList.GetSubItemByColumnName('Level "+"', li, str);
  LevelPosSE.Value := strtofloat(str);
  BandList.GetSubItemByColumnName('Level "-"', li, str);
  LevelNegSE.Value := strtofloat(str);
  BandList.GetSubItemByColumnName('Noise "+"', li, str);
  NoisePosSE.Value := strtofloat(str);
  BandList.GetSubItemByColumnName('Noise "-"', li, str);
  NoiseNegSE.Value := strtofloat(str);
  BandList.GetSubItemByColumnName('Искать "+" макс.', li, str);
  PosCB.Checked := str = '+';
  BandList.GetSubItemByColumnName('Искать "-" макс.', li, str);
  negCB.Checked := str = '+';
  BandList.GetSubItemByColumnName('Единицы', li, str);
  // единицы
  if str = 'Абс.' then
  begin
    UnitsCB.ItemIndex := 0;
  end;
  if str = '%' then
  begin
    UnitsCB.ItemIndex := 1;
  end;
  if str = '20Lg' then
  begin
    UnitsCB.ItemIndex := 2;
  end;
  if str = '10Lg' then
  begin
    UnitsCB.ItemIndex := 3;
  end;
  BandList.GetSubItemByColumnName('Отклонение от среднего', li, str);
  if str = '+' then
    MOOffsetCB.Checked := true
  else
    MOOffsetCB.Checked := false;
end;

procedure TFindMaxForm.BandListResize(Sender: TObject);
begin
  LVChange(BandList);
end;

procedure TFindMaxForm.SavePathBtnClick(Sender: TObject);
begin
  if SaveDialog1.Execute(0) then
  begin
    SavePathEdit.Text := SaveDialog1.FileName;
  end;
end;

procedure TFindMaxForm.cChart1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  c: cDoublecursor;
  p2: point2;
  rec: cResRec;
begin
  if cursig<>nil then
  begin
    if Key = VK_SPACE then
    BEGIN
      c := cDoublecursor(cChart1.activePage.getChild('cDoubleCursor'));
      p2.y := tr.GetY(c.getx1);
      p2.x := c.getx1;
      rec := cResRec.create;
      rec.p.x := p2.x;
      rec.p.y := p2.y;
      if cAmpFindSignal(cursig).res=nil then
      begin
        cAmpFindSignal(cursig).res:=cResSignal.create;
      end;
      cAmpFindSignal(cursig).res.AddObj(rec);
      updatemarkers(cursig);
      ShowMarkrsInLB(cursig);
    END;
  end;
end;

procedure TFindMaxForm.DelBandBtnClick(Sender: TObject);
begin
  if BandList.Selected <> nil then
  begin
    BandList.Selected.destroy;
  end;
end;

procedure TFindMaxForm.ExpBtnClick(Sender: TObject);
var
  li: tlistitem;
  I: integer;
  str, s: string;
  f: tStringList;
  tab: char;
begin
  if NameEdit.Text = '' then
    exit;
  tab := ';';
  f := tStringList.create;
  // пишем заголовок
  s := 'X1;X2;Level "+";Level "-";Noise "+";Noise "-";Искать "+" макс.;Искать "-" макс.;Единицы';
  f.Add(s);
  for I := 0 to BandList.Items.count - 1 do
  begin
    s := '';
    li := BandList.Items[I];
    BandList.GetSubItemByColumnName('X1', li, str);
    s := s + str + ';';
    BandList.GetSubItemByColumnName('X2', li, str);
    s := s + str + ';';
    BandList.GetSubItemByColumnName('Level "+"', li, str);
    s := s + str + ';';
    BandList.GetSubItemByColumnName('Level "-"', li, str);
    s := s + str + ';';
    BandList.GetSubItemByColumnName('Noise "+"', li, str);
    s := s + str + ';';
    BandList.GetSubItemByColumnName('Noise "-"', li, str);
    s := s + str + ';';
    BandList.GetSubItemByColumnName('Искать "+" макс.', li, str);
    s := s + str + ';';
    BandList.GetSubItemByColumnName('Искать "-" макс.', li, str);
    s := s + str + ';';
    BandList.GetSubItemByColumnName('Единицы', li, str);
    s := s + str + ';';
    f.Add(s);
  end;
  if not DirectoryExists(extractfiledir(NameEdit.Text)) then
  begin
    ForceDirectories(extractfiledir(NameEdit.Text));
  end;
  f.SaveToFile(NameEdit.Text);
  f.destroy;
  NameEditChange(nil);
end;

procedure TFindMaxForm.ExtremumLBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  I: integer;
  r: cResRec;
  str: tstrings;
  // var
  // li:
begin
  if ssCtrl in Shift then
  begin
    // копируем по С
    if (Key = 67) then
    begin
      str := tStringList.create;
      str.Add(cAmpFindSignal(cursig).Name);
      str.AddStrings(ExtremumLB.Items);
      Clipboard.AsText := str.Text; // cAmpFindSignal(cursig).Name+char(0)+ExtremumLB.Items.Text;
      str.destroy;
    end;
  end;
  if Key = VK_DELETE then
  begin
    while ExtremumLB.SelCount <> 0 do
    begin
      for I := 0 to ExtremumLB.count - 1 do
      begin
        if ExtremumLB.Selected[I] then
        begin
          ExtremumLB.Items.Delete(I);
          r := cAmpFindSignal(cursig).res.getRec(I);
          cAmpFindSignal(cursig).res.RemoveObj(I);
          r.destroy;
          break;
        end;
      end;
    end;
    updatemarkers(cursig);
  end;
end;

procedure TFindMaxForm.FloatEdit1MouseEnter(Sender: TObject);
begin
  if FloatSpinEdit1.Text<>'' then
    cpage(cChart1.activePage).cursor.setx1(FloatSpinEdit1.Value);
end;

procedure TFindMaxForm.FormCreate(Sender: TObject);
begin
  load;
end;

procedure TFindMaxForm.FormDestroy(Sender: TObject);
begin
  Save;
end;

function GetTBandFromStr(str: string): tband;
var
  j, col: integer;
  s: string;
  b: tband;
begin
  col := 0;
  b := tband.create;
  for j := 1 to length(str) do
  begin
    if str[j] <> ';' then
    begin
      s := s + str[j];
    end
    else
    begin
      case col of
        0:
          b.f1 := strtofloat(s);
        1:
          b.f2 := strtofloat(s);
        2:
          b.LevelPos := strtofloat(s);
        3:
          b.LevelNeg := strtofloat(s);
        4:
          b.NoisePos := strtofloat(s);
        5:
          b.NoiseNeg := strtofloat(s);
        6:
          begin
            if s = '+' then
              b.PosRes := true
            else
              b.PosRes := false;
          end;
        7:
          begin
            if s = '+' then
              b.NegRes := true
            else
              b.NegRes := false;
          end;
        8:
          begin
            // единицы
            if s = 'Абс.' then
            begin
              b.units := u_Abs;
            end;
            if s = '%' then
            begin
              b.units := u_percent;
            end;
            if s = '10Lg' then
            begin
              b.units := u_10Lg;
            end;
            if s = '20Lg' then
            begin
              b.units := u_20Lg;
            end;
          end;
        9:
          begin
            // единицы
            if s = '+' then
              b.MO_Offset := true
            else
              b.MO_Offset := false;
          end;
      end;
      inc(col);
      s := '';
    end;
  end;
  result := b;
end;

procedure TFindMaxForm.ImportBtnClick(Sender: TObject);
var
  li: tlistitem;
  I: integer;
  str: string;
  f: tStringList;
  tab: char;
  b: tband;
begin
  if FileExists(NameEdit.Text) then
  begin
    BandList.Clear;
    f := tStringList.create;
    f.LoadFromFile(NameEdit.Text);
    for I := 1 to f.count - 1 do
    begin
      b := GetTBandFromStr(f.Strings[I]);
      AddBandToLV(b);
      b.destroy;
    end;
    f.destroy;
  end;
end;

procedure TFindMaxForm.LgYClick(Sender: TObject);
begin
  if LgY.Checked then
  begin
    cpage(cChart1.activePage).activeAxis.Lg := true;
    cChart1.redraw;
  end
  else
  begin
    cpage(cChart1.activePage).activeAxis.Lg := false;
    cChart1.redraw;
  end;
end;

procedure TFindMaxForm.NameEditChange(Sender: TObject);
var
  errorstr, res: string;
  color: tcolor;
begin
  errorstr := '';
  if not fileexists(NameEdit.Text) then
  begin
    errorstr := 'Не корректный путь к файлу';
    NameEdit.color := $008080FF;
    NameEdit.hint := errorstr;
  end
  else
  begin
    NameEdit.color := clWindow;
    NameEdit.hint := '';
  end;
end;

procedure TFindMaxForm.PathBtnClick(Sender: TObject);
begin
  if SaveDialog1.Execute(0) then
  begin
    NameEdit.Text := SaveDialog1.FileName;
  end;
end;

procedure TFindMaxForm.AssigneBand;
var
  b: tband;
  I, j: integer;
  li: tlistitem;
  str: string;
begin
  setlength(TExtOperAmpFind(eo).bands, BandList.Items.count);
  for I := 0 to BandList.Items.count - 1 do
  begin
    str := '';
    li := BandList.Items[I];
    for j := 0 to BandList.Items[I].SubItems.count - 1 do
    begin
      str := str + li.SubItems[j] + ';';
    end;
    b := GetTBandFromStr(str);
    TExtOperAmpFind(eo).bands[I] := b;
  end;
end;

procedure TFindMaxForm.Save;
var
  ifile: tinifile;
  path: string;
begin
  path := startdir + '\Opers\';
  if not DirectoryExists(path) then
    ForceDirectories(path);
  ifile := tinifile.create(path + 'FindMax.Ini');
  ifile.WriteString('Main', 'bandsPath', NameEdit.Text);
  ifile.WriteString('Main', 'SavePath', SavePathEdit.Text);
  ifile.destroy;
end;
// сохранение результатов расчета
procedure TFindMaxForm.SaveBtnClick(Sender: TObject);
var
  str, s, tab:string;
  f:tstringlist;
  i, j:integer;
  signal: cAmpFindSignal;
  о: Integer;
  rec:cResRec;
begin
  //
  tab := ';';
  f := tStringList.create;
  // пишем заголовок
  s:='';
  f.Add(s);
  f.Add('1');
  for I := 0 to SignalsLB.Count - 1 do
  begin
    signal := cAmpFindSignal(SignalsLB.Items.Objects[I]);
    if signal.res.Count>0 then
    begin
      if s='' then
        s:=signal.Name
      else
      begin
        s:=s+';;'+signal.Name;
      end;
      f.Strings[0]:=s;
      if f.Strings[1]='1' then
        f.Strings[1]:='';
      f.Strings[1]:=f.Strings[1]+'X;Y;';
    end;
    for j := 0 to signal.res.Count - 1 do
    begin
      rec:=signal.res.getRec(j);
      if j+2<f.count then
      begin
        str:=f.Strings[j+2];
        str:=str+';'+floattostr(rec.p.x)+';'+floattostr(rec.p.y);
        f.Strings[j+2]:=str;
      end
      else
      begin
        str:='';
        str:=floattostr(rec.p.x)+';'+floattostr(rec.p.y);
        f.Add(str);
      end;
    end;
  end;
  if not DirectoryExists(extractfiledir(NameEdit.Text)) then
  begin
    ForceDirectories(extractfiledir(SavePathEdit.Text));
  end;
  f.SaveToFile(SavePathEdit.Text);
  f.destroy;
  NameEditChange(nil);
end;

procedure TFindMaxForm.load;
var
  ifile: tinifile;
  path: string;
begin
  path := startdir + '\Opers\FindMax.Ini';
  if FileExists(path) then
  begin
    ifile := tinifile.create(path);
    NameEdit.Text := ifile.ReadString('Main', 'bandsPath', '');
    SavePathEdit.Text := ifile.ReadString('Main', 'SavePath', '');
    ifile.destroy;
  end;
  ImportBtnClick(nil);
end;

end.
