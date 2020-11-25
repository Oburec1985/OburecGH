object GenSignalsEditFrm: TGenSignalsEditFrm
  Left = 0
  Top = 0
  Caption = #1057#1086#1079#1076#1072#1090#1100' '#1089#1080#1075#1085#1072#1083
  ClientHeight = 253
  ClientWidth = 314
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 16
  object AmpLabel: TLabel
    Left = 105
    Top = 50
    Width = 113
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072' '#1089#1080#1075#1085#1072#1083#1072
  end
  object FreqLabel: TLabel
    Left = 105
    Top = 95
    Width = 97
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1089#1080#1075#1085#1072#1083#1072
  end
  object PhaseLabel: TLabel
    Left = 105
    Top = 140
    Width = 68
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1060#1072#1079#1072', '#1075#1088#1072#1076'.'
  end
  object Label1: TLabel
    Left = 12
    Top = 3
    Width = 73
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1048#1084#1103' '#1089#1080#1075#1085#1072#1083#1072
  end
  object FsLabel: TLabel
    Left = 210
    Top = 3
    Width = 73
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1048#1084#1103' '#1089#1080#1075#1085#1072#1083#1072
  end
  object Label2: TLabel
    Left = 105
    Top = 184
    Width = 62
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077
  end
  object NameEdit: TEdit
    Left = 6
    Top = 20
    Width = 174
    Height = 24
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 0
    Text = 'GenSignal_001'
  end
  object STypeRG: TRadioGroup
    Left = 6
    Top = 50
    Width = 79
    Height = 127
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1058#1080#1087' '#1089#1080#1075#1085#1072#1083#1072
    ItemIndex = 0
    Items.Strings = (
      #1057#1080#1085#1091#1089
      #1055#1080#1083#1072
      #1064#1059#1084)
    TabOrder = 1
  end
  object AmpSE: TFloatSpinEdit
    Left = 105
    Top = 67
    Width = 91
    Height = 26
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Increment = 0.100000000000000000
    TabOrder = 2
    Value = 1.000000000000000000
  end
  object FreqSE: TFloatSpinEdit
    Left = 105
    Top = 111
    Width = 91
    Height = 26
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Increment = 0.100000000000000000
    TabOrder = 3
    Value = 10.000000000000000000
  end
  object PhaseSE: TFloatSpinEdit
    Left = 105
    Top = 157
    Width = 91
    Height = 26
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Increment = 0.100000000000000000
    TabOrder = 4
  end
  object FsEdit: TFloatEdit
    Left = 210
    Top = 20
    Width = 90
    Height = 24
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 5
    Text = '1000'
  end
  object CreateSignalBtn: TButton
    Left = 210
    Top = 203
    Width = 90
    Height = 26
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 6
    OnClick = CreateSignalBtnClick
  end
  object OffsetFE: TFloatSpinEdit
    Left = 105
    Top = 204
    Width = 91
    Height = 26
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Increment = 0.100000000000000000
    TabOrder = 7
  end
end
