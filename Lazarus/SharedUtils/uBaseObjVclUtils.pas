unit uBaseObjVclUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, uBaseObjLaz;

// --- Аннотации ---
// Рекурсивно добавляет узлы из иерархии TBaseObj в TTreeView.
//
// Параметры:
//   ATreeView: TTreeView - Компонент TTreeView для заполнения.
//   AParentNode: TTreeNode - Родительский узел в TTreeView.
//   ABaseObj: TBaseObj - Объект TBaseObj для добавления в дерево.
procedure AddNodeToTreeView(ATreeView: TTreeView; AParentNode: TTreeNode; ABaseObj: TBaseObj);

// Отображает иерархию объектов TBaseObj в компоненте TTreeView.
//
// Параметры:
//   ATreeView: TTreeView - Компонент для отображения дерева.
//   ARootNode: TBaseObj - Корневой узел иерархии для отображения.
procedure BaseObjToTreeView(ATreeView: TTreeView; ARootNode: TBaseObj);

implementation

procedure AddNodeToTreeView(ATreeView: TTreeView; AParentNode: TTreeNode; ABaseObj: TBaseObj);
var
  i: Integer;
  NewNode: TTreeNode;
begin
  // Добавляем текущий объект как узел дерева
  NewNode := ATreeView.Items.AddChild(AParentNode, ABaseObj.Caption);
  NewNode.Data := ABaseObj; // Сохраняем ссылку на объект в узле
  NewNode.ImageIndex := ABaseObj.ImageIndex;
  NewNode.SelectedIndex := ABaseObj.ImageIndex;

  // Рекурсивно добавляем всех потомков
  for i := 0 to ABaseObj.GetChildCount - 1 do
  begin
    AddNodeToTreeView(ATreeView, NewNode, ABaseObj.GetChild(i));
  end;
end;

procedure BaseObjToTreeView(ATreeView: TTreeView; ARootNode: TBaseObj);
begin
  if (ATreeView = nil) or (ARootNode = nil) then
    Exit;

  ATreeView.Items.BeginUpdate;
  try
    ATreeView.Items.Clear;
    // Начинаем рекурсивный обход с корневого элемента
    AddNodeToTreeView(ATreeView, nil, ARootNode);
    ATreeView.FullExpand;
  finally
    ATreeView.Items.EndUpdate;
  end;
end;

end.
