unit uSpin;

interface

uses Windows, Classes, StdCtrls, ExtCtrls, Controls, Messages, SysUtils,
  Forms, Graphics, Menus, Buttons;

const
  InitRepeatPause = 400;  {pause before repeat timer (ms)}
  RepeatPause     = 100;  {pause before hint window displays (ms)}

type
  TNumGlyphs = Buttons.TNumGlyphs;

  TTimerSpeedButton = class;

{ TSpinButton }

  tfloatspinbutton = class (TWinControl)
  private
    FUpButton: TTimerSpeedButton;
    FDownButton: TTimerSpeedButton;
    FFocusedButton: TTimerSpeedButton;
    FFocusControl: TWinControl;
    FOnUpClick: TNotifyEvent;
    FOnDownClick: TNotifyEvent;
    function CreateButton: TTimerSpeedButton;
    function GetUpGlyph: TBitmap;
    function GetDownGlyph: TBitmap;
    procedure SetUpGlyph(Value: TBitmap);
    procedure SetDownGlyph(Value: TBitmap);
    function GetUpNumGlyphs: TNumGlyphs;
    function GetDownNumGlyphs: TNumGlyphs;
    procedure SetUpNumGlyphs(Value: TNumGlyphs);
    procedure SetDownNumGlyphs(Value: TNumGlyphs);
    procedure BtnClick(Sender: TObject);
    procedure BtnMouseDown (Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetFocusBtn (Btn: TTimerSpeedButton);
    procedure AdjustSize (var W, H: Integer); reintroduce;
    procedure WMSize(var Message: TWMSize);  message WM_SIZE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Ctl3D;
    property DownGlyph: TBitmap read GetDownGlyph write SetDownGlyph;
    property DownNumGlyphs: TNumGlyphs read GetDownNumGlyphs write SetDownNumGlyphs default 1;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FocusControl: TWinControl read FFocusControl write FFocusControl;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property UpGlyph: TBitmap read GetUpGlyph write SetUpGlyph;
    property UpNumGlyphs: TNumGlyphs read GetUpNumGlyphs write SetUpNumGlyphs default 1;
    property Visible;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDock;
    property OnStartDrag;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
  end;

{ TSpinEdit }

  TFloatSpinEdit = class(TCustomEdit)
  private
    fOnDownClick, fOnUpClick:tnotifyevent;
  private
    FMinValue: double;
    FMaxValue: double;
    FIncrement: double;
    FButton: tFloatSpinButton;
    FEditorEnabled: Boolean;
    function GetMinHeight: Integer;
    function GetValue: double;
    function CheckValue (NewValue: double): double;
    procedure SetValue (NewValue: double);
    procedure SetEditRect;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMExit);   message CM_EXIT;
    procedure WMPaste(var Message: TWMPaste);   message WM_PASTE;
    procedure WMCut(var Message: TWMCut);   message WM_CUT;
  protected
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function IsValidChar(Key: Char): Boolean; virtual;
    procedure UpClick (Sender: TObject); virtual;
    procedure DownClick (Sender: TObject); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Button: tFloatSpinButton read FButton;
  published
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled default True;
    property Enabled;
    property Font;
    property Increment: double read FIncrement write FIncrement;
    property MaxLength;
    property MaxValue: double read FMaxValue write FMaxValue;
    property MinValue: double read FMinValue write FMinValue;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Value: double read GetValue write SetValue;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnDownClick: tnotifyevent read fOnDownClick write fOnDownClick;
    property OnUpClick: tnotifyevent read fOnUpClick write fOnUpClick;
  end;

{ TTimerSpeedButton }

  TTimeBtnState = set of (tbFocusRect, tbAllowTimer);

  TTimerSpeedButton = class(TSpeedButton)
  private
    FRepeatTimer: TTimer;
    FTimeBtnState: TTimeBtnState;
    procedure TimerExpired(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    destructor Destroy; override;
    property TimeBtnState: TTimeBtnState read FTimeBtnState write FTimeBtnState;
  end;

implementation

uses Themes;

//{$R SPIN}

{ tFloatSpinButton }

constructor tFloatSpinButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csAcceptsControls, csSetCaption] +
    [csFramed, csOpaque];
  { Frames don't look good around the buttons when themes are on }
  if ThemeServices.ThemesEnabled then
    ControlStyle := ControlStyle - [csFramed];
  FUpButton := CreateButton;
  FDownButton := CreateButton;
  UpGlyph := nil;
  DownGlyph := nil;

  Width := 20;
  Height := 25;
  FFocusedButton := FUpButton;
end;

function tFloatSpinButton.CreateButton: TTimerSpeedButton;
begin
  Result := TTimerSpeedButton.Create(Self);
  Result.OnClick := BtnClick;
  Result.OnMouseDown := BtnMouseDown;
  Result.Visible := True;
  Result.Enabled := True;
  Result.TimeBtnState := [tbAllowTimer];
  Result.Parent := Self;
end;

procedure tFloatSpinButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFocusControl) then
    FFocusControl := nil;
