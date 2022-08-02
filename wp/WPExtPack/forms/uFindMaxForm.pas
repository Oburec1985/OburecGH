
unit uFindMaxForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, uSpin, ExtCtrls, uChart, uWPProc,
  Winpos_ole_TLB, PosBase, uBinFile, uComponentServises, uCommonMath,
  MathFunction,
  utrend, uAxis, upage, ubasepage, uWPProcServices, ImgList, uMarkers, uCommonTypes,
  uDoubleCursor, Clipbrd, DCL_MYOWN, Spin, inifiles, Buttons, Grids, uPoint;

type
  TFindMaxForm = class(TForm)
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    BandTS: TPageControl;
    AlgOptsTabSheet: TTabSheet;
    AlgOptsGB: TGroupBox;
    SignalsGB: TGroupBox;
    SignalsListGB: TGroupBox;
    SignalsLB: TListBox;
    ExtremumLB: TListBox;
    SavePage: TTabSheet;
    SaveDialog1: TSaveDialog;
    SaveBandGB: TGroupBox;
    NameEdit: TEdit;
    NameLabel: TLabel;
    ExpBtn: TButton;
    ImportBtn: TButton;
    PathBtn: TButton;
    GroupBox1: TGroupBox;
    MainSplitter: TSplitter;
    cChart1: cChart;
    GroupBox2: TGroupBox;
    SavePathLabel: TLabel;
    SavePathEdit: TEdit;
    LgY: TCheckBox;
    SavePathBtn: TButton;
    Splitter1: TSplitter;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    SpinEdit1: TSpinEdit;
    SaveBtn: TButton;
    ApplyBtn: TSpeedButton;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    EditBandGB: TGroupBox;
    PointsLV: TBtnListView;
    Splitter2: TSplitter;
    Panel1: TPanel;
    CurvsLB: TListBox;
    CurvsPanel: TPanel;
    DelCurv: TSpeedButton;
    AddCurv: TSpeedButton;
    CurveTypePC: TPageControl;
    Кривая: TTabSheet;
    Xlabel: TLabel;
    YLabel: TLabel;
    Yedit: TFloatEdit;
    Xedit: TFloatEdit;
    AddPoint: TSpeedButton;
    DelPoint: TSpeedButton;
    Уровень: TTabSheet;
    PositiveCB: TCheckBox;
    LvlLabel: TLabel;
    LvlFE: TFloatEdit;
    AlgTypeCB: TComboBox;
    Label3: TLabel;
    UnitsLabel: TLabel;
    UnitsCB: TComboBox;
    ThresholdLabel: TLabel;
    ThresholdE: TFloatEdit;
    procedure SavePathBtnClick(Sender: TObject);
    procedure ExpBtnClick(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure PathBtnClick(Sender: TObject);
    procedure ImportBtnClick(Sender: TObject);
    procedure DelBandBtnClick(Sender: TObject);
    procedure SignalsLBDblClick(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure cChart1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ExtremumLBKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LgYClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SignalsLBDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cChart1MovePoint(data, subdata: TObject);
    procedure AddCurvClick(Sender: TObject);
    // применить изменения из формы к полосе
    // sender - tband
    procedure AddPointClick(Sender: TObject);
    procedure CurvsLBClick(Sender: TObject);
    procedure PositiveCBClick(Sender: TObject);
    procedure DelCurvClick(Sender: TObject);
    procedure cChart1InsertPoint(data, subdata: TObject);
    procedure AlgTypeCBChange(Sender: TObject);
  public
    eo: TObject;
    mng: cWPObjMng;
    markers: cMarkerList;
    cursig: TObject;
    clip: tclipboard;
    tr: ctrend;
    curband: TObject;

  private
    function GetNotifyStr: string;
    // обновляем объект графики маркеры
    procedure updatemarkers(s: TObject);
    procedure ShowMarkrsInLB(s: TObject);
    procedure ShowSignalInChart(s: TObject);
    function GetPropertyStr: String;
    procedure ShowLevels(s: TObject);
    // отобразить свойства полосы на форме
    procedure ShowBandProperties(band: TObject);
    procedure Save;
    procedure load;
    // отобразить список сигналов
    procedure ShowSignals;
  public
    function ShowModal: Integer; override;
    // constructor create;override;
  end;

var
  FindMaxForm: TFindMaxForm;

const
  c_IndCurve = 0;
  c_IndLvl = 1;

implementation

uses
  uFindMaxOper, uWPExtPack;
{$R *.dfm}

function TFindMaxForm.GetNotifyStr: string;
begin

end;

function TFindMaxForm.ShowModal: Integer;
var
  hgraph, hpage, track: Integer;
begin
  ShowSignals;
  result := inherited ShowModal;
end;

procedure TFindMaxForm.ShowSignals;
var
  I: Integer;
  src: csrc;
  s: cwpsignal;
begin
  SignalsLB.Clear;
  src := mng.curSrc;
  if src <> nil then
  begin
    for I := 0 to src.ChildCount - 1 do
    begin
      s := src.getSignalObj(I);
      SignalsLB.AddItem(s.name, s);
    end;
  end;
end;

procedure TFindMaxForm.ShowMarkrsInLB(s: TObject);
var
  j: Integer;
  str: string;
  x, y: double;
begin
  cursig := s;
  ExtremumLB.Clear;
  // r=nil then exit;
  // заполняем лист экстремумами
  // if r.dst<>nil then
  begin
    // for j := 0 to r.dst.Count - 1 do
    begin
      // str := 'x: ' + formatstr(r.GetDstX(j), 4) + ';';
      // str := str + 'y:' + formatstr(r.GetDstY(j), 4);
      ExtremumLB.AddItem(str, nil);
    end;
  end;
end;

procedure TFindMaxForm.updatemarkers(s: TObject);
var
  I: Integer;
begin
  if markers = nil then
  begin
    markers := cMarkerList.create;
    cpage(cChart1.activePage).activeAxis.AddChild(markers);
  end
  else
    markers.Clear;
  // for I := 0 to cresultsignal(s).dst.count - 1 do
  begin
    // markers.AddMarker(p2(cresultsignal(s).GetDstX(i), cresultsignal(s).GetDstY(i)));
  end;
end;

procedure TFindMaxForm.ShowSignalInChart(s: TObject);
var
  I: Integer;
begin
  if tr = nil then
  begin
    tr := ctrend(cpage(cChart1.activePage).activeAxis.AddTrend);
    tr.drawpoint := false;
  end
  else
    tr.Clear;
  begin
    CreateTrend(tr, cwpSignal(s));
    cpage(cChart1.activePage).Normalise;
    // res:=TExtOperAmpFind(eo).GetResultSignal(cAmpFindSignal(s).Name);
    // if res<>nil then
    begin
      // updatemarkers(res)
    end;
    // else
    begin
      showmessage('Результат не посчитан для сигнала');
    end;
    cChart1.redraw;
  end;
  // ShowLevels(sig);
end;

procedure TFindMaxForm.SignalsLBDblClick(Sender: TObject);
var
  I, j: Integer;
  s:cwpsignal;
begin
  // применить
  if SignalsLB.SelCount = 1 then
  begin
    for I := 0 to SignalsLB.count - 1 do
    begin
      if SignalsLB.Selected[I] then
      begin
        s := cwpsignal(SignalsLB.Items.Objects[I]);
        // ShowMarkrsInLB(s);
        // Если активна вкладка с настройкой полос
        // Если активна вкладка результатов
        if BandTS.ActivePageIndex = 1 then
        begin
           ShowLevels(s);
           ShowSignalInChart(s);
        end;
      end;
    end;
  end;
end;

procedure TFindMaxForm.SignalsLBDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  obj: TObject;
  red: boolean;
begin
  red := false;
  with SignalsLB.Canvas do
  begin
    if red then
    begin
      Brush.Color := $008080FF;
      FillRect(Rect);
      Font.Color := clBlack; // RGB(255, 255, 255);
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

function GetStrFromBand(b: tband): string;
var
  s, str: string;
  j: Integer;
  p:cpoint2d;
begin
  str := 'bType=' + inttostr(b.btype) + ';';
  // s:='Units='+inttostr(b.units)+';';
  str := str + 'PosRes=' + BoolToStr(b.PosRes) + ';';
  str := str + 'Pcount=' + inttostr(b.count) + ';';
  s := 'Data="';
  for j := 0 to b.count - 1 do
  begin
    p := b.GetP2d(j);
    if j <> b.count - 1 then
      s := s + floattostr(p.x) + ';' + floattostr(p.y) + ';'
    else
      s := s + floattostr(p.x) + ';' + floattostr(p.y) + ';';
  end;
  str := str + s+'"';
  result := str;
end;

function TFindMaxForm.GetPropertyStr: String;
var
  props: string;
  b: tband;
  I: Integer;
begin
  props := 'Type=' + AlgTypeCB.ItemIndex;
  props := 'BandCount=' + inttostr(CurvsLB.Items.count) + ';';
  for I := 0 to CurvsLB.Items.count - 1 do
  begin
    b := tband(CurvsLB.Items.Objects[i]);
    if I > 0 then
    begin
      props := props + ';';
    end;
    props := props+inttostr(i)+'="'+GetStrFromBand(b)+'"';
  end;
  result := props;
end;

procedure TFindMaxForm.AddCurvClick(Sender: TObject);
var
  b: tband;
begin
  b := tband.create;
  CurvsLB.AddItem('Band_' + inttostr(CurvsLB.Items.count), b);
end;

procedure TFindMaxForm.AddPointClick(Sender: TObject);
begin
  if curband <> nil then
  begin
    tband(curband).AddPoint(Xedit.FloatNum, Yedit.FloatNum);
    ShowBandProperties(curband);
  end;
end;

procedure TFindMaxForm.AlgTypeCBChange(Sender: TObject);
begin
  case AlgTypeCB.ItemIndex of
    0:
    begin
      EditBandGB.Visible:=false;
    end;
    1:
    begin
      EditBandGB.Visible:=true;
    end;
  end;
end;

procedure TFindMaxForm.ShowBandProperties(band: TObject);
var
  b: tband;
  I: Integer;
  li: tlistitem;
  p: cpoint2d;
begin
  b := tband(band);
  PointsLV.Clear;
  CurveTypePC.ActivePageIndex := b.btype;
  PositiveCB.Checked := b.PosRes;
  // unitscb.ItemIndex:=band.units;
  case CurveTypePC.ActivePageIndex of
    c_IndCurve:
    begin
      for I := 0 to b.count - 1 do
      begin
        li := PointsLV.Items.Add;
        p := b.GetP2d(I);
        PointsLV.SetSubItemByColumnName('X', floattostr(p.x), li);
        PointsLV.SetSubItemByColumnName('Y', floattostr(p.y), li);
      end;
    end;
    c_IndLvl:
    begin
      // for I := 0 to PointsLV.items.Count - 1 do
      // begin
      // b.a[i].y:=LvlFE.FloatNum;
      // end;
    end;
  end;
end;

procedure TFindMaxForm.ApplyBtnClick(Sender: TObject);
var
  I, j: Integer;
  b: tband;
  s: TObject;
  str, resstr: string;
  param: OleVariant;
begin
  str := GetPropertyStr;
  // установка свойств
  TExtOperAmpFind(eo).SetPropStr(str);
  for I := 0 to SignalsLB.count - 1 do
  begin
    s := SignalsLB.Items.Objects[I];
    TExtOperAmpFind(eo).Execute(cwpsignal(s).signal);
  end;
  BringToFront;
  str := GetNotifyStr;
  param := str;
  // вызов уведомления о вызове оператора с настройками param
  TExtPack(extPack).NotifyPlugin($000F0001, param);
  if markers <> nil then
  begin
    if markers.visible then
    begin
      if markers.count <> 0 then
      begin
        // res:=TExtOperAmpFind(eo).GetResultSignal(cAmpFindSignal(cursig).Name);
        // updatemarkers(res);
        ShowLevels(cursig);
      end;
    end;
  end;
  // modalresult:=mrok;
end;

procedure TFindMaxForm.ShowLevels(s: TObject);
var
  I: Integer;
  p: point2;
  b:tBand;
  tr:ctrend;
  j: Integer;
begin
  for I := 0 to CurvsLB.Count - 1 do
  begin
    b:=tband(curvslb.Items.Objects[i]);
    tr:=cpage(cChart1.activePage).activeAxis.AddTrend;
    tr.name:='line_'+inttostr(i);
    if b.PosRes then
      tr.color:=red
    else
      tr.color:=blue;
    for j := 0 to b.count - 1 do
    begin
      p:=b.GetP2(j);
      tr.AddPoint(p);
    end;
  end;
end;

procedure TFindMaxForm.SavePathBtnClick(Sender: TObject);
begin
  if SaveDialog1.Execute(0) then
  begin
    SavePathEdit.Text := SaveDialog1.FileName;
  end;
end;

procedure TFindMaxForm.cChart1InsertPoint(data, subdata: TObject);
var
  bp: cbeziepoint;
  index, BandInd: Integer;
  p2: point2d;
  cp:cpoint2d;
  b: tband;
  r: double;
  li: tlistitem;
begin
  ctrend(data).FindPoint(cbeziepoint(subdata).point.x, index);
  p2 := p2d(cbeziepoint(subdata).point.x, cbeziepoint(subdata).point.y);
  BandInd:=strtoint(getendnum(ctrend(data).name));
  b:=tband(curvslb.Items.Objects[bandind]);
  cp:=cpoint2d.Create;
  cp.x:=p2.x;
  cp.y:=p2.y;
  b.pl.Insert(index,cp);
  if b.units = u_Abs then
  begin
    b.Setpoint(index, p2.x, p2.y);
  end
  else
  begin
    if b.units = u_percent then
    begin
      r := tr.boundrect.TopRight.y - tr.boundrect.BottomLeft.y;
      p2.y := 100 * (p2.y - tr.boundrect.BottomLeft.y) / r;
      b.Setpoint(index, p2.x, p2.y);
    end;
  end;
  ShowBandProperties(b);
end;

procedure TFindMaxForm.cChart1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  c: cDoublecursor;
  p2: point2;
begin
  if cursig <> nil then
  begin
    if Key = VK_SPACE then
    BEGIN
      c := cDoublecursor(cChart1.activePage.getChild('cDoubleCursor'));
      p2.y := tr.GetY(c.getx1);
      p2.x := c.getx1;
      if cursig <> nil then
      begin
        // if cursig is cAmpFindSignal then
        // s:=TExtOperAmpFind(eo).GetResultSignal(cAmpFindSignal(cursig).Name);
      end;
      // if s=nil then exit;
      // if s.dst<>nil then
      // begin
      // s.addMarker(p2.x,p2.y);
      // end;
      // updatemarkers(s);
      ShowMarkrsInLB(cursig);
    END;
    if Key = VK_INSERT then
    BEGIN
    END;
  end;
end;

procedure TFindMaxForm.cChart1MovePoint(data, subdata: TObject);
var
  bp: cbeziepoint;
  index, BandInd: Integer;
  p2: point2d;
  b: tband;
  r: double;
  li: tlistitem;
begin
  ctrend(data).FindPoint(cbeziepoint(subdata).point.x, index);
  p2 := p2d(cbeziepoint(subdata).point.x, cbeziepoint(subdata).point.y);
  BandInd:=strtoint(getendnum(ctrend(data).name));
  b:=tband(curvslb.Items.Objects[bandind]);
  if b.units = u_Abs then
  begin
    b.Setpoint(index, p2.x, p2.y);
  end
  else
  begin
    if b.units = u_percent then
    begin
      r := tr.boundrect.TopRight.y - tr.boundrect.BottomLeft.y;
      p2.y := 100 * (p2.y - tr.boundrect.BottomLeft.y) / r;
      b.Setpoint(index, p2.x, p2.y);
    end;
  end;
  ShowBandProperties(b);
end;

procedure TFindMaxForm.CurvsLBClick(Sender: TObject);
var
  I: Integer;
  b: tband;
begin
  if CurvsLB.SelCount > 0 then
  begin
    for I := 0 to CurvsLB.Items.count - 1 do
    begin
      if CurvsLB.Selected[I] then
      begin
        b := tband(CurvsLB.Items.Objects[I]);
        ShowBandProperties(b);
        curband := b;
      end;
    end;
  end;
end;

procedure TFindMaxForm.DelBandBtnClick(Sender: TObject);
begin
  { if BandList.Selected <> nil then
    begin
    BandList.Selected.destroy;
    end; }
end;

procedure TFindMaxForm.DelCurvClick(Sender: TObject);
var
  i:integer;
begin
  if curband<>nil then
  begin
    for I := 0 to CurvsLB.Items.Count - 1 do
    begin
      if CurvsLB.Items.Objects[i]=curband then
      begin
        tBand(curband).destroy;
        CurvsLB.Items.Delete(i);
        curband:=nil;
        exit;
      end;
    end;
  end;
end;

procedure TFindMaxForm.ExpBtnClick(Sender: TObject);
var
  I, j: Integer;
  str, s: string;
  f: tStringList;
  tab: char;
  b: tband;
  p: cpoint2d;
begin
  if NameEdit.Text = '' then
    exit;
  tab := ';';
  f := tStringList.create;
  case AlgTypeCB.ItemIndex of
    0:
    begin
      s := 'Units='+inttostr(UnitsCB.ItemIndex)+';'+'Level='+floattostr(ThresholdE.FloatNum);
      f.Add(str);
    end;
    1:
    begin
      // пишем заголовок
      s := 'bType;Units;PosRes;pCount;Data';
      f.Add(s);
      for I := 0 to CurvsLB.Items.count - 1 do
      begin
        s := '';
        b := tband(CurvsLB.Items.Objects[I]);
        str:=GetStrFromBand(b);
        str := str + s+'"';
        f.Add(str);
      end;
    end;
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
  I: Integer;
  str: tstrings;
  // res:cresultsignal;
  // var
  // li:
begin
  if ssCtrl in Shift then
  begin
    // копируем по С
    if (Key = 67) then
    begin
      str := tStringList.create;
      // str.Add(cAmpFindSignal(cursig).Name);
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
          // res :=TExtOperAmpFind(eo).GetResultSignal(cAmpFindSignal(cursig).Name);
          // res.DelMarker(I);
          break;
        end;
      end;
    end;
    // res:=TExtOperAmpFind(eo).GetResultSignal(trimname(cAmpFindSignal(cursig).name));
    // updatemarkers(res);
  end;
end;

procedure TFindMaxForm.FormCreate(Sender: TObject);
begin
  load;
end;

procedure TFindMaxForm.FormDestroy(Sender: TObject);
begin
  Save;
end;

procedure TFindMaxForm.ImportBtnClick(Sender: TObject);
var
  li: tlistitem;
  I: Integer;
  str: string;
  f: tStringList;
  tab: char;
  b: tband;
begin
  if FileExists(NameEdit.Text) then
  begin
    f := tStringList.create;
    f.LoadFromFile(NameEdit.Text);
    if pos('Units', f.Strings[0])=1 then
    begin
      AlgTypeCb.ItemIndex:=0;
      str:=GetParam(f.Strings[0], 'Units');
      UnitsCB.ItemIndex:=strtoint(str);
      str:=GetParam(f.Strings[0], 'Threshold');
      ThresholdE.FloatNum:=strtofloat(str);
    end
    else
    begin
      AlgTypeCb.ItemIndex:=1;
      for I := 1 to f.count - 1 do
      begin
        b := GetTBandFromStr(f.Strings[I]);
      end;
      CurvsLB.AddItem('Band_' + inttostr(CurvsLB.Items.count), b);
    end;
    f.destroy;
  end;
end;

procedure TFindMaxForm.LgYClick(Sender: TObject);
begin
  if LgY.Checked then
  begin
    cpage(cChart1.activePage).activeAxis.Lg := true;
    cChart1.Invalidate;
  end
  else
  begin
    cpage(cChart1.activePage).activeAxis.Lg := false;
    cChart1.Invalidate;
  end;
end;

procedure TFindMaxForm.NameEditChange(Sender: TObject);
var
  errorstr, res: string;
  Color: tcolor;
begin
  errorstr := '';
  if not FileExists(NameEdit.Text) then
  begin
    errorstr := 'Не корректный путь к файлу';
    NameEdit.Color := $008080FF;
    NameEdit.hint := errorstr;
  end
  else
  begin
    NameEdit.Color := clWindow;
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

procedure TFindMaxForm.PositiveCBClick(Sender: TObject);
begin
  if curband<>nil then
  begin
    tband(curband).PosRes:=PositiveCB.Checked;
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
