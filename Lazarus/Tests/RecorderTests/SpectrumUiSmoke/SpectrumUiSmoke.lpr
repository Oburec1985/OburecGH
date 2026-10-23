program SpectrumUiSmoke;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Classes, SysUtils, Controls, Menus, Math,
  uRecorderSpectrumView, uRecorderFormModel, uRecorderTags,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartCursor, uOglChartRenderer, uOglChartTrend, uOglChartTypes, uOglChartDrawObj,
  uRecorderCoreServices, uRecorderSpectrumEngine, uRecorderSpectrumRuntime;
type TChartAccess = class(TOglChart) public property OnContextPopup; end;
procedure Check(AValue:Boolean; const AMessage:string);
begin if not AValue then raise Exception.Create(AMessage); end;
procedure Frame(ABus:TRecorderEventBus; const AName:string; APeak:Integer;
  AEmpty:Boolean=False);
var lFrame:TRecorderSpectrumFrame; lData:TRecorderSpectrumFrameEventData;
  I:Integer;
begin
  lFrame:=Default(TRecorderSpectrumFrame);
  lFrame.SourceTagName:=AName; lFrame.FrequencyStepHz:=1;
  if not AEmpty then
  begin
    SetLength(lFrame.Rms,101);
    for I:=0 to 100 do lFrame.Rms[I]:=0.1;
    lFrame.Rms[APeak]:=10; lFrame.Rms[90]:=100;
  end;
  lData:=TRecorderSpectrumFrameEventData.Create(lFrame);
  try ABus.Publish(TRecorderEventBus.MakeEvent(rceSpectrumFrame,nil,AName,'',0,lData));
  finally lData.Free; end;
end;
function Series(APage:TChartPage; const AName:string):cBuffTrend1d;
var I,J:Integer;
begin
  Result:=nil;
  for I:=0 to APage.ChildCount-1 do
    for J:=0 to APage.Children[I].ChildCount-1 do
      if (APage.Children[I].Children[J] is cBuffTrend1d) and
        (APage.Children[I].Children[J].Name=AName+'#primary') then
        Exit(cBuffTrend1d(APage.Children[I].Children[J]));
end;
procedure TrackPopup(AChart:TOglChart; APage:TChartPage; AX:Double);
var lRect:TChartPixelRect; lRenderer:TOpenGLChartRenderer; lHandled:Boolean;
begin
  lRenderer:=TOpenGLChartRenderer(AChart.GetRenderer);
  lRect:=lRenderer.GetPageContentRect(APage); lHandled:=False;
  TChartAccess(AChart).OnContextPopup(AChart,Point(Round(
    lRenderer.XValueToPixel(APage,nil,AX,lRect.Left,lRect.Right)),
    (lRect.Top+lRect.Bottom) div 2),lHandled);
end;
procedure RunTracking;
var lHost:TForm; lBus:TRecorderEventBus; lTags:TRecorderTagRegistry;
  lComp:TRecorderSpectrumComponent; lView:TRecorderSpectrumView;
  lChart:TOglChart; lPage:TChartPage; lCursor:TChartCursor;
  lMenu:TMenuItem; lCommands:TComponent; lSeries:cBuffTrend1d;
