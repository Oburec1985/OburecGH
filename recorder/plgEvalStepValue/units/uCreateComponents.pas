unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  uEvalStepCfgFrm,
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, uPluginClass, tags, Recorder, uRCFunc,
  uEvalStepAlg, uCommonMath, nativeXml, ulogfile,
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

var
  g_cfgpath:string;

const
  // ���������� ���������� ��� ������� �������� plug-in`�.
  GPluginInfo: TInternalPluginInfo = (
    Name: 'EvalStepAlg';
    Dsc: '������ ������� �������� �� ���������� ��������';
    Vendor: '��� ����';
    Version: 1;
    SubVertion:0;);

  procedure createComponents();
  procedure doLoad(path: string);
  procedure doSave(path: string);
  procedure doRCInit(Loaded:boolean);

  procedure destroyEngine;
  procedure createFormsRecorderUIThread();
  procedure destroyFormsRecorderUIThread();
  // MainThead. ����� ��������� ����� ��� ��������� ������� � ������ �����
  procedure createForms();
  // MainThead
  procedure destroyForms();
  procedure RecorderInit;


implementation

procedure RecorderInit;
begin
  //if ThresholdFrm<>nil then
  //  ThresholdFrm.AttachAlarms;
end;

procedure destroyEngine;
begin
 g_AlgList.destroy;
 if true then exit;
end;


procedure createForms();
begin
  // �������� � MainThread
  if GetCurrentThreadId = MainThreadID then
  begin

  end;
end;

procedure destroyForms();
begin
  exit;
  if GetCurrentThreadId = MainThreadID then
  begin
    if EvalStepCfgFrm<>nil then
    begin
      EvalStepCfgFrm.destroy;
      EvalStepCfgFrm:=nil;
    end;
    g_AlgList.Destroy;
  end;
end;


procedure createComponents();
var
  str, str1, cfg, dir, fname:string;
  m_toolBarIcon:IPicture;
  i, m_btnID:cardinal;
begin
  g_AlgList:=cAlgList.Create;

  cfg := extractfiledir(getRConfig);
  i := 0;
  if DirectoryExists(cfg) then
  begin
    //dir := cfg + '\logs\';
    //if not DirectoryExists(dir) then
    //begin
    //  ForceDirectories(dir);
    //end;
    //fname := dir + 'ControlCyclogramLog_' + inttostr(i) + '.log';
    //while FileExists(fname) do
    //begin
    //  inc(i);
    //  fname := dir + 'ControlCyclogramLog_' + inttostr(i) + '.log';
    //end;
    //g_logFile := cLogFile.Create(fname, ';');
    //g_logFile.m_Rewrite := false;
  end;
end;

procedure createFormsRecorderUIThread();
var
  h: thandle;
  str, str1:string;
  show:boolean;
begin
  if EvalStepCfgFrm=nil then
  begin
    EvalStepCfgFrm:=TEvalStepCfgFrm.Create(nil);
    EvalStepCfgFrm.show;
    EvalStepCfgFrm.close;
  end;

end;

procedure destroyFormsRecorderUIThread();
begin
  if true then exit;
  
  if EvalStepCfgFrm<>nil then
  begin
    EvalStepCfgFrm.free;
    EvalStepCfgFrm := nil;
  end;
end;

procedure doLoad(path: string);
var
  doc:TNativeXml;
  node:txmlnode;
  b:boolean;
begin
  g_cfgpath:=path;
  ecm(b);
  g_algList.doLoad(nil);
  if b then
    lcm;
end;

procedure doSave(path: string);
var
  dir, name:string;
begin
  g_cfgpath:=path;
  dir:=extractfiledir(path);
  name:=trimext(extractfilename(path));
  g_algList.doSave(nil);
end;


procedure doRCInit(Loaded:boolean);
var
  i:integer;
  a:cEvalStepAlg;
  b:boolean;
begin
  if not Loaded then
  begin
    g_cfgpath:=getRConfig;
    doLoad(g_cfgpath);
  end;
  for i:=0 to g_AlgList.Count-1 do
  begin
    a:=g_AlgList.getobj(i);
    a.m_tag.tagname:=a.m_tag.tagname;
    a.m_outTag.tagname:=a.m_outTag.tagname;

    ecm(b);
    a.m_outTag.tag.SetFreq(a.m_tag.freq);
    a.UpdateFFTSize;
    if b then
      lcm;
  end;
end;


end.
