object TresHoldFrame: TTresHoldFrame
  Left = 0
  Top = 0
  Width = 504
  Height = 348
  TabOrder = 0
  DesignSize = (
    504
    348)
  object NameLabel: TLabel
    Left = 8
    Top = 2
    Width = 121
    Height = 16
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1072#1083#1075#1086#1088#1080#1090#1084#1072
  end
  object OptsLabel: TLabel
    Left = 8
    Top = 50
    Width = 61
    Height = 16
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  end
  object ChannelLabel: TLabel
    Left = 9
    Top = 234
    Width = 35
    Height = 16
    Caption = #1050#1072#1085#1072#1083
  end
  object OutLabel: TLabel
    Left = 169
    Top = 234
    Width = 36
    Height = 16
    Caption = #1042#1099#1093#1086#1076
  end
  object AlgNameEdit: TEdit
    Left = 9
    Top = 24
    Width = 481
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 0
  end
  object OptsEdit: TEdit
    Left = 9
    Top = 72
    Width = 481
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 1
    ExplicitWidth = 489
  end
  object ChannelCB: TRcComboBox
    Left = 9
    Top = 256
    Width = 145
    Height = 24
    TabOrder = 2
  end
  object OutChannelName: TEdit
    Left = 160
    Top = 256
    Width = 330
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 3
    ExplicitWidth = 313
  end
end