begin
  lHost:=TForm.CreateNew(nil); lHost.SetBounds(0,0,1000,600);
  lBus:=TRecorderEventBus.Create; lTags:=TRecorderTagRegistry.Create(lBus);
  lComp:=TRecorderSpectrumComponent.Create;
  try
    lComp.SetTagRefAt(0,lTags.CreateTag('Wave'));
    lComp.SetTagRefAt(1,lTags.CreateTag('Other'));
    lComp.RangeMinX:=1; lComp.RangeMaxX:=100; lComp.LgX:=False;
    lView:=TRecorderSpectrumView.Create(lHost);
    lView.Parent:=lHost; lView.Align:=alClient; lView.Configure(lComp,lTags);
    lHost.Show; Application.ProcessMessages;
    lChart:=lView.GetChartControl;
    lPage:=TChartPage(TChartModel(lChart.Model).Children[0]);
    lSeries:=Series(lPage,'Wave'); Check(lSeries<>nil,'Wave series absent');
    Frame(lBus,'Wave',30); Frame(lBus,'Other',45); lView.RefreshControl(lTags,1);
    lCursor:=GetOrCreatePageCursor(lPage); lCursor.Visible:=True;
    lCursor.CursorType:=cctDouble; lCursor.X1:=30; lCursor.X2:=60;
    lChart.SelectedObject:=lSeries; lChart.Repaint; Application.ProcessMessages;
    TrackPopup(lChart,lPage,30);
    lCommands:=lView.FindComponent('SpectrumCommands');
    lMenu:=TMenuItem(lCommands.FindComponent('FollowPeakItem'));
    Check((lMenu<>nil) and lMenu.Enabled,'Follow command unavailable at cursor');
    lMenu.Click; Check(lMenu.Checked,'Tracking not enabled');
    Frame(lBus,'Wave',31); lView.RefreshControl(lTags,1);
    Check(Abs(lCursor.X1-31)<0.01,'Tracking ignored new local peak');
    Check(Abs(lCursor.X2-60)<0.01,'Tracking moved wrong double cursor');
    lChart.SelectedObject:=Series(lPage,'Other');
    Frame(lBus,'Other',46); Frame(lBus,'Wave',32); lView.RefreshControl(lTags,1);
    Check(Abs(lCursor.X1-32)<0.01,'Tracking binding changed with selection');
    lView.RefreshControl(lTags,1);
    Check(Abs(lCursor.X1-32)<0.01,'Cursor changed without fresh frame');
    TrackPopup(lChart,lPage,32); Check(lMenu.Checked,'Tracking check lost');
    lMenu.Click;
    Frame(lBus,'Wave',33); lView.RefreshControl(lTags,1);
    Check(Abs(lCursor.X1-32)<0.01,'Disabled tracking moved cursor');
    lChart.SelectedObject:=lSeries;
    lCursor.X2:=40; TrackPopup(lChart,lPage,40); lMenu.Click;
    Frame(lBus,'Wave',41); lView.RefreshControl(lTags,1);
    Check(Abs(lCursor.X2-41)<0.01,'Second cursor tracking failed');
    Check(Abs(lCursor.X1-32)<0.01,'Second tracking changed first cursor');
    Frame(lBus,'Wave',0,True); lView.RefreshControl(lTags,1);
    Check(Abs(lCursor.X2-41)<0.01,'Empty frame moved tracked cursor');
    lComp.LgX:=True; lView.Configure(lComp,lTags);
    Application.ProcessMessages;
    lPage:=TChartPage(TChartModel(lChart.Model).Children[0]);
    lSeries:=Series(lPage,'Wave'); lChart.SelectedObject:=lSeries;
    Frame(lBus,'Wave',30); lView.RefreshControl(lTags,1);
    lCursor:=GetOrCreatePageCursor(lPage); lCursor.Visible:=True;
    lCursor.X1:=30; lChart.Repaint; Application.ProcessMessages;
    TrackPopup(lChart,lPage,30);
    lCommands:=lView.FindComponent('SpectrumCommands');
    lMenu:=TMenuItem(lCommands.FindComponent('FollowPeakItem'));
    Check(not lMenu.Checked,'Reconfigure retained stale tracking binding');
    lMenu.Click; Frame(lBus,'Wave',31); lView.RefreshControl(lTags,1);
    Check(Abs(lCursor.X1-31)<0.01,'Logarithmic X tracking failed');
    WriteLn('RESULT SpectrumUiSmoke tracking/local-peak/fresh/off/binding/double/empty/reconfigure passed');
  finally lHost.Free; lComp.Free; lTags.Free; lBus.Free; end;
end;
procedure Run;
var lHost:TForm; lView:TRecorderSpectrumView; lComp:TRecorderSpectrumComponent;
  lTags:TRecorderTagRegistry; lChart:TOglChart; lPage:TChartPage;
  lAxis:TChartAxis; lCursor:TChartHorizontalCursor; lCommands:TComponent;
  lHandled:Boolean; I,J:Integer;
begin
  lHost:=TForm.CreateNew(nil); lHost.SetBounds(0,0,800,500);
  lTags:=TRecorderTagRegistry.Create; lComp:=TRecorderSpectrumComponent.Create;
  lView:=nil;
  try
    lComp.AddAxis.Name:='Secondary';
    lView:=TRecorderSpectrumView.Create(lHost);
    lView.Parent:=lHost; lView.Align:=alClient;
    for J:=0 to 1 do
    begin
      lView.Configure(lComp,lTags);
      lHost.Show; Application.ProcessMessages;
      lChart:=lView.GetChartControl;
      lPage:=TChartPage(TChartModel(lChart.Model).Children[0]);
      lAxis:=nil; lCursor:=nil;
      for I:=0 to lPage.ChildCount-1 do
      begin
        if lPage.Children[I] is TChartAxis then lAxis:=TChartAxis(lPage.Children[I]);
        if lPage.Children[I] is TChartHorizontalCursor then
          lCursor:=TChartHorizontalCursor(lPage.Children[I]);
      end;
      Check((lAxis<>nil) and (lCursor<>nil),'Axis/cursor resource absent');
      Check(not lCursor.Visible,'Reconfigured cursor must start hidden');
      lChart.SelectedObject:=lAxis;
      lHandled:=False;
      TChartAccess(lChart).OnContextPopup(lChart,Point(300,180),lHandled);
      lCommands:=lView.FindComponent('SpectrumCommands');
      Check(lCommands<>nil,'Designer context menu resource absent');
      TMenuItem(lCommands.FindComponent('SetLevelItem')).Click;
      Check(lCursor.Visible and lCursor.ShowLabel,'Level cursor and label not enabled');
      Check(lCursor.Axis=lAxis,'Level cursor ignored selected secondary axis');
      Check(not IsNan(lCursor.Y) and not IsInfinite(lCursor.Y),'Invalid cursor value');
      lChart.Repaint; Application.ProcessMessages;
      TMenuItem(lCommands.FindComponent('HideLevelItem')).Click;
      Check(not lCursor.Visible,'Level cursor hide failed');
    end;
    WriteLn('RESULT SpectrumUiSmoke menu/secondary-axis/label/hide/reconfigure passed');
  finally lHost.Free; lComp.Free; lTags.Free; end;
end;
begin
  try
    Application.Initialize; Application.ShowMainForm:=False; Run; RunTracking;
  except on E:Exception do begin WriteLn('RESULT SpectrumUiSmoke failed: ',E.Message);
    DumpExceptionBackTrace(Output); Halt(1); end; end;
end.
