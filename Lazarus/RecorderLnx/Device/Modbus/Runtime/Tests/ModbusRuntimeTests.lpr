
Program ModbusRuntimeTests;

{$mode objfpc}{$H+}{$pointermath on}

Uses SysUtils, uModbusCoreTypes, uRecorderModbusTransport,
uRecorderModbusFakeTransport, uRecorderModbusRuntime, uRecorderModbusRtuTransport;

Procedure Check(ACondition:Boolean;Const AName:String);
Begin
  If Not ACondition Then
    Begin
      WriteLn('FAIL ',AName);
      Halt(1)
    End
End;
Procedure PutWord(P:PByte;O:Integer;V:Word);
Begin
  P[O] := V shr 8;
  P[O+1] := V
End;
Function Crc(P:PByte;N:Integer): Word;

Var I,J: Integer;
  C: Cardinal;
Begin
  C := $FFFF;
  For I:=0 To N-1 Do
    Begin
      C := C xor P[I];
      For J:=0 To 7 Do
        If C And 1<>0 Then C := (C shr 1)xor $A001
        Else C := C shr 1
    End;
  Result := C
End;

Procedure TcpReply(F:TRecorderModbusFakeTransport;Tid:Word;UnitId:Byte;
                   Const Pdu:Array Of Byte);

Var B: array[0..259] Of Byte;
  I,N: Integer;
Begin
  FillChar(B,SizeOf(B),0);
  PutWord(@B[0],0,Tid);
  PutWord(@B[0],4,Length(Pdu)+1);
  B[6] := UnitId;
  For I:=0 To High(Pdu) Do
    B[7+I] := Pdu[I];
  N := 7+Length(Pdu);
  F.ConfigureResponse(@B[0],N)
End;

Function AddTag(D:TModbusDeviceConfig;R:TModbusRegion;A:Word;T:TModbusDataType;W:Boolean):
                                                                                    TModbusTagConfig
;
Begin
  Result := D.AddTag;
  Result.Region := R;
  Result.Address := A;
  Result.DataType := T;
  If W Then Result.Access := maReadWrite
End;

Procedure TestTcp;

Var C: TModbusBusConfig;
  D: TModbusDeviceConfig;
  F: TRecorderModbusFakeTransport;
  I: IRecorderModbusTransport;
  B: TRecorderModbusBusRuntime;
  R: TRecorderModbusTransportResult;
  Bits: Byte;
Begin
  C := TModbusBusConfig.Create;
  Try
    C.Alias := 'tcp';
    C.Transport := mtTcp;
    C.Retries := 0;
    D := C.AddDevice;
    D.UnitId := 7;
    AddTag(D,mrCoil,0,mdBool,True);
    AddTag(D,mrDiscreteInput,8,mdBool,False);
    AddTag(D,mrInputRegister,10,mdUInt16,False);
    AddTag(D,mrHoldingRegister,20,mdUInt16,True);
    AddTag(D,mrHoldingRegister,21,mdUInt32,True);
    F := TRecorderModbusFakeTransport.Create;
    I := F;
    B := TRecorderModbusBusRuntime.Create(C,I);
    Try
      Check(B.Connect.Code=mtcOk,'connect');
      Check(B.Initialize.Code=mtcOk,'init');
      Check(B.Configure.Code=mtcOk,'configure');
      Check(B.Start.Code=mtcOk,'start');
      TcpReply(F,1,7,[$01,$01,$01]);
      R := B.Tick;
      Check((R.Code=mtcOk)and(B.TagAt(0,0).Value = 1),'fc01');
      TcpReply(F,2,7,[$02,$01,$01]);
      R := B.Tick;
      Check((R.Code=mtcOk)and(B.TagAt(0,1).Value = 1),'fc02');
      TcpReply(F,3,7,[$04,$02,$12,$34]);
      R := B.Tick;
      Check((R.Code=mtcOk)and(B.TagAt(0,2).Value = $1234),'fc04');
      TcpReply(F,4,7,[$03,$06,$00,$2A,$00,$00,$00,$05]);
      R := B.Tick;
      Check((R.Code=mtcOk)and(B.TagAt(0,3).Value = 42)and(B.TagAt(0,4).Value = 5),'fc03');
      TcpReply(F,5,7,[$05,$00,$00,$FF,$00]);
      R := B.WriteValue(0,0,1);
      Check((R.Code=mtcOk)and(F.LastRequestByte(7) = 5)and
        (F.LastRequestByte(10)=$FF)and(F.LastRequestByte(11)=0),
        'numeric 1 packs to fc05 on');
      TcpReply(F,6,7,[$06,$00,$14,$00,$2B]);
      R := B.WriteValue(0,3,43);
      Check((R.Code=mtcOk)and(F.LastRequestByte(7) = 6),'fc06');
      TcpReply(F,7,7,[$10,$00,$15,$00,$02]);
      R := B.WriteValue(0,4,6);
      Check((R.Code=mtcOk)and(F.LastRequestByte(7) = 16),'fc16');
      R := B.WriteValue(0,2,9);
      Check((R.Code=mtcInvalidArgument)and(F.ExchangeCount=7),'read only rejected');
      Bits := $05;
      TcpReply(F,8,7,[$0F,$00,$00,$00,$03]);
      R := B.WriteCoils(0,0,3,@Bits,1);
      Check((R.Code=mtcOk)and(F.LastRequestByte(7) = 15),'fc15');
      Check(B.Stop.Code=mtcOk,'stop');
      Check(B.Start.Code=mtcOk,'restart');
      Check(B.Disconnect.Code=mtcOk,'disconnect');
      Check(B.Connect.Code=mtcOk,'connect again');
      Check(B.Initialize.Code=mtcOk,'initialize again');
      Check(B.Configure.Code=mtcOk,'configure again');
      Check(B.Start.Code=mtcOk,'start again');
      TcpReply(F,99,7,[$01,$01,$01]);
      R := B.Tick;
      Check(R.Code=mtcProtocolError,'bad mbap');
      TcpReply(F,10,7,[$82,$02]);
      R := B.Tick;
      Check((R.Code=mtcExceptionResponse)and(R.ProtocolCode=2),'exception');
      F.FailNext(mtcTimeout);
      R := B.Tick;
      Check((R.Code=mtcTimeout)and(B.State=mrsOffline),'timeout');
      Sleep(270);
      TcpReply(F,12,7,[$01,$01,$01]);
      R := B.Tick;
      Check((R.Code=mtcOk)and(B.State=mrsRunning),'reconnect');
    Finally
      B.Free;
      I := Nil
