# -*- coding: utf-8 -*-
"""Integrate TagId references across RecorderLnx GUI."""
from pathlib import Path

ROOT = Path(r'D:/works/OburecGH/Lazarus/RecorderLnx')


def rw(p: Path) -> str:
    raw = p.read_bytes()
    for enc in ('utf-8', 'cp1251'):
        try:
            return raw.decode(enc).replace('\r\n', '\n').replace('\r', '\n')
        except UnicodeDecodeError:
            pass
    return raw.decode('latin-1').replace('\r\n', '\n')


def ww(p: Path, t: str) -> None:
    p.write_bytes(t.replace('\n', '\r\n').encode('utf-8'))


def patch_project_files() -> None:
    p = ROOT / 'Core/uRecorderProjectFiles.pas'
    t = rw(p)
    reps = [
        (
            "        lIni.WriteString(lSection, 'TagName', lComponent.TagName);",
            "        lIni.WriteString(lSection, 'TagName', lComponent.TagName);\n"
            "        lIni.WriteInt64(lSection, 'TagId', lComponent.TagId);",
        ),
        (
            "            lIni.WriteString(lSection, Format('OscLine%dTagName', [K]), lLine.TagName);",
            "            lIni.WriteString(lSection, Format('OscLine%dTagName', [K]), lLine.TagName);\n"
            "            lIni.WriteInt64(lSection, Format('OscLine%dTagId', [K]), lLine.TagId);",
        ),
        (
            "          lIni.WriteString(lSection, 'TahoTagName', lSpectrum.TahoTagName);",
            "          lIni.WriteString(lSection, 'TahoTagName', lSpectrum.TahoTagName);\n"
            "          lIni.WriteInt64(lSection, 'TahoTagId', lSpectrum.TahoTagId);",
        ),
        (
            "            lIni.WriteString(lSection, Format('Tag%d', [K]), lSpectrum.TagNames[K]);",
            "            lIni.WriteString(lSection, Format('Tag%d', [K]), lSpectrum.TagNames[K]);\n"
            "            if (K >= Low(lSpectrum.TagIds)) and (K <= High(lSpectrum.TagIds)) then\n"
            "              lIni.WriteInt64(lSection, Format('Tag%dId', [K]), lSpectrum.TagIds[K]);",
        ),
        (
            "            lIni.WriteString(lSection, Format('Line%dTagName', [K]), lLine.TagName);",
            "            lIni.WriteString(lSection, Format('Line%dTagName', [K]), lLine.TagName);\n"
            "            lIni.WriteInt64(lSection, Format('Line%dTagId', [K]), lLine.TagId);",
        ),
        (
            "          lComponent.TagName := lIni.ReadString(lSection, 'TagName', '');",
            "          lComponent.TagName := lIni.ReadString(lSection, 'TagName', '');\n"
            "          lComponent.TagId := lIni.ReadInt64(lSection, 'TagId', 0);",
        ),
        (
            "              lLine.TagName := lIni.ReadString(lSection, Format('OscLine%dTagName', [K]), '');",
            "              lLine.TagName := lIni.ReadString(lSection, Format('OscLine%dTagName', [K]), '');\n"
            "              lLine.TagId := lIni.ReadInt64(lSection, Format('OscLine%dTagId', [K]), 0);",
        ),
        (
            "            lSpectrum.TahoTagName := lIni.ReadString(lSection, 'TahoTagName', lSpectrum.TahoTagName);",
            "            lSpectrum.TahoTagName := lIni.ReadString(lSection, 'TahoTagName', lSpectrum.TahoTagName);\n"
            "            lSpectrum.TahoTagId := lIni.ReadInt64(lSection, 'TahoTagId', 0);",
        ),
        (
            "              lSpectrum.TagNames.Add(lIni.ReadString(lSection, Format('Tag%d', [K]), ''));",
            "              lSpectrum.TagNames.Add(lIni.ReadString(lSection, Format('Tag%d', [K]), ''));\n"
            "              lSpectrum.EnsureTagIdsCount;\n"
            "              lSpectrum.TagIds[lSpectrum.TagNames.Count - 1] :=\n"
            "                lIni.ReadInt64(lSection, Format('Tag%dId', [K]), 0);",
        ),
        (
            "              lLine.TagName := lIni.ReadString(lSection, Format('Line%dTagName', [K]), lLine.TagName);",
            "              lLine.TagName := lIni.ReadString(lSection, Format('Line%dTagName', [K]), lLine.TagName);\n"
            "              lLine.TagId := lIni.ReadInt64(lSection, Format('Line%dTagId', [K]), 0);",
        ),
    ]
    for old, new in reps:
        if old not in t:
            raise RuntimeError(f'missing in project files: {old[:60]}')
        t = t.replace(old, new, 1)
    ww(p, t)
    print('project files ok')


