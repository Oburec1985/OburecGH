unit uPressFrm2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath, MathFunction,
  Forms, ComCtrls,
  uRecBasicFactory,
  uRecorderEvents,
  uComponentServises,
  uChart,
  inifiles,
  upage,
  tags,
  complex,
  uBuffTrend1d,
  uCommonMath,
  uCommonTypes,
  pluginClass,
  uMeasureBase,
  uMBaseControl,
  shellapi,
  uPathMng,
  uExcel,
  uListMath,
  uSpm, uBaseAlg,
  opengl, uSimpleObjects,
  math, uAxis, uDrawObj, uDoubleCursor, uBasicTrend,
  Dialogs, ExtCtrls, StdCtrls, DCL_MYOWN, Spin, Buttons, uPressFrmFrame2,
  // uPathMng,
  uEditCurveFrm,
  uThresholdsFrm,
  uRcCtrls, Menus;

type
  tband = record
    f1, f2: double;
    i1, i2: integer;
  end;

  tEvalData = record
    rms_mean:double; // среднее в полосе СКО
    rms_max:double; // главный пик (СКО)
    Freq:double;
    iMax:integer;
  end;

  TTagRec = record
    // rms
    name: string;
    // спектр тега
    m_s:cspm;
    // кривая для коррекции ачх
    m_curve:cCurve;
    // тег рекордера ( по одному тегу создается несколько
    // скалярн полосовых тегов)
    m_bandTags: array of itag;
    // максимум
    m_SKO: array of tEvalData;
  end;

  PTagRec = ^TTagRec;



  TPressFrm2 = class(TRecFrm)
    BarGraphGB: TGroupBox;
    BarPanel: TPanel;
    Panel1: TPanel;
    MaxLabel: TLabel;
    MaxFreqLabel: TLabel;
    MaxCamLabel: TLabel;
    MaxAE: TEdit;
    MaxFE: TEdit;
    MaxCamE: TEdit;
    UnitMaxALab: TLabel;
    UnitMaxFLab: TLabel;
    AvrCB: TCheckBox;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    SaveBtn: TSpeedButton;
    OpenBtn: TButton;
    BNumSB: TSpinButton;
    BNumIE: TIntEdit;
    BNumLabel: TLabel;
    WndCB: TComboBox;
    PressFrmFrame21: TPressFrmFrame2;
    procedure N1Click(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure PressFrmFrame21ProgrBarMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: integer);
    procedure BNumSBDownClick(Sender: TObject);
    procedure BNumSBUpClick(Sender: TObject);
    procedure WndCBChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    m_BargraphStep: integer;
    m_lastFile:string;
    m_saveBlockNum: integer;

    m_bnum: integer;
    bnumUpdate: boolean;
    bWndUpdate: boolean;

    m_frames: tlist;
    // максимум (по умолчанию из тега)
    m_ManualRange: boolean;
    m_HH, m_H: double;
    //
    m_Max: point2d;
  private
    fInitBands: boolean;
    m_ind: integer;
  private
    // выравнивает ширину фреймов на компоненте на всю ширину
    procedure sortframes;
    procedure InitExcel;
    procedure ClearFrames;
    procedure UpdateView;
    procedure updatedata;
    procedure doStart;
    procedure doStop;
    function Ready: boolean;
  public
    procedure UpdateCaption;
    function Frame(i: integer): TPressFrmFrame2; overload;
    function Frame(s: string): TPressFrmFrame2; overload;
    function FrameCount: integer;
    function f1: double;
    function f2: double;
    procedure CreateFrame(sname: string);
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IPressCamFrm2 = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cPressCamFactory2 = class(cRecBasicFactory)
  public
    m_loadFile,m_Section: string;
    sortedFrames: tlist;
    m_comparator: fcomparator;

    fLastBlock: double;
    // пересчитано в интдексы или нет
    M_InitBands: boolean;
    m_manualBand: boolean;
    m_bands: array of tband;
    // merafile
    m_RepFile: string;
    m_spmCfg: cAlgConfig;
    // manual
    m_Manualref: boolean;
    // список ref для каждого датчика
    m_refArray: array of double;
    //
    m_typeRes: integer;
    // теги
    m_createTags: boolean;
    m_tagsinit: boolean;
    m_tags: array of TTagRec;

    m_AlarmHandler:AlarmHandler;
    m_Thresholds:TThresholdGroup;
    // относительные уровни для расчета Alarm-а
    m_AlarmHlev, m_AlarmHHlev,
    // заданный абсолютный максимум
    m_AlarmBase:double;
  private
    // число дочерних компонентов
    m_counter: integer;
  protected
    procedure GenRepFilePath;
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
    // конфигуратор спектра
    procedure CreateAlgConfig;
    function getSpm(i: integer): cspm; overload;
    function getSpm(s: string): cspm; overload;
    // пересчитать полосы в индексы
    procedure ReevalBands(s: cspm);
  public
    procedure Sort;
    function GetWnd: string;
    function GetWndType: TWndType;
    function GetWndFunc: PWndFunc;
    function GetWndInd: integer;
    function GetRef(i: integer): double;
    procedure SetRef(d: double);
    procedure doAfterLoad; override;
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doChangeCfg(Sender: TObject);
    // создать теги из списка спектров
    procedure CreateTags();
    procedure doStart;
    procedure doStop;
    // ПОЛУЧАЕТ НА ВХОД список тегов и создает cspm-ы
    procedure CreateAlg(list: tstrings);
    procedure createFrames; overload;
    procedure createFrames(f: tform); overload;
    procedure AutoEvalBand(t: itag);
    procedure SetBCount(c: integer);
    function getBCount: integer;
    function BandsToStr: string;
    function RefsToStr: string;
    procedure StrToBands(s: string);
    procedure StrToRefs(s: string);
    function getFrmByBNum(i: integer): TPressFrm2;
    function getTag(s: string): PTagRec;overload;
    function getTag(i: integer): PTagRec;overload;
    // пересчет rms в амплитуду
    function RescaleEst(restype:integer; rms:double):double;
    // когда Recorder загрузил конфиги;
    procedure doRecorderInit;override;
  public
    constructor create;
    destructor destroy; override;
    property BandCount: integer read getBCount write SetBCount;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

