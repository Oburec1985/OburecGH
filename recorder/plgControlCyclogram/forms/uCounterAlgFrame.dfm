inherited CounterAlgFrame: TCounterAlgFrame
  Constraints.MinHeight = 226
  Constraints.MinWidth = 302
  object ThresholdLabel1: TLabel [1]
    Left = 9
    Top = 98
    Width = 71
    Height = 13
    Caption = #1053#1080#1078#1085#1080#1081' '#1087#1086#1088#1086#1075
  end
  object ThresholdLabel2: TLabel [2]
    Left = 144
    Top = 98
    Width = 74
    Height = 13
    Caption = #1042#1077#1088#1093#1085#1080#1081' '#1087#1086#1088#1086#1075
  end
  object ChannelLabel: TLabel [4]
    Left = 9
    Top = 218
    Width = 31
    Height = 13
    Caption = #1050#1072#1085#1072#1083
  end
  object Label1: TLabel [5]
    Left = 169
    Top = 218
    Width = 33
    Height = 13
    Caption = #1042#1099#1093#1086#1076
  end
  object LabelMinThreshold: TLabel [6]
    Left = 279
    Top = 98
    Width = 102
    Height = 13
    Caption = #1052#1080#1085#1080#1084#1072#1083#1100#1085#1099#1081' '#1087#1086#1088#1086#1075
  end
  object Label2: TLabel [7]
    Left = 9
    Top = 166
    Width = 95
    Height = 13
    Caption = #1050#1072#1085#1072#1083' '#1088#1072#1079#1088#1077#1096#1077#1085#1080#1103
  end
  object Label3: TLabel [8]
    Left = 144
    Top = 166
    Width = 88
    Height = 13
    Caption = #1050#1072#1085#1072#1083' '#1086#1073#1085#1091#1083#1077#1085#1080#1103
  end
  inherited AlgNameEdit: TEdit
    Height = 21
    ExplicitHeight = 21
  end
  inherited OptsEdit: TEdit
    Height = 21
    TabOrder = 3
    ExplicitHeight = 21
  end
  object LoThresholdSE: TFloatSpinEdit
    Left = 9
    Top = 120
    Width = 121
    Height = 22
    Increment = 0.100000000000000000
    TabOrder = 1
    OnChange = LoThresholdSEChange
  end
  object HiThresholdSE: TFloatSpinEdit
    Left = 144
    Top = 120
    Width = 121
    Height = 22
    Increment = 0.100000000000000000
    TabOrder = 2
    OnChange = HiThresholdSEChange
  end
  object ChannelCB: TRcComboBox
    Left = 9
    Top = 240
    Width = 145
    Height = 21
    TabOrder = 4
    OnChange = ChannelCBChange
  end
  object OutChannelName: TEdit
    Left = 160
    Top = 240
    Width = 277
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 5
  end
  object MinThresholdSE: TFloatSpinEdit
    Left = 279
    Top = 120
    Width = 121
    Height = 22
    Increment = 0.100000000000000000
    TabOrder = 6
    OnChange = HiThresholdSEChange
  end
  object TrigCB: TRcComboBox
    Left = 9
    Top = 188
    Width = 121
    Height = 21
    Hint = #1045#1089#1083#1080' '#1082#1072#1085#1072#1083' '#1088#1072#1074#1077#1085' 0, '#1090#1086' '#1088#1072#1089#1095#1077#1090' '#1085#1077' '#1080#1076#1077#1090
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    Text = 'TrigCB'
  end
  object NullTagCB: TRcComboBox
    Left = 144
    Top = 188
    Width = 121
    Height = 21
    Hint = #1045#1089#1083#1080' '#1082#1072#1085#1072#1083' '#1088#1072#1074#1077#1085' 0, '#1090#1086' '#1088#1072#1089#1095#1077#1090' '#1085#1077' '#1080#1076#1077#1090
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    Text = 'TrigCB'
  end
  object SaveOnStartCb: TCheckBox
    Left = 279
    Top = 190
    Width = 169
    Height = 17
    Caption = #1057#1086#1093#1088#1072#1085#1103#1090#1100' '#1087#1088#1080' '#1057#1090#1072#1088#1090'/'#1057#1090#1086#1087
    TabOrder = 9
  end
end
