unit uRecFactory;

interface
// Тестовый модуль для демонстрации создания компонента кнопка

uses
  recorder, windows, activex, uExtFrm, cfreg,
  // Ole2,
  Classes, sysutils, dialogs, uRecBasicFactory,
  ShlObj, inifiles, forms;

type

  //cFrmFactory = class(TInterfacedObject, ICustomFormFactory)
  cRecFactory = class(cRecBasicFactory)
  private

  public
    constructor create;
    function doCreateForm: cRecBasicIFrm; override;
  end;

  //cExtFrm = class(TInterfacedObject, IVForm, ISettingsINI)
  cExtFrm = class(cRecBasicIFrm)
  public
    function doCreateFrm:TRecFrm;override;
  end;

const
  // ctrl+shift+G
  IID: TGuid = (D1: $006D6EDE; D2: $C344; D3: $45C0;
    D4: ($82, $1F, $2F, $F7, $0B, $7B, $23, $A8));

  c_Pic= 'MECH';
  c_Name= 'BtnFact';

implementation

uses
  PluginClass;

constructor cRecFactory.create;
begin
  m_lRefCount := 1;
  m_name:=c_Name;
  m_picname:=c_Pic;
  m_Guid:=IID;
end;

function cRecFactory.doCreateForm: cRecBasicIFrm;
begin
  result :=cExtFrm.create;
end;

function cExtFrm.doCreateFrm:TRecFrm;
begin
  result:=TExtFrm.create(nil);
end;

end.
