unit uTagInfoFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath,
  uRecorderEvents, ubaseObj, uCommonTypes, uRCFunc,
  uRTrig, ubasealg, uBuffTrend1d, tags,
  PluginClass, ImgList, Menus;

type
  TTagInfoPair = record
    v: integer;
    str: string;
    color: tcolor;
    bckgnd: tcolor;
  end;

  PTagInfoPair = ^TTagInfoPair;

  TTagInfoFrm = class(TRecFrm)
    TopPanel: TPanel;
    RichText: TRichEdit;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure N1Click(Sender: TObject);
  private
    fcapacity: integer;
    fcount: integer;
    m_textPairs: array of TTagInfoPair;
  public
    m_tag: ctag;
    lastval: integer;
  private
  protected
    procedure RBtnClick(Sender: TObject);
    procedure UpdateData;

    function getTextLabel: string;
    procedure setTextLabel(t: string);

    function getShowLabel: boolean;
    procedure setShowLabel(b: boolean);
    function getLabelFont: tfont;
    procedure setLabelFont(f: tfont);
    function getFont: tfont;
    procedure setFont(f: tfont);
    function getCount: integer;
    procedure setCount(c: integer);
    procedure setCapacity(c: integer);
  public
    procedure setpair(index: integer; p: TTagInfoPair);
    function getpair(index: integer): TTagInfoPair;
    function get(i: integer): PTagInfoPair;
    procedure delete(i: integer);
    property count: integer read getCount write setCount;
    property LabelFont: tfont read getLabelFont write setLabelFont;
    property Font: tfont read getFont write setFont;
    property ShowLabel: boolean read getShowLabel write setShowLabel;
    property TextLabel: string read getTextLabel write setTextLabel;
    function addTextInfo(v: integer; str: string; c: tcolor;
      backcol: tcolor): PTagInfoPair;
    procedure ClearTextInfo;
  public
    property pair[index: integer]: TTagInfoPair read getpair write setpair;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  ITagInfoFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cTagInfoFactory = class(cRecBasicFactory)
  private
    m_counter: integer;
  protected
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doStart;
    procedure CreateEvents;
    procedure DestroyEvents;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

const
  // ctrl+shift+G
  // ['{CF0EF3CE-51AC-4C37-B2F6-B86D1A47854F}']
  IID_TAGINFO: TGuid = (D1: $CF0EF3CE; D2: $51AC; D3: $4C37;
    D4: ($B2, $F6, $B8, $6D, $1A, $47, $85, $4F));

  c_Pic = 'TAGINFO';
  c_Name = 'Значение в текст';
  c_defXSize = 370;
  c_defYSize = 90;

var
  g_TagInfoFactory: cTagInfoFactory;
  TagInfoFrm: TTagInfoFrm;

implementation

uses
  uTagInfoEditFrm;
{$R *.dfm}

{ TTagInfoFrm }
function TTagInfoFrm.addTextInfo(v: integer; str: string; c: tcolor;
  backcol: tcolor): PTagInfoPair;
var
  i: integer;
begin
  if fcount+1>fcapacity then
  begin
    setcapacity(fcount+50);
  end;
  m_textPairs[fcount].v := v;
  m_textPairs[fcount].str := str;
  m_textPairs[fcount].color := c;
  m_textPairs[fcount].bckgnd := backcol;
  result := @m_textPairs[fcount];
  inc(fcount);
end;

procedure TTagInfoFrm.ClearTextInfo;
begin
  setlength(m_textPairs, 0);
end;

function TTagInfoFrm.getCount: integer;
begin
  result := fcount;
end;

procedure TTagInfoFrm.setCount(c: integer);
begin
  fcount := c;
  if fcount > fcapacity then
  begin
    setCapacity(fcount+50);
  end;
end;

constructor TTagInfoFrm.create(Aowner: tcomponent);
begin
  inherited;
  m_tag := ctag.create;
  lastval := -1;
end;

procedure TTagInfoFrm.delete(i: integer);
var
  copylen: integer;
