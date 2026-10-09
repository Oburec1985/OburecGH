# PXI MX-248 Win32 vendor runtime provenance

> Архитектура и правила обновления:
> [MX-248 README](../../Docs/README.md).

Manifest повторно зафиксирован 2026-10-09 по аппаратно проверенному комплекту
MIC-315 (MX-248 s/n 3253, PCI 2/14/0):

`C:\Program Files (x86)\Mera\Recorder`

Все перечисленные DLL проверены как PE i386. `VC_redist.x86.exe` — официальный
Microsoft Visual C++ 2015–2022 Redistributable x86 версии 14.50.35719.0,
найденный в локальном Package Cache.

Проверенный минимальный комплект хранится в этом каталоге и по умолчанию
используется `build-installer.ps1`. Внешний `VendorDevApiDir` оставлен только
для контролируемой замены всего комплекта. Сборщик сверяет каждый файл с
`manifest.sha256`. Обновлять manifest можно только целиком после проверки
импортов, PE architecture, лицензии/права распространения и hardware smoke.
Нельзя смешивать DLL из разных установок Recorder/Mr300: совпадение имён и x86
не подтверждает ABI-совместимость.

Причина обязательности полного closure: DevAPI не сообщает ошибку загрузки
device DLL. При отсутствии любой транзитивной зависимости он возвращает код 0
и пустой список. На MIC-315 это воспроизводилось при отсутствии `FTD2XX.dll`
и private VC90 DLL.

Статическое private dependency closure проверенного набора:

```text
mx224v14 -> DevAPI, MDProtocol
MDProtocol -> FTD2XX, wd_utils, DevAPI
mdpC6424 -> DevAPI, MDProtocol
MDProtocol, mdpC6424, mx224v14 -> mfc90, msvcp90, msvcr90
```

Карта получена из таблиц PE imports. Системные DLL в графе опущены. Финальный
hardware smoke выполнил discovery, `CreateDeviceH`, `Reset`, чтение s/n и
revision, затем `DevAPI.Test`; результат: s/n 3253, revision 1, все коды 0.
