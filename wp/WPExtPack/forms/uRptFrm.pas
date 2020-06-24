unit uRptFrm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls, uWPProc,
  Winpos_ole_TLB, PosBase, uBinFile, uComponentServises, uCommonMath,
  MathFunction, uWPServices, ImgList, uMarkers, uCommonTypes, shellapi,
  uDoubleCursor, Clipbrd, DCL_MYOWN, Spin, inifiles, Buttons, uWPExtOperRpt,
  uWpExtPack,
  VirtualTrees,
  uVTServices,
  ComCtrls,
  uBtnListView,
  uPathMng,
  uSpmFrm,
  uMeasureBase,
  uWPProcServices,
  uEditSignalsRepPropFrn,
  Menus, uTmpltNameFrame;

type
  RptBand = class
  public
    P2d: point2d;
    P2i: tpoint;
    trigname1, trigname2: string;
    shift1, shift2: double;
    // тип 0 -физ, 1 - индексы, 2 - триггеры
    bandType: integer;
  private
    fTrig1, ftrig2: ctrig;
  protected
    procedure settrig1(t: ctrig);
    procedure settrig2(t: ctrig);
  public
    property trig1: ctrig read fTrig1 write settrig1;
    property trig2: ctrig read ftrig2 write settrig2;
  end;

  TRptFrm = class(TForm)
    Panel2: TPanel;
    ApplyBtn: TSpeedButton;
    AddBtn: TSpeedButton;
    DelBtn: TSpeedButton;
    TopGB: TGroupBox;
    ReportTypeRG: TRadioGroup;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    Splitter1: TSplitter;
    LoadCfgCB: TComboBox;
    Label8: TLabel;
    LoadBtn: TButton;
    Panel5: TPanel;
    BandsSG: TStringGrid;
    BandsTC: TPageControl;
    TabSheet1: TTabSheet;
    X1Label: TLabel;
    X2Label: TLabel;
    X2FE: TFloatEdit;
    X1FE: TFloatEdit;
    TabSheet2: TTabSheet;
    Label4: TLabel;
    Label5: TLabel;
    X1IE: TIntEdit;
    X2IE: TIntEdit;
    Триггеры: TTabSheet;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    X1CB: TComboBox;
    X2CB: TComboBox;
    ShiftTrig1FE: TFloatEdit;
    ShiftTrig2FE: TFloatEdit;
    Trig1Res: TFloatEdit;
    Trig2Res: TFloatEdit;
    Splitter2: TSplitter;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    UpdateBandBtn: TSpeedButton;
    AbsDropToStartBtn: TButton;
    AbsDropToEndBtn: TButton;
    Panel1: TPanel;
    AutoBandsCB: TCheckBox;
    SaveCfgCB: TComboBox;
    SaveCfgLabel: TLabel;
    SaveCfgBtn: TButton;
    RightPanel: TPanel;
    RightPC: TPageControl;
    SignalsTS: TTabSheet;
    OptionsTS: TTabSheet;
    SignalsTV: TVTree;
    OptsLV: TBtnListView;
    BandPanel: TPanel;
    MaxColCountLabel: TLabel;
    Label15: TLabel;
    OpenFileCB: TCheckBox;
    MaxColCount: TIntEdit;
    SetEstNamesCB: TCheckBox;
    SpmEdit: TEdit;
    SpmBtn: TButton;
    RepFilterCB: TCheckBox;
    FltName: TEdit;
    ParamsGB: TGroupBox;
    ParamsLB: TListBox;
    Panel3: TPanel;
    Panel4: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    ParamNameEdit: TEdit;
    ApplyParamBtn: TButton;
    ParamValEdit: TEdit;
    AddParamBtn: TButton;
    DelParamBtn: TButton;
    ParamsPropLV: TBtnListView;
    TmpltNameFrame1: TTmpltNameFrame;
    SelectAllEstsCB: TCheckBox;
    CursorRngBtn: TButton;
    StayOnTopBtn: TSpeedButton;
    EditFltBtn: TButton;
    UseMDBCB: TCheckBox;
    EvalMaxLengthCB: TCheckBox;
    AutoBandsPC: TPageControl;
    AutoBandsIntervalPage: TTabSheet;
    Label3: TLabel;
    Label14: TLabel;
    AutoBandLengthFE: TFloatEdit;
    AutoBandIntervalShiftFE: TFloatEdit;
    TabSheet3: TTabSheet;
    AutoBandChannelCB: TComboBox;
    Label16: TLabel;
    AutoBOffset2: TFloatEdit;
    AutoBOffset1: TFloatEdit;
    Label17: TLabel;
    Label18: TLabel;
    BandCountIE: TIntEdit;
    AutoBandsCountLabel: TLabel;
    Label13: TLabel;
    Threshold: TFloatEdit;
    procedure AddBtnClick(Sender: TObject);
    procedure TrigsRGClick(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure SignalsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure SignalsTVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DelBtnClick(Sender: TObject);
    procedure BandsSGSelectCell(Sender: TObject; ACol, ARow: integer;
      var CanSelect: Boolean);
    procedure ReportTypeRGClick(Sender: TObject);
    procedure MaxColCountChange(Sender: TObject);
    procedure ApplyBandTypeBtnClick(Sender: TObject);
    procedure BandsSGEnter(Sender: TObject);
    procedure BandsSGSetEditText(Sender: TObject; ACol, ARow: integer;
      const Value: string);
    procedure LoadBtnClick(Sender: TObject);
    procedure SelectAllEstsCBClick(Sender: TObject);
    procedure X1CBChange(Sender: TObject);
    procedure X2CBChange(Sender: TObject);
    procedure ParamsLBClick(Sender: TObject);
    procedure AddParamBtnClick(Sender: TObject);
    procedure ParamsPropLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ApplyParamBtnClick(Sender: TObject);
    procedure OptsLVClick(Sender: TObject);
    procedure OptsLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure N2Click(Sender: TObject);
    procedure UpdateBandBtnClick(Sender: TObject);
    procedure AbsDropToStartBtnClick(Sender: TObject);
    procedure AbsDropToEndBtnClick(Sender: TObject);
    procedure AutoBandsCBClick(Sender: TObject);
    procedure AutoBandLengthFEChange(Sender: TObject);
    procedure SpmBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveCfgBtnClick(Sender: TObject);
    procedure StayOnTopBtnClick(Sender: TObject);
    procedure EditFltBtnClick(Sender: TObject);
    procedure TmpltNameFrame1MakeDefaultNameBtnClick(Sender: TObject);
    procedure TmpltNameFrame1PathBtnClick(Sender: TObject);
    procedure UseMDBCBClick(Sender: TObject);
    procedure AutoBandChannelCBChange(Sender: TObject);
    procedure TmpltNameFrame1FolderRGClick(Sender: TObject);
    procedure TmpltNameFrame1NameRGClick(Sender: TObject);
  private
    eo: TObject;
    mng: cWPObjMng;
    // невозможно создать выходной файл
    invalidpath: Boolean;
    selectInd: integer;
  private
    procedure UpdateParams(itemName: string);
    procedure InitSG;
    procedure InitParamsLB;

    procedure SaveCfg;
    procedure LoadCfg(fname: string); overload;
    procedure LoadCfg; overload;

    procedure clearBands;
    procedure UpdateTrigs;
    procedure UpdateTrigVals;
    // если файл для обработки алгоритмом не ссылается на мера файл,
    // то путь должен быть абсолютным
    procedure LoadDefaultCfg;
    procedure ShowSrcSignals;
    function GetNotifyStr: string;
    function GetSelectSrc: csrc;
    function CreateBound: RptBand;
    function GetBound(ind: integer): RptBand;
    // Расчет
    function GetEst(str: string): Boolean;
    procedure ShowProperties;
    procedure ApplyOpts;
    procedure addBandToSg(b: RptBand; index: integer); overload;
    procedure addBandToSg(b: RptBand); overload;
    // происходит при обновлении источника данных
    procedure UpdateSrc(src: csrc);
    procedure ShowSrcInCB(src:csrc);
    procedure CheckMDBPath(src:csrc);
    // получить источник из SignalsTV
    function GetSrc(i:integer):csrc;
    procedure EvalBandsByChannel;
  public
    procedure addcursorband;
    procedure Init(oper: TObject; p_mng: cWPObjMng);
    function GetPropertyStr: string;
    // перенос опций в оператор
    procedure SetPropertyStr(str: string);
    function EditOper: integer;
  end;

var
  RptFrm: TRptFrm;

const
  c_RMS_Name = 'СКЗ в полосе';
  c_N_Name = 'Подсчет импульсов';
  c_A1_Name = 'Максимум в полосе';

  c_SRCindex = 18;
  c_SignalIndex = 22;
  c_Excel = 0;
  c_Word = 1;

  c_bandType_phis = 0;
  c_bandType_ind = 1;
  c_bandType_trig = 2;

implementation

{$R *.dfm}


function GetSelItemFromLB(LB: TListBox): string;
var
  Item: pointer;
  I: integer;
begin
  result := '';
  for I := 0 to LB.Count - 1 do
  begin
    if LB.Selected[I] then
    begin
      result := LB.Items.Strings[I];
      exit;
    end;
  end;
end;

function GetParamValFromLV(lv: TBtnListView; param: string): string;
var
  I: integer;
  li: TListItem;
  str: string;
begin
  result := '';
  for I := 0 to lv.Items.Count - 1 do
  begin
    li := lv.Items[I];
    lv.GetSubItemByColumnName('Имя', li, str);
    if str = param then
    begin
      lv.GetSubItemByColumnName('Значение', li, str);
      result := str;
      exit;
    end;
  end;
end;

procedure TRptFrm.ShowSrcSignals;
var
  I, j: integer;
  s: cwpSignal;
  Node, parentNode: PVirtualNode;
  d: pnodedata;
  src: csrc;
begin
  SignalsTV.clear;
  // отображаем все
  for I := 0 to mng.SrcCount - 1 do
  begin
    parentNode := SignalsTV.AddChild(nil);
    d := SignalsTV.GetNodeData(parentNode);
    d.color := SignalsTV.normalcolor;
    d.imageindex := c_SRCindex;
    src := mng.GetSrc(I); ;
    d.data := src;
    d.caption := src.name;
    for j := 0 to src.childCount - 1 do
    begin
      s := src.getSignalObj(j);
      Node := SignalsTV.AddChild(parentNode);
      d := SignalsTV.GetNodeData(Node);
      d.color := SignalsTV.normalcolor;
      d.imageindex := c_SignalIndex;
      d.data := s;
      d.caption := s.name;
    end;
  end;
end;

procedure TRptFrm.SignalsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  TrigsRGClick(nil);
end;

procedure TRptFrm.SignalsTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Node, child: PVirtualNode;
  data: pnodedata;
begin
  if Key = VK_DELETE then
  begin
    SignalsTV.DeleteSelectedNodes;
  end;
end;

procedure TRptFrm.SpmBtnClick(Sender: TObject);
begin
  SpmEdit.Text := SpmFrm.ShowmodalEx(SpmEdit.Text);
end;

procedure TRptFrm.StayOnTopBtnClick(Sender: TObject);
begin
  if FormStyle = fsNormal then
  begin
    FormStyle := fsStayOnTop;
    StayOnTopBtn.Hint := 'Поверх окон';
    StayOnTopBtn.Down := true;
  end
  else
  begin
    FormStyle := fsNormal;
    StayOnTopBtn.Down := false;
    StayOnTopBtn.Hint := 'Скрывать окно';
  end;
end;

procedure DeleteRowFromStringGrid(Grid: TStringGrid; ARow: integer);
var
  Count, row, I: integer;
begin
  Count := Grid.RowCount; // всего строк
  row := Grid.row; // выбранная строка
  if (Count - Grid.FixedRows <= 1) then
    exit; // оставляет по крайней мере одну строку
  // --------------------------- Смещаем строки вверх ------------------------
  for I := ARow to Count - 1 do
  begin
    Grid.Rows[I] := Grid.Rows[I + 1];
  end;
  // --------------------------------------------------------------------------
  Grid.RowCount := Grid.RowCount - 1;
  Grid.SetFocus();
end;

procedure TRptFrm.DelBtnClick(Sender: TObject);
var
  b: RptBand;
begin
  b := RptBand(BandsSG.Rows[selectInd].Objects[0]);
  if b <> nil then
  begin
    b.Destroy;
    DeleteRowFromStringGrid(BandsSG, selectInd);
  end;
end;

procedure TRptFrm.clearBands;
var
  I: integer;
  b: RptBand;
begin
  for I := 0 to BandsSG.RowCount - 1 do
  begin
    b := RptBand(BandsSG.Rows[I].Objects[0]);
    b.Destroy;
  end;
  BandsSG.RowCount := 0;
end;

procedure TRptFrm.SaveCfg;
var
  ifile: tinifile;
  str: string;
  I, dynCount: integer;
  o: cOptRecord;
  s:cwpsignal;
begin
  ifile := tinifile.Create(startDir + '\Opers\RptOper.ini');
  str := GetPropertyStr;
  // настройка сохранения оценок
  ifile.WriteString('Main', 'SavePath', SaveCfgCB.Text);
  ifile.WriteString('Main', 'LoadCfg', LoadCfgCB.Text);

  ifile.WriteString('Main', 'SpmCfg', SpmEdit.Text);
  ifile.WriteString('Main', 'Cfg', str);
  ifile.WriteBool('Main', 'OpenFile', OpenFileCB.Checked);
  ifile.WriteBool('Main', 'Filter', RepFilterCB.Checked);
  ifile.WriteBool('Main', 'UseMDB', UseMDBCB.Checked);

  ifile.WriteBool('Main', 'AutoBands', AutoBandsCB.Checked);
  ifile.WriteFloat('Main', 'AutoBandsLen', AutoBandLengthFE.FloatNum);
  ifile.WriteFloat('Main', 'AutoBandsShift', AutoBandIntervalShiftFE.FloatNum);

  ifile.WriteInteger('Main', 'AutoBandsType', AutoBandsPC.ActivePageIndex);
  s:=cwpsignal(GetComboBoxItem(autobandchannelcb));
  if s<>nil then
    ifile.WriteString('Main', 'AutoBandsChannel', s.name)
  else
    ifile.WriteString('Main', 'AutoBandsChannel', '');
  ifile.WriteFloat('Main', 'AutoBandsOffset1', AutoBOffset1.FloatNum);
  ifile.WriteFloat('Main', 'AutoBandsOffset2', AutoBOffset2.FloatNum);


  ifile.WriteString('Main', 'FltName', FltName.Text);

  ifile.WriteInteger('Main', 'RepType', ReportTypeRG.ItemIndex);

  dynCount := 0;
  for I := 0 to OptsLV.Items.Count - 1 do
  begin
    o := cOptRecord(OptsLV.Items[I].data);
    ifile.WriteBool('Estimate', o.name, OptsLV.Items[I].Checked);
    if o.dyn then
    begin
      if o.estType <> '' then
      begin
        str := 'Est_' + inttostr(dynCount);
        ifile.WriteString(str, 'esttype', o.estType);
        ifile.WriteString(str, 'Name', o.Name);
        ifile.WriteBool(str, 'Enabled', o.eval);
        if o.estType = c_estType_A1 then
        begin
          ifile.WriteFloat(str, 'F1', o.band.x);
          ifile.WriteFloat(str, 'F2', o.band.y);
        end;
        if o.estType = c_estType_N then
        begin
          ifile.WriteFloat(str, 'T1', o.band.x);
          ifile.WriteFloat(str, 'T2', o.band.y);
          ifile.WriteBool(str, 'Perc', o.percent);
        end;
        if o.estType = c_estType_Rms then
        begin
          ifile.WriteFloat(str, 'F1', o.band.x);
          ifile.WriteFloat(str, 'F2', o.band.y);
          ifile.WriteBool(str, 'Perc', o.percent);
        end;
      end;
      inc(dynCount);
    end;
  end;
  // ifile.WriteFloat('Main', 'F1', rmsF1.floatnum);
  // ifile.WriteFloat('Main', 'F2', rmsF2.floatnum);
  ifile.Destroy;
end;

procedure TRptFrm.SaveCfgBtnClick(Sender: TObject);
begin
  SaveCfg;
  TmpltNameFrame1.SaveParams;
end;

procedure TRptFrm.UpdateTrigVals;
var
  t: ctrig;
  src: csrc;
begin
  src := GetSelectSrc;
  if src = nil then
    exit;
  if X1CB.ItemIndex > -1 then
  begin
    t := ctrig(X1CB.Items.Objects[X1CB.ItemIndex]);
    if t <> nil then
    begin
      Trig1Res.FloatNum := t.GetTime(src);
    end;
  end;
  if X2CB.ItemIndex > -1 then
  begin
    t := ctrig(X2CB.Items.Objects[X2CB.ItemIndex]);
    if t <> nil then
    begin
      Trig2Res.FloatNum := t.GetTime(src);
    end;
  end;
end;

procedure TRptFrm.UseMDBCBClick(Sender: TObject);
begin
  if usemdbcb.checked then
    CheckMDBPath(GetSrc(0));
end;

procedure TRptFrm.UpdateTrigs;
var
  I: integer;
  tr: ctrig;
begin
  X1CB.clear;
  X2CB.clear;
  for I := 0 to mng.TrigList.Count - 1 do
  begin
    tr := mng.getTrig(I);
    X1CB.Items.AddObject(tr.id, tr);
    X2CB.Items.AddObject(tr.id, tr);
  end;
  X1CB.ItemIndex := -1;
  X2CB.ItemIndex := -1;
end;

procedure TRptFrm.X1CBChange(Sender: TObject);
var
  t: ctrig;
  src: csrc;
begin
  t := ctrig(X1CB.Items.Objects[X1CB.ItemIndex]);
  if t <> nil then
  begin
    src := GetSelectSrc;
    if src <> nil then
      Trig1Res.FloatNum := t.GetTime(src);
  end;
end;

procedure TRptFrm.X2CBChange(Sender: TObject);
var
  t: ctrig;
  src: csrc;
begin
  t := ctrig(X2CB.Items.Objects[X2CB.ItemIndex]);
  if t <> nil then
  begin
    src := GetSelectSrc;
    if src <> nil then
      Trig2Res.FloatNum := t.GetTime(src);
  end;
end;

procedure TRptFrm.LoadDefaultCfg;
var
  pmng: cPathMng;
begin
  LoadCfgCB.Items.clear;
  pmng := cPathMng.Create('');
  pmng.FillFileList(startDir + '\Opers\' + '\RptCfg\', LoadCfgCB.Items);
  if LoadCfgCB.Items.Count > 0 then
    LoadCfgCB.ItemIndex := 0;
  pmng.Destroy;
end;

procedure TRptFrm.LoadCfg;
var
  ifile: tinifile;
  str: string;
begin
  str := startDir + '\Opers\' + 'RptOper.ini';
  TmpltNameFrame1.LoadParams;
  LoadCfg(str);
  ifile := tinifile.Create(str);

  SaveCfgCB.Text := ifile.ReadString('Main', 'SavePath', str);
  LoadCfgCB.Text := ifile.ReadString('Main', 'LoadCfg', str);

  ifile.Destroy;
end;

procedure TRptFrm.LoadCfg(fname: string);
var
  ifile: tinifile;
  src, str, sval: string;
  p2: point2d;
  I, j: integer;
  b: RptBand;
  pars: tstringlist;
  find: Boolean;
  o: cOptRecord;
  li: TListItem;
begin
  ifile := tinifile.Create(fname);
  src := ifile.ReadString('Main', 'Cfg', '');

  SpmEdit.Text := ifile.ReadString('Main', 'SpmCfg', c_spmopts);
  OpenFileCB.Checked := ifile.ReadBool('Main', 'OpenFile', false);
  RepFilterCB.Checked := ifile.ReadBool('Main', 'Filter', false);

  UseMDBCB.Checked:=ifile.ReadBool('Main', 'UseMDB', false);

  AutoBandsCB.Checked:=ifile.ReadBool('Main', 'AutoBands', false);
  AutoBandLengthFE.FloatNum:=ifile.ReadFloat('Main', 'AutoBandsLen', 1);
  AutoBandIntervalShiftFE.FloatNum:=ifile.ReadFloat('Main', 'AutoBandsShift', 0);

  AutoBandsPC.ActivePageIndex:=ifile.ReadInteger('Main', 'AutoBandsType', 0);
  str:=ifile.ReadString('Main', 'AutoBandsChannel', '');
  setComboBoxItem(str,autobandchannelcb);
  AutoBOffset1.FloatNum:=ifile.readFloat('Main', 'AutoBandsOffset1', 0);
  AutoBOffset2.FloatNum:=ifile.readFloat('Main', 'AutoBandsOffset2', 0);


  FltName.Text := ifile.ReadString('Main', 'FltName', '.XLSRep');
  str := src;
  if str = '' then
  begin

  end
  else
  begin
    pars := ParsStrParamExt(str, ';', '"');
    str := GetParsValue(pars, 'BandCount');
    BandsSG.RowCount := StrToInt(str) + 1;
    str := GetParsValue(pars, 'X');
    j := 0;

    for I := 1 to BandsSG.RowCount - 1 do
    begin
      b := RptBand.Create;
      sval := GetSubString(str, ';', j + 1, j);
      if not isValue(sval) then
      begin
        showmessage('Файл конфигурации отчета поврежден');
        exit;
      end;
      // тип 0 -физ, 1 - индексы, 2 - триггеры
      b.bandType := StrToInt(sval);
      case b.bandType of
        c_bandType_phis:
          begin
            sval := GetSubString(str, ';', j + 1, j);
            b.P2d.x := strtofloatext(sval);
            sval := GetSubString(str, ';', j + 1, j);
            b.P2d.y := strtofloatext(sval);
          end;
        c_bandType_ind:
          begin
            sval := GetSubString(str, ';', j + 1, j);
            b.P2i.x := StrToInt(sval);
            sval := GetSubString(str, ';', j + 1, j);
            b.P2i.y := StrToInt(sval);
          end;
        c_bandType_trig:
          begin
            // имя старта
            sval := GetSubString(str, ';', j + 1, j);
            b.trig1 := mng.getTrig(sval);
            b.trigname1 := sval;
            // имя стопа
            sval := GetSubString(str, ';', j + 1, j);
            b.trig2 := mng.getTrig(sval);
            b.trigname2 := sval;
            // сдвиг 1
            sval := GetSubString(str, ';', j + 1, j);
            b.shift1 := strtofloatext(sval);
            // сдвиг 2
            sval := GetSubString(str, ';', j + 1, j);
            b.shift2 := strtofloatext(sval);
          end;
      end;
      addBandToSg(b, I);
    end;
    TmpltNameFrame1.SavePathEdit.Text := GetParsValue(pars, 'SavePath');
    SetPropertyStr(src);
  end;

  sval := GetParsValue(pars, 'MaxColCount');
  if sval <> '_' then
    MaxColCount.IntNum := StrToInt(sval);

  sval := GetParsValue(pars, 'SetEstNames');
  SetEstNamesCB.Checked := sval = '1';

  ReportTypeRG.ItemIndex := ifile.ReadInteger('Main', 'RepType', 0);
  ReportTypeRGClick(nil);

  pars.clear;
  pars.Sorted := true;
  ifile.ReadSection('Estimate', pars);
  for I := 0 to tExtOperRpt(eo).opts.Count - 1 do
  begin
    o := cOptRecord(OptsLV.Items[I].data);
    o.eval := ifile.ReadBool('Estimate', o.name, true);
    OptsLV.Items[I].Checked := o.eval;
  end;
  // зачищаем лишние опции
  I := 0;
  while I < OptsLV.Items.Count do
  begin
    li := OptsLV.Items[I];
    if cOptRecord(li.data).dyn then
    begin
      tExtOperRpt(eo).DelEsimate(cOptRecord(li.data).name);
      li.Destroy;
      continue;
    end;
    inc(I);
  end;

  pars.clear;
  pars.Sorted := true;
  ifile.ReadSections(pars);
  for I := 0 to pars.Count - 1 do
  begin
    if pos('Est_', pars.Strings[I]) > 0 then
    begin
      o := cOptRecord.Create;
      o.dyn := true;
      o.name := ifile.ReadString(pars.Strings[I], 'Name', '');
      o.estType := ifile.ReadString(pars.Strings[I], 'esttype', '');
      o.eval := ifile.ReadBool(pars.Strings[I], 'Enabled', true);
      if o.estType = c_estType_A1 then
      begin
        // занимает 2 колонки
        o.size := 2;
        o.band.x := ifile.ReadFloat(pars.Strings[I], 'F1', 0);
        o.band.y := ifile.ReadFloat(pars.Strings[I], 'F2', 0);
      end;
      if o.estType = c_estType_Rms then
      begin
        // занимает 2 колонки
        o.size := 1;
        o.percent := ifile.ReadBool(pars.Strings[I], 'Perc', false);
        o.band.x := ifile.ReadFloat(pars.Strings[I], 'F1', 0);
        o.band.y := ifile.ReadFloat(pars.Strings[I], 'F2', 0);
      end;
      if o.estType = c_estType_N then
      begin
        // занимает 2 колонки
        o.size := 1;
        o.percent := ifile.ReadBool(pars.Strings[I], 'Perc', false);
        o.band.x := ifile.ReadFloat(pars.Strings[I], 'T1', 0);
        o.band.y := ifile.ReadFloat(pars.Strings[I], 'T2', 0);
      end;
      tExtOperRpt(eo).AddEsimate(o);
    end;
  end;

  pars.Destroy;
  ifile.Destroy;
end;

procedure TRptFrm.LoadBtnClick(Sender: TObject);
begin
  LoadCfg(LoadCfgCB.Text);
end;

procedure TRptFrm.MaxColCountChange(Sender: TObject);
begin
  if MaxColCount.IntNum < 1 then
    MaxColCount.IntNum := 1;
end;

procedure TRptFrm.N2Click(Sender: TObject);
var
  str: string;
begin
  // Параметры расчета спектра
  tExtOperRpt(eo).setSmpOpts(SpmFrm.ShowmodalEx(tExtOperRpt(eo).getsmpopts));
end;

procedure TRptFrm.OptsLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  OptsLVClick(nil);
end;

procedure TRptFrm.OptsLVClick(Sender: TObject);
var
  li: TListItem;
  opt: cOptRecord;
  I: integer;
  str: string;
begin
  li := OptsLV.Selected;
  if li = nil then
    exit;
  opt := cOptRecord(li.data);
  if (opt.estType = c_estType_A1) then
  begin
    ParamsLB.ClearSelection;
    ParamsLB.Selected[0] := true;
    str := GetSelItemFromLB(ParamsLB);
    UpdateParams(str);
    opt.eval := li.Checked;
  end;
  if (opt.estType = c_estType_N) then
  begin
    ParamsLB.ClearSelection;
    ParamsLB.Selected[1] := true;
    str := GetSelItemFromLB(ParamsLB);
    UpdateParams(str);
    opt.eval := li.Checked;
  end;
  if (opt.estType = c_estType_Rms) then
  begin
    ParamsLB.ClearSelection;
    ParamsLB.Selected[2] := true;
    str := GetSelItemFromLB(ParamsLB);
    UpdateParams(str);
    opt.eval := li.Checked;
  end;
end;

procedure TRptFrm.ReportTypeRGClick(Sender: TObject);
begin
  if ReportTypeRG.ItemIndex = c_Excel then
  begin
    TmpltNameFrame1.SavePathEdit.Text := TrimExt
      (TmpltNameFrame1.SavePathEdit.Text);
    TmpltNameFrame1.SavePathEdit.Text := TmpltNameFrame1.SavePathEdit.Text +
      '.xlsx';
    // word
    MaxColCountLabel.Visible := true;
    MaxColCount.Visible := true;
    SetEstNamesCB.Visible := true;
  end;
  if ReportTypeRG.ItemIndex = c_Word then
  begin
    TmpltNameFrame1.SavePathEdit.Text := TrimExt
      (TmpltNameFrame1.SavePathEdit.Text);
    TmpltNameFrame1.SavePathEdit.Text := TmpltNameFrame1.SavePathEdit.Text +
      '.docx';
    // word
    MaxColCountLabel.Visible := true;
    MaxColCount.Visible := true;
    SetEstNamesCB.Visible := true;
  end;
end;

procedure TRptFrm.InitSG;
begin
  BandsSG.ColCount := 4;
  BandsSG.Cells[1, 0] := 'X1';
  BandsSG.Cells[2, 0] := 'X2';
  BandsSG.Cells[3, 0] := 'Тип';
  BandsSG.RowCount := 1;
end;

procedure TRptFrm.ApplyOpts;
var
  I: integer;
  li: TListItem;
begin
  for I := 0 to OptsLV.Items.Count - 1 do
  begin
    li := OptsLV.Items[I];
    cOptRecord(li.data).eval := li.Checked;
  end;
end;

function TRptFrm.GetEst(str: string): Boolean;
var
  li: TListItem;
  o: cOptRecord;
  I: integer;
begin
  result := false;
  for I := 0 to OptsLV.Items.Count - 1 do
  begin
    li := OptsLV.Items[I];
    o := cOptRecord(li.data);
    if o.name = str then
    begin
      result := true;
    end;
  end;
end;

procedure TRptFrm.ShowProperties;
var
  I: integer;
  li: TListItem;
  o: cOptRecord;
begin
  UpdateTrigs;
  OptsLV.clear;
  for I := 0 to tExtOperRpt(eo).opts.Count - 1 do
  begin
    li := OptsLV.Items.Add;
    o := cOptRecord(tExtOperRpt(eo).opts.Objects[I]);
    li.caption := o.name;
    li.Checked := o.eval;
    li.data := o;
    OptsLV.SetSubItemByColumnName('Описание', o.getdsc, li);
  end;
  SpmEdit.Text := tExtOperRpt(eo).m_spmOpts;
end;

procedure TRptFrm.ParamsLBClick(Sender: TObject);
var
  Item: pointer;
  I: integer;
  str: string;
begin
  str := GetSelItemFromLB(ParamsLB);
  if str <> '' then
    UpdateParams(str);
end;

procedure TRptFrm.ParamsPropLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  str: string;
begin
  ParamsPropLV.GetSubItemByColumnName('Имя', Item, str);
  ParamNameEdit.Text := str;
  ParamsPropLV.GetSubItemByColumnName('Значение', Item, str);
  ParamValEdit.Text := str;
end;

procedure TRptFrm.ApplyParamBtnClick(Sender: TObject);
var
  li, optLi: TListItem;
  opt: cOptRecord;
  str: string;
begin
  li := ParamsPropLV.Selected;
  ParamsPropLV.SetSubItemByColumnName('Значение', ParamValEdit.Text, li);

  optLi := OptsLV.Selected;
  if optLi <> nil then
  begin
    opt := cOptRecord(optLi.data);
    if opt <> nil then
    begin
      if opt.estType = c_estType_Rms then
      begin
        opt.band.x := strtofloatext(GetParamValFromLV(ParamsPropLV, 'F1'));
        opt.band.y := strtofloatext(GetParamValFromLV(ParamsPropLV, 'F2'));
        str := GetParamValFromLV(ParamsPropLV, 'Проц.');
        if str = '1' then
        begin
          opt.percent := true;
        end
        else
        begin
          opt.percent := false;
        end;
        OptsLV.SetSubItemByColumnName('Описание', opt.getdsc, optLi);
      end;
      if opt.estType = c_estType_A1 then
      begin
        opt.band.x := strtofloatext(GetParamValFromLV(ParamsPropLV, 'F1'));
        opt.band.y := strtofloatext(GetParamValFromLV(ParamsPropLV, 'F2'));
        OptsLV.SetSubItemByColumnName('Описание', opt.getdsc, optLi);
      end;
      if opt.estType = c_estType_N then
      begin
        opt.band.x := strtofloatext(GetParamValFromLV(ParamsPropLV, 'Lvl1'));
        opt.band.y := strtofloatext(GetParamValFromLV(ParamsPropLV, 'Lvl2'));
        str := GetParamValFromLV(ParamsPropLV, 'Проц.');
        if str = '1' then
        begin
          opt.percent := true;
        end
        else
        begin
          opt.percent := false;
        end;
        OptsLV.SetSubItemByColumnName('Описание', opt.getdsc, optLi);
      end;
    end;
  end;
end;

procedure TRptFrm.AutoBandChannelCBChange(Sender: TObject);
begin
  CheckCBItemInd(AutoBandChannelCB);
  if AutoBandsCB.Checked then
    EvalBandsByChannel;
end;

procedure TRptFrm.AutoBandLengthFEChange(Sender: TObject);
begin
  AutoBandsCBClick(nil);
end;

procedure TRptFrm.EvalBandsByChannel;
var
  s:cwpsignal;
begin
  BandCountIE.IntNum:=0;
  s:=cwpsignal(GetComboBoxItem(autobandchannelcb));
  if s=nil then
    exit;
  TExtOperRpt(eo).m_autoBOffset1:=AutoBOffset1.FloatNum;
  TExtOperRpt(eo).m_autoBOffset2:=AutoBOffset2.FloatNum;
  TExtOperRpt(eo).m_autoBThreshold:=Threshold.FloatNum;
  TExtOperRpt(eo).EvalBandsByChannel(s);
  BandCountIE.IntNum:=TExtOperRpt(eo).m_AutoBCount;
end;

procedure TRptFrm.AutoBandsCBClick(Sender: TObject);
var
  src: csrc;
  I: integer;
  len: double;

begin
  if AutoBandsCB.Checked then
  begin
    AutoBandsPC.Visible:=true;
    BandsTC.Visible:=false;
    AutoBandsCountLabel.Visible:=true;
    BandCountIE.Visible:=true;
    BandCountIE.Color:=clGreen;
    src := GetSelectSrc;
    if src <> nil then
    begin
      case AutoBandsPC.ActivePageIndex of
        0:
        begin
          len := src.t2 - src.t1;
          BandCountIE.IntNum := trunc
            ((src.t2 - src.t1) / (AutoBandLengthFE.FloatNum +
                AutoBandIntervalShiftFE.FloatNum));
          if len > BandCountIE.IntNum * (AutoBandLengthFE.FloatNum +
              AutoBandIntervalShiftFE.FloatNum) then
          begin
            BandCountIE.IntNum := BandCountIE.IntNum + 1;
          end;
        end;
        1:
        begin
          EvalBandsByChannel;
        end;
      end;
    end;
  end
  else
  begin
    AutoBandsCountLabel.Visible:=false;
    BandsTC.Visible:=true;
    AutoBandsPC.Visible:=false;
    BandCountIE.Visible:=false;
    BandCountIE.Color:=clWhite;
  end;
end;

procedure TRptFrm.UpdateBandBtnClick(Sender: TObject);
begin
  if not AutoBandsCB.Checked then
    ApplyBandTypeBtnClick(nil);
end;

procedure TRptFrm.UpdateParams(itemName: string);
var
  li, optLi: TListItem;
  opt: cOptRecord;
  str: string;
  a, b, c: double;
begin
  opt := nil;
  optLi := OptsLV.Selected;
  if optLi <> nil then
  begin
    opt := cOptRecord(optLi.data);
  end;

  if itemName = c_A1_Name then
  begin
    str := tExtOperRpt(eo).GenEstName(c_estType_A1);
    a := 0.8;
    b := 1.2;
    if opt <> nil then
    begin
      if opt.estType = c_estType_A1 then
      begin
        a := opt.band.x;
        b := opt.band.y;
      end;
    end;
    ParamsPropLV.clear;
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'Название', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', str, li);
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'F1', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', floattostr(a), li);
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'F2', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', floattostr(b), li);
  end;
  if itemName = c_N_Name then
  begin
    str := tExtOperRpt(eo).GenEstName(c_estType_N);
    a := 0.8;
    b := 1.2;
    c := 1;
    if opt <> nil then
    begin
      if opt.estType = c_estType_N then
      begin
        a := opt.band.x;
        b := opt.band.y;
        if opt.percent then
          c := 1
        else
          c := 0;
      end
    end;
    ParamsPropLV.clear;
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'Название', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', str, li);
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'Lvl1', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', floattostr(a), li);
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'Lvl2', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', floattostr(b), li);
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'Проц.', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', inttostr(round(c)), li);
  end;
  if itemName = c_RMS_Name then
  begin
    str := tExtOperRpt(eo).GenEstName(c_estType_Rms);
    a := 0.8;
    b := 1.2;
    c := 1;
    if opt <> nil then
    begin
      if opt.estType = c_estType_Rms then
      begin
        a := opt.band.x;
        b := opt.band.y;
        if opt.percent then
          c := 1
        else
          c := 0;
      end
    end;
    ParamsPropLV.clear;
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'Название', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', str, li);
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'F1', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', floattostr(a), li);
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'F2', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', floattostr(b), li);
    li := ParamsPropLV.Items.Add;
    ParamsPropLV.SetSubItemByColumnName('Имя', 'Проц.', li);
    ParamsPropLV.SetSubItemByColumnName('Значение', inttostr(round(c)), li);
  end;
end;

procedure TRptFrm.InitParamsLB;
begin
  ParamsLB.clear;
  ParamsLB.AddItem('Максимум в полосе', nil);
  ParamsLB.AddItem('Подсчет импульсов', nil);
  ParamsLB.AddItem('СКЗ в полосе', nil);
end;

procedure TRptFrm.addcursorband;
var
  b: RptBand;
  g: tgraphstruct;
  p: point2d;
begin
  b := RptBand.Create;
  g := activeGraph;
  if g.hpage = 0 then
    exit;
  p := GetGraphCursorX(g.hpage, g.hgraph);
  b.P2d := P2d(p.x, p.y);
  b.bandType := c_bandType_phis;
  if b = nil then
    exit;
  addBandToSg(b);
end;

procedure TRptFrm.Init(oper: TObject; p_mng: cWPObjMng);
begin
  mng := p_mng;
  eo := oper;
  if length(TExtOperRpt(eo).m_bandlist)=0 then
    setlength(TExtOperRpt(eo).m_bandlist, 500);

  ShowProperties;
  InitSG;
  InitParamsLB;
  LoadDefaultCfg;
  TmpltNameFrame1.SetIFile(startDir + '\Opers\' + 'RptOper.ini', 'Main',
    'RptTmplt_', startDir);
  LoadCfg;
end;

function TRptFrm.GetPropertyStr: string;
var
  props: string;
  I: integer;
  o: cOptRecord;
  b: RptBand;
begin
  props := 'BandCount=' + inttostr(BandsSG.RowCount - 1) + ';';
  begin
    props := props + 'X="';
    for I := 1 to BandsSG.RowCount - 1 do
    begin
      b := RptBand(BandsSG.Rows[I].Objects[0]);
      // величины
      props := props + inttostr(b.bandType) + ';';
      case b.bandType of
        c_bandType_phis:
          props := props + floattostr(b.P2d.x) + ';' + floattostr(b.P2d.y);
        c_bandType_ind:
          props := props + inttostr(b.P2i.x) + ';' + inttostr(b.P2i.y);
        c_bandType_trig:
          begin
            if (b.trig1 <> nil) and (b.trig2 <> nil) then
            begin
              props := props + b.trig1.Name + ';' + b.trig2.Name + ';' +
                floattostr(b.shift1) + ';' + floattostr(b.shift2);
            end;
          end;
      end;
      if I <> BandsSG.RowCount - 1 then
      begin
        props := props + ';';
      end
      else
      begin
        props := props + '";';
      end;
    end;
  end;
  if SetEstNamesCB.Checked then
  begin
    props := props + 'SetEstNames=1;';
  end
  else
  begin
    props := props + 'SetEstNames=0;';
  end;
  props := props + 'MaxColCount=' + inttostr(MaxColCount.IntNum) + ';';

  for I := 0 to OptsLV.Items.Count - 1 do
  begin
    o := cOptRecord(OptsLV.Items[I].data);
    props := props + o.name;
    if o.eval then
    begin
      props := props + '=1;';
    end
    else
    begin
      props := props + '=0;';
    end;
    if o.name = 'Bandrms' then
    begin
      // if PercRmsCB.Checked then
      // begin
      // props := props + 'PercentF=1;';
      // end
      // else
      // begin
      // props := props + 'PercentF=0;';
      // end;
      // props := props + 'RMSf1=' + floattostr(rmsF1.floatnum) + ';';
      // props := props + 'RMSf2=' + floattostr(rmsF2.floatnum) + ';';
    end;
  end;
  if pos(o.name, 'A_') > 0 then
  begin
    props := props + o.name + '_F1=' + floattostr(o.band.x) + ';';
    props := props + o.name + '_F2=' + floattostr(o.band.y) + ';';
  end;
  if AutoBandsCB.Checked then
  begin
    props := props + 'AutoBand=1;';
    case AutoBandsPC.ActivePageIndex of
      0: props := props + 'AutoBandType=0;';
      1:
      begin
        props := props + 'AutoBandType=1;';
        props := props + 'AutoBOffset1='+floattostr(AutoBOffset1.FloatNum)+';';
        props := props + 'AutoBOffset2='+floattostr(AutoBOffset2.FloatNum)+';';
        props := props + 'AutoBThreshold='+floattostr(Threshold.FloatNum)+';';
        props := props + 'AutoBChannel='+AutoBandChannelCB.text+';';
      end;
    end;
  end
  else
    props := props + 'AutoBand=0;';

  props := props + 'AutoBandLen=' + floattostr(AutoBandLengthFE.FloatNum) + ';';
  props := props + 'AutoBandShift=' + floattostr
    (AutoBandIntervalShiftFE.FloatNum) + ';';

  if TmpltNameFrame1.SavePathEdit.Text <> '' then
    props := props + 'SavePath=' + TmpltNameFrame1.SavePathEdit.Text
  else
    props := props + 'SavePath=' + '.\' + 'Rpt.xls';
  props := props + ';';

  if TmpltNameFrame1.SavePathEdit.Text <> '' then
    props := props + 'TmpltPath=' + TmpltNameFrame1.TmpltEdit.Text;

  result := props;
end;

procedure TRptFrm.SelectAllEstsCBClick(Sender: TObject);
var
  I: integer;
begin
  for I := 0 to OptsLV.Items.Count - 1 do
  begin
    OptsLV.Items[I].Checked := SelectAllEstsCB.Checked;
  end;
end;

procedure TRptFrm.SetPropertyStr(str: string);
begin
  tExtOperRpt(eo).SetPropStr(str);
end;

procedure TRptFrm.TmpltNameFrame1FolderRGClick(Sender: TObject);
begin
  TmpltNameFrame1.FolderRGClick(Sender);

end;

procedure TRptFrm.TmpltNameFrame1MakeDefaultNameBtnClick(Sender: TObject);
begin
  TmpltNameFrame1.MakeDefaultNameBtnClick(Sender);

end;

procedure TRptFrm.TmpltNameFrame1NameRGClick(Sender: TObject);
begin
  TmpltNameFrame1.NameRGClick(Sender);

end;

procedure TRptFrm.TmpltNameFrame1PathBtnClick(Sender: TObject);
begin
  TmpltNameFrame1.PathBtnClick(Sender);

end;

procedure TRptFrm.TrigsRGClick(Sender: TObject);
var
  b: RptBand;
  s: csrc;
  p2: point2d;
begin
  BandsSG.Options := BandsSG.Options + [goEditing];
  b := GetBound(selectInd);
  if b <> nil then
  begin
    X1FE.FloatNum := b.P2d.x;
    X2FE.FloatNum := b.P2d.y;
  end
  else
  begin
    exit;
  end;
  BandsTC.ActivePageIndex := 0;
  s := GetSelectSrc;
  X1FE.FloatNum := s.t1;
  X2FE.FloatNum := s.t2;
end;

function TRptFrm.GetBound(ind: integer): RptBand;
begin
  result := RptBand(BandsSG.Rows[selectInd].Objects[0]);
end;

function TRptFrm.CreateBound: RptBand;
var
  src: csrc;
  obj: TObject;
  g: tgraphstruct;
  p: point2d;
begin
  result := RptBand.Create;
  if FormStyle = fsStayOnTop then
  begin
    g := activeGraph;
    p := GetGraphCursorX(g.hpage, g.hgraph);
    result.P2d := P2d(p.x, p.y);
    result.bandType := c_bandType_phis;
    exit;
  end;
  case BandsTC.ActivePageIndex of
    c_bandType_phis:
      begin
        result.P2d := P2d(X1FE.FloatNum, X2FE.FloatNum);
        result.bandType := c_bandType_phis;
      end;
    c_bandType_ind:
      begin
        result.P2i := point(X1IE.IntNum, X2IE.IntNum);
        result.bandType := c_bandType_ind;
      end;
    c_bandType_trig:
      begin
        if X1CB.ItemIndex > -1 then
        begin
          obj := X1CB.Items.Objects[X1CB.ItemIndex];
          if obj <> nil then
            result.trig1 := ctrig(obj)
          else
          begin
            result.Destroy;
            result := nil;
            exit;
          end;
        end
        else
        begin
          result.Destroy;
          result := nil;
          exit;
        end;
        if X2CB.ItemIndex > -1 then
        begin
          obj := X2CB.Items.Objects[X2CB.ItemIndex];
          if obj <> nil then
            result.trig2 := ctrig(obj)
          else
          begin
            result.Destroy;
            result := nil;
            exit;
          end;
        end
        else
        begin
          result.Destroy;
          result := nil;
          exit;
        end;
        result.bandType := c_bandType_trig;
      end;
  end;
end;

procedure TRptFrm.addBandToSg(b: RptBand; index: integer);
begin
  case b.bandType of
    c_bandType_phis:
      begin
        BandsSG.Cells[1, index] := floattostr(b.P2d.x);
        BandsSG.Cells[2, index] := floattostr(b.P2d.y);
        BandsSG.Cells[3, index] := 'Физ.';
      end;
    c_bandType_ind:
      begin
        BandsSG.Cells[1, index] := inttostr(b.P2i.x);
        BandsSG.Cells[2, index] := inttostr(b.P2i.y);
        BandsSG.Cells[3, index] := 'Инд.';
      end;
    c_bandType_trig:
      begin
        BandsSG.Cells[1, index] := b.trigname1 + ' ' + floattostr(b.shift1);
        BandsSG.Cells[2, index] := b.trigname2 + ' ' + floattostr(b.shift2);
        BandsSG.Cells[3, index] := 'Триг.';
      end;
  end;
  BandsSG.Rows[index].Objects[0] := b;
end;

procedure TRptFrm.AbsDropToEndBtnClick(Sender: TObject);
var
  src: csrc;
begin
  src := GetSelectSrc;
  if EvalMaxLengthCB.Checked then
    src.EvalStartStopMax(nil)
  else
    src.EvalStartStop(nil);
  if src <> nil then
  begin
    X2FE.FloatNum := src.t2;
  end;
end;

procedure TRptFrm.AbsDropToStartBtnClick(Sender: TObject);
var
  src: csrc;
begin
  src := GetSelectSrc;
  if EvalMaxLengthCB.Checked then
    src.EvalStartStopMax(nil)
  else
    src.EvalStartStop(nil);
  if src <> nil then
  begin
    X1FE.FloatNum := src.t1;
  end;
end;

procedure TRptFrm.addBandToSg(b: RptBand);
begin
  BandsSG.RowCount := BandsSG.RowCount + 1;
  case b.bandType of
    c_bandType_phis:
      begin
        BandsSG.Cells[1, BandsSG.RowCount - 1] := floattostr(b.P2d.x);
        BandsSG.Cells[2, BandsSG.RowCount - 1] := floattostr(b.P2d.y);
        BandsSG.Cells[3, BandsSG.RowCount - 1] := 'Физ.';
      end;
    c_bandType_ind:
      begin
        BandsSG.Cells[1, BandsSG.RowCount - 1] := inttostr(b.P2i.x);
        BandsSG.Cells[2, BandsSG.RowCount - 1] := inttostr(b.P2i.y);
        BandsSG.Cells[3, BandsSG.RowCount - 1] := 'Инд.';
      end;
    c_bandType_trig:
      begin
        BandsSG.Cells[1, BandsSG.RowCount - 1] := b.trig1.Name;
        BandsSG.Cells[2, BandsSG.RowCount - 1] := b.trig2.Name;
        BandsSG.Cells[3, BandsSG.RowCount - 1] := 'Триг.';
      end;
  end;
  BandsSG.Rows[BandsSG.RowCount - 1].Objects[0] := b;
end;

procedure TRptFrm.AddBtnClick(Sender: TObject);
var
  b: RptBand;
begin
  b := CreateBound;
  if b = nil then
    exit;
  addBandToSg(b);
end;

function TRptFrm.GetSelectSrc: csrc;
var
  Node: PVirtualNode;
  data: pnodedata;
begin
  result := nil;
  Node := SignalsTV.RootNode;
  if mng.SrcCount = 0 then
    exit;
  if Node = nil then
    exit;
  result := mng.GetSrc(0);
  data := SignalsTV.GetNodeData(Node);
  if data <> nil then
    result := csrc(data.data);
  if SignalsTV.SelectedCount > 0 then
  begin
    Node := SignalsTV.GetFirstSelected(true);
    data := SignalsTV.GetNodeData(Node);
    if TObject(data.data) is csrc then
    begin
      result := csrc(data.data);
      exit;
    end
    else
    begin
      Node := Node.Parent;
      data := SignalsTV.GetNodeData(Node);
      result := csrc(data.data);
    end;
  end;
end;

function TRptFrm.GetSrc(i: integer): csrc;
var
  node:pvirtualnode;
  data:pnodedata;
  j:integer;
begin
  result:=nil;
  if i<SignalsTV.RootNodeCount then
  begin
    node:=SignalsTV.GetFirst(false);
    j:=0;
    while j<i do
    begin
      node:=SignalsTV.GetNextSibling(node);
    end;
    data := SignalsTV.GetNodeData(Node);
    if TObject(data.data) is csrc then
    begin
      result := csrc(data.data);
    end;
  end;
end;

function TRptFrm.GetNotifyStr: string;
var
  I, j, scount: integer;
  signal: cwpSignal;
  str, numstr: string;
  Node: PVirtualNode;
  data: pnodedata;
  src: csrc;
begin
  // 'o="/Operators/ПоискЭкстремумов";
  // p="BandCount=1,bx_0=5,by_0=2000,L_pos_0=90,L_neg_0=10,N_pos_0=5,N_neg_0=5,N_Max_0=+,N_Neg_0=+,Units_0=%";
  // s1_001="3- 1_СA"i1_001=0;c1_001=2048;d1_001="3- 1_СA_AFlg" s2_002="18- 1_Taho_СA"i2_002=0;c2_002=2048;d2_002="3- 1_СA_AFlg"s3_003="18- 3_Stop_СA"i3_003=0;c3_003=2048;d3_003="18- 3_Stop_СA_AFlg"s4_004="18- 4_Start_СA"i4_004=0;c4_004=2048;d4_004="18- 4_Start_СA_AFlg"'
  result := 'o="/Расширения/' + RptRegName + '";p="' + tExtOperRpt(eo)
    .props + '";';
  scount := 0;
  for I := 0 to SignalsTV.RootNodeCount - 1 do
  begin
    Node := SignalsTV.GetFirst(false);
    data := SignalsTV.GetNodeData(Node);
    if TObject(data.data) is csrc then
    begin
      src := csrc(data.data);
    end;
    mng.curSrc := src;
    for j := 0 to src.childCount - 1 do
    begin
      inc(scount);
      signal := src.getSignalObj(j);
      numstr := inttostr(scount);
      str := numstr;
      if length(str) < 3 then
      begin
        while length(str) <> 3 do
        begin
          str := '0' + str;
        end;
      end;
      // важно писать полный путь, т.к. по нему потом определяется источник
      // и соответствующий ID
      result := result + 's1' + '_' + str + '="' + signal.Node.AbsolutePath +
        '";' + 'i1' + '_' + str + '=' + '0' + ';' + 'c1' + '_' + str + '=' +
        inttostr(signal.signal.size) + ';' + 'd1' + '_' + str + '="";';
    end;
  end;
end;

procedure TRptFrm.ApplyBandTypeBtnClick(Sender: TObject);
var
  b: RptBand;
begin
  if selectInd < 2 then
  begin
    if BandsSG.RowCount > 1 then
      selectInd := 1
    else
      exit;
  end;
  case BandsTC.ActivePageIndex of
    // физика
    0:
      begin
        b := RptBand(BandsSG.Rows[selectInd].Objects[0]);
        b.bandType := c_bandType_phis;
        b.P2d.x := X1FE.FloatNum;
        b.P2d.y := X2FE.FloatNum;
      end;
    // индексы
    1:
      begin
        b := RptBand(BandsSG.Rows[selectInd].Objects[0]);
        b.bandType := c_bandType_ind;
        b.P2i.x := X1IE.IntNum;
        b.P2i.y := X2IE.IntNum;
      end;
    // триггеры
    2:
      begin
        b := RptBand(BandsSG.Rows[selectInd].Objects[0]);
        b.bandType := c_bandType_trig;
        if X1CB.ItemIndex>-1 then
        begin
          b.trig1 := ctrig(X1CB.Items.Objects[X1CB.ItemIndex]);
          b.trigname1 := b.trig1.name;
          b.shift1 := ShiftTrig1FE.FloatNum;
        end;
        if X2CB.ItemIndex>-1 then
        begin
          b.trig2 := ctrig(X2CB.Items.Objects[X2CB.ItemIndex]);
          b.trigname2 := b.trig2.name;
          b.shift2 := ShiftTrig2FE.FloatNum;
        end;
      end;
  end;
  addBandToSg(b, selectInd);
end;

procedure TRptFrm.ApplyBtnClick(Sender: TObject);
var
  str: string;
  I, j: integer;
  Node: PVirtualNode;
  data: pnodedata;
  src: csrc;
  s: cwpSignal;
  prop, fltstr, mdbpath, fname: string;
begin
  // копирование настроек формы в оператор
  ApplyOpts;
  str := GetPropertyStr;
  tExtOperRpt(eo).props := str;
  tExtOperRpt(eo).repType := ReportTypeRG.ItemIndex;
  // установка свойств
  tExtOperRpt(eo).SetPropStr(tExtOperRpt(eo).props);
  // считаем обработку
  tExtOperRpt(eo).firstsignal := true;
  if SignalsTV.RootNodeCount > 0 then
  begin
    I := 0;
    Node := SignalsTV.GetFirst(false);
    while I <= SignalsTV.RootNodeCount - 1 do
    begin
      data := SignalsTV.GetNodeData(Node);
      if TObject(data.data) is csrc then
      begin
        src := csrc(data.data);
      end;
      if src <> tExtOperRpt(eo).ressrc then
      begin
        for j := 0 to src.childCount - 1 do
        begin
          s := src.getSignalObj(j);
          if isHelpChannel(s) then
            continue;
          if RepFilterCB.Checked then
          begin
            fltstr := FltName.Text;
            prop := s.signal.GetProperty(fltstr);
            if prop <> '1' then
              continue;
          end;
          tExtOperRpt(eo).Execute(s.signal);
          tExtOperRpt(eo).firstsignal := false;
        end;
      end;
      // получаем след нод того же уровня
      Node := SignalsTV.GetNextSibling(Node);
      inc(I);
    end;
  end
  else
    exit;
  str := tExtOperRpt(eo).buildreportpath(src);
  if ReportTypeRG.ItemIndex = c_Excel then
  begin
    if UseMDBCB.Checked then
    begin
      mdbpath:=src.merafile.filename;
      mdbpath:=FindMBaseWithObjPath(mdbpath);
      if mdbpath<>'' then
      begin
        if g_mbase=nil then
        begin
          g_mbase:=cMBase.create;
          g_mbase.InitBaseFolder(mdbpath);
        end;
        fname:=src.merafile.filename;
        tExtOperRpt(eo).BuildReportExcel(str,g_mbase.getRegByMeraFile(fname));
      end;
    end
    else
    begin
      tExtOperRpt(eo).BuildReportExcel(str, nil);
    end;
  end;
  if ReportTypeRG.ItemIndex = c_Word then
  begin
    tExtOperRpt(eo).BuildReportWord(str);
  end;
  if OpenFileCB.Checked then
    shellexecute(0, 'open', PChar(str), PChar(str), PChar(startDir),
      SW_SHOWNORMAL);
  str := GetNotifyStr;
  // param:=str;
  // вызов уведомления
  // ExtPack(extPack).NotifyPlugin($000F0001, param);
  modalresult := mrok;
end;

procedure TRptFrm.BandsSGEnter(Sender: TObject);
var
  b: RptBand;
begin

end;

procedure TRptFrm.BandsSGSelectCell(Sender: TObject; ACol, ARow: integer;
  var CanSelect: Boolean);
var
  b: RptBand;
  I: integer;
begin
  selectInd := ARow;
  b := RptBand(BandsSG.Rows[selectInd].Objects[0]);
  if b <> nil then
  begin
    BandsTC.TabIndex := b.bandType;
    case b.bandType of
      c_bandType_phis:
        begin
          X1FE.FloatNum := b.P2d.x;
          X2FE.FloatNum := b.P2d.y;
        end;
      c_bandType_ind:
        begin
          X1IE.IntNum := b.P2i.x;
          X2IE.IntNum := b.P2i.y;
        end;
      c_bandType_trig:
        begin
          setComboBoxItem(b.trigname1, X1CB);
          I := X1CB.Items.IndexOf(b.trigname1);
          if I >= 0 then
          begin
            X1CB.ItemIndex := I;
          end;
          setComboBoxItem(b.trigname2, X2CB);
          I := X2CB.Items.IndexOf(b.trigname2);
          if I >= 0 then
          begin
            X2CB.ItemIndex := I;
          end;
          ShiftTrig1FE.FloatNum := b.shift1;
          ShiftTrig2FE.FloatNum := b.shift2;
          UpdateTrigVals;
        end;
    end;
  end;
end;

procedure TRptFrm.BandsSGSetEditText(Sender: TObject; ACol, ARow: integer;
  const Value: string);
var
  b: RptBand;
begin
  if isValue(Value) then
  begin
    b := RptBand(BandsSG.Rows[selectInd].Objects[0]);
    if b <> nil then
    begin
      if b.bandType = c_bandType_ind then
      begin
        if ACol = 1 then
          b.P2i.x := StrToInt(Value);
        if ACol = 2 then
          b.P2i.y := StrToInt(Value);
      end
      else
      begin
        if ACol = 1 then
          b.P2d.x := strtofloat(Value);
        if ACol = 2 then
          b.P2d.y := strtofloat(Value);
      end;
    end;
  end;
end;

procedure TRptFrm.CheckMDBPath(src:csrc);
var
  mdbpath, fname, str:string;
begin
  if src=nil then exit;
  if UseMDBCB.Checked then
  begin
    mdbpath:=src.merafile.filename;
    mdbpath:=FindMBaseWithObjPath(mdbpath);
    if mdbpath<>'' then
    begin
      UseMDBCB.ShowHint:=true;
      UseMDBCB.Hint:=mdbpath;
      UseMDBCB.Visible:=true;
    end
    else
    begin
      UseMDBCB.ShowHint:=true;
      UseMDBCB.Hint:='Путь к БДИ не найден';
      UseMDBCB.Checked:=false;
      UseMDBCB.Visible:=false;
    end;
  end
end;

procedure TRptFrm.AddParamBtnClick(Sender: TObject);
var
  o: cOptRecord;
  p2: point2d;
  li: TListItem;
  str: string;
begin
  str := GetSelItemFromLB(ParamsLB);
  if str = '' then
    exit;
  o := cOptRecord.Create;
  o.dyn := true;
  o.eval := false;

  if str = 'Максимум в полосе' then
  begin
    str := c_estType_A1;
    o.estType := str;
    o.band.x := strtofloatext(GetParamValFromLV(ParamsPropLV, 'F1'));
    o.band.y := strtofloatext(GetParamValFromLV(ParamsPropLV, 'F2'));
    o.size := 2;
  end;
  if str = 'Подсчет импульсов' then
  begin
    str := c_estType_N;
    o.size := 1;
    o.estType := str;
    o.band.x := strtofloatext(GetParamValFromLV(ParamsPropLV, 'Lvl1'));
    o.band.y := strtofloatext(GetParamValFromLV(ParamsPropLV, 'Lvl2'));
    str := GetParamValFromLV(ParamsPropLV, 'Проц.');
    if str = '1' then
    begin
      o.percent := true;
    end
    else
    begin
      o.percent := false;
    end;
  end;
  if str = 'СКЗ в полосе' then
  begin
    str := c_estType_Rms;
    o.estType := str;
    o.band.x := strtofloatext(GetParamValFromLV(ParamsPropLV, 'F1'));
    o.band.y := strtofloatext(GetParamValFromLV(ParamsPropLV, 'F2'));
    str := GetParamValFromLV(ParamsPropLV, 'Проц.');
    o.size := 1;
    if str = '1' then
    begin
      o.percent := true;
    end
    else
    begin
      o.percent := false;
    end;
  end;
  o.name := tExtOperRpt(eo).GenEstName(o.estType);
  tExtOperRpt(eo).AddEsimate(o);
  // p2 := P2d(F1FE.floatnum, F2FE.floatnum);
  li := OptsLV.Items.Add;
  li.caption := o.name;
  li.Checked := o.eval;
  li.data := o;
  OptsLV.SetSubItemByColumnName('Описание', o.getdsc, li);
end;

procedure TRptFrm.EditFltBtnClick(Sender: TObject);
var
  srclist: tstringlist;
  I: integer;
  n: PVirtualNode;
  d: pnodedata;
  src: csrc;
begin
  if EditRepPropFrm = nil then
    EditRepPropFrm := tEditRepPropFrm.Create(nil);
  n := SignalsTV.GetFirst(false);
  srclist := tstringlist.Create;
  while n <> nil do
  begin
    d := SignalsTV.GetNodeData(n);
    src := csrc(d.data);
    srclist.AddObject(src.name, src);
    n := SignalsTV.GetNextSibling(n);
  end;
  EditRepPropFrm.AddSrcList(srclist, FltName.Text);
  if EditRepPropFrm.ShowModal=mrok then
  begin
    EditRepPropFrm.UpdateSrcProperties;
  end;
  srclist.Destroy;
end;

function TRptFrm.EditOper: integer;
var
  str: string;
  I: integer;
begin
  if mng.curSrc<>nil then
  begin
    UpdateSrc(mng.curSrc);
    TrigsRGClick(nil);
  end;
  Show;
  // if showmodal = mrok then
  // begin
  // str := GetPropertyStr;
  // SetPropertyStr(str);
  // end;
end;

procedure TRptFrm.ShowSrcInCB(src:csrc);
var
  i:integer;
  s:cwpsignal;
begin
  for I := 0 to src.ChildCount - 1 do
  begin
    s:=src.getSignalObj(I);
    AutoBandChannelCB.AddItem(s.name, s);
  end;
end;

procedure TRptFrm.UpdateSrc(src: csrc);
begin
  ShowSrcSignals;
  ShowSrcInCB(src);
  ShowProperties;
  CheckMDBPath(src);
  if src <> nil then
  begin
    TmpltNameFrame1.SetObjectPath(src.merafile.FileName);
  end;

  if AutoBandsCB.Checked then
  begin
    AbsDropToStartBtnClick(nil);
    AbsDropToEndBtnClick(nil);
    if AutoBandsCB.Checked then
    begin
      AutoBandsCBClick(nil);
    end;
  end;
end;

procedure TRptFrm.FormShow(Sender: TObject);
begin
  UpdateTrigs;
  TmpltNameFrame1.FolderRGClick(Sender);
  TmpltNameFrame1.NameRGClick(Sender);
end;

procedure RptBand.settrig1(t: ctrig);
begin
  fTrig1 := t;
  if t <> nil then
  begin
    trigname1 := t.Name;
  end;
end;

procedure RptBand.settrig2(t: ctrig);
begin
  ftrig2 := t;
  if t <> nil then
  begin
    trigname2 := t.Name;
  end;
end;

end.
