# Заметки по комментированию модулей OGlChart

Текущая задача: подробное комментирование модулей проекта Lazarus OGlChart.
Все файлы сохраняются в кодировке Windows-1251 (CP1251), с окончаниями строк CRLF, без BOM.

## Метод сохранения кодировки
Используется двухэтапный метод записи через UTF-8 временный файл `.utf8.pas` с последующей конвертацией через PowerShell:
```powershell
[System.IO.File]::WriteAllText('$target', [System.IO.File]::ReadAllText('$temp', [System.Text.Encoding]::UTF8).Replace([string]([char]13 + [char]10), [string][char]10).Replace([string][char]10, [string]([char]13 + [char]10)), [System.Text.Encoding]::GetEncoding(1251))
```

## Прогресс комментирования модулей:
- [ ] uOglChartAxis.pas
- [ ] uOglChartBaseObj.pas
- [ ] uOglChartChart.pas
- [ ] uOglChartControl.pas
- [ ] uOglChartDrawObj.pas
- [ ] uOglChartFontMng.pas
- [ ] uOglChartLineHelper.pas
- [ ] uOglChartLog.pas
- [ ] uOglChartMng.pas
- [ ] uOglChartModel.pas
- [ ] uOglChartPage.pas
- [ ] uOglChartSerializer.pas
- [ ] uOglChartTrend.pas
- [ ] uOglChartTypes.pas
- [ ] uoglchart.pas
- [ ] uOglChartFrameListener.pas
- [ ] uOglChartRenderer.pas
