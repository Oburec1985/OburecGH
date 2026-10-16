program OscillogramRuntimeSmoke;
{$mode objfpc}{$H+}{$codepage UTF8}
uses Interfaces, Forms, Controls, ExtCtrls, Classes, SysUtils, IniFiles, Math, FileUtil, Graphics,
  fpjson, jsonparser, IntfGraphics, FPImage,
  {$IFDEF MSWINDOWS} Windows, {$ENDIF}
  uRecorderFormModel, uRecorderTags, uRecorderPluginRuntime,
  uRecorderVisualControl, uRecorderProjectFiles, uRecorderPluginApi,
  uRecorderVisualComponentApiV2, uFormEditorController;

type
  TSmokePageProvider = class
    Page: TRecorderFormPage;
    function GetPage: TRecorderFormPage;
  end;
function TSmokePageProvider.GetPage: TRecorderFormPage;
begin Result := Page; end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;

{$IFDEF MSWINDOWS}
procedure CheckDescriptorPrefixes(const APluginPath: string);
var lGet: TRecorderVisualGetDescriptorV2; lModule: HMODULE;
  lGuard: record Descriptor:TRecorderVisualComponentDescriptorV2;
    Tail:array[0..15] of Byte; end;
  lSizes: array[0..3] of SizeUInt; I,J:Integer; lBytes:PByte;
begin
  lModule := GetModuleHandle(PChar(ExtractFileName(APluginPath)));
  Pointer(lGet) := GetProcAddress(lModule,'RecorderVisualGetDescriptorV2');
  Check(Assigned(lGet),'production discovery export unavailable');
  lSizes[0] := PtrUInt(@lGuard.Descriptor.Edit)-PtrUInt(@lGuard.Descriptor);
  lSizes[1] := PtrUInt(@lGuard.Descriptor.ImportState)-PtrUInt(@lGuard.Descriptor);
  lSizes[2] := PtrUInt(@lGuard.Descriptor.EnumerateAliases)-PtrUInt(@lGuard.Descriptor);
  lSizes[3] := SizeOf(lGuard.Descriptor);
  lBytes := @lGuard;
  for I := 0 to High(lSizes) do
  begin
    FillChar(lGuard,SizeOf(lGuard),$A5);
    Check(lGet(0,@lGuard.Descriptor,lSizes[I])=REC_VISUAL_OK,'old-host prefix rejected');
    Check(lGuard.Descriptor.Header.Size=lSizes[I],'descriptor prefix Size mismatch');
    Check(Assigned(lGuard.Descriptor.CreateInstance) and
      Assigned(lGuard.Descriptor.LoadState),'required callbacks missing in prefix');
    for J := lSizes[I] to SizeOf(lGuard)-1 do
      Check(lBytes[J]=$A5,'descriptor export wrote beyond caller capacity');
  end;
  FillChar(lGuard,SizeOf(lGuard),$A5);
  Check(lGet(0,@lGuard.Descriptor,1)=REC_VISUAL_ERROR,'truncated prefix accepted');
  for J := 0 to SizeOf(lGuard)-1 do Check(lBytes[J]=$A5,'rejected export changed memory');
  WriteLn('RESULT Production descriptor old-prefix/capacity canaries passed');
end;

function wglGetCurrentContext: PtrUInt; stdcall; external 'opengl32.dll';
function wglGetCurrentDC: HDC; stdcall; external 'opengl32.dll';
function wglMakeCurrent(ADC:HDC; AContext:PtrUInt): BOOL; stdcall; external 'opengl32.dll';
procedure glReadBuffer(AMode:LongWord); stdcall; external 'opengl32.dll';
procedure glReadPixels(AX,AY,AWidth,AHeight:LongInt; AFormat,AType:LongWord;
  AData:Pointer); stdcall; external 'opengl32.dll';
function glGetError:LongWord; stdcall; external 'opengl32.dll';
procedure glGetIntegerv(AName:LongWord; AValue:Pointer); stdcall; external 'opengl32.dll';
var g_ChartWindow: HWND; g_ChartArea: Integer;
function FindChartWindow(AWindow: HWND; AData: LPARAM): BOOL; stdcall;
var lRect: TRect; lArea: Integer;
  lDC:HDC; lPixelFormat:Integer;
begin
  Result := True;
  GetClientRect(AWindow,lRect);
  lDC:=GetDC(AWindow);
  lPixelFormat:=GetPixelFormat(lDC);
  ReleaseDC(AWindow,lDC);
  if (GetWindow(AWindow, GW_CHILD) <> 0) or (lPixelFormat=0) then Exit;
  GetClientRect(AWindow, lRect);
  lArea := lRect.Right * lRect.Bottom;
  if (lRect.Right > 200) and (lRect.Bottom > 100) and (lArea > g_ChartArea) then
  begin g_ChartArea := lArea; g_ChartWindow := AWindow; end;
end;

procedure CheckWaveformPixels(ARoot: HWND; AExpectWaveform:Boolean = True);
var lRect: TRect; X,Y,lBlue,lIndex,lReadBuffer,lMinY,lMaxY: Integer;
  lBitmap: Graphics.TBitmap; lImage:TLazIntfImage; lColor:TFPColor;
  lPixels:array of Byte;
