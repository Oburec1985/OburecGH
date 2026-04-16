object SubRegsFrm: TSubRegsFrm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1091#1077#1084#1099#1081' '#1079#1072#1084#1077#1088':'
  ClientHeight = 170
  ClientWidth = 348
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object Label3: TLabel
    Left = 3
    Top = 7
    Width = 108
    Height = 12
    Caption = #1044#1083#1080#1085#1072' '#1080#1085#1090#1077#1088#1074#1072#1083#1072', '#1089#1077#1082'.'
  end
  object Label14: TLabel
    Left = 3
    Top = 55
    Width = 166
    Height = 12
    Caption = #1055#1088#1086#1087#1091#1089#1082' '#1084#1077#1078#1076#1091' '#1080#1085#1090#1077#1088#1074#1072#1083#1072#1084#1080', '#1089#1077#1082'.'
  end
  object BandLengthFE: TFloatEdit
    Left = 3
    Top = 28
    Width = 119
    Height = 20
    TabOrder = 0
    Text = '1'
  end
  object BandIntervalShiftFE: TFloatEdit
    Left = 3
    Top = 76
    Width = 119
    Height = 20
    TabOrder = 1
    Text = '0'
  end
  object SubdivBtn: TButton
    Left = 7
    Top = 139
    Width = 115
    Height = 25
    Caption = #1056#1072#1079#1076#1077#1083#1080#1090#1100
    TabOrder = 2
    OnClick = SubdivBtnClickTimer
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 50
    OnTimer = SubdivBtnClickTimer
    Left = 272
    Top = 120
  end
end
