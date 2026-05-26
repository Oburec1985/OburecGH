unit ubaseobjLaz;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs, laz2_dom, laz2_xmlread, laz2_xmlwrite;

type
  TBaseObj = class;

  // --- TBaseObjList -----------------------------------------------------------
  // Представляет собой строго типизированный список для хранения объектов TBaseObj.
  // Является оберткой над стандартным TObjectList, обеспечивая безопасность типов
  // и автоматическое управление памятью дочерних объектов.
  TBaseObjList = class(TObjectList)
  private
    function Get(Index: Integer): TBaseObj;
    procedure Put(Index: Integer; AValue: TBaseObj);
  public
    // Создает экземпляр списка. Владеет объектами (AOwnsObjects = True),
    // что означает, что при удалении из списка или уничтожении самого списка,
    // содержащиеся в нем объекты будут автоматически освобождены.
    constructor Create;

    // Добавляет объект в список.
    function Add(AObject: TBaseObj): Integer;

    // Возвращает индекс объекта в списке.
    function IndexOf(AObject: TBaseObj): Integer;

    // Вставляет объект в список по указанному индексу.
    procedure Insert(Index: Integer; AObject: TBaseObj);

    // Позволяет обращаться к элементам списка по индексу, как к массиву.
    property Items[Index: Integer]: TBaseObj read Get write Put; default;
  end;

  // --- TBaseObj ---------------------------------------------------------------
  // Базовый иерархический объект.
  // Является основой для создания древовидных структур данных.
  // Поддерживает:
  // - Вложенность (родитель-потомок).
  // - Управление дочерними объектами.
  // - Сериализацию в XML и текстовый формат.
  // - Связь с визуальными компонентами через ImageIndex.
  TBaseObj = class(TObject)
  private
    // --- Внутренние поля ---
    FName: string;          // Уникальное имя объекта в пределах одного уровня иерархии.
    FCaption: string;       // Отображаемое имя/заголовок объекта.
    FImageIndex: Integer;   // Индекс иконки в ассоциированном TImageList. -1 = нет иконки.
    FParent: TBaseObj;      // Ссылка на родительский объект. Nil для корневого элемента.
    FChildren: TBaseObjList;// Список дочерних объектов.
    FManager: TObject;      // Ссылка на внешний менеджер объектов (пока не используется).

    // --- Приватные методы ---
    // Внутренний метод для установки родителя. Вызывается свойством Parent.
    procedure SetParent(AValue: TBaseObj);
  protected
    // --- Виртуальные методы для переопределения в наследниках ---

    // Вызывается после полной загрузки объекта из потока (например, из XML).
    // Предназначен для дополнительной инициализации.
    procedure Loaded; virtual;

    // Записывает состояние объекта (его свойства) в узел XML.
    // Вызывается рекурсивно для всей иерархии при сохранении в XML.
    procedure WriteToXMLNode(Node: TDOMNode); virtual;

    // Считывает состояние объекта из узла XML.
    procedure ReadFromXMLNode(Node: TDOMNode); virtual;

    // Записывает состояние объекта в текстовый поток с отступами.
    procedure WriteToTextStream(Stream: TStream; Indent: Integer); virtual;

  public
    // --- Конструктор и Деструктор ---

    // Создает экземпляр объекта, инициализирует поля значениями по умолчанию
    // и создает список дочерних объектов FChildren.
    constructor Create;

    // Уничтожает объект и безопасно освобождает всю иерархию дочерних объектов.
    destructor Destroy; override;

    // --- Управление иерархией ---

    // Добавляет объект AChild в список дочерних объектов.
    procedure AddChild(AChild: TBaseObj);

    // Удаляет объект AChild из списка дочерних (но не освобождает его из памяти).
    procedure RemoveChild(AChild: TBaseObj);

    // Отсоединяет текущий объект от его родителя.
    procedure Unlink;

    // Освобождает все дочерние объекты из памяти и очищает список.
    procedure ClearChildren;

    // Возвращает дочерний объект по индексу.
    function GetChild(Index: Integer): TBaseObj;

    // Возвращает количество дочерних объектов.
    function GetChildCount: Integer;

    // Ищет дочерний объект по имени.
    // AName: Имя для поиска.
    // Recursive: Если True, поиск выполняется по всему поддереву.
    function FindChildByName(const AName: string; Recursive: Boolean = False): TBaseObj;

    // Возвращает самый верхний объект в иерархии (корень дерева).
    function GetRoot: TBaseObj;

    // Проверяет, является ли текущий объект предком для объекта AnObject.
    function IsParentOf(AnObject: TBaseObj): Boolean;

    // --- Сериализация ---

    // Сохраняет объект и всю его дочернюю иерархию в XML-файл.
    procedure SaveToXML(const AFileName: string);

    // Загружает объект и его иерархию из XML-файла.
    procedure LoadFromXML(const AFileName: string);

    // Сохраняет объект и всю иерархию в XML в поток (только для корневого объекта).
    procedure SaveToXMLStream(Stream: TStream);

    // Загружает объект и его иерархию из XML из потока (только для корневого объекта).
    procedure LoadFromXMLStream(Stream: TStream);

    // Сохраняет объект и всю иерархию в текстовый файл.
    procedure SaveToText(const AFileName: string);

    // --- Свойства ---
    property Name: string read FName write FName;
    property Caption: string read FCaption write FCaption;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property Parent: TBaseObj read FParent write SetParent;
    property Children: TBaseObjList read FChildren;
  	property Manager: TObject read FManager write FManager;
  end;