begin
  g_ChartWindow := 0; g_ChartArea := 0;
  EnumChildWindows(ARoot, @FindChartWindow, 0);
  Check(g_ChartWindow <> 0, 'plugin has no native chart surface');
  UpdateWindow(g_ChartWindow);
  GetClientRect(g_ChartWindow,lRect);
  { WGL front buffer is the real displayed native surface. GDI BitBlt/GetPixel
    returns black for this accelerated surface, so it cannot prove rendering.
    Do not borrow a context for another window or inspect plugin Pascal types. }
  Check((wglGetCurrentContext()<>0) and
    (WindowFromDC(wglGetCurrentDC())=g_ChartWindow),'chart context is not current');
  Check(glGetError()=0,'chart left an OpenGL error before capture');
  SetLength(lPixels,lRect.Right*lRect.Bottom*4);
  glGetIntegerv($0C02,@lReadBuffer); { GL_READ_BUFFER }
  try
    glReadBuffer($0404); { GL_FRONT }
    glReadPixels(0,0,lRect.Right,lRect.Bottom,$1908,$1401,@lPixels[0]);
    Check(glGetError()=0,'native framebuffer capture failed');
  finally glReadBuffer(lReadBuffer); end;
  lBitmap := Graphics.TBitmap.Create;
  lImage:=TLazIntfImage.Create(0,0);
  try
    lBitmap.SetSize(lRect.Right,lRect.Bottom);
    lImage.LoadFromBitmap(lBitmap.Handle,lBitmap.MaskHandle);
    for Y:=0 to lRect.Bottom-1 do
      for X:=0 to lRect.Right-1 do
      begin
        lIndex:=((lRect.Bottom-1-Y)*lRect.Right+X)*4;
        lColor.Red:=lPixels[lIndex]*257; lColor.Green:=lPixels[lIndex+1]*257;
        lColor.Blue:=lPixels[lIndex+2]*257; lColor.Alpha:=65535;
        lImage.Colors[X,Y]:=lColor;
      end;
    lBitmap.LoadFromIntfImage(lImage);
    if AExpectWaveform then
      lBitmap.SaveToFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'osc-waveform.bmp')
    else
      lBitmap.SaveToFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'osc-cleared.bmp');
  finally lImage.Free; lBitmap.Free; end;
  lBlue:=0; lMinY:=lRect.Bottom; lMaxY:=0;
  for Y:=lRect.Bottom div 5 to lRect.Bottom*4 div 5 do
    for X:=lRect.Right div 5 to lRect.Right*4 div 5 do
      begin
        lIndex:=(Y*lRect.Right+X)*4;
        if (lPixels[lIndex+2]>180) and (lPixels[lIndex]<80) and
          (lPixels[lIndex+1]<80) then
        begin Inc(lBlue); lMinY:=Min(lMinY,Y); lMaxY:=Max(lMaxY,Y); end;
      end;
  WriteLn('Oscillogram waveform blue pixels: ',lBlue);
  if AExpectWaveform then
  begin
    Check(lBlue > 20, 'plugin did not render the supplied waveform');
    Check(lMaxY-lMinY>lRect.Bottom div 5,'waveform has no expected amplitude span');
  end
  else Check(lBlue=0,'cleared input left stale waveform pixels');
end;
{$ENDIF}

function ComponentJson(AComponent:TRecorderPluginVisualComponent;
  AFactory:TRecorderComponentFactoryBase):UTF8String;
var lData:TRecorderPluginConfigBytes;
begin
  Check(AFactory.SaveOpaqueComponentState(AComponent)=rosSuccess,'project state save');
  lData:=AComponent.ConfigBlob;
  Check(Length(lData)>0,'empty project state');
  SetString(Result,PAnsiChar(@lData[0]),Length(lData));
end;

procedure ExpectProjectLoadError(const AFile:string; AForms:TRecorderFormManager;
  AFactories:TRecorderComponentFactory);
var lRejected:Boolean;
begin
  lRejected:=False;
  try LoadRecorderGuiConfig(AFile,AForms,AFactories);
  except on E:ERecorderFormError do lRejected:=True; end;
  Check(lRejected,'invalid hex envelope was not rejected');
end;

procedure CheckEnvelopeSafety(const AFile:string; ASource:TRecorderFormManager;
  AFactories:TRecorderComponentFactory);
const Section='Page.0.Component.0';
var lIni:TIniFile; lForms,lReload:TRecorderFormManager;
  lComponent:TRecorderPluginVisualComponent;
  lRaw,lAgain:TRecorderPluginConfigBytes;
begin
  lForms:=TRecorderFormManager.Create; lReload:=TRecorderFormManager.Create;
  try
    lIni:=TIniFile.Create(AFile);
    try lIni.WriteString(Section,'PluginStateData','not-hex'); lIni.UpdateFile;
    finally lIni.Free; end;
    ExpectProjectLoadError(AFile,lForms,AFactories);
    SaveRecorderGuiConfig(AFile,ASource);
    lIni:=TIniFile.Create(AFile);
    try lIni.DeleteKey(Section,'PluginStateData'); lIni.UpdateFile;
    finally lIni.Free; end;
    ExpectProjectLoadError(AFile,lForms,AFactories);
    SaveRecorderGuiConfig(AFile,ASource);
    lIni:=TIniFile.Create(AFile);
    try
      lIni.WriteString(Section,'PluginStateEncoding','hex-v2');
      lIni.WriteString(Section,'PluginStateData','future-native-payload');
      lIni.UpdateFile;
    finally lIni.Free; end;
    LoadRecorderGuiConfig(AFile,lForms,AFactories);
    lComponent:=TRecorderPluginVisualComponent(lForms.Pages[0].Components[0]);
    Check(lComponent.Factory=nil,'unknown envelope attached production factory');
    Check(lComponent.ConfigSchemaId='recorder.unknown-envelope-v1','unknown envelope marker');
    lRaw:=lComponent.ConfigBlob;
    SaveRecorderGuiConfig(AFile,lForms);
    LoadRecorderGuiConfig(AFile,lReload,AFactories);
    lComponent:=TRecorderPluginVisualComponent(lReload.Pages[0].Components[0]);
    Check(lComponent.Factory=nil,'unknown envelope reloaded into factory');
    lAgain:=lComponent.ConfigBlob;
    Check((Length(lRaw)>0) and (Length(lRaw)=Length(lAgain)) and
      (CompareByte(lRaw[0],lAgain[0],Length(lRaw))=0),'unknown envelope lost raw bytes');
    WriteLn('RESULT Oscillogram malformed/missing/unknown envelope safety passed');
  finally lForms.Free; lReload.Free; end;
end;

procedure CheckProjectMigration(AFactories:TRecorderComponentFactory; ATag:TRecorderTag);
const Section='Page.0.Component.0'; AOriginalType='sample.oscillogram';
var lLegacy,lPlaceholder,lNative:string; lIni:TIniFile;
  lEmptyFactories:TRecorderComponentFactory; lForms,lReload:TRecorderFormManager;
  lComponent:TRecorderPluginVisualComponent; lRaw,lRawReload:TRecorderPluginConfigBytes;
  lBefore,lAfter,lInvalid:UTF8String; lJson:TJSONData; lRoot,lItem:TJSONObject;
  lFactory:TRecorderComponentFactoryBase;
