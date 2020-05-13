unit uPairRestoreForm;

interface

uses
  Windows, SysUtils, Forms,  StdCtrls, DCL_MYOWN, Classes, uMeraSignal,
  uTickData,uBldMath, uBldFile, usensor, Controls,  utrend, ustage, uTrendSignal,
  Spin, CommonOptsFrame, uBaseBldAlg, usensorlist, uTag, uAxis, uSaveSignalForm,
  uTagSignal, uPair;

type
  TPairRestoreForm = class(TForm)
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    ApplyGB: TGroupBox;
    OkBtn: TButton;
    CancelBtn: TButton;
  private
    { Private declarations }
  public
    function ShowModal(t:csensor;sensors:calgsensorlist; opts:cBaseOpts):integer;
  end;

var
  PairRestoreForm: TPairRestoreForm;

implementation
uses
  uPairRestore;
{$R *.dfm}


function TPairRestoreForm.ShowModal(t:csensor;sensors:calgsensorlist; opts:cBaseOpts):integer;
var
  alg:cPairRestore;
  s:csensor;
  i:integer;
  ax:caxis;
  tr:ctrend;
  tag:cbasetag;
begin
  BaseAlgOptsFrame1.SetOpts(t,sensors,Opts);
  BaseAlgOptsFrame1.MeraFileCB.Checked:=true;
  if inherited showmodal = mrok then
  begin
    BaseAlgOptsFrame1.GetOpts(opts);
    // выполняем алгоритм
    alg:=cPairRestore.create;
    alg.pair:=cpair(opts.data);
    alg.sensorsList:=sensors;
    alg.getOpts(opts);
    alg.apply(t,sensors,opts);
    // очистка данных
    alg.Destroy;
  end;
end;

end.
