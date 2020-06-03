unit uCommonTypes;

interface
uses classes, types, windows;

type
  cpoint2d = class
  public
    x,y:double;
  end;

  point2 = record
    x,y:single;
  end;

  point2i2 = record
    x,y:int16;
  end;

  pPoint2d = ^point2d;

  point2d = record
    x,y:double;
  end;

  pointsArray = array of point2;

  point3=record
    x,
    y,
    z:single;
  end;

  point3d=record
    x,
    y,
    z:double;
  end;


  fRect = record
    BottomLeft: Point2;
    TopRight: Point2;
  end;

  fRectd = record
    BottomLeft: Point2d;
    TopRight: Point2d;
  end;

  sMouseStruct =record
    // левая клавиша мыши нажата
    mousedown:boolean;
    // оконные координаты мыши
    iPos:tpoint;
    // координаты на момент начала перетягивания мыши
    DragBegginPos:tpoint;
    // оконные инвертированные координаты мыши
    iPos_inv:tpoint;
    // положение курсора в координатах вьюпорта. Положение именно в координатах
    // страницы на которую наведена мышь
    pos:point2;
    // координаты тренда при условии активной оси
    activeAxisPos:point2;
    // смещение мыши в координатах окна
    strafe:point2;
    // смещение мыши в координатах тренда
    activeaxisstrafe:point2d;
    // shift
    vk_shift:boolean;
  end;

const
  c_carret = #13#10;
  cllightGreen=$0000FF80;

  axisX:point3 = (x:1;y:0;z:0);
  axisY:point3 = (x:0;y:1;z:0);
  axisZ:point3 = (x:0;y:0;z:1);
  axisO:point3 = (x:0;y:0;z:0);

  red:point3 = (x:1;y:0;z:0);
  green:point3 = (x:0;y:1;z:0);
  blue:point3 = (x:0;y:0;z:1);
  black:point3 = (x:0;y:0;z:0);
  brightyellow:point3 = (x:1;y:1;z:0.5);
  yellow:point3 = (x:1;y:1;z:0);
  purple:point3 = (x:0.25098;y:0.03921;z:0.021729);
  acid:point3 = (x:0.35294;y:0.93725;z:0.003137);
  bRIGHTbLUE:point3 = (x:0.0862745;y:0.08235294;z:0.827450980);
  Orange:point3 = (x:0.85490196;y:0.55686274;z:0.0862745);
  violet:point3 = (x:0.298039215;y:0.3294117647;z:0.61960784313);
  Lilac:point3 = (x:0.88627450980;y:0.06274509803;z:0.78039215686);
  white:point3 = (x:1;y:1;z:1);
  gray:point3 = (x:0.6;y:0.6;z:0.6);
  Brightgray:point3 = (x:0.8;y:0.8;z:0.8);
  // https://en.wikipedia.org/wiki/List_of_colors:_A%E2%80%93F
  Aero:point3 = (x:0.49;y:0.73;z:0.91);
  AlienArmpit:point3 = (x:0.77;y:0.88;z:0.48);
  Amazon:point3 = (x:0.23;y:0.48;z:0.34);
  AntiqueRuby:point3 = (x:0.52;y:0.11;z:0.18);
  BarbiePink:point3 = (x:0.91;y:0.25;z:0.59);
  Bittersweet:point3 = (x:0.100;y:0.44;z:0.37);
  BrickRed:point3 = (x:0.80;y:0.25;z:0.33);
  CadmiumRed:point3 = (x:0.89;y:0.00;z:0.13);
  Cerulean:point3 = (x:0.00;y:0.48;z:0.65);
  Citron:point3 = (x:0.62;y:0.66;z:0.12);

  ColorArray:  array[0..17] of point3 = ((x:0;y:0;z:1), // blue
                                        (x:0;y:1;z:0), // green
                                        (x:1;y:0;z:0), // red
                                        (x:0.85490196;y:0.55686274;z:0.0862745), // orange
                                        (x:0.25098;y:0.03921;z:0.021729), // purple
                                        (x:0.35294;y:0.93725;z:0.003137), // acid
                                        (x:0.298039215;y:0.3294117647;z:0.61960784313), //violet
                                        (x:0.88627450980;y:0.06274509803;z:0.78039215686), // Lilac
                                        (x:0.49;y:0.73;z:0.91),   //Aero
                                        (x:0.77;y:0.88;z:0.48),  // AlienArmpit
                                        (x:0.23;y:0.48;z:0.34),  // Amazon
                                        (x:0.52;y:0.11;z:0.18),   // AntiqueRuby
                                        (x:0.91;y:0.25;z:0.59),    //BarbiePink
                                        (x:0.100;y:0.44;z:0.37), // Bittersweet
                                        (x:0.80;y:0.25;z:0.33),    // BrickRed
                                        (x:0.89;y:0.00;z:0.13),  // CadmiumRed
                                        (x:0.00;y:0.48;z:0.65), //Cerulean
                                        (x:0.62;y:0.66;z:0.12) //Citron
                                        );
  // , [red], [Orange], [purple], [acid], [violet], [Lilac]);


function p2(x,y:single):point2;
function p2d(x,y:double):point2d;
function p2top2d(p:point2):point2d;
function p3(x,y,z:single):point3;
function summP2(p1,p2:point2):point2;
function summP2d(p1,p2:point2d):point2d;
function DecP2(p0,p1:point2):point2;

function AltKeyDown : boolean;
function CtrlKeyDown : boolean;
function ShiftKeyDown : boolean;
function CapsLock : boolean;
function InsertOn : boolean;
function NumLock : boolean;

function ScrollLock : boolean;

implementation

function AltKeyDown : boolean;
begin
 result:=(Word(GetAsyncKeyState(VK_MENU)) and $8000)<>0;
end;

function CtrlKeyDown : boolean;
begin
 result:=(Word(GetAsyncKeyState(VK_CONTROL)) and $8000)<>0;
end;

function ShiftKeyDown : boolean;
begin
 result:=(Word(GetAsyncKeyState(VK_SHIFT)) and $8000)<>0;
end;

function CapsLock : boolean;
begin
 result:=(GetAsyncKeyState(VK_CAPITAL) and 1)<>0;
end;

function InsertOn : boolean;
begin
 result:=(GetAsyncKeyState(VK_INSERT) and 1)<>0;
end;

function NumLock : boolean;
begin
 result:=(GetAsyncKeyState(VK_NUMLOCK) and 1)<>0;
end;

function ScrollLock : boolean;
begin
 result:=(GetAsyncKeyState(VK_SCROLL) and 1)<>0;
end;


function DecP2(p0,p1:point2):point2;
begin
  result:=p2((p0.x-p1.x),(p0.y-p1.y));
end;

function summP2(p1,p2:point2):point2;
begin
  result.y:=p1.y+p2.y;
  result.x:=p1.x+p2.x;
end;

function summP2d(p1,p2:point2d):point2d;
begin
  result.y:=p1.y+p2.y;
  result.x:=p1.x+p2.x;
end;

function p2(x,y:single):point2;
begin
  result.x:=x;
  result.y:=y;
end;

function p2d(x,y:double):point2d;
begin
  result.x:=x;
  result.y:=y;
end;

function p2top2d(p:point2):point2d;
begin
  result:=p2d(p.x,p.y);
end;

function p3(x,y,z:single):point3;
begin
  result.x:=x;
  result.y:=y;
  result.z:=z;
end;

end.
