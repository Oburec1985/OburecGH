// Модуль для чтения и записи файлов форматов BLD и LFM для дискретно-фазового
// метода.

unit uBLDLFMFile;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;


type
  TTypeSensor = (srRoot,     srPeak,     srInEdge, srOutEdge, srTacho,        // типы датчиков
                 srRoot_cap, srPeak_cap, srUTS,    srIRIG_B,  srGasTurbine);


   TBLDSensor = packed record
     Chan       : Word;
     Amplifier  : byte;         // Усиление МФПИ
                                // при чтении здесь бит определяющий длину имени канала!!!
     ChanName   : ANSIString;   // Имя канала    // (формат уточняется)
     ChanType   : Word;         // Тип датчика
   end;


  TBLDHeader = record
    SignRec    : array [0 .. 5] of ANSIChar; // сигнатура  cBLDSign = 'RecBld';
    HeaderSize : LongWord;                   // размер заголовка
                                             // Pasport — 4 байта у Олега Борисовича (формат уточняется)
    TypeCard   : Word;                       // тип карты   Cодержит тип платы 2070 или 2081.
    ChanAmount : Word;                       // кол-во записывемых каналов.
    ArrSensors : array of TBLDSensor;        // Массив структур описывающих датчики
    TestDate   : TDateTime;                  // дата испытания
    SampleFreq : Word;                       // частота дискретизации
    SignDATA   : array [0 .. 3] of ANSIChar; // сигнатура cBLDData = 'DATA'
  end;


  TDataBLD = packed record
    Channel : byte;
    Marker  : byte;
    Data    : DWord;  // собственно данные
  end;


  TArrDataBLD = array of TDataBLD;


  { TRWDFMFile }


  TRWDFMFile = class    // класс предок общий абстрактный для файлов дискретно-фазового метода
  private
    fFStream  : TFileStream;
    fFileName : ShortString;
  public
    constructor Create;
    constructor CreateWrite(const AFileName : ShortString);
    constructor CreateLoad(const AFileName : ShortString);
    destructor Destroy; override;
    property FileName : ShortString read fFileName write fFileName;
    property FStream  : TFileStream read fFStream write fFStream;
  end;


  { TBLDFile }


  TBLDFile = class(TRWDFMFile)            // собственно чтение-запись BLD файла
  private
    fBLDHeader    : TBLDHeader;
    fArrDataBLD   : TArrDataBLD;   //array of TDataBLD;
    procedure LoadHeader(AFs : TFileStream);
    procedure LoadData(AFs   : TFileStream);
    procedure SaveHeader(AFs : TFileStream);
    procedure SaveData(AFs   : TFileStream);
    function GetSizeSensors(const ABLDSensor : TBLDSensor) : LongWord;
    function GetSizeHeader   : LongWord;      // размер хеадера
    procedure ClearHeader;
    procedure ClearData;

  public
  //  fBLDHeader : TBLDHeader;           //
 //   fDataBLD   : array of TDataBLD;    //
    destructor Destroy; override;
    procedure Load(AFs : TFileStream); overload;
    procedure Load; overload;
    procedure Save(AFs : TFileStream); overload;
    procedure Save; overload;
    property BLDHeader : TBLDHeader read fBLDHeader write fBLDHeader;
    function GetNumSensTacho : ShortInt;                         // возвращает номер датчика тахо
    function GetNumSensName(const AName : String) : ShortInt;   // возвращает номер датчика по имени
    function GetNameSensNum(const ANum : Byte) : String;        // имя датчика по номеру канала
    procedure SortDataBLD;                                      // сортировка массива
  //  property DataBLD   : array of TDataBLD;
 //   property BLDHeader : TBLDHeader read fBLDHeader;
    property ArrDataBLD : TArrDataBLD read fArrDataBLD;
  end;


  TLFMHeader = record
    Signature  : ShortString;       // сигнатура cLFMSign = '@dfm';
    LastFile   : ShortString;       //ANSIString         // последний считываемы файл
  end;


  TLFMSensor = record
    Name    : string;
    Chun    : byte;
    ObjType : byte;
  end;


  TLFMPair = record
    Name           : string;
    Root           : SmallInt;
    Peak           : SmallInt;
    SkipBlades     : SmallInt;
    Base           : Single;
    Tahoshift      : Single;

    BladesPointers : array of integer;
    Impuls         : array of integer;

    Checked        : Boolean;
    Fi             : Single;
  end;


  cLFMStage = record
    Name               : string;
    StageType          : byte;
    Diametr            : single;
    Resonanse          : single;
    BladeNumber        : byte;
    PairsCount         : byte;
    OrderBlade         : boolean;
    kfSigma            : single;
    CountHarm          : shortint;
    OrderHarm          : array of integer;
    F1                 : single;
    LimStressResonance : single;
    LimStressStill     : single;
    Bin                : single;
    Bout               : single;
    Pairlist           : tstringlist;
    TahoComb           : shortint;
  end;


  { TLFMFile }


  TLFMFile = class(TRWDFMFile)
  private
    fLFMHeader : TLFMHeader;
    fLFMSensor : array of TLFMSensor;
  //  fLFMStage  : array of TLFMStage;
    procedure LoadHeader(AFs : TFileStream);
