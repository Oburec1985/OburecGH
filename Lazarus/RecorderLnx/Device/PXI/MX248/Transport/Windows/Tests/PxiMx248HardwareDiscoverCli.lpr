program PxiMx248HardwareDiscoverCli;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Math, Variants, uRecorderAcquisitionTypes,
  uRecorderDeviceInterfaces, uRecorderDriverContractsV2,
  uRecorderDataSources, uRecorderTags,
  uRecorderPxiMx248Types, uRecorderPxiMx248RuntimeTransport,
  uRecorderPxiMx248DataSource,
  uRecorderPxiMx248DeviceAdapter,
  uRecorderPxiMx248WindowsTransport;

var
  lBlockCount, lTickCount, lExitCode, lFiniteChannelSamples: Integer;
  lZeroTotal, lNonFiniteTotal, lChangingBlocks: Int64;
  lTotalSamples: Int64;
  lStartedAt, lElapsedMs: QWord;
  lBridgePath: string;
  lDevices: TPxiMx248DiscoveredDevices;
  lResult: TRcOperationResult;
  lTransport: TRecorderPxiMx248WindowsTransport;
  lConfiguration: TPxiMx248Configuration;
  lBlock: TRcAcquisitionBlock;
  lLiveProperties, lSerial, lVersion, lZeroValues: string;
  lMin, lMax, lSum, lSumSquares, lValue: Double;
  lPreviousBlock: TRcAcquisitionBlock;
  lHasPreviousBlock: Boolean;
  lAdapter: TRcPxiMx248DeviceAdapter;

