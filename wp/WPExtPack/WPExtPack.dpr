library WPExtPack;

uses
  ComServ,
  SysUtils,
  Classes,
  dialogs,
  consts,
  windows,
  registry,
  WPExtPack_TLB in 'WPExtPack_TLB.pas',
  uWpExtPack in 'units\uWpExtPack.pas' {ExtPack: CoClass},
  POSBase in '..\SharedWP\POSBase.pas',
  uWPproc in 'units\uWPproc.pas',
  uWPProcServices in 'units\uWPProcServices.pas',
  uWPProcFrm in 'forms\uWPProcFrm.pas' {FxForm},
  Winpos_ole_TLB in '..\SharedWP\Winpos_ole_TLB.pas',
  uFindMaxOper in 'units\uFindMaxOper.pas' {ExtOperAmpFind: CoClass},
  uNIIPMTenzopluginForm in 'forms\uNIIPMTenzopluginForm.pas' {NIIPMForm},
  uFindMaxForm in 'forms\uFindMaxForm.pas' {FindMaxForm},
  uGlobalStrings in '..\..\sharedUtils\utils\uGlobalStrings.pas',
  ubtnlistview in '..\..\sharedUtils\компоненты\dcl_dpk\ubtnlistview.pas',
  uGenForm in 'forms\uGenForm.pas' {GenFrm},
  uSignalsUtils in '..\..\sharedUtils\mera\uSignalsUtils.pas',
  ubuffsignal in '..\..\sharedUtils\mera\ubuffsignal.pas',
  uMeraFile in '..\..\sharedUtils\mera\uMeraFile.pas',
  umeraSignal in '..\..\sharedUtils\mera\umeraSignal.pas',
  uSelectPathForm in 'forms\uSelectPathForm.pas' {SelectPathFrm},
  uVTServices in '..\..\sharedUtils\utils\uVTServices.pas',
  uCorrectUTS in 'forms\uCorrectUTS.pas' {CorrectUTSFrm},
  EditSignalPathFrm in 'forms\EditSignalPathFrm.pas' {SignalPathFrm},
  uSelectIntervalFrm in 'forms\uSelectIntervalFrm.pas' {SelectIntervalFrm},
  uGraphMngFrm in 'forms\uGraphMngFrm.pas' {GraphFrm},
  uAddSignalFrm in 'forms\uAddSignalFrm.pas' {EditSignalsListFrm},
  UWPEvents in 'units\UWPEvents.pas',
  uWPExtOperRpt in 'units\uWPExtOperRpt.pas',
  uRptFrm in 'forms\uRptFrm.pas' {RptFrm},
  uCommonMath in '..\..\sharedUtils\math\uCommonMath.pas',
  u2DMath in '..\..\sharedUtils\math\u2DMath.pas',
  uScriptFrm in 'forms\uScriptFrm.pas' {ScriptFrm},
  VBScript_RegExp_55_TLB in '..\..\sharedUtils\utils\scripts\VBScript_RegExp_55_TLB.pas',
  uComponentServises in '..\..\sharedUtils\utils\uComponentServises.pas',
  uAddScriptItemFrm in 'forms\uAddScriptItemFrm.pas' {AddScriptItemFrm},
  uExcel in '..\..\sharedUtils\utils\reports\excel\uExcel.pas',
  uWord in '..\..\sharedUtils\utils\reports\msWord\uWord.pas',
  ulogFrame in '..\..\sharedUtils\forms\ulogFrame.pas' {LogFrame: TFrame},
  uJournalForm in '..\..\sharedUtils\forms\uJournalForm.pas' {JournalForm},
  uCyclogramRepFrm in 'forms\uCyclogramRepFrm.pas' {CyclogramRepFrm},
  uTrigLvlEditFrm in 'forms\uTrigLvlEditFrm.pas' {TrigLvlFrm},
  uBDIFrm in 'forms\uBDIFrm.pas' {BDIFrm},
  uKBHMFrm in 'forms\uKBHMFrm.pas' {KBHMFrm},
  uSelsinFrm in 'forms\uSelsinFrm.pas' {SelsinFrm},
  uEditSelsinFrm in 'forms\uEditSelsinFrm.pas' {EditSelsinFrm},
  uTrigsFrm in 'forms\uTrigsFrm.pas' {TrigsFrm},
  uNode in '..\..\3d\objects\uNode.pas',
  uBasicNode in '..\..\sharedUtils\objects\uBasicNode.pas',
  MSScriptControl_TLB in '..\..\sharedUtils\utils\scripts\MSScriptControl_TLB.pas',
  uSpmFrm in 'forms\uSpmFrm.pas' {SpmFrm},
  uWPSpmFrame in 'forms\frames\uWPSpmFrame.pas' {WPSpmFrame: TFrame},
  uBaseObj in '..\..\sharedUtils\objects\uBaseObj.pas',
  uWPExtOperHilbFilter in 'units\uWPExtOperHilbFilter.pas' {ExtOperHilbertFlt: CoClass},
  uFrmHibFltFrm in 'forms\uFrmHibFltFrm.pas' {HilbFltFrm},
  uWPOpers in 'units\uWPOpers.pas',
  uIntervalFrm in 'forms\uIntervalFrm.pas' {IntervalFrm},
  uIntervalFrame in 'forms\frames\uIntervalFrame.pas' {IntervalFrame: TFrame},
  uTmpltNameFrame in 'forms\frames\uTmpltNameFrame.pas' {TmpltNameFrame: TFrame},
  uIEPlgClass in 'units\uIEPlgClass.pas' {IEMeraPlg: CoClass},
  uWPNameFilterFrame in 'forms\frames\uWPNameFilterFrame.pas' {WPNameFltFrame: TFrame},
  uSaveSimpleMeraFrm in 'forms\uSaveSimpleMeraFrm.pas' {SaveSimpleMeraFrm},
  uRzdFrm in 'forms\uRzdFrm.pas' {RZDFrm},
  uRZDTareFrame in 'forms\frames\uRZDTareFrame.pas' {RZDTareFrame: TFrame},
  uMNK in '..\..\sharedUtils\math\uMNK.pas',
  uWPExtOperMNK in 'units\uWPExtOperMNK.pas',
  uMNKFrm in 'forms\uMNKFrm.pas' {MNKFrm},
  uExtOperMng in 'units\uExtOperMng.pas',
  uRZDBase in 'units\uRZDBase.pas',
  uDBObject in '..\..\sharedUtils\mera\database\uDBObject.pas',
  uBaseObjService in '..\..\sharedUtils\objects\uBaseObjService.pas',
  uAddRZDDatafrm in 'forms\uAddRZDDatafrm.pas' {AddRZDDataFrm},
  UDirChangeNotifier in '..\..\sharedUtils\utils\PathUtils\UDirChangeNotifier.pas',
  uEventTypes in '..\..\sharedUtils\utils\lists\uEventTypes.pas',
  usetlist in '..\..\sharedUtils\utils\lists\usetlist.pas',
  uPointsList in '..\..\sharedUtils\utils\lists\uPointsList.pas',
  PathUtils in '..\..\sharedUtils\utils\PathUtils\PathUtils.pas',
  uPathMng in '..\..\sharedUtils\utils\uPathMng.pas',
  uEditTubeFrm in 'forms\uEditTubeFrm.pas' {EditTubeFrm},
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  uEditSignalsRepPropFrn in 'forms\uEditSignalsRepPropFrn.pas' {EditRepPropFrm},
  uUnitsDB in '..\..\sharedUtils\objects\uUnitsDB.pas',
  uIEManchester2087 in 'units\uIEManchester2087.pas',
  uBinFile in '..\..\sharedUtils\uBinFile.pas',
  uWPservices in '..\SharedWP\uWPservices.pas',
  uMeasureBase in '..\..\sharedUtils\mera\database\uMeasureBase.pas',
  uFFT in '..\..\sharedUtils\math\uFFT.pas',
  uSubRegsFrm in 'forms\uSubRegsFrm.pas' {SubRegsFrm},
  uExtFFTInverse in 'units\uExtFFTInverse.pas',
  uFFTInverseFrm in 'forms\uFFTInverseFrm.pas' {FFTInverseFrm},
  fft in '..\..\sharedUtils\math\alglib-2.6.0.delphi (1)\delphi\src\fft.pas',
  uExtBalanceSignals in 'units\uExtBalanceSignals.pas',
  uExtBalanceSignalsFrm in 'forms\uExtBalanceSignalsFrm.pas' {BalanceZeroFrm},
  uLogFile in '..\..\sharedUtils\utils\uLogFile.pas',
  uFFTFlt in 'units\uFFTFlt.pas',
  uFFTfltFrm in 'forms\uFFTfltFrm.pas' {FFTFltFrm},
  uLissajousFrm in 'forms\uLissajousFrm.pas' {LissajousFrm};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

