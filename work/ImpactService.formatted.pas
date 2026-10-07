
Unit uRecorderImpactHammerService;

{$mode objfpc}{$H+}
{$codepage UTF8}


{ Recorder adapter joining stable tag identities, the headless impact runtime,
  post-capture DSP, and the shared immutable FRF repository. }

Interface

Uses 
Classes, SysUtils, Math, SyncObjs, uRecorderTags, uRecorderCoreServices,
uRecorderImpactHammerModel, uRecorderImpactHammer, uRecorderImpactDsp,
uRecorderFrfContracts, uRecorderFrfRepository,
uRecorderImpactHammerContracts;

Type 
  TRecorderImpactHammerService = Class;

    TRecorderImpactWorker = Class(TThread)
      Private 
        fOwner: TRecorderImpactHammerService;
        fWake: TEvent;
      Protected 
        Procedure Execute;
        override;
      Public 
        constructor Create(AOwner: TRecorderImpactHammerService);
        destructor Destroy;
        override;
        Procedure Wake;
    End;

    TRecorderImpactMomentsArray = array Of TRecorderImpactSpectralMoments;
    TRecorderImpactSampleBufferArray = array Of TRecorderDoubleArray;

    TRecorderPreparedImpact = Class
      Public 
        Sequence: QWord;
        Responses: TRecorderImpactMomentsArray;
    End;

    TRecorderImpactHammerService = Class(TInterfacedObject,
                                         IRecorderImpactHammerApplicationService)
      Private 
        fModel: TRecorderImpactHammerComponent;
        fRegistry: TRecorderTagRegistry;
        fHammerTag: TRecorderTag;
        fResponseTags: array Of TRecorderTag;
        fPreloadTimes: TRecorderImpactSampleBufferArray;
        fPreloadValues: TRecorderImpactSampleBufferArray;
        fRuntime: TRecorderImpactRuntime;
        fDsp: TRecorderImpactDspPipeline;
        fSubscription: Integer;
        fCaptureToken: QWord;
        fCaptureStartSeconds: Double;
        fCaptureEndSeconds: Double;
        fCurrentImpact: Integer;
        fLastError: string;
        fQualityOk: Boolean;
        fPublishedCurves: array Of TRecorderFrfCurveData;
        fPrepared: TList;
        fWorker: TRecorderImpactWorker;
        fCompletionPending: Boolean;
        fRevision: QWord;
        fLock: TCriticalSection;
        Procedure HandleEvent(ASender: TObject; Const AEvent: TRecorderEvent);
        Procedure ProcessSample(ATag: TRecorderTag; ATime, AValue: Double);
        Procedure PreloadCapture;
        Procedure AddSnapshot(ATag: TRecorderTag; AChannel: Integer);
        Procedure CompleteCapture;
        Procedure ProcessPendingCapture;
        Procedure RecomputeAndPublish;
        Function FindPrepared(ASequence: QWord): TRecorderPreparedImpact;
        Procedure RemovePrepared(ASequence: QWord);
        Procedure ClearPrepared;
        Function ResolveTags: Boolean;
        Procedure PrepareCaptureBuffers;
        Function ConfigureRuntime: Boolean;
        Function ImpactSequence: QWord;
        Procedure FillPresentation(Var ASnapshot: TRecorderImpactHammerSnapshot);
      Public 
        constructor Create;
        destructor Destroy;
        override;
        Function Configure(AComponent: TRecorderImpactHammerComponent;
                           ARegistry: TRecorderTagRegistry): Boolean;
        Procedure NavigateToPreviousImpact;
        Procedure NavigateToNextImpact;
        Procedure SetCurrentImpactHidden(AHidden: Boolean);
        Procedure DeleteCurrentImpact;
        Procedure StartMeasurement;
        Procedure ArmMeasurement;
        Procedure StopMeasurement;
        Function Provider: IRecorderFrfProvider;
        Function Revision: QWord;
        Procedure FillSnapshot(out ASnapshot: TRecorderImpactHammerSnapshot);
        property LastError: string read fLastError;
    End;

    Implementation

    constructor TRecorderImpactWorker.Create(AOwner: TRecorderImpactHammerService);
    Begin
      inherited Create(True);
      FreeOnTerminate := False;
      fOwner := AOwner;
      fWake := TEvent.Create(Nil, False, False, '');
      Start;
    End;

    destructor TRecorderImpactWorker.Destroy;
    Begin
      Terminate;
      fWake.SetEvent;
      WaitFor;
      fWake.Free;
      inherited Destroy;
    End;

    Procedure TRecorderImpactWorker.Wake;
    Begin
      fWake.SetEvent;
    End;

    Procedure TRecorderImpactWorker.Execute;
    Begin
      While Not Terminated Do
        Begin
          fWake.WaitFor(INFINITE);
          If Not Terminated Then
            fOwner.ProcessPendingCapture;
        End;
    End;

    constructor TRecorderImpactHammerService.Create;
    Begin
      inherited Create;
      fRuntime := TRecorderImpactRuntime.Create;
      fDsp := TRecorderImpactDspPipeline.Create;
      fLock := TCriticalSection.Create;
      fPrepared := TList.Create;
      fWorker := TRecorderImpactWorker.Create(Self);
      fQualityOk := True;
      Inc(fRevision);
      fCurrentImpact := -1;
    End;

    destructor TRecorderImpactHammerService.Destroy;
    Begin
      If (fSubscription <> 0) And (fRegistry <> Nil) And
         (fRegistry.EventBus <> Nil) Then
        fRegistry.EventBus.Unsubscribe(fSubscription);
      fWorker.Free;
      UnregisterRecorderFrfProvider(Self);
      ClearPrepared;
      fPrepared.Free;
      fDsp.Free;
      fRuntime.Free;
      fLock.Free;
      inherited Destroy;
    End;

    Function TRecorderImpactHammerService.ResolveTags: Boolean;

    Var 
      I: Integer;
    Begin
      Result := (fRegistry <> Nil) And (fModel <> Nil);
      If Not Result Then
        Exit;
      fHammerTag := fRegistry.FindById(fModel.HammerTagId);
      Result := fHammerTag <> Nil;
      If Not Result Then
        Begin
          fLastError := 'Не найден тег ударного молотка.';
          Exit;
        End;
      SetLength(fResponseTags, fModel.ResponseCount);
      For I := 0 To fModel.ResponseCount - 1 Do
        Begin
          fResponseTags[I] := fRegistry.FindById(fModel.Responses[I].TagId);
          If fResponseTags[I] = Nil Then
            Begin
              fLastError := Format('Не найден тег отклика %s.',
                            [fModel.Responses[I].TagName]);
              Exit(False);
            End;
        End;
    End;

    Procedure TRecorderImpactHammerService.PrepareCaptureBuffers;

    Var 
      Channel: Integer;
      Tag: TRecorderTag;
    Begin
      SetLength(fPreloadTimes, Length(fResponseTags) + 1);
      SetLength(fPreloadValues, Length(fResponseTags) + 1);
      For Channel := 0 To High(fPreloadTimes) Do
        Begin
          If Channel = 0 Then
            Tag := fHammerTag
          Else
            Tag := fResponseTags[Channel - 1];
          SetLength(fPreloadTimes[Channel], Tag.SignalBuffer.Capacity);
          SetLength(fPreloadValues[Channel], Tag.SignalBuffer.Capacity);
        End;
    End;

    Function TRecorderImpactHammerService.ConfigureRuntime: Boolean;

    Var 
      RuntimeSettings: TRecorderImpactSettings;
      DspSettings: TRecorderImpactDspSettings;
      I: Integer;
    Begin
      RuntimeSettings := Default(TRecorderImpactSettings);
      RuntimeSettings.SampleRateHz := fModel.SampleRateHz;
      RuntimeSettings.Threshold := fModel.TriggerThreshold;
      RuntimeSettings.Hysteresis := fModel.TriggerHysteresis;
      RuntimeSettings.PretriggerSeconds := fModel.PretriggerSamples /
                                           fModel.SampleRateHz;
      RuntimeSettings.CaptureSeconds := fModel.CaptureSamples /
                                        fModel.SampleRateHz;
      RuntimeSettings.Capacity := fModel.ImpactCapacity;
      RuntimeSettings.ResponseCount := fModel.ResponseCount;
      RuntimeSettings.Polarity := TRecorderImpactPolarity(
                                  Ord(fModel.TriggerPolarity));
      RuntimeSettings.Estimator := TRecorderFrfEstimatorKind(
                                   Ord(fModel.Estimator));
      Result := fRuntime.Configure(RuntimeSettings, fLastError);
      If Not Result Then
        Exit;
      DspSettings := Default(TRecorderImpactDspSettings);
      DspSettings.SampleRateHz := fModel.SampleRateHz;
      DspSettings.CaptureSamples := fModel.CaptureSamples;
      DspSettings.FftSize := fModel.FftSize * fModel.ZeroPadFactor;
      DspSettings.WelchSegmentSamples := fModel.WelchSegmentSize;
      DspSettings.WelchOverlapPercent := fModel.WelchOverlapPercent;
      DspSettings.ResponseCount := fModel.ResponseCount;
      DspSettings.WindowKind := TRecorderImpactWindowKind(Ord(fModel.WindowKind));
      DspSettings.ForceWindowFraction := fModel.ForceWindowFraction;
      DspSettings.ExponentialEndFraction := fModel.ExponentialEndFraction;
      DspSettings.ExcitationUnitName := fModel.ExcitationUnitName;
      SetLength(DspSettings.ResponseUnitNames, fModel.ResponseCount);
      For I := 0 To fModel.ResponseCount - 1 Do
        DspSettings.ResponseUnitNames[I] := fModel.Responses[I].ResponseUnitName;
      Result := fDsp.Configure(DspSettings, fLastError);
    End;

    Function TRecorderImpactHammerService.Configure(
                                                    AComponent: TRecorderImpactHammerComponent;
                                                    ARegistry: TRecorderTagRegistry): Boolean;
    Begin
      UnregisterRecorderFrfProvider(Self);
      If (fSubscription <> 0) And (fRegistry <> Nil) And
         (fRegistry.EventBus <> Nil) Then
        fRegistry.EventBus.Unsubscribe(fSubscription);
      fSubscription := 0;
      FreeAndNil(fWorker);
      fLock.Enter;
      Try
        fModel := AComponent;
        fRegistry := ARegistry;
        fLastError := '';
        fCaptureToken := 0;
        fCurrentImpact := -1;
        fRuntime.Stop;
        ClearPrepared;
        fRuntime.ClearPublished;
        fQualityOk := True;
        Inc(fRevision);
        Result := ResolveTags And ConfigureRuntime;
        If Result Then
          PrepareCaptureBuffers;
        fWorker := TRecorderImpactWorker.Create(Self);
        If Result And (fRegistry.EventBus <> Nil) Then
          fSubscription := fRegistry.EventBus.Subscribe(@HandleEvent);
        If Result Then
          RegisterRecorderFrfProvider(Self, fRuntime.Provider);
      Finally
        fLock.Leave;
    End;
  End;