procedure Run;
var
  I: Integer;

  function TestPxiSettings: string;
  begin
    Result := Trim(GetEnvironmentVariable('RECORDER_MX248_TEST_PXI'));
    if Result = '' then Result := 'pxi.bus-role=Master';
  end;

  function BlocksDiffer(const A, B: TRcAcquisitionBlock): Boolean;
  var
    Channel, Sample: Integer;
  begin
    Result := (A.ChannelCount <> B.ChannelCount) or
      (A.SampleCount <> B.SampleCount);
    if Result then Exit;
    for Channel := 0 to A.ChannelCount - 1 do
    begin
      if Length(A.Values[Channel]) <> Length(B.Values[Channel]) then
        Exit(True);
      for Sample := 0 to High(A.Values[Channel]) do
        if A.Values[Channel][Sample] <> B.Values[Channel][Sample] then
          Exit(True);
    end;
    Result := False;
  end;

  procedure ReadAndReportBlocks(AUseAdapter: Boolean; ACount: Integer);
  var
    BlockIndex, ChannelIndex, SampleIndex: Integer;
    ReadSucceeded: Boolean;
  begin
    lZeroTotal := 0;
    lNonFiniteTotal := 0;
    lChangingBlocks := 0;
    lTotalSamples := 0;
    lHasPreviousBlock := False;
    lExitCode := 0;
    lStartedAt := GetTickCount64;
    for BlockIndex := 1 to ACount do
    begin
      if AUseAdapter then
      begin
        ReadSucceeded := lAdapter.ReadBlock(30000, lBlock);
        if ReadSucceeded then
          lResult := TRcOperationResult.Success
        else
          lResult := TRcOperationResult.Failure(rocTransport,
            'mx248.runtime.read', VarToStr(lAdapter.GetDeviceProperty(rdpErrorText)));
      end
      else
      begin
        lResult := lTransport.ReadBlock(30000, lBlock);
        ReadSucceeded := lResult.IsSuccess;
      end;
      WriteLn(Format('read_block[%d]_code=%d', [BlockIndex, Ord(lResult.Code)]));
      WriteLn(Format('read_block[%d]_stage=%s', [BlockIndex, lResult.Stage]));
      WriteLn(Format('read_block[%d]_channels=%d', [BlockIndex, lBlock.ChannelCount]));
      WriteLn(Format('read_block[%d]_samples=%d', [BlockIndex, lBlock.SampleCount]));
      WriteLn(Format('read_block[%d]_rate=%g', [BlockIndex, lBlock.SampleRateHz]));
      if not ReadSucceeded then
      begin
        lExitCode := 13;
        Break;
      end;
      Inc(lTotalSamples, Int64(lBlock.ChannelCount) * lBlock.SampleCount);
      if lHasPreviousBlock and BlocksDiffer(lPreviousBlock, lBlock) then
        Inc(lChangingBlocks);
      for ChannelIndex := 0 to lBlock.ChannelCount - 1 do
      begin
        lMin := Infinity;
        lMax := NegInfinity;
        lSum := 0;
        lSumSquares := 0;
        lFiniteChannelSamples := 0;
        for SampleIndex := 0 to lBlock.SampleCount - 1 do
        begin
          lValue := lBlock.Values[ChannelIndex][SampleIndex];
          if IsNan(lValue) or IsInfinite(lValue) then
          begin
            Inc(lNonFiniteTotal);
            lExitCode := 15;
            Continue;
          end;
          Inc(lFiniteChannelSamples);
          if Abs(lValue) <= 1E-20 then Inc(lZeroTotal);
          lMin := Min(lMin, lValue);
          lMax := Max(lMax, lValue);
          lSum := lSum + lValue;
          lSumSquares := lSumSquares + Sqr(lValue);
        end;
        if lFiniteChannelSamples > 0 then
          WriteLn(Format('read_block[%d]_ch[%d]_min=%g max=%g mean=%g rms=%g first=%g last=%g finite_samples=%d',
            [BlockIndex, ChannelIndex + 1, lMin, lMax, lSum / lFiniteChannelSamples,
            Sqrt(lSumSquares / lFiniteChannelSamples), lBlock.Values[ChannelIndex][0],
            lBlock.Values[ChannelIndex][lBlock.SampleCount - 1], lFiniteChannelSamples]));
      end;
      CopyRecorderAcquisitionBlock(lBlock, lPreviousBlock);
      lHasPreviousBlock := True;
      if lExitCode <> 0 then Break;
    end;
    lElapsedMs := GetTickCount64 - lStartedAt;
    WriteLn('zero_value_count=', lZeroTotal);
    WriteLn('nonfinite_value_count=', lNonFiniteTotal);
    WriteLn('changing_block_count=', lChangingBlocks);
    WriteLn('total_samples=', lTotalSamples);
    WriteLn('elapsed_ms=', lElapsedMs);
  end;

  procedure RunAdapterAcquisition;
  var
    RuntimeTransport: IPxiMx248BlockTransport;
    DefaultValues: TStringList;
    StageText: string;
    ValueIndex: Integer;
    Started: Boolean;
  begin
    RuntimeTransport := TRecorderPxiMx248WindowsTransport.Create(
      lDevices[0].Chassis, lDevices[0].Slot, lBridgePath, 30000);
    lAdapter := TRcPxiMx248DeviceAdapter.Create(
      Format('PXI:%d:%d', [lDevices[0].Chassis, lDevices[0].Slot]),
      lDevices[0].DeviceName, RuntimeTransport);
    Started := False;
    StageText := 'SetProp';
    try
      try
        lLiveProperties := lAdapter.GetProp('*');
        if Trim(lLiveProperties) = '' then
          raise Exception.Create('Could not serialize default properties');
        DefaultValues := TStringList.Create;
        try
          DefaultValues.StrictDelimiter := True;
          DefaultValues.Delimiter := ';';
          DefaultValues.NameValueSeparator := '=';
          DefaultValues.DelimitedText := lLiveProperties;
          for ValueIndex := DefaultValues.Count - 1 downto 0 do
            if SameText(DefaultValues.Names[ValueIndex], 'device.type') then
              DefaultValues.Delete(ValueIndex);
          if not lAdapter.SetProp(DefaultValues.DelimitedText) then
            raise Exception.Create(VarToStr(
              lAdapter.GetDeviceProperty(rdpErrorText)));
        finally
          DefaultValues.Free;
        end;
        lAdapter.LoadPxiSettings(TestPxiSettings);
        WriteLn('runtime_pxi_settings=', TestPxiSettings);
        StageText := 'Connect';
        lAdapter.Connect;
        WriteLn('runtime_connect=ok');
        StageText := 'InitializeDevice';
        lAdapter.InitializeDevice;
        WriteLn('runtime_initialize=ok');
        StageText := 'ConfigureDevice';
        lAdapter.ConfigureDevice;
        WriteLn('runtime_configure=ok');
        StageText := 'Start';
        lAdapter.Start;
        Started := True;
        WriteLn('runtime_start=ok');
        StageText := 'ReadBlock';
        ReadAndReportBlocks(True, lBlockCount);
      except
        on E: Exception do
        begin
          if lExitCode = 0 then lExitCode := 20;
          WriteLn('runtime_error_stage=', StageText);
          WriteLn('runtime_error=', E.Message);
        end;
      end;
    finally
      if Started then
      begin
        try
          StageText := 'Stop';
          lAdapter.Stop;
          WriteLn('runtime_stop=ok');
        except
          on E: Exception do
          begin
            if lExitCode = 0 then lExitCode := 21;
            WriteLn('runtime_stop_error=', E.Message);
          end;
        end;
      end;
      try
        StageText := 'Disconnect';
        lAdapter.Disconnect;
        WriteLn('runtime_disconnect=ok');
      except
        on E: Exception do
        begin
          if lExitCode = 0 then lExitCode := 22;
          WriteLn('runtime_disconnect_error=', E.Message);
        end;
      end;
      FreeAndNil(lAdapter);
      RuntimeTransport := nil;
    end;
  end;

  procedure RunDataSource;
  var
    RuntimeTransport: IPxiMx248BlockTransport;
    Device: IRecorderDevice;
    SourceRef: IRecorderDataSource;
    Source: TRecorderPxiMx248DataSource;
    Registry: TRecorderTagRegistry;
    DefaultValues: TStringList;
    StageText: string;
    ValueIndex, TickIndex, TagIndex: Integer;
    Started, SourceCreated: Boolean;
    Tag: TRecorderTag;
    History, LastBlock: TRecorderSignalSnapshot;
    TotalHistorySamples: Int64;
    ExpectedBlockSamples: Integer;
    ExpectedBlockCount: Int64;
    ExpectedSamplesPerChannel, SamplesPerChannel: Int64;
    ActualBlockCount: QWord;
    NextTickMs, NowMs: QWord;
    TickPeriodMs: Cardinal;
    ReadErrorText: string;
    BlockSamplesText: string;
  begin
    RuntimeTransport := TRecorderPxiMx248WindowsTransport.Create(
      lDevices[0].Chassis, lDevices[0].Slot, lBridgePath, 30000);
    lAdapter := TRcPxiMx248DeviceAdapter.Create(
      Format('PXI:%d:%d', [lDevices[0].Chassis, lDevices[0].Slot]),
      lDevices[0].DeviceName, RuntimeTransport);
    Device := lAdapter;
    Registry := TRecorderTagRegistry.Create(nil);
    Source := nil;
    SourceRef := nil;
    Started := False;
    SourceCreated := False;
    StageText := 'SetProp';
    lExitCode := 0;
    try
      try
        lLiveProperties := lAdapter.GetProp('*');
        if Trim(lLiveProperties) = '' then
          raise Exception.Create('Could not serialize default properties');
        DefaultValues := TStringList.Create;
        try
          DefaultValues.StrictDelimiter := True;
          DefaultValues.Delimiter := ';';
          DefaultValues.NameValueSeparator := '=';
          DefaultValues.DelimitedText := lLiveProperties;
          for ValueIndex := DefaultValues.Count - 1 downto 0 do
            if SameText(DefaultValues.Names[ValueIndex], 'device.type') then
              DefaultValues.Delete(ValueIndex);
          if not lAdapter.SetProp(DefaultValues.DelimitedText) then
            raise Exception.Create(VarToStr(
              lAdapter.GetDeviceProperty(rdpErrorText)));
        finally
          DefaultValues.Free;
        end;
        lAdapter.LoadPxiSettings(TestPxiSettings);
        WriteLn('datasource_pxi_settings=', TestPxiSettings);
        Source := TRecorderPxiMx248DataSource.Create(
          Format('PXI:%d:%d', [lDevices[0].Chassis, lDevices[0].Slot]),
          Device, 200);
        SourceRef := Source;
        SourceCreated := True;
        StageText := 'Registry.ConfigureTags';
        Source.ConfigureTags(Registry);
        WriteLn('datasource_configure_tags=ok');
        StageText := 'PrepareHardware';
        Source.PrepareHardware;
        WriteLn('datasource_prepare_hardware=ok');
        BlockSamplesText := lAdapter.GetProp('block-samples');
        if not TryStrToInt(Copy(BlockSamplesText,
          Pos('=', BlockSamplesText) + 1, MaxInt), ExpectedBlockSamples) then
          ExpectedBlockSamples := 0;
        StageText := 'Start';
        Source.Start;
        Started := True;
        WriteLn('datasource_start=ok');
        lStartedAt := GetTickCount64;
        TickPeriodMs := Source.UpdateTimeMs;
        NextTickMs := lStartedAt + TickPeriodMs;
        ExpectedSamplesPerChannel := 0;
        ExpectedBlockCount := 0;
        SamplesPerChannel := 0;
        ActualBlockCount := 0;
        for TickIndex := 1 to lTickCount do
        begin
          NowMs := GetTickCount64;
          if NextTickMs > NowMs then
            Sleep(Cardinal(NextTickMs - NowMs));
          StageText := Format('Tick[%d]', [TickIndex]);
          Source.Tick;
          ReadErrorText := Trim(VarToStr(
            lAdapter.GetDeviceProperty(rdpErrorText)));
          if ReadErrorText <> '' then
            raise Exception.Create(ReadErrorText);
          WriteLn(Format('datasource_tick[%d]=ok', [TickIndex]));

          Inc(NextTickMs, TickPeriodMs);
          NowMs := GetTickCount64;
          if NextTickMs <= NowMs then
          begin
            if NowMs - NextTickMs >= TickPeriodMs then
              NextTickMs := NowMs + TickPeriodMs
            else
              NextTickMs := NowMs + 1;
          end;
        end;
        lElapsedMs := GetTickCount64 - lStartedAt;
        TotalHistorySamples := 0;
        WriteLn('datasource_tag_count=', Registry.TagCount);
        WriteLn('datasource_expected_block_samples=', ExpectedBlockSamples);
        for TagIndex := 0 to Registry.TagCount - 1 do
        begin
          Tag := Registry.Tags[TagIndex];
          History := Tag.Snapshot;
          LastBlock := Tag.LastBlockSnapshot;
          if (TagIndex = 0) then
          begin
            SamplesPerChannel := History.Count;
            ActualBlockCount := Tag.BlockCounter;
            ExpectedSamplesPerChannel := Round(lTickCount * TickPeriodMs *
              Tag.PollFrequencyHz / 1000.0);
            if ExpectedBlockSamples > 0 then
              ExpectedBlockCount := Round(ExpectedSamplesPerChannel /
                ExpectedBlockSamples);
          end;
          Inc(TotalHistorySamples, History.Count);
          if History.Count > 0 then
            WriteLn(Format('tag[%d] name=%s history=%d capacity=%d latest=%g latest_time=%.9f block_samples=%d block_counter=%d units=%s source_units=%s rate=%g history_first=%.9f history_last=%.9f block_first=%.9f block_last=%.9f',
              [TagIndex + 1, Tag.Name, History.Count, Tag.SignalBuffer.Capacity,
              History.Values[History.Count - 1], History.Times[History.Count - 1],
              LastBlock.Count, Tag.BlockCounter, Tag.UnitName, Tag.SourceUnitName,
              Tag.PollFrequencyHz, History.Times[0],
              History.Times[History.Count - 1], LastBlock.Times[0],
              LastBlock.Times[LastBlock.Count - 1]]))
          else
            WriteLn(Format('tag[%d] name=%s history=0 capacity=%d block_samples=%d block_counter=%d units=%s source_units=%s rate=%g',
              [TagIndex + 1, Tag.Name, Tag.SignalBuffer.Capacity,
              LastBlock.Count, Tag.BlockCounter, Tag.UnitName,
              Tag.SourceUnitName, Tag.PollFrequencyHz]));
          if (History.Count = 0) or (LastBlock.Count <> ExpectedBlockSamples) then
            if lExitCode = 0 then lExitCode := 24;
        end;
        WriteLn('datasource_expected_samples_per_channel=',
          ExpectedSamplesPerChannel);
        WriteLn('datasource_history_samples_per_channel=', SamplesPerChannel);
        WriteLn('datasource_expected_blocks=', ExpectedBlockCount);
        WriteLn('datasource_published_blocks=', ActualBlockCount);
        WriteLn('datasource_total_samples_in_history=', TotalHistorySamples);
        WriteLn('datasource_elapsed_ms=', lElapsedMs);
        if (ExpectedBlockCount > 0) and
          (Abs(Int64(ActualBlockCount) - ExpectedBlockCount) > 1) and
          (lExitCode = 0) then
          lExitCode := 27;
      except
        on E: Exception do
        begin
          if lExitCode = 0 then lExitCode := 23;
          WriteLn('datasource_error_stage=', StageText);
          WriteLn('datasource_error=', E.Message);
        end;
      end;
    finally
      if Started then
      begin
        try
          StageText := 'Stop';
          Source.Stop;
          WriteLn('datasource_stop=ok');
        except
          on E: Exception do
          begin
            if lExitCode = 0 then lExitCode := 25;
            WriteLn('datasource_stop_error=', E.Message);
          end;
        end;
      end;
      if SourceCreated then
      begin
        SourceRef := nil;
        Source := nil;
      end;
      try
        lAdapter.Disconnect;
        WriteLn('datasource_disconnect=ok');
      except
        on E: Exception do
        begin
          if lExitCode = 0 then lExitCode := 26;
          WriteLn('datasource_disconnect_error=', E.Message);
        end;
      end;
      Device := nil;
      lAdapter := nil;
      Registry.Free;
      RuntimeTransport := nil;
    end;
  end;
