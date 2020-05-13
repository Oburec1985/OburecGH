unit uPairShapeForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, uBldEng, uBldObj,
  StdCtrls, CommonOptsFrame,
  uturbina, ustage, uBaseBldAlg, uBldCompProc, usensor, uSpin, uSensorRep, Spin,
  ExtCtrls, uSensorlist, Dialogs, uPairShapeFrame;

type
  TPairShapeForm = class(TForm)
    PairShapeOptsGB: TGroupBox;
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    pairShapeFrame1: TpairShapeFrame;
    OkBtn: TButton;
    CancelBtn: TButton;
    Splitter1: TSplitter;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    sList:cAlgSensorList;
  private
  public
    Function ShowModal(t:csensor;sensorlist:cAlgSensorList; opts:cBaseOpts):integer;
  end;

var
  PairShapeForm: TPairShapeForm;

implementation
uses uPairShape;
{$R *.dfm}

procedure TPairShapeForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

Function TPairShapeForm.ShowModal(t:csensor; sensorlist:cAlgSensorList; opts:cBaseOpts):integer;
begin
  slist:=sensorlist;
  BaseAlgOptsFrame1.SetOpts(t,sensorlist,opts);
  pairShapeFrame1.setopts(t,sensorlist,cPairShapeOpts(opts));
  result:= inherited showmodal;
  if Result=mrok then
  begin
    BaseAlgOptsFrame1.GetOpts(opts);
    pairShapeFrame1.getopts(cPairShapeOpts(opts));
  end;
end;

end.
