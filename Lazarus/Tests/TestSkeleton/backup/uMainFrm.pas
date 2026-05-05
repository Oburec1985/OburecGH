unit uMainFrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  uOglChartControl, uOglChartRenderer, uOglChartSerializer, uOglChartModel,
  uOglChartTypes;

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
  fChart := TOglChartControl.Create(Self);
  fChart.Parent := Self;
  fChart.Align := alClient;
  
  // Инициализируем рендер
  fChart.Renderer := TOpenGLChartRenderer.Create;
  
  // Начальные данные
  fChart.Model.Title := 'Skeleton Test';
  fChart.Model.BackgroundColor := $FF333333; // Темно-серый
end;

procedure TMainFrm.btnChangeColorClick(Sender: TObject);
begin
  // Случайный цвет для проверки реактивности и потокобезопасности
  fChart.Model.BackgroundColor := $FF000000 or (Random($FFFFFF));
  fChart.InvalidateChart;
end;

procedure TMainFrm.btnSaveClick(Sender: TObject);
var
  lSerializer: IChartSerializer;
  lText: TStringList;
begin
  lSerializer := TJsonChartSerializer.Create;
  lText := TStringList.Create;
  try
    lText.Text := fChart.ObjectManager.SaveToString(lSerializer);
    lText.SaveToFile('chart_model.json');
    ShowMessage('Model saved to chart_model.json');
  finally
    lText.Free;
  end;
end;

procedure TMainFrm.btnLoadClick(Sender: TObject);
var
  lSerializer: IChartSerializer;
  lText: TStringList;
begin
  if not FileExists('chart_model.json') then
  begin
    ShowMessage('Save something first!');
    Exit;
  end;

  lSerializer := TJsonChartSerializer.Create;
  lText := TStringList.Create;
  try
    lText.LoadFromFile('chart_model.json');
    fChart.ObjectManager.LoadFromString(lSerializer, lText.Text);
    fChart.InvalidateChart;
    ShowMessage('Model loaded: ' + fChart.Model.Title);
  finally
    lText.Free;
  end;
end;

end.
