object pairShapeFrame: TpairShapeFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object Label1: TLabel
    Left = 3
    Top = 81
    Width = 129
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088' '#1087#1086#1088#1094#1080#1080' ('#1086#1073#1086#1088#1086#1090#1099')'
  end
  object SkipBladeLabel: TLabel
    Left = 3
    Top = 7
    Width = 105
    Height = 13
    Caption = #1055#1088#1086#1087#1091#1089#1090#1080#1090#1100' '#1083#1086#1087#1072#1090#1086#1082
  end
  object PortionSE: TSpinEdit
    Left = 3
    Top = 100
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 0
    Value = 30
  end
  object SkipBladeSE: TSpinEdit
    Left = 3
    Top = 26
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
  end
  object EvalPortionCB: TCheckBox
    Left = 3
    Top = 54
    Width = 147
    Height = 17
    Caption = #1042#1099#1095#1080#1089#1083#1103#1090#1100' '#1088#1072#1079#1084#1077#1088' '#1087#1086#1088#1094#1080#1080
    TabOrder = 2
    OnClick = EvalPortionCBClick
  end
end
