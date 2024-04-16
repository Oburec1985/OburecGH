object DigsFrm: TDigsFrm
  Left = 0
  Top = 0
  Caption = 'DigsFrm'
  ClientHeight = 421
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  PixelsPerInch = 120
  TextHeight = 16
  object SignalsSG: TStringGrid
    Left = 0
    Top = 0
    Width = 633
    Height = 421
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