begin
  lLegacy:=ExtractFilePath(ParamStr(0))+'legacy-osc.ini';
  lPlaceholder:=ExtractFilePath(ParamStr(0))+'placeholder-osc.ini';
  lNative:=ExtractFilePath(ParamStr(0))+'native-osc.ini';
  SysUtils.DeleteFile(lLegacy); SysUtils.DeleteFile(lPlaceholder); SysUtils.DeleteFile(lNative);
  lIni:=TIniFile.Create(lLegacy);
  try
    lIni.WriteInteger('Project','PageCount',1);
    lIni.WriteString('Page.0','Id','legacy');
    lIni.WriteString('Page.0','Name','Legacy');
    lIni.WriteInteger('Page.0','ComponentCount',1);
    lIni.WriteString(Section,'Type',AOriginalType);
    lIni.WriteString(Section,'Id','osc1');
    lIni.WriteString(Section,'TagName',ATag.Name);
    lIni.WriteInt64(Section,'TagId',ATag.Id);
    lIni.WriteString(Section,'DisplayFormat','6');
    lIni.WriteInteger(Section,'BindingMode',1);
    lIni.WriteInteger(Section,'TagOffset',3);
    lIni.WriteFloat(Section,'OscXScale',0.75);
    lIni.WriteFloat(Section,'OscYScale',7.5);
    lIni.WriteFloat(Section,'OscYOffset',-12.25);
    lIni.WriteBool(Section,'OscClosedInput',True);
    lIni.WriteBool(Section,'OscAutoRangeEnabled',True);
    lIni.WriteBool(Section,'OscLegendVisible',False);
    lIni.WriteBool(Section,'OscLevelCursorVisible',True);
    lIni.WriteInteger(Section,'OscAxisCount',2);
    lIni.WriteInteger(Section,'OscPrimaryAxisIndex',1);
    lIni.WriteString(Section,'OscAxis1Name','Вторая ось');
    lIni.WriteFloat(Section,'OscAxis1YScale',2.5);
    lIni.WriteFloat(Section,'OscAxis1YOffset',-3.25);
    lIni.WriteInteger(Section,'OscLineCount',2);
    lIni.WriteString(Section,'OscLine0TagName',ATag.Name);
    lIni.WriteInt64(Section,'OscLine0TagId',ATag.Id);
    lIni.WriteInteger(Section,'OscLine0AxisIndex',1);
    lIni.WriteInteger(Section,'OscLine0Color',255);
    lIni.WriteString(Section,'OscLine1TagName','Другой канал');
    lIni.WriteInt64(Section,'OscLine1TagId',9876543210);
    lIni.WriteInteger(Section,'OscLine1AxisIndex',0);
    lIni.WriteBool(Section,'OscLine1Visible',False);
    lIni.WriteBool(Section,'OscXCursorEnabled',True);
    lIni.WriteInteger(Section,'OscXCursorCount',2);
    lIni.WriteBool(Section,'OscTriggerEnabled',True);
    lIni.WriteString(Section,'OscTriggerTag',ATag.Name);
    lIni.WriteInteger(Section,'OscTriggerEdge',1);
    lIni.WriteFloat(Section,'OscTriggerLevel',1.25);
    lIni.WriteFloat(Section,'OscTriggerPreRollPercent',37.5);
    lIni.UpdateFile;
  finally lIni.Free; end;
  lEmptyFactories:=TRecorderComponentFactory.Create;
  lForms:=TRecorderFormManager.Create; lReload:=TRecorderFormManager.Create;
  try
    LoadRecorderGuiConfig(lLegacy,lForms,lEmptyFactories);
    Check((lForms.PageCount=1) and (lForms.Pages[0].ComponentCount=1),'placeholder retained');
    Check(lForms.Pages[0].Components[0] is TRecorderPluginVisualComponent,
      'missing DLL did not produce generic raw placeholder');
    lComponent:=TRecorderPluginVisualComponent(lForms.Pages[0].Components[0]);
    Check((lComponent.Factory=nil) and (lComponent.PluginTypeId=AOriginalType),
      'missing DLL placeholder lost original alias/type');
    lRaw:=lComponent.ConfigBlob;
    Check(lComponent.ConfigSchemaId='recorder.ini.section-v1','raw schema marker');
    SetString(lBefore,PAnsiChar(@lRaw[0]),Length(lRaw));
    lJson:=GetJSON(lBefore);
    try
      lRoot:=TJSONObject(lJson);
      Check(lRoot.Get('Type','')=AOriginalType,'raw original type missing');
      Check(lRoot.Get('TagId','')=IntToStr(ATag.Id),'raw TagId missing');
      Check(lRoot.Get('OscAxis1Name','')='Вторая ось','raw Unicode axis changed');
    finally lJson.Free; end;
    SaveRecorderGuiConfig(lPlaceholder,lForms);
    LoadRecorderGuiConfig(lPlaceholder,lReload,lEmptyFactories);
    lRawReload:=TRecorderPluginVisualComponent(lReload.Pages[0].Components[0]).ConfigBlob;
    Check((Length(lRaw)=Length(lRawReload)) and
      (CompareByte(lRaw[0],lRawReload[0],Length(lRaw))=0),'placeholder raw bytes changed');
    try LoadRecorderGuiConfig(lPlaceholder,lForms,AFactories);
    except WriteLn('Failed legacy raw payload: ',lBefore); raise; end;
    lComponent:=TRecorderPluginVisualComponent(lForms.Pages[0].Components[0]);
    Check(lComponent.PluginTypeId='sample.oscillogram','alias import did not canonicalize type');
    Check(lComponent.Factory=AFactories.FindFactory('sample.oscillogram'),
      'alias import did not attach canonical factory');
    lBefore:=ComponentJson(lComponent,AFactories.FindFactory('sample.oscillogram'));
    lJson:=GetJSON(lBefore);
    try
      lRoot:=TJSONObject(lJson);
      Check((lRoot.Get('TagId',Int64(0))=ATag.Id) and (lRoot.Get('TagName','')=ATag.Name),'import binding');
      Check((lRoot.Get('BindingMode',-1)=1) and (lRoot.Get('TagOffset',-1)=3)
        and (lRoot.Get('DisplayFormat','')='6'),'import primary binding/offset/format');
      Check((lRoot.Get('XCursorCount',0)=2) and lRoot.Get('XCursorEnabled',False),'import double cursor');
      Check(lRoot.Get('TriggerEnabled',False) and (lRoot.Get('TriggerEdge',0)=1) and
        (Abs(lRoot.Get('TriggerLevel',0.0)-1.25)<1E-9),'import falling trigger');
      Check(Abs(lRoot.Get('TriggerPreRollPercent',0.0)-37.5)<1E-9,'import pre-roll');
      Check((TJSONArray(lRoot.Find('Axes')).Count=2) and
        (lRoot.Get('PrimaryAxisIndex',0)=1),'import axes');
      lItem:=TJSONObject(TJSONArray(lRoot.Find('Axes')).Items[1]);
      Check((lItem.Get('Name','')='Вторая ось') and
        (Abs(lItem.Get('YOffset',0.0)+3.25)<1E-9),'import axis settings');
      Check(TJSONArray(lRoot.Find('Lines')).Count=2,'import extra lines');
      lItem:=TJSONObject(TJSONArray(lRoot.Find('Lines')).Items[0]);
      Check((lItem.Get('TagId',Int64(0))=ATag.Id) and
        (lItem.Get('TagName','')=ATag.Name) and lItem.Get('Visible',False) and
        (lItem.Get('Color',0)=255),'import first line mapping');
      Check(lItem.Get('AxisIndex',-1)=1,'canonical line axis lost');
      lItem:=TJSONObject(TJSONArray(lRoot.Find('Lines')).Items[1]);
      Check((lItem.Get('TagId',Int64(0))=9876543210) and
        (lItem.Get('TagName','')='Другой канал') and
        (lItem.Get('AxisIndex',-1)=0) and
        not lItem.Get('Visible',True),'import line settings UTF8');
    finally lJson.Free; end;
    SaveRecorderGuiConfig(lNative,lForms);
    lIni:=TIniFile.Create(lNative);
    try Check(lIni.ReadString(Section,'Type','')='sample.oscillogram',
      'native save wrote legacy alias rather than canonical type');
    finally lIni.Free; end;
    LoadRecorderGuiConfig(lNative,lReload,AFactories);
    Check(TRecorderPluginVisualComponent(lReload.Pages[0].Components[0]).PluginTypeId=
      'sample.oscillogram','native reload did not retain canonical type');
    lAfter:=ComponentJson(TRecorderPluginVisualComponent(lReload.Pages[0].Components[0]),
      AFactories.FindFactory('sample.oscillogram'));
    Check(lBefore=lAfter,'native project reload changed full plugin JSON');
    WriteLn('RESULT Oscillogram project ',AOriginalType,' legacy/placeholder/native roundtrip passed');
    CheckEnvelopeSafety(lNative,lForms,AFactories);
    lFactory:=AFactories.FindFactory('sample.oscillogram');
    lComponent:=TRecorderPluginVisualComponent(lForms.Pages[0].Components[0]);
    SetString(lInvalid,PAnsiChar(@lRaw[0]),Length(lRaw));
    lJson:=GetJSON(lInvalid);
    try
      TJSONObject(lJson).Strings['OscTriggerLevel']:='NaN';
      lInvalid:=lJson.AsJSON;
    finally lJson.Free; end;
    SetLength(lRawReload,Length(lInvalid));
    Move(lInvalid[1],lRawReload[0],Length(lRawReload));
    lComponent.ConfigBlob:=lRawReload;
    lComponent.ConfigSchemaId:='recorder.ini.section-v1';
    Check(lFactory.LoadOpaqueComponentState(lComponent)=rosFailure,'invalid legacy fields accepted');
    lRaw:=lComponent.ConfigBlob;
    Check((Length(lRaw)=Length(lRawReload)) and
      (CompareByte(lRaw[0],lRawReload[0],Length(lRaw))=0),'rejected import lost original bytes');
    lAfter:=ComponentJson(lComponent,lFactory);
    Check(lAfter=lBefore,'rejected import changed native prior state');
    WriteLn('RESULT Oscillogram invalid legacy import rollback passed');
  finally
    lForms.Free; lReload.Free; lEmptyFactories.Free;
    SysUtils.DeleteFile(lLegacy); SysUtils.DeleteFile(lPlaceholder); SysUtils.DeleteFile(lNative);
  end;
