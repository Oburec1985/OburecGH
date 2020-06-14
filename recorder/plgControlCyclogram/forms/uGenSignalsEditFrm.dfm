object GenSignalsEditFrm: TGenSignalsEditFrm
  Left = 0
  Top = 0
  Caption = #1057#1086#1079#1076#1072#1090#1100' '#1089#1080#1075#1085#1072#1083
  ClientHeight = 268
  ClientWidth = 383
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object AmpLabel: TLabel
    Left = 119
    Top = 56
    Width = 113
    Height = 16
    Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072' '#1089#1080#1075#1085#1072#1083#1072
  end
  object FreqLabel: TLabel
    Left = 119
    Top = 105
    Width = 97
    Height = 16
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1089#1080#1075#1085#1072#1083#1072
  end
  object PhaseLabel: TLabel
    Left = 119
    Top = 160
    Width = 68
    Height = 16
    Caption = #1060#1072#1079#1072', '#1075#1088#1072#1076'.'
  end
  object Label1: TLabel
    Left = 16
    Top = 4
    Width = 73
    Height = 16
    Caption = #1048#1084#1103' '#1089#1080#1075#1085#1072#1083#1072
  end
  object FsLabel: TLabel
    Left = 254
    Top = 4
    Width = 73
    Height = 16
    Caption = #1048#1084#1103' '#1089#1080#1075#1085#1072#1083#1072
  end
  object NameEdit: TEdit
    Left = 8
    Top = 26
    Width = 232
    Height = 24
    TabOrder = 0
    Text = 'GenSignal_001'
  end
  object STypeRG: TRadioGroup
    Left = 8
    Top = 56
    Width = 105
    Height = 105
    Caption = #1058#1080#1087' '#1089#1080#1075#1085#1072#1083#1072
    ItemIndex = 0
    Items.Strings = (
      #1057#1080#1085#1091#1089
      #1055#1080#1083#1072
      #1064#1059#1084)
    TabOrder = 1
  end
  object AmpSE: TFloatSpinEdit
    Left = 119
    Top = 78
    Width = 121
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 2
  end
  object FreqSE: TFloatSpinEdit
    Left = 119
    Top = 127
    Width = 121
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 3
  end
  object PhaseSE: TFloatSpinEdit
    Left = 119
    Top = 182
    Width = 121
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 4
  end
  object FsEdit: TFloatEdit
    Left = 254
    Top = 26
    Width = 121
    Height = 24
    TabOrder = 5
    Text = '1000'
  end
  object CreateSignalBtn: TButton
    Left = 280
    Top = 235
    Width = 95
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 6
    OnClick = CreateSignalBtnClick
  end
end
