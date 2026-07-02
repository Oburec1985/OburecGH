object GistFrame: TGistFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object ColSizeLabel: TLabel
    Left = 235
    Top = 34
    Width = 80
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088' '#1084#1072#1088#1082#1077#1088#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object MarkerColorLabel: TLabel
    Left = 235
    Top = 58
    Width = 44
    Height = 13
    Caption = #1042#1077#1088#1096#1080#1085#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object MarkerSizeLabel: TLabel
    Left = 235
    Top = 6
    Width = 80
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088' '#1084#1072#1088#1082#1077#1088#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object ColSizeSE: TSpinEdit
    Left = 321
    Top = 31
    Width = 135
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 0
    Value = 0
  end
  object GistTypeRG: TRadioGroup
    Left = 11
    Top = 3
    Width = 221
    Height = 56
    Caption = #1054#1090#1088#1080#1089#1086#1074#1082#1072' '#1075#1080#1089#1090#1086#1075#1088#1072#1084#1084#1099
    Items.Strings = (
      #1057#1090#1086#1083#1073#1094#1099
      #1058#1086#1095#1082#1080)
    TabOrder = 1
  end
  object MarkerColorBox: TPanel
    Left = 235
    Top = 79
    Width = 64
    Height = 25
    Color = clCream
    ParentBackground = False
    TabOrder = 2
    OnClick = MarkerColorBoxClick
  end
  object MarkerSizeSE: TSpinEdit
    Left = 321
    Top = 3
    Width = 135
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object MarkerTypeRG: TRadioGroup
    Left = 11
    Top = 58
    Width = 221
    Height = 110
    Caption = #1054#1090#1088#1080#1089#1086#1074#1082#1072' '#1084#1072#1088#1082#1077#1088#1086#1074
    Items.Strings = (
      #1087#1088#1103#1084#1086#1091#1086#1083#1100#1085#1080#1082
      #1087#1088#1103#1084#1086#1091#1086#1083#1100#1085#1080#1082' '#1080' '#1075#1088#1072#1085#1080#1094#1099
      #1087#1091#1089#1090#1086#1081' '#1087#1088#1103#1084#1086#1091#1075#1086#1083#1100#1085#1080#1082
      #1050#1088#1091#1075)
    TabOrder = 4
  end
  object BackGroundColorDialog: TColorDialog
    Left = 312
    Top = 90
  end
end
