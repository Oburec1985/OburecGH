unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  Windows,
  SysUtils,
  cfreg,
  uGateFrm,
  uCompMng;

type
  {��� ��� �������� ���������� � plug-in`�}
  {���� ��� ������� ������������ � Delphi, ��� PLUGININFO}
  TInternalPluginInfo = record
    Name: AnsiString;    // ������������
    Dsc: AnsiString;     // ��������
    Vendor: AnsiString;  // �������� ������������
    Version: integer;    // ������
    SubVertion: integer; // ���-������
  end;

  procedure createComponents(compMng:cCompMng);
  function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;
  procedure destroyComponents(compMng:cCompMng);

const
  // ���������� ���������� ��� ������� �������� plug-in`�.
  GPluginInfo: TInternalPluginInfo = (
    Name: '������ ��� ���������� ����������';
    Dsc: '������ ��� ���������� ����������';
    Vendor: '��� ����';
    Version: 1;
    SubVertion:0;);

implementation
//uses
//  PluginClass;

procedure createComponents(compMng:cCompMng);
begin
  CompMng.Add(cGateFactory.Create);
  //CompMng.Add(cRecFactory.Create);
end;

procedure destroyComponents(compMng:cCompMng);
begin

end;

function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;
var
  str : string;
begin
  str := GPluginInfo.Name + #13#10 +
         GPluginInfo.Dsc + #13#10 +
         '������ ' + IntToStr(GPluginInfo.Version) + '.' + IntToStr(GPluginInfo.SubVertion) + #13#10 + #13#10 +
         GPluginInfo.Vendor;
  MessageBox(0, PChar(str), '���������� � ������', MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_TOPMOST);

  result := true;
end;

end.
