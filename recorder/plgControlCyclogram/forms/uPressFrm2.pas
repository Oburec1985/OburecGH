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

  TPressFrm2 = class(TRecFrm)
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
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    SaveBtn: TSpeedButton;
    PressFrmFrame21: TPressFrmFrame2;
    procedure N1Click(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
  public
    m_lastFile:string;
    m_saveBlockNum:integer;

    BGraphFrames:tlist;
    m_manualBand:boolean;
    // максимум (по умолчанию из тега)
    m_ManualRange:boolean;
    m_RefAmp:double;
    m_f1, m_f2,
    m_HH,
    m_H:double;
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
    procedure setBCount(bc:integer);
    procedure setSName(str:string);
    procedure AutoEvalBands;
    procedure UpdateView;
    procedure updatedata;
    procedure doStart;
    procedure doStop;
    procedure UpdateFrames;
    function BandsToStr:string;
    procedure StrToBands(s:string);
    function Frame(i:integer):TPressFrmFrame2;
  public
    property BandCount:integer read fBCount write setBCount;
    procedure CreateFrame(sname:string; fftNum:integer);
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
  result:=TPressFrmFrame2(BGraphFrames.Items[i]);
end;

function TPressFrm2.BandsToStr: string;
var
  I: Integer;
  fr:TPressFrmFrame2;
begin
  result:='';
  for I := 0 to BGraphFrames.Count - 1 do
  begin
    fr:=Frame(i);
    //result:=result+floattostr(fr.m_f1)+','+floattostr(fr.m_f2)+';';
  end;
end;

procedure TPressFrm2.BGraphFramesClear;
var
  I: Integer;
  fr:TPressFrmFrame2;
begin
  for I := 1 to BGraphFrames.Count - 1 do
  begin
    fr:=Frame(i);
    fr.Destroy;
  end;
  BGraphFrames.Clear;
end;

constructor TPressFrm2.create(Aowner: tcomponent);
begin
  inherited;
  m_HH:=0.7;
  m_H:=0.5;
  BGraphFrames:=tlist.Create;
  setBCount(6);
end;

procedure TPressFrm2.CreateFrame(sname: string; fftNum: integer);
begin

end;

destructor TPressFrm2.destroy;
begin
  inherited;
  BGraphFrames.Destroy;
end;

procedure TPressFrm2.doStart;
var
  fr:TPressFrmFrame2;
  i:integer;
begin
  if (not fInitBands) and (not m_manualBand) then
  begin
    AutoEvalBands;
  end;
  for I := 0 to BandCount - 1 do
  begin
    fr:=TPressFrmFrame2(BGraphFrames[i]);
    fr.Prepare;
    // обновляем диапазон
    //if m_spm.m_tag<>nil then
    //begin
    //  if not m_ManualRange then
    //  begin
    //    m_RefAmp:=m_Spm.m_tag.GetMaxYValue;
    //  end;
    //end;
    UpdateFrames;
  end;
end;

procedure TPressFrm2.doStop;
var
  fr:TPressFrmFrame2;
  i:integer;
begin
  for I := 0 to BandCount - 1 do
  begin
    fr:=TPressFrmFrame2(BGraphFrames[i]);
    fr.Stop;
  end;
end;

procedure TPressFrm2.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  s:string;
begin
  inherited;
  //SensorName:=a_pIni.ReadString(str, 'SensorName', '');
  m_manualBand:=a_pIni.ReadBool(str, 'ManualBand', false);
  if m_manualBand then
  begin
    s:=a_pIni.ReadString(str, 'Bands', '');
    StrToBands(s);
  end;
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
  fname:string;
  I,j,r,c, r0: Integer;
  f:TPressFrm2;
  fr:TPressFrmFrame2;
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
  for I := 0 to g_PressCamFactory2.count - 1 do
  begin
    f:=TPressFrm2(g_PressCamFactory2.GetFrm(i));
    // имя сигнала
    //SetCell(1, r-1, c, f.Name);
    //SetCell(1, r-1, c, f.SensorName);
    SetCell(1, r, c, 'Band');
    SetCell(1, r, c+1, 'A1');
    SetCell(1, r, c+2, 'F1');
    SetCell(1, r, c+3, 'Amp.av');
    for j := 0 to f.bandcount - 1 do
    begin
      fr:=f.Frame(j);
      //SetCell(1, r+1+j, c, floattostr(fr.m_f1)+'...'+floattostr(fr.m_f2));
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

procedure TPressFrm2.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
begin
  inherited;
  //a_pIni.WriteString(str, 'SensorName', getSName);
  if m_manualBand then
  begin
    a_pIni.WriteBool(str, 'ManualBand', m_manualBand);
    a_pIni.WriteString(str, 'Bands', BandsToStr);
  end;
end;

procedure TPressFrm2.N1Click(Sender: TObject);
begin
  //PressFrmEdit.EditPressFrm(self);
end;

procedure TPressFrm2.setBCount(bc:integer);
var
  I: Integer;
  p:tpanel;
  c:tcomponent;
  fr:TPressFrmFrame2;
  txt:string;
begin
  for i:=fbCount-1 downto 1 do
  begin
    c:=BarGraphGB.FindComponent(BarPanel.name+'_'+inttostr(i));
    c.Destroy;
  end;
  BGraphFramesClear;
  BGraphFrames.Add(PressFrmFrame21);
  //PressFrmFrame1.spm:=m_spm;
  for I := 0 to bc - 2 do
  begin
    txt:=BarPanel.name+'_'+inttostr(i);
    p:=TPanel.Create(self);
    p.parent:=BarGraphGB;
    p.Align:=alTop;
    p.Width:=BarPanel.Width;
    p.Height:=BarPanel.Height;
    fr:=TPressFrmFrame2.Create(nil);
    fr.name:=fr.classname+'_'+inttostr(i);
    fr.Parent:=p;
    BGraphFrames.Add(fr);
    fr.FreqEdit.Text:='0';
    fr.AmpE.Text:='0';
    //fr.spm:=m_Spm;
  end;
  // сортировка по размещению
  if fbCount>1 then
  begin
    for I :=fbCount-1 to 1 do
    begin
      fr:=Frame(i);
      fr.Top:=0;
    end;
  end;
  BarPanel.top:=0;
  fbCount:=bc;
  AutoEvalBands;
end;

procedure TPressFrm2.AutoEvalBands;
var
  df:double;
  fr:TPressFrmFrame2;
  i:integer;
begin
  if m_manualBand then exit;
  //if m_spm=nil then exit;
  //if m_spm.m_tag=nil then exit;
  //if m_spm.m_tag.tag<>nil then
  //begin
  //  df:=m_spm.m_tag.freq/2;
  //  df:=round(df/BGraphFrames.Count);
  //  for I := 0 to BGraphFrames.Count - 1 do
  //  begin
  //    fr:=BGraphFrames.Items[i];
  //    fr.BandLabel.Caption:='B_'+inttostr(i+1);
  //    fr.FreqEdit.Text:='0';
  //    fr.AmpE.Text:='0';
  //    fr.m_f1:=i*df;
  //    fr.m_f2:=fr.m_f1+df;
  //    fr.m_A:=0;
  //    fr.m_f:=0;
  //    fr.m_Max:=0;
  //  end;
  //  fInitBands:=true;
  //end;
end;

procedure TPressFrm2.setSName(str: string);
var
  i:integer;
  fr:TPressFrmFrame2;
  t:itag;
begin
  t:=getTagByName(str);
  {if t<>nil then
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
  end;}
end;

procedure TPressFrm2.StrToBands(s: string);
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
    fr:=Frame(i);
    //fr.m_f1:=strtofloatext(f);
    f:=getSubStrByIndex(s1,',',1, 1);
    //fr.m_f2:=strtofloatext(f);
  end;
end;

procedure TPressFrm2.updatedata;
var
  time, sum:double;
  I: Integer;
  fr:TPressFrmFrame2;
  p2:point2d;
  ind:integer;
begin
  //time:=m_Spm.LastBlockTime;
  if time>fLastBlock then
  begin
    sum:=0;
    for I := 0 to BandCount - 1 do
    begin
      fr:=TPressFrmFrame2(BGraphFrames[i]);
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

procedure TPressFrm2.UpdateFrames;
var
  I: Integer;
  fr:TPressFrmFrame2;
begin
  for I := 0 to BandCount - 1 do
  begin
    fr:=TPressFrmFrame2(BGraphFrames[i]);
    fr.m_RefAmp:=m_RefAmp;
    fr.m_hh:=m_hh;
    fr.m_h:=m_h;
  end;
end;

procedure TPressFrm2.UpdateView;
var
  I: Integer;
  fr:TPressFrmFrame2;
begin
  for I := 0 to BandCount - 1 do
  begin
    fr:=TPressFrmFrame2(BGraphFrames[i]);
    fr.updateView;
    MaxAE.Text:=formatstrnoe(m_max.y, c_digs);
    MaxFE.Text:=formatstrnoe(m_max.x, c_digs);
    MaxCamE.Text:=inttostr(m_ind);
    MaxAvrAE.Text:=formatstrnoe(m_AvrA, c_digs);
  end;
end;

end.
