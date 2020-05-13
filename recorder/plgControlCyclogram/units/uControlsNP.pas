unit uControlsNP;

interface

uses
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc,
  Generics.Collections, Controls, uControlObj, uCommonMath, uControlCyclogramEditFrm, uMBaseControl;

type

  cControlsNP = class(cNonifyProcessor)
  protected

  protected
    procedure doSave(path: string);override;
    procedure doLoad(path: string);override;
  public
    constructor create;
    destructor destroy;override;
    function ProcessBtnClick(pMsgInfo:PCB_MESSAGE): boolean;override;
  end;
  // транслятор сообщений из Recorder в базу TMBaseControl
  cMBaseNP = class(cNonifyProcessor)
  protected
    m_base:TMBaseControl;
  public
    procedure init(p_base:TMBaseControl);
    function ProcessNotify(a_dwCommand: dword; a_dwData: dword): boolean;override;
  end;


  procedure createNP;

implementation

procedure createNP;
var
  np:cControlsNP;
  base_np:cMBaseNP;
begin
  np:=cControlsNP.create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(np);
  if TExtRecorderPack(GPluginInstance).m_loadDefCfg then
  begin
    np.doLoad(getconfigname);
  end;

  base_np:=cMBaseNP.create;
  base_np.name:='MBaseControlNP';
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(base_np);
end;

procedure cControlsNP.doLoad(path: string);
var
  dir, name, newpath:string;
begin
  inherited;
  if not RStateConfig then
    ecm;
  if RStateConfig then
  begin
    dir:=extractfiledir(path);
    name:=trimext(extractfilename(path));
    newpath:=dir+'\'+name+'.xml';
    if fileexists(newpath) then
    begin
      g_conmng.LoadFromXML(newpath, 'ControlCyclogram');
      //if fileexists(newpath) then
      //begin
      //  if ControlCyclogramEditFrm<>nil then
      //  begin
      //    ControlCyclogramEditFrm.load(newpath);
      //  end;
      //end;
    end;
    lcm;
  end;
end;

procedure cControlsNP.doSave(path: string);
var
  dir, name:string;
begin
  inherited;
  dir:=extractfiledir(path);
  name:=trimext(extractfilename(path));
  g_conmng.SaveToXML(dir+'\'+name+'.xml','ControlCyclogram');
end;


constructor cControlsNP.create;
begin

end;


destructor cControlsNP.destroy;
begin
  //WriteUserProperties(ini_path); // записываем кастомные свойства тегов в файл

  // освобождаем память
  //SettingsFrm.destroy;
  //SettingsFrm := nil;

  inherited;
end;

//-- обрабатываем нажатие на кнопку --------------------------------------------
function cControlsNP.ProcessBtnClick(pMsgInfo:PCB_MESSAGE): boolean;
begin
  //
end;

{ cMBaseNP }

procedure cMBaseNP.init(p_base: TMBaseControl);
begin
  m_base:=p_base;
end;

function cMBaseNP.ProcessNotify(a_dwCommand, a_dwData: dword): boolean;
begin
  if a_dwCommand=v_NotifyMBaseSetProperties then
  begin
    if m_base<>nil then
      m_base.DoGetNotify(a_dwData)
    else
    begin
      init(MBaseControl);
      m_base.DoGetNotify(a_dwData);
    end;
  end;
end;

end.
