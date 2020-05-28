unit uQueue;

interface
uses
  ucommontypes;

type
  cP2dQueue = class
  protected
    data: array of point2d;
  public
    // Добавить (положить) в начало дека новый элемент
    procedure push_front

    push_back
    Добавить (положить) в конец дека новый элемент
    pop_front
    Извлечь из дека первый элемент
    pop_back
    Извлечь из дека последний элемент
    front
    Узнать значение первого элемента (не удаляя его)
    back
    Узнать значение последнего элемента (не удаляя его)
    size
    Узнать количество элементов в деке
    clear
    Очистить дек (удалить из него все элементы)
  end;

implementation

end.