implementation

{ TBaseObjList }

constructor TBaseObjList.Create;
begin
  // True в конструкторе родителя означает, что список "владеет" объектами.
  // Он будет автоматически вызывать их деструкторы при очистке (Clear) или
  // при собственном уничтожении.
  inherited Create(True);
end;

function TBaseObjList.Get(Index: Integer): TBaseObj;
begin
  // Унаследованный GetItem возвращает TObject, приводим его к нашему типу.
  Result := TBaseObj(inherited GetItem(Index));
end;

procedure TBaseObjList.Put(Index: Integer; AValue: TBaseObj);
begin
  // Унаследованный SetItem принимает TObject.
  inherited SetItem(Index, AValue);
end;

function TBaseObjList.Add(AObject: TBaseObj): Integer;
begin
  Result := inherited Add(AObject);
end;

function TBaseObjList.IndexOf(AObject: TBaseObj): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TBaseObjList.Insert(Index: Integer; AObject: TBaseObj);
begin
  inherited Insert(Index, AObject);
end;

{ TBaseObj }

constructor TBaseObj.Create;
begin
  inherited Create;
  FName := Self.ClassName;
  FCaption := Self.ClassName;
  FImageIndex := -1; // -1 означает "нет иконки"
  FChildren := TBaseObjList.Create;
end;

destructor TBaseObj.Destroy;
var
  i: Integer;
begin
  // Этот деструктор реализует безопасное рекурсивное уничтожение дерева.
  // Проблема: если просто освобождать список FChildren, который владеет объектами,
  // то при уничтожении дочернего объекта он попытается отсоединиться от родителя (Self),
  // чей список FChildren в этот момент уже находится в процессе итерации для удаления.
  // Это приводит к ошибке "Access Violation".

  // Решение: перед уничтожением списка мы проходим по всем детям и обнуляем
  // их ссылку на родителя.
  if FChildren <> nil then
  begin
    for i := 0 to FChildren.Count - 1 do
      TBaseObj(FChildren.Items[i]).FParent := nil;
  end;

  // Теперь, когда все дочерние элементы "отсоединены", можно безопасно
  // освободить список. При уничтожении дочерних объектов их метод Unlink
  // ничего не сделает, так как ссылка FParent у них теперь nil.
  FreeAndNil(FChildren);

  // В самом конце отсоединяем сам объект от его родителя (если он есть).
  Unlink;

  inherited Destroy;
end;

procedure TBaseObj.SetParent(AValue: TBaseObj);
begin
  // Процедура смены родителя.
  if FParent <> AValue then
  begin
    // 1. Отсоединяемся от старого родителя.
    Unlink;
    // 2. Если новый родитель указан, добавляемся к нему в дочерние.
    if AValue <> nil then
      AValue.AddChild(Self);
  end;
end;

procedure TBaseObj.AddChild(AChild: TBaseObj);
begin
  if (AChild <> nil) and (AChild.Parent <> Self) then
  begin
    // Отсоединяем от старого родителя перед добавлением к новому.
    AChild.Unlink;
    FChildren.Add(AChild);
    AChild.FParent := Self;
  end;
end;

procedure TBaseObj.RemoveChild(AChild: TBaseObj);
begin
  if (AChild <> nil) and (AChild.Parent = Self) then
  begin
    AChild.FParent := nil;
    // Remove извлекает объект из списка, но не освобождает память,
    // даже если список владеет объектами.
    FChildren.Remove(AChild);
  end;
end;

