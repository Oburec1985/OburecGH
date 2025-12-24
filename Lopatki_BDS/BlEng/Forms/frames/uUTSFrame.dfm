object UTSFrame: TUTSFrame
  Left = 0
  Top = 0
  Width = 480
  Height = 207
  TabOrder = 0
  DesignSize = (
    480
    207)
  object UtsLabel: TLabel
    Left = 16
    Top = 3
    Width = 63
    Height = 16
    Caption = #1050#1072#1085#1072#1083' UTS'
  end
  object SignalTypeLabel: TLabel
    Left = 184
    Top = 3
    Width = 72
    Height = 16
    Caption = #1058#1080#1087' '#1089#1080#1075#1085#1072#1083#1072
  end
  object UTSChannel: TComboBox
    Left = 16
    Top = 22
    Width = 145
    Height = 24
    TabOrder = 0
  end
  object UTSLV: TBtnListView
    Left = 16
    Top = 49
    Width = 449
    Height = 150
    Anchors = [akLeft, akTop, akBottom]
    Columns = <>
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ChangeTextColor = False
    Editable = False
  end
  object SEVCB: TComboBox
    Left = 184
    Top = 22
    Width = 145
    Height = 24
    TabOrder = 2
    Items.Strings = (
      'IRIG-B'
      'UTS')
  end
end
