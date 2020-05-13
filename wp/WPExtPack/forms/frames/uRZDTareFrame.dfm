object RZDTareFrame: TRZDTareFrame
  Left = 0
  Top = 0
  Width = 705
  Height = 232
  Constraints.MinHeight = 232
  Constraints.MinWidth = 701
  TabOrder = 0
  DesignSize = (
    705
    232)
  object T1Label: TLabel
    Left = 4
    Top = 207
    Width = 20
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'T1='
  end
  object T2Label: TLabel
    Left = 100
    Top = 206
    Width = 20
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'T2='
  end
  object Label1: TLabel
    Left = 354
    Top = 208
    Width = 20
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'T1='
  end
  object Label2: TLabel
    Left = 453
    Top = 207
    Width = 20
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'T2='
  end
  object Label3: TLabel
    Left = 34
    Top = 182
    Width = 110
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1048#1085#1090#1077#1088#1074#1072#1083' '#1086#1073#1088#1072#1073#1086#1090#1082#1080':'
  end
  object Label4: TLabel
    Left = 374
    Top = 183
    Width = 152
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1048#1085#1090#1077#1088#1074#1072#1083' "'#1074#1099#1095#1080#1089#1083#1077#1085#1080#1103' '#1085#1091#1083#1103'":'
  end
  object HFCbox: TComboBox
    Left = 1
    Top = 54
    Width = 697
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object Path: TComboBox
    Left = 1
    Top = 5
    Width = 672
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object S1Cbox: TComboBox
    Left = 1
    Top = 79
    Width = 697
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object S2Cbox: TComboBox
    Left = 1
    Top = 103
    Width = 697
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
  object S3Cbox: TComboBox
    Left = 1
    Top = 128
    Width = 697
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
  end
  object S4Cbox: TComboBox
    Left = 1
    Top = 153
    Width = 697
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
  end
  object VFCbox: TComboBox
    Left = 1
    Top = 29
    Width = 697
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 6
  end
  object PathBtn: TButton
    Left = 673
    Top = 7
    Width = 24
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 7
    OnClick = PathBtnClick
    ExplicitLeft = 669
  end
  object SelectIntervalCursorBtn: TButton
    Left = 206
    Top = 182
    Width = 128
    Height = 24
    Hint = #1042#1099#1073#1088#1072#1090#1100' '#1080#1085#1090#1077#1088#1074#1072#1083' '#1076#1083#1103' '#1074#1099#1095#1080#1089#1083#1077#1085#1080#1103' '#1084#1072#1090#1088#1080#1094#1099
    Anchors = [akLeft, akBottom]
    Caption = #1042#1099#1073#1088#1072#1090#1100' '#1087#1086' '#1082#1091#1088#1089#1086#1088#1091
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    OnClick = SelectIntervalCursorBtnClick
  end
  object T1FE: TFloatEdit
    Left = 34
    Top = 205
    Width = 68
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 9
    Text = '0.0'
  end
  object T2FE: TFloatEdit
    Left = 125
    Top = 204
    Width = 76
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 10
    Text = '0.0'
  end
  object NullFE1: TFloatEdit
    Left = 384
    Top = 205
    Width = 68
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 11
    Text = '0.0'
  end
  object NullFE2: TFloatEdit
    Left = 475
    Top = 205
    Width = 76
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 12
    Text = '0.0'
  end
  object NullBtn: TButton
    Left = 555
    Top = 206
    Width = 136
    Height = 24
    Hint = #1042#1099#1073#1088#1072#1090#1100' '#1080#1085#1090#1077#1088#1074#1072#1083' '#1076#1083#1103' '#1074#1099#1095#1080#1089#1083#1077#1085#1080#1103' '#1089#1084#1077#1097#1077#1085#1080#1103' '#1085#1091#1083#1103
    Anchors = [akLeft, akBottom]
    Caption = #1042#1099#1073#1088#1072#1090#1100' '#1087#1086' '#1082#1091#1088#1089#1086#1088#1091
    ParentShowHint = False
    ShowHint = True
    TabOrder = 13
    OnClick = SelectIntervalCursorBtnClick
  end
  object SelectIntervalGraphBtn: TButton
    Left = 206
    Top = 206
    Width = 127
    Height = 25
    Hint = #1042#1099#1073#1088#1072#1090#1100' '#1080#1085#1090#1077#1088#1074#1072#1083' '#1076#1083#1103' '#1074#1099#1095#1080#1089#1083#1077#1085#1080#1103' '#1084#1072#1090#1088#1080#1094#1099
    Anchors = [akLeft, akBottom]
    Caption = #1044#1080#1072#1087#1072#1079#1086#1085' '#1075#1088#1072#1092#1080#1082#1072
    ParentShowHint = False
    ShowHint = True
    TabOrder = 14
    OnClick = SelectIntervalGraphBtnClick
  end
  object OpenDialog1: TOpenDialog
    Filter = 'mera '#1092#1072#1081#1083'|*.mera'
    Left = 56
    Top = 72
  end
end