var
  g_PressCamFactory2: cPressCamFactory2;

const
  c_Pic = 'PRESSFRM2';
  c_Name = 'Анализ камер сгорания2';
  c_defXSize = 560;
  c_defYSize = 355;

  // ctrl+shift+G
  // ['{54C462CD-E137-4BA6-9EB5-EFD92D159DE5}']
  IID_PRESS: TGuid = (D1: $54C462CD; D2: $A137; D3: $4BA6;
    D4: ($9E, $B5, $EF, $D9, $2D, $15, $9D, $E5));

implementation

uses
  uPressFrmEdit2;
{$R *.dfm}

{ IPressCamFactory }
function RepFile: string;
begin
  result := g_PressCamFactory2.m_RepFile;
end;

procedure cPressCamFactory2.StrToBands(s: string);
var
  s1, f: string;
  i, ind: integer;
  fr: TPressFrmFrame2;
begin
  ind := 1;
  for i := 0 to BandCount - 1 do
  begin
    s1 := getSubStrByIndex(s, ';', 1, i);
    if s1 = '' then
    begin
      m_manualBand := false;
      break;
    end;
    f := getSubStrByIndex(s1, ',', 1, 0);
    m_bands[i].f1 := strtofloatext(f);
    f := getSubStrByIndex(s1, ',', 1, 1);
    m_bands[i].f2 := strtofloatext(f);
  end;
end;

procedure cPressCamFactory2.StrToRefs(s: string);
var
  s1: string;
  i: integer;
begin
  setlength(m_refArray, m_spmCfg.ChildCount);
  for i := 0 to m_spmCfg.ChildCount - 1 do
  begin
    s1 := getSubStrByIndex(s, ';', 1, i);
    if s1 = '' then
    begin
      m_Manualref := false;
      break;
    end;
    m_refArray[i] := strtofloatext(s1);
  end;
end;

function cPressCamFactory2.RefsToStr: string;
var
  i: integer;
begin
  result := '';
  for i := 0 to Length(m_refArray) - 1 do
  begin
    result := result + floattostr(m_refArray[i]) + ';';
  end;
end;

function cPressCamFactory2.RescaleEst(restype: integer; rms: double): double;
var
  w:PWndFunc;
  v:double;
begin
  if restype=0 then // СКО
  begin
    v:=rms/sqrt2;
    w:=GetWndFunc;
    // коррекция с цчетом оконной функции для СКО (т.к. исходный спектр корректируется по acf для А)
    //if w<>nil then
    //begin
    //  if w.wndtype<>wdRect then
    //  begin
        //v:=v*w.ecf/w.acf;
    //    v:=v*w.ecf;
    //  end;
    //end;
  end
  else  // p-p
  begin
    v:=rms*2;
  end;
  result:=v;
end;

function cPressCamFactory2.BandsToStr: string;
var
  i: integer;
  fr: TPressFrmFrame2;
  b: tband;
begin
  result := '';
  for i := 0 to BandCount - 1 do
  begin
    b := m_bands[i];
    result := result + floattostr(b.f1) + ',' + floattostr(b.f2) + ';';
  end;
end;

procedure cPressCamFactory2.CreateAlg(list: tstrings);
var
  i, j: integer;
  sname: string;
  spm: cspm;
  find: boolean;
begin
  // удаляем лишние
  for i := m_spmCfg.ChildCount - 1 downto 0 do
  begin
    spm := cspm(m_spmCfg.getAlg(i));
    find := false;
    for j := 0 to list.Count - 1 do
    begin
      if spm.m_tag.tagname = list.Strings[j] then
      begin
        find := true;
        break;
      end;
    end;
    if not find then
    begin
      m_spmCfg.delAlg(spm);
    end;
  end;
  // добавляем новые
  for i := 0 to list.Count - 1 do
  begin
    sname := list.Strings[i];
    spm := getSpm(sname);
    if spm = nil then
    begin
      spm := cspm(g_algMng.CreateObjByType('cSpm'));
      if g_PressCamFactory2.m_spmCfg.str = '' then
      begin
        g_PressCamFactory2.m_spmCfg.str := spm.Properties;
      end;
      spm.Properties := 'Channel=' + sname;
      g_PressCamFactory2.m_spmCfg.AddChild(spm);
      g_algMng.Add(spm, nil);
    end;
  end;
end;

procedure cPressCamFactory2.createFrames(f: tform);
var
  i: integer;
  Frm: TPressFrm2;
  fr: TPressFrmFrame2;
  j: integer;
  s: cspm;
begin
  Frm := TPressFrm2(f);
  Frm.ClearFrames;
  Frm.m_frames.Add(Frm.PressFrmFrame21);
  s := getSpm(0);
  Frm.PressFrmFrame21.spm := g_PressCamFactory2.getSpm(s.m_tag.tagname);
  Frm.BarPanel.ShowHint := true;
  Frm.BarPanel.Hint := s.m_tag.tagname;

  for j := 1 to m_spmCfg.ChildCount - 1 do
  begin
    s := getSpm(j);
    Frm.CreateFrame(s.m_tag.tagname);
  end;
  Frm.sortframes;
  // сортировка по размещению
end;

