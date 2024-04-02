unit uPIDreg;

{$mode objfpc}{$H+}

interface

uses
  Classes, ExtCtrls, SysUtils;

type

  { TPIDreg }
  //Теория вопроса https://www.youtube.com/watch?v=qJt-AtaccJE
  //https://ru.wikipedia.org/wiki/ПИД-регулятор

  TPIDreg = class(TObject)
    private
      fActive: boolean; //вкл/выкл

      fTreg: integer; //период регулирования, милисекунды
      fResponse: double; //обратная связь

      fE: double; //ошибка регулирования
      fLastE: double; //ошибка регулирования на предыдущем шаге
      fLastE2: double; //ошибка регулирования на позапрошлом шаге

      fOutput: double; //выходное значение в % от шкалы
      fOutputFIZ: double; //выходное значение в физической величине, определяемой по fMax и fMin
      fSet: double; //задание, в
      fP: double; //пропорциональный коэффициент (коэффициент усиления (%/<единица физ. величины>)
      fI: double; //интегральный коэффициент (1/Тинтегрирования, милисекунды)
      fD: double; //дифференциальный коэффициент (Тдифференцирования, милисекунды)

      fTimer: TTimer; //Таймер цигла регулирования

      fDOut: double; //Приращение воздействия

      fMax: double; //Максимальное значение управляющего воздействия
      fMin: double; //Минимальное значение управляющего воздействия
      function getActive: boolean;
      function getD: double;
      function getI: double;
      function getMax: double;
      function getOutput: double;
      function getOutputFIZ: double;
      function getP: double;
      function getResponse: double;
      function getTreg: integer;
      procedure Reset;
      procedure setActive(AValue: boolean);
      procedure setD(AValue: double);
      procedure setI(AValue: double);
      procedure setMax(AValue: double);
      procedure setMin(AValue: double);
      procedure setP(AValue: double);
      procedure setResponse(AValue: double);
      procedure setTreg(AValue: integer);
    public
      constructor Create;
      destructor Destroy; override;

      property Active: boolean read getActive write setActive;
      property Treg: integer read getTreg write setTreg;
      property Response: double read getResponse write setResponse;
      property P: double read getP write setP;
      property I: double read getI write setI;
      property D: double read getD write setD;
      property Max: double read getMax write setMax;
      property Min: double read getMax write setMin;
      property Output: double read getOutput;
      property OutputFIZ: double read getOutputFIZ;
  end;

implementation

{ TPIDreg }

function TPIDreg.getActive: boolean;
begin
  result := fActive;
end;

function TPIDreg.getD: double;
begin
  result := fD;
end;

function TPIDreg.getI: double;
begin
  result := fI;
end;

function TPIDreg.getMax: double;
begin
  result := fMax;
end;

function TPIDreg.getOutput: double;
begin
  result := fOutput;
end;

function TPIDreg.getOutputFIZ: double;
begin
  result := fOutputFIZ;
end;

function TPIDreg.getP: double;
begin
  result := fP;
end;

function TPIDreg.getResponse: double;
begin
  result := fResponse;
end;

function TPIDreg.getTreg: integer;
begin
  result := fTreg;
end;

procedure TPIDreg.Reset;
begin
  fE := 0;
  fLastE := 0;
  fLastE2 := 0;
  fOutput := 0;
end;

procedure TPIDreg.setActive(AValue: boolean);
begin
  if fActive = AValue then exit;

  fActive := AValue;
  reset;

  if fActive then
     begin
       fTimer.Active := true;
     end else
     begin
       fTimer.Active := false;
       fOutput := 0;
     end;
end;

procedure TPIDreg.setD(AValue: double);
begin
  fD := AValue;
end;

procedure TPIDreg.setI(AValue: double);
begin
  fI := AValue;
end;

procedure TPIDreg.setMax(AValue: double);
begin
  fMax := AValue;
end;

procedure TPIDreg.setMin(AValue: double);
begin
  fMin := AValue;
end;

procedure TPIDreg.setP(AValue: double);
begin
  fP := AValue;
end;

procedure TPIDreg.setResponse(AValue: double);
begin
  fResponse := AValue;
end;

procedure TPIDreg.setTreg(AValue: integer);
begin
  fTreg := AValue;
end;

constructor TPIDreg.Create;
begin
  inherited;

  fActive := false;

  fP := 1;
  fI := 1;
  fD := 1;

  fMax := 100;
  fMin := 0;

  fTreg := 100; //По умолчанию 100 мс

  fOutput := 0;

  fTimer := TTimer.Create(nil);
  fTimer.OnTimer := ExecCycle;
  fTimer.Interval := fTreg;
end;

destructor TPIDreg.Destroy;
begin
  FreeAndNil(fTimer);
  inherited Destroy;
end;

procedure TPIDreg.ExecCycle(Sender: TObject);
begin
  fLastE2 := fLastE;
  fLastE := fE;
  fE := fSet - fResponse;

  fDOut := fP * (fE - fLastE + fTreg * fI * fLastE + fD / fTreg  * (fE - 2 * fLastE + fLastE2));
  fOutput := fOutput + fDOut; //в процентах

  if fOutput > 100 then fOutput := 100; //Ограничение выдаваемого значения

  fOutputFiz := fMin + fOutput * (fMax - fMin)/100; //в физической величине
end;

end.

