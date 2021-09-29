unit uAriphmAlgFrame;

interface


uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath,
  uComponentservises,
  tags,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg,
  uRcCtrls, DCL_MYOWN, uTahoAlg, Spin, ComCtrls, uBtnListView,
  uAriphmAlg,
  uRcFunc;

type
  TAriphmAlgFrame = class(TBaseAlgFrame)
    ChannelLabel: TLabel;
    ChannelCB: TRcComboBox;
    Label2: TLabel;
    OutChannelName: TEdit;
    ResTypeCB: TRcComboBox;
    Label1: TLabel;
    ChanALabel: TLabel;
    ChanA: TRcComboBox;
    ChanB: TRcComboBox;
    ChanBLabel: TLabel;
  private
    m_init:boolean;
  public
    procedure init;
    function getProperties: string; override;
    procedure setProperties(s: string); override;
    function algClass:string;override;
    procedure clearframeparams; override;
  public
    procedure doShow; override;
    constructor create(aOwner: tcomponent); override;
    destructor destroy; override;
    function CreateAlg: cBaseAlg; override;
  end;

const
  c_algClass  = 'cAriphmAlg';


implementation

{$R *.dfm}

{ TFrame2 }

function TAriphmAlgFrame.algClass: string;
begin
  result:=c_algClass;
end;

procedure TAriphmAlgFrame.clearframeparams;
begin
  inherited;

end;

constructor TAriphmAlgFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := 'Арифметические операции';
end;

function TAriphmAlgFrame.CreateAlg: cBaseAlg;
begin
  result:=cAriphmAlg.create;
end;

destructor TAriphmAlgFrame.destroy;
begin

  inherited;
end;

procedure TAriphmAlgFrame.doShow;
begin
  inherited;
  // если CB заполнять в конструкторе выдается ошибка has no parent wnd!
  init;
  ChannelCB.updateTagsList;
  ChanA.updateTagsList;
  ChanB.updateTagsList;
end;

function TAriphmAlgFrame.getProperties: string;
var
  str:string;
begin
  addParam(m_pars, 'TypeRes', inttostr(ResTypeCB.itemindex));
  if ChanA.text<>'' then
  begin
    addParam(m_pars, 'Aparam', ChanA.text);
  end;
  if ChanB.text<>'' then
  begin
    addParam(m_pars, 'Bparam', ChanB.text);
  end;
  if ChannelCB.text<>'' then
  begin
    case ResTypeCB.itemindex of
      c_Add: str:='Add';
      c_Dec: str:='Dec';
      c_Mult: str:='Mult';
      c_Div: str:='Div';
    end;
    OutChannelName.text:=ChanA.text+'_'+ChanB.text+'_'+str;
    ChannelCB.text:=OutChannelName.text;
    addParam(m_pars, 'OutChannel', ChannelCB.text);
  end;
  result:=ParsToStr(m_pars);
end;

procedure TAriphmAlgFrame.init;
begin
  if not m_init then
  begin
    restypecb.items.add('Сложение');
    restypecb.items.add('Вычитание');
    restypecb.items.add('Умножение');
    restypecb.items.add('Деление');
    m_init:=true;
  end;
end;

procedure TAriphmAlgFrame.setProperties(s: string);
var
  p:tnotifyevent;
  str:string;
  t:itag;
begin
  inherited;

  str:=GetParsValue(m_pars, 'TypeRes');
  if checkstr(str) then
    ResTypeCB.itemindex:=strtoint(str);

  setcomboboxitem(GetParsValue(m_pars, 'OutChannel'), ChannelCB);
  setcomboboxitem(GetParsValue(m_pars, 'Aparam'), ChanA);
  setcomboboxitem(GetParsValue(m_pars, 'Bparam'), ChanB);
end;

end.
