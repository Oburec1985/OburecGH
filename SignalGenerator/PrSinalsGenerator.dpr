program PrSinalsGenerator;

uses
  Forms,
  SignalsGenerator in 'SignalsGenerator.pas' {GeneratorForm},
  uSinFrame in 'frames\uSinFrame.pas' {SinFrame: TFrame},
  uBaseObj in '..\sharedUtils\objects\uBaseObj.pas',
  uBaseObjMng in '..\sharedUtils\objects\uBaseObjMng.pas',
  uBaseObjService in '..\sharedUtils\objects\uBaseObjService.pas',
  uDescObj in '..\sharedUtils\utils\uDescObj.pas',
  uFrameListener in '..\sharedUtils\utils\uFrameListener.pas',
  uEventList in '..\sharedUtils\utils\lists\uEventList.pas',
  uEventTypes in '..\sharedUtils\utils\lists\uEventTypes.pas',
  uRegClassesList in '..\sharedUtils\utils\lists\uRegClassesList.pas',
  usetlist in '..\sharedUtils\utils\lists\usetlist.pas',
  uSimpleSetList in '..\sharedUtils\utils\lists\uSimpleSetList.pas',
  uvectorlist in '..\sharedUtils\utils\lists\uvectorlist.pas',
  uSpin in '..\sharedUtils\компоненты\dcl_dpk\uSpin.pas',
  DCL_MYOWN in '..\sharedUtils\компоненты\dcl_dpk\DCL_MYOWN.pas',
  Spin in '..\sharedUtils\компоненты\dcl_dpk\Spin.pas',
  uAlignEdit in '..\sharedUtils\компоненты\dcl_dpk\uAlignEdit.pas',
  ubtnlistview in '..\sharedUtils\компоненты\dcl_dpk\ubtnlistview.pas',
  uChart in '..\sharedUtils\компоненты\chart_dpk\chart\uChart.pas',
  uAxis in '..\sharedUtils\компоненты\chart_dpk\chart\items\uAxis.pas',
  uChartCursor in '..\sharedUtils\компоненты\chart_dpk\chart\items\uChartCursor.pas',
  uDoubleCursor in '..\sharedUtils\компоненты\chart_dpk\chart\items\uDoubleCursor.pas',
  uDrawObj in '..\sharedUtils\компоненты\chart_dpk\chart\items\uDrawObj.pas',
  uDrawObjMng in '..\sharedUtils\компоненты\chart_dpk\chart\items\uDrawObjMng.pas',
  uGistogram in '..\sharedUtils\компоненты\chart_dpk\chart\items\uGistogram.pas',
  uLegend in '..\sharedUtils\компоненты\chart_dpk\chart\items\uLegend.pas',
  uMarkers in '..\sharedUtils\компоненты\chart_dpk\chart\items\uMarkers.pas',
  upage in '..\sharedUtils\компоненты\chart_dpk\chart\items\upage.pas',
  uPageMng in '..\sharedUtils\компоненты\chart_dpk\chart\items\uPageMng.pas',
  uPoint in '..\sharedUtils\компоненты\chart_dpk\chart\items\uPoint.pas',
  uTabObj in '..\sharedUtils\компоненты\chart_dpk\chart\items\uTabObj.pas',
  uTextLabel in '..\sharedUtils\компоненты\chart_dpk\chart\items\uTextLabel.pas',
  uTrend in '..\sharedUtils\компоненты\chart_dpk\chart\items\uTrend.pas',
  uCommonTypes in '..\sharedUtils\uCommonTypes.pas',
  uText in '..\sharedUtils\компоненты\chart_dpk\chart\utils\uText.pas',
  uChartEvents in '..\sharedUtils\компоненты\chart_dpk\chart\utils\lists\uChartEvents.pas',
  uSystemInfoFrame in '..\sharedUtils\forms\uSystemInfoFrame.pas' {SystemInfoFrame: TFrame},
  uGetMngObjForm in '..\sharedUtils\forms\uGetMngObjForm.pas' {GetMngObjForm},
  ulogFrame in '..\sharedUtils\forms\ulogFrame.pas' {LogFrame: TFrame},
  uProgressDlg in '..\sharedUtils\forms\uProgressDlg.pas' {ProgresDlg},
  MathFunction in '..\sharedUtils\math\MathFunction.pas',
  u2DMath in '..\sharedUtils\math\u2DMath.pas',
  uCommonMath in '..\sharedUtils\math\uCommonMath.pas',
  uListMath in '..\sharedUtils\math\uListMath.pas',
  uMatrix in '..\sharedUtils\math\uMatrix.pas',
  uMyMath in '..\sharedUtils\math\uMyMath.pas',
  uObjXML in '..\sharedUtils\objects\utils\uObjXML.pas',
  uChartClickFrListener in '..\sharedUtils\компоненты\chart_dpk\chart\items\framelisteners\uChartClickFrListener.pas',
  uObjFrameListener in '..\sharedUtils\компоненты\chart_dpk\chart\items\framelisteners\uObjFrameListener.pas',
  uPageFrameListener in '..\sharedUtils\компоненты\chart_dpk\chart\items\framelisteners\uPageFrameListener.pas',
  uSimpleObjects in '..\sharedUtils\ogl\uSimpleObjects.pas',
  dglOpenGL in '..\sharedUtils\ogl\dglOpenGL.pas',
  uOglExpFunc in '..\sharedUtils\ogl\uOglExpFunc.pas',
  uChartInputFrame in '..\sharedUtils\компоненты\chart_dpk\chart\forms\frames\uChartInputFrame.pas' {ChartInputFrame: TFrame},
  uChartCfgForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uChartCfgForm.pas' {ChartCfgForm},
  uCreateObjForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uCreateObjForm.pas' {CreateObjForm},
  uCreateTrendFrame in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uCreateTrendFrame.pas' {EditChartCfgFrame: TFrame},
  uCursorForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uCursorForm.pas' {CursorForm},
  uDoubleCursorForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uDoubleCursorForm.pas' {DoubleCursorForm},
  uDrawObjEditForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uDrawObjEditForm.pas' {DrawObjEditForm},
  uDrawObjFrame in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uDrawObjFrame.pas' {DrawObjFrame: TFrame},
  uEditChartObjFrame in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uEditChartObjFrame.pas' {EditDrawObjFrame: TFrame},
  uEditMenuChartForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uEditMenuChartForm.pas' {EditMenuChartForm},
  uGistForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uGistForm.pas' {GistForm},
  uGistFrame in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uGistFrame.pas' {GistFrame: TFrame},
  uPageForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uPageForm.pas' {PageForm},
  uTextLabelForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uTextLabelForm.pas' {TextLabelForm},
  uTrendForm in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uTrendForm.pas' {TrendForm},
  uTrendFrame in '..\sharedUtils\компоненты\chart_dpk\chart\forms\uTrendFrame.pas' {TrendFrame: TFrame},
  uObjDb in '..\sharedUtils\utils\PathUtils\uObjDb.pas',
  PathUtils in '..\sharedUtils\utils\PathUtils\PathUtils.pas',
  UDirChangeNotifier in '..\sharedUtils\utils\PathUtils\UDirChangeNotifier.pas',
  uPlatformInfo in '..\sharedUtils\utils\platform\uPlatformInfo.pas',
  adCpuUsage in '..\sharedUtils\utils\platform\adCpuUsage.pas' {/,},
  uLoadSignalForm in 'Forms\uLoadSignalForm.pas' {LoadSignalForm},
  uSrsForm in 'Forms\uSrsForm.pas' {SRSForm},
  ufileMng in '..\sharedUtils\utils\ufileMng.pas',
  uSaveSignalForm in 'Forms\uSaveSignalForm.pas' {SaveSignalForm},
  uShockFrame in 'frames\uShockFrame.pas' {ShockFrame: TFrame},
  uMeraFile in '..\sharedUtils\mera\uMeraFile.pas',
  uTagUtils in '..\sharedUtils\objects\utils\uTagUtils.pas',
  umeraSignal in '..\sharedUtils\mera\umeraSignal.pas',
  uBuffSignal in '..\sharedUtils\mera\uBuffSignal.pas',
  uPageSRS in 'algs\uPageSRS.pas',
  uSRS in 'algs\uSRS.pas',
  uKoltSRS in 'algs\uKoltSRS.pas',
  FreeFrmSignal in 'frames\FreeFrmSignal.pas' {FreeFrmSignalFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGeneratorForm, GeneratorForm);
  Application.CreateForm(TProgresDlg, ProgresDlg);
  Application.CreateForm(TChartCfgForm, ChartCfgForm);
  Application.CreateForm(TCreateObjForm, CreateObjForm);
  Application.CreateForm(TCursorForm, CursorForm);
  Application.CreateForm(TDoubleCursorForm, DoubleCursorForm);
  Application.CreateForm(TDrawObjEditForm, DrawObjEditForm);
  Application.CreateForm(TEditMenuChartForm, EditMenuChartForm);
  Application.CreateForm(TGistForm, GistForm);
  Application.CreateForm(TPageForm, PageForm);
  Application.CreateForm(TTextLabelForm, TextLabelForm);
  Application.CreateForm(TTrendForm, TrendForm);
  Application.CreateForm(TLoadSignalForm, LoadSignalForm);
  Application.CreateForm(TSRSForm, SRSForm);
  Application.CreateForm(TSaveSignalForm, SaveSignalForm);
  Application.Run;
end.
