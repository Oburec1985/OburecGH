unit uSpmFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uCommonMath, uComponentservises, uGrmsAlg,
  Dialogs, uAlgFrame, StdCtrls, ExtCtrls, uSpin, ubasealg, tags, uRCFunc,
  uRcCtrls, Spin, DCL_MYOWN, ComCtrls, uBtnListView;

type
  TSpmFrame = class(TBaseAlgFrame)
    SpmPan: TPanel;
    FFTCountLabel: TLabel;
    FFTCountEdit: TIntEdit;
    FFTCountSpinBtn: TSpinButton;
    ChannelCB: TRcComboBox;
    ChannelLabel: TLabel;
    Label2: TLabel;
    OutChannelName: TEdit;
    AddNullCB: TCheckBox;
    BlockCountLabel: TLabel;
    FFTBCount: TIntEdit;
    FsLabel: TLabel;
    FsEdit: TFloatEdit;
    dFLabel: TLabel;
    FFTdX: TFloatEdit;
    AlgDTLabel: TLabel;
    AlgDTFE: TFloatEdit;
    AHComboBox: TComboBox;
    AHLabel: TLabel;
    AHBtn: TButton;
    ResTypeRG: TRadioGroup;

    procedure FFTCountEditChange(Sender: TObject);
    procedure FFTCountSpinBtnDownClick(Sender: TObject);
    procedure FFTCountSpinBtnUpClick(Sender: TObject);
    procedure ChannelCBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FFTBCountChange(Sender: TObject);
    procedure AlgDTFEChange(Sender: TObject);
    procedure ChannelCBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  protected
    m_lastOutTag: string;
  protected
    function getProperties: string; override;
    procedure setProperties(s: string); override;
    function algClass: string; override;
    procedure clearframeparams; override;
    procedure SetFFTCount(fftCount: Integer); overload;
    // changeDt - 1 значит изменили dt, 0 - изменили blockCount
    procedure SetFFTCount(fftCount: Integer; changeDt, changeBCount: Boolean);
      overload;
  public
    procedure EndMsel; override;
    procedure doShow; override;
    constructor create(aOwner: tcomponent); override;
    destructor destroy; override;
    function CreateAlg: cBaseAlg; override;
  end;

var
  SpmFrame: TSpmFrame;

implementation

const
  c_algClass = 'cSpm';
{$R *.dfm}

procedure TSpmFrame.FFTBCountChange(Sender: TObject);
begin
  SetFFTCount(FFTCountEdit.IntNum, false, true);
end;

procedure TSpmFrame.FFTCountEditChange(Sender: TObject);
begin
  updateOptsStr;
  SetFFTCount(FFTCountEdit.IntNum);
end;

procedure TSpmFrame.FFTCountSpinBtnDownClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum > 2 then
    FFTCountEdit.IntNum := round(FFTCountEdit.IntNum / 2);
end;

procedure TSpmFrame.FFTCountSpinBtnUpClick(Sender: TObject);
begin
  if FFTCountEdit.IntNum > 2 then
    FFTCountEdit.IntNum := FFTCountEdit.IntNum * 2;
end;

function TSpmFrame.getProperties: string;
var
  str, lstr: string;
  b, err: Boolean;
  t: itag;
begin
  delPars(m_pars);
  if FFTCountEdit.text <> '' then
  begin
    str := GetMultiSelectComponentString(FFTCountEdit, err);
    if not err then
    begin
      addParam(m_pars, 'FFTCount', str);
    end;
  end;
  str := inttostr(ResTypeRG.ItemIndex);
  if not err then
  begin
    addParam(m_pars, 'FFTrestype', str);
  end;
  b := GetMultiSelectComponentBool(AddNullCB, err);
  if not err then
  begin
    addParam(m_pars, 'Addnull', booltostr(b));
  end;
  str := GetMultiSelectComponentString(AlgDTFE, err);
  if not err then
  begin
    addParam(m_pars, 'dX', replaceChar(str, ',', '.'));
    // addParam(m_pars, 'dX', replaceChar(floattostr(AlgDTFE.FloatNum), ',', '.'));
  end;
  str := GetMultiSelectComponentString(FFTBCount, err);
  if not err then
  begin
    addParam(m_pars, 'BCount', str);
  end;
  if ChannelCB.text <> '' then
  begin
    str := GetMultiSelectComponentString(ChannelCB, err);
    if not err then
    begin
      addParam(m_pars, 'Channel', str);
      b := true;
      lstr := str + '_Spm';
      while b do
      begin
        t := getTagByName(lstr);
        if (t = nil) or (lstr = m_lastOutTag) then
          b := false
        else
          lstr := ModName(lstr, false);
      end;
      OutChannelName.text := lstr;
      m_lastOutTag := lstr;
      addParam(m_pars, 'OutChannel', lstr);
    end;
  end;
  result := ParsToStr(m_pars);
