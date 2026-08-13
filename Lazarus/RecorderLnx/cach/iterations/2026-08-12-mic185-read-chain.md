# MIC-185: цепочка чтения RecorderLnx и оригинального Recorder

## Запрос

Разложить `Read` по функциям после остановки сбора примерно через 1:20 и сравнить реализацию с оригинальным Recorder.

## RecorderLnx

1. `TRecorderDataSourceThread.Execute` вызывает `fSource.Tick` с периодом источника.
2. `TRecorderMic185DataSource.DoTick` вызывает `fDevice.ReadBlock`.
3. `TRecorderMic185Device.ReadBlock` вызывает `TRecorderMebiusTcpClient.ReadMeasDataBlock` и переводит разобранные массивы в `TRecorderAcquisitionBlock`.
4. `ReadMeasDataBlock` вычитывает все доступные MEBE-пакеты через `ReadPacket(..., False)`, разделяет измерения, температуры и UTS.
5. `ReadPacket` сначала вызывает `TryTakePacket`, затем при необходимости `ReadAvailable`.
6. `TryTakePacket` проверяет сигнатуру, CRC и размер; неполный пакет сохраняет; при неверном заголовке сдвигается на один байт.
7. `ReadAvailable(False)` проверяет сокет через `SocketHasData`, затем одним `Read` добавляет доступный TCP-фрагмент в хвост накопителя.

## Оригинальный Recorder

1. Выделенный `CHostThreadRx::Run` непрерывно вызывает `CTCPLink::OnRead`.
2. `CTCPLink::OnRead` делает блокирующий `recv` непосредственно в память, выделенную `CPacketCollector::Alloc`.
3. `CPacketCollector::AcceptBlock` подтверждает фактический размер фрагмента и циклически вызывает `Select`.
4. `CPacketCollector::Select` сохраняет неполный пакет, проверяет сигнатуру/CRC/размер и при ошибке сдвигается на один байт.
5. `CPacketDispatcher::Dispatch` направляет измерительные пакеты в `CTCPLink::OnReadData`.
6. `CMIC185V2::OnReadData` принимает только UTS, измерительные и температурные пакеты; `Put` вызывает `m_scanInput->Decommutate`.

## Наблюдение по последнему журналу

Перед остановкой счётчики байтов, пакетов и блоков росли, `buffered=0`, `syncdrop=0`, `lost=False`. Затем по разным адресам перестали поступать байты, после чего `Read` получил EOF: `TCP connection closed by device`. Накопления неполного пакета и потери синхронизации журнал не показывает.

Главное архитектурное отличие: оригинал читает сокет непрерывно в отдельном RX-потоке, а RecorderLnx опрашивает сокет из периодического `DoTick`. Парсер границ пакетов по смыслу совпадает с оригиналом.

## Проверка

Исходники обеих реализаций и `C:\Mera Files\RecorderLnx\LogWindows.log` просмотрены. Код не менялся.
