object GenFrm: TGenFrm
  Left = 0
  Top = 0
  Caption = #1043#1077#1085#1077#1088#1072#1090#1086#1088
  ClientHeight = 596
  ClientWidth = 638
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ActionGB: TGroupBox
    Left = 0
    Top = 288
    Width = 638
    Height = 252
    Align = alBottom
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1089#1080#1075#1085#1072#1083#1072
    TabOrder = 0
    object FSLabel: TLabel
      Left = 20
      Top = 70
      Width = 122
      Height = 13
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1076#1080#1089#1082#1088#1077#1090#1080#1079#1072#1094#1080#1080
    end
    object LengthLabel: TLabel
      Left = 20
      Top = 118
      Width = 85
      Height = 13
      Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100', '#1089
    end
    object Label2: TLabel
      Left = 20
      Top = 19
      Width = 55
      Height = 13
      Caption = #1060#1072#1079#1072', '#1088#1072#1076'.'
    end
    object FSse: TSpinEdit
      Left = 20
      Top = 93
      Width = 121
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 10000
    end
    object LengthSE: TFloatSpinEdit
      Left = 20
      Top = 137
      Width = 121
      Height = 22
      Increment = 0.100000000000000000
      TabOrder = 1
      Value = 10.000000000000000000
    end
    object GroupBox2: TGroupBox
      Left = 469
      Top = 15
      Width = 167
      Height = 235
      Align = alRight
      Caption = #1052#1077#1085#1103#1090#1100' '#1095#1072#1089#1090#1086#1090#1091
      TabOrder = 2
      object F1Label: TLabel
        Left = 8
        Top = 128
        Width = 101
        Height = 13
        Caption = #1053#1072#1095'. '#1095#1072#1089#1090#1086#1090#1072' F1, '#1043#1094
      end
      object F2Label: TLabel
        Left = 8
        Top = 172
        Width = 119
        Height = 13
        Caption = #1050#1086#1085#1077#1095#1085'. '#1095#1072#1089#1090#1086#1090#1072' F2, '#1043#1094
      end
      object F1SE: TFloatSpinEdit
        Left = 8
        Top = 147
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 0
        Value = 10.000000000000000000
      end
      object F2SE: TFloatSpinEdit
        Left = 8
        Top = 191
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 1
        Value = 1000.000000000000000000
      end
      object FreqRG: TRadioGroup
        Left = 8
        Top = 19
        Width = 153
        Height = 105
        ItemIndex = 0
        Items.Strings = (
          #1055#1086#1089#1090#1086#1103#1085#1085#1072#1103' '#1095#1072#1089#1090#1086#1090#1072
          #1051#1080#1085#1077#1081#1085#1099#1081' '#1079#1072#1082#1086#1085
          #1069#1082#1089#1087#1086#1085#1077#1085#1094#1080#1072#1083#1100#1085#1099#1081)
        TabOrder = 2
        OnClick = FreqRGClick
      end
    end
    object PhaseSE: TSpinEdit
      Left = 20
      Top = 42
      Width = 121
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
    end
    object GroupBox3: TGroupBox
      Left = 301
      Top = 15
      Width = 168
      Height = 235
      Align = alRight
      Caption = #1052#1077#1085#1103#1090#1100' '#1072#1084#1087#1083#1080#1090#1091#1076#1091
      TabOrder = 4
      object A1Label: TLabel
        Left = 8
        Top = 128
        Width = 13
        Height = 13
        Caption = 'A1'
      end
      object A2Label: TLabel
        Left = 8
        Top = 172
        Width = 13
        Height = 13
        Caption = 'A2'
      end
      object A1se: TFloatSpinEdit
        Left = 8
        Top = 147
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 0
        Value = 1.000000000000000000
      end
      object A2se: TFloatSpinEdit
        Left = 8
        Top = 191
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 1
        Value = 10.000000000000000000
      end
      object AmpRG: TRadioGroup
        Left = 8
        Top = 19
        Width = 153
        Height = 105
        ItemIndex = 0
        Items.Strings = (
          #1055#1086#1089#1090#1086#1103#1085#1085#1072#1103' '#1072#1084#1087#1083#1080#1090#1091#1076#1072
          #1051#1080#1085#1077#1081#1085#1099#1081' '#1079#1072#1082#1086#1085
          #1069#1082#1089#1087#1086#1085#1077#1085#1094#1080#1072#1083#1100#1085#1099#1081)
        TabOrder = 2
        OnClick = AmpRGClick
      end
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 638
    Height = 288
    ActivePage = MeandrTS
    Align = alClient
    TabOrder = 1
    object MeandrTS: TTabSheet
      Caption = #1052#1077#1072#1085#1076#1088
      object Label1: TLabel
        Left = 16
        Top = 16
        Width = 195
        Height = 13
        Caption = #1057#1082#1074#1072#1078#1085#1086#1089#1090#1100' ('#1055#1077#1088#1080#1086#1076'/'#1044#1083#1080#1090'. '#1080#1084#1087#1091#1083#1100#1089#1072')'
      end
      object SKse: TFloatSpinEdit
        Left = 16
        Top = 34
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 0
        Value = 2.000000000000000000
      end
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 540
    Width = 638
    Height = 56
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 2
    DesignSize = (
      638
      56)
    object Button1: TButton
      Left = 22
      Top = 28
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object Button2: TButton
      Left = 551
      Top = 24
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end
