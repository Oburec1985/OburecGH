# PNG-сжатый ICO вызывает FPImageException

## Симптом

При запуске RecorderCoordinator из Lazarus debugger возникало исключение
`FPImageException: Bitmap with unknown compression (268435456)` в
`intfgraphics.pas`. Проект при этом успешно компилировался.

## Подтверждённые факты

- Поток `ilCommandButtons.Bitmap` корректно распаковывается и совпадает с
  рабочим ImageList RecorderLnx.
- Все кадры `rcPanel.ico` были PNG-сжаты.
- Старый LCL трактовал начало PNG-кадра 16x16 как DIB; байты ширины PNG
  `00 00 00 10` прочитались little-endian как `biCompression=$10000000`, что
  точно соответствует десятичному значению 268435456 из исключения.

## Исправление

`prepare_app_icons.ps1` теперь записывает каждый ICO-кадр как несжатый 32-bit
DIB (`BITMAPINFOHEADER`, BGRA bottom-up и AND mask), а не PNG.

## Проверка

- семь кадров нового ICO начинаются с DIB header size `28-00-00-00`;
- forced-сборка RecorderCoordinator Win64 завершилась с exit code 0;
- свежий standalone EXE запустился и оставался активен до контрольной остановки.

