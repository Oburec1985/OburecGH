unit uRecorderPxiMx248SettingsService;

{
  Назначение: UI-neutral граница применения черновика настроек PXI MX-248.
  Диалог передаёт сюда стабильный SourceId, положение модуля и один полностью
  проверенный строковый пакет. Реализация сервиса принадлежит composition/runtime
  слою и решает, сохранить конфигурацию offline или применить её к live source.

  Контракт: диалог не знает transport, datasource и lifecycle. ApplyDraft не
  вызывается до успешного CalcProperties. Сервис не владеет диалогом и не должен
  вызывать его повторно. Архитектура: Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderDriverContractsV2, uRecorderPxiMx248Types;

type
  IPxiMx248SettingsService = interface
    ['{96BD307E-6DD9-4E07-A214-8D457CCADDC2}']
    function ApplyDraft(const ASourceId: string; AChassis, ASlot: Integer;
      const AProperties: string): TRecorderOperationResult;
    function Discover(out ADevices: TPxiMx248DiscoveredDevices):
      TRecorderOperationResult;
  end;

implementation

end.
