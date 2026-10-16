# ЦАП показывал backend-ы вместо выходных устройств

## Завершение: PortAudio runtime отсутствовал — 2026-10-15

После запуска нового EXE UI показывал только «Без аппаратного вывода (тест)».
Это подтвердило работу нового UI и отсутствие `portaudio.dll`: discovery
PortAudio завершался ошибкой загрузки, а агрегатор оставлял доступный null-
endpoint. В проект добавлен Win64 runtime PortAudio; post-build и установщик
копируют его рядом с `RecorderLnx.exe`.

Прямой вызов DLL: `Pa_Initialize=0`, 36 endpoint-ов, default=5. Временный probe,
использующий production `TRecorderAudioDacFactory.DiscoverEndpoints`, вернул 22
выходных устройства, включая Sound Blaster Play! 3, LG HDMI, High Definition
Audio и USB Audio Device. Штатная forced-сборка успешна, post-build SHA-256 DLL
совпадает с сохранённым runtime.

## Дополнение: Refresh остался старым — 2026-10-15

Пользователь повторно получил `audio.portaudio` и `null`. Проверка процесса
подтвердила, что запущен штатный `RecorderLnx.exe` сборки 17:01, тогда как код
discovery был собран только в `RecorderLnx_dac_devices_verify.exe` в 17:08.
Попытка пересобрать штатный путь дошла до линковки и завершилась Windows error 5:
запущенный процесс удерживает `RecorderLnx.exe`. Это не ошибка Refresh: старый
процесс не содержит нового кода. Остаточный шаг — штатно закрыть RecorderLnx,
повторить forced build без `-o` и перезапустить штатный EXE.

## Симптом

В выпадающем списке компонента ЦАП отображались `audio.portaudio` и `null`,
тогда как оригинальный `DAC Control` показывает реальные динамики, HDMI и
USB-аудиоустройства.

## Первопричина

UI заполнял список идентификаторами фабрик драйверов. Общий контракт фабрики не
имел стадии discovery, а минимальная PortAudio-обёртка загружала только
`Pa_OpenDefaultStream` и поэтому не могла ни перечислить, ни открыть выбранное
устройство.

## Исправление

- В общий DAC-контракт добавлен `DiscoverEndpoints` с раздельными полями
  `BackendId`, `Endpoint` и `DisplayName`.
- PortAudio загружает API перечисления устройств и возвращает только устройства
  с выходными каналами.
- Выбранное устройство открывается через `Pa_OpenStream`; default endpoint
  продолжает использовать `Pa_OpenDefaultStream`.
- Комбобокс показывает `DisplayName`, но сохраняет backend и endpoint.
- Null-backend обозначен понятным тестовым пунктом, а не строкой `null`.

## Проверка

- Forced Win64-сборка `RecorderLnx_dac_devices_verify.exe`: успешно.
- Forced-сборка и запуск `RecorderDacCoreTest`: `RESULT ... passed`.
- На машине сборки PortAudio DLL не найдена, поэтому фактический состав списка
  звуковых устройств требует проверки на целевой машине с PortAudio V19.

