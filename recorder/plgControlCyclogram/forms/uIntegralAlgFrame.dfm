inherited IntegralAlgFrame: TIntegralAlgFrame
  Constraints.MinHeight = 226
  Constraints.MinWidth = 302
  object ThresholdLabel1: TLabel [1]
    Left = 9
    Top = 98
    Width = 71
    Height = 13
    Caption = #1053#1080#1078#1085#1080#1081' '#1087#1086#1088#1086#1075
  end
  object ChannelLabel: TLabel [3]
    Left = 9
    Top = 282
    Width = 31
    Height = 13
    Caption = #1050#1072#1085#1072#1083
  end
  object Label1: TLabel [4]
    Left = 173
    Top = 282
    Width = 33
    Height = 13
    Caption = #1042#1099#1093#1086#1076
  end
  object FltCountLabel: TLabel [5]
    Left = 175
    Top = 163
    Width = 63
    Height = 13
    Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082
  end
  object ShiftLabel: TLabel [6]
    Left = 175
    Top = 211
    Width = 52
    Height = 13
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077
  end
  inherited AlgNameEdit: TEdit
    Height = 21
    ExplicitHeight = 21
  end
  inherited OptsEdit: TEdit
    Height = 21
    TabOrder = 2
    ExplicitHeight = 21
  end
  object LoThresholdSE: TFloatSpinEdit
    Left = 9
    Top = 120
    Width = 121
    Height = 22
    Hint = 
      #1045#1089#1083#1080' '#1076#1074#1072'  '#1072#1073#1089#1086#1083#1102#1090#1085#1099#1077' '#1079#1085#1072#1095#1077#1085#1080#1103' '#1084#1077#1085#1100#1096#1077' '#1087#1086#1088#1086#1075#1086#1074#1086#1075#1086' '#1079#1085#1072#1095#1077#1085#1080#1103' '#1090#1086' '#1080#1085#1090#1077 +
      #1075#1088#1072#1083' '#1087#1088#1080#1088#1072#1074#1085#1080#1074#1072#1077#1090#1089#1103' '#1085#1091#1083#1102
    Increment = 0.100000000000000000
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnChange = LoThresholdSEChange
  end
  object ChannelCB: TRcComboBox
    Left = 9
    Top = 304
    Width = 145
    Height = 21
    TabOrder = 3
    OnChange = ChannelCBChange
  end
  object OutChannelName: TEdit
    Left = 173
    Top = 304
    Width = 264
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 4
  end
  object FltRG: TRadioGroup
    Left = 9
    Top = 163
    Width = 160
    Height = 110
    Caption = #1060#1080#1083#1100#1090#1088#1072#1094#1080#1103
    TabOrder = 5
    OnClick = FltRGClick
  end
  object FltCountEdit: TIntEdit
    Left = 173
    Top = 182
    Width = 121
    Height = 21
    TabOrder = 6
    Text = '10'
  end
  object ShiftIE: TIntEdit
    Left = 175
    Top = 230
    Width = 121
    Height = 21
    TabOrder = 7
    Text = '10'
  end
  object SpinBtn: TSpinButton
    Left = 300
    Top = 178
    Width = 20
    Height = 25
    DownGlyph.Data = {
      0E010000424D0E01000000000000360000002800000009000000060000000100
      200000000000D800000000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000008080000080800000808000000000000080800000808000008080000080
      8000008080000080800000808000000000000000000000000000008080000080
      8000008080000080800000808000000000000000000000000000000000000000
      0000008080000080800000808000000000000000000000000000000000000000
      0000000000000000000000808000008080000080800000808000008080000080
      800000808000008080000080800000808000}
    TabOrder = 8
    UpGlyph.Data = {
      0E010000424D0E01000000000000360000002800000009000000060000000100
      200000000000D800000000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000000000000000000000000000000000000000000000000000000000000080
      8000008080000080800000000000000000000000000000000000000000000080
      8000008080000080800000808000008080000000000000000000000000000080
      8000008080000080800000808000008080000080800000808000000000000080
      8000008080000080800000808000008080000080800000808000008080000080
      800000808000008080000080800000808000}
    OnDownClick = SpinBtnDownClick
    OnUpClick = SpinBtnUpClick
  end
end
