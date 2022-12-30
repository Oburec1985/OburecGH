unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  uEvalStepCfgFrm,
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc,
  uEvalStepAlg, uCommonMath, nativeXml,
  Generics.Collections, Controls;

type
  {��� ��� �������� ���������� � plug-in`�}
  {���� ��� ������� ������������ � Delphi, ��� PLUGININFO}
  TInternalPluginInfo = record
    Name: AnsiString; // ������������
    Dsc: AnsiString; // ��������
    Vendor: AnsiString; // �������� ������������
    Version: integer; // ������
    SubVertion: integer; // ���-������
  end;

  // ���������� ��������� �� Recorder � ���� TMBaseControl
  cEvalStepValNP = class(cNonifyProcessor)
  public
    m_toolBarIcon:IPicture;
    m_btnID:cardinal;
    // ����������
    m_toolBarIcon2:IPicture;
    m_btnID2:cardinal;
  protected
    procedure doAddParentList;override;
    procedure doSave(path: string);override;
    procedure doLoad(path: string);override;
  public
    function ProcessBtnClick(pMsgInfo:PCB_MESSAGE): boolean;override;
  end;

var
  g_EvalStepValNP:cEvalStepValNP;
  g_cfgpath:string;

const
  // ���������� ���������� ��� ������� �������� plug-in`�.
  GPluginInfo: TInternalPluginInfo = (
    Name: '';
    Dsc: '������ ������� �������� �� ���������� ��������';
    Vendor: '��� ����';
    Version: 1;
    SubVertion:0;);

  procedure createComponents(compMng:cCompMng);
  procedure destroyEngine;
  procedure createFormsRecorderUIThread(compMng: cCompMng);
  procedure destroyFormsRecorderUIThread(compMng: cCompMng);
  // MainThead. ����� ��������� ����� ��� ��������� ������� � ������ �����
  procedure createForms(compMng: cCompMng);
  // MainThead
  procedure destroyForms(compMng: cCompMng);



implementation

procedure destroyEngine;
begin
 if true then exit;
 // ������� � ������ �������
 {$IfDef DEBUG}
 {$EndIf}
end;


procedure createForms(compMng: cCompMng);
begin
  // �������� � MainThread
  if GetCurrentThreadId = MainThreadID then
  begin
    // �������� ����� ����� ������ ������ SHOWMODAL � UITHREAD
    // ���������� ���� ����������, �.�. �������� ����� � �������� ������� ������ �������
    // ���� ����� ������ ��� �������� �� � ��� �� ������ ��� ������� �� ����� ���������� ��������� �����
    EvalStepCfgFrm:=TEvalStepCfgFrm.Create(nil);
    EvalStepCfgFrm.Show;
    EvalStepCfgFrm.close;

    g_EvalStepValNP:=cEvalStepValNP.Create;
    TExtRecorderPack(GPluginInstance).m_nplist.AddNP(g_EvalStepValNP);

    g_AlgList:=cAlgList.Create;
  end;
end;

procedure destroyForms(compMng: cCompMng);
begin
  exit;
  if GetCurrentThreadId = MainThreadID then
  begin
    if EvalStepCfgFrm<>nil then
    begin
      EvalStepCfgFrm.destroy;
      EvalStepCfgFrm:=nil;
    end;
    g_EvalStepValNP.Destroy;
    g_AlgList.Destroy;
  end;
end;


procedure createComponents(compMng:cCompMng);
var
  str, str1:string;
  m_toolBarIcon:IPicture;
  m_btnID:cardinal;
begin
  //CompMng.Add(cGLFact.Create);
end;

procedure createFormsRecorderUIThread(compMng: cCompMng);
var
  h: thandle;
  str, str1:string;
  show:boolean;
begin
  EvalStepCfgFrm:=TEvalStepCfgFrm.Create(nil);
  EvalStepCfgFrm.show;
  EvalStepCfgFrm.close;
end;

procedure destroyFormsRecorderUIThread(compMng: cCompMng);
begin
  if EvalStepCfgFrm<>nil then
  begin
    EvalStepCfgFrm.free;
    EvalStepCfgFrm := nil;
  end;
end;

{ cMBaseAlgNP }
procedure cEvalStepValNP.doAddParentList;
var
  str, str1:string;
begin
  inherited;
  // ��������� ������ � ��������� ����������
  str  := '��������� ������';
  str1 := '��������� ������';
  m_toolBarIcon:= LoadPicFromRes('FX48');
  cCompMng(TExtRecorderPack(GPluginInstance).m_CompMng).m_BtnTagPropPage.AddButton(m_toolBarIcon,
                                m_toolBarIcon, m_toolBarIcon,
                                m_toolBarIcon,
                                pAnsiChar(@str1[1]), @str[1], GPluginInstance, m_btnID);
end;


procedure cEvalStepValNP.doLoad(path: string);
var
  doc:TNativeXml;
  node:txmlnode;
begin
  g_cfgpath:=path;
  ecm;
  g_algList.doLoad(nil);
  lcm;
end;

procedure cEvalStepValNP.doSave(path: string);
var
  dir, name:string;
begin
  g_cfgpath:=path;
  dir:=extractfiledir(path);
  name:=trimext(extractfilename(path));
  g_algList.doSave(nil);
end;

function cEvalStepValNP.ProcessBtnClick(pMsgInfo: PCB_MESSAGE): boolean;
begin
  if pMsgInfo.uID=m_btnID then
  begin
    EvalStepCfgFrm.Show;   // ���������� ����� ��������
  end;
end;

end.
