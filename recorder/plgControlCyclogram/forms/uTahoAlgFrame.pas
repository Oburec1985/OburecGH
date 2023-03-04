unit uTahoAlgFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises, mathfunction, tags,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, uCounterAlg,
  uRcCtrls, DCL_MYOWN, uTahoAlg, Spin, ComCtrls, uBtnListView, uRcFunc;



type
  TTahoAlgFrame = class(TBaseAlgFrame)
    TahoTypeCB: TCheckBox;
    LvlPan: TPanel;
    L1Edit: TFloatEdit;
    L2Edit: TFloatEdit;
    L1Label: TLabel;
    L2Label: TLabel;
    SpmPan: TPanel;
    FFTCountLabel: TLabel;
    AddNullCB: TCheckBox;
    ChannelLabel: TLabel;
    Label2: TLabel;
    ChannelCB: TRcComboBox;
    OutChannelName: TEdit;
    Label3: TLabel;
    FFTDx: TFloatEdit;
    Label4: TLabel;
    BandF1Edit: TFloatEdit;
    BandF2Edit: TFloatEdit;
    UseBandCB: TCheckBox;
    FFTCountEdit: TIntEdit;
    FFTCountSpinBtn: TSpinButton;
    Label5: TLabel;
    MinValFE: TFloatEdit;
    FsLabel: TLabel;
    FsEdit: TFloatEdit;
    WndLabel: TLabel;
    WndCB: TComboBox;
    dXLabel: TLabel;
    dXEdit: TFloatEdit;
    procedure L1EditChange(Sender: TObject);
    procedure TahoTypeCBClick(Sender: TObject);
    procedure FFTCountSpinBtnDownClick(Sender: TObject);
    procedure FFTCountSpinBtnUpClick(Sender: TObject);
    procedure ChannelCBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  protected
    finit:boolean;
    curAlg:cbasealgcontainer;
  protected
    function ShowAlg(a:cbaseAlgContainer):boolean;override;
    procedure init;
    function getProperties: string; override;
    procedure setProperties(s: string); override;
    function algClass:string;override;
    procedure clearframeparams; override;
    procedure SetTahoType(levels:boolean);
    procedure SetFFTCount(fftCount: Integer);    
  public
    procedure doShow; override;
    constructor create(aOwner: tcomponent); override;
    destructor destroy; override;
    function CreateAlg: cBaseAlg; override;
  end;

var
  TahoAlgFrame: TTahoAlgFrame;

const
  c_algClass  = 'cTahoAlg';

implementation

{$R *.dfm}


function TTahoAlgFrame.algClass: string;
begin
  result:=c_algClass;
end;

procedure TTahoAlgFrame.ChannelCBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  li:tlistitem;
begin
  Accept:=false;
  if source is tListView then
  begin
    li:=tBtnListView(source).selected;
    if li=nil then exit;
    if li.Data <>nil then
    begin
      if tListitem(source).Data <>nil then
      begin
        if Supports(itag(li.Data),IID_ITAG) then
        begin
          Accept:=not isscalar(itag(li.Data));
        end;
      end;
    end;
  end;
end;

procedure TTahoAlgFrame.clearframeparams;
begin
  inherited;

end;

constructor TTahoAlgFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := 'Расчет Тахо';
end;

function TTahoAlgFrame.CreateAlg: cBaseAlg;
begin
  result:=cTahoAlg.create;
end;

destructor TTahoAlgFrame.destroy;
begin

  inherited;
end;

procedure TTahoAlgFrame.doShow;
begin
  inherited;
  init;
  ChannelCB.updateTagsList;
end;


function TTahoAlgFrame.getProperties: string;
var
  str:string;
begin
  //inherited;
  str:=replaceChar(dXEdit.Text, ',', '.');
  addParam(m_pars, 'Period', str);

  str:=booltostr(AddNullCB.Checked);
  addParam(m_pars, 'Addnull', str);

  if TahoTypecb.Checked then
  begin
    addParam(m_pars, 'TahoType', 'Level');
    str:=replaceChar(l1edit.text, ',', '.');
    addParam(m_pars, 'LHi', str);
    str:=replaceChar(l2edit.text, ',', '.');
    addParam(m_pars, 'LLo', str);
  end
  else
  begin
    // WndCb.ItemIndex синхронизирован с константами в uFFT!!!!
    addParam(m_pars, 'WndType', inttostr(WndCb.ItemIndex));
    addParam(m_pars, 'TahoType', 'FFT');
    addParam(m_pars, 'FFTCount', FFTCountEdit.Text);

    addParam(m_pars, 'FFTUseBand', booltostr(UseBandCB.checked));
    str:=replaceChar(BandF1Edit.text, ',', '.');
    addParam(m_pars, 'FFTBand1', str);
    str:=replaceChar(BandF2Edit.text, ',', '.');
    addParam(m_pars, 'FFTBand2', str);

    str:=replaceChar(MinValFe.text, ',', '.');
    addParam(m_pars, 'MinValue', str);
  end;
  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);

    OutChannelName.text:=ChannelCB.text+'_Taho';
  end;
  result:=ParsToStr(m_pars);