//    procedure LoadData(AFs   : TFileStream);
    procedure SaveHeader(AFs : TFileStream);
//    procedure SaveData(AFs   : TFileStream);
  public
    procedure Load(AFs : TFileStream); overload;
    procedure Load; overload;
    procedure Save(AFs : TFileStream); overload;
    procedure Save; overload;
    destructor Destroy; override;
  end;


var
  BLDFile : TBLDFile;


implementation


const
  cBLDSign : array[0 .. 5] of AnsiChar = ('R', 'e', 'c', 'B', 'l', 'd'); // сигнатура для BLD файла
  cBLDData : array[0 .. 3] of AnsiChar = ('D', 'A', 'T', 'A');           // сигнатура для данных в BLD

  cLFMSign : array[0 .. 3] of AnsiChar = ('@', 'd', 'f', 'm');           // сигнатура для LFM файла


{ TRWDFMFile }


constructor TRWDFMFile.Create;
begin
  inherited Create;

end;

constructor TRWDFMFile.CreateWrite(const AFileName: ShortString);
begin
  Create;

  fFStream := TFileStream.Create(AFileName, fmCreate or fmOpenWrite);
end;


constructor TRWDFMFile.CreateLoad(const AFileName: ShortString);
begin
  Create;

  fFStream := TFileStream.Create(AFileName, fmOpenRead);
end;


destructor TRWDFMFile.Destroy;
begin

  FreeAndNil(fFStream);
  inherited Destroy;
end;


{ TBLDFile }


procedure TBLDFile.LoadHeader(AFs : TFileStream);                 // загрузка заголовка

  procedure ReadBLDSensor(var BLDSensor : TBLDSensor);            // читаем сенсор
  var
    NameLen, i : byte;
    Ch : ANSIChar;
  begin
    AFs.ReadBuffer(BLDSensor.Chan,      SizeOf(TBLDSensor.Chan));
    AFs.ReadBuffer(BLDSensor.Amplifier, SizeOf(TBLDSensor.Amplifier));
    AFs.ReadBuffer(NameLen,             SizeOf(Byte));            // читаем длину строки с именем
    BLDSensor.ChanName := '';
    for i := 1 to NameLen do
    begin
      AFs.ReadBuffer(Ch, SizeOf(ANSIChar));
      BLDSensor.ChanName := BLDSensor.ChanName + Ch;
    end;
    AFs.ReadBuffer(BLDSensor.ChanType,  SizeOf(TBLDSensor.ChanType));
  end;

var
  i : Integer;
  OffSet  :  Int64;
begin
  ClearHeader;
  AFs.ReadBuffer(fBLDHeader.SignRec,    SizeOf(TBLDHeader.SignRec));
  AFs.ReadBuffer(fBLDHeader.HeaderSize, SizeOf(TBLDHeader.HeaderSize));
  AFs.ReadBuffer(fBLDHeader.TypeCard,   SizeOf(TBLDHeader.TypeCard));      // 2070 or 2081
  AFs.ReadBuffer(fBLDHeader.ChanAmount, SizeOf(TBLDHeader.ChanAmount));

  SetLength(fBLDHeader.ArrSensors, fBLDHeader.ChanAmount);
  for i := 0 to fBLDHeader.ChanAmount - 1 do
    ReadBLDSensor(fBLDHeader.ArrSensors[i]);

  AFs.ReadBuffer(fBLDHeader.TestDate,   SizeOf(TBLDHeader.TestDate));
  AFs.ReadBuffer(fBLDHeader.SampleFreq, SizeOf(TBLDHeader.SampleFreq));
  AFs.Position := AFs.Position + (AFs.Position + 4) mod 6;                 // промотали ffff до кратного 6 значения с учетом длины DATA
  AFs.ReadBuffer(fBLDHeader.SignDATA,  SizeOf(TBLDHeader.SignDATA));

  OffSet := 6;
  if not CompareMem(@fBLDHeader.SignDATA, @cBLDDATA, SizeOf(TBLDHeader.SignDATA)) then  // в некоторых файлах не совпадает длина заголовка +/- - ищем DATA
    repeat
      Inc(OffSet);
      AFs.Position := OffSet;
      AFs.ReadBuffer(fBLDHeader.SignDATA, SizeOf(TBLDHeader.SignDATA));
    until CompareMem(@fBLDHeader.SignDATA, @cBLDData, SizeOf(TBLDHeader.SignDATA)) or (OffSet > AFs.Size - fBLDHeader.HeaderSize);
