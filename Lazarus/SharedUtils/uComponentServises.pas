unit uComponentServises;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, 
  {$IFDEF FPC}
  ComCtrls,
  {$ELSE}
  Vcl.ComCtrls,
  {$ENDIF}
  uBaseClass;

// Функции отрисовки базового объекта
function SyncToTreeView(AObj: TBaseObj; ATreeView: TTreeView; AParentNode: TTreeNode = nil): TTreeNode;
procedure SyncFromTreeView(AObj: TBaseObj; ATreeView: TTreeView; ANode: TTreeNode);

implementation

function SyncToTreeView(AObj: TBaseObj; ATreeView: TTreeView; AParentNode: TTreeNode): TTreeNode;
var
  li: Integer;
begin
  Result := ATreeView.Items.AddChildObject(AParentNode, AObj.Caption, AObj);
  Result.ImageIndex := AObj.ImageIndex;
  Result.SelectedIndex := AObj.ImageIndex;
  AObj.Data := Result; // Связываем узел дерева с нашим объектом

  for li := 0 to AObj.ChildCount - 1 do
    SyncToTreeView(AObj[li], ATreeView, Result);
end;

procedure SyncFromTreeView(AObj: TBaseObj; ATreeView: TTreeView; ANode: TTreeNode);
var
  lChildNode: TTreeNode;
begin
  if not Assigned(ANode) then
    Exit;

  if Assigned(ANode.Data) and (TObject(ANode.Data) = AObj) then
    AObj.Selected := ANode.Selected;

  lChildNode := ANode.GetFirstChild;
  while Assigned(lChildNode) do
  begin
    if Assigned(lChildNode.Data) and (TObject(lChildNode.Data) is TBaseObj) then
      SyncFromTreeView(TBaseObj(lChildNode.Data), ATreeView, lChildNode);
    lChildNode := lChildNode.GetNextSibling;
  end;
end;

end.