Procedure TRecorderImpactHammerService.HandleEvent(ASender: TObject;
                                                   Const AEvent: TRecorderEvent);

Var 
  Data: TRecorderTagUpdateEventData;
  I: Integer;
Begin
  If (AEvent.Kind <> rceDataUpdated) Or
     Not (AEvent.Data is TRecorderTagUpdateEventData) Then
    Exit;
  Data := TRecorderTagUpdateEventData(AEvent.Data);
  fLock.Enter;
  Try
    If Data.SampleCount > 0 Then
      Begin
        For I := 0 To Data.SampleCount - 1 Do
          ProcessSample(Data.Tag, Data.Times[I], Data.Values[I]);
      End
    Else
      ProcessSample(Data.Tag, Data.TimeSec, Data.Value);
  Finally
    fLock.Leave;
End;
End;

Procedure TRecorderImpactHammerService.ProcessSample(ATag: TRecorderTag;
                                                     ATime, AValue: Double);

Var 
  TriggerEvent: TRecorderImpactTriggerEvent;
  I: Integer;
Begin
  If (ATag = fHammerTag) And (fCaptureToken = 0) And
     fRuntime.ProcessTriggerSample(ATime, AValue, TriggerEvent) Then
    Begin
      fCaptureToken := TriggerEvent.CaptureToken;
      fCaptureStartSeconds := TriggerEvent.CaptureStartSeconds;
      fCaptureEndSeconds := TriggerEvent.CaptureEndSeconds;
      PreloadCapture;
    End;
  If fCaptureToken = 0 Then
    Exit;
  If fCompletionPending Then
    Exit;
  If ATag = fHammerTag Then
    fRuntime.AddExcitationSample(fCaptureToken, ATime, AValue);
  For I := 0 To High(fResponseTags) Do
    If ATag = fResponseTags[I] Then
      fRuntime.AddResponseSample(fCaptureToken, I, ATime, AValue);
  If fRuntime.CaptureReady(fCaptureToken) Then
    Begin
      fCompletionPending := True;
      Inc(fRevision);
      fWorker.Wake;
    End;