end;

function ReadFileBytes(const APath: string): TBytes;
var lStream: TFileStream;
begin
  Result := nil;
  lStream := TFileStream.Create(APath, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result,lStream.Size);
    if Length(Result)>0 then lStream.ReadBuffer(Result[0],Length(Result));
  finally lStream.Free; end;
end;

{$IFDEF MSWINDOWS}
function WaveFootprint(ARoot:HWND; ADC:HDC; AContext:PtrUInt):QWord;
var lRect:TRect; lPixels:array of Byte; X,Y,lIndex,lBlue,lReadBuffer:Integer;
begin
  g_ChartWindow:=0; g_ChartArea:=0;
  EnumChildWindows(ARoot,@FindChartWindow,0);
  Check(g_ChartWindow<>0,'Context smoke chart absent');
  Check(WindowFromDC(ADC)=g_ChartWindow,'Context smoke DC belongs to another view');
  Check(wglMakeCurrent(ADC,AContext),'Cannot select captured view context');
  GetClientRect(g_ChartWindow,lRect);
  SetLength(lPixels,lRect.Right*lRect.Bottom*4);
  glGetIntegerv($0C02,@lReadBuffer);
  try
    glReadBuffer($0404);
    glReadPixels(0,0,lRect.Right,lRect.Bottom,$1908,$1401,@lPixels[0]);
    Check(glGetError()=0,'Context smoke framebuffer read failed');
  finally glReadBuffer(lReadBuffer); end;
  Result:=0; lBlue:=0;
  for Y:=lRect.Bottom div 5 to lRect.Bottom*4 div 5 do
    for X:=lRect.Right div 5 to lRect.Right*4 div 5 do
    begin
      lIndex:=(Y*lRect.Right+X)*4;
      if (lPixels[lIndex+2]>180) and (lPixels[lIndex]<80) and (lPixels[lIndex+1]<80) then
      begin
        Inc(lBlue);
        Result:=Result xor (QWord(X+1)*73856093 xor QWord(Y+1)*19349663);
      end;
    end;
  Check(lBlue>20,'Context smoke has no visible signal');
