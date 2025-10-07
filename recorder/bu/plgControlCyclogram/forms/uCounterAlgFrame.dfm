inherited CounterAlgFrame: TCounterAlgFrame
  Width = 481
  Height = 334
  Constraints.MinHeight = 226
  Constraints.MinWidth = 302
  object ThresholdLabel1: TLabel [1]
    Left = 9
    Top = 98
    Width = 83
    Height = 16
    Caption = #1053#1080#1078#1085#1080#1081' '#1087#1086#1088#1086#1075
  end
  object ThresholdLabel2: TLabel [2]
    Left = 144
    Top = 98
    Width = 85
    Height = 16
    Caption = #1042#1077#1088#1093#1085#1080#1081' '#1087#1086#1088#1086#1075
  end
  object ChannelLabel: TLabel [4]
    Left = 9
    Top = 234
    Width = 35
    Height = 16
    Caption = #1050#1072#1085#1072#1083
  end
  object OutLabel: TLabel [5]
    Left = 169
    Top = 234
    Width = 36
    Height = 16
    Caption = #1042#1099#1093#1086#1076
  end
  object LabelMinThreshold: TLabel [6]
    Left = 279
    Top = 98
    Width = 120
    Height = 16
    Caption = #1052#1080#1085#1080#1084#1072#1083#1100#1085#1099#1081' '#1087#1086#1088#1086#1075
  end
  object TrigChanLabel: TLabel [7]
    Left = 9
    Top = 182
    Width = 111
    Height = 16
    Caption = #1050#1072#1085#1072#1083' '#1088#1072#1079#1088#1077#1096#1077#1085#1080#1103
  end
  object ZeroChanLabel: TLabel [8]
    Left = 144
    Top = 182
    Width = 101
    Height = 16
    Caption = #1050#1072#1085#1072#1083' '#1086#1073#1085#1091#1083#1077#1085#1080#1103
  end
  object ShiftChanLabel: TLabel [9]
    Left = 279
    Top = 182
    Width = 62
    Height = 16
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077
  end
  inherited AlgNameEdit: TEdit
    Width = 459
  end
  inherited OptsEdit: TEdit
    Width = 459
    TabOrder = 3
  end
  object LoThresholdSE: TFloatSpinEdit
    Left = 9
    Top = 120
    Width = 121
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 1
    OnChange = LoThresholdSEChange
  end
  object HiThresholdSE: TFloatSpinEdit
    Left = 144
    Top = 120
    Width = 121
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 2
    OnChange = HiThresholdSEChange
  end
  object ChannelCB: TRcComboBox
    Left = 9
    Top = 256
    Width = 145
    Height = 24
    TabOrder = 4
    OnChange = ChannelCBChange
  end
  object OutChannelName: TEdit
    Left = 160
    Top = 256
    Width = 307
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 5
  end
  object MinThresholdSE: TFloatSpinEdit
    Left = 279
    Top = 120
    Width = 121
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 6
    OnChange = HiThresholdSEChange
  end
  object TrigCB: TRcComboBox
    Left = 9
    Top = 204
    Width = 121
    Height = 24
    Hint = #1045#1089#1083#1080' '#1082#1072#1085#1072#1083' '#1088#1072#1074#1077#1085' 0, '#1090#1086' '#1088#1072#1089#1095#1077#1090' '#1085#1077' '#1080#1076#1077#1090
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    Text = 'TrigCB'
  end
  object NullTagCB: TRcComboBox
    Left = 144
    Top = 204
    Width = 121
    Height = 24
    Hint = #1045#1089#1083#1080' '#1082#1072#1085#1072#1083' '#1088#1072#1074#1077#1085' 0, '#1090#1086' '#1088#1072#1089#1095#1077#1090' '#1085#1077' '#1080#1076#1077#1090
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    Text = 'TrigCB'
  end
  object SaveOnStartCb: TCheckBox
    Left = 279
    Top = 160
    Width = 188
    Height = 17
    Caption = #1057#1086#1093#1088#1072#1085#1103#1090#1100' '#1087#1088#1080' '#1057#1090#1072#1088#1090'/'#1057#1090#1086#1087
    TabOrder = 9
  end
  object ShiftTagCB: TRcComboBox
    Left = 279
    Top = 204
    Width = 121
    Height = 24
    Hint = #1045#1089#1083#1080' '#1082#1072#1085#1072#1083' '#1088#1072#1074#1077#1085' 0, '#1090#1086' '#1088#1072#1089#1095#1077#1090' '#1085#1077' '#1080#1076#1077#1090
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
    Text = 'TrigCB'
  end
end
