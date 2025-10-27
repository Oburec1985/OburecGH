unit u3120Factory;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath,
  uComponentServises,
  Forms, ComCtrls,
  uRecBasicFactory,
  uCommonMath, MathFunction, u2DMath,
  uRecorderEvents,
  uChart,
  inifiles,
  tags,
  uCommonTypes,
  pluginClass,
  shellapi,
  uPathMng,
  uControlObj,
  math;

type
  I3120Frm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  c3120Factory = class(cRecBasicFactory)
  public
    // merafile
    m_MeraFile: string;
    m_ShockFile: string;
  private
    m_counter: integer;
  protected
    procedure dosave(sender:tobject);
    procedure doload(sender:tobject);
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
    // когда Recorder загрузил конфиги;
    procedure doRecorderInit; override;
  public
    procedure doAfterLoad; override;
    procedure doUpdateData; override;
    procedure doChangeRState(sender: tobject);
    procedure doStart;
    procedure doStop;
  public
    procedure incFrmCounter;
    constructor create;
    destructor destroy; override;
    // создаем метки
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

var
  g_3120Factory: c3120Factory;

const
  c_Pic = 'PIC3120';
  c_Name = 'Испытания трансмиссии';
  c_defXSize = 400;
  c_defYSize = 400;

  // ctrl+shift+G
  // ['{54C462CD-E137-4BA6-9FB5-EFD92D159DE7}']
  IID_3120: TGuid = (D1: $64C462CD; D2: $E137; D3: $4BA6;
    D4: ($9F, $B5, $EF, $D9, $2D, $15, $9D, $E7)) ;

implementation
uses
  u3120ControlObj, u3120Frm;

{ c3120Factory }

procedure c3120Factory.incFrmCounter;
begin
  inc(m_counter);
end;


constructor c3120Factory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_3120;

  g_conmng:=cControlMng.create;
  createevents;
end;

procedure c3120Factory.dosave(sender: tobject);
var
  path, name, dir:string;
begin
  path:=getRConfig;
  dir:=extractfiledir(path);
  name:=trimext(extractfilename(path));
  g_conmng.SaveToXML(dir+'\'+name+'_3120'+'.xml','3120Cyclogram');
end;

procedure c3120Factory.doload(sender: tobject);
var
  dir, name, path:string;
  b:boolean;
  I, mnum: Integer;
  c:cControlObj;
begin
  inherited;
  /// перенес загрузку в инициализацию
  path:=getRConfig;
  if not RStateConfig then
    ecm(b);
  if RStateConfig then
  begin
    dir:=extractfiledir(path);
    name:=trimext(extractfilename(path));
    name:=dir+'\'+name+'_3120'+'.xml';
    if fileexists(name) then
    begin
      g_conmng.LoadFromXML(name, '3120Cyclogram');
    end;
    if b then
      lcm;
  end;
  mnum:=0;
  for I := 0 to g_conmng.ControlsCount - 1 do
  begin
    c:=g_conmng.getControlObj(i);
    if c is cmncontrol then
    begin
      g_Marray[mnum]:=cmncontrol(c);
      inc(mnum);
    end;
  end;
end;

procedure c3120Factory.createevents;
begin
  // addplgevent('cSRSFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('c3120Factory_doChangeRState', c_RC_DoChangeRCState,    doChangeRState);
  addplgevent('c3120Factory_Save', c_RC_SaveCfg,    dosave);
  addplgevent('c3120Factory_Load', c_RC_LoadCfg,    doload);
end;

destructor c3120Factory.destroy;
begin
  g_conmng.destroy;
  destroyevents;
  inherited;
end;

procedure c3120Factory.destroyevents;
begin

end;

procedure c3120Factory.doAfterLoad;
begin
  inherited;

end;

procedure c3120Factory.doChangeRState(sender: tobject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
        doStop;
      end;
    RSt_StopToView:
      begin
        //g_3120Factory.m_MeraFile := GetMeraFile;
        doStart;
      end;
    RSt_StopToRec:
      begin
        //g_3120Factory.m_MeraFile := GetMeraFile;
        doStart;
      end;
    RSt_ViewToStop:
      begin
        doStop;
      end;
    RSt_ViewToRec:
      begin
        //g_3120Factory.m_MeraFile := GetMeraFile;
      end;
    RSt_initToRec:
      begin
        //g_3120Factory.m_MeraFile := GetMeraFile;
        doStart;
      end;
    RSt_initToView:
      begin
        //g_FrfFactory.m_MeraFile := GetMeraFile;
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

function c3120Factory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := I3120Frm.create();
  end;
end;

procedure c3120Factory.doDestroyForms;
begin
  inherited;

end;



procedure c3120Factory.doRecorderInit;
var
  i, j: integer;
  Frm: TRecFrm;
begin
  // exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
  end;
end;

procedure c3120Factory.doSetDefSize(var PSize: SIZE);
begin
  inherited;

end;

procedure c3120Factory.doStart;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TFrm3120(Frm).doStart;
  end;
end;

procedure c3120Factory.doStop;
var
  path: string;
  i: integer;
  f: TRecFrm;
begin
  for i := 0 to Count - 1 do
  begin
    f := TRecFrm(GetFrm(i));
  end;
end;

procedure c3120Factory.doUpdateData;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TRecFrm(Frm).updatedata;
  end;
end;

{ I3120Frm }

procedure I3120Frm.doClose;
begin
  m_lRefCount := 1;
end;

function I3120Frm.doCreateFrm: TRecFrm;
begin
  result := TFrm3120.create(nil);
end;

function I3120Frm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function I3120Frm.doRepaint: boolean;
begin
  inherited;
  TFrm3120(m_pMasterWnd).UpdateView;
end;

end.
