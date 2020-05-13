program zipdemo2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  DZUtils in '..\..\DZUtils.pas',
  SFXInterface in '..\..\SFXInterface.pas',
  SFXStructs in '..\..\SFXStructs.pas',
  ZipFix in '..\..\ZipFix.pas',
  ZipMsg in '..\..\ZipMsg.pas',
  ZipMstr in '..\..\ZipMstr.pas',
  ZipSFX in '..\..\ZipSFX.pas',
  ZMCompat in '..\..\ZMCompat.pas',
  ZMCore in '..\..\ZMCore.pas',
  ZMCtx in '..\..\ZMCtx.pas',
  ZMDBind in '..\..\ZMDBind.pas',
  ZMDefMsgs in '..\..\ZMDefMsgs.pas',
  ZMDelZip in '..\..\ZMDelZip.pas',
  ZMDlg in '..\..\ZMDlg.pas',
  ZMExtrLZ77 in '..\..\ZMExtrLZ77.pas',
  ZMHash in '..\..\ZMHash.pas',
  ZMMsgStr in '..\..\ZMMsgStr.pas',
  ZMSBind in '..\..\ZMSBind.pas',
  ZMStructs in '..\..\ZMStructs.pas',
  ZMUtils in '..\..\ZMUtils.pas',
  ZMWrkr in '..\..\ZMWrkr.pas',
  ZMXcpt in '..\..\ZMXcpt.pas';

{$R *.RES}
{$R 'Res\ZMRes.res'}

begin
  Application.Initialize;
  Application.Title := 'Zip Demo 2';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
