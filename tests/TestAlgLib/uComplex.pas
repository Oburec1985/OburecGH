unit uComplex;


interface
uses
 SysUtils,Math;

 const
   MinComplex = 5.0e-324;
   MaxComplex = 1.7e+308;
 Type
   PComplex =^TComplex;
   TComplex = record
     Re,
     Im:Double;
   end;// TComplex = record
   TCmxArray = array of TComplex;function GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False):TCmxArray;implementation{------------------------------------------------------------------------------function GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False): TCmxArray;
  ������ ������� Exp ���������� ��� FFT �������. (�����������)
  CountFFTPoints - ����� ����� ��� FFT �������.
  InverseFFT - ���� True, �� ��������� ����� ��� ��������� ���,
  ����� ��� �������.
  ������:
  CountFFTPoints = 32
  CountBlock = 5+1, � ������ [0][1][2..3][4..7][8..15][16..31]
  Len = 32
  ����� ���� ��������� ������ ���� ����������� ��� ���, ������� � ����� [1]
  Result (������) ����� ��������� ���:
  [0][1][2..3][4..7][8..15][16..31]
   | | | | | |
   | | | | | |--- ��� �������� ������ ������� = 16
   | | | | |
   | | | | |---------- ��� �������� ������ ������� = 8
   | | | |
   | | | |---------------- ��� �������� ������ ������� = 4
   | | |
   | | |---------------------- ��� �������� ������ ������� = 2
   | |
   | |--------------------------- ��� �������� ������ ������� = 1
   |
   |------------------------------ �� ������������, ��������� ��� ������������
   � ������, ���� �����, ��� ����� ����� ����� ������� 16 (������ ������ ���),
   �� � exp ��������� ����� � ������� ������� � ������ = 16, � ��� ��� ���� �����
   ����� 16, ���������� ���� 16 !. ���� ������ ������ :)}function GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False):TCmxArray;
var
  I,StartIndex,N,LenB:Integer;
  w,wn:TComplex;
  Mnogitel:Double;
begin
  Mnogitel := -2*Pi; //������ ���
  if InverseFFT then
    Mnogitel:= 2*Pi; //�������� ���
  SetLength(Result,CountFFTPoints);
  LenB:=1;
  while LenB <CountFFTPoints do //��������� ������ ����.
  begin
    N := LenB; //������� ����� ��������� � �����
    LenB := LenB shl 1;    //������� ������ EXP ���������(������) ��� ���.    wn.Re := 0;
    wn.Im := Mnogitel/LenB;
    wn := exp(wn);
    w := 1;
    StartIndex:=N; //��������� ������ � �������.
    Dec(N); //�.� ���������� � ����
    For I:=0 to N do //��������� ���� exp ����������� ��� ���, � �������
    begin
      Result[StartIndex+I]:=w;
      w:=w*wn;
    end;
  end;
end;

{------------------------------------------------------------------------------function GetArrayIndex(CountPoint: Integer;MinIteration: Integer): TIndexArray;
������ ������ ������ CountPoint �� �����(��������) �� 0 �� CountPoint-1.
���� ������ ����� ��������� � ���� �������, � ��� ������������������, �������
���������� ��� ����� ������ �������� ��� ������ � ���. ������� ��� ����, �����
��������� ����������� ���������� ������ ��� ���.
��������� ������������ ����� �������� �������� MinIteration..
���� ������ �������� ������������ ������ ���������� ������ ���� ���,
� �� ��� ������ ������ fft �������..
�� ����� �������� � ����� �� ��� ������������ �� �������}
function GetArrayIndex(CountPoint: Integer; MinIteration: Integer):TIndexArray;
Var I,LenBlock,HalfBlock,HalfBlock_1,
 StartIndex,EndIndex,ChIndex,NChIndex :Integer;
 TempArray:TIndexArray;
begin
 EndIndex:=CountPoint-1;
 SetLength(Result,CountPoint);
 For I:=0 to EndIndex do //����������� ������� �� �������
 Result[I]:=I;
 LenBlock :=CountPoint;
 HalfBlock :=LenBlock shr 1;
40
 HalfBlock_1:=HalfBlock -1;
 while LenBlock > MinIteration do //������������ ������� � ������ �������
LenBlock
 begin
 StartIndex:=0; //�������� � �������� ������ �����
 TempArray :=Copy(Result,0,CountPoint);
 repeat //������������ ������� � ����������(������ ����� =StartIndex)
 ����� ������� LenBlock
 ChIndex :=StartIndex;
 NChIndex:=ChIndex+1;
 EndIndex:=StartIndex+HalfBlock_1;
 //�������� ������ � �������� ������� � �������� ������� � ��������
 //������
 for I:=StartIndex to EndIndex do
 begin
 Result[I] :=TempArray[ChIndex];
 Result[I+HalfBlock]:=TempArray[NChIndex];
 ChIndex :=ChIndex +2;
 NChIndex:=NChIndex+2;
 end;
 StartIndex:=StartIndex+LenBlock; //��������� � ������� �����
 Until StartIndex >= CountPoint; //���� ����� �� ����� �������,
 //������ ������ ������ ���.
 //��������� ����� ����, ���� �� ������ �� ������������ ������� (MinIteration)
 LenBlock :=LenBlock shr 1;
 HalfBlock :=LenBlock shr 1;
 HalfBlock_1:=HalfBlock - 1;
 end;
 TempArray:=Nil;
end;
end.
