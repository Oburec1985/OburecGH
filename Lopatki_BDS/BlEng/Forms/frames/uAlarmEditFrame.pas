unit uAlarmEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, uBaseObjPropertyFrame, uSpin, ExtCtrls, Spin, uAlarms;

type
  TEditAlarmFrame = class(TFrame)
    ThresholdSE: TFloatSpinEdit;
    ThresholdLabel: TLabel;
    DSCLabel: TLabel;
    DSCEdit: TEdit;
    ColorLabel: TLabel;
    ColorBox: TColorBox;
    GisterezisLabel: TLabel;
    GisterezisSE: TSpinEdit;
    NameLabel: TLabel;
    TypeLabel: TLabel;
    TypeImage: TImage;
    NameEdit: TEdit;
    TypeCB: TComboBox;
  public
    a:calarm;
  public
    procedure GetAlarm(alarm:cAlarm);
    procedure SetAlarm;
  end;

implementation

{$R *.dfm}

procedure TEditAlarmFrame.GetAlarm(alarm:cAlarm);
begin
  a:=alarm;
  NameEdit.Text:=a.name;
  if a.LoAlarm then
    TypeCB.ItemIndex:=0
  else
    TypeCB.ItemIndex:=1;  
  thresholdse.Value:=a.threshold;
  GisterezisSE.Value:=a.Gisterezis;
  DSCEdit.Text:=a.dsc;
end;

procedure TEditAlarmFrame.SetAlarm;
begin
  a.name:=NameEdit.Text;
  a.threshold:=thresholdse.Value;
  a.Gisterezis:=GisterezisSE.Value;
  a.dsc:=DSCEdit.Text;
  case TypeCB.ItemIndex of
    0:a.LoAlarm:=true;
    1:a.LoAlarm:=false;
  end;
end;

end.
