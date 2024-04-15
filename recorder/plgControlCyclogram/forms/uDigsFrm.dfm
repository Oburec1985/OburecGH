object DigsFrm: TDigsFrm
  Left = 0
  Top = 0
  Caption = 'DigsFrm'
  ClientHeight = 316
  ClientWidth = 475
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  PixelsPerInch = 96
  TextHeight = 12
  object SignalsSG: TStringGrid
    Left = 0
    Top = 0
    Width = 475
    Height = 316
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    TabOrder = 0
    OnDrawCell = SignalsSGDrawCell
  end
  object PopupMenu1: TPopupMenu
    Left = 112
    Top = 176
    object N1: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
      OnClick = N1Click
    end
  end
end
