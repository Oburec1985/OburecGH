unit uGrmsSrcFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises, uGrmsSrcAlg,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, tags, uSpm, ubaseobj,
  uRcCtrls, Spin, DCL_MYOWN, ComCtrls;

type
  TGrmsSrcFrame = class(TBaseAlgFrame)
    Label2: TLabel;
    OutChannelName: TEdit;
    TahoLabel: TLabel;
    SpmPan: TPanel;
    FFTCountLabel: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    AlgDTFE: TFloatEdit;
    BandF1Edit: TFloatEdit;
    BandF2Edit: TFloatEdit;
    FFTCountEdit: TIntEdit;
    FFTCountSpinBtn: TSpinButton;
    PercentCB: TCheckBox;
    ChannelCB: TRcComboBox;
    ChannelLabel: TLabel;
    TahoCB: TRcComboBox;
    FsLabel: TLabel;
    FsEdit: TFloatEdit;
    FFTdx: TFloatEdit;
    dFLabel: TLabel;
    AddNullCB: TCheckBox;
    ResTypeRG: TRadioGroup;
    AlgLabel: TLabel;
    AlgCB: TComboBox;
    TrackingCB: TCheckBox;
    procedure FFTCountSpinBtnDownClick(Sender: TObject);
    procedure FFTCountSpinBtnUpClick(Sender: TObject);
    procedure FFTCountEditChange(Sender: TObject);
    procedure TahoCBChange(Sender: TObject);
    procedure ChannelCBChange(Sender: TObject);
    procedure AlgDTFEChange(Sender: TObject);
    procedure BandF1EditChange(Sender: TObject);
    procedure BandF2EditChange(Sender: TObject);
    procedure PercentCBClick(Sender: TObject);
    procedure AlgCBChange(Sender: TObject);
  public
  protected
    procedure updateAlgCB;
    function getProperties: string; override;
    procedure setProperties(p_str: string); override;
    function algClass:string;override;
    procedure clearframeparams; override;
    procedure updateOptsStr;
    procedure SetFFTCount(fftCount: Integer);overload;
    // changeDt - 1 ������ �������� dt, 0 - �������� blockCount
    procedure SetFFTCount(fftCount: Integer; changeDt:boolean);overload;
  public
    procedure doShow; override;
    constructor create(aOwner: tcomponent); override;
    destructor destroy; override;
    function CreateAlg: cBaseAlg; override;
  end;

const
  c_algClass  = 'cGrmsSrcAlg';

var
  GrmsFrame: TGrmsSrcFrame;

implementation

uses uRCFunc;

{$R *.dfm}


procedure TGrmsSrcFrame.updateOptsStr;
begin
  OptsEdit.text:=getProperties;
end;

procedure TGrmsSrcFrame.FFTCountEditChange(Sender: TObject);
begin
  updateOptsStr;
  SetFFTCount(FFTCountEdit.IntNum);
end;

procedure TGrmsSrcFrame.FFTCountSpinBtnDownClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum>2 then
    FFTCountEdit.IntNum:=round(FFTCountEdit.IntNum/2);
end;

procedure TGrmsSrcFrame.FFTCountSpinBtnUpClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum>2 then
    FFTCountEdit.IntNum:=FFTCountEdit.IntNum*2;
end;


procedure TGrmsSrcFrame.AlgDTFEChange(Sender: TObject);
begin
  updateOptsStr;
  SetFFTCount(FFTCountEdit.IntNum, true);
end;

procedure TGrmsSrcFrame.updateAlgCB;
var
  I: Integer;
  o:cbaseobj;
begin
  AlgCB.Clear;
  for I := 0 to g_algMng.Count - 1 do
  begin
    o:=g_algMng.getObj(i);
    if o is cspm then
    begin
      if ChannelCB.ItemIndex<>-1 then
      begin
        if cspm(o).m_tag.tag=nil then
        begin
          cspm(o).m_tag.tag:=uRCFunc.getTagByName(cspm(o).m_tag.tagname);
        end;
        if cspm(o).m_tag.tag=ChannelCB.gettag(ChannelCB.ItemIndex) then
        begin
          AlgCB.AddItem(cspm(o).name,o);
        end;
      end;
    end;
  end;
  if algcb.Items.count>0 then
    algcb.ItemIndex:=0;