begin
  if (ParamCount < 1) or (ParamCount > 3) or not FileExists(ParamStr(1)) then
  begin
    WriteLn('Usage: PxiMx248HardwareDiscoverCli <bridge.exe> [--maintenance|--acquire [blocks]|--runtime [blocks]|--datasource [ticks]]');
    lExitCode := 2;
    Exit;
  end;
  if (ParamCount >= 2) and not (SameText(ParamStr(2), '--maintenance') or
    SameText(ParamStr(2), '--acquire') or SameText(ParamStr(2), '--runtime') or
    SameText(ParamStr(2), '--datasource')) then
  begin
    WriteLn('Mode must be --maintenance, --acquire or --runtime.');
    lExitCode := 2;
    Exit;
  end;
  if (ParamCount = 3) and
    ((not (SameText(ParamStr(2), '--acquire') or
    SameText(ParamStr(2), '--runtime') or SameText(ParamStr(2), '--datasource'))) or
    (not TryStrToInt(ParamStr(3), lBlockCount)) or (lBlockCount < 1)) then
  begin
    WriteLn('The optional count requires --acquire, --runtime or --datasource and a positive integer.');
    lExitCode := 2;
    Exit;
  end;
  if ParamCount = 3 then lBlockCount := StrToInt(ParamStr(3))
  else lBlockCount := 4;
  lTickCount := 20;
  if (ParamCount >= 2) and SameText(ParamStr(2), '--datasource') and
    (ParamCount = 3) then lTickCount := lBlockCount;
  lZeroTotal := 0;
  lNonFiniteTotal := 0;
  lChangingBlocks := 0;
  lTotalSamples := 0;
  lExitCode := 0;
  lHasPreviousBlock := False;
  lBridgePath := ExpandFileName(ParamStr(1));
  WriteLn('bridge=', lBridgePath);
  WriteLn('vendor_dir=', GetEnvironmentVariable('RECORDER_MX248_VENDOR_DIR'));
  lResult := RecorderDiscoverPxiMx248(lDevices, lBridgePath);
  WriteLn('result_code=', Ord(lResult.Code));
  WriteLn('result_stage=', lResult.Stage);
  WriteLn('result_text=', lResult.MessageText);
  WriteLn('device_count=', Length(lDevices));
  for I := 0 to High(lDevices) do
    WriteLn(Format('device[%d]=index:%d serial:%d revision:%d name:%s ' +
      'chassis_type:%d chassis:%d slot:%d', [I, lDevices[I].DeviceIndex,
      lDevices[I].SerialNumber, lDevices[I].Revision, lDevices[I].DeviceName,
      lDevices[I].ChassisType, lDevices[I].Chassis, lDevices[I].Slot]));
  if not lResult.IsSuccess then begin lExitCode := 1; Exit; end;
  if Length(lDevices) = 0 then begin lExitCode := 3; Exit; end;
  if (ParamCount >= 2) and SameText(ParamStr(2), '--runtime') then
  begin
    RunAdapterAcquisition;
    Exit;
  end;
  if (ParamCount >= 2) and SameText(ParamStr(2), '--datasource') then
  begin
    RunDataSource;
    Exit;
  end;
  lTransport := TRecorderPxiMx248WindowsTransport.Create(lDevices[0].Chassis,
    lDevices[0].Slot, lBridgePath, 30000);
  try
    lResult := lTransport.Connect;
    WriteLn('connect_code=', Ord(lResult.Code));
    WriteLn('connect_stage=', lResult.Stage);
    WriteLn('connect_text=', lResult.MessageText);
    if not lResult.IsSuccess then begin lExitCode := 4; Exit; end;
    lResult := lTransport.Initialize(lSerial, lVersion);
    WriteLn('initialize_code=', Ord(lResult.Code));
    WriteLn('initialize_stage=', lResult.Stage);
    WriteLn('initialize_text=', lResult.MessageText);
    WriteLn('serial=', lSerial);
    WriteLn('version=', lVersion);
    if not lResult.IsSuccess then begin lExitCode := 5; Exit; end;
    lResult := lTransport.TestLink;
    WriteLn('test_code=', Ord(lResult.Code));
    WriteLn('test_stage=', lResult.Stage);
    WriteLn('test_text=', lResult.MessageText);
    if not lResult.IsSuccess then begin lExitCode := 6; Exit; end;
    lResult := lTransport.ReadLiveProperties(lLiveProperties);
    WriteLn('read_properties_code=', Ord(lResult.Code));
    WriteLn('read_properties_stage=', lResult.Stage);
    WriteLn('read_properties_text=', lResult.MessageText);
    WriteLn('live_properties_begin');
    WriteLn(lLiveProperties);
    WriteLn('live_properties_end');
    if not lResult.IsSuccess then begin lExitCode := 7; Exit; end;
    if (ParamCount = 2) and SameText(ParamStr(2), '--maintenance') then
    begin
      PxiMx248DefaultConfiguration(lConfiguration);
      for I := 0 to High(lConfiguration.Channels) do
        lConfiguration.Channels[I].RangeIndex := 2;
      lResult := lTransport.SetModuleProperties(lConfiguration);
      if lResult.IsSuccess then
        lResult := lTransport.ProgramAcquisition(lConfiguration);
      WriteLn('configure_code=', Ord(lResult.Code));
      WriteLn('configure_stage=', lResult.Stage);
      WriteLn('configure_text=', lResult.MessageText);
      if not lResult.IsSuccess then begin lExitCode := 8; Exit; end;
      lResult := lTransport.ConfigurePxi(0, 0, 0, 0, 0, 0);
      WriteLn('configure_pxi_code=', Ord(lResult.Code));
      WriteLn('configure_pxi_stage=', lResult.Stage);
      WriteLn('configure_pxi_text=', lResult.MessageText);
      if not lResult.IsSuccess then begin lExitCode := 9; Exit; end;
      lResult := lTransport.ZeroBalance(1, lZeroValues);
      WriteLn('zero_balance_code=', Ord(lResult.Code));
      WriteLn('zero_balance_stage=', lResult.Stage);
      WriteLn('zero_balance_text=', lResult.MessageText);
      WriteLn('zero_balance_values=', lZeroValues);
      if not lResult.IsSuccess then begin lExitCode := 10; Exit; end;
    end
    else if (ParamCount >= 2) and SameText(ParamStr(2), '--acquire') then
    begin
      PxiMx248DefaultConfiguration(lConfiguration);
      lResult := lTransport.ProgramAcquisition(lConfiguration);
      WriteLn('configure_code=', Ord(lResult.Code));
      WriteLn('configure_stage=', lResult.Stage);
      WriteLn('configure_text=', lResult.MessageText);
      if not lResult.IsSuccess then begin lExitCode := 11; Exit; end;
      { The original Recorder makes the standalone board the PXI trigger master
        before acquisition.  An unconfigured MX-248 reports Slave and may start
        successfully without ever advancing its acquisition FIFO. }
      lResult := lTransport.ConfigurePxi(0, 0, 1, 2, 0, 0);
      WriteLn('configure_pxi_code=', Ord(lResult.Code));
      WriteLn('configure_pxi_stage=', lResult.Stage);
      WriteLn('configure_pxi_text=', lResult.MessageText);
      if not lResult.IsSuccess then begin lExitCode := 17; Exit; end;
      lResult := lTransport.ReadLiveProperties(lLiveProperties);
      WriteLn('configured_properties_code=', Ord(lResult.Code));
      WriteLn('configured_properties_begin');
      WriteLn(lLiveProperties);
      WriteLn('configured_properties_end');
      if not lResult.IsSuccess then begin lExitCode := 18; Exit; end;
      PreparePxiMx248Block(lBlock, CPxiMx248ChannelCount,
        lConfiguration.BlockSamples);
      lResult := lTransport.Start;
      WriteLn('start_code=', Ord(lResult.Code));
      WriteLn('start_stage=', lResult.Stage);
      WriteLn('start_text=', lResult.MessageText);
      if not lResult.IsSuccess then lExitCode := 12;
      try
        ReadAndReportBlocks(False, lBlockCount);
        lElapsedMs := GetTickCount64 - lStartedAt;
        WriteLn('zero_value_count=', lZeroTotal);
        WriteLn('nonfinite_value_count=', lNonFiniteTotal);
        WriteLn('changing_block_count=', lChangingBlocks);
        WriteLn('total_samples=', lTotalSamples);
        WriteLn('elapsed_ms=', lElapsedMs);
      finally
        lResult := lTransport.Stop;
        WriteLn('stop_code=', Ord(lResult.Code));
        WriteLn('stop_stage=', lResult.Stage);
        WriteLn('stop_text=', lResult.MessageText);
      end;
      if not lResult.IsSuccess and (lExitCode = 0) then lExitCode := 14;
    end;
  finally
    lTransport.Disconnect;
    lTransport.Free;
  end;
end;

begin
  lExitCode := 0;
  Run;
  if lExitCode <> 0 then Halt(lExitCode);
end.
