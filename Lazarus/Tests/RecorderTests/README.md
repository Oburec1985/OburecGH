# RecorderTests

Тут будут тесты-примеры RecorderLnx. Каждый пример должен одновременно показывать использование класса и проверять ожидаемое поведение.

## Общий принцип

Тесты лежат рядом с проверяемым примером и собираются в собственный `lib`
каталог.

Запуск всех тестов:

```powershell
.\Tests\RecorderTests\run-recorder-tests.ps1
```

Шаблон сборки на Windows:

```powershell
C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe -MObjFPC -FuC:\Oburec\OburecGH\Lazarus\RecorderLnx\Core -FUC:\Oburec\OburecGH\Lazarus\Tests\RecorderTests\<TestName>\lib -oC:\Oburec\OburecGH\Lazarus\Tests\RecorderTests\<TestName>\lib\<ProgramName>.exe C:\Oburec\OburecGH\Lazarus\Tests\RecorderTests\<TestName>\<ProgramName>.lpr
```

## StateMachine

`StateMachine/RecorderStateMachineTest.lpr` проверяет базовые переходы `TRecorderStateMachine`, модель настроек запуска/остановки `TRecorderRunControlSettings` и сохранение/загрузку этих настроек в INI-файл.

Сборка:

```powershell
C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe -MObjFPC -FuC:\Oburec\OburecGH\Lazarus\RecorderLnx\Core -FUC:\Oburec\OburecGH\Lazarus\Tests\RecorderTests\StateMachine\lib -oC:\Oburec\OburecGH\Lazarus\Tests\RecorderTests\StateMachine\lib\RecorderStateMachineTest.exe C:\Oburec\OburecGH\Lazarus\Tests\RecorderTests\StateMachine\RecorderStateMachineTest.lpr
```

## FormModel

`FormModel/RecorderFormModelTest.lpr` проверяет базовую модель экранных формуляров:
`TRecorderFormPage`, `TRecorderFormManager`, `TRecorderComponentFactory`,
`TRecorderFormFactory`, а также первые модельные компоненты `StaticText` и
`TagValue`.

Сборка:

```powershell
C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe -MObjFPC -FuC:\Oburec\OburecGH\Lazarus\RecorderLnx\Core -FUC:\Oburec\OburecGH\Lazarus\Tests\RecorderTests\FormModel\lib -oC:\Oburec\OburecGH\Lazarus\Tests\RecorderTests\FormModel\lib\RecorderFormModelTest.exe C:\Oburec\OburecGH\Lazarus\Tests\RecorderTests\FormModel\RecorderFormModelTest.lpr
```

## Остальные тесты-примеры

- `CoreServices/RecorderCoreServicesTest.lpr`
- `DataSources/RecorderDataSourcesTest.lpr`
- `EventQueue/RecorderEventQueueTest.lpr`
- `Storage/RecorderStorageTest.lpr`
- `Tags/RecorderTagsTest.lpr`
- `TimeSystem/RecorderTimeSystemTest.lpr`
