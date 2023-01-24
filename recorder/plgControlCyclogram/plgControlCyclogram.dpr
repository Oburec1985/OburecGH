library plgControlCyclogram;

uses
  u2dMath,
  Windows,
  Themes,
  SysUtils,
  Classes,
  PluginClass in '..\SharedRUnits\PluginClass.pas',
  uCompMng in '..\plgTestClear\units\uCompMng.pas',
  uRecBasicFactory in '..\SharedRUnits\uRecBasicFactory.pas',
  uRecorderEvents in '..\SharedRUnits\uRecorderEvents.pas',
  uCreateComponents in 'units\uCreateComponents.pas',
  blaccess in '..\SharedRUnits\interfaces\blaccess.pas',
  CFREG in '..\SharedRUnits\interfaces\CFREG.PAS',
  DevAPI in '..\SharedRUnits\interfaces\DevAPI.pas',
  device in '..\SharedRUnits\interfaces\device.pas',
  journal in '..\SharedRUnits\interfaces\journal.pas',
  modules in '..\SharedRUnits\interfaces\modules.pas',
  plugin in '..\SharedRUnits\interfaces\plugin.pas',
  rcPlugin in '..\SharedRUnits\interfaces\rcPlugin.pas',
  recorder in '..\SharedRUnits\interfaces\recorder.pas',
  signal in '..\SharedRUnits\interfaces\signal.pas',
  tags in '..\SharedRUnits\interfaces\tags.pas',
  transformers in '..\SharedRUnits\interfaces\transformers.pas',
  uControlObj in 'units\uControlObj.pas',
  uControlEditFrame in 'forms\uControlEditFrame.pas' {ControlEditFrame: TFrame},
  uModeFrame in 'forms\uModeFrame.pas' {ModeFrame: TFrame},
  uControlCyclogramEditFrm in 'forms\uControlCyclogramEditFrm.pas' {ControlCyclogramEditFrm},
  uControlDeskFrm in 'forms\uControlDeskFrm.pas' {ControlDeskFrm},
  uBaseObj in '..\..\sharedUtils\objects\uBaseObj.pas',
  uBaseObjMng in '..\..\sharedUtils\objects\uBaseObjMng.pas',
  usetlist in '..\..\sharedUtils\utils\lists\usetlist.pas',
  uRTrig in 'units\uRTrig.pas',
  uEventTypes in '..\..\sharedUtils\utils\lists\uEventTypes.pas',
  ueventlist in '..\..\sharedUtils\utils\lists\ueventlist.pas',
  uComponentServises in '..\..\sharedUtils\utils\uComponentServises.pas',
  uCustomEditControlFrame in 'forms\uCustomEditControlFrame.pas' {CustomControlEditFrame: TFrame},
  uDacControlEditFrame in 'forms\uDacControlEditFrame.pas' {DACControlEditFrame: TFrame},
  uRvclService in '..\SharedRUnits\uRvclService.pas',
  uVTServices in '..\..\sharedUtils\utils\uVTServices.pas',
  uModesTabsFrame in 'forms\uModesTabsFrame.pas' {ModesTabFrame: TFrame},
  uModesTabsForm in 'forms\uModesTabsForm.pas' {ModesTabForm},
  uControlsNP in 'units\uControlsNP.pas',
  uModesStepFrame in 'forms\uModesStepFrame.pas' {ModesStepFrame: TFrame},
  uMeasureBase in '..\..\sharedUtils\mera\database\uMeasureBase.pas',
  uChart in '..\..\sharedUtils\����������\chart_dpk\chart\uChart.pas',
  uAutoPage in '..\..\sharedUtils\����������\chart_dpk\chart\items\uAutoPage.pas',
  uAxis in '..\..\sharedUtils\����������\chart_dpk\chart\items\uAxis.pas',
  uBasePage in '..\..\sharedUtils\����������\chart_dpk\chart\items\uBasePage.pas',
  uBasicTrend in '..\..\sharedUtils\����������\chart_dpk\chart\items\uBasicTrend.pas',
  uBuffTrend in '..\..\sharedUtils\����������\chart_dpk\chart\items\uBuffTrend.pas',
  uBuffTrend1d in '..\..\sharedUtils\����������\chart_dpk\chart\items\uBuffTrend1d.pas',
  uBuffTrend2d in '..\..\sharedUtils\����������\chart_dpk\chart\items\uBuffTrend2d.pas',
  uChartCursor in '..\..\sharedUtils\����������\chart_dpk\chart\items\uChartCursor.pas',
  uDoubleCursor in '..\..\sharedUtils\����������\chart_dpk\chart\items\uDoubleCursor.pas',
  uDrawObj in '..\..\sharedUtils\����������\chart_dpk\chart\items\uDrawObj.pas',
  uDrawObjMng in '..\..\sharedUtils\����������\chart_dpk\chart\items\uDrawObjMng.pas',
  uEdit in '..\..\sharedUtils\����������\chart_dpk\chart\items\uEdit.pas',
  uFloatEdit in '..\..\sharedUtils\����������\chart_dpk\chart\items\uFloatEdit.pas',
  uFloatLabel in '..\..\sharedUtils\����������\chart_dpk\chart\items\uFloatLabel.pas',
  uFontMng in '..\..\sharedUtils\����������\chart_dpk\chart\items\uFontMng.pas',
  uGistogram in '..\..\sharedUtils\����������\chart_dpk\chart\items\uGistogram.pas',
  uGraphObj in '..\..\sharedUtils\����������\chart_dpk\chart\items\uGraphObj.pas',
  uGrid in '..\..\sharedUtils\����������\chart_dpk\chart\items\uGrid.pas',
  uGrid_ in '..\..\sharedUtils\����������\chart_dpk\chart\items\uGrid_.pas',
  uGrid_new in '..\..\sharedUtils\����������\chart_dpk\chart\items\uGrid_new.pas',
  uInfoPage in '..\..\sharedUtils\����������\chart_dpk\chart\items\uInfoPage.pas',
  uLabel in '..\..\sharedUtils\����������\chart_dpk\chart\items\uLabel.pas',
  uLegend in '..\..\sharedUtils\����������\chart_dpk\chart\items\uLegend.pas',
  uMarkers in '..\..\sharedUtils\����������\chart_dpk\chart\items\uMarkers.pas',
  upage in '..\..\sharedUtils\����������\chart_dpk\chart\items\upage.pas',
  uPageMng in '..\..\sharedUtils\����������\chart_dpk\chart\items\uPageMng.pas',
  uPoint in '..\..\sharedUtils\����������\chart_dpk\chart\items\uPoint.pas',
  uSimpleTrend in '..\..\sharedUtils\����������\chart_dpk\chart\items\uSimpleTrend.pas',
  uTabObj in '..\..\sharedUtils\����������\chart_dpk\chart\items\uTabObj.pas',
  uTextLabel in '..\..\sharedUtils\����������\chart_dpk\chart\items\uTextLabel.pas',
  uTrend in '..\..\sharedUtils\����������\chart_dpk\chart\items\uTrend.pas',
  uChartEvents in '..\..\sharedUtils\����������\chart_dpk\chart\utils\lists\uChartEvents.pas',
  uText in '..\..\sharedUtils\����������\chart_dpk\chart\utils\uText.pas',
  uAxisForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uAxisForm.pas' {AxisForm},
  uChartCfgForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uChartCfgForm.pas' {ChartCfgForm},
  uCreateObjForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uCreateObjForm.pas' {CreateObjForm},
  uCreateObjFrm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uCreateObjFrm.pas' {CreateObjFrm},
  uCreateTrendFrame in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uCreateTrendFrame.pas' {EditChartCfgFrame: TFrame},
  uCursorForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uCursorForm.pas' {CursorForm},
  uDoubleCursorForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uDoubleCursorForm.pas' {DoubleCursorForm},
  uDrawObjEditForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uDrawObjEditForm.pas' {DrawObjEditForm},
  uDrawObjFrame in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uDrawObjFrame.pas' {DrawObjFrame: TFrame},
  uEditChartObjFrame in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uEditChartObjFrame.pas' {EditDrawObjFrame: TFrame},
  uEditMenuChartForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uEditMenuChartForm.pas' {EditMenuChartForm},
  uGistForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uGistForm.pas' {GistForm},
  uGistFrame in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uGistFrame.pas' {GistFrame: TFrame},
  uPageForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uPageForm.pas' {PageForm},
  uTextLabelForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uTextLabelForm.pas' {TextLabelForm},
  uTrendForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uTrendForm.pas' {TrendForm},
  uTrendFrame in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uTrendFrame.pas' {TrendFrame: TFrame},
  uChartInputFrame in '..\..\sharedUtils\����������\chart_dpk\chart\forms\frames\uChartInputFrame.pas' {ChartInputFrame: TFrame},
  uChartClickFrListener in '..\..\sharedUtils\����������\chart_dpk\chart\items\framelisteners\uChartClickFrListener.pas',
  uObjFrameListener in '..\..\sharedUtils\����������\chart_dpk\chart\items\framelisteners\uObjFrameListener.pas',
  uPageFrameListener in '..\..\sharedUtils\����������\chart_dpk\chart\items\framelisteners\uPageFrameListener.pas',
  uCommonMath in '..\..\sharedUtils\math\uCommonMath.pas',
  uNodeObject in '..\..\3d\objects\uNodeObject.pas',
  uTreeNode in '..\..\sharedUtils\objects\uTreeNode.pas',
  uTrigFrame in 'forms\uTrigFrame.pas' {TrigFrame: TFrame},
  uBaseObjService in '..\..\sharedUtils\objects\uBaseObjService.pas',
  uRCFunc in '..\SharedRUnits\uRCFunc.pas',
  uRcCtrls in '..\SharedRUnits\RC_lib\uRcCtrls.pas',
  uDBObject in '..\..\sharedUtils\mera\database\uDBObject.pas',
  uMDBFrm in '..\..\sharedUtils\mera\database\uMDBFrm.pas' {MDBFrm},
  uMBaseControl in 'forms\uMBaseControl.pas' {MBaseControl},
  uRcClient in '..\SharedRUnits\uRcClient.pas',
  uPathMng in '..\..\sharedUtils\utils\uPathMng.pas',
  PathUtils in '..\..\sharedUtils\utils\PathUtils\PathUtils.pas',
  uDownloadRegsFrm in '..\..\sharedUtils\mera\database\uDownloadRegsFrm.pas' {DownloadRegsFrm},
  ZipMstr in '..\..\sharedUtils\ZipMaster\ZipMstr.pas',
  uMDBBaseObjFrame in '..\..\sharedUtils\mera\database\uMDBBaseObjFrame.pas' {MDBBaseObjFrame: TFrame},
  uMDBTestObjFrame in '..\..\sharedUtils\mera\database\uMDBTestObjFrame.pas' {MDBTestObjFrame: TFrame},
  uRcClientFrm in '..\SharedRUnits\uRcClientFrm.pas' {RcClientFrm},
  uAutoPropsFrm in 'forms\uAutoPropsFrm.pas' {AutoPropFrm},
  uTrigsFrm in 'forms\uTrigsFrm.pas' {TrigsFrm},
  uTagsListFrame in '..\SharedRUnits\uTagsListFrame.pas' {TagsListFrame: TFrame},
  iplgmngr in '..\SharedRUnits\interfaces\iplgmngr.pas',
  uMDBRegObjFrame in '..\..\sharedUtils\mera\database\uMDBRegObjFrame.pas' {MDBRegObjFrame: TFrame},
  scales in '..\SharedRUnits\interfaces\scales.pas',
  sdb in '..\SharedRUnits\interfaces\sdb.pas',
  sdbview in '..\SharedRUnits\interfaces\sdbview.pas',
  transf in '..\SharedRUnits\interfaces\transf.pas',
  meconsts in '..\SharedRUnits\interfaces\meconsts.pas',
  uAlgFrm in 'forms\uAlgFrm.pas' {AlgFrm},
  uAlgFrame in 'forms\uAlgFrame.pas' {BaseAlgFrame: TFrame},
  uAlgAddFrm in 'forms\uAlgAddFrm.pas' {AddAlgFrm},
  uBaseAlg in 'units\uBaseAlg.pas',
  uIntegralAlgFrame in 'forms\uIntegralAlgFrame.pas' {IntegralAlgFrame: TFrame},
  uIntegralAlg in 'units\uIntegralAlg.pas',
  uBaseAlgNP in 'units\uBaseAlgNP.pas',
  uTahoAlgFrame in 'forms\uTahoAlgFrame.pas' {TahoAlgFrame: TFrame},
  uTahoAlg in 'units\uTahoAlg.pas',
  uFFT in '..\..\sharedUtils\math\uFFT.pas',
  uGrmsFrame in 'forms\uGrmsFrame.pas' {GRmsFrame: TFrame},
  uGrmsAlg in 'units\uGrmsAlg.pas',
  uPhaseFrame in 'forms\uPhaseFrame.pas' {PhaseFrame: TFrame},
  uPolarGraph in 'forms\uPolarGraph.pas' {PolarGraph},
  uSpmChartEdit in 'forms\uSpmChartEdit.pas' {SpmChartEditFrm},
  uSynchroPhaseAlg in 'units\uSynchroPhaseAlg.pas',
  uSpmFrame in 'forms\uSpmFrame.pas' {SpmFrame: TFrame},
  uGrmsSrcAlg in 'units\uGrmsSrcAlg.pas',
  uGrmsSrcFrame in 'forms\uGrmsSrcFrame.pas' {GrmsSrcFrame: TFrame},
  uFillingFactorAlg in 'units\uFillingFactorAlg.pas',
  uFillFctFrame in 'forms\uFillFctFrame.pas' {FillFctFrame: TFrame},
  uControlWarnFrm in 'forms\uControlWarnFrm.pas' {CntrlWrnChart},
  uEditControlWrnFrm in 'forms\uEditControlWrnFrm.pas' {EditCntlWrnFrm},
  uEditProfileFrm in 'forms\uEditProfileFrm.pas' {EditProfileFrm},
  uCursorFrm in 'forms\uCursorFrm.pas' {CursorFrm},
  ubuffsignal in '..\..\sharedUtils\mera\ubuffsignal.pas',
  uMeraFile in '..\..\sharedUtils\mera\uMeraFile.pas',
  umeraSignal in '..\..\sharedUtils\mera\umeraSignal.pas',
  uSignalsUtils in '..\..\sharedUtils\mera\uSignalsUtils.pas',
  uPhaseAlg in 'units\uPhaseAlg.pas',
  uPhaseCrossSpmFrame in 'forms\uPhaseCrossSpmFrame.pas' {SynchroPhasePhrame: TFrame},
  uBandsFrm in 'forms\uBandsFrm.pas' {BandsFrm},
  uFreqBand in '..\..\sharedUtils\����������\chart_dpk\chart\items\uFreqBand.pas',
  uAHCorrectionFrm in 'forms\uAHCorrectionFrm.pas' {AHCorrectionFrm},
  uSpmChart in 'forms\uSpmChart.pas' {SpmChart},
  uPolarGraphPage in '..\..\sharedUtils\����������\chart_dpk\chart\items\uPolarGraphPage.pas',
  uScktComp in '..\..\sharedUtils\utils\socket\uScktComp.pas',
  uEditPolarFrm in 'forms\uEditPolarFrm.pas' {EditPolarFrm},
  uCyclogramReportFrm in 'forms\uCyclogramReportFrm.pas' {CyclogramReportFrm},
  uAlarms in '..\SharedRUnits\interfaces\uAlarms.pas',
  uSpm in 'units\uSpm.pas',
  uTagInfoFrm in 'forms\uTagInfoFrm.pas' {TagInfoFrm},
  uTagInfoEditFrm in 'forms\uTagInfoEditFrm.pas' {TagInfoEditFrm},
  uPeakFactorAlg in 'units\uPeakFactorAlg.pas',
  uPeakFactorFrame in 'forms\uPeakFactorFrame.pas' {PeakFactorFrame: TFrame},
  uHardwareMath in '..\..\sharedUtils\math\uHardwareMath.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  PerformanceTime in '..\..\sharedUtils\utils\PerformanceTime.pas',
  uComplexDiagram in 'forms\uComplexDiagram.pas' {ComplexDiagramFrm},
  uCounterAlg in 'units\uCounterAlg.pas',
  uCounterAlgFrame in 'forms\uCounterAlgFrame.pas' {CounterAlgFrame: TFrame},
  uRCTags in '..\SharedRUnits\uRCTags.pas',
  uIRDiagram in 'forms\uIRDiagram.pas' {IRDiagramFrm},
  uQueue in '..\..\sharedUtils\utils\lists\uQueue.pas',
  uGenSignalsFrm in 'forms\uGenSignalsFrm.pas' {GenSignalsFrm},
  uGenSignalsEditFrm in 'forms\uGenSignalsEditFrm.pas' {GenSignalsEditFrm},
  uIRDiagramEditFrm in 'forms\uIRDiagramEditFrm.pas' {IRDiagrEditFrm},
  u3dObj in 'forms\u3dObj.pas' {ObjFrm3d},
  uGLFrmEdit in 'forms\uGLFrmEdit.pas' {ObjFrm3dEdit},
  uAriphmAlg in 'units\uAriphmAlg.pas',
  uAriphmAlgFrame in 'forms\uAriphmAlgFrame.pas' {AriphmAlgFrame: TFrame},
  uTimeIntervalAlg in 'units\uTimeIntervalAlg.pas',
  uExcel in '..\..\sharedUtils\utils\reports\excel\uExcel.pas',
  uConfirmDlg in '..\..\sharedUtils\forms\uConfirmDlg.pas' {ConfirmFmr},
  uEditPropertiesFrm in 'forms\uEditPropertiesFrm.pas' {EditPropertiesFrm},
  uBaseAlgBands in 'uBaseAlgBands.pas',
  uAlgsSaveFrm in 'forms\uAlgsSaveFrm.pas' {SaveAlgsFrm},
  Iterative_FFT_sse in '..\..\sharedUtils\math\FFT_������\Iterative_FFT_sse.pas',
  uFrmSync in '..\SharedRUnits\uFrmSync.pas' {FrmSync},
  uSyncOscillogram in 'forms\uSyncOscillogram.pas' {SyncOscFrm},
  uSyncOscillogramEditFrm in 'forms\uSyncOscillogramEditFrm.pas' {EditSyncOscFrm},
  uQueue2 in '..\..\sharedUtils\utils\lists\uQueue2.pas';