procedure TBaseObj.Unlink;
begin
  // Отсоединение от родителя.
  if FParent <> nil then
  begin
    // Используем FParent.FChildren.Remove, так как FParent.RemoveChild
    // снова установит FParent в nil, что здесь не нужно.
    FParent.FChildren.Remove(Self);
    FParent := nil;
  end;
end;

procedure TBaseObj.ClearChildren;
begin
  // Clear для TObjectList с OwnsObjects=True вызывает деструкторы
  // для всех элементов списка, что обеспечивает рекурсивное уничтожение поддерева.
  FChildren.Clear;
end;

function TBaseObj.GetChild(Index: Integer): TBaseObj;
begin
  Result := FChildren[Index];
end;

function TBaseObj.GetChildCount: Integer;
begin
  Result := FChildren.Count;
end;

function TBaseObj.FindChildByName(const AName: string; Recursive: Boolean): TBaseObj;
var
  i: Integer;
  TempObj: TBaseObj;
begin
  Result := nil;
  for i := 0 to GetChildCount - 1 do
  begin
    TempObj := GetChild(i);
    if CompareText(TempObj.Name, AName) = 0 then
    begin
      Result := TempObj;
      Exit;
    end;
    if Recursive then
    begin
      Result := TempObj.FindChildByName(AName, True);
      if Result <> nil then
        Exit;
    end;
  end;
end;

function TBaseObj.GetRoot: TBaseObj;
begin
  Result := Self;
  while Result.FParent <> nil do
    Result := Result.FParent;
end;

function TBaseObj.IsParentOf(AnObject: TBaseObj): Boolean;
var
  TempParent: TBaseObj;
begin
  Result := False;
  if AnObject = nil then Exit;
  TempParent := AnObject.Parent;
  while TempParent <> nil do
  begin
    if TempParent = Self then
    begin
      Result := True;
      Exit;
    end;
    TempParent := TempParent.Parent;
  end;
end;

procedure TBaseObj.Loaded;
begin
  // Заглушка. Может быть переопределена в классах-наследниках
  // для выполнения действий после загрузки данных из файла.
end;

procedure TBaseObj.WriteToXMLNode(Node: TDOMNode);
var
  i: Integer;
  ChildNode: TDOMNode;
begin
  // Сохраняем основные свойства как атрибуты XML-узла.
  (Node as TDOMElement).SetAttribute('Name', Self.Name);
  (Node as TDOMElement).SetAttribute('Caption', Self.Caption);
  (Node as TDOMElement).SetAttribute('ImageIndex', IntToStr(Self.ImageIndex));
  (Node as TDOMElement).SetAttribute('ClassName', Self.ClassName);

  // Рекурсивно сохраняем все дочерние объекты.
  for i := 0 to GetChildCount - 1 do
  begin
    ChildNode := Node.OwnerDocument.CreateElement('Object');
    Node.AppendChild(ChildNode);
    GetChild(i).WriteToXMLNode(ChildNode);
  end;
end;

procedure TBaseObj.ReadFromXMLNode(Node: TDOMNode);
var
  i: Integer;
  ChildNode: TDOMNode;
  NewObj: TBaseObj;
  lClassName: string;
  ChildClass: TClass;
begin
  // Считываем свойства из атрибутов.
  if (Node as TDOMElement).HasAttribute('Name') then
    Self.FName := (Node as TDOMElement).GetAttribute('Name');
  if (Node as TDOMElement).HasAttribute('Caption') then
    Self.FCaption := (Node as TDOMElement).GetAttribute('Caption');
  if (Node as TDOMElement).HasAttribute('ImageIndex') then
    Self.FImageIndex := StrToIntDef((Node as TDOMElement).GetAttribute('ImageIndex'), -1);

  // Рекурсивно считываем и создаем дочерние объекты.
  ChildNode := Node.FirstChild;
  while ChildNode <> nil do
  begin
    if (ChildNode.NodeType = ELEMENT_NODE) and (ChildNode.NodeName = 'Object') then
    begin
      // Для воссоздания объекта нужного класса требуется, чтобы
      // классы были зарегистрированы (например, через RegisterClass).
      lClassName := (ChildNode as TDOMElement).GetAttribute('ClassName');
      ChildClass := GetClass(lClassName);
      if ChildClass <> nil then
      begin
        NewObj := TBaseObj(ChildClass.Create);
        AddChild(NewObj);
        NewObj.ReadFromXMLNode(ChildNode);
      end;
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TBaseObj.SaveToXML(const AFileName: string);
var
  XMLDoc: TXMLDocument;
  RootNode: TDOMNode;
  FS: TFileStream;