procedure cPressCamFactory2.createFrames;
var
  i: integer;
  Frm: TPressFrm2;
  fr: TPressFrmFrame2;
  j: integer;
  s: cspm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := TPressFrm2(GetFrm(i));
    Frm.ClearFrames;
    Frm.m_frames.Add(Frm.PressFrmFrame21);
    s := getSpm(0);
    Frm.PressFrmFrame21.spm := g_PressCamFactory2.getSpm(s.m_tag.tagname);
    Frm.BarPanel.ShowHint := true;
    Frm.BarPanel.Hint := s.m_tag.tagname;

    for j := 1 to m_spmCfg.ChildCount - 1 do
    begin
      s := getSpm(j);
      Frm.CreateFrame(s.m_tag.tagname);
    end;
    Frm.sortframes;
  end;
  setlength(m_refArray, m_spmCfg.ChildCount);
end;

procedure cPressCamFactory2.CreateAlgConfig;
var
  i: integer;
  f: TPressFrm2;
begin
  if g_algMng <> nil then
  begin
    if m_spmCfg = nil then
    begin
      m_spmCfg := g_algMng.newCfg(cspm.ClassName, cspm);
      m_spmCfg.name := 'Pressure_spmCfg';
      m_spmCfg.m_NotSaveCfg := true;
    end;
  end;
end;

procedure cPressCamFactory2.destroyevents;
begin
  RemovePlgEvent(doUpdateData, c_RUpdateData);
  RemovePlgEvent(doChangeCfg, c_RC_LeaveCfg);
  RemovePlgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cPressCamFactory2.createevents;
