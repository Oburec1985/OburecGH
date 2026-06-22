# Кодировки legacy-текста (SharedUtils)

Маркер: `SHARED_STRING_ENCODING_2026_06`.

Модуль: `uSharedStringEncoding.pas`.

## Когда использовать

| Ситуация | Функция |
|---|---|
| Файл MERA/SDB/INI/XML/CSV с `windows-1251` или смешанной кодировкой | `SharedLoadLegacyTextFile`, `SharedLoadLegacyTextLines` |
| XML с декларацией `encoding="windows-1251"` (FPC `XMLRead` не принимает cp1251) | `SharedReadLegacyXmlFile` |
| Сырые байты файла → UTF-8 `string` для LCL | `SharedLegacyBytesToUtf8` |
| Только CP1251 `RawByteString` / hex-константы | `SharedCp1251BytesToUtf8` |
| Проверка, что текст не испорчен (`?` от битой перекодировки) | `SharedIsGoodDisplayText` |
| Имя из метаданных или запасное с диска | `SharedPreferredDisplayText` |

**Не дублировать** локальные `SdbReadXmlFile`, `IsValidUtf8`, `Cp1251BytesToUtf8` в
прикладных модулях — подключать `uSharedStringEncoding`.

## Алгоритм `SharedLegacyBytesToUtf8`

1. Если байты проходят проверку UTF-8 (`SharedIsValidUtf8`) — интерпретировать как UTF-8.
2. Иначе — перекодировать из Windows-1251 (`SharedCp1251BytesToUtf8`).

Так обрабатываются оба типичных случая поставки Mera:
файлы реально в UTF-8, но с устаревшей декларацией `windows-1251`, и настоящие CP1251.

## XML

```pascal
uses DOM, uSharedStringEncoding;

var
  lDoc: TXMLDocument;
begin
  SharedReadLegacyXmlFile(lDoc, AFileName);
  try
    // ...
  finally
    lDoc.Free;
  end;
end;
```

`SharedReadLegacyXmlFile` читает файл в память, перекодирует в UTF-8, подменяет
декларацию кодировки на `UTF-8` и передаёт поток в `ReadXMLFile`. Исходный файл
на диске не изменяется.

## Текстовые файлы (CSV, INI-подобные)

```pascal
var
  lLines: TStringList;
begin
  lLines := TStringList.Create;
  try
    SharedLoadLegacyTextLines(lLines, AFileName);
  finally
    lLines.Free;
  end;
end;
```

**Не использовать** `TStringList.LoadFromFile` для legacy-файлов MERA без явной
кодировки — на разных ОС результат непредсказуем.

## Отображение в LCL

```pascal
Caption := SharedPreferredDisplayText(lMetaName, lDiskName);
```

Если метаданные XML содержат `?` (битая перекодировка), показывается имя с диска.

## Исходники Lazarus

| Модуль | Использование |
|---|---|
| `RecorderLnx/SDB/uRecorderSdbStore.pas` | XML метаданные ГХ, CSV точек |
| `RecorderLnx/SDB/uRecorderSdbSelectDialog.pas` | проверка подписи в панели деталей |

При добавлении чтения legacy-файлов в других проектах Lazarus — сначала
`uSharedStringEncoding`, затем запись в эту таблицу.

## Связанные документы

- `RecorderLnx/Docs/source-encoding.md` — кодировка **исходников** `.pas` (UTF-8)
- `RecorderLnx/Docs/sdb.md` — формат SDB и чтение ГХ
