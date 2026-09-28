# `.mera` не открывался в WinPOS на Linux

## Симптом

После назначения ассоциации двойной щелчок по файлу `.mera` не запускал
WinPOS на KIP-4.

## Причина

Созданный launcher проверял Linux-путь
`~/.wine/drive_c/Program Files (x86)/MERA/WinPOS/WinPos.exe`. На диске Wine
каталог называется `Mera`; Linux учитывает регистр, поэтому проверка файла
завершалась ошибкой до запуска Wine. Дополнительно Wine зарегистрировал
расширение как `application/x-wine-extension-mera`, тогда как наш обработчик
назначался только новому MIME `application/x-mera-measurement`.

## Исправление

Launcher использует фактический регистр каталога, умеет найти `WinPos.exe`
без учёта регистра и запускает его из рабочего каталога WinPOS. Ассоциация
назначается как для собственного MIME, так и для Wine MIME расширения `.mera`.
Ошибки launcher отображаются пользователю через `zenity` при его наличии.

## Проверка

SSH-аудитом сопоставлены штатный ярлык WinPOS, установленный desktop-файл,
launcher, MIME defaults и реальный файл `/home/user/Загрузки/0001.mera`.
Сборка и проверка после развёртывания фиксируются в журнале итерации.

## Повторное проявление на MIC-200 (2026-09-28)

Встроенная команда `associate-mera` создавала desktop-обработчик, который
позже вызывал `open-mera`. В нём снова оказался жёсткий путь к `.wine` и
прямой запуск `WinPos.exe`. На MIC-200 фактический префикс — `.wineetersoft`,
а рабочая регистрация Wine@Etersoft запускает программу через
`wine start /ProgIDOpen WinPos`.

Исправлено в самом LinuxSetupManager: он ищет `.wineetersoft`, `.wine` и
остальные `.wine*`, находит `WinPos.exe` без зависимости от регистра, затем
открывает замер через зарегистрированный ProgID WinPos. MIME-пакет дополнен
сигнатурой `[MERA]`; оба MIME (`application/x-mera-measurement` и
`application/x-wine-extension-mera`) назначаются одному обработчику.

На MIC-200 установлен пакет 0.1.98. Встроенной CLI-командой ассоциация
применена для пользователя `mera`. Контрольный запуск файла
`/home/mera/Mera files/usml/0001/0001.mera` создал процесс
`WINPOS.EXE Z:\\home\\mera\\Mera files\\usml\\0001\\0001.mera`.
