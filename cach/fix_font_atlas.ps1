$path = "c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFontMng.pas"
$content = Get-Content -Path $path -Encoding default

# 1. Восстанавливаем gUseTextureAtlas := True по умолчанию
$content = $content -replace "gUseTextureAtlas: Boolean = False;", "gUseTextureAtlas: Boolean = True;"

# 2. Модифицируем метод BuildTextureAtlas
# Найдем начало метода и заменим инициализацию битмапа
$old_block = @"
  lBitmap := TBitmap.Create;
  try
    lBitmap.PixelFormat := pf32bit;
    lBitmap.Canvas.Font.Name := fName;
    
    lBitmap.Canvas.Font.Size := Round(fScale * 7.2);
    if fBold then
      lBitmap.Canvas.Font.Style := [fsBold]
    else
      lBitmap.Canvas.Font.Style := [];

    lHeight := lBitmap.Canvas.TextHeight('A');
"@

$new_block = @"
  lBitmap := TBitmap.Create;
  try
    lBitmap.PixelFormat := pf32bit;
    // Обеспечиваем ненулевой размер битмапа для корректной работы GDI / Canvas.TextHeight
    lBitmap.Width := 32;
    lBitmap.Height := 32;
    
    // Подменяем логическое имя шрифта на реальный системный шрифт для рисования
    if (fName = 'PageCaption') or (fName = 'AxisLabel') or (fName = 'AxisSelected') or
       (fName = 'GridTick') or (fName = 'Legend') or (fName = 'Debug') then
      lBitmap.Canvas.Font.Name := 'Arial'
    else
      lBitmap.Canvas.Font.Name := fName;
    
    lBitmap.Canvas.Font.Size := Round(fScale * 7.2);
    if fBold then
      lBitmap.Canvas.Font.Style := [fsBold]
    else
      lBitmap.Canvas.Font.Style := [];

    lHeight := lBitmap.Canvas.TextHeight('A');
"@

$content = $content.Replace($old_block, $new_block)

Set-Content -Path $path -Value $content -Encoding default
