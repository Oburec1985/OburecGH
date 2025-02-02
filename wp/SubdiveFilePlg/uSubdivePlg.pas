unit uSubdivePlg;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, ActiveX, SubdivFilePlg_TLB, Winpos_ole_TLB, StdVcl, windows, POSBase;

type
  TSubdivePlgClass = class(TAutoObject, IWPPlugin)
  protected
    function Connect(const app: IDispatch): Integer; safecall;
    function Disconnect: Integer; safecall;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer; safecall;
  end;

var
  // ��������� �� ������ �������
  bar_ID: Integer;
  ID_RunSubdiveFile: integer = 4;

implementation

uses ComServ;

function TSubdivePlgClass.Connect(const app: IDispatch): Integer;
var
  hbmp: cardinal;
begin
  WINPOS:=app as IWinPOS;
  // ���������� ������ �������
  bar_ID := WINPOS.CreateToolbar();
  // ����������� ����� ������� � ������ (������ ����� �������)
  ID_RunSubdiveFile := WINPOS.RegisterCommand();
  // �������� ��� �������� ������� ����� ������� � �������� ������� �����
  // hinstans - ���������� ���������� ������� �������� ��������������� ����������
  hbmp := LoadBitmap(HInstance, 'SUBREGS');
  WINPOS.CreatetoolbarButton(bar_ID, ID_RunSubdiveFile, hbmp,'������� ����'#10'������� ����');
end;

function TSubdivePlgClass.Disconnect: Integer;
begin

end;

function TSubdivePlgClass.NotifyPlugin(what: Integer; var param: OleVariant): Integer;
begin
  // what = $1006 then  ADD_LINE ����������� � ���������� ����� �� ������
  if what = 268828673 then
  begin
  end;
  // Del_LINE �������� ����� � ������� = $1007 then
  if what = 268894209 then
  begin
  end;
  // DEL_GRAPH �������� �������
  if HIWORD(what) = $1004 then
  begin
  end;
  // NODE_RENAMING = 0x101f0001
  if what = $101F0001 then
  begin
  end;
  // ����������� ����������� � ������ ������ ���� 0x00070001
  if what = $00070001 then
  begin
  end;
  // NODE_RENAMED = 0x10200001
  if what = $10200001 then
  begin
  end;
  // del_node = 270401537 ������� �������� ����
  if what = $101E0001 then
  begin
  end;
  // ������ �������
  if HIWORD(what) = ID_RunSubdiveFile then
  begin

  end;
  // ������� �������� ����� ((5 shl 16) or 1) ��� �������������� ������
  if what = 327681 then
  begin
  end;
  if what = $000A0001 then
  begin

  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TSubdivePlgClass, Class_SubdivePlgClass,
    ciMultiInstance, tmApartment);
end.