end;


procedure TBLDFile.LoadData(AFs : TFileStream);                // загрузка данных
var
  i : LongWord;
begin
  ClearData;
  SetLength(fArrDataBLD, (AFs.Size - AFs.Position) div SizeOf(TDataBLD));
  //if (AFs.Size - AFs.Position) mod SizeOf(TDataBLD) <> 0 then begin end;  // ошибка соотношения длины ф-ла и размера записи
  for i := 0 to High(fArrDataBLD) do
    AFs.ReadBuffer(fArrDataBLD[i], SizeOf(TDataBLD));
end;


procedure TBLDFile.SaveHeader(AFs : TFileStream);             // запись заголовка

  procedure SaveSensor(const Sensor : TBLDSensor);
  var
    NameLen, i : byte;
  begin
    AFs.WriteBuffer(Sensor.Chan,      SizeOf(TBLDSensor.Chan));
    AFs.WriteBuffer(Sensor.Amplifier, SizeOf(TBLDSensor.Amplifier));
    NameLen := Length(Sensor.ChanName);
    AFs.WriteBuffer(NameLen,          SizeOf(Byte));            // пишем длину строки с именем
    for i := 1 to NameLen do
      AFs.WriteBuffer(Sensor.ChanName[i], SizeOf(ANSIChar));
    AFs.WriteBuffer(Sensor.ChanType,  SizeOf(TBLDSensor.ChanType));
  end;

var
  i : Integer;
  ChF : ANSIChar;
begin
  fBLDHeader.HeaderSize := GetSizeHeader;
  AFs.WriteBuffer(cBLDSign, SizeOf(cBLDSign));
  AFs.WriteBuffer(fBLDHeader.HeaderSize, SizeOf(TBLDHeader.HeaderSize));
  AFs.WriteBuffer(fBLDHeader.TypeCard,   SizeOf(TBLDHeader.TypeCard));
  AFs.WriteBuffer(fBLDHeader.ChanAmount, SizeOf(TBLDHeader.ChanAmount));

  for i := 0 to High(fBLDHeader.ArrSensors) do
    SaveSensor(fBLDHeader.ArrSensors[i]);

  AFs.WriteBuffer(fBLDHeader.TestDate,   SizeOf(TBLDHeader.TestDate));
  AFs.WriteBuffer(fBLDHeader.SampleFreq, SizeOf(TBLDHeader.SampleFreq));
  ChF := 'f';
  for i := 1 to ((fBLDHeader.HeaderSize + 4) mod 6) do
    AFs.WriteBuffer(ChF, SizeOf(ANSIChar));
  AFs.WriteBuffer(cBLDData, SizeOf(cBLDData));
end;


procedure TBLDFile.SaveData(AFs : TFileStream);
var
  i : Integer;
begin
  for i := 0 to High(fArrDataBLD) do
    AFs.WriteBuffer(fArrDataBLD[i], SizeOf(TDataBLD));
end;


function TBLDFile.GetSizeSensors(const ABLDSensor : TBLDSensor) : LongWord;
begin
  Result := SizeOf(TBLDSensor.Chan) + SizeOf(TBLDSensor.Amplifier) + SizeOf(TBLDSensor.ChanType) +
            SizeOf(Byte) +            // размер имени - в структуру не входит, но в файл пишется
            Length(ABLDSensor.ChanName);
end;


function TBLDFile.GetSizeHeader: LongWord;   // размер хеадера
var
  i : byte;
