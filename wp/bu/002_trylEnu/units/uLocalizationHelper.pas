unit uLocalizationHelper;

interface

uses
  Forms, Classes, gnugettext;

/// <summary>
/// Переводит компоненты формы или фрейма на текущий выбранный язык.
/// </summary>
procedure TranslateForm(AForm: TComponent);

implementation

procedure TranslateForm(AForm: TComponent);
begin
  if Assigned(AForm) then
    TranslateComponent(AForm);
end;

end.
