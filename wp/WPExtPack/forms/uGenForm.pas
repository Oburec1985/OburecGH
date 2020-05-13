unit uGenForm;

interface

uses
  Windows, SysUtils, Classes, Forms,
  ComCtrls, StdCtrls, DCL_MYOWN, uSpin, Spin, ExtCtrls, posBase,
  winpos_ole_tlb, Controls;

type
  TGenFrm = class(TForm)
    ActionGB: TGroupBox;
    PageControl1: TPageControl;
    MeandrTS: TTabSheet;
    SKse: TFloatSpinEdit;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    FSLabel: TLabel;
    FSse: TSpinEdit;
    LengthSE: TFloatSpinEdit;
    LengthLabel: TLabel;
    GroupBox2: TGroupBox;
    F1SE: TFloatSpinEdit;
    F1Label: TLabel;
    F2SE: TFloatSpinEdit;
    F2Label: TLabel;
    PhaseSE: TSpinEdit;
    Label2: TLabel;
    FreqRG: TRadioGroup;
    GroupBox3: TGroupBox;
    A1Label: TLabel;
    A2Label: TLabel;
    A1se: TFloatSpinEdit;
    A2se: TFloatSpinEdit;
    AmpRG: TRadioGroup;
    procedure FreqRGClick(Sender: TObject);
    procedure AmpRGClick(Sender: TObject);
  private
    vPhase, aPhase, a:double;
  private
    // решаем уравнение x:=x0+v0*t+a*tt/2
    function GetSqrX(x0, v0, a, t:double):double;
    function GetScale(t:double):double;
    // получить ускорение при логарифмическом законе
    function GetA(t:double):double;
    function GetLevel(phase:double):double;
    function GetPhase(t:double):double;
  public
    Function ShowModal:integer;override;
  end;

var
  GenFrm: TGenFrm;

implementation

{$R *.dfm}

procedure TGenFrm.AmpRGClick(Sender: TObject);
begin
  if AmpRG.ItemIndex=0 then
  begin
    A2se.Enabled:=false;
  end
  else
  begin
    A2se.Enabled:=true;
  end;
end;

procedure TGenFrm.FreqRGClick(Sender: TObject);
begin
  if freqrg.ItemIndex=0 then
  begin
    f2se.Enabled:=false;
  end
  else
  begin
    f2se.Enabled:=true;
  end;
end;

function TGenFrm.GetA(t:double):double;
begin

end;

function TGenFrm.GetSqrX(x0, v0, a, t:double):double;
begin
  result:=x0+v0*t+a*t*t/2;
end;

function TGenFrm.GetScale(t:double):double;
var
  a:double;
begin
  case AmpRG.ItemIndex of
    // посто€нна€ амплитуда
    0:
    begin
      result:=1;
    end;
    1:
    // линейный закон
    begin
      a:=(A2se.Value-A1se.Value)/LengthSE.Value;
      result:=a1se.Value+a*t;
    end;
  end;
end;

function TGenFrm.GetPhase(t:double):double;
begin
  case freqrg.ItemIndex of
    // посто€нна€ частота
    0:
    result:=2*Pi*f1se.Value*t+PhaseSE.Value;
    // линейный закон
    1:
    begin
      result:=GetSqrX(phaseSE.Value, Vphase, Aphase, t);
    end;
    2:;
  end;
end;

function TGenFrm.GetLevel(phase:double):double;
var
  P:double;
begin
  case PageControl1.tabIndex of
    // меандр
    0:
    begin
      p:=2*pi/(Skse.Value);
      if p>phase then
        result:=1
      else
        result:=0;
    end;
  end;
end;

Function TGenFrm.ShowModal:integer;
var
  i, len:cardinal;
  val, phase, dt, t, p0:double;
  s:iwpsignal;
  d:idispatch;
begin
  AmpRGClick(nil);
  FreqRGClick(nil);
  if inherited showmodal=mrok then
  begin
    case freqrg.ItemIndex of
      // посто€нна€ частота
      0:a:=0;
      // линейный рост частоты
      1:a:=(f2se.Value-f1se.Value)/LengthSE.Value;
    end;
    len:=round(fsse.value*lengthse.value);
    dt:=1/fsse.Value;
    t:=0;
    Vphase:=F1SE.Value*2*pi;
    Aphase:=a*2*pi;

    s:=posbase.winpos.CreateSignal(VT_R8) as IWPSignal;
    //-- помещаем сигнал в дерево
    posbase.winpos.Link('/Signals/generator', 'ћеандр', S as IDispatch);
    posbase.winpos.Refresh();
    //-- зададим длину сигнала
    S.size:= Len;
    s.DeltaX:=dt;
    for I := 0 to len - 1 do
    begin
      phase:=GetPhase(t)+p0;
      // убираем целое число периодов
      phase:=phase-2*pi*trunc(phase/(2*pi));
      // значение
      val:=GetLevel(phase)*GetScale(t);
      t:=t+dt;
      s.SetY(i, val);
    end;
  end;
end;

end.
