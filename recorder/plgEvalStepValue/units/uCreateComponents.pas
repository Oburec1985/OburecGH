unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  uRecFactory,
  uGlFrm,
  uCompMng;

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


const
  // ���������� ���������� ��� ������� �������� plug-in`�.
  GPluginInfo: TInternalPluginInfo = (
    Name: '������ ��� ���������� ����������';
    Dsc: '������ ��� ���������� ����������';
    Vendor: '��� ����';
    Version: 1;
    SubVertion:0;);

  procedure createComponents(compMng:cCompMng);

implementation
uses
  PluginClass;

procedure createComponents(compMng:cCompMng);
begin
  //CompMng.Add(cRecFactory.Create);
  CompMng.Add(cGLFact.Create);
end;

end.
