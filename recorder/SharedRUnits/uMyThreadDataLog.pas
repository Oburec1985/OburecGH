unit uMyThreadDataLog;

interface

uses
  Windows, SysUtils, Classes, ActiveX, SyncObjs, Variants, ComCtrls, shellapi,
  Dialogs, Math,

  uMyRecorderUtils, uMyDataAndConvert, uMyFileUtils,

  PluginClass, recorder, tags, propaccess, blaccess;

  type
  TMyWriteTimeTagsThread = class(Tthread)
    private{ private declarations }
    public
      // info
      Started : Boolean; // Поток уже запустился
      // управление
      ThreadWork : Boolean;      // разрешение на начало работы
      ThreadPause : Boolean;     // приостановить работу
      DelayWork : Integer;       // дискретность записи (ms)
      SavePath : string;         // путь для записи
      TagsArray : DynTagsArray;  // массив тегов для лога
      Header : string;           // шапка лога
      HeaderEnable : boolean;    // использовать шапку
      TagsNameEnable : boolean;  // использовать имена тегов
    protected
      procedure Execute; override; // Главная процедура потока;
    end;

implementation

procedure TMyWriteTimeTagsThread.Execute;
var
  ThreadFirstRun : Boolean;
  Timer_HourBegin, Timer_LastAdd, Timer_Diff, Timer_Step : TDateTime;
  Local_FormatSettings : TFormatSettings;
  steps, i : Integer;
  Stemp : string;
  Dtemp : Extended; //Double;
begin
  ThreadFirstRun  := True; // первый старт
  Timer_HourBegin := 0;
  Timer_LastAdd   := 0;

  While not Terminated do //Пока поток не остановлен;
    begin
      if not Started then ThreadFirstRun := True; // первый старт
      Started := True; // поток начал работу

      if (Not ThreadWork) or (ThreadPause) then
        begin
          if Not ThreadWork then ThreadFirstRun := True; // начинаем работу с самого начала

          Sleep(100);
        end
      else
        begin
          if ThreadFirstRun then
            begin
              CheckCreateSavePath(SavePath);

              if HeaderEnable then SaveStringToFile(SavePath, Header);

              if TagsNameEnable then
                begin
                  Stemp := ';'; // первая ячейка пустая, время

                  for i := 0 to Length(TagsArray) - 1 do
                    begin
                      if TagsArray[i] = nil then
                        begin
                          Stemp := Stemp + 'нет тега;';
                          Continue;
                        end;

                      try
                        Stemp := Stemp + String(TagsArray[i].GetName) + ';';
                      except
                        Stemp := Stemp + 'ошибка имени;';
                      end;
                    end;

                  SaveStringToFile(SavePath, Stemp);
                end;

              ThreadFirstRun := false;

              GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, Local_FormatSettings);
              Timer_HourBegin := StrToDateTime( FormatDateTime('dd.mm.yyyy hh', Now, Local_FormatSettings) ); // время с округлением до часа
              Timer_LastAdd   := 0;//Now;
            end;

          Timer_Step := DelayWork * MsSecondTime;
          Timer_Diff := Now - Timer_HourBegin;     // прошло времени от начального часа
          steps := Floor(Timer_Diff / Timer_Step); // число срезов от начального часа

          if Timer_LastAdd <= (Timer_HourBegin + steps*Timer_Step) then
            begin
              Timer_LastAdd := Now;

              Stemp := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now, Local_FormatSettings) + ';';

              for i := 0 to Length(TagsArray) - 1 do
                begin
                  if TagsArray[i] = nil then
                    begin
                      Stemp := Stemp + 'нет тега;';
                      Continue;
                    end;

                  try
                    Dtemp := TagsArray[i].GetEstimate(ESTIMATOR_MEAN);
                    Stemp := Stemp + DoubleToString(Dtemp, 15, 6) + ';';
                  except
                    Stemp := Stemp + 'ошибка чтения;';
                  end;
                end;

              SaveStringToFile(SavePath, Stemp);
            end;

          if DelayWork > 1000 then // интервал больше 1 секунды - спать 1 секунду
            Sleep(1000)
          else // интервал меньше 1 секунды - спать десятую часть интервала
            Sleep(DelayWork div 10);
        end;
    end;

  Free;
end;

end.
