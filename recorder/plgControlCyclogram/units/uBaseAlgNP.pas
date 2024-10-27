unit uBaseAlgNP;

interface
uses
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc, uAlgFrm, uAlgAddFrm,uBaseAlg,
  Generics.Collections, Controls, uControlObj,
  uCommonMath,
  uAlgsSaveFrm,
  uControlCyclogramEditFrm,
  shellApi, ubaseobj,
  uSyncOscillogram,
  uMBaseControl;

type

  // транслятор сообщений из Recorder в базу TMBaseControl
  cMBaseAlgNP = class(cNonifyProcessor)
  public
    m_toolBarIcon:IPicture;
    m_btnID:cardinal;
    // сохранялка
    m_toolBarIcon2:IPicture;
    m_btnID2:cardinal;

  protected
    procedure doAddParentList;override;
    procedure doSave(path: string);override;
    procedure doLoad(path: string);override;
    procedure doRCInit;override;
  public
    function ProcessBtnClick(pMsgInfo:PCB_MESSAGE): boolean;override;
  end;


implementation

{ cMBaseNP }
uses
  uControlWarnFrm;

procedure cMBaseAlgNP.doAddParentList;
var
  str, str1:string;
begin
  inherited;
  g_algMng:=cAlgMng.create;
  // добавляем кнопку в редакторе формуляров
  str  := 'Расчетные каналы';
  str1 := 'Расчетные каналы';
  m_toolBarIcon:= LoadPicFromRes('FX48');
  cCompMng(TExtRecorderPack(GPluginInstance).m_CompMng).m_BtnTagPropPage.AddButton(m_toolBarIcon,
                                m_toolBarIcon, m_toolBarIcon,
                                m_toolBarIcon,
                                pAnsiChar(@str1[1]), @str[1], GPluginInstance, m_btnID);
  // добавляем кнопку
  str  := 'Сохранить обработку';
  str1 := 'Сохранить обработку';
  m_toolBarIcon2:= LoadPicFromRes('SAVE');
  cCompMng(TExtRecorderPack(GPluginInstance).m_CompMng).m_BtnMainFrame.AddButton(m_toolBarIcon2,
                                m_toolBarIcon2,
                                m_toolBarIcon2,
                                m_toolBarIcon2,
                                pAnsiChar(@str1[1]), @str[1], GPluginInstance, m_btnID2);
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
    if g_algMng<>nil then
    begin
      if not RStateConfig then
        ecm;
      g_algMng.LoadFromXML(newpath, 'Algorithm');
      lcm;
    end;
  end;
end;

procedure cMBaseAlgNP.doRCInit;
var
  I: Integer;
  A:cbaseobj;
begin
  for I := 0 to g_algMng.Count - 1 do
  begin
    a:=g_algMng.getobj(i);
    if a is cbasealgcontainer then
      cbasealgcontainer(a).linkTags;
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
var
  dir:string;
begin
  if pMsgInfo.uID=m_btnID then
  begin
    AlgFrm.Show;   // показываем форму настроек
  end;
  if pMsgInfo.uID=m_btnID2 then
  begin
    if g_OscFactory<>nil then
    begin
      //dir:=extractfiledi(g_merafile);
      g_merafile:=GetMeraFile;
      g_OscFactory.SaveMera(g_merafile);
    end;
    if fileexists(g_Path) then
      ShellExecute(0,nil,pwidechar(g_Path),nil,nil, SW_HIDE);
  end;
end;

end.
