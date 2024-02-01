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
    RcComboBox1: TRcComboBox;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure N1Click(Sender: TObject);
  public
    m_tag:ctag;
    m_Spm:cSpm;
    BGraphFrames:tlist;
  private
    fNumCam:integer;
    fBCount:integer;
    fLastBlock:double;
  private
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
    m_meraFile: string;
    m_spmCfg:cAlgConfig;
  private
    m_counter: integer;
  protected
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
  c_Name = 'јнализ камер сгорани€';
  c_defXSize = 530;
  c_defYSize = 530;


  // ctrl+shift+G
  // ['{54C462CD-E137-4BA6-9EB5-EFD92D159DE5}']
  IID_PRESS: TGuid = (D1: $54C462CD; D2: $E137; D3: $4BA6;
    D4: ($9E, $B5, $EF, $D9, $2D, $15, $9D, $E5));

implementation
uses
 uPressFrmEdit;

{$R *.dfm}

{ IPressCamFactory }

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

end;

procedure cPressCamFactory.doStart;
var
  i: integer;
  Frm: TPressCamFrm;
begin
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
procedure TPressCamFrm.BGraphFramesClear;
var
  I: Integer;
  fr:TPressFrmFrame;
begin
  for I := 1 to BGraphFrames.Count - 1 do
  begin
    fr:=TPressFrmFrame(BGraphFrames.Items[i]);
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
begin
  inherited;
  SensorName:=a_pIni.ReadString(str, 'SensorName', '');
end;

procedure TPressCamFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
begin
  inherited;
  a_pIni.WriteString(str, 'SensorName', getSName);
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
  if m_spm=nil then exit;
  if m_spm.m_tag<>nil then
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
    // если тега нет, запоминаем им€
    if m_tag.tag=nil then
    begin
      m_tag.tagname:=str;
    end;
  end;
  if m_spm<>nil then
  begin
    m_spm.Properties:='Channel='+str;
    AutoEvalBands;
    // установка resname (к нему спектры цепл€ютс€ (отображение))
    m_spm.resname:=m_spm.genTagName;
  end;
end;

procedure TPressCamFrm.updatedata;
var
  time:double;
  I: Integer;
  fr:TPressFrmFrame;
begin
  time:=m_Spm.LastBlockTime;
  if time>fLastBlock then
  begin
    for I := 0 to BandCount - 1 do
    begin
      fr:=TPressFrmFrame(BGraphFrames[i]);
      fr.Eval;
    end;
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
  end;
end;

end.
