unit uProcNotify;

interface

uses
  Windows,
  recorder,
  tags,
  plugin,
  ActiveX,
  SysUtils,
  Forms,
  uFrmSync,
  journal,
  SyncObjs,
  Classes,
  ExtCtrls,
  blaccess,
  ulogfile,
  uEventList,
  uRecorderEvents,
  dialogs,
  variants,
  uRCFunc,
  uRecBasicFactory,
  cfreg;

type

  cNotifyProcessorList = class;

  cNonifyProcessor = class
  protected
    // ссылка на cNotifyProcessorList
    list: cNotifyProcessorList;
    fname: string;
  protected
    procedure setName(s: string);
    // событие происходит при присвоении cNotifyProcessorList
    procedure doAddParentList; virtual;
    procedure doSave(path: string); virtual;
    procedure doLoad(path: string); virtual;
    procedure doLeaveCfg; virtual;
    // когда все плагины уже загружены и конфиг тоже
    procedure doRCInit; virtual;
  public
    function ProcessNotify(a_dwCommand: dword; a_dwData: dword): boolean;
      virtual;
    // function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;virtual;
    function ProcessBtnClick(pMsgInfo: PCB_MESSAGE): boolean; virtual;
    property name: string read fname write setName;
  end;

  cNotifyProcessorList = class(TStringList)
  public
    function GetNP(i: integer): cNonifyProcessor; overload;
    function GetNP(str: string): cNonifyProcessor; overload;
    Procedure AddNP(np: cNonifyProcessor);
    procedure DelNP(i: integer); overload;
    procedure DelNP(str: string); overload;
    procedure CallAllProcessNotify(a_dwCommand: dword; a_dwData: dword);
    destructor destroy;
    constructor Create;
  end;

implementation
uses
  PluginClass;


procedure cNonifyProcessor.setName(s: string);
var
  i: integer;
begin
  if list <> nil then
  begin
    if list.Find(fname, i) then
    begin
      list.Delete(i);
    end;
    list.AddObject(s, self);
  end;
  fname := s;
end;

procedure cNonifyProcessor.doAddParentList;
begin

end;

procedure cNonifyProcessor.doLeaveCfg;
begin

end;

procedure cNonifyProcessor.doLoad(path: string);
begin

end;

procedure cNonifyProcessor.doRCInit;
begin

end;

procedure cNonifyProcessor.doSave(path: string);
begin

end;

function cNonifyProcessor.ProcessBtnClick(pMsgInfo: PCB_MESSAGE): boolean;
begin

end;

function cNonifyProcessor.ProcessNotify(a_dwCommand: dword;
  a_dwData: dword): boolean;
var
  pMsgInfo: PCB_MESSAGE;
  path: string;
  b:boolean;
begin
  case a_dwCommand of
    PN_SHOWINFO:
    begin
      pMsgInfo := pointer(a_dwData);
    end;
    PN_LEAVERCCONFIG:
    begin
      if TExtRecorderPack(G_Plg).m_loadState then
      begin

      end
      else
        doLeaveCfg;
    end;
    PN_RCLOADCONFIG:
    begin
      path := getRConfig;
      doLoad(path);
    end;
    PN_RCINITIALIZED:
      begin
        doRCInit;
      end;
    PN_RCSAVECONFIG:
      begin
        path := getRConfig;
        doSave(path);
      end;
    PN_CUSTOM_BUTTON_CLICK:
      begin
        if a_dwData = 0 then
        begin

        end
        else
        begin
          pMsgInfo := pointer(a_dwData);
          ProcessBtnClick(pMsgInfo);
        end;
      end;
  end;
end;

function cNotifyProcessorList.GetNP(i: integer): cNonifyProcessor;
begin
  result := NIL;
  if i < count then
    result := cNonifyProcessor(objects[i]);
end;

function cNotifyProcessorList.GetNP(str: string): cNonifyProcessor;
var
  i: integer;
begin
  result := nil;
  if Find(str, i) then
    result := cNonifyProcessor(objects[i]);
end;

procedure cNotifyProcessorList.CallAllProcessNotify(a_dwCommand: dword;
  a_dwData: dword);
var
  i: integer;
  np: cNonifyProcessor;
  b, b1:boolean;
begin
  b:=false;
  b1:=(a_dwCommand=PN_RCLOADCONFIG);
  if b1 then
  begin
    TExtRecorderPack(G_Plg).m_loadState:=true;
    ecm(b);
  end;
  for i := 0 to count - 1 do
  begin
    np := GetNP(i);
    np.ProcessNotify(a_dwCommand, a_dwData);
  end;
  if b1 then
  begin
    TExtRecorderPack(G_Plg).m_loadState:=false;
    if b then
      lcm;
  end;
end;

Procedure cNotifyProcessorList.AddNP(np: cNonifyProcessor);
begin
  np.list := self;
  if np.name = '' then
  begin
    np.name := np.ClassName;
  end;
  AddObject(np.name, np);
  np.doAddParentList;
end;

procedure cNotifyProcessorList.DelNP(i: integer);
var
  np: cNonifyProcessor;
begin
  np := cNonifyProcessor(objects[i]);
  np.destroy;
  Delete(i);
end;

procedure cNotifyProcessorList.DelNP(str: string);
var
  i: integer;
begin
  if Find(str, i) then
    DelNP(i);
end;

destructor cNotifyProcessorList.destroy;
var
  np: cNonifyProcessor;
  i: integer;
begin
  for i := 0 to count - 1 do
  begin
    np := cNonifyProcessor(objects[i]);
    np.destroy;
  end;
  clear;
  inherited;
end;

constructor cNotifyProcessorList.Create;
begin
  sorted := true;
  inherited;
end;

end.
