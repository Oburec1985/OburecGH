unit uLogThread;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TLogPriority = (lpDebug, lpInfo, lpWarning, lpError, lpCritical);      // Приоритеты сообщений


const
  LogPriorityStrings : array [TLogPriority] of string = ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL');


type
  TQueueLog = class;      // упреждающее объявление


  TLogThread = class(TThread)
  private
    fCapacity     : Byte;                              // размер массива строк
    fCount        : Byte;                              // счетчик сообщений в массиве строк
    fOwner        : TQueueLog;                         // владелец
    fArrLogString : array of ShortString;              // хранилище
    procedure WriteLnLog;
  protected
    procedure Execute; override;
  public
    procedure SetLogString(const ALogString : ShortString);
    constructor Create(const ACapacity : byte);
    destructor Destroy; override;
    property Owner : TQueueLog write fOwner;
  end;


  TQueueLog = class(TObject)                        // класс содержит массив с трэдами
  private
    fMaxQuantity  : Word;                           // максимальное к-во строк в лог-файле
    fCount        : Word;                           // счетчик строк
    fCountFile    : Word;                           // счетчик файлов
    fFlag         : Boolean;                        // признак занято // заменить на приоритеты!!!
    fBaseFileName : ShortString;                    // основа для имени файла, которое дополняется номерами
    fFileName     : ShortString;
    fArrLogThread : array [TLogPriority] of TLogThread;
    procedure FileSizeControl;
    function GetDateTimeFName : ShortString;        // возвр дату время для имени файла
  protected
    property FileName : ShortString read fFileName;
    property Flag     : Boolean     read fFlag write fFlag;
  public
    constructor Create(const AFileName : ShortString);
    destructor Destroy; override;
    property MaxQuantity : Word write fMaxQuantity;          // максимальное к-во строк в лог-файле
    procedure LogDebug(const Msg : Shortstring);
    procedure LogInfo(const Msg : Shortstring);
    procedure LogWarning(const Msg : Shortstring);
    procedure LogError(const Msg : Shortstring);
    procedure LogCritical(const Msg : Shortstring);
  end;


implementation

uses
  LCLProc, LazFileUtils;

    //////////////////////// TLogThread /////////////////////////

procedure TLogThread.Execute;
begin
  while (not Terminated) do
    if fCount > 0 then                        // массив с логами не пустой
      if not (fOwner as TQueueLog).Flag then  // очередь свободна
      begin
        (fOwner as TQueueLog).Flag := True;
        Synchronize(@WriteLnLog);
        (fOwner as TQueueLog).Flag := False;
        fCount := 0;                          // сбросили счетчик
      end;
end;


constructor TLogThread.Create(const ACapacity : byte);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  fCapacity       := ACapacity;
  fCount          := 0;
  SetLength(fArrLogString, ACapacity);

end;


destructor TLogThread.Destroy;
begin
  Terminate;
  SetLength(fArrLogString, 0);
  Self := nil
end;


procedure TLogThread.SetLogString(const ALogString : ShortString);
var
  Today : TDateTime;
begin
  Inc(fCount);
  if fCount > fCapacity then
  begin               // здесь реакцию на переполнение

  end
  else
  begin
    Today := Now;
    fArrLogString[fCount] := DateToStr(Today) + ' ' + TimeToStr(Today) + ' ' + ALogString + '; ' + #13 + #10;
  end;
end;


procedure TLogThread.WriteLnLog;
var
  i  : Byte;
  fs : TFileStream;
begin
  if FileExistsUTF8((fOwner as TQueueLog).FileName) then
    fs := TFileStream.Create((fOwner as TQueueLog).FileName, fmOpenWrite or fmShareDenyNone)
  else
    fs := TFileStream.Create((fOwner as TQueueLog).FileName, fmCreate);
  fs.Position := fs.Size;
  for i := 0 to fCount do                                // всё накопленное в файл
    fs.Write(fArrLogString[i][1], Length(fArrLogString[i]));
  fs.Free;
end;

      ////////////////// TQueueLog ////////////////////////

constructor TQueueLog.Create(const AFileName : ShortString);
var
  i : TLogPriority;
begin
  inherited Create;
  fCount        := 0;                  // счетчик строк в файле
  fCountFile    := 0;
  fBaseFileName := AFileName;
  fFileName     := IntToStr(fCountFile) + '_' + GetDateTimeFName + fBaseFileName;
  for i := Low(TLogPriority) to High(TLogPriority) do
  begin
    fArrLogThread[i] := TLogThread.Create(20);
    fArrLogThread[i].Owner := Self;    // владелец
    if Assigned(fArrLogThread[i].FatalException) then
      raise fArrLogThread[i].FatalException;
    fArrLogThread[i].Start;
  end;
end;


destructor TQueueLog.Destroy;
var
  i : TLogPriority;
begin
  for i := Low(TLogPriority) to High(TLogPriority) do
    FreeAndNil(fArrLogThread[i]);

  inherited Destroy;
end;


procedure TQueueLog.FileSizeControl;
var
  Today : TDateTime;
begin
  Inc(fCount);
  if fCount >= fMaxQuantity then
  begin
    Inc(fCountFile);
    fCount    := 0;
    Today     := Now;
    fFileName := IntToStr(fCountFile) + '_' + GetDateTimeFName + fBaseFileName;
  end;
end;


function TQueueLog.GetDateTimeFName : ShortString; // возвр дату время для имени файла
var
  Today : TDateTime;
  Hour, Minute, Second, MilliSecond : word;
  Year, Month, Day : word;
begin
  Result := '';
  Today := Now;
  DecodeTime(Today, Hour, Minute, Second, MilliSecond);
  DecodeDate(Today, Year, Month, Day);
  Result := IntToStr(Year) + '_' + IntToStr(Month) + '_' + IntToStr(Day) + '_' + IntToStr(Hour)  + '_' + IntToStr(Minute) + '_' + IntToStr(Second) + '_';
end;


procedure TQueueLog.LogDebug(const Msg : Shortstring);
begin
  fArrLogThread[lpDebug].SetLogString(LogPriorityStrings[lpDebug] + ' ' + Msg);
  FileSizeControl;
end;


procedure TQueueLog.LogInfo(const Msg : Shortstring);
begin
  fArrLogThread[lpInfo].SetLogString(LogPriorityStrings[lpInfo] + ' ' + Msg);
  FileSizeControl;
end;


procedure TQueueLog.LogWarning(const Msg : Shortstring);
begin
  fArrLogThread[lpWarning].SetLogString(LogPriorityStrings[lpWarning] + ' ' + Msg);
  FileSizeControl;
end;


procedure TQueueLog.LogError(const Msg : Shortstring);
begin
  fArrLogThread[lpError].SetLogString(LogPriorityStrings[lpError] + ' ' + Msg);
  FileSizeControl;
end;


procedure TQueueLog.LogCritical(const Msg : Shortstring);
begin
  fArrLogThread[lpCritical].SetLogString(LogPriorityStrings[lpCritical] + ' ' + Msg);
  FileSizeControl;
end;

end.

