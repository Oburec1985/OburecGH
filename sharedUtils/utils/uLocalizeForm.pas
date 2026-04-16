unit uLocalizeForm;

interface

uses
  Forms, gnugettext;

type
  // Перехватчик для автоматической локализации форм
  TForm = class(Forms.TForm)
  public
    procedure AfterConstruction; override;
  end;

  // Перехватчик для автоматической локализации фреймов
  TFrame = class(Forms.TFrame)
  public
    procedure AfterConstruction; override;
  end;

implementation

{ TForm }

procedure TForm.AfterConstruction;
begin
  inherited AfterConstruction;
  if DefaultInstance.Enabled then
    TranslateComponent(Self);
end;

{ TFrame }

procedure TFrame.AfterConstruction;
begin
  inherited AfterConstruction;
  if DefaultInstance.Enabled then
    TranslateComponent(Self);
end;

end.
