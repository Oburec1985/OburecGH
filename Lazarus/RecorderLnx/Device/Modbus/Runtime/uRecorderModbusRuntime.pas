
Unit uRecorderModbusRuntime;


{ Allocation-free Bus -> Device -> Tag scheduler. Configure creates all plans
  and frames; Tick performs one transaction and publishes leaf snapshots. }

{$mode objfpc}{$H+}{$codepage UTF8}{$pointermath on}

Interface

Uses SysUtils, SyncObjs, fgl, uRecorderModbusTransport, uModbusCoreTypes,
uModbusPlanner;

Type 
  TRecorderModbusRuntimeState = (mrsDisconnected,mrsConnected,mrsInitialized,
                                 mrsConfigured,mrsRunning,mrsOffline);
  TRecorderModbusQuality = (mqUnknown,mqGood,mqBadCommunication,mqBadProtocol);

  TRecorderModbusTagRuntime = Class
    Private fConfig: TModbusTagConfig;
      fValue: Double;
      fGeneration: QWord;
      fQuality: TRecorderModbusQuality;
    Public 
      constructor Create(AConfig:TModbusTagConfig);
      Procedure Publish(AValue:Double; AQuality:TRecorderModbusQuality);
      Procedure PublishQuality(AQuality:TRecorderModbusQuality);
      property Config: TModbusTagConfig read fConfig;
      property Value: Double read fValue;
      property Generation: QWord read fGeneration;
      property Quality: TRecorderModbusQuality read fQuality;
  End;
  TRecorderModbusTagList = specialize TFPGObjectList<TRecorderModbusTagRuntime>;

  TRecorderModbusDeviceRuntime = Class
    Private fConfig: TModbusDeviceConfig;
      fTags: TRecorderModbusTagList;
      fReadPlan: TModbusPlan;
    Public 
      constructor Create(AConfig:TModbusDeviceConfig);
      destructor Destroy;
      override;
      Procedure BuildPlan;
      property Config: TModbusDeviceConfig read fConfig;
      property ReadPlan: TModbusPlan read fReadPlan;
      property Tags: TRecorderModbusTagList read fTags;
  End;
  TRecorderModbusDeviceList = specialize TFPGObjectList<TRecorderModbusDeviceRuntime>;

  TRecorderModbusDecodeBinding = Record
    Tag: TRecorderModbusTagRuntime;
    DataOffset: Word;
    BitOffset: Byte;
  End;
  TRecorderModbusDecodeBindings = array Of TRecorderModbusDecodeBinding;

  TRecorderModbusPollEntry = Record
    DeviceIndex,PlanIndex,RequestLength: Integer;
    Request: array[0..CRecorderModbusMaxAduSize-1] Of Byte;
    Bindings: TRecorderModbusDecodeBindings;
  End;
  TRecorderModbusPollEntries = array Of TRecorderModbusPollEntry;

  TRecorderModbusBusRuntime = Class
    Private 
      fConfig: TModbusBusConfig;
      fTransport: IRecorderModbusTransport;
      fDevices: TRecorderModbusDeviceList;
      fPollEntries: TRecorderModbusPollEntries;
      fPollIndex: Integer;
      fTransactionId: Word;
      fState: TRecorderModbusRuntimeState;
      fSessionGeneration,fConfigurationGeneration,fConfiguredGeneration: Cardinal;
      fReconnectDelayMs,fReconnectMaxDelayMs: Cardinal;
      fNextReconnectTick: QWord;
      fExchangeLock: TCriticalSection;
      fResponse: array[0..CRecorderModbusMaxAduSize-1] Of Byte;
      Procedure BuildPollEntries;
      Procedure BuildReadFrame(Var AEntry:TRecorderModbusPollEntry;Const AItem:TModbusPlanItem);
      Procedure BuildDecodeBindings(Var AEntry:TRecorderModbusPollEntry;
                                    ADevice:TRecorderModbusDeviceRuntime;
                                    Const AItem:TModbusPlanItem);
      Procedure ScheduleReconnect;
      Function RestoreSession: TRecorderModbusTransportResult;
      Function ExecuteFrame(ARequest:PByte;ALength:Integer;AUnit,AFunction:Byte;
                            out APdu:PByte;out APduLength:Integer): TRecorderModbusTransportResult;
      Function ValidateResponse(AFrame:PByte;ALength:Integer;ATid:Word;
                                AUnit,AFunction:Byte;out APdu:PByte;out APduLength:Integer):
                                                                      TRecorderModbusTransportResult
      ;
      Procedure DecodeRead(Const AEntry:TRecorderModbusPollEntry;APdu:PByte;ALength:Integer);
      Procedure SetPlanQuality(Const AEntry:TRecorderModbusPollEntry;AQuality:TRecorderModbusQuality
      );
      Function WriteFrame(ADeviceIndex,AFunction:Integer;AStart,ACount:Word;
                          AData:PByte;ADataLength:Integer): TRecorderModbusTransportResult;
    Public 
      constructor Create(AConfig:TModbusBusConfig;Const ATransport:IRecorderModbusTransport);
      destructor Destroy;
      override;
      Procedure ConfigurationChanged;
      Function Connect: TRecorderModbusTransportResult;
      Function Initialize: TRecorderModbusTransportResult;
      Function Configure: TRecorderModbusTransportResult;
      Function Start: TRecorderModbusTransportResult;
      Function Stop: TRecorderModbusTransportResult;
      Function Disconnect: TRecorderModbusTransportResult;
      Function Tick: TRecorderModbusTransportResult;
      Function WriteValue(ADeviceIndex,ATagIndex:Integer;AValue:Double):
                                                                      TRecorderModbusTransportResult
      ;
      Function WriteCoils(ADeviceIndex:Integer;AStart,ACount:Word;APackedBits:PByte;
                          AByteCount:Integer): TRecorderModbusTransportResult;
      Function DeviceCount: Integer;
      Function DeviceAt(AIndex:Integer): TRecorderModbusDeviceRuntime;
      Function TagAt(ADeviceIndex,ATagIndex:Integer): TRecorderModbusTagRuntime;
      property State: TRecorderModbusRuntimeState read fState;
      property SessionGeneration: Cardinal read fSessionGeneration;
  End;

