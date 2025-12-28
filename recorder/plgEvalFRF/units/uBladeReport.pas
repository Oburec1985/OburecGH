unit uBladeReport;

interface
uses
  classes,
  uspmband;

type

  cExtremum = class
  public
    Index: Integer; // Индекс элемента в исходном массиве Y
    Value: Double;  // Значение экстремума (найденное Y-значение)
    Freq: Double;  // частота экстремума
    BandNum:integer; // в полосе № (-1 если не попал в полосу)
    // главный экстремум в полосе
    Main,
    // в допуске
    InTol:boolean;
    NumInBand:integer; // номер экстремума внут*ри той же полосы
    decrement:double;
    m_b:tSpmBand;
  public
    constructor create;
    destructor destroy;
  end;
  // список найденных экстремумов на линии для сравненияс
  // l: tlist;
  function CheckExtremList(l:tlist; bands:blist):boolean;

implementation


{ TExtremum1d }
constructor cExtremum.create;
begin
  m_b:=nil;
  BandNum:=-1;
  Main:=false;
  NumInBand:=-1;
end;

destructor cExtremum.destroy;
begin

end;

function CheckExtremList(l:tlist; bands:blist):boolean;
var
  I, bnum: Integer;
  e:cExtremum;
begin
  bnum:=0;
  result:=true;
  for I := 0 to l.Count - 1 do
  begin
    e:=cExtremum(l.Items[i]);
    if e.InTol then
    begin
      if bnum=e.BandNum then
      begin
        inc(bnum);
        continue;
      end;
    end;
    // если попался экстремум не в допуске или какая то полоса не заполнена экстремумом
    result:=false;
    break;
  end;
end;

end.
