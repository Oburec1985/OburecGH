program RecorderFormModelTest;

{
  RecorderFormModelTest

  Назначение:
    Тест-пример первого ядра экранных формуляров RecorderLnx. Пример показывает,
    как зарегистрировать модельные компоненты, создать страницы, добавить их в
    менеджер и переключить активную страницу без участия LCL UI.
}

{$mode objfpc}{$H+}

uses
  SysUtils,
  uRecorderFormModel,
  uRecorderProjectFiles;

procedure AssertEquals(AActual, AExpected: Integer; const AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %d, got %d',
      [AStep, AExpected, AActual]);
end;

procedure AssertEquals(const AActual, AExpected, AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %s, got %s',
      [AStep, AExpected, AActual]);
end;

procedure AssertTrue(ACondition: Boolean; const AStep: string);
begin
  if not ACondition then
    raise Exception.Create(AStep + ': condition is false');
end;

procedure TestComponentFactory;
var
  lFactory: TRecorderComponentFactory;
  lComponent: TRecorderVisualComponent;
begin
  lFactory := TRecorderComponentFactory.Create;
  try
    lFactory.RegisterDefaultComponents;

    lComponent := lFactory.CreateComponent(TRecorderStaticTextComponent.TypeId);
    try
      AssertEquals(lComponent.TypeId, 'StaticText', 'static text component type');
    finally
      lComponent.Free;
    end;

    AssertTrue(lFactory.IsComponentRegistered(TRecorderTagValueComponent.TypeId),
      'tag value component is registered');
    AssertTrue(lFactory.IsComponentRegistered(TRecorderOscillogramComponent.TypeId),
      'oscillogram component is registered');
    AssertTrue(not lFactory.IsComponentRegistered('UnknownType'),
      'unknown component type is not registered');

    Writeln('Component factory test passed.');
  finally
    lFactory.Free;
  end;
end;

procedure TestFormPages;
var
  lComponentFactory: TRecorderComponentFactory;
  lFormFactory: TRecorderFormFactory;
  lManager: TRecorderFormManager;
  lBasePage: TRecorderFormPage;
  lDebugPage: TRecorderFormPage;
  lValueComponent: TRecorderVisualComponent;
begin
  lComponentFactory := TRecorderComponentFactory.Create;
  lManager := TRecorderFormManager.Create;
  try
    lComponentFactory.RegisterDefaultComponents;
    lFormFactory := TRecorderFormFactory.Create(lComponentFactory);
    try
      lBasePage := lFormFactory.CreateBlankPage('base', 'BasePage', 'Base page');
      lManager.AddPage(lBasePage);

      lDebugPage := lFormFactory.CreateDebugTagPage('debug', 'DebugPage',
        'Debug tags', 'MemTag');
      lManager.AddPage(lDebugPage);

      AssertEquals(lManager.PageCount, 2, 'page count');
      AssertTrue(lManager.ActivePage = lBasePage, 'first page becomes active');
      AssertEquals(lDebugPage.ComponentCount, 2, 'debug page component count');

      lValueComponent := lDebugPage.FindComponentById('debug.tag-value');
      AssertTrue(lValueComponent <> nil, 'tag value component exists');
      AssertEquals(lValueComponent.TagName, 'MemTag', 'tag binding');
      AssertEquals(lValueComponent.Bounds.Width, 180, 'tag value width');

      lManager.SetActivePageById('debug');
      AssertTrue(lManager.ActivePage = lDebugPage, 'debug page is active');
      AssertTrue(not lManager.TrySetActivePageById('missing'),
        'missing page is not activated');
      AssertTrue(lManager.ActivePage = lDebugPage,
        'active page is preserved after missing page lookup');

      Writeln('Form pages test passed.');
    finally
      lFormFactory.Free;
    end;
  finally
    lManager.Free;
    lComponentFactory.Free;
  end;
end;

procedure TestGuiConfigSavesBaseOscillogramCount;
var
  lComponentFactory: TRecorderComponentFactory;
  lFileName: string;
  lLoaded: TRecorderFormManager;
  lManager: TRecorderFormManager;
  lPage: TRecorderFormPage;