Implementation

Function WordBE(P:PByte;O:Integer): Word;
inline;
Begin
  Result := (Word(P[O]) shl 8) Or P[O+1]
End;
Procedure PutWord(P:PByte;O:Integer;V:Word);
inline;
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
        If C And 1<>0 Then C := (C shr 1) xor $A001
        Else C := C shr 1
    End;
  Result := Word(C)
End;

Function ValueBytes(T:TModbusDataType): Integer;
inline;
Begin
  Case T Of 
    mdBool,mdUInt16,mdInt16: Result := 2;
    mdUInt32,mdInt32,mdFloat32: Result := 4;
    mdFloat64: Result := 8
  End
End;

Procedure Ordered(P:PByte;N:Integer;O:TModbusByteOrder;out D:Array Of Byte);

Var I,W: Integer;
Begin
  W := N Div 2;
  For I:=0 To W-1 Do
    Case O Of 
      moABCD:
              Begin
                D[I*2] := P[I*2];
                D[I*2+1] := P[I*2+1]
              End;
      moBADC:
              Begin
                D[I*2] := P[I*2+1];
                D[I*2+1] := P[I*2]
              End;
      moCDAB:
              Begin
                D[I*2] := P[(W-1-I)*2];
                D[I*2+1] := P[(W-1-I)*2+1]
              End;
      moDCBA:
              Begin
                D[I*2] := P[N-1-I*2];
                D[I*2+1] := P[N-2-I*2]
              End
    End
End;

Function DecodeValue(P:PByte;T:TModbusDataType;O:TModbusByteOrder;out V:Double): Boolean;

Var C,N: array[0..7] Of Byte;
  I,L: Integer;
  U16: Word;
  I16: SmallInt;
  U32: Cardinal;
  I32: LongInt;
  F32: Single;
  F64: Double;
Begin
  L := ValueBytes(T);
  Ordered(P,L,O,C);
  For I:=0 To L-1 Do
    N[I] := C[L-1-I];
  Case T Of 
    mdBool:
            Begin
              U16 := (Word(C[0])shl 8)Or C[1];
              V := Ord(U16<>0)
            End;
    mdUInt16:
              Begin
                Move(N,U16,2);
                V := U16
              End;
    mdInt16:
             Begin
               Move(N,I16,2);
               V := I16
             End;
    mdUInt32:
              Begin
                Move(N,U32,4);
                V := U32
              End;
    mdInt32:
             Begin
               Move(N,I32,4);
               V := I32
             End;
    mdFloat32:
               Begin
                 Move(N,F32,4);
                 V := F32
               End;
    mdFloat64:
               Begin
                 Move(N,F64,8);
                 V := F64
               End
  End;
  Result := True
