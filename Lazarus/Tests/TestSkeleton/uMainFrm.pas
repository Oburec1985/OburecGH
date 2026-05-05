unit uMainFrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  uOglChartControl, uOglChartRenderer, uOglChartSerializer, uOglChartModel,
  uOglChartLog;

type
  { TMainFrm }
  TMainFrm = class(TForm)
    pnlTools: TPanel;
    btnLoad: TButton;
    btnSave: TButton;
    btnChangeColor: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnChangeColorClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
  private
    fChart: TOglChartControl;
  public
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.lfm}

{ TMainFrm }

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  ChartLogSetFileName(ExtractFilePath(ParamStr(0)) + 'oglchart_debug.log');
  ChartLogInfo('TMainFrm.FormCreate enter form=' + ChartPtr(Self));

  fChart := TOglChartControl.Create(Self);
  fChart.Parent := Self;
  fChart.Align := alClient;
  ChartLogInfo(Format('TMainFrm.FormCreate chart=%s manager=%s model=%s', [
    ChartPtr(fChart), ChartPtr(fChart.ObjectManager), ChartPtr(fChart.Model)
  ]));

  fChart.Renderer := TOpenGLChartRenderer.Create;
  ChartLogInfo('TMainFrm.FormCreate renderer assigned');

  fChart.Model.Title := 'Skeleton Test';
  fChart.Model.BackgroundColor := $FF333333;
  ChartLogInfo(Format('TMainFrm.FormCreate leave title="%s" background=%s', [
    fChart.Model.Title,
    IntToHex(fChart.Model.BackgroundColor, 8)
  ]));
end;

procedure TMainFrm.btnChangeColorClick(Sender: TObject);
begin
  ChartLogInfo(Format('btnChangeColorClick enter old_background=%s', [
    IntToHex(fChart.Model.BackgroundColor, 8)
  ]));
  fChart.Model.BackgroundColor := $FF000000 or Random($FFFFFF);
  ChartLogInfo(Format('btnChangeColorClick new_background=%s', [
    IntToHex(fChart.Model.BackgroundColor, 8)
  ]));
  fChart.InvalidateChart;
  ChartLogInfo('btnChangeColorClick leave');
end;

procedure TMainFrm.btnSaveClick(Sender: TObject);
var
  lSerializer: TJsonChartSerializer;
  lText: TStringList;
begin
  ChartLogInfo('btnSaveClick enter');
  lSerializer := TJsonChartSerializer.Create;
  ChartLogInfo('btnSaveClick serializer created serializer=' + ChartPtr(lSerializer));
  lText := TStringList.Create;
  ChartLogInfo('btnSaveClick stringlist created list=' + ChartPtr(lText));
  try
    try
      ChartLogInfo(Format('btnSaveClick before SaveToString chart=%s manager=%s model=%s title="%s" background=%s', [
        ChartPtr(fChart),
        ChartPtr(fChart.ObjectManager),
        ChartPtr(fChart.Model),
        fChart.Model.Title,
        IntToHex(fChart.Model.BackgroundColor, 8)
      ]));
      lText.Text := fChart.ObjectManager.SaveToString(lSerializer);
      ChartLogInfo(Format('btnSaveClick after SaveToString text_length=%d text="%s"', [
        Length(lText.Text),
        lText.Text
      ]));
      lText.SaveToFile('chart_model.json');
      ChartLogInfo('btnSaveClick file saved chart_model.json');
      ShowMessage('Model saved to chart_model.json');
      ChartLogInfo('btnSaveClick message shown');
    except
      on E: Exception do
      begin
        ChartLogException('btnSaveClick inner', E);
        raise;
      end;
    end;
  finally
    ChartLogInfo('btnSaveClick finally before lText.Free list=' + ChartPtr(lText));
    lText.Free;
    ChartLogInfo('btnSaveClick finally after lText.Free');
    ChartLogInfo('btnSaveClick finally before lSerializer.Free serializer=' + ChartPtr(lSerializer));
    lSerializer.Free;
    ChartLogInfo('btnSaveClick finally after lSerializer.Free');
  end;
  ChartLogInfo('btnSaveClick leave');
end;

procedure TMainFrm.btnLoadClick(Sender: TObject);
var
  lSerializer: TJsonChartSerializer;
  lText: TStringList;
begin
  ChartLogInfo('btnLoadClick enter');
  if not FileExists('chart_model.json') then
  begin
    ChartLogWarning('btnLoadClick file chart_model.json not found');
    ShowMessage('Save something first!');
    Exit;
  end;

  lSerializer := TJsonChartSerializer.Create;
  ChartLogInfo('btnLoadClick serializer created serializer=' + ChartPtr(lSerializer));
  lText := TStringList.Create;
  ChartLogInfo('btnLoadClick stringlist created list=' + ChartPtr(lText));
  try
    try
      lText.LoadFromFile('chart_model.json');
      ChartLogInfo(Format('btnLoadClick file loaded text_length=%d text="%s"', [
        Length(lText.Text),
        lText.Text
      ]));
      fChart.ObjectManager.LoadFromString(lSerializer, lText.Text);
      ChartLogInfo(Format('btnLoadClick after LoadFromString model=%s title="%s" background=%s', [
        ChartPtr(fChart.Model),
        fChart.Model.Title,
        IntToHex(fChart.Model.BackgroundColor, 8)
      ]));
      fChart.InvalidateChart;
      ChartLogInfo('btnLoadClick chart invalidated');
      ShowMessage('Model loaded: ' + fChart.Model.Title);
      ChartLogInfo('btnLoadClick message shown');
    except
      on E: Exception do
      begin
        ChartLogException('btnLoadClick inner', E);
        raise;
      end;
    end;
  finally
    ChartLogInfo('btnLoadClick finally before lText.Free list=' + ChartPtr(lText));
    lText.Free;
    ChartLogInfo('btnLoadClick finally after lText.Free');
    ChartLogInfo('btnLoadClick finally before lSerializer.Free serializer=' + ChartPtr(lSerializer));
    lSerializer.Free;
    ChartLogInfo('btnLoadClick finally after lSerializer.Free');
  end;
  ChartLogInfo('btnLoadClick leave');
end;

end.