end;

procedure CheckIndependentViewWindows(AComponent:TRecorderPluginVisualComponent;
  AFactories:TRecorderComponentFactory);
var lSessions:array[0..1] of TRecorderPluginViewSession;
  lPanels:array[0..1] of TPanel; lRoots:array[0..1] of HWND;
  lDCs:array[0..1] of HDC; lContexts:array[0..1] of PtrUInt;
  lOriginal,lChanged:array[0..1] of QWord;
  lWindow:TForm; lSurface:TRecorderVisualSurfaceV2; I:Integer;
  lBefore,lAfter:UTF8String; lSavedDC:HDC; lSavedContext:PtrUInt;
begin
  lBefore:=ComponentJson(AComponent,AComponent.Factory);
  lSessions[0]:=nil; lSessions[1]:=nil;
  lSavedDC:=wglGetCurrentDC; lSavedContext:=wglGetCurrentContext;
  lWindow:=TForm.CreateNew(nil);
  try
    lWindow.SetBounds(0,0,1540,540); lWindow.Show;
    for I:=0 to 1 do
    begin
      lPanels[I]:=TPanel.Create(lWindow); lPanels[I].Parent:=lWindow;
      lPanels[I].SetBounds(I*760,0,760,500);
      lSessions[I]:=RecorderPluginVisualOpenView(AComponent);
      Check(lSessions[I]<>nil,'Production direct session missing');
      Check(lSessions[I].SetDisplayWindow(1)=REC_VISUAL_NOT_HANDLED,'Detached context unexpectedly accepted');
      lSurface:=Default(TRecorderVisualSurfaceV2);
      lSurface.Header.Size:=SizeOf(lSurface);
      lSurface.Header.AbiMajor:=REC_VISUAL_ABI_V2_MAJOR;
      lSurface.Header.AbiMinor:=REC_VISUAL_ABI_V2_MINOR;
      lSurface.NativeBackend:=REC_VISUAL_NATIVE_WIN32;
      lSurface.Dpi:=96; lSurface.ParentWindow:=lPanels[I].Handle;
      lSurface.Width:=lPanels[I].ClientWidth; lSurface.Height:=lPanels[I].ClientHeight;
      lSurface.Flags:=REC_VISUAL_VIEW_INTERACTIVE;
      Check(lSessions[I].Attach(lSurface)=REC_VISUAL_OK,'Production direct attach failed');
      Application.ProcessMessages;
      Check(lSessions[I].SetDisplayWindow(1)=REC_VISUAL_OK,'Positive production view context rejected');
      AFactories.DoUpdateData; { Original nil DATA_UPDATED payload stays valid. }
      Application.ProcessMessages;
      lRoots[I]:=FindWindowEx(lPanels[I].Handle,0,nil,'Oscillogram plugin view');
      Check(lRoots[I]<>0,'Production direct root absent');
      { A global DATA_UPDATED paints every view; the last current WGL context
        can belong to a sibling. Paint this owned chart before capturing it. }
      g_ChartWindow:=0; g_ChartArea:=0;
      EnumChildWindows(lRoots[I],@FindChartWindow,0);
      Check(g_ChartWindow<>0,'Direct chart window absent');
      RedrawWindow(g_ChartWindow,nil,0,RDW_INVALIDATE or RDW_UPDATENOW);
      lDCs[I]:=wglGetCurrentDC; lContexts[I]:=wglGetCurrentContext;
      lOriginal[I]:=WaveFootprint(lRoots[I],lDCs[I],lContexts[I]);
    end;
    Check(lSessions[0].SetDisplayWindow(-1)=REC_VISUAL_ERROR,'Negative display window accepted');
    Check(lSessions[0].SetDisplayWindow(0)=REC_VISUAL_ERROR,'Zero display window accepted');
    Check(lSessions[0].SetDisplayWindow(NaN)=REC_VISUAL_ERROR,'NaN display window accepted');
    Check(lSessions[0].SetDisplayWindow(Infinity)=REC_VISUAL_ERROR,'Infinite display window accepted');
    Check(lSessions[0].SetDisplayWindow(0.25)=REC_VISUAL_OK,'Changed window rejected');
    Application.ProcessMessages;
    lChanged[0]:=WaveFootprint(lRoots[0],lDCs[0],lContexts[0]);
    lChanged[1]:=WaveFootprint(lRoots[1],lDCs[1],lContexts[1]);
    Check(lChanged[0]<>lOriginal[0],'Cold window change without new data did not redraw waveform');
    Check(lChanged[1]=lOriginal[1],'One view context changed sibling waveform');
    Check(lSessions[0].SetDisplayWindow(0.5)=REC_VISUAL_OK,'Second cold window change rejected');
    Application.ProcessMessages;
    Check(WaveFootprint(lRoots[0],lDCs[0],lContexts[0])<>lChanged[0],
      'Second no-new-data window change did not redraw');
    Check(WaveFootprint(lRoots[1],lDCs[1],lContexts[1])=lOriginal[1],
      'Second context change reset sibling');
    lAfter:=ComponentJson(AComponent,AComponent.Factory);
    Check(lAfter=lBefore,'Per-view context reset binding/cursor/model state');
    WriteLn('RESULT Oscillograph per-view window positive/invalid/no-new-data/independence passed');
  finally
    for I:=0 to 1 do lSessions[I].Free;
    lWindow.Free;
    wglMakeCurrent(lSavedDC,lSavedContext);
  end;
end;
{$ENDIF}

procedure CheckBuiltinSimpleProject(AFactories: TRecorderComponentFactory; ATag: TRecorderTag);
const Section = 'Page.0.Component.0';
var lFile: string; lIni: TIniFile; lForms,lReload: TRecorderFormManager;
  lOsc: TRecorderOscillogramComponent;