end;

procedure TTahoAlgFrame.init;
begin
  if not finit then
  begin
    finit:=true;
    wndcb.Items.Add('Прямоугольное');
    wndcb.Items.Add('Ханнинг');
  end;
end;

procedure TTahoAlgFrame.L1EditChange(Sender: TObject);
begin
  updateOptsStr;
end;

procedure TTahoAlgFrame.SetFFTCount(fftCount: Integer);
var
  bCount: double;
  fftpoints:integer;
begin
  FFTdX.FloatNum := FsEdit.FloatNum / (fftCount*2);
  if FsEdit.FloatNum <> 0 then
  begin
    bCount := (FsEdit.FloatNum * DxEdit.FloatNum) / (fftCount);
    if bCount < 1 then
    begin
      AddNullCB.checked:=true;
      AddNullCB.showhint:=true;
      AddNullCB.hint:='Размер порции: '+inttostr(trunc(FsEdit.FloatNum * DxEdit.FloatNum))+' меньше FFTCount: '+inttostr(fftCount);
    end
    else
    begin
      AddNullCB.showhint:=false;
      if AddNullCB.checked then
      begin

      end
      else
      begin
        DxEdit.FloatNum := fftCount * bcount / FsEdit.FloatNum;
      end;
    end;
  end;
end;

procedure TTahoAlgFrame.setProperties(s: string);
var
  p:tnotifyevent;
  str:string;
  t:itag;
  ne:tnotifyevent;
begin
  inherited;
  // m_pars обновлен в inherited
  //p:=LoThresholdSE.OnChange;
  //LoThresholdSE.OnChange:=nil;
  //LoThresholdSE.OnChange:=p;

  str:=GetParsValue(m_pars, 'MinValue');

  p := minvalfe.OnChange;
  minvalfe.OnChange := nil;
  minvalfe.Text:=str;
  minvalfe.OnChange := p;

  str:=GetParsValue(m_pars, 'TahoType');
  if str='Level' then
  begin
    SetTahoType(true);
    L1Edit.Text:=GetParsValue(m_pars, 'LHi');
    L2Edit.Text:=GetParsValue(m_pars, 'LLo');
  end
  else
  begin
    SetTahoType(false);
    FFTCountEdit.Text:=GetParsValue(m_pars, 'FFTCount');

    UseBandCB.checked:=strtoboolext(GetParsValue(m_pars, 'FFTUseBand'));
    ne:=BandF1Edit.OnChange;
    BandF1Edit.OnChange:=nil;
    BandF1Edit.text:=GetParsValue(m_pars, 'FFTBand1');
    BandF1Edit.OnChange:=ne;

    ne:=BandF2Edit.OnChange;
    BandF2Edit.OnChange:=nil;
    BandF2Edit.text:=GetParsValue(m_pars, 'FFTBand2');
    BandF2Edit.OnChange:=ne;
  end;

  dxEdit.Text:=GetParsValue(m_pars, 'Period');

  str:=GetParsValue(m_pars, 'Addnull');
  AddNullCB.Checked:=strtoboolext(str);

  str:=GetParsValue(m_pars, 'WndType');
  if checkstr(str) then
    WndCB.itemindex:=strtoint(str);

  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);

  if channelcb.ItemIndex>-1 then
  begin
    t := ChannelCB.gettag(ChannelCB.ItemIndex);
    FsEdit.FloatNum := t.GetFreq;
    fftdx.floatnum:=FsEdit.FloatNum/(FFTCountEdit.IntNum*2);

    OutChannelName.text:=ChannelCB.text+'_Taho';
  end;
end;

procedure TTahoAlgFrame.SetTahoType(levels: boolean);
begin
  TahoTypeCB.Checked:=levels;
  lvlPan.Visible:=levels;
  SpmPan.Visible:=not levels;
end;

function TTahoAlgFrame.ShowAlg(a: cbaseAlgContainer): boolean;
begin
  result:=inherited;
  if result then
    OutChannelName.text:=m_a.resname;
end;

procedure TTahoAlgFrame.FFTCountSpinBtnDownClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum>2 then
    FFTCountEdit.IntNum:=round(FFTCountEdit.IntNum/2);
  SetFFTCount(FFTCountEdit.IntNum);
end;

procedure TTahoAlgFrame.FFTCountSpinBtnUpClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum>2 then
    FFTCountEdit.IntNum:=FFTCountEdit.IntNum*2;
  SetFFTCount(FFTCountEdit.IntNum);
end;

procedure TTahoAlgFrame.TahoTypeCBClick(Sender: TObject);
begin
  SetTahoType(tahotypecb.checked);
end;

end.
