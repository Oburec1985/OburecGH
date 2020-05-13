object CursorFrm: TCursorFrm
  Left = 0
  Top = 0
  Caption = 'CursorFrm'
  ClientHeight = 404
  ClientWidth = 312
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object LV: TBtnListView
    Left = 0
    Top = 33
    Width = 312
    Height = 371
    Align = alClient
    Columns = <
      item
        Caption = #8470
        Width = 51
      end
      item
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        Width = 51
      end
      item
        Caption = #1047#1085#1072#1095#1077#1085#1080#1077
        Width = 51
      end>
    Items.ItemData = {
      03210000000100000000000000FFFFFFFFFFFFFFFF01000000FFFFFFFF000000
      00013000015800FFFF}
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnClick = LVClick
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ChangeTextColor = False
    Editable = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 312
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    Caption = #1050#1091#1088#1089#1086#1088
    TabOrder = 1
  end
end
