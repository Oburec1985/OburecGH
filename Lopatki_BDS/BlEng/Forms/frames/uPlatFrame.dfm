object Platframe: TPlatframe
  Left = 0
  Top = 0
  Width = 688
  Height = 86
  TabOrder = 0
  object BuffSizeLabel: TLabel
    Left = 304
    Top = 13
    Width = 76
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088' '#1073#1091#1092#1077#1088#1072
  end
  object PeriodLabel: TLabel
    Left = 152
    Top = 13
    Width = 101
    Height = 13
    Caption = #1055#1077#1088#1080#1086#1076' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1103
  end
  object Label1: TLabel
    Left = 3
    Top = 13
    Width = 42
    Height = 13
    Caption = #1063#1072#1089#1090#1086#1090#1072
  end
  object ModeLabel: TLabel
    Left = 504
    Top = 13
    Width = 32
    Height = 13
    Caption = #1056#1077#1078#1080#1084
  end
  object BufSizeCB: TComboBox
    Left = 304
    Top = 32
    Width = 169
    Height = 21
    TabOrder = 0
    Text = '128'
    Items.Strings = (
      '128'
      '255'
      '510'
      '1023'
      '2046'
      '4095'
      '6141')
  end
  object PeriodSE: TFloatSpinEdit
    Left = 152
    Top = 32
    Width = 121
    Height = 22
    Increment = 0.100000001490116100
    TabOrder = 1
    Value = 0.100000001490116100
  end
  object FreqFE: TFloatSpinEdit
    Left = 3
    Top = 32
    Width = 121
    Height = 22
    Increment = 0.100000001490116100
    TabOrder = 2
    Value = 10000.000000000000000000
  end
  object ModeCB: TComboBox
    Left = 504
    Top = 32
    Width = 169
    Height = 21
    ItemIndex = 0
    TabOrder = 3
    Text = #1057#1080#1085#1093#1088#1086#1085#1085#1099#1081
    Items.Strings = (
      #1057#1080#1085#1093#1088#1086#1085#1085#1099#1081
      #1040#1089#1080#1085#1093#1088#1086#1085#1085#1099#1081)
  end
end
