object GenFreqForm: TGenFreqForm
  Left = 0
  Top = 140
  Caption = 'GenFreqForm'
  ClientHeight = 639
  ClientWidth = 678
  Color = clInactiveBorder
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  DesignSize = (
    678
    639)
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 454
    Top = 63
    Width = 90
    Height = 13
    Caption = #1042#1088#1077#1084#1103' '#1086#1090#1088#1080#1089#1086#1074#1082#1080':'
  end
  object SpeedButton1: TSpeedButton
    Left = 242
    Top = 59
    Width = 191
    Height = 25
    AllowAllUp = True
    GroupIndex = -1
    Caption = #1052#1072#1089#1096#1090#1072#1073#1080#1088#1086#1074#1072#1090#1100' '#1086#1089#1080
    OnClick = SpeedButton1Click
  end
  object Label8: TLabel
    Left = 8
    Top = 481
    Width = 93
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1055#1077#1088#1080#1086#1076' '#1074#1080#1073#1088#1072#1094#1080#1080':'
  end
  object GetDataBtn: TButton
    Left = 483
    Top = 609
    Width = 192
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1047#1072#1076#1072#1090#1100' '#1079#1072#1082#1086#1085' '#1080#1079#1084#1077#1085#1077#1085#1080#1103' '#1095#1072#1089#1090#1086#1090#1099
    ModalResult = 1
    TabOrder = 0
    ExplicitTop = 568
  end
  object CancelBtn: TButton
    Left = 8
    Top = 609
    Width = 217
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    ModalResult = 2
    TabOrder = 1
    ExplicitTop = 568
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 501
    Width = 217
    Height = 50
    Anchors = [akLeft, akBottom]
    Caption = #1064#1072#1075' '#1076#1080#1089#1082#1088#1077#1090#1080#1079#1072#1094#1080#1080' '#1089#1080#1075#1085#1072#1083#1072' '#1095#1072#1089#1090#1086#1090#1099
    Color = 10923223
    ParentColor = False
    TabOrder = 2
    ExplicitTop = 463
    object UnitsComboBox: TComboBox
      Left = 95
      Top = 17
      Width = 74
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = #1057#1077#1082
      Items.Strings = (
        #1057#1077#1082
        #1043#1094)
    end
    object FloatEdit1: TFloatEdit
      Left = 37
      Top = 17
      Width = 52
      Height = 21
      TabOrder = 1
      Text = '0,1'
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 217
    Height = 49
    Caption = #1050#1086#1086#1088#1076#1080#1085#1072#1090#1099' '#1090#1086#1095#1082#1080' '#1074' '#1077#1076'. '#1095#1072#1088#1090#1072
    Color = 10923223
    ParentColor = False
    TabOrder = 3
    object Label1: TLabel
      Left = 5
      Top = 22
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label2: TLabel
      Left = 101
      Top = 22
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object XPosEdit: TEdit
      Left = 21
      Top = 19
      Width = 70
      Height = 21
      TabOrder = 0
    end
    object YPosEdit: TEdit
      Left = 117
      Top = 19
      Width = 70
      Height = 21
      TabOrder = 1
    end
  end
  object GroupBox3: TGroupBox
    Left = 454
    Top = 8
    Width = 217
    Height = 49
    Caption = #1050#1086#1086#1088#1076#1080#1085#1072#1090#1099' '#1082#1091#1088#1089#1086#1088#1072
    Color = 10923223
    ParentColor = False
    TabOrder = 5
    object Label3: TLabel
      Left = 5
      Top = 22
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label4: TLabel
      Left = 101
      Top = 22
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object CursorXPosEdit: TEdit
      Left = 21
      Top = 19
      Width = 70
      Height = 21
      TabOrder = 0
    end
    object CursorYPosEdit: TEdit
      Left = 117
      Top = 19
      Width = 70
      Height = 21
      TabOrder = 1
    end
  end
  object GroupBox4: TGroupBox
    Left = 231
    Top = 8
    Width = 217
    Height = 49
    Caption = #1050#1086#1086#1088#1076#1080#1085#1072#1090#1099' '#1090#1086#1095#1082#1080'. '#1042' '#1087#1080#1082#1089#1077#1083#1103#1093
    Color = 10923223
    ParentColor = False
    TabOrder = 4
    object Label5: TLabel
      Left = 5
      Top = 22
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label6: TLabel
      Left = 101
      Top = 22
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object iXPosEdit: TEdit
      Left = 24
      Top = 19
      Width = 70
      Height = 21
      TabOrder = 0
    end
    object iYPosEdit: TEdit
      Left = 117
      Top = 19
      Width = 70
      Height = 21
      TabOrder = 1
    end
  end
  object Edit1: TEdit
    Left = 546
    Top = 63
    Width = 125
    Height = 21
    TabOrder = 6
  end
  object cGlChart1: cGlChart
    Left = 6
    Top = 90
    Width = 664
    Height = 382
    onBeforeDrawChart = cGlChart1BeforeDrawChart
    onBeforeUpdateAxisByText = cGlChart1BeforeUpdateAxisByText
    onUpdateAxisByText = cGlChart1UpdateAxisByText
    BeforeSetPoint = cGlChart1BeforeSetPoint
    OnChangePointsType = cGlChart1ChangePointsType
    OnRemove = cGlChart1Remove
    OnRefine = cGlChart1Refine
    OnClick = cGlChart1Click
    OnPaint = cGlChart1Paint
    OnMoove = cGlChart1Moove
  end
  object ChangeChartTargetButton: TButton
    Left = 8
    Top = 574
    Width = 217
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = #1047#1072#1082#1086#1085' '#1080#1079#1084#1077#1085#1077#1085#1080#1103' '#1095#1072#1089#1090#1086#1090#1099'/ '#1074#1080#1073#1088#1072#1094#1080#1080
    TabOrder = 8
    OnClick = ChangeChartTargetButtonClick
    ExplicitTop = 536
  end
  object TVibrEdit: TEdit
    Left = 100
    Top = 478
    Width = 77
    Height = 22
    Anchors = [akLeft, akBottom]
    TabOrder = 9
    OnChange = TVibrEditChange
    ExplicitTop = 440
  end
  object GroupBox5: TGroupBox
    Left = 231
    Top = 478
    Width = 394
    Height = 122
    Anchors = [akLeft, akBottom]
    Caption = #1055#1088#1077#1076#1087#1088#1086#1089#1084#1086#1090#1088
    Color = 10923223
    ParentColor = False
    TabOrder = 10
    ExplicitTop = 440
    object Label9: TLabel
      Left = 180
      Top = 34
      Width = 57
      Height = 13
      Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
    end
    object Label10: TLabel
      Left = 5
      Top = 17
      Width = 242
      Height = 13
      Caption = #1056#1072#1089#1095#1077#1090' '#1090#1086#1095#1077#1082', '#1082#1086#1090#1086#1088#1099#1077' '#1073#1091#1076#1091#1090' '#1079#1072#1087#1080#1089#1072#1085#1099' '#1074' '#1092#1072#1081#1083
    end
    object Label12: TLabel
      Left = 6
      Top = 70
      Width = 34
      Height = 13
      Caption = 't1, '#1089#1077#1082
    end
    object Label13: TLabel
      Left = 6
      Top = 95
      Width = 34
      Height = 13
      Caption = 't2, '#1089#1077#1082
    end
    object Label11: TLabel
      Left = 180
      Top = 50
      Width = 74
      Height = 13
      Caption = #1076#1072#1090#1095#1080#1082#1072' '#1075#1088#1072#1076'.'
    end
    object Label15: TLabel
      Left = 6
      Top = 50
      Width = 42
      Height = 13
      Caption = #1083#1086#1087#1072#1090#1082#1080
    end
    object Label14: TLabel
      Left = 6
      Top = 34
      Width = 57
      Height = 13
      Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
    end
    object Label16: TLabel
      Left = 214
      Top = 69
      Width = 38
      Height = 13
      Caption = #1055#1077#1088#1080#1086#1076
    end
    object SensorPosEdit: TFloatEdit
      Left = 260
      Top = 39
      Width = 79
      Height = 21
      TabOrder = 0
      Text = '15'
    end
    object StartTimeEdit: TFloatEdit
      Left = 82
      Top = 67
      Width = 79
      Height = 21
      TabOrder = 1
      Text = '0.0'
    end
    object EndTimeEdit: TFloatEdit
      Left = 82
      Top = 93
      Width = 79
      Height = 21
      TabOrder = 2
      Text = '3'
    end
    object BladePosEdit: TFloatEdit
      Left = 82
      Top = 40
      Width = 79
      Height = 21
      TabOrder = 3
      Text = '0.0'
    end
    object Button1: TButton
      Left = 260
      Top = 93
      Width = 75
      Height = 25
      Caption = #1056#1072#1089#1095#1077#1090
      TabOrder = 4
      OnClick = ViewPointsClick
    end
    object PeriodFloatEdit: TFloatEdit
      Left = 260
      Top = 66
      Width = 35
      Height = 21
      TabOrder = 5
      Text = '15'
    end
    object AutoTCheckBox: TCheckBox
      Left = 301
      Top = 68
      Width = 97
      Height = 17
      Caption = #1040#1074#1090#1086
      TabOrder = 6
    end
  end
end
