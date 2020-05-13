unit uPhaseCrossSpmFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uAlgFrame, StdCtrls, uRcCtrls, DCL_MYOWN, Spin, ExtCtrls, uBaseAlg,
  uCommonMath, uComponentservises, uSpin, tags,
  uRCFunc, uSynchroPhaseAlg;

type
  TSynchroPhasePhrame = class(TBaseAlgFrame)
    ChannelCB: TRcComboBox;
    ChannelLabel: TLabel;
    Label1: TLabel;
    TahoChannel: TRcComboBox;
    FsLabel: TLabel;
    FsEdit: TFloatEdit;
    Label2: TLabel;
    OutChannelName: TEdit;
    SpmPan: TPanel;
    FFTCountLabel: TLabel;
    BlockCountLabel: TLabel;
    dFLabel: TLabel;
    AlgDTLabel: TLabel;
    FFTCountEdit: TIntEdit;
    FFTCountSpinBtn: TSpinButton;
    AddNullCB: TCheckBox;
    FFTBCount: TIntEdit;
    FFTdX: TFloatEdit;
    AlgDTFE: TFloatEdit;
    procedure FFTCountEditChange(Sender: TObject);
    procedure FFTBCountChange(Sender: TObject);
    procedure AlgDTFEChange(Sender: TObject);
    procedure FFTCountSpinBtnDownClick(Sender: TObject);
    procedure FFTCountSpinBtnUpClick(Sender: TObject);
  private
    m_lastOutTag: string;
  protected
    function getProperties: string; override;
    procedure setProperties(s: string); override;
    function algClass: string; override;
    procedure clearframeparams; override;
    procedure SetFFTCount(fftCount: Integer);overload;
    // changeDt - 1 значит изменили dt, 0 - изменили blockCount
    procedure SetFFTCount(fftCount: Integer; changeDt, changeBCount:boolean);overload;
  public
    procedure doShow; override;
    constructor create(aOwner: tcomponent); override;
    destructor destroy; override;
    function CreateAlg: cBaseAlg; override;
  end;

var
  SynchroPhasePhrame: TSynchroPhasePhrame;

const
  c_algClass = 'cSyncPhaseAlg';

implementation

{$R *.dfm}

{ TSWynchroPhasePhrame }


procedure TSynchroPhasePhrame.SetFFTCount(fftCount: Integer; changeDt, changeBCount: boolean);
var
  bCount: double;
  p:TNotifyEvent;
begin
  if not changeDt then
  begin
    if changeBCount then
    begin
      p:=AlgDTFE.OnChange;
      AlgDTFE.OnChange:=nil;
      AlgDTFE.FloatNum:=FFTBCount.IntNum*fftcount/FsEdit.FloatNum;
      AlgDTFE.OnChange:=p;
      exit;
    end
    else
    begin
      SetFFTCount(fftCount);
      exit;
    end;
  end;
  p:=FFTBCount.OnChange;
  FFTBCount.OnChange:=nil;
  if AddNullCB.Checked then
  begin
    if FsEdit.FloatNum <> 0 then
    begin
      bCount := (AlgDTFE.FloatNum*FsEdit.FloatNum)/ fftcount;
      if bCount < 1 then
      begin
        FFTBCount.IntNum:=1;
      end
      else
      begin
        FFTBCount.IntNum:=trunc(bCount);
        if frac(bCount)>0 then
        begin
          FFTBCount.IntNum:=FFTBCount.IntNum+1;
        end;
      end;
    end;
  end
  else
  begin
    if FsEdit.FloatNum <> 0 then
    begin
      if changeBCount then
        bCount:=FFTBCount.IntNum
      else
        bCount := (AlgDTFE.FloatNum*FsEdit.FloatNum)/ fftcount;
      if bCount < 1 then
      begin
        AddNullCB.Checked:=true;
        FFTBCount.IntNum:=1;
      end
      else
      begin
        FFTBCount.IntNum:=trunc(bCount);
        if frac(bCount)>0 then
        begin
          FFTBCount.IntNum:=FFTBCount.IntNum+1;
        end;
      end;
      if changeBCount then
        AlgDTFE.FloatNum:=bCount*fftcount/FsEdit.FloatNum;
    end;
  end;
  FFTBCount.OnChange:=p;
end;

procedure TSynchroPhasePhrame.SetFFTCount(fftCount: Integer);
var
  bCount: double;
  p:TNotifyEvent;
begin
  FFTdX.FloatNum := FsEdit.FloatNum / (fftCount*2);
  if AddNullCB.Checked then
  begin
    if FsEdit.FloatNum <> 0 then
    begin
      bCount := (FsEdit.FloatNum * AlgDTFE.FloatNum) / (fftCount);
      if bCount < 0 then
      begin
        bCount := 1;
      end;
      AlgDTFE.FloatNum := fftCount * FFTBCount.IntNum / FsEdit.FloatNum;
    end;
  end
  else
  begin
    if FsEdit.FloatNum <> 0 then
    begin
      bCount := (FsEdit.FloatNum * AlgDTFE.FloatNum) / (fftCount);
      if bCount < 1 then
      begin
        bCount := 1;
      end;
      p:=FFTBCount.OnChange;
      FFTBCount.OnChange:=nil;
      FFTBCount.IntNum := round(bCount);
      FFTBCount.OnChange:=p;

      p:=AlgDTFE.OnChange;
      AlgDTFE.OnChange:=nil;
      AlgDTFE.FloatNum := fftCount * FFTBCount.IntNum / FsEdit.FloatNum;
      AlgDTFE.OnChange:=p;
    end;
  end;
