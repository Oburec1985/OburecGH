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
  uChart in '..\..\sharedUtils\компоненты\chart_dpk\chart\uChart.pas',
  uAutoPage in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uAutoPage.pas',
  uAxis in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uAxis.pas',
  uBasePage in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uBasePage.pas',
  uBasicTrend in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uBasicTrend.pas',
  uBuffTrend in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uBuffTrend.pas',
  uBuffTrend1d in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uBuffTrend1d.pas',
  uBuffTrend2d in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uBuffTrend2d.pas',
  uChartCursor in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uChartCursor.pas',
  uDoubleCursor in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uDoubleCursor.pas',
  uDrawObj in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uDrawObj.pas',
  uDrawObjMng in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uDrawObjMng.pas',
  uEdit in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uEdit.pas',
  uFloatEdit in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uFloatEdit.pas',
  uFloatLabel in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uFloatLabel.pas',
  uFontMng in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uFontMng.pas',
  uGistogram in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uGistogram.pas',
  uGraphObj in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uGraphObj.pas',
  uGrid in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uGrid.pas',
  uGrid_ in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uGrid_.pas',
  uGrid_new in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uGrid_new.pas',
  uInfoPage in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uInfoPage.pas',
  uLabel in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uLabel.pas',
  uLegend in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uLegend.pas',
  uMarkers in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uMarkers.pas',
  upage in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\upage.pas',
  uPageMng in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uPageMng.pas',
  uPoint in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uPoint.pas',
  uSimpleTrend in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uSimpleTrend.pas',
  uTabObj in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uTabObj.pas',
  uTextLabel in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uTextLabel.pas',
  uTrend in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uTrend.pas',
  uChartEvents in '..\..\sharedUtils\компоненты\chart_dpk\chart\utils\lists\uChartEvents.pas',
  uText in '..\..\sharedUtils\компоненты\chart_dpk\chart\utils\uText.pas',
  uAxisForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uAxisForm.pas' {AxisForm},
  uChartCfgForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uChartCfgForm.pas' {ChartCfgForm},
  uCreateObjForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCreateObjForm.pas' {CreateObjForm},
  uCreateObjFrm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCreateObjFrm.pas' {CreateObjFrm},
  uCreateTrendFrame in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCreateTrendFrame.pas' {EditChartCfgFrame: TFrame},
  uCursorForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCursorForm.pas' {CursorForm},
  uDoubleCursorForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uDoubleCursorForm.pas' {DoubleCursorForm},
  uDrawObjEditForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uDrawObjEditForm.pas' {DrawObjEditForm},
  uDrawObjFrame in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uDrawObjFrame.pas' {DrawObjFrame: TFrame},
  uEditChartObjFrame in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uEditChartObjFrame.pas' {EditDrawObjFrame: TFrame},
  uEditMenuChartForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uEditMenuChartForm.pas' {EditMenuChartForm},
  uGistForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uGistForm.pas' {GistForm},
  uGistFrame in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uGistFrame.pas' {GistFrame: TFrame},
  uPageForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uPageForm.pas' {PageForm},
  uTextLabelForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uTextLabelForm.pas' {TextLabelForm},
  uTrendForm in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uTrendForm.pas' {TrendForm},
  uTrendFrame in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uTrendFrame.pas' {TrendFrame: TFrame},
  uChartInputFrame in '..\..\sharedUtils\компоненты\chart_dpk\chart\forms\frames\uChartInputFrame.pas' {ChartInputFrame: TFrame},
  uChartClickFrListener in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\framelisteners\uChartClickFrListener.pas',
  uObjFrameListener in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\framelisteners\uObjFrameListener.pas',
  uPageFrameListener in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\framelisteners\uPageFrameListener.pas',
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
  uFreqBand in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uFreqBand.pas',
  uAHCorrectionFrm in 'forms\uAHCorrectionFrm.pas' {AHCorrectionFrm},
  uSpmChart in 'forms\uSpmChart.pas' {SpmChart},
  uPolarGraphPage in '..\..\sharedUtils\компоненты\chart_dpk\chart\items\uPolarGraphPage.pas',
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
  Iterative_FFT_sse in '..\..\sharedUtils\math\FFT_койнов\Iterative_FFT_sse.pas',
  uFrmSync in '..\SharedRUnits\uFrmSync.pas' {FrmSync},
  uSyncOscillogram in 'forms\uSyncOscillogram.pas' {SyncOscFrm},
  uSyncOscillogramEditFrm in 'forms\uSyncOscillogramEditFrm.pas' {EditSyncOscFrm},
  uQueue2 in '..\..\sharedUtils\utils\lists\uQueue2.pas';

