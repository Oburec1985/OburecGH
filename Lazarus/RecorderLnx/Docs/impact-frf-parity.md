# Ударный FRF: контракт функционального соответствия

Цель — отдельный компонент RecorderLnx для измерения FRF ударным молотком.
Источники поведения: legacy `uSRSFrm`, `uEditSrsFrm`, `uModelPointMng`.
Статусы ниже подтверждены кодом и тестами на 2026-10-01.

## Расчётное ядро и runtime

- `SRS-D01` trigger, pretrigger и time sync — `DONE`: capture interval,
  unequal arrival и приведение timestamped series к общей сетке перед DSP
  реализованы и покрыты jitter/phase test.
- `SRS-D02` bounded set, capture association, navigation/hide/delete/clear —
  `DONE`.
- `SRS-D03` rectangular/Hann/Hamming/force/exponential и zero-pad — `DONE`:
  код, persistence и независимая golden-матрица покрыты.
- `SRS-D04` FFT и auto/cross spectra — `DONE`: pipeline получает синхронные
  ресэмплированные блоки; профильный runner проверяет известную фазу.
- `SRS-D05` legacy H0/H1/H2, magnitude/phase — `DONE`.
- `SRS-D06` coherence и quality threshold — `DONE`.
- `SRS-D07` hide/delete с recompute и новой публикацией — `DONE`.
- `SRS-D08` Welch segmentation/overlap/averaging — `DONE`: implementation и
  golden tests вариантов окна/overlap проходят.
- `SRS-D09` configure/arm/acquire/finalize/stop/error — `DONE`: lifecycle
  Recorder управляет доступностью, stop/fault/recovery покрыты service test.
- `SRS-D10` response point-group/increment semantics — `DONE`: versioned
  настройки преобразуются в owner-scoped bindings через model-point catalog;
  concrete 3D target покрыт service test.

## Публикация

- `SRS-P01` immutable versioned multi-curve snapshot — `DONE`.
- `SRS-P02` chart и 3D читают один provider/version — `DONE`: aggregate
  provider обслуживает несколько владельцев, service строит presentation из
  той же опубликованной версии, которую читает 3D; race tests проходят.
- `SRS-P03` удалить scalar sampler — `DONE`; 3D использует frequency-grid
  provider.
- `SRS-P04` атомарная полная публикация — `DONE`.

## Модель, настройки, проект

- `SRS-C01` stable tags, trigger/timing/capacity — `DONE`.
- `SRS-C02` FFT/zero-pad/H0-H2/windows/units/Welch — `DONE` для
  model/settings/persistence.
- `SRS-C03` response color/axis/point mapping/CurveId/space/gain — `DONE` для
  model/settings/persistence; runtime bridge учитывается в `SRS-3D05`.
- `SRS-C04` validation, draft, OK/Cancel, transactional load — `DONE`.

`uRecorderProjectFiles` сохраняет versioned ImpactHammer config; настоящий
GUI-project round-trip проверяет все DSP-поля и response bindings. Invalid load
не изменяет target.

## Runtime UI

- `SRS-U01` count/index/navigation — `DONE`.
- `SRS-U02` hide/delete/recompute — `DONE`.
- `SRS-U03` time plots hammer/responses — `DONE`: native LFM smoke подтверждает
  данные и series на time chart.
- `SRS-U04` spectrum/FRF/phase/coherence/visibility — `DONE`: native LFM smoke
  подтверждает пять наполненных chart paths и persisted visibility.
- `SRS-U05` estimator/window/Welch/result controls — `DONE`: runtime controls
  транзакционно применяют estimator/window/Welch к service/model.
- `SRS-U06` cursor frequency/readouts/compare — `DONE`: chart mouse задаёт два
  cursor X, presenter интерполирует значения, view показывает readout и
  imported comparison добавляется как read-only curves.
- `SRS-U07` log X/Y, manual scale, result type, line visibility и persisted
  chart state — `DONE`: axis state, active result, excitation/response
  visibility сохраняются и покрыты model round-trip.
- `SRS-U08` enable/disable и recorder-state behavior — `DONE`.

## Storage/export

- `SRS-X01` storage port session/time blocks — `DONE`: UI-neutral port,
  JSON/Mera adapters и golden round-trip покрывают raw/time blocks.
- `SRS-X02` averaged FRF/phase/coherence export с metadata — `DONE`: JSON,
  CSV и Mera export покрыты golden tests.
- `SRS-X03` optional MDB/Mera adapter — `DONE`: concrete Mera folder adapter
  с manifest/data round-trip внедрён в application composition.
- `SRS-X04` optional WinPos adapter — `DONE`: concrete launcher внедрён и
  получает валидированный export context/session snapshot.
- `SRS-X05` нет file/MDB IO в UI/domain — `DONE`; сохранить через adapters.
- `SRS-X06` database comparison/import workflow — `DONE`: Mera/database-backed
  и portable comparison проходят общий validated import/display path.

## 3D

- `SRS-3D01` stable helper/node/curve ID, axis/space/gain — `DONE`: Save Points
  разрешает group/point через catalog и публикует owner-scoped bindings в
  выбранный 3D component.
- `SRS-3D02` frequency/animation-phase controllers — `DONE`.
- `SRS-3D03` provider→sampler→motion adapter→scene — `DONE`.
- `SRS-3D04` XYZ interpolation по frequency/phase — `DONE` в integration test.
- `SRS-3D05` legacy Save Points/model lookup/play/scale lifecycle — `DONE` на
  уровне code/service tests: target lookup, owner-scoped replace/remove,
  play/stop, scale и animation frequency подключены; native scene acceptance
  остаётся в `T08`.

## Проверки

- `SRS-T01` trigger/pretrigger/unequal timing — `DONE`: arrival и time-grid
  resampling с jitter/известной фазой покрыты.
- `SRS-T02` ring/wrap/delete/hide/recompute — `DONE`.
- `SRS-T03` windows/zero-pad/estimators/coherence/Welch — `DONE`.
- `SRS-T04` immutable atomic snapshot и общий version — `DONE`.
- `SRS-T05` stable curve→3D motion — `DONE` в service integration test;
  native scene smoke остаётся в `T08`.
- `SRS-T06` migration/project/Cancel/export — `DONE`: project/Cancel,
  legacy estimator migration, validation security и storage golden round-trip
  покрыты.
- `SRS-T07` steady-state без allocations/name lookup/plan creation — `DONE`:
  ingest hot path preallocated и проверен heap-allocation test; chart refresh
  revision-gated и series переиспользуются.
- `SRS-T08` forced builds и runtime UI/acquisition/3D — `DONE`: 2026-10-01
  профильные forced build/runtime tests, native LFM five-chart smoke, unified
  real OBR→Save Points→FRF motion и full RecorderLnx link прошли.

## Подтверждённая интеграция текущего P0

Visual control зарегистрирован, создаёт service и доступен через palette
factory. Service разрешает stable tag IDs, слушает EventBus, захватывает hammer
и два response, строит spectra, усредняет видимые удары и публикует repository.
Hide/delete вызывают recompute. Default provider доступен 3D.

Графический путь подтверждён native LFM smoke: `FillSnapshot` заполняет пять
типов результатов, presenter формирует frame, view обновляет reusable series и
вызывает redraw. Storage validation ограничивает размеры/идентичности/
монотонность/finite values; запись выполняется атомарно.

## Итог

Все идентификаторы матрицы имеют статус `DONE`. Verdict — `ЦЕЛЬ ДОСТИГНУТА`.