end;

function TSynchroPhasePhrame.algClass: string;
begin
  result := c_algClass;
end;

procedure TSynchroPhasePhrame.AlgDTFEChange(Sender: TObject);
begin
  updateOptsStr;
  SetFFTCount(FFTCountEdit.IntNum, true, false);
end;

procedure TSynchroPhasePhrame.clearframeparams;
begin
  inherited;

end;

constructor TSynchroPhasePhrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.text := 'Фаза (кросс.спектр)';
end;

function TSynchroPhasePhrame.CreateAlg: cBaseAlg;
begin
  result := cSyncPhaseAlg.create;
end;

destructor TSynchroPhasePhrame.destroy;
begin

  inherited;
end;

procedure TSynchroPhasePhrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
  TahoChannel.updateTagsList;
end;

procedure TSynchroPhasePhrame.FFTBCountChange(Sender: TObject);
begin
  SetFFTCount(FFTCountEdit.IntNum, false, true);
end;

procedure TSynchroPhasePhrame.FFTCountEditChange(Sender: TObject);
begin
  updateOptsStr;
  SetFFTCount(FFTCountEdit.IntNum);
end;

procedure TSynchroPhasePhrame.FFTCountSpinBtnDownClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum > 2 then
    FFTCountEdit.IntNum := round(FFTCountEdit.IntNum / 2);
end;

procedure TSynchroPhasePhrame.FFTCountSpinBtnUpClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum > 2 then
    FFTCountEdit.IntNum := FFTCountEdit.IntNum * 2;
end;

function TSynchroPhasePhrame.getProperties: string;
var
  str: string;
  b: boolean;
  t: itag;
begin
  if FFTCountEdit.text <> '' then
    addParam(m_pars, 'FFTCount', FFTCountEdit.text);
  addParam(m_pars, 'Addnull', booltostr(AddNullCB.Checked));
  addParam(m_pars, 'dX', replaceChar(floattostr(AlgDTfe.FloatNum), ',','.'));
  addParam(m_pars, 'BCount', inttostr(FFTBCount.IntNum));
  if TahoChannel.text <> '' then
  begin
    addParam(m_pars, 'Taho', TahoChannel.text);
  end;
  if ChannelCB.text <> '' then
  begin
    addParam(m_pars, 'Channel', ChannelCB.text);
    str := ChannelCB.text + '_PhaseCr';
    b := true;
    while b do
    begin
      t := getTagByName(str);
      if (t = nil) or (str = m_lastOutTag) then
        b := false
      else
        str := ModName(str, false);
    end;
    OutChannelName.text := str;
    m_lastOutTag := str;
    addParam(m_pars, 'OutChannel', str);
  end;

  result := ParsToStr(m_pars);
end;

procedure TSynchroPhasePhrame.setProperties(s: string);
var
  p: tnotifyevent;
  str: string;
  t: itag;
begin
  inherited;
  // m_pars обновлен в inherited
  p := FFTCountEdit.OnChange;
  FFTCountEdit.OnChange := nil;
  FFTCountEdit.text := GetParsValue(m_pars, 'FFTCount');
  FFTCountEdit.OnChange := p;

  str := GetParsValue(m_pars, 'Addnull');
  if checkstr(str) then
  begin
    AddNullCB.Checked := StrToBool(str);
  end;

  str := GetParsValue(m_pars, 'dX');
  if checkstr(str) then
  begin
    AlgDTFE.FloatNum := strToFloatExt(str);
  end;

  str := GetParsValue(m_pars, 'BCount');
  if checkstr(str) then
  begin
    FFTBCount.IntNum:= strtoint(str);
  end;
  setcomboboxitem(GetParsValue(m_pars, 'Taho'), TahoChannel);
  setcomboboxitem(GetParsValue(m_pars, 'Channel'), ChannelCB);
  if ChannelCB.ItemIndex > 0 then
  begin
    str := GetParsValue(m_pars, 'OutChannel');
    t := ChannelCB.gettag(ChannelCB.ItemIndex);
    FsEdit.FloatNum := t.GetFreq;
    fftdx.floatnum:=FsEdit.FloatNum/(FFTCountEdit.IntNum*2);
    if str = '' then
    begin
      OutChannelName.text := ChannelCB.text + '_PhaseCr';
      m_lastOutTag := '';
    end
    else
    begin
      OutChannelName.text := str;
      m_lastOutTag := str;
    end;
  end;
end;

end.
