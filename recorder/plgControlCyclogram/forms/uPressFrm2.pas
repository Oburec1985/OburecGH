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
  uSpm, uBaseAlg,
  opengl, uSimpleObjects,
  math, uAxis, uDrawObj, uDoubleCursor, uBasicTrend,
  Dialogs, ExtCtrls, StdCtrls, DCL_MYOWN, Spin, Buttons, uPressFrmFrame2,
  uRcCtrls, Menus;

type
  tband = record
    f1,f2:double;
    i1,i2:integer;
  end;

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
    PressFrmFrame21: TPressFrmFrame2;
    procedure N1Click(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
  public
    m_lastFile:string;
    m_saveBlockNum:integer;
    m_bnum:integer;

    m_frames:tlist;
    // максимум (по умолчанию из тега)
    m_ManualRange:boolean;
    m_HH,
    m_H:double;
    //
    m_Max:point2d;
  private
    fInitBands:boolean;
    m_ind:integer;
  private
    procedure InitExcel;
    procedure ClearFrames;
    procedure UpdateView;
    procedure updatedata;
    procedure doStart;
    procedure doStop;
    function Frame(i:integer):TPressFrmFrame2;overload;
    function Frame(s:string):TPressFrmFrame2;overload;
    function Ready:boolean;
    procedure UpdateCaption;
  public
    function f1:double;
    function f2:double;
    procedure CreateFrame(sname:string);
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
    fLastBlock:double;
    // пересчитано в интдексы или нет
    M_InitBands:boolean;
    m_manualBand:boolean;
    m_bands:array of tband;
    // merafile
    m_RepFile: string;
    m_spmCfg:cAlgConfig;
    // manual
    m_Manualref:boolean;
    // список ref для каждого датчика
    m_refArray:array of double;
    //
    m_createTags:boolean;
    m_typeRes:integer;
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
    function getSpm(i:integer):cspm;overload;
    function getSpm(s:string):cspm;overload;
    // пересчитать полосы в индексы
    procedure ReevalBands(s:cspm);
  public
    function GetRef(i:integer):double;
    procedure doAfterLoad; override;
    procedure doUpdateData(sender: tobject);
    procedure doChangeRState(sender: tobject);
    procedure doStart;
    procedure doStop;
    // ПОЛУЧАЕТ НА ВХОД список тегов и создает cspm-ы
    procedure CreateAlg(list:tstrings);
    procedure createFrames;overload;
    procedure createFrames(f:tform);overload;
    procedure AutoEvalBand(t:itag);
    procedure SetBCount(c:integer);
    function getBCount: integer;
    function BandsToStr: string;
    procedure StrToBands(s:string);
  public
    constructor create;
    destructor destroy; override;
    property BandCount:integer read getBCount write setBCount;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

var
  g_PressCamFactory2:cPressCamFactory2;

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
function RepFile:string;
begin
  result:=g_PressCamFactory2.m_RepFile;
end;

procedure cPressCamFactory2.StrToBands(s: string);
var
  s1, f:string;
  I, ind: Integer;
  fr:TPressFrmFrame2;
begin
  ind:=1;
  for I := 0 to BandCount - 1 do
  begin
    s1:=getSubStrByIndex(s,';',1, i);
    if s1='' then
    begin
      m_manualBand:=false;
      break;
    end;
    f:=getSubStrByIndex(s1,',',1, 0);
    m_bands[i].f1:=strtofloatext(f);
    f:=getSubStrByIndex(s1,',',1, 1);
    m_bands[i].f2:=strtofloatext(f);
  end;
end;

function cPressCamFactory2.BandsToStr: string;
var
  I: Integer;
  fr:TPressFrmFrame2;
  b:tband;
begin
  result:='';
  for I := 0 to BandCount - 1 do
  begin
    b:=m_bands[i];
    result:=result+floattostr(b.f1)+','+floattostr(b.f2)+';';
  end;
end;

procedure cPressCamFactory2.CreateAlg(list: tstrings);
var
  I, j: Integer;
  sname:string;
  spm:cspm;
  find:boolean;
begin
  // удаляем лишние
  for I := m_spmCfg.childCount - 1 downto 0 do
  begin
    spm:=cspm(m_spmCfg.getAlg(i));
    find:=false;
    for j := 0 to List.Count - 1 do
    begin
      if spm.m_tag.tagname=list.Strings[j] then
      begin
        find:=true;
        break;
      end;
    end;
    if not find then
    begin
      m_spmCfg.delAlg(spm);
    end;
  end;
  // добавляем новые
  for I := 0 to list.Count - 1 do
  begin
    sname:=list.Strings[i];
    spm:=getSpm(sname);
    if spm=nil then
    begin
      spm:=cSpm(g_algMng.CreateObjByType('cSpm'));
      if g_PressCamFactory2.m_spmCfg.str='' then
      begin
        g_PressCamFactory2.m_spmCfg.str:=spm.Properties;
      end;
      spm.Properties:='Channel='+sname;
      g_PressCamFactory2.m_spmCfg.AddChild(spm);
      g_algMng.Add(spm, nil);
    end;
  end;
end;

procedure cPressCamFactory2.createFrames(f:tform);
var
  i: integer;
  Frm: TPressFrm2;
  fr:TPressFrmFrame2;
  j: Integer;
  s:cspm;
begin
  Frm:=TPressFrm2(f);
  Frm.ClearFrames;
  Frm.m_frames.Add(Frm.PressFrmFrame21);
  s:=getSpm(0);
  Frm.PressFrmFrame21.spm:=g_PressCamFactory2.getSpm(s.m_tag.tagname);
  Frm.barpanel.ShowHint:=true;
  Frm.barpanel.Hint:=s.m_tag.tagname;

  for j := 1 to m_spmCfg.ChildCount - 1 do
  begin
    s:=getSpm(j);
    frm.CreateFrame(s.m_tag.tagname);
  end;
  // сортировка по размещению
  if Frm.m_frames.Count>1 then
  begin
    for j :=Frm.m_frames.Count-1 downto 0 do
    begin
      fr:=frm.Frame(j);
      fr.parent.Top:=0;
    end;
  end;
end;

procedure cPressCamFactory2.createFrames;
var
  i: integer;
  Frm: TPressFrm2;
  fr:TPressFrmFrame2;
  j: Integer;
  s:cspm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := TPressFrm2(GetFrm(i));
    Frm.ClearFrames;

    Frm.m_frames.Add(Frm.PressFrmFrame21);
    s:=getSpm(0);
    Frm.PressFrmFrame21.spm:=g_PressCamFactory2.getSpm(s.m_tag.tagname);
    Frm.barpanel.ShowHint:=true;
    Frm.barpanel.Hint:=s.m_tag.tagname;

    for j := 1 to m_spmCfg.ChildCount - 1 do
    begin
      s:=getSpm(j);
      frm.CreateFrame(s.m_tag.tagname);
    end;
  end;
  // сортировка по размещению
  if Frm.m_frames.Count>1 then
  begin
    for j :=Frm.m_frames.Count-1 downto 0 do
    begin
      fr:=frm.Frame(j);
      fr.parent.Top:=0;
    end;
  end;
  setlength(m_refArray, m_spmCfg.ChildCount);
end;


procedure cPressCamFactory2.CreateAlgConfig;
var
  I: Integer;
  f:TPressFrm2;
begin
  if g_algMng<>nil then
  begin
    if m_spmCfg=nil then
    begin
      m_spmCfg:=g_algMng.newCfg(cSpm.ClassName,cSpm);
      m_spmCfg.name:='Pressure_spmCfg';
      m_spmCfg.m_NotSaveCfg:=true;
    end;
  end;
end;

procedure cPressCamFactory2.createevents;
begin
  addplgevent('cSRSFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cSRSFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
end;

constructor cPressCamFactory2.create;
begin
  inherited;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_PRESS;
  createevents;
end;

destructor cPressCamFactory2.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cPressCamFactory2.destroyevents;
begin

end;

procedure cPressCamFactory2.doAfterLoad;
var
  s:cspm;
begin
  inherited;
  CreateAlgConfig;
end;

procedure cPressCamFactory2.doChangeRState(sender: tobject);
begin
 case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
        doStop;
      end;
    RSt_StopToView:
      begin
        //g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_StopToRec:
      begin
        //g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_ViewToStop:
      begin
        doStop;
      end;
    RSt_ViewToRec:
      begin
        //g_SRSFactory.m_meraFile := GetMeraFile;
      end;
    RSt_initToRec:
      begin
        //g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_initToView:
      begin
        //g_SRSFactory.m_meraFile := GetMeraFile;
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
  fLastBlock:=-1;
  GenRepFilePath;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := TPressFrm2(GetFrm(i));
    Frm.doStart;
  end;
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

procedure cPressCamFactory2.doUpdateData(sender: tobject);
var
  i: integer;
  Frm: TRecFrm;
begin
  //if g_disableFRF then
  //  exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TPressFrm2(Frm).updatedata;
  end;
end;

procedure cPressCamFactory2.GenRepFilePath;
var
  mf:string;
begin
  mf:=GetMeraFile;
  m_RepFile:=ExtractFileDir(mf)+'\PressCamReport'+'.xlsx';
end;

function cPressCamFactory2.getBCount: integer;
begin
  result:=Length(m_bands);
end;

function cPressCamFactory2.GetRef(i: integer): double;
var
  s:cSpm;
begin
  if m_Manualref then
    result:=m_refArray[i]
  else
  begin
    s:=getSpm(i);
    if s<>nil then
    begin
      result:=s.m_tag.GetMaxYValue;
    end;
  end;
end;

function cPressCamFactory2.getSpm(s: string): cspm;
var
  I: Integer;
  spm:cspm;
begin
  result:=nil;
  for I := 0 to m_spmCfg.childCount - 1 do
  begin
    spm:=cspm(m_spmCfg.getAlg(i));
    if spm.m_tag<>nil then
    begin
      if spm.m_tag.tagname=s then
      begin
        result:=spm;
        exit;
      end;
    end;
  end;
end;

procedure cPressCamFactory2.ReevalBands(s:cspm);
var
  I: Integer;
begin
  M_InitBands:=true;
  if s<>nil then
  begin
    for I := 0 to Length(m_bands) - 1 do
    begin
      m_bands[i].i1:=s.getIndByX(m_bands[i].f1);
      m_bands[i].i2:=s.getIndByX(m_bands[i].f2);
    end;
  end;
end;

procedure cPressCamFactory2.SetBCount(c:integer);
var
  s:cspm;
begin
  setlength(m_bands,c);
  s:=getSpm(0);
  if s=nil then exit;
  if s.m_tag=nil then exit;
  if s.m_tag.tag=nil then exit;
  if not m_manualBand then
  begin
    AutoEvalBand(s.m_tag.tag);
    ReEvalBands(s);
  end;
end;

procedure cPressCamFactory2.AutoEvalBand(t:itag);
var
  I: Integer;
  f,df:double;
  frm:TPressFrm2;
begin
  M_InitBands:=false;
  if BandCount=0 then exit;
  if m_bands[0].f2=0 then
  begin
    df:=t.GetFreq/2;
    df:=round(df/bandCount);
    f:=0;
    for I := 0 to bandCount - 1 do
    begin
      m_bands[i].f1:=f;
      m_bands[i].f2:=f+df;
      f:=m_bands[i].f2;
    end;
  end;
  for I := 0 to count - 1 do
  begin
    frm:=TPressFrm2(getfrm(i));
    frm.UpdateCaption;
  end;
end;

function cPressCamFactory2.getSpm(i: integer): cspm;
begin
  if m_spmCfg.ChildCount>0 then
    result:=cspm(m_spmCfg.getAlg(i))
  else
    result:=nil;
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
function TPressFrm2.Frame(i:integer): TPressFrmFrame2;
begin
  result:=TPressFrmFrame2(m_frames.Items[i]);
end;


function TPressFrm2.Frame(s: string): TPressFrmFrame2;
var
  I: Integer;
  fr:TPressFrmFrame2;
begin
  for I := 0 to m_frames.count - 1 do
  begin
    fr:=Frame(i);
    if fr.spm.m_tag.tagname=s then
    begin
      result:=fr;
      exit;
    end;
  end;
end;

procedure TPressFrm2.ClearFrames;
var
  I: Integer;
  fr:TPressFrmFrame2;
  c:tcomponent;
begin
  //for i:=m_frames.Count-1 downto 1 do
  //begin
  //  c:=BarGraphGB.FindComponent(BarPanel.name+'_'+inttostr(i));
  //  if c<>nil then
  //    c.Destroy;
  //end;
  for I := 1 to m_frames.Count - 1 do
  begin
    fr:=Frame(i);
    fr.Parent.Destroy;
  end;
  m_frames.Clear;
end;

constructor TPressFrm2.create(Aowner: tcomponent);
begin
  inherited;
  m_HH:=0.7;
  m_H:=0.5;
  m_frames:=tlist.Create;
  PressFrmFrame21.m_frm:=self;
end;

procedure TPressFrm2.CreateFrame(sname: string);
var
  fr:TPressFrmFrame2;
  p:tpanel;
  i:integer;
  txt:string;
begin
  i:=m_frames.Count;
  txt:=BarPanel.name+'_'+inttostr(i);
  p:=TPanel.Create(self);
  p.parent:=BarGraphGB;
  p.Align:=alTop;
  p.Width:=BarPanel.Width;
  p.Height:=BarPanel.Height;
  p.name:=txt;

  p.ShowHint:=true;
  p.Hint:=sname;

  fr:=TPressFrmFrame2.Create(nil);
  fr.name:=fr.classname+'_'+inttostr(i);
  fr.Parent:=p;
  fr.FreqEdit.Text:='0';
  fr.AmpE.Text:='0';
  fr.spm:=g_PressCamFactory2.getSpm(sname);
  fr.m_frm:=self;

  m_Frames.Add(fr);
end;

destructor TPressFrm2.destroy;
begin
  inherited;
  m_frames.Destroy;
end;

function TPressFrm2.Ready: boolean;
var
  s:cspm;
begin
  result:=false;
  s:=PressFrmFrame21.spm;
  if s<>nil then
  begin
    if s.m_tag<>nil then
    begin
      if s.m_tag.tag<>nil then
      begin
        result:=true;
      end;
    end;
  end;
end;

procedure TPressFrm2.doStart;
var
  fr:TPressFrmFrame2;
  i:integer;
begin
  if Ready then
  begin
    g_PressCamFactory2.AutoEvalBand(PressFrmFrame21.spm.m_tag.tag);
    g_PressCamFactory2.ReevalBands(PressFrmFrame21.spm);
  end;
  for I := 0 to m_frames.Count - 1 do
  begin
    fr:=Frame(i);
    fr.Prepare;
  end;
end;

procedure TPressFrm2.doStop;
var
  fr:TPressFrmFrame2;
  i:integer;
begin

end;


function TPressFrm2.f1: double;
begin
  result:=g_PressCamFactory2.m_bands[m_bnum].f1;
end;

function TPressFrm2.f2: double;
begin
  result:=g_PressCamFactory2.m_bands[m_bnum].f2;
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
function GetEmptyRow(sh, r0, col:integer):integer;
var
  ws:olevariant;
  res:string;
  r:integer;
begin
  ws:=E.ActiveWorkbook.Sheets.Item[sh];
  r:=r0;
  res:=ws.cells[r0,col];
  while res<>'' do
  begin
    inc(r0);
    res:=ws.cells[r0,col];
  end;
  result:=r0;
end;

procedure TPressFrm2.SaveBtnClick(Sender: TObject);
var
  fname, str:string;
  I,j,r,c, r0: Integer;
  f:TPressFrm2;
  fr:TPressFrmFrame2;
  rng:OleVariant;
  spm:cspm;
  k: Integer;
begin
  fname:=RepFile;
  if fname='' then exit;
  if m_lastFile<>fname then
  begin
    m_saveBlockNum:=0;
  end
  else
    inc(m_saveBlockNum);
  m_lastFile:=fname;

  InitExcel;
  if fileexists(fname) then
  begin
    OpenWorkBook(fname);
    if m_saveBlockNum=0 then
      E.ActiveWorkbook.Sheets.Item[1].cells.clear;
  end
  else
  begin
    AddWorkBook;
    AddSheet('Page_01');
    DeleteSheet(2);
  end;
  r0:=GetEmptyRow(1,1,2);
  // sheet, r, c, v
  SetCell(1, r0, 2, 'MeraFile:');
  SetCell(1, r0, 3, fname);
  SetCell(1, r0, 4, 'Time:');
  SetCell(1, r0, 5, DateToStr(date)+' '+TimeToStr(date));
  r:=r0+2;
  c:=2;
  for I := 0 to g_PressCamFactory2.m_spmCfg.ChildCount - 1 do
  begin
    // имя сигнала
    //SetCell(1, r-1, c, f.Name);
    spm:=cspm(g_PressCamFactory2.m_spmCfg.getAlg(i));
    str:=spm.m_tag.tagname;
    SetCell(1, r-1, c, str);
    SetCell(1, r, c, 'Band');
    SetCell(1, r, c+1, 'A1');
    SetCell(1, r, c+2, 'F1');
    SetCell(1, r, c+3, 'Amp.av');
    // проход по формам (полосам)
    for j := 0 to g_PressCamFactory2.Count - 1 do
    begin
      f:=TPressFrm2(g_PressCamFactory2.GetFrm(j));
      fr:=f.Frame(str);
      SetCell(1, r+1+j, c, floattostr(f.f1)+'...'+floattostr(f.f2));
      SetCell(1, r+1+j, c+1, fr.m_max);
      SetCell(1, r+1+j, c+2, fr.m_f);
      SetCell(1, r+1+j, c+3, fr.m_A);
    end;
    c:=c+4;
  end;
  // разметка заголовка
  rng:=GetRangeObj(1, point(r, 2), point(r,c-1));
  // c_Excel_GrayInd = 15;
  rng.Interior.ColorIndex := 15;
  rng.Font.Bold:=True;
  // ставим сетку всего блока
  rng:=GetRangeObj(1, point(r, 2), point(r+j, c-1));
  SetRangeBorder(rng);

  SaveWorkBookAs(fname);
  CloseWorkBook;
  CloseExcel;
end;

procedure TPressFrm2.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  s:string;
  i,c:integer;
  strings:tstringlist;
begin
  inherited;
  c:=a_pIni.ReadInteger(str, 'sCount', 0);
  if c>0 then
  begin
    strings:=tstringlist.Create;
    for I := 0 to c - 1 do
    begin
      s:=a_pIni.ReadString(str, 's_'+inttostr(i), '');
      if s<>'' then
      begin
        strings.Add(s);
      end;
    end;
    if strings.Count>0 then
    begin
      g_PressCamFactory2.CreateAlg(strings);
      g_PressCamFactory2.CreateFrames(self);
    end;
    strings.Destroy;
  end;
  m_bnum:=a_pIni.ReadInteger(str, 'BNum', 0);
  if self=g_PressCamFactory2.GetFrm(0) then
  begin
    c:=a_pIni.ReadInteger('PressCamFactory2', 'FFTCount', 256);
    g_PressCamFactory2.m_spmCfg.str:='FFTCount='+inttostr(c);
    g_PressCamFactory2.BandCount:=a_pIni.ReadInteger('PressCamFactory2', 'BandCount', 0);
    g_PressCamFactory2.m_manualBand:=a_pIni.ReadBool('PressCamFactory2', 'ManualBand', false);
    g_PressCamFactory2.m_typeRes:=a_pIni.ReadInteger('PressCamFactory2', 'TypeRes', 0);
    g_PressCamFactory2.m_createTags:=a_pIni.ReadBool('PressCamFactory2', 'CreateTags', false);

    if g_PressCamFactory2.m_manualBand then
    begin
      s:=a_pIni.ReadString('PressCamFactory2', 'Bands', '');
      g_PressCamFactory2.StrToBands(s);
    end
    else
    begin
      if g_PressCamFactory2.bandCount=0 then
      begin
        g_PressCamFactory2.SetBCount(6);
      end;
    end;
  end;
  // рисуем название полосы
  updateCaption;
end;


procedure TPressFrm2.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, c: integer;
  fr:TPressFrmFrame2;
  s:cspm;
  lstr:string;
begin
  inherited;
  c:=0;
  for I := 0 to m_frames.Count - 1 do
  begin
    fr:=Frame(i);
    s:=fr.spm;
    if s.m_tag.tagname<>'' then
    begin
      a_pIni.WriteString(str, 's_'+inttostr(c), s.m_tag.tagname);
    end;
    inc(c);
  end;
  a_pIni.WriteInteger(str, 'sCount', c);
  a_pIni.WriteInteger(str, 'BNum', m_bnum);
  if self=g_PressCamFactory2.GetFrm(0) then
  begin
    lstr:=GetParam(g_PressCamFactory2.m_spmCfg.str, 'FFTCount');
    a_pIni.WriteInteger('PressCamFactory2', 'FFTCount', strtoint(lstr));
    a_pIni.WriteInteger('PressCamFactory2', 'BandCount', g_PressCamFactory2.BandCount);
    a_pIni.WriteBool('PressCamFactory2', 'ManualBand', g_PressCamFactory2.m_manualBand);

    a_pIni.WriteInteger('PressCamFactory2', 'TypeRes', g_PressCamFactory2.m_typeRes);
    a_pIni.WriteBool('PressCamFactory2', 'CreateTags', g_PressCamFactory2.m_createTags);
    if g_PressCamFactory2.m_manualBand then
    begin
      a_pIni.WriteString('PressCamFactory2', 'Bands', g_PressCamFactory2.BandsToStr);
    end;
  end;
end;

procedure TPressFrm2.UpdateCaption;
begin
  if g_PressCamFactory2.BandCount>0 then
  begin
    if g_PressCamFactory2.m_bands[m_bnum].f2<>0 then
    begin
      BarGraphGB.Caption:='Band: '+formatstr(g_PressCamFactory2.m_bands[m_bnum].f1, c_digs)+'..'+formatstr(g_PressCamFactory2.m_bands[m_bnum].f2, c_digs);
    end;
  end;
end;

procedure TPressFrm2.N1Click(Sender: TObject);
begin
  PressFrmEdit2.EditPressFrm(self);
end;

procedure TPressFrm2.OpenBtnClick(Sender: TObject);
begin
  if fileexists(m_lastFile) then
    ShellExecute(0,nil,pwidechar(m_lastFile),nil,nil, SW_HIDE);
end;

procedure TPressFrm2.updatedata;
var
  time, sum:double;
  I: Integer;
  fr:TPressFrmFrame2;
  b:boolean;
begin
  sum:=0;
  b:=false;
  m_Max.y:=0;
  m_ind:=-1;
  for I := 0 to m_frames.Count-1 do
  begin
    fr:=Frame(i);
    if i=0 then
    begin
      time:=fr.spm.LastBlockTime;
      if (time>g_PressCamFactory2.fLastBlock) then
      begin
        g_PressCamFactory2.fLastBlock:=time;
        b:=true;
      end;
    end;
    //if b then
    begin
      fr.Eval;
      if m_Max.y<fr.m_Max then
      begin
        m_Max.y:=fr.m_Max;
        m_Max.x:=fr.m_f;
        m_ind:=i;
      end;
    end;
  end;
end;

procedure TPressFrm2.UpdateView;
var
  I: Integer;
  fr:TPressFrmFrame2;
begin
  for I := 0 to m_frames.Count - 1 do
  begin
    fr:=TPressFrmFrame2(m_frames[i]);
    fr.updateView;
    MaxAE.Text:=formatstrnoe(m_max.y, c_digs);
    MaxFE.Text:=formatstrnoe(m_max.x, c_digs);
    MaxCamE.Text:=inttostr(m_ind);
  end;
end;

end.
