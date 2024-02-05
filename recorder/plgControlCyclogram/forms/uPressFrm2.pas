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

    m_frames:tlist;
    // �������� (�� ��������� �� ����)
    m_ManualRange:boolean;
    m_RefAmp:double;
    m_f1, m_f2,
    m_HH,
    m_H:double;
  private
    fInitBands:boolean;
    fLastBlock:double;
    m_Max:point2d;
    m_ind:integer;
    m_AvrA:double;
  private
    procedure InitExcel;
    procedure ClearFrames;
    procedure UpdateView;
    procedure updatedata;
    procedure doStart;
    procedure doStop;
    function BandsToStr:string;
    procedure StrToBands(s:string);
    function Frame(i:integer):TPressFrmFrame2;
  public
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
    m_manualBand:boolean;
    m_bands:array of tband;
    // merafile
    m_RepFile: string;
    m_spmCfg:cAlgConfig;
  private
    // ����� �������� �����������
    m_counter: integer;

  protected
    procedure GenRepFilePath;
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
    // ������������ �������
    procedure CreateAlgConfig;
    function getSpm(i:integer):cspm;overload;
    function getSpm(s:string):cspm;overload;
    // ����������� ������ � �������
    procedure ReevalBands(s:cspm);
  public
    procedure doAfterLoad; override;
    procedure doUpdateData(sender: tobject);
    procedure doChangeRState(sender: tobject);
    procedure doStart;
    procedure doStop;
    // �������� �� ���� ������ ����� � ������� cspm-�
    procedure CreateAlg(list:tstrings);
    procedure createFrames;
    procedure SetBCount(c:integer);
    function getBCount: integer;
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
  c_Name = '������ ����� ��������2';
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

procedure cPressCamFactory2.CreateAlg(list: tstrings);
var
  I: Integer;
  sname:string;
  spm:cspm;
begin
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
    for j := 1 to m_spmCfg.ChildCount - 1 do
    begin
      s:=getSpm(j);
      frm.CreateFrame(s.m_tag.tagname);
    end;
    // ���������� �� ����������
    if Frm.m_frames.Count>1 then
    begin
      for j :=Frm.m_frames.Count-1 downto 0 do
      begin
        fr:=frm.Frame(j);
        fr.Top:=0;
      end;
    end;
  end;
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

function cPressCamFactory2.getBCount: integer;
begin
  result:=Length(m_bands);
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
  for I := 0 to Length(m_bands) - 1 do
  begin
    m_bands[i].i1:=s.getIndByX(m_bands[i].f1);
    m_bands[i].i2:=s.getIndByX(m_bands[i].f2);
  end;
end;

procedure cPressCamFactory2.SetBCount(c:integer);
var
  I: Integer;
  f,df:double;
  s:cspm;
begin
  setlength(m_bands,c);
  s:=getSpm(0);
  if s=nil then exit;
  if s.m_tag=nil then exit;
  if s.m_tag.tag=nil then exit;
  df:=s.m_tag.freq/2;
  df:=round(df/c);
  f:=0;
  for I := 0 to c - 1 do
  begin
    m_bands[i].f1:=f;
    m_bands[i].f2:=m_bands[0].f1+df;
    f:=m_bands[i].f2;
  end;
  if not m_manualBand then
    ReEvalBands(s);
end;

function cPressCamFactory2.getSpm(i: integer): cspm;
begin
  result:=cspm(m_spmCfg.getAlg(i));
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

function TPressFrm2.BandsToStr: string;
var
  I: Integer;
  fr:TPressFrmFrame2;
begin
  result:='';
  for I := 0 to m_frames.Count - 1 do
  begin
    fr:=Frame(i);
    //result:=result+floattostr(fr.m_f1)+','+floattostr(fr.m_f2)+';';
  end;
end;

procedure TPressFrm2.ClearFrames;
var
  I: Integer;
  fr:TPressFrmFrame2;
  c:tcomponent;
