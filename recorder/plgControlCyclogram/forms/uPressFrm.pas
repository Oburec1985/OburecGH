unit uPressFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath,
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
  Dialogs, ExtCtrls, StdCtrls, DCL_MYOWN, Spin, Buttons, uPressFrmFrame,
  uRcCtrls, Menus;

type

  TPressCamFrm = class(TRecFrm)
    BarGraphGB: TGroupBox;
    BarPanel: TPanel;
    Panel1: TPanel;
    MaxLabel: TLabel;
    MaxFreqLabel: TLabel;
    MaxCamLabel: TLabel;
    AvgAmpLabel: TLabel;
    MaxAE: TEdit;
    MaxFE: TEdit;
    MaxCamE: TEdit;
    MaxAvrAE: TEdit;
    UnitMaxALab: TLabel;
    UnitMaxFLab: TLabel;
    UnitMaxAvrALab: TLabel;
    AvrCB: TCheckBox;
    PressFrmFrame1: TPressFrmFrame;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    SaveBtn: TSpeedButton;
    procedure N1Click(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
  public
    m_lastFile:string;
    m_saveBlockNum:integer;

    m_tag:ctag;
    m_Spm:cSpm;
    BGraphFrames:tlist;
    m_manualBand:boolean;
  private
    fInitBands:boolean;
    fNumCam:integer;
    fBCount:integer;
    fLastBlock:double;
    m_Max:point2d;
    m_ind:integer;
    m_AvrA:double;
  private
    procedure InitExcel;
    procedure BGraphFramesClear;
    procedure initFrm;
    procedure setBCount(bc:integer);
    function getSName:string;
    procedure setSName(str:string);
    procedure AutoEvalBands;
    procedure UpdateView;
    procedure updatedata;
    procedure doStart;
    procedure doStop;
    function BandsToStr:string;
    procedure StrToBands(s:string);
    function BandFrame(i:integer):TPressFrmFrame;
  public
    property SensorName:string read getSName write setSName;
    property BandCount:integer read fBCount write setBCount;
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IPressCamFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cPressCamFactory = class(cRecBasicFactory)
  public
    // merafile
    m_RepFile: string;
    m_spmCfg:cAlgConfig;
  private
    m_counter: integer;
  protected
    procedure GenRepFilePath;
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
    // конфигуратор спектра
    procedure CreateAlgConfig;
  public
    procedure doAfterLoad; override;
    procedure doUpdateData(sender: tobject);
    procedure doChangeRState(sender: tobject);
    procedure doStart;
    procedure doStop;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

var
  g_PressCamFactory:cPressCamFactory;

const
  c_Pic = 'PRESSFRM';
  c_Name = 'Анализ камер сгорания';
  c_defXSize = 560;
  c_defYSize = 355;


  // ctrl+shift+G
  // ['{54C462CD-E137-4BA6-9EB5-EFD92D159DE5}']
  IID_PRESS: TGuid = (D1: $54C462CD; D2: $E137; D3: $4BA6;
    D4: ($9E, $B5, $EF, $D9, $2D, $15, $9D, $E5));

implementation
uses
 uPressFrmEdit;

{$R *.dfm}

{ IPressCamFactory }
function RepFile:string;
begin
  result:=g_PressCamFactory.m_RepFile;
end;

procedure cPressCamFactory.CreateAlgConfig;
var
  I: Integer;
  f:TPressCamFrm;
begin
  if g_algMng<>nil then
  begin
    if m_spmCfg=nil then
    begin
      m_spmCfg:=g_algMng.newCfg(cSpm.ClassName,cSpm);
      m_spmCfg.m_NotSaveCfg:=true;
    end;
    for I := 0 to count - 1 do
    begin
      f:=TpressCamFrm(getfrm(i));
      f.initFrm;
    end;
  end;
end;

procedure cPressCamFactory.createevents;
begin
  addplgevent('cSRSFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cSRSFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
end;

constructor cPressCamFactory.create;
begin
  inherited;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_PRESS;
  createevents;
end;

destructor cPressCamFactory.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cPressCamFactory.destroyevents;
begin

end;

procedure cPressCamFactory.doAfterLoad;
begin
  inherited;
  CreateAlgConfig;
end;

procedure cPressCamFactory.doChangeRState(sender: tobject);
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

function cPressCamFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  result := IPressCamFrm.create();
  inc(m_counter);
end;

procedure cPressCamFactory.doDestroyForms;
begin
  inherited;

end;

procedure cPressCamFactory.doSetDefSize(var PSize: SIZE);
begin
  inherited;
  PSize.cx := c_defXSize;
  PSize.cy := c_defYSize;
end;

procedure cPressCamFactory.doStart;
var
  i: integer;
  Frm: TPressCamFrm;
begin
  GenRepFilePath;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := TPressCamFrm(GetFrm(i));
    Frm.doStart;
  end;
end;

procedure cPressCamFactory.doStop;
var
  i: integer;
  Frm: TPressCamFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := TPressCamFrm(GetFrm(i));
    Frm.doStop;
  end;
end;

procedure cPressCamFactory.doUpdateData(sender: tobject);
var
  i: integer;
  Frm: TRecFrm;
begin
  //if g_disableFRF then
  //  exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TPressCamFrm(Frm).updatedata;
  end;
end;

procedure cPressCamFactory.GenRepFilePath;
var
  mf:string;
begin
  mf:=GetMeraFile;
  m_RepFile:=ExtractFileDir(mf)+'\PressCamReport'+'.xlsx';
end;

{ IPressCamFrm }

procedure IPressCamFrm.doClose;
begin
  m_lRefCount := 1;
end;

function IPressCamFrm.doCreateFrm: TRecFrm;
begin
  result := TPressCamFrm.create(nil);
end;

function IPressCamFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function IPressCamFrm.doRepaint: boolean;
begin
  inherited;
  TPressCamFrm(m_pMasterWnd).UpdateView;
end;

{ TPressCamFrm }
function TPressCamFrm.BandFrame(i:integer): TPressFrmFrame;
begin
  result:=TPressFrmFrame(BGraphFrames.Items[i]);
end;

function TPressCamFrm.BandsToStr: string;
var
  I: Integer;
  fr:TPressFrmFrame;
begin
  result:='';
  for I := 0 to BGraphFrames.Count - 1 do
  begin
    fr:=BandFrame(i);
    result:=result+floattostr(fr.m_f1)+','+floattostr(fr.m_f2)+';';
  end;
end;

procedure TPressCamFrm.BGraphFramesClear;
var
  I: Integer;
  fr:TPressFrmFrame;
begin
  for I := 1 to BGraphFrames.Count - 1 do
  begin
    fr:=BandFrame(i);
    fr.Destroy;
  end;
  BGraphFrames.Clear;
end;

constructor TPressCamFrm.create(Aowner: tcomponent);
begin
  inherited;
  m_tag:=cTag.create;
  BGraphFrames:=tlist.Create;
  initFrm;
  setBCount(6);
end;

destructor TPressCamFrm.destroy;
begin
  inherited;
  m_tag.destroy;
  BGraphFrames.Destroy;
end;

procedure TPressCamFrm.doStart;
var
  fr:TPressFrmFrame;
  i:integer;
begin
  if (not fInitBands) and (not m_manualBand) then
  begin
    AutoEvalBands;
  end;
  for I := 0 to BandCount - 1 do
  begin
    fr:=TPressFrmFrame(BGraphFrames[i]);
    fr.Prepare;
  end;
end;

procedure TPressCamFrm.doStop;
var
  fr:TPressFrmFrame;
  i:integer;
begin
  for I := 0 to BandCount - 1 do
  begin
    fr:=TPressFrmFrame(BGraphFrames[i]);
    fr.Stop;
  end;
end;

function TPressCamFrm.getSName:string;
begin
  result:=m_tag.tagname;
end;

procedure TPressCamFrm.initFrm;
begin
  if m_spm=nil then
  begin
    m_spm:=cSpm(g_algMng.CreateObjByType('cSpm'));
    g_PressCamFactory.m_spmCfg.str:=m_spm.Properties;
    g_PressCamFactory.m_spmCfg.AddChild(m_spm);
    g_algMng.Add(m_spm, nil);
  end;
end;

procedure TPressCamFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  s:string;
begin
  inherited;
  SensorName:=a_pIni.ReadString(str, 'SensorName', '');
  m_manualBand:=a_pIni.ReadBool(str, 'ManualBand', false);
  if m_manualBand then
  begin
    s:=a_pIni.ReadString(str, 'Bands', '');
    StrToBands(s);
  end;
end;

procedure TPressCamFrm.InitExcel;
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

procedure TPressCamFrm.SaveBtnClick(Sender: TObject);
var
  fname:string;
  I,j,r,c, r0: Integer;
  f:TPressCamFrm;
  fr:tpressfrmframe;
  rng:OleVariant;
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
  for I := 0 to g_PressCamFactory.count - 1 do
  begin
    f:=TPressCamFrm(g_PressCamFactory.GetFrm(i));
    // имя сигнала
    //SetCell(1, r-1, c, f.Name);
    SetCell(1, r-1, c, f.SensorName);
    SetCell(1, r, c, 'Band');
    SetCell(1, r, c+1, 'A1');
    SetCell(1, r, c+2, 'F1');
    SetCell(1, r, c+3, 'Amp.av');
    for j := 0 to f.bandcount - 1 do
    begin
      fr:=f.BandFrame(j);
      SetCell(1, r+1+j, c, floattostr(fr.m_f1)+'...'+floattostr(fr.m_f2));
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

procedure TPressCamFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
begin
  inherited;
  a_pIni.WriteString(str, 'SensorName', getSName);
  if m_manualBand then
  begin
    a_pIni.WriteBool(str, 'ManualBand', m_manualBand);
    a_pIni.WriteString(str, 'Bands', BandsToStr);
  end;
end;

procedure TPressCamFrm.N1Click(Sender: TObject);
begin
  PressFrmEdit.EditPressFrm(self);
end;

procedure TPressCamFrm.setBCount(bc:integer);
var
  I: Integer;
  p:tpanel;
  c:tcomponent;
  fr:TPressFrmFrame;
  txt:string;
begin
  for i:=fbCount-1 downto 1 do
  begin
    c:=BarGraphGB.FindComponent(BarPanel.name+'_'+inttostr(i));
    c.Destroy;
  end;
  BGraphFramesClear;
  BGraphFrames.Add(PressFrmFrame1);
  PressFrmFrame1.spm:=m_spm;
  for I := 0 to bc - 2 do
  begin
    txt:=BarPanel.name+'_'+inttostr(i);
    p:=TPanel.Create(self);
    p.parent:=BarGraphGB;
    p.Align:=alTop;
    p.Width:=BarPanel.Width;
    p.Height:=BarPanel.Height;
    fr:=TPressFrmFrame.Create(nil);
    fr.name:=fr.classname+'_'+inttostr(i);
    fr.Parent:=p;
    BGraphFrames.Add(fr);
    fr.FreqEdit.Text:='0';
    fr.AmpE.Text:='0';
    fr.spm:=m_Spm;
  end;
  BarPanel.top:=0;
  fbCount:=bc;
  AutoEvalBands;
end;

procedure TPressCamFrm.AutoEvalBands;
var
  df:double;
  fr:TPressFrmFrame;
  i:integer;
begin
  if m_manualBand then exit;
  if m_spm=nil then exit;
  if m_spm.m_tag=nil then exit;
  if m_spm.m_tag.tag<>nil then
  begin
    df:=m_spm.m_tag.freq/2;
    df:=round(df/BGraphFrames.Count);
    for I := 0 to BGraphFrames.Count - 1 do
    begin
      fr:=BGraphFrames.Items[i];
      fr.BandLabel.Caption:='Range_'+inttostr(i+1);
      fr.FreqEdit.Text:='0';
      fr.AmpE.Text:='0';
      fr.m_f1:=i*df;
      fr.m_f2:=fr.m_f1+df;
      fr.m_A:=0;
      fr.m_f:=0;
      fr.m_Max:=0;
    end;
    fInitBands:=true;
  end;
end;

procedure TPressCamFrm.setSName(str: string);
var
  i:integer;
  fr:TPressFrmFrame;
  t:itag;
begin
  t:=getTagByName(str);
  if t<>nil then
  begin
    if t<>m_tag.tag then
    begin
      m_tag.tag:=t;
    end;
  end
  else
  begin
    // если тега нет, запоминаем имя
    if m_tag.tag=nil then
    begin
      m_tag.tagname:=str;
    end;
  end;
  BarGraphGB.Caption:=str;
  if m_spm<>nil then
  begin
    m_spm.Properties:='Channel='+str;
    m_spm.m_tag.tagname:=str;
    // установка resname (к нему спектры цепляются (отображение))
    m_spm.resname:=m_spm.genTagName;
    AutoEvalBands;
  end;
end;

procedure TPressCamFrm.StrToBands(s: string);
var
  s1, f:string;
  I, ind: Integer;
  fr:TPressFrmFrame;
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
    fr:=BandFrame(i);
    fr.m_f1:=strtofloatext(f);
    f:=getSubStrByIndex(s1,',',1, 1);
    fr.m_f2:=strtofloatext(f);
  end;
end;

procedure TPressCamFrm.updatedata;
var
  time, sum:double;
  I: Integer;
  fr:TPressFrmFrame;
  p2:point2d;
  ind:integer;
begin
  time:=m_Spm.LastBlockTime;
  if time>fLastBlock then
  begin
    sum:=0;
    for I := 0 to BandCount - 1 do
    begin
      fr:=TPressFrmFrame(BGraphFrames[i]);
      fr.Eval;
      if (i=0) or (p2.y<fr.m_Max) then
      begin
        ind:=i;
        p2.x:=fr.m_f;
        p2.y:=fr.m_Max;
      end;
      sum:=fr.m_A+sum;
    end;
    m_Max:=p2;
    m_ind:=ind;
    m_AvrA:=sum/bandCount;
  end;
end;

procedure TPressCamFrm.UpdateView;
var
  I: Integer;
  fr:TPressFrmFrame;
begin
  for I := 0 to BandCount - 1 do
  begin
    fr:=TPressFrmFrame(BGraphFrames[i]);
    fr.updateView;
    MaxAE.Text:=floattostr(m_max.y);
    MaxFE.Text:=floattostr(m_max.x);
    MaxCamE.Text:=inttostr(m_ind);
    MaxAvrAE.Text:=floattostr(m_AvrA);
  end;
end;

end.