def patch_lpi() -> None:
    p = ROOT / 'RecorderLnx.lpi'
    t = rw(p)
    ins = """      <Unit>
        <Filename Value="Core/uRecorderTagRefs.pas"/>
        <IsPartOfProject Value="True"/>
      </Unit>
"""
    if 'uRecorderTagRefs.pas' not in t:
        t = t.replace(
            '        <Filename Value="Core/uRecorderTags.pas"/>\n        <IsPartOfProject Value="True"/>\n      </Unit>\n',
            '        <Filename Value="Core/uRecorderTags.pas"/>\n        <IsPartOfProject Value="True"/>\n      </Unit>\n' + ins,
            1,
        )
    ww(p, t)
    print('lpi ok')


def patch_visual_control() -> None:
    p = ROOT / 'UI/uRecorderVisualControl.pas'
    t = rw(p)
    t = t.replace(
        'uses\n  uOglChartTrend,\n  uRecorderOglOscillogramView,\n  uRecorderTrendView,\n  uRecorderSpectrumView;',
        'uses\n  uOglChartTrend,\n  uRecorderOglOscillogramView,\n  uRecorderTrendView,\n  uRecorderSpectrumView,\n  uRecorderTagRefs;',
    )
    t = t.replace(
        '  lTag := ATagRegistry.FindByName(fComponent.TagName);\n  if (lTag <> nil) and (lTag.SignalBuffer.Count > 0) then\n  begin\n    lValue := lTag.SignalBuffer.LatestValue;\n    lValueStr := FormatFloat(\'0.000\', lValue);\n  end\n  else\n    lValueStr := \'0.0\';\n    \n  Caption := fComponent.TagName + \'  \' + lValueStr;',
        '  lTag := RecorderResolveTag(ATagRegistry, fComponent.TagId, fComponent.TagName);\n  if lTag <> nil then\n    RecorderBindComponentTag(fComponent, lTag);\n  if (lTag <> nil) and (lTag.SignalBuffer.Count > 0) then\n  begin\n    lValue := lTag.SignalBuffer.LatestValue;\n    lValueStr := FormatFloat(\'0.000\', lValue);\n  end\n  else\n    lValueStr := \'0.0\';\n\n  if lTag <> nil then\n    Caption := lTag.Name + \'  \' + lValueStr\n  else\n    Caption := fComponent.TagName + \'  \' + lValueStr;',
    )
    ww(p, t)
    print('visual control ok')


