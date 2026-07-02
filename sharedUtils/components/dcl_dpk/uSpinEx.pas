unit uSpinEx;

interface

uses
  Windows, Classes, Controls, Spin;

type
  TSpinButtonEx = class(tspinbutton)
  private
    fClickDelay: Integer;
    fLastClickTime: LongWord;
  protected
    procedure BtnClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ClickDelay: Integer read fClickDelay write fClickDelay default 1000;
  end;

implementation

{ TSpinButtonEx }

constructor TSpinButtonEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fClickDelay := 1000;
  fLastClickTime := 0;
end;

procedure TSpinButtonEx.BtnClick(Sender: TObject);
var
  lNow: LongWord;
begin
  lNow := GetTickCount;
  // Если прошло меньше времени, чем ClickDelay, игнорируем клик
  if (lNow - fLastClickTime) < LongWord(fClickDelay) then
    Exit;

  fLastClickTime := lNow;
  inherited BtnClick(Sender);
end;

end.