End;

Procedure TRecorderImpactHammerService.ProcessPendingCapture;
Begin
  Try
    Try
      CompleteCapture;
    Except
      on E: Exception Do
            Begin
              fLock.Enter;
              Try
                fLastError := 'Ошибка обработки удара: ' + E.Message;
              Finally
                fLock.Leave;
            End;
End;
End;
Finally
  fLock.Enter;
  Try
    fCompletionPending := False;
    Inc(fRevision);
  Finally
    fLock.Leave;
End;
End;
End;

Procedure TRecorderImpactHammerService.AddSnapshot(ATag: TRecorderTag;
                                                   AChannel: Integer);

Var 
  Times: TRecorderDoubleArray;
  Values: TRecorderDoubleArray;
  Count: Integer;
  I: Integer;
Begin
  Times := fPreloadTimes[AChannel];
  Values := fPreloadValues[AChannel];
  ATag.SnapshotRangeInto(fCaptureStartSeconds, True, Times, Values, Count);
  fPreloadTimes[AChannel] := Times;
  fPreloadValues[AChannel] := Values;
  For I := 0 To Count - 1 Do
    Begin
      If AChannel = 0 Then
        fRuntime.AddExcitationSample(fCaptureToken, Times[I], Values[I])
      Else
        fRuntime.AddResponseSample(fCaptureToken, AChannel - 1,
                                   Times[I], Values[I]);
      If Times[I] >= fCaptureEndSeconds Then
        Break;
    End;