def patch_oscillogram_view() -> None:
    p = ROOT / 'UI/uRecorderOglOscillogramView.pas'
    t = rw(p)
    t = t.replace(
        '    fAbsoluteTagName: string;\n    fBindingMode: TRecorderTagBindingMode;',
        '    fAbsoluteTagId: TRecorderTagId;\n    fAbsoluteTagName: string;\n    fBindingMode: TRecorderTagBindingMode;',
    )
    t = t.replace(
        '  uOglChartTrend, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,\n  uOglChartColors;',
        '  uOglChartTrend, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,\n  uOglChartColors, uRecorderTagRefs;',
    )
    t = t.replace(
        '  fAbsoluteTagName := AComponent.TagName;\n  SyncLinesFromComponent',
        '  fAbsoluteTagId := AComponent.TagId;\n  fAbsoluteTagName := AComponent.TagName;\n  SyncLinesFromComponent',
    )
    t = t.replace(
        '        lTagName := Trim(lLine.TagName);',
        '        lLineTag := RecorderResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);\n        if lLineTag <> nil then\n          lTagName := lLineTag.Name\n        else\n          lTagName := Trim(lLine.TagName);',
    )
    t = t.replace(
        '      lLineTag := ResolveTagByName(ATagRegistry, lTagName);',
        '      lLineTag := ATagRegistry.FindByName(lTagName);',
    )
    t = t.replace(
        '    if fAbsoluteTagName <> \'\' then\n      Result := ATagRegistry.FindByName(fAbsoluteTagName);',
        '    Result := RecorderResolveTag(ATagRegistry, fAbsoluteTagId, fAbsoluteTagName);',
    )
    t = t.replace(
        'function TRecorderOglOscillogram.ResolveTagByName(\n  ATagRegistry: TRecorderTagRegistry; const ATagName: string): TRecorderTag;\nbegin\n  Result := nil;\n  if (ATagRegistry = nil) or (Trim(ATagName) = \'\') then\n    Exit;\n  Result := ATagRegistry.FindByName(ATagName);\nend;',
        'function TRecorderOglOscillogram.ResolveTagByName(\n  ATagRegistry: TRecorderTagRegistry; const ATagName: string): TRecorderTag;\nbegin\n  Result := RecorderResolveTag(ATagRegistry, 0, ATagName);\nend;',
    )
    t = t.replace(
        '    lTag := ResolveTagByName(ATagRegistry, lLine.TagName);',
        '    lTag := RecorderResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);',
    )
    ww(p, t)
    print('oscillogram view ok')


def patch_trend_view() -> None:
    p = ROOT / 'UI/uRecorderTrendView.pas'
    t = rw(p)
    if 'uRecorderTagRefs' not in t:
        # add to implementation uses - find implementation section
        idx = t.find('implementation')
        impl_uses = t.find('uses', idx)
        if impl_uses < 0:
            t = t.replace(
                'implementation\n\n',
                'implementation\n\nuses\n  uRecorderTagRefs;\n\n',
                1,
            )
        else:
            end = t.find(';', impl_uses)
            t = t[:end] + ', uRecorderTagRefs' + t[end:]
    t = t.replace(
        '    if (not lLine.Visible) or (lLine.TagName = \'\') then\n      Continue;\n\n    lTag := fTagRegistry.FindByName(lLine.TagName);',
        '    if not lLine.Visible then\n      Continue;\n\n    lTag := RecorderResolveTag(fTagRegistry, lLine.TagId, lLine.TagName);\n    if lTag <> nil then\n      RecorderBindTrendLineTag(lLine, lTag);',
    )
    ww(p, t)
    print('trend view ok')


def patch_spectrum_view() -> None:
    p = ROOT / 'UI/uRecorderSpectrumView.pas'
    t = rw(p)
    if 'uRecorderTagRefs' not in t:
        t = t.replace(
            'implementation\n\n',
            'implementation\n\nuses\n  uRecorderTagRefs;\n\n',
            1,
        )
    t = t.replace(
        '    SetLength(fBufferedFrames, fComponent.TagNames.Count);\n    for I := 0 to fComponent.TagNames.Count - 1 do\n    begin\n      fBufferedFrames[I].TagName := fComponent.TagNames[I];',
        '    RecorderSyncSpectrumComponentTagNames(fTagRegistry, fComponent);\n    SetLength(fBufferedFrames, fComponent.TagNames.Count);\n    for I := 0 to fComponent.TagNames.Count - 1 do\n    begin\n      fBufferedFrames[I].TagName := fComponent.TagNames[I];',
    )
    t = t.replace(
        '  for I := 0 to fComponent.TagNames.Count - 1 do\n  begin\n    lSeries := cBuffTrend1d.Create;\n    lSeries.Name := fComponent.TagNames[I];\n    lSeries.Caption := fComponent.TagNames[I];',
        '  RecorderSyncSpectrumComponentTagNames(fTagRegistry, fComponent);\n  for I := 0 to fComponent.TagNames.Count - 1 do\n  begin\n    lSeries := cBuffTrend1d.Create;\n    lSeries.Name := fComponent.TagNames[I];\n    lSeries.Caption := fComponent.TagNames[I];',
    )
    ww(p, t)
    print('spectrum view ok')


