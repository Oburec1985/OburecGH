# MIC315: Sound Blaster PLAY! 3 скрыт в RDP-сеансе

## Исправлено

Повторная регрессия 2026-10-16: новый сеанс снова дал DEFAULT=1 и Remote Audio.
Обнаружен обычный Default.rdp с audiomode:i:0. Сохранена резервная копия
C:\Users\User\Documents\Default.rdp.before-dac-audio-20261016-173316,
параметр обычного профиля изменён на audiomode:i:1 с сохранением UTF-16 и
атрибута Hidden. MIC315 переподключён через MIC315-local-audio.rdp.
Свежий probe session 1 снова подтвердил DEFAULT=6, Sound Blaster, Fs=44100.

Создано C:\Users\User\Documents\MIC315-local-audio.rdp с audiomode:i:1,
выполнено переподключение. Повторный probe в пользовательском session 1:
COUNT=29, DEFAULT=6, Speakers Sound Blaster доступен как MME index=6,
DirectSound index=15, WASAPI index=20. Для выбранного MME Fs=44100 Гц.
Повторная аппаратная проверка после настройки: AudioRestart 20 cycles PASS.

Хост: 192.168.15.84; USB VID_041E&PID_324D.

Проверено через SSH: USB composite/audio и MMDevice Speakers Sound Blaster
имеют Status OK, ConfigManagerErrorCode 0. Аппаратная карта и драйвер доступны.

Scripts/Get-DacAudioDevices.ps1 использует установленную portaudio.dll.
В session 0: COUNT=29, default=6, Sound Blaster output 6 (MME), 15
(DirectSound), 20 (WASAPI). Следовательно, DLL не потеряла поддержку карты.

Тот же probe запущен временной Interactive scheduled task в сеансе пользователя
User, session 1 (RDP). COUNT=9, default=1. MME/DirectSound/WASAPI показывают
только «Удаленное аудио». WDM/KS имеет встроенные SPDIF/HD Audio, но Sound
Blaster отсутствует во всех API. Это исключает фильтрацию списка RecorderLnx
как причину отсутствия именно USB-карты. Временная задача удалена.

Условие продолжения: переподключить RDP с воспроизведением звука на удалённом
компьютере (audiomode:i:1), затем перезапустить RecorderLnx для новой сессии
PortAudio. Не выполнялись принудительное отключение RDP, перезапуск аудиослужб
или изменение драйверов. Итоговые диагностические файлы оставлены в
C:\Mera Files\screens на MIC315.
