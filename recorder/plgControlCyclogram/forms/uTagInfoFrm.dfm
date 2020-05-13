object TagInfoFrm: TTagInfoFrm
  Left = 0
  Top = 0
  Caption = 'TagInfoFrm'
  ClientHeight = 80
  ClientWidth = 367
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 19
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 367
    Height = 41
    Align = alTop
    PopupMenu = PopupMenu1
    TabOrder = 0
  end
  object RichText: TRichEdit
    Left = 0
    Top = 41
    Width = 367
    Height = 39
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
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
