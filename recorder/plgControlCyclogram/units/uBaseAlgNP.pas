unit uBaseAlgNP;

interface
uses
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc, uAlgFrm, uAlgAddFrm,uBaseAlg,
  Generics.Collections, Controls, uControlObj, uCommonMath, uControlCyclogramEditFrm, uMBaseControl;

type

  // трансл€тор сообщений из Recorder в базу TMBaseControl
  cMBaseAlgNP = class(cNonifyProcessor)
  public
    m_toolBarIcon:IPicture;
    m_btnID:cardinal;
  protected
    procedure doAddParentList;override;
    procedure doSave(path: string);override;
    procedure doLoad(path: string);override;
  public
    function ProcessBtnClick(pMsgInfo:PCB_MESSAGE): boolean;override;
  end;


implementation

{ cMBaseNP }

procedure cMBaseAlgNP.doAddParentList;
var
  str, str1:string;
begin
  inherited;
  g_algMng:=cAlgMng.create;
  // добавл€ем кнопку в редакторе формул€ров
  str  := '–асчетные каналы';
  str1 := '–асчетные каналы';
  m_toolBarIcon:= LoadPicFromRes('FX48');
  TExtRecorderPack(GPluginInstance).m_CompMng.m_BtnTagPropPage.AddButton(m_toolBarIcon,
                                m_toolBarIcon,
                                m_toolBarIcon,
                                m_toolBarIcon,
                                pAnsiChar(@str1[1]), @str[1], GPluginInstance, m_btnID);
end;

procedure cMBaseAlgNP.doLoad(path: string);
var
  dir, name, newpath:string;
begin
  inherited;
  dir:=extractfiledir(path);
  name:=trimext(extractfilename(path));
  newpath:=dir+'\'+name+'.xml';
  if fileexists(newpath) then
  begin
    //'C:\Mera Files\Recorder\configs\Controls_02\cfg.xml'
    if g_algMng<>nil then
    begin
      if not RStateConfig then
        ecm;
      g_algMng.LoadFromXML(newpath, 'Algorithm');
      lcm;
    end;
  end;
end;

procedure cMBaseAlgNP.doSave(path: string);
var
  dir, name:string;
begin
  inherited;
  dir:=extractfiledir(path);
  name:=trimext(extractfilename(path));
  g_algMng.AddToXML(dir+'\'+name+'.xml','Algorithm');
end;

function cMBaseAlgNP.ProcessBtnClick(pMsgInfo: PCB_MESSAGE): boolean;
begin
  if pMsgInfo.uID=m_btnID then
  begin
    AlgFrm.Show;   // показываем форму настроек
  end;
end;

end.
