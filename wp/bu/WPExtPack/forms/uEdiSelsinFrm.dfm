object EditSelsinFrm: TEditSelsinFrm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1089#1077#1083#1100#1089#1080#1085#1072
  ClientHeight = 501
  ClientWidth = 475
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label6: TLabel
    Left = 8
    Top = 98
    Width = 15
    Height = 13
    Caption = 'L1:'
  end
  object Label7: TLabel
    Left = 159
    Top = 98
    Width = 15
    Height = 13
    Caption = 'L2:'
  end
  object Label1: TLabel
    Left = 310
    Top = 98
    Width = 15
    Height = 13
    Caption = 'L3:'
  end
  object Label12: TLabel
    Left = 8
    Top = 393
    Width = 87
    Height = 13
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1087#1080#1090#1072#1085#1080#1103
  end
  object Label2: TLabel
    Left = 9
    Top = 327
    Width = 47
    Height = 13
    Caption = #1055#1080#1090#1072#1085#1080#1077':'
  end
  object Label4: TLabel
    Left = 8
    Top = 29
    Width = 65
    Height = 13
    Caption = #1048#1084#1103' '#1076#1072#1090#1095#1080#1082#1072
  end
  object Label5: TLabel
    Left = 183
    Top = 331
    Width = 106
    Height = 13
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1089#1077#1082#1090#1086#1088#1086#1074':'
  end
  object L1CB: TComboBox
    Left = 8
    Top = 119
    Width = 145
    Height = 21
    TabOrder = 0
    Text = 'L1CB'
  end
  object L2CB: TComboBox
    Left = 159
    Top = 119
    Width = 145
    Height = 21
    TabOrder = 1
    Text = 'X1CB'
  end
  object L3CB: TComboBox
    Left = 310
    Top = 119
    Width = 145
    Height = 21
    TabOrder = 2
    Text = 'X1CB'
  end
  object ExcFreqEdit: TFloatEdit
    Left = 8
    Top = 412
    Width = 145
    Height = 21
    ReadOnly = True
    TabOrder = 3
    Text = '402'
  end
  object ExcCB: TComboBox
    Left = 8
    Top = 350
    Width = 145
    Height = 21
    TabOrder = 4
    Text = 'X1CB'
  end
  object NameEdit: TEdit
    Left = 8
    Top = 48
    Width = 457
    Height = 21
    TabOrder = 5
    Text = 'NameEdit'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 163
    Width = 457
    Height = 142
    Caption = #1050#1072#1083#1080#1073#1088#1086#1074#1082#1072' '#1072#1084#1087#1083#1080#1090#1091#1076' '#1092#1072#1079#1085#1099#1093' '#1085#1072#1087#1088#1103#1078#1077#1085#1080#1081
    Color = clMedGray
    ParentBackground = False
    ParentColor = False
    TabOrder = 6
    object SKO1Label: TLabel
      Left = 17
      Top = 49
      Width = 28
      Height = 13
      Caption = #1057#1050#1054'1'
    end
    object Label8: TLabel
      Left = 111
      Top = 65
      Width = 20
      Height = 13
      Caption = 'Max'
    end
    object Label9: TLabel
      Left = 111
      Top = 92
      Width = 16
      Height = 13
      Caption = 'Min'
    end
    object SKO2Label: TLabel
      Left = 162
      Top = 49
      Width = 28
      Height = 13
      Caption = #1057#1050#1054'2'
    end
    object Label11: TLabel
      Left = 259
      Top = 65
      Width = 20
      Height = 13
      Caption = 'Max'
    end
    object Label13: TLabel
      Left = 259
      Top = 92
      Width = 16
      Height = 13
      Caption = 'Min'
    end
    object SKO3Label: TLabel
      Left = 313
      Top = 49
      Width = 28
      Height = 13
      Caption = #1057#1050#1054'3'
    end
    object Label15: TLabel
      Left = 410
      Top = 65
      Width = 20
      Height = 13
      Caption = 'Max'
    end
    object Label16: TLabel
      Left = 410
      Top = 92
      Width = 16
      Height = 13
      Caption = 'Min'
    end
    object SKOMax1: TFloatEdit
      Left = 11
      Top = 62
      Width = 91
      Height = 21
      TabOrder = 0
      Text = '0.1'
    end
    object SKOMin1: TFloatEdit
      Left = 11
      Top = 89
      Width = 91
      Height = 21
      TabOrder = 1
      Text = '0.1'
    end
    object SKOMax2: TFloatEdit
      Left = 162
      Top = 62
      Width = 91
      Height = 21
      TabOrder = 2
      Text = '0.1'
    end
    object SKOMin2: TFloatEdit
      Left = 162
      Top = 89
      Width = 91
      Height = 21
      TabOrder = 3
      Text = '0.1'
    end
    object SKOMax3: TFloatEdit
      Left = 313
      Top = 62
      Width = 91
      Height = 21
      TabOrder = 4
      Text = '0.1'
    end
    object SKOMin3: TFloatEdit
      Left = 313
      Top = 89
      Width = 91
      Height = 21
      TabOrder = 5
      Text = '0.1'
    end
    object AutoCalibrCB: TCheckBox
      Left = 11
      Top = 26
      Width = 120
      Height = 17
      Caption = #1040#1074#1090#1086#1082#1072#1083#1080#1073#1088#1086#1074#1082#1072
      TabOrder = 6
    end
  end
  object ShiftSectr: TSpinEdit
    Left = 183
    Top = 350
    Width = 121
    Height = 22
    MaxValue = 5
    MinValue = 0
    TabOrder = 7
    Value = 0
  end
end