End;

Function EncodeValue(V:Double;T:TModbusDataType;O:TModbusByteOrder;P:PByte;out L:Integer): Boolean;

Var C,N: array[0..7] Of Byte;
  I,W: Integer;
  U16: Word;
  I16: SmallInt;
  U32: Cardinal;
  I32: LongInt;
  F32: Single;
  F64: Double;
Begin
  Result := False;
  L := ValueBytes(T);
  Case T Of 
    mdBool:
            Begin
              If V<>0 Then U16 := 1
              Else U16 := 0;
              Move(U16,N,2)
            End;
    mdUInt16:
              Begin
                If (V<0)Or(V>High(Word))Then Exit;
                U16 := Trunc(V);
                Move(U16,N,2)
              End;
    mdInt16:
             Begin
               If (V<Low(SmallInt))Or(V>High(SmallInt))Then Exit;
               I16 := Trunc(V);
               Move(I16,N,2)
             End;
    mdUInt32:
              Begin
                If (V<0)Or(V>High(Cardinal))Then Exit;
                U32 := Trunc(V);
                Move(U32,N,4)
              End;
    mdInt32:
             Begin
               If (V<Low(LongInt))Or(V>High(LongInt))Then Exit;
               I32 := Trunc(V);
               Move(I32,N,4)
             End;
    mdFloat32:
               Begin
                 F32 := V;
                 Move(F32,N,4)
               End;
    mdFloat64:
               Begin
                 F64 := V;
                 Move(F64,N,8)
               End
  End;
  For I:=0 To L-1 Do
    C[I] := N[L-1-I];
  W := L Div 2;
  For I:=0 To W-1 Do
    Case O Of 
      moABCD:
              Begin
                P[I*2] := C[I*2];
                P[I*2+1] := C[I*2+1]
              End;
      moBADC:
              Begin
                P[I*2] := C[I*2+1];
                P[I*2+1] := C[I*2]
              End;
      moCDAB:
              Begin
                P[I*2] := C[(W-1-I)*2];
                P[I*2+1] := C[(W-1-I)*2+1]
              End;
      moDCBA:
              Begin
                P[I*2] := C[L-1-I*2];
                P[I*2+1] := C[L-2-I*2]
              End
    End;
  Result := True
End;

constructor TRecorderModbusTagRuntime.Create(AConfig:TModbusTagConfig);
Begin
  inherited Create;
  fConfig := AConfig;
  fQuality := mqUnknown
End;
Procedure TRecorderModbusTagRuntime.Publish(AValue:Double;AQuality:TRecorderModbusQuality);
Begin
  fValue := AValue;
  fQuality := AQuality;
  Inc(fGeneration)
End;
Procedure TRecorderModbusTagRuntime.PublishQuality(AQuality:TRecorderModbusQuality);
Begin
  fQuality := AQuality;
  Inc(fGeneration)
End;

constructor TRecorderModbusDeviceRuntime.Create(AConfig:TModbusDeviceConfig);

Var I: Integer;
Begin
  inherited Create;
  fConfig := AConfig;
  fTags := TRecorderModbusTagList.Create(True);
  For I:=0 To AConfig.TagCount-1 Do
    fTags.Add(TRecorderModbusTagRuntime.Create(AConfig.TagAt(I)))
End;
destructor TRecorderModbusDeviceRuntime.Destroy;
Begin
  fTags.Free;
  inherited
End;
Procedure TRecorderModbusDeviceRuntime.BuildPlan;
Begin
  BuildReadPlan(fConfig,fReadPlan)
End;

constructor TRecorderModbusBusRuntime.Create(AConfig:TModbusBusConfig;Const ATransport:
                                             IRecorderModbusTransport);

Var I: Integer;
Begin
  inherited Create;
  fConfig := AConfig;
  fTransport := ATransport;
  fDevices := TRecorderModbusDeviceList.Create(True);
  For I:=0 To AConfig.DeviceCount-1 Do
    fDevices.Add(TRecorderModbusDeviceRuntime.Create(AConfig.DeviceAt(I)));
  fExchangeLock := TCriticalSection.Create;
  fConfigurationGeneration := 1;
  fReconnectDelayMs := 250;
  fReconnectMaxDelayMs := 10000
