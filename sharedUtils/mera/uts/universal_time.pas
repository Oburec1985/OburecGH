unit universal_time;
{$OPTIMIZATION OFF}
interface
uses Windows,  SysUtils, StdCtrls, Math, DateUtils;


const One_ms:Int64 =40000; //������������ ����� �������� � �����
      About_One_ms:Int64 =35000;
      Ten_ms:Int64 =400000;
      One_s:Int64 = 40000000;
      Dopusk:Int64 =1000;
      BsTimeM2081=1/40;// MHZ
      BsTimeM2070=1/40;// MHZ
type
  TTypeOfTime=(SEV,IRIG);

  TAutomState=(WaitStart,WaitCode,WaitAfterBit,WaitAfterNoise);

  TUnTimeAutomat = class //-------------------------
      tau:Double; //������������ ������� � ������
  private
    FState:TAutomState;
    Ffalling_edge: Int64; //��������� ��������� ����� �������� � 8 ��
    Fbitseq:array [0..100] of DWord;
    FNoise:Cardinal;
    Fshifter:DWord;
    Fsecond: Cardinal; //IRIG since 12/30/1899.
    Fyear: Cardinal;  //IRIG �� 2010 �� 2050
    Fmonth: Cardinal;
    Fday: Cardinal;   //IRIG �� 1 �� 366
    FNbits:Cardinal;
    FNwhite:Cardinal;
    FCurrIndex,FLastIndex:Cardinal;
    FTypeOfTime:TTypeOfTime;
    FFlag_IRIG:Integer; //������� �������� ��������� �����
    function bits2digits(s:Dword):Cardinal;
    procedure NewStick_SEV(Index:Cardinal);
    procedure NewStick_IREG(Index:Cardinal);
  public
    ms:Cardinal;//������ ����� � �������������
    constructor Create;
    procedure NewStick(Index:Cardinal);
    property second :cardinal read Fsecond write Fsecond;
    property noise :cardinal read FNoise;
    property TipeOfTime :TTypeOfTime read FTypeOfTime write FTypeOfTime;
  end;


implementation

function Differencel(const minuend,subtrahend{����������}:Cardinal; var inv:boolean):Cardinal;//
var
  i64:Int64;
begin
  i64:= minuend;
  i64:= i64-subtrahend;
  if i64 <-$1000000 then
    i64:=i64+$100000000;
  if i64<0 then
    inv:=True
  else
   //������� ��������
   inv:=False;
  result:=i64 and $FFFFFFFF;
end;

function Difference64(const minuend,subtrahend{����������}:Cardinal):Int64;
begin
  result:= minuend;
  result:= result- subtrahend;
  if result <-$1000000 then
    result:=result+$100000000;
end;



constructor TUnTimeAutomat.Create;
begin
  inherited Create;
  FState:=WaitStart;
  FNoise:=0;
  FNbits:=0;
  tau:=BsTimeM2081;
  FTypeOfTime:=SEV;
end;

procedure TUnTimeAutomat.NewStick(Index:Cardinal);
begin
  case TipeOfTime of
    SEV: NewStick_SEV(Index);
    IRIG:NewStick_IREG(Index);
  end;
end;

procedure TUnTimeAutomat.NewStick_SEV(Index:Cardinal);
var
  interval:Integer;
  dt:Double;//�������� � ������������
  tu:Double;
  bb:boolean;
  procedure NoiseToStart;
  begin
    dec (FNoise);
    if FNoise<1 then FState:=WaitStart;
  end;
  procedure Noise;
  begin
    if FState=WaitStart then
      Fnoise:=5
    else
      FNoise:=200;
    FState:=WaitAfterNoise;
  end;
begin
  FCurrIndex:=Index;
  dt:=Differencel(FCurrIndex,FLastIndex,bb)*tau;
  FLastIndex:=FCurrIndex;
  tu:=tau*90;
  if dt<(80-tu) then interval:=0  //���
  else
  begin
    if dt<(80+tu) then
      interval:=1
    else
    begin
      if dt < (920-tu) then
        interval:=2
      else
      begin
        if dt<(920+tu) then
          interval:=3
        else
        begin
          if dt<1000-tu then
            interval:=4
          else
          begin
            if dt<1000+tu then
              interval:=5
            else
             interval:=6;
          end;
        end;
      end;
    end;
  end;
  case interval of
  0:begin // 0<dt<80
      FNWhite:=0;
      case FState of
        WaitAfterNoise: NoiseToStart;
        else Noise;
      end;
    end;
  1:begin // dt= 80
      FNWhite:=0;
      case FState of
        WaitStart:  begin
            //           ms:=0;
                       FNBits:=0;
                       Fshifter:=0;
                       FState:=WaitAfterBit;
                    end;
        WaitCode:   begin
                       inc(ms);
                       Fshifter:=Fshifter shl 1;
                       Fshifter:=Fshifter+1;
                       inc(FNBits);
                       FState:=WaitAfterBit;
                    end;
        WaitAfterNoise:NoiseToStart;
        else Noise;
      end;
    end;
    2:begin // 80<dt<920
        FNWhite:=0;
        case FState of
          WaitAfterNoise: NoiseToStart;
        else Noise;
        end;
      end;
    3:begin
        FNWhite:=0;
        case FState of // dt= 920
          WaitAfterBit: FState:=WaitCode;
          WaitAfterNoise: NoiseToStart;
          else Noise;
        end;
      end;
    4:begin // 920<dt<1000
       FNWhite:=0;
       case FState of
         WaitAfterNoise:NoiseToStart;
         else Noise;
       end;
      end;
    5:case FState of // dt=1000
        WaitStart:
        begin
          inc(ms);
        end;
        WaitCode:
        begin
          Fshifter:=Fshifter shl 1;
          inc(FNBits);
          inc(ms);
          inc(FNWhite);
        end;
        WaitAfterNoise: NoiseToStart;
        else Noise;
      end;
    6:
    begin // dt>1000
      FNWhite:=0;
      case FState of
        WaitAfterNoise:NoiseToStart;
        else Noise;
      end;
    end;
  end;
  if ms=1000 then
  begin
    ms:=0;
    inc(Fsecond);
  end;
  if FNBits=32 then
  begin
    Fsecond:=bits2digits(Fshifter);
    FState:=WaitStart;
    ms:=32;
    FNBits:=0;
  end;
  if FNWhite>32 then
    FState:=WaitStart;
 end;//---------------------------NewStick---------------------------


