inherited CounterAlgFrame: TCounterAlgFrame
  Width = 439
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
    Top = 170
    Width = 35
    Height = 16
    Caption = #1050#1072#1085#1072#1083
  end
  object Label1: TLabel [5]
    Left = 169
    Top = 170
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
  inherited AlgNameEdit: TEdit
    Width = 417
  end
  inherited OptsEdit: TEdit
    Width = 417
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
    Top = 192
    Width = 145
    Height = 24
    TabOrder = 4
    OnChange = ChannelCBChange
  end
  object OutChannelName: TEdit
    Left = 160
    Top = 192
    Width = 265
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 5
    ExplicitWidth = 277
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
end