End;

Procedure TRecorderImpactHammerService.PreloadCapture;

Var 
  I: Integer;
Begin
  AddSnapshot(fHammerTag, 0);
  For I := 0 To High(fResponseTags) Do
    AddSnapshot(fResponseTags[I], I + 1);
End;

Procedure TRecorderImpactHammerService.CompleteCapture;

Var 
  Block: TRecorderImpactCaptureBlock;
  Series: TRecorderSampleSeries;
  Resampled: array Of Double;
  Moments: TRecorderImpactSpectralMoments;
  Prepared: TRecorderPreparedImpact;
  Sequence: QWord;
  I: Integer;
  J: Integer;
Begin
  Sequence := fRuntime.RecordImpact(fCaptureToken, True, irrNone);
  fCaptureToken := 0;
  If Sequence = 0 Then
    Exit;
  fCurrentImpact := fRuntime.Impacts.Count - 1;
  Block := fRuntime.Impacts.Capture(fCurrentImpact);
  fDsp.ResetCapture;
  SetLength(Resampled, fModel.CaptureSamples);
  Series := Block.Excitation;
  If Not ResampleImpactSeries(Series, Block.StartSeconds,
     fModel.SampleRateHz, fModel.CaptureSamples, Resampled) Then
    Exit;
  For J := 0 To fModel.CaptureSamples - 1 Do
    fDsp.AddSample(0, Resampled[J]);
  For I := 0 To fModel.ResponseCount - 1 Do
    Begin
      Series := Block.Response(I);
      If Not ResampleImpactSeries(Series, Block.StartSeconds,
         fModel.SampleRateHz, fModel.CaptureSamples, Resampled) Then
        Exit;
      For J := 0 To fModel.CaptureSamples - 1 Do
        fDsp.AddSample(I + 1, Resampled[J]);
    End;
  If Not fDsp.Ready Then
    Exit;
  Prepared := TRecorderPreparedImpact.Create;
  Prepared.Sequence := Sequence;
  SetLength(Prepared.Responses, fModel.ResponseCount);
  For I := 0 To fModel.ResponseCount - 1 Do
    Begin
      If Not fDsp.PrepareResponse(I, Moments) Then
        Begin
          Prepared.Free;
          Exit;
        End;
      Prepared.Responses[I] := Moments;
    End;
  fPrepared.Add(Prepared);
  RecomputeAndPublish;