end;

procedure tFloatSpinButton.AdjustSize(var W, H: Integer);
begin
  if (FUpButton = nil) or (csLoading in ComponentState) then Exit;
  if W < 15 then W := 15;
  FUpButton.SetBounds(0, 0, W, H div 2);
  FDownButton.SetBounds(0, FUpButton.Height - 1, W, H - FUpButton.Height + 1);
end;

procedure tFloatSpinButton.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  W, H: Integer;
begin
  W := AWidth;
  H := AHeight;
  AdjustSize(W, H);
  inherited SetBounds(ALeft, ATop, W, H);
end;

procedure tFloatSpinButton.WMSize(var Message: TWMSize);
var
  W, H: Integer;
begin
  inherited;
  { check for minimum size }
  W := Width;
  H := Height;
  AdjustSize(W, H);
  if (W <> Width) or (H <> Height) then
    inherited SetBounds(Left, Top, W, H);
  Message.Result := 0;
end;

procedure tFloatSpinButton.WMSetFocus(var Message: TWMSetFocus);
begin
  FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState + [tbFocusRect];
  FFocusedButton.Invalidate;
end;

procedure tFloatSpinButton.WMKillFocus(var Message: TWMKillFocus);
begin
  FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState - [tbFocusRect];
  FFocusedButton.Invalidate;
end;

procedure tFloatSpinButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP:
      begin
        SetFocusBtn (FUpButton);
        FUpButton.Click;
      end;
    VK_DOWN:
      begin
        SetFocusBtn (FDownButton);
        FDownButton.Click;
      end;
    VK_SPACE:
      FFocusedButton.Click;
  end;
end;

procedure tFloatSpinButton.BtnMouseDown (Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    SetFocusBtn (TTimerSpeedButton (Sender));
    if (FFocusControl <> nil) and FFocusControl.TabStop and 
        FFocusControl.CanFocus and (GetFocus <> FFocusControl.Handle) then
      FFocusControl.SetFocus
    else if TabStop and (GetFocus <> Handle) and CanFocus then
      SetFocus;
  end;
end;

procedure tFloatSpinButton.BtnClick(Sender: TObject);
begin
  if Sender = FUpButton then
  begin
    if Assigned(FOnUpClick) then FOnUpClick(Self);
  end
  else
    if Assigned(FOnDownClick) then FOnDownClick(Self);
end;

procedure tFloatSpinButton.SetFocusBtn (Btn: TTimerSpeedButton);
begin
  if TabStop and CanFocus and  (Btn <> FFocusedButton) then
  begin
    FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState - [tbFocusRect];
    FFocusedButton := Btn;
    if (GetFocus = Handle) then 
    begin
       FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState + [tbFocusRect];
       Invalidate;
    end;
  end;
end;

procedure tFloatSpinButton.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure tFloatSpinButton.Loaded;
var
  W, H: Integer;
begin
  inherited Loaded;
  W := Width;
  H := Height;
  AdjustSize (W, H);
  if (W <> Width) or (H <> Height) then
    inherited SetBounds (Left, Top, W, H);
end;

function tFloatSpinButton.GetUpGlyph: TBitmap;
begin
  Result := FUpButton.Glyph;
end;

procedure tFloatSpinButton.SetUpGlyph(Value: TBitmap);
begin
  if Value <> nil then
    FUpButton.Glyph := Value
  else
  begin
    FUpButton.Glyph.Handle := LoadBitmap(HInstance, 'SpinUp');
    FUpButton.NumGlyphs := 1;
    FUpButton.Invalidate;
  end;
end;

function tFloatSpinButton.GetUpNumGlyphs: TNumGlyphs;
begin
  Result := FUpButton.NumGlyphs;
end;

procedure tFloatSpinButton.SetUpNumGlyphs(Value: TNumGlyphs);
begin
  FUpButton.NumGlyphs := Value;
end;

function tFloatSpinButton.GetDownGlyph: TBitmap;
begin
  Result := FDownButton.Glyph;
end;

procedure tFloatSpinButton.SetDownGlyph(Value: TBitmap);
begin
  if Value <> nil then
    FDownButton.Glyph := Value
  else
  begin
    FDownButton.Glyph.Handle := LoadBitmap(HInstance, 'SpinDown');
    FUpButton.NumGlyphs := 1;
    FDownButton.Invalidate;
  end;
end;

function tFloatSpinButton.GetDownNumGlyphs: TNumGlyphs;
begin
  Result := FDownButton.NumGlyphs;
end;

procedure tFloatSpinButton.SetDownNumGlyphs(Value: TNumGlyphs);
begin
  FDownButton.NumGlyphs := Value;
end;

{ TSpinEdit }

constructor TFloatSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButton := tFloatSpinButton.Create(Self);
  FButton.Width := 15;
  FButton.Height := 17;
  FButton.Visible := True;  
  FButton.Parent := Self;
  FButton.FocusControl := Self;
  FButton.OnUpClick := UpClick;
  FButton.OnDownClick := DownClick;
  Text := '0';
  ControlStyle := ControlStyle - [csSetCaption];
  FIncrement := 1;
  FEditorEnabled := True;
  ParentBackground := False;
  increment:=0.1;
end;

destructor TFloatSpinEdit.Destroy;
begin
  FButton := nil;
  inherited Destroy;
end;

procedure TFloatSpinEdit.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TFloatSpinEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then UpClick (Self)
  else if Key = VK_DOWN then DownClick (Self);
  inherited KeyDown(Key, Shift);
end;

procedure TFloatSpinEdit.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then inherited KeyPress(Key);
end;

function TFloatSpinEdit.IsValidChar(Key: Char): Boolean;
begin
  Result := (Key in [DecimalSeparator, '+', '-', '0'..'9']) or
    ((Key < #32) and (Key <> Chr(VK_RETURN)));
  if not FEditorEnabled and Result and ((Key >= #32) or
      (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE))) then
    Result := False;
end;

procedure TFloatSpinEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
{  Params.Style := Params.Style and not WS_BORDER;  }
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TFloatSpinEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TFloatSpinEdit.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - FButton.Width - 2;
  Loc.Top := 0;  
  Loc.Left := 0;  
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));  {debug}
end;

procedure TFloatSpinEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
    { text edit bug: if size to less than minheight, then edit ctrl does
      not display the text }
  if Height < MinHeight then   
    Height := MinHeight
  else if FButton <> nil then
  begin
    if NewStyleControls and Ctl3D then
      FButton.SetBounds(Width - FButton.Width - 5, 0, FButton.Width, Height - 5)
    else FButton.SetBounds (Width - FButton.Width, 1, FButton.Width, Height - 3);
    SetEditRect;
  end;
end;

function TFloatSpinEdit.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  Result := Metrics.tmHeight + I div 4 + GetSystemMetrics(SM_CYBORDER) * 4 + 2;
end;

procedure TFloatSpinEdit.UpClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0)
  else Value := Value + FIncrement;

  if Assigned(fOnUpClick) then
    fOnUpClick(sender);
