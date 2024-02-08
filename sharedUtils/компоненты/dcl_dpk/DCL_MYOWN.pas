unit DCL_MYOWN;
//{$R myDCLbitmap.res } //прикомпиллируем ресурсы-картинки
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,extctrls,Math, uBtnListView, uSpin, uAlignEdit, uVTServices,
  rkVistaProBar, uStringGridExt;

type  //-----------------------------------------------//
  TFloatEdit = class(TEdit)
  private
    { Private declarations }
      function Point_or_Comma(str: string):string;
      function GNumb:Single;
      procedure SNumb(flt:Single);
  protected
    { Protected declarations }
      procedure Change; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property FloatNum: Single read GNumb write SNumb;
    property OnChange;
  published
    { Published declarations }
  end; //------------TFloatEdit------------------------//


type //--------------------------------------------------//
  TIntEdit = class(TEdit)
  private
    // Private declarations
      function GeNumb:Integer;
      procedure SeNumb(intg:Integer);

  protected
    // Protected declarations                            
      procedure Change; override;

  public
    // Public declarations
    constructor Create(AOwner: TComponent); override;
    property IntNum: Integer read GeNumb write SeNumb;
    property OnChange;
  published
    // Published declarations
  end;//-------------------------------------------------//

type //-----------------------------------------------------//
  TmodScrollBar = class(TScrollBar)                         //
  private                                                   //
    // Private declarations                                 //
                                                            //
  protected                                                 //
    // Protected declarations                               //
                                                            //
  public                                                    //
    // Public declarations                                  //
    constructor Create(AOwner: TComponent); override;       //
    procedure MorePage(Sender: TObject; Shift: TShiftState; //
                    MousePos: TPoint; var Handled: Boolean);//
                                                            //
                                                            //
    procedure LessPage(Sender: TObject; Shift: TShiftState; //
                    MousePos: TPoint; var Handled: Boolean);//
  published                                                 //
    // Published declarations                               //
  end;//----------------------------------------------------//


   type//----------------------------------------------------------------//
     TLamp=class(TCustomControl)
     private
    // Private declarations
     HInst:THandle;
     BitMapOn, BitMapOff,WorkMap:TBitmap;
     FState:Boolean;
     FColor:Single;
     Procedure SetState(st:Boolean);
  protected
     Procedure Paint;override;
  public
   procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);override;
   constructor Create(AOwner:TComponent); override;
   destructor Destroy; override;
   procedure ChangeState;
  published
    // Published declarations
   property State :Boolean read FState  write SetState; 
   property Color :single read FColor  write FColor; //
end;//------------------------------------------------//

type//------------------------------------------------------------------//
     TSMeterDcl=class(TCustomControl)                                      //
     private                                                            //
    // Private declarations                                             //
     HInst:THandle;                                                     //
     ResMap,pict,WorkMap:TBitmap;                                       //
     Fi:Extended;//угол стрелки от 0 до 3Pi2/2                          //
     Len:Extended;//длина в пикселах                                    //
     fMin:Single;                                                       //
     fMax:Single;                                                       //
     fValue:Single;                                                     //
     Procedure SetMin(mn:Single);                                       //
     Procedure SetMax(mx:Single);                                       //
     Procedure SetValue(vl:Single);                                     //
     Procedure Scale(Pict:TBitMap);                                     //
     procedure Arrow(Pct:TBitMap);                                     //
  protected                                                             //
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);override;//
    procedure Paint;override;                                           //
  public                                                                //
    // Public declarations                                              //
  constructor Create(AOwner:TComponent);override;                       //
  destructor Destroy; override;                                         //
                                                                        //
  published                                                             //
    // Published declarations                                           //
  property Min :Single read FMin  write SetMin;                         //
  property Max :Single read FMax  write SetMax;                         //
  property Value :Single read FValue  write SetValue;                   //
end;//--------------------------SMeter----------------------------------//





procedure Register;



implementation

///////////////////////// для TFloatEdit /////////////////////////////////////////////

constructor TFloatEdit.Create(AOwner: TComponent);//----//
begin                                                   //
   inherited Create(AOwner);                            //
   Text:='0.0';                                         //
end; //-------Новый конструктор-------------------------//

