# -*- coding: utf-8 -*-
import io

file_path = "uOglChartRenderer.pas"

with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Normalize
content = content.replace("\r\n", "\n").replace("\r", "\n")

# Move from private/protected to public
decl_src = """    procedure DrawCursor(ACursor: TChartCursor; APage: TChartPage; const ARect: TChartPixelRect);
    procedure DrawCursorLabel(ACursor: TChartCursor; AXPixel, AYPixel: Single; const AText: string);
    function FindSelectedTrend(APage: TChartPage; ASelectedObj: TChartBaseObject): cBaseTrend;
    function GetTrendValueAtX(ATrend: cBaseTrend; AWorldX: Double; out AValueY: Double): Boolean;
    /// <summary> Рекурсивный обход и отрисовка дочерних объектов модели. </summary>"""

decl_dest = """    procedure DrawCursor(ACursor: TChartCursor; APage: TChartPage; const ARect: TChartPixelRect);
    procedure DrawCursorLabel(ACursor: TChartCursor; AXPixel, AYPixel: Single; const AText: string);
    /// <summary> Рекурсивный обход и отрисовка дочерних объектов модели. </summary>"""

if decl_src in content:
    content = content.replace(decl_src, decl_dest)
    print("Private decl cleaned.")

public_src = """  public

    constructor Create;"""

public_dest = """  public
    function FindSelectedTrend(APage: TChartPage; ASelectedObj: TChartBaseObject): cBaseTrend;
    function GetTrendValueAtX(ATrend: cBaseTrend; AWorldX: Double; out AValueY: Double): Boolean;

    constructor Create;"""

if public_src in content:
    content = content.replace(public_src, public_dest)
    print("Public decl added.")

content = content.replace("\n", "\r\n")

with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("Done.")
