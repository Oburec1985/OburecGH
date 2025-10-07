object GenSignalsEditFrm: TGenSignalsEditFrm
  Left = 0
  Top = 0
  Caption = #1057#1086#1079#1076#1072#1090#1100' '#1089#1080#1075#1085#1072#1083
  ClientHeight = 300
  ClientWidth = 395
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 19
  object AmpLabel: TLabel
    Left = 125
    Top = 59
    Width = 35
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1040#1084#1087'.'
  end
  object FreqLabel: TLabel
    Left = 125
    Top = 113
    Width = 35
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'F, '#1043#1094
  end
  object PhaseLabel: TLabel
    Left = 125
    Top = 166
    Width = 83
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1060#1072#1079#1072', '#1075#1088#1072#1076'.'
  end
  object Label1: TLabel
    Left = 14
    Top = 4
    Width = 91
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1048#1084#1103' '#1089#1080#1075#1085#1072#1083#1072
  end
  object FsLabel: TLabel
    Left = 249
    Top = 4
    Width = 21
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Fs:'
  end
  object Label2: TLabel
    Left = 125
    Top = 219
    Width = 75
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077
  end
  object F2SweepLabel: TLabel
    Left = 217
    Top = 113
    Width = 44
    Height = 19
    Caption = 'F2, '#1043#1094
  end
  object SweepTimeLabel: TLabel
    Left = 293
    Top = 113
    Width = 52
    Height = 19
    Caption = 'T2, '#1089#1077#1082
  end
  object NameEdit: TEdit
    Left = 7
    Top = 24
    Width = 207
    Height = 27
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 0
    Text = 'GenSignal_001'
  end
  object STypeRG: TRadioGroup
    Left = 7
    Top = 59
    Width = 94
    Height = 151
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
    Left = 125
    Top = 80
    Width = 80
    Height = 29
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Increment = 0.100000000000000000
    TabOrder = 2
    Value = 1.000000000000000000
  end
  object FreqSE: TFloatSpinEdit
    Left = 125
    Top = 132
    Width = 80
    Height = 29
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Increment = 0.100000000000000000
    TabOrder = 3
    Value = 10.000000000000000000
  end
  object PhaseSE: TFloatSpinEdit
    Left = 125
    Top = 186
    Width = 80
    Height = 29
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Increment = 0.100000000000000000
    TabOrder = 4
  end
  object FsEdit: TFloatEdit
    Left = 249
    Top = 24
    Width = 107
    Height = 27
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 5
    Text = '1000'
  end
  object CreateSignalBtn: TButton
    Left = 249
    Top = 241
    Width = 107
    Height = 31
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 6
    OnClick = CreateSignalBtnClick
  end
  object OffsetFE: TFloatSpinEdit
    Left = 125
    Top = 242
    Width = 80
    Height = 29
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Increment = 0.100000000000000000
    TabOrder = 7
  end
  object Freq2Fe: TFloatSpinEdit
    Left = 217
    Top = 132
    Width = 67
    Height = 29
    Increment = 5.000000000000000000
    TabOrder = 8
  end
  object TimeSe: TFloatSpinEdit
    Left = 293
    Top = 132
    Width = 70
    Height = 29
    Increment = 0.100000000000000000
    TabOrder = 9
    Value = 100.000000000000000000
  end
  object SweepSinCB: TCheckBox
    Left = 217
    Top = 85
    Width = 71
    Height = 17
    Caption = 'Sweep'
    Checked = True
    State = cbChecked
    TabOrder = 10
  end
  object SweepLgCB: TCheckBox
    Left = 293
    Top = 80
    Width = 54
    Height = 27
    Caption = 'Lg'
    Checked = True
    State = cbChecked
    TabOrder = 11
  end
end