End;
destructor TRecorderModbusBusRuntime.Destroy;
Begin
  Disconnect;
  fExchangeLock.Free;
  fDevices.Free;
  fTransport := Nil;
  inherited
End;
Function TRecorderModbusBusRuntime.DeviceCount: Integer;
Begin
  Result := fDevices.Count
End;
Function TRecorderModbusBusRuntime.DeviceAt(AIndex:Integer): TRecorderModbusDeviceRuntime;
Begin
  If (AIndex<0)Or(AIndex>=fDevices.Count)Then Exit(Nil);
  Result := fDevices[AIndex]
End;
Function TRecorderModbusBusRuntime.TagAt(ADeviceIndex,ATagIndex:Integer): TRecorderModbusTagRuntime;

Var D: TRecorderModbusDeviceRuntime;
Begin
  D := DeviceAt(ADeviceIndex);
  If (D=Nil)Or(ATagIndex<0)Or(ATagIndex>=D.Tags.Count)Then Exit(Nil);
  Result := D.Tags[ATagIndex]
End;
Procedure TRecorderModbusBusRuntime.ConfigurationChanged;
Begin
  Inc(fConfigurationGeneration);
  If fState=mrsConfigured Then fState := mrsInitialized
End;

Function TRecorderModbusBusRuntime.Connect: TRecorderModbusTransportResult;
Begin
  If fTransport=Nil Then Exit(ModbusTransportError(mtcInvalidState,mtsOpen,fConfig.Alias,
                              'No transport'));
  If fState In[mrsConnected,mrsInitialized,mrsConfigured,mrsRunning]Then Exit(ModbusTransportOk);
  Result := fTransport.Open;
  If Result.Code=mtcOk Then
    Begin
      Inc(fSessionGeneration);
      fState := mrsConnected;
      fReconnectDelayMs := 250
    End
  Else
    Begin
      fState := mrsOffline;
      ScheduleReconnect
    End
End;
Function TRecorderModbusBusRuntime.Initialize: TRecorderModbusTransportResult;
Begin
  If fState<>mrsConnected Then Exit(ModbusTransportError(mtcInvalidState,mtsConfigure,fConfig.Alias,
                                    'Not connected'));
  fState := mrsInitialized;
  Result := ModbusTransportOk
End;

Procedure TRecorderModbusBusRuntime.BuildReadFrame(Var AEntry:TRecorderModbusPollEntry;Const AItem:
                                                   TModbusPlanItem);

Var O: Integer;
  C: Word;
Begin
  FillChar(AEntry.Request,SizeOf(AEntry.Request),0);
  If fConfig.Transport=mtTcp Then
    Begin
      O := 7;
      AEntry.RequestLength := 12;
      PutWord(@AEntry.Request[0],4,6);
      AEntry.Request[6] := AItem.UnitId
    End
  Else
    Begin
      O := 1;
      AEntry.RequestLength := 8;
      AEntry.Request[0] := AItem.UnitId
    End;
  AEntry.Request[O] := AItem.FunctionCode;
  PutWord(@AEntry.Request[0],O+1,AItem.StartAddress);
  PutWord(@AEntry.Request[0],O+3,AItem.Count);
  If fConfig.Transport=mtRtu Then
    Begin
      C := Crc(@AEntry.Request[0],6);
      AEntry.Request[6] := C;
      AEntry.Request[7] := C shr 8
    End
End;

Procedure TRecorderModbusBusRuntime.BuildDecodeBindings(Var AEntry:TRecorderModbusPollEntry;
  ADevice:TRecorderModbusDeviceRuntime;Const AItem:TModbusPlanItem);
Var
  I,N: Integer;
  T: TModbusTagConfig;