function TFloatEdit.Point_or_Comma(str: string):string;//-//
var ppoint :Pchar;                                        //
begin                                                     //
ppoint:= StrScan(PChar(str),'.');                         //
if assigned(ppoint)then ppoint^:=DecimalSeparator         //
else begin                                                //
      ppoint:= StrScan(PChar(str),',');                   //
       if assigned(ppoint)then ppoint^:=DecimalSeparator; //
     end;                                                 //
Result:=str;                                              //
end;//--------Point_or_Comma------------------------------//

function TFloatEdit.GNumb: Single; //----//
begin                                    //
   if Text='' then Text:='0';            //
Result:=StrToFloat(Point_or_Comma(Text));//
end;//-----------------------------------//

procedure TFloatEdit.SNumb(flt:Single); //
begin                                   //
Text:=FloatToStrF(flt,ffGeneral,5,3);   //
//Text:=FormatFloat('0.000E+00',flt);   //
end;//----------------------------------//

procedure TFloatEdit.Change; //--убирает не числовые значения----------------//
var i: Integer; ch:Char;                                                     //
begin                                                                        //
  i:=Length(Text);                                                           //
  while i>0 do                                                               //
     begin                                                                   //
       ch:=Text[i];                                                        //
       if (ch<'0') or (ch>'9') then                                        //
        if (ch<>'-')and (ch<>'+')and(ch<>'.')and(ch<>',')and (ch<>'E') then//
          begin                                                            //
            beep;beep;beep;beep;beep;                                    //
            SelStart:=i-1;  SelLength:=1; ClearSelection;                //
             beep;beep;beep;beep;                                        //
          end;                                                             //
          Dec(i);                                                          //
     end;
   inherited change;                                                           //
end;//--------------Change-метод вызываемый при взменении текста-------------//

///////////////////////// для TIntEdit /////////////////////////////////////////////

constructor TIntEdit.Create(AOwner: TComponent);//------//
begin                                                   //
   inherited Create(AOwner);                            //
   Text:='000';                                         //
end; //-------Новый конструктор-------------------------//


function TIntEdit.GeNumb: Integer;  //---//
begin                                    //
   if Text='' then Text:='0';            //
   Result:=StrToInt(Text);               //
end;//-----------------------------------//

procedure TIntEdit.SeNumb(intg :Integer); //
begin                                     //
Text:=IntToStr(intg);                     //
end;//------------------------------------//

procedure TIntEdit.Change; //--убирает не числовые значения-----//
var i: Integer; ch:Char;
begin
  i:=Length(Text);
  while i>0 do
     begin
       ch:=Text[i];
       if (ch<'0') or (ch>'9') then
        if (ch<>'-')and (ch<>'+') then
          begin
            beep;beep;beep;beep;beep;
            SelStart:=i-1;  SelLength:=1; ClearSelection;
             beep;beep;beep;beep;
          end;
          Dec(i);
     end;
     inherited Change;
end;//--Change-метод вызываемый при взменении текста------------//

//////////////////// для TmodScrollBar////////////////////////////////////

constructor TmodScrollBar.Create(AOwner: TComponent);//-//
begin                                                   //
   inherited Create(AOwner);                            //
   Position:=Min; PageSize:=Max;                        //
   OnMouseWheelDown:=  LessPage;                        //
   OnMouseWheelUp:=    MorePage;                        //
   TabStop:=True;                                       //
                                                        //
end; //-------Новый конструктор-------------------------//


procedure TmodScrollBar.MorePage(Sender: TObject; Shift: TShiftState;//---------------//
    MousePos: TPoint; var Handled: Boolean);                                          //
var x1,x2,y1,y2,pstn:Integer;                                                         //
begin                                                                                 //
Handled:=True;                                                                        //
if Sender = Self then                                                                 //
  begin                                                                               //
    x1:= ClientOrigin.x; y1:= ClientOrigin.y; x2:= x1 + Width;  y2:= y1 + Height;   //
    if (MousePos.x > x1)and(MousePos.x < x2)and(MousePos.y > y1)and(MousePos.y < y2)//
     then   if (Position + PageSize)<(Max-SmallChange)                              //
                  then                                                              //
                       begin                                                        //
                         PageSize:=PageSize+SmallChange;                          //
                         RecreateWnd;                                             //
                         Scroll(scPageUp, pstn);                                  //
                       end                                                          //
                   else PageSize:=Max-Position;                                     //
  end;                                                                                //
