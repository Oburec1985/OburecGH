unit uPairTrendForm;

interface

uses
  Windows, SysUtils, Forms,  StdCtrls, DCL_MYOWN, Classes, uMeraSignal,
  uTickData,uBldMath, uBldFile, usensor, Controls,  utrend, ustage, uTrendSignal,
  Spin, CommonOptsFrame, uBaseBldAlg, usensorlist, uTag, uAxis, uSaveSignalForm,
  uTagSignal, uPair, upage;

type
  TPairTrendForm = class(TForm)
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
  PairTrendForm: TPairTrendForm;

implementation
uses
  uPairTrend;

{$R *.dfm}


function TPairTrendForm.ShowModal(t:csensor;sensors:calgsensorlist; opts:cBaseOpts):integer;
var
  alg:cPairTrend;
  s:csensor;
  i:integer;
  ax:caxis;
  tr:ctrend;
  tag:cbasetag;
begin
  BaseAlgOptsFrame1.SetOpts(t,sensors,Opts);
  if inherited showmodal = mrok then
  begin
    BaseAlgOptsFrame1.GetOpts(opts);
    // выполняем алгоритм
    alg:=cPairTrend.create;
    alg.pair:=cpair(opts.data);
    alg.sensorsList:=sensors;
    alg.getOpts(opts);
    if opts.trend<>nil then
      ax:=caxis(opts.trend.GetParentByClassName('cAxis'))
    else
      ax:=cpage(opts.chart.tabs.activepage).activeAxis;
    for i:=0 to opts.stage.BladeCount-1 do
    begin
      tag:=cbasetag(alg.tags.getobj('XYArray_'+inttostr(i)));
      tag.dsc:='Дистанция прохода лопатки №'+'inttostr(i)'+' между датчиками пары';
      tag.active:=true;
      // сохранение в мера файл
      if BaseAlgOptsFrame1.MeraFileCB.Checked then
      begin
      end
      else
      // отрисовка в график
      begin
        if (i=0) and (opts.trend<>nil) then
        begin
          tag.DrawObj:=opts.trend;
          tag.DrawObj.name:=tag.name;
        end
        else
        begin
          tr:=ax.AddTrend;
          tag.DrawObj:=tr;
          tag.DrawObj.name:=tag.name;
        end;
      end;
    end;
    alg.apply(t,sensors,opts);
    // очистка данных
    alg.Destroy;
  end;
end;

end.