Begin
  N := 0;
  For I:=0 To ADevice.Tags.Count-1 Do
    Begin
      T := ADevice.Tags[I].Config;
      If T.Enabled And (T.Region=AItem.Region) And (T.Address>=AItem.StartAddress) And
         (Cardinal(T.Address)+T.RegisterCount<=Cardinal(AItem.StartAddress)+AItem.Count) Then Inc(N)
    End;
  SetLength(AEntry.Bindings,N);
  N := 0;
  For I:=0 To ADevice.Tags.Count-1 Do
    Begin
      T := ADevice.Tags[I].Config;
      If Not (T.Enabled And (T.Region=AItem.Region) And (T.Address>=AItem.StartAddress) And
         (Cardinal(T.Address)+T.RegisterCount<=Cardinal(AItem.StartAddress)+AItem.Count)) Then Continue;
      AEntry.Bindings[N].Tag := ADevice.Tags[I];
      If AItem.FunctionCode In [1,2] Then
        Begin
          AEntry.Bindings[N].DataOffset := (T.Address-AItem.StartAddress) Div 8;
          AEntry.Bindings[N].BitOffset := (T.Address-AItem.StartAddress) Mod 8
        End
      Else AEntry.Bindings[N].DataOffset := (T.Address-AItem.StartAddress)*2;
      Inc(N)
    End
End;

Procedure TRecorderModbusBusRuntime.BuildPollEntries;

Var D,P,N: Integer;
Begin
  N := 0;
  For D:=0 To fDevices.Count-1 Do
    Begin
      fDevices[D].BuildPlan;
      If fDevices[D].Config.Enabled Then Inc(N,Length(fDevices[D].ReadPlan))
    End;
  SetLength(fPollEntries,N);
  N := 0;
  For D:=0 To fDevices.Count-1 Do
    If fDevices[D].Config.Enabled Then For P:=0 To High(fDevices[D].ReadPlan) Do
                                         Begin
                                           fPollEntries[N].DeviceIndex := D;
                                           fPollEntries[N].PlanIndex := P;
                                           BuildReadFrame(fPollEntries[N],fDevices[D].ReadPlan[P]);
                                           BuildDecodeBindings(fPollEntries[N],fDevices[D],
                                             fDevices[D].ReadPlan[P]);
                                           Inc(N)
                                         End;
  fPollIndex := 0
End;
Function TRecorderModbusBusRuntime.Configure: TRecorderModbusTransportResult;
Begin
  If fState<>mrsInitialized Then Exit(ModbusTransportError(mtcInvalidState,mtsConfigure,fConfig.
                                      Alias,'Not initialized'));
  BuildPollEntries;
  fConfiguredGeneration := fConfigurationGeneration;
  fState := mrsConfigured;
  Result := ModbusTransportOk
End;
Function TRecorderModbusBusRuntime.Start: TRecorderModbusTransportResult;
Begin
  If fState<>mrsConfigured Then Exit(ModbusTransportError(mtcInvalidState,mtsConfigure,fConfig.Alias
                                     ,'Not configured'));
  fState := mrsRunning;
  Result := ModbusTransportOk
End;
Function TRecorderModbusBusRuntime.Stop: TRecorderModbusTransportResult;
Begin
  If fState=mrsRunning Then fState := mrsConfigured;
  Result := ModbusTransportOk
End;
Function TRecorderModbusBusRuntime.Disconnect: TRecorderModbusTransportResult;
Begin
  If fTransport<>Nil Then Result := fTransport.Close
  Else Result := ModbusTransportOk;
  fState := mrsDisconnected;
  fNextReconnectTick := 0
End;
Procedure TRecorderModbusBusRuntime.ScheduleReconnect;
Begin
  fNextReconnectTick := GetTickCount64+fReconnectDelayMs;
  If fReconnectDelayMs<fReconnectMaxDelayMs Then
    Begin
      fReconnectDelayMs := fReconnectDelayMs*2;
      If fReconnectDelayMs>fReconnectMaxDelayMs Then fReconnectDelayMs := fReconnectMaxDelayMs
    End
End;
Function TRecorderModbusBusRuntime.RestoreSession: TRecorderModbusTransportResult;
Begin
  If (fState=mrsOffline)And(GetTickCount64<fNextReconnectTick)Then Exit(ModbusTransportError(
                                                                        mtcStopped,mtsOpen,fConfig.
                                                                        Alias,'Backoff'));
  Result := Connect;
  If Result.Code<>mtcOk Then Exit;
  Result := Initialize;
  If Result.Code<>mtcOk Then Exit;
  Result := Configure;
  If Result.Code<>mtcOk Then Exit;
  Result := Start
End;

Function TRecorderModbusBusRuntime.ValidateResponse(AFrame:PByte;ALength:Integer;ATid:Word;AUnit,
                                                    AFunction:Byte;out APdu:PByte;out APduLength:
                                                    Integer): TRecorderModbusTransportResult;