end;

function TGrmsSrcFrame.getProperties: string;
var
  str:string;
begin
  ClearParsResult(m_pars);
  if AlgDTFE.text<>'' then
    addParam(m_pars, 'dX', replaceChar(floattostr(AlgDTfe.FloatNum), ',','.'));
  if BandF1Edit.text<>'' then
    addParam(m_pars, 'Band1', replaceChar(floattostr(BandF1Edit.FloatNum), ',','.'));
  if BandF2Edit.text<>'' then
    addParam(m_pars, 'Band2', replaceChar(floattostr(BandF2Edit.FloatNum), ',','.'));
  if FFTCountEdit.text<>'' then
    addParam(m_pars, 'FFTCount', FFTCountEdit.text);

  addParam(m_pars, 'Addnull', booltostr(AddNullCB.Checked));
  addParam(m_pars, 'Percent', booltostr(PercentCB.Checked));
  // ��������� �� ������ ��������� �������
  if AlgCB.ItemIndex>0 then
  begin
    addParam(m_pars, 'AlgName', cbaseobj(AlgCB.Items.Objects[AlgCB.ItemIndex]).name);
  end;


  str := inttostr(ResTypeRG.ItemIndex);
  addParam(m_pars, 'FFTrestype', str);

  addParam(m_pars, 'TahoTracking', booltostr(TrackingCB.Checked));

  if ChannelCB.text<>'' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
  end;
  if TahoCB.text<>'' then
  begin
    addParam(m_pars, 'Taho', TahoCB.text);
  end
  else
  begin
    addParam(m_pars, 'Taho', '');
  end;
  result:=ParsToStr(m_pars);
end;

procedure TGrmsSrcFrame.PercentCBClick(Sender: TObject);
begin
  if trackingCB.Checked then
  begin
    if PercentCB.Checked then
    begin
      PercentCB.Caption:='������ b1*F1...b2*F1';
    end
    else
    begin
      PercentCB.Caption:='������ (F1-b1)...(F1+b2)';
    end;
  end
  else
  begin
    PercentCB.Caption:='������ b1...b2';
  end;
  updateOptsStr;
end;

procedure TGrmsSrcFrame.setProperties(p_str: string);
var
  p:tnotifyevent;
  str:string;
  t:itag;
  i:integer;
  o:cbaseobj;
begin
  inherited;
  // m_pars �������� � inherited
  p:=FFTCountEdit.OnChange;
  FFTCountEdit.OnChange:=nil;
  FFTCountEdit.Text := GetParsValue(m_pars, 'FFTCount');
  FFTCountEdit.OnChange:=p;

  str := GetParsValue(m_pars, 'Addnull');
  if checkstr(str) then
  begin
    AddNullCB.Checked := StrToBool(str);
  end;

  p:=AlgDTFE.OnChange;
  AlgDTFE.OnChange:=nil;
  AlgDTFE.Text := GetParsValue(m_pars, 'dX');
  AlgDTFE.OnChange:=p;

  p:=BandF1Edit.OnChange;
  BandF1Edit.OnChange:=nil;
  BandF1Edit.Text := GetParsValue(m_pars, 'Band1');
  BandF1Edit.OnChange:=p;

  p:=BandF2Edit.OnChange;
  BandF2Edit.OnChange:=nil;
  BandF2Edit.Text := GetParsValue(m_pars, 'Band2');
  BandF2Edit.OnChange:=p;

  p:=PercentCB.OnClick;
  PercentCB.OnClick:=nil;
  str:=GetParsValue(m_pars, 'Percent');
  if checkstr(str) then
    PercentCB.checked := strtobool(str);
  PercentCB.OnClick:=p;

  str := GetParsValue(m_pars, 'FFTrestype');
  if isvalue(str) then
  begin
    i := strtoint(str);
  end
  else
  begin
    i := 0;
  end;
  ResTypeRG.ItemIndex:=i;

  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);
  if ChannelCB.ItemIndex > 0 then
  begin
    t := ChannelCB.gettag(ChannelCB.ItemIndex);
    FsEdit.FloatNum := t.GetFreq;
    OutChannelName.text:=ChannelCB.text+'_Grms';
  end;

  str := GetParsValue(m_pars, 'OutChannel');
  if checkstr(str) then
    OutChannelName.text:=str;


  setcomboboxitem(GetParsValue(m_pars, 'Taho'), TahoCB);
  TrackingCB.Checked:=StrToBoolDef(GetParsValue(m_pars, 'TahoTracking'), true);

  updateAlgCB;
  str:=GetParsValue(m_pars, 'AlgName');
  o:=g_algMng.getobj(str);
  if o<>nil then
  begin
    algcb.ItemIndex:=-1;
    for I := 0 to algcb.items.count do
    begin
      if algcb.items.Strings[i]=o.name then
      begin
        algcb.ItemIndex:=i;
        break;
      end;
    end;
    if algcb.ItemIndex=-1 then
      algcb.AddItem(o.name,o);
  end;

  SetFFTCount(FFTCountEdit.IntNum);
