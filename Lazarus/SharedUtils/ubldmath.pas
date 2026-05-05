unit UBLDMath;

{$mode ObjFPC}{$H+}

interface


uses
  Classes, SysUtils, uBLDLFMFile;


const
  cFreq    = 80000000; // 80 МГц
  cTime    = 1000000;  // в микросекундах
  cTPeriod = cTime / cFreq;


type
  TTahoRec = record
    ImpData      : DWord;    // к-во импульсов в периоде между двумя отметками тахо
    BegIndex,
    EndIndex     : DWord;    // индексы прихода тахо в массиве данных
    ImpPerGradus : Double;   // ImpData / 360 - для обороти индивидуальное значение периода ибо скорость может быть неравномерна
    Validate     : Boolean;  // годный ли оборот
  end;


  TArrPeriodImpTacho = array of TTahoRec;


  TCalculated = record    // расчитанные значения
    Time     : Double;    // время в микросекундах
    Phase    : Double;    // фаза в градусах
    RelPhase : Double;    // фаза по каналам
  end;


  TArrCalculated = array of TCalculated;


  { TDFMCalculon }

  TDFMCalculon = class
  private
    fBLDFile           : TBLDFile;
    fArrPeriodImpTacho : TArrPeriodImpTacho;                              // массив количеств импульсов между отметками тахо
    fArrCalculated     : TArrCalculated;
    function GetPeriodSample : Double;
    procedure FillingArrCalculated;                                       // заполняет массив расчитанных значений - время и фазу относительно тахо
    function GetSpeed(const ACalculated : TCalculated) : Double;          // получаем скорость рад/сек
    function GetNumTurn(const ACount : DWord) : DWord;
  public
    function GetTime(const ACount1, ACount2 : DWord) : Double;            // время между отсчетами

    function SensorImpulsCount(const AName : string) : DWord; overload;   // количество импульсов от датчика по имени
    function SensorImpulsCount(const ANum : Byte) : DWord; overload;      // количество импульсов от датчика по номеру

    function GetPhase(const ACount1, ACount2 : DWord) : Double; overload; // фаза между отсчетами
    function GetPhase(const AInd : DWord) : Double; overload;             // фаза от ближайшего тахо

    function GetFullTurn : DWord;                                         // количество полных оборотов
    constructor Create(ABLDFile : TBLDFile);
    destructor Destroy; override;
    procedure GetPeriodFromTacho;                                         // заполняет массив fArrPeriodImpTacho - имп. тахо, к-во имп, следующий имп тахо, импульс на градус для текущего оборота
    procedure Calc;
    function GetRecCalc(const i : DWord) : TCalculated;
  end;



var
  DFMCalculon : TDFMCalculon;


implementation


uses
  Math, LCLType;


procedure TDFMCalculon.GetPeriodFromTacho;     // заполняет массив fArrPeriodImpTacho - имп. тахо, к-во имп, следующий имп тахо
var
  NumSensTaho : byte;  // номер канала сенсора Тахо
  i : DWord;
begin
  NumSensTaho := fBLDFile.GetNumSensTacho;
  SetLength(fArrPeriodImpTacho, 0);

  for i := 0 to High(fBLDFile.ArrDataBLD) do
    if fBLDFile.ArrDataBLD[i].Channel = NumSensTaho then  // данные с тахо
      if Length(fArrPeriodImpTacho) = 0 then // ничего еще не было
      begin
        SetLength(fArrPeriodImpTacho, 1);
        fArrPeriodImpTacho[0].BegIndex := i;
        fArrPeriodImpTacho[0].EndIndex := MAXDWORD;
        fArrPeriodImpTacho[0].ImpData  := MAXDWORD;
      end
      else
        if (Length(fArrPeriodImpTacho) = 1) and (fArrPeriodImpTacho[0].EndIndex = MAXDWORD) and (fArrPeriodImpTacho[0].ImpData = MAXDWORD) then   // первый уже есть но не заполнен
        begin
          fArrPeriodImpTacho[0].EndIndex     := i;
          fArrPeriodImpTacho[0].ImpData      := fBLDFile.ArrDataBLD[i].Data - fBLDFile.ArrDataBLD[fArrPeriodImpTacho[0].BegIndex].Data;
          fArrPeriodImpTacho[0].ImpPerGradus := fArrPeriodImpTacho[0].ImpData / 360;
        end
        else
        begin
          SetLength(fArrPeriodImpTacho, Length(fArrPeriodImpTacho) + 1);
          fArrPeriodImpTacho[High(fArrPeriodImpTacho)].BegIndex     := fArrPeriodImpTacho[High(fArrPeriodImpTacho) - 1].EndIndex; // с предыдущего конца
          fArrPeriodImpTacho[High(fArrPeriodImpTacho)].EndIndex     := i;                                                         // текущий
          fArrPeriodImpTacho[High(fArrPeriodImpTacho)].ImpData      := fBLDFile.ArrDataBLD[i].Data - fBLDFile.ArrDataBLD[fArrPeriodImpTacho[High(fArrPeriodImpTacho)].BegIndex].Data;
          fArrPeriodImpTacho[High(fArrPeriodImpTacho)].ImpPerGradus := fArrPeriodImpTacho[High(fArrPeriodImpTacho)].ImpData / 360;
        end;
end;


procedure TDFMCalculon.Calc;
begin
  GetPeriodFromTacho;        // заполняет массив fArrPeriodImpTacho - имп. тахо, к-во имп, следующий имп тахо
  FillingArrCalculated;      // заполняет массив расчитанных значений


end;


