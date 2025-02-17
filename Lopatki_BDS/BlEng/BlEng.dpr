program BlEng;

uses
  FastMM4,
  sysutils,
  Forms,
  MainForm in 'Forms\MainForm.pas' {MainBldForm},
  uEventTypes in '..\..\sharedUtils\utils\lists\uEventTypes.pas',
  uStage in 'BldStruct\uStage.pas',
  uTurbina in 'BldStruct\uTurbina.pas',
  uBldObj in 'BldStruct\uBldObj.pas',
  uPair in 'BldStruct\uPair.pas',
  uSensor in 'BldStruct\uSensor.pas',
  uBldEng in 'BldStruct\uBldEng.pas',
  uBlade in 'BldStruct\uBlade.pas',
  uBaseObjPropertyFrame in 'Forms\frames\uBaseObjPropertyFrame.pas' {BaseObjPropertyFrame: TFrame},
  uStageFrame in 'Forms\frames\uStageFrame.pas' {StageFrame: TFrame},
  uCreateObjDlg in 'Forms\uCreateObjDlg.pas' {CreateObjDlg},
  uTurbineFrame in 'Forms\frames\uTurbineFrame.pas' {TurbineFrame: TFrame},
  uPairFrame in 'Forms\frames\uPairFrame.pas' {PairFrame: TFrame},
  uSensorFrame in 'Forms\frames\uSensorFrame.pas' {SensorFrame: TFrame},
  uBldCompProc in 'uBld\uBldCompProc.pas',
  uTickData in 'BldStruct\ticks\uTickData.pas',
  uBaseObjService in '..\..\sharedUtils\objects\uBaseObjService.pas',
  uBaseObjTypes in 'BldStruct\uBaseObjTypes.pas',
  uBlInterfaceFrame in 'Forms\frames\uBlInterfaceFrame.pas' {ObjInterfaceFrame: TFrame},
  uCompaundFrame in 'Forms\frames\uCompaundFrame.pas' {CompaundFrame: TFrame},
  uCfgForm in 'Forms\uCfgForm.pas' {CfgForm},
  uLfmFile in 'uBld\FileFormats\uLfmFile.pas',
  uBinFile in '..\..\sharedUtils\uBinFile.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  uBaseObj in '..\..\sharedUtils\objects\uBaseObj.pas',
  uMyMath in '..\..\sharedUtils\math\uMyMath.pas',
  u2DMath in '..\..\sharedUtils\math\u2DMath.pas',
  uCommonMath in '..\..\sharedUtils\math\uCommonMath.pas',
  uListMath in '..\..\sharedUtils\math\uListMath.pas',
  uFrameListener in '..\..\sharedUtils\utils\uFrameListener.pas',
  uEventList in '..\..\sharedUtils\utils\lists\uEventList.pas',
  uChan in 'BldStruct\uChan.pas',
  uvectorlist in '..\..\sharedUtils\utils\lists\uvectorlist.pas',
  uFrameEvents in 'Forms\frames\uFrameEvents.pas',
  uLoadBldForm in 'Forms\FilesDlg\uLoadBldForm.pas' {LoadBldDlg},
  uBldMath in 'uBld\uBldMath.pas',
  uSimpleSetList in '..\..\sharedUtils\utils\lists\uSimpleSetList.pas',
  uErrorProc in 'uBld\uErrorProc.pas',
  uSystemInfoFrame in '..\..\sharedUtils\forms\uSystemInfoFrame.pas' {SystemInfoFrame: TFrame},
  uPlatformInfo in '..\..\sharedUtils\utils\platform\uPlatformInfo.pas',
  adCpuUsage in '..\..\sharedUtils\utils\platform\adCpuUsage.pas',
  uEditListFrame in 'Forms\frames\uEditListFrame.pas' {EditEngListFrame: TFrame},
  uChanFrame in 'Forms\frames\uChanFrame.pas' {ChanFrame: TFrame},
  uGenBldForm in 'Forms\uGenBldForm.pas' {GeneratorForm},
  uSelAlgFrame in 'Forms\frames\uSelAlgFrame.pas' {SelectAlgFrame: TFrame},
  uSelectAlgDlg in 'Forms\uSelectAlgDlg.pas' {SelAlgDlg},
  uGlTurbineFrame in 'Forms\frames\uGlTurbineFrame.pas' {glTurbineFrame: TFrame},
  uGetEngObjForm in 'Forms\uGetEngObjForm.pas' {GetEngObjForm},
  ufileMng in '..\..\sharedUtils\utils\ufileMng.pas',
  uBldTypes in 'uBld\uBldTypes.pas',
  uBldFile in 'uBld\FileFormats\uBldFile.pas',
  uBaseBldAlg in 'uBld\algoritms\uBaseBldAlg.pas',
  uShapeAlg in 'uBld\algoritms\uShapeAlg.pas',
  uDensityAlg in 'uBld\algoritms\uDensityAlg.pas',
  uTrendAlg in 'uBld\algoritms\uTrendAlg.pas',
  uXYTrendPos in 'Forms\Algoritms\uXYTrendPos.pas' {XYTrendForm},
  uRestoreVibrationAlg in 'uBld\algoritms\uRestoreVibrationAlg.pas',
  uSensorRep in 'uBld\algoritms\uSensorRep.pas',
  uPathMng in '..\..\sharedUtils\utils\uPathMng.pas',
  PathUtils in '..\..\sharedUtils\utils\PathUtils\PathUtils.pas',
  uBldPathMng in 'BldStruct\uBldPathMng.pas',
  uProgressDlg in '..\..\sharedUtils\forms\uProgressDlg.pas' {ProgresDlg},
  uChart in '..\..\sharedUtils\����������\chart_dpk\chart\uChart.pas',
  uAxis in '..\..\sharedUtils\����������\chart_dpk\chart\items\uAxis.pas',
  uDrawObj in '..\..\sharedUtils\����������\chart_dpk\chart\items\uDrawObj.pas',
  uMarkers in '..\..\sharedUtils\����������\chart_dpk\chart\items\uMarkers.pas',
  upage in '..\..\sharedUtils\����������\chart_dpk\chart\items\upage.pas',
  uPoint in '..\..\sharedUtils\����������\chart_dpk\chart\items\uPoint.pas',
  uTrend in '..\..\sharedUtils\����������\chart_dpk\chart\items\uTrend.pas',
  CommonOptsFrame in 'Forms\Algoritms\CommonOptsFrame.pas' {BaseAlgOptsFrame: TFrame},
  uStageShapeForm in 'Forms\Algoritms\uStageShapeForm.pas' {StageShapeForm},
  uMultiSensorForm in 'Forms\Algoritms\uMultiSensorForm.pas' {MultiSensorForm},
  uStageReConfig in 'Forms\Algoritms\uStageReConfig.pas' {StageReConfigForm},
  uRestoreAlgForm in 'Forms\Algoritms\uRestoreAlgForm.pas' {RestoreAlgForm},
  uSensorList in 'BldStruct\uSensorList.pas',
  uBldObjList in 'BldStruct\uBldObjList.pas',
  uMultiSensor in 'uBld\algoritms\uMultiSensor.pas',
  uSensorRepForm in 'Forms\Algoritms\uSensorRepForm.pas' {SensorRepForm},
  uPairTrend in 'uBld\algoritms\uPairTrend.pas',
  uPairShapeForm in 'Forms\Algoritms\uPairShapeForm.pas' {PairShapeForm},
  uSetList in '..\..\sharedUtils\utils\lists\uSetList.pas',
  uCreateTrendForm in 'Forms\uCreateTrendForm.pas' {SelGraphForm},
  MathFunction in '..\..\sharedUtils\math\MathFunction.pas',
  uLogFile in '..\..\sharedUtils\utils\uLogFile.pas',
  uMeraFile in '..\..\sharedUtils\mera\uMeraFile.pas',
  uSignalsTVFrame in 'Forms\frames\uSignalsTVFrame.pas' {SignalsTVFrame: TFrame},
  uSaveSignalForm in 'Forms\uSaveSignalForm.pas' {SaveSignalsForm},
  uEvalFirstBladeOffset in 'uBld\algoritms\uEvalFirstBladeOffset.pas',
  uBaseAlgForm in 'Forms\Algoritms\uBaseAlgForm.pas' {BaseAlgForm},
  uGetSkipBladesForm in 'Forms\uGetSkipBladesForm.pas' {GetSkipBladesForm},
  uGetSkipBladesAlg in 'uBld\algoritms\uGetSkipBladesAlg.pas',
  uComponentServises in '..\..\sharedUtils\utils\uComponentServises.pas',
  uObjFrameListener in '..\..\sharedUtils\����������\chart_dpk\chart\items\framelisteners\uObjFrameListener.pas',
  uBladeEditFrame in 'Forms\frames\uBladeEditFrame.pas' {BladePosFrame: TFrame},
  uBladeForm in 'Forms\uBladeForm.pas' {BladeForm},
  uEvalSkipBladesForm in 'Forms\Algoritms\uEvalSkipBladesForm.pas' {EvalSkipBladesForm},
  uSaveEng in 'helptools\uSaveEng.pas',
  uProgramForm in 'Forms\uProgramForm.pas' {EditProjForm},
  uBldTimeProc in 'BldStruct\uBldTimeProc.pas',
  uBldTimeProcForm in 'Forms\uBldTimeProcForm.pas' {BldTimeProcForm},
  uAlgEditFrame in 'Forms\frames\uAlgEditFrame.pas' {AlgEditFrame: TFrame},
  uPairShapeFrame in 'Forms\Algoritms\uPairShapeFrame.pas' {pairShapeFrame: TFrame},
  uGetSensorsForm in 'Forms\uGetSensorsForm.pas' {SelectSensorsForm},
  uAlgorithms in 'uBld\algoritms\uAlgorithms.pas',
  uEvalTahoAlg in 'uBld\algoritms\uEvalTahoAlg.pas',
  ulogFrame in '..\..\sharedUtils\forms\ulogFrame.pas' {LogFrame: TFrame},
  uJournalForm in '..\..\sharedUtils\forms\uJournalForm.pas' {JournalForm},
  uBaseObjMng in '..\..\sharedUtils\objects\uBaseObjMng.pas',
  uBldEngEventTypes in 'helptools\uBldEngEventTypes.pas',
  uTagsCfgFrame in 'Forms\Tags\uTagsCfgFrame.pas' {TagsCfgFrame: TFrame},
  uTagPropertiesFrame in 'Forms\Tags\uTagPropertiesFrame.pas' {TagPropertiesFrame: TFrame},
  uTag in '..\..\sharedUtils\objects\uTag.pas',
  uTagUtils in 'uBld\uTagUtils.pas',
  uAlgTagListFrame in 'Forms\frames\uAlgTagListFrame.pas' {AlgTagListFrame: TFrame},
  uCreateObjForm in '..\..\sharedUtils\����������\chart_dpk\chart\forms\uCreateObjForm.pas' {TCreateObjForm: TCreateObjForm},
  uEditTagForm in 'Forms\Tags\uEditTagForm.pas' {EditTagForm},
  uChartInputFrame in '..\..\sharedUtils\����������\chart_dpk\chart\forms\frames\uChartInputFrame.pas' {ChartInputFrame: TFrame},
  uChartFrame in 'Forms\frames\uChartFrame.pas' {ChartFrame: TFrame},
  uAlarms in 'BldStruct\uAlarms.pas',
  uAlarmEditFrame in 'Forms\frames\uAlarmEditFrame.pas' {EditAlarmFrame: TFrame},
  uEditAlarmForm in 'Forms\uEditAlarmForm.pas' {EditAlarmForm},
  uAlarmsHistoryForm in 'Forms\DataBase\uAlarmsHistoryForm.pas' {AlarmsHistoryBase},
  uHistoryMng in 'BldStruct\uHistoryMng.pas',
  uProcessAlgTask in 'BldStruct\tasks\uProcessAlgTask.pas',
  NativeXmlObjectStorage in '..\..\sharedUtils\utils\xml\NativeXmlObjectStorage.pas',
  NativeXml in '..\..\sharedUtils\utils\xml\NativeXml.pas',
  uObjXML in '..\..\sharedUtils\objects\utils\uObjXML.pas',
  uRegClassesList in '..\..\sharedUtils\utils\lists\uRegClassesList.pas',
  uXMLFile in 'uBld\FileFormats\uXMLFile.pas',
  uTaskMng in 'BldStruct\tasks\uTaskMng.pas',
  uAlgMng in 'BldStruct\uAlgMng.pas',
  uTaskFrame in 'Forms\frames\uTaskFrame.pas' {TaskFrame: TFrame},
  uGetMngObjForm in '..\..\sharedUtils\forms\uGetMngObjForm.pas' {GetMngObjForm},
  uBladeTicksFile in 'uBld\FileFormats\uBladeTicksFile.pas',
  uTicks in 'BldStruct\ticks\uTicks.pas',
  uArrayTicks in 'BldStruct\ticks\uArrayTicks.pas',
  UDirChangeNotifier in '..\..\sharedUtils\utils\PathUtils\UDirChangeNotifier.pas',
  uEgineMonitorForm in 'Forms\uEgineMonitorForm.pas' {EngineMonitorForm},
  uObjDb in '..\..\sharedUtils\utils\PathUtils\uObjDb.pas',
  uDensityForm in 'Forms\Algoritms\uDensityForm.pas' {DensityForm},
  uTagSignal in '..\..\sharedUtils\objects\uTagSignal.pas',
  umeraSignal in '..\..\sharedUtils\mera\umeraSignal.pas',
  uTrendSignal in '..\..\sharedUtils\����������\chart_dpk\chart\items\uTrendSignal.pas',
  uPairShape in 'uBld\algoritms\uPairShape.pas',
  uPairTrendForm in 'Forms\Algoritms\uPairTrendForm.pas' {PairTrendForm},
  uGetTimeForm in 'Forms\FilesDlg\uGetTimeForm.pas' {GetTimeForm},
  universal_time in '..\..\sharedUtils\mera\uts\universal_time.pas',
  uUTSSensor in 'BldStruct\uUTSSensor.pas',
  uUTSFrame in 'Forms\frames\uUTSFrame.pas' {UTSFrame: TFrame},
  uGlobalStrings in '..\..\sharedUtils\utils\uGlobalStrings.pas',
  uPairRestore in 'uBld\algoritms\uPairRestore.pas',
  uPairRestoreForm in 'Forms\Algoritms\uPairRestoreForm.pas' {PairRestoreForm},
  uMetaData in '..\..\sharedUtils\objects\uMetaData.pas',
  uAddPropertieForm in '..\..\sharedUtils\forms\uAddPropertieForm.pas' {AddPropertieForm},
  uHardwareCFGForm in 'Forms\uHardwareCFGForm.pas' {HardwareCFGForm},
  MxxxxTypes in 'helptools\Hardware\MxxxxTypes.pas',
  MxxxxAPI in 'helptools\Hardware\MxxxxAPI.pas',
  Types4bld in 'helptools\Hardware\Types4bld.pas',
  uPlatFrame in 'Forms\frames\uPlatFrame.pas' {Platframe: TFrame},
  uPlat in 'helptools\Hardware\uPlat.pas',
  u2081 in 'helptools\Hardware\u2081.pas',
  u2070 in 'helptools\Hardware\u2070.pas',
  uTagOwnerObj in 'BldStruct\uTagOwnerObj.pas',
  uEditGraphForm in 'Forms\uEditGraphForm.pas' {EditPraphForm},
  uMatrix in '..\..\sharedUtils\math\uMatrix.pas',
  uBldGlobalStrings in 'uBld\uBldGlobalStrings.pas',
  uMeasureTest in 'uBld\algoritms\uMeasureTest.pas',
  uSignalsUtils in '..\..\sharedUtils\mera\uSignalsUtils.pas',
  uBuffSignal in '..\..\sharedUtils\mera\uBuffSignal.pas',
  uDataThread in 'BldStruct\uDataThread.pas',
  uFileThread in 'BldStruct\uFileThread.pas',
  uDBForm in '..\..\sharedUtils\forms\uDBForm.pas' {DBForm},
  uDBase in '..\..\sharedUtils\utils\uDBase.pas',
  uBladeBase in 'Forms\DataBase\uBladeBase.pas' {BladeFrm},
  ME415 in 'Forms\ME415.pas' {Form2},
  sdDebug in '..\..\sharedUtils\utils\xml\sdDebug.pas',
  uMNode in '..\..\3d\objects\uMNode.pas',
  uNode in '..\..\3d\objects\uNode.pas',
  uquat in '..\..\3d\math\uquat.pas',
  uConfigFile3d in '..\..\3d\tools\uConfigFile3d.pas',
  RepODS in '..\..\sharedUtils\utils\reports\RepODS.pas',
  RepODT in '..\..\sharedUtils\utils\reports\RepODT.pas',
  uObaFile in '..\..\3d\objects\uObaFile.pas';