def patch_mainform() -> None:
    p = ROOT / 'UI/uMainForm.pas'
    t = rw(p)
    if 'uRecorderTagRefs' not in t:
        t = t.replace(
            '  uFormEditorController, uRecorderSettingsDialog, uTagSettingsDialog,',
            '  uFormEditorController, uRecorderSettingsDialog, uTagSettingsDialog,\n  uRecorderTagRefs,',
        )
    t = t.replace(
        '    if (fTagRegistry <> nil) and (fTagRegistry.SelectedTag <> nil) then\n      lComponent.TagName := fTagRegistry.SelectedTag.Name;',
        '    if (fTagRegistry <> nil) and (fTagRegistry.SelectedTag <> nil) then\n      RecorderBindComponentTag(lComponent, fTagRegistry.SelectedTag);',
    )
    t = t.replace(
        '    if lTag <> nil then\n    begin\n      lComponent.TagName := lTag.Name;\n      if lComponent.AxisCount > 0 then',
        '    if lTag <> nil then\n    begin\n      RecorderBindComponentTag(lComponent, lTag);\n      if lComponent.AxisCount > 0 then',
    )
    t = t.replace(
        '      lLine := lComponent.AddLine;\n      lLine.TagName := lTag.Name;',
        '      lLine := lComponent.AddLine;\n      RecorderBindTrendLineTag(lLine, lTag);',
    )
    t = t.replace(
        '    if lTag <> nil then\n      lComponent.TagNames.Add(lTag.Name);',
        '    if lTag <> nil then\n      lComponent.SetTagRefAt(lComponent.TagNames.Count, lTag);',
    )
    if 'RecorderResolveTagIdsInManager' not in t:
        t = t.replace(
            '  LoadRecorderGuiConfig(lFiles.GuiFileName, fFormManager, fComponentFactory);\n  if FileExists(lFiles.GuiFileName) then',
            '  LoadRecorderGuiConfig(lFiles.GuiFileName, fFormManager, fComponentFactory);\n  RecorderResolveTagIdsInManager(fTagRegistry, fFormManager);\n  if FileExists(lFiles.GuiFileName) then',
        )
    if 'RecorderSyncTagNamesInManager' not in t:
        t = t.replace(
            '      RebuildTagList(edTagSearch.Text);\n      AddLog(Format(\'Tag settings updated: %d channel(s).\', [lTags.Count]));',
            '      RecorderSyncTagNamesInManager(fTagRegistry, fFormManager);\n      RebuildTagList(edTagSearch.Text);\n      if fFormEditor <> nil then\n        fFormEditor.RefreshLive;\n      RefreshBaseOscillograms;\n      AddLog(Format(\'Tag settings updated: %d channel(s).\', [lTags.Count]));',
        )
    ww(p, t)
    print('mainform ok')


def patch_tag_settings() -> None:
    p = ROOT / 'UI/uTagSettingsDialog.pas'
    t = rw(p)
    t = t.replace(
        '    TagAt(0).Name := Trim(fNameEdit.Text);',
        '    if not fTagRegistry.RenameTag(TagAt(0), Trim(fNameEdit.Text)) then\n      raise ERecorderTagError.Create(\'Invalid tag name\');',
    )
    t = t.replace(
        '  lTag.Name := lTagName;',
        '  if not fTagRegistry.RenameTag(lTag, lTagName) then\n    raise ERecorderTagError.Create(\'Invalid tag name\');',
        1,
    )
    ww(p, t)
    print('tag settings ok')


