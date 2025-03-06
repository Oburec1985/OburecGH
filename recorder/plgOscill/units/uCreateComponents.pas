unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc,
  uCommonMath, nativeXml,
  Generics.Collections, Controls, uRecBasicFactory,
  uEditGraphFrm,
  uGrapfForm;

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

var
  g_cfgpath:string;

const
  // ���������� ���������� ��� ������� �������� plug-in`�.
  GPluginInfo: TInternalPluginInfo = (
    Name: 'TestPlg';
    Dsc: '������ ������';
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
  procedure RecorderInit;

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
    EditGraphFrm:=TEditGraphFrm.Create(nil);
  end;
end;

procedure destroyForms(compMng: cCompMng);
begin
  if GetCurrentThreadId = MainThreadID then
  begin

  end;
end;


procedure createComponents(compMng:cCompMng);
var
  str, str1:string;
  m_toolBarIcon:IPicture;
  m_btnID:cardinal;
begin
  g_GraphFrmFactory:=cGraphFrmFactory.create;
  CompMng.Add(g_GraphFrmFactory);
end;

procedure createFormsRecorderUIThread(compMng: cCompMng);
var
  h: thandle;
  str, str1:string;
  show:boolean;
begin
  begin
  end;
end;

procedure destroyFormsRecorderUIThread(compMng: cCompMng);
begin
  begin
  end;
end;

procedure RecorderInit;
begin
  //if ThresholdFrm<>nil then
  //  ThresholdFrm.AttachAlarms;
end;

end.
