# -*- coding: utf-8 -*-
import io
import os

replacements = {
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartSelectListener.pas": (
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartAxis, uOglChartPage,\n  uOglChartRenderer, uOglChartChart;",
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,\n  uOglChartAxis, uOglChartPage, uOglChartRenderer, uOglChartChart;"
    ),
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas": (
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartAxis, uOglChartPage,\n  uOglChartTrend, uOglChartRenderer, uOglChartChart, uOglChartTextLabel;",
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,\n  uOglChartAxis, uOglChartPage, uOglChartTrend, uOglChartRenderer, uOglChartChart,\n  uOglChartTextLabel;"
    ),
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPageGeometryListener.pas": (
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartPage,\n  uOglChartRenderer, uOglChartChart;",
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,\n  uOglChartPage, uOglChartRenderer, uOglChartChart;"
    ),
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartVertexEditListener.pas": (
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartAxis, uOglChartPage,\n  uOglChartTrend, uOglChartRenderer, uOglChartChart, uOglChartLineHelper;",
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,\n  uOglChartAxis, uOglChartPage, uOglChartTrend, uOglChartRenderer, uOglChartChart,\n  uOglChartLineHelper;"
    ),
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartLabelEditListener.pas": (
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartAxis, uOglChartPage,\n  uOglChartTrend, uOglChartRenderer, uOglChartChart, uOglChartTextLabel;",
        "uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,\n  uOglChartAxis, uOglChartPage, uOglChartTrend, uOglChartRenderer, uOglChartChart,\n  uOglChartTextLabel;"
    ),
}

for file_path, (old_text, new_text) in replacements.items():
    if os.path.exists(file_path):
        # 1. Read in CP1251
        with io.open(file_path, "r", encoding="cp1251") as f:
            content = f.read()
        
        # Normalize line endings for replacement match
        content_norm = content.replace('\r\n', '\n')
        old_text_norm = old_text.replace('\r\n', '\n')
        new_text_norm = new_text.replace('\r\n', '\n')
        
        if old_text_norm in content_norm:
            content_norm = content_norm.replace(old_text_norm, new_text_norm)
            content = content_norm.replace('\n', '\r\n')
            
            # Write back in CP1251 with CRLF
            with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
                f.write(content)
            print("Successfully patched uses in: %s" % os.path.basename(file_path))
        else:
            print("Warning: uses clause pattern not matched in: %s" % os.path.basename(file_path))
    else:
        print("Error: File not found: %s" % file_path)

print("Uses patch complete.")
