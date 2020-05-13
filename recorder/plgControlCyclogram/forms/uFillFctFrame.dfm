inherited FillFctFrame: TFillFctFrame
  object ThresholdLabel1: TLabel [2]
    Left = 9
    Top = 98
    Width = 30
    Height = 13
    Caption = #1055#1086#1088#1086#1075
  end
  object ChannelLabel: TLabel [3]
    Left = 9
    Top = 170
    Width = 31
    Height = 13
    Caption = #1050#1072#1085#1072#1083
  end
  object Label1: TLabel [4]
    Left = 169
    Top = 170
    Width = 33
    Height = 13
    Caption = #1042#1099#1093#1086#1076
  end
  object FsLabel: TLabel [5]
    Left = 160
    Top = 98
    Width = 42
    Height = 13
    Caption = #1063#1072#1089#1090#1086#1090#1072
  end
  inherited OptsEdit: TEdit
    Top = 69
    ExplicitTop = 69
  end
  object ThresholdSE: TFloatSpinEdit
    Left = 9
    Top = 120
    Width = 121
    Height = 22
    Increment = 0.100000000000000000
    TabOrder = 2
    Value = 0.500000000000000000
    OnChange = ThresholdSEChange
  end
  object ChannelCB: TRcComboBox
    Left = 9
    Top = 192
    Width = 120
    Height = 21
    TabOrder = 3
    OnChange = ChannelCBChange
  end
  object OutChannelName: TEdit
    Left = 160
    Top = 192
    Width = 277
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 4
  end
  object FsSE: TFloatSpinEdit
    Left = 160
    Top = 120
    Width = 121
    Height = 22
    Increment = 0.100000000000000000
    TabOrder = 5
    Value = 0.100000000000000000
    OnChange = FsSEChange
  end
end
