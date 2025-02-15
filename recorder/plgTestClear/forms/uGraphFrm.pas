unit uGraphFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uRecBasicFactory, inifiles,
  uEventList, //udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath,
  uRecorderEvents, ubaseObj, uCommonTypes, uRCFunc,
  //uBuffTrend1d,
  tags,
  PluginClass, ImgList, Menus;

type
  TTagInfoPair = record
    v: integer;
    str: string;
    color: tcolor;
    bckgnd: tcolor;
  end;

  PTagInfoPair = ^TTagInfoPair;

  TTestFrm = class(TRecFrm)
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    //constructor create(Aowner: tcomponent); override;
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
  //TagInfoFrm: TTagInfoFrm;

implementation

uses
  //uTagInfoEditFrm;
{$R *.dfm}

constructor TTestFrm.create(Aowner: tcomponent);
begin
  inherited;
end;

destructor TTestFrm.destroy;
begin
  inherited;
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

procedure TTestFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, c: integer;
  t: ctag;
begin
  inherited;
  t := LoadTagIni(a_pIni, str, 'Tag');
  //LoadExTagIni(a_pIni, m_tag, str, 'Tag');
end;

procedure TTestFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
begin
  inherited;
  //saveTagToIni(a_pIni, m_tag, str, 'Tag');
end;


procedure TTestFrm.UpdateData;
begin

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
  addplgevent('cTagInfoFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cTagInfoFactory_doChangeRState', c_RC_DoChangeRCState,
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
  //result := TForm3.create(nil);
end;

function ITagInfoFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function ITagInfoFrm.doRepaint: boolean;
begin
  //TForm3(m_pMasterWnd).UpdateData;
end;

end.
