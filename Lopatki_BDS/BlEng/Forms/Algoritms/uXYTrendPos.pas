unit uXYTrendPos;

interface

uses
  Windows, SysUtils, Forms,  StdCtrls, DCL_MYOWN, Classes, uMeraSignal,
  uTickData,uBldMath, uBldFile, usensor, Controls,  utrend, ustage, uTrendSignal,
  Spin, CommonOptsFrame, uBaseBldAlg, usensorlist, uTag, uAxis, uSaveSignalForm,
  uTagSignal, upage;

type
  TXYTrendForm = class(TForm)
    CancelBtn: TButton;
    OkBtn: TButton;
    StartBladeSE: TSpinEdit;
    BladeIndLabel: TLabel;
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    EndBladeSE: TSpinEdit;
    Label1: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure setopts(opts:cBaseOpts);
    procedure getopts(o:cBaseOpts);
  public
    function ShowModal(t:csensor;sensors:calgsensorlist; opts:cBaseOpts):integer;
  end;

var
  XYTrendForm: TXYTrendForm;

implementation
uses
  uTrendAlg;
{$R *.dfm}

procedure TXYTrendForm.setopts(opts:cBaseOpts);
begin
  if opts.stage<>nil then
  begin
    EndBladeSE.Value:=opts.stage.BladeCount-1;
    EndBladeSE.MaxValue:=opts.stage.BladeCount-1;
    EndBladeSE.MinValue:=0;

    StartBladeSE.Value:=0;
    StartBladeSE.MaxValue:=opts.stage.BladeCount-1;
    StartBladeSE.MinValue:=0;
  end;
end;

procedure TXYTrendForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

procedure TXYTrendForm.getopts(o:cBaseOpts);
begin
  BaseAlgOptsFrame1.GetOpts(o);
end;

function TXYTrendForm.ShowModal(t:csensor;sensors:calgsensorlist; opts:cBaseOpts):integer;
var
  alg:ctrendalg;
  s:csensor;
  tag:cBaseTag;
  i:integer;
  ax:caxis;
  tr:ctrend;
begin
  BaseAlgOptsFrame1.SetOpts(t,sensors,Opts);
  setopts(opts);
  if inherited showmodal = mrok then
  begin
    GetOpts(opts);
    // выполняем алгоритм
    alg:=ctrendalg.create;
    alg.sensorsList:=sensors;
    alg.getOpts(opts);

    if opts.trend<>nil then
      ax:=caxis(opts.trend.GetParentByClassName('cAxis'))
    else
      ax:=cpage(opts.chart.tabs.activepage).activeAxis;

    for i:=StartBladeSE.Value to EndBladeSE.Value do
    begin
      tag:=cbasetag(alg.tags.getobj('XYArray_'+inttostr(i)));
      tag.active:=true;
      // сохранение в мера файл
      if BaseAlgOptsFrame1.merafilecb.Checked then
      begin
      end
      else
      // отрисовка в график
      begin
        if (i=StartBladeSE.Value) and (opts.trend<>nil) then
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