End;

Function TRecorderImpactHammerService.FindPrepared(
                                                   ASequence: QWord): TRecorderPreparedImpact;

Var 
  I: Integer;
Begin
  Result := Nil;
  For I := 0 To fPrepared.Count - 1 Do
    If TRecorderPreparedImpact(fPrepared[I]).Sequence = ASequence Then
      Exit(TRecorderPreparedImpact(fPrepared[I]));
End;

Procedure TRecorderImpactHammerService.RemovePrepared(ASequence: QWord);

Var 
  Item: TRecorderPreparedImpact;
Begin
  Item := FindPrepared(ASequence);
  If Item = Nil Then
    Exit;
  fPrepared.Remove(Item);
  Item.Free;
End;

Procedure TRecorderImpactHammerService.ClearPrepared;
Begin
  While fPrepared.Count > 0 Do
    Begin
      TObject(fPrepared.Last).Free;
      fPrepared.Delete(fPrepared.Count - 1);
    End;
End;

Procedure TRecorderImpactHammerService.RecomputeAndPublish;

Var 
  Curves: array Of TRecorderFrfCurveData;
  Included: array Of TRecorderImpactMomentsArray;
  EstimateInput: TRecorderImpactMomentsArray;
  Estimate: TRecorderFrfEstimate;
  RecordItem: TRecorderImpactRecord;
  Prepared: TRecorderPreparedImpact;
  I: Integer;
  J: Integer;
  ResponseIndex: Integer;
  Count: Integer;
Begin
  SetLength(Included, fRuntime.Impacts.Count);
  Count := 0;
  For I := 0 To fRuntime.Impacts.Count - 1 Do
    Begin
      RecordItem := fRuntime.Impacts.Item(I);
      If Not RecordItem.Accepted Or RecordItem.Hidden Then
        Continue;
      Prepared := FindPrepared(RecordItem.Sequence);
      If Prepared <> Nil Then
        Begin
          Included[Count] := Prepared.Responses;
          Inc(Count);
        End;
    End;
  If Count = 0 Then
    Begin
      fRuntime.ClearPublished;
      SetLength(fPublishedCurves, 0);
      fQualityOk := True;
      Exit;
    End;
  SetLength(Curves, fModel.ResponseCount);
  fQualityOk := True;
  For ResponseIndex := 0 To fModel.ResponseCount - 1 Do
    Begin
      SetLength(EstimateInput, Count);
      For I := 0 To Count - 1 Do
        EstimateInput[I] := Included[I][ResponseIndex];
      If Not EstimateImpactMoments(EstimateInput,
         TRecorderFrfEstimatorKind(Ord(fModel.Estimator)), Estimate) Then
        Exit;
      Curves[ResponseIndex].Id := fModel.Responses[ResponseIndex].CurveId;
      Curves[ResponseIndex].FrequencyHz := Estimate.FrequencyHz;
      Curves[ResponseIndex].Magnitude := Estimate.Magnitude;
      Curves[ResponseIndex].PhaseRadians := Estimate.PhaseRadians;
      Curves[ResponseIndex].Coherence := Estimate.Coherence;
      For J := 0 To High(Estimate.Coherence) Do
        If Estimate.Coherence[J] < fModel.CoherenceThreshold Then
          fQualityOk := False;
    End;
  fRuntime.PublishCurves(Curves);
  fPublishedCurves := Copy(Curves);
End;