begin
  copylen := count - 1 - i;
  move(m_textPairs[i], m_textPairs[i + 1], copylen * sizeof(TTagInfoPair));
  setlength(m_textPairs, length(m_textPairs) - 1);
end;

destructor TTagInfoFrm.destroy;
begin
  LogRecorderMessage('TTagInfoFrm.destroy_enter');
  m_tag.destroy;
  inherited;
  LogRecorderMessage('TTagInfoFrm.destroy_exit');
end;

procedure TTagInfoFrm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  RBtnClick(nil);
end;

function TTagInfoFrm.getLabelFont: tfont;
begin
  result := TopPanel.Font;
end;

function TTagInfoFrm.getpair(index: integer): TTagInfoPair;
begin
  result := m_textPairs[index];
end;

procedure TTagInfoFrm.setpair(index: integer; p: TTagInfoPair);
begin
  m_textPairs[index] := p;
end;

procedure TTagInfoFrm.setLabelFont(f: tfont);
begin
  TopPanel.Font := f;
end;

function TTagInfoFrm.get(i: integer): PTagInfoPair;
begin
  result := @m_textPairs[i];
end;

function TTagInfoFrm.getFont: tfont;
begin
  result := RichText.Font;
end;

procedure TTagInfoFrm.setCapacity(c: integer);
begin
  if fcapacity < c then
  begin
    fcapacity := c;
    setlength(m_textPairs, c);
  end;
end;

procedure TTagInfoFrm.setFont(f: tfont);
begin
  RichText.Font := f;
end;

function TTagInfoFrm.getShowLabel: boolean;
begin
  result := TopPanel.Visible;
end;

function TTagInfoFrm.getTextLabel: string;
begin
  result := TopPanel.Caption;
end;

procedure TTagInfoFrm.setShowLabel(b: boolean);
begin
  TopPanel.Visible := b;
end;

procedure TTagInfoFrm.setTextLabel(t: string);
begin
  TopPanel.Caption := t;
end;

procedure SaveFontToIni(ifile: TIniFile; f: tfont; key, section: string);
var
  str: string;
begin
  str := f.name + ';' + inttostr(f.SIZE);
  ifile.WriteString(section, key, str);
end;

procedure LoadFontIni(ifile: TIniFile; f: tfont; key, section: string);
var
  str, lstr: string;
  i, ind, len, state: integer;
begin
  str := ifile.ReadString(section, key, '');
  len := length(str);
  i := 1;
  state := 0;
  while (i < len) and (ind > -1) do
  begin
    lstr := GetSubString(str, ';', i, ind);
    i := ind + 1;
    case state of
      0:
        f.name := lstr;
      1:
        f.SIZE := strtoIntExt(lstr);
    end;
    inc(state);
  end;
end;

procedure TTagInfoFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, c: integer;
  t: ctag;
begin
  inherited;
  t := LoadTagIni(a_pIni, str, 'Tag');
  TopPanel.Caption := a_pIni.ReadString(str, 'TInfo_LabelText', '');
  LoadFontIni(a_pIni, Font, 'Font', str);
  LoadFontIni(a_pIni, LabelFont, 'LabelFont', str);
  if t <> nil then
  begin
    m_tag.destroy;
    m_tag := t;
  end;
  c := a_pIni.ReadInteger(str, 'StrCount', 0);
  count:=c;
  for i := 0 to c - 1 do
  begin
    m_textPairs[i].v := a_pIni.ReadInteger(str, 'TInfo_v_' + inttostr(i), i);
    m_textPairs[i].color := a_pIni.ReadInteger(str,'TInfo_Color_' + inttostr(i), clBlack);
    m_textPairs[i].bckgnd := a_pIni.ReadInteger(str, 'TInfo_BackColor_' + inttostr(i), clWindow);
    m_textPairs[i].str := a_pIni.ReadString(str, 'TInfo_str_' + inttostr(i),'');
  end;
end;

