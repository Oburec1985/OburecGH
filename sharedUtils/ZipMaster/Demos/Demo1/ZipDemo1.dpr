Program zipdemo1;

uses
  Forms,
  msgunit in 'msgunit.pas' {Msgform},
  extrunit in 'extrunit.pas' {Extract},
  Addunit in 'Addunit.pas' {AddForm},
  sfxunit in 'sfxunit.pas' {MakeSFX},
  MainUnit in 'MainUnit.pas' {Mainform},
  renunit in 'renunit.pas' {RenForm},
  SortGrid in '..\SortGrid\SortGrid.pas',
  SortGridPreview in '..\SortGrid\SortGridPreview.pas' {SortGridPreviewForm},
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
{$R 'Res\dzsfxUS.res'}

Begin
    Application.Initialize;
    Application.Title := 'Zip Demo 1';
    Application.CreateForm(TMainform, Mainform);
  Application.CreateForm(TMsgform, Msgform);
  Application.CreateForm(TExtract, Extract);
  Application.CreateForm(TAddForm, AddForm);
  Application.CreateForm(TMakeSFX, MakeSFX);
  Application.CreateForm(TRenForm, RenForm);
  Application.CreateForm(TSortGridPreviewForm, SortGridPreviewForm);
  Application.Run;
End.