Procedure TRecorderImpactHammerService.FillPresentation(
                                                        Var ASnapshot: TRecorderImpactHammerSnapshot
);

Var 
  Block: TRecorderImpactCaptureBlock;
  Prepared: TRecorderPreparedImpact;
  Series: TRecorderSampleSeries;
  Curve: ^TRecorderImpactPresentationCurve;
  ResultType: TRecorderImpactResultType;
  ResponseIndex: Integer;
  CurveIndex: Integer;

Procedure InitializeResult(AType: TRecorderImpactResultType;
                           Const AXUnit: String; ACount: Integer);
Begin
  ASnapshot.Results[AType].ResultType := AType;
  ASnapshot.Results[AType].XUnitName := AXUnit;
  SetLength(ASnapshot.Results[AType].Curves, ACount);
End;

Procedure SetCurveIdentity(AType: TRecorderImpactResultType;
                           AIndex: Integer; AId: QWord; Const AName, AUnit: String;
                           AColor: LongInt; AVisible: Boolean);
Begin
  Curve := @ASnapshot.Results[AType].Curves[AIndex];
  Curve^.CurveId := AId;
  Curve^.Name := AName;
  Curve^.UnitName := AUnit;
  Curve^.Color := AColor;
  Curve^.Visible := AVisible;
  Curve^.Quality := icqGood;
End;

Procedure CopyTimeSeries(AType: TRecorderImpactResultType; AIndex: Integer;
                         Const ASeries: TRecorderSampleSeries);

Var 
  I: Integer;
Begin
  Curve := @ASnapshot.Results[AType].Curves[AIndex];
  SetLength(Curve^.X, Length(ASeries));
  SetLength(Curve^.Y, Length(ASeries));
  For I := 0 To High(ASeries) Do
    Begin
      Curve^.X[I] := ASeries[I].TimeSeconds -
                     Block.StartSeconds;
      Curve^.Y[I] := ASeries[I].Value;
    End;
End;

Procedure CopySpectrum(AIndex: Integer; Const AFrequency, APower: Array Of Double);

Var 
  I: Integer;
Begin
  Curve := @ASnapshot.Results[irtSpectrum].Curves[AIndex];
  SetLength(Curve^.X, Length(AFrequency));
  For I := 0 To High(AFrequency) Do
    Curve^.X[I] := AFrequency[I];
  SetLength(Curve^.Y, Length(APower));
  For I := 0 To High(APower) Do
    Curve^.Y[I] := Sqrt(Max(0.0, APower[I]));
End;

Procedure CopyPublished(AType: TRecorderImpactResultType; AIndex: Integer;
                        Const AX, AY: Array Of Double);

Var 
  I: Integer;
Begin
  Curve := @ASnapshot.Results[AType].Curves[AIndex];
  SetLength(Curve^.X, Length(AX));
  SetLength(Curve^.Y, Length(AY));
  For I := 0 To High(AX) Do
    Curve^.X[I] := AX[I];
  For I := 0 To High(AY) Do
    Curve^.Y[I] := AY[I];
End;

