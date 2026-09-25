# OGLChart: осевой zoom без Ctrl и preset спектра

## Симптом

- «По виду» на спектре подбирал диапазон по текущим данным вместо масштаба,
  сохранённого в настройках компонента.
- Рамочный zoom над осями требовал Ctrl, хотя сама область оси уже однозначно
  задаёт X-only или Y-only операцию.

## Подтверждённая причина

`TChartPanZoomListener.MouseDown` целиком помещал начало рамочного zoom в ветку
`ssCtrl`. В spectrum page одновременно был включён `AutoScaleOnZoomReset`,
поэтому общий reset вызывал fit по данным вместо применения Preset-границ.

## Исправление

- В общем listener hit-test осей выполняется независимо от Ctrl; plot area
  по-прежнему требует Ctrl.
- Spectrum page сохраняет `RangeMin/Max` в Preset и отключает auto-fit при
  reset. Обратный drag продолжает использовать общий zoom-out.

## Проверка

- `lzrObrPack.lpk` forced build: exit 0.
- `RecorderLnx.lpi` forced Windows build: exit 0.
- `SampleInfoPlugin.lpi` forced Windows build: exit 0.
- Полная Linux-сборка: `BUILD_EXIT=0`, `MISSING_LIBS=none`.
- DEB `recorderlnx_0.1.77_amd64.deb` установлен на MIC-200; пакет сообщает
  `version=0.1.77`, `status=installed`.
