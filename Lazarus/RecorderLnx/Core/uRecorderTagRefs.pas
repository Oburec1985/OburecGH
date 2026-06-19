unit uRecorderTagRefs;

{
  Tag reference helpers: resolve tags by stable Id with name fallback,
  bind components to registry tags, sync cached names after rename.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uRecorderFormModel;

function RecorderResolveTag(ARegistry: TRecorderTagRegistry;
  ATagId: TRecorderTagId; const ATagName: string): TRecorderTag;

procedure RecorderBindTagRef(out ATagId: TRecorderTagId; var ATagName: string;
  ATag: TRecorderTag);

procedure RecorderBindComponentTag(AComponent: TRecorderVisualComponent;
  ATag: TRecorderTag);

procedure RecorderBindTrendLineTag(ALine: TRecorderTrendLine; ATag: TRecorderTag);

procedure RecorderSyncVisualComponentTagName(ARegistry: TRecorderTagRegistry;
  AComponent: TRecorderVisualComponent);

procedure RecorderSyncTrendLineTagName(ARegistry: TRecorderTagRegistry;
  ALine: TRecorderTrendLine);

procedure RecorderSyncOscillogramTagNames(ARegistry: TRecorderTagRegistry;
  AOsc: TRecorderOscillogramComponent);

procedure RecorderSyncTrendComponentTagNames(ARegistry: TRecorderTagRegistry;
  ATrend: TRecorderTrendComponent);

procedure RecorderSyncSpectrumComponentTagNames(ARegistry: TRecorderTagRegistry;
  ASpectrum: TRecorderSpectrumComponent);

procedure RecorderSyncTagNamesInManager(ARegistry: TRecorderTagRegistry;
  AManager: TRecorderFormManager);

procedure RecorderResolveComponentTagIds(ARegistry: TRecorderTagRegistry;
  AComponent: TRecorderVisualComponent);

procedure RecorderResolveTagIdsInManager(ARegistry: TRecorderTagRegistry;
  AManager: TRecorderFormManager);

implementation

function RecorderResolveTag(ARegistry: TRecorderTagRegistry;
  ATagId: TRecorderTagId; const ATagName: string): TRecorderTag;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  if ATagId <> 0 then
    Result := ARegistry.FindById(ATagId);
  if (Result = nil) and (Trim(ATagName) <> '') then
  begin
    Result := ARegistry.FindByName(ATagName);
    if (Result <> nil) and (ATagId = 0) then
      ; // caller may persist Id later
  end;
end;

procedure RecorderBindTagRef(out ATagId: TRecorderTagId; var ATagName: string;
  ATag: TRecorderTag);
begin
  if ATag = nil then
  begin
    ATagId := 0;
    ATagName := '';
    Exit;
  end;
  ATagId := ATag.Id;
  ATagName := ATag.Name;
end;

procedure RecorderBindComponentTag(AComponent: TRecorderVisualComponent;
  ATag: TRecorderTag);
var
  lTagId: TRecorderTagId;
  lTagName: string;
begin
  if AComponent = nil then
    Exit;
  lTagId := AComponent.TagId;
  lTagName := AComponent.TagName;
  RecorderBindTagRef(lTagId, lTagName, ATag);
  AComponent.TagId := lTagId;
  AComponent.TagName := lTagName;
end;

procedure RecorderBindTrendLineTag(ALine: TRecorderTrendLine; ATag: TRecorderTag);
var
  lTagId: TRecorderTagId;
  lTagName: string;
begin
  if ALine = nil then
    Exit;
  lTagId := ALine.TagId;
  lTagName := ALine.TagName;
  RecorderBindTagRef(lTagId, lTagName, ATag);
  ALine.TagId := lTagId;
  ALine.TagName := lTagName;
end;

procedure RecorderSyncTrendLineTagName(ARegistry: TRecorderTagRegistry;
  ALine: TRecorderTrendLine);
var
  lTag: TRecorderTag;
begin
  if (ALine = nil) or (ARegistry = nil) then
    Exit;
  lTag := RecorderResolveTag(ARegistry, ALine.TagId, ALine.TagName);
  if lTag <> nil then
    RecorderBindTrendLineTag(ALine, lTag);
end;

procedure RecorderSyncVisualComponentTagName(ARegistry: TRecorderTagRegistry;
  AComponent: TRecorderVisualComponent);
var
  lTag: TRecorderTag;
begin
  if (AComponent = nil) or (ARegistry = nil) then
    Exit;
  lTag := RecorderResolveTag(ARegistry, AComponent.TagId, AComponent.TagName);
  if lTag <> nil then
    RecorderBindComponentTag(AComponent, lTag);
end;

procedure RecorderSyncOscillogramTagNames(ARegistry: TRecorderTagRegistry;
  AOsc: TRecorderOscillogramComponent);
var
  I: Integer;
begin
  if (AOsc = nil) or (ARegistry = nil) then
    Exit;
  RecorderSyncVisualComponentTagName(ARegistry, AOsc);
  for I := 0 to AOsc.LineCount - 1 do
    RecorderSyncTrendLineTagName(ARegistry, AOsc.Lines[I]);
end;

procedure RecorderSyncTrendComponentTagNames(ARegistry: TRecorderTagRegistry;
  ATrend: TRecorderTrendComponent);
var
  I: Integer;
begin
  if (ATrend = nil) or (ARegistry = nil) then
    Exit;
  for I := 0 to ATrend.LineCount - 1 do
    RecorderSyncTrendLineTagName(ARegistry, ATrend.Lines[I]);
end;

procedure RecorderSyncSpectrumComponentTagNames(ARegistry: TRecorderTagRegistry;
  ASpectrum: TRecorderSpectrumComponent);
var
  I: Integer;
  lTag: TRecorderTag;
begin
  if (ASpectrum = nil) or (ARegistry = nil) then
    Exit;
  for I := 0 to ASpectrum.TagNames.Count - 1 do
    ASpectrum.ResolveTagAt(ARegistry, I);
  lTag := RecorderResolveTag(ARegistry, ASpectrum.TahoTagId, ASpectrum.TahoTagName);
  if lTag <> nil then
  begin
    ASpectrum.TahoTagId := lTag.Id;
    ASpectrum.TahoTagName := lTag.Name;
  end;
end;

procedure RecorderSyncTagNamesInManager(ARegistry: TRecorderTagRegistry;
  AManager: TRecorderFormManager);
var
  I, J: Integer;
  lPage: TRecorderFormPage;
  lComponent: TRecorderVisualComponent;
begin
  if (ARegistry = nil) or (AManager = nil) then
    Exit;
  for I := 0 to AManager.PageCount - 1 do
  begin
    lPage := AManager.Pages[I];
    for J := 0 to lPage.ComponentCount - 1 do
    begin
      lComponent := lPage.Components[J];
      if lComponent is TRecorderOscillogramComponent then
        RecorderSyncOscillogramTagNames(ARegistry, TRecorderOscillogramComponent(lComponent))
      else if lComponent is TRecorderTrendComponent then
        RecorderSyncTrendComponentTagNames(ARegistry, TRecorderTrendComponent(lComponent))
      else if lComponent is TRecorderSpectrumComponent then
        RecorderSyncSpectrumComponentTagNames(ARegistry, TRecorderSpectrumComponent(lComponent))
      else
        RecorderSyncVisualComponentTagName(ARegistry, lComponent);
    end;
  end;
end;

procedure RecorderResolveComponentTagIds(ARegistry: TRecorderTagRegistry;
  AComponent: TRecorderVisualComponent);
var
  I: Integer;
  lTag: TRecorderTag;
  lOsc: TRecorderOscillogramComponent;
  lTrend: TRecorderTrendComponent;
  lSpectrum: TRecorderSpectrumComponent;
begin
  if (AComponent = nil) or (ARegistry = nil) then
    Exit;
  if AComponent.TagId = 0 then
  begin
    lTag := ARegistry.FindByName(AComponent.TagName);
    if lTag <> nil then
      AComponent.TagId := lTag.Id;
  end;
  if AComponent is TRecorderOscillogramComponent then
  begin
    lOsc := TRecorderOscillogramComponent(AComponent);
    for I := 0 to lOsc.LineCount - 1 do
    begin
      if lOsc.Lines[I].TagId = 0 then
      begin
        lTag := ARegistry.FindByName(lOsc.Lines[I].TagName);
        if lTag <> nil then
          lOsc.Lines[I].TagId := lTag.Id;
      end;
    end;
  end
  else if AComponent is TRecorderTrendComponent then
  begin
    lTrend := TRecorderTrendComponent(AComponent);
    for I := 0 to lTrend.LineCount - 1 do
    begin
      if lTrend.Lines[I].TagId = 0 then
      begin
        lTag := ARegistry.FindByName(lTrend.Lines[I].TagName);
        if lTag <> nil then
          lTrend.Lines[I].TagId := lTag.Id;
      end;
    end;
  end
  else if AComponent is TRecorderSpectrumComponent then
  begin
    lSpectrum := TRecorderSpectrumComponent(AComponent);
    lSpectrum.ResolveTagIdsFromNames(ARegistry);
  end;
end;

procedure RecorderResolveTagIdsInManager(ARegistry: TRecorderTagRegistry;
  AManager: TRecorderFormManager);
var
  I, J: Integer;
  lPage: TRecorderFormPage;
begin
  if (ARegistry = nil) or (AManager = nil) then
    Exit;
  for I := 0 to AManager.PageCount - 1 do
  begin
    lPage := AManager.Pages[I];
    for J := 0 to lPage.ComponentCount - 1 do
      RecorderResolveComponentTagIds(ARegistry, lPage.Components[J]);
  end;
end;

end.
