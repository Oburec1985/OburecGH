unit uAlgFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uBaseAlg, ucommonmath;

type
  TBaseAlgFrame = class(TFrame)
    AlgNameEdit: TEdit;
    NameLabel: TLabel;
    OptsEdit: TEdit;
    OptsLabel: TLabel;
  protected
    m_pars:tstringlist;
    ms:boolean;
  public
    m_a:cBaseAlgContainer;
  protected
    function getProperties:string;virtual;
    procedure setProperties(s:string);virtual;
    function algClass:string;virtual;abstract;
    procedure clearframeparams; virtual;abstract;
    procedure updateOptsStr;
  public
    property properties:string read getProperties write setProperties;
    // возвращает true если фрейм предназначен для работы с алгоритмом a
    // multiselect - для последнего элемента должно быть false
    function ShowAlg(a:cbaseAlgContainer):boolean;overload;virtual;
    function ShowAlg(cfg:cAlgConfig):boolean;overload;virtual;
    procedure EndMsel;virtual;

    procedure doShow;virtual;abstract;
    function GetDsc:string;virtual;
    function CreateAlg:cBaseAlg;virtual;abstract;
    constructor create(aOwner:tcomponent);override;
    destructor destroy;override;
  end;

implementation

{$R *.dfm}

{ TBaseAlgFrame }

constructor TBaseAlgFrame.create(aOwner: tcomponent);
begin
  inherited;
  m_pars:=tstringlist.Create;
end;

destructor TBaseAlgFrame.destroy;
begin
  delPars(m_pars);
  m_pars.destroy;
  inherited;
end;


procedure TBaseAlgFrame.EndMsel;
begin

end;

function TBaseAlgFrame.GetDsc: string;
begin
  result:=AlgNameEdit.Text;
end;

function TBaseAlgFrame.getProperties: string;
begin
  clearParsResult(m_pars);
end;

procedure TBaseAlgFrame.setProperties(s: string);
begin
  OptsEdit.text:=s;
  updateParams(m_pars, s, ',');
end;

function TBaseAlgFrame.ShowAlg(cfg:cAlgConfig):boolean;
begin
  result:=false;
  if cfg<>nil then
  begin
    if cfg.clType.ClassName=algClass then
    begin
      result:=true;
      setProperties(cfg.str);
    end;
  end
  else
  begin
    clearframeparams;
  end;
end;

function TBaseAlgFrame.ShowAlg(a: cbaseAlgContainer):boolean;
begin
  result:=false;
  if a<>nil then
  begin
    if a.classname=algClass then
    begin
      result:=true;
      setProperties(a.getFullProperties);
    end;
  end
  else
  begin
    clearframeparams;
  end;
end;

procedure TBaseAlgFrame.updateOptsStr;
begin
  OptsEdit.text:=getProperties;
end;

end.
