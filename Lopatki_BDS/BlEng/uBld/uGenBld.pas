unit uGenBld;

interface
 uses
   Messages,classes,SysUtils,Windows,inifiles,math,comctrls;

 Type
  // структура хранит информацию об измерительном канале
  sBldSensor = record
    mChanNumber: short;      // Номер канала
    mAmplifier: byte;        // Усиление МФПИ
    mChanName: string;        // Номер канала
    mChanType: short;        // Тип датчика
  end;

  // структура содержит информацию для заполнения заголовка Bld файла
  sBldTitle = record
    mTitle:string;               // Cодержит заголовок - строку "RecBld" для bld.
    mCardType:short;             // Cодержит тип платы 2070 или 2081.
    mChanNumber:short;           // Число записывемых каналов.
    mSensors:array of sBldSensor;// Массив структур описывающих датчики
    mTestDate:TDateTime;         // Дата испытания
    mSamplingFreq:short;         // Частота дискритизации
    mEmpty:array of char;        // Дополнение до 6байт символами ff
    mData:array of byte;         // Данные
  end;

  // Клас для чтения/ записи Bld файла
  cBldFile = class
    mBldTitle:sBldtitle; // Заголовочная информация bld файла
    f:File;
  private
    // При создании с переменной f ассоциируется файл
    constructor Create(filename:string);
    // Сохранение заполненых полей экземпляра класса в Bld файл
    procedure Save;
    // Загрузка Bld файла в поля класса
    function Load:boolean;
  end;

implementation
constructor cBldFile.Create(filename:string);
begin
  AssignFile(F,FileName);
end;

procedure cBldFile.Save;
begin
  // Проверка, что файл существует
  if Assigned(@f) then
  begin

  end;
end;

function cBldFile.Load:boolean;
  var lReaded,i:cardinal; // Число реально считанных байт.
  // вспомогательная процедура для чтения инф-ии канала
  procedure readSensor(var sensor:sBldSensor);
  var
    Ch:char;
    iReaded:cardinal;
    bEndName:boolean;
  begin
    bEndName:=false;
    BlockRead(f,sensor.mChanNumber,2,iReaded);
    BlockRead(f,sensor.mAmplifier,2,iReaded);
    while not bEndName do
    begin
      BlockRead(f,Ch,1,iReaded);
      if Ch<>#0 then bEndName:=true
      else sensor.mChanName:=sensor.mChanName+Ch;
    end;
    BlockRead(f,sensor.mChanType,2,iReaded);
  end;
begin
  // Проверка, что файл существует
  if Assigned(@f) then
  begin
  // считать строку заголовка(6),тип платы(2) и число датчиков(2)
    BlockRead(f,mBldTitle,10,lReaded);if mBldTitle.mTitle<>'RecBld' then exit;
    SetLength(mBldTitle.mSensors,mBldTitle.mChanNumber);
    for i:=0 to mBldTitle.mChanNumber-1 do readSensor(mBldTitle.mSensors[i]);
    BlockRead(f,mBldTitle.mTestDate,4,lReaded);
    BlockRead(f,mBldTitle.mSamplingFreq,2,lReaded);
  end;
end;

end.