Var L,C: Word;
Begin
  APdu := Nil;
  APduLength := 0;
  If fConfig.Transport=mtTcp Then
    Begin
      If ALength<9 Then Exit(ModbusTransportError(mtcProtocolError,mtsRead,fConfig.Alias,'TCP short'
        ));
      If WordBE(AFrame,0)<>ATid Then Exit(ModbusTransportError(mtcProtocolError,mtsRead,fConfig.
                                          Alias,'MBAP transaction'));
      If WordBE(AFrame,2)<>0 Then Exit(ModbusTransportError(mtcProtocolError,mtsRead,fConfig.Alias,
                                       'MBAP protocol'));
      L := WordBE(AFrame,4);
      If (L<2)Or(ALength<>6+L)Then Exit(ModbusTransportError(mtcProtocolError,mtsRead,fConfig.Alias,
                                        'MBAP length'));
      If AFrame[6]<>AUnit Then Exit(ModbusTransportError(mtcProtocolError,mtsRead,fConfig.Alias,
                                    'MBAP unit'));
      APdu := AFrame+7;
      APduLength := ALength-7
    End
  Else
    Begin
      If ALength<4 Then Exit(ModbusTransportError(mtcProtocolError,mtsRead,fConfig.Alias,'RTU short'
        ));
      If AFrame[0]<>AUnit Then Exit(ModbusTransportError(mtcProtocolError,mtsRead,fConfig.Alias,
                                    'RTU unit'));
      C := Crc(AFrame,ALength-2);
      If (AFrame[ALength-2]<>Byte(C))Or(AFrame[ALength-1]<>Byte(C shr 8))Then Exit(
                                                                                ModbusTransportError
                                                                                   (mtcProtocolError
                                                                                   ,mtsRead,fConfig.
                                                                                   Alias,'RTU CRC'))
      ;
      APdu := AFrame+1;
      APduLength := ALength-3
    End;
  If APdu[0]=AFunction Or $80 Then
    Begin
      If APduLength<>2 Then Exit(ModbusTransportError(mtcProtocolError,mtsRead,fConfig.Alias,
                                 'Exception length'));
      Exit(ModbusTransportError(mtcExceptionResponse,mtsRead,fConfig.Alias,'Modbus exception',0,APdu
           [1]))
    End;
  If APdu[0]<>AFunction Then Exit(ModbusTransportError(mtcProtocolError,mtsRead,fConfig.Alias,
                                  'Function'));
  Result := ModbusTransportOk(ALength)
End;

Function TRecorderModbusBusRuntime.ExecuteFrame(ARequest:PByte;ALength:Integer;AUnit,AFunction:Byte;
                                                out APdu:PByte;out APduLength:Integer):
                                                                      TRecorderModbusTransportResult
;

Var N,Attempt: Integer;
  T: Word;
Begin
  Inc(fTransactionId);
  If fTransactionId=0 Then Inc(fTransactionId);
  T := fTransactionId;
  If fConfig.Transport=mtTcp Then PutWord(ARequest,0,T);
  For Attempt:=0 To fConfig.Retries Do
    Begin
      Result := fTransport.Exchange(ARequest,ALength,@fResponse[0],Length(fResponse),N,
        fConfig.TimeoutMs);
      If Result.Code=mtcOk Then
        Begin
          Result := ValidateResponse(@fResponse[0],N,T,AUnit,AFunction,APdu,APduLength);
          If Result.Code In [mtcOk,mtcExceptionResponse] Then Exit
        End;
      If Attempt=fConfig.Retries Then Break
    End;
  If Not (Result.Code In [mtcProtocolError,mtcExceptionResponse]) Then
    Begin
      fTransport.Close;
      fState := mrsOffline;
      ScheduleReconnect
    End
End;

Procedure TRecorderModbusBusRuntime.SetPlanQuality(Const AEntry:TRecorderModbusPollEntry;AQuality:
                                                   TRecorderModbusQuality);

Var K: Integer;
Begin
  For K:=0 To High(AEntry.Bindings) Do AEntry.Bindings[K].Tag.PublishQuality(AQuality)
End;

Procedure TRecorderModbusBusRuntime.DecodeRead(Const AEntry:TRecorderModbusPollEntry;APdu:PByte;
                                               ALength:Integer);

Var I: TModbusPlanItem;
  K,E: Integer;
  T: TModbusTagConfig;
  B: ^TRecorderModbusDecodeBinding;
  V: Double;