{$R *.res}

begin
  Application.Initialize;
  LoadStrings(extractfiledir(application.exename)+'\files\CfgFiles\Services.Ini');
  InitGlobalStrings;
  //CreateObjForm:=TCreateObjForm.Create(nil);
  Application.CreateForm(TMainBldForm, MainBldForm);
  Application.CreateForm(TCreateObjDlg, CreateObjDlg);
  Application.CreateForm(TCfgForm, CfgForm);
  Application.CreateForm(TLoadBldDlg, LoadBldDlg);
  Application.CreateForm(TGeneratorForm, GeneratorForm);
  Application.CreateForm(TSelAlgDlg, SelAlgDlg);
  Application.CreateForm(TXYTrendForm, XYTrendForm);
  Application.CreateForm(TStageShapeForm, StageShapeForm);
  Application.CreateForm(TStageReConfigForm, StageReConfigForm);
  Application.CreateForm(TSensorRepForm, SensorRepForm);
  Application.CreateForm(TPairShapeForm, PairShapeForm);
  Application.CreateForm(TSelGraphForm, SelGraphForm);
  Application.CreateForm(TSaveSignalsForm, SaveSignalsForm);
  Application.CreateForm(TBaseAlgForm, BaseAlgForm);
  Application.CreateForm(TGetSkipBladesForm, GetSkipBladesForm);
  Application.CreateForm(TBladeForm, BladeForm);
  Application.CreateForm(TEvalSkipBladesForm, EvalSkipBladesForm);
  Application.CreateForm(TEditProjForm, EditProjForm);
  Application.CreateForm(TBldTimeProcForm, BldTimeProcForm);
  Application.CreateForm(TSelectSensorsForm, SelectSensorsForm);
  Application.CreateForm(TJournalForm, JournalForm);
  Application.CreateForm(TCreateObjForm, CreateObjForm);
  Application.CreateForm(TEditTagForm, EditTagForm);
  Application.CreateForm(TEditAlarmForm, EditAlarmForm);
  Application.CreateForm(TEngineMonitorForm, EngineMonitorForm);
  Application.CreateForm(TDensityForm, DensityForm);
  Application.CreateForm(TForm2, Form2);
  // ������ �������� ����� �� TLabel???????
  //Application.CreateForm(TPairTrendForm, PairTrendForm);
  Application.CreateForm(TGetTimeForm, GetTimeForm);
  Application.CreateForm(TPairRestoreForm, PairRestoreForm);
  Application.CreateForm(TAddPropertieForm, AddPropertieForm);
  Application.CreateForm(THardwareCFGForm, HardwareCFGForm);
  Application.CreateForm(TEditGraphForm, EditGraphForm);
  Application.CreateForm(TDBForm, DBForm);
  Application.CreateForm(TBladeFrm, BladeFrm);
  //Application.CreateForm(TAlarmsHistoryBase, AlarmsHistoryBase);
  Application.Run;
end.
