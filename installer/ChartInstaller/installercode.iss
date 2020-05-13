
[Setup]
AppName=BlEng
AppVerName=BlEng 0.5
DefaultDirName={pf}\Mera\BladeEngine
DefaultGroupName=Mera
UninstallDisplayIcon={app}\BlEng.exe
OutputDir=output

[Types]
Name: "Chart"; Description: "Полная установка"

[Components]
Name: "program"; Description: "Файлы проекта cChart"; Types: Chart; Flags: fixed

[Files]
Source: "..\..\sharedUtils\компоненты\chart_dpk\uRegisterComponent.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\ComponentsLib.bdsproj"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\ComponentsLib.cfg"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\ComponentsLib.dpk"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\ComponentsLib.drc"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\ComponentsLib.identcache"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\ComponentsLib.res"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\ComponentsLib.bdsproj.local"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\ComponentsLib.dproj.local"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\ComponentsLib.dproj"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\uChart.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\utils\uText.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\utils\uText.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\utils\lists\uChartEvents.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uAxis.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uChartCursor.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uDoubleCursor.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uDrawObj.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uDrawObjMng.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uGistogram.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uLegend.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uMarkers.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\upage.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uPageMng.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uPoint.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uTabObj.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uTextLabel.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\uTrend.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\framelisteners\uChartClickFrListener.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\framelisteners\uObjFrameListener.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\items\framelisteners\uPageFrameListener.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uChartCfgForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uChartCfgForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCreateObjForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCreateObjForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCreateTrendFrame.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCreateTrendFrame.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCursorForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uCursorForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uDoubleCursorForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uDoubleCursorForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uDrawObjEditForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uDrawObjEditForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uDrawObjFrame.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uDrawObjFrame.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uEditChartObjFrame.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uEditChartObjFrame.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uEditMenuChartForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uEditMenuChartForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uGistForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uGistForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uGistFrame.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uGistFrame.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uPageForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uPageForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uTextLabelForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uTextLabelForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uTrendForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uTrendForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uTrendFrame.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\uTrendFrame.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\frames\uChartInputFrame.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\chart_dpk\chart\forms\frames\uChartInputFrame.dfm"; DestDir: "{app}"; Components: program

Source: "..\..\sharedUtils\компоненты\dcl_dpk\Spin.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\dcl_dpk\uAlignEdit.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\dcl_dpk\ubtnlistview.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\компоненты\dcl_dpk\uSpin.pas"; DestDir: "{app}"; Components: program

Source: "..\..\sharedUtils\uCommonTypes.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\objects\uBaseObj.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\objects\uBaseObjInt.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\objects\uBaseObjMng.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\objects\uBaseObjService.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\objects\uBaseObjStr.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\math\MathFunction.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\math\u2DMath.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\math\uCommonMath.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\math\uListMath.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\math\uMatrix.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\math\uMyMath.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\forms\uGetMngObjForm.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\forms\uGetMngObjForm.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\forms\ulogFrame.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\forms\ulogFrame.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\forms\uProgressDlg.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\forms\uProgressDlg.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\forms\uSystemInfoFrame.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\forms\uSystemInfoFrame.dfm"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\ogl\dglOpenGL.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\ogl\uOglExpFunc.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\ogl\uSimpleObjects.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\uComponentServises.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\uCursors.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\uDescObj.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\ufileMng.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\uFrameListener.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\uLogFile.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\uPathMng.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\lists\ueventlist.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\lists\uEventTypes.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\lists\uRegClassesList.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\lists\usetlist.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\lists\uSimpleSetList.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\lists\uvectorlist.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\PathUtils\PathUtils.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\platform\adCpuUsage.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\platform\uPlatformInfo.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\xml\NativeXml.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\xml\NativeXml.inc"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\xml\NativeXmlAppend.pas"; DestDir: "{app}"; Components: program
Source: "..\..\sharedUtils\utils\xml\NativeXmlObjectStorage.pas"; DestDir: "{app}"; Components: program