Begin
  I := fDevices[AEntry.DeviceIndex].ReadPlan[AEntry.PlanIndex];
  If ALength<2 Then
    Begin
      SetPlanQuality(AEntry,mqBadProtocol);
      Exit
    End;
  E := (I.Count+7)Div 8;
  If I.FunctionCode In[3,4]Then E := I.Count*2;
  If (APdu[1]<>E)Or(ALength<>E+2)Then
    Begin
      SetPlanQuality(AEntry,mqBadProtocol);
      Exit
    End;
  For K:=0 To High(AEntry.Bindings) Do
    Begin
      B := @AEntry.Bindings[K];
      T := B^.Tag.Config;
      If I.FunctionCode In[1,2]Then
        V := Ord(((APdu[2+B^.DataOffset] shr B^.BitOffset) And 1)<>0)
      Else DecodeValue(APdu+2+B^.DataOffset,T.DataType,T.ByteOrder,V);
      B^.Tag.Publish(V*T.Scale+T.Offset,mqGood)
    End
End;

Function TRecorderModbusBusRuntime.Tick: TRecorderModbusTransportResult;

Var E: ^TRecorderModbusPollEntry;
  I: TModbusPlanItem;
  P: PByte;
  N: Integer;
Begin
  fExchangeLock.Acquire;
  Try
    If fState=mrsOffline Then
      Begin
        Result := RestoreSession;
        If Result.Code<>mtcOk Then Exit
      End;
    If fState<>mrsRunning Then Exit(ModbusTransportError(mtcInvalidState,mtsWrite,fConfig.Alias,
                                    'Not running'));
    If Length(fPollEntries)=0 Then Exit(ModbusTransportOk);
    E := @fPollEntries[fPollIndex];
    I := fDevices[E^.DeviceIndex].ReadPlan[E^.PlanIndex];
    Result := ExecuteFrame(@E^.Request[0],E^.RequestLength,I.UnitId,I.FunctionCode,P,N);
    If Result.Code=mtcOk Then DecodeRead(E^,P,N)
    Else If Result.Code In[mtcProtocolError,mtcExceptionResponse]Then SetPlanQuality(E^,
                                                                                     mqBadProtocol)
    Else SetPlanQuality(E^,mqBadCommunication);
    Inc(fPollIndex);
    If fPollIndex>=Length(fPollEntries)Then fPollIndex := 0 Finally fExchangeLock.Release
End
End;

Function TRecorderModbusBusRuntime.WriteFrame(ADeviceIndex,AFunction:Integer;AStart,ACount:Word;
                                              AData:PByte;ADataLength:Integer):
                                                                      TRecorderModbusTransportResult
;

Var F: array[0..CRecorderModbusMaxAduSize-1] Of Byte;
  O,N: Integer;
  C: Word;
  P: PByte;
  PN: Integer;
Begin
  fExchangeLock.Acquire;
  Try
    If fState=mrsOffline Then
      Begin
        Result := RestoreSession;
        If Result.Code<>mtcOk Then Exit
      End;
    If fState<>mrsRunning Then Exit(ModbusTransportError(mtcInvalidState,mtsWrite,fConfig.Alias,
                                    'Not running'));
    FillChar(F,SizeOf(F),0);
    If fConfig.Transport=mtTcp Then
      Begin
        O := 7;
        F[6] := fDevices[ADeviceIndex].Config.UnitId
      End
    Else
      Begin
        O := 1;
        F[0] := fDevices[ADeviceIndex].Config.UnitId
      End;
    F[O] := AFunction;
    PutWord(@F[0],O+1,AStart);
    If AFunction In[5,6]Then
      Begin
        Move(AData^,F[O+3],2);
        N := O+5
      End
    Else
      Begin
        PutWord(@F[0],O+3,ACount);
        F[O+5] := ADataLength;
        Move(AData^,F[O+6],ADataLength);
        N := O+6+ADataLength
      End;
    If fConfig.Transport=mtTcp Then
      Begin
        PutWord(@F[0],4,N-6)
      End
    Else
      Begin
        C := Crc(@F[0],N);
        F[N] := C;
        F[N+1] := C shr 8;
        Inc(N,2)
      End;
    Result := ExecuteFrame(@F[0],N,fDevices[ADeviceIndex].Config.UnitId,AFunction,P,PN);
    If (Result.Code=mtcOk)And((PN<>5)Or(WordBE(P,1)<>AStart)Or(WordBE(P,3)<>ACount))Then Result := 
                                                                                ModbusTransportError
                                                                                                   (
                                                                                    mtcProtocolError
                                                                                                   ,
                                                                                             mtsRead
                                                                                                   ,
                                                                                             fConfig
                                                                                                   .
                                                                                               Alias
                                                                                                   ,
                                                                             'Write acknowledgement'
                                                                                                   )

                                                                                             Finally
                                                                                       fExchangeLock
                                                                                                   .
                                                                                             Release