begin
  Result := SizeOf(TBLDHeader.SignRec)  + SizeOf(TBLDHeader.HeaderSize) +
            SizeOf(TBLDHeader.TypeCard) + SizeOf(TBLDHeader.ChanAmount) +
            SizeOf(TBLDHeader.TestDate) + SizeOf(TBLDHeader.SampleFreq);
  for i := 0 to High(fBLDHeader.ArrSensors) do
    Result := Result + GetSizeSensors(fBLDHeader.ArrSensors[i])
end;


procedure TBLDFile.ClearHeader;
begin
  fBLDHeader.SignRec := '';
  SetLength(fBLDHeader.ArrSensors, 0);
  FillChar(fBLDHeader, SizeOf(TBLDHeader), 0);
end;


procedure TBLDFile.ClearData;
begin
  SetLength(fArrDataBLD, 0);
end;


procedure TBLDFile.Load(AFs : TFileStream);
begin
  LoadHeader(AFs);
  LoadData(AFs);
end;


procedure TBLDFile.Save(AFs : TFileStream);
begin
  SaveHeader(AFs);
  SaveData(AFs);
end;


procedure TBLDFile.Load;
begin
  Load(fFStream);
end;


procedure TBLDFile.Save;
begin
  Save(fFStream);
end;


function TBLDFile.GetNumSensTacho : ShortInt;  // возвращает номер датчика тахо
var
  i : Byte;
begin
  Result := -1;
  for i := 0 to High(fBLDHeader.ArrSensors) do
    if fBLDHeader.ArrSensors[i].ChanType = Ord(srTacho) then
      Exit(i);
end;


function TBLDFile.GetNumSensName(const AName: String): ShortInt;  // возвращает номер датчика по имени
var
  i : Byte;
begin
  Result := -1;
  for i := 0 to High(fBLDHeader.ArrSensors) do
    if fBLDHeader.ArrSensors[i].ChanName = AName then
      Exit(i);
end;


function TBLDFile.GetNameSensNum(const ANum : Byte) : String;  // имя датчика по номеру канала
begin
  Result := '';
  Result := fBLDHeader.ArrSensors[ANum].ChanName;
end;


procedure TBLDFile.SortDataBLD;

  procedure QuickSort(var ADataBLD : array of TDataBLD; const min, max : Integer);
  var
    i, j : Integer;
    Mid, Tmp : TDataBLD;
  begin
    if min < max then
    begin
      mid := ADataBLD[min];
      i := min - 1;
      j := max + 1;
      while i < j do
      begin
        repeat
          Inc(i);
        until ADataBLD[i].Data >= mid.Data;
        repeat
          Dec(j);
        until ADataBLD[j].Data <= mid.Data;
        if i < j then
        begin
          tmp         := ADataBLD[i];
          ADataBLD[i] := ADataBLD[j];
          ADataBLD[j] := tmp;
        end;
      end;
      QuickSort(ADataBLD, min,   j);
      QuickSort(ADataBLD, j + 1, max);
    end;
  end;

begin
  QuickSort(fArrDataBLD, 0, High(fArrDataBLD));
end;


destructor TBLDFile.Destroy;
begin
  ClearHeader;
  SetLength(fArrDataBLD, 0);

  inherited Destroy;
end;


{ TLFMFile }


procedure TLFMFile.LoadHeader(AFs: TFileStream);
begin
  AFs.ReadBuffer(fLFMHeader.Signature, SizeOf(TLFMHeader.Signature));
  AFs.ReadBuffer(fLFMHeader.LastFile,  SizeOf(TLFMHeader.LastFile));
end;


procedure TLFMFile.SaveHeader(AFs: TFileStream);
begin
  AFs.WriteBuffer(fLFMHeader.Signature, SizeOf(TLFMHeader.Signature));
  AFs.WriteBuffer(fLFMHeader.LastFile,  SizeOf(TLFMHeader.LastFile));
end;


procedure TLFMFile.Load(AFs: TFileStream);
begin
  LoadHeader(AFs);

end;


procedure TLFMFile.Save(AFs: TFileStream);
begin
  SaveHeader(AFs);

end;


procedure TLFMFile.Load;
begin
  Load(fFStream);

end;


procedure TLFMFile.Save;
begin
  Save(fFStream);

end;


destructor TLFMFile.Destroy;
begin
  SetLength(fLFMSensor, 0);
//  SetLength(fLFMStage, 0);

  inherited Destroy;
end;


initialization
  BLDFile := TBLDFile.Create;


finalization
  FreeAndNil(BLDFile)

end.
