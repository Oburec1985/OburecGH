unit Unit3;

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
  TGenSignalsFrm = class(TRecFrm)
  private
    fcapacity: integer;
    fcount: integer;
  public
    m_tag: ctag;
    lastval: integer;
  private
  protected
    procedure RBtnClick(Sender: TObject);
    procedure UpdateData;

  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IGenSignalsFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cGenSignalsFactory = class(cRecBasicFactory)
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
  IID_GENSIGNALS: TGuid = (D1: $027E3774; D2: $0414; D3: $4582;
    D4: ($A9, $16, $DB, $63, $60, $96, $43, $66));

  c_Pic = 'GENSIGNALS';
  c_Name = 'Генератор сигналов';
  c_defXSize = 370;
  c_defYSize = 90;

var
  g_GenSignalsFactory: cGenSignalsFactory;
  GenSignalsFrm: TGenSignalsFrm;


implementation

{$R *.dfm}

{ cGenSignalsFactory }

constructor cGenSignalsFactory.create;
begin

end;

procedure cGenSignalsFactory.CreateEvents;
begin

end;

destructor cGenSignalsFactory.destroy;
begin

  inherited;
end;

procedure cGenSignalsFactory.DestroyEvents;
begin

end;

procedure cGenSignalsFactory.doChangeRState(Sender: TObject);
begin

end;

function cGenSignalsFactory.doCreateForm: cRecBasicIFrm;
begin

end;

procedure cGenSignalsFactory.doSetDefSize(var pSize: SIZE);
begin
  inherited;

end;

procedure cGenSignalsFactory.doStart;
begin

end;

procedure cGenSignalsFactory.doUpdateData(Sender: TObject);
begin

end;

end.
