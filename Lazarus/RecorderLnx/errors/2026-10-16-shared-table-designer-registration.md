# TSharedColorCheckTable отсутствует в дизайнере Lazarus

Симптом: открытие uRecorderImpactHammerView.lfm в IDE выдаёт «Невозможно
найти класс компонента TSharedColorCheckTable», хотя приложение запускается.

Подтверждено: uSharedColorCheckTable выполнял Classes.RegisterClass при
runtime initialization. Установленный RunAndDesignTime пакет LzrObrPack
не содержал этот unit/HasRegisterProc и не регистрировал компонент в IDE.

Исправление: добавлен Register с RegisterComponents; unit включён в LPK,
generated package PAS содержит RegisterUnit. Пакет -B собран успешно.
IDE построена lazbuild --build-ide=-oC:\lazarus\lazarus-shared-table.exe,
после подтверждения отсутствия процесса установлена C:\lazarus\lazarus.exe.
SHA2563ACF32A253D2134D3F5A4161619B552223D19BEA3AADD3F3917F78160789F1F1.

Build IDE автоматически перенёс прежний EXE в lazarus.old.exe, поэтому
прямая попытка backup lazarus.exe после build обнаружила отсутствие файла.
Старый lazarus.old.exe сохранён дополнительно как
C:\lazarus\lazarus.before-shared-table-40be0f668d5747f4a31a2a210611bcd5.exe;
хеши E098837FD495D03697EDC538305B5B027F95BEAE9257358B71040F6F4505711A совпали.
Пользовательские файлы IDE не закрывались принудительно, конфигурация пакетов
не менялась (профиль уже содержал LzrObrPack).

Проверка: package и IDE compile exit0, main/UI LFM streaming smoke PASS.
Открытие формы непосредственно в новой IDE пока не проверено; автоматически
IDE не запускалась. Для installed IDE недостаточно только сборки приложения.
