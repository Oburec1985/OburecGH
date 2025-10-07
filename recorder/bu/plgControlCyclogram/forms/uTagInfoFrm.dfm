object TagInfoFrm: TTagInfoFrm
  Left = 0
  Top = 0
  Caption = 'TagInfoFrm'
  ClientHeight = 101
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -20
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  OnMouseUp = FormMouseUp
  PixelsPerInch = 120
  TextHeight = 24
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 464
    Height = 52
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    PopupMenu = PopupMenu1
    TabOrder = 0
  end
  object RichText: TRichEdit
    Left = 0
    Top = 52
    Width = 464
    Height = 49
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -22
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'RichEdit1')
    ParentFont = False
    PopupMenu = PopupMenu1
    TabOrder = 1
  end
  object PopupMenu1: TPopupMenu
    Left = 160
    Top = 8
    object N1: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
      OnClick = N1Click
    end
  end
end
