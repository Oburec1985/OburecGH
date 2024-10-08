object SinFrame: TSinFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Constraints.MinHeight = 257
  Constraints.MinWidth = 431
  TabOrder = 0
  DesignSize = (
    451
    304)
  object FreqLabel: TLabel
    Left = 3
    Top = 3
    Width = 69
    Height = 16
    Caption = #1063#1072#1089#1090#1086#1090#1072', '#1043#1094
  end
  object EndFreqLabel: TLabel
    Left = 3
    Top = 85
    Width = 128
    Height = 16
    Caption = #1050#1086#1085#1077#1095#1085#1072#1103' '#1095#1072#1089#1090#1086#1090#1072', '#1043#1094
  end
  object PhaseLabel: TLabel
    Left = 219
    Top = 5
    Width = 64
    Height = 16
    Caption = #1060#1072#1079#1072', '#1075#1088#1072#1076
  end
  object EndPhaseLabel: TLabel
    Left = 219
    Top = 85
    Width = 124
    Height = 16
    Caption = #1050#1086#1085#1077#1095#1085#1072#1103' '#1092#1072#1079#1072', '#1075#1088#1072#1076
  end
  object DscLabel: TLabel
    Left = 3
    Top = 261
    Width = 57
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077
  end
  object FreqPeriodLabel: TLabel
    Left = 3
    Top = 164
    Width = 104
    Height = 16
    Caption = #1055#1077#1088#1080#1086#1076#1080#1095#1085#1086#1089#1090#1100', '#1089
  end
  object PhasePeriodLabel: TLabel
    Left = 219
    Top = 164
    Width = 104
    Height = 16
    Caption = #1055#1077#1088#1080#1086#1076#1080#1095#1085#1086#1089#1090#1100', '#1089
  end
  object ALabel: TLabel
    Left = 459
    Top = 5
    Width = 63
    Height = 16
    Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072
  end
  object EndALabel: TLabel
    Left = 459
    Top = 85
    Width = 122
    Height = 16
    Caption = #1050#1086#1085#1077#1095#1085#1072#1103' '#1072#1084#1087#1083#1080#1090#1091#1076#1072
  end
  object PeriodALabel: TLabel
    Left = 459
    Top = 164
    Width = 104
    Height = 16
    Caption = #1055#1077#1088#1080#1086#1076#1080#1095#1085#1086#1089#1090#1100', '#1089
  end
  object Label1: TLabel
    Left = 659
    Top = 5
    Width = 147
    Height = 16
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100' '#1089#1080#1075#1085#1072#1083#1072', '#1089
  end
  object FreqFE: TFloatEdit
    Left = 3
    Top = 24
    Width = 121
    Height = 24
    TabOrder = 0
    Text = '1000'
  end
  object EndFreqFE: TFloatEdit
    Left = 3
    Top = 104
    Width = 121
    Height = 24
    TabOrder = 1
    Text = '1100'
  end
  object ChangeFreqCB: TCheckBox
    Left = 3
    Top = 56
    Width = 128
    Height = 17
    Caption = #1052#1077#1085#1103#1090#1100' '#1095#1072#1089#1090#1086#1090#1091
    TabOrder = 2
    OnClick = ChangePeriodFreqCBClick
  end
  object PhaseEdit: TFloatEdit
    Left = 219
    Top = 24
    Width = 121
    Height = 24
    TabOrder = 3
    Text = '0'
  end
  object EndPhaseEdit: TFloatEdit
    Left = 219
    Top = 104
    Width = 121
    Height = 24
    TabOrder = 4
    Text = '90'
  end
  object ChangePhaseCB: TCheckBox
    Left = 219
    Top = 56
    Width = 97
    Height = 17
    Caption = #1052#1077#1085#1103#1090#1100' '#1092#1072#1079#1091
    TabOrder = 5
    OnClick = ChangePhaseCBClick
  end
  object DscEdit: TEdit
    Left = 3
    Top = 280
    Width = 445
    Height = 24
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 6
    Text = 'DscEdit'
  end
  object ChangePeriodFreqCB: TCheckBox
    Left = 3
    Top = 140
    Width = 208
    Height = 17
    Caption = #1053#1077#1087#1088#1077#1088#1099#1074#1085#1086'('#1074#1099#1082#1083'.)/'#1057#1082#1072#1095#1082#1072#1084#1080'('#1074#1082#1083'.)'
    TabOrder = 7
    OnClick = ChangePeriodFreqCBClick
  end
  object FreqPeriodFE: TFloatEdit
    Left = 3
    Top = 183
    Width = 121
    Height = 24
    TabOrder = 8
    Text = '1100'
  end
  object ChangePeriodPhaseCB: TCheckBox
    Left = 219
    Top = 140
    Width = 208
    Height = 17
    Caption = #1053#1077#1087#1088#1077#1088#1099#1074#1085#1086'('#1074#1099#1082#1083'.)/'#1057#1082#1072#1095#1082#1072#1084#1080'('#1074#1082#1083'.)'
    TabOrder = 9
    OnClick = ChangePhaseCBClick
  end
  object PhasePeriodFE: TFloatEdit
    Left = 219
    Top = 183
    Width = 121
    Height = 24
    TabOrder = 10
    Text = '1100'
  end
  object AFE: TFloatEdit
    Left = 459
    Top = 24
    Width = 121
    Height = 24
    TabOrder = 11
    Text = '1'
  end
  object EndAFE: TFloatEdit
    Left = 459
    Top = 104
    Width = 121
    Height = 24
    TabOrder = 12
    Text = '90'
  end
  object ChangeACB: TCheckBox
    Left = 459
    Top = 56
    Width = 97
    Height = 17
    Caption = #1052#1077#1085#1103#1090#1100' '#1072#1084#1087#1083#1080#1090#1091#1076#1091
    TabOrder = 13
    OnClick = ChangeACBClick
  end
  object ChangePeriodACB: TCheckBox
    Left = 459
    Top = 140
    Width = 208
    Height = 17
    Caption = #1053#1077#1087#1088#1077#1088#1099#1074#1085#1086'('#1074#1099#1082#1083'.)/'#1057#1082#1072#1095#1082#1072#1084#1080'('#1074#1082#1083'.)'
    TabOrder = 14
    OnClick = ChangeACBClick
  end
  object PeriodAFE: TFloatEdit
    Left = 459
    Top = 183
    Width = 121
    Height = 24
    TabOrder = 15
    Text = '1100'
  end
  object TimeLengthFE: TFloatEdit
    Left = 659
    Top = 24
    Width = 128
    Height = 24
    TabOrder = 16
    Text = '0.1'
  end
end