procedure TTagInfoFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
begin
  inherited;
  saveTagToIni(a_pIni, m_tag, str, 'Tag');
  a_pIni.WriteString(str, 'TInfo_LabelText', TopPanel.Caption);
  a_pIni.WriteInteger(str, 'StrCount', count);
  SaveFontToIni(a_pIni, Font, 'Font', str);
  SaveFontToIni(a_pIni, LabelFont, 'LabelFont', str);
  for i := 0 to count - 1 do
  begin
    a_pIni.WriteInteger(str, 'TInfo_v_' + inttostr(i), m_textPairs[i].v);
    a_pIni.WriteInteger(str, 'TInfo_Color_' + inttostr(i),
      m_textPairs[i].color);
    a_pIni.WriteInteger(str, 'TInfo_BackColor_' + inttostr(i),
      m_textPairs[i].bckgnd);
    a_pIni.WriteString(str, 'TInfo_str_' + inttostr(i), m_textPairs[i].str);
  end;
end;

procedure TTagInfoFrm.N1Click(Sender: TObject);
begin
  RBtnClick(nil);
end;

procedure TTagInfoFrm.RBtnClick(Sender: TObject);
begin
  TagInfoEditFrm.EditTextInfo(self);
end;

procedure TTagInfoFrm.UpdateData;
var
  i, v: integer;
  p: TTagInfoPair;
begin
  if m_tag.tag=nil then
    exit;

  v := round(GetScalar(m_tag.tag));
  if v <> lastval then
  begin
    for i := 0 to count - 1 do
    begin
      p := m_textPairs[i];
      if p.v = v then
        break;
    end;
    LogRecorderMessage('TTagInfoFrm_UpdateData_enter');
    RichText.text := p.str;
    RichText.Font.color := p.color;
    RichText.color := p.bckgnd;
    LogRecorderMessage('TTagInfoFrm_UpdateData_exit');
  end;
  lastval := v;
end;

{ cTagInfoFactory }
constructor cTagInfoFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_TAGINFO;
  // GateSettingsFrm  := TGateSettingsFrm.Create(nil);
  // SelectChannelFrm := TSelectChannelFrm.Create(nil);
  CreateEvents;
end;

destructor cTagInfoFactory.destroy;
begin
  DestroyEvents;
  inherited;
end;

procedure cTagInfoFactory.doChangeRState(Sender: TObject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
      end;
    RSt_StopToView:
      begin
        doStart;
      end;
    RSt_StopToRec:
      begin
        doStart;
      end;
    RSt_ViewToStop:
      begin

      end;
    RSt_ViewToRec:
      begin

      end;
    RSt_initToRec:
      begin
        doStart;
      end;
    RSt_initToView:
      begin
        doStart;
      end;
    RSt_RecToStop:
      begin
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

procedure cTagInfoFactory.doUpdateData(Sender: TObject);
var
  i: integer;
  Frm: TRecFrm;
begin
  // for i := 0 to m_CompList.Count - 1 do
  // begin
  // Frm := GetFrm(i);
  // TTagInfoFrm(Frm).UpdateData;
  // end;
end;

function cTagInfoFactory.doCreateForm: cRecBasicIFrm;
begin
  result := ITagInfoFrm.create();
end;

procedure cTagInfoFactory.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure cTagInfoFactory.CreateEvents;
begin
  addplgevent('cPolarFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cPolarFactory_doChangeRState', c_RC_DoChangeRCState,
    doChangeRState);
end;

procedure cTagInfoFactory.DestroyEvents;
begin
  removeplgEvent(doUpdateData, c_RUpdateData);
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cTagInfoFactory.doStart;
begin

end;

{ ITagInfoFrm }

procedure ITagInfoFrm.doClose;
begin
  m_lRefCount := 1;
end;

function ITagInfoFrm.doCreateFrm: TRecFrm;
begin
  result := TTagInfoFrm.create(nil);
end;

function ITagInfoFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function ITagInfoFrm.doRepaint: boolean;
begin
  TTagInfoFrm(m_pMasterWnd).UpdateData;
end;

end.