end;//--------------------MorePage----------------------------------------------------//


procedure TmodScrollBar.LessPage(Sender: TObject; Shift: TShiftState;//---------------//
    MousePos: TPoint; var Handled: Boolean);                                          //
var x1,x2,y1,y2,pstn:Integer;                                                         //
begin                                                                                 //
Handled:=True;                                                                        //
if Sender = Self then                                                                 //
  begin                                                                               //
    x1:= ClientOrigin.x; y1:= ClientOrigin.y; x2:= x1 + Width;  y2:= y1 + Height;   //
    if (MousePos.x > x1)and(MousePos.x < x2)and(MousePos.y > y1)and(MousePos.y < y2)//
     then   if PageSize>SmallChange  then                                           //
                                       begin                                        //
                                         PageSize:=PageSize-SmallChange;          //
                                         RecreateWnd;                             //
                                         Scroll(scPageDown,	pstn);                //
                                       end                                          //
                                     else PageSize:=1;                              //
  end;                                                                                //
end;//------------------LessPage------------------------------------------------------//



///////////////////////////////TLamp/////////////////////////////////////////////////////


constructor TLamp.Create(AOwner:TComponent);//
begin                                       //
  inherited Create(AOwner);                 //
  HInst:=FindResourceHInstance(HINSTANCE);  //
  BitMapOn :=TBitmap.Create;                //
  BitMapOff:=TBitmap.Create;                //
  Workmap:=TBitmap.Create;                  //
  ControlStyle:=[csOpaque];                 //
  RePaint;                                  //
end;//--------------------------------------//

Procedure TLamp.SetState(st:Boolean); //
begin                                 //
if St then  FState:=True              //
      else  FState:=False;            //
RePaint;                              //
end;//--------------------------------//

Procedure TLamp.ChangeState;//
begin                       //
FState:= not FState;        //
RePaint;                    //
end;//----------------------//

Procedure TLamp.Paint;//------------------------------------------------------------------------//
begin                                                                                              //
  if FState then                                                                                   //
   TransparentBlt(Canvas.Handle,0,0,Width,Height,BitMapOn.Canvas.Handle,0,0,Width,Height,clWhite)  //
   else                                                                                            //
   TransparentBlt(Canvas.Handle,0,0,Width,Height,BitMapOff.Canvas.Handle,0,0,Width,Height,clWhite);//
end;//----------------------------------------TLamp.Paint------------------------------------------//

procedure TLamp.SetBounds(ALeft, ATop, AWidth, AHeight: Integer); //----------//
begin                                                                         //
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);                          //
  BitMapOn.Height:=Height;                                                    //
  BitMapOn.Width:= Width;;                                                    //
  BitMapOff.Height:=Height;                                                   //
  BitMapOff.Width:= Width;                                                    //
  //Workmap.LoadFromResourceName(HInst,'On');                                 //
  Workmap.LoadFromFile('вкл2_40x39.bmp');                                     //
  StretchBlt(BitMapOn.Canvas.Handle,0,0,Width,Height,                         //
                      Workmap.Canvas.Handle,0,0,Workmap.Width,Workmap.Height, //
                      SrcCopy);                                               //
  //Workmap.LoadFromResourceName(HInst,'Off');//                              //
  Workmap.LoadFromFile('выкл_40х39.bmp');                                     //
  StretchBlt(BitMapOff.Canvas.Handle,0,0,Width,Height,                        //
                      Workmap.Canvas.Handle,0,0,Workmap.Width,Workmap.Height, //
                      SrcCopy);                                               //
end; //----------------переписывание SetBounds--------------------------------//


destructor TLamp.Destroy; //
begin                     //
 BitMapOn.Free;           //
 BitMapOff.Free;          //
 WorkMap.Free;            //
inherited Destroy;        //
end;//--------------------//          }


///////////////////////////////TSMeter/////////////////////////////////////////////////////

constructor TSMeterDcl.Create(AOwner:TComponent);//