Begin
  For ResultType := Low(TRecorderImpactResultType) To
      High(TRecorderImpactResultType) Do
    Begin
      ASnapshot.Results[ResultType].ResultType := ResultType;
      SetLength(ASnapshot.Results[ResultType].Curves, 0);
    End;
  If (fCurrentImpact < 0) Or (fCurrentImpact >= fRuntime.Impacts.Count) Then
    Exit;
  Block := fRuntime.Impacts.Capture(fCurrentImpact);
  Prepared := FindPrepared(fRuntime.Impacts.Item(fCurrentImpact).Sequence);

  InitializeResult(irtTime, 's', fModel.ResponseCount + 1);
  SetCurveIdentity(irtTime, 0, 0, fModel.HammerTagName,
                   fModel.ExcitationUnitName, $0000FF, fModel.ExcitationVisible);
  Series := Block.Excitation;
  CopyTimeSeries(irtTime, 0, Series);
  For ResponseIndex := 0 To fModel.ResponseCount - 1 Do
    Begin
      SetCurveIdentity(irtTime, ResponseIndex + 1,
                       fModel.Responses[ResponseIndex].CurveId,
                       fModel.Responses[ResponseIndex].TagName,
                       fModel.Responses[ResponseIndex].ResponseUnitName,
                       fModel.Responses[ResponseIndex].Color,
                       fModel.Responses[ResponseIndex].Visible);
      Series := Block.Response(ResponseIndex);
      CopyTimeSeries(irtTime, ResponseIndex + 1, Series);
    End;

  If Prepared <> Nil Then
    Begin
      InitializeResult(irtSpectrum, 'Hz', fModel.ResponseCount + 1);
      SetCurveIdentity(irtSpectrum, 0, 0, fModel.HammerTagName,
                       fModel.ExcitationUnitName, $0000FF, fModel.ExcitationVisible);
      If Length(Prepared.Responses) > 0 Then
        CopySpectrum(0, Prepared.Responses[0].FrequencyHz,
                     Prepared.Responses[0].ExcitationPower);
      For ResponseIndex := 0 To High(Prepared.Responses) Do
        Begin
          SetCurveIdentity(irtSpectrum, ResponseIndex + 1,
                           fModel.Responses[ResponseIndex].CurveId,
                           fModel.Responses[ResponseIndex].TagName,
                           fModel.Responses[ResponseIndex].ResponseUnitName,
                           fModel.Responses[ResponseIndex].Color,
                           fModel.Responses[ResponseIndex].Visible);
          CopySpectrum(ResponseIndex + 1,
                       Prepared.Responses[ResponseIndex].FrequencyHz,
                       Prepared.Responses[ResponseIndex].ResponsePower);
        End;
    End;

  For ResultType := irtFrfMagnitude To irtCoherence Do
    InitializeResult(ResultType, 'Hz', Length(fPublishedCurves));
  For CurveIndex := 0 To High(fPublishedCurves) Do
    Begin
      ResponseIndex := CurveIndex;
      For ResultType := irtFrfMagnitude To irtCoherence Do
        SetCurveIdentity(ResultType, CurveIndex,
                         fPublishedCurves[CurveIndex].Id,
                         fModel.Responses[ResponseIndex].TagName,
                         fModel.Responses[ResponseIndex].ResponseUnitName,
                         fModel.Responses[ResponseIndex].Color,
                         fModel.Responses[ResponseIndex].Visible);
      CopyPublished(irtFrfMagnitude, CurveIndex,
                    fPublishedCurves[CurveIndex].FrequencyHz,
                    fPublishedCurves[CurveIndex].Magnitude);
      CopyPublished(irtPhase, CurveIndex,
                    fPublishedCurves[CurveIndex].FrequencyHz,
                    fPublishedCurves[CurveIndex].PhaseRadians);
      CopyPublished(irtCoherence, CurveIndex,
                    fPublishedCurves[CurveIndex].FrequencyHz,
                    fPublishedCurves[CurveIndex].Coherence);
    End;
End;

Function TRecorderImpactHammerService.ImpactSequence: QWord;
Begin
  Result := 0;
  If (fCurrentImpact >= 0) And
     (fCurrentImpact < fRuntime.Impacts.Count) Then
    Result := fRuntime.Impacts.Item(fCurrentImpact).Sequence;
End;

Procedure TRecorderImpactHammerService.NavigateToPreviousImpact;
Begin
  fLock.Enter;
  Try
    If fCompletionPending Then
      Exit;
    If fCurrentImpact > 0 Then
      Begin
        Dec(fCurrentImpact);
        Inc(fRevision);
      End;
  Finally
    fLock.Leave;
End;
End;

Procedure TRecorderImpactHammerService.NavigateToNextImpact;
Begin
  fLock.Enter;
  Try
    If fCompletionPending Then
      Exit;
    If fCurrentImpact + 1 < fRuntime.Impacts.Count Then
      Begin
        Inc(fCurrentImpact);
        Inc(fRevision);
      End;
  Finally
    fLock.Leave;
End;
End;

