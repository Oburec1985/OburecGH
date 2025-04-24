unit uGrahamScan2;

interface

uses
  SysUtils, Math, uCommonMath, ucommontypes;


procedure SortForGrahamScan(var points: pointsArray);

implementation

var
  Pivot: point2;

function Orientation(a, b, c: point2): Integer;
var
  val: Double;
begin
  val := (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y);
  if Abs(val) < 1e-10 then
    Result := 0
  else if val > 0 then
    Result := 1
  else
    Result := -1;
end;

function ComparePoints(const p, q: point2): Integer;
var
  orien: Integer;
  dist_p, dist_q: Double;
begin
  orien := Orientation(Pivot, p, q);
  if orien = 0 then
  begin
    dist_p := Sqr(p.x - Pivot.x) + Sqr(p.y - Pivot.y);
    dist_q := Sqr(q.x - Pivot.x) + Sqr(q.y - Pivot.y);
    if dist_p < dist_q then
      Result := -1
    else if dist_p > dist_q then
      Result := 1
    else
      Result := 0;
  end
  else if orien > 0 then
    Result := -1
  else
    Result := 1;
end;

procedure QuickSort(var points: pointsArray; left, right: Integer);
var
  i, j: Integer;
  pivot: point2;
  temp: point2;
begin
  if left < right then
  begin
    i := left;
    j := right;
    pivot := points[(left + right) div 2];
    repeat
      while ComparePoints(points[i], pivot) < 0 do
        Inc(i);
      while ComparePoints(points[j], pivot) > 0 do
        Dec(j);
      if i <= j then
      begin
        temp := points[i];
        points[i] := points[j];
        points[j] := temp;
        Inc(i);
        Dec(j);
      end;
    until i > j;
    QuickSort(points, left, j);
    QuickSort(points, i, right);
  end;
end;

procedure SortForGrahamScan(var points: pointsArray);
var
  n, i, pivotIdx: Integer;
begin
  n := Length(points);
  if n < 2 then
    Exit;

  // Находим опорную точку
  pivotIdx := 0;
  for i := 1 to n - 1 do
    if (points[i].y < points[pivotIdx].y) or
       ((points[i].y = points[pivotIdx].y) and (points[i].x < points[pivotIdx].x)) then
      pivotIdx := i;

  // Устанавливаем опорную точку в глобальную переменную
  Pivot := points[pivotIdx];

  // Перемещаем опорную точку в начало
  if pivotIdx <> 0 then
  begin
    points[pivotIdx] := points[0];
    points[0] := Pivot;
  end;

  // Сортируем точки, начиная с индекса 1
  QuickSort(points, 1, n - 1);
end;

end.