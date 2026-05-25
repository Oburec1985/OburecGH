# RecorderTests

Тут будут тесты-примеры RecorderLnx. Каждый пример должен одновременно показывать использование класса и проверять ожидаемое поведение.

## StateMachine

`StateMachine/RecorderStateMachineTest.lpr` проверяет базовые переходы `TRecorderStateMachine`, модель настроек запуска/остановки `TRecorderRunControlSettings` и сохранение/загрузку этих настроек в INI-файл.

Сборка на Windows:

```powershell
C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe -MObjFPC -FuD:\works\OburecGH\Lazarus\RecorderLnx\Core -FUD:\works\OburecGH\Lazarus\Tests\RecorderTests\StateMachine\lib -oD:\works\OburecGH\Lazarus\Tests\RecorderTests\StateMachine\lib\RecorderStateMachineTest.exe D:\works\OburecGH\Lazarus\Tests\RecorderTests\StateMachine\RecorderStateMachineTest.lpr
```

Запуск:

```powershell
D:\works\OburecGH\Lazarus\Tests\RecorderTests\StateMachine\lib\RecorderStateMachineTest.exe
```
