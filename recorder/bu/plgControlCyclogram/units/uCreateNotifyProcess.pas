unit uCreateNotifyProcess;
// ����� ������������� ������������ ��������� �����������

interface

uses
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder,
  Generics.Collections, Controls, uControlsNP, uBaseAlgNP;


  procedure createNP;

implementation

procedure createNP;
var
  np:cNonifyProcessor;
begin
  np:=cMBaseAlgNP.create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(np);
end;


end.