end;

procedure TSpmFrame.SetFFTCount(fftCount: Integer; changeDt,
  changeBCount: Boolean);
var
  bCount: double;
  p: TNotifyEvent;
begin
  if not changeDt then
  begin
    if changeBCount then
    begin
      p := AlgDTFE.OnChange;
      AlgDTFE.OnChange := nil;
      if FsEdit.FloatNum <> 0 then
        AlgDTFE.FloatNum := FFTBCount.IntNum * fftCount / FsEdit.FloatNum;
      AlgDTFE.OnChange := p;
      exit;
    end
    else
    begin
      SetFFTCount(fftCount);
      exit;
    end;
  end;
  p := FFTBCount.OnChange;
  FFTBCount.OnChange := nil;
  if AddNullCB.Checked then
  begin
    if FsEdit.FloatNum <> 0 then
    begin
      bCount := (AlgDTFE.FloatNum * FsEdit.FloatNum) / fftCount;
      if bCount < 1 then
      begin
        FFTBCount.IntNum := 1;
      end
      else
      begin
        FFTBCount.IntNum := trunc(bCount);
        if frac(bCount) > 0 then
        begin
          FFTBCount.IntNum := FFTBCount.IntNum + 1;
        end;
      end;
    end;
  end
  else
  begin
    if FsEdit.FloatNum <> 0 then
    begin
      if changeBCount then
        bCount := FFTBCount.IntNum
      else
        bCount := (AlgDTFE.FloatNum * FsEdit.FloatNum) / fftCount;
      if bCount < 1 then
      begin
        AddNullCB.Checked := true;
        FFTBCount.IntNum := 1;
      end
      else
      begin
        FFTBCount.IntNum := trunc(bCount);
        if frac(bCount) > 0 then
        begin
          FFTBCount.IntNum := FFTBCount.IntNum + 1;
        end;
      end;
      if changeBCount then
        AlgDTFE.FloatNum := bCount * fftCount / FsEdit.FloatNum;
    end;
  end;
  FFTBCount.OnChange := p;
end;

procedure TSpmFrame.SetFFTCount(fftCount: Integer);
var
  bCount: double;
  p: TNotifyEvent;
begin
  FFTdX.FloatNum := FsEdit.FloatNum / (fftCount * 2);
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
      p := FFTBCount.OnChange;
      FFTBCount.OnChange := nil;
      FFTBCount.IntNum := round(bCount);
      FFTBCount.OnChange := p;

      p := AlgDTFE.OnChange;
      AlgDTFE.OnChange := nil;
      AlgDTFE.FloatNum := fftCount * FFTBCount.IntNum / FsEdit.FloatNum;
      AlgDTFE.OnChange := p;
    end;
  end;
end;

procedure TSpmFrame.EndMsel;
begin
  // m_pars обновлен в inherited
  endMultiSelect(FFTCountEdit);
  endMultiSelect(AddNullCB);
  endMultiSelect(AlgDTFE);
  endMultiSelect(FFTBCount);
  endMultiSelect(ChannelCB);
  endMultiSelect(FsEdit);
  endMultiSelect(FFTdX);
  endMultiSelect(OutChannelName);
  endMultiSelect(ResTypeRG);
end;

procedure TSpmFrame.setProperties(s: string);
var
  p: TNotifyEvent;
  str: string;
  i: Integer;
  t: itag;