begin                                         //
  inherited Create(AOwner);                   //
  //HInst:=FindResourceHInstance(HINSTANCE);    //
  ResMap :=TBitmap.Create;                    //
  ResMap.LoadFromResourceName(HInst,'BACKGR');//
  pict :=TBitmap.Create;
  WorkMap:=TBitmap.Create;
  WorkMap.Height:=ResMap.Height;
  WorkMap.Width:=ResMap.Width;
   with WorkMap.Canvas do
     begin
        Font.Color:=clRed;
        Font.Style:=[fsBold];
        Pen.Color:=clRed;
        Pen.Width:=4;
     end;
 ControlStyle:=[csNoStdEvents,csOpaque];
  AutoSize:=False;                            //
  Fi:=0; Len:=30;                             //
  SetMax(100);                                //
  SetMin(0);                                  //
  SetValue(10);                               //
  Repaint;
end;//----------------------------------------//


procedure TSMeterDcl.SetMin(mn:Single);//
begin                               //
if mn>fMax then begin               //
                 fMin:=fMax;        //
                 fMax:=mn;          //
                end                 //
            else fMin:=mn;          //
Repaint;
end;//------------------------------//

procedure TSMeterDcl.SetMax(mx:Single);//
begin                               //
if mx<fMin then begin               //
                 fMax:=fMin;        //
                 fMin:=mx;          //
                end                 //
           else fMax:=mx;           //
Repaint;
end;//------------------------------//

procedure TSMeterDcl.SetValue(vl:Single);//---//
begin                                      //
fValue:=vl;                                //
if fValue>fMax then fValue:=fMax;          //
if fValue<fMin then fValue:=fMin;          //
Repaint;
end;//-------------------------------------//

procedure TSMeterDcl.Scale(Pict:TBitMap);//-------------------//
begin                                                      //
  with pict.Canvas do                                      //
   begin                                                   //
     TextOut(10,110,FloatToStrF(fMin,ffFixed,4,1));        //
     TextOut(90,110,FloatToStrF(fMax,ffFixed,4,1));        //
     TextOut(55,12,FloatToStrF((fMax+fMin)/2,ffFixed,4,1));//
   end;                                                    //
end;//-----------------------------------------------------//

procedure TSMeterDcl.Arrow(Pct:TBitMap);//--------//
begin                                          //
  Fi:=3*Pi/2/(fMax-fMin)*(fValue-fMin);        //
  with Pct.Canvas do                           //
   begin                                       //
     MoveTo(64,64);                            //
     LineTo(64-Round(Len*cos(Fi-Pi/4)),        //
                   64-Round(Len*sin(Fi-Pi/4)));//
   end;                                        //
end;//-----------------------------------------//

procedure TSMeterDcl.Paint;
begin
 BitBlt(WorkMap.Canvas.Handle,0,0,WorkMap.Width,WorkMap.Height, ResMap.Canvas.Handle,0,0, SrcCopy);
 Arrow(WorkMap);
 Scale(WorkMap);
 StretchBlt(pict.Canvas.Handle,0,0,Width,Height, WorkMap.Canvas.Handle,0,0,WorkMap.Width,WorkMap.Height, SrcCopy);
 TransparentBlt(Canvas.Handle,0,0,Width,Height, pict.Canvas.Handle,0,0,Width,Height, clWhite);
// BitBlt(Canvas.Handle,0,0,WorkMap.Width,WorkMap.Height, WorkMap.Canvas.Handle,0,0, SrcCopy);
end;


procedure TSMeterDcl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  pict.Height:=Height;                                       //
  pict.Width:=Width;

end;

destructor TSMeterDcl.Destroy; //
begin                       //
 ResMap.Free;          //
  pict.Free;

inherited Destroy;          //
                            //
end;//----------------------//

///////////////////////////////////////////////////////////////////////////////////////////
procedure Register;
begin
   RegisterComponents('Samples', [TFloatEdit]);
   RegisterComponents('Samples', [TIntEdit]);
   RegisterComponents('Samples', [TmodScrollBar]);
   RegisterComponents('Samples', [TLamp]);
   RegisterComponents('Samples', [TSMeterDcl]);
   RegisterComponents('Samples', [TBtnListView]);
   RegisterComponents('Samples', [tfloatspinedit]);
   RegisterComponents('Samples', [TAlignEdit]);
   RegisterComponents('Samples', [TAlignEdit]);
   RegisterComponents('Samples', [TVTree]);
   RegisterComponents('Samples', [TStringGridExt]);
   RegisterComponents('Samples', [TVistaProBar]);
end;

end.
