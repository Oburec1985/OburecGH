unit uControlFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, StdCtrls, ComCtrls;

type
  TControlFrame = class(TFrame)
    ControlNameEdit: TEdit;
    ControlNameLabel: TLabel;
    FeedbackCB: TComboBox;
    FeedbackLabel: TLabel;
    ControlsPageControl: TPageControl;
  private
    { Private declarations }
  public
    constructor create(aowner:tcomponent);override;
  end;

implementation

{$R *.dfm}

constructor TControlFrame.create(aowner:tcomponent);override;
begin
  inherited;
  // создание подфреймов с настройками конкретных реализаций контрола
end;

end.