procedure TUnTimeAutomat.NewStick_IREG(Index:Cardinal);//---------------
var i:  integer;
    ddddiff:Int64;
    bit_sense:Word; //�������� ���� 888 - �������������� ���
begin
 // ������������� (����������� �������� ������ 8 ����. ��������)
 Ffalling_edge:=(Ffalling_edge+Ten_ms)and $FFFFFFFF;
 ddddiff:= Difference64(Index,Ffalling_edge);
 inc(ms,10);  if ms=1000 then begin ms:=0; inc(Fsecond); end;
       //����������� ���
    if InRange(ddddiff,-Dopusk,Dopusk) then // ��� 8-�� �� �������
        begin //������������ �������������
          Ffalling_edge:=Ffalling_edge+ ddddiff div 2;
          Ffalling_edge:=Ffalling_edge and $FFFFFFFF;
          bit_sense:=888;
          Dec(FFlag_IRIG);  if FFlag_IRIG<0 then FFlag_IRIG:=0;
        end
    else begin
           if InRange(ddddiff,-One_ms*6-Dopusk,-One_ms*6+Dopusk) then
              begin
                bit_sense:=0; //��� 2-� �� �������
                Dec(FFlag_IRIG);  if FFlag_IRIG<0 then FFlag_IRIG:=0;
              end
           else
              begin
                if InRange(ddddiff,-One_ms*3-Dopusk,-One_ms*3+Dopusk)then
                   begin
                       bit_sense:=1;//��� 5-�� �� �������
                       Dec(FFlag_IRIG);
                       if FFlag_IRIG<0 then FFlag_IRIG:=0;
                   end
                     else
                   begin //����������� �������������
                     Ffalling_edge:=Index; ddddiff:=0;
                     FFlag_IRIG:=90;
                    end;
               end;
         end;

for i := 1 to 100 do  Fbitseq[i-1]:=Fbitseq[i];
Fbitseq[100]:= bit_sense;
if (Fbitseq[100]=888) and (Fbitseq[99]=888)
   and (Fbitseq[98]=0) and (FFlag_IRIG=0) then
   begin
      Fyear:= 2000+Fbitseq[50]+Fbitseq[51]*2+Fbitseq[52]*4+Fbitseq[53]*8
              +Fbitseq[55]*10+Fbitseq[56]*20+Fbitseq[57]*40+Fbitseq[58]*80;
      Fday:= Fbitseq[30]+Fbitseq[31]*2+Fbitseq[32]*4+Fbitseq[33]*8
              +Fbitseq[35]*10+Fbitseq[36]*20+Fbitseq[37]*40+Fbitseq[38]*80
              +Fbitseq[40]*100+Fbitseq[41]*200;
      if Inrange(Fyear,2010,2050) and Inrange(Fday,1,366)then
        begin
           Fsecond:=Trunc(EncodeDateDay(Fyear,Fday))*SecsPerDay; ms:=0;
           for i := 0 to 8 do   Fsecond:=  Fsecond+ (Fbitseq[i+80] shl i);
           for i := 9 to 16 do Fsecond:=  Fsecond+ (Fbitseq[i+81] shl i);
        end;
    end;

end;//------------------------------------------------------------------------

function TUnTimeAutomat.bits2digits(s:Dword):Cardinal;
const mask=$00F;
var i:Integer;
    sl:Dword;
    rsl:Word;
function Revers(Inp:Word):Word;
var temp1,temp2,temp4,temp8:Word;
begin
  temp2:=Inp and $0002;
  temp1:=Inp and $0001;
  temp4:=Inp and $0004;
  temp8:=Inp and $0008;
  temp1:=temp1 shl 3;
  temp8:=temp8 shr 3;
  temp2:=temp2 shl 1;
  temp4:=temp4 shr 1;
  Result:= temp1 or temp2 or temp4 or temp8;
end;
begin
  sl:=s;
  Result:=0;
  for i:=0 to 7 do
  begin
    rsl:= sl and mask;
    rsl:=Revers(rsl);
    Result:=Result*10 + rsl;
    sl:=sl shr 4;
  end;
end;

end.
