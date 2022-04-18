unit uCompMng;

interface

uses
  classes, activeX, sysutils, dialogs,
  recorder, plugin, cfreg;

type
  cCompMng = class(Tstringlist)
  public
    // ����� ��� ���������� �����������
    m_FormRegistrator: ICustomFormsRegistrator;
    // ��������� ���������� ���. ��������
    m_CustomButtonsCtrl: ICustomButtonsControl;
    // ������ �� ������ ��������� (���������� ����������)
    m_BtnMainFrame,
    // ������ �� �������� �����
    m_BtnTagPropPage: ICustomButtonsToolBar;
  public
    procedure doAfterLoad;
    constructor create(r:irecorder);
    destructor destroy;
    procedure unregFact(ifact:tobject);
    // destructor destroy; �������������, ����� f ��� �������� ��������� �
    // delphi � ��� ��������� � �� ������������ �������
    procedure Add(f: tobject);
    function GetIfact_(i: integer): ICustomFormFactory; overload;
  end;

implementation

uses
  pluginclass, uRecBasicFactory;

constructor cCompMng.create(r: irecorder);
var
  UISrv: tagVARIANT;
  val: OleVariant;
  rep: hresult;
  count: cardinal;
  str, str1: string;
begin
  rep := r.GetProperty(RCPROP_UISERVERLINK, val);
  UISrv := tagVARIANT(val);
  if (FAILED(rep) or (UISrv.VT <> VT_UNKNOWN)) then
  begin
    LogRecorderMessage('�� ������� �������� ������ ����������������� ����������.', false);
  end;
  m_FormRegistrator := nil;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator,
    m_FormRegistrator);
  m_FormRegistrator.GetFactoriesCount(@count);
  if FAILED(rep) or (m_FormRegistrator = niL) then
  begin
    LogRecorderMessage('�� ������� �������� ��������� ���������� ������� ������������������ ������.', false);
  end;
  // ��������� ���������� ���. ��������
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomButtonsControl,
    m_CustomButtonsCtrl);

  m_BtnMainFrame := nil;
  str := 'main_frame';
  rep := m_CustomButtonsCtrl.GetToolBarByName(@str[1], m_BtnMainFrame);

  m_BtnTagPropPage := nil;
  str := 'tags_property_page';
  rep := m_CustomButtonsCtrl.GetToolBarByName(@str[1], m_BtnTagPropPage);

end;

destructor cCompMng.destroy;
var
  f: ICustomFormFactory;
  i: integer;
  fact:cRecBasicFactory;
  str:string;
begin
  LogRecorderMessage('cCompMng.destroy_enter', false);
  for i := 0 to count - 1 do
  begin
    fact:=cRecBasicFactory(Objects[i]);
    //f:=GetIfact(i);
    fact.GetInterface(IID_ICustomFormFactory, f);
    m_FormRegistrator.UnRegisterFormFactory(f);
    f:=nil;
    // ����� 14.03.18/ �� ������ �������� ������� ������ ��� �������� � ����� (����������)
    //fact.destroy;
    if fact.refcount=1 then
    begin
      // ���� ��������� ��� ��������� ����������
      if fact.count=0 then
        fact._Release;
    end;
  end;

  // ������� ������ ������
  Clear;
  str:=inttostr(i);
  m_FormRegistrator := nil;
  m_CustomButtonsCtrl:=nil;
  m_BtnMainFrame:=nil;
  m_BtnTagPropPage:=nil;
  LogRecorderMessage('cCompMng.destroy_exit', false);
end;

procedure cCompMng.doAfterLoad;
var
  f:cRecBasicFactory;
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    f:=cRecBasicFactory(Objects[i]);
    f.doAfterLoad;
  end;
end;

function cCompMng.GetIfact_(i: integer): ICustomFormFactory;
begin
  objects[i].GetInterface(IID_ICustomFormFactory, result);
end;

procedure cCompMng.unregFact(ifact:tobject);
var
  I: Integer;
  f:ICustomFormFactory;
begin
  for I := 0 to Count - 1 do
  begin
    if ifact=Objects[i] then
    begin
      ifact.GetInterface(IID_ICustomFormFactory,f);
      m_FormRegistrator.UnRegisterFormFactory(f);
      delete(i);
      f:=nil;
    end;
  end;
end;

procedure cCompMng.Add(f: tobject);
var
  lf:ICustomFormFactory;
  str:widestring;
  count:integer;
  g:tguid;
begin
  f.GetInterface(IID_ICustomFormFactory, lf);
  lf.GetFactoryID(g);
  lf.GetFormTypeName(str);
  AddObject(str,f);
  // ������������ �������
  m_FormRegistrator.GetFactoriesCount(@count);
  m_FormRegistrator.RegisterFormFactory(lf); // lf ����������� ���������
  cRecBasicFactory(f).doInit;
end;

end.
