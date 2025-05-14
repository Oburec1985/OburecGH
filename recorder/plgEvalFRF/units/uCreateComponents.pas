unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc,
  uCommonMath, nativeXml, uEditEvalFRFFrm, uEvalFRFFrm,
  Generics.Collections, Controls, uRecBasicFactory;

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
  GPlgDSC: array [0..255] of ansichar;
const
  // ���������� ���������� ��� ������� �������� plug-in`�.
  GPluginInfo: TInternalPluginInfo = (
    Name: 'FrfPlg';
    Dsc: '����� ����������� ������';
    Vendor: '��� ����';
    Version: 1;
    SubVertion:0;);



  procedure createComponents(compMng:cCompMng);
  procedure destroyEngine;
  procedure createFormsRecorderUIThread(compMng: cCompMng);
  procedure destroyFormsRecorderUIThread(compMng: cCompMng);
  // MainThead. ����� ��������� ����� ��� ��������� ������� � ������ �����
  procedure createForms;
  // MainThead
  procedure destroyForms();
  procedure RecorderInit;

implementation

procedure destroyEngine;
begin
 if true then exit;
 // ������� � ������ �������
 {$IfDef DEBUG}
 {$EndIf}
end;


procedure createForms;
begin
  // �������� � MainThread
  if GetCurrentThreadId = MainThreadID then
  begin
    // �������� ����� ����� ������ ������ SHOWMODAL � UITHREAD
    // ���������� ���� ����������, �.�. �������� ����� � �������� ������� ������ �������
    // ���� ����� ������ ��� �������� �� � ��� �� ������ ��� ������� �� ����� ���������� ��������� �����
    EditFRFFrm:=TEditFRFFrm.Create(nil);
  end;
end;

procedure destroyForms();
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
  g_FrfFactory:=cFRFFactory.create;
  CompMng.Add(g_FrfFactory);
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