End
End;

Function TRecorderModbusBusRuntime.WriteValue(ADeviceIndex,ATagIndex:Integer;AValue:Double):
                                                                      TRecorderModbusTransportResult
;

Var T: TRecorderModbusTagRuntime;
  D: array[0..7] Of Byte;
  N,F: Integer;
  C: Word;
Begin
  T := TagAt(ADeviceIndex,ATagIndex);
  If T=Nil Then Exit(ModbusTransportError(mtcInvalidArgument,mtsWrite,fConfig.Alias,'Tag index'));
  If (T.Config.Access<>maReadWrite)Or(T.Config.Region In[mrDiscreteInput,mrInputRegister])Then Exit(
                                                                                ModbusTransportError
                                                                                                   (
                                                                                  mtcInvalidArgument
                                                                                                   ,
                                                                                            mtsWrite
                                                                                                   ,
                                                                                             fConfig
                                                                                                   .
                                                                                               Alias
                                                                                                   ,
                                                                                         'Read only'
    ));
  If T.Config.Region=mrCoil Then
    Begin
      F := 5;
      If AValue>0 Then
        Begin
          D[0] := $FF;
          D[1] := 0
        End
      Else
        Begin
          D[0] := 0;
          D[1] := 0
        End;
      C := WordBE(@D[0],0);
      Result := WriteFrame(ADeviceIndex,F,T.Config.Address,C,@D[0],2)
    End
  Else
    Begin
      If T.Config.Scale=0 Then Exit(ModbusTransportError(mtcInvalidArgument,mtsWrite,fConfig.Alias,
                                    'Zero scale'));
      If Not EncodeValue((AValue-T.Config.Offset)/T.Config.Scale,T.Config.DataType,T.Config.
         ByteOrder,@D[0],N)Then Exit(ModbusTransportError(mtcInvalidArgument,mtsWrite,fConfig.Alias,
                                     'Value range'));
      C := T.Config.RegisterCount;
      If C=1 Then
        Begin
          F := 6;
          C := WordBE(@D[0],0)
        End
      Else F := 16;
      Result := WriteFrame(ADeviceIndex,F,T.Config.Address,C,@D[0],N)
    End;
  If Result.Code=mtcOk Then T.Publish(AValue,mqGood)
End;

Function TRecorderModbusBusRuntime.WriteCoils(ADeviceIndex:Integer;AStart,ACount:Word;APackedBits:
                                              PByte;AByteCount:Integer):
                                                                      TRecorderModbusTransportResult
;

Var I: Integer;
  T: TModbusTagConfig;
  Found: Boolean;
Begin
  If (ADeviceIndex<0)Or(ADeviceIndex>=fDevices.Count)Or(ACount=0)Or(AByteCount<>(ACount+7)Div 8)Or(
     APackedBits=Nil)Then Exit(ModbusTransportError(mtcInvalidArgument,mtsWrite,fConfig.Alias,
                               'Coil batch'));
  Found := False;
  For I:=0 To fDevices[ADeviceIndex].Tags.Count-1 Do
    Begin
      T := fDevices[ADeviceIndex].Tags[I].Config;
      If (T.Region=mrCoil)And(T.Address>=AStart)And(T.Address<Cardinal(AStart)+ACount)Then
        Begin
          Found := True;
          If T.Access<>maReadWrite Then Exit(ModbusTransportError(mtcInvalidArgument,mtsWrite,
                                             fConfig.Alias,'Read only coil'))
        End
    End;
  If Not Found Then Exit(ModbusTransportError(mtcInvalidArgument,mtsWrite,fConfig.Alias,
                         'Unknown coil range'));
  Result := WriteFrame(ADeviceIndex,15,AStart,ACount,APackedBits,AByteCount)
End;

End.