begin
  lFile := ExtractFilePath(ParamStr(0))+'builtin-simple-osc.ini';
  lIni := TIniFile.Create(lFile);
  try
    lIni.WriteInteger('Project','PageCount',1);
    lIni.WriteString('Page.0','Id','simple');
    lIni.WriteInteger('Page.0','ComponentCount',1);
    lIni.WriteString(Section,'Type','Oscillogram');
    lIni.WriteString(Section,'Id','simple1');
    lIni.WriteString(Section,'Name','Simple');
    lIni.WriteString(Section,'TagName',ATag.Name);
    lIni.WriteInt64(Section,'TagId',ATag.Id);
    lIni.WriteString(Section,'DisplayFormat','0.000');
    lIni.WriteInteger(Section,'BindingMode',1);
    lIni.WriteInteger(Section,'TagOffset',3);
    lIni.WriteInteger(Section,'OscLineCount',1);
    lIni.WriteString(Section,'OscLine0TagName','Second');
    lIni.WriteInt64(Section,'OscLine0TagId',9876543210);
    lIni.WriteInteger(Section,'OscLine0Color',255);
    lIni.WriteBool(Section,'OscLine0Visible',False);
    { Erroneously persisted advanced keys must not turn the built-in simple
      component into the separate plugin Oscillograph. }
    lIni.WriteBool(Section,'OscClosedInput',True);
    lIni.WriteInteger(Section,'OscAxisCount',3);
    lIni.WriteFloat(Section,'OscXScale',2.5);
    lIni.WriteBool(Section,'OscTriggerEnabled',True);
    lIni.UpdateFile;
  finally lIni.Free; end;
  lForms := TRecorderFormManager.Create; lReload := TRecorderFormManager.Create;
  try
    LoadRecorderGuiConfig(lFile,lForms,AFactories);
    Check(lForms.Pages[0].Components[0] is TRecorderOscillogramComponent,
      'Builtin Oscillogram must not migrate into plugin');
    lOsc := TRecorderOscillogramComponent(lForms.Pages[0].Components[0]);
    Check((lOsc.TagId=ATag.Id) and (lOsc.TagName=ATag.Name) and
      (lOsc.DisplayFormat='0.000') and (Ord(lOsc.BindingMode)=1) and
      (lOsc.TagOffset=3),'Simple primary binding/format lost');
    Check((lOsc.LineCount=1) and (lOsc.Lines[0].TagId=9876543210) and
      (lOsc.Lines[0].TagName='Second') and (lOsc.Lines[0].Color=255) and
      not lOsc.Lines[0].Visible,'Simple extra line settings lost');
    Check(not lOsc.ClosedInput and not lOsc.TriggerEnabled and
      (lOsc.AxisCount=1) and (lOsc.XScale=0),'Simple component consumed plugin settings');
    SaveRecorderGuiConfig(lFile,lForms);
    lIni := TIniFile.Create(lFile);
    try
      Check(lIni.ReadString(Section,'Type','')='Oscillogram','Simple type must remain builtin');
      Check(not lIni.ValueExists(Section,'PluginStateData'),'Simple state must not become opaque plugin state');
      Check(not lIni.ValueExists(Section,'OscTriggerEnabled') and
        not lIni.ValueExists(Section,'OscAxisCount'),'Simple save leaked plugin settings');
    finally lIni.Free; end;
    LoadRecorderGuiConfig(lFile,lReload,AFactories);
    Check(lReload.Pages[0].Components[0] is TRecorderOscillogramComponent,'Simple reload type changed');
    lOsc := TRecorderOscillogramComponent(lReload.Pages[0].Components[0]);
    Check((lOsc.TagId=ATag.Id) and (lOsc.TagOffset=3) and
      (lOsc.LineCount=1) and (lOsc.Lines[0].TagId=9876543210) and
      not lOsc.Lines[0].Visible,'Simple native roundtrip lost settings');
    WriteLn('RESULT Builtin simple Oscillogram distinct load/save/defaults passed');
  finally lForms.Free; lReload.Free; SysUtils.DeleteFile(lFile); end;
end;

procedure CheckRealGuiPages(const APath: string; AFactories: TRecorderComponentFactory;
  ATags: TRecorderTagRegistry);
var
  lForms: TRecorderFormManager; lProvider: TSmokePageProvider;
  lWindow: TForm; lCanvas: TPanel; lEditor: TFormEditorController;
  lBefore,lAfter: TBytes; I,J,lMissing,lPlugins: Integer;
