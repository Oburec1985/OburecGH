# -*- coding: utf-8 -*-
"""Fix double-spaced lines and restore corrupted comments in chart_lzr units."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORRUPT = '\x98'

SPACING_FILES = [
    'uOglChartSelectListener.pas',
    'uOglChartLabelEditListener.pas',
    'uOglChartCursorListener.pas',
    'uOglChartCursor.pas',
]


def read_text(path: Path) -> str:
    raw = path.read_bytes()
    for enc in ('utf-8', 'cp1251', 'latin-1'):
        try:
            return raw.decode(enc).replace('\r\n', '\n').replace('\r', '\n')
        except UnicodeDecodeError:
            continue
    raise RuntimeError(f'cannot decode {path}')


def write_utf8_crlf(path: Path, text: str) -> None:
    path.write_bytes(text.replace('\n', '\r\n').encode('utf-8'))


def collapse_double_spacing(text: str) -> str:
    lines = [line.rstrip() for line in text.split('\n')]
    non_empty = sum(1 for line in lines if line.strip())
    followed = sum(
        1 for i in range(len(lines) - 1)
        if lines[i].strip() and not lines[i + 1].strip()
    )
    if non_empty and followed / non_empty > 0.7:
        cleaned: list[str] = []
        i = 0
        while i < len(lines):
            line = lines[i]
            cleaned.append(line)
            if line.strip() and i + 1 < len(lines) and not lines[i + 1].strip():
                i += 2
                continue
            i += 1
        lines = cleaned

    final: list[str] = []
    prev_empty = False
    for line in lines:
        if not line.strip():
            if not prev_empty:
                final.append('')
            prev_empty = True
        else:
            final.append(line)
            prev_empty = False
    return '\n'.join(final)


def fix_directives(text: str) -> str:
    return text.replace('{ objfpc}{+}', '{$mode objfpc}{$H+}')


def fix_cursor_listener_header(text: str) -> str:
    return text.replace(
        '{\n  Ìîäóëü uOglChartCursorListener\n  Îïèñàíèå: Ñëóøàòåëü ñîáûòèé ìûøè äëÿ óïðàâëåíèÿ èíòåðàêòèâíûì êóðñîðîì ãðàôèêà.\n}',
        '{\n  Модуль uOglChartCursorListener\n  Описание: Слушатель событий мыши для управления интерактивным курсором графика.\n}',
    ).replace(
        '  // Ñëóøàòåëü ñîáûòèé äëÿ èíòåðàêòèâíîãî èçìåðèòåëüíîãî êóðñîðà.\n'
        '  // Îáðàáàòûâàåò ïåðåìåùåíèå ëèíèé êóðñîðà, ïåðåòàñêèâàíèå ìåòîê,\n'
        '  // ïðèòÿãèâàíèå ê ýêñòðåìóìàì òðåíäîâ (Shift) è êëàâèàòóðíûå ñî÷åòàíèÿ.',
        '  // Слушатель событий для интерактивного измерительного курсора.\n'
        '  // Обрабатывает перемещение линий курсора, перетаскивание меток,\n'
        '  // притягивание к экстремумам трендов (Shift) и клавиатурные сочетания.',
    )


def fix_spacing_files() -> None:
    for name in SPACING_FILES:
        path = ROOT / name
        text = read_text(path)
        text = fix_directives(text)
        if name == 'uOglChartCursorListener.pas':
            text = fix_cursor_listener_header(text)
        text = collapse_double_spacing(text)
        write_utf8_crlf(path, text)
        print(f'{name}: ok')


def fix_axis_file() -> None:
    write_utf8_crlf(ROOT / 'uOglChartAxis.pas', AXIS_CONTENT)
    print('uOglChartAxis.pas: ok')


SUMMARY_BY_PROC = {
    'procedure InitShaders': 'Компиляция и инициализация шейдеров с необходимыми параметрами.',
    'procedure Apply2DView': 'Устанавливает ортографическую проекцию OpenGL 2D для всего графика.',
    'procedure SetGLColor': 'Преобразует цвет компонента Lazarus в формат OpenGL (ABGR -> RGBA).',
    'function PageContentRect': 'Возвращает прямоугольник области построения страницы (без полей осей).',
    'function PageToPixelRect': 'Возвращает прямоугольник страницы в координатах окна.',
    'function GetPrimaryXAxis': 'Возвращает основную ось X для указанной страницы.',
    'function NiceStep': 'Подбирает «красивый» шаг сетки для заданного диапазона оси.',
    'procedure BuildLinearTicks': 'Формирует деления сетки (тики) для линейного масштаба оси.',
    'procedure BuildLogTicks': 'Формирует деления сетки (тики) для логарифмического масштаба оси.',
    'procedure BuildAxisTicks': 'Формирует подписи и координаты делений для оси Y.',
    'procedure BuildXTicks': 'Формирует подписи и координаты делений для оси X.',
    'function FormatTick': 'Форматирует числовое значение деления в строку подписи.',
    'function ValueToPixel': 'Преобразует значение оси в пиксельную координату.',
    'procedure DrawLine': 'Рисует отрезок линии.',
    'procedure DrawRect': 'Рисует контур прямоугольника.',
    'procedure FillRect': 'Заливает прямоугольник цветом.',
    'procedure AddTextHit': 'Регистрирует область текста для клика и редактирования.',
    'procedure DrawText': 'Рисует обычный текст с заданным шрифтом.',
    'procedure DrawTextSelection': 'Рисует выделение фрагмента текста.',
    'procedure DrawEditableText': 'Рисует редактируемую метку оси или страницы.',
    'procedure DrawGrid': 'Рисует сетку, оси делений и подписи.',
    'procedure DrawAxes': 'Рисует рамку и границы области построения.',
    'procedure DrawPageFrame': 'Рисует рамку страницы.',
    'procedure DrawLineSeries': 'Рисует серию TChartLineSeries.',
    'procedure DrawBuffTrend1d': 'Рисует буферизованный тренд cBuffTrend1d.',
    'procedure DrawBaseTrend': 'Рисует базовый тренд cBaseTrend.',
    'procedure DrawTrendPoints': 'Рисует точечный тренд cTrend.',
    'procedure DrawCursorLabel': 'Рисует метку курсора с цветовым оформлением.',
    'procedure RenderObject': 'Рекурсивный обход и отрисовка дочерних объектов модели.',
    'procedure RenderPage': 'Отрисовывает содержимое страницы APage.',
    'procedure DrawHighlights': 'Подсвечивает выделенные и наведённые объекты.',
}

EXACT_LINE_FIXES = {
    '  // Тип редактируемой числовой метки на графике': '  // Тип редактируемой числовой метки на графике',
}

CODE_COMMENT_FIXES = [
    ('TChartEditLabelKind = (', '  // Тип редактируемой числовой метки на графике\n  TChartEditLabelKind = ('),
    ('celNone,', '    celNone,       // метка не редактируется'),
    ('celAxisMin,', '    celAxisMin,    // минимальное значение оси Y'),
    ('celAxisMax,', '    celAxisMax,    // максимальное значение оси Y'),
    ('celXMin,', '    celXMin,       // минимальное значение оси X'),
    ('celXMax', '    celXMax        // максимальное значение оси X'),
    ('TChartTextHit = record', '  // Описание зарегистрированной текстовой области для редактирования меток\n  TChartTextHit = record'),
    ('Rect: TChartPixelRect;', '    Rect: TChartPixelRect;          // прямоугольник текста в пикселях'),
    ('Axis: TChartAxis;', '    Axis: TChartAxis;               // связанная ось (если есть)'),
    ('Page: TChartPage;', '    Page: TChartPage;               // связанная страница (если есть)'),
    ('Kind: TChartEditLabelKind;', '    Kind: TChartEditLabelKind;      // тип метки'),
    ('TextLeft: Integer;', '    TextLeft: Integer;              // координата X левого края текстового блока'),
    ('Font: cOglFont;', '    Font: cOglFont;                 // используемый шрифт'),
    ('TChartTick = record', '  // Структура деления (тика) на оси графика\n  TChartTick = record'),
    ('Value: Double;', '    Value: Double;                  // числовое значение деления'),
    ('  // Класс OpenGL-рендерера', '  // Класс OpenGL-рендерера всего графика.\n  // Реализует интерфейсы IChartRenderer (для TOglChart) и IChartOffsetHelper (для преобразования координат).'),
    ('fHost: IOpenGLContextHost;', '    fHost: IOpenGLContextHost;        // ссылка на хост OpenGL (форма/виджет)'),
    ('fUseShader: Boolean;', '    fUseShader: Boolean;              // флаг использования шейдеров для отрисовки линий'),
    ('fProgram: GLuint;', '    fProgram: GLuint;                 // программа шейдеров для 2D-линий'),
    ('fProgram1d: GLuint;', '    fProgram1d: GLuint;               // программа шейдеров для одномерных буферизованных трендов'),
    ('fShaderInitialized: Boolean;', '    fShaderInitialized: Boolean;      // флаг успешной компиляции и линковки шейдеров'),
    ('fPageRect: TChartPixelRect;', '    fPageRect: TChartPixelRect;       // текущий прямоугольник активной страницы в пикселях'),
    ('fFontMng: cOglFontMng;', '    fFontMng: cOglFontMng;            // менеджер OpenGL-шрифтов для отрисовки текста осей и меток'),
    ('fTextHits: array of TChartTextHit;', '    fTextHits: array of TChartTextHit; // массив зарегистрированных текстовых областей'),
    ('fActiveHit: TChartTextHit;', '    fActiveHit: TChartTextHit;        // активная редактируемая текстовая область'),
    ('fEditText: string;', '    fEditText: string;                // накапливаемый редактируемый текст'),
    ('fEditCursor: Integer;', '    fEditCursor: Integer;             // позиция курсора при редактировании'),
    ('fEditSelectionStart: Integer;', '    fEditSelectionStart: Integer;     // начало выделенного фрагмента'),
    ('fEditSelectionLength: Integer;', '    fEditSelectionLength: Integer;    // длина выделенного фрагмента'),
    ('fSelectedObject: TChartBaseObject;', '    fSelectedObject: TChartBaseObject; // выделенный объект модели'),
    ('fHoveredObject: TChartBaseObject;', '    fHoveredObject: TChartBaseObject;  // объект модели под курсором мыши'),
    ('fSelectionRectActive: Boolean;', '    fSelectionRectActive: Boolean;    // активна ли рамка выделения (режим зума)'),
    ('fSelectionRect: TChartPixelRect;', '    fSelectionRect: TChartPixelRect;  // координаты рамки выделения в пикселях'),
    ('// ---', None),
    ('SetGLColor($D8F5F5FA);', 'SetGLColor($D8F5F5FA); // полупрозрачная подложка метки (85% непрозрачности)'),
    ('lTextWidth := Round(lMaxW) + 12;', 'lTextWidth := Round(lMaxW) + 12; // 6px слева, 6px справа'),
    ('SetGLColor($FFFF0000)', 'SetGLColor($FFFF0000) // красный (рамка)'),
    ('SetGLColor(TChartFlagLabel(ALabel).Trend.Color)', 'SetGLColor(TChartFlagLabel(ALabel).Trend.Color) // в цвет связанного тренда'),
    ('SetGLColor($FFCCCCCC);', 'SetGLColor($FFCCCCCC); // серый фон'),
    ('lFont := fFontMng.Font(cfGridTick)', 'lFont := fFontMng.Font(cfGridTick) // стандартный шрифт сетки'),
    ('lFont.Color := TChartFlagLabel(ALabel).Trend.Color', 'lFont.Color := TChartFlagLabel(ALabel).Trend.Color // цвет линии тренда'),
]


def fix_corrupt_line(line: str, next_line: str = '', prev_context: str = '') -> str:
    stripped = line.strip()
    indent = line[: len(line) - len(line.lstrip())]

    if stripped.startswith('/// <summary>') and CORRUPT in line:
        for proc, text in SUMMARY_BY_PROC.items():
            if next_line.strip().startswith(proc):
                return f'{indent}/// <summary> {text} </summary>'
        return f'{indent}/// <summary> Вспомогательный метод рендерера. </summary>'

    if stripped.startswith('{') and CORRUPT in line and 'uOglChartRenderer' in line:
        return ''

    for key, val in CODE_COMMENT_FIXES:
        if key == '// ---':
            continue
        if key in line and CORRUPT in line:
            if val is None:
                continue
            if key == '  // Класс OpenGL-рендерера':
                return val
            if key == 'Text: string;' and 'TChartTick' in prev_context:
                return '    Text: string;                   // отформатированная подпись деления'
            if key == 'Text: string;' and 'TChartTextHit' in prev_context:
                return '    Text: string;                   // текущий текст метки'
            if key == 'Value: Double;' and 'TChartTick' not in prev_context:
                continue
            return val if val.startswith((' ', '\t')) else indent + val

    if stripped.startswith('// ---') and CORRUPT in line:
        if 'IChartRenderer' in line:
            return '    // --- Реализация IChartRenderer ---'
        if 'IChartOffsetHelper' in line:
            return '    // --- Реализация IChartOffsetHelper ---'
        if 'MouseDown' in next_line or 'Initialize' in next_line:
            return '    // --- Реализация IChartRenderer ---'
        return '    // --- Дополнительные методы ---'

    if '//' in line and CORRUPT in line:
        code = line.split('//', 1)[0].rstrip()
        for key, val in CODE_COMMENT_FIXES:
            if key in code and val and not val.startswith((' ', '\t')):
                return indent + val
        return code

    if CORRUPT in line:
        return re.sub(r'\x98+', '', line)
    return line


def fix_renderer_file() -> None:
    path = ROOT / 'uOglChartRenderer.pas'
    text = read_text(path)
    header = '''{
  Модуль uOglChartRenderer
  Описание: основной OpenGL-рендерер графического компонента TOglChart.
            Отвечает за отрисовку страниц, осей, трендов (линейных и буферизованных),
            сетки графика (включая редактируемые подписи и интерактивные метки), курсора
            измерений и рамок. Поддерживает аппаратное ускорение отрисовки линий шейдерами.
}'''
    text = re.sub(
        r'\{\s*\n(?:[^\}]*\x98[^\}]*\n)+\}',
        header,
        text,
        count=1,
        flags=re.MULTILINE,
    )
    text = text.replace('{$codepage cp1251}', '')
    if '{$mode objfpc}' not in text[:200]:
        text = text.replace(
            'unit uOglChartRenderer;\n',
            'unit uOglChartRenderer;\n{$mode objfpc}{$H+}\n{$codepage UTF8}\n',
            1,
        )

    lines = text.split('\n')
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if CORRUPT in line:
            nxt = lines[i + 1] if i + 1 < len(lines) else ''
            ctx = '\n'.join(out[-20:])
            fixed = fix_corrupt_line(line, nxt, ctx)
            if fixed == '' and line.strip().startswith('{'):
                out.append('{')
                i += 1
                while i < len(lines) and not lines[i].strip().startswith('}'):
                    i += 1
                out.append(header.split('\n', 1)[1])
                if i < len(lines):
                    out.append('}')
                    i += 1
                continue
            if fixed == '  // Класс OpenGL-рендерера всего графика.\n  // Реализует интерфейсы IChartRenderer (для TOglChart) и IChartOffsetHelper (для преобразования координат).':
                out.append('  // Класс OpenGL-рендерера всего графика.')
                out.append('  // Реализует интерфейсы IChartRenderer (для TOglChart) и IChartOffsetHelper (для преобразования координат).')
            elif '\n' in fixed:
                out.extend(fixed.split('\n'))
            else:
                out.append(fixed)
        else:
            out.append(line)
        i += 1

    text = collapse_double_spacing('\n'.join(out))

    # section markers near public interface
    text = text.replace(
        '    procedure Initialize(AHost: IOpenGLContextHost);',
        '    // --- Реализация IChartRenderer ---\n\n    procedure Initialize(AHost: IOpenGLContextHost);',
        1,
    )
    text = text.replace(
        '    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;',
        '    // --- Реализация IChartOffsetHelper ---\n\n    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;',
        1,
    )
    text = text.replace(
        '    function MouseDown(AX, AY: Integer; ADoubleClick: Boolean): Boolean;',
        '    // --- Методы ввода мыши ---\n\n    function MouseDown(AX, AY: Integer; ADoubleClick: Boolean): Boolean;',
        1,
    )
    text = text.replace(
        '    function GetPageRect(APage: TChartPage): TChartPixelRect;',
        '    // --- Дополнительные методы рендерера ---\n\n    function GetPageRect(APage: TChartPage): TChartPixelRect;',
        1,
    )
    text = text.replace(
        '    property SelectedObject: TChartBaseObject read fSelectedObject write fSelectedObject;',
        '    // --- Свойства состояния ---\n    property SelectedObject: TChartBaseObject read fSelectedObject write fSelectedObject;',
        1,
    )

    write_utf8_crlf(path, text)
    print(f'uOglChartRenderer.pas: ok, corrupt={text.count(CORRUPT)}')


AXIS_CONTENT = '''unit uOglChartAxis;

{$mode objfpc}{$H+}

{
  Модуль uOglChartAxis
  Описание: базовый класс cAxis (TChartAxis), используемый для осей графика в компоненте TOglChart.
            Хранит диапазоны значений, масштаб и пресеты для зума.
}

interface

uses
  uOglChartDrawObj;

type
  { TChartAxisScale }
  // Тип шкалирования оси (линейная или логарифмическая)
  TChartAxisScale = (casLinear, casLog10);

  { cAxis }
  /// <summary>
  /// Класс оси графика. Хранит диапазоны значений, масштаб и пресеты
  /// для сброса пользовательского зума/панорамы.
  /// </summary>
  cAxis = class(cMoveObj)
  private
    fScale: TChartAxisScale;             // режим масштаба оси Y (линейный или логарифмический)
    fMinValue: Double;                   // минимальное значение оси Y
    fMaxValue: Double;                   // максимальное значение оси Y
    fUseOwnX: Boolean;                  // флаг использования независимого диапазона X для этой оси
    fXMinValue: Double;                 // независимый минимум X
    fXMaxValue: Double;                 // независимый максимум X
    fXScale: TChartAxisScale;            // независимый масштаб X (линейный или логарифмический)
    fPresetMinValue: Double;             // сохранённый минимум оси Y
    fPresetMaxValue: Double;             // сохранённый максимум оси Y
    fHasPresetRange: Boolean;            // признак наличия пользовательского диапазона Y
  private
  public
    /// <summary>
    /// Устанавливает свойства оси по умолчанию.
    /// </summary>
    procedure AssignDefaultProperties; override;

    /// <summary> Тип шкалы оси Y (линейная/логарифмическая). </summary>
    property Scale: TChartAxisScale read fScale write fScale;
    /// <summary> Нижняя грань Y. </summary>
    property MinValue: Double read fMinValue write fMinValue;
    /// <summary> Верхняя грань Y. </summary>
    property MaxValue: Double read fMaxValue write fMaxValue;
    /// <summary> Флаг наличия собственного диапазона по оси X для этой оси. </summary>
    property UseOwnX: Boolean read fUseOwnX write fUseOwnX;
    /// <summary> Минимальное значение оси X. </summary>
    property XMinValue: Double read fXMinValue write fXMinValue;
    /// <summary> Максимальное значение оси X. </summary>
    property XMaxValue: Double read fXMaxValue write fXMaxValue;
    /// <summary> Тип масштабирования оси по оси X. </summary>
    property XScale: TChartAxisScale read fXScale write fXScale;
    property PresetMinValue: Double read fPresetMinValue write fPresetMinValue;
    property PresetMaxValue: Double read fPresetMaxValue write fPresetMaxValue;
    property HasPresetRange: Boolean read fHasPresetRange write fHasPresetRange;
  end;

  TChartAxis = cAxis;

procedure ChartAxisApplyUserValue(AAxis: TChartAxis; AIsMin: Boolean; AValue: Double);

implementation

{ cAxis }

/// <summary>
/// Задаёт значения по умолчанию для оси: линейный масштаб, диапазон [0..1] для X и Y.
/// </summary>
procedure cAxis.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Axis';
  Caption := 'Axis';
  fScale := casLinear;
  fMinValue := 0;
  fMaxValue := 1;
  fUseOwnX := False;
  fXMinValue := 0;
  fXMaxValue := 1;
  fXScale := casLinear;
  fPresetMinValue := fMinValue;
  fPresetMaxValue := fMaxValue;
  fHasPresetRange := False;
end;

procedure ChartAxisApplyUserValue(AAxis: TChartAxis; AIsMin: Boolean; AValue: Double);
begin
  if AAxis = nil then
    Exit;
  if AIsMin then
  begin
    AAxis.MinValue := AValue;
    AAxis.PresetMinValue := AValue;
  end
  else
  begin
    AAxis.MaxValue := AValue;
    AAxis.PresetMaxValue := AValue;
  end;
  if AAxis.PresetMaxValue > AAxis.PresetMinValue then
    AAxis.HasPresetRange := True;
end;

end.
'''


def main() -> None:
    fix_spacing_files()
    fix_axis_file()
    fix_renderer_file()


if __name__ == '__main__':
    main()