// ресурсы можно редактировать программой sharedUnits/utils/ResourceEdit
{$R *.TLB}
{$R *.res}
{$R toolbarExtPack.res}
//{$R WPExtPack.res}


function  DllRegisterServer: hresult; stdcall;
var
  reg:tregistry;
var
  buffer:array[0..255] of char;
begin
  reg :=tregistry.Create;
  try
    reg.rootkey := hkey_local_machine;
    getmodulefilename(hinstance, buffer, 255);
    reg.openkey('\Software\MERA\Winpos\COMPlugins', True);
    reg.writestring(string(buffer),'WPExtPack.ExtPack');
    // showmessage(string(buffer));
    // делаем не через кокласс а через connect главного класса .Connect(
    // reg.writestring(string(buffer),'WPExtPack.IEMeraPlg');
    // showmessage(string(buffer));
  finally
    reg.Free;
  end;
  Result := comserv.dllregisterserver;
end;


function dllunregisterserver: hresult; stdcall;
var
  reg: tregistry;
var
  buffer: array[0..255] of char;
begin
  reg := tregistry.Create;
  try
    reg.rootkey := hkey_local_machine;
    getmodulefilename(hinstance, buffer, 255);
    if (reg.openkey('\Software\MERA\Winpos\COMPlugins', False)) then
    begin
      //showmessage('unreg: '+string(buffer));
      reg.DeleteValue(string(buffer));
    end;
  finally
    reg.Free;
   end;
  Result := comserv.dllunregisterserver;
end;


exports dllgetclassobject Name 'DllGetClassObject',
  dllcanunloadnow Name 'DllCanUnloadNow',
  dllregisterserver name 'DllRegisterServer',
  dllunregisterserver Name 'DllUnregisterServer';
begin

end.
