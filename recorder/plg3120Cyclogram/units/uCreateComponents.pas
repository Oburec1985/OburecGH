unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc,
  uCommonMath, nativeXml,
  Generics.Collections, Controls, uRecBasicFactory,
  u3120frm, uTransmisNumFrm,
  u3120Factory;

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
    Name: '3120Cyclogram';
    Dsc: '��������� ����������� (p3120)';
    Vendor: '��� ����';
    Version: 1;
    SubVertion:0;);

  procedure createComponents(compMng:cCompMng);
  procedure destroyEngine;
  procedure createFormsRecorderUIThread(compMng: cCompMng);
  procedure destroyFormsRecorderUIThread(compMng: cCompMng);
  // MainThead. ����� ��������� ����� ��� ��������� ������� � ������ �����
  procedure createForms();
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


procedure createForms();
begin
  // �������� � MainThread
  if GetCurrentThreadId = MainThreadID then
  begin
    // �������� ����� ����� ������ ������ SHOWMODAL � UITHREAD
    // ���������� ���� ����������, �.�. �������� ����� � �������� ������� ������ �������
    // ���� ����� ������ ��� �������� �� � ��� �� ������ ��� ������� �� ����� ���������� ��������� �����
    //frm3120:=Tfrm3120.Create(nil);
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
  g_3120Factory:=c3120Factory.create;
  CompMng.Add(g_3120Factory);
end;

procedure createFormsRecorderUIThread(compMng: cCompMng);
var
  h: thandle;
  str, str1:string;
  show:boolean;
begin
  TransNumFrm:=TTransNumFrm.Create(nil);
  TransNumFrm.show;
  begin
  end;
end;

procedure destroyFormsRecorderUIThread(compMng: cCompMng);
begin
  TransNumFrm.Destroy;
  begin
  end;
end;

procedure RecorderInit;
begin
  //if ThresholdFrm<>nil then
  //  ThresholdFrm.AttachAlarms;
end;

end.