//{$FPUTYPE SSE}
{$R toolbarExtPack.res}
{$R *.res}

{ -----------------------------------------------Процедура - точка входа в dll }
{ Вызывается при загрузке и выгрузке dll }
procedure DllEntryPoint(Reason: integer);
begin
  case Reason of { Ветвление по коду причины вызова }
    DLL_PROCESS_ATTACH:
    begin

    end;
    DLL_PROCESS_DETACH:
    begin
      // удаление делфевых глобальных классов управления темами форм
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


// ----------------------------Экспортируемые функции}
// {Ниже описаны и реализованы пять функций, которые должна экспортировать}
// библиотека plug-in`а для Recorder`а}
// Получение типа объекта, реализованного в библиотеке}
function GetPluginType: integer; cdecl;
begin
  Result := PLUGIN_CLASS; { В данном случае, это тип объекта plug-in`а }
end;
// Функция создания экземпляра plug-in`а.
// Функция объявлена таким образом, как будто она возвращает не интерфейс,
// а указатель. Причина такого объявления обоснована в документе описания.
function CreatePluginClass: pointer { IRecorderPlugin } ; cdecl;
begin
  GPluginInstance := TExtRecorderPack.Create;
  // Создание одного глобального экземпляра plug-in`а}
  Result := pointer(GPluginInstance);
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // При возврате плагина как поинтера DELPHI не вызывает приращение ссылки!!!!!
  GPluginInstance._AddRef;
end;

// Функция удаления plug-in`а
function DestroyPluginClass(piPlg: IRecorderPlugin): integer; cdecl;
begin
  // Так как объект один и глобальный, то он здесь не удаляется.
  // Объект plug-in`а удаляет себя сам (как любой COM объект),
  // если счетчик ссылок его интерфейсов станет равен нулю.
  GlobDetach;
  Result := RCERROR_NOERROR;
  {$ifdef DEBUG}
  TExtRecorderPack(GPluginInstance).destroyForms;
  TExtRecorderPack(GPluginInstance).destroyLog;

  GPluginInstance._release;
  GPluginInstance := NIL;
  {$endif}
end;

{ Функция получения строки описания plug-in`а }
function GetPluginDescription: LPCSTR; cdecl;
begin
  // Описание извлекается из глобальной описательной структуры}
  Result := LPCSTR(GPluginInfo.Dsc);
  // Result := LPCSTR('Модуль для теста (пустой)');
end;

{ Функция получения полного описания plug-in`а }
procedure GetPluginInfo(var lpPluginInfo: PLUGININFO); cdecl;
begin
  // Описание извлекается из глобальной описательной структуры
  // Копирование строк производится именно функциями StrCopy()
  // из-за того, что структура описания plug-in`а описана
  // в языке C++}
  //ZeroMemory(lpPluginInfo,sizeof(lpPluginInfo));
  StrCopy(@lpPluginInfo.name, LPCSTR(GPluginInfo.Name));
  StrCopy(@lpPluginInfo.describe, LPCSTR(GPluginInfo.Dsc));
  StrCopy(@lpPluginInfo.vendor, LPCSTR(GPluginInfo.vendor));
  lpPluginInfo.version := GPluginInfo.version;
  lpPluginInfo.subversion := GPluginInfo.SubVertion;
end;

{ ---------------------Объявление экспортируемых процедур---------------------- }
// Оъявление строковых имен экспортируемых функций
exports GetPluginType name 'GetPluginType';
exports CreatePluginClass name 'CreatePluginClass';
exports DestroyPluginClass name 'DestroyPluginClass';
exports GetPluginDescription name 'GetPluginDescription';
exports GetPluginInfo name 'GetPluginInfo';

begin
  // Подстановка своей функции DllEntryPoint, таким образом
  // через функцию DllEntryPoint появляется возможность
  // обрабатывать сообщения о выгрузке библиотеки
  if not Assigned(DLLProc) then
    DLLProc := @DllEntryPoint;
  DllEntryPoint(DLL_PROCESS_ATTACH);

end.
