# Архитектура визуальных компонентов мнемосхем в RecorderLnx



В данном документе описывается структура, жизненный цикл и реестр визуальных компонентов мнемосхем в проекте `RecorderLnx`.



---



## 1. Общий принцип работы и слабая связанность (Decoupling)



Для обеспечения расширяемости системы и изоляции контроллера `TFormEditorController` от конкретных деталей реализации визуальных компонентов (таких как осциллограммы, тренды, цифровые индикаторы и текстовые метки) введена интерфейсная модель на основе **Реестра Визуальных Компонентов**.



Контроллер редактора форм `TFormEditorController` оперирует исключительно базовой моделью данных `TRecorderVisualComponent` и общим интерфейсом `IVForm`. Он ничего не знает о конкретных классах отображения, что позволяет:

1. Легко добавлять новые компоненты в проект (включая C++ плагины).

2. Динамически создавать нужные элементы интерфейса во время отрисовки (Render) и обновлять их в реальном времени (RefreshLive).



---



## 2. Основные сущности архитектуры



### Интерфейс `IVForm`

Объявлен в модуле [uRecorderVisualControl.pas](file:///d:/works/OburecGH/Lazarus/RecorderLnx/UI/uRecorderVisualControl.pas). Каждый визуальный виджет (наследник `TControl`), который планируется размещать на мнемосхеме, обязан реализовывать этот интерфейс:



```pascal

type

  IVForm = interface

    ['{69A4CBA7-4E0D-47C0-B95D-8D5EF980ACF8}']

    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);

    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);

    function GetChartControl: TOglChart;

  end;

```



### Реестр `TRecorderVisualControlRegistry`

Статический реестр сопоставления классов моделей (`TRecorderVisualComponentClass`) и классов их визуального представления (`TRecorderVisualControlClass`).

Регистрация происходит в секции `initialization` соответствующих модулей или централизованно.



Пример регистрации:

```pascal

initialization

  TRecorderVisualControlRegistry.RegisterControl(TRecorderStaticTextComponent, TRecorderStaticTextView);

  TRecorderVisualControlRegistry.RegisterControl(TRecorderTagValueComponent, TRecorderTagValueView);

  TRecorderVisualControlRegistry.RegisterControl(TRecorderTrendComponent, TRecorderTrendView);

  TRecorderVisualControlRegistry.RegisterControl(TRecorderOscillogramComponent, TRecorderOglOscillogram);

```



---



## 3. Взаимодействие в `TFormEditorController`



### Отрисовка и кэширование страниц (метод `Render`)

Когда контроллер выполняет метод `Render`, он **не уничтожает** контролы предыдущей страницы. Вместо этого для каждой страницы мнемосхемы (`PageId`) создается собственная выделенная панель `TPanel` (страничный холст), которая кэшируется в списке `fPagePanels`.



При переключении вкладок:

1. Неактивные панели страниц скрываются (`Visible := False`).

2. Активная панель страницы отображается (`Visible := True`) и переносится на передний план (`BringToFront`).

3. Контроллер проверяет, изменилось ли количество или состав компонентов на активной странице. Если состав не менялся, то существующие визуальные контролы (включая тренды и OpenGL-чарты) **не пересоздаются**, а лишь адаптируют свои размеры и конфигурацию. Это сохраняет историю графиков и предотвращает утечки контекстов OpenGL.



```pascal

  // Показываем только активную панель

  for I := 0 to fPagePanels.Count - 1 do

  begin

    lPnl := TPanel(fPagePanels.Objects[I]);

    lPnl.Visible := (lPnl = lPagePanel);

    if lPnl.Visible then

      lPnl.BringToFront;

  end;

```



### Обновление в реальном времени (метод `RefreshLive`)

Обновление накопленных данных и графиков выполняется путем обхода **всех** созданных панелей страниц (включая скрытые в данный момент вкладки). Если дочерний элемент поддерживает интерфейс `IVForm`, вызывается его метод `RefreshControl`:



```pascal

procedure TFormEditorController.RefreshLive;

var

  I, J: Integer;

  lPagePanel: TPanel;

  lCompPanel: TControl;

  lChild: TControl;

  lVisualCtrl: IVForm;

begin

  if fPagePanels = nil then

    Exit;

    

  for I := 0 to fPagePanels.Count - 1 do

  begin

    lPagePanel := TPanel(fPagePanels.Objects[I]);

    for J := 0 to lPagePanel.ControlCount - 1 do

    begin

      lCompPanel := lPagePanel.Controls[J];

      if lCompPanel is TPanel then

      begin

        if TPanel(lCompPanel).ControlCount > 0 then

        begin

          lChild := TPanel(lCompPanel).Controls[0];

          if Supports(lChild, IVForm, lVisualCtrl) then

            lVisualCtrl.RefreshControl(fTagRegistry, fDisplaySeconds);

        end;

      end;

    end;

  end;

end;

```



---



## 4. Жизненный цикл данных трендов



Визуальный компонент тренда (`TRecorderTrendView`) накапливает предысторию сигналов непрерывно.

Благодаря кэшированию страниц:

1. **История не теряется**: Переход на другие вкладки программы и возврат назад не приводят к пересозданию чарта тренда.

2. **Фоновое наполнение**: Так как метод `RefreshLive` обновляет все страницы в фоновом режиме, тренд продолжает наполняться точками, даже когда его вкладка скрыта. При ее открытии пользователь мгновенно получает актуальный график со всей накопленной предысторией.



---



## 5. Разработка новых компонентов (включая C++ плагины)



Для интеграции нового визуального компонента в мнемосхемы RecorderLnx необходимо:

1. Описать класс модели данных, унаследованный от `TRecorderVisualComponent` (в модуле [uRecorderFormModel.pas](file:///d:/works/OburecGH/Lazarus/RecorderLnx/Core/uRecorderFormModel.pas)).

2. Создать класс отображения (наследник `TControl`/`TPanel`), реализующий интерфейс `IVForm`.

3. Зарегистрировать связь класса модели и класса отображения через `TRecorderVisualControlRegistry.RegisterControl`.

4. Для С++ плагинов: плагин должен экспортировать фабричную функцию, которая создает `TControl` (через обертку C++ / Delphi), реализующий методы `IVForm`. Контроллер сможет работать с ним прозрачно.



---



## 6. Критическое правило: Управление памятью в RunTime



В проектах `AGrav` и `RecorderLnx` действуют строгие ограничения на динамическое выделение памяти:



> [!IMPORTANT]

> **Память нельзя выделять в RunTime (внутри циклов обработки или потоков захвата)!**

> 

> 1. **Априорное выделение**: Все буферы, массивы и объекты должны создаваться/разворачиваться заранее (при старте программы или переконфигурировании). В RunTime работа должна вестись строго в рамках уже выделенной памяти.

> 2. **Chunk Allocation (Блочное выделение)**: Если динамическое выделение памяти в RunTime абсолютно неизбежно, память должна выделяться крупными блоками (экспоненциально или пулами), а не мелкими фрагментами. Это предотвращает дефрагментацию системной кучи (heap fragmentation) и повышает стабильность программы при длительной непрерывной работе.

> 3. **Очистка вместо пересоздания**: При сбросе состояний (старт/стоп, перезапуск) объекты не должны пересоздаваться. Используйте встроенные методы `Clear` для очистки внутренних данных, чтобы сохранить неизменными внешние ссылки на эти объекты.





---



## 5. Оригинальные интерфейсы Recorder



Оригинальные интерфейсы Recorder (такие как `IVForm`, `IRecorder`, `ITag`) находятся по пути:

[SharedRUnits/interfaces/](file:///d:/works/OburecGH/recorder/SharedRUnits/interfaces/)

