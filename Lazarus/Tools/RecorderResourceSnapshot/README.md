# Recorder Resource Snapshot

Отдельная GUI-утилита для разового снимка ресурсов запущенного процесса
`Recorder.exe` или `RecorderLnx.exe`.

1. Запустите Recorder/RecorderLnx.
2. Запустите `RecorderResourceSnapshot.exe`.
3. Выберите процесс и файл журнала.
4. Нажмите **Снять слепок**.

Каждый снимок дописывается в конец UTF-8 лога. На Windows фиксируются CPU
процесса, память, потоки, handles, GDI/USER objects, IPv4 TCP/UDP sockets и I/O.
Значение `process_cpu_machine_percent` — доля всей вычислительной мощности
машины, `process_cpu_one_core_percent` — эквивалент загрузки одного ядра.

Сборка:

```powershell
C:\lazarus\lazbuild.exe -B RecorderResourceSnapshot.lpi
```

Автоматический снимок без GUI:

```powershell
.\RecorderResourceSnapshot.exe --pid=1234 --log=C:\Logs\recorder.log
```
