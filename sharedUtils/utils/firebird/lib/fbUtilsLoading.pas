{ *************************************************************************** }
{                                                                             }
{                                                                             }
{                                                                             }
{ ������ fbUtilsLoading - ������, �������� ��������� ������� �������� IBX     }
{ (c) 2012 ������� ������� ���������                                          }
{ ��������� ����������: 09.05.2012                                            }
{ �������������� �� D7, D2007, D2010, D-XE2                                   }
{ ����� �����: http://loginovprojects.ru/                                     }
{ e-mail: loginov_d@inbox.ru                                                  }
{                                                                             }
{ *************************************************************************** }

{
���� ������ �� ������ �������� ��������.
��� ������� ���������� � ������ ������� ������ ���� Firebird ���������� ������
��������. � ���� ������ ��������� ���� ��������� ���������� ���������� GDS32.dll
�� ���������� ����. ����� ������� ��������� ���������� ��������� FIREBIRD.
� ��������, ������ ������ �� �������� ������ ������������, �� ����� ��� �����������
��� ��������� ��������� �������.
����� �������, ����� ���� ���������� �� �������� ��������� GDS32.dll �� �����
WINDOWS\System32\, ��������� ���� ���� ����� ���������������� ������� ��������
Firebird. � ���� ����� �� ���������� ��� ���������� Interbase, �� � ����� �������
����� ����������� ���� WINDOWS\System32\GDS32.dll ��������� ������ � Interbase, �
�� � Firebird.

������ ������ ������ ����� ��� ��������������� "����������" ����������. Firebird
������ �������� � �� �� �����, ��� � ���� ��������� � ������������� � TCP-�����,
������������� �� ������������. � ���� ������ ���������� ���������� �� �������
�� ����, ���� �� �� ���������� ������ ������ Firebird.
����� ����� ����� ���������� ���������������� � "����������" ������� Firebird (embedded).
� ���� ������ ���� fbembed.dll ����������������� � GDS32.dll, � ���������� IBX
���������� �������� � Firebird ��� �� � ��� �� ������.
}

unit fbUtilsLoading;

interface

uses
  Windows, SysUtils, IBIntf;

{$IF RTLVersion >= 23.00}
   {$DEFINE DXE2PLUS}
{$IFEND}

var
  HGDS32: THandle;

const
  {������� ����, �� �������� ����������� ���� Firebird}
  FirebirdPath = 'C:\ProgramsFolder\FIREBIRD\';

  {������� ���� � ���������� GDS32.dll}
  GDS32FileName = FirebirdPath + 'bin\GDS32.dll';

implementation

procedure InitFBClient;
var
  Err: string;

  function TryLoadGDS32: Boolean;
  {$IFDEF DXE2PLUS}
  var
    ServerType: string;
  {$ENDIF}
  begin
  {$IFDEF DXE2PLUS}
    { � ����� ������� IBX ����-�� ��������... }
    ServerType := 'IBServer';
    Result := IBIntf.GetGDSLibrary(ServerType).TryIBLoad;
  {$ELSE}
    Result := IBIntf.GetGDSLibrary.TryIBLoad;
    // ����� ����� ��������� ������, ���� �� ����������� Delphi 7 � ������ ��������
    // ���������� IBX (������ �� ����������: http://ibase.ru/ibx/ibxdp711.zip)
  {$ENDIF}
  end;

begin
  {��� ������������� �� ������ �������� ������� ���������� �� ��������� ��������,
   ��������� � ��������� GDS32.dll. �� ��������� ������� ������ �� ���������, �����
   ���������� ������ ���������}

  {������������� ���������� ��������� FIREBIRD. ��� ����, �� �������� ����������
   GDS32.dll ����� ������ ���� � ����������� "firebird.msg" � log-���� "firebird.log"}
  if not SetEnvironmentVariable(PChar('FIREBIRD'), PChar(FirebirdPath)) then
  begin
    // ����� ����� ���������� ��������� ������
  end;

  if GetModuleHandle('GDS32.dll') = 0 then // ���� ���������� GDS32.dll ��� �� ���������
  begin
    if FileExists(GDS32FileName) then
    begin
      HGDS32 := LoadLibrary(GDS32FileName); // ��������� ���������� GDS32.dll
      if HGDS32 = 0 then
      begin
        Err := '��������� ���� GDS32.dll ������������, ������ ��������� ��� �� �������';
      end else
      begin
        if not TryLoadGDS32 then
        begin
          Err := '��������� ���� GDS32.dll ��������� �������, ������ ���������� IBX �� ���-�� �� ����������';
        end;
      end;
    end else // ���� ��������� ���� �� ������
    begin
      if TryLoadGDS32 then
      begin
        Err := '��������� ���� GDS32.dll �� ������, ������ �� ���������� GDS32.dll ����. ���������� ����� �������� �����������!';
      end
      else
      begin
        Err := '��������� ���� GDS32.dll �� ������. ���������� GDS32.dll �� ����������� �� ������ ����������!';
      end;
    end;
  end else
  begin
    Err := '���������� GDS32.dll ��������� �������������� �� ������� �����';
  end;

  Trim(Err); // �� ���� ������ ����� ������� ��������� � ���������
end;

initialization
  InitFBClient;
finalization
  if HGDS32 <> 0 then // ���� ���������� GDS32.dll ���� ��������� � ���� ������, �� ��������� ��
  try
    FreeLibrary(HGDS32);
  except
    // ������ ��� �������� GDS32.dll
  end;
end.
