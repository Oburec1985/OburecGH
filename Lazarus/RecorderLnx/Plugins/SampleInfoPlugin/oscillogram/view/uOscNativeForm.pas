unit uOscNativeForm;
{$mode objfpc}{$H+}
interface
uses Classes, Forms, uOscView;
type
  TOscNativeForm = class(TForm)
  published
    View: TOscView;
  public
    ViewId: QWord;
    DisplayWindowSeconds: Double;
  end;
implementation
{$R *.lfm}
end.