begin
  addplgevent('cSRSFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cSRSFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
  addplgevent('cSRSFactory_doChangeRState', c_RC_LeaveCfg, doChangeCfg);
end;

function TlistSortCompare(p1, p2: pointer): integer;
begin
  if TPressFrm2(p1).m_bnum > TPressFrm2(p2).m_bnum then
    result := 1
  else
  begin
    if TPressFrm2(p1).m_bnum < TPressFrm2(p2).m_bnum then
      result := -1
    else
      result := 0;
  end;
end;

constructor cPressCamFactory2.create;
begin
  inherited;
  sortedFrames := tlist.create;
  m_comparator := TlistSortCompare;

  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_PRESS;
  createevents;
  BandCount := 6;

  m_AlarmHandler:=AlarmHandler.Create;
  m_AlarmHandler.Attach;
  m_Thresholds:=TThresholdGroup.create;
  m_AlarmHlev:=0.5;
  m_AlarmHHlev:=0.7;
  m_AlarmBase:=1;
end;

destructor cPressCamFactory2.destroy;
begin
  sortedFrames.destroy;
  m_AlarmHandler.Destroy;
  m_Thresholds.destroy;

  destroyevents;
  inherited;
end;

procedure cPressCamFactory2.doAfterLoad;
var
  s: cspm;
  i: integer;
  f: TPressFrm2;
begin
  inherited;
  CreateAlgConfig;
  for i := 0 to m_CompList.Count - 1 do
  begin
    f := TPressFrm2(GetFrm(i));
    f.sortframes;
  end;
end;

procedure cPressCamFactory2.CreateTags();
var
  i, j: integer;
  s: cspm;
  b:boolean;
  k: Integer;
  a:TAlarms;
begin
  if length(m_tags)<>m_spmCfg.ChildCount then
    setlength(m_tags, m_spmCfg.ChildCount);
  for i := 0 to m_spmCfg.ChildCount - 1 do
  begin
    s := getSpm(i);
    m_tags[i].name := s.m_tag.tagname;
    m_tags[i].m_s:=s;
    setlength(m_tags[i].m_bandTags, BandCount);
    setlength(m_tags[i].m_SKO, BandCount);
    if m_createTags then
    begin
      for j := 0 to BandCount - 1 do
      begin
        m_tags[i].m_bandTags[j] := createScalar(s.m_tag.tagname + 'b' + inttostr(j), false);
        // добавляем алармы по каждому из тегов
        m_Thresholds.addtag(m_tags[i].m_bandTags[j],b);
      end;
    end;
  end;
  for k := 0 to m_Thresholds.AlarmList.Count - 1 do
  begin
    a:=m_Thresholds.GetAlarm(i);
    a.m_a_hh:=m_AlarmBase*m_AlarmHHlev;
    a.m_a_h:=m_AlarmBase*m_AlarmHlev;
  end;
end;

procedure cPressCamFactory2.doChangeCfg(Sender: TObject);
var
  s: cspm;
begin
  if m_spmCfg<>nil then
  begin
    if m_spmCfg.ChildCount>0 then
    begin
      m_tagsinit := true;
      CreateTags;
    end;
  end;
end;

procedure cPressCamFactory2.doChangeRState(Sender: TObject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
        doStop;
      end;
    RSt_StopToView:
      begin
        // g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_StopToRec:
      begin
        // g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_ViewToStop:
      begin
        doStop;
      end;
    RSt_ViewToRec:
      begin
        // g_SRSFactory.m_meraFile := GetMeraFile;
      end;
    RSt_initToRec:
      begin
        // g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_initToView:
      begin
        // g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_RecToStop:
      begin
        doStop;
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

function cPressCamFactory2.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  result := IPressCamFrm2.create();
  inc(m_counter);
end;

procedure cPressCamFactory2.doDestroyForms;
begin
  inherited;

end;



procedure cPressCamFactory2.doSetDefSize(var PSize: SIZE);
begin
  inherited;
  PSize.cx := c_defXSize;
  PSize.cy := c_defYSize;
end;

procedure cPressCamFactory2.doStart;
var
  i: integer;
  Frm: TPressFrm2;
begin
  fLastBlock := -1;
  GenRepFilePath;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := TPressFrm2(GetFrm(i));
    Frm.doStart;
  end;
  Sort;
end;

procedure cPressCamFactory2.doStop;
var
  i: integer;
  Frm: TPressFrm2;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := TPressFrm2(GetFrm(i));
    Frm.doStop;
  end;
end;

procedure cPressCamFactory2.doUpdateData(Sender: TObject);
var
  bnum, j, i,
  // индекс максимума в спектре
  imax: integer;
  Frm: TRecFrm;
  t:TTagRec;
  k: Integer;
  v, sum, max:double;
begin
  // if g_disableFRF then
  // exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TPressFrm2(Frm).updatedata;
  end;
  //// добавлено 05.11.24. Оценки и теги считать вфабрике
  /// а в компоненте только отображать
  // сохранение тегов
  // проход по списку тегов
  for i := 0 to length(m_tags) - 1 do
  begin
    t:=m_tags[i];
    // проход по списку полос
    for bnum := 0 to length(m_bands)-1 do
    begin
      // проход по списку
      for k := m_bands[bnum].i1 to m_bands[bnum].i2 do
      begin
        v:=tdoubleArray(t.m_s.m_rms.p)[k];
        sum:=sum+v;
        if v>max then
        begin
          max:=v;
          imax:=i;
        end;
      end;
      t.m_SKO[bnum].rms_max:=max;
      t.m_SKO[bnum].Freq:=t.m_s.SpmDx*imax;
      t.m_SKO[bnum].iMax:=imax;
      // поменять на сумму квадратов корень?
      t.m_SKO[bnum].rms_mean:=sum/(m_bands[bnum].i2-m_bands[bnum].i1);
      if m_createTags then
      begin
        if m_tagsinit then
        begin
          max:=RescaleEst(m_typeRes ,t.m_SKO[bnum].rms_max);
          t.m_bandTags[bnum].PushValue(max, -1);
        end;
      end;
    end;
  end;
end;

procedure cPressCamFactory2.GenRepFilePath;
var
  mf: string;
begin
  mf := GetMeraFile;
  m_RepFile := ExtractFileDir(mf) + '\PressCamReport' + '.xlsx';
end;

function cPressCamFactory2.getBCount: integer;
begin
  result := Length(m_bands);
end;

function cPressCamFactory2.getFrmByBNum(i: integer): TPressFrm2;
begin
  result := nil
end;

function cPressCamFactory2.GetRef(i: integer): double;
var
  s: cspm;
begin
  if i>length(m_refArray)-1 then exit;
  if m_Manualref then
  begin
    result := m_refArray[i];
    if result = 0 then
    begin
      s := getSpm(i);
      if s <> nil then
      begin
        result := s.m_tag.GetMaxYValue;
      end;
    end;
  end
  else
  begin
    s := getSpm(i);
    if s <> nil then
    begin
      result := s.m_tag.GetMaxYValue;
    end;
  end;
end;

procedure cPressCamFactory2.SetRef(d: double);
var
  i: integer;
begin
  for i := 0 to Length(m_refArray) - 1 do
  begin
    m_refArray[i] := d;
  end;
end;

procedure cPressCamFactory2.Sort;
var
  i: integer;
begin
  sortedFrames.clear;
  for i := 0 to m_CompList.Count - 1 do
  begin
    sortedFrames.Add(GetFrm(i));
  end;
  if Count > 0 then
  begin
    sortedFrames.Sort(m_comparator);
  end;
end;

function cPressCamFactory2.getSpm(s: string): cspm;
var
  i: integer;
  spm: cspm;
begin
  result := nil;
  for i := 0 to m_spmCfg.ChildCount - 1 do
  begin
    spm := cspm(m_spmCfg.getAlg(i));
    if spm.m_tag <> nil then
    begin
      if spm.m_tag.tagname = s then
      begin
        result := spm;
        exit;
      end;
    end;
  end;
end;

function cPressCamFactory2.getTag(s: string): PTagRec;
var
  I: Integer;
begin
  result:=nil;
  for I := 0 to length(m_tags) - 1 do
  begin
    if m_tags[i].name=s then
    begin
      result:=@m_tags[i];
      exit;
    end;
  end;
end;

function cPressCamFactory2.getTag(i: integer): PTagRec;
begin
  result:=@m_tags[i];
end;

function cPressCamFactory2.GetWnd: string;
var
  s: string;
begin
  s := getparam(m_spmCfg.str, 'Wnd');
  if CheckStr(s) then
    result := s
  else
    result := 'Rect';
end;

// c_Rect = 'Rect';
// c_Hann = 'Hann';
// c_Hamming = 'Hamming';
// c_Blackmann = 'Blackman';
// c_Flattop = 'Flattop';

function cPressCamFactory2.GetWndInd: integer;
var
  s: string;
  i: integer;
begin
  s := GetWnd;
  if s = 'Rect' then
  begin
    result := 0;
  end
  else
  begin
    if s = 'Hann' then
    begin
      result := 2;
    end
    else
    begin
      if s = 'Hamming' then
      begin
        result := 1;
      end
      else
      begin
        if s = 'Blackman' then
        begin
          result := 3;
        end
        else // Flattop
        begin
          result := 4;
        end;
      end;
    end;
  end;
end;

function cPressCamFactory2.GetWndFunc: PWndFunc;
var
  s: cspm;
begin
  s := getSpm(0);
  result := s.GetWndFunc;
end;

function cPressCamFactory2.GetWndType: TWndType;
var
  s: cspm;
begin
  s := getSpm(0);
  result := wdRect;
  if s <> nil then
    result := s.GetWndType;
end;

procedure cPressCamFactory2.ReevalBands(s: cspm);
var
  i: integer;
begin
  M_InitBands := true;
  if s <> nil then
  begin
    for i := 0 to Length(m_bands) - 1 do
    begin
      m_bands[i].i1 := s.getIndByX(m_bands[i].f1);
      m_bands[i].i2 := s.getIndByX(m_bands[i].f2);
    end;
  end;
end;

procedure cPressCamFactory2.SetBCount(c: integer);
var
  s: cspm;
  Frm: TPressFrm2;
  i:integer;
begin
  setlength(m_bands, c);
  if m_spmCfg = nil then
    exit;
  s := getSpm(0);
  if s = nil then
    exit;
  if s.m_tag = nil then
    exit;
  if s.m_tag.tag = nil then
    exit;
  if not m_manualBand then
  begin
    AutoEvalBand(s.m_tag.tag);
    ReevalBands(s);
  end;
end;

procedure cPressCamFactory2.AutoEvalBand(t: itag);
var
  i: integer;
  f, df: double;
  Frm: TPressFrm2;
begin
  M_InitBands := false;
  if BandCount = 0 then
    exit;
  if m_bands[0].f2 = 0 then
  begin
    df := t.GetFreq / 2;
    df := round(df / BandCount);
    f := 0;
    for i := 0 to BandCount - 1 do
    begin
      m_bands[i].f1 := f;
      m_bands[i].f2 := f + df;
      f := m_bands[i].f2;
    end;
  end;
  for i := 0 to Count - 1 do
  begin
    Frm := TPressFrm2(GetFrm(i));
    Frm.UpdateCaption;
  end;
end;

function cPressCamFactory2.getSpm(i: integer): cspm;
begin
  if m_spmCfg.ChildCount > 0 then
    result := cspm(m_spmCfg.getAlg(i))
  else
    result := nil;
end;

{ IPressCamFrm }

procedure IPressCamFrm2.doClose;
begin
  m_lRefCount := 1;
end;

function IPressCamFrm2.doCreateFrm: TRecFrm;
begin
  result := TPressFrm2.create(nil);
end;

function IPressCamFrm2.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function IPressCamFrm2.doRepaint: boolean;
begin
  inherited;
  TPressFrm2(m_pMasterWnd).UpdateView;
end;

{ TPressCamFrm }
function TPressFrm2.Frame(i: integer): TPressFrmFrame2;
begin
  result := TPressFrmFrame2(m_frames.Items[i]);
end;

function TPressFrm2.FrameCount: integer;
begin
  result := m_frames.Count;
end;

procedure TPressFrm2.FormShow(Sender: TObject);
begin
  sortframes;
end;

function TPressFrm2.Frame(s: string): TPressFrmFrame2;
var
  i: integer;
  fr: TPressFrmFrame2;
begin
  for i := 0 to m_frames.Count - 1 do
  begin
    fr := Frame(i);
    if fr.spm.m_tag.tagname = s then
    begin
      result := fr;
      exit;
    end;
  end;
end;

procedure TPressFrm2.BNumSBDownClick(Sender: TObject);
begin
  if BNumIE.IntNum > 0 then
  begin
    BNumIE.IntNum := BNumIE.IntNum - 1;
    bnumUpdate := true;
  end;
end;

procedure TPressFrm2.BNumSBUpClick(Sender: TObject);
begin
  if BNumIE.IntNum < g_PressCamFactory2.BandCount - 1 then
  begin
    BNumIE.IntNum := BNumIE.IntNum + 1;
    bnumUpdate := true;
  end;
end;

procedure TPressFrm2.ClearFrames;
var
  i: integer;
  fr: TPressFrmFrame2;
  c: tcomponent;
begin
  for i := 1 to m_frames.Count - 1 do
  begin
    fr := Frame(i);
    fr.parent.destroy;
  end;
  m_frames.clear;
end;

constructor TPressFrm2.create(Aowner: tcomponent);
begin
  inherited;
  m_BargraphStep := 100;
  m_HH := 0.7;
  m_H := 0.5;
  m_frames := tlist.create;
  PressFrmFrame21.m_frm := self;

  g_PressCamFactory2.sortedFrames.Add(self);
end;

procedure TPressFrm2.CreateFrame(sname: string);
var
  fr: TPressFrmFrame2;
  p: TPanel;
  i: integer;
  txt: string;
begin
  i := m_frames.Count;
  txt := BarPanel.name + '_' + inttostr(i);
  p := TPanel.create(self);
  p.parent := BarGraphGB;
  p.Align := alTop;
  p.Width := BarPanel.Width;
  p.Height := BarPanel.Height;
  p.name := txt;

  p.ShowHint := true;
  p.Hint := sname;

  fr := TPressFrmFrame2.create(nil);
  fr.name := fr.ClassName + '_' + inttostr(i);
  fr.parent := p;
  fr.Align := alClient;
  fr.Width := PressFrmFrame21.Width;
  fr.FreqEdit.Text := '0';
  fr.AmpE.Text := '0';
  fr.spm := g_PressCamFactory2.getSpm(sname);
  fr.m_frm := self;

  fr.AmpE.Width := PressFrmFrame21.AmpE.Width;
  fr.AmpE.left := PressFrmFrame21.AmpE.left;
  fr.FreqEdit.Width := PressFrmFrame21.FreqEdit.Width;
  fr.FreqEdit.left := PressFrmFrame21.FreqEdit.left;
  fr.ALabel.Width := PressFrmFrame21.ALabel.Width;
  fr.ALabel.left := PressFrmFrame21.ALabel.left;
  fr.FLabel.Width := PressFrmFrame21.FLabel.Width;
  fr.FLabel.left := PressFrmFrame21.FLabel.left;
  fr.ProgrBar.left := PressFrmFrame21.ProgrBar.left;
  // fr.ProgrBar.width:=p.Width-fr.ProgrBar.Left-2;

  m_frames.Add(fr);
end;

destructor TPressFrm2.destroy;
begin
  inherited;
  m_frames.destroy;
end;

function TPressFrm2.Ready: boolean;
var
  s: cspm;
begin
  result := false;
  s := PressFrmFrame21.spm;
  if s <> nil then
  begin
    if s.m_tag <> nil then
    begin
      if s.m_tag.tag <> nil then
      begin
        result := true;
      end;
    end;
  end;
end;

procedure TPressFrm2.doStart;
var
  fr: TPressFrmFrame2;
  i: integer;
begin
  if Ready then
  begin
    g_PressCamFactory2.AutoEvalBand(PressFrmFrame21.spm.m_tag.tag);
    g_PressCamFactory2.ReevalBands(PressFrmFrame21.spm);
  end;
  for i := 0 to m_frames.Count - 1 do
  begin
    fr := Frame(i);
    fr.Prepare;
  end;
end;

procedure TPressFrm2.doStop;
var
  fr: TPressFrmFrame2;
  i: integer;
begin

end;

function TPressFrm2.f1: double;
begin
  result := g_PressCamFactory2.m_bands[m_bnum].f1;
end;

function TPressFrm2.f2: double;
begin
  result := g_PressCamFactory2.m_bands[m_bnum].f2;
end;

procedure TPressFrm2.InitExcel;
begin
  if not CheckExcelInstall then
  begin
    showmessage('Необходима установка Excel');
    exit;
  end;
  CreateExcel;
  VisibleExcel(true);
end;

// получить номер строки в которое встречена пустая ячейка
// проверка идет по колонке col в листе sh начиная с sh
function GetEmptyRow(sh, r0, col: integer): integer;
var
  ws, rng: olevariant;
  res: string;

  adr: string;
begin
  ws := E.ActiveWorkbook.Sheets[sh];
  ws.activate;
  res := ws.cells[r0, col];
  while res <> '' do
  begin
    inc(r0);
    res := ws.cells[r0, col];
  end;
  result := r0;
end;

procedure TPressFrm2.SaveBtnClick(Sender: TObject);
var
  fname, str: string;
  i, j, r, c, r0: integer;
  f: TPressFrm2;
  fr: TPressFrmFrame2;
  rng: olevariant;
  spm: cspm;
  k: integer;
  date: tdatetime;
  p_list: tstringlist;
begin
  fname := RepFile;
  if fname = '' then
    exit;
  if m_lastFile <> fname then
  begin
    m_saveBlockNum := 0;
  end
  else
    inc(m_saveBlockNum);
  m_lastFile := fname;

  InitExcel;
  if fileexists(fname) then
  begin
    OpenWorkBook(fname);
    if m_saveBlockNum = 0 then
    begin
      E.ActiveWorkbook.Sheets.Item[1].cells.clear;
    end;
  end
  else
  begin
    AddWorkBook;
    AddSheet('Page_01');
    // DeleteSheet(2);
  end;
  r0 := GetEmptyRow(1, 1, 2);
  begin
    // showmessage(E.ActiveWorkbook.Sheets.Item[1].cells[r0, 2]);
  end;
  // sheet, r, c, v
  SetCell(1, r0, 2, 'MeraFile:');
  SetCell(1, r0, 3, fname);
  SetCell(1, r0, 4, 'Time:');
  date := now;
  SetCell(1, r0, 5, DateToStr(date) + ' ' + TimeToStr(date));
  r := r0 + 2;
  c := 2;
  for i := 0 to g_PressCamFactory2.m_spmCfg.ChildCount - 1 do
  begin
    // имя сигнала
    // SetCell(1, r-1, c, f.Name);
    spm := cspm(g_PressCamFactory2.m_spmCfg.getAlg(i));
    str := spm.m_tag.tagname;
    SetCell(1, r - 1, c, str);
    SetCell(1, r, c, 'Band');
    SetCell(1, r, c + 1, 'A1');
    SetCell(1, r, c + 2, 'F1');
    SetCell(1, r, c + 3, 'Pk-Pk');
    // проход по формам (полосам)
    for j := 0 to g_PressCamFactory2.Count - 1 do
    begin
      // f := TPressFrm2(g_PressCamFactory2.GetFrm(j));
      f := TPressFrm2(g_PressCamFactory2.sortedFrames.Items[j]);
      fr := f.Frame(str);
      SetCell(1, r + 1 + j, c, floattostr(f.f1) + '...' + floattostr(f.f2));
      SetCell(1, r + 1 + j, c + 1, fr.m_Max);
      SetCell(1, r + 1 + j, c + 2, fr.m_f);
      SetCell(1, r + 1 + j, c + 3, fr.getA * 2);
    end;
    c := c + 4;
  end;
  // разметка заголовка
  rng := GetRangeObj(1, point(r, 2), point(r, c - 1));
  // c_Excel_GrayInd = 15;
  rng.Interior.ColorIndex := 15;
  rng.Font.Bold := true;
  // ставим сетку всего блока
  rng := GetRangeObj(1, point(r, 2), point(r + j, c - 1));
  SetRangeBorder(rng);

  str := ExtractFileDir(fname);
  SaveWorkBookAs(fname);

  fname := ExtractFileName(fname);
  p_list := tstringlist.create;
  fname := FindFileExt(fname, str + '\', 1, p_list);
  if fname = '' then
  begin
    if p_list.Count > 0 then
    begin
      fname := p_list.Strings[0];
      g_PressCamFactory2.m_RepFile := fname;
      m_lastFile := fname;
    end;
  end;
  p_list.destroy;
  CloseWorkBook;
  CloseExcel;
end;

procedure TPressFrm2.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  s: string;
  i, c: integer;
  Strings: tstringlist;
  w: TWndType;
begin
  inherited;
  g_PressCamFactory2.m_loadFile:=a_pIni.FileName;
  g_PressCamFactory2.m_Section:=str;
  c := a_pIni.ReadInteger(str, 'sCount', 0);
  if c > 0 then
  begin
    Strings := tstringlist.create;
    for i := 0 to c - 1 do
    begin
      s := a_pIni.ReadString(str, 's_' + inttostr(i), '');
      if s <> '' then
      begin
        Strings.Add(s);
      end;
    end;
    if Strings.Count > 0 then
    begin
      g_PressCamFactory2.CreateAlg(Strings);
      g_PressCamFactory2.createFrames(self);
    end;
    Strings.destroy;
  end;
  m_BargraphStep := a_pIni.ReadInteger(str, 'BarGraphStepCount', 100);
  m_BargraphStep := 100;
  m_bnum := a_pIni.ReadInteger(str, 'BNum', 0);
  if self = g_PressCamFactory2.GetFrm(0) then
  begin
    c := a_pIni.ReadInteger('PressCamFactory2', 'FFTCount', 256);
    s := 'FFTCount=' + inttostr(c) + ',';
    s := s + 'Wnd=' + a_pIni.ReadString(str, 'Wnd', 'Rect');
    g_PressCamFactory2.m_spmCfg.str := s;
    g_PressCamFactory2.BandCount := a_pIni.ReadInteger('PressCamFactory2',
      'BandCount', 0);
    g_PressCamFactory2.m_manualBand := a_pIni.ReadBool('PressCamFactory2',
      'ManualBand', false);
    g_PressCamFactory2.m_typeRes := a_pIni.ReadInteger('PressCamFactory2',
      'TypeRes', 0);
    g_PressCamFactory2.m_createTags := a_pIni.ReadBool('PressCamFactory2',
      'CreateTags', false);
    if g_PressCamFactory2.m_manualBand then
    begin
      s := a_pIni.ReadString('PressCamFactory2', 'Bands', '');
      g_PressCamFactory2.StrToBands(s);
    end
    else
    begin
      if g_PressCamFactory2.BandCount = 0 then
      begin
        g_PressCamFactory2.SetBCount(6);
      end;
    end;
    g_PressCamFactory2.m_Manualref := a_pIni.ReadBool('PressCamFactory2',
      'ManualRef', false);
    s := a_pIni.ReadString('PressCamFactory2', 'Refs', '');
    g_PressCamFactory2.StrToRefs(s);
  end;
  BNumIE.IntNum := m_bnum;
  bnumUpdate := true;
  // рисуем название полосы
  UpdateCaption;
  if g_PressCamFactory2.getSpm(0) <> nil then
  begin
    w := g_PressCamFactory2.GetWndType;
    WndCB.ItemIndex := integer(w);
  end;
  sortframes;
  g_PressCamFactory2.Sort;
end;

procedure cPressCamFactory2.doRecorderInit;
var
  ifile:TIniFile;
  I, c, len: Integer;
  s, scurve:string;
  tr:PTagRec;
begin
  if fileexists(m_loadFile) then
  begin
    ifile:=TIniFile.Create(m_loadFile);
    c:= ifile.ReadInteger(m_section, 'sCount', 0);
    for I := 0 to c - 1 do
    begin
      s:=ifile.ReadString(m_section, 's_' + inttostr(i), '');
      scurve:=ifile.ReadString(m_section, 'AFH_' + inttostr(i), '');
      tr:=getTag(s);
      if tr<>nil then
      begin
        if scurve<>'' then
        begin
          tr.m_curve:=cCurve.create;
          tr.m_curve.fromStr(scurve);
          len:=length(tdoublearray(tr.m_s.m_rms.p));
          if len>0 then
          begin
            tr.m_curve.getMemScaleData(len);
            tr.m_curve.EvalData;
            tr.m_s.SetScaleData(tr.m_curve.m_ScaleData.p);
          end;
          tr.m_s.SetUseScaleData(tr.m_curve.m_use);
        end;
      end;
    end;
  end;
end;

procedure TPressFrm2.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, c: integer;
  fr: TPressFrmFrame2;
  s: cspm;
  sig:ptagrec;
  lstr: string;
begin
  inherited;
  // сохраняется при загрузке iniFile GUI Recorder чтобы после инициализации всех структур донастроить
  c := 0;
  for i := 0 to m_frames.Count - 1 do
  begin
    fr := Frame(i);
    s := fr.spm;
    if s.m_tag.tagname <> '' then
    begin
      a_pIni.WriteString(str, 's_' + inttostr(c), s.m_tag.tagname);
    end;
    inc(c);
  end;
  if s <> nil then
    a_pIni.WriteString(str, 'Wnd', s.GetWndStr)
  else
    a_pIni.WriteString(str, 'Wnd', 'c_Rect');
  a_pIni.WriteInteger(str, 'BarGraphStepCount', m_BargraphStep);
  a_pIni.WriteInteger(str, 'sCount', c);
  // сохраняем АЧХ
  for I := 0 to c - 1 do
  begin
    sig:=g_PressCamFactory2.getTag(i);
    if sig.m_curve<>nil then
      lstr:=sig.m_curve.ToStr
    else
      lstr:='';
    a_pIni.WriteString(str, 'AFH_'+inttostr(i), lstr);
  end;
  a_pIni.WriteInteger(str, 'BNum', m_bnum);
  if self = g_PressCamFactory2.GetFrm(0) then
  begin
    lstr := getparam(s.GetProperties, 'FFTCount');
    a_pIni.WriteInteger('PressCamFactory2', 'FFTCount', strtoint(lstr));
    a_pIni.WriteInteger('PressCamFactory2', 'BandCount',
      g_PressCamFactory2.BandCount);
    a_pIni.WriteInteger('PressCamFactory2', 'TypeRes',
      g_PressCamFactory2.m_typeRes);
    a_pIni.WriteBool('PressCamFactory2', 'CreateTags',
      g_PressCamFactory2.m_createTags);

    a_pIni.WriteBool('PressCamFactory2', 'ManualBand',
      g_PressCamFactory2.m_manualBand);
    if g_PressCamFactory2.m_manualBand then
    begin
      a_pIni.WriteString('PressCamFactory2', 'Bands',
        g_PressCamFactory2.BandsToStr);
    end;
    a_pIni.WriteBool('PressCamFactory2', 'ManualRef',
      g_PressCamFactory2.m_Manualref);
    if g_PressCamFactory2.m_Manualref then
    begin
      a_pIni.WriteString('PressCamFactory2', 'Refs',
        g_PressCamFactory2.RefsToStr);
    end;
  end;
end;

procedure TPressFrm2.sortframes;
var
  s: cspm;
  j: integer;
  fr: TPressFrmFrame2;
begin

  // сортировка по размещению
  if m_frames.Count > 1 then
  begin
    for j := m_frames.Count - 1 downto 0 do
    begin
      s := g_PressCamFactory2.getSpm(j);
      fr := Frame(s.m_tag.tagname);
      fr.parent.Top := 0;
      fr.ProgrBar.Width := TPanel(fr.parent).Width - fr.ProgrBar.left - 4;
    end;
  end;
  for j := 0 to FrameCount - 1 do
  begin
    Frame(j).ProgrBar.MaxValue := m_BargraphStep;
  end;
end;

procedure TPressFrm2.UpdateCaption;
begin
  if bnumUpdate then
  begin
    if g_PressCamFactory2.BandCount > 0 then
    begin
      if g_PressCamFactory2.m_bands[m_bnum].f2 <> 0 then
      begin
        BarGraphGB.Caption := 'Band: ' + formatstr
          (g_PressCamFactory2.m_bands[m_bnum].f1, c_digs) + '..' + formatstr
          (g_PressCamFactory2.m_bands[m_bnum].f2, c_digs);
        bnumUpdate := false;
      end;
    end;
  end;
end;

procedure TPressFrm2.N1Click(Sender: TObject);
begin
  PressFrmEdit2.EditPressFrm(self);
end;

procedure TPressFrm2.OpenBtnClick(Sender: TObject);
begin
  // sortframes;
  if fileexists(m_lastFile) then
    ShellExecute(0, nil, pwidechar(m_lastFile), nil, nil, SW_HIDE);
end;

procedure TPressFrm2.PressFrmFrame21ProgrBarMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  PressFrmFrame21.ProgrBar.Hint := inttostr(PressFrmFrame21.ProgrBar.Width);
end;

procedure TPressFrm2.updatedata;
var
  time, sum: double;
  i: integer;
  fr: TPressFrmFrame2;
  b: boolean;
  t:TTagRec;
begin
  sum := 0;
  b := false;
  m_Max.Y := 0;
  m_ind := -1;
  for i := 0 to m_frames.Count - 1 do
  begin
    fr := Frame(i);
    if i = 0 then
    begin
      time := fr.spm.LastBlockTime;
      if (time > g_PressCamFactory2.fLastBlock) then
      begin
        g_PressCamFactory2.fLastBlock := time;
        b := true;
      end;
    end;
    // if b then
    begin
      //fr.Eval;
      t:=g_PressCamFactory2.m_tags[i];
      fr.m_Max:=t.m_SKO[m_bnum].rms_max;
      fr.m_f:=t.m_SKO[m_bnum].Freq;
      fr.m_A:=t.m_SKO[m_bnum].rms_mean;
      if m_Max.Y < fr.m_Max then
      begin
        m_Max.Y := fr.m_Max;
        m_Max.X := fr.m_f;
        m_ind := i;
      end;
    end;
  end;
end;

procedure TPressFrm2.UpdateView;
var
  i: integer;
  fr: TPressFrmFrame2;
begin
  if bWndUpdate then
  begin
    case WndCB.ItemIndex of
      0:
        g_PressCamFactory2.m_spmCfg.str := 'Wnd=Rect';
      1:
        g_PressCamFactory2.m_spmCfg.str := 'Wnd=Hamming';
      2:
        g_PressCamFactory2.m_spmCfg.str := 'Wnd=Hann'; // Хеннинг
      3:
        g_PressCamFactory2.m_spmCfg.str := 'Wnd=Blackmann';
      4:
        g_PressCamFactory2.m_spmCfg.str := 'Wnd=Flattop';
    end;
    bWndUpdate := false;
  end;
  for i := 0 to m_frames.Count - 1 do
  begin
    fr := TPressFrmFrame2(m_frames[i]);
    fr.UpdateView;
    if bnumUpdate then
    begin
      if BNumIE.IntNum > g_PressCamFactory2.BandCount then
      begin
        BNumIE.IntNum := g_PressCamFactory2.BandCount - 1
      end
      else
      begin
        m_bnum := BNumIE.IntNum;
      end;
      UpdateCaption;
    end;

    if g_PressCamFactory2.m_typeRes = 0 then
    begin
      MaxAE.Text := formatstrnoe(m_Max.Y / sqrt2, c_digs);
    end
    else
    begin
      MaxAE.Text := formatstrnoe(m_Max.Y * 2, c_digs);
    end;
    MaxFE.Text := formatstrnoe(m_Max.X, c_digs);
    MaxCamE.Text := inttostr(m_ind + 1);
  end;
end;

procedure TPressFrm2.WndCBChange(Sender: TObject);
begin
  bWndUpdate := true;
end;

end.