begin
  Check(FileExists(APath),'Real GUI config does not exist: '+APath);
  lBefore := ReadFileBytes(APath);
  lForms := TRecorderFormManager.Create;
  lProvider := TSmokePageProvider.Create;
  lWindow := nil; lEditor := nil;
  try
    { Only GUI configuration is loaded. No recorder/device configuration,
      Start, plugin editor actions, or writes to the user's project occur. }
    LoadRecorderGuiConfig(APath,lForms,AFactories);
    Check(lForms.PageCount>0,'Real GUI project has no pages');
    for I:=0 to lForms.PageCount-1 do
    begin
      lProvider.Page := lForms.Pages[I];
      lMissing := 0; lPlugins := 0;
      for J:=0 to lProvider.Page.ComponentCount-1 do
        if lProvider.Page.Components[J] is TRecorderPluginVisualComponent then
          if lProvider.Page.Components[J].Factory=nil then Inc(lMissing)
          else Inc(lPlugins);
      WriteLn('Real GUI page begin index=',I,' id=',lProvider.Page.Id,
        ' components=',lProvider.Page.ComponentCount,' plugin=',lPlugins,' missing=',lMissing);
      Flush(Output);
      lWindow := TForm.CreateNew(nil);
      lWindow.Caption := 'Read-only real GUI smoke: '+lProvider.Page.Name;
      lWindow.SetBounds(25,25,1280,800);
      lCanvas := TPanel.Create(lWindow);
      lCanvas.Parent := lWindow; lCanvas.Align := alClient;
      lEditor := TFormEditorController.Create(lCanvas,@lProvider.GetPage,AFactories);
      try
        lEditor.SetDataContext(ATags,nil,1);
        lWindow.Show;
        lEditor.Render;
        Application.ProcessMessages;
        lEditor.RefreshLive;
        Application.ProcessMessages;
        WriteLn('Real GUI runtime rendered index=',I);
        lEditor.Enabled := True;
        Application.ProcessMessages;
        lWindow.SetBounds(25,25,1000,650);
        Application.ProcessMessages;
        lEditor.Enabled := False;
        Application.ProcessMessages;
        WriteLn('Real GUI edit/resize/runtime rendered index=',I);
        Flush(Output);
      finally FreeAndNil(lEditor); FreeAndNil(lWindow); end;
    end;
    lAfter := ReadFileBytes(APath);
    Check(Length(lBefore)=Length(lAfter),'Real user GUI file size changed');
    if Length(lBefore)>0 then
      Check(CompareByte(lBefore[0],lAfter[0],Length(lBefore))=0,'Real user GUI bytes changed');
    WriteLn('RESULT Oscillogram real GUI all pages runtime/edit/resize read-only passed pages=',lForms.PageCount);
  finally
    lEditor.Free; lWindow.Free; lForms.Free; lProvider.Free;
  end;
end;

procedure Run(const APluginFile: string);
var
  lConfigFile, lPluginDirectory, lPluginPath: string;
  lIni: TMemIniFile; lFactories: TRecorderComponentFactory;
  lTags: TRecorderTagRegistry; lTag: TRecorderTag; lRuntime: TRecorderPluginRuntime;
  lPage: TRecorderFormPage; lContext: TRecorderComponentCreateContext;
  lFactory: TRecorderComponentFactoryBase; lComponent: TRecorderPluginVisualComponent;
  lBuiltinComponent: TRecorderVisualComponent;
  lBuiltinCount: Integer;
  lDefaultFactories: TRecorderComponentFactory;
  lHost: TRecorderPluginVisualHostControl; lState: TRecorderPluginConfigBytes;
  lHostForm: TForm;
  lJsonText: UTF8String; lJson: TJSONData; I: Integer;
  {$IFDEF MSWINDOWS} lRoot: HWND; {$ENDIF}
begin
  Check(FileExists(APluginFile), 'production plugin DLL missing');
  lDefaultFactories:=TRecorderComponentFactory.Create;
  try
    lDefaultFactories.RegisterDefaultComponents;
    Check(lDefaultFactories.FindFactory('Oscillogram') is TRecorderOscillogramFactory,
      'host must own the separate simple Oscillogram');
    Check(lDefaultFactories.FindFactory('sample.oscillogram')=nil,
      'host default registry registered plugin type without DLL');
  finally lDefaultFactories.Free; end;
  lPluginDirectory := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'plugins';
  Check(ForceDirectories(lPluginDirectory), 'cannot prepare isolated plugin directory');
  lPluginPath := IncludeTrailingPathDelimiter(lPluginDirectory) + ExtractFileName(APluginFile);
  Check(FileUtil.CopyFile(APluginFile, lPluginPath), 'cannot copy production DLL into loader directory');
  lConfigFile := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'oscillogram-runtime.ini';
  lIni := TMemIniFile.Create(lConfigFile);
  try
    lIni.WriteInteger('Plugins','Count',1);
    lIni.WriteString('Plugin0','FileName',ExtractFileName(APluginFile));
    lIni.UpdateFile;
  finally lIni.Free; end;
  lFactories := TRecorderComponentFactory.Create;
  lFactories.RegisterDefaultComponents;
  lBuiltinCount := lFactories.FactoryCount;
  lTags := TRecorderTagRegistry.Create(nil);
  lPage := TRecorderFormPage.Create('smoke','Smoke','Smoke');
  lRuntime := TRecorderPluginRuntime.Create(lFactories,lTags);
  lHost := nil;
  lHostForm := nil;
  try
    lTag := lTags.CreateTag('Wave',512,True);
    lTag.UnitName := 'mV'; lTag.PollFrequencyHz := 100;
    lTag.RangeMin := -10; lTag.RangeMax := 10;
    lTags.SelectedTagName := lTag.Name;
    for I := 0 to 200 do lTag.AddSample(I/100,8*Sin(2*Pi*I/100));
    lRuntime.LoadConfigured(lConfigFile);
    Check(lRuntime.LoadedCount = 1,'production DLL was not loaded');
    {$IFDEF MSWINDOWS} CheckDescriptorPrefixes(lPluginPath); {$ENDIF}
    lFactory := lFactories.FindFactory('sample.oscillogram');
    Check(lFactory <> nil,'production plugin factory missing');
    Check(lFactories.FindFactory('Oscillogram')<>lFactory,'plugin stole builtin Oscillogram type');
    Check(lFactories.FactoryCount=lBuiltinCount+1,'plugin must add exactly its own factory');
    lBuiltinComponent:=lFactories.CreateComponent('Oscillogram');
    try
      Check(lBuiltinComponent is TRecorderOscillogramComponent,
        'builtin Oscillogram must use the simple host model');
      Check(lBuiltinComponent.Factory<>lFactory,'builtin component uses plugin factory');
    finally lBuiltinComponent.Free; end;
    WriteLn('RESULT Simple builtin Oscillogram/plugin Oscillograph distinct factories passed');
    CheckProjectMigration(lFactories,lTag);
    CheckBuiltinSimpleProject(lFactories,lTag);
    if (ParamCount=2) and not SameText(ParamStr(2),'inspect') then
      CheckRealGuiPages(ParamStr(2),lFactories,lTags);
    lContext := Default(TRecorderComponentCreateContext);
    lContext.Page := lPage; lContext.ComponentNo := 1;
    lContext.SelectedTag := lTag;
    lComponent := TRecorderPluginVisualComponent(lFactory.CreateComponentForPage(lContext));
    Check(lFactory.SaveOpaqueComponentState(lComponent) = rosSuccess,
      'production plugin did not serialize its state');
    lState := lComponent.ConfigBlob;
    SetString(lJsonText,PAnsiChar(@lState[0]),Length(lState));
    lJson := GetJSON(lJsonText);
    try
      Check(TJSONObject(lJson).Get('TagName','') = 'Wave','palette binding not owned by plugin');
      Check(TJSONObject(lJson).Get('TagId',Int64(0)) = lTag.Id,'plugin binding ID mismatch');
      { The model default scale is 0..1, while this fixture supplies +/-8 mV.
        Exercise the plugin's own saved autoscale setting instead of relying
        on an unrelated default to make the entire waveform visible. }
      TJSONObject(lJson).Booleans['AutoRangeEnabled'] := True;
      TJSONObject(lJson).Booleans['XCursorEnabled'] := True;
      TJSONObject(lJson).Integers['XCursorCount'] := 2;
      TJSONObject(lJson).Integers['BindingMode'] := 1;
      TJSONObject(lJson).Strings['TriggerTagName'] := 'Wave';
      lJsonText := lJson.AsJSON;
      SetLength(lState, Length(lJsonText));
      Move(lJsonText[1], lState[0], Length(lState));
      lComponent.ConfigBlob := lState;
      Check(lFactory.LoadOpaqueComponentState(lComponent) = rosSuccess,
        'production autoscale configuration did not load');
    finally lJson.Free; end;
    lHost := TRecorderPluginVisualHostControl.Create(nil);
    lHostForm := TForm.CreateNew(nil);
    lHostForm.Caption := 'Oscillogram production smoke';
    lHostForm.SetBounds(50,50,820,540);
    lHost.Parent := lHostForm;
    lHost.Align := alClient;
    lHostForm.Show;
    Application.ProcessMessages;
    lHost.Configure(lComponent,lTags);
    lHost.Show;
    Application.ProcessMessages;
    lFactories.DoUpdateData;
    Application.ProcessMessages;
    {$IFDEF MSWINDOWS}
    lRoot := FindWindowEx(lHost.Handle,0,nil,'Oscillogram plugin view');
    Check(lRoot <> 0,'production plugin has no native root');
    WriteLn('Native visibility form=',IsWindowVisible(lHostForm.Handle),
      ' host=',IsWindowVisible(lHost.Handle),' plugin=',IsWindowVisible(lRoot),
      ' formStyle=',GetWindowLongPtr(lHostForm.Handle,GWL_STYLE));
    Flush(Output);
    if (ParamCount = 2) and SameText(ParamStr(2),'inspect') then Sleep(10000);
    CheckWaveformPixels(lRoot);
    CheckIndependentViewWindows(lComponent,lFactories);
    { Cursor preservation above uses a deliberately enabled blue double
      cursor. Disable it for the subsequent empty-waveform pixel assertion. }
    lJsonText := ComponentJson(lComponent,lFactory);
    lJson := GetJSON(lJsonText);
    try
      TJSONObject(lJson).Booleans['XCursorEnabled'] := False;
      lJsonText := UTF8String(lJson.AsJSON);
    finally lJson.Free; end;
    SetLength(lState,Length(lJsonText));
    Move(lJsonText[1],lState[0],Length(lJsonText));
    lComponent.ConfigBlob := lState;
    Check(lFactory.LoadOpaqueComponentState(lComponent)=rosSuccess,
      'Cannot restore cursor-free waveform fixture');
    lFactories.DoUpdateData;
    Application.ProcessMessages;
    { Force a cold metadata refresh to exceed the initially prepared 4096
      samples. A stale fs/catalog cannot draw this newly renamed ID-bound tag. }
    lTag.Name:='Переименованный датчик';
    lTag.UnitName:='V'; lTag.PollFrequencyHz:=10000;
    lTag.SignalBuffer.SetCapacity(20000);
    lTag.ClearSignalHistory;
    lRuntime.NotifyAll(PN_RCLOADCONFIG);
    for I:=0 to 10000 do lTag.AddSample(I/10000,8*Sin(2*Pi*I/10000));
    lFactories.DoUpdateData;
    Application.ProcessMessages;
    CheckWaveformPixels(lRoot);
    Check(lFactory.SaveOpaqueComponentState(lComponent)=rosSuccess,'rename state save');
    lState:=lComponent.ConfigBlob;
    SetString(lJsonText,PAnsiChar(@lState[0]),Length(lState));
    lJson:=GetJSON(lJsonText);
    try Check(TJSONObject(lJson).Get('TagId',Int64(0))=lTag.Id,'rename lost stable binding');
    finally lJson.Free; end;
    WriteLn('RESULT Oscillogram metadata rename/unit/10000Hz refresh passed');
    lTag.ClearSignalHistory;
    lFactories.DoUpdateData;
    Application.ProcessMessages;
    CheckWaveformPixels(lRoot,False);
    for I := 0 to 200 do lTag.AddSample(I/100,8*Sin(2*Pi*I/100));
    lFactories.DoUpdateData;
    Application.ProcessMessages;
    CheckWaveformPixels(lRoot);
    lHost.EditMode := True;
    Check(not IsWindowEnabled(lRoot),'production view did not release editor input');
    lHost.EditMode := False;
    lHostForm.SetBounds(50,50,920,640);
    RecreateWnd(lHost);
    Application.ProcessMessages;
    lFactories.DoUpdateData;
    Application.ProcessMessages;
    lRoot := FindWindowEx(lHost.Handle,0,nil,'Oscillogram plugin view');
    Check(lRoot <> 0,'production view did not survive native parent recreation');
    CheckWaveformPixels(lRoot);
    {$ENDIF}
    FreeAndNil(lHost);
    Check(lFactory.SaveOpaqueComponentState(lComponent) = rosSuccess,
      'plugin state was lost on native view detach');
    Check(lFactory.LoadOpaqueComponentState(lComponent) = rosSuccess,
      'plugin state reload failed');
  finally
    lHost.Free;
    lHostForm.Free;
    lRuntime.Free;
    lFactories.Free;
    lTags.Free;
    lPage.Free;
    SysUtils.DeleteFile(lConfigFile);
  end;
end;

begin
  try
    Check(ParamCount in [1,2],'usage: OscillogramRuntimeSmoke plugin-library [gui-ini|inspect]');
    Application.Initialize;
    Application.ShowMainForm := False;
    Run(ParamStr(1));
    WriteLn('RESULT OscillogramRuntimeSmoke passed');
  except
    on E: Exception do begin WriteLn('RESULT OscillogramRuntimeSmoke failed: ',E.Message); Halt(1); end;
  end;
end.
