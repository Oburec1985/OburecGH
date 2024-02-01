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
  TPresRec = record
    AvrA:double;
    MaxA:double;
    Fr:double;
    f1,f2:double;
  end;

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
  private
    fNumCam:integer;
    fBCount:integer;
    BGraphFrames:tlist;
  private
    procedure initFrm;
    procedure setBCount(bc:integer);
    function getSName:string;
    procedure setSName(str:string);
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
  PressCamFrm: TPressCamFrm;
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
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    //Frm := GetFrm(i);
    //TSRSFrm(Frm).doStart;
  end;
end;

procedure cPressCamFactory.doStop;
begin

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
    //TSRSFrm(Frm).updatedata;
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
  //TSRSFrm(m_pMasterWnd).UpdateView;
end;

{ TPressCamFrm }

constructor TPressCamFrm.create(Aowner: tcomponent);
begin
  inherited;
  m_tag:=cTag.create;
  BGraphFrames:=tlist.Create;
  setBCount(6);
end;

destructor TPressCamFrm.destroy;
begin
  inherited;
  m_tag.destroy;
  BGraphFrames.Destroy;
end;

function TPressCamFrm.getSName: string;
begin
  result:=m_tag.tagname;
end;

procedure TPressCamFrm.initFrm;
begin
  if m_spm=nil then
  begin
    m_spm:=cSpm(g_algMng.CreateObjByType('cSpm'));
    //f.m_spm.name:=f.+'_spm_r'+inttostr(i);
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
  BGraphFrames.Clear;
  BGraphFrames.Add(PressFrmFrame1);
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
  end;
  BarPanel.top:=0;
  for I := 0 to BGraphFrames.Count - 1 do
  begin
    fr:=BGraphFrames.Items[i];
    fr.BandLabel.Caption:='Range_'+inttostr(i+1);
    fr.FreqEdit.Text:='0';
    fr.AmpE.Text:='0';
  end;
  if m_spm=nil then
  begin
    m_spm:=cSpm(g_algMng.CreateObjByType('cSpm'));
    m_spm.name:=name+'_spm_r'+inttostr(i);
    g_PressCamFactory.m_spmCfg.str:=m_spm.Properties;
    g_PressCamFactory.m_spmCfg.AddChild(m_spm);
    g_algMng.Add(m_spm, nil);
  end;
  fbCount:=bc;
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
    // установка resname (к нему спектры цепл€ютс€ (отображение))
    m_spm.resname:=m_spm.genTagName;
  end;
end;

end.
