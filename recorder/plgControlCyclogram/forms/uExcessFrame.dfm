inherited ExcessFrame: TExcessFrame
  object PCountLabel: TLabel [2]
    Left = 8
    Top = 154
    Width = 72
    Height = 16
    Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082
  end
  object dFLabel: TLabel [3]
    Left = 146
    Top = 154
    Width = 119
    Height = 16
    Caption = #1056#1072#1079#1084#1077#1088' '#1087#1086#1088#1094#1080#1080', '#1089#1077#1082'.'
  end
  object ChannelLabel: TLabel [4]
    Left = 9
    Top = 102
    Width = 35
    Height = 16
    Caption = #1050#1072#1085#1072#1083
  end
  object Label1: TLabel [5]
    Left = 155
    Top = 102
    Width = 36
    Height = 16
    Caption = #1042#1099#1093#1086#1076
  end
  object PCountEdit: TIntEdit
    Left = 8
    Top = 176
    Width = 121
    Height = 24
    Enabled = False
    TabOrder = 2
    Text = '16384'
  end
  object dTFE: TEdit
    Left = 146
    Top = 176
    Width = 121
    Height = 24
    TabOrder = 3
  end
  object AlgTypeRG: TRadioGroup
    Left = 8
    Top = 206
    Width = 185
    Height = 75
    Caption = #1058#1080#1087' '#1072#1083#1075#1086#1088#1080#1090#1084#1072
    Items.Strings = (
      #1055#1086' '#1074#1088#1077#1084#1077#1085#1080' (A/Rms)'
      #1055#1086' '#1089#1087#1077#1082#1090#1088#1091' A1/Rms')
    TabOrder = 4
  end
  object ChannelCB: TRcComboBox
    Left = 9
    Top = 124
    Width = 120
    Height = 24
    TabOrder = 5
  end
  object OutChannelName: TEdit
    Left = 146
    Top = 124
    Width = 277
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 6
  end
end
