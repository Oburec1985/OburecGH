unit ResStr;

{$mode ObjFPC}{$H+}{$codepage UTF8}

interface

uses
  Classes, SysUtils;

resourcestring
  rsConfNotFound = 'Файл конфигурации не найден! '
    +'Возможно требуется выполнить '
    +'сохранение в ПО Recorder';
  rsRxMsg = 'Время Recorder: %f; Шина: %s, Устройство: %s, '
    +'Ответ: %s';
  rsTxMsg = 'Время Recorder: %f; Шина: %s, Устройство: %s, '
    +'Запрос: %s';
  rsBus = ' Шина: ';
  rsVers = '. Версия: %s';
  rsMakePauseDelay = 'Задайте значение паузы между '
    +'опросами одного устройства!';
  rsEmptyAdress = 'Поле адреса не должно быть '
    +'пустым!';
  rsTriesNumber = 'Поле числа попыток не должно '
    +'быть пустым!';
  rsEmptyTimer = 'Поле таймера ожидания ответа не '
    +'должно быть пустым!';
  rsDisableDevice = 'Выключить устройство';
  rsEnableDevice = 'Включить устройство';
  rsDisableBus = 'Выключить шину';
  rsEnableBus = 'Включить шину';
  rsSelectBus = 'Выберите шину для добавления '
    +'устройства';
  rsSelectDevice = 'Выберите устройство для '
    +'добавления тэга';
  rsBigEndian = 'Старшим байтом вперед';
  rsGrandWord = 'Старшим словом вперед';
  rsGrandDoubleWord = 'Старшим двойным словом вперед';
  rsReverse = 'Обратный порядок байт';
  rsNoCorrection = 'Без корректировки';
  rsSystem = 'Система';

  rsPlgName = 'Плагин Modbus Master';
  rsPlgDescr = 'Реализация протокола Modbus Master (RTU и TCP)';
  rsVendor = 'Скрипник Александр';

implementation

end.