Procedure TRecorderImpactHammerService.SetCurrentImpactHidden(AHidden: Boolean);
Begin
  fLock.Enter;
  Try
    If fCompletionPending Then
      Exit;
    If ImpactSequence <> 0 Then
      If fRuntime.Impacts.SetHidden(ImpactSequence, AHidden) Then
        Begin
          RecomputeAndPublish;
          Inc(fRevision);
        End;
  Finally
    fLock.Leave;
End;
End;

Procedure TRecorderImpactHammerService.DeleteCurrentImpact;
Begin
  fLock.Enter;
  Try
    If fCompletionPending Then
      Exit;
    If ImpactSequence <> 0 Then
      Begin
        RemovePrepared(ImpactSequence);
        If fRuntime.Impacts.Delete(ImpactSequence) Then
          Begin
            If fCurrentImpact >= fRuntime.Impacts.Count Then
              fCurrentImpact := fRuntime.Impacts.Count - 1;
            RecomputeAndPublish;
            Inc(fRevision);
          End;
      End;
  Finally
    fLock.Leave;
End;
End;

Procedure TRecorderImpactHammerService.StartMeasurement;
Begin
  fLock.Enter;
  Try
    If fCompletionPending Then
      Exit;
    fRuntime.Stop;
    fRuntime.Arm;
    Inc(fRevision);
  Finally
    fLock.Leave;
End;
End;

Procedure TRecorderImpactHammerService.ArmMeasurement;
Begin
  fLock.Enter;
  Try
    If fCompletionPending Then
      Exit;
    fRuntime.Arm;
    Inc(fRevision);
  Finally
    fLock.Leave;
End;
End;

Procedure TRecorderImpactHammerService.StopMeasurement;
Begin
  fLock.Enter;
  Try
    If fCompletionPending Then
      Exit;
    fRuntime.Stop;
    fCaptureToken := 0;
    Inc(fRevision);
  Finally
    fLock.Leave;
End;
End;

Function TRecorderImpactHammerService.Provider: IRecorderFrfProvider;
Begin
  Result := fRuntime.Provider;
End;

Function TRecorderImpactHammerService.Revision: QWord;
Begin
  fLock.Enter;
  Try
    Result := fRevision;
  Finally
    fLock.Leave;
End;
End;

Procedure TRecorderImpactHammerService.FillSnapshot(
                                                    out ASnapshot: TRecorderImpactHammerSnapshot);

Var 
  Item: TRecorderImpactRecord;
Begin
  fLock.Enter;
  Try
    ASnapshot := Default(TRecorderImpactHammerSnapshot);
    If fCompletionPending Then
      Begin
        ASnapshot.State := ihsRunning;
        ASnapshot.StatusText := 'Обработка удара...';
        ASnapshot.CanStop := False;
        Exit;
      End;
    Case fRuntime.State Of 
      isIdle:
              ASnapshot.State := ihsIdle;
      isArmed:
               ASnapshot.State := ihsArmed;
      isCapturing:
                   ASnapshot.State := ihsRunning;
      isStopped:
                 ASnapshot.State := ihsIdle;
      isFaulted:
                 ASnapshot.State := ihsFault;
    End;
    ASnapshot.StatusText := fLastError;
    If (ASnapshot.StatusText = '') And Not fQualityOk Then
      ASnapshot.StatusText := 'Когерентность ниже заданного порога.'
    ;
    ASnapshot.ImpactIndex := fCurrentImpact;
    ASnapshot.ImpactCount := fRuntime.Impacts.Count;
    ASnapshot.CanNavigatePrevious := fCurrentImpact > 0;
    ASnapshot.CanNavigateNext := fCurrentImpact + 1 < fRuntime.Impacts.Count;
    ASnapshot.CanHide := fCurrentImpact >= 0;
    ASnapshot.CanDelete := fCurrentImpact >= 0;
    ASnapshot.CanStart := True;
    ASnapshot.CanArm := fRuntime.State = isStopped;
    ASnapshot.CanStop := fRuntime.State In [isArmed, isCapturing];
    If fCurrentImpact >= 0 Then
      Begin
        Item := fRuntime.Impacts.Item(fCurrentImpact);
        ASnapshot.ImpactHidden := Item.Hidden;
      End;
    FillPresentation(ASnapshot);
  Finally
    fLock.Leave;
End;
End;

End.