begin
  // Сохранение может быть инициировано только для корневого элемента.
  if Parent <> nil then
  begin
    GetRoot.SaveToXML(AFileName);
    Exit;
  end;

  XMLDoc := TXMLDocument.Create;
  try
    RootNode := XMLDoc.CreateElement('Root');
    XMLDoc.AppendChild(RootNode);
    WriteToXMLNode(RootNode);
    FS := TFileStream.Create(AFileName, fmCreate);
    try
      // WriteXMLFile из laz2_xmlwrite принимает поток, а не имя файла.
      WriteXMLFile(XMLDoc, FS);
    finally
      FS.Free;
    end;
  finally
    XMLDoc.Free;
  end;
end;

procedure TBaseObj.LoadFromXML(const AFileName: string);
var
  XMLDoc: TXMLDocument;
  RootNode: TDOMNode;
begin
  // Загрузка может быть инициирована только для корневого элемента.
  if Parent <> nil then
  begin
    raise Exception.Create('LoadFromXML can only be called on a root object.');
  end;

  ReadXMLFile(XMLDoc, AFileName);
  try
    RootNode := XMLDoc.DocumentElement;
    if (RootNode <> nil) and (RootNode.NodeName = 'Root') then
    begin
      ClearChildren;
      ReadFromXMLNode(RootNode);
      Loaded; // Вызываем после полной загрузки.
    end;
  finally
    XMLDoc.Free;
  end;
end;

procedure TBaseObj.SaveToXMLStream(Stream: TStream);
var
  XMLDoc: TXMLDocument;
  RootNode: TDOMNode;
begin
  if Parent <> nil then
  begin
    GetRoot.SaveToXMLStream(Stream);
    Exit;
  end;

  XMLDoc := TXMLDocument.Create;
  try
    RootNode := XMLDoc.CreateElement('Root');
    XMLDoc.AppendChild(RootNode);
    WriteToXMLNode(RootNode);
    WriteXMLFile(XMLDoc, Stream);
  finally
    XMLDoc.Free;
  end;
end;

procedure TBaseObj.LoadFromXMLStream(Stream: TStream);
var
  XMLDoc: TXMLDocument;
  RootNode: TDOMNode;
  TempFileName: string;
  FS: TFileStream;
begin
  if Parent <> nil then
  begin
    raise Exception.Create('LoadFromXMLStream can only be called on a root object.');
  end;

  TempFileName := GetTempFileName('', 'xml');
  try
    Stream.Position := 0;
    FS := TFileStream.Create(TempFileName, fmCreate);
    try
      FS.CopyFrom(Stream, Stream.Size);
    finally
      FS.Free;
    end;
    ReadXMLFile(XMLDoc, TempFileName);
    try
      RootNode := XMLDoc.DocumentElement;
      if (RootNode <> nil) and (RootNode.NodeName = 'Root') then
      begin
        ClearChildren;
        ReadFromXMLNode(RootNode);
        Loaded;
      end;
    finally
      XMLDoc.Free;
    end;
  finally
    if FileExists(TempFileName) then
      DeleteFile(TempFileName);
  end;
end;

procedure TBaseObj.WriteToTextStream(Stream: TStream; Indent: Integer);
var
  i: Integer;
  Line: string;
  Prefix: string;
begin
  Prefix := StringOfChar(' ', Indent * 2);
  Line := Prefix + 'ClassName=' + Self.ClassName + sLineBreak;
  Stream.Write(Line[1], Length(Line));
  Line := Prefix + 'Name=' + Name + sLineBreak;
  Stream.Write(Line[1], Length(Line));
  Line := Prefix + 'Caption=' + Caption + sLineBreak;
  Stream.Write(Line[1], Length(Line));
  Line := Prefix + 'ImageIndex=' + IntToStr(ImageIndex) + sLineBreak;
  Stream.Write(Line[1], Length(Line));

  for i := 0 to GetChildCount - 1 do
  begin
    GetChild(i).WriteToTextStream(Stream, Indent + 1);
  end;
end;

procedure TBaseObj.SaveToText(const AFileName: string);
var
  FS: TFileStream;
begin
  if Parent <> nil then
  begin
    GetRoot.SaveToText(AFileName);
    Exit;
  end;

  FS := TFileStream.Create(AFileName, fmCreate);
  try
    WriteToTextStream(FS, 0);
  finally
    FS.Free;
  end;
end;

end.