function TDFMCalculon.GetRecCalc(const i : DWord): TCalculated;
begin
  Result := fArrCalculated[i];
end;


function TDFMCalculon.GetTime(const ACount1, ACount2 : DWord): Double;  //
begin
  Result := (ACount2 - ACount1) * cTPeriod;  // GetPeriodSample;
end;


function TDFMCalculon.GetPhase(const ACount1, ACount2 : DWord) : Double;  // фаза между двумя импульсами в градусах
var
  n1, n2 : DWord;
begin
  Result := MAXDWORD;
  n1 := GetNumTurn(ACount1);
  n2 := GetNumTurn(ACount2);

  if n1 = n2 then  // импульсы в одном обороте
  begin
    Result := Abs(ACount1 - ACount2) / fArrPeriodImpTacho[n1].ImpPerGradus;
    Exit;
  end;

  if n1 > n2 then
  begin

    Exit;
  end;

  if n1 < n2 then
  begin

    Exit;
  end;

//  Result :=

//  Result := (AInd - fBLDFile.fDataBLD[fArrPeriodImpTacho[i].BegIndex].Data) / fArrPeriodImpTacho[i].ImpPerGradus;
end;


function TDFMCalculon.SensorImpulsCount(const AName: string): DWord; // количество импульсов от датчика
var
  i : DWord;
  NumSensor : byte;
begin
  Result := 0;
  NumSensor := fBLDFile.GetNumSensName(AName);
  for i := 0 to High(fBLDFile.ArrDataBLD) do
    if fBLDFile.ArrDataBLD[i].Channel = NumSensor then
      Inc(Result);
end;


function TDFMCalculon.SensorImpulsCount(const ANum: Byte): DWord;
var
  i : DWord;
begin
  Result := 0;
  for i := 0 to High(fBLDFile.ArrDataBLD) do
    if fBLDFile.ArrDataBLD[i].Channel = ANum then
      Inc(Result);
end;


function TDFMCalculon.GetPhase(const AInd : DWord): Double;  // фаза в градусах относительно тахо для конкретного индекса отсчета в массиве
var
  i : DWord;
begin
  Result := 0.0;
  for i := 0 to High(fArrPeriodImpTacho) do
    if InRange(AInd, fBLDFile.ArrDataBLD[fArrPeriodImpTacho[i].BegIndex].Data + 1, fBLDFile.ArrDataBLD[fArrPeriodImpTacho[i].EndIndex].Data - 1) then // ищем между ячейками массива со значениями тахо
    begin
      Result := (AInd - fBLDFile.ArrDataBLD[fArrPeriodImpTacho[i].BegIndex].Data) / fArrPeriodImpTacho[i].ImpPerGradus;
      Exit;
    end;
end;


function TDFMCalculon.GetFullTurn: DWord;
begin
  Result := Length(fArrPeriodImpTacho)
end;


function TDFMCalculon.GetPeriodSample : Double;    // в микросекунды
begin
  Result := cTPeriod; //fBLDFile.BLDHeader.SampleFreq);
end;


procedure TDFMCalculon.FillingArrCalculated;                                      // заполняет массив расчитанных значений - время и фазу относительно тахо
var
  i, j : DWord;
begin
  SetLength(fArrCalculated, Length(fBLDFile.ArrDataBLD));
  for i := 0 to High(fBLDFile.ArrDataBLD) do
  begin
    fArrCalculated[i].Time := GetTime(0, fBLDFile.ArrDataBLD[i].Data);              // время прихода импульса
    if fBLDFile.ArrDataBLD[i].Channel = 0 then                                      // костыль!!! в некоторых файлах фаза тахо не зануляется
      fArrCalculated[i].Phase := 0
    else
    begin
      fArrCalculated[i].Phase := DFMCalculon.GetPhase(fBLDFile.ArrDataBLD[i].Data); // фаза относительно тахо
      if i > 2 then
        for j := i - 1 downto 0 do
        begin
          fArrCalculated[i].RelPhase := 0;
          if fBLDFile.ArrDataBLD[j].Channel = fBLDFile.ArrDataBLD[i].Channel then     // нашли более раннюю отметку канала
          begin
            if fArrCalculated[i].Phase > fArrCalculated[j].Phase then
              fArrCalculated[i].RelPhase := fArrCalculated[i].Phase - fArrCalculated[j].Phase
            else
              fArrCalculated[i].RelPhase := (360 - fArrCalculated[j].Phase) + fArrCalculated[i].Phase;
            Break;
          end;
        end;
    end;
  end;
end;


function TDFMCalculon.GetSpeed(const ACalculated: TCalculated): Double;  //  скорость оборота
begin
  Result := 360 / ACalculated.Time
end;


function TDFMCalculon.GetNumTurn(const ACount : DWord): DWord; // номер оборота которому принадлежит отсчет
var
  i : DWord;
begin
  Result := MAXDWORD;
  for i := 0 to High(fArrPeriodImpTacho) do
    if InRange(ACount, fBLDFile.ArrDataBLD[fArrPeriodImpTacho[i].BegIndex].Data, fBLDFile.ArrDataBLD[fArrPeriodImpTacho[i].EndIndex].Data - 1) then // включая первый тахо
      Exit(i);
end;


constructor TDFMCalculon.Create(ABLDFile : TBLDFile);
begin
  inherited Create;

  fBLDFile := ABLDFile;
end;


destructor TDFMCalculon.Destroy;
begin
  SetLength(fArrPeriodImpTacho, 0);
  SetLength(fArrCalculated, 0);

  inherited Destroy;
end;


end.