//{$FPUTYPE SSE}
{$R toolbarExtPack.res}
{$R *.res}

{ -----------------------------------------------��������� - ����� ����� � dll }
{ ���������� ��� �������� � �������� dll }
procedure DllEntryPoint(Reason: integer);
begin
  case Reason of { ��������� �� ���� ������� ������ }
    DLL_PROCESS_ATTACH:
    begin

    end;
    DLL_PROCESS_DETACH:
    begin
      // �������� �������� ���������� ������� ���������� ������ ����
      ThemeServices.Free;
    end;
    DLL_THREAD_ATTACH:
    begin

    end;
    DLL_THREAD_DETACH:
    begin

    end;
  end;
end;


// ----------------------------�������������� �������}
// {���� ������� � ����������� ���� �������, ������� ������ ��������������}
// ���������� plug-in`� ��� Recorder`�}
// ��������� ���� �������, �������������� � ����������}
function GetPluginType: integer; cdecl;
begin
  Result := PLUGIN_CLASS; { � ������ ������, ��� ��� ������� plug-in`� }
end;
// ������� �������� ���������� plug-in`�.
// ������� ��������� ����� �������, ��� ����� ��� ���������� �� ���������,
// � ���������. ������� ������ ���������� ���������� � ��������� ��������.
function CreatePluginClass: pointer { IRecorderPlugin } ; cdecl;
begin
  GPluginInstance := TExtRecorderPack.Create;
  // �������� ������ ����������� ���������� plug-in`�}
  Result := pointer(GPluginInstance);
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // ��� �������� ������� ��� �������� DELPHI �� �������� ���������� ������!!!!!
  GPluginInstance._AddRef;
end;

// ������� �������� plug-in`�
function DestroyPluginClass(piPlg: IRecorderPlugin): integer; cdecl;
begin
  // ��� ��� ������ ���� � ����������, �� �� ����� �� ���������.
  // ������ plug-in`� ������� ���� ��� (��� ����� COM ������),
  // ���� ������� ������ ��� ����������� ������ ����� ����.
  GlobDetach;
  Result := RCERROR_NOERROR;
  {$ifdef DEBUG}
  TExtRecorderPack(GPluginInstance).destroyForms;
  TExtRecorderPack(GPluginInstance).destroyLog;

  GPluginInstance._release;
  GPluginInstance := NIL;
  {$endif}
end;

{ ������� ��������� ������ �������� plug-in`� }
function GetPluginDescription: LPCSTR; cdecl;
begin
  // �������� ����������� �� ���������� ������������ ���������}
  Result := LPCSTR(GPluginInfo.Dsc);
  // Result := LPCSTR('������ ��� ����� (������)');
end;

{ ������� ��������� ������� �������� plug-in`� }
procedure GetPluginInfo(var lpPluginInfo: PLUGININFO); cdecl;
begin
  // �������� ����������� �� ���������� ������������ ���������
  // ����������� ����� ������������ ������ ��������� StrCopy()
  // ��-�� ����, ��� ��������� �������� plug-in`� �������
  // � ����� C++}
  //ZeroMemory(lpPluginInfo,sizeof(lpPluginInfo));
  StrCopy(@lpPluginInfo.name, LPCSTR(GPluginInfo.Name));
  StrCopy(@lpPluginInfo.describe, LPCSTR(GPluginInfo.Dsc));
  StrCopy(@lpPluginInfo.vendor, LPCSTR(GPluginInfo.vendor));
  lpPluginInfo.version := GPluginInfo.version;
  lpPluginInfo.subversion := GPluginInfo.SubVertion;
end;

{ ---------------------���������� �������������� ��������---------------------- }
// ��������� ��������� ���� �������������� �������
exports GetPluginType name 'GetPluginType';
exports CreatePluginClass name 'CreatePluginClass';
exports DestroyPluginClass name 'DestroyPluginClass';
exports GetPluginDescription name 'GetPluginDescription';
exports GetPluginInfo name 'GetPluginInfo';

begin
  // ����������� ����� ������� DllEntryPoint, ����� �������
  // ����� ������� DllEntryPoint ���������� �����������
  // ������������ ��������� � �������� ����������
  if not Assigned(DLLProc) then
    DLLProc := @DllEntryPoint;
  DllEntryPoint(DLL_PROCESS_ATTACH);

end.
