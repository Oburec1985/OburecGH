object EditAlarmFrame: TEditAlarmFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 235
  Align = alClient
  Constraints.MinHeight = 235
  TabOrder = 0
  ExplicitHeight = 304
  DesignSize = (
    451
    235)
  object ThresholdLabel: TLabel
    Left = 5
    Top = 61
    Width = 92
    Height = 13
    Caption = #1047#1085#1072#1095#1077#1085#1080#1077' '#1091#1089#1090#1072#1074#1082#1080
  end
  object DSCLabel: TLabel
    Left = 5
    Top = 161
    Width = 49
    Height = 13
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077
  end
  object ColorLabel: TLabel
    Left = 5
    Top = 109
    Width = 26
    Height = 13
    Caption = #1062#1074#1077#1090
  end
  object GisterezisLabel: TLabel
    Left = 132
    Top = 61
    Width = 75
    Height = 13
    Caption = #1043#1080#1089#1090#1077#1088#1077#1079#1080#1089', %'
  end
  object NameLabel: TLabel
    Left = 3
    Top = 10
    Width = 65
    Height = 13
    Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072
  end
  object TypeLabel: TLabel
    Left = 130
    Top = 10
    Width = 64
    Height = 13
    Caption = #1058#1080#1087' '#1086#1073#1098#1077#1082#1090#1072
  end
  object TypeImage: TImage
    Left = 258
    Top = 18
    Width = 32
    Height = 32
    Transparent = True
  end
  object ThresholdSE: TFloatSpinEdit
    Left = 5
    Top = 80
    Width = 119
    Height = 22
    Increment = 0.100000001490116100
    TabOrder = 0
  end
  object DSCEdit: TEdit
    Left = 5
    Top = 180
    Width = 443
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object ColorBox: TColorBox
    Left = 5
    Top = 128
    Width = 119
    Height = 22
    ItemHeight = 16
    TabOrder = 2
  end
  object GisterezisSE: TSpinEdit
    Left = 131
    Top = 80
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object NameEdit: TEdit
    Left = 3
    Top = 29
    Width = 121
    Height = 21
    TabOrder = 4
  end
  object TypeCB: TComboBox
    Left = 130
    Top = 29
    Width = 122
    Height = 21
    ItemHeight = 13
    ItemIndex = 1
    TabOrder = 5
    Text = 'Hi Alarm'
    Items.Strings = (
      'Lo Alarm'
      'Hi Alarm')
  end
end