def patch_osc_settings() -> None:
    p = ROOT / 'UI/uRecorderOscillogramSettingsDialog.pas'
    t = rw(p)
    if 'uRecorderTagRefs' not in t:
        t = t.replace(
            '  uRecorderColorSwatch, uRecorderFormModel, uRecorderTags, uOglChartColors;',
            '  uRecorderColorSwatch, uRecorderFormModel, uRecorderTags, uOglChartColors,\n  uRecorderTagRefs;',
        )
    t = t.replace(
        '    lLine.TagName := TRecorderTag(fLineTagCombo.Items.Objects[fLineTagCombo.ItemIndex]).Name;',
        '    RecorderBindTrendLineTag(lLine, TRecorderTag(fLineTagCombo.Items.Objects[fLineTagCombo.ItemIndex]));',
    )
    t = t.replace(
        '    fDraft.TagName := TRecorderTag(fTagCombo.Items.Objects[fTagCombo.ItemIndex]).Name;',
        '    RecorderBindComponentTag(fDraft, TRecorderTag(fTagCombo.Items.Objects[fTagCombo.ItemIndex]));',
    )
    t = t.replace(
        '  fComponent.AssignOscillogram(fDraft);\n  fComponent.TagName := fDraft.TagName;',
        '  fComponent.AssignOscillogram(fDraft);\n  fComponent.TagId := fDraft.TagId;\n  fComponent.TagName := fDraft.TagName;',
    )
    ww(p, t)
    print('osc settings ok')


def patch_trend_settings() -> None:
    p = ROOT / 'UI/uRecorderTrendSettingsDialog.pas'
    t = rw(p)
    if 'uRecorderTagRefs' not in t:
        t = t.replace(
            '  uRecorderColorSwatch, uRecorderFormModel, uRecorderTags, uOglChartColors;',
            '  uRecorderColorSwatch, uRecorderFormModel, uRecorderTags, uOglChartColors,\n  uRecorderTagRefs;',
        )
    t = t.replace(
        'procedure TRecorderTrendSettingsDialog.StoreLineControls;\nvar\n  lLine: TRecorderTrendLine;\n  lName: string;',
        'procedure TRecorderTrendSettingsDialog.StoreLineControls;\nvar\n  lLine: TRecorderTrendLine;\n  lName: string;\n  lTag: TRecorderTag;',
    )
    t = t.replace(
        '  lLine := fDraft.Lines[fSelectedLine];\n  lLine.TagName := Trim(fLineTagCombo.Text);',
        '  lLine := fDraft.Lines[fSelectedLine];\n  lTag := fTagRegistry.FindByName(Trim(fLineTagCombo.Text));\n  if lTag <> nil then\n    RecorderBindTrendLineTag(lLine, lTag)\n  else\n  begin\n    lLine.TagId := 0;\n    lLine.TagName := Trim(fLineTagCombo.Text);\n  end;',
    )
    t = t.replace(
        'procedure TRecorderTrendSettingsDialog.AddLineClick(Sender: TObject);\nvar\n  lLine: TRecorderTrendLine;',
        'procedure TRecorderTrendSettingsDialog.AddLineClick(Sender: TObject);\nvar\n  lLine: TRecorderTrendLine;\n  lTag: TRecorderTag;',
    )
    t = t.replace(
        '  lLine := fDraft.AddLine;\n  lLine.AxisIndex := 0;\n  if fLineTagCombo.Items.Count > 0 then\n    lLine.TagName := fLineTagCombo.Items[0];',
        '  lLine := fDraft.AddLine;\n  lLine.AxisIndex := 0;\n  if fLineTagCombo.Items.Count > 0 then\n  begin\n    lTag := fTagRegistry.FindByName(fLineTagCombo.Items[0]);\n    if lTag <> nil then\n      RecorderBindTrendLineTag(lLine, lTag)\n    else\n      lLine.TagName := fLineTagCombo.Items[0];\n  end;',
    )
    ww(p, t)
    print('trend settings ok')


def main() -> None:
    patch_project_files()
    patch_lpi()
    patch_visual_control()
    patch_oscillogram_view()
    patch_trend_view()
    patch_spectrum_view()
    patch_mainform()
    patch_tag_settings()
    patch_osc_settings()
    patch_trend_settings()
    print('done')


if __name__ == '__main__':
    main()