begin
  inherited;
  // m_pars обновлен в inherited
  p := FFTCountEdit.OnChange;
  FFTCountEdit.OnChange := nil;
  str := GetParsValue(m_pars, 'FFTCount');
  SetMultiSelectComponentString(FFTCountEdit, str);
  FFTCountEdit.OnChange := p;

  str := GetParsValue(m_pars, 'FFTrestype');
  if isvalue(str) then
  begin
    i := strtoint(str);
  end
  else
  begin
    i := 0;
  end;
  setMultiSelectItemInd(ResTypeRG, i);

  str := GetParsValue(m_pars, 'Addnull');
  if checkstr(str) then
  begin
    SetMultiSelectComponentBool(AddNullCB, StrToBool(str));
  end;

  str := GetParsValue(m_pars, 'BCount');
  if checkstr(str) then
  begin
    p := FFTBCount.OnChange;
    FFTBCount.OnChange := nil;
    SetMultiSelectComponentString(FFTBCount, str);
    FFTBCount.OnChange := p;
  end;

  str := GetParsValue(m_pars, 'dX');
  //if checkstr(str) then
  //begin
  //  p := AlgDTFE.OnChange;
  //  AlgDTFE.OnChange := nil;
  //  SetMultiSelectComponentString(AlgDTFE, str);
  //  AlgDTFE.OnChange := p;
  //end
  //else
  begin
    str := GetParsValue(m_pars, 'Channel');
    t := getTagByName(str);
    if t<>nil then
    begin
      p := AlgDTFE.OnChange;
      AlgDTFE.OnChange := nil;
      str:=floattostr(fftbcount.IntNum*FFTCountEdit.IntNum/t.GetFreq);
      SetMultiSelectComponentString(AlgDTFE, str);
      AlgDTFE.OnChange := p;
    end;
  end;
  str := GetParsValue(m_pars, 'Channel');
  SetMultiSelectComponentString(ChannelCB, str);
  if ChannelCB.ItemIndex >= 0 then
  begin
    str := GetParsValue(m_pars, 'OutChannel');
    t := ChannelCB.gettag(ChannelCB.ItemIndex);
    SetMultiSelectComponentString(FsEdit, floattostr(t.GetFreq));
    SetMultiSelectComponentString
      (FFTdX, floattostr(FsEdit.FloatNum / (FFTCountEdit.IntNum * 2)));
    if not checkstr(str) then
    begin
      SetMultiSelectComponentString(OutChannelName, ChannelCB.text + '_spm');
      m_lastOutTag := '';
    end
    else
    begin
      SetMultiSelectComponentString(OutChannelName, str);
      OutChannelName.text := str;
      m_lastOutTag := str;
    end;
  end
  else
  begin
    OutChannelName.text := '';
  end;
  if AlgDTFE.FloatNum = -1 then
    SetFFTCount(FFTCountEdit.IntNum, false, true);
end;

function TSpmFrame.algClass: string;
begin
  result := c_algClass;
end;

procedure TSpmFrame.AlgDTFEChange(Sender: TObject);
begin
  updateOptsStr;
  SetFFTCount(FFTCountEdit.IntNum, true, false);
end;

procedure TSpmFrame.ChannelCBDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  inherited;
  updateOptsStr;
end;

procedure TSpmFrame.ChannelCBDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  li: tlistitem;
begin
  Accept := false;
  if Source is tListView then
  begin
    li := tBtnListView(Source).selected;
    if li = nil then
      exit;
    if li.Data <> nil then
    begin
      if tlistitem(Source).Data <> nil then
      begin
        if Supports(itag(li.Data), IID_ITAG) then
        begin
          Accept := not isscalar(itag(li.Data));
        end;
      end;
    end;
  end;
end;

procedure TSpmFrame.clearframeparams;
begin
  inherited;

end;

constructor TSpmFrame.create(aOwner: tcomponent);
begin
  inherited;
  AlgNameEdit.text := 'Спектр';
end;

destructor TSpmFrame.destroy;
begin
  inherited;
end;

function TSpmFrame.CreateAlg: cBaseAlg;
begin
  result := cGRmsAlg.create;
end;

procedure TSpmFrame.doShow;
begin
  inherited;
  ChannelCB.updateTagsList;
  if ResTypeRG.Items.Count=0 then
  begin
    ResTypeRG.Items.Add('Амплитудный спектр');
    ResTypeRG.Items.Add('Интегрирование');
    ResTypeRG.Items.Add('Двойной интеграл');
  end;
end;

end.
