object BaseAlgOptsFrame: TBaseAlgOptsFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 599
  Align = alTop
  Constraints.MinHeight = 399
  Constraints.MinWidth = 451
  TabOrder = 0
  object StageGB: TGroupBox
    Left = 0
    Top = 227
    Width = 451
    Height = 218
    Align = alTop
    Caption = #1057#1090#1091#1087#1077#1085#1100
    TabOrder = 0
    object StageCB: TComboBox
      Left = 3
      Top = 20
      Width = 134
      Height = 21
      TabOrder = 0
    end
    object ValidBladeGB: TGroupBox
      Left = 2
      Top = 56
      Width = 447
      Height = 160
      Align = alBottom
      Caption = #1060#1080#1083#1100#1090#1088#1072#1094#1080#1103' '#1086#1073#1086#1088#1086#1090#1086#1074
      TabOrder = 1
      object ThresholdLabel: TLabel
        Left = 9
        Top = 42
        Width = 121
        Height = 13
        Caption = #1047#1085#1072#1095#1077#1085#1080#1077' '#1087#1086#1088#1086#1075#1072', '#1075#1088#1072#1076'.'
      end
      object UseThresholdCB: TCheckBox
        Left = 9
        Top = 20
        Width = 126
        Height = 17
        Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1087#1086#1088#1086#1075#1080
        TabOrder = 0
      end
      object ThresholdSE: TFloatSpinEdit
        Left = 9
        Top = 58
        Width = 121
        Height = 22
        Increment = 0.100000001490116100
        TabOrder = 1
      end
      object UseEvalSkipBlades: TCheckBox
        Left = 9
        Top = 97
        Width = 119
        Height = 17
        Hint = 
          #1056#1072#1089#1095#1080#1090#1099#1074#1072#1090#1100' '#1095#1080#1089#1083#1086' '#1087#1088#1086#1087#1091#1089#1082#1086#1074' '#1087#1086' '#1088#1072#1089#1090#1086#1103#1085#1080#1102' '#1084#1077#1078#1076#1091' '#1080#1084#1087#1091#1083#1100#1089#1072#1084#1080'. '#1045#1089#1083#1080' ' +
          #1083#1086#1087#1072#1090#1082#1080' '#1088#1072#1089#1087#1086#1083#1086#1078#1077#1085#1099' '#1085#1077' '#1088#1077#1075#1091#1083#1103#1088#1085#1086' '#1090#1086' '#1085#1077#1086#1073#1093#1086#1076#1080#1084#1086' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1072#1087#1088#1080 +
          #1086#1088#1085#1091#1102' '#1092#1086#1088#1084#1091' '#1080' '#1087#1088#1072#1074#1080#1083#1100#1085#1086' '#1089#1095#1080#1090#1072#1090#1100' '#1087#1088#1086#1087#1091#1089#1082' '#1083#1086#1087#1072#1090#1086#1082' '#1095#1090#1086#1073' '#1088#1072#1073#1086#1090#1072#1083#1086'!!!'
        Caption = #1056#1072#1089#1095#1077#1090' '#1087#1088#1086#1087#1091#1089#1082#1086#1074
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
      end
      object UseBadTickProcCheckBox: TCheckBox
        Left = 9
        Top = 119
        Width = 232
        Height = 17
        Caption = #1042#1099#1079#1099#1074#1072#1090#1100' '#1086#1073#1088#1072#1073#1086#1090#1082#1091' '#1089#1073#1086#1081#1085#1099#1093' '#1086#1073#1086#1088#1086#1090#1086#1074
        TabOrder = 3
      end
      object UseBladesPos: TRadioGroup
        Left = 242
        Top = 15
        Width = 203
        Height = 143
        Align = alRight
        Items.Strings = (
          #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1089#1084#1077#1097#1077#1085#1080#1103
          #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1087#1086#1083#1086#1078#1077#1085#1080#1103' '#1083#1086#1087#1072#1090#1086#1082)
        TabOrder = 4
        Visible = False
      end
    end
  end
  object CommonGB: TGroupBox
    Left = 0
    Top = 0
    Width = 451
    Height = 227
    Align = alTop
    TabOrder = 1
    object SensorNameLabel: TLabel
      Left = 2
      Top = 8
      Width = 65
      Height = 13
      Caption = #1048#1084#1103' '#1076#1072#1090#1095#1080#1082#1072
    end
    object TahoNameLabel: TLabel
      Left = 6
      Top = 96
      Width = 92
      Height = 13
      Caption = #1048#1084#1103' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072
    end
    object SkipBladeLabel: TLabel
      Left = 3
      Top = 49
      Width = 105
      Height = 13
      Caption = #1055#1088#1086#1087#1091#1089#1090#1080#1090#1100' '#1083#1086#1087#1072#1090#1086#1082
    end
    object StartTimeLabel: TLabel
      Left = 244
      Top = 49
      Width = 49
      Height = 13
      Caption = #1053#1072#1095#1072#1083#1086', '#1089
    end
    object EndTimeLabel: TLabel
      Left = 244
      Top = 90
      Width = 43
      Height = 13
      Caption = #1050#1086#1085#1077#1094', '#1089
    end
    object ImpulseCountLabel: TLabel
      Left = 244
      Top = 131
      Width = 132
      Height = 13
      Caption = #1063#1080#1089#1083#1086' '#1080#1084#1087#1091#1083#1100#1089#1086#1074' '#1076#1072#1090#1095#1080#1082#1072
    end
    object TahoCB: TComboBox
      Left = 3
      Top = 115
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object SkipBladeIE: TIntEdit
      Left = 2
      Top = 68
      Width = 133
      Height = 21
      Enabled = False
      TabOrder = 1
      Text = '000'
    end
    object SensorsNameCB: TComboBox
      Left = 3
      Top = 27
      Width = 132
      Height = 21
      TabOrder = 2
      OnChange = SensorsNameCBChange
    end
    object UseStageInfoCheckBox: TCheckBox
      Left = 3
      Top = 154
      Width = 224
      Height = 17
      Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1072#1087#1088#1080#1086#1088#1085#1091#1102' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1102
      TabOrder = 3
      OnClick = UseStageInfoCheckBoxClick
    end
    object SelectSensorsBtn: TButton
      Left = 141
      Top = 27
      Width = 50
      Height = 21
      Caption = '...'
      TabOrder = 4
      OnClick = SelectSensorsBtnClick
    end
    object StartTimeFE: TFloatSpinEdit
      Left = 244
      Top = 65
      Width = 121
      Height = 22
      Increment = 0.100000001490116100
      TabOrder = 5
      OnChange = StartTimeFEChange
    end
    object EndTimeFE: TFloatSpinEdit
      Left = 244
      Top = 106
      Width = 121
      Height = 22
      Increment = 0.100000001490116100
      TabOrder = 6
      OnChange = StartTimeFEChange
    end
    object ImpulseCountIE: TIntEdit
      Left = 244
      Top = 150
      Width = 121
      Height = 21
      TabOrder = 7
      Text = '000'
    end
    object SyncCB: TCheckBox
      Left = 244
      Top = 26
      Width = 224
      Height = 17
      Caption = #1057#1080#1085#1093#1088#1086#1085#1080#1079#1072#1094#1080#1103' '#1089' '#1082#1091#1088#1089#1086#1088#1086#1084
      TabOrder = 8
      OnClick = SyncCBClick
    end
    object MeraFileCB: TCheckBox
      Left = 3
      Top = 186
      Width = 129
      Height = 17
      Caption = #1047#1072#1087#1080#1089#1100' '#1074' Mera '#1092#1072#1081#1083
      TabOrder = 9
      OnClick = MeraFileCBClick
    end
    object UseUTSCB: TCheckBox
      Left = 244
      Top = 186
      Width = 121
      Height = 17
      Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1057#1045#1042
      TabOrder = 10
      OnClick = MeraFileCBClick
    end
  end
  object TagsGB: TGroupBox
    Left = 0
    Top = 445
    Width = 451
    Height = 154
    Align = alClient
    TabOrder = 2
    OnClick = TagsGBClick
    inline AlgTagList1: TAlgTagListFrame
      Left = 2
      Top = 15
      Width = 447
      Height = 137
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 447
      ExplicitHeight = 137
      inherited TagListLV: TBtnListView
        Height = 249
        ExplicitHeight = 249
      end
    end
  end
end
