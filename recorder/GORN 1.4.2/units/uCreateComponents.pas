unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  Windows,
  SysUtils, Classes,
  cfreg,
  uMainFrm, uSettingsFrm, uSelectChannelFrm,
  uCompMng,
  PluginClass, uRCFunc,
  uCreateNotifyProcess;

type
  {��� ��� �������� ���������� � plug-in`�}
  {���� ��� ������� ������������ � Delphi, ��� PLUGININFO}
  TInternalPluginInfo = record
    Name: AnsiString;    // ������������
    Dsc: AnsiString;     // ��������
    Vendor: AnsiString;  // �������� ������������
    Version: integer;    // ������
    SubVertion: integer; // ���-������
    Year: integer;       // ��� �������
  end;

  procedure createComponents(compMng:cCompMng);
  // Thread ���� Recorder. ����� ���� ��������� ������� ��� ����������
   procedure createFormsRecorderUIThread(compMng:cCompMng);
   procedure destroyFormsRecorderUIThread(compMng:cCompMng);
  // MainThead. ����� ��������� ����� ��� ��������� ������� � ������ �����
  procedure createForms(compMng:cCompMng);
  // MainThead
  procedure destroyForms(compMng:cCompMng);
  function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;
  procedure destroyComponents(compMng:cCompMng);

const
  // ���������� ���������� ��� �������� �������� plug-in`�.
  GPluginInfo: TInternalPluginInfo = (
    Name:      '������ ����';
    Dsc:       '������ ���������� ������� ����';
    Vendor:    '��� ����';
    Version:   1;
    SubVertion:4;
    Year:      2023;);

var
  // ���� ��� ������� �������� frmSync ���� �� ������ ��� ����� � ������ ����� FrmSync
  g_delFrms : boolean;

implementation

procedure createFormsRecorderUIThread(compMng:cCompMng);
var
  np : cNonifyProcessor;
begin
  g_delFrms := false;
  //FullDebugModeScanMemoryPoolBeforeEveryOperation:=true;

  // GetCurrentThreadId;
  np := cTagPropNP.create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(np);

  SettingsFrm := TSettingsFrm.create(nil);
  SettingsFrm.show;
  SettingsFrm.close;
  SettingsFrm.m_ThID:=GetCurrentThreadId;
  SettingsFrm.m_MainThread:=MainThreadID;
  //SettingsFrm.HandleNeeded;

  SelectChannelFrm := TSelectChannelFrm.create(nil);
  SelectChannelFrm.HandleNeeded;
end;

procedure destroyFormsRecorderUIThread(compMng:cCompMng);
begin
  // �������� ���� � UIThread
  // �����!!! ������ ��������� ������� ����� ����� ����� ����������� ������ � UIThread
  // ���� ���������� � MainThread (�������� ������ ����� ��� �������� �������� ���������),
  // �� ����� ������ ��� �������� ����� Code Error 5 (� HandleAllocated �� �������!)

  TExtRecorderPack(GPluginInstance).EList.active := false;

  if SettingsFrm <> nil then
    begin
      SettingsFrm.free;
      SettingsFrm := nil;
    end;

  if SelectChannelFrm <> nil then
    begin
      SelectChannelFrm.free;
      SelectChannelFrm := nil;
    end;

  g_delFrms := true;
end;

procedure createForms(compMng:cCompMng);
begin
  // �������� � MainThread
  if GetCurrentThreadId=MainThreadID then
  begin
    // ����� ��������� ����� (���������� � ��������� mainThread) ���������� �� uFrmSync
  end;
end;

procedure destroyForms(compMng:cCompMng);
begin
  // �������� ���� � MainThread
end;

procedure createComponents(compMng:cCompMng);
var
  fact:cGORNFactory;
begin
  fact:=cGORNFactory.Create;
  CompMng.Add(fact);
  //CompMng.Add(cRecFactory.Create);

  //CompMng.Add(cPluginFactory.Create);
end;

procedure destroyComponents(compMng:cCompMng);
begin
end;

function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;
var
  str : string;
begin
  str := GPluginInfo.Name + #13#10 + #13#10 +
         GPluginInfo.Dsc + #13#10 + '������ ' + IntToStr(GPluginInfo.Version) + '.' + IntToStr(GPluginInfo.SubVertion) + #13#10 + #13#10 + GPluginInfo.Vendor + ', ' + IntToStr(GPluginInfo.Year);
  MessageBox(0, PChar(str), '���������� � ������', MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_TOPMOST);

  result := true;
end;

end.