begin
  lFileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderFormModelTest.gui.ini';
  if FileExists(lFileName) then
    DeleteFile(lFileName);

  lComponentFactory := TRecorderComponentFactory.Create;
  lLoaded := TRecorderFormManager.Create;
  lManager := TRecorderFormManager.Create;
  try
    lComponentFactory.RegisterDefaultComponents;
    lPage := TRecorderFormPage.Create('BasePage', 'BasePage', 'Base page');
    lPage.BaseOscillogramCount := 5;
    lManager.AddPage(lPage);

    SaveRecorderGuiConfig(lFileName, lManager);
    LoadRecorderGuiConfig(lFileName, lLoaded, lComponentFactory);

    AssertEquals(lLoaded.PageCount, 1, 'loaded gui page count');
    AssertEquals(lLoaded.Pages[0].BaseOscillogramCount, 5,
      'loaded base oscillogram count');
    Writeln('GUI config base oscillogram count test passed.');
  finally
    lManager.Free;
    lLoaded.Free;
    lComponentFactory.Free;
    if FileExists(lFileName) then
      DeleteFile(lFileName);
  end;
end;

procedure TestGuiConfigSavesOscillogramBinding;
var
  lComponentFactory: TRecorderComponentFactory;
  lFileName: string;
  lLoaded: TRecorderFormManager;
  lLoadedOsc: TRecorderOscillogramComponent;
  lManager: TRecorderFormManager;
  lOsc: TRecorderOscillogramComponent;
  lPage: TRecorderFormPage;
begin
  lFileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderFormModelOscTest.gui.ini';
  if FileExists(lFileName) then
    DeleteFile(lFileName);

  lComponentFactory := TRecorderComponentFactory.Create;
  lLoaded := TRecorderFormManager.Create;
  lManager := TRecorderFormManager.Create;
  try
    lComponentFactory.RegisterDefaultComponents;
    lPage := TRecorderFormPage.Create('Page1', 'Page1', 'Mnemonic');
    lManager.AddPage(lPage);

    lOsc := TRecorderOscillogramComponent(
      lComponentFactory.CreateComponent(TRecorderOscillogramComponent.TypeId));
    lOsc.Id := 'Page1.osc1';
    lOsc.Name := 'Osc1';
    lOsc.TagName := 'AbsTag';
    lOsc.BindingMode := rtbmAbsoluteTag;
    lOsc.TagOffset := 3;
    lOsc.SetBounds(10, 20, 300, 180);
    lPage.AddComponent(lOsc);

    SaveRecorderGuiConfig(lFileName, lManager);
    LoadRecorderGuiConfig(lFileName, lLoaded, lComponentFactory);

    AssertEquals(lLoaded.PageCount, 1, 'loaded osc page count');
    AssertEquals(lLoaded.Pages[0].ComponentCount, 1, 'loaded osc component count');
    AssertTrue(lLoaded.Pages[0].Components[0] is TRecorderOscillogramComponent,
      'loaded component is oscillogram');
    lLoadedOsc := TRecorderOscillogramComponent(lLoaded.Pages[0].Components[0]);
    AssertEquals(lLoadedOsc.TagName, 'AbsTag', 'loaded osc absolute tag');
    AssertEquals(Ord(lLoadedOsc.BindingMode), Ord(rtbmAbsoluteTag),
      'loaded osc binding mode');
    AssertEquals(lLoadedOsc.TagOffset, 3, 'loaded osc tag offset');
    Writeln('GUI config oscillogram binding test passed.');
  finally
    lManager.Free;
    lLoaded.Free;
    lComponentFactory.Free;
    if FileExists(lFileName) then
      DeleteFile(lFileName);
  end;
end;

begin
  TestComponentFactory;
  TestFormPages;
  TestGuiConfigSavesBaseOscillogramCount;
  TestGuiConfigSavesOscillogramBinding;
end.
