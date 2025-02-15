unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, uHardwareMath, uQueue, ucommontypes, complex;

type

  TpackVector = packed array [0..3] of Single;
  PpackVector = ^TpackVector;

  TVector = array [0..3] of Single;
  PVector = ^TVector;


  TForm1 = class(TForm)
    Memo1: TMemo;
    Button2: TButton;
    Memo2: TMemo;
    Memo3: TMemo;
    TestSummSkripnik: TButton;
    Memo4: TMemo;
    PickBackBtn: TButton;
    PickFrontBtn: TButton;
    PushFrontBtn: TButton;
    PushBackBtn: TButton;
    DropBtn: TButton;
    procedure Button2Click(Sender: TObject);
    procedure TestSummSkripnikClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PickFrontBtnClick(Sender: TObject);
    procedure PushBackBtnClick(Sender: TObject);
    procedure PickBackBtnClick(Sender: TObject);
    procedure PushFrontBtnClick(Sender: TObject);
    procedure DropBtnClick(Sender: TObject);
  private
    Fr, t1, t2: Int64;
    Dt: Extended;

    //q:cQueue_p2d;
    q:cQueue<point2d>;
    counter:integer;
  protected
    procedure showQueue;
  private
    procedure StartTimer(comment:string);
    procedure StopTimer(comment:string);
  public
    { Public declarations }
  end;

const
  iTimes = 1;
  iSize = 22;
  sseRegCount = 4; // ���������� ���������
  sseRegSize = 4; // ������ �������� sse (4 ����� � ����. ������)
  sseRegSize_1 = 3; // ������ �������� sse (4 ����� � ����. ������)
  SizeAligned = SizeOf(TVector);

var
  Form1: TForm1;

implementation

//{$ALIGN 16}
{$R *.dfm}


procedure TForm1.Button2Click(Sender: TObject);
var
  i : integer;
begin
  Memo2.Text := '';
  for i := 0 to 27 do
    Memo2.Text := Memo2.Text + IntToStr(i) + ' = ' + BoolToStr( IsProcessorFeaturePresent(i), true ) + #13#10;
end;

procedure TForm1.DropBtnClick(Sender: TObject);
begin
  q.drop_front(1);
  showQueue;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //q:=cQueue_p2d.create;
  q:=cQueue<point2d>.create;
  q.capacity:=6;
  q.m_resizeMode:=false;
  q.push_back(p2d(1,0));
  q.push_back(p2d(2,0));
  q.push_back(p2d(3,0));
  q.push_back(p2d(4,0));
  q.push_back(p2d(5,0));
  q.push_back(p2d(6,0));
  counter:=7;
  //d:=phase_deg(0,-1,2,0);
  //showmessage(floattostr(d));
  showQueue;
end;

procedure TForm1.PickBackBtnClick(Sender: TObject);
begin
  q.pop_back;
  showQueue;
end;

procedure TForm1.PickFrontBtnClick(Sender: TObject);
begin
  q.pop_front;
  showQueue;
end;

procedure TForm1.PushBackBtnClick(Sender: TObject);
begin
  q.push_back(p2d(counter,0));

  inc(counter);
  showQueue;
end;

procedure TForm1.PushFrontBtnClick(Sender: TObject);
begin
  q.push_front(p2d(counter,0));
  inc(counter);
  showQueue;
end;

procedure TForm1.showQueue;
var
  I: Integer;
  v:double;
  str:string;
begin
  str:='Peak: ';
  for I := 0 to q.size - 1 do
  begin
    v:=q.peak(i).x;
    str:=str+inttostr(round(v))+'; ';
  end;
  str:=str+c_carret+'Get: ';
  memo4.Text:=str;
  str:='';
  for I := 0 to q.size - 1 do
  begin
    v:=q.GetByInd(i).x;
    str:=str+inttostr(round(v))+'; ';
  end;
  memo4.Text:=memo4.Text+str;
end;

procedure TForm1.StartTimer(comment: string);
begin
  // ������ ��������� �������� ������.
  Memo3.Text := Memo3.Text + comment + #13#10;
  QueryPerformanceFrequency(Fr);
  QueryPerformanceCounter(t1);
end;

procedure TForm1.StopTimer(comment: string);
begin
  Memo3.Text := Memo3.Text + '���������: '#9#9 + comment + #13#10;
  // ��������� �������� ������.
  QueryPerformanceCounter(t2);
  Memo3.Text := Memo3.Text + '������������ � �����: '#9 + FloatToStrF(t2 - t1, ffnumber, 20, 0) + #13#10;
  Dt := (t2 - t1)/Fr;
  Memo1.Text := Memo1.Text + '������������ � �������������: '#9 + FloatToStrF(Dt*1000000, ffnumber, 20, 10) + #13#10 + #13#10;
end;

procedure TForm1.TestSummSkripnikClick(Sender: TObject);
var
  i, j, k, SseCount:integer;
  ars:array of single;
  ard: array of double;
  Fr, t: Int64;
  res, Dt: Extended;

  DataUnaligned1, DataAligned1, DataUnaligned2, DataAligned2: Pointer;
  SizeUnaligned1, SizeUnaligned2:integer;

  v1, v2:pVector;
begin
  setlength(ard, iSize);
  //setlength(ars, iSize);
  //SizeAligned:=iSize;
  // align by 4 bits, i.e. by 16 bytes
  GetMemAligned(4 , nil, sizeof(single)*isize,
                pointer(ars),
                DataUnaligned1,
                SizeUnaligned1);
  GetMemAligned(4 , nil, sizeof(single)*sizeof(tvector),
                pointer(v1),
                DataUnaligned1,
                SizeUnaligned1);

  // ������������� �������
  for I := 0 to iSize-1 do
  begin
    ard[I] := i;
  end;
  // ������������� �������
  for I := 0 to iSize-1 do
  begin
    ars[I] := i;
  end;

  /////////////////////// Math
  StartTimer('Math:');
  // ������� ����� iTimes ���
  for i := 1 to iTimes do
  begin
    res := SUM(ard);
  end;
  StopTimer('Math:'+floattostr(res));

  /////////////////////// Math
  StartTimer('SSE_d:');
  // ������� ����� iTimes ���
  for i := 1 to iTimes do
  begin
    //res := sumSSE_d(ard);
    res := sum_SSE_d(ard, 3, 9);
    //res := sum_SSE_d(ard);
  end;
  StopTimer('SSE_d:'+floattostr(res));
end;



end.