begin
  for i:=m_frames.Count-1 downto 1 do
  begin
    c:=BarGraphGB.FindComponent(BarPanel.name+'_'+inttostr(i));
    c.Destroy;
  end;
  for I := 1 to m_frames.Count - 1 do
  begin
    fr:=Frame(i);
    fr.Destroy;
  end;
  m_frames.Clear;
end;

constructor TPressFrm2.create(Aowner: tcomponent);
begin
  inherited;
  m_HH:=0.7;
  m_H:=0.5;
  m_frames:=tlist.Create;
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

procedure TPressFrm2.doStart;
var
  fr:TPressFrmFrame2;
  i:integer;
begin
  //if (not fInitBands) and (not m_manualBand) then
  begin

  end;
end;

procedure TPressFrm2.doStop;
var
  fr:TPressFrmFrame2;
  i:integer;
begin

end;

procedure TPressFrm2.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  s:string;
begin
  inherited;
  //SensorName:=a_pIni.ReadString(str, 'SensorName', '');
  //m_manualBand:=a_pIni.ReadBool(str, 'ManualBand', false);
  //if m_manualBand then
  begin
    //s:=a_pIni.ReadString(str, 'Bands', '');
    //StrToBands(s);
  end;
end;

procedure TPressFrm2.InitExcel;
begin
  if not CheckExcelInstall then
  begin
    showmessage('���������� ��������� Excel');
    exit;
  end;
  CreateExcel;
  VisibleExcel(true);
end;
// �������� ����� ������ � ������� ��������� ������ ������
// �������� ���� �� ������� col � ����� sh ������� � sh
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
    // ��� �������
    //SetCell(1, r-1, c, f.Name);
    //SetCell(1, r-1, c, f.SensorName);
    SetCell(1, r, c, 'Band');
    SetCell(1, r, c+1, 'A1');
    SetCell(1, r, c+2, 'F1');
    SetCell(1, r, c+3, 'Amp.av');
    //for j := 0 to f.bandcount - 1 do
    //begin
    //  fr:=f.Frame(j);
      //SetCell(1, r+1+j, c, floattostr(fr.m_f1)+'...'+floattostr(fr.m_f2));
    //  SetCell(1, r+1+j, c+1, fr.m_max);
    //  SetCell(1, r+1+j, c+2, fr.m_f);
    //  SetCell(1, r+1+j, c+3, fr.m_A);
    //end;
    c:=c+4;
  end;
  // �������� ���������
  rng:=GetRangeObj(1, point(r, 2), point(r,c-1));
  // c_Excel_GrayInd = 15;
  rng.Interior.ColorIndex := 15;
  rng.Font.Bold:=True;
  // ������ ����� ����� �����
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
  //if m_manualBand then
  begin
    //a_pIni.WriteBool(str, 'ManualBand', m_manualBand);
    a_pIni.WriteString(str, 'Bands', BandsToStr);
  end;
end;

procedure TPressFrm2.N1Click(Sender: TObject);
begin
  PressFrmEdit2.EditPressFrm(self);
end;


procedure TPressFrm2.StrToBands(s: string);
var
  s1, f:string;
  I, ind: Integer;
  fr:TPressFrmFrame2;
begin
  ind:=1;
  //for I := 0 to BandCount - 1 do
  //begin
    s1:=getSubStrByIndex(s,';',1, i);
    if s1='' then
    begin
      //m_manualBand:=false;
      ///break;
    end;
    f:=getSubStrByIndex(s1,',',1, 0);
    fr:=Frame(i);
    //fr.m_f1:=strtofloatext(f);
    f:=getSubStrByIndex(s1,',',1, 1);
    //fr.m_f2:=strtofloatext(f);
  //end;
end;

procedure TPressFrm2.updatedata;
begin

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
    MaxAvrAE.Text:=formatstrnoe(m_AvrA, c_digs);
  end;
end;

end.
