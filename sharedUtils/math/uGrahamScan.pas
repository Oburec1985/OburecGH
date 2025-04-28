unit uGrahamScan;

interface
uses
  SysUtils, Math, uCommonMath, ucommontypes;


  function GrahamScan(points: pointsArray; p_size:integer): pointsArray;
  procedure SortForGrahamScan(var points: pointsArray; var bottom:point2);
  procedure FindDiameter(const hull: pointsArray; var p1, p2: point2;
            var maxDist: Double);
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

procedure SortForGrahamScan(var points: pointsArray; var bottom:point2);
var
  n, i, pivotIdx: Integer;
begin
  n := Length(points);
  if n < 2 then
    Exit;

  // Ќаходим опорную точку
  pivotIdx := 0;
  for i := 1 to n - 1 do
    if (points[i].y < points[pivotIdx].y) or
       ((points[i].y = points[pivotIdx].y) and (points[i].x < points[pivotIdx].x)) then
      pivotIdx := i;

  // ”станавливаем опорную точку в глобальную переменную
  Pivot := points[pivotIdx];
  bottom:=Pivot;

  // ѕеремещаем опорную точку в начало
  if pivotIdx <> 0 then
  begin
    points[pivotIdx] := points[0];
    points[0] := Pivot;
  end;

  // —ортируем точки, начина€ с индекса 1
  QuickSort(points, 1, n - 1);
end;







function ComparePoints2(const p1, p2: point2): Integer;
begin
  if p1.x < p2.x then
    Result := -1
  else if p1.x > p2.x then
    Result := 1
  else if p1.y < p2.y then
    Result := -1
  else if p1.y > p2.y then
    Result := 1
  else
    Result := 0;
end;

function Orientation2(p, q, r: point2): Integer;
var
  val: Double;
begin
  val := (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
  if Abs(val) < 1e-10 then
    Result := 0
  else if val > 0 then
    Result := 1
  else
    Result := -1;
end;

function Distance(p1, p2: point2): Double;
begin
  Result := Sqrt(Sqr(p2.x - p1.x) + Sqr(p2.y - p1.y));
end;

function GrahamScan(points: pointsArray; p_size:integer): pointsArray;
var
  n, m, i: Integer;
  bottom: point2;
  sortedPoints: pointsArray;
  stack: pointsArray;
begin
  n := p_size;
  if n < 3 then
  begin
    Result := points;
    Exit;
  end;
  SetLength(sortedPoints, n);
  move(points[0], sortedPoints[0], p_size*sizeof(point2));
  // Sort points by polar angle

  SortForGrahamScan(sortedPoints, bottom);

  // Graham scan
  SetLength(stack, n);
  stack[0] := bottom;
  stack[1] := sortedPoints[0];
  m := 2;

  for i := 1 to n - 1 do
  begin
    if ComparePoints2(sortedPoints[i], bottom) = 0 then
      Continue;
    while (m >= 2) and (Orientation2(stack[m-2], stack[m-1], sortedPoints[i]) <= 0) do
      Dec(m);
    stack[m] := sortedPoints[i];
    Inc(m);
  end;

  SetLength(stack, m);
  Result := stack;
end;

procedure FindDiameter(const hull: pointsarray; var p1, p2: point2;
          var maxDist: Double);
var
  n, i, j, k: Integer;
  dist: Double;
begin
  n := Length(hull);
  if n < 2 then
  begin
    maxDist := 0;
    Exit;
  end;

  maxDist := 0;
  j := 1;

  for i := 0 to n - 1 do
  begin
    k := (j + 1) mod n;
    while True do
    begin
      dist := Distance(hull[i], hull[j]);
      if dist > maxDist then
      begin
        maxDist := dist;
        p1 := hull[i];
        p2 := hull[j];
      end;

      if Distance(hull[i], hull[k]) > dist then
        j := k
      else
        Break;
      k := (k + 1) mod n;
    end;
  end;
end;

 
end.