end;

procedure TGrmsSrcFrame.TahoCBChange(Sender: TObject);
begin
  updateOptsStr;
end;

procedure TGrmsSrcFrame.AlgCBChange(Sender: TObject);
begin
  updateOptsStr;
end;

function TGrmsSrcFrame.algClass: string;
begin
  result:=c_algClass;
end;

procedure TGrmsSrcFrame.BandF1EditChange(Sender: TObject);
begin
  updateOptsStr;
end;

procedure TGrmsSrcFrame.BandF2EditChange(Sender: TObject);
begin
  updateOptsStr;
end;

procedure TGrmsSrcFrame.ChannelCBChange(Sender: TObject);
begin
  updatealgcb;
  updateOptsStr;
end;

procedure TGrmsSrcFrame.clearframeparams;
begin
  inherited;

end;

constructor TGrmsSrcFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.Text := '��� � ������ (1.0)';

end;

destructor TGrmsSrcFrame.destroy;
begin
  inherited;
end;

function TGrmsSrcFrame.CreateAlg: cBaseAlg;
begin
  result := cGrmsSrcAlg.create;
end;

procedure TGrmsSrcFrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
  TahoCB.updateTagsList;
  if ResTypeRG.Items.Count=0 then
  begin
    ResTypeRG.Items.Add('��� ��������������');
    ResTypeRG.Items.Add('��������������');
    ResTypeRG.Items.Add('������� ��������');
  end;
end;

procedure TGrmsSrcFrame.SetFFTCount(fftCount: Integer; changeDt: boolean);
var
  fftdx, bCount: double;
begin
  if changeDt then
  begin
    bCount := (FsEdit.FloatNum*AlgDTFE.FloatNum) /(fftCount);
    if bcount<1 then
      AddNullCB.Checked:=true;
    SetFFTCount(fftCount);
    exit;
  end;
  SetFFTCount(fftCount);
end;

procedure TGrmsSrcFrame.SetFFTCount(fftCount: Integer);
var
  bCount, lfftdx: double;
begin
  lfftdx := FsEdit.FloatNum / (fftCount*2);
  if AddNullCB.Checked then
  begin
    if FsEdit.FloatNum <> 0 then
    begin
      bCount := (FsEdit.FloatNum * AlgDTFE.FloatNum) / (fftCount);
      if bCount < 0 then
      begin
        bCount := 1;
      end;
    end;
  end
  else
  begin
    if FsEdit.FloatNum <> 0 then
    begin
      bCount := 1;
      AlgDTFE.FloatNum := fftCount * bCount/FsEdit.FloatNum;
    end;
  end;
  FFTdx.FloatNum:=lfftdx;
end;

end.