End;
Finally
  C.Free
End;
End;

Procedure TestRetry;
Var C:TModbusBusConfig;
  D:TModbusDeviceConfig;
  F:TRecorderModbusFakeTransport;
  I:IRecorderModbusTransport;
  B:TRecorderModbusBusRuntime;
  R:TRecorderModbusTransportResult;
Begin
  C:=TModbusBusConfig.Create;
  Try
    C.Alias:='retry'; C.Transport:=mtTcp; C.Retries:=1;
    D:=C.AddDevice; D.UnitId:=2; AddTag(D,mrHoldingRegister,0,mdUInt16,False);
    F:=TRecorderModbusFakeTransport.Create; I:=F;
    B:=TRecorderModbusBusRuntime.Create(C,I);
    Try
      B.Connect; B.Initialize; B.Configure; B.Start;
      TcpReply(F,1,2,[$03,$02,$00,$07]); F.FailNext(mtcTimeout);
      R:=B.Tick;
      Check((R.Code=mtcOk)and(F.ExchangeCount=2)and(B.TagAt(0,0).Value=7),'retry success')
    Finally
      B.Free; I:=Nil
    End
  Finally
    C.Free
  End
End;

Procedure TestRtuCrc;

Var C: TModbusBusConfig;
  D: TModbusDeviceConfig;
  F: TRecorderModbusFakeTransport;
  I: IRecorderModbusTransport;
  B: TRecorderModbusBusRuntime;
  R: TRecorderModbusTransportResult;
  Frame: array[0..6] Of Byte;
  X: Word;
  H0,H1: TFPCHeapStatus;
  Started,Elapsed: QWord;
  K: Integer;
Begin
  C := TModbusBusConfig.Create;
  Try
    C.Alias := 'rtu';
    C.Transport := mtRtu;
    C.Retries := 0;
    D := C.AddDevice;
    D.UnitId := 1;
    AddTag(D,mrHoldingRegister,0,mdUInt16,False);
    F := TRecorderModbusFakeTransport.Create;
    I := F;
    B := TRecorderModbusBusRuntime.Create(C,I);
    Try
      B.Connect;
      B.Initialize;
      B.Configure;
      B.Start;
      Frame[0] := 1;
      Frame[1] := 3;
      Frame[2] := 2;
      Frame[3] := 0;
      Frame[4] := 9;
      Frame[5] := 0;
      Frame[6] := 0;
      F.ConfigureResponse(@Frame[0],7);
      R := B.Tick;
      Check(R.Code=mtcProtocolError,'bad crc');
      X := Crc(@Frame[0],5);
      Frame[5] := X;
      Frame[6] := X shr 8;
      F.ConfigureResponse(@Frame[0],7);
      R := B.Tick;
      Check((R.Code=mtcOk)and(B.TagAt(0,0).Value = 9),'rtu valid crc');
      H0 := GetFPCHeapStatus;
      Started := GetTickCount64;
      For K:=1 To 10000 Do
        Begin
          R:=B.Tick;
          Check(R.Code=mtcOk,'steady tick')
        End;
      Elapsed:=GetTickCount64-Started;
      H1:=GetFPCHeapStatus;
      Check(H1.CurrHeapUsed=H0.CurrHeapUsed,'zero steady heap allocations');
      WriteLn('INFO 10000 ticks ms=',Elapsed);
    Finally
      B.Free;
      I := Nil
End;
Finally
  C.Free
End
End;

Begin
  Check(RecorderModbusRtuSilentIntervalUs(1200,8,mpNone,1)=29167,
    'rtu 1200 8N1 t3.5');
  Check(RecorderModbusRtuSilentIntervalUs(9600,8,mpEven,1)=4011,
    'rtu 9600 8E1 t3.5');
  Check(RecorderModbusRtuSilentIntervalUs(38400,8,mpNone,1)=1750,
    'rtu high baud t3.5');
  TestTcp;
  TestRetry;
  TestRtuCrc;
  WriteLn('RESULT ModbusRuntimeTests passed')
End.