end;

procedure TFloatSpinEdit.DownClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0)
  else Value := Value - FIncrement;

  if Assigned(fOnDownClick) then
    fOnDownClick(self);
end;

procedure TFloatSpinEdit.WMPaste(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TFloatSpinEdit.WMCut(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TFloatSpinEdit.CMExit(var Message: TCMExit);
begin
  inherited;
  if CheckValue (Value) <> Value then
    SetValue (Value);
end;

function strtoFloatExt(Str: string): double;
var
  i: integer;
  ch:char;
begin
  i := pos('.', Str);
  if i=0 then
  begin
    i := pos(',', Str);
  end;
  if i > 0 then
  begin
    ch:=Str[i];
    if decimalseparator <> ch then
    begin
      Str[i] := decimalseparator;
    end;
  end;
  result := strtofloat(Str);
end;


function TFloatSpinEdit.GetValue: double;
begin
  try
  begin
    if text<>'' then
      Result := StrTofloatExt (Text)
    else
      Result := FMinValue;
  end;
  except
    Result := FMinValue;
  end;
end;

procedure TFloatSpinEdit.SetValue (NewValue: double);
begin
  Text := floatToStr (CheckValue (NewValue));
end;

function TFloatSpinEdit.CheckValue (NewValue: double): double;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue) then
  begin
    if NewValue < FMinValue then
      Result := FMinValue
    else if NewValue > FMaxValue then
      Result := FMaxValue;
  end;
end;

procedure TFloatSpinEdit.CMEnter(var Message: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll;
  inherited;
end;

{TTimerSpeedButton}

destructor TTimerSpeedButton.Destroy;
begin
  if FRepeatTimer <> nil then
    FRepeatTimer.Free;
  inherited Destroy;
end;

procedure TTimerSpeedButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown (Button, Shift, X, Y);
  if tbAllowTimer in FTimeBtnState then
  begin
    if FRepeatTimer = nil then
      FRepeatTimer := TTimer.Create(Self);

    FRepeatTimer.OnTimer := TimerExpired;
    FRepeatTimer.Interval := InitRepeatPause;
    FRepeatTimer.Enabled  := True;
  end;
end;

procedure TTimerSpeedButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);
begin
  inherited MouseUp (Button, Shift, X, Y);
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled  := False;
end;

procedure TTimerSpeedButton.TimerExpired(Sender: TObject);
begin
  FRepeatTimer.Interval := RepeatPause;
  if (FState = bsDown) and MouseCapture then
  begin
    try
      Click;
    except
      FRepeatTimer.Enabled := False;
      raise;
    end;
  end;
end;

procedure TTimerSpeedButton.Paint;
var
  R: TRect;
begin
  inherited Paint;
  if tbFocusRect in FTimeBtnState then
  begin
    R := Bounds(0, 0, Width, Height);
    InflateRect(R, -3, -3);
    if FState = bsDown then
      OffsetRect(R, 1, 1);
    DrawFocusRect(Canvas.Handle, R);
  end;
end;

end.
