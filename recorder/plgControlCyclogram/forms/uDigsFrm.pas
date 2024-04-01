unit uDigsFrm;

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
  uRcCtrls, Menus, Grids;

type
  TDigColumn = class(TNamedObj)
  public
    owner:TNamedObjList;
    fname:string;
    estimate:integer;
  protected
    procedure setname(s:string);
  public
    property name:string read fname write setname;
    destructor destroy;
  end;


  TGroup = class
  public
    owner:TNamedObjList;
    fname:string;
    m_tags: TNamedObjList;
  protected
    procedure setname(s:string);
  public
    property name:string read fname write setname;
    constructor create;
    destructor destroy;
  end;

  TDigsFrm = class(TRecFrm)
    SignalsSG: TStringGrid;
  private

  public
    fcolCount:integer;
    colNames:TNamedObjList;
    glist:TNamedObjList;
  protected
    procedure setColCount(c:integer);
  public
    property colCount:integer read fColCount Write setColCount;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IDigsFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cDigsFrmFactory = class(cRecBasicFactory)
  public

  private
    // число дочерних компонентов
    m_counter: integer;
  protected
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
  public
    procedure doAfterLoad; override;
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doChangeCfg(Sender: TObject);
    procedure doStart;
    procedure doStop;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

var
  g_DigsFrmFactory2: cDigsFrmFactory;

const
  c_Pic = 'PRESSFRM2';
  c_Name = 'Цифровой формуляр';
  c_defXSize = 560;
  c_defYSize = 355;

  // ctrl+shift+G
  // ['{54C462CD-F137-4BA6-9EB5-EFD92D159DE5}']
  IID_PRESS: TGuid = (D1: $54C462CD; D2: $F137; D3: $4BA6;
    D4: ($9E, $B5, $EF, $D9, $2D, $15, $9D, $E5));

var
  DigsFrm: TDigsFrm;

implementation

{$R *.dfm}
{ cDigsFrmFactory }

constructor cDigsFrmFactory.create;
begin
  inherited;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_PRESS;
  createevents;
end;

destructor cDigsFrmFactory.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cDigsFrmFactory.destroyevents;
begin
  RemovePlgEvent(doUpdateData, c_RUpdateData);
  RemovePlgEvent(doChangeCfg, c_RC_LeaveCfg);
  RemovePlgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cDigsFrmFactory.createevents;
begin
  addplgevent('DigsFrmFact_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('DigsFrmFact_doChangeRState', c_RC_DoChangeRCState,
    doChangeRState);
  addplgevent('DigsFrmFact_doChangeRState', c_RC_LeaveCfg, doChangeCfg);
end;

procedure cDigsFrmFactory.doAfterLoad;
begin
  inherited;

end;

procedure cDigsFrmFactory.doChangeCfg(Sender: TObject);
begin

end;

procedure cDigsFrmFactory.doChangeRState(Sender: TObject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
        doStop;
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
        doStop;
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
        doStop;
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

function cDigsFrmFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  result := IDigsFrm.create();
  inc(m_counter);
end;

procedure cDigsFrmFactory.doDestroyForms;
begin
  inherited;

end;

procedure cDigsFrmFactory.doSetDefSize(var PSize: SIZE);
begin
  inherited;
  PSize.cx := c_defXSize;
  PSize.cy := c_defYSize;
end;

procedure cDigsFrmFactory.doStart;
begin

end;

procedure cDigsFrmFactory.doStop;
begin

end;

procedure cDigsFrmFactory.doUpdateData(Sender: TObject);
begin

end;

{ IDigsFrm }

procedure IDigsFrm.doClose;
begin
  m_lRefCount := 1;
end;

function IDigsFrm.doCreateFrm: TRecFrm;
begin
  result := TDigsFrm.create(nil);
end;

function IDigsFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function IDigsFrm.doRepaint: boolean;
begin
  TDigsFrm(m_pMasterWnd).UpdateView;
end;

{ TGroup }

constructor TGroup.create;
begin
  m_tags := TNamedobjList.create;
end;

destructor TGroup.destroy;
var
  i:integer;
begin
  if owner<>nil then
  begin
    if owner.find(name,i) then
    begin
      owner.Delete(i);
    end;
  end;
  m_tags.destroy;
  inherited;
end;

procedure TGroup.setname(s: string);
var
  i:integer;
begin
  if owner<>nil then
  begin
    if owner.Find(fname, i) then
    begin
      owner.Delete(i);
      owner.AddObject(s, self);
    end;
  end;
end;

{ TDigsFrm }
constructor TDigsFrm.create;
begin
  inherited;
  glist:=TNamedobjList.Create;
end;

destructor TDigsFrm.destroy;
begin
  glist.Destroy;
  inherited;
end;

procedure TDigsFrm.setColCount(c: integer);
begin
  if c>colNames.Count then
  begin
    while c>colNames.Count do
    begin
      colNames.Add('c_'+inttostr(colNames.Count));
    end;
  end
  else
  begin
    if c<colNames.Count then
    begin

    end;
  end;
  fcolCount:=c;
  SignalsSG.ColCount:=c;
end;

{ TColumn }

destructor TDigColumn.destroy;
var
  i:integer;
begin
  if owner<>nil then
  begin
    if owner.find(name,i) then
    begin
      owner.Delete(i);
    end;
  end;
  inherited;
end;

procedure TDigColumn.setname(s: string);
var
  i:integer;
begin
  if owner<>nil then
  begin
    if owner.Find(fname, i) then
    begin
      owner.Delete(i);
      owner.AddObject(s, self);
    end;
  end;
end;


end.
