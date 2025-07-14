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
  object TabControl: TPageControl
    Left = 0
    Top = 0
    Width = 638
    Height = 288
    ActivePage = ShockPage
    Align = alClient
    TabOrder = 1
    ExplicitTop = -6
    object MeandrTS: TTabSheet
      Caption = #1052#1077#1072#1085#1076#1088
      ExplicitLeft = 6
      ExplicitTop = 22
      object Label1: TLabel
        Left = 16
        Top = 15
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
    object ShockPage: TTabSheet
      Caption = 'Shock'
      ImageIndex = 1
      ExplicitLeft = 5
      ExplicitTop = 22
      object AmplImpactLabel: TLabel
        Left = 18
        Top = 49
        Width = 61
        Height = 13
        Caption = 'Ampl. impact'
      end
      object RefAmpl: TLabel
        Left = 18
        Top = 105
        Width = 44
        Height = 13
        Caption = 'Ampl ref.'
      end
      object ShockCountL: TLabel
        Left = 18
        Top = 151
        Width = 57
        Height = 13
        Caption = 'ShockCount'
      end
      object RefLenL: TLabel
        Left = 162
        Top = 105
        Width = 38
        Height = 13
        Caption = 'Ref. len'
      end
      object ImpactLenL: TLabel
        Left = 162
        Top = 49
        Width = 50
        Height = 13
        Caption = 'Impact len'
      end
      object RefShiftL: TLabel
        Left = 305
        Top = 105
        Width = 45
        Height = 13
        Caption = 'Ref. shift'
      end
      object FsLab: TLabel
        Left = 18
        Top = 2
        Width = 61
        Height = 13
        Caption = 'Ampl. impact'
      end
      object PauseLabel: TLabel
        Left = 18
        Top = 201
        Width = 38
        Height = 13
        Caption = 'Ref. len'
      end
      object AmplImpact: TFloatSpinEdit
        Left = 18
        Top = 68
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 0
        Value = 2.000000000000000000
      end
      object AmplRefFE: TFloatSpinEdit
        Left = 18
        Top = 124
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 1
        Value = 1.000000000000000000
      end
      object RefLenE: TFloatSpinEdit
        Left = 162
        Top = 124
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 2
        Value = 0.030000000000000000
      end
      object ImpactLenSE: TFloatSpinEdit
        Left = 162
        Top = 68
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 3
        Value = 0.030000000000000000
      end
      object RefShiftSE: TFloatSpinEdit
        Left = 305
        Top = 124
        Width = 121
        Height = 22
        Increment = 0.003000000000000000
        TabOrder = 4
        Value = 0.003000000000000000
      end
      object FsFe: TFloatSpinEdit
        Left = 18
        Top = 21
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 5
        Value = 57600.000000000000000000
      end
      object ImpactE: TEdit
        Left = 305
        Top = 21
        Width = 121
        Height = 21
        TabOrder = 6
        Text = 'Impact'
      end
      object RefNameE: TEdit
        Left = 305
        Top = 68
        Width = 121
        Height = 21
        TabOrder = 7
        Text = 'Ref'
      end
      object PauseFe: TFloatSpinEdit
        Left = 17
        Top = 220
        Width = 121
        Height = 22
        Increment = 0.100000000000000000
        TabOrder = 8
        Value = 1.000000000000000000
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
    object CancelBtn: TButton
      Left = 22
      Top = 28
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 560
      Top = 28
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
  object ShockCountIE: TSpinEdit
    Left = 22
    Top = 194
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 3
    Value = 2
  end
end
