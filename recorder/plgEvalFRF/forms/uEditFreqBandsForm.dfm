object EditFreqBandsForm: TEditFreqBandsForm
  Left = 0
  Top = 0
  Caption = 'EditFreqBandsForm'
  ClientHeight = 342
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 301
    Width = 689
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitLeft = 304
    ExplicitTop = 224
    ExplicitWidth = 185
    object OKBtn: TButton
      Left = 584
      Top = 6
      Width = 75
      Height = 25
      Caption = 'OKBtn'
      TabOrder = 0
    end
    object CancelBtn: TButton
      Left = 16
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 1
    end
  end
  object StringGrid: TStringGrid
    Left = 369
    Top = 0
    Width = 320
    Height = 301
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 312
    ExplicitTop = 120
    ExplicitHeight = 120
  end
end
