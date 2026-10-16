unit FrameSettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, uFrmSimple;

type

  { TFrameSettings }

  TFrameSettings = class(TFrmSimple)
  private
    { Private declarations }
  fTypeChanged: TNotifyEvent;
  public
  procedure ApplySettings; virtual; abstract;
  procedure DoTypeChanged;
    { Public declarations }
  property OnTypeChanged: TNotifyEvent read fTypeChanged write fTypeChanged;
  end;

implementation

{$R *.lfm}

procedure TFrameSettings.DoTypeChanged;
begin
  if Assigned(fTypeChanged) then
     fTypeChanged(self);
end;


end.